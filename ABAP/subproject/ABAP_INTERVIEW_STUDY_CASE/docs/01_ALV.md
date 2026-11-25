# 01 — ALV (ABAP List Viewer)

> Basis kasus: **ZMM052 — Report PO Import** (`ZMMR_PO_IMPORT_LOCAL`) di DEV (TRD 130).
> Source referensi: [../outputs/dev_src/ZMMR_PO_IMPORT_LOCAL.abap](../outputs/dev_src/ZMMR_PO_IMPORT_LOCAL.abap), include ALV bersama [../outputs/dev_src/ZABAPALV.abap](../outputs/dev_src/ZABAPALV.abap).

## 1. Konsep singkat (untuk interview)

ALV adalah cara standar SAP menampilkan data tabel internal dengan fitur siap pakai: sort, filter, total, subtotal, layout/variant, export Excel, print.
Ada 4 jenis yang sering ditanya:

| Jenis | Cara panggil | Kapan dipakai | Kelebihan | Kekurangan |
|---|---|---|---|---|
| **A. Function module grid** | `REUSE_ALV_GRID_DISPLAY` | Report sederhana, kode lama | Cepat dibuat, tidak perlu screen | Teknologi lama (FM), event lewat nama FORM (string) |
| **B. Function module list / hierarki** | `REUSE_ALV_LIST_DISPLAY`, `REUSE_ALV_HIERSEQ_LIST_DISPLAY` | Output list klasik, header-item | Bisa header-item, jalan di background | Tampilan list, interaksi terbatas |
| **C. OO grid** | `CL_GUI_ALV_GRID` + `CL_GUI_CUSTOM_CONTAINER` | Butuh editable, toolbar custom, beberapa grid di satu layar | Paling fleksibel, event OO | Perlu buat screen (SE51) + PF-STATUS |
| **D. SALV (Simple ALV OO)** | `CL_SALV_TABLE=>FACTORY` | Report read-only modern | Kode paling ringkas, tanpa field catalog manual | **Tidak bisa editable** (resmi) |

Kalimat kunci interview:
- *Field catalog* = definisi kolom (nama field, judul, panjang, hotspot, do_sum, no_out).
- *Layout* = setelan tampilan (zebra, colwidth_optimize, warna baris lewat `INFO_FIELDNAME`).
- *Event* = titik di mana program bereaksi (TOP_OF_PAGE, USER_COMMAND, HOTSPOT_CLICK, DATA_CHANGED).
- *Variant* (`I_SAVE = 'A'`) = user bisa simpan susunan kolom sendiri.

## 2. Apa yang ada di ZMM052 (analisa program nyata)

Alur program:

```
Selection screen (S_BUKRS, S_EKORG, S_EBELN, S_LIFNR, S_BEDAT, S_MATNR, S_EINDT, L/C ...)
  + radio R1/R2/R3 (jenis tampilan) + P_SCR (layar) / P_OLP (kirim ke OLAP)
AT SELECTION-SCREEN OUTPUT  -> AUTHORITY-CHECK Z_OLAP, sembunyikan P_OLP kalau tidak berhak
START-OF-SELECTION
  PERFORM GET_DATA          -> isi IT_TRACK dari EKKO/EKPO/EKET/EIPO/...
  PERFORM CEK_AUTHOR        -> buang PO yang BSART-nya tidak boleh dilihat (M_BEST_BSA)
  P_SCR = 'X' -> PERFORM SET_ALV
  P_OLP = 'X' -> PERFORM TO_OLAP (insert ke DB SQL lewat DBCON TRIASDB04)
```

Bagian ALV (`FORM SET_ALV`) memakai **jenis A**:

| Komponen | Di kode ZMM052 | Penjelasan |
|---|---|---|
| Layout | `LAYOUT_INIT_BOX`: `ZEBRA`, `COLWIDTH_OPTIMIZE`, `DETAIL_POPUP`, `INFO_FIELDNAME = 'LINE_COLOR'` | Baris belang, lebar kolom otomatis, warna per baris dari field `LINE_COLOR` |
| Field catalog | `BUILD_FIELDCAT` memanggil `F_ALV_FIELDCATG_WT_FRZ` dan `F_ALV_FIELDCATG` (include `ZABAPALV`) | Kolom Vendor..Delivery Date di-*freeze* (`FIX_COLUMN`), Vendor & PO Number diberi `HOTSPOT = 'X'` |
| Sort | `F_SORT`: LIFNR lalu EBELN | Urutan awal tampilan |
| Event | `EVENTTAB_BUILD` (REUSE_ALV_EVENTS_GET) + `TOP_OF_PAGE` (REUSE_ALV_COMMENTARY_WRITE) | Judul di atas grid |
| User command | `I_CALLBACK_USER_COMMAND = 'F_USER_COMMAND'` | `&IC1` (klik hotspot/double-click): PO → `ME23N`, Vendor → `XK03` |
| Variant | `I_SAVE = 'A'`, `IS_VARIANT-REPORT = SY-REPID` | User bisa simpan layout |
| Otorisasi | `CEK_AUTHOR` cek `M_BEST_BSA` per document type | Contoh baik: data disaring sesuai hak akses |

Hal yang bisa ditanya interviewer dari program ini:
1. *Kenapa `SY-LSIND = 0` di F_USER_COMMAND?* → supaya tidak menumpuk list level baru setiap klik.
2. *Bagaimana tahu kolom mana yang diklik?* → `FU_SELFIELD-SEL_TAB_FIELD` (contoh `'IT_TRACK-EBELN'`) dan `FU_SELFIELD-TABINDEX`.
3. *Bagaimana pindah ke transaksi lain membawa nilai?* → `SET PARAMETER ID 'BES'` + `CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN`.
4. *Catatan performa:* `CEK_AUTHOR` memakai `FOR ALL ENTRIES` — wajib cek tabel driver tidak kosong (sudah ada `IF IT_TRACK[] IS INITIAL. EXIT.`).

## 3. Study case hands-on

Tujuan: membuat **4 versi report PO mini** dengan data yang sama, supaya beda tiap jenis ALV terasa langsung.

**Data:** EKKO + EKPO (PO, item, vendor, material, qty, net value). Selection: `S_EBELN`, `S_BEDAT`, `S_LIFNR`.
**Tempat latihan:** `sandbox-new` (TRS 130), package `$TMP`, nama `ZTRAIN_ALV_A` s.d. `ZTRAIN_ALV_D`. Jangan di DEV/QAS/PRD.

Struktur output yang dipakai semua case:

```abap
TYPES: BEGIN OF ty_po,
         ebeln TYPE ekko-ebeln,
         bedat TYPE ekko-bedat,
         lifnr TYPE ekko-lifnr,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netwr TYPE ekpo-netwr,
         waers TYPE ekko-waers,
         line_color(4) TYPE c,
       END OF ty_po.
DATA: gt_po TYPE STANDARD TABLE OF ty_po,
      gs_po TYPE ty_po.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,
                s_bedat FOR ekko-bedat,
                s_lifnr FOR ekko-lifnr.

FORM get_data.
  SELECT k~ebeln k~bedat k~lifnr p~ebelp p~matnr p~txz01
         p~menge p~meins p~netwr k~waers
    INTO CORRESPONDING FIELDS OF TABLE gt_po
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    WHERE k~ebeln IN s_ebeln
      AND k~bedat IN s_bedat
      AND k~lifnr IN s_lifnr
      AND k~bstyp = 'F'          "hanya PO (bukan RFQ/kontrak)
      AND p~loekz = space.
ENDFORM.
```

(`TABLES ekko.` perlu dideklarasikan untuk `SELECT-OPTIONS ... FOR ekko-...`.)

### Case A — `REUSE_ALV_GRID_DISPLAY` (meniru ZMM052)

Target fitur: field catalog manual, hotspot PO → ME23N, total `NETWR`, warna baris merah kalau `NETWR` > 100 juta, TOP_OF_PAGE.

```abap
TYPE-POOLS: slis.
DATA: gt_fcat   TYPE slis_t_fieldcat_alv,
      gs_fcat   TYPE slis_fieldcat_alv,
      gs_layout TYPE slis_layout_alv.

FORM build_fcat.
  PERFORM add_fcat USING 'EBELN' 'PO Number'   'X' ' '.
  PERFORM add_fcat USING 'EBELP' 'Item'        ' ' ' '.
  PERFORM add_fcat USING 'BEDAT' 'PO Date'     ' ' ' '.
  PERFORM add_fcat USING 'LIFNR' 'Vendor'      ' ' ' '.
  PERFORM add_fcat USING 'MATNR' 'Material'    ' ' ' '.
  PERFORM add_fcat USING 'TXZ01' 'Description' ' ' ' '.
  PERFORM add_fcat USING 'MENGE' 'Qty'         ' ' ' '.
  PERFORM add_fcat USING 'MEINS' 'UoM'         ' ' ' '.
  PERFORM add_fcat USING 'NETWR' 'Net Value'   ' ' 'X'.
  PERFORM add_fcat USING 'WAERS' 'Curr'        ' ' ' '.
ENDFORM.

FORM add_fcat USING p_field p_text p_hotspot p_sum.
  CLEAR gs_fcat.
  gs_fcat-fieldname = p_field.
  gs_fcat-tabname   = 'GT_PO'.
  gs_fcat-seltext_l = p_text.
  gs_fcat-hotspot   = p_hotspot.
  gs_fcat-do_sum    = p_sum.
  IF p_field = 'NETWR'.
    gs_fcat-cfieldname = 'WAERS'.     "nilai mata uang ikut field WAERS
  ENDIF.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.

FORM set_color.
  LOOP AT gt_po INTO gs_po.
    IF gs_po-netwr > 100000000.
      gs_po-line_color = 'C610'.      "C=color, 6=merah, 1=intensified, 0=normal
      MODIFY gt_po FROM gs_po.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM display.
  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname    = 'LINE_COLOR'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = gs_layout
      it_fieldcat             = gt_fcat
      i_save                  = 'A'
    TABLES
      t_outtab                = gt_po
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  IF r_ucomm = '&IC1' AND rs_selfield-fieldname = 'EBELN'.
    READ TABLE gt_po INTO gs_po INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      SET PARAMETER ID 'BES' FIELD gs_po-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.

FORM top_of_page.
  DATA: lt_head TYPE slis_t_listheader,
        ls_head TYPE slis_listheader.
  ls_head-typ  = 'H'.
  ls_head-info = 'Daftar PO - Latihan ALV A'.
  APPEND ls_head TO lt_head.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_head.
ENDFORM.
```

Checklist uji Case A:
- [ ] Kolom Net Value punya total di bawah.
- [ ] Klik nomor PO membuka ME23N dengan PO yang benar.
- [ ] Baris > 100 juta berwarna merah.
- [ ] Simpan layout (Ctrl+F9 / tombol Save Layout), buka ulang, layout tetap.

### Case B — `REUSE_ALV_HIERSEQ_LIST_DISPLAY` (header–item)

Target: header = PO (EBELN, BEDAT, LIFNR, total), item = baris EKPO di bawahnya.
Poin belajar: dua tabel (`T_OUTTAB_HEADER`, `T_OUTTAB_ITEM`) dan `IS_KEYINFO` (`HEADER01 = 'EBELN'`, `ITEM01 = 'EBELN'`) sebagai penghubung.

```abap
DATA: gs_key TYPE slis_keyinfo_alv.
gs_key-header01 = 'EBELN'.
gs_key-item01   = 'EBELN'.
CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    it_fieldcat        = gt_fcat          "fieldcat berisi kolom header (tabname GT_HEAD) & item (GT_PO)
    i_tabname_header   = 'GT_HEAD'
    i_tabname_item     = 'GT_PO'
    is_keyinfo         = gs_key
  TABLES
    t_outtab_header    = gt_head
    t_outtab_item      = gt_po.
```

Checklist: setiap PO tampil sekali sebagai header, item-itemnya di bawah; jalankan juga di background (SE38 → Execute in background) untuk melihat bahwa list ALV bisa jadi spool.

### Case C — `CL_GUI_ALV_GRID` (OO, editable)

Target: grid di screen 100, kolom `MENGE` bisa diedit (hanya simulasi, **tidak disimpan ke EKPO**), tombol toolbar "Hitung Ulang", handler `DATA_CHANGED` validasi qty > 0.

Langkah:
1. SE38 buat program, SE51 buat screen `0100` dengan Custom Control bernama `CC_ALV`.
2. PF-STATUS `S100` dengan tombol BACK/EXIT/CANCEL.
3. PBO: buat container + grid sekali saja (cek `go_grid IS INITIAL`).

```abap
DATA: go_cont TYPE REF TO cl_gui_custom_container,
      go_grid TYPE REF TO cl_gui_alv_grid,
      gt_lvc  TYPE lvc_t_fcat,
      gs_lvc  TYPE lvc_s_fcat,
      gs_lay  TYPE lvc_s_layo.

CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_data_changed.
    DATA: ls_mod TYPE lvc_s_modi,
          lv_qty TYPE ekpo-menge.
    LOOP AT er_data_changed->mt_good_cells INTO ls_mod WHERE fieldname = 'MENGE'.
      lv_qty = ls_mod-value.
      IF lv_qty <= 0.
        CALL METHOD er_data_changed->add_protocol_entry
          EXPORTING
            i_msgid     = '00'
            i_msgty     = 'E'
            i_msgno     = '001'
            i_msgv1     = 'Qty harus > 0'
            i_fieldname = ls_mod-fieldname
            i_row_id    = ls_mod-row_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

DATA: go_handler TYPE REF TO lcl_handler.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  IF go_grid IS INITIAL.
    CREATE OBJECT go_cont EXPORTING container_name = 'CC_ALV'.
    CREATE OBJECT go_grid EXPORTING i_parent = go_cont.
    PERFORM build_lvc_fcat.             "sama seperti Case A, tipe LVC; MENGE: gs_lvc-edit = 'X'
    gs_lay-zebra      = 'X'.
    gs_lay-cwidth_opt = 'X'.
    CREATE OBJECT go_handler.
    SET HANDLER go_handler->on_data_changed FOR go_grid.
    CALL METHOD go_grid->register_edit_event
      EXPORTING i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING is_layout       = gs_lay
      CHANGING  it_outtab       = gt_po
                it_fieldcatalog = gt_lvc.
  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDMODULE.
```

Poin interview Case C:
- Beda field catalog: `SLIS_T_FIELDCAT_ALV` (FM) vs `LVC_T_FCAT` (OO).
- Editable: `LVC_S_FCAT-EDIT = 'X'` + `REGISTER_EDIT_EVENT`; ambil data terbaru dengan `CHECK_CHANGED_DATA`.
- Event OO: `HOTSPOT_CLICK`, `DOUBLE_CLICK`, `TOOLBAR`, `USER_COMMAND`, `DATA_CHANGED`.
- Container harus dibuat sekali; jika dibuat ulang setiap PBO → memory leak/grid dobel.

### Case D — `CL_SALV_TABLE`

Target: report read-only paling ringkas, dengan fungsi toolbar standar, sort, aggregation, dan event klik.

```abap
DATA: go_salv TYPE REF TO cl_salv_table,
      go_cols TYPE REF TO cl_salv_columns_table,
      go_col  TYPE REF TO cl_salv_column_table,
      go_agg  TYPE REF TO cl_salv_aggregations,
      lx_msg  TYPE REF TO cx_salv_msg.

TRY.
    cl_salv_table=>factory( IMPORTING r_salv_table = go_salv
                            CHANGING  t_table      = gt_po ).
  CATCH cx_salv_msg INTO lx_msg.
    MESSAGE lx_msg TYPE 'E'.
ENDTRY.

go_salv->get_functions( )->set_all( abap_true ).
go_cols = go_salv->get_columns( ).
go_cols->set_optimize( abap_true ).
go_col ?= go_cols->get_column( 'EBELN' ).
go_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
go_col ?= go_cols->get_column( 'NETWR' ).
go_col->set_currency_column( 'WAERS' ).   "total per mata uang
go_agg = go_salv->get_aggregations( ).
go_agg->add_aggregation( columnname = 'NETWR' ).
go_salv->display( ).
```

(Bentuk `object->method( )` dan `?=` sudah ada sejak 7.0, aman di 7.31. Jangan pakai `NEW`, `DATA(...)`, atau `|...|`.)

Poin interview Case D:
- Tidak perlu field catalog: kolom diambil dari tipe tabel.
- `get_column` bisa raise `CX_SALV_NOT_FOUND` → bungkus `TRY ... CATCH`.
- SALV **tidak mendukung edit** secara resmi; kalau perlu edit → `CL_GUI_ALV_GRID`.

## 4. Ringkasan perbandingan (hafalkan)

| Pertanyaan | A (REUSE grid) | B (REUSE list/hier) | C (CL_GUI_ALV_GRID) | D (CL_SALV_TABLE) |
|---|---|---|---|---|
| Perlu screen sendiri? | Tidak | Tidak | **Ya** (custom control) | Tidak (atau container opsional) |
| Field catalog | `SLIS_T_FIELDCAT_ALV` | `SLIS_T_FIELDCAT_ALV` | `LVC_T_FCAT` | Otomatis |
| Editable | Terbatas | Tidak | **Ya** | Tidak |
| Event | FORM callback (string) | FORM callback | Method handler OO | Method handler OO |
| Background job | Otomatis jadi list | Ya | Tidak (butuh GUI) | Ya (fullscreen jadi list) |
| Contoh di sistem | ZMM052, ZSD113 (log error) | — | — | — |

## 5. Program latihan yang sudah diuji (25 Nov 2026)

Versi lengkap tiap case ada di [../src/](../src/): `ZTRAIN_ALV_A.abap`, `ZTRAIN_ALV_B.abap`, `ZTRAIN_ALV_C.abap`, `ZTRAIN_ALV_D.abap`. Semuanya sudah dibuat di **sandbox-new** (`$TMP`) dan di **S/4HANA ADB** (`$TMP`). Detail: [06_HASIL_UJI.md](06_HASIL_UJI.md).

| Program | Syntax check sandbox-new (7.31) | Jalan di sandbox-new | S/4 |
|---|---|---|---|
| ZTRAIN_ALV_A | OK | Background job OK. Di SAP GUI Java server, grid dengan TOP_OF_PAGE (HTML) membuat klien macet — batasan GUI Java, bukan program | Sintaks OK |
| ZTRAIN_ALV_B | OK | Background + GUI OK (expand header → item) | Sintaks OK, GUI OK |
| ZTRAIN_ALV_C | OK | GUI OK: edit Qty, Qty = 0 ditolak lewat `DATA_CHANGED`, Back OK | Sintaks OK (screen/status belum dibuat di S/4) |
| ZTRAIN_ALV_D | OK setelah 1 perbaikan | GUI OK: hotspot → ME23N, total per mata uang | Sintaks + grid OK; ME23N S/4 dump (DDIC S/4) |

Perbaikan dari uji: di ABAP 7.31 `SET HANDLER ... FOR go_salv->get_event( ).` **error** ("." expected). Hasil method harus disimpan dulu ke variabel:

```abap
DATA go_evt TYPE REF TO cl_salv_events_table.
go_evt = go_salv->get_event( ).
SET HANDLER go_events->on_link_click FOR go_evt.
```

Ini contoh nyata batasan 7.31 yang bagus untuk diceritakan: method chaining di posisi operand belum didukung di semua statement.

Dua temuan lain dari uji GUI (sudah diperbaiki di `src/`):

1. **EKKO berisi RFQ, kontrak, dan PO.** Tanpa filter, report "PO" ikut menampilkan RFQ (di sandbox: BSART ZQ07), dan ME23N menolak membukanya. Solusi: `AND k~bstyp = 'F'` (F = PO, A = RFQ, K = kontrak, L = scheduling agreement).
2. **Kolom nilai wajib dihubungkan ke kolom mata uang.** Tanpa itu, total mencampur USD + IDR, dan IDR (0 desimal di TCURX) tampil 100× lebih kecil. REUSE: `fieldcat-cfieldname = 'WAERS'`. SALV: `go_col->set_currency_column( 'WAERS' )`. OO grid: `lvc_s_fcat-cfieldname`.

Keduanya pertanyaan interview yang sering keluar: "kenapa total di ALV Anda salah?" dan "bagaimana membedakan PO dari RFQ di EKKO?".

## 6. Pertanyaan interview yang mungkin muncul

1. Apa beda `REUSE_ALV_GRID_DISPLAY` dan `CL_GUI_ALV_GRID`? → FM vs OO; OO butuh container/screen, lebih fleksibel, mendukung edit dan banyak grid.
2. Bagaimana membuat kolom hotspot dan menangkap kliknya? → fieldcat `HOTSPOT = 'X'`, callback `USER_COMMAND` dengan `'&IC1'` (FM) / event `HOTSPOT_CLICK` (OO).
3. Bagaimana memberi warna baris / sel? → baris: layout `INFO_FIELDNAME`; sel: layout `CTAB_FNAME` (tabel `LVC_T_SCOL`/`SLIS_T_SPECIALCOL_ALV`).
4. Bagaimana menampilkan total dan subtotal? → fieldcat `DO_SUM`, sort table dengan `SUBTOT = 'X'`.
5. Report ALV dijalankan background, apa yang terjadi? → grid tidak bisa tampil, output jadi spool list (FM/SALV). `CL_GUI_ALV_GRID` butuh `CL_GUI_ALV_GRID=>OFFLINE( )` untuk dicek.
6. Bagaimana user menyimpan layout? → `I_SAVE = 'A'` + `IS_VARIANT-REPORT`.
