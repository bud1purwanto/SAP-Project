# ZPP090 — Change / Mundurkan Nomor Jumbo Roll

| Atribut | Isi |
|---|---|
| Program utama | `ZPPI_CHANGE_JR_NUMBER` |
| TCODE | ZPP090 |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Koreksi dan pemunduran sequence nomor JR, update counter ZSEQNUM & log ZLOG_JRNO, termasuk fix line CPP 2 digit.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 1 | Source ABAP aktif |
| `docs/` | 1 | FS/TS, analisa, diagram |
| `outputs/` | 1 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [CHECKPOINT.md](CHECKPOINT.md) | Root cause & live testing |
| [docs/EMAIL_LOG_MEMUNDURKAN_NO_ROLL.md](docs/EMAIL_LOG_MEMUNDURKAN_NO_ROLL.md) | Log email kasus |

## 4. Catatan / Aturan Khusus

- Ikuti aturan global di [AGENTS.md](../../AGENTS.md).
