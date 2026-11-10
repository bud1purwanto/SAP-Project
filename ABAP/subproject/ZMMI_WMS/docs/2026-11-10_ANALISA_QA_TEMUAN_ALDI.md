# Analisa Temuan QA Aldi — ZMMI_WMS vs ZBMBC (2026-11-10)

| Atribut | Isi |
|---|---|
| Server | `qa` (TRQ 320), read-only |
| Program | `ZMMI_WMS` QA (UDAT 06.11.2026) = `src/ZMMI_WMS.abap` (diff kosong), `ZBAP_STOCK_BY_CHAR1_F01` QA → `outputs/*_qa.abap` |
| Pelapor | Aldi Dwi Kusuma (chat 3:23 PM) |
| Perubahan kode | Tidak ada |

## Logika HU di ZBMBC (QA, `ZBAP_STOCK_BY_CHAR1_F01` baris 843-866)

HU diisi hanya bila isi HU cocok dengan stock line: `VEPO-MATNR/CHARG/WERKS` **+ `VEPO-LGORT` = Sloc stok + `VEPO-SOBKZ` = jenis stok** + `VEKP-MAGRV`.
ZMMI_WMS hanya mencocokkan Material + Plant + Batch (temuan M4 di review 05.11.2026).

## 1. Batch 0003860400 — "duplikat"

| Data | Isi |
|---|---|
| HU | VENUM 0000702397 = **6000319605** (PLT, dibuat 27.01.2026), isi VEPO Sloc **2309**, 17,110 |
| MCHB | 2000/**2309** 17,110 (ERSDA 27.01.2026) · 2000/**2310** 118,758 (LAEDA 27.01.2026) · 2801 0 |
| MSEG | 311 tahun 2026: 17,110 dari 2310 → 2309 (sisa 118,758 tetap di 2310, tanpa HU) |

- **ZMMI_WMS Screen:** 2 stock line (2309 dan 2310) × 1 HU → **2 baris dengan HU yang sama** → terlihat duplikat. Baris 2310 seharusnya tidak punya HU.
- **ZBMBC:** 2309 → HU 6000319605; 2310 → HU kosong (VEPO-LGORT ≠ 2310).
- **ZMMI_WMS mode WMS:** unique batch memilih baris 2309 (Sloc = Sloc isi HU) → 1 baris; stok 2310 (118,758) tidak dikirim.
- **Akar masalah:** M4 — HU dipasang ke semua Sloc stok batch tanpa cek `VEPO-LGORT`.

## 2. Batch 0003879068 — di ZMMI ada HU, di ZBMBC tidak

| Data | Isi |
|---|---|
| HU | VENUM 0000701877 = **6000319206** (PLT, dibuat 20.05.2025), isi VEPO 2000/**1813**, **SOBKZ E, SO 15451/90**, 880,760 |
| MCHB | 2000/**1813** 880,760 (stok bebas, ERSDA 23.04.2026) |
| MSKA | semua 0 (15451/10, 15451/90, 15685/10) |
| MSEG terakhir | 413 15451/90 → 15685/10, lalu **411** 15685/10 → stok bebas 1813 (2026) |

- Fisik batch tetap di HU 6000319206 dan Sloc sama (1813). Yang berubah hanya jenis stok (SO → bebas) via 413/411; isi HU (VEPO-SOBKZ/SONUM) tidak ikut ter-update.
- **ZBMBC:** stok bebas (SOBKZ kosong) ≠ VEPO-SOBKZ 'E' → HU kosong.
- **ZMMI_WMS:** cocok Material + Plant + Batch → HU 6000319206 tampil.
- Secara fisik HU ZMMI benar; secara aturan ZBMBC tidak cocok. Perlu keputusan bisnis.

## 3. Batch 0003884578 & 0003880100

Di-exclude Aldi karena data transaksi QA keliru; batch dihapus Aldi. Tidak dianalisa.

## Usulan (perlu AGREED Baginda)

| Opsi | Aturan HU | 0003860400 | 0003879068 |
|---|---|---|---|
| A (rekomendasi) | Cocok Sloc (`VEPO-LGORT` = Sloc stok), SOBKZ diabaikan | 2310 tanpa HU → tidak duplikat | HU tetap tampil (Sloc sama) |
| B | Sama persis ZBMBC (Sloc + SOBKZ) | sama dengan A | HU kosong, sama ZBMBC |
| C | Tetap (as-is) | tetap duplikat di Screen | HU tampil |

Pertanyaan turunan: stock line yang tidak punya HU cocok (mis. 2310 = 118,758) — tetap ditampilkan dengan HU kosong (seperti ZBMBC) atau dibuang (program berbasis HU)?
Mode WMS tidak terpengaruh untuk 0003860400 (unique batch sudah memilih 2309).
