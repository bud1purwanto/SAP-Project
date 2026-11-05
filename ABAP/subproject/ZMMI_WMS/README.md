# ZMMI_WMS — HU Stock with Characteristic for WMS

| Atribut | Isi |
|---|---|
| Program utama | `ZMMI_WMS` |
| TCODE | — |
| Modul | MM / WM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Program feed WMS berbasis HU: VEKP → HU Box/Pallet → batch → stok MCHB/MSKA → karakteristik; output ALV/WMS, mass select di awal.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 1 | Source ABAP aktif |
| `scripts/` | 9 | Script push/fetch/patch/audit |
| `docs/` | 1 | FS/TS, analisa, diagram |
| `tests/` | 4 | Script/harness test |
| `outputs/` | 16 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/DESIGN_ZMMI_WMS_2026-10-30.md](docs/DESIGN_ZMMI_WMS_2026-10-30.md) | Desain & keputusan Baginda |
| [outputs/COMPARE_SUMMARY_20261103.md](outputs/COMPARE_SUMMARY_20261103.md) | Ringkasan compare vs ZBMBC |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
