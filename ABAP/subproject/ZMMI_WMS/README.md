# ZMMI_WMS — WMS (HU Stock with Characteristic) + asal ZBMBC

> 2026-11-05: sub-project `ZBMBC` digabung ke sini atas keputusan Baginda — ZBMBC (WMS mode) berkembang jadi program baru `ZMMI_WMS`. Nama folder tetap `ZMMI_WMS` (path dipakai script). README lama ZBMBC: [docs/README_ZBMBC_lama.md](docs/README_ZBMBC_lama.md).

| Atribut | Isi |
|---|---|
| Program utama | `ZMMI_WMS` (baru); asal: `ZBAP_STOCK_BY_CHAR1` (include `_TOP`, `_F01`) |
| TCODE | ZBMBC (program asal); ZMMI_WMS — |
| Modul | MM / WM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| README dibuat | 2026-11-05 (digabung 2026-11-05) |

## 1. Tujuan

- **ZMMI_WMS (baru):** feed WMS gudang FGS berbasis HU: VEKP (Created On + MAGRV) → HU Box/Pallet → batch → stok MCHB/MSKA → karakteristik; output ALV / WMS (staging `Y_ZBMBCSR` + `SP_Merge_ZBMBCSR_WMS`), mass select di awal.
- **ZBMBC (asal):** report Stock Overview with Characteristic, execution type Screen/OLAP/WMS — mode WMS-nya digantikan ZMMI_WMS.

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `src/` | Salinan kerja source: `ZMMI_WMS.abap`, `ZBAP_STOCK_BY_CHAR1*.abap` (bukan sumber kebenaran — pull server dulu) |
| `scripts/` | Script ZMMI_WMS (push/fetch/compare/flow/WRICEF) |
| `scripts/zbmbc/` | Script asal ZBMBC (capture ALV/WMS, compare, ADBC test). `push_program.mjs` baca `src/` langsung → wajib pull + diff dulu ([03](../../00_RULES/03_Push_Program_dan_SmartForm.md#wajib-pull-source-terbaru-sebelum-push)) |
| `docs/` | Design, FS/WRICEF, review, analisa WMS mode ZBMBC |
| `tests/` | Harness test |
| `outputs/` | Backup source, dump ALV/WMS, hasil compare; `zbmbc_logs/` log RFC lama |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/DESIGN_ZMMI_WMS_2026-10-30.md](docs/DESIGN_ZMMI_WMS_2026-10-30.md) | Desain & keputusan Baginda |
| [docs/Functional Specification HU Stock for WMS ZMMI_WMS (v1).docx](<docs/Functional Specification HU Stock for WMS ZMMI_WMS (v1).docx>) | WRICEF/FS v1 (05.11.2026) |
| [docs/2026-11-05_REVIEW_ZMMI_WMS.md](docs/2026-11-05_REVIEW_ZMMI_WMS.md) | Code review 05.11.2026 |
| [outputs/COMPARE_SUMMARY_20261103.md](outputs/COMPARE_SUMMARY_20261103.md) | Ringkasan compare vs ZBMBC |
| [docs/ANALISIS_WMS_MODE_2026-10-28.md](docs/ANALISIS_WMS_MODE_2026-10-28.md) | Analisa mode WMS ZBMBC |
| [docs/ANALISIS_WMS_MODE_2026-10-29_ADBC.md](docs/ANALISIS_WMS_MODE_2026-10-29_ADBC.md) | ADBC multi-row INSERT |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
- `outputs/ZBMBC_ALV_*` = capture ALV besar (>70 ribu baris, 10–32 MB). Jangan dibaca penuh; pakai grep/head.
