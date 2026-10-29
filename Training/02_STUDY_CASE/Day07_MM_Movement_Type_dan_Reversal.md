# Day 07 — MM: Movement Type, Reversal & GI JR Closing

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | MM / PP | `prod` (read-only) + `sandbox-new` (write) | 3–4 jam | mm-analisa-production, abap-dev-sandbox-new |

## Tujuan

1. Memahami movement type 101/102/261/262/531/532 dan cara **menghitung netto**.
2. Menangani dokumen **reversal** dengan benar (jebakan paling umum di report SAP).
3. Membuat report mini "GR vs GI per batch" di Sandbox.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D07` — GR vs GI per order JR, 3 mode (Semua / Tanpa GI / GI kurang) |
| 2 | Flow A (produksi JR: GR 101, GI 261, waste 531, reversal) + Flow B (agregasi netto & keputusan mode) |
| 3 | Analisa 1 order nyata di Production |

## Cerita Kasus

Saat closing bulanan PP, tim cost accounting menemukan **Jumbo Roll yang sudah di-GR tetapi bahan bakunya belum di-GI**,
atau GI-nya lebih kecil dari GR. Ini membuat biaya produksi tidak akurat.
Dibuatlah `ZPPR_GI_JR_CLOSING` dengan 3 mode:

| Mode | Kriteria |
|---|---|
| `R_ALL` | Semua anomali |
| `R_NOGI` | GR efektif > 0 tetapi GI efektif = 0 |
| `R_LESS` | GI efektif > 0 tetapi GI < GR − toleransi |

Selisih wajar ada karena **Extra Length** (~1%) dari PPIC:

```
Waste Combine = Qty GI JR − Qty GR Slit Roll − Qty Extra Length
Contoh: 1.771,45 − 1.693,50 − 14,84 = 63,11 kg
```

## Konsep Kunci

- **Netto GR** = Σ(101) − Σ(102). **Netto GI** = Σ(261) − Σ(262).
- Pembatalan via MBST membuat dokumen baru (102/262) dan mengisi `MSEG-SMBLN` = nomor dokumen asal.
- Jebakan: menjumlahkan hanya 101 dan 261 tanpa 102/262 → angka **terlihat dobel** setelah ada cancel.
- `MKPF-BKTXT` (header text) di Trias sering berisi nomor roll atau combine order — berguna untuk penelusuran.

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Mesin film → GR JR (101) + GI bahan (261) + waste (531) → closing; cabang pembatalan 102/262 |
| B — Program | Input → ambil movement → hitung netto per order → keputusan mode R_ALL/R_NOGI/R_LESS dengan toleransi → ALV |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — pahami FS.**
```
Baca 05_REFERENSI/GI_JR_CLOSING/FS_ZPPR_GI_JR_CLOSING.md.
Ringkas dalam 5 poin untuk orang awam: masalah bisnis, 3 mode, rumus, dan peran reversal.
```

**Langkah 2 — analisa 1 batch nyata.**
```
Pakai skill mm-analisa-production, server prod read-only.
Ambil 1 order JR bulan lalu dari AUFM (filter AUFNR). Tampilkan semua movement 101/102/261/262/531/532:
MBLNR, BWART, MATNR, CHARG, MENGE, SMBLN, BUDAT. Hitung netto GR dan netto GI.
```

**Langkah 3 — report mini di Sandbox.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D07:
- Input: S_AUFNR, S_BUDAT, P_TOL (toleransi kg, default 0)
- Ambil MSEG (via AUFM atau MSEG WHERE AUFNR) movement 101 102 261 262
- Agregasi per AUFNR: qty_gr_net, qty_gi_net, cnt_261_net
- Radio R_ALL / R_NOGI / R_LESS sesuai FS
- Tampilkan ALV
Jangan SELECT di dalam LOOP. Gunakan COLLECT atau SORTED TABLE untuk agregasi.
```

**Langkah 4 — uji jebakan reversal.** Cari di Sandbox (atau minta AI mencari) order yang punya 102 atau 262. Pastikan hasil report tidak dobel.

**Langkah tambahan — flow.**
```
Buatkan Flow A dan Flow B (Mermaid) sesuai tabel "Flow yang Dibuat", berdasarkan kode program saya. Cek silang: setiap tabel dan keputusan di kode harus muncul di Flow B.
```

## Tugas

1. Laporan 1 order nyata: tabel movement + netto + kesimpulan (normal / NOGI / LESS).
2. Program `ZTRN_<INISIAL>_D07` berjalan di Sandbox.
3. Tulis 3 kalimat: apa yang terjadi bila reversal diabaikan.

## Checklist Selesai

- [ ] Bisa menghitung netto dengan pasangan reversal.
- [ ] Paham alasan bisnis toleransi/extra length.
- [ ] Report mini berjalan dengan 3 mode.

- [ ] Program `ZTRN_<INISIAL>_D07` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai dan cocok dengan kode.

## Kuis

1. Batch punya 101 = 1.000 kg, 102 = 1.000 kg, 101 = 980 kg. Berapa netto GR?
2. Field apa di `MSEG` yang menunjuk dokumen yang dibatalkan?
3. Mengapa selisih GI vs GR tidak selalu berarti error?

<details>
<summary>Kunci jawaban</summary>

1. 1.000 − 1.000 + 980 = **980 kg**.
2. `SMBLN` (dengan `SJAHR`, `SMBLP`).
3. Ada extra length dari PPIC dan waste combine yang wajar secara operasional; karena itu dipakai toleransi.
</details>

## Referensi

- [FS_ZPPR_GI_JR_CLOSING.md](../05_REFERENSI/GI_JR_CLOSING/FS_ZPPR_GI_JR_CLOSING.md)
- [DESIGN.md](../05_REFERENSI/GI_JR_CLOSING/DESIGN.md)
