# PROCESS_ORDER_RFC — Create Process Order (COR1) via RFC

| Atribut | Isi |
|---|---|
| Program utama | `ABAP4_CALL_TRANSACTION → COR1 (tanpa objek Z)` |
| TCODE | COR1 |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Solusi membuat process order JR (Total Qty 1 ROL, base quantity KG) dari aplikasi luar SAP via RFC, zero transport, background.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 0 | Source ABAP aktif |
| `scripts/` | 0 | Script push/fetch/patch/audit |
| `docs/` | 1 | FS/TS, analisa, diagram |
| `tests/` | 0 | Script/harness test |
| `outputs/` | 0 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/Solusi_COR1_via_RFC.md](docs/Solusi_COR1_via_RFC.md) | Analisa & solusi |

## 4. Catatan / Aturan Khusus

- Dipindah dari `Claude outputs/` pada 2026-11-05.
