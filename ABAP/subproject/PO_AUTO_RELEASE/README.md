# PO_AUTO_RELEASE — PO Auto Release

| Atribut | Isi |
|---|---|
| Program utama | `ZPO_AUTO_RELEASE, ZMMI_PO_RELEASE_PHASE2, BAdI ZCL_IM_ME_PROCESS_PO_CUST_POST` |
| TCODE | — |
| Modul | MM |
| Server write | `sandbox-new` (TRS) |
| Dokumen status | belum ada — buat dari [Template_Checkpoint](../../01_TEMPLATE/Template_Checkpoint.md) |
| README dibuat | 2026-11-05 |

## 1. Tujuan

Auto-release PO di bawah ambang (< USD 500), pilot org TPOL/9999, exception flagging, diagram proses As-Is/To-Be.

## 2. Isi Folder

| Folder | Jumlah file | Isi |
|---|---|---|
| `src/` | 7 | Source ABAP aktif |
| `docs/` | 18 | FS/TS, analisa, diagram |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/](docs/) | Dokumen sprint (docx/xlsx/png/html) — belum ada ringkasan .md |

## 4. Catatan / Aturan Khusus

- Versi source di `src/` bertingkat (`_v2`, `_v4`, `_v6_sprint1`). Tandai versi aktif di checkpoint.
