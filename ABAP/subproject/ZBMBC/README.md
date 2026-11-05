# ZBMBC — Stock Overview with Characteristic (WMS)

| Atribut | Isi |
|---|---|
| Program utama | `ZBAP_STOCK_BY_CHAR1 (include _TOP, _F01)` |
| TCODE | ZBMBC |
| Modul | MM / WM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Report stock overview dengan karakteristik; execution type Screen/OLAP/WMS, feed HU ke WMS gudang FGS via staging Y_ZBMBCSR + SP_Merge_ZBMBCSR_WMS.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 3 | Source ABAP aktif |
| `scripts/` | 14 | Script push/fetch/patch/audit |
| `docs/` | 2 | FS/TS, analisa, diagram |
| `outputs/` | 48 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/ANALISIS_WMS_MODE_2026-10-28.md](docs/ANALISIS_WMS_MODE_2026-10-28.md) | Analisa mode WMS |
| [docs/ANALISIS_WMS_MODE_2026-10-29_ADBC.md](docs/ANALISIS_WMS_MODE_2026-10-29_ADBC.md) | ADBC multi-row INSERT |

## 4. Catatan / Aturan Khusus

- `outputs/` berisi capture ALV besar (>70 ribu baris per file). Jangan dibaca penuh; pakai grep/head.
