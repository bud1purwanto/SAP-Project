*&---------------------------------------------------------------------*
*& Include ZS4CCA_CORE
*& Local class tool ZS4CCA (F1): ambil source, scan referensi,
*& L1 diff DDIC (ADB vs ECC opsional), L2 syntax check S/4, ALV.
*& Hanya membaca. Tidak menulis ke sistem mana pun.
*&---------------------------------------------------------------------*

CLASS lcl_util DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS is_custom
      IMPORTING iv_name      TYPE csequence
      RETURNING VALUE(rv_yes) TYPE abap_bool.
    CLASS-METHODS include_of
      IMPORTING iv_line        TYPE string
      RETURNING VALUE(rv_name) TYPE progname.
    CLASS-METHODS is_main
      IMPORTING it_lines      TYPE string_table
      RETURNING VALUE(rv_yes) TYPE abap_bool.
    CLASS-METHODS unquote
      IMPORTING iv_token       TYPE string
      RETURNING VALUE(rv_text) TYPE string.
    CLASS-METHODS code_part
      IMPORTING iv_line        TYPE string
      RETURNING VALUE(rv_code) TYPE string.
    CLASS-METHODS is_literal
      IMPORTING iv_token      TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.

CLASS lcl_util IMPLEMENTATION.

  METHOD is_custom.
    DATA(lv_name) = to_upper( condense( iv_name ) ).
    rv_yes = xsdbool( lv_name CP 'Z*' OR lv_name CP 'Y*' ).
  ENDMETHOD.

  METHOD include_of.
    DATA lv_name TYPE string.
    DATA(lv_line) = to_upper( iv_line ).
    FIND FIRST OCCURRENCE OF REGEX `^\s*INCLUDE\s+([A-Z0-9_/]+)\s*(IF\s+FOUND\s*)?\.`
         IN lv_line SUBMATCHES lv_name.
    IF sy-subrc = 0 AND lv_name <> 'STRUCTURE' AND lv_name <> 'TYPE'.
      rv_name = lv_name.
    ENDIF.
  ENDMETHOD.

  METHOD is_main.
    LOOP AT it_lines INTO DATA(lv_line).
      DATA(lv_code) = to_upper( code_part( lv_line ) ).
      IF lv_code IS INITIAL.
        CONTINUE.
      ENDIF.
      rv_yes = xsdbool( lv_code CP 'REPORT*' OR lv_code CP 'PROGRAM*'
                     OR lv_code CP 'FUNCTION-POOL*' ).
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD unquote.
    rv_text = iv_token.
    DATA(lv_len) = strlen( rv_text ).
    IF lv_len >= 2 AND is_literal( rv_text ) = abap_true.
      rv_text = substring( val = rv_text off = 1 len = lv_len - 2 ).
    ENDIF.
    rv_text = to_upper( rv_text ).
  ENDMETHOD.

  METHOD is_literal.
    IF iv_token IS INITIAL.
      RETURN.
    ENDIF.
    DATA(lv_first) = substring( val = iv_token off = 0 len = 1 ).
    rv_yes = xsdbool( lv_first = `'` OR lv_first = '`' ).
  ENDMETHOD.

  METHOD code_part.
    " Bagian kode tanpa komentar (* di kolom 1 atau " di akhir baris)
    IF iv_line IS INITIAL.
      RETURN.
    ENDIF.
    IF substring( val = iv_line off = 0 len = 1 ) = '*'.
      RETURN.
    ENDIF.
    DATA lv_off TYPE i.
    rv_code = iv_line.
    FIND FIRST OCCURRENCE OF '"' IN rv_code MATCH OFFSET lv_off.
    IF sy-subrc = 0.
      rv_code = substring( val = rv_code off = 0 len = lv_off ).
    ENDIF.
    CONDENSE rv_code.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Sumber source: file upload (baseline Alfa), RFC ECC, atau ADB lokal
*----------------------------------------------------------------------*
CLASS lcl_source DEFINITION FINAL.
  PUBLIC SECTION.
    DATA mt_units   TYPE tt_unit READ-ONLY.
    DATA mt_mains   TYPE string_table READ-ONLY.
    DATA mt_missing TYPE string_table READ-ONLY.
    METHODS constructor
      IMPORTING iv_mode TYPE ty_mode
                iv_dest TYPE rfcdest OPTIONAL.
    METHODS load_from_files.
    METHODS load_program
      IMPORTING iv_name    TYPE progname
                iv_is_main TYPE abap_bool DEFAULT abap_false.
    METHODS lines_of
      IMPORTING iv_name         TYPE progname
      RETURNING VALUE(rt_lines) TYPE string_table.
    METHODS has
      IMPORTING iv_name       TYPE progname
      RETURNING VALUE(rv_yes) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_mode TYPE ty_mode.
    DATA mv_dest TYPE rfcdest.
    METHODS fetch
      IMPORTING iv_name         TYPE progname
      RETURNING VALUE(rt_lines) TYPE string_table.
    METHODS add_missing
      IMPORTING iv_name TYPE csequence.
ENDCLASS.

CLASS lcl_source IMPLEMENTATION.

  METHOD constructor.
    mv_mode = iv_mode.
    mv_dest = iv_dest.
  ENDMETHOD.

  METHOD has.
    rv_yes = xsdbool( line_exists( mt_units[ name = iv_name ] ) ).
  ENDMETHOD.

  METHOD lines_of.
    READ TABLE mt_units INTO DATA(ls_unit) WITH TABLE KEY name = iv_name.
    IF sy-subrc = 0.
      rt_lines = ls_unit-lines.
    ENDIF.
  ENDMETHOD.

  METHOD add_missing.
    DATA(lv_name) = to_upper( CONV string( iv_name ) ).
    IF NOT line_exists( mt_missing[ table_line = lv_name ] ).
      APPEND lv_name TO mt_missing.
    ENDIF.
  ENDMETHOD.

  METHOD load_from_files.
    DATA: lt_files TYPE filetable,
          lt_lines TYPE string_table,
          lv_rc    TYPE i,
          lv_act   TYPE i,
          lv_off   TYPE i.

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        window_title            = 'Pilih file .abap (program utama + include)'
        file_filter             = 'ABAP (*.abap;*.txt)|*.abap;*.txt|Semua (*.*)|*.*'
        multiselection          = abap_true
      CHANGING
        file_table              = lt_files
        rc                      = lv_rc
        user_action             = lv_act
      EXCEPTIONS
        OTHERS                  = 1 ).
    IF sy-subrc <> 0 OR lv_act <> cl_gui_frontend_services=>action_ok.
      RETURN.
    ENDIF.

    DATA(lv_bom) = cl_abap_conv_in_ce=>uccp( 'FEFF' ).

    LOOP AT lt_files INTO DATA(ls_file).
      DATA(lv_path) = CONV string( ls_file-filename ).
      CLEAR lt_lines.
      cl_gui_frontend_services=>gui_upload(
        EXPORTING
          filename = lv_path
          filetype = 'ASC'
          codepage = '4110'
        CHANGING
          data_tab = lt_lines
        EXCEPTIONS
          OTHERS   = 1 ).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      " buang BOM UTF-8 di baris pertama
      IF lt_lines IS NOT INITIAL.
        ASSIGN lt_lines[ 1 ] TO FIELD-SYMBOL(<lv_first>).
        IF strlen( <lv_first> ) > 0 AND substring( val = <lv_first> off = 0 len = 1 ) = lv_bom.
          <lv_first> = substring( val = <lv_first> off = 1 ).
        ENDIF.
      ENDIF.
      " nama unit = nama file tanpa folder dan ekstensi
      DATA(lv_base) = lv_path.
      FIND ALL OCCURRENCES OF REGEX `[\\/]` IN lv_base MATCH OFFSET lv_off.
      IF sy-subrc = 0.
        lv_base = substring( val = lv_base off = lv_off + 1 ).
      ENDIF.
      lv_base = to_upper( replace( val = lv_base regex = `\.[^.]*$` with = `` ) ).
      INSERT VALUE #( name = CONV #( lv_base ) lines = lt_lines ) INTO TABLE mt_units.
      IF sy-subrc = 0 AND lcl_util=>is_main( lt_lines ) = abap_true.
        APPEND lv_base TO mt_mains.
      ENDIF.
    ENDLOOP.

    " INCLUDE Z yang dirujuk tapi filenya tidak ikut
    LOOP AT mt_units INTO DATA(ls_unit).
      LOOP AT ls_unit-lines INTO DATA(lv_line).
        DATA(lv_inc) = lcl_util=>include_of( lv_line ).
        IF lv_inc IS NOT INITIAL AND lcl_util=>is_custom( lv_inc ) = abap_true
           AND has( lv_inc ) = abap_false.
          add_missing( lv_inc ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD load_program.
    IF has( iv_name ) = abap_true.
      RETURN.
    ENDIF.
    DATA(lt_lines) = fetch( iv_name ).
    IF lt_lines IS INITIAL.
      add_missing( iv_name ).
      RETURN.
    ENDIF.
    INSERT VALUE #( name = iv_name lines = lt_lines ) INTO TABLE mt_units.
    IF iv_is_main = abap_true.
      APPEND CONV string( iv_name ) TO mt_mains.
    ENDIF.
    " include custom ikut dibaca (rekursif)
    LOOP AT lt_lines INTO DATA(lv_line).
      DATA(lv_inc) = lcl_util=>include_of( lv_line ).
      IF lv_inc IS NOT INITIAL AND lcl_util=>is_custom( lv_inc ) = abap_true.
        load_program( lv_inc ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD fetch.
    DATA: lt_src TYPE STANDARD TABLE OF abaptxt255 WITH EMPTY KEY,
          lv_msg TYPE c LENGTH 200.

    CASE mv_mode.
      WHEN 'ADB'.
        " versi inactive dulu (program salinan yang belum bisa diaktifkan)
        READ REPORT iv_name INTO lt_src STATE 'I'.
        IF sy-subrc <> 0.
          READ REPORT iv_name INTO lt_src.
          IF sy-subrc <> 0.
            CLEAR lt_src.
          ENDIF.
        ENDIF.
      WHEN 'RFC'.
        CALL FUNCTION 'RPY_PROGRAM_READ'
          DESTINATION mv_dest
          EXPORTING
            program_name          = iv_name
            with_includelist      = abap_false
            only_source           = abap_true
            with_lowercase        = abap_true
          TABLES
            source_extended       = lt_src
          EXCEPTIONS
            cancelled             = 1
            not_found             = 2
            permission_error      = 3
            system_failure        = 4 MESSAGE lv_msg
            communication_failure = 5 MESSAGE lv_msg
            OTHERS                = 6.
        IF sy-subrc <> 0.
          CLEAR lt_src.
        ENDIF.
    ENDCASE.

    rt_lines = VALUE #( FOR ls_src IN lt_src ( CONV string( ls_src-line ) ) ).
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Scanner: token resmi ABAP (SCAN ABAP-SOURCE) -> referensi objek
*----------------------------------------------------------------------*
CLASS lcl_scan DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS scan
      IMPORTING iv_unit       TYPE progname
                it_lines      TYPE string_table
      RETURNING VALUE(rt_ref) TYPE tt_ref.
  PRIVATE SECTION.
    CLASS-METHODS add
      IMPORTING iv_unit TYPE progname
                iv_line TYPE i
                iv_kind TYPE csequence
                iv_name TYPE csequence
                iv_sub  TYPE csequence OPTIONAL
      CHANGING  ct_ref  TYPE tt_ref.
    CLASS-METHODS add_table
      IMPORTING iv_unit  TYPE progname
                iv_line  TYPE i
                iv_kind  TYPE csequence
                iv_token TYPE string
      CHANGING  ct_ref   TYPE tt_ref.
    CLASS-METHODS add_type
      IMPORTING iv_unit  TYPE progname
                iv_line  TYPE i
                iv_token TYPE string
      CHANGING  ct_ref   TYPE tt_ref.
ENDCLASS.

CLASS lcl_scan IMPLEMENTATION.

  METHOD add.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    APPEND VALUE #( unit = iv_unit line = iv_line kind = iv_kind
                    name = to_upper( CONV string( iv_name ) )
                    sub  = to_upper( CONV string( iv_sub ) ) ) TO ct_ref.
  ENDMETHOD.

  METHOD add_table.
    " nama tabel setelah FROM/JOIN/UPDATE/...; (x) = dinamis
    DATA(lv_name) = iv_token.
    IF lv_name IS INITIAL OR lcl_util=>is_literal( lv_name ) = abap_true.
      RETURN.
    ENDIF.
    IF substring( val = lv_name off = 0 len = 1 ) = '('.
      add( EXPORTING iv_unit = iv_unit iv_line = iv_line iv_kind = 'DYN'
                     iv_name = lv_name iv_sub = 'TABEL DINAMIS'
           CHANGING  ct_ref = ct_ref ).
      RETURN.
    ENDIF.
    IF substring( val = lv_name off = 0 len = 1 ) = '*'.
      lv_name = substring( val = lv_name off = 1 ).
    ENDIF.
    add( EXPORTING iv_unit = iv_unit iv_line = iv_line iv_kind = iv_kind iv_name = lv_name
         CHANGING  ct_ref = ct_ref ).
  ENDMETHOD.

  METHOD add_type.
    " TYPE/LIKE x-y -> field DDIC ; TYPE zxxx -> tipe custom
    DATA: lv_tab  TYPE string,
          lv_fld  TYPE string,
          lv_rest TYPE string ##NEEDED.
    IF iv_token IS INITIAL OR lcl_util=>is_literal( iv_token ) = abap_true
       OR substring( val = iv_token off = 0 len = 1 ) = '('.
      RETURN.
    ENDIF.
    IF iv_token CS '-'.
      SPLIT iv_token AT '-' INTO lv_tab lv_fld lv_rest.
      IF lv_tab IS NOT INITIAL AND lv_fld IS NOT INITIAL.
        add( EXPORTING iv_unit = iv_unit iv_line = iv_line iv_kind = 'FLD'
                       iv_name = lv_tab iv_sub = lv_fld
             CHANGING  ct_ref = ct_ref ).
      ENDIF.
    ELSEIF lcl_util=>is_custom( iv_token ) = abap_true.
      add( EXPORTING iv_unit = iv_unit iv_line = iv_line iv_kind = 'ZTYP' iv_name = iv_token
           CHANGING  ct_ref = ct_ref ).
    ENDIF.
  ENDMETHOD.

  METHOD scan.
    DATA: lt_tok   TYPE STANDARD TABLE OF stokes WITH EMPTY KEY,
          lt_stm   TYPE STANDARD TABLE OF sstmnt WITH EMPTY KEY,
          lt_t     TYPE string_table,
          lt_pref  TYPE string_table,
          lv_crow  TYPE i VALUE -1,
          lv_ccol  TYPE i VALUE -1,
          lv_i     TYPE i,
          lv_j     TYPE i.

    SCAN ABAP-SOURCE it_lines TOKENS INTO lt_tok STATEMENTS INTO lt_stm.
    IF lt_stm IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_stm INTO DATA(ls_stm).
      CLEAR lt_t.
      LOOP AT lt_tok INTO DATA(ls_tok) FROM ls_stm-from TO ls_stm-to.
        APPEND COND string( WHEN ls_tok-type = 'S' THEN ls_tok-str
                            ELSE to_upper( ls_tok-str ) ) TO lt_t.
      ENDLOOP.
      IF lt_t IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA(lv_row) = lt_tok[ ls_stm-from ]-row.

      " kalimat berantai (titik dua): pastikan prefiks ada di depan
      IF ls_stm-colonrow > 0.
        IF ls_stm-colonrow = lv_crow AND ls_stm-coloncol = lv_ccol.
          IF lt_pref IS NOT INITIAL AND lt_t[ 1 ] <> lt_pref[ 1 ].
            DATA(lt_tmp) = lt_pref.
            APPEND LINES OF lt_t TO lt_tmp.
            lt_t = lt_tmp.
          ENDIF.
        ELSE.
          lv_crow = ls_stm-colonrow.
          lv_ccol = ls_stm-coloncol.
          CLEAR lt_pref.
          DO nmax( val1 = 1 val2 = CONV i( ls_stm-prefixlen ) ) TIMES.
            IF sy-index <= lines( lt_t ).
              APPEND lt_t[ sy-index ] TO lt_pref.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDIF.

      DATA(lv_n)  = lines( lt_t ).
      DATA(lv_kw) = lt_t[ 1 ].
      DATA(lv_k2) = COND string( WHEN lv_n >= 2 THEN lt_t[ 2 ] ).
      DATA(lv_k3) = COND string( WHEN lv_n >= 3 THEN lt_t[ 3 ] ).

      " --- baca tabel: SELECT / OPEN CURSOR / subquery
      IF lv_kw = 'SELECT' OR ( lv_kw = 'OPEN' AND lv_k2 = 'CURSOR' ).
        lv_i = 1.
        WHILE lv_i < lv_n.
          IF lt_t[ lv_i ] = 'FROM' OR lt_t[ lv_i ] = 'JOIN'.
            lv_j = lv_i + 1.
            " FROM ( a INNER JOIN b ...) -> lompati kurung
            WHILE lv_j <= lv_n AND lt_t[ lv_j ] = '('.
              lv_j = lv_j + 1.
            ENDWHILE.
            IF lv_j <= lv_n.
              add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABR'
                                   iv_token = lt_t[ lv_j ]
                         CHANGING  ct_ref = rt_ref ).
            ENDIF.
          ENDIF.
          lv_i = lv_i + 1.
        ENDWHILE.
      ENDIF.

      " --- tulis tabel DB (disaring nanti: harus tabel DDIC)
      CASE lv_kw.
        WHEN 'UPDATE' OR 'MODIFY'.
          IF lv_k2 <> 'TABLE' AND lv_k2 <> 'SCREEN' AND lv_k2 <> 'LINE'
             AND lv_k2 <> 'CURRENT'.
            add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABW'
                                 iv_token = lv_k2
                       CHANGING  ct_ref = rt_ref ).
          ENDIF.
        WHEN 'INSERT'.
          " INSERT wa INTO TABLE itab / INSERT LINES OF ... = internal table
          IF NOT ( line_exists( lt_t[ table_line = 'TABLE' ] )
                   OR line_exists( lt_t[ table_line = 'LINES' ] )
                   OR line_exists( lt_t[ table_line = 'INDEX' ] )
                   OR lv_k2 = 'REPORT' OR lv_k2 = 'TEXTPOOL' ).
            add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABW'
                                 iv_token = COND #( WHEN lv_k2 = 'INTO' THEN lv_k3 ELSE lv_k2 )
                       CHANGING  ct_ref = rt_ref ).
          ENDIF.
        WHEN 'DELETE'.
          IF lv_k2 = 'FROM'.
            add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABW'
                                 iv_token = lv_k3
                       CHANGING  ct_ref = rt_ref ).
          ELSEIF lv_k2 <> 'ADJACENT' AND lv_k2 <> 'TABLE' AND lv_k2 <> 'REPORT'
             AND lv_k2 <> 'TEXTPOOL' AND lv_k2 <> 'DATASET'.
            add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABW'
                                 iv_token = lv_k2
                       CHANGING  ct_ref = rt_ref ).
          ENDIF.
        WHEN 'TABLES'.
          LOOP AT lt_t INTO DATA(lv_tabs) FROM 2.
            add_table( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TABS'
                                 iv_token = lv_tabs
                       CHANGING  ct_ref = rt_ref ).
          ENDLOOP.
        WHEN 'CALL'.
          IF ( lv_k2 = 'FUNCTION' OR lv_k2 = 'TRANSACTION' ) AND lv_n >= 3.
            IF lcl_util=>is_literal( lv_k3 ) = abap_true.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row
                             iv_kind = COND string( WHEN lv_k2 = 'FUNCTION' THEN `FM` ELSE `TCODE` )
                             iv_name = lcl_util=>unquote( lv_k3 )
                   CHANGING  ct_ref = rt_ref ).
            ELSE.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'DYN'
                             iv_name = lv_k3 iv_sub = |CALL { lv_k2 }|
                   CHANGING  ct_ref = rt_ref ).
            ENDIF.
          ENDIF.
        WHEN 'LEAVE'.
          IF lv_k2 = 'TO' AND lv_k3 = 'TRANSACTION' AND lv_n >= 4.
            IF lcl_util=>is_literal( lt_t[ 4 ] ) = abap_true.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'TCODE'
                             iv_name = lcl_util=>unquote( lt_t[ 4 ] )
                   CHANGING  ct_ref = rt_ref ).
            ENDIF.
          ENDIF.
        WHEN 'SUBMIT'.
          IF lv_k2 IS NOT INITIAL.
            IF substring( val = lv_k2 off = 0 len = 1 ) = '('.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'DYN'
                             iv_name = lv_k2 iv_sub = 'SUBMIT'
                   CHANGING  ct_ref = rt_ref ).
            ELSE.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'PROG' iv_name = lv_k2
                   CHANGING  ct_ref = rt_ref ).
            ENDIF.
          ENDIF.
        WHEN 'EXEC'.
          IF lv_k2 = 'SQL'.
            add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'NSQL' iv_name = 'EXEC SQL'
                 CHANGING  ct_ref = rt_ref ).
          ENDIF.
        WHEN 'CLASS' OR 'INTERFACE'.
          " class/interface lokal: jangan dicek ke repository
          IF lv_k2 IS NOT INITIAL.
            add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'LCLS' iv_name = lv_k2
                 CHANGING  ct_ref = rt_ref ).
          ENDIF.
      ENDCASE.

      " --- token di posisi mana pun
      lv_i = 1.
      WHILE lv_i <= lv_n.
        DATA(lv_tk) = lt_t[ lv_i ].
        DATA(lv_nx) = COND string( WHEN lv_i < lv_n THEN lt_t[ lv_i + 1 ] ).

        IF lv_tk = '%_HINTS'.
          add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'HINT' iv_name = '%_HINTS'
                         iv_sub = lv_nx
               CHANGING  ct_ref = rt_ref ).
        ENDIF.

        IF ( lv_tk = 'TYPE' OR lv_tk = 'LIKE' ) AND lv_nx IS NOT INITIAL AND lv_kw <> 'CALL'.
          IF lv_nx = 'REF' AND lv_i + 3 <= lv_n AND lt_t[ lv_i + 2 ] = 'TO'.
            DATA(lv_cls) = lt_t[ lv_i + 3 ].
            IF lv_cls <> 'DATA' AND lv_cls <> 'OBJECT'.
              add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'CLAS' iv_name = lv_cls
                   CHANGING  ct_ref = rt_ref ).
            ENDIF.
          ELSEIF lv_nx = 'TABLE' OR lv_nx = 'STANDARD' OR lv_nx = 'SORTED'
              OR lv_nx = 'HASHED' OR lv_nx = 'RANGE' OR lv_nx = 'LINE'.
            " TYPE [STANDARD] TABLE OF x / RANGE OF x / LINE OF x
            lv_j = lv_i + 1.
            WHILE lv_j < lv_n AND lv_j <= lv_i + 4.
              IF lt_t[ lv_j ] = 'OF'.
                add_type( EXPORTING iv_unit = iv_unit iv_line = lv_row
                                    iv_token = lt_t[ lv_j + 1 ]
                          CHANGING  ct_ref = rt_ref ).
                EXIT.
              ENDIF.
              lv_j = lv_j + 1.
            ENDWHILE.
          ELSE.
            add_type( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_token = lv_nx
                      CHANGING  ct_ref = rt_ref ).
          ENDIF.
        ENDIF.

        " pemanggilan statis class=>method
        IF lv_tk CS '=>' AND lv_tk <> '=>'.
          SPLIT lv_tk AT '=>' INTO DATA(lv_cl) DATA(lv_meth) ##NEEDED.
          IF lv_cl IS NOT INITIAL AND lv_cl <> 'ME' AND lv_cl <> 'SUPER'
             AND substring( val = lv_cl off = 0 len = 1 ) <> '('.
            add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'CLAS' iv_name = lv_cl
                 CHANGING  ct_ref = rt_ref ).
          ENDIF.
        ELSEIF lv_tk = '=>' AND lv_i > 1.
          add( EXPORTING iv_unit = iv_unit iv_line = lv_row iv_kind = 'CLAS'
                         iv_name = lt_t[ lv_i - 1 ]
               CHANGING  ct_ref = rt_ref ).
        ENDIF.

        lv_i = lv_i + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* L1: cek referensi ke repository ADB (S/4) dan ECC (opsional, RFC)
*----------------------------------------------------------------------*
CLASS lcl_ddic DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_dest TYPE rfcdest OPTIONAL.
    METHODS load
      IMPORTING it_ref TYPE tt_ref.
    METHODS evaluate
      IMPORTING is_ref  TYPE ty_ref
                iv_main TYPE progname
      CHANGING  ct_find TYPE tt_find.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_tab,
             tabname  TYPE tabname,
             tabclass TYPE tabclass,
             viewref  TYPE dd02l-viewref,
           END OF ty_tab,
           tt_tab TYPE SORTED TABLE OF ty_tab WITH NON-UNIQUE KEY tabname.
    TYPES: BEGIN OF ty_fld,
             tabname   TYPE tabname,
             fieldname TYPE fieldname,
             leng      TYPE dd03l-leng,
           END OF ty_fld,
           tt_fld TYPE SORTED TABLE OF ty_fld WITH NON-UNIQUE KEY tabname fieldname.
    TYPES ty_name TYPE c LENGTH 40.
    TYPES tt_name TYPE SORTED TABLE OF ty_name WITH NON-UNIQUE KEY table_line.

    DATA: mv_dest TYPE rfcdest,
          mt_tab  TYPE tt_tab,
          mt_fld  TYPE tt_fld,
          mt_etab TYPE tt_tab,
          mt_efld TYPE tt_fld,
          mt_fm   TYPE tt_name,
          mt_tc   TYPE tt_name,
          mt_prog TYPE tt_name,
          mt_cls  TYPE tt_name,
          mt_typ  TYPE tt_name.

    METHODS ecc_read
      IMPORTING iv_table       TYPE tabname
                iv_where       TYPE string
                it_fields      TYPE string_table
      RETURNING VALUE(rt_rows) TYPE string_table.
    METHODS add
      IMPORTING is_ref    TYPE ty_ref
                iv_main   TYPE progname
                iv_sev    TYPE ty_sev
                iv_code   TYPE csequence
                iv_obj    TYPE csequence
                iv_detail TYPE string
                iv_action TYPE string
      CHANGING  ct_find   TYPE tt_find.
    METHODS add_missing_z
      IMPORTING is_ref  TYPE ty_ref
                iv_main TYPE progname
                iv_obj  TYPE csequence
      CHANGING  ct_find TYPE tt_find.
ENDCLASS.

CLASS lcl_ddic IMPLEMENTATION.

  METHOD constructor.
    mv_dest = iv_dest.
  ENDMETHOD.

  METHOD load.
    DATA: lr_tab  TYPE RANGE OF tabname,
          lr_fm   TYPE RANGE OF rs38l_fnam,
          lr_tc   TYPE RANGE OF tcode,
          lr_prog TYPE RANGE OF progname,
          lr_cls  TYPE RANGE OF seoclsname,
          lr_dtel TYPE RANGE OF rollname,
          lr_ttyp TYPE RANGE OF ttypename,
          lt_ftab TYPE SORTED TABLE OF tabname WITH UNIQUE KEY table_line,
          lt_dtel TYPE STANDARD TABLE OF rollname WITH EMPTY KEY,
          lt_ttyp TYPE STANDARD TABLE OF ttypename WITH EMPTY KEY,
          lt_rows TYPE string_table.

    LOOP AT it_ref INTO DATA(ls_ref).
      CASE ls_ref-kind.
        WHEN 'TABR' OR 'TABW' OR 'TABS'.
          lr_tab = VALUE #( BASE lr_tab ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
        WHEN 'FLD'.
          lr_tab = VALUE #( BASE lr_tab ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
          INSERT CONV tabname( ls_ref-name ) INTO TABLE lt_ftab.
        WHEN 'FM'.
          lr_fm = VALUE #( BASE lr_fm ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
        WHEN 'TCODE'.
          lr_tc = VALUE #( BASE lr_tc ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
        WHEN 'PROG'.
          lr_prog = VALUE #( BASE lr_prog ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
        WHEN 'CLAS'.
          lr_cls = VALUE #( BASE lr_cls ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
        WHEN 'ZTYP'.
          lr_tab  = VALUE #( BASE lr_tab  ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
          lr_cls  = VALUE #( BASE lr_cls  ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
          lr_dtel = VALUE #( BASE lr_dtel ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
          lr_ttyp = VALUE #( BASE lr_ttyp ( sign = 'I' option = 'EQ' low = ls_ref-name ) ).
      ENDCASE.
    ENDLOOP.
    SORT: lr_tab, lr_fm, lr_tc, lr_prog, lr_cls, lr_dtel, lr_ttyp.
    DELETE ADJACENT DUPLICATES FROM: lr_tab, lr_fm, lr_tc, lr_prog, lr_cls, lr_dtel, lr_ttyp.

    " --- repository ADB (sistem ini = S/4)
    IF lr_tab IS NOT INITIAL.
      SELECT tabname, tabclass, viewref FROM dd02l
        WHERE tabname IN @lr_tab AND as4local = 'A' AND as4vers = '0000'
        INTO CORRESPONDING FIELDS OF TABLE @mt_tab.
    ENDIF.
    IF lt_ftab IS NOT INITIAL.
      SELECT tabname, fieldname, leng FROM dd03l
        FOR ALL ENTRIES IN @lt_ftab
        WHERE tabname = @lt_ftab-table_line AND as4local = 'A' AND as4vers = '0000'
          AND fieldname NOT LIKE '.%'
        INTO CORRESPONDING FIELDS OF TABLE @mt_fld.
    ENDIF.
    IF lr_fm IS NOT INITIAL.
      SELECT funcname FROM tfdir WHERE funcname IN @lr_fm INTO TABLE @mt_fm.
    ENDIF.
    IF lr_tc IS NOT INITIAL.
      SELECT tcode FROM tstc WHERE tcode IN @lr_tc INTO TABLE @mt_tc.
    ENDIF.
    IF lr_prog IS NOT INITIAL.
      SELECT name FROM trdir WHERE name IN @lr_prog INTO TABLE @mt_prog.
    ENDIF.
    IF lr_cls IS NOT INITIAL.
      SELECT clsname FROM seoclass WHERE clsname IN @lr_cls INTO TABLE @mt_cls.
    ENDIF.
    IF lr_dtel IS NOT INITIAL.
      SELECT rollname FROM dd04l WHERE rollname IN @lr_dtel AND as4local = 'A'
        INTO TABLE @lt_dtel.
      LOOP AT lt_dtel INTO DATA(lv_dtel).
        INSERT CONV ty_name( lv_dtel ) INTO TABLE mt_typ.
      ENDLOOP.
    ENDIF.
    IF lr_ttyp IS NOT INITIAL.
      SELECT typename FROM dd40l WHERE typename IN @lr_ttyp AND as4local = 'A'
        INTO TABLE @lt_ttyp.
      LOOP AT lt_ttyp INTO DATA(lv_ttyp).
        INSERT CONV ty_name( lv_ttyp ) INTO TABLE mt_typ.
      ENDLOOP.
    ENDIF.

    " --- repository ECC (opsional, via RFC destination)
    IF mv_dest IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT lr_tab INTO DATA(ls_rtab).
      lt_rows = ecc_read( iv_table  = 'DD02L'
                          iv_where  = |TABNAME = '{ ls_rtab-low }' AND AS4LOCAL = 'A'|
                          it_fields = VALUE #( ( `TABNAME` ) ( `TABCLASS` ) ) ).
      LOOP AT lt_rows INTO DATA(lv_row).
        SPLIT lv_row AT '|' INTO DATA(lv_tn) DATA(lv_tc).
        INSERT VALUE #( tabname = condense( lv_tn ) tabclass = condense( lv_tc ) )
               INTO TABLE mt_etab.
      ENDLOOP.
    ENDLOOP.
    LOOP AT lt_ftab INTO DATA(lv_ftab).
      lt_rows = ecc_read( iv_table  = 'DD03L'
                          iv_where  = |TABNAME = '{ lv_ftab }' AND AS4LOCAL = 'A'|
                          it_fields = VALUE #( ( `FIELDNAME` ) ( `LENG` ) ) ).
      LOOP AT lt_rows INTO DATA(lv_frow).
        SPLIT lv_frow AT '|' INTO DATA(lv_fn) DATA(lv_fl).
        INSERT VALUE #( tabname = lv_ftab fieldname = condense( lv_fn )
                        leng = condense( lv_fl ) ) INTO TABLE mt_efld.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD ecc_read.
    DATA: lt_opt TYPE STANDARD TABLE OF rfc_db_opt WITH EMPTY KEY,
          lt_fld TYPE STANDARD TABLE OF rfc_db_fld WITH EMPTY KEY,
          lt_dat TYPE STANDARD TABLE OF tab512 WITH EMPTY KEY,
          lv_msg TYPE c LENGTH 200.

    lt_opt = VALUE #( ( text = iv_where ) ).
    lt_fld = VALUE #( FOR lv_f IN it_fields ( fieldname = lv_f ) ).
    CALL FUNCTION 'RFC_READ_TABLE'
      DESTINATION mv_dest
      EXPORTING
        query_table           = iv_table
        delimiter             = '|'
      TABLES
        options               = lt_opt
        fields                = lt_fld
        data                  = lt_dat
      EXCEPTIONS
        system_failure        = 1 MESSAGE lv_msg
        communication_failure = 2 MESSAGE lv_msg
        OTHERS                = 3.
    IF sy-subrc = 0.
      rt_rows = VALUE #( FOR ls_dat IN lt_dat ( CONV string( ls_dat-wa ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD add.
    APPEND VALUE #( main = iv_main unit = is_ref-unit line = is_ref-line layer = 'L1'
                    severity = iv_sev code = iv_code ref_obj = iv_obj
                    detail = iv_detail action = iv_action ) TO ct_find.
  ENDMETHOD.

  METHOD add_missing_z.
    add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'I' iv_code = 'L1_MISSING_Z'
                   iv_obj = iv_obj
                   iv_detail = |Objek custom { iv_obj } belum ada di ADB|
                   iv_action = `Bawa objek/DDIC Z ke ADB (F0b) lalu scan ulang`
         CHANGING  ct_find = ct_find ).
  ENDMETHOD.

  METHOD evaluate.
    DATA(lv_name) = to_upper( is_ref-name ).
    DATA(lv_z)    = lcl_util=>is_custom( lv_name ).

    CASE is_ref-kind.

      WHEN 'TABR' OR 'TABW' OR 'TABS'.
        DATA(lv_write) = xsdbool( is_ref-kind = 'TABW' ).
        READ TABLE mt_tab  INTO DATA(ls_t) WITH KEY tabname = lv_name.
        DATA(lv_adb) = xsdbool( sy-subrc = 0 ).
        READ TABLE mt_etab INTO DATA(ls_e) WITH KEY tabname = lv_name.
        DATA(lv_ecc) = xsdbool( sy-subrc = 0 ).

        IF lv_adb = abap_false.
          " tulis ke nama yang tidak dikenal = kemungkinan internal table
          IF lv_write = abap_true AND lv_ecc = abap_false.
            RETURN.
          ENDIF.
          IF lv_z = abap_true.
            add_missing_z( EXPORTING is_ref = is_ref iv_main = iv_main iv_obj = lv_name
                           CHANGING  ct_find = ct_find ).
          ELSE.
            add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'E'
                           iv_code = 'L1_TAB_REMOVED' iv_obj = lv_name
                           iv_detail = |Tabel/view { lv_name } tidak ada di S/4HANA|
                           iv_action = `Cari pengganti di Simplification List / CDS view`
                 CHANGING  ct_find = ct_find ).
          ENDIF.
          RETURN.
        ENDIF.

        " struktur (bukan tabel DB): abaikan
        IF ls_t-tabclass <> 'TRANSP' AND ls_t-tabclass <> 'VIEW'
           AND ls_t-tabclass <> 'CLUSTER' AND ls_t-tabclass <> 'POOL'.
          RETURN.
        ENDIF.

        IF ls_t-viewref IS NOT INITIAL AND is_ref-kind <> 'TABS'.
          IF lv_write = abap_true.
            add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'E'
                           iv_code = 'L1_TAB_REPLACED_WRITE' iv_obj = lv_name
                           iv_detail = |Tulis langsung ke { lv_name } (replacement object { ls_t-viewref }) tidak didukung di S/4|
                           iv_action = `Ganti dengan BAPI/API standar`
                 CHANGING  ct_find = ct_find ).
          ELSE.
            add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'W'
                           iv_code = 'L1_TAB_REPLACED_READ' iv_obj = lv_name
                           iv_detail = |{ lv_name } dibaca lewat replacement object { ls_t-viewref }|
                           iv_action = `Masih jalan; cek performa, pertimbangkan tabel/CDS baru`
                 CHANGING  ct_find = ct_find ).
          ENDIF.
        ELSEIF ls_t-tabclass = 'VIEW'
           AND ( lv_write = abap_true OR ( lv_ecc = abap_true AND ls_e-tabclass <> 'VIEW' ) ).
          add( EXPORTING is_ref = is_ref iv_main = iv_main
                         iv_sev = COND #( WHEN lv_write = abap_true THEN 'E' ELSE 'W' )
                         iv_code = COND string( WHEN lv_write = abap_true THEN `L1_TAB_VIEW_WRITE`
                                                ELSE `L1_TAB_NOW_VIEW` )
                         iv_obj = lv_name
                         iv_detail = |{ lv_name } di S/4 berupa VIEW (compatibility view)|
                         iv_action = COND #( WHEN lv_write = abap_true
                                             THEN `Tulis ke view tidak bisa: pakai tabel/BAPI pengganti`
                                             ELSE `Baca masih jalan; cek performa, pertimbangkan tabel baru` )
               CHANGING  ct_find = ct_find ).
        ENDIF.

        IF lv_ecc = abap_true AND ( ls_e-tabclass = 'CLUSTER' OR ls_e-tabclass = 'POOL' )
           AND ls_t-tabclass = 'TRANSP' AND is_ref-kind = 'TABR'.
          add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'W'
                         iv_code = 'L1_EX_POOL_CLUSTER' iv_obj = lv_name
                         iv_detail = |{ lv_name } dulu { ls_e-tabclass } di ECC, sekarang transparan|
                         iv_action = `Hasil SELECT tidak lagi otomatis urut: tambah ORDER BY bila perlu`
               CHANGING  ct_find = ct_find ).
        ENDIF.

      WHEN 'FLD'.
        DATA(lv_fld) = to_upper( is_ref-sub ).
        READ TABLE mt_tab INTO DATA(ls_ft) WITH KEY tabname = lv_name.
        IF sy-subrc <> 0.
          IF lv_z = abap_true.
            add_missing_z( EXPORTING is_ref = is_ref iv_main = iv_main iv_obj = lv_name
                           CHANGING  ct_find = ct_find ).
          ENDIF.
          RETURN.
        ENDIF.
        READ TABLE mt_fld INTO DATA(ls_f) WITH KEY tabname = lv_name fieldname = lv_fld.
        IF sy-subrc <> 0.
          IF ls_ft-tabclass <> 'VIEW'.
            add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'E'
                           iv_code = 'L1_FIELD_MISSING' iv_obj = |{ lv_name }-{ lv_fld }|
                           iv_detail = |Field { lv_name }-{ lv_fld } tidak ada di S/4|
                           iv_action = `Cari field/tabel pengganti`
                 CHANGING  ct_find = ct_find ).
          ENDIF.
          RETURN.
        ENDIF.
        READ TABLE mt_efld INTO DATA(ls_ef) WITH KEY tabname = lv_name fieldname = lv_fld.
        IF sy-subrc = 0 AND ls_ef-leng <> ls_f-leng.
          add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'W'
                         iv_code = 'L1_FIELD_LENGTH' iv_obj = |{ lv_name }-{ lv_fld }|
                         iv_detail = |Panjang { lv_name }-{ lv_fld } berubah: ECC { ls_ef-leng ALPHA = OUT } -> S/4 { ls_f-leng ALPHA = OUT }|
                         iv_action = `Cek variabel penampung, offset/length, CONCATENATE, WRITE TO`
               CHANGING  ct_find = ct_find ).
        ENDIF.

      WHEN 'FM' OR 'TCODE' OR 'PROG' OR 'CLAS'.
        DATA(lv_found) = SWITCH abap_bool( is_ref-kind
          WHEN 'FM'    THEN xsdbool( line_exists( mt_fm[ table_line = lv_name ] ) )
          WHEN 'TCODE' THEN xsdbool( line_exists( mt_tc[ table_line = lv_name ] ) )
          WHEN 'PROG'  THEN xsdbool( line_exists( mt_prog[ table_line = lv_name ] ) )
          WHEN 'CLAS'  THEN xsdbool( line_exists( mt_cls[ table_line = lv_name ] ) ) ).
        IF lv_found = abap_true.
          RETURN.
        ENDIF.
        IF lv_z = abap_true.
          add_missing_z( EXPORTING is_ref = is_ref iv_main = iv_main iv_obj = lv_name
                         CHANGING  ct_find = ct_find ).
        ELSE.
          DATA(lv_what) = SWITCH string( is_ref-kind
            WHEN 'FM' THEN `Function module` WHEN 'TCODE' THEN `T-code`
            WHEN 'PROG' THEN `Program` ELSE `Class/interface` ).
          add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'E'
                         iv_code = |L1_{ is_ref-kind }_MISSING| iv_obj = lv_name
                         iv_detail = |{ lv_what } { lv_name } tidak ada di S/4HANA|
                         iv_action = `Cari pengganti (Simplification List / API baru)`
               CHANGING  ct_find = ct_find ).
        ENDIF.

      WHEN 'ZTYP'.
        IF NOT ( line_exists( mt_typ[ table_line = lv_name ] )
              OR line_exists( mt_cls[ table_line = lv_name ] )
              OR line_exists( mt_tab[ tabname = lv_name ] ) ).
          add_missing_z( EXPORTING is_ref = is_ref iv_main = iv_main iv_obj = lv_name
                         CHANGING  ct_find = ct_find ).
        ENDIF.

      WHEN 'NSQL'.
        add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'W'
                       iv_code = 'L1_NATIVE_SQL' iv_obj = 'EXEC SQL'
                       iv_detail = `Native SQL: sintaks DB lama (Oracle) bisa tidak valid di HANA`
                       iv_action = `Ubah ke Open SQL, atau sesuaikan ke HANA SQL / AMDP`
             CHANGING  ct_find = ct_find ).

      WHEN 'HINT'.
        add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'W'
                       iv_code = 'L1_DB_HINT' iv_obj = |%_HINTS { is_ref-sub }|
                       iv_detail = `Database hint untuk DB lama tidak berlaku di HANA`
                       iv_action = `Hapus hint (kandidat fix otomatis kelas A)`
             CHANGING  ct_find = ct_find ).

      WHEN 'DYN'.
        add( EXPORTING is_ref = is_ref iv_main = iv_main iv_sev = 'I'
                       iv_code = 'L1_DYNAMIC' iv_obj = lv_name
                       iv_detail = |{ is_ref-sub } dinamis ({ lv_name }), tidak bisa dicek statis|
                       iv_action = `Periksa manual nilai variabelnya`
             CHANGING  ct_find = ct_find ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* L2: syntax check source (include digabung) dengan compiler S/4
*----------------------------------------------------------------------*
CLASS lcl_syntax DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING io_src TYPE REF TO lcl_source.
    METHODS check
      IMPORTING iv_main        TYPE progname
      RETURNING VALUE(rt_find) TYPE tt_find.
  PRIVATE SECTION.
    CONSTANTS c_max_errors TYPE i VALUE 80.
    DATA mo_src TYPE REF TO lcl_source.
    METHODS expand
      IMPORTING iv_name  TYPE progname
                iv_depth TYPE i
      CHANGING  ct_src   TYPE string_table
                ct_map   TYPE tt_map.
    METHODS comment_out
      IMPORTING iv_line TYPE i
      CHANGING  ct_src  TYPE string_table.
ENDCLASS.

CLASS lcl_syntax IMPLEMENTATION.

  METHOD constructor.
    mo_src = io_src.
  ENDMETHOD.

  METHOD expand.
    IF iv_depth > 20.
      RETURN.
    ENDIF.
    DATA(lt_lines) = mo_src->lines_of( iv_name ).
    LOOP AT lt_lines INTO DATA(lv_line).
      DATA(lv_row) = sy-tabix.
      DATA(lv_inc) = lcl_util=>include_of( lv_line ).
      IF lv_inc IS NOT INITIAL AND mo_src->has( lv_inc ) = abap_true.
        APPEND |*>> INCLUDE { lv_inc }| TO ct_src.
        APPEND VALUE #( unit = iv_name line = lv_row ) TO ct_map.
        expand( EXPORTING iv_name = lv_inc iv_depth = iv_depth + 1
                CHANGING  ct_src = ct_src ct_map = ct_map ).
      ELSE.
        APPEND lv_line TO ct_src.
        APPEND VALUE #( unit = iv_name line = lv_row ) TO ct_map.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD comment_out.
    " jadikan komentar seluruh kalimat yang memuat baris error
    DATA(lv_max)  = lines( ct_src ).
    DATA(lv_from) = iv_line.
    WHILE lv_from > 1.
      DATA(lv_prev) = lcl_util=>code_part( ct_src[ lv_from - 1 ] ).
      IF lv_prev IS NOT INITIAL
         AND substring( val = lv_prev off = strlen( lv_prev ) - 1 len = 1 ) = '.'.
        EXIT.
      ENDIF.
      lv_from = lv_from - 1.
    ENDWHILE.
    DATA(lv_to) = iv_line.
    WHILE lv_to < lv_max.
      DATA(lv_cur) = lcl_util=>code_part( ct_src[ lv_to ] ).
      IF lv_cur IS NOT INITIAL
         AND substring( val = lv_cur off = strlen( lv_cur ) - 1 len = 1 ) = '.'.
        EXIT.
      ENDIF.
      lv_to = lv_to + 1.
    ENDWHILE.
    LOOP AT ct_src ASSIGNING FIELD-SYMBOL(<lv_src>) FROM lv_from TO lv_to.
      <lv_src> = |*{ <lv_src> }|.
    ENDLOOP.
  ENDMETHOD.

  METHOD check.
    DATA: lt_src  TYPE string_table,
          lt_map  TYPE tt_map,
          lv_msg  TYPE string,
          lv_line TYPE i,
          lv_word TYPE string,
          lv_last TYPE i VALUE -1.

    expand( EXPORTING iv_name = iv_main iv_depth = 0
            CHANGING  ct_src = lt_src ct_map = lt_map ).
    IF lt_src IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_dir) = VALUE trdir( name = 'ZS4CCA_SYNCHK' subc = '1'
                                uccheck = abap_true fixpt = abap_true ).
    DO c_max_errors TIMES.
      CLEAR: lv_msg, lv_line, lv_word.
      SYNTAX-CHECK FOR lt_src MESSAGE lv_msg LINE lv_line WORD lv_word
                   DIRECTORY ENTRY ls_dir.
      IF sy-subrc = 0 OR lv_line <= 0 OR lv_line > lines( lt_src ) OR lv_line = lv_last.
        EXIT.
      ENDIF.
      lv_last = lv_line.
      DATA(ls_map) = lt_map[ lv_line ].
      DATA(lv_is_z) = xsdbool( lv_word IS NOT INITIAL
                               AND lcl_util=>is_custom( lv_word ) = abap_true ).
      APPEND VALUE #( main = iv_main unit = ls_map-unit line = ls_map-line layer = 'L2'
                      severity = COND #( WHEN lv_is_z = abap_true THEN 'I' ELSE 'E' )
                      code     = COND #( WHEN lv_is_z = abap_true THEN 'L2_MISSING_Z'
                                         ELSE 'L2_SYNTAX' )
                      ref_obj  = lv_word
                      detail   = lv_msg
                      action   = COND #( WHEN lv_is_z = abap_true
                                         THEN `Objek Z belum ada di ADB: bawa DDIC/objek Z (F0b), scan ulang`
                                         ELSE `Error kompilasi di S/4: perbaiki kode sesuai pesan` ) )
             TO rt_find.
      comment_out( EXPORTING iv_line = lv_line CHANGING ct_src = lt_src ).
    ENDDO.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Runner: orkestrasi + tampilan ALV
*----------------------------------------------------------------------*
CLASS lcl_runner DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS run.
    METHODS display.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_owner,
             unit TYPE progname,
             main TYPE progname,
           END OF ty_owner,
           tt_owner TYPE HASHED TABLE OF ty_owner WITH UNIQUE KEY unit.
    DATA mo_src   TYPE REF TO lcl_source.
    DATA mt_find  TYPE tt_find.
    DATA mt_owner TYPE tt_owner.
    METHODS layer1.
    METHODS layer2.
    METHODS set_owner
      IMPORTING iv_unit  TYPE progname
                iv_main  TYPE progname
                iv_depth TYPE i.
    METHODS owner_of
      IMPORTING iv_unit        TYPE progname
      RETURNING VALUE(rv_main) TYPE progname.
    METHODS set_col
      IMPORTING io_cols TYPE REF TO cl_salv_columns_table
                iv_name TYPE lvc_fname
                iv_text TYPE string.
ENDCLASS.

CLASS lcl_runner IMPLEMENTATION.

  METHOD run.
    DATA lt_names TYPE STANDARD TABLE OF progname WITH EMPTY KEY.
    DATA(lv_mode) = COND ty_mode( WHEN rb_file = abap_true THEN 'FIL'
                                  WHEN rb_rfc  = abap_true THEN 'RFC'
                                  ELSE 'ADB' ).
    mo_src = NEW #( iv_mode = lv_mode iv_dest = p_dest ).

    CASE lv_mode.
      WHEN 'FIL'.
        mo_src->load_from_files( ).
      WHEN 'RFC'.
        LOOP AT s_prog INTO DATA(ls_prog) WHERE sign = 'I' AND option = 'EQ'.
          mo_src->load_program( iv_name = ls_prog-low iv_is_main = abap_true ).
        ENDLOOP.
      WHEN 'ADB'.
        SELECT name FROM trdir
          WHERE name IN @s_prog AND ( subc = '1' OR subc = 'M' )
          INTO TABLE @lt_names UP TO 500 ROWS.
        LOOP AT lt_names INTO DATA(lv_name).
          mo_src->load_program( iv_name = lv_name iv_is_main = abap_true ).
        ENDLOOP.
    ENDCASE.

    IF mo_src->mt_units IS INITIAL.
      MESSAGE 'Tidak ada source yang terbaca' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LOOP AT mo_src->mt_mains INTO DATA(lv_main).
      set_owner( iv_unit = CONV #( lv_main ) iv_main = CONV #( lv_main ) iv_depth = 0 ).
    ENDLOOP.

    IF p_l1 = abap_true.
      layer1( ).
    ENDIF.
    IF p_l2 = abap_true.
      layer2( ).
    ENDIF.

    " include/program yang dirujuk tapi tidak ada di sumber
    LOOP AT mo_src->mt_missing INTO DATA(lv_miss).
      APPEND VALUE #( unit = CONV #( lv_miss ) layer = 'L1' severity = 'W'
                      code = 'L1_SOURCE_MISSING' ref_obj = lv_miss
                      detail = |Source { lv_miss } tidak ditemukan di sumber yang dipilih|
                      action = `Masukkan ke daftar missing objects (deliverable)` ) TO mt_find.
    ENDLOOP.

    SORT mt_find BY main unit line layer code ref_obj.
    DELETE ADJACENT DUPLICATES FROM mt_find COMPARING main unit line layer code ref_obj.
  ENDMETHOD.

  METHOD set_owner.
    IF iv_depth > 20 OR line_exists( mt_owner[ unit = iv_unit ] ).
      RETURN.
    ENDIF.
    INSERT VALUE #( unit = iv_unit main = iv_main ) INTO TABLE mt_owner.
    DATA(lt_lines) = mo_src->lines_of( iv_unit ).
    LOOP AT lt_lines INTO DATA(lv_line).
      DATA(lv_inc) = lcl_util=>include_of( lv_line ).
      IF lv_inc IS NOT INITIAL AND mo_src->has( lv_inc ) = abap_true.
        set_owner( iv_unit = lv_inc iv_main = iv_main iv_depth = iv_depth + 1 ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD owner_of.
    READ TABLE mt_owner INTO DATA(ls_owner) WITH TABLE KEY unit = iv_unit.
    IF sy-subrc = 0.
      rv_main = ls_owner-main.
    ENDIF.
  ENDMETHOD.

  METHOD layer1.
    DATA: lt_ref   TYPE tt_ref,
          lt_one   TYPE tt_ref,
          lt_local TYPE string_table.

    LOOP AT mo_src->mt_units INTO DATA(ls_unit).
      lt_one = lcl_scan=>scan( iv_unit = ls_unit-name it_lines = ls_unit-lines ).
      APPEND LINES OF lt_one TO lt_ref.
    ENDLOOP.

    " class/interface lokal tidak dicek ke repository
    LOOP AT lt_ref INTO DATA(ls_local) WHERE kind = 'LCLS'.
      APPEND ls_local-name TO lt_local.
    ENDLOOP.
    LOOP AT lt_local INTO DATA(lv_local).
      DELETE lt_ref WHERE kind = 'CLAS' AND name = lv_local.
    ENDLOOP.
    DELETE lt_ref WHERE kind = 'LCLS'.
    DELETE lt_ref WHERE kind = 'CLAS' AND ( name CP 'LCL*' OR name CP 'LIF*' ).

    DATA(lo_ddic) = NEW lcl_ddic( p_dest ).
    lo_ddic->load( lt_ref ).
    LOOP AT lt_ref INTO DATA(ls_ref).
      lo_ddic->evaluate( EXPORTING is_ref = ls_ref iv_main = owner_of( ls_ref-unit )
                         CHANGING  ct_find = mt_find ).
    ENDLOOP.
  ENDMETHOD.

  METHOD layer2.
    DATA lt_one TYPE tt_find.
    DATA(lo_syn) = NEW lcl_syntax( mo_src ).
    LOOP AT mo_src->mt_mains INTO DATA(lv_main).
      lt_one = lo_syn->check( CONV #( lv_main ) ).
      APPEND LINES OF lt_one TO mt_find.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_col.
    TRY.
        DATA(lo_col) = io_cols->get_column( iv_name ).
        lo_col->set_short_text( CONV #( iv_text ) ).
        lo_col->set_medium_text( CONV #( iv_text ) ).
        lo_col->set_long_text( CONV #( iv_text ) ).
      CATCH cx_salv_not_found ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD display.
    IF mt_find IS INITIAL.
      MESSAGE 'Tidak ada temuan' TYPE 'S'.
      RETURN.
    ENDIF.
    gt_find = mt_find.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_alv)
                                CHANGING  t_table      = gt_find ).
        lo_alv->get_functions( )->set_all( abap_true ).
        DATA(lo_cols) = lo_alv->get_columns( ).
        lo_cols->set_optimize( abap_true ).
        set_col( io_cols = lo_cols iv_name = 'MAIN'     iv_text = `Program utama` ).
        set_col( io_cols = lo_cols iv_name = 'UNIT'     iv_text = `Include/unit` ).
        set_col( io_cols = lo_cols iv_name = 'LINE'     iv_text = `Baris` ).
        set_col( io_cols = lo_cols iv_name = 'LAYER'    iv_text = `Lapis` ).
        set_col( io_cols = lo_cols iv_name = 'SEVERITY' iv_text = `Sev` ).
        set_col( io_cols = lo_cols iv_name = 'CODE'     iv_text = `Kode temuan` ).
        set_col( io_cols = lo_cols iv_name = 'REF_OBJ'  iv_text = `Objek dirujuk` ).
        set_col( io_cols = lo_cols iv_name = 'DETAIL'   iv_text = `Detail` ).
        set_col( io_cols = lo_cols iv_name = 'ACTION'   iv_text = `Saran tindakan` ).
        lo_alv->get_display_settings( )->set_list_header(
          CONV #( |ZS4CCA - { lines( gt_find ) } temuan (L1 diff DDIC, L2 syntax S/4)| ) ).
        lo_alv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_salv).
        MESSAGE lx_salv TYPE 'I'.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
