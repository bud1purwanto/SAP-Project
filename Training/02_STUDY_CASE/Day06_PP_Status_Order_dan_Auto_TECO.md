# Day 06 — PP: Status Production Order & Auto TECO

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | PP | `prod` (read-only) + `sandbox-new` (write) | 3–4 jam | pp-analisa-production |

## Tujuan

1. Memahami **status objek** SAP (`JEST`, `TJ02T`) dan arti REL, PCNF, CNF, DLV, TECO, CLSD.
2. Melakukan analisa "mengapa order ini belum TECO?" dari data Production.
3. Menghubungkan aturan bisnis dengan logic Z program (`ZPPI_COHVPI`).

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D06` — **TECO Readiness Checker**: status aktif, qty target vs GR, confirmation terakhir, dan rekomendasi per order |
| 2 | Flow A (siklus status order CRTD → CLSD) + Flow B (aturan keputusan "siap TECO" di program) |
| 3 | Laporan analisa 1 order nyata di Production yang belum TECO |

## Cerita Kasus

Setiap akhir bulan PPIC menjalankan Auto TECO (`ZPPI_COHVPI`) untuk menutup order yang sudah selesai.
Ternyata beberapa order tetap berstatus **REL** dan tidak ter-TECO. Controller bertanya:
*"Kenapa order ini tidak ikut di-TECO? Apakah programnya salah atau datanya yang belum lengkap?"*

## Konsep Kunci

Siklus status order (sederhana):

```
CRTD (created) -> REL (released) -> PCNF (partially confirmed) -> CNF (confirmed)
   -> DLV (delivered, GR penuh) -> TECO (technically completed) -> CLSD (closed, setelah settlement)
```

| Kode internal | Singkatan | Arti |
|---|---|---|
| I0001 | CRTD | Created |
| I0002 | REL | Released |
| I0010 | PCNF | Partially confirmed |
| I0009 | CNF | Confirmed |
| I0012 | DLV | Delivered |
| I0045 | TECO | Technically completed |
| I0046 | CLSD | Closed |

> Verifikasi kode di `TJ02T` (jangan menghafal; minta AI membacanya).

- `AUFK-OBJNR` (contoh `OR000100007232823`) adalah kunci ke `JEST`.
- `JEST-INACT = 'X'` berarti status **tidak aktif** lagi. Hanya baca yang `INACT = ' '`.
- FM standar membaca status: `STATUS_READ` (hanya baca).

## Spesifikasi Program `ZTRN_<INISIAL>_D06`

| Bagian | Isi |
|---|---|
| Input | `S_AUFNR`, `S_ERDAT`, `S_AUART` (default: order type dari `ZMAP_TYPE` `PROG = 'ZPPI_COHVPI'`), `P_DAYS` (hari tanpa movement, default 7) |
| Data | `AUFK` (OBJNR) → `JEST` (status aktif, `INACT = ' '`) + `TJ02T` (teks) → `AFPO` (PSMNG, WEMNG) → `AFRU` (confirmation terakhir, `STOKZ` kosong) → `AUFM` (movement terakhir) — semua via FOR ALL ENTRIES |
| Aturan | Sudah `TECO`/`CLSD` → "Sudah TECO". `DLV` atau WEMNG ≥ PSMNG, dan tidak ada movement ≥ `P_DAYS` hari → **"Siap TECO"** (hijau). WEMNG < PSMNG → "GR belum penuh" (kuning). Movement < `P_DAYS` hari → "Masih aktif" (kuning). Tanpa confirmation → "Belum confirm" (merah) |
| Output | ALV: lampu, order, order type, material, status aktif (gabung teks), PSMNG, WEMNG, % GR, tgl confirmation terakhir, tgl movement terakhir, rekomendasi |
| Batasan | **Hanya report** — tidak melakukan TECO |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | CRTD → REL → PCNF → CNF → DLV → TECO → CLSD, siapa/TCODE apa yang memicu tiap perubahan |
| B — Program | Input → ambil order → ambil status/qty/confirmation/movement → pohon keputusan rekomendasi → ALV |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — pilih sampel.**
```
Pakai skill pp-analisa-production, server prod read-only.
Cari 5 order dari AUFK dengan ERDAT bulan lalu dan AUART yang ada di ZMAP_TYPE untuk PROG = 'ZPPI_COHVPI'.
Tampilkan AUFNR, AUART, ERDAT, OBJNR.
```

**Langkah 2 — status tiap order.**
```
Untuk 5 order tadi, baca JEST (OBJNR, INACT = ' ', STAT LIKE 'I%') lalu terjemahkan via TJ02T (SPRAS = 'E').
Tampilkan tabel: order, daftar status aktif.
```

**Langkah 3 — kelengkapan.**
```
Untuk order yang belum TECO: bandingkan AFPO-PSMNG vs WEMNG, cek confirmation terakhir di AFRU (STOKZ kosong),
dan cek movement terakhir di AUFM. Simpulkan alasan paling mungkin belum TECO.
```

**Langkah 4 — cocokkan dengan program.**
```
Baca source ZPPI_COHVPI. Temukan kriteria order yang dipilih untuk TECO (status, movement, tanggal).
Apakah order tadi memenuhi kriteria? Tunjukkan baris kodenya.
```

**Langkah 5 — program TECO Readiness Checker.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D06 sesuai spesifikasi: <tempel>.
Status aktif per order digabung jadi satu teks (contoh "REL PCNF DLV"). Push ke sandbox-new dan jalankan.
Bandingkan rekomendasi program untuk 5 order dengan analisa manual Anda di langkah 1-4.
```

**Langkah 6 — flow** (Flow A & B, ikuti template).

## Tugas

Buat laporan analisa (pakai [Template_Laporan_Analisa.md](../03_TEMPLATE/Template_Laporan_Analisa.md)) untuk 1 order yang belum TECO:
- Status aktif, qty target vs GR, confirmation terakhir.
- Kriteria program yang tidak terpenuhi.
- Kesimpulan: **data belum lengkap** atau **program perlu disesuaikan**.

## Checklist Selesai

- [ ] Bisa membaca status order dari `JEST` + `TJ02T`.
- [ ] Bisa membedakan masalah data vs masalah program.
- [ ] Laporan selesai dengan bukti data.

- [ ] Program `ZTRN_<INISIAL>_D06` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai dan cocok dengan kode.

## Kuis

1. Apa arti `JEST-INACT = 'X'`?
2. Mengapa program interface (contoh ke MES) dilarang memproses order TECO/DLV/CLSD?
3. Apa beda TECO dan CLSD?

<details>
<summary>Kunci jawaban</summary>

1. Status tersebut pernah aktif tetapi sekarang sudah tidak berlaku.
2. Order sudah selesai/tertutup; memproses ulang bisa membuat posting ganda, biaya salah, atau data tidak konsisten.
3. TECO = secara teknis selesai (tidak ada aktivitas logistik lagi), masih bisa menerima biaya/settlement; CLSD = ditutup penuh setelah settlement, tidak bisa diposting lagi.
</details>

## Referensi

- [AUTO_TECO_ZPP001/](../05_REFERENSI/AUTO_TECO_ZPP001/) — FS dan source `ZPPI_COHVPI`.
- [CHECKPOINT_PP_AUTO_TECO.md](../05_REFERENSI/AUTO_TECO_ZPP001/CHECKPOINT_PP_AUTO_TECO.md)
