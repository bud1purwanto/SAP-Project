# AUTO_TECO — Auto TECO Production Order

| Atribut | Isi |
|---|---|
| Program utama | `ZPPI_COHVPI, ZPPR_ZPP001` |
| TCODE | COHVPI / ZPP001 |
| Modul | PP |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Auto TECO Production Order (interface MES) dengan validasi status order dan email notifikasi HTML + lampiran Excel. Juga memuat analisa insiden GR duplikat ZPP001 (ZPPI_SR_PROCESS).

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 2 | Source ABAP aktif |
| `scripts/` | 5 | Script push/fetch/patch/audit |
| `docs/` | 10 | FS/TS, analisa, diagram |
| `tests/` | 3 | Script/harness test |
| `outputs/` | 5 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [CHECKPOINT.md](CHECKPOINT.md) | Status program & struktur |
| [docs/CHECKPOINT_ZPPI_COHVPI_FS_v5.md](docs/CHECKPOINT_ZPPI_COHVPI_FS_v5.md) | Checkpoint FS v5 |
| [docs/FS_Auto_TECO_ZPPI_COHVPI_v4.docx](docs/FS_Auto_TECO_ZPPI_COHVPI_v4.docx) | Functional Spec v4 |
| [docs/2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md](docs/2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md) | Analisa GR duplikat ZPP001 |
| [docs/2026-10-16_USULAN_ENHANCEMENT_ZPP001_ANTI_GR_DUPLIKAT.md](docs/2026-10-16_USULAN_ENHANCEMENT_ZPP001_ANTI_GR_DUPLIKAT.md) | Usulan enhancement anti GR duplikat |
| [docs/2026-10-17_STATUS_BUKTI_ZPP001_GR3X.md](docs/2026-10-17_STATUS_BUKTI_ZPP001_GR3X.md) | Status bukti GR 3x |

## 4. Catatan / Aturan Khusus

- File `*_payload.json` di root folder ini dibaca/ditulis script di `scripts/` relatif terhadap working directory. **Jangan dipindah** tanpa menyesuaikan script.
