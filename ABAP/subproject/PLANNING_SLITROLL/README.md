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

| Folder | Isi |
|---|---|
| `src/` | Salinan kerja source, 1 file per objek (pull server dulu sebelum push) |
| `scripts/` | Script push/fetch/patch/audit |
| `docs/` | FS/TS, analisa, diagram |
| `tests/` | Script/harness test |
| `outputs/` | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/TECHNICAL_NOTES.md](docs/TECHNICAL_NOTES.md) | Catatan teknis & mapping |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
