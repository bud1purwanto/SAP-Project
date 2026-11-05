# ZMM061 — Returnable Pallet Stock

| Atribut | Isi |
|---|---|
| Program utama | `ZMMR_RETURN_PALLET_STOCK` |
| TCODE | ZMM061 |
| Modul | MM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Report stok returnable pallet/core/sideboard, status siklus dari log ZPALLETR, mapping terminal ZMAP_TYPE per TCODE.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 1 | Source ABAP aktif |
| `scripts/` | 3 | Script push/fetch/patch/audit |
| `docs/` | 3 | FS/TS, analisa, diagram |
| `outputs/` | 2 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/Functional Specification Returnable Pallet Stock ZMM061 (v1).docx](docs/Functional%20Specification%20Returnable%20Pallet%20Stock%20ZMM061%20%28v1%29.docx) | Functional Spec v1 |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
