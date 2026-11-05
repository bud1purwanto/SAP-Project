# PLANNING_SLITROLL — Report Hasil Planning Slit Roll

| Atribut | Isi |
|---|---|
| Program utama | `ZPPR_PLANNING_SLITROLL` |
| TCODE | — |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Report ALV hasil planning Slit Roll: relasi vendor batch → original order → combine order, mapping order type SR di ZMAP_TYPE.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 1 | Source ABAP aktif |
| `scripts/` | 0 | Script push/fetch/patch/audit |
| `docs/` | 1 | FS/TS, analisa, diagram |
| `tests/` | 0 | Script/harness test |
| `outputs/` | 0 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/TECHNICAL_NOTES.md](docs/TECHNICAL_NOTES.md) | Catatan teknis & mapping |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
