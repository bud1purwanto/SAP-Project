# Day 04 — Report Stok + Transfer Posting dalam 1 Program (Radio Button)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | MM / ABAP | `sandbox-new` (write) | 3–4 jam | abap-dev-sandbox-new, mm-analisa-production |

## Tujuan

1. **Memodifikasi program yang sudah ada** (Day 03) dengan minimal diff — keterampilan yang paling sering dipakai developer.
2. Membuat **selection screen dinamis**: radio button yang menampilkan/menyembunyikan field (`MODIF ID`, `AT SELECTION-SCREEN OUTPUT`).
3. Menggabungkan **report** (stok & histori transfer) dan **transaksi** (posting) dalam 1 program yang rapi.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D04` (salinan Day 03 yang dimodifikasi): Radio **Report** & Radio **Posting** |
| 2 | Flow A (siklus cek stok → transfer → cek histori) + Flow B (percabangan radio, validasi, BAPI, ALV) |
| 3 | Diff Day 03 → Day 04 (apa saja yang berubah) + bukti 1 posting muncul di report histori |

## Cerita Kasus

User gudang memakai program Day 03, tetapi sebelum transfer selalu membuka `MMBE` untuk cek stok, dan setelahnya `MB51` untuk melihat histori.
Mereka meminta **satu program**: pilih *Report* untuk melihat stok & histori transfer, atau pilih *Posting* untuk memindahkan stok.

## Konsep Kunci

```abap
PARAMETERS: r_rpt  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND ucm,
            r_post RADIOBUTTON GROUP g1.

SELECT-OPTIONS s_matnr FOR mard-matnr MODIF ID rpt.   " hanya mode Report
PARAMETERS     p_matnr TYPE mara-matnr MODIF ID pst.  " hanya mode Posting

AT SELECTION-SCREEN OUTPUT.            " dijalankan setiap layar digambar ulang
  LOOP AT SCREEN.
    IF ( screen-group1 = 'RPT' AND r_post = 'X' )
    OR ( screen-group1 = 'PST' AND r_rpt  = 'X' ).
      screen-active = 0.               " sembunyikan
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
```

- `USER-COMMAND` pada radio membuat layar langsung berubah saat radio diklik.
- Field `OBLIGATORY` yang disembunyikan tetap divalidasi SAP → **jangan** pakai `OBLIGATORY`; validasi manual di `AT SELECTION-SCREEN` hanya saat `sy-ucomm = 'ONLI'` (tombol Execute) sesuai radio yang aktif.
- Report histori: `MKPF` + `MSEG` movement `311`/`312`, tandai baris yang sudah dibatalkan (ada `312` dengan `SMBLN` menunjuk dokumen tsb).
- Minimal diff: salin Day 03, ubah hanya yang perlu. Gunakan `FORM` agar logika Report dan Posting terpisah rapi.

## Spesifikasi Program `ZTRN_<INISIAL>_D04`

| Bagian | Mode Report (`R_RPT`) | Mode Posting (`R_POST`) |
|---|---|---|
| Input | `S_MATNR`, `S_WERKS`, `S_LGORT`, `S_CHARG`, `S_BUDAT` (histori) | Semua input Day 03 (`P_MATNR` … `P_TEST`) |
| Proses | 1) Stok per SLoc/batch (`MCHB`, fallback `MARD`). 2) Histori transfer `MSEG` 311/312 + `MKPF` | Logika Day 03 dipindah ke `FORM posting` |
| Output | ALV stok, lalu tombol/radio untuk ALV histori — atau 2 ALV berurutan (stok dulu, `F3` → histori). Kolom histori: Dokumen, Tgl, Material, Batch, Dari SLoc, Ke SLoc, Qty, User, **Status (Aktif/Dibatalkan)** | Hasil posting; jika sukses **otomatis tampilkan Report** untuk material tsb |
| Validasi | Minimal 1 filter material/SLoc | Sama seperti Day 03 |

Struktur kode yang disarankan:

```
START-OF-SELECTION.
  IF r_rpt = 'X'.
    PERFORM get_stock.
    PERFORM get_history.
    PERFORM display_report.
  ELSE.
    PERFORM validate_posting.
    PERFORM posting.
    IF posting sukses. PERFORM show_report_for_material. ENDIF.
  ENDIF.
```

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Cek stok → putuskan transfer → posting 311 → cek histori → (bila salah) batal 312 |
| B — Program | Radio Report/Posting → cabang masing-masing → validasi → (Posting) BAPI → commit/rollback → tampilkan report |

## Langkah dengan AI

**Langkah 1 — rencana perubahan.**
```
Ini source ZTRN_<INISIAL>_D03 saya: <read_program dari sandbox-new>.
Saya ingin menambahkan mode Report sesuai spesifikasi: <tempel>.
Buat RENCANA perubahan dulu (bagian mana yang tetap, mana yang dipindah ke FORM, mana yang baru). Jangan tulis kode dulu.
```

**Langkah 2 — kode dengan minimal diff.**
```
Pakai skill abap-dev-sandbox-new. Tulis ZTRN_<INISIAL>_D04 berdasarkan rencana tadi.
Pertahankan logika posting Day 03 apa adanya, hanya dipindah ke FORM. Selection screen dinamis dengan MODIF ID.
```

**Langkah 3 — tampilkan diff.**
```
Tampilkan perbandingan Day 03 vs Day 04: baris yang ditambah, diubah, dipindah. Pastikan tidak ada logika posting yang berubah.
```

**Langkah 4 — push & uji.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | Klik radio Posting | Field report hilang, field posting muncul |
| T2 | Report untuk material dari Day 03 | Stok & dokumen 311 Day 03 tampil, status Aktif |
| T3 | Posting test run | Simulasi OK |
| T4 | Posting nyata | Dokumen baru + report otomatis menampilkan dokumen tsb |

**Langkah 5 — flow** (Flow A & B).

## Tugas

1. Empat skenario uji terdokumentasi.
2. Diff Day 03 → Day 04 (ringkas, poin per poin).
3. Flow A & B selesai.

## Checklist Selesai

- [ ] Radio mengubah layar tanpa error `OBLIGATORY`.
- [ ] Logika posting sama dengan Day 03 (dibuktikan dengan diff).
- [ ] Histori menandai dokumen yang dibatalkan.
- [ ] Flow A & B selesai.

## Kuis

1. Event apa yang dipakai untuk menyembunyikan field?
2. Mengapa field tersembunyi tidak boleh `OBLIGATORY`?
3. Apa keuntungan memecah logika ke `FORM`?

<details>
<summary>Kunci jawaban</summary>

1. `AT SELECTION-SCREEN OUTPUT` dengan `LOOP AT SCREEN` + `MODIFY SCREEN`.
2. SAP tetap memeriksa field wajib walau tidak tampil di mode lain → user tidak bisa eksekusi.
3. Kode lebih mudah dibaca, diuji, dan diubah tanpa mengganggu bagian lain (minimal diff).

Potongan kode acuan — validasi per mode:

```abap
AT SELECTION-SCREEN.
  CHECK sy-ucomm = 'ONLI'.              " hanya saat Execute
  IF r_post = 'X'.
    IF p_matnr IS INITIAL OR p_lgort IS INITIAL OR p_umlgo IS INITIAL
       OR p_menge IS INITIAL.
      MESSAGE 'Mode Posting: material, SLoc asal/tujuan, qty wajib diisi'
        TYPE 'E'.
    ENDIF.
  ELSE.
    IF s_matnr[] IS INITIAL AND s_lgort[] IS INITIAL.
      MESSAGE 'Mode Report: isi minimal material atau SLoc' TYPE 'E'.
    ENDIF.
  ENDIF.
```

Potongan kode acuan — tandai dokumen dibatalkan:

```abap
" gt_hist: MSEG 311/312. Dokumen 312 menyimpan dokumen asal di SMBLN.
LOOP AT gt_hist INTO gs_hist WHERE bwart = '312'.
  CLEAR gs_cancel.
  gs_cancel-mblnr = gs_hist-smbln.
  gs_cancel-mjahr = gs_hist-sjahr.
  APPEND gs_cancel TO gt_cancel.
ENDLOOP.
SORT gt_cancel BY mblnr mjahr.
LOOP AT gt_hist INTO gs_hist WHERE bwart = '311'.
  READ TABLE gt_cancel TRANSPORTING NO FIELDS
    WITH KEY mblnr = gs_hist-mblnr mjahr = gs_hist-mjahr BINARY SEARCH.
  IF sy-subrc = 0.
    gs_hist-status = 'Dibatalkan'.
  ELSE.
    gs_hist-status = 'Aktif'.
  ENDIF.
  MODIFY gt_hist FROM gs_hist.
ENDLOOP.
```
</details>

## Referensi

- [Day 03](Day03_Program_Transfer_Posting.md) — program dasar.
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
