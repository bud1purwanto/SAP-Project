# Code Review — ZMMI_WMS (2026-11-05)

| Atribut | Isi |
|---|---|
| Objek | `ZMMI_WMS` (1 program, tanpa include, 1.315 baris) |
| Sumber review | `src/ZMMI_WMS.abap` (identik `outputs/ZMMI_WMS_live.abap`, versi Ref 002 03.11.2026) |
| Server | Tidak dicek live — MCP SAP gagal connect di sesi ini |
| Reviewer | Claude (read-only, checklist `02_AGENTS/abap-reviewer.md`) |
| Perubahan kode | Tidak ada |

## Ringkasan

Program read-only di SAP (tidak ada BAPI/UPDATE tabel standar), sintaks 7.31 bersih, mass select + FAE + BINARY SEARCH rapi.
Risiko utama ada di **jalur WMS** (tulis ke DB MSSQL eksternal): bypass otorisasi, staging bersama tanpa lock, dan pemilihan HU yang belum deterministik.

| Level | Jumlah |
|---|---|
| Critical | 0 |
| Major | 4 |
| Minor | 8 |

---

## Major

### M1. Mode WMS bisa dijalankan tanpa otorisasi `Z_OLAP` — baris 285-293, 325, 344
- **Masalah:** `Z_OLAP` hanya dicek di `AT SELECTION-SCREEN OUTPUT` untuk menyembunyikan `P_WMS`. Di `START-OF-SELECTION` tidak dicek ulang.
- **Dampak:** user tanpa `Z_OLAP` bisa jalankan WMS via variant, `SUBMIT ... WITH P_WMS = 'X'`, atau background job → tulis ke `Y_ZBMBCSR` + SP MERGE ke `ZBMBCSR_WMS`.
- **Fix:** di `START-OF-SELECTION`, sebelum `PERFORM GT_HU`:
```abap
  IF P_WMS = 'X'.
    AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
    IF SY-SUBRC NE 0.
      MESSAGE 'No Authorization for WMS' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.
```
(Pola sama di ZBMBC — perlu keputusan Baginda apakah ZBMBC ikut dibenahi.)

### M2. Plant kosong = semua plant tanpa cek otorisasi — baris 311-317
- **Masalah:** `LOOP AT S_WERKS` hanya cek `S_WERKS-LOW`. `S_WERKS` kosong → tidak ada cek sama sekali, data semua plant tampil/terkirim. Opsi `CP`/`NE`/`E` (exclude) juga lolos.
- **Pembanding:** ZBMBC punya `FORM CHECK_WERKS` (`SUSR_USER_AUTH_FOR_OBJ_GET` + handling `*`); ZMMI_WMS hanya copy loop awalnya.
- **Fix (opsi):** filter hasil per plant — setelah `GT_CONT` terbentuk (baris 479-481), hapus baris yang plant-nya gagal `AUTHORITY-CHECK Z_WERKS` (cek per plant unik, bukan per baris). Butuh AGREED Baginda karena mengubah perilaku.

### M3. Staging `Y_ZBMBCSR` dipakai bersama ZBMBC tanpa lock — baris 1265-1299
- **Masalah:** `DELETE FROM Y_ZBMBCSR` → INSERT → COMMIT → SP. ZBMBC (Execution Type WMS) memakai staging yang sama. Dua run paralel (ZMMI_WMS vs ZBMBC, atau 2 job ZMMI_WMS) saling hapus/campur isi staging.
- **Dampak:** data run A ikut ter-merge run B, atau hilang; SP MERGE ON `[Batch]` bisa error bila batch double dari dua run (MERGE gagal bila >1 source row match target).
- **Fix:** kunci logis sebelum `CONNECT`, lepas setelah `DISCONNECT` — di kedua program:
```abap
  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      TABNAME        = 'Y_ZBMBCSR'
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    MESSAGE 'Staging WMS sedang dipakai, coba lagi' TYPE 'I'.
    EXIT.
  ENDIF.
  ...
  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      TABNAME = 'Y_ZBMBCSR'.
```
Alternatif: jadwalkan job ZBMBC-WMS dan ZMMI_WMS di slot berbeda (organisatoris).

### M4. Batch dikaitkan ke HU tanpa syarat Sloc — baris 446-477, 806-821
- **Masalah:** `GT_CONT` cuma key Material+Plant+Batch. Stok batch di Sloc mana pun dipasangkan ke semua HU yang pernah berisi batch itu (termasuk HU lama dengan `VEPO-LGORT` kosong / `SOBKZ W`).
- **Bukti:** compare TRS 03.11 — 93 baris (Screen) / 42 baris (WMS) ZMMI isi HU sementara ZBMBC kosong; 11/2 baris HU beda (contoh batch `0000032966`: ZMMI kirim HU 2017, ZBMBC HU 2027).
- **Dampak:** WMS bisa menerima HU yang salah/usang untuk batch. Unique batch prio 1 (Sloc = VEPO-LGORT) hanya memilih **stock line**, bukan **HU** — HU yang terpilih tetap tergantung urutan baris (lihat m1).
- **Fix:** keputusan bisnis dulu. Opsi: (a) samakan ZBMBC — HU dipakai hanya bila `VEPO-LGORT` = Sloc stok (simpan LGORT di `TY_CONT`, cocokkan di `ADD_OUT`); (b) mode WMS: prioritaskan HU yang LGORT-nya cocok, baru HU terbaru (bukan terkecil).

---

## Minor

| # | Baris | Temuan | Saran |
|---|---|---|---|
| m1 | 763, 795, 735-738 | `SORT` tanpa `STABLE` + `SORT GT_CONT` ulang (763) dengan key lebih pendek dari 482 → urutan HU dalam batch tidak dijamin. Tie-break "HU nomor terkecil" di design jadi tidak deterministik (lolos test 51/51, tapi bukan jaminan). | Hapus SORT 763 (sudah urut dari 482) atau pakai `SORT ... STABLE`; lebih aman tambah `HUBOX HUPLT` ke `TY_RANK` sebagai key sort eksplisit. |
| m2 | 437-443 | `HUBOX/HUPLT` sudah di-`ALPHA_OUTPUT` (tanpa leading zero) lalu dipakai sebagai urutan → perbandingan teks; HU beda panjang digit salah urut (`999` > `1000`). | Urut pakai `VENUM`/EXIDV internal, konversi tampilan di akhir. |
| m3 | 1062-1067 | Storage Bin = quant LQUA pertama per Material+Plant+Batch, tanpa filter Sloc/qty/storage type → bisa ambil quant interim (922) atau quant negatif (kasus batch `0000036833`). | Filter `GESME > 0` & storage type bukan interim (9xx), atau cocokkan `LGNUM` dari Sloc. Perlu keputusan (beda dengan ZBMBC). |
| m4 | 1089-1101 | Baris stok bebas (MCHB, tanpa SO) diberi Customer Name dari `MSKU` (stok konsinyasi di customer) hanya karena batch sama. | Dugaan logika warisan ZBMBC — konfirmasi bisnis. |
| m5 | 1271-1287 | INSERT native SQL per baris (50k baris = 50k round trip ke MSSQL). | Bila lambat di PRD: bulk insert (beberapa VALUES per statement) atau BCP/staging file. Ukur dulu. |
| m6 | 1303-1307 | `CATCH CX_SY_NATIVE_SQL_ERROR` tanpa `INTO` → `SQLCODE/SQLMSG` hilang, pesan generik. Error dari `THROW` di SP juga tak terbaca. | `CATCH ... INTO LX_SQL`, tampilkan `LX_SQL->SQLMSG`; di background tulis ke job log. |
| m7 | 567, 888, 1032, 973, 202 | Konstanta tersebar: MTART `ZFGS/ZSFG`, PARVW `AG`, KLART `023`, nama karakteristik, status `0060`. | Pindah ke blok `CONSTANTS` (atau `ZMAP_TYPE` bila perlu diubah tanpa transport). |
| m8 | 238, 320 | `S_ERDAT` default hari ini → cari HU lama by HU Number jadi 0 baris kalau user lupa kosongkan tanggal. Mode Screen: qty stok berulang per HU (batch di >1 HU) → total ALV dobel. | Tambah info di selection text / dokumentasi; atau kosongkan `S_ERDAT` otomatis bila `S_EXIDV` terisi (perlu AGREED). |

---

## Yang Sudah Benar (dicek)

- Sintaks 7.31: tidak ada inline `DATA(...)`, string template, constructor operator, `@`.
- Setiap FAE dijaga `IS NOT INITIAL` + driver di-`SORT`/`DELETE ADJACENT DUPLICATES`.
- Semua `READ ... BINARY SEARCH` didahului `SORT` dengan key urutan sama (GT_HU, GT_CONT, GT_HULOC, GT_STKDT, GT_VBAK, GT_VBPA, GT_ADRC, GT_MSKU, GT_KNA1, GT_LQUA, GT_OBJ, GT_AUSP, GT_DESC).
- Tidak ada SELECT dalam LOOP; field eksplisit; `FREE` tabel besar setelah dipakai.
- HU status `0060` (Deleted) dibuang di level header & lower/higher.
- Tidak ada `UPDATE/INSERT/DELETE` tabel SAP standar; tidak ada BAPI/COMMIT di SAP.
- Native SQL: rollback saat INSERT error, `DISCONNECT` selalu jalan.

## Dampak Transport

- Hint `VEKP~Z02` butuh extension index `R3TR XINX VEKP Z02` (TRDK924903). Import index **sebelum/bersama** program; create index di PRD (~5,8 juta baris) jam sepi + statistik (DB20). Tanpa index: hint diabaikan → full scan VEKP (±7 s/hari data), tidak error.
- Fix M3 (lock) ideal di ZMMI_WMS **dan** ZBAP_STOCK_BY_CHAR1_F01 dalam satu request.

## Tidak Dicek

- Source live di server (MCP SAP down) — asumsi `src/` = versi terakhir di TRS.
- Syntax check / aktivasi via RFC, runtime PRD, volume PRD.
- Isi tabel `ZBMBCSR_WMS` / perilaku SP di MSSQL selain definisi `ZBMBC/outputs/SP_Merge_ZBMBCSR_WMS_def.txt`.
- Konfigurasi batch level (unique per client vs per material) — relevan untuk key unik CHARG saja.
- Authorization object `Z_OLAP` / `Z_WERKS` di role user.

## Next Step (usulan)

1. Baginda putuskan M1-M4 mana yang dikerjakan (M1 & M3 rekomendasi duluan — kecil, risiko rendah).
2. Untuk M4/m3: perlu keputusan bisnis dengan Rasyid / tim WMS.
3. Setelah AGREED → patch di `sandbox-new`, backup dulu ke `outputs/`, compare ulang vs ZBMBC.
