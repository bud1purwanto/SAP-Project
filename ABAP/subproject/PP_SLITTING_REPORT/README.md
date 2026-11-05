# PP_SLITTING_REPORT — Rekap Slitting Harian

| Atribut | Isi |
|---|---|
| Program utama | `ZPPR_SLITTING_REKAP_DAILY, ZPPR_SLITTING_REKAP_PC_V2` |
| TCODE | ZPP016, ZPP016N, ZPP106 |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Rekap slitting harian, perbandingan ZPP016 vs ZPP016N, traceability batch/final batch, export OLAP.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 8 | Source ABAP aktif |
| `scripts/` | 1 | Script push/fetch/patch/audit |
| `docs/` | 2 | FS/TS, analisa, diagram |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/MATRIX_ZPP016_VS_ZPP016N.md](docs/MATRIX_ZPP016_VS_ZPP016N.md) | Matrix perbedaan ZPP016 vs ZPP016N |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
