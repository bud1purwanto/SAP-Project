# 05 — SmartForms (Print PO Local)

> Basis kasus: SmartForm **`ZMMF_PO_LOCAL`** (form dibuat 2005, package ZTRD) + driver program **`ZMMF_PO_LOCAL`** (Rimbun Gracia Siahaan, 6 Nov 2012) di DEV (TRD 130).
> Source referensi: [../outputs/dev_src/ZMMF_PO_LOCAL.abap](../outputs/dev_src/ZMMF_PO_LOCAL.abap), `ZMMF_PO_LOCAL_TOP.abap`, `ZMMF_PO_LOCAL_F01.abap`.
>
> Konfigurasi output (tabel `TNAPR`, aplikasi `EF` = Purchase Order):
>
> | Output type | Driver program | FORM entry | Form | Catatan |
> |---|---|---|---|---|
> | **Z01** | `ZMMF_PO_LOCAL` | `ENTRY_NEU` | `ZMMF_PO_LOCAL` (diisi di kolom form SAPscript, kolom SmartForm kosong) | Kasus study ini. Di DEV tidak ada NAST Z01 sejak 2024 |
> | Z03 | `ZMMF_PO_LOCAL_PDF` | `ENTRY_NEU` | SmartForm `ZMMF_PO_LOCAL_PDF` | Versi yang **aktif dipakai** (NAST Z03 ada sampai Juli 2026) |
> | Z04 | `ZMMF_PO_IMPORT_PDF` | `ENTRY_NEU` | SmartForm `ZMMF_PO_IMPORT_PDF` | PO import |
> | NEU | `SAPFM06P` | `ENTRY_NEU` | SAPscript `MEDRUCK` | Standar SAP |
>
> Konsep dan alurnya sama untuk Z01 dan Z03, jadi Z01 cocok untuk belajar; untuk cetakan PO terbaru lihat Z03.

## 1. Konsep singkat (untuk interview)

**SmartForms** = alat desain form cetak (pengganti SAPscript). Saat diaktifkan, SmartForms **meng-generate function module** (nama acak, mis. `/1BCDWB/SF00000123`). Program memanggil FM itu untuk mencetak.

Tiga komponen yang selalu ditanya:
1. **Form** (transaksi `SMARTFORMS`): layout + logika tampilan.
   - *Global Settings*: **Form Interface** (parameter import/tables dari driver), **Global Definitions** (variabel, tipe, initialization, form routines).
   - *Pages and Windows*: **Main window** (isi yang mengalir ke halaman berikutnya, mis. tabel item) dan **secondary window** (header, footer, logo, alamat — posisi tetap).
   - Node: Text, Graphic (logo dari SE78), Address, **Table** (header/main area/footer, line type dari Table Painter), **Loop**, Condition, Program Lines, Alternative, Command (page break).
2. **Style** (`SMARTSTYLES`): font, paragraph format, character format.
3. **Driver / print program**: ambil data → siapkan parameter output → `SSF_FUNCTION_MODULE_NAME` → `CALL FUNCTION fm_name`.

Hubungan dengan **output determination** (NACE):
- Output type (mis. Z01) → `TNAPR`: program + FORM routine + form.
- Saat PO disimpan/dicetak, program `RSNAST00` memanggil `PERFORM entry_neu IN PROGRAM zmmf_po_local USING return_code us_screen`.
- Record output tersimpan di tabel **`NAST`** (OBJKY = nomor PO, VSTAT 0 = belum diproses, 1 = sudah).

## 2. Analisa driver `ZMMF_PO_LOCAL`

Struktur: `REPORT ZMMF_PO_LOCAL` + `INCLUDE ZMMF_PO_LOCAL_TOP` (data) + `INCLUDE ZMMF_PO_LOCAL_F01` (logika, ~1.200 baris).

```
ENTRY_NEU (dipanggil oleh output control, NAST sudah terisi)
  CEK_OUTPUT_TYPE  -> kalau PO sudah pernah dicetak (NAST VSTAT=1) dengan output type LAIN,
                      tampilkan info "Sudah pernah dicetak dengan output type ..." dan STOP
  F_PROCESSING
    F_SELECT_DATA        -> EKKO/EKPO untuk NAST-OBJKY -> IT_PO
    F_FIND_DATA_VENDOR   -> nama/alamat/telp/fax vendor (LFA1/ADRC)
    F_FIND_DATA_PLANT    -> plant & alamat (T001W)
    F_FIND_DATA_SLOC     -> storage location (T001L)
    F_FIND_DATA_PO_NO    -> nomor & tanggal PO
    F_ADDITIONAL_DATA
    F_FIND_ITEM_DATA     -> isi I_ZPO_LOCAL per item (harga, diskon, last price, kurs via RKC_SINGLE_EXCHANGE_RATE_GET)
    F_GET_INFORECORD     -> kasus subcont
    F_PO_RETURN          -> kasus PO return
    F_CALL_SMARTFORMS
      F_SMARTFORMS_CONFIGURE -> NAST -> SSFCOMPOP (printer, copies, preview/print, fax)
      V_FORMNAME = 'ZMMF_PO_LOCAL'           <- hardcode, menimpa *TNAPR-SFORM
      SSF_FUNCTION_MODULE_NAME -> V_FUNCNAME
      F_GET_TERM_PAYMENT, F_GET_HEADER_TEXT (READ_TEXT)
      IF BSART = 'PO06' -> F_GET_SCHE_LINES, CALL FUNCTION V_FUNCNAME ... TABLES I_ZPO_LOCAL, IT_EKET
      ELSE              -> CALL FUNCTION V_FUNCNAME ... TABLES I_ZPO_LOCAL
  ENT_RETCO = 0 (sukses) / 1 (gagal) -> output control tandai NAST
```

Form interface yang dipakai (dari `CALL FUNCTION V_FUNCNAME`):

| Jenis | Parameter |
|---|---|
| Standar | `CONTROL_PARAMETERS` (SSFCTRLOP), `OUTPUT_OPTIONS` (SSFCOMPOP) |
| Header vendor | `S_VENDOR`, `S_ADDRESS`, `S_CITY`, `S_TELP`, `S_FAX` |
| Header plant/sloc | `S_WERKS`, `S_NAME_WERKS`, `S_ADDRESS_PLANT`, `S_CITY_PLANT`, `S_LGORT`, `S_LGORT_TEXT` |
| Header PO | `S_EBELN`, `S_DATE_PO`, `S_DATE_PRT`, `S_PAY1` (term of payment), `P_WAERS`, `PO_TYPE`, `V_REV` (revisi) |
| Total | `S_SUBTOTAL`, `S_DISCOUNT`, `S_TAX`, `S_FREIGHT`, `S_TOTAL_ORDER` |
| Flag | `S_FLAG_PREV` (preview) |
| Tables | `I_ZPO_LOCAL` (struktur `ZPO_LOCAL`), `IT_EKET` (schedule line, hanya PO06) |

Struktur item `ZPO_LOCAL` (semua CHAR, angka sudah diformat di driver): `ZNO`, `ZMATNR`, `ZDESCRIPTION`, `ZMENGE`, `ZMEINS`, `ZUNITPRICE`, `ZPEINH`, `ZBPRME`, `ZUNITDISC`, `ZUNITDISC2`, `ZTOTALDISC`, `ZTOTALPRICE`, `ZWAERS`, `ZWAERS2`, `ZEINDT`, `ZPRNO`, `ZFANO`, `ZLASTPRICE`, `ZLASTVENDOR`, `ZTEXT`, `WAERS`.

Poin diskusi interview dari program nyata:
1. **Kenapa nama FM SmartForm tidak di-hardcode?** Nama FM hasil generate berbeda di DEV/QAS/PRD → wajib `SSF_FUNCTION_MODULE_NAME`. Program ini sudah benar.
2. **Form name di-hardcode** (`V_FORMNAME = 'ZMMF_PO_LOCAL'`) setelah membaca `*TNAPR-SFORM` → konfigurasi NACE tidak berpengaruh. Lebih baik ambil dari `TNAPR-SFORM` (atau `TNAPR-FONAM`) supaya satu driver bisa dipakai beberapa form.
3. **Data diformat ke CHAR di driver** (`CURRENCY_AMOUNT_SAP_TO_DISPLAY`, kurs) → form jadi sederhana, tapi total di form tidak bisa dihitung ulang dengan aman. Alternatif: kirim tipe numerik + field referensi currency/unit, format di form.
4. **Pencegahan cetak ganda beda output type** di `CEK_OUTPUT_TYPE` → contoh validasi bisnis di driver.
5. `F_SMARTFORMS_CONFIGURE` meniru logika standar `SAPFM06P` (cek `NAST-NACHA` 1 print / 2 fax / 5 email, `SY-XCODE` preview vs print).

## 3. Study case hands-on

**Tempat:** `sandbox-new` (TRS 130), package `$TMP`. Jangan ubah `ZMMF_PO_LOCAL` di DEV.

### Latihan 1 — Membaca form yang ada (bisa di DEV, read-only)
1. `SMARTFORMS` → Form `ZMMF_PO_LOCAL` → **Display**.
2. Catat: Form Interface (cocokkan dengan tabel bagian 2), Global Definitions, daftar Page/Window, node Table untuk `I_ZPO_LOCAL`.
3. Menu *Environment → Function Module Name* → catat nama FM generate; buka di SE37 (display) dan lihat parameternya sama dengan Form Interface.
4. ME23N PO lokal → *Messages* → lihat output type yang ada (di DEV umumnya Z03). Print preview untuk melihat hasil.

Pertanyaan untuk dijawab sendiri: window mana yang main window? Di node mana subtotal/total dicetak? Bagaimana form tahu jumlah halaman (`&SFSY-PAGE&` / `&SFSY-FORMPAGES&`)?

### Latihan 2 — Buat form + driver mini sendiri
Target: SmartForm `ZTRN_PO_SIMPLE` + program `ZTRN_PO_PRINT` (selection: nomor PO) yang mencetak header PO, tabel item, dan total.

**a. Form (`SMARTFORMS`)**
- Form Interface:
  - Import `IS_EKKO TYPE EKKO`, `IV_VENDOR_NAME TYPE LFA1-NAME1`
  - Tables `IT_EKPO LIKE EKPO`
- Global Definitions: `GS_EKPO TYPE EKPO`, `GV_TOTAL TYPE EKPO-NETWR`.
- Page `FIRST` (next page `NEXT`), page `NEXT`.
- Window `HEADER` (secondary): teks "PURCHASE ORDER", `&IS_EKKO-EBELN&`, `&IS_EKKO-BEDAT&`, `&IV_VENDOR_NAME&`.
- Window `MAIN`: node **Table** loop `IT_EKPO INTO GS_EKPO`
  - Header: Item | Material | Description | Qty | UoM | Net Value
  - Main area: `&GS_EKPO-EBELP&`, `&GS_EKPO-MATNR&`, `&GS_EKPO-TXZ01&`, `&GS_EKPO-MENGE&`, `&GS_EKPO-MEINS&`, `&GS_EKPO-NETWR&`
  - Tab *Calculations*: operasi **Total**, field `GS_EKPO-NETWR`, target `GV_TOTAL`, waktu *after loop*
  - Footer: "Total" `&GV_TOTAL&`
- Window `FOOTER` (secondary, tiap halaman): `Page &SFSY-PAGE& of &SFSY-FORMPAGES&`.
- Aktifkan (Ctrl+F3).

**b. Driver**
```abap
REPORT ztrn_po_print.

PARAMETERS: p_ebeln TYPE ekko-ebeln OBLIGATORY.

DATA: gs_ekko   TYPE ekko,
      gt_ekpo   TYPE STANDARD TABLE OF ekpo,
      gv_name   TYPE lfa1-name1,
      gv_fm     TYPE rs38l_fnam,
      gs_ctrl   TYPE ssfctrlop,
      gs_outopt TYPE ssfcompop.

START-OF-SELECTION.
  SELECT SINGLE * FROM ekko INTO gs_ekko WHERE ebeln = p_ebeln.
  IF sy-subrc <> 0.
    MESSAGE 'PO tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SELECT * FROM ekpo INTO TABLE gt_ekpo
    WHERE ebeln = p_ebeln AND loekz = space.
  SELECT SINGLE name1 FROM lfa1 INTO gv_name WHERE lifnr = gs_ekko-lifnr.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZTRN_PO_SIMPLE'
    IMPORTING
      fm_name            = gv_fm
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE 'SmartForm tidak ditemukan' TYPE 'E'.
  ENDIF.

  gs_ctrl-preview   = 'X'.
  gs_ctrl-no_dialog = ' '.
  gs_outopt-tddest  = 'LP01'.          "sesuaikan printer di sandbox

  CALL FUNCTION gv_fm
    EXPORTING
      control_parameters = gs_ctrl
      output_options     = gs_outopt
      is_ekko            = gs_ekko
      iv_vendor_name     = gv_name
    TABLES
      it_ekpo            = gt_ekpo
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.
```

**c. Uji**
- [ ] PO dengan 3 item → 1 halaman, total benar (cocokkan dengan ME23N).
- [ ] PO dengan banyak item (≥ 40) → pindah ke halaman `NEXT`, header tabel muncul lagi, nomor halaman "1 of 2".
- [ ] PO tidak ada → pesan error, tidak dump.

### Latihan 3 (lanjutan) — Sambungkan ke output type
1. Ubah driver menjadi FORM `ENTRY_NEU USING ent_retco ent_screen` yang membaca nomor PO dari `NAST-OBJKY` (lihat pola `ZMMF_PO_LOCAL_F01`).
2. NACE → aplikasi EF → buat output type latihan (mis. `ZTRN`) → *Processing routines*: program `ZTRN_PO_PRINT`, routine `ENTRY_NEU`, SmartForm `ZTRN_PO_SIMPLE`.
3. Condition record (MN04) untuk output type tersebut → ME22N → Messages → tambah ZTRN → Print preview.
4. Cek tabel `NAST` (SE16N) untuk PO tersebut.

Ini menjelaskan pertanyaan "bagaimana form PO tercetak otomatis saat PO disimpan".

### Latihan 4 (opsional) — PDF / email
Set `gs_ctrl-getotf = 'X'` → ambil `JOB_OUTPUT_INFO-OTFDATA` → `CONVERT_OTF` ke PDF → simpan (`GUI_DOWNLOAD`) atau kirim email (`CL_BCS`). Inilah pola di balik versi `_PDF` (Z03).

## 4. Hasil uji (25 Nov 2026)

- Driver latihan [../src/ZTRAIN_PO_PRINT.abap](../src/ZTRAIN_PO_PRINT.abap) lolos syntax check di sandbox-new dan sudah dibuat di sandbox-new serta S/4 (`$TMP`). Nama form dijadikan parameter `P_FORM` (default `ZTRN_PO_SIMPLE`).
- SmartForm `ZTRN_PO_SIMPLE` **belum dibuat**: pembuatan form dikerjakan di transaksi `SMARTFORMS` (GUI) sebagai bagian latihan. Tanpa form, driver berhenti dengan pesan "SmartForm tidak ditemukan" (tidak dump).
- Form asli `ZMMF_PO_LOCAL` ada di DEV dan sandbox-new (bisa dibuka read-only untuk Latihan 1).

## 5. Pertanyaan interview yang mungkin muncul

1. Beda SmartForms dan SAPscript? → SmartForms: GUI grafis, generate FM, tanpa perlu menulis `WRITE_FORM`; SAPscript: `OPEN_FORM`/`WRITE_FORM`/`CLOSE_FORM`, client-dependent, logika di driver. (Adobe Forms = generasi berikutnya, butuh ADS.)
2. Kenapa pakai `SSF_FUNCTION_MODULE_NAME`? → nama FM generate berbeda antar sistem.
3. Beda main window dan secondary window? → main window mengalir antar halaman (hanya satu per halaman); secondary posisi tetap.
4. Bagaimana menambah field baru di form? → tambah di Form Interface/Global Data → isi dari driver → taruh di node Text; aktifkan ulang (transport form + driver).
5. Bagaimana debug SmartForm? → breakpoint di node *Program Lines*, atau debug FM generate; cek `JOB_OUTPUT_INFO`.
6. Bagaimana menghubungkan form ke output type? → NACE: output type → processing routine (program, form routine, form).
7. Bagaimana logo masuk ke form? → upload di `SE78` (BMP), lalu node Graphic.
