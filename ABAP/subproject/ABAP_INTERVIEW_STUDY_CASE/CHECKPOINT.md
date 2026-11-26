# CHECKPOINT — ABAP_INTERVIEW_STUDY_CASE (materi belajar)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-25 |
| Status | Dokumen v1 + uji sandbox-new (syntax 8/8, runtime ALV/BAPI) + push S/4 (syntax belum bisa dicek) |
| Server source terakhir | dev-aix TRD 130 (read-only) |
| Jumlah baris source | — |
| Backup terakhir | `outputs/dev_src/` (snapshot 25 Nov 2026) |

## Log Sesi (terbaru di atas, wajib — lihat [08](../../00_RULES/08_Checkpoint_Wajib.md))
| Waktu | AI / device | Pekerjaan | Status | Next step |
|---|---|---|---|---|
| 2026-11-26 | Claude / Linux | IDoc selesai: WE20 inbound, uji 199016=53, 199019=51 -> edit 69 -> 53; bug FM (tulis DB sebelum validasi) diperbaiki (backup outputs/LZTRN_IDOCU01_before_fix_20261126.abap); GUI logout. Export docs 00-08 -> docs/export/Study_Case_ABAP_Interview.docx + .pdf (42 hlm, scripts/build_docx.js) | Selesai | Review Baginda; hapus data uji ZTRN_PO_LOG/ZTRAIN_PROBE hanya atas perintah |
| 2026-11-25 | Claude / Linux GUI :99 | BANGUN IDoc sandbox (TERPUTUS, usage limit): DONE segmen ZTRN_E1POHDR/ITM + basic type ZTRN_PO01 (released, $TMP), WE81 ZTRN_PO, WE82, BD54 ZTRNLS, WE21 port ZTRNFILE (/tmp/), WE20 partner ZTRNLS outbound, program ZTRN_IDOC_PO_OUT -> IDoc 199012 status 03 + file /tmp/ZTRN_PO_00199012, tabel ZTRN_PO_LOG, FG ZTRN_IDOC + FM Z_IDOC_INPUT_ZTRN_PO (generate OK), WE57, BD51, WE42 process code ZTRN_PO (+TBD52 FM). Request: TRDK921884 (workbench) & TRDK921886 (cust), JANGAN TRANSPORT | Sebagian | WE20 inbound (EDI_AGREE_IN_MESSTYPE_INSERT, EVCODE ZTRN_PO), uji WE19 53/51/BD87, update 07_IDOC + 06_HASIL_UJI, logout GUI |
| 2026-11-25 | Claude / Linux | Docs 07_IDOC (IDoc custom ZTRN_PO01, kode out/in lolos syntax mock sandbox, interface dicocokkan FUPARAREF) dan 08_ODATA (SEGW ZTRN_PO_SRV di S/4 + CDS; method Gateway dicek SEOCOMPO S/4). Cek: ECC tanpa Gateway, tanpa partner profile/IDoc | Selesai (dokumen) | Bangun IDoc di sandbox (perlu izin config client) / OData di S/4 |
| 2026-11-25 | Claude / Linux GUI :99 | Uji GUI: sandbox ALV B/C/D lulus (fix BSTYP='F' & currency column), ALV A bikin GUI Java macet (JxBrowser TOP_OF_PAGE); S/4 syntax via SA38: 5 OK, 3 error ZDATE/ZLINE (sesuai perkiraan), ALV B/D jalan, ME23N S/4 dump DDIC. Screenshot outputs/gui_test_20261125 | Selesai | Review Baginda |
| 2026-11-25 | Claude / Linux | Uji program latihan: 6 ZTRAIN_* di sandbox-new ($TMP) + screen/status ALV C, syntax 8/8 OK (fix SALV SET HANDLER), ALV A/B/D background OK, BAPI testrun +/-, SO 5683 dibuat (ZDATE/ZLINE dibersihkan enhancement ZSDE_MV45AFZZ_03); 8 ZTRAIN_* + ZTRAIN_PROBE di S/4 $TMP, syntax tidak bisa via gateway; koreksi doc 04 (8 implicit enhancement DEV) | Selesai sebagian | Uji GUI sandbox & S/4 (butuh password), opsional SO material SR |
| 2026-11-25 | Claude / Linux | Analisa DEV (ZMM052, ZSD113, BAdI ZBADI_ADD_TAB_SO, MV45AFZZ/ZB, ZMMF_PO_LOCAL) + tulis docs 00–05 | Selesai | Review Baginda; IDoc & OO ABAP menyusul |

## 1. Yang Sudah Selesai
- Subproject dibuat, helper RFC read-only, snapshot source DEV.
- Dokumen: ALV, BAPI vs BDC, BAdI, User Exit, SmartForms.

## 2. Perubahan Terakhir
| Tanggal | Perubahan | Objek / FORM | Bukti (push / test) |
|---|---|---|---|
| 2026-11-25 | Tidak ada perubahan di SAP (read-only) | — | — |
| 2026-11-25 | Program latihan baru $TMP: ZTRAIN_ALV_A/B/C/D, ZTRAIN_BAPI_SO, ZTRAIN_PO_PRINT (+ dynpro 0100, status S100 ALV C) | sandbox-new | push + pull ulang sama, syntax OK |
| 2026-11-25 | SO 5683 (PO ZTRAIN-EXT) dibuat lalu di-change via BAPI | sandbox-new | izin Baginda (1 SO) |
| 2026-11-25 | 8 ZTRAIN_* + ZTRAIN_PROBE (sengaja error) di $TMP | S/4 ADB | push OK, syntax belum dicek |

## 3. Keputusan Baginda
| Tanggal | Keputusan |
|---|---|
| 2026-11-25 | Uji di sandbox dan S/4; boleh buat ZTRAIN_* di S/4 $TMP; boleh buat 1 SO di sandbox |
| 2026-11-25 | ALV pakai report PO; BAPI pakai ZSD113; BAdI pakai tab Additional Screen VA01; user exit = validasi VA01/VA02; SmartForms = ZMMF_PO_LOCAL; IDoc & OO ABAP ditunda |

## 4. Masih Terbuka / Next Step
- [ ] Review isi dokumen oleh Baginda.
- [x] Uji GUI sandbox-new dan S/4 (25 Nov). Sisa: ALV A interaktif (GUI Windows), ALV C di S/4 (screen/status).
- [ ] Opsional: 1 SO material SR (grup 3*) untuk bukti ZDATE/ZLINE tersimpan.
- [ ] Hands-on IDoc (config WE20/WE21/BD54/WE42 di sandbox, perlu izin) dan OData (SEGW di S/4, perlu GUI Windows/ADT bila GUI Java macet).
- [ ] Modul OO ABAP.

## 5. Risiko / Catatan
- Implicit enhancement `SAPMV45A` dicek lewat program sementara (ENHINCINX + CL_ENH_TOOL_HOOK_IMPL): 8 enhancement di DEV & sandbox, 5 berbeda isi.
- Gateway S/4 menolak FM syntax check/job; Z_RFC_PROGRAM_UPDATE S/4 tidak cek sintaks. `ZTRAIN_PROBE` (error) masih ada di S/4 $TMP.
- Output type Z01 tidak dipakai di DEV sejak 2024; cetak PO aktif memakai Z03 (`ZMMF_PO_LOCAL_PDF`).
