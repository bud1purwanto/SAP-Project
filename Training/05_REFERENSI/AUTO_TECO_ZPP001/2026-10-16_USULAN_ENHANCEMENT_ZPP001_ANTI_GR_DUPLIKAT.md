# Usulan Enhancement ZPP001 (ZPPI_SR_PROCESS) — Anti GR Duplikat

Tanggal: 2026-10-16. Basis source: PRD (backup `outputs/ZPPI_SR_PROCESS*_PRD_20261016.abap`). Kasus: combine order 100007232823 (lihat `2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md`).

## 1. Temuan Kode — Kompensasi Ada, Tapi Putus

Alur sukses: `PROCESS_ALL` → `CHANGE_BATCH_ORIGINAL_ORDER` → `GR` (101) → `SOTOSO`/`SOTOUN` (413/411) → `CHANGE_BATCH_INPUTAN` (JR) → `CONFIRMATION` → `GI` → `SLOC_TO_SLOC`. Setiap step commit sendiri.

Rantai kompensasi yang sudah ada:
`GI gagal` / `CONFIRMATION gagal` → `UNDO_CHANGE_BATCH_INPUTAN` → (jika undo sukses) `CANCEL_CONFIRMATION` → `CANCEL_SOTOSO` / `CANCEL_SOTOUN` → `CANCEL_GR`.

Titik putus:

| # | Lokasi | Masalah |
|---|---|---|
| G1 | `CANCEL_CONFIRMATION` (F01 ±15525) | `SELECT AFRU ... STOKZ = '' AND STZHL = ''`. Bila confirmation **gagal dibuat**, tidak ada AFRU aktif → `FLAG = 'X'` → cancel 411/413/GR **di-skip**. Skenario kasus ini. |
| G2 | `UNDO_CHANGE_BATCH_INPUTAN` (F01 ±12223) | `CANCEL_CONFIRMATION` hanya dipanggil bila undo karakteristik JR sukses. Undo gagal/lock → GR tidak di-cancel. |
| G3 | `CHANGE_BATCH_INPUTAN` (F01 11717) | Cabang gagal hanya log "Failed"; `PERFORM UNDO_CHANGE_BATCH_INPUTAN` di-comment. GR+411 tertinggal. |
| G4 | `USER_COMMAND` `WHEN 'YES'` (TOP 1310) | Guard hanya `CEK_COM_ORDER_STATUS` (status combine order). Tidak cek GR batch yang sudah ada → re-run lolos. |
| G5 | `PROCESS_ALL` / `ALV3` | Log hanya popup ALV, tidak persisten. Error tidak dapat ditelusuri. |

## 2. Usulan Enhancement

### E1 — Guard anti GR ganda (prioritas 1, menutup G4)
Sebelum `PROCESS_ALL`, hitung net GR per batch (jumlah 101 − jumlah 102) untuk AUFNR+CHARG di `IT_MAIN` (MARKS8 = space). Net > 0 → stop, tampilkan nomor dokumen GR existing.

### E2 — Perbaiki rantai kompensasi (prioritas 1, menutup G1–G3)
- Form baru `ROLLBACK_AFTER_GR`: cancel berurutan 413 (`S_MBLNR`) → 411 (`U_MBLNR`) → 101 (`R_MBLNR`) memakai form `CANCEL_*` yang sudah ada.
- `CANCEL_CONFIRMATION`: jika tidak ada AFRU aktif, skip BDC CO13 saja, **tetap** panggil `ROLLBACK_AFTER_GR`.
- `UNDO_CHANGE_BATCH_INPUTAN`: panggil `CANCEL_CONFIRMATION` terlepas dari hasil undo (undo gagal cukup dilog).
- `CHANGE_BATCH_INPUTAN` cabang gagal: panggil `ROLLBACK_AFTER_GR`.
- Jika rollback sendiri gagal: popup tegas (bukan ALV) berisi nomor dokumen yang tertinggal + instruksi jangan proses ulang.

### E3 — Log persisten (prioritas 2, menutup G5)
Application log SLG1 (`BAL_LOG_CREATE`, `BAL_LOG_MSG_ADD`, `BAL_DB_SAVE`), object `ZPP` / subobject `ZPP001` (buat di SLG0), external ID = combine order. Isi = seluruh `IT_LOG` + user + waktu.

## 3. Contoh Kode (ABAP 7.31)

### E1 — `CEK_GR_EXIST`
```abap
FORM CEK_GR_EXIST CHANGING P_FLAG.
  TYPES: BEGIN OF TY_KEY,
           MATNR TYPE MSEG-MATNR,
           WERKS TYPE MSEG-WERKS,
           CHARG TYPE MSEG-CHARG,
           AUFNR TYPE MSEG-AUFNR,
         END OF TY_KEY,
         BEGIN OF TY_MV,
           CHARG TYPE MSEG-CHARG,   " wajib field pertama (AT NEW/END OF)
           BWART TYPE MSEG-BWART,
           MBLNR TYPE MSEG-MBLNR,
           MJAHR TYPE MSEG-MJAHR,
           ZEILE TYPE MSEG-ZEILE,
         END OF TY_MV.
  DATA: LT_KEY TYPE STANDARD TABLE OF TY_KEY,
        LS_KEY TYPE TY_KEY,
        LT_MV  TYPE STANDARD TABLE OF TY_MV,
        LS_MV  TYPE TY_MV,
        LS_MAIN LIKE LINE OF IT_MAIN,
        LV_NET TYPE I,
        LV_CHARG TYPE MSEG-CHARG,
        LV_MSG TYPE STRING.

  CLEAR P_FLAG.
  LOOP AT IT_MAIN INTO LS_MAIN WHERE MARKS8 = SPACE.
    CLEAR LS_KEY.
    SELECT SINGLE MATNR DWERK INTO (LS_KEY-MATNR, LS_KEY-WERKS)
      FROM AFPO WHERE AUFNR = LS_MAIN-AUFNR.
    CHECK SY-SUBRC = 0.
    LS_KEY-CHARG = LS_MAIN-CHARG.
    LS_KEY-AUFNR = LS_MAIN-AUFNR.
    APPEND LS_KEY TO LT_KEY.
  ENDLOOP.

  SORT LT_KEY BY MATNR WERKS CHARG AUFNR.
  DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING ALL FIELDS.
  CHECK LT_KEY IS NOT INITIAL.

* MATNR+WERKS di depan agar Oracle memakai index MSEG~M
  SELECT CHARG BWART MBLNR MJAHR ZEILE
    FROM MSEG INTO TABLE LT_MV
    FOR ALL ENTRIES IN LT_KEY
   WHERE MATNR = LT_KEY-MATNR
     AND WERKS = LT_KEY-WERKS
     AND CHARG = LT_KEY-CHARG
     AND AUFNR = LT_KEY-AUFNR
     AND BWART IN ('101','102').
  CHECK SY-SUBRC = 0.

  SORT LT_MV BY CHARG.
  LOOP AT LT_MV INTO LS_MV.
    AT NEW CHARG.
      CLEAR LV_NET.
    ENDAT.
    IF LS_MV-BWART = '101'.
      LV_NET = LV_NET + 1.
    ELSE.
      LV_NET = LV_NET - 1.
    ENDIF.
    AT END OF CHARG.
      IF LV_NET > 0.               " GR aktif sudah ada -> blok
        P_FLAG  = 'X'.
        LV_CHARG = LS_MV-CHARG.
        EXIT.
      ENDIF.
    ENDAT.
  ENDLOOP.

  IF P_FLAG = 'X'.
    CONCATENATE 'Batch' LV_CHARG 'sudah GR. Proses ulang dibatalkan.'
                'Cek MB51 / hubungi PP.' INTO LV_MSG SEPARATED BY SPACE.
    MESSAGE LV_MSG TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
```
Catatan: `CHARG` harus field pertama di `TY_MV`, karena `AT NEW`/`AT END OF` membandingkan semua field di kiri field kontrol. Urutan field SELECT harus sama dengan struktur (`INTO TABLE` positional).

Pemanggilan di `USER_COMMAND` (TOP):
```abap
    WHEN 'YES'.
      CLEAR: FLAG.
      PERFORM CEK_COM_ORDER_STATUS CHANGING FLAG.
      IF FLAG EQ SPACE.
        PERFORM CEK_GR_EXIST CHANGING FLAG.       " E1 baru
      ENDIF.
      IF FLAG EQ SPACE.
        PERFORM PROCESS_ALL.
        SET USER-COMMAND 'RW'.
      ELSE.
        EXIT.
      ENDIF.
```

### E2 — `ROLLBACK_AFTER_GR` + patch `CANCEL_CONFIRMATION`
```abap
FORM ROLLBACK_AFTER_GR.
  DATA: LV_MSG TYPE STRING.
  CLEAR FLAG.
  IF S_MBLNR NE SPACE AND FLAG EQ SPACE.
    PERFORM CANCEL_SOTOSO USING S_MBLNR S_MJAHR.
  ENDIF.
  IF U_MBLNR NE SPACE AND FLAG EQ SPACE.
    PERFORM CANCEL_SOTOUN USING U_MBLNR U_MJAHR.
  ENDIF.
  IF R_MBLNR NE SPACE AND FLAG EQ SPACE.
    PERFORM CANCEL_GR USING R_MBLNR R_MJAHR.
  ENDIF.
  IF FLAG NE SPACE.                " rollback gagal -> peringatan keras
    CONCATENATE 'GR' R_MBLNR 'SUDAH TERPOSTING dan gagal dibatalkan.'
                'JANGAN proses ulang. Hubungi PP/IT.'
           INTO LV_MSG SEPARATED BY SPACE.
    MESSAGE LV_MSG TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
```
`CANCEL_CONFIRMATION`:
```abap
  IF V_RUECK = SPACE OR V_RUECK = '0000000000'.
*   Confirmation tidak terbentuk -> tidak perlu CO13,
*   tetapi GR/411/413 WAJIB tetap dibatalkan
    PERFORM ROLLBACK_AFTER_GR.
    EXIT.
  ENDIF.
  ...
    IF LS_SUBRC = 0.
      ...
      PERFORM ROLLBACK_AFTER_GR.   " ganti 3 blok IF CANCEL_* lama
    ENDIF.
```
`CHANGE_BATCH_INPUTAN` cabang gagal (sebelum log "Confirmation Failed"): `PERFORM UNDO_CHANGE_BATCH_INPUTAN.` di-uncomment, atau minimal `PERFORM ROLLBACK_AFTER_GR.`
`UNDO_CHANGE_BATCH_INPUTAN`: pindahkan `PERFORM CANCEL_CONFIRMATION.` keluar dari `IF LS_SUBRC = 0`.

Perhatian: `CANCEL_GR` memakai variabel global `FLAG`; `ROLLBACK_AFTER_GR` harus dipanggil sebagai langkah terakhir agar tidak mengubah alur `FLAG` pemanggil.

## 4. Skenario Uji (sandbox-new / QA)
1. Proses normal → 101+411+261+AFRU lengkap; tidak ada regresi.
2. Proses ulang combine order yang sudah GR → diblok E1, tidak ada dokumen baru.
3. Simulasi confirmation gagal (kunci order di CO11N sesi lain) → GR+411 otomatis di-reverse (102 + reversal 411), log SLG1 tercatat.
4. Simulasi change batch JR gagal (kunci batch JR di MSC2N) → GR+411 di-reverse.
5. Simulasi rollback gagal → popup peringatan keras muncul.
6. Cancel → process ulang (kasus normal CVTKR_11) → tetap boleh (net GR = 0).

## 5. Dampak & Transport
- Objek: `ZPPI_SR_PROCESS_TOP`, `ZPPI_SR_PROCESS_F01`; SLG0 object `ZPP`/`ZPP001` (E3).
- Dev → QAS → PRD, satu TR workbench + satu TR customizing (SLG0).
- Performa: tambahan 1 SELECT MSEG FOR ALL ENTRIES per proses (≤ puluhan batch) — cek ST05 di QA.
- Tidak mengubah data historis; dokumen duplikat kasus 15-10 tetap di-reverse manual oleh PP.
