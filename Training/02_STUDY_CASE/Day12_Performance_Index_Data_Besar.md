# Day 12 — Performance: SELECT Sesuai Index & Olah Data Besar

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★ | MM / ABAP | `sandbox-new` (write) + `prod` (read-only, hanya cek index) | 4 jam | abap-dev-sandbox-new |

## Tujuan

1. Membaca **index tabel** dan menyusun `WHERE` agar database memakai index (bukan full table scan).
2. Mengenali dan memperbaiki **SELECT di dalam LOOP** pada data besar.
3. Mengolah **data sangat besar** tanpa kehabisan memori: `PACKAGE SIZE` / `OPEN CURSOR ... FETCH`, `FOR ALL ENTRIES` per blok, `FREE`.
4. **Mengukur** dengan angka: `GET RUN TIME`, `ST05` (SQL trace + explain plan).

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D12` dengan 3 mode: **A** lambat (SELECT di LOOP), **B** cepat (index + JOIN/FAE), **C** data besar (PACKAGE SIZE + agregasi per paket) — output identik |
| 2 | Flow B untuk ketiga mode (tandai setiap akses database) |
| 3 | Tabel perbandingan: waktu, jumlah statement SQL, index yang dipakai (dari explain plan `ST05`) |

## Cerita Kasus

Report rekap pergerakan material bulanan (seperti `ZPPR_GI_JR_CLOSING` dan rekap slitting) dijalankan untuk 1 bulan plant 2000.
`MSEG` berisi jutaan baris. Versi awal: ambil `MKPF` per tanggal, lalu **untuk setiap dokumen** `SELECT` ke `MSEG`, lalu **untuk setiap item** `SELECT SINGLE` ke `MAKT`.
Hasilnya: 15+ menit, dump `TIME_OUT`, atau `TSV_TNEW_PAGE_ALLOC_FAILED` (memori habis).

## Konsep Kunci

**1. Index.** Cek di `SE11` → Indexes, atau tabel `DD12L` (daftar index) + `DD17S` (field per index).
`WHERE` memakai index jika field **awal** index terisi (dengan `=` atau rentang sempit). Contoh yang sering dipakai:

| Tabel | Akses yang efisien |
|---|---|
| `MKPF` | `BUDAT` (index tanggal posting — cek namanya di sistem) |
| `MSEG` | Primary key `MBLNR, MJAHR, ZEILE` (dari hasil MKPF); index material `MATNR, WERKS, LGORT, BWART, SOBKZ` |
| `AUFM` | `AUFNR` (pergerakan per order) |
| `MCHA`/`MCH1` | `MATNR, CHARG` |

**2. Lima pola lambat.**

| # | Pola | Perbaikan |
|---|---|---|
| 1 | `SELECT` di dalam `LOOP` (N+1) | Ambil sekali: JOIN atau FOR ALL ENTRIES, lalu `READ TABLE ... BINARY SEARCH` / `HASHED TABLE` |
| 2 | `WHERE` tidak sesuai index | Isi field awal index; pilih tabel "driver" yang ter-index |
| 3 | `SELECT *` | Field seperlunya |
| 4 | FAE tanpa cek kosong / duplikat | `IS NOT INITIAL` + `SORT` + `DELETE ADJACENT DUPLICATES` |
| 5 | Ambil semua baris ke memori sekaligus | `PACKAGE SIZE` / `OPEN CURSOR` + agregasi per paket + `FREE` |

**3. Data besar.**

```abap
SELECT mblnr mjahr zeile matnr werks bwart menge shkzg
  FROM mseg
  INTO TABLE lt_pack
  PACKAGE SIZE 10000
  WHERE mblnr IN lr_mblnr ...
  " proses 10.000 baris, ringkas ke gt_sum (COLLECT), lalu baris paket dibuang
  PERFORM aggregate TABLES lt_pack.
ENDSELECT.
```

- Memori hanya menampung 1 paket + hasil ringkasan, bukan jutaan baris.
- Alternatif setara: `OPEN CURSOR WITH HOLD` → `FETCH NEXT CURSOR ... PACKAGE SIZE` → `CLOSE CURSOR`.
- **Jangan** `COMMIT WORK` di dalam `SELECT ... ENDSELECT` / cursor tanpa `WITH HOLD` (cursor tertutup).

## Spesifikasi Program `ZTRN_<INISIAL>_D12`

| Bagian | Isi |
|---|---|
| Input | `S_BUDAT` (wajib), `P_WERKS`, `S_BWART` (default 101 102 261 262 311 312), radio `R_A` / `R_B` / `R_C`, `P_PKG` (package size, default 10000) |
| Output | Rekap per material + movement type: qty netto, jumlah dokumen, deskripsi material. Baris terakhir: waktu eksekusi (mikrodetik) |
| Mode A | Lambat sengaja: LOOP `MKPF` → SELECT `MSEG` per dokumen → SELECT SINGLE `MAKT` per item |
| Mode B | `MKPF` (index BUDAT) JOIN `MSEG` (key) sekali; `MAKT` via FAE + `HASHED TABLE` |
| Mode C | Seperti B tetapi `PACKAGE SIZE P_PKG` dengan agregasi per paket; `FREE` tabel paket |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| B-A | LOOP MKPF → (DB) MSEG per dokumen → (DB) MAKT per item → COLLECT |
| B-B | (DB) MKPF⋈MSEG sekali → (DB) MAKT FAE sekali → LOOP + READ HASHED → COLLECT |
| B-C | LOOP paket: (DB) ambil N baris → COLLECT → buang paket → paket berikutnya → (DB) MAKT sekali |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — baca index (read-only).**
```
Server prod (read-only): baca DD12L dan DD17S untuk tabel MKPF, MSEG, AUFM (index aktif, field berurutan).
Tampilkan sebagai tabel: index, urutan field. Mana yang cocok untuk filter BUDAT + WERKS + BWART?
```

**Langkah 2 — kode tiga mode.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D12 sesuai spesifikasi: <tempel>. ABAP 7.31.
Ketiga mode harus menghasilkan output identik. Ukur waktu dengan GET RUN TIME FIELD.
Beri komentar *SLOW* pada setiap pola lambat di mode A.
```

**Langkah 3 — ukur.** Jalankan A, B, C dengan input sama (mulai 1 hari, lalu 1 minggu, lalu 1 bulan). Aktifkan `ST05` untuk mode A dan B, bandingkan jumlah statement dan lihat *Explain* untuk memastikan index terpakai.

**Langkah 4 — review.**
```
Review mode B dan C saya: apakah WHERE mengikuti index? Ada risiko memori? Apakah hasil ketiga mode identik?
```

**Langkah 5 — flow** (tiga flow B).

## Tugas

| Metrik | Mode A | Mode B | Mode C |
|---|---|---|---|
| Waktu 1 hari (µs) | | | |
| Waktu 1 bulan (µs) | | | |
| Jumlah statement SQL (ST05) | | | |
| Index yang dipakai (Explain) | | | |
| Output identik? | | | |

Tulis 3 kalimat kesimpulan: kapan mode B cukup, kapan perlu mode C.

## Checklist Selesai

- [ ] Index tabel dibaca dari sistem, bukan ditebak.
- [ ] Output ketiga mode identik.
- [ ] Ada angka perbandingan nyata dan bukti explain plan.
- [ ] Program `ZTRN_<INISIAL>_D12` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow selesai.

## Kuis

1. Index `MSEG` dimulai `MATNR`. Query hanya memfilter `BWART`. Apakah index dipakai?
2. Mengapa `SELECT` di dalam `LOOP` lambat walau tiap query cepat?
3. Apa beda masalah yang diselesaikan JOIN/FAE vs `PACKAGE SIZE`?
4. Mengapa tidak boleh `COMMIT WORK` di dalam `SELECT ... PACKAGE SIZE ... ENDSELECT`?

<details>
<summary>Kunci jawaban</summary>

1. Umumnya tidak efektif — field awal index (`MATNR`) kosong, database cenderung full scan.
2. Setiap query punya overhead round-trip; 5.000 dokumen × (1 + item) query = puluhan ribu round-trip.
3. JOIN/FAE mengurangi **jumlah akses** database; `PACKAGE SIZE` membatasi **memori** saat hasilnya sangat besar.
4. `COMMIT WORK` menutup cursor database yang sedang dibuka → dump `DBIF_RSQL_INVALID_CURSOR`. Gunakan `OPEN CURSOR WITH HOLD` jika memang perlu commit.

Potongan kode acuan — mode C:

```abap
TYPES: BEGIN OF ty_row,
         matnr TYPE mseg-matnr,
         bwart TYPE mseg-bwart,
         menge TYPE mseg-menge,
         shkzg TYPE mseg-shkzg,
       END OF ty_row,
       BEGIN OF ty_sum,
         matnr TYPE mseg-matnr,
         bwart TYPE mseg-bwart,
         menge TYPE mseg-menge,
         jml   TYPE i,
       END OF ty_sum.
DATA: lt_pack TYPE STANDARD TABLE OF ty_row,
      ls_row  TYPE ty_row,
      gt_sum  TYPE STANDARD TABLE OF ty_sum,
      gs_sum  TYPE ty_sum.

SELECT b~matnr b~bwart b~menge b~shkzg
  FROM mkpf AS a
  INNER JOIN mseg AS b ON b~mblnr = a~mblnr AND b~mjahr = a~mjahr
  INTO TABLE lt_pack
  PACKAGE SIZE p_pkg
  WHERE a~budat IN s_budat
    AND b~werks = p_werks
    AND b~bwart IN s_bwart.
  LOOP AT lt_pack INTO ls_row.
    CLEAR gs_sum.
    gs_sum-matnr = ls_row-matnr.
    gs_sum-bwart = ls_row-bwart.
    IF ls_row-shkzg = 'H'.
      gs_sum-menge = ls_row-menge * -1.
    ELSE.
      gs_sum-menge = ls_row-menge.
    ENDIF.
    gs_sum-jml = 1.
    COLLECT gs_sum INTO gt_sum.
  ENDLOOP.
  FREE lt_pack.                       " lepas memori paket
ENDSELECT.
```
</details>

## Referensi

- [TECHNICAL_NOTES.md](../05_REFERENSI/PLANNING_SLITROLL/TECHNICAL_NOTES.md) — contoh nyata penyelarasan index.
- [FS_ZPPR_GI_JR_CLOSING.md](../05_REFERENSI/GI_JR_CLOSING/FS_ZPPR_GI_JR_CLOSING.md) — report movement bulanan.
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
