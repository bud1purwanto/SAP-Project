# ABAP_INTERVIEW_STUDY_CASE — Study case teknik ABAP ECC 6 untuk interview

| Atribut | Isi |
|---|---|
| Program utama | Tidak ada (materi belajar). Kasus: `ZMMR_PO_IMPORT_LOCAL` (ZMM052), `ZSD_UPLOAD_SO` (ZSD113), `ZBADI_ADD_TAB_SO`, `MV45AFZZ`, `ZMMF_PO_LOCAL` |
| TCODE | ZMM052, ZSD113, VA01/VA02/VA03, ME23N, SMARTFORMS, SE18/SE19 |
| Modul | ABAP (MM, SD) |
| Server analisa | dev-aix (TRD 130), read-only |
| Server write (latihan) | `sandbox-new` (TRS) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| Terakhir diperbarui | 2026-11-25 |

## 1. Tujuan

Materi study case hands-on per teknik ABAP (ALV, BAPI, BAdI, User Exit, SmartForms, IDoc, OData) berbasis program nyata di DEV, untuk persiapan interview (permintaan Pak Adi Yuda). OO ABAP ditunda.

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `src/` | (kosong) source latihan bila dibuat |
| `scripts/` | `dev_q.mjs`, `dev_batch.mjs` — helper read-only RFC ke DEV (call_function diblok) |
| `docs/` | Dokumen study case per teknik |
| `tests/` | (kosong) |
| `outputs/dev_src/` | Snapshot source DEV 25 Nov 2026 (read-only) |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/00_INDEX.md](docs/00_INDEX.md) | Daftar modul, benang merah, aturan latihan |
| [docs/01_ALV.md](docs/01_ALV.md) | 4 jenis ALV, analisa ZMM052 |
| [docs/02_BAPI_vs_BDC.md](docs/02_BAPI_vs_BDC.md) | BAPI create SO vs BDC, analisa ZSD113 |
| [docs/03_BADI.md](docs/03_BADI.md) | BAdI tab item SO, analisa ZBADI_ADD_TAB_SO |
| [docs/04_USER_EXIT.md](docs/04_USER_EXIT.md) | Validasi VA01/VA02 di MV45AFZZ/MV45AFZB |
| [docs/05_SMARTFORMS.md](docs/05_SMARTFORMS.md) | SmartForm PO Local + driver + output type |
| [docs/06_HASIL_UJI.md](docs/06_HASIL_UJI.md) | Hasil uji sandbox-new & S/4 (RFC + GUI) |
| [docs/07_IDOC.md](docs/07_IDOC.md) | IDoc dari nol: konsep, IDoc custom PO outbound/inbound, WE19/BD87 |
| [docs/08_ODATA.md](docs/08_ODATA.md) | OData di S/4: SEGW + DPC_EXT, pembanding CDS/RAP |
| [docs/export/](docs/export/) | Gabungan 00–08 dalam Word & PDF (`scripts/build_docx.js`, jalankan ulang setelah docs berubah) |

## 4. Aturan Khusus Sub-Project

- Latihan create/change objek hanya di sandbox-new, package `$TMP`, prefix `ZTRAIN_`/`ZTRN_`.
- Objek asli di DEV hanya dibaca.

## 5. Objek SAP Terkait

| Objek | Jenis | Keterangan |
|---|---|---|
| `ZMMR_PO_IMPORT_LOCAL` / `ZABAPALV` | Program / include | ALV REUSE grid (ZMM052) |
| `ZSD_UPLOAD_SO` | Program | Upload SO (ZSD113), `SD_SALESDOCUMENT_CREATE` + `BAPI_SALESORDER_CHANGE` |
| `ZBADI_ADD_TAB_SO` (ENHO) / `ZBADI_ADDNEW_TAB_SO` (class) / `ZBADI_ADD_TAB_SO` (program, dynpro 4003) | BAdI | `BADI_SLS_ITEM_SCR_CUS` |
| `ZNEWTAB`, `ZBAPE_VBAP(X)`, `ZVBAPKOZ(X)` | Append structure | Field VBAP-ZDATE, ZLINE |
| `MV45AFZZ`, `MV45AFZB` | Include user exit | Kosong di DEV |
| `ZMMF_PO_LOCAL` | SmartForm + driver | Output type Z01 (EF) |
