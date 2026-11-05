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

| Folder | Isi |
|---|---|
| `src/` | Salinan kerja source, 1 file per objek (pull server dulu sebelum push) |
| `scripts/` | Script push/fetch/patch/audit; `scripts/_adhoc/` = 244 script check/inspect/sim sekali pakai |
| `docs/` | FS/TS, analisa, diagram |
| `tests/` | Script/harness test |
| `outputs/` | Backup source, dump, hasil compare; `outputs/src_snapshot/` = versi/kandidat lama dari `src/` |

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

- Wajib patuhi arsitektur di [ARCHITECTURE_COA_DYNAMIC.md](ARCHITECTURE_COA_DYNAMIC.md) saat mengembangkan/memperbaiki COA (dipindah dari `00_RULES/06`, 2026-11-05):
  1. `ZQMF_COA` murni hanya untuk Page 1 (Sertifikat / MIC Inspection Characteristics).
  2. `ZQMF_COA_BATCH_POTRAIT` khusus Lampiran Batch List (Portrait <= 8 kolom).
  3. `ZQMF_COA_BATCH_LANDSCAPE` khusus Lampiran Batch List (Landscape > 8 kolom).
  4. Mapping dan ukuran kolom dinamis sesuai tabel `ZQM_COA_CUST_COL`.
  5. Contoh verifikasi data uji:
     - DO `85004908` (6 kolom - DOM_DEFAUL) → ZQMF_COA + ZQMF_COA_BATCH_POTRAIT (2 hal Portrait)
     - DO `0084000047` (7 kolom - SRAABI) → ZQMF_COA + ZQMF_COA_BATCH_POTRAIT (2 hal Portrait)
     - DO `0085000140` (10 kolom - SRACLI) → ZQMF_COA + ZQMF_COA_BATCH_LANDSCAPE (Page 1 Port + Page 2 Land)
- `package.json` di root folder ini dipakai script Node; jangan dipindah.
