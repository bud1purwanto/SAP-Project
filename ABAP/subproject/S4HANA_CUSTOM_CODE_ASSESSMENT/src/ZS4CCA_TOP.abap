*&---------------------------------------------------------------------*
*& Include ZS4CCA_TOP
*& Tipe data, data global, dan layar seleksi tool ZS4CCA (F1)
*& Brief: subproject/S4HANA_CUSTOM_CODE_ASSESSMENT/docs/
*&        BRIEF_TOOL_DETEKSI_PERBAIKAN_S4.md
*&---------------------------------------------------------------------*

TYPES ty_mode TYPE c LENGTH 3.
TYPES ty_sev  TYPE c LENGTH 1.

" Satu unit source = satu program / include
TYPES: BEGIN OF ty_unit,
         name  TYPE progname,
         lines TYPE string_table,
       END OF ty_unit,
       tt_unit TYPE SORTED TABLE OF ty_unit WITH UNIQUE KEY name.

" Referensi objek yang ditemukan scanner
" KIND: TABR baca tabel | TABW tulis tabel | TABS stmt TABLES
"       FLD  field DDIC (NAME=tabel, SUB=field) | FM | TCODE | PROG
"       CLAS class/interface | ZTYP tipe Z | NSQL | HINT | DYN | LCLS
TYPES: BEGIN OF ty_ref,
         unit TYPE progname,
         line TYPE i,
         kind TYPE c LENGTH 5,
         name TYPE string,
         sub  TYPE string,
       END OF ty_ref,
       tt_ref TYPE STANDARD TABLE OF ty_ref WITH EMPTY KEY.

" Satu temuan (baris ALV)
TYPES: BEGIN OF ty_find,
         main     TYPE progname,
         unit     TYPE progname,
         line     TYPE i,
         layer    TYPE c LENGTH 2,
         severity TYPE c LENGTH 1,
         code     TYPE c LENGTH 24,
         ref_obj  TYPE c LENGTH 70,
         detail   TYPE string,
         action   TYPE string,
       END OF ty_find,
       tt_find TYPE STANDARD TABLE OF ty_find WITH EMPTY KEY.

" Peta baris source gabungan (L2) ke unit + baris asal
TYPES: BEGIN OF ty_map,
         unit TYPE progname,
         line TYPE i,
       END OF ty_map,
       tt_map TYPE STANDARD TABLE OF ty_map WITH EMPTY KEY.

DATA gv_prog TYPE progname.
DATA gt_find TYPE tt_find.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE gv_t1.
  SELECTION-SCREEN COMMENT /1(79) gv_c1.
  SELECTION-SCREEN COMMENT /1(79) gv_c2.
  SELECTION-SCREEN COMMENT /1(79) gv_c3.
  PARAMETERS: rb_file RADIOBUTTON GROUP src DEFAULT 'X',
              rb_rfc  RADIOBUTTON GROUP src,
              rb_adb  RADIOBUTTON GROUP src.
  SELECT-OPTIONS s_prog FOR gv_prog NO INTERVALS.
  PARAMETERS p_dest TYPE rfcdest.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE gv_t2.
  SELECTION-SCREEN COMMENT /1(79) gv_c4.
  PARAMETERS: p_l1 AS CHECKBOX DEFAULT 'X',
              p_l2 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.
