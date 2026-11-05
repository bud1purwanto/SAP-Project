# PO_EMAIL — PO Notification Email & Approver Routing

| Atribut | Isi |
|---|---|
| Program utama | `ZMMI_PO_EMAIL` |
| TCODE | — |
| Modul | MM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Routing approver berjenjang, notifikasi email PO (HTML + Excel), mapping ZMAP_TYPE (EMAIL_TEXT, EXC_RULE, GM, PRICE_AXES, DEFAULT), dynamic exception rules, last price.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 36 | Source ABAP aktif |
| `scripts/` | 5 | Script push/fetch/patch/audit |
| `docs/` | 12 | FS/TS, analisa, diagram |
| `outputs/` | 9 | Backup source, dump, hasil compare |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/Functional Specification PO Notification Sprint2 (v8).docx](docs/Functional%20Specification%20PO%20Notification%20Sprint2%20%28v8%29.docx) | FS terbaru (v8) |
| [docs/2026-07-29-po-email-excel-attachment.md](docs/2026-07-29-po-email-excel-attachment.md) | Lampiran Excel |
| [docs/2026-07-30-zmmi-po-email-dynamic-exception-rules.md](docs/2026-07-30-zmmi-po-email-dynamic-exception-rules.md) | Dynamic exception rules |
| [docs/IMPL_ZMMI_PO_EMAIL_lastprice.md](docs/IMPL_ZMMI_PO_EMAIL_lastprice.md) | Implementasi last price |
| [docs/MAP_PO_PRINT_lastprice.md](docs/MAP_PO_PRINT_lastprice.md) | Mapping PO print last price |

## 4. Catatan / Aturan Khusus

- `src/` berisi banyak backup `*_before_*` — sumber aktif: `src/ZMMI_PO_EMAIL.abap`.
