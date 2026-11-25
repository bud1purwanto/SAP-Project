# 03 — BAdI (Business Add-In)

> Basis kasus: tab **"Additional Screen"** di item Sales Order (VA01/VA02/VA03), contoh dokumen 60000156 item 10 (ZREC).
> Objek di DEV (TRD 130), dibuat user **TRSTDEV** 24 Agu 2023 (method `ACTIVATE_TAB_PAGE` terakhir diubah 29 Sep 2023):
>
> | Objek | Nama | Keterangan |
> |---|---|---|
> | Enhancement spot / BAdI definition | `BADI_SLS_ITEM_SCR_CUS` (spot `BADI_SLS_ITEM`) | BAdI standar SAP untuk tab custom di item sales document |
> | Enhancement implementation | `ZBADI_ADD_TAB_SO` | Implementasi (SE19) |
> | Implementing class | `ZBADI_ADDNEW_TAB_SO` | Interface `IF_EX_SLS_ITEM_SCR_CUS` |
> | Program subscreen | `ZBADI_ADD_TAB_SO`, dynpro **4003** | Layar "Production Data" + "Product Group Material" |
> | Append VBAP | `ZNEWTAB` (field `ZDATE` DATS 8, `ZLINE` CHAR, data element `ZLINE`) | Field disimpan di VBAP |
> | Append BAPI | `ZBAPE_VBAP`/`ZBAPE_VBAPX`, `ZVBAPKOZ`/`ZVBAPKOZX` | Agar field juga bisa diisi via BAPI (dipakai ZSD113) |
> | Tabel mapping | `ZMAPPG` (MATNR+BUKRS → GRPPRD3, SBU), `ZMAP_LINEBR` (ZLINE → ZPROD1) | Sumber "Group Prod 3", "SBU", "Production Line Group" |
>
> Source referensi: [../outputs/dev_src/](../outputs/dev_src/) file `ZBADI_ADDNEW_TAB_SO_CM001..CM004.abap` dan `ZBADI_ADD_TAB_SO.abap`.

## 1. Konsep singkat (untuk interview)

**Enhancement** = menambah logika ke program standar SAP **tanpa memodifikasi** program standar. Urutan teknologi (lama → baru):

| Teknologi | Contoh | Cara implement | Catatan |
|---|---|---|---|
| User exit (form) | `MV45AFZZ` `USEREXIT_SAVE_DOCUMENT_PREPARE` | Edit include SAP (butuh access key) | Lihat [04_USER_EXIT.md](04_USER_EXIT.md) |
| Customer exit | `CALL CUSTOMER-FUNCTION '001'`, enhancement `V45A0002` | SMOD (lihat) / CMOD (project) | Include `ZX...` |
| **Classic BAdI** | `ME_PROCESS_PO_CUST`, `MB_MIGO_BADI` | SE18 / SE19, dipanggil `CL_EXITHANDLER=>GET_INSTANCE` | OO, bisa multiple-use + filter |
| **New (kernel) BAdI** | `BADI_SLS_ITEM_SCR_CUS` | Enhancement spot, SE19, dipanggil `GET BADI` / `CALL BADI` | Lebih cepat, bagian Enhancement Framework |
| Implicit/explicit enhancement | `ENHANCEMENT-POINT`, awal/akhir FORM/FM | SE80 → Enhance | Paling fleksibel, juga tanpa access key |

Istilah kunci:
- **BAdI definition** (SAP) = interface + method yang disediakan SAP.
- **BAdI implementation** (kita) = class yang mengimplementasikan interface tersebut.
- **Multiple use** = boleh lebih dari satu implementasi aktif. **Filter** = implementasi hanya jalan untuk nilai tertentu (mis. country, document type).
- **Screen enhancement BAdI** = BAdI yang juga menyediakan *subscreen area* (seperti kasus ini).

Contoh BAdI yang sudah diimplementasikan di DEV (berguna untuk cerita interview): `ME_PROCESS_PO_CUST` (`ZME_PROCESS_PO_CUST`, `ZMMTICKPORETUR`), `MB_MIGO_BADI` (`ZMB_MIGO_BADI`, `ZMIGO_BADI_PIB`), `WORKORDER_UPDATE`, `INVOICE_UPDATE`.

## 2. Analisa implementasi di DEV

### 2.1 Cara kerja (alur)

```
VA01/VA02/VA03 buka item
  SAP panggil BAdI BADI_SLS_ITEM_SCR_CUS
   ├─ ACTIVATE_TAB_PAGE            -> daftarkan tab: caption 'Additional Screen',
   │                                  program ZBADI_ADD_TAB_SO, dynpro 4003
   │                                  + siapkan nilai awal (DB VBAP / memory) ke SAP memory (parameter ID)
   ├─ TRANSFER_DATA_TO_SUBSCREEN   -> IS_VBAP-ZDATE/ZLINE -> SET PARAMETER ID 'ZDATE'/'ZLINE'
   │      Subscreen 4003 PBO       -> GET PARAMETER ID ... ke field layar;
   │                                  VA03: field input dimatikan (LOOP AT SCREEN)
   │                                  ZLINE terisi -> cari Production Line Group di ZMAP_LINEBR
   │      Subscreen 4003 PAI       -> SET PARAMETER ID dari input user;
   │                                  simpan juga ke tabel memory 'ZBADI_ADD_TAB_SO' (per VBELN+POSNR)
   │      F4 pada ZLINE            -> nilai karakteristik ZZPRODLINE (CABN/CAWN/CAWNT)
   └─ TRANSFER_DATA_FROM_SUBSCREEN -> GET PARAMETER ID -> CS_VBAP-ZDATE/ZLINE
Save -> standar SAP menyimpan VBAP termasuk field append ZDATE/ZLINE
```

### 2.2 Isi tiap method

| Method | Isi di `ZBADI_ADDNEW_TAB_SO` |
|---|---|
| `ACTIVATE_TAB_PAGE` | Hanya untuk `SY-TCODE` VA01/VA02/VA03: append ke `CT_CUS_ITEM_TAB` (`ITEM_CAPTION`, `ITEM_PROGRAM`, `ITEM_DYNPRO`). Lalu: VA01 kosongkan parameter ID; baca `VBAP-ZDATE/ZLINE` dari DB, kalau kosong ambil dari memory `ZBADI_ADD_TAB_SO`; cari BUKRS dari plant (T001K) lalu `ZMAPPG` → set `ZGRUP`, `ZSBU`. |
| `TRANSFER_DATA_TO_SUBSCREEN` | `IS_VBAP-ZDATE/ZLINE` → `SET PARAMETER ID`. |
| `TRANSFER_DATA_FROM_SUBSCREEN` | `GET PARAMETER ID` → `CS_VBAP-ZDATE/ZLINE`. |
| `PASS_FCODE_TO_SUBSCREEN` | Kosong. |

### 2.3 Poin kritik (bahan diskusi "apa yang bisa diperbaiki")

1. **Komunikasi class ↔ subscreen lewat SAP memory (`SET/GET PARAMETER ID`).** Parameter ID berlaku untuk seluruh sesi user, sehingga bisa "bocor" antar item atau antar mode (dua sesi VA02 terbuka bersamaan). Pola yang direkomendasikan: **function group** yang memegang subscreen + data global, dengan FM setter/getter (mis. `Z_SO_TAB_SET_DATA`, `Z_SO_TAB_GET_DATA`) yang dipanggil dari method BAdI. Data tetap di dalam program yang sama dengan subscreen.
2. **Logika baca data di `ACTIVATE_TAB_PAGE`.** Method ini tujuannya hanya mendaftarkan tab. Membaca DB (`SELECT SINGLE ... FROM VBAP`) di sini berjalan setiap kali item dibuka. Seharusnya cukup memakai `IS_VBAP` di `TRANSFER_DATA_TO_SUBSCREEN` (VBAP di buffer dokumen sudah berisi nilai terbaru, termasuk yang belum disimpan).
3. **Memory `EXPORT/IMPORT ... ID 'ZBADI_ADD_TAB_SO'`** dipakai sebagai cadangan untuk item baru (VBELN masih kosong di VA01). Rawan tertinggal dari dokumen sebelumnya di sesi yang sama → perlu `FREE MEMORY ID` saat dokumen baru dimulai.
4. **Cek `SY-TCODE`** membuat tab tidak muncul jika SO dibuka dari transaksi lain (mis. `ZVA01`, VA02 dipanggil dari report via `CALL TRANSACTION` tetap VA02 — aman; tapi custom tcode varian tidak). Alternatif: cek `T180-TRTYP` (H=create, V=change, A=display) yang tersedia lewat parameter/komunikasi standar.
5. **Mode display ditentukan dari `SY-TCODE = 'VA03'`.** Di VA02 dengan dokumen terkunci/ditampilkan, field masih input. Lebih tepat pakai indikator aktivitas (`TRTYP`).

Kesimpulan: implementasi **berfungsi** (data tersimpan di VBAP, terbukti VBAP mengandung ZDATE/ZLINE untuk SO lama, mis. SO 2866, 6605, 2500), tetapi desain komunikasi datanya bisa dibuat lebih aman.

## 3. Study case hands-on

**Tujuan:** membangun ulang tab item custom sendiri dengan desain yang lebih rapi, supaya paham setiap langkah.
**Tempat:** `sandbox-new` (TRS 130), package `$TMP`. **Jangan** ubah `ZBADI_ADD_TAB_SO` di DEV.

Skenario: tambah field **"Catatan Produksi"** (`ZZTRN_REMARK`, CHAR 40) di item SO, tampil di tab "Latihan BAdI".

### Langkah 1 — Cari BAdI yang cocok (keterampilan yang sering ditanya)
- SE18 → BAdI name `BADI_SLS_ITEM_SCR_CUS` → lihat interface dan method.
- Cara mencari BAdI lain secara umum:
  - Classic BAdI: breakpoint di `CL_EXITHANDLER=>GET_INSTANCE`, jalankan transaksi, catat `EXIT_NAME`.
  - New BAdI: cari statement `GET BADI` / `CALL BADI` di program standar (SE80 → Find), atau SE84 → Enhancements → Business Add-ins, atau ST05 trace tabel `BADI*`/`SXS_*`.
  - Dokumentasi SPRO: Sales and Distribution → System Modifications → Business Add-Ins.

### Langkah 2 — Tambah field di VBAP
- SE11 `VBAP` → Append structure `ZATRN_VBAP` → field `ZZTRN_REMARK` CHAR40 (pakai data element baru `ZTRN_REMARK`).
- Untuk BAPI (opsional, menyambung ke [02_BAPI_vs_BDC.md](02_BAPI_vs_BDC.md)): append yang sama ke `BAPE_VBAP`, `BAPE_VBAPX` (CHAR1), `VBAPKOZ`, `VBAPKOZX`.

### Langkah 3 — Function group + subscreen
SE80 → Function group `ZTRN_SO_TAB`.

TOP include:
```abap
FUNCTION-POOL ztrn_so_tab.
DATA: gv_remark TYPE vbap-zztrn_remark,
      gv_display TYPE c.
```

FM setter/getter:
```abap
FUNCTION z_trn_so_tab_set.
*"  IMPORTING
*"     VALUE(IV_REMARK) TYPE VBAP-ZZTRN_REMARK
*"     VALUE(IV_DISPLAY) TYPE C OPTIONAL
  gv_remark  = iv_remark.
  gv_display = iv_display.
ENDFUNCTION.

FUNCTION z_trn_so_tab_get.
*"  EXPORTING
*"     VALUE(EV_REMARK) TYPE VBAP-ZZTRN_REMARK
  ev_remark = gv_remark.
ENDFUNCTION.
```

Screen `9001` (tipe **Subscreen**), field `GV_REMARK` (ambil dari program → Dictionary/Program fields).
Flow logic:
```abap
PROCESS BEFORE OUTPUT.
  MODULE pbo_9001.
PROCESS AFTER INPUT.
  MODULE pai_9001.
```
```abap
MODULE pbo_9001 OUTPUT.
  IF gv_display = 'X'.
    LOOP AT SCREEN.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.

MODULE pai_9001 INPUT.
  "nilai GV_REMARK otomatis terisi dari layar; tidak perlu memory
ENDMODULE.
```

### Langkah 4 — Implementasi BAdI (SE19)
SE19 → Create implementation (new BAdI) → enhancement spot `BADI_SLS_ITEM` → implementation `ZTRN_SO_ITEM_TAB` → BAdI `BADI_SLS_ITEM_SCR_CUS` → class `ZCL_TRN_SO_ITEM_TAB`.

```abap
METHOD if_ex_sls_item_scr_cus~activate_tab_page.
  DATA: ls_tab TYPE LINE OF sales_cust_tab_page_t.
  ls_tab-item_caption = 'Latihan BAdI'.
  ls_tab-item_program = 'SAPLZTRN_SO_TAB'.
  ls_tab-item_dynpro  = '9001'.
  APPEND ls_tab TO ct_cus_item_tab.
ENDMETHOD.

METHOD if_ex_sls_item_scr_cus~transfer_data_to_subscreen.
  DATA: lv_display TYPE c.
  IF sy-tcode = 'VA03'.          "latihan: cukup SY-TCODE; diskusikan alternatif TRTYP
    lv_display = 'X'.
  ENDIF.
  CALL FUNCTION 'Z_TRN_SO_TAB_SET'
    EXPORTING
      iv_remark  = is_vbap-zztrn_remark
      iv_display = lv_display.
ENDMETHOD.

METHOD if_ex_sls_item_scr_cus~transfer_data_from_subscreen.
  CALL FUNCTION 'Z_TRN_SO_TAB_GET'
    IMPORTING
      ev_remark = cs_vbap-zztrn_remark.
ENDMETHOD.
```

(Lihat signature persis tiap method di SE18/SE24 sebelum menulis; nama parameter di atas mengikuti implementasi DEV: `CT_CUS_ITEM_TAB`, `IS_VBAP`, `CS_VBAP`.)

Aktifkan class + implementation.

### Langkah 5 — Uji
- [ ] VA01 → item → tab **Latihan BAdI** muncul.
- [ ] Isi catatan di item 10 dan item 20 dengan nilai berbeda, pindah-pindah item → nilai tidak tertukar.
- [ ] Save → SE16N `VBAP` field `ZZTRN_REMARK` terisi per item.
- [ ] VA02 → ubah → Save → nilai berubah.
- [ ] VA03 → field tidak bisa diinput.
- [ ] Nonaktifkan implementation di SE19 → tab hilang (bukti BAdI bisa dimatikan tanpa hapus kode).
- [ ] Bandingkan: buka SO lama di DEV (VA03, mis. 60000156) untuk melihat tab "Additional Screen" asli.

## 4. Hasil uji & catatan lingkungan (25 Nov 2026)

- Implementasi BAdI `ZBADI_ADD_TAB_SO` **hanya ada di DEV**. Di sandbox-new tidak ada (tab "Additional Screen" tidak muncul di VA01 sandbox), walaupun field VBAP-ZDATE/ZLINE dan append BAPI-nya ada.
- Kode method latihan (Langkah 4) sudah lolos syntax check di sandbox-new memakai class lokal yang mengimplementasikan `IF_EX_SLS_ITEM_SCR_CUS` ([../src/ZTRAIN_BADI_MOCK.abap](../src/ZTRAIN_BADI_MOCK.abap)); field `ZZTRN_REMARK` diganti `ZLINE` karena append latihan belum dibuat. Ini membuktikan nama interface, method, dan parameter (`CT_CUS_ITEM_TAB`, `IS_VBAP`, `CS_VBAP`, tipe `SALES_CUST_TAB_PAGE_T`) benar.
- Langkah 2–5 (append VBAP, function group + subscreen, implementasi SE19) belum dijalankan: perlu perubahan DDIC di tabel standar VBAP dan dikerjakan di GUI.
- BAdI ini bekerja bersama user exit: `ZSDE_MV45AFZB` (`USEREXIT_CHECK_VBAP`) mengisi default ZDATE/ZLINE, `ZSDE_MV45AFZZ_03` (`USEREXIT_SAVE_DOCUMENT_PREPARE`) memvalidasi/membersihkan, `ZSDE_MV45AFZZ_04` (`USEREXIT_SAVE_DOCUMENT`) membersihkan parameter ID `ZDATE`/`ZLINE`. Lihat [04_USER_EXIT.md](04_USER_EXIT.md).

## 5. Pertanyaan interview yang mungkin muncul

1. Beda user exit, customer exit, BAdI? → lihat tabel bagian 1; poin utama: user exit = modifikasi include SAP (access key), customer exit = CMOD project, BAdI = OO, multiple-use + filter, tidak perlu access key.
2. Beda classic BAdI dan new BAdI? → classic: SE18/SE19, `CL_EXITHANDLER`; new: enhancement spot, `GET BADI`/`CALL BADI`, performa lebih baik, bisa *fallback class*.
3. Bagaimana menambah tab/field custom di VA01? → (a) BAdI `BADI_SLS_ITEM_SCR_CUS` untuk item (contoh DEV; untuk header cek BAdI sejenis di spot yang sama lewat SE18), atau (b) cara lama screen 8459 (item) / 8309 (header) "Additional data B" di `SAPMV45A` + user exit `MV45AFZZ`.
4. Kenapa harus append juga ke `BAPE_VBAP`/`VBAPKOZ`? → supaya field bisa diisi oleh BAPI SD (EXTENSIONIN).
5. Bagaimana data berpindah antara class BAdI dan subscreen? → lewat function group (FM setter/getter) atau atribut statis class; hindari SAP memory parameter ID.
6. Bagaimana mematikan BAdI? → SE19 → deactivate implementation (perubahan ini juga ikut transport ke QAS/PRD).
