# Rancangan Program: COA Gabungan per Alias (ZQMI_COA)

> Turunan teknis dari [BLUEPRINT_ALIAS_MAPPING_ZQM002.md](BLUEPRINT_ALIAS_MAPPING_ZQM002.md). **Ini rancangan, bukan perubahan.** Program DEV tidak disentuh sampai ada perintah "execute".
> Dasar baris: `src/ZQMI_COA_{TOP,F01,F02}_group.abap` dan `outputs/ZQMI_COA_ALV_Development AIX_alias20261112.abap` (fetch DEV 12 Nov 2026). Re-fetch DEV dan cocokkan ulang nomor baris sebelum execute.
> Disusun 13 Nov 2026.

## 0. Ide Utama: "Baca dengan MIC batch, tampilkan dengan MIC alias"

Program sekarang membaca nilai QM lewat `IT_ZMAP-MIC` (GET_MIC → QAMV/QAMR), lalu semua proses setelahnya (rata-rata, limit, ZLOG_COA, EXEC, print) memakai `IT_DATA-MIC` dan `IT_DATA-MATNR`. Rancangan ini memanfaatkan pola itu:

1. **Sebelum baca nilai:** untuk roll jalur alias, `IT_ZMAP` diisi dari mapping **material alias** yang MIC-nya sudah **diterjemahkan ke MIC batch** (PAAATSTD → PAANTSTD untuk PLE6, PAPATSTD untuk PLE7). GET_TRACED_LOTS dan GET_MIC berjalan **tanpa perubahan**.
2. **Setelah nilai terbaca:** baris diberi label COA: `IT_DATA-MIC` = MIC alias, `IT_DATA-COA_MAT` = material alias. MIC batch disimpan di `IT_DATA-BATCH_MIC`.
3. **Sesudahnya:** kunci yang tadinya `MATNR` diganti `COA_MAT`. Karena `IT_DATA-MIC` sudah MIC alias, MICFMT, LT_COA_MAP, ZLOG_COA, EXEC, dan print otomatis memakai MIC alias.

**Jalur as-is / fallback:** `COA_MAT = MATNR`, `BATCH_MIC = MIC`, `COA_PATH` = kode fallback/`ASIS`. Semua kunci baru bernilai sama dengan kunci lama, jadi hasilnya identik dengan program sekarang.

```
GET_DATA
 ├─ PHASE 2  AUSP: + ATINN ZZALIAS                         [ubah kecil]
 ├─ PERFORM ALIAS_RESOLVE  (semua roll, sebelum loop)      [FORM baru]
 │    ├─ ALIAS_CONVERT        alias → material alias (cache)
 │    ├─ ALIAS_READ_MAP       mapping material alias + customer (cache)
 │    ├─ ALIAS_TRANSLATE_MIC  MIC alias → MIC batch per MATNR (cache)
 │    ├─ ALIAS_LIMIT_PREP     spec asli per MATNR (Opsi B/C saja)
 │    └─ ALIAS_DECIDE_GROUP   status kelompok VBELN+AMAT
 ├─ PHASE 3 loop per roll
 │    ├─ jalur alias → PERFORM ALIAS_FILL_ZMAP             [ubah]
 │    └─ selain itu  → mapping material batch (as-is)
 │    GET_TRACED_LOTS / GET_MIC                             [tetap]
 ├─ loop nilai per roll: isi COA_MAT/COA_MIC di IT_MIC1, METHOD alias  [ubah kecil]
 ├─ rata-rata: kunci VBELN+COA_MAT+MIC, GET_AVG_KEY pakai BATCH_MIC     [ubah kunci]
 ├─ limit: READ LT_COA_MAP by COA_MAT, lalu PERFORM ALIAS_APPLY_LIMIT  [ubah + FORM baru]
 └─ ZLOG_COA, SET_COA_RANGE_FLAG, SORT by COA_MAT                       [tetap / ubah kunci]
F02 EXEC: MSTAT by COA_MAT, header alias, lebar dari semua roll         [ubah]
ALV ZQM003: kunci COA_MAT/COA_MIC + 3 kolom                             [ubah]
```

## 1. TOP (`ZQMI_COA_TOP`)

### 1.1 Field tambahan (struktur internal, bukan DDIC)

```abap
* IT_DATA (baris 10-44) — IT_LOT ikut karena IT_LOT LIKE IT_DATA
        COA_MAT   LIKE MARA-MATNR,          " material COA: AMAT atau MATNR
        COA_PATH  TYPE C LENGTH 7,          " ALIAS / ASIS / NOALIAS / NOCONV / NOMAP / NONE / MIXED / LIMIT
        BATCH_MIC LIKE QAMV-VERWMERKM,      " MIC asli batch (sebelum relabel)
        ALIAS     TYPE AUSP-ATWRT,          " nilai ZZALIAS roll

* IT_MIC1 (baris 46-72)
        COA_MAT   LIKE MARA-MATNR,
        COA_PATH  TYPE C LENGTH 7,
        COA_MIC   LIKE QPMK-MKMNR,          " MIC alias (= MIC untuk as-is)
```

`MOVE-CORRESPONDING IT_MIC1 TO WA_DATA` (F01 ±619) otomatis membawa `COA_MAT` dan `COA_PATH`.

### 1.2 Tabel kerja alias

```abap
CONSTANTS: GC_ALIAS_LIMIT TYPE C LENGTH 2 VALUE 'A'.  " diisi sesuai keputusan QA: A / B1 / B2 / C (lihat §6)

DATA: GV_ATINN_ALIAS TYPE CABN-ATINN.

* Status per roll (diisi ALIAS_RESOLVE)
TYPES: BEGIN OF TY_AROLL,
         VBELN TYPE LIPS-VBELN,
         POSNR TYPE LIPS-POSNR,
         CHARG TYPE LIPS-CHARG,
         MATNR TYPE MARA-MATNR,
         ALIAS TYPE AUSP-ATWRT,
         AMAT  TYPE MARA-MATNR,
         PATH  TYPE C LENGTH 7,
       END OF TY_AROLL.
DATA: GT_AROLL TYPE SORTED TABLE OF TY_AROLL
        WITH UNIQUE KEY VBELN POSNR CHARG,
      GS_AROLL TYPE TY_AROLL.

* Status per kelompok COA (VBELN + AMAT)
TYPES: BEGIN OF TY_AGRP,
         VBELN  TYPE LIPS-VBELN,
         AMAT   TYPE MARA-MATNR,
         ALIAS  TYPE AUSP-ATWRT,
         STATUS TYPE C LENGTH 7,            " ALIAS atau kode fallback
         NMAT   TYPE I,                     " jumlah tipe produksi
         MSG    TYPE STRING,                " alasan (untuk pesan & log)
       END OF TY_AGRP.
DATA: GT_AGRP TYPE SORTED TABLE OF TY_AGRP WITH UNIQUE KEY VBELN AMAT,
      GS_AGRP TYPE TY_AGRP.

* Mapping material alias (sudah merge umum + customer), per VBELN + AMAT
* Field sama dengan IT_ZMAP + VBELN; MATNR berisi AMAT, MIC berisi MIC alias
DATA: BEGIN OF GT_AMAP OCCURS 0,
        VBELN LIKE LIPS-VBELN.
        INCLUDE STRUCTURE IT_ZMAP.          " MATNR MIC KUNNR METHOD MAPPING UOM MIC_DESC LOWER/UPPER SEQ_NO NUM
DATA: END OF GT_AMAP.

* Terjemahan MIC per tipe produksi
TYPES: BEGIN OF TY_AMIC,
         VBELN  TYPE LIPS-VBELN,
         AMAT   TYPE MARA-MATNR,
         MATNR  TYPE MARA-MATNR,            " tipe produksi (material batch)
         AMIC   TYPE QPMK-MKMNR,            " MIC alias
         BMIC   TYPE QPMK-MKMNR,            " MIC batch hasil terjemahan
         HOW    TYPE C LENGTH 6,            " EXACT / RULE / SUFFIX / DESC / SAME / NONE
         CHK    TYPE C,                     " X = cek silang deskripsi beda
         LOW    TYPE QPMK-TOLERANZUN,       " spec asli MIC batch (Opsi B/C)
         HIGH   TYPE QPMK-TOLERANZOB,
         HASLO  TYPE C,                     " X = lower terisi
         HASHI  TYPE C,                     " X = upper terisi
         CNT    TYPE I,                     " Opsi C: jumlah lot unik ber-hasil (bobot)
       END OF TY_AMIC.
DATA: GT_AMIC TYPE SORTED TABLE OF TY_AMIC
        WITH UNIQUE KEY VBELN AMAT MATNR AMIC,
      GS_AMIC TYPE TY_AMIC.
* Index balik untuk relabel: (VBELN, MATNR, BMIC) -> AMIC
DATA: GT_AMIC_B TYPE SORTED TABLE OF TY_AMIC
        WITH NON-UNIQUE KEY VBELN MATNR BMIC.

* Cache (lintas DO, terutama ZQM003 rentang tanggal)
TYPES: BEGIN OF TY_ACONV,
         ALIAS TYPE AUSP-ATWRT,
         PFX   TYPE C LENGTH 2,
         LAST  TYPE C LENGTH 1,
         AMAT  TYPE MARA-MATNR,
         VIA   TYPE C LENGTH 6,
       END OF TY_ACONV.
DATA: GT_ACONV TYPE SORTED TABLE OF TY_ACONV WITH UNIQUE KEY ALIAS PFX LAST.

* Log alasan (untuk investigasi; ditampilkan lewat pesan S / tidak disimpan DB)
DATA: GT_ALOG TYPE STANDARD TABLE OF STRING.
```

> `INCLUDE STRUCTURE` di atas hanya ilustrasi. Saat execute, pakai pola yang sama dengan `IT_ZMAP` (OCCURS + field LIKE ZMAP_COA-...) agar konsisten dengan gaya program.

## 2. F01 `GET_DATA`: titik perubahan

### 2.1 PHASE 2 — baca ZZALIAS bersama karakteristik lain (±346)

```abap
  IF GV_ATINN_ALIAS IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING INPUT = 'ZZALIAS'
      IMPORTING OUTPUT = GV_ATINN_ALIAS.
  ENDIF.
  ...
        AND ( ATINN = ATINN_ROLL OR ATINN = ATINN_CODE OR
              ATINN = ATINN_WIDTH OR ATINN = ATINN_LENGTH OR
              ATINN = GV_ATINN_ALIAS )                       " <-- tambah
```

Tidak mengubah pembacaan lain, karena semua `READ TABLE IT_AUSP` memakai kunci OBJEK + ATINN.

### 2.2 Panggil ALIAS_RESOLVE sebelum PHASE 3 (±359)

```abap
  REFRESH GT_LOT_AVG.
  REFRESH GT_AVGKEY.
  PERFORM ALIAS_RESOLVE.                                     " <-- baru
  LOOP AT IT_DATA.
```

### 2.3 PHASE 3 — pilih sumber IT_ZMAP (±395–451)

```abap
    " cari status roll
    CLEAR GS_AROLL.
    READ TABLE GT_AROLL INTO GS_AROLL
      WITH TABLE KEY VBELN = IT_DATA-VBELN POSNR = IT_DATA-POSNR CHARG = IT_DATA-CHARG.
    IT_DATA-ALIAS    = GS_AROLL-ALIAS.
    IF GS_AROLL-PATH = 'ALIAS'.
      IT_DATA-COA_MAT  = GS_AROLL-AMAT.
      IT_DATA-COA_PATH = 'ALIAS'.
    ELSE.
      IT_DATA-COA_MAT  = IT_DATA-MATNR.
      IT_DATA-COA_PATH = GS_AROLL-PATH.          " NOALIAS/NOCONV/NOMAP/NONE/MIXED/LIMIT, kosong = ASIS
      IF IT_DATA-COA_PATH IS INITIAL.
        IT_DATA-COA_PATH = 'ASIS'.
      ENDIF.
    ENDIF.

    IF L_SUBRC EQ 0.
      IF IT_DATA-COA_PATH = 'ALIAS'.
        PERFORM ALIAS_FILL_ZMAP USING IT_DATA-VBELN IT_DATA-COA_MAT IT_DATA-MATNR.   " isi IT_ZMAP
      ELSE.
        " ... blok mapping as-is yang sekarang (SELECT ZMAP_COA by IT_DATA-MATNR,
        "     merge customer, STOP 'Material belum dimapping...') TIDAK DIUBAH
      ENDIF.
    ENDIF.
    PERFORM GET_TRACED_LOTS.
    PERFORM GET_MIC.
```

### 2.4 LT_COA_MAP (±455–470)

```abap
    IF IT_DATA-COA_PATH = 'ALIAS'.
      " Satu set baris mapping alias per VBELN+AMAT (MIC alias, limit alias, SEQ alias)
      LOOP AT GT_AMAP WHERE VBELN = IT_DATA-VBELN AND MATNR = IT_DATA-COA_MAT.
        CLEAR LS_COA_MAP.
        LS_COA_MAP-VBELN = IT_DATA-VBELN.
        MOVE-CORRESPONDING GT_AMAP TO LS_COA_MAP.            " MATNR = AMAT, MIC = MIC alias
        APPEND LS_COA_MAP TO LT_COA_MAP.
      ENDLOOP.
    ELSE.
      LOOP AT IT_ZMAP.                                       " as-is, tidak berubah
        ...
      ENDLOOP.
    ENDIF.
```

`SORT/DELETE ADJACENT DUPLICATES ... COMPARING VBELN MATNR MIC` tetap. Isi kolom MATNR di LT_COA_MAP = COA_MAT.

### 2.5 Loop nilai per roll (±474–628)

Satu-satunya tempat relabel. Tepat sebelum `MODIFY IT_MIC1` (±618):

```abap
        " Label COA (default as-is)
        IT_MIC1-COA_MAT  = IT_LOT-COA_MAT.
        IT_MIC1-COA_PATH = IT_LOT-COA_PATH.
        IT_MIC1-COA_MIC  = IT_MIC1-MIC.
        IF IT_LOT-COA_PATH = 'ALIAS'.
          READ TABLE GT_AMIC_B INTO GS_AMIC
            WITH KEY VBELN = IT_LOT-VBELN MATNR = IT_LOT-MATNR BMIC = IT_MIC1-MIC.
          IF SY-SUBRC = 0.
            IT_MIC1-COA_MIC = GS_AMIC-AMIC.
          ENDIF.
        ENDIF.
        MODIFY IT_MIC1.
        MOVE-CORRESPONDING IT_MIC1 TO WA_DATA.
        WA_DATA-BATCH_MIC = IT_MIC1-MIC.                     " <-- baru
        WA_DATA-MIC       = IT_MIC1-COA_MIC.                 " <-- baru (as-is: sama)
```

Re-read METHOD (±594–612): untuk jalur alias, ambil METHOD dari `GT_AMAP` (sudah merge customer); blok SELECT ZMAP_COA by `IT_LOT-MATNR` yang ada sekarang hanya untuk selain alias.

```abap
        IF IT_MIC1-METHOD IS INITIAL AND IT_LOT-COA_PATH = 'ALIAS'.
          READ TABLE GT_AMAP WITH KEY VBELN = IT_LOT-VBELN MATNR = IT_LOT-COA_MAT MIC = IT_MIC1-COA_MIC.
          IF SY-SUBRC = 0.
            IT_MIC1-METHOD = GT_AMAP-METHOD.
          ENDIF.
        ENDIF.
        IF IT_MIC1-METHOD IS INITIAL AND IT_LOT-COA_PATH <> 'ALIAS'.
          " ... 2x SELECT SINGLE METHOD yang sekarang
        ENDIF.
```

`GET_JR_AVG`, `GET_BAR_AVG`, dan pembacaan QAMR di loop ini tetap memakai `IT_MIC1-MIC` (MIC batch). Tidak berubah.

### 2.6 Rata-rata (±642–734): ganti kunci

| Lokasi | Sekarang | Menjadi |
|---|---|---|
| SORT IT_DATA_UNIQUE (2x) | `VBELN MATNR MIC INSLOT DESCENDING CHARG ASCENDING` | `VBELN COA_MAT MIC INSLOT DESCENDING CHARG ASCENDING` |
| DELETE ADJACENT DUPLICATES | `COMPARING VBELN MATNR MIC INSLOT` | `COMPARING VBELN COA_MAT MIC INSLOT` |
| ELSEIF pembanding grup | `IT_DATA_AVG-MATNR = IT_DATA_UNIQUE-MATNR` | `IT_DATA_AVG-COA_MAT = IT_DATA_UNIQUE-COA_MAT` |
| PERFORM GET_AVG_KEY (3x) | `... IT_DATA_UNIQUE-MIC ...` | `... IT_DATA_UNIQUE-BATCH_MIC ...` (GT_AVGKEY diisi GET_MIC dengan MIC batch) |
| Setiap lot masuk hitungan (`LV_COUNT = 1` dan `LV_COUNT + 1`, 3 tempat) | — | Khusus Opsi C, jalur alias: `PERFORM ALIAS_COUNT_LOT USING IT_DATA_UNIQUE` → `GT_AMIC-CNT + 1` untuk (VBELN, COA_MAT, MATNR, MIC alias). Bobot limit = lot yang sama dengan yang dipakai rata-rata nilai |

`IT_DATA-MIC` sudah MIC alias, sehingga `MICFMT USING IT_DATA_AVG-MIC` memakai desimal MIC alias. MICFMT sudah punya cadangan "QPMK plant mana pun", jadi tidak perlu wrapper.

Hasil: satu baris per **VBELN + COA_MAT + MIC alias**, berisi rata-rata **seluruh roll** PLE6 + PLE7 (bukan rata-rata dari rata-rata per tipe). Baris wakil memegang MATNR/CHARG/INSLOT roll pertama (urut INSLOT desc).

### 2.7 Limit dan SEQ (±747–778)

```abap
    READ TABLE LT_COA_MAP INTO LS_COA_MAP
      WITH KEY VBELN = IT_DATA-VBELN
               MATNR = IT_DATA-COA_MAT                       " <-- dari IT_DATA-MATNR
               MIC   = IT_DATA-MIC BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      ... (SEQ, CHK, NUMMIC, replace LOWER/UPPER dari mapping) TIDAK DIUBAH
    ENDIF.

    IF IT_DATA-COA_PATH = 'ALIAS'.
      PERFORM ALIAS_APPLY_LIMIT CHANGING IT_DATA.            " <-- baru, §6
    ENDIF.

    " --- BEGIN ZLOG_COA CHECK --- TIDAK DIUBAH (IT_DATA-MIC = MIC alias, INSLOT = lot wakil)
```

`ALIAS_APPLY_LIMIT` dipanggil **sebelum** `SET_COA_RANGE_FLAG` (±815), sehingga warna/flag range memakai limit final.

### 2.8 Urutan akhir (±828)

```abap
  SORT IT_DATA BY VBELN COA_MAT CHK DESCENDING NUMMIC NUM ASCENDING MIC ASCENDING.
```

### 2.9 Pesan info setelah GET_DATA

Setelah loop, untuk setiap kelompok di `GT_AGRP`:

- `ALIAS`: `MESSAGE 'COA gabungan alias &1 (&2), &3 tipe produksi' TYPE 'S'`
- fallback dari kelompok yang punya alias (NOCONV/NOMAP/NONE/MIXED/LIMIT): `MESSAGE 'Alias &1 dicetak per tipe produksi: &2' TYPE 'S'`

Kalau lebih dari satu kelompok, pesan pertama + "(lihat log)" dan detail di `GT_ALOG`.

## 3. FORM baru `ALIAS_RESOLVE` dan sub-FORM

Semua di include baru `ZQMI_COA_F03` (atau di akhir F01). Kode konversi dan terjemahan di-port dari harness `tests/alias_live/zz_alias_form.abap` dengan perbaikan yang sudah ada di blueprint.

### 3.1 `ALIAS_RESOLVE`

```abap
FORM ALIAS_RESOLVE.
  DATA: LV_ALIAS TYPE AUSP-ATWRT,
        LV_AMAT  TYPE MARA-MATNR,
        LV_KUNNR TYPE KUNNR,
        LV_STAT  TYPE C LENGTH 7.

  REFRESH: GT_AROLL, GT_AGRP, GT_AMAP, GT_AMIC, GT_AMIC_B, GT_ALOG.

  " 1) Per roll: alias + material alias
  LOOP AT IT_DATA.
    CLEAR: GS_AROLL, LV_ALIAS, LV_AMAT.
    GS_AROLL-VBELN = IT_DATA-VBELN.
    GS_AROLL-POSNR = IT_DATA-POSNR.
    GS_AROLL-CHARG = IT_DATA-CHARG.
    GS_AROLL-MATNR = IT_DATA-MATNR.
    READ TABLE IT_INOB WITH KEY MATNR = IT_DATA-MATNR CHARG = IT_DATA-CHARG BINARY SEARCH.
    IF SY-SUBRC = 0.
      READ TABLE IT_AUSP WITH KEY OBJEK = IT_INOB-OBJEK ATINN = GV_ATINN_ALIAS BINARY SEARCH.
      IF SY-SUBRC = 0.
        LV_ALIAS = IT_AUSP-ATWRT.
      ENDIF.
    ENDIF.
    GS_AROLL-ALIAS = LV_ALIAS.
    IF LV_ALIAS IS INITIAL.
      GS_AROLL-PATH = 'NOALIAS'.
    ELSE.
      PERFORM ALIAS_CONVERT USING LV_ALIAS IT_DATA-MATNR CHANGING LV_AMAT.
      IF LV_AMAT IS INITIAL.
        GS_AROLL-PATH = 'NOCONV'.
      ELSE.
        GS_AROLL-AMAT = LV_AMAT.
        GS_AROLL-PATH = 'ALIAS'.                             " sementara, final di langkah 3
      ENDIF.
    ENDIF.
    INSERT GS_AROLL INTO TABLE GT_AROLL.
  ENDLOOP.

  " 2) MIXED: satu MATNR dalam DO punya roll ber-AMAT berbeda, atau campur alias/tanpa alias
  PERFORM ALIAS_CHECK_MIXED.

  " 3) Per kelompok VBELN+AMAT
  LOOP AT GT_AROLL INTO GS_AROLL WHERE PATH = 'ALIAS'.
    READ TABLE GT_AGRP TRANSPORTING NO FIELDS
      WITH TABLE KEY VBELN = GS_AROLL-VBELN AMAT = GS_AROLL-AMAT.
    CHECK SY-SUBRC <> 0.                                     " kelompok sudah diproses
    CLEAR GS_AGRP.
    GS_AGRP-VBELN = GS_AROLL-VBELN.
    GS_AGRP-AMAT  = GS_AROLL-AMAT.
    GS_AGRP-ALIAS = GS_AROLL-ALIAS.

    SELECT SINGLE KUNAG INTO LV_KUNNR FROM LIKP WHERE VBELN = GS_AROLL-VBELN.
    PERFORM ALIAS_READ_MAP USING GS_AGRP-VBELN GS_AGRP-AMAT LV_KUNNR CHANGING LV_STAT.
    IF LV_STAT IS INITIAL.
      " terjemahkan untuk setiap MATNR (tipe produksi) dalam kelompok
      PERFORM ALIAS_TRANSLATE_GROUP USING GS_AGRP-VBELN GS_AGRP-AMAT CHANGING LV_STAT GS_AGRP-NMAT.
    ENDIF.
    IF LV_STAT IS INITIAL AND ( GC_ALIAS_LIMIT = 'B1' OR GC_ALIAS_LIMIT = 'B2' OR GC_ALIAS_LIMIT = 'C' ).
      PERFORM ALIAS_LIMIT_PREP USING GS_AGRP-VBELN GS_AGRP-AMAT CHANGING LV_STAT.
    ENDIF.
    IF LV_STAT IS INITIAL.
      GS_AGRP-STATUS = 'ALIAS'.
    ELSE.
      GS_AGRP-STATUS = LV_STAT.                              " NOMAP / NONE / LIMIT
    ENDIF.
    INSERT GS_AGRP INTO TABLE GT_AGRP.
  ENDLOOP.

  " 4) Tulis status kelompok ke roll (seluruh kelompok ikut, tidak ada fallback per roll/MIC)
  LOOP AT GT_AROLL INTO GS_AROLL WHERE PATH = 'ALIAS'.
    READ TABLE GT_AGRP INTO GS_AGRP
      WITH TABLE KEY VBELN = GS_AROLL-VBELN AMAT = GS_AROLL-AMAT.
    IF GS_AGRP-STATUS <> 'ALIAS'.
      GS_AROLL-PATH = GS_AGRP-STATUS.
      MODIFY TABLE GT_AROLL FROM GS_AROLL.
    ENDIF.
  ENDLOOP.

  " 5) Buang terjemahan kelompok fallback, bangun index balik untuk relabel
  LOOP AT GT_AGRP INTO GS_AGRP WHERE STATUS <> 'ALIAS'.
    DELETE GT_AMIC WHERE VBELN = GS_AGRP-VBELN AND AMAT = GS_AGRP-AMAT.
    DELETE GT_AMAP WHERE VBELN = GS_AGRP-VBELN AND MATNR = GS_AGRP-AMAT.
  ENDLOOP.
  GT_AMIC_B[] = GT_AMIC[].
ENDFORM.
```

### 3.2 `ALIAS_CONVERT` (alias → material alias, cache)

Port dari harness langkah 1–2, ditambah:

- **Cache** di `GT_ACONV` dengan kunci (ALIAS, 2 karakter awal MATNR, karakter terakhir MATNR).
- **1 alias = 1 material alias** (dipastikan 13 Nov 2026): `SELECT SINGLE` seperti harness, tanpa aturan kandidat ganda.
- **SAME** (AMAT = MATNR batch): dikembalikan sebagai AMAT biasa. Terjemahan MIC nanti identitas (semua EXACT), jadi tetap jalur alias.

```abap
FORM ALIAS_CONVERT USING P_ALIAS P_MATNR CHANGING P_AMAT.
  " a) cache
  " b) ZZCODE: CAWNT-ATWTB = alias -> ATZHL -> CAWN-ATWRT (kode 3) ->
  "    MATNR(2) + kode + MATNR+len-1(1), wajib ada di MARA
  " c) MAKT: REGEX '^(.*\s)\S+\s*$' pada MAKTX batch -> awalan + alias,
  "    MAKTG = teks, MATNR LIKE MATNR(2)%  -> SELECT SINGLE
  " d) simpan ke cache (termasuk hasil kosong agar tidak dicari ulang)
ENDFORM.
```

### 3.3 `ALIAS_READ_MAP` (mapping material alias + customer)

Sama dengan blok as-is F01 ±401–446 (umum + override customer, aturan merge sama), dengan MATNR = AMAT. Hasil di-append ke `GT_AMAP` (sekali per VBELN+AMAT). Kalau kosong: `P_STAT = 'NOMAP'`.

Tambahan: kalau `MIC_DESC` kosong, isi dari QPMT (`KURZTEXT`, `SPRACHE = 'E'`) **MIC alias**, supaya deskripsi di COA adalah deskripsi alias, bukan deskripsi MIC batch dari QAMV.

### 3.4 `ALIAS_TRANSLATE_GROUP` (MIC alias → MIC batch, per tipe produksi)

```abap
FORM ALIAS_TRANSLATE_GROUP USING P_VBELN P_AMAT CHANGING P_STAT P_NMAT.
  " daftar MATNR unik di kelompok
  LOOP AT GT_AROLL INTO GS_AROLL WHERE VBELN = P_VBELN AND AMAT = P_AMAT AND PATH = 'ALIAS'.
    COLLECT GS_AROLL-MATNR INTO LT_MAT.
  ENDLOOP.
  P_NMAT = LINES( LT_MAT ).
  LOOP AT LT_MAT INTO LV_MAT.
    " kamus MIC plan (MAPL PLNTY 'Q' -> PLMK) material batch + JR pasangannya,
    " dan material alias + JR pasangannya (sama dengan harness langkah 4)
    LOOP AT GT_AMAP WHERE VBELN = P_VBELN AND MATNR = P_AMAT.
      " urutan: EXACT -> RULE -> SUFFIX -> DESC (level sama: MIC(1)) -> NONE
      " cek silang: RULE/SUFFIX dengan deskripsi beda -> CHK = 'X' (tetap dipakai)
      " INSERT GS_AMIC INTO TABLE GT_AMIC
      IF GS_AMIC-HOW = 'NONE'.
        P_STAT = 'NONE'.
        " catat MIC alias + MATNR penyebab ke GT_ALOG
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
```

Perbedaan dengan harness:

| Harness | Rancangan |
|---|---|
| Per roll, MIC NONE dibuang | Per kelompok; satu NONE → seluruh kelompok fallback |
| DESC tanpa batas level | DESC hanya kandidat dengan `MIC(1)` sama (S/P/A) |
| Tanpa cek silang | Flag CHK untuk RULE/SUFFIX dengan deskripsi beda |
| Kamus dibaca setiap roll | Kamus di-cache per MATNR (plan) |

Kalau dua MIC alias diterjemahkan ke **MIC batch yang sama** pada satu MATNR, perlakukan sebagai NONE (tidak bisa dibedakan saat relabel).

### 3.5 `ALIAS_CHECK_MIXED`

> **Diputuskan 13 Nov 2026:** roll dengan alias atau tipe produksi yang berbeda tetap dicetak di COA terpisah.

Untuk setiap VBELN + MATNR: kalau roll-rollnya punya lebih dari satu AMAT, atau ada roll `ALIAS` bersama roll `NOALIAS`/`NOCONV`, semua roll MATNR itu diberi `PATH = 'MIXED'`, dan kelompok AMAT yang memuat MATNR itu ikut fallback (diset di langkah 3 lewat status kelompok `MIXED`).

### 3.6 `ALIAS_FILL_ZMAP` (dipanggil per roll di PHASE 3)

```abap
FORM ALIAS_FILL_ZMAP USING P_VBELN P_AMAT P_MATNR.
  REFRESH IT_ZMAP.
  LOOP AT GT_AMIC INTO GS_AMIC
       WHERE VBELN = P_VBELN AND AMAT = P_AMAT AND MATNR = P_MATNR.
    READ TABLE GT_AMAP WITH KEY VBELN = P_VBELN MATNR = P_AMAT MIC = GS_AMIC-AMIC.
    MOVE-CORRESPONDING GT_AMAP TO IT_ZMAP.                               " METHOD, MAPPING, UOM, MIC_DESC, SEQ, limit alias
    IT_ZMAP-MATNR = P_MATNR.
    IT_ZMAP-MIC   = GS_AMIC-BMIC.                            " GET_MIC membaca QAMV dengan MIC batch
    APPEND IT_ZMAP.
  ENDLOOP.
  SORT IT_ZMAP BY MIC.
ENDFORM.
```

`MAPPING` (SR/JR Base/Converting) dari mapping alias menentukan lot sumber di GET_MIC, sama seperti as-is.

## 4. F02 `EXEC` (±54–250)

| # | Lokasi | Perubahan |
|---|---|---|
| E1 | Validasi tipe film (±234–241) | `SORT T_DETAIL1 BY COA_MAT` + `DELETE ADJACENT DUPLICATES ... COMPARING COA_MAT`. Roll jalur alias satu kelompok = 1 nilai → lolos. Campur kelompok alias + as-is atau AMAT beda → tetap `Tipe film tidak boleh berbeda!`. As-is: COA_MAT = MATNR, identik |
| E2 | Header alias (±174) | `LOOP AT LT_DIST_BATCHES WHERE COA_MAT = LV_PRODUCT_COAMAT` (variabel baru diisi `IT_DATA-COA_MAT`). Hasil: PLE-18 dari semua roll kelompok. Alternatif lebih ringan: kalau `COA_PATH = 'ALIAS'`, langsung pakai `IT_DATA-ALIAS` |
| E3 | Lebar ZZWIDTH (±99–125) | Kalau baris terpilih jalur alias: kumpulkan lebar dari **semua roll IT_LOT** dengan VBELN + COA_MAT sama (VB_BATCH_GET_DETAIL per MATNR+CHARG unik). As-is: tetap per baris terpilih seperti sekarang |
| E4 | QPMK MAX(VERSION) (±83) | `MKMNR = IT_DATA-MIC` (MIC alias). Kalau tidak ketemu, ulang dengan `IT_DATA-BATCH_MIC` |
| E5 | Rata-rata IT_DETAIL1 (±268) | Tidak berubah (1 baris per MIC alias per DO) |
| E6 | SAVE_ADD_INFO / ZLOG_COA (±816–1010) | Tidak berubah: memakai `IT_DATA-MIC` (MIC alias) dan `IT_DATA-INSLOT` (lot wakil), konsisten dengan pembacaan di F01 |

F_PRINT, batch list, DOWNLOAD_BATCH_LIST_XLSX, PREPARE_DYNAMIC_ROLL_COLUMNS: **tidak berubah**. `LT_ROLL_LOT = IT_LOT` sudah berisi semua roll DO, dan selalu memakai MATNR+CHARG asli.

## 5. ALV ZQM003 dan download

### 5.1 ZQM003 (`ZQMI_COA_ALV`)

| Lokasi | Perubahan |
|---|---|
| TY_ALVR (±4–24) | `+ COA_MAT LIKE MARA-MATNR, COA_PATH(7), BATCH_MIC LIKE QPMK-MKMNR` |
| LT_UNIQUE / LT_FINAL (±162–216) | Isi dan kunci dari `IT_MIC1-COA_MAT` + `IT_MIC1-COA_MIC` (bukan MATNR + MIC). SORT/COMPARING/pembanding ikut. MICFMT pakai COA_MIC |
| LT_SEQ (±255–264) | Kunci VBELN + COA_MAT + MIC (IT_DATA-MIC sudah MIC alias) |
| LT_METHOD (±266–274) | Jalur alias: METHOD dari `GT_AMAP`; as-is: SELECT seperti sekarang |
| Baris ALV (±286–345) | `MIC = IT_MIC1-COA_MIC`, `BATCH_MIC = IT_MIC1-MIC`, `COA_MAT`, `COA_PATH`; `MICDES/UOM/MICMIN/MICMAX` untuk jalur alias diambil dari baris final `IT_DATA` (READ by VBELN + COA_MAT + MIC alias) supaya **limit dan deskripsi sama dengan print**; READ LT_FINAL dengan COA_MAT + COA_MIC |
| ZLOG (LT_ZKEY ±221) | `MIC = IT_MIC1-COA_MIC` |
| Field catalog | Tambah COA_MAT ("Material COA"), COA_PATH ("Jalur"), BATCH_MIC ("MIC Batch", `NO_OUT = 'X'`) |

### 5.2 DOWNLOAD (F01 ±1129) dan DOWNLOAD_DETAIL (±1264)

Tambah kolom COA_MAT dan BATCH_MIC di file. Baris tetap dari IT_DATA (MIC = MIC alias).

## 6. FORM `ALIAS_APPLY_LIMIT` — tiga opsi limit

Hanya **satu** opsi yang diimplementasikan, sesuai keputusan QA (§3.6 blueprint). `GC_ALIAS_LIMIT` di bawah hanya untuk menunjukkan percabangan di rancangan; saat execute, cabang yang tidak dipilih tidak ditulis.

### 6.1 Sumber spec asli (Opsi B dan C): `ALIAS_LIMIT_PREP`

Opsi B2 harus memutuskan kelompok **sebelum** nilai dibaca (kalau ditolak, roll harus ikut mapping as-is). Karena itu spec asli diambil dari **inspection plan** (PLMK) per MATNR saat ALIAS_RESOLVE, bukan dari QAMV lot yang baru terbaca di GET_MIC. Kamus PLMK yang sama dipakai juga untuk B1 dan C, supaya satu sumber.

```abap
FORM ALIAS_LIMIT_PREP USING P_VBELN P_AMAT CHANGING P_STAT.
  " untuk setiap GT_AMIC (VBELN, AMAT, MATNR, AMIC, BMIC):
  "   SELECT TOLERANZUN TOLERANZOB (+ flag terisi) FROM MAPL JOIN PLMK
  "     WHERE MAPL~MATNR IN (MATNR, JR-pasangan) AND PLNTY = 'Q' AND LOEKZ = ' '
  "       AND PLMK~VERWMERKM = BMIC AND PLMK~LOEKZ = ' '
  "   kalau tidak ada di PLMK -> QPMK (MAX VERSION, WERKS) BMIC
  "   simpan LOW/HIGH/HASLO/HASHI ke GT_AMIC
  " Opsi B2: per AMIC, kalau LOW/HIGH beda antar MATNR -> P_STAT = 'LIMIT'
  "          (catat daftar MIC di GT_ALOG untuk pesan)
  " Opsi B1: per AMIC, hitung terketat; kalau lower > upper -> P_STAT = 'LIMIT'
ENDFORM.
```

> **Diputuskan 13 Nov 2026:** Opsi B dan C memakai spec **inspection plan** (PLMK) untuk semua tipe produksi dalam kelompok. Catatan uji: bandingkan PLMK vs QAMV untuk DO uji (AL-01); kalau spec lot berbeda dengan plan (plan diubah setelah lot dibuat), yang dicetak adalah spec plan saat ini.

### 6.2 `ALIAS_APPLY_LIMIT`

Dipanggil per baris final IT_DATA jalur alias (§2.7), setelah replace limit dari LT_COA_MAP dan sebelum SET_COA_RANGE_FLAG.

```abap
FORM ALIAS_APPLY_LIMIT CHANGING PS_DATA LIKE IT_DATA.
  DATA: LV_LOW TYPE F, LV_HIGH TYPE F, LV_N_LO TYPE I, LV_N_HI TYPE I,
        LV_HASLO TYPE C, LV_HASHI TYPE C, LV_DEC TYPE I, LV_UOM TYPE C LENGTH 30.

  PERFORM MICFMT USING PS_DATA-MIC PS_DATA-WERKS CHANGING LV_DEC LV_UOM.

  CASE GC_ALIAS_LIMIT.
```

**Opsi A — limit dari MIC alias**

```abap
    WHEN 'A'.
      " Mapping alias berisi LOWER/UPPER -> sudah dipasang oleh blok LT_COA_MAP (perilaku sekarang).
      " Sisi yang kosong di mapping: pakai spec QPMK MIC alias (bukan spec lot batch wakil).
      READ TABLE LT_COA_MAP ... (sudah terbaca di §2.7: LS_COA_MAP)
      IF LS_COA_MAP-LOWER_LIMIT IS INITIAL OR LS_COA_MAP-UPPER_LIMIT IS INITIAL.
        SELECT SINGLE TOLERANZUN TOLERANZOB INTO (LV_LOW, LV_HIGH)
          FROM QPMK WHERE MKMNR = PS_DATA-MIC AND WERKS = PS_DATA-WERKS
          AND VERSION = ( SELECT MAX( VERSION ) FROM QPMK
                          WHERE MKMNR = PS_DATA-MIC AND WERKS = PS_DATA-WERKS ).
        IF LS_COA_MAP-LOWER_LIMIT IS INITIAL.  -> tulis LV_LOW ke MICMIN/RAW_MICMIN
        IF LS_COA_MAP-UPPER_LIMIT IS INITIAL.  -> tulis LV_HIGH ke MICMAX/RAW_MICMAX
      ENDIF.
```

Catatan: `LS_COA_MAP` lokal di GET_DATA. Saat execute, kirim LOWER/UPPER mapping sebagai parameter USING, atau letakkan cabang A langsung di blok §2.7.

**Opsi B1 — spec asli, terketat**

```abap
    WHEN 'B1'.
      CLEAR: LV_HASLO, LV_HASHI.
      LOOP AT GT_AMIC INTO GS_AMIC
           WHERE VBELN = PS_DATA-VBELN AND AMAT = PS_DATA-COA_MAT AND AMIC = PS_DATA-MIC.
        IF GS_AMIC-HASLO = 'X' AND ( LV_HASLO IS INITIAL OR GS_AMIC-LOW > LV_LOW ).
          LV_LOW = GS_AMIC-LOW.  LV_HASLO = 'X'.             " lower terbesar
        ENDIF.
        IF GS_AMIC-HASHI = 'X' AND ( LV_HASHI IS INITIAL OR GS_AMIC-HIGH < LV_HIGH ).
          LV_HIGH = GS_AMIC-HIGH. LV_HASHI = 'X'.            " upper terkecil
        ENDIF.
      ENDLOOP.
      " lower > upper sudah ditolak di ALIAS_LIMIT_PREP (status LIMIT), jadi di sini selalu valid
      PERFORM ALIAS_SET_LIMIT USING LV_LOW LV_HASLO LV_HIGH LV_HASHI LV_DEC CHANGING PS_DATA.
```

**Opsi B2 — spec asli, tolak kalau beda**

```abap
    WHEN 'B2'.
      " Sampai di sini berarti semua tipe produksi punya spec sama (yang beda sudah
      " jadi status LIMIT -> fallback per tipe produksi di ALIAS_RESOLVE).
      READ TABLE GT_AMIC INTO GS_AMIC
        WITH KEY VBELN = PS_DATA-VBELN AMAT = PS_DATA-COA_MAT AMIC = PS_DATA-MIC.
      PERFORM ALIAS_SET_LIMIT USING GS_AMIC-LOW GS_AMIC-HASLO GS_AMIC-HIGH GS_AMIC-HASHI LV_DEC
                              CHANGING PS_DATA.
```

**Opsi C — rata-rata spec asli antar tipe produksi**

```abap
    WHEN 'C'.
      " Aturan sama dengan rata-rata nilai tanpa alias: bobot = jumlah lot unik
      " ber-hasil per tipe (GT_AMIC-CNT, diisi ALIAS_COUNT_LOT saat rata-rata nilai),
      " desimal = MICFMT. Kalau semua CNT = 0, tiap tipe berbobot 1.
      DATA: LV_W TYPE I, LV_SUMCNT TYPE I.
      CLEAR: LV_LOW, LV_HIGH, LV_N_LO, LV_N_HI, LV_SUMCNT.
      LOOP AT GT_AMIC INTO GS_AMIC
           WHERE VBELN = PS_DATA-VBELN AND AMAT = PS_DATA-COA_MAT AND AMIC = PS_DATA-MIC.
        LV_SUMCNT = LV_SUMCNT + GS_AMIC-CNT.
      ENDLOOP.
      LOOP AT GT_AMIC INTO GS_AMIC
           WHERE VBELN = PS_DATA-VBELN AND AMAT = PS_DATA-COA_MAT AND AMIC = PS_DATA-MIC.
        IF LV_SUMCNT > 0. LV_W = GS_AMIC-CNT. ELSE. LV_W = 1. ENDIF.
        CHECK LV_W > 0.
        IF GS_AMIC-HASLO = 'X'. LV_LOW  = LV_LOW  + LV_W * GS_AMIC-LOW.  LV_N_LO = LV_N_LO + LV_W. ENDIF.
        IF GS_AMIC-HASHI = 'X'. LV_HIGH = LV_HIGH + LV_W * GS_AMIC-HIGH. LV_N_HI = LV_N_HI + LV_W. ENDIF.
      ENDLOOP.
      IF LV_N_LO > 0. LV_LOW  = LV_LOW  / LV_N_LO. LV_HASLO = 'X'. ENDIF.
      IF LV_N_HI > 0. LV_HIGH = LV_HIGH / LV_N_HI. LV_HASHI = 'X'. ENDIF.
      " desimal: MICFMT (LV_DEC), dibulatkan saat WRITE di ALIAS_SET_LIMIT
      PERFORM ALIAS_SET_LIMIT USING LV_LOW LV_HASLO LV_HIGH LV_HASHI LV_DEC CHANGING PS_DATA.
  ENDCASE.
ENDFORM.

FORM ALIAS_SET_LIMIT USING P_LOW P_HASLO P_HIGH P_HASHI P_DEC CHANGING PS_DATA LIKE IT_DATA.
  IF P_HASLO = 'X'.
    WRITE P_LOW  TO PS_DATA-MICMIN EXPONENT 0 DECIMALS P_DEC LEFT-JUSTIFIED.
    PS_DATA-RAW_MICMIN = P_LOW.
  ELSE.
    CLEAR: PS_DATA-MICMIN, PS_DATA-RAW_MICMIN.
  ENDIF.
  IF P_HASHI = 'X'.
    WRITE P_HIGH TO PS_DATA-MICMAX EXPONENT 0 DECIMALS P_DEC LEFT-JUSTIFIED.
    PS_DATA-RAW_MICMAX = P_HIGH.
  ELSE.
    CLEAR: PS_DATA-MICMAX, PS_DATA-RAW_MICMAX.
  ENDIF.
ENDFORM.
```

Catatan bersama:

- **Sisi limit kosong** (contoh: PLE6 punya upper, PLE7 tidak). Aturan mengikuti sifat masing-masing opsi, **diputuskan 13 Nov 2026**, tidak perlu ditanyakan ke QA:

| Opsi | Aturan sisi kosong | Alasan |
|---|---|---|
| A | Tidak relevan; sisi kosong di mapping alias diisi spec QPMK MIC alias | Limit tidak berasal dari tipe produksi |
| B1 | Pakai limit yang ada | Kosong = tanpa batas; yang terketat adalah yang punya batas |
| B2 | Kosong vs terisi = beda → kelompok ditolak (LIMIT) | Opsi ini memang menolak setiap perbedaan |
| C | Rata-rata hanya dari tipe yang punya nilai | Tidak bisa merata-rata "tanpa batas" |
- **Limit hanya angka untuk MIC kuantitatif.** MIC kualitatif (`TYPE` bukan kuantitatif) tidak diproses `ALIAS_APPLY_LIMIT`; isi limit mengikuti perilaku sekarang.
- **RAW_MICMIN/RAW_MICMAX** diisi angka hasil hitung (bukan hasil bulat), sehingga `SET_COA_RANGE_FLAG` menilai dengan limit sebenarnya. Untuk Opsi C dengan pembulatan, nilai 37.6 dibandingkan dengan 37.5 (bukan 38). Kalau QA ingin konsisten dengan tampilan, ganti RAW dengan hasil `PARSE_LIMIT_TO_RAW` dari teks yang dicetak.

### 6.3 Perbandingan beban implementasi

| Opsi | Kode tambahan | Catatan |
|---|---|---|
| A | ±15 baris (cabang QPMK alias untuk sisi kosong) | Tidak perlu `ALIAS_LIMIT_PREP` |
| B1 | ±60 baris (`ALIAS_LIMIT_PREP` + cabang B1) | Status LIMIT hanya untuk limit tidak beririsan |
| B2 | ±50 baris | Paling banyak kelompok fallback (4,2% batch PRD punya limit beda) |
| C | ±70 baris | Termasuk ALIAS_COUNT_LOT (bobot lot sama dengan rata-rata nilai) |

## 7. Ringkasan perubahan per include

| Include | Baru | Diubah | Catatan |
|---|---|---|---|
| TOP | ±90 baris (tipe + tabel kerja) | ±7 baris (field IT_DATA, IT_MIC1) | Tidak ada DDIC |
| F01 GET_DATA | — | ±45 baris di 8 titik (§2.1–2.8) | Blok as-is tidak diubah, hanya dibungkus IF |
| F01/F03 FORM baru | ±400–480 baris | — | ALIAS_RESOLVE, CONVERT, READ_MAP, TRANSLATE_GROUP, CHECK_MIXED, FILL_ZMAP, LIMIT_PREP, APPLY_LIMIT, SET_LIMIT |
| F01 download | — | ±10 baris | Kolom COA_MAT, BATCH_MIC |
| F02 EXEC | — | ±25 baris (E1–E4) | |
| ALV ZQM003 | — | ±35 baris + fieldcat | |

## 8. Urutan kerja saat "execute"

1. Re-fetch DEV AIX (TOP/F01/F02/ALV), cocokkan nomor baris dokumen ini.
2. Bangun FORM baru di **subroutine pool harness** (`scripts/mt_pool_build.mjs`), uji AL-01, AL-03..AL-09 tanpa menyentuh program.
3. Terapkan ubah-kunci (§2.6–2.8) dengan `COA_MAT = MATNR` untuk semua roll (FORM alias belum dipanggil). Jalankan regresi L-QM01–15 + ML-QM01–04 → harus 100% identik (ZQM002 dan ZQM003).
4. Aktifkan `ALIAS_RESOLVE` + `ALIAS_FILL_ZMAP` + relabel. Ulang regresi (DO tanpa alias harus tetap identik), lalu AL-01..AL-12.
5. Terapkan opsi limit yang dipilih QA (§6), uji AL-02.
6. EXEC (§4) dan ZQM003 (§5), uji print AL-01 dan ZQM003 AL-11/AL-12.
7. Push ke sandbox-new dulu, baru program DEV setelah Mas setujui.

## 9. Hal yang perlu dicek ulang saat execute

- `IT_DATA_UNIQUE`/`IT_DATA_AVG` dideklarasikan `LIKE IT_DATA`, jadi field baru otomatis ikut. Cek juga tabel lain `LIKE IT_DATA` (LT_DIST_BATCHES, LT_ROLL_LOT, T_DETAIL) — tidak perlu diubah, hanya ikut membawa field.
- `IT_LOOP` (`DELETE ADJACENT DUPLICATES COMPARING CHARG`, ±633) tidak terpengaruh.
- Multi-level converting (`GT_MT_LOT`) dan JR averaging (`GT_AVGKEY`) memakai MIC batch → tetap benar karena relabel terjadi setelahnya; satu-satunya titik yang perlu `BATCH_MIC` adalah `GET_AVG_KEY` di rata-rata.
- ZQM003 rentang tanggal memproses banyak DO sekaligus: semua tabel kerja alias berkunci VBELN, cache konversi lintas DO.
