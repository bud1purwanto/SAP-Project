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

" Satu usulan perbaikan (baris ALV F3)
TYPES: BEGIN OF ty_chg,
         main    TYPE progname,
         unit    TYPE progname,
         line   TYPE i,
         rule   TYPE c LENGTH 12,
         risk    TYPE c LENGTH 1,
         applied TYPE abap_bool,
         before TYPE string,
         after  TYPE string,
         note   TYPE string,
       END OF ty_chg,
       tt_chg TYPE STANDARD TABLE OF ty_chg WITH EMPTY KEY.

" Ringkasan konversi per program
TYPES: BEGIN OF ty_sum,
         main       TYPE progname,
         copy       TYPE progname,
         status     TYPE c LENGTH 16,
         n_auto     TYPE i,
         n_warn     TYPE i,
         n_manual   TYPE i,
         err_before TYPE i,
         err_after  TYPE i,
         z_missing  TYPE i,
         note       TYPE string,
       END OF ty_sum,
       tt_sum TYPE STANDARD TABLE OF ty_sum WITH EMPTY KEY.

DATA gv_prog TYPE progname.
DATA gt_sum  TYPE tt_sum.
DATA gt_chg  TYPE tt_chg.
DATA gt_find TYPE tt_find.

* Layar seleksi. Label diisi di INITIALIZATION (ZS4CCA_MAIN).
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE gv_t1.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS rb_file RADIOBUTTON GROUP src DEFAULT 'X' USER-COMMAND src.
    SELECTION-SCREEN COMMENT 3(75) gv_r1 FOR FIELD rb_file.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS rb_rfc RADIOBUTTON GROUP src.
    SELECTION-SCREEN COMMENT 3(75) gv_r2 FOR FIELD rb_rfc.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS rb_adb RADIOBUTTON GROUP src.
    SELECTION-SCREEN COMMENT 3(75) gv_r3 FOR FIELD rb_adb.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 3(26) gv_l1 FOR FIELD s_prog MODIF ID prg.
    SELECT-OPTIONS s_prog FOR gv_prog NO INTERVALS MODIF ID prg.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE gv_t2.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 3(26) gv_l2 FOR FIELD p_dest.
    PARAMETERS p_dest TYPE rfcdest.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE gv_t3.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_l1 AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(75) gv_l3 FOR FIELD p_l1.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_l2 AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(75) gv_l4 FOR FIELD p_l2.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_fix AS CHECKBOX DEFAULT ' '.
    SELECTION-SCREEN COMMENT 3(75) gv_l5 FOR FIELD p_fix.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_sim AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 3(75) gv_l6 FOR FIELD p_sim.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.
