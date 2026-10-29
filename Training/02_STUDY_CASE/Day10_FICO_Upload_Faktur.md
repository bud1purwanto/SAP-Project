# Day 10 — FICO: Upload Faktur & BKPF-AEDAT

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★ | FI | `prod` (read-only) + `sandbox-new` (write) | 4 jam | fico-analisa-production |

## Tujuan

1. Memahami struktur dokumen FI (`BKPF`/`BSEG`) dan **jejak audit** (`CDHDR`/`CDPOS`).
2. Menganalisa mengapa Z program yang mengubah dokumen tidak meninggalkan jejak yang sama seperti transaksi standar.
3. Menimbang solusi dari sisi **audit & compliance**, bukan hanya teknis.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D10` — **Upload & Audit Checker Faktur** (simulasi, tanpa update) |
| 2 | Flow A (upload faktur pajak sampai audit) + Flow B (upload file → validasi → cek jejak audit) |
| 3 | Laporan analisa untuk auditor |

## Cerita Kasus

Tim pajak meng-upload nomor faktur pajak ke dokumen FI melalui `ZFI106` (`ZFIC_UPLOAD_FAKTUR`).
Nomor faktur masuk ke `BKPF-XBLNR` dengan benar. Namun auditor menemukan:

- Field **"Changed On" (`BKPF-AEDAT`)** tetap kosong/tanggal lama.
- Di `FB03` → *Environment → Document Changes*, perubahan nomor faktur **tidak terlihat**.

Auditor bertanya: *"Siapa yang mengubah nomor faktur, kapan? Mengapa tidak tercatat?"*

## Konsep Kunci

| Field / Tabel | Arti |
|---|---|
| `BKPF-XBLNR` | Reference / nomor faktur pajak |
| `BKPF-CPUDT`/`CPUTM`/`USNAM` | Kapan & siapa **membuat** dokumen (tidak boleh diubah) |
| `BKPF-AEDAT` | Tanggal perubahan terakhir **oleh transaksi** |
| `CDHDR`/`CDPOS` | Change document: siapa, kapan, field apa, nilai lama → baru (object `BELEG`) |

- Transaksi standar `FB02` mengisi `AEDAT` dan membuat change document.
- FM level rendah `CHANGE_DOCUMENT` (dipakai Z program ini) hanya mengupdate field yang dikirim; **tidak** otomatis men-stamp `AEDAT`.
- Audit trail lengkap butuh `CHANGEDOCUMENT_OPEN` → `CHANGEDOCUMENT_SINGLE_CASE` → `CHANGEDOCUMENT_CLOSE` (object `BELEG`), atau memakai jalur FM standar yang setara FB02.

## Spesifikasi Program `ZTRN_<INISIAL>_D10`

| Bagian | Isi |
|---|---|
| Input | `P_FILE` (file CSV/TXT di PC: BUKRS;BELNR;GJAHR;FAKTUR), F4 untuk pilih file |
| Proses | 1) Upload file (`GUI_UPLOAD` / `CL_GUI_FRONTEND_SERVICES`). 2) Validasi format (kolom lengkap, faktur 16+ digit). 3) Cek dokumen di `BKPF` (FOR ALL ENTRIES). 4) Bandingkan `XBLNR` sekarang vs faktur di file. 5) Cek `CDHDR` (`OBJECTCLAS = 'BELEG'`) untuk dokumen tsb |
| Output | ALV: dokumen, faktur file, `XBLNR` sekarang, `AEDAT`, ada change document?, status (`Dokumen tidak ada` / `Sudah sama` / `Akan berubah` / `Format salah`), catatan audit |
| Batasan | **Tidak mengubah** `BKPF`. Program hanya simulasi + audit check |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Tim pajak terima faktur → upload `ZFI106` → `BKPF-XBLNR` berubah → auditor cek `FB03` (Document Changes) |
| B — Program | Pilih file → upload → validasi baris → cek BKPF → bandingkan → cek CDHDR → status → ALV |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — bukti data.**
```
Pakai skill fico-analisa-production, server prod read-only.
Ambil 3 dokumen BKPF yang XBLNR-nya diisi lewat ZFI106 (minta saya memberikan BUKRS/BELNR/GJAHR sampel).
Tampilkan XBLNR, CPUDT, USNAM, TCODE, AEDAT, UPDDT.
```

**Langkah 2 — jejak audit.**
```
Untuk dokumen yang sama, cek CDHDR dengan OBJECTCLAS = 'BELEG' dan OBJECTID = BUKRS+BELNR+GJAHR
(minta AI menjelaskan format OBJECTID dan cek di sistem). Ada entry perubahan XBLNR atau tidak?
```

**Langkah 3 — kode.**
```
Baca source ZFIC_UPLOAD_FAKTUR, FORM EXECUTION. Jelaskan:
(a) field apa yang diubah, (b) FM apa yang dipanggil, (c) mengapa AEDAT tidak berubah,
(d) bandingkan dengan perilaku FB02.
```

**Langkah 4 — opsi solusi.**
```
Beri 2 opsi solusi beserta kelebihan, kekurangan, dan risiko audit masing-masing.
Opsi 1: stamp AEDAT = SY-DATUM saja. Opsi 2: AEDAT + change document object BELEG.
```

**Langkah 5 — program Upload & Audit Checker (Sandbox).**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D10 sesuai spesifikasi: <tempel>.
Cari 3 dokumen BKPF di sandbox-new untuk data uji, buat file CSV contoh (1 baris format salah, 1 dokumen tidak ada).
Format OBJECTID CDHDR untuk BELEG: cek dulu dari contoh nyata di sandbox, jangan menebak.
```

**Langkah 6 — flow** (Flow A & B).

## Tugas

Laporan analisa 1 halaman untuk auditor dan tim FI:
1. Ringkasan masalah (bahasa awam).
2. Bukti data (sebelum/sesudah, ada/tidak CDHDR).
3. Root cause (lokasi kode).
4. Rekomendasi + alasan audit.
5. Field yang **tidak boleh** disentuh.

## Checklist Selesai

- [ ] Paham beda field "dibuat" vs "diubah" di `BKPF`.
- [ ] Paham peran `CDHDR`/`CDPOS` untuk audit.
- [ ] Rekomendasi mempertimbangkan compliance, bukan hanya "angka muncul".

- [ ] Program `ZTRN_<INISIAL>_D10` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai dan cocok dengan kode.

## Kuis

1. Mengapa `UPDATE BKPF SET ...` langsung dari program dilarang?
2. Field mana yang mencatat siapa pembuat dokumen?
3. Di mana auditor melihat histori perubahan dokumen FI?

<details>
<summary>Kunci jawaban</summary>

1. Melewati validasi standar, tidak ada change document, merusak audit trail, dan berisiko inkonsistensi data.
2. `BKPF-USNAM` (dengan `CPUDT`/`CPUTM`).
3. `FB03` → *Environment → Document Changes*, yang membaca `CDHDR`/`CDPOS`.
</details>

## Referensi

- [ZFIC_UPLOAD_FAKTUR_BKPF_AEDAT_Analysis.md](../05_REFERENSI/FICO_UPLOAD_FAKTUR/ZFIC_UPLOAD_FAKTUR_BKPF_AEDAT_Analysis.md)
