# COA — Certificate of Analysis

| Atribut | Isi |
|---|---|
| Program utama | `ZQMI_COA / ZQMR_COA (include ZQMI_CERTIFICATE_F01), Smart Forms ZQMF_COA*` |
| TCODE | ZQM002 (print), ZQM003 (ALV) |
| Modul | QM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Certificate of Analysis mode print & ALV via cabang SY-TCODE, batch list dinamis multi-level, perbaikan decimal MIC dari QPMK.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 76 | Source ABAP aktif |
| `scripts/` | 324 | Script push/fetch/patch/audit |
| `docs/` | 36 | FS/TS, analisa, diagram |
| `tests/` | 18 | Script/harness test |
| `outputs/` | 229 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [ARCHITECTURE_COA_DYNAMIC.md](ARCHITECTURE_COA_DYNAMIC.md) | Arsitektur resmi Smart Forms COA dinamis (wajib) |
| [docs/COA.md](docs/COA.md) | Ringkasan COA |
| [docs/ZQMI_COA_Technical_Specification.md](docs/ZQMI_COA_Technical_Specification.md) | Technical Spec |
| [docs/WRICEF_ZQM002_Certificate_of_Analysis.md](docs/WRICEF_ZQM002_Certificate_of_Analysis.md) | WRICEF ZQM002 |
| [docs/STANDAR_SKENARIO_TESTING_COA.md](docs/STANDAR_SKENARIO_TESTING_COA.md) | Standar skenario testing |
| [docs/SMARTFORM.md](docs/SMARTFORM.md) | Catatan Smart Form |
| [docs/SMARTFORMS_PATCH.md](docs/SMARTFORMS_PATCH.md) | Patch Smart Form |

## 4. Catatan / Aturan Khusus

- Wajib patuhi arsitektur di [ARCHITECTURE_COA_DYNAMIC.md](ARCHITECTURE_COA_DYNAMIC.md) dan [00_RULES/06](../../00_RULES/06_Aturan_Khusus_Subproject.md).
- `package.json` di root folder ini dipakai script Node; jangan dipindah.
