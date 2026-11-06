# LABELROL_DOCX — Cetak Label Roll via template DOCX

| Atribut | Isi |
|---|---|
| Program utama | `ZMMR_LABELROL_DOCX` (+ include `ZMMR_LABELROL_DOCX_INCL`) |
| Class | `ZCL_LABEL_DOCX` (isi template DOCX via XSLT `ZDOCX_*`, cetak via OLE Word) |
| Modul | MM (label) |
| Server analisa | dev-aix (TRD/130), read-only |
| Server write | `sandbox-new` (TRS) |
| Terakhir diperbarui | 2026-11-06 |

## 1. Tujuan
Mencetak label roll/HU dari template DOCX di `/spare/saplabel/saplabeldocx/<LABEL>.docx`. Data diambil dari karakteristik batch.

## 2. Isi Folder
| Folder | Isi |
|---|---|
| `src/` | Salinan kerja source (pull dari dev 2026-11-06) |
| `scripts/` | `fetch_src.mjs`: tarik ulang source (read-only) |
| `docs/` | Design brief |
| `outputs/` | Snapshot source dev sebelum perubahan |

## 3. Dokumen Kunci
| Dokumen | Isi |
|---|---|
| [docs/BRIEF_barcode128_qrcode_native.md](docs/BRIEF_barcode128_qrcode_native.md) | Rancangan encode Code128 & QR native ABAP (ganti labelutils/Python) |

## 4. Aturan Khusus
- SAP_BASIS 731: tanpa sintaks 7.40+ (inline declaration, constructor expression).
- Barcode di template berupa **font**, jadi string encode harus identik dengan output labelutils.

## 5. Objek SAP Terkait
| Objek | Jenis | Keterangan |
|---|---|---|
| `ZMMR_LABELROL_DOCX` | Program | Report utama |
| `ZMMR_LABELROL_DOCX_INCL` | Include | Utilitas labelutils (download exe, execute, baca log) |
| `ZCL_LABEL_DOCX` | Class | GET_DOCUMENT, PROTECT, PROTECT_SPACE, RESTORE_SPACE |
| `ZDOCX_DEL_REPEATED_TEXT`, `ZDOCX_FILL_TEMPLATE`, `ZDOCX_DEL_WSDT` | XSLT | Pengisian template |
| `ZMAP_LABEL`, `ZLABEL_WINDOWS` | Tabel/struktur | Mapping label & struktur data |
