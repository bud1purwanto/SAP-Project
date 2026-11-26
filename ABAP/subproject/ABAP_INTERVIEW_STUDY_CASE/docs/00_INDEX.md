# Study Case Teknik ABAP ECC 6 — Persiapan Interview

> Permintaan: Pak Adi Yuda (WhatsApp 25 Nov 2026) — study case sederhana per teknik agar paham lewat hands-on, bukan sekadar teori.
> Sistem acuan: SAP ECC 6.0 EHP6, ABAP 7.31. Semua contoh program nyata diambil read-only dari **DEV AIX (TRD 130)** tanggal 25 Nov 2026.
> Semua kode latihan memakai sintaks ABAP 7.31 (tanpa `DATA(...)` inline, `NEW`, `VALUE`, string template `|...|`).

## Daftar modul

| No | Teknik | Kasus nyata di sistem | Dokumen | Status |
|---|---|---|---|---|
| 1 | **ALV** | ZMM052 Report PO Import (`ZMMR_PO_IMPORT_LOCAL`) | [01_ALV.md](01_ALV.md) | Siap |
| 2 | **BAPI** (vs BDC) | ZSD113 Upload create SO (`ZSD_UPLOAD_SO`) | [02_BAPI_vs_BDC.md](02_BAPI_vs_BDC.md) | Siap |
| 3 | **BAdI** | Tab "Additional Screen" item SO (`BADI_SLS_ITEM_SCR_CUS` → `ZBADI_ADD_TAB_SO`) | [03_BADI.md](03_BADI.md) | Siap |
| 4 | **User Exit** | 8 implicit enhancement di `MV45AFZZ`/`MV45AFZB` (termasuk "Validasi Tab Prod Line") + validasi latihan | [04_USER_EXIT.md](04_USER_EXIT.md) | Siap (dikoreksi setelah uji) |
| 5 | **SmartForms** | Print PO Local (`ZMMF_PO_LOCAL`, output type Z01) | [05_SMARTFORMS.md](05_SMARTFORMS.md) | Siap |
| — | **Hasil uji** sandbox-new & S/4 | Semua program latihan | [06_HASIL_UJI.md](06_HASIL_UJI.md) | 25 Nov 2026 |
| 6 | **IDoc** | Belum ada IDoc di DEV/sandbox → dibangun dari nol: IDoc custom `ZTRN_PO01` (outbound PO + inbound log), sandbox-new | [07_IDOC.md](07_IDOC.md) | **Dibangun & diuji** di sandbox (outbound 03, inbound 53/51/69→53) |
| 7 | **OData** | ECC tidak punya Gateway → di S/4: SEGW `ZTRN_PO_SRV` + pembanding CDS `@OData.publish` | [08_ODATA.md](08_ODATA.md) | Siap (method Gateway dicek ada; belum dibangun) |
| 8 | OO ABAP | — | — | Ditunda (permintaan Baginda) |

## Benang merah antar modul

Kelima kasus saling terhubung sehingga mudah diceritakan saat interview:

```
ZSD113 (BAPI)  ──EXTENSIONIN BAPE_VBAP──►  VBAP-ZDATE / VBAP-ZLINE  ◄──tab "Additional Screen"── BAdI BADI_SLS_ITEM_SCR_CUS
                                                  │
                    User exit (implicit enhancement): CHECK_VBAP isi default, SAVE_DOCUMENT_PREPARE validasi/clear ZDATE-ZLINE
                    (terbukti ikut jalan saat BAPI: SO latihan 5683 di sandbox)

ZMM052 (ALV report PO)  ──hotspot──►  ME23N  ──output Z01/Z03──►  SmartForm ZMMF_PO_LOCAL (driver ZMMF_PO_LOCAL)
```

## Format tiap dokumen

1. **Konsep singkat** — definisi dan istilah yang biasa ditanya.
2. **Analisa program nyata** — alur, objek, dan poin kritik (apa yang bisa diperbaiki).
3. **Study case hands-on** — langkah, kode 7.31, checklist uji.
4. **Pertanyaan interview** + jawaban ringkas.

## Aturan latihan (penting)

- Latihan **membuat/mengubah** objek hanya di **sandbox-new (TRS 130)**, package `$TMP`, prefix `ZTRAIN_` / `ZTRN_`.
- DEV, QAS, PRD hanya untuk **melihat** (display) objek asli. Jangan ubah `ZBADI_ADD_TAB_SO`, `ZMMF_PO_LOCAL`, `ZSD_UPLOAD_SO`, `MV45AFZZ` di DEV.
- Jangan posting dokumen bisnis di DEV/QAS tanpa izin. Sales Order / PO latihan dibuat di sandbox-new.
- Data master (customer, material, sales area) di sandbox-new bisa berbeda dari DEV — cek dulu sebelum latihan.

## Urutan belajar yang disarankan

1. ALV (paling dasar, langsung terlihat hasilnya).
2. BAPI (membuat SO), lalu bandingkan dengan BDC.
3. BAdI (tab custom di item SO, field yang sama dengan BAPI).
4. User exit (validasi field dari BAdI sebelum save).
5. SmartForms (cetak PO, sambung ke output type).

## Snapshot source DEV

Folder [../outputs/dev_src/](../outputs/dev_src/) berisi salinan read-only (25 Nov 2026): `ZMMR_PO_IMPORT_LOCAL`, `ZABAPALV`, `ZSD_UPLOAD_SO`, class `ZBADI_ADDNEW_TAB_SO` (CU, CM001–CM004), `ZBADI_ADD_TAB_SO`, `MV45AFZZ`, `MV45AFZB`, `ZMMF_PO_LOCAL` (+ TOP, F01), `ZMMF_PO_LOCAL_PDF`, `ZMMR_PO_CONDITION`, `ZMMR_DISCOUNT_PO`.
