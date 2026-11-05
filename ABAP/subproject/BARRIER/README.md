# BARRIER — Barrier Inspection & Usage Decision

| Atribut | Isi |
|---|---|
| Program utama | `ZQMI_PENDING_BARRIER, ZQMI_BARRIER_PASS_FAIL, FM ZQM_GET_BATCH_SR_BY_JR` |
| TCODE | ZQM004 |
| Modul | QM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Barrier Inspection List & Upload, Result Recording dan Usage Decision untuk karakteristik barrier (WVTR/MVTR, OTR/O2TR).

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `src/` | Salinan kerja source, 1 file per objek (pull server dulu sebelum push) |
| `scripts/` | Script push/fetch/patch/audit |
| `outputs/` | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

Belum ada.

## 4. Catatan / Aturan Khusus

- Belum ada dokumen di `docs/`. Buat FS/checkpoint dari [01_TEMPLATE](../../01_TEMPLATE/).
