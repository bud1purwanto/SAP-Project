# GI_JR_CLOSING — GI Jumbo Roll vs GR (Closing PP)

| Atribut | Isi |
|---|---|
| Program utama | `ZPPR_GI_JR_CLOSING` |
| TCODE | — |
| Modul | PP / CO |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Observasi closing PP: exception GI Jumbo Roll terhadap GR (tanpa 261, GI < GR, selisih toleransi), ALV report & email notifikasi per line.

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
| [docs/FS_ZPPR_GI_JR_CLOSING.md](docs/FS_ZPPR_GI_JR_CLOSING.md) | Functional Spec |
| [docs/DESIGN.md](docs/DESIGN.md) | Desain teknis |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
