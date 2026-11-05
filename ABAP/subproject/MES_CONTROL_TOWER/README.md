# MES_CONTROL_TOWER — MES Control Tower Master Data Download

| Atribut | Isi |
|---|---|
| Program utama | `FM ZPP_MD_DL (pool SAPLZPP_MD, include LZPP_MDU01)` |
| TCODE | — |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Download master data MAST, MKAL, STPO/STKO untuk MES dengan default date 19000101 untuk tanggal kosong.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 1 | Source ABAP aktif |
| `docs/` | 1 | FS/TS, analisa, diagram |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/TECHNICAL_SPECIFICATION_MES_CONTROL_TOWER.md](docs/TECHNICAL_SPECIFICATION_MES_CONTROL_TOWER.md) | Technical Spec |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
