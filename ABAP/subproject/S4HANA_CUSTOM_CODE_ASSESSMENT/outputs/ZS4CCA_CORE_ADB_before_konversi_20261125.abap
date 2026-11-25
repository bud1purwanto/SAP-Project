*&---------------------------------------------------------------------*
*& Include ZS4CCA_CORE
*& Local class tool ZS4CCA (F1): ambil source, scan referensi,
*& L1 diff DDIC (ADB vs ECC opsional), L2 syntax check S/4, ALV.
*& Hanya membaca. Tidak menulis ke sistem mana pun.
*&---------------------------------------------------------------------*

CLASS LCL_UTIL DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS IS_CUSTOM
      IMPORTING IV_NAME      TYPE CSEQUENCE
      RETURNING VALUE(RV_YES) TYPE ABAP_BOOL.
    CLASS-METHODS INCLUDE_OF
      IMPORTING IV_LINE        TYPE STRING
      RETURNING VALUE(RV_NAME) TYPE PROGNAME.
    CLASS-METHODS IS_MAIN
      IMPORTING IT_LINES      TYPE STRING_TABLE
      RETURNING VALUE(RV_YES) TYPE ABAP_BOOL.
    CLASS-METHODS UNQUOTE
      IMPORTING IV_TOKEN       TYPE STRING
      RETURNING VALUE(RV_TEXT) TYPE STRING.
    CLASS-METHODS CODE_PART
      IMPORTING IV_LINE        TYPE STRING
      RETURNING VALUE(RV_CODE) TYPE STRING.
    CLASS-METHODS IS_LITERAL
      IMPORTING IV_TOKEN      TYPE STRING
      RETURNING VALUE(RV_YES) TYPE ABAP_BOOL.
ENDCLASS.

CLASS LCL_UTIL IMPLEMENTATION.

  METHOD IS_CUSTOM.
    DATA(LV_NAME) = TO_UPPER( CONDENSE( IV_NAME ) ).
    RV_YES = XSDBOOL( LV_NAME CP 'Z*' OR LV_NAME CP 'Y*' ).
  ENDMETHOD.

  METHOD INCLUDE_OF.
    DATA LV_NAME TYPE STRING.
    DATA(LV_LINE) = TO_UPPER( IV_LINE ).
    FIND FIRST OCCURRENCE OF REGEX `^\s*INCLUDE\s+([A-Z0-9_/]+)\s*(IF\s+FOUND\s*)?\.`
         IN LV_LINE SUBMATCHES LV_NAME.
    IF SY-SUBRC = 0 AND LV_NAME <> 'STRUCTURE' AND LV_NAME <> 'TYPE'.
      RV_NAME = LV_NAME.
    ENDIF.
  ENDMETHOD.

  METHOD IS_MAIN.
    LOOP AT IT_LINES INTO DATA(LV_LINE).
      DATA(LV_CODE) = TO_UPPER( CODE_PART( LV_LINE ) ).
      IF LV_CODE IS INITIAL.
        CONTINUE.
      ENDIF.
      RV_YES = XSDBOOL( LV_CODE CP 'REPORT*' OR LV_CODE CP 'PROGRAM*'
                     OR LV_CODE CP 'FUNCTION-POOL*' ).
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD UNQUOTE.
    RV_TEXT = IV_TOKEN.
    DATA(LV_LEN) = STRLEN( RV_TEXT ).
    IF LV_LEN >= 2 AND IS_LITERAL( RV_TEXT ) = ABAP_TRUE.
      RV_TEXT = SUBSTRING( VAL = RV_TEXT OFF = 1 LEN = LV_LEN - 2 ).
    ENDIF.
    RV_TEXT = TO_UPPER( RV_TEXT ).
  ENDMETHOD.

  METHOD IS_LITERAL.
    IF IV_TOKEN IS INITIAL.
      RETURN.
    ENDIF.
    DATA(LV_FIRST) = SUBSTRING( VAL = IV_TOKEN OFF = 0 LEN = 1 ).
    RV_YES = XSDBOOL( LV_FIRST = `'` OR LV_FIRST = '`' ).
  ENDMETHOD.

  METHOD CODE_PART.
    " Bagian kode tanpa komentar (* di kolom 1 atau " di akhir baris)
    IF IV_LINE IS INITIAL.
      RETURN.
    ENDIF.
    IF SUBSTRING( VAL = IV_LINE OFF = 0 LEN = 1 ) = '*'.
      RETURN.
    ENDIF.
    DATA LV_OFF TYPE I.
    RV_CODE = IV_LINE.
    FIND FIRST OCCURRENCE OF '"' IN RV_CODE MATCH OFFSET LV_OFF.
    IF SY-SUBRC = 0.
      RV_CODE = SUBSTRING( VAL = RV_CODE OFF = 0 LEN = LV_OFF ).
    ENDIF.
    CONDENSE RV_CODE.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Sumber source: file upload (baseline Alfa), RFC ECC, atau ADB lokal
*----------------------------------------------------------------------*
CLASS LCL_SOURCE DEFINITION FINAL.
  PUBLIC SECTION.
    DATA MT_UNITS   TYPE TT_UNIT READ-ONLY.
    DATA MT_MAINS   TYPE STRING_TABLE READ-ONLY.
    DATA MT_MISSING TYPE STRING_TABLE READ-ONLY.
    METHODS CONSTRUCTOR
      IMPORTING IV_MODE TYPE TY_MODE
                IV_DEST TYPE RFCDEST OPTIONAL.
    METHODS LOAD_FROM_FILES.
    METHODS LOAD_PROGRAM
      IMPORTING IV_NAME    TYPE PROGNAME
                IV_IS_MAIN TYPE ABAP_BOOL DEFAULT ABAP_FALSE.
    METHODS LINES_OF
      IMPORTING IV_NAME         TYPE PROGNAME
      RETURNING VALUE(RT_LINES) TYPE STRING_TABLE.
    METHODS HAS
      IMPORTING IV_NAME       TYPE PROGNAME
      RETURNING VALUE(RV_YES) TYPE ABAP_BOOL.
  PRIVATE SECTION.
    DATA MV_MODE TYPE TY_MODE.
    DATA MV_DEST TYPE RFCDEST.
    METHODS FETCH
      IMPORTING IV_NAME         TYPE PROGNAME
      RETURNING VALUE(RT_LINES) TYPE STRING_TABLE.
    METHODS ADD_MISSING
      IMPORTING IV_NAME TYPE CSEQUENCE.
ENDCLASS.

CLASS LCL_SOURCE IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    MV_MODE = IV_MODE.
    MV_DEST = IV_DEST.
  ENDMETHOD.

  METHOD HAS.
    RV_YES = XSDBOOL( LINE_EXISTS( MT_UNITS[ NAME = IV_NAME ] ) ).
  ENDMETHOD.

  METHOD LINES_OF.
    READ TABLE MT_UNITS INTO DATA(LS_UNIT) WITH TABLE KEY NAME = IV_NAME.
    IF SY-SUBRC = 0.
      RT_LINES = LS_UNIT-LINES.
    ENDIF.
  ENDMETHOD.

  METHOD ADD_MISSING.
    DATA(LV_NAME) = TO_UPPER( CONV STRING( IV_NAME ) ).
    IF NOT LINE_EXISTS( MT_MISSING[ TABLE_LINE = LV_NAME ] ).
      APPEND LV_NAME TO MT_MISSING.
    ENDIF.
  ENDMETHOD.

  METHOD LOAD_FROM_FILES.
    DATA: LT_FILES TYPE FILETABLE,
          LT_LINES TYPE STRING_TABLE,
          LV_RC    TYPE I,
          LV_ACT   TYPE I,
          LV_OFF   TYPE I.

    CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG(
      EXPORTING
        WINDOW_TITLE            = 'Pilih file .abap (program utama + include)'
        FILE_FILTER             = 'ABAP (*.abap;*.txt)|*.abap;*.txt|Semua (*.*)|*.*'
        MULTISELECTION          = ABAP_TRUE
      CHANGING
        FILE_TABLE              = LT_FILES
        RC                      = LV_RC
        USER_ACTION             = LV_ACT
      EXCEPTIONS
        OTHERS                  = 1 ).
    IF SY-SUBRC <> 0 OR LV_ACT <> CL_GUI_FRONTEND_SERVICES=>ACTION_OK.
      RETURN.
    ENDIF.

    DATA(LV_BOM) = CL_ABAP_CONV_IN_CE=>UCCP( 'FEFF' ).

    LOOP AT LT_FILES INTO DATA(LS_FILE).
      DATA(LV_PATH) = CONV STRING( LS_FILE-FILENAME ).
      CLEAR LT_LINES.
      CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD(
        EXPORTING
          FILENAME = LV_PATH
          FILETYPE = 'ASC'
          CODEPAGE = '4110'
        CHANGING
          DATA_TAB = LT_LINES
        EXCEPTIONS
          OTHERS   = 1 ).
      IF SY-SUBRC <> 0.
        CONTINUE.
      ENDIF.
      " buang BOM UTF-8 di baris pertama
      IF LT_LINES IS NOT INITIAL.
        ASSIGN LT_LINES[ 1 ] TO FIELD-SYMBOL(<LV_FIRST>).
        IF STRLEN( <LV_FIRST> ) > 0 AND SUBSTRING( VAL = <LV_FIRST> OFF = 0 LEN = 1 ) = LV_BOM.
          <LV_FIRST> = SUBSTRING( VAL = <LV_FIRST> OFF = 1 ).
        ENDIF.
      ENDIF.
      " nama unit = nama file tanpa folder dan ekstensi
      DATA(LV_BASE) = LV_PATH.
      FIND ALL OCCURRENCES OF REGEX `[\\/]` IN LV_BASE MATCH OFFSET LV_OFF.
      IF SY-SUBRC = 0.
        LV_BASE = SUBSTRING( VAL = LV_BASE OFF = LV_OFF + 1 ).
      ENDIF.
      LV_BASE = TO_UPPER( REPLACE( VAL = LV_BASE REGEX = `\.[^.]*$` WITH = `` ) ).
      INSERT VALUE #( NAME = CONV #( LV_BASE ) LINES = LT_LINES ) INTO TABLE MT_UNITS.
      IF SY-SUBRC = 0 AND LCL_UTIL=>IS_MAIN( LT_LINES ) = ABAP_TRUE.
        APPEND LV_BASE TO MT_MAINS.
      ENDIF.
    ENDLOOP.

    " INCLUDE Z yang dirujuk tapi filenya tidak ikut
    LOOP AT MT_UNITS INTO DATA(LS_UNIT).
      LOOP AT LS_UNIT-LINES INTO DATA(LV_LINE).
        DATA(LV_INC) = LCL_UTIL=>INCLUDE_OF( LV_LINE ).
        IF LV_INC IS NOT INITIAL AND LCL_UTIL=>IS_CUSTOM( LV_INC ) = ABAP_TRUE
           AND HAS( LV_INC ) = ABAP_FALSE.
          ADD_MISSING( LV_INC ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD LOAD_PROGRAM.
    IF HAS( IV_NAME ) = ABAP_TRUE.
      RETURN.
    ENDIF.
    DATA(LT_LINES) = FETCH( IV_NAME ).
    IF LT_LINES IS INITIAL.
      ADD_MISSING( IV_NAME ).
      RETURN.
    ENDIF.
    INSERT VALUE #( NAME = IV_NAME LINES = LT_LINES ) INTO TABLE MT_UNITS.
    IF IV_IS_MAIN = ABAP_TRUE.
      APPEND CONV STRING( IV_NAME ) TO MT_MAINS.
    ENDIF.
    " include custom ikut dibaca (rekursif)
    LOOP AT LT_LINES INTO DATA(LV_LINE).
      DATA(LV_INC) = LCL_UTIL=>INCLUDE_OF( LV_LINE ).
      IF LV_INC IS NOT INITIAL AND LCL_UTIL=>IS_CUSTOM( LV_INC ) = ABAP_TRUE.
        LOAD_PROGRAM( LV_INC ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD FETCH.
    DATA: LT_SRC TYPE STANDARD TABLE OF ABAPTXT255 WITH EMPTY KEY,
          LV_MSG TYPE C LENGTH 200.

    CASE MV_MODE.
      WHEN 'ADB'.
        " versi inactive dulu (program salinan yang belum bisa diaktifkan)
        READ REPORT IV_NAME INTO LT_SRC STATE 'I'.
        IF SY-SUBRC <> 0.
          READ REPORT IV_NAME INTO LT_SRC.
          IF SY-SUBRC <> 0.
            CLEAR LT_SRC.
          ENDIF.
        ENDIF.
      WHEN 'RFC'.
        CALL FUNCTION 'RPY_PROGRAM_READ'
          DESTINATION MV_DEST
          EXPORTING
            PROGRAM_NAME          = IV_NAME
            WITH_INCLUDELIST      = ABAP_FALSE
            ONLY_SOURCE           = ABAP_TRUE
            WITH_LOWERCASE        = ABAP_TRUE
          TABLES
            SOURCE_EXTENDED       = LT_SRC
          EXCEPTIONS
            CANCELLED             = 1
            NOT_FOUND             = 2
            PERMISSION_ERROR      = 3
            SYSTEM_FAILURE        = 4 MESSAGE LV_MSG
            COMMUNICATION_FAILURE = 5 MESSAGE LV_MSG
            OTHERS                = 6.
        IF SY-SUBRC <> 0.
          CLEAR LT_SRC.
        ENDIF.
    ENDCASE.

    RT_LINES = VALUE #( FOR LS_SRC IN LT_SRC ( CONV STRING( LS_SRC-LINE ) ) ).
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Scanner: token resmi ABAP (SCAN ABAP-SOURCE) -> referensi objek
*----------------------------------------------------------------------*
CLASS LCL_SCAN DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS SCAN
      IMPORTING IV_UNIT       TYPE PROGNAME
                IT_LINES      TYPE STRING_TABLE
      RETURNING VALUE(RT_REF) TYPE TT_REF.
  PRIVATE SECTION.
    CLASS-METHODS ADD
      IMPORTING IV_UNIT TYPE PROGNAME
                IV_LINE TYPE I
                IV_KIND TYPE CSEQUENCE
                IV_NAME TYPE CSEQUENCE
                IV_SUB  TYPE CSEQUENCE OPTIONAL
      CHANGING  CT_REF  TYPE TT_REF.
    CLASS-METHODS ADD_TABLE
      IMPORTING IV_UNIT  TYPE PROGNAME
                IV_LINE  TYPE I
                IV_KIND  TYPE CSEQUENCE
                IV_TOKEN TYPE STRING
      CHANGING  CT_REF   TYPE TT_REF.
    CLASS-METHODS ADD_TYPE
      IMPORTING IV_UNIT  TYPE PROGNAME
                IV_LINE  TYPE I
                IV_TOKEN TYPE STRING
      CHANGING  CT_REF   TYPE TT_REF.
ENDCLASS.

CLASS LCL_SCAN IMPLEMENTATION.

  METHOD ADD.
    IF IV_NAME IS INITIAL.
      RETURN.
    ENDIF.
    APPEND VALUE #( UNIT = IV_UNIT LINE = IV_LINE KIND = IV_KIND
                    NAME = TO_UPPER( CONV STRING( IV_NAME ) )
                    SUB  = TO_UPPER( CONV STRING( IV_SUB ) ) ) TO CT_REF.
  ENDMETHOD.

  METHOD ADD_TABLE.
    " nama tabel setelah FROM/JOIN/UPDATE/...; (x) = dinamis
    DATA(LV_NAME) = IV_TOKEN.
    IF LV_NAME IS INITIAL OR LCL_UTIL=>IS_LITERAL( LV_NAME ) = ABAP_TRUE.
      RETURN.
    ENDIF.
    IF SUBSTRING( VAL = LV_NAME OFF = 0 LEN = 1 ) = '('.
      ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = IV_LINE IV_KIND = 'DYN'
                     IV_NAME = LV_NAME IV_SUB = 'TABEL DINAMIS'
           CHANGING  CT_REF = CT_REF ).
      RETURN.
    ENDIF.
    IF SUBSTRING( VAL = LV_NAME OFF = 0 LEN = 1 ) = '*'.
      LV_NAME = SUBSTRING( VAL = LV_NAME OFF = 1 ).
    ENDIF.
    ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = IV_LINE IV_KIND = IV_KIND IV_NAME = LV_NAME
         CHANGING  CT_REF = CT_REF ).
  ENDMETHOD.

  METHOD ADD_TYPE.
    " TYPE/LIKE x-y -> field DDIC ; TYPE zxxx -> tipe custom
    DATA: LV_TAB  TYPE STRING,
          LV_FLD  TYPE STRING,
          LV_REST TYPE STRING ##NEEDED.
    IF IV_TOKEN IS INITIAL OR LCL_UTIL=>IS_LITERAL( IV_TOKEN ) = ABAP_TRUE
       OR SUBSTRING( VAL = IV_TOKEN OFF = 0 LEN = 1 ) = '('.
      RETURN.
    ENDIF.
    IF IV_TOKEN CS '-'.
      SPLIT IV_TOKEN AT '-' INTO LV_TAB LV_FLD LV_REST.
      IF LV_TAB IS NOT INITIAL AND LV_FLD IS NOT INITIAL.
        ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = IV_LINE IV_KIND = 'FLD'
                       IV_NAME = LV_TAB IV_SUB = LV_FLD
             CHANGING  CT_REF = CT_REF ).
      ENDIF.
    ELSEIF LCL_UTIL=>IS_CUSTOM( IV_TOKEN ) = ABAP_TRUE.
      ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = IV_LINE IV_KIND = 'ZTYP' IV_NAME = IV_TOKEN
           CHANGING  CT_REF = CT_REF ).
    ENDIF.
  ENDMETHOD.

  METHOD SCAN.
    DATA: LT_TOK   TYPE STANDARD TABLE OF STOKES WITH EMPTY KEY,
          LT_STM   TYPE STANDARD TABLE OF SSTMNT WITH EMPTY KEY,
          LT_T     TYPE STRING_TABLE,
          LT_PREF  TYPE STRING_TABLE,
          LV_CROW  TYPE I VALUE -1,
          LV_CCOL  TYPE I VALUE -1,
          LV_I     TYPE I,
          LV_J     TYPE I.

    SCAN ABAP-SOURCE IT_LINES TOKENS INTO LT_TOK STATEMENTS INTO LT_STM.
    IF LT_STM IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT LT_STM INTO DATA(LS_STM).
      CLEAR LT_T.
      LOOP AT LT_TOK INTO DATA(LS_TOK) FROM LS_STM-FROM TO LS_STM-TO.
        APPEND COND STRING( WHEN LS_TOK-TYPE = 'S' THEN LS_TOK-STR
                            ELSE TO_UPPER( LS_TOK-STR ) ) TO LT_T.
      ENDLOOP.
      IF LT_T IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA(LV_ROW) = LT_TOK[ LS_STM-FROM ]-ROW.

      " kalimat berantai (titik dua): pastikan prefiks ada di depan
      IF LS_STM-COLONROW > 0.
        IF LS_STM-COLONROW = LV_CROW AND LS_STM-COLONCOL = LV_CCOL.
          IF LT_PREF IS NOT INITIAL AND LT_T[ 1 ] <> LT_PREF[ 1 ].
            DATA(LT_TMP) = LT_PREF.
            APPEND LINES OF LT_T TO LT_TMP.
            LT_T = LT_TMP.
          ENDIF.
        ELSE.
          LV_CROW = LS_STM-COLONROW.
          LV_CCOL = LS_STM-COLONCOL.
          CLEAR LT_PREF.
          DO NMAX( VAL1 = 1 VAL2 = CONV I( LS_STM-PREFIXLEN ) ) TIMES.
            IF SY-INDEX <= LINES( LT_T ).
              APPEND LT_T[ SY-INDEX ] TO LT_PREF.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDIF.

      DATA(LV_N)  = LINES( LT_T ).
      DATA(LV_KW) = LT_T[ 1 ].
      DATA(LV_K2) = COND STRING( WHEN LV_N >= 2 THEN LT_T[ 2 ] ).
      DATA(LV_K3) = COND STRING( WHEN LV_N >= 3 THEN LT_T[ 3 ] ).

      " --- baca tabel: SELECT / OPEN CURSOR / subquery
      IF LV_KW = 'SELECT' OR ( LV_KW = 'OPEN' AND LV_K2 = 'CURSOR' ).
        LV_I = 1.
        WHILE LV_I < LV_N.
          IF LT_T[ LV_I ] = 'FROM' OR LT_T[ LV_I ] = 'JOIN'.
            LV_J = LV_I + 1.
            " FROM ( a INNER JOIN b ...) -> lompati kurung
            WHILE LV_J <= LV_N AND LT_T[ LV_J ] = '('.
              LV_J = LV_J + 1.
            ENDWHILE.
            IF LV_J <= LV_N.
              ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABR'
                                   IV_TOKEN = LT_T[ LV_J ]
                         CHANGING  CT_REF = RT_REF ).
            ENDIF.
          ENDIF.
          LV_I = LV_I + 1.
        ENDWHILE.
      ENDIF.

      " --- tulis tabel DB (disaring nanti: harus tabel DDIC)
      CASE LV_KW.
        WHEN 'UPDATE' OR 'MODIFY'.
          IF LV_K2 <> 'TABLE' AND LV_K2 <> 'SCREEN' AND LV_K2 <> 'LINE'
             AND LV_K2 <> 'CURRENT'.
            ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABW'
                                 IV_TOKEN = LV_K2
                       CHANGING  CT_REF = RT_REF ).
          ENDIF.
        WHEN 'INSERT'.
          " INSERT wa INTO TABLE itab / INSERT LINES OF ... = internal table
          IF NOT ( LINE_EXISTS( LT_T[ TABLE_LINE = 'TABLE' ] )
                   OR LINE_EXISTS( LT_T[ TABLE_LINE = 'LINES' ] )
                   OR LINE_EXISTS( LT_T[ TABLE_LINE = 'INDEX' ] )
                   OR LV_K2 = 'REPORT' OR LV_K2 = 'TEXTPOOL' ).
            ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABW'
                                 IV_TOKEN = COND #( WHEN LV_K2 = 'INTO' THEN LV_K3 ELSE LV_K2 )
                       CHANGING  CT_REF = RT_REF ).
          ENDIF.
        WHEN 'DELETE'.
          IF LV_K2 = 'FROM'.
            ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABW'
                                 IV_TOKEN = LV_K3
                       CHANGING  CT_REF = RT_REF ).
          ELSEIF LV_K2 <> 'ADJACENT' AND LV_K2 <> 'TABLE' AND LV_K2 <> 'REPORT'
             AND LV_K2 <> 'TEXTPOOL' AND LV_K2 <> 'DATASET'.
            ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABW'
                                 IV_TOKEN = LV_K2
                       CHANGING  CT_REF = RT_REF ).
          ENDIF.
        WHEN 'TABLES'.
          LOOP AT LT_T INTO DATA(LV_TABS) FROM 2.
            ADD_TABLE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TABS'
                                 IV_TOKEN = LV_TABS
                       CHANGING  CT_REF = RT_REF ).
          ENDLOOP.
        WHEN 'CALL'.
          IF ( LV_K2 = 'FUNCTION' OR LV_K2 = 'TRANSACTION' ) AND LV_N >= 3.
            IF LCL_UTIL=>IS_LITERAL( LV_K3 ) = ABAP_TRUE.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW
                             IV_KIND = COND STRING( WHEN LV_K2 = 'FUNCTION' THEN `FM` ELSE `TCODE` )
                             IV_NAME = LCL_UTIL=>UNQUOTE( LV_K3 )
                   CHANGING  CT_REF = RT_REF ).
            ELSE.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'DYN'
                             IV_NAME = LV_K3 IV_SUB = |CALL { LV_K2 }|
                   CHANGING  CT_REF = RT_REF ).
            ENDIF.
          ENDIF.
        WHEN 'LEAVE'.
          IF LV_K2 = 'TO' AND LV_K3 = 'TRANSACTION' AND LV_N >= 4.
            IF LCL_UTIL=>IS_LITERAL( LT_T[ 4 ] ) = ABAP_TRUE.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'TCODE'
                             IV_NAME = LCL_UTIL=>UNQUOTE( LT_T[ 4 ] )
                   CHANGING  CT_REF = RT_REF ).
            ENDIF.
          ENDIF.
        WHEN 'SUBMIT'.
          IF LV_K2 IS NOT INITIAL.
            IF SUBSTRING( VAL = LV_K2 OFF = 0 LEN = 1 ) = '('.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'DYN'
                             IV_NAME = LV_K2 IV_SUB = 'SUBMIT'
                   CHANGING  CT_REF = RT_REF ).
            ELSE.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'PROG' IV_NAME = LV_K2
                   CHANGING  CT_REF = RT_REF ).
            ENDIF.
          ENDIF.
        WHEN 'EXEC'.
          IF LV_K2 = 'SQL'.
            ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'NSQL' IV_NAME = 'EXEC SQL'
                 CHANGING  CT_REF = RT_REF ).
          ENDIF.
        WHEN 'CLASS' OR 'INTERFACE'.
          " class/interface lokal: jangan dicek ke repository
          IF LV_K2 IS NOT INITIAL.
            ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'LCLS' IV_NAME = LV_K2
                 CHANGING  CT_REF = RT_REF ).
          ENDIF.
      ENDCASE.

      " --- token di posisi mana pun
      LV_I = 1.
      WHILE LV_I <= LV_N.
        DATA(LV_TK) = LT_T[ LV_I ].
        DATA(LV_NX) = COND STRING( WHEN LV_I < LV_N THEN LT_T[ LV_I + 1 ] ).

        IF LV_TK = '%_HINTS'.
          ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'HINT' IV_NAME = '%_HINTS'
                         IV_SUB = LV_NX
               CHANGING  CT_REF = RT_REF ).
        ENDIF.

        IF ( LV_TK = 'TYPE' OR LV_TK = 'LIKE' ) AND LV_NX IS NOT INITIAL AND LV_KW <> 'CALL'.
          IF LV_NX = 'REF' AND LV_I + 3 <= LV_N AND LT_T[ LV_I + 2 ] = 'TO'.
            DATA(LV_CLS) = LT_T[ LV_I + 3 ].
            IF LV_CLS <> 'DATA' AND LV_CLS <> 'OBJECT'.
              ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'CLAS' IV_NAME = LV_CLS
                   CHANGING  CT_REF = RT_REF ).
            ENDIF.
          ELSEIF LV_NX = 'TABLE' OR LV_NX = 'STANDARD' OR LV_NX = 'SORTED'
              OR LV_NX = 'HASHED' OR LV_NX = 'RANGE' OR LV_NX = 'LINE'.
            " TYPE [STANDARD] TABLE OF x / RANGE OF x / LINE OF x
            LV_J = LV_I + 1.
            WHILE LV_J < LV_N AND LV_J <= LV_I + 4.
              IF LT_T[ LV_J ] = 'OF'.
                ADD_TYPE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW
                                    IV_TOKEN = LT_T[ LV_J + 1 ]
                          CHANGING  CT_REF = RT_REF ).
                EXIT.
              ENDIF.
              LV_J = LV_J + 1.
            ENDWHILE.
          ELSE.
            ADD_TYPE( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_TOKEN = LV_NX
                      CHANGING  CT_REF = RT_REF ).
          ENDIF.
        ENDIF.

        " pemanggilan statis class=>method
        IF LV_TK CS '=>' AND LV_TK <> '=>'.
          SPLIT LV_TK AT '=>' INTO DATA(LV_CL) DATA(LV_METH) ##NEEDED.
          IF LV_CL IS NOT INITIAL AND LV_CL <> 'ME' AND LV_CL <> 'SUPER'
             AND SUBSTRING( VAL = LV_CL OFF = 0 LEN = 1 ) <> '('.
            ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'CLAS' IV_NAME = LV_CL
                 CHANGING  CT_REF = RT_REF ).
          ENDIF.
        ELSEIF LV_TK = '=>' AND LV_I > 1.
          ADD( EXPORTING IV_UNIT = IV_UNIT IV_LINE = LV_ROW IV_KIND = 'CLAS'
                         IV_NAME = LT_T[ LV_I - 1 ]
               CHANGING  CT_REF = RT_REF ).
        ENDIF.

        LV_I = LV_I + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* L1: cek referensi ke repository ADB (S/4) dan ECC (opsional, RFC)
*----------------------------------------------------------------------*
CLASS LCL_DDIC DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS CONSTRUCTOR
      IMPORTING IV_DEST TYPE RFCDEST OPTIONAL.
    METHODS LOAD
      IMPORTING IT_REF TYPE TT_REF.
    METHODS EVALUATE
      IMPORTING IS_REF  TYPE TY_REF
                IV_MAIN TYPE PROGNAME
      CHANGING  CT_FIND TYPE TT_FIND.
  PRIVATE SECTION.
    TYPES: BEGIN OF TY_TAB,
             TABNAME  TYPE TABNAME,
             TABCLASS TYPE TABCLASS,
             VIEWREF  TYPE DD02L-VIEWREF,
           END OF TY_TAB,
           TT_TAB TYPE SORTED TABLE OF TY_TAB WITH NON-UNIQUE KEY TABNAME.
    TYPES: BEGIN OF TY_FLD,
             TABNAME   TYPE TABNAME,
             FIELDNAME TYPE FIELDNAME,
             LENG      TYPE DD03L-LENG,
           END OF TY_FLD,
           TT_FLD TYPE SORTED TABLE OF TY_FLD WITH NON-UNIQUE KEY TABNAME FIELDNAME.
    TYPES TY_NAME TYPE C LENGTH 40.
    TYPES TT_NAME TYPE SORTED TABLE OF TY_NAME WITH NON-UNIQUE KEY TABLE_LINE.

    DATA: MV_DEST TYPE RFCDEST,
          MT_TAB  TYPE TT_TAB,
          MT_FLD  TYPE TT_FLD,
          MT_ETAB TYPE TT_TAB,
          MT_EFLD TYPE TT_FLD,
          MT_FM   TYPE TT_NAME,
          MT_TC   TYPE TT_NAME,
          MT_PROG TYPE TT_NAME,
          MT_CLS  TYPE TT_NAME,
          MT_TYP  TYPE TT_NAME.

    METHODS ECC_READ
      IMPORTING IV_TABLE       TYPE TABNAME
                IV_WHERE       TYPE STRING
                IT_FIELDS      TYPE STRING_TABLE
      RETURNING VALUE(RT_ROWS) TYPE STRING_TABLE.
    METHODS ADD
      IMPORTING IS_REF    TYPE TY_REF
                IV_MAIN   TYPE PROGNAME
                IV_SEV    TYPE TY_SEV
                IV_CODE   TYPE CSEQUENCE
                IV_OBJ    TYPE CSEQUENCE
                IV_DETAIL TYPE STRING
                IV_ACTION TYPE STRING
      CHANGING  CT_FIND   TYPE TT_FIND.
    METHODS ADD_MISSING_Z
      IMPORTING IS_REF  TYPE TY_REF
                IV_MAIN TYPE PROGNAME
                IV_OBJ  TYPE CSEQUENCE
      CHANGING  CT_FIND TYPE TT_FIND.
ENDCLASS.

CLASS LCL_DDIC IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    MV_DEST = IV_DEST.
  ENDMETHOD.

  METHOD LOAD.
    DATA: LR_TAB  TYPE RANGE OF TABNAME,
          LR_FM   TYPE RANGE OF RS38L_FNAM,
          LR_TC   TYPE RANGE OF TCODE,
          LR_PROG TYPE RANGE OF PROGNAME,
          LR_CLS  TYPE RANGE OF SEOCLSNAME,
          LR_DTEL TYPE RANGE OF ROLLNAME,
          LR_TTYP TYPE RANGE OF TTYPENAME,
          LT_FTAB TYPE SORTED TABLE OF TABNAME WITH UNIQUE KEY TABLE_LINE,
          LT_DTEL TYPE STANDARD TABLE OF ROLLNAME WITH EMPTY KEY,
          LT_TTYP TYPE STANDARD TABLE OF TTYPENAME WITH EMPTY KEY,
          LT_ROWS TYPE STRING_TABLE.

    LOOP AT IT_REF INTO DATA(LS_REF).
      CASE LS_REF-KIND.
        WHEN 'TABR' OR 'TABW' OR 'TABS'.
          LR_TAB = VALUE #( BASE LR_TAB ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
        WHEN 'FLD'.
          LR_TAB = VALUE #( BASE LR_TAB ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
          INSERT CONV TABNAME( LS_REF-NAME ) INTO TABLE LT_FTAB.
        WHEN 'FM'.
          LR_FM = VALUE #( BASE LR_FM ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
        WHEN 'TCODE'.
          LR_TC = VALUE #( BASE LR_TC ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
        WHEN 'PROG'.
          LR_PROG = VALUE #( BASE LR_PROG ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
        WHEN 'CLAS'.
          LR_CLS = VALUE #( BASE LR_CLS ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
        WHEN 'ZTYP'.
          LR_TAB  = VALUE #( BASE LR_TAB  ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
          LR_CLS  = VALUE #( BASE LR_CLS  ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
          LR_DTEL = VALUE #( BASE LR_DTEL ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
          LR_TTYP = VALUE #( BASE LR_TTYP ( SIGN = 'I' OPTION = 'EQ' LOW = LS_REF-NAME ) ).
      ENDCASE.
    ENDLOOP.
    SORT: LR_TAB, LR_FM, LR_TC, LR_PROG, LR_CLS, LR_DTEL, LR_TTYP.
    DELETE ADJACENT DUPLICATES FROM: LR_TAB, LR_FM, LR_TC, LR_PROG, LR_CLS, LR_DTEL, LR_TTYP.

    " --- repository ADB (sistem ini = S/4)
    IF LR_TAB IS NOT INITIAL.
      SELECT TABNAME, TABCLASS, VIEWREF FROM DD02L
        WHERE TABNAME IN @LR_TAB AND AS4LOCAL = 'A' AND AS4VERS = '0000'
        INTO CORRESPONDING FIELDS OF TABLE @MT_TAB.
    ENDIF.
    IF LT_FTAB IS NOT INITIAL.
      SELECT TABNAME, FIELDNAME, LENG FROM DD03L
        FOR ALL ENTRIES IN @LT_FTAB
        WHERE TABNAME = @LT_FTAB-TABLE_LINE AND AS4LOCAL = 'A' AND AS4VERS = '0000'
          AND FIELDNAME NOT LIKE '.%'
        INTO CORRESPONDING FIELDS OF TABLE @MT_FLD.
    ENDIF.
    IF LR_FM IS NOT INITIAL.
      SELECT FUNCNAME FROM TFDIR WHERE FUNCNAME IN @LR_FM INTO TABLE @MT_FM.
    ENDIF.
    IF LR_TC IS NOT INITIAL.
      SELECT TCODE FROM TSTC WHERE TCODE IN @LR_TC INTO TABLE @MT_TC.
    ENDIF.
    IF LR_PROG IS NOT INITIAL.
      SELECT NAME FROM TRDIR WHERE NAME IN @LR_PROG INTO TABLE @MT_PROG.
    ENDIF.
    IF LR_CLS IS NOT INITIAL.
      SELECT CLSNAME FROM SEOCLASS WHERE CLSNAME IN @LR_CLS INTO TABLE @MT_CLS.
    ENDIF.
    IF LR_DTEL IS NOT INITIAL.
      SELECT ROLLNAME FROM DD04L WHERE ROLLNAME IN @LR_DTEL AND AS4LOCAL = 'A'
        INTO TABLE @LT_DTEL.
      LOOP AT LT_DTEL INTO DATA(LV_DTEL).
        INSERT CONV TY_NAME( LV_DTEL ) INTO TABLE MT_TYP.
      ENDLOOP.
    ENDIF.
    IF LR_TTYP IS NOT INITIAL.
      SELECT TYPENAME FROM DD40L WHERE TYPENAME IN @LR_TTYP AND AS4LOCAL = 'A'
        INTO TABLE @LT_TTYP.
      LOOP AT LT_TTYP INTO DATA(LV_TTYP).
        INSERT CONV TY_NAME( LV_TTYP ) INTO TABLE MT_TYP.
      ENDLOOP.
    ENDIF.

    " --- repository ECC (opsional, via RFC destination)
    IF MV_DEST IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT LR_TAB INTO DATA(LS_RTAB).
      LT_ROWS = ECC_READ( IV_TABLE  = 'DD02L'
                          IV_WHERE  = |TABNAME = '{ ls_rtab-low }' AND AS4LOCAL = 'A'|
                          IT_FIELDS = VALUE #( ( `TABNAME` ) ( `TABCLASS` ) ) ).
      LOOP AT LT_ROWS INTO DATA(LV_ROW).
        SPLIT LV_ROW AT '|' INTO DATA(LV_TN) DATA(LV_TC).
        INSERT VALUE #( TABNAME = CONDENSE( LV_TN ) TABCLASS = CONDENSE( LV_TC ) )
               INTO TABLE MT_ETAB.
      ENDLOOP.
    ENDLOOP.
    LOOP AT LT_FTAB INTO DATA(LV_FTAB).
      LT_ROWS = ECC_READ( IV_TABLE  = 'DD03L'
                          iv_where  = |TABNAME = '{ lv_ftab }' AND AS4LOCAL = 'A'|
                          IT_FIELDS = VALUE #( ( `FIELDNAME` ) ( `LENG` ) ) ).
      LOOP AT LT_ROWS INTO DATA(LV_FROW).
        SPLIT LV_FROW AT '|' INTO DATA(LV_FN) DATA(LV_FL).
        INSERT VALUE #( TABNAME = LV_FTAB FIELDNAME = CONDENSE( LV_FN )
                        LENG = CONDENSE( LV_FL ) ) INTO TABLE MT_EFLD.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD ECC_READ.
    DATA: LT_OPT TYPE STANDARD TABLE OF RFC_DB_OPT WITH EMPTY KEY,
          LT_FLD TYPE STANDARD TABLE OF RFC_DB_FLD WITH EMPTY KEY,
          LT_DAT TYPE STANDARD TABLE OF TAB512 WITH EMPTY KEY,
          LV_MSG TYPE C LENGTH 200.

    LT_OPT = VALUE #( ( TEXT = IV_WHERE ) ).
    LT_FLD = VALUE #( FOR LV_F IN IT_FIELDS ( FIELDNAME = LV_F ) ).
    CALL FUNCTION 'RFC_READ_TABLE'
      DESTINATION MV_DEST
      EXPORTING
        QUERY_TABLE           = IV_TABLE
        DELIMITER             = '|'
      TABLES
        OPTIONS               = LT_OPT
        FIELDS                = LT_FLD
        DATA                  = LT_DAT
      EXCEPTIONS
        SYSTEM_FAILURE        = 1 MESSAGE LV_MSG
        COMMUNICATION_FAILURE = 2 MESSAGE LV_MSG
        OTHERS                = 3.
    IF SY-SUBRC = 0.
      RT_ROWS = VALUE #( FOR LS_DAT IN LT_DAT ( CONV STRING( LS_DAT-WA ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD ADD.
    APPEND VALUE #( MAIN = IV_MAIN UNIT = IS_REF-UNIT LINE = IS_REF-LINE LAYER = 'L1'
                    SEVERITY = IV_SEV CODE = IV_CODE REF_OBJ = IV_OBJ
                    DETAIL = IV_DETAIL ACTION = IV_ACTION ) TO CT_FIND.
  ENDMETHOD.

  METHOD ADD_MISSING_Z.
    ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'I' IV_CODE = 'L1_MISSING_Z'
                   IV_OBJ = IV_OBJ
                   IV_DETAIL = |Objek custom { IV_OBJ } belum ada di ADB|
                   IV_ACTION = `Bawa objek/DDIC Z ke ADB (F0b) lalu scan ulang`
         CHANGING  CT_FIND = CT_FIND ).
  ENDMETHOD.

  METHOD EVALUATE.
    DATA(LV_NAME) = TO_UPPER( IS_REF-NAME ).
    DATA(LV_Z)    = LCL_UTIL=>IS_CUSTOM( LV_NAME ).

    CASE IS_REF-KIND.

      WHEN 'TABR' OR 'TABW' OR 'TABS'.
        DATA(LV_WRITE) = XSDBOOL( IS_REF-KIND = 'TABW' ).
        READ TABLE MT_TAB  INTO DATA(LS_T) WITH KEY TABNAME = LV_NAME.
        DATA(LV_ADB) = XSDBOOL( SY-SUBRC = 0 ).
        READ TABLE MT_ETAB INTO DATA(LS_E) WITH KEY TABNAME = LV_NAME.
        DATA(LV_ECC) = XSDBOOL( SY-SUBRC = 0 ).

        IF LV_ADB = ABAP_FALSE.
          " tulis ke nama yang tidak dikenal = kemungkinan internal table
          IF LV_WRITE = ABAP_TRUE AND LV_ECC = ABAP_FALSE.
            RETURN.
          ENDIF.
          IF LV_Z = ABAP_TRUE.
            ADD_MISSING_Z( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_OBJ = LV_NAME
                           CHANGING  CT_FIND = CT_FIND ).
          ELSE.
            ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'E'
                           IV_CODE = 'L1_TAB_REMOVED' IV_OBJ = LV_NAME
                           IV_DETAIL = |Tabel/view { LV_NAME } tidak ada di S/4HANA|
                           IV_ACTION = `Cari pengganti di Simplification List / CDS view`
                 CHANGING  CT_FIND = CT_FIND ).
          ENDIF.
          RETURN.
        ENDIF.

        " struktur (bukan tabel DB): abaikan
        IF LS_T-TABCLASS <> 'TRANSP' AND LS_T-TABCLASS <> 'VIEW'
           AND LS_T-TABCLASS <> 'CLUSTER' AND LS_T-TABCLASS <> 'POOL'.
          RETURN.
        ENDIF.

        IF LS_T-VIEWREF IS NOT INITIAL AND IS_REF-KIND <> 'TABS'.
          IF LV_WRITE = ABAP_TRUE.
            ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'E'
                           IV_CODE = 'L1_TAB_REPLACED_WRITE' IV_OBJ = LV_NAME
                           IV_DETAIL = |Tulis langsung ke { LV_NAME } (replacement object { LS_T-VIEWREF }) tidak didukung di S/4|
                           IV_ACTION = `Ganti dengan BAPI/API standar`
                 CHANGING  CT_FIND = CT_FIND ).
          ELSE.
            ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'W'
                           IV_CODE = 'L1_TAB_REPLACED_READ' IV_OBJ = LV_NAME
                           IV_DETAIL = |{ LV_NAME } dibaca lewat replacement object { LS_T-VIEWREF }|
                           IV_ACTION = `Masih jalan; cek performa, pertimbangkan tabel/CDS baru`
                 CHANGING  CT_FIND = CT_FIND ).
          ENDIF.
        ELSEIF LS_T-TABCLASS = 'VIEW'
           AND ( LV_WRITE = ABAP_TRUE OR ( LV_ECC = ABAP_TRUE AND LS_E-TABCLASS <> 'VIEW' ) ).
          ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN
                         IV_SEV = COND #( WHEN LV_WRITE = ABAP_TRUE THEN 'E' ELSE 'W' )
                         IV_CODE = COND STRING( WHEN LV_WRITE = ABAP_TRUE THEN `L1_TAB_VIEW_WRITE`
                                                ELSE `L1_TAB_NOW_VIEW` )
                         IV_OBJ = LV_NAME
                         IV_DETAIL = |{ LV_NAME } di S/4 berupa VIEW (compatibility view)|
                         IV_ACTION = COND #( WHEN LV_WRITE = ABAP_TRUE
                                             THEN `Tulis ke view tidak bisa: pakai tabel/BAPI pengganti`
                                             ELSE `Baca masih jalan; cek performa, pertimbangkan tabel baru` )
               CHANGING  CT_FIND = CT_FIND ).
        ENDIF.

        IF LV_ECC = ABAP_TRUE AND ( LS_E-TABCLASS = 'CLUSTER' OR LS_E-TABCLASS = 'POOL' )
           AND LS_T-TABCLASS = 'TRANSP' AND IS_REF-KIND = 'TABR'.
          ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'W'
                         IV_CODE = 'L1_EX_POOL_CLUSTER' IV_OBJ = LV_NAME
                         IV_DETAIL = |{ LV_NAME } dulu { LS_E-TABCLASS } di ECC, sekarang transparan|
                         IV_ACTION = `Hasil SELECT tidak lagi otomatis urut: tambah ORDER BY bila perlu`
               CHANGING  CT_FIND = CT_FIND ).
        ENDIF.

      WHEN 'FLD'.
        DATA(LV_FLD) = TO_UPPER( IS_REF-SUB ).
        READ TABLE MT_TAB INTO DATA(LS_FT) WITH KEY TABNAME = LV_NAME.
        IF SY-SUBRC <> 0.
          IF LV_Z = ABAP_TRUE.
            ADD_MISSING_Z( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_OBJ = LV_NAME
                           CHANGING  CT_FIND = CT_FIND ).
          ENDIF.
          RETURN.
        ENDIF.
        READ TABLE MT_FLD INTO DATA(LS_F) WITH KEY TABNAME = LV_NAME FIELDNAME = LV_FLD.
        IF SY-SUBRC <> 0.
          IF LS_FT-TABCLASS <> 'VIEW'.
            ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'E'
                           IV_CODE = 'L1_FIELD_MISSING' IV_OBJ = |{ LV_NAME }-{ LV_FLD }|
                           IV_DETAIL = |Field { LV_NAME }-{ LV_FLD } tidak ada di S/4|
                           IV_ACTION = `Cari field/tabel pengganti`
                 CHANGING  CT_FIND = CT_FIND ).
          ENDIF.
          RETURN.
        ENDIF.
        READ TABLE MT_EFLD INTO DATA(LS_EF) WITH KEY TABNAME = LV_NAME FIELDNAME = LV_FLD.
        IF SY-SUBRC = 0 AND LS_EF-LENG <> LS_F-LENG.
          ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'W'
                         IV_CODE = 'L1_FIELD_LENGTH' IV_OBJ = |{ LV_NAME }-{ LV_FLD }|
                         IV_DETAIL = |Panjang { LV_NAME }-{ LV_FLD } berubah: ECC { LS_EF-LENG ALPHA = OUT } -> S/4 { LS_F-LENG ALPHA = OUT }|
                         IV_ACTION = `Cek variabel penampung, offset/length, CONCATENATE, WRITE TO`
               CHANGING  CT_FIND = CT_FIND ).
        ENDIF.

      WHEN 'FM' OR 'TCODE' OR 'PROG' OR 'CLAS'.
        DATA(LV_FOUND) = SWITCH ABAP_BOOL( IS_REF-KIND
          WHEN 'FM'    THEN XSDBOOL( LINE_EXISTS( MT_FM[ TABLE_LINE = LV_NAME ] ) )
          WHEN 'TCODE' THEN XSDBOOL( LINE_EXISTS( MT_TC[ TABLE_LINE = LV_NAME ] ) )
          WHEN 'PROG'  THEN XSDBOOL( LINE_EXISTS( MT_PROG[ TABLE_LINE = LV_NAME ] ) )
          WHEN 'CLAS'  THEN XSDBOOL( LINE_EXISTS( MT_CLS[ TABLE_LINE = LV_NAME ] ) ) ).
        IF LV_FOUND = ABAP_TRUE.
          RETURN.
        ENDIF.
        IF LV_Z = ABAP_TRUE.
          ADD_MISSING_Z( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_OBJ = LV_NAME
                         CHANGING  CT_FIND = CT_FIND ).
        ELSE.
          DATA(LV_WHAT) = SWITCH STRING( IS_REF-KIND
            WHEN 'FM' THEN `Function module` WHEN 'TCODE' THEN `T-code`
            WHEN 'PROG' THEN `Program` ELSE `Class/interface` ).
          ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'E'
                         IV_CODE = |L1_{ IS_REF-KIND }_MISSING| IV_OBJ = LV_NAME
                         IV_DETAIL = |{ LV_WHAT } { LV_NAME } tidak ada di S/4HANA|
                         IV_ACTION = `Cari pengganti (Simplification List / API baru)`
               CHANGING  CT_FIND = CT_FIND ).
        ENDIF.

      WHEN 'ZTYP'.
        IF NOT ( LINE_EXISTS( MT_TYP[ TABLE_LINE = LV_NAME ] )
              OR LINE_EXISTS( MT_CLS[ TABLE_LINE = LV_NAME ] )
              OR LINE_EXISTS( MT_TAB[ TABNAME = LV_NAME ] ) ).
          ADD_MISSING_Z( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_OBJ = LV_NAME
                         CHANGING  CT_FIND = CT_FIND ).
        ENDIF.

      WHEN 'NSQL'.
        ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'W'
                       IV_CODE = 'L1_NATIVE_SQL' IV_OBJ = 'EXEC SQL'
                       IV_DETAIL = `Native SQL: sintaks DB lama (Oracle) bisa tidak valid di HANA`
                       IV_ACTION = `Ubah ke Open SQL, atau sesuaikan ke HANA SQL / AMDP`
             CHANGING  CT_FIND = CT_FIND ).

      WHEN 'HINT'.
        ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'W'
                       IV_CODE = 'L1_DB_HINT' IV_OBJ = |%_HINTS { IS_REF-SUB }|
                       IV_DETAIL = `Database hint untuk DB lama tidak berlaku di HANA`
                       IV_ACTION = `Hapus hint (kandidat fix otomatis kelas A)`
             CHANGING  CT_FIND = CT_FIND ).

      WHEN 'DYN'.
        ADD( EXPORTING IS_REF = IS_REF IV_MAIN = IV_MAIN IV_SEV = 'I'
                       IV_CODE = 'L1_DYNAMIC' IV_OBJ = LV_NAME
                       IV_DETAIL = |{ IS_REF-SUB } dinamis ({ LV_NAME }), tidak bisa dicek statis|
                       IV_ACTION = `Periksa manual nilai variabelnya`
             CHANGING  CT_FIND = CT_FIND ).

    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* L2: syntax check source (include digabung) dengan compiler S/4
*----------------------------------------------------------------------*
CLASS LCL_SYNTAX DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS CONSTRUCTOR
      IMPORTING IO_SRC TYPE REF TO LCL_SOURCE.
    METHODS CHECK
      IMPORTING IV_MAIN        TYPE PROGNAME
      RETURNING VALUE(RT_FIND) TYPE TT_FIND.
  PRIVATE SECTION.
    CONSTANTS C_MAX_ERRORS TYPE I VALUE 120.
    " kalimat yang kalau dikomentari membuat error berantai di bawahnya
    CONSTANTS C_STRUCT TYPE STRING VALUE
      `|DATA|TYPES|CONSTANTS|STATICS|FIELD-SYMBOLS|TABLES|PARAMETERS|SELECT-OPTIONS|RANGES|CLASS|INTERFACE|FORM|FUNCTION|METHOD|LOOP|IF|CASE|DO|WHILE|TRY|AT|ELSE|ELSEIF|WHEN|CATCH|`.
    DATA MO_SRC TYPE REF TO LCL_SOURCE.
    METHODS EXPAND
      IMPORTING IV_NAME  TYPE PROGNAME
                IV_DEPTH TYPE I
      CHANGING  CT_SRC   TYPE STRING_TABLE
                CT_MAP   TYPE TT_MAP.
    METHODS COMMENT_OUT
      IMPORTING IV_LINE TYPE I
      EXPORTING EV_KW   TYPE STRING
      CHANGING  CT_SRC  TYPE STRING_TABLE.
ENDCLASS.

CLASS LCL_SYNTAX IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    MO_SRC = IO_SRC.
  ENDMETHOD.

  METHOD EXPAND.
    IF IV_DEPTH > 20.
      RETURN.
    ENDIF.
    DATA(LT_LINES) = MO_SRC->LINES_OF( IV_NAME ).
    LOOP AT LT_LINES INTO DATA(LV_LINE).
      DATA(LV_ROW) = SY-TABIX.
      DATA(LV_INC) = LCL_UTIL=>INCLUDE_OF( LV_LINE ).
      IF LV_INC IS NOT INITIAL AND MO_SRC->HAS( LV_INC ) = ABAP_TRUE.
        APPEND |*>> INCLUDE { LV_INC }| TO CT_SRC.
        APPEND VALUE #( UNIT = IV_NAME LINE = LV_ROW ) TO CT_MAP.
        EXPAND( EXPORTING IV_NAME = LV_INC IV_DEPTH = IV_DEPTH + 1
                CHANGING  CT_SRC = CT_SRC CT_MAP = CT_MAP ).
      ELSE.
        APPEND LV_LINE TO CT_SRC.
        APPEND VALUE #( UNIT = IV_NAME LINE = LV_ROW ) TO CT_MAP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD COMMENT_OUT.
    " jadikan komentar seluruh kalimat yang memuat baris error
    DATA(LV_MAX)  = LINES( CT_SRC ).
    DATA(LV_FROM) = IV_LINE.
    WHILE LV_FROM > 1.
      DATA(LV_PREV) = LCL_UTIL=>CODE_PART( CT_SRC[ LV_FROM - 1 ] ).
      IF LV_PREV IS NOT INITIAL
         AND SUBSTRING( VAL = LV_PREV OFF = STRLEN( LV_PREV ) - 1 LEN = 1 ) = '.'.
        EXIT.
      ENDIF.
      LV_FROM = LV_FROM - 1.
    ENDWHILE.
    DATA(LV_TO) = IV_LINE.
    WHILE LV_TO < LV_MAX.
      DATA(LV_CUR) = LCL_UTIL=>CODE_PART( CT_SRC[ LV_TO ] ).
      IF LV_CUR IS NOT INITIAL
         AND SUBSTRING( VAL = LV_CUR OFF = STRLEN( LV_CUR ) - 1 LEN = 1 ) = '.'.
        EXIT.
      ENDIF.
      LV_TO = LV_TO + 1.
    ENDWHILE.
    " kata pertama kalimat (untuk deteksi error berantai)
    CLEAR EV_KW.
    LOOP AT CT_SRC INTO DATA(LV_TEXT) FROM LV_FROM TO LV_TO.
      DATA(LV_CP) = LCL_UTIL=>CODE_PART( LV_TEXT ).
      IF LV_CP IS NOT INITIAL.
        FIND FIRST OCCURRENCE OF REGEX `^\s*([A-Za-z0-9_\-]+)` IN LV_CP SUBMATCHES EV_KW.
        EXIT.
      ENDIF.
    ENDLOOP.
    EV_KW = TO_UPPER( EV_KW ).
    LOOP AT CT_SRC ASSIGNING FIELD-SYMBOL(<LV_SRC>) FROM LV_FROM TO LV_TO.
      <LV_SRC> = |*{ <LV_SRC> }|.
    ENDLOOP.
  ENDMETHOD.

  METHOD CHECK.
    DATA: LT_SRC  TYPE STRING_TABLE,
          LT_MAP  TYPE TT_MAP,
          LV_MSG  TYPE STRING,
          LV_LINE TYPE I,
          LV_WORD TYPE STRING,
          LV_LAST TYPE I VALUE -1,
          LV_KW   TYPE STRING,
          LV_STRU TYPE STRING,
          LV_ROOT TYPE STRING,
          LV_CASC TYPE ABAP_BOOL,
          LV_CODE TYPE STRING,
          LV_SEV  TYPE TY_SEV,
          LV_ACT  TYPE STRING.

    EXPAND( EXPORTING IV_NAME = IV_MAIN IV_DEPTH = 0
            CHANGING  CT_SRC = LT_SRC CT_MAP = LT_MAP ).
    IF LT_SRC IS INITIAL.
      RETURN.
    ENDIF.

    DATA(LS_DIR) = VALUE TRDIR( NAME = 'ZS4CCA_SYNCHK' SUBC = '1'
                                UCCHECK = ABAP_TRUE FIXPT = ABAP_TRUE ).
    DO C_MAX_ERRORS TIMES.
      CLEAR: LV_MSG, LV_LINE, LV_WORD, LV_STRU.
      SYNTAX-CHECK FOR LT_SRC MESSAGE LV_MSG LINE LV_LINE WORD LV_WORD
                   DIRECTORY ENTRY LS_DIR.
      IF SY-SUBRC = 0 OR LV_LINE <= 0 OR LV_LINE > LINES( LT_SRC ) OR LV_LINE = LV_LAST.
        EXIT.
      ENDIF.
      LV_LAST = LV_LINE.
      DATA(LS_MAP) = LT_MAP[ LV_LINE ].
      DATA(LV_IS_Z) = XSDBOOL( LV_WORD IS NOT INITIAL
                               AND LCL_UTIL=>IS_CUSTOM( LV_WORD ) = ABAP_TRUE ).
      LV_CODE = 'L2_SYNTAX'.
      LV_SEV  = 'E'.
      LV_ACT  = `Error kompilasi di S/4: perbaiki kode sesuai pesan`.
      IF LV_IS_Z = ABAP_TRUE.
        LV_CODE = 'L2_MISSING_Z'.
        LV_SEV  = 'I'.
        LV_ACT  = `Objek Z belum ada di ADB: bawa DDIC/objek Z (F0b), scan ulang`.
      ELSEIF LV_MSG CS 'Inconsistency in the dictionary'.
        FIND FIRST OCCURRENCE OF REGEX `structure\s+([A-Za-z0-9_/]+)` IN LV_MSG SUBMATCHES LV_STRU.
        LV_CODE = 'L2_ADB_DDIC'.
        LV_SEV  = 'I'.
        LV_ACT  = |Dictionary ADB tidak konsisten (bukan salah program): cek dan aktifkan struktur { LV_STRU } di SE11 ADB|.
      ELSEIF LV_CASC = ABAP_TRUE.
        LV_CODE = 'L2_CASCADE'.
        LV_SEV  = 'I'.
        LV_ACT  = |Kemungkinan akibat error di { LV_ROOT }: periksa lagi setelah error utama diperbaiki|.
      ENDIF.
      APPEND VALUE #( MAIN = IV_MAIN UNIT = LS_MAP-UNIT LINE = LS_MAP-LINE LAYER = 'L2'
                      SEVERITY = LV_SEV
                      CODE     = LV_CODE
                      REF_OBJ  = COND STRING( WHEN LV_STRU IS NOT INITIAL THEN LV_STRU ELSE LV_WORD )
                      DETAIL   = LV_MSG
                      ACTION   = LV_ACT )
             TO RT_FIND.
      COMMENT_OUT( EXPORTING IV_LINE = LV_LINE
                   IMPORTING EV_KW   = LV_KW
                   CHANGING  CT_SRC  = LT_SRC ).
      " kalimat deklarasi/blok yang dikomentari: error berikutnya kemungkinan berantai
      DATA(LV_PROBE) = |\|{ LV_KW }\||.
      IF LV_CASC = ABAP_FALSE AND LV_KW IS NOT INITIAL AND C_STRUCT CS LV_PROBE.
        LV_CASC = ABAP_TRUE.
        LV_ROOT = |{ LS_MAP-UNIT }:{ LS_MAP-LINE }|.
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* F3: Fixer - usulkan dan terapkan perbaikan ke SALINAN *_ECC6 di ADB
* Aturan: R01_HINT  hapus %_HINTS ORACLE '...'
*         R02_KONV  KONV -> PRCD_ELEMENTS (perbandingan field dari DDIC)
* Tidak pernah menulis ke program asli maupun ke ECC.
* Format remark mengikuti SOP-ABAP-06 (kode lama dikomentari).
*----------------------------------------------------------------------*
CLASS LCL_FIXER DEFINITION FINAL.
  PUBLIC SECTION.
    CONSTANTS C_SUFFIX TYPE STRING VALUE `_ECC6`.
    CLASS-METHODS COPY_NAME
      IMPORTING IV_NAME        TYPE CSEQUENCE
      RETURNING VALUE(RV_NAME) TYPE PROGNAME.
    METHODS CONSTRUCTOR
      IMPORTING IO_SRC TYPE REF TO LCL_SOURCE.
    METHODS PROPOSE
      RETURNING VALUE(RT_CHG) TYPE TT_CHG.
    METHODS APPLY
      IMPORTING IT_CHG   TYPE TT_CHG
      EXPORTING ET_MAINS TYPE STRING_TABLE
                ET_LOG   TYPE STRING_TABLE.
  PRIVATE SECTION.
    TYPES TT_TOK TYPE STANDARD TABLE OF STOKES WITH EMPTY KEY.
    TYPES TT_STM TYPE STANDARD TABLE OF SSTMNT WITH EMPTY KEY.
    TYPES: BEGIN OF TY_EDIT,
             UNIT TYPE PROGNAME,
             ROW  TYPE I,
             COL  TYPE I,
             LEN  TYPE I,
             NEW  TYPE STRING,
             RULE TYPE C LENGTH 12,
             RISK TYPE C LENGTH 1,
             NOTE TYPE STRING,
           END OF TY_EDIT,
           TT_EDIT TYPE STANDARD TABLE OF TY_EDIT WITH EMPTY KEY.
    TYPES: BEGIN OF TY_REPL,
             OLD  TYPE TABNAME,
             NEW  TYPE TABNAME,
             RULE TYPE C LENGTH 12,
           END OF TY_REPL,
           TT_REPL TYPE STANDARD TABLE OF TY_REPL WITH EMPTY KEY.
    TYPES: BEGIN OF TY_FLD,
             TABNAME   TYPE TABNAME,
             FIELDNAME TYPE FIELDNAME,
             DATATYPE  TYPE DD03L-DATATYPE,
             LENG      TYPE DD03L-LENG,
           END OF TY_FLD,
           TT_FLD TYPE STANDARD TABLE OF TY_FLD WITH EMPTY KEY.
    TYPES: BEGIN OF TY_PAIR,
             RULE  TYPE C LENGTH 12,
             FIELD TYPE FIELDNAME,
           END OF TY_PAIR,
           TT_PAIR TYPE SORTED TABLE OF TY_PAIR WITH UNIQUE KEY RULE FIELD.

    DATA MO_SRC  TYPE REF TO LCL_SOURCE.
    DATA MT_REPL TYPE TT_REPL.
    DATA MT_MISS TYPE TT_PAIR.
    DATA MT_CHGD TYPE TT_PAIR.

    METHODS LOAD_DDIC.
    METHODS EDITS_OF
      IMPORTING IV_UNIT        TYPE PROGNAME
                IT_LINES       TYPE STRING_TABLE
      RETURNING VALUE(RT_EDIT) TYPE TT_EDIT.
    METHODS RULE_HINTS
      IMPORTING IV_UNIT TYPE PROGNAME
                IT_TOK  TYPE TT_TOK
                IT_STM  TYPE TT_STM
      CHANGING  CT_EDIT TYPE TT_EDIT.
    METHODS RULE_REPLACE
      IMPORTING IV_UNIT TYPE PROGNAME
                IT_TOK  TYPE TT_TOK
                IT_STM  TYPE TT_STM
      CHANGING  CT_EDIT TYPE TT_EDIT.
    METHODS APPLY_EDITS
      IMPORTING IV_LINE       TYPE STRING
                IT_EDIT       TYPE TT_EDIT
      RETURNING VALUE(RV_NEW) TYPE STRING.
    METHODS WRITE_UNIT
      IMPORTING IV_NAME  TYPE PROGNAME
                IV_ORIG  TYPE PROGNAME
                IV_TYPE  TYPE C
                IT_LINES TYPE STRING_TABLE
      EXPORTING EV_OK    TYPE ABAP_BOOL
                EV_MSG   TYPE STRING.
ENDCLASS.

CLASS LCL_FIXER IMPLEMENTATION.

  METHOD COPY_NAME.
    DATA(LV_N) = TO_UPPER( CONDENSE( CONV STRING( IV_NAME ) ) ).
    IF STRLEN( LV_N ) >= STRLEN( C_SUFFIX )
       AND SUBSTRING( VAL = LV_N OFF = STRLEN( LV_N ) - STRLEN( C_SUFFIX ) ) = C_SUFFIX.
      RV_NAME = LV_N.
      RETURN.
    ENDIF.
    IF STRLEN( LV_N ) + STRLEN( C_SUFFIX ) > 40.
      LV_N = SUBSTRING( VAL = LV_N OFF = 0 LEN = 40 - STRLEN( C_SUFFIX ) ).
    ENDIF.
    RV_NAME = LV_N && C_SUFFIX.
  ENDMETHOD.

  METHOD CONSTRUCTOR.
    MO_SRC = IO_SRC.
    MT_REPL = VALUE #( ( OLD = 'KONV' NEW = 'PRCD_ELEMENTS' RULE = 'R02_KONV' ) ).
    LOAD_DDIC( ).
  ENDMETHOD.

  METHOD LOAD_DDIC.
    DATA LT_F TYPE TT_FLD.
    LOOP AT MT_REPL INTO DATA(LS_R).
      CLEAR LT_F.
      SELECT TABNAME, FIELDNAME, DATATYPE, LENG FROM DD03L
        WHERE ( TABNAME = @LS_R-OLD OR TABNAME = @LS_R-NEW )
          AND AS4LOCAL = 'A' AND AS4VERS = '0000'
          AND FIELDNAME NOT LIKE '.%'
        INTO CORRESPONDING FIELDS OF TABLE @LT_F.
      SORT LT_F BY TABNAME FIELDNAME.
      LOOP AT LT_F INTO DATA(LS_O) WHERE TABNAME = LS_R-OLD.
        READ TABLE LT_F INTO DATA(LS_N)
             WITH KEY TABNAME = LS_R-NEW FIELDNAME = LS_O-FIELDNAME BINARY SEARCH.
        IF SY-SUBRC <> 0.
          INSERT VALUE #( RULE = LS_R-RULE FIELD = LS_O-FIELDNAME ) INTO TABLE MT_MISS.
        ELSEIF LS_N-DATATYPE <> LS_O-DATATYPE OR LS_N-LENG <> LS_O-LENG.
          INSERT VALUE #( RULE = LS_R-RULE FIELD = LS_O-FIELDNAME ) INTO TABLE MT_CHGD.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD EDITS_OF.
    DATA: LT_TOK TYPE TT_TOK,
          LT_STM TYPE TT_STM.
    SCAN ABAP-SOURCE IT_LINES TOKENS INTO LT_TOK STATEMENTS INTO LT_STM.
    IF LT_STM IS INITIAL.
      RETURN.
    ENDIF.
    RULE_HINTS( EXPORTING IV_UNIT = IV_UNIT IT_TOK = LT_TOK IT_STM = LT_STM
                CHANGING  CT_EDIT = RT_EDIT ).
    RULE_REPLACE( EXPORTING IV_UNIT = IV_UNIT IT_TOK = LT_TOK IT_STM = LT_STM
                  CHANGING  CT_EDIT = RT_EDIT ).
  ENDMETHOD.

  METHOD RULE_HINTS.
    " %_HINTS <DB> '<teks hint>'  -> hapus ketiga token (harus satu baris)
    LOOP AT IT_STM INTO DATA(LS_STM).
      DATA(LV_I) = LS_STM-FROM.
      WHILE LV_I + 2 <= LS_STM-TO.
        IF TO_UPPER( IT_TOK[ LV_I ]-STR ) = '%_HINTS'.
          DATA(LS_A) = IT_TOK[ LV_I ].
          DATA(LS_C) = IT_TOK[ LV_I + 2 ].
          IF LS_A-ROW = LS_C-ROW AND LCL_UTIL=>IS_LITERAL( LS_C-STR ) = ABAP_TRUE.
            APPEND VALUE #( UNIT = IV_UNIT ROW = LS_A-ROW COL = LS_A-COL
                            LEN  = LS_C-COL + STRLEN( LS_C-STR ) - LS_A-COL
                            NEW  = `` RULE = 'R01_HINT' RISK = ' '
                            NOTE = `Hint database Oracle tidak berlaku di HANA` )
                   TO CT_EDIT.
            LV_I = LV_I + 3.
            CONTINUE.
          ELSE.
            APPEND VALUE #( UNIT = IV_UNIT ROW = LS_A-ROW COL = LS_A-COL LEN = 0
                            NEW  = `` RULE = 'R01_HINT' RISK = 'E'
                            NOTE = `Hint multi-baris / bentuk tidak dikenal: hapus manual` )
                   TO CT_EDIT.
          ENDIF.
        ENDIF.
        LV_I = LV_I + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD RULE_REPLACE.
    " nama tabel lama -> tabel baru; field dibandingkan dari DDIC ADB
    DATA: LV_FLD  TYPE STRING,
          LV_REST TYPE STRING,
          LV_DUM  TYPE STRING.
    LOOP AT IT_STM INTO DATA(LS_STM).
      IF LS_STM-FROM > LS_STM-TO.
        CONTINUE.
      ENDIF.
      DATA(LV_FIRST) = TO_UPPER( IT_TOK[ LS_STM-FROM ]-STR ).
      DATA(LV_WRITE) = XSDBOOL( LV_FIRST = 'INSERT' OR LV_FIRST = 'UPDATE'
                             OR LV_FIRST = 'MODIFY' OR LV_FIRST = 'DELETE' ).
      LOOP AT MT_REPL INTO DATA(LS_R).
        DATA(LV_OLD)  = CONV STRING( LS_R-OLD ).
        DATA(LV_OLEN) = STRLEN( LV_OLD ).
        DATA(LV_HITS) = 0.
        DATA LT_NEW TYPE TT_EDIT.
        CLEAR LT_NEW.
        DATA(LV_IDX) = LS_STM-FROM.
        WHILE LV_IDX <= LS_STM-TO.
          DATA(LS_TOK) = IT_TOK[ LV_IDX ].
          LV_IDX = LV_IDX + 1.
          IF LCL_UTIL=>IS_LITERAL( LS_TOK-STR ) = ABAP_TRUE.
            CONTINUE.
          ENDIF.
          DATA(LV_UP) = TO_UPPER( LS_TOK-STR ).
          CLEAR: LV_FLD, LV_REST.
          IF LV_UP = LV_OLD.
            " token nama tabel saja
          ELSEIF STRLEN( LV_UP ) > LV_OLEN
             AND SUBSTRING( VAL = LV_UP OFF = 0 LEN = LV_OLEN ) = LV_OLD
             AND ( SUBSTRING( VAL = LV_UP OFF = LV_OLEN LEN = 1 ) = '-'
                OR SUBSTRING( VAL = LV_UP OFF = LV_OLEN LEN = 1 ) = '~' ).
            LV_REST = SUBSTRING( VAL = LS_TOK-STR OFF = LV_OLEN ).
            LV_FLD  = SUBSTRING( VAL = LV_UP OFF = LV_OLEN + 1 ).
            SPLIT LV_FLD AT '-' INTO LV_FLD LV_DUM.
          ELSE.
            CONTINUE.
          ENDIF.
          LV_HITS = LV_HITS + 1.

          DATA(LV_RISK) = ` `.
          DATA(LV_NOTE) = ||.
          IF LV_FLD IS INITIAL.
            LV_RISK = 'W'.
            LV_NOTE = |Struktur { LS_R-OLD } diganti { LS_R-NEW }: periksa field yang hilang atau berubah tipe, dan SELECT *|.
          ELSEIF LINE_EXISTS( MT_MISS[ RULE = LS_R-RULE FIELD = LV_FLD ] ).
            LV_RISK = 'E'.
            LV_NOTE = |Field { LS_R-OLD }-{ LV_FLD } tidak ada di { LS_R-NEW }|.
          ELSEIF LINE_EXISTS( MT_CHGD[ RULE = LS_R-RULE FIELD = LV_FLD ] ).
            LV_RISK = 'W'.
            LV_NOTE = |Tipe/panjang { LV_FLD } berubah di { LS_R-NEW }: periksa variabel penampung|.
          ENDIF.
          IF LV_WRITE = ABAP_TRUE AND LV_IDX - 1 > LS_STM-FROM.
            LV_RISK = 'E'.
            LV_NOTE = |Tulis ke { LS_R-OLD }: tidak bisa diganti otomatis (pakai BAPI/API)|.
          ENDIF.
          APPEND VALUE #( UNIT = IV_UNIT ROW = LS_TOK-ROW COL = LS_TOK-COL
                          LEN  = STRLEN( LS_TOK-STR )
                          NEW  = |{ LS_R-NEW }{ LV_REST }|
                          RULE = LS_R-RULE RISK = LV_RISK NOTE = LV_NOTE ) TO LT_NEW.
        ENDWHILE.

        IF LV_HITS = 0.
          CONTINUE.
        ENDIF.
        APPEND LINES OF LT_NEW TO CT_EDIT.

        " field yang hilang di tabel baru, ditulis tanpa awalan, di kalimat yang sama
        LV_IDX = LS_STM-FROM.
        WHILE LV_IDX <= LS_STM-TO.
          DATA(LS_T2) = IT_TOK[ LV_IDX ].
          LV_IDX = LV_IDX + 1.
          IF LCL_UTIL=>IS_LITERAL( LS_T2-STR ) = ABAP_TRUE.
            CONTINUE.
          ENDIF.
          DATA(LV_UP2) = TO_UPPER( LS_T2-STR ).
          IF LINE_EXISTS( MT_MISS[ RULE = LS_R-RULE FIELD = LV_UP2 ] ).
            APPEND VALUE #( UNIT = IV_UNIT ROW = LS_T2-ROW COL = LS_T2-COL LEN = 0
                            NEW = `` RULE = LS_R-RULE RISK = 'E'
                            NOTE = |Field { LV_UP2 } tidak ada di { LS_R-NEW }| ) TO CT_EDIT.
          ENDIF.
        ENDWHILE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD APPLY_EDITS.
    DATA(LT_E) = IT_EDIT.
    SORT LT_E BY COL DESCENDING.
    RV_NEW = IV_LINE.
    LOOP AT LT_E INTO DATA(LS_E) WHERE RISK <> 'E'.
      DATA(LV_LEN) = STRLEN( RV_NEW ).
      IF LS_E-COL > LV_LEN.
        CONTINUE.
      ENDIF.
      DATA(LV_LEFT)  = SUBSTRING( VAL = RV_NEW OFF = 0 LEN = LS_E-COL ).
      DATA(LV_END)   = LS_E-COL + LS_E-LEN.
      DATA(LV_RIGHT) = COND STRING( WHEN LV_END < LV_LEN THEN SUBSTRING( VAL = RV_NEW OFF = LV_END ) ).
      IF LS_E-NEW IS INITIAL AND CONDENSE( LV_LEFT ) IS NOT INITIAL.
        LV_LEFT = REPLACE( VAL = LV_LEFT REGEX = `\s+$` WITH = `` ).
      ENDIF.
      RV_NEW = LV_LEFT && LS_E-NEW && LV_RIGHT.
    ENDLOOP.
  ENDMETHOD.

  METHOD PROPOSE.
    LOOP AT MO_SRC->MT_UNITS INTO DATA(LS_UNIT).
      DATA(LT_EDIT) = EDITS_OF( IV_UNIT = LS_UNIT-NAME IT_LINES = LS_UNIT-LINES ).
      IF LT_EDIT IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA(LT_KEY) = LT_EDIT.
      SORT LT_KEY BY ROW RULE.
      DELETE ADJACENT DUPLICATES FROM LT_KEY COMPARING ROW RULE.
      LOOP AT LT_KEY INTO DATA(LS_KEY).
        DATA(LT_SAME) = VALUE TT_EDIT( FOR E IN LT_EDIT
                                       WHERE ( ROW = LS_KEY-ROW AND RULE = LS_KEY-RULE ) ( E ) ).
        DATA(LV_BEFORE) = LS_UNIT-LINES[ LS_KEY-ROW ].
        DATA LV_RISK TYPE C LENGTH 1.
        LV_RISK = ' '.
        LOOP AT LT_SAME INTO DATA(LS_S).
          IF LS_S-RISK = 'E'.
            LV_RISK = 'E'.
          ELSEIF LS_S-RISK = 'W' AND LV_RISK = ' '.
            LV_RISK = 'W'.
          ENDIF.
        ENDLOOP.
        DATA(LV_NOTE) = LT_SAME[ 1 ]-NOTE.
        LOOP AT LT_SAME INTO LS_S WHERE RISK = 'E'.
          LV_NOTE = LS_S-NOTE.
          EXIT.
        ENDLOOP.
        APPEND VALUE #( UNIT = LS_UNIT-NAME LINE = LS_KEY-ROW RULE = LS_KEY-RULE
                        RISK = LV_RISK BEFORE = LV_BEFORE
                        AFTER = APPLY_EDITS( IV_LINE = LV_BEFORE IT_EDIT = LT_SAME )
                        NOTE = LV_NOTE ) TO RT_CHG.
      ENDLOOP.
    ENDLOOP.
    SORT RT_CHG BY UNIT LINE RULE.
  ENDMETHOD.

  METHOD WRITE_UNIT.
    DATA: LT_SRC   TYPE STANDARD TABLE OF ABAPTXT255 WITH EMPTY KEY,
          LV_TITLE TYPE C LENGTH 70.
    EV_OK = ABAP_FALSE.
    LT_SRC = VALUE #( FOR L IN IT_LINES ( LINE = L ) ).

    SELECT SINGLE NAME FROM TRDIR WHERE NAME = @IV_NAME INTO @DATA(LV_EXIST).
    IF SY-SUBRC = 0.
      INSERT REPORT IV_NAME FROM IT_LINES.
      IF SY-SUBRC = 0.
        EV_OK  = ABAP_TRUE.
        EV_MSG = `salinan sudah ada, source diperbarui`.
      ELSE.
        EV_MSG = `INSERT REPORT gagal`.
      ENDIF.
      RETURN.
    ENDIF.

    LV_TITLE = |S4 salinan { IV_ORIG }|.
    CALL FUNCTION 'RPY_PROGRAM_INSERT'
      EXPORTING
        PROGRAM_NAME        = IV_NAME
        TITLE_STRING        = LV_TITLE
        STATUS              = 'K'
        APPLICATION         = 'S'
        SUPPRESS_DIALOG     = 'X'
        SAVE_INACTIVE       = 'A'
        AUTHORIZATION_GROUP = ' '
        DEVELOPMENT_CLASS   = '$TMP'
        EDIT_LOCK           = ' '
        PROGRAM_TYPE        = IV_TYPE
        TEMPORARY           = ' '
        TRANSPORT_NUMBER    = ' '
        UCCHECK             = 'X'
      TABLES
        SOURCE_EXTENDED     = LT_SRC
      EXCEPTIONS
        ALREADY_EXISTS      = 1
        CANCELLED           = 2
        NAME_NOT_ALLOWED    = 3
        PERMISSION_ERROR    = 4
        OTHERS              = 5.
    CASE SY-SUBRC.
      WHEN 0.
        EV_OK  = ABAP_TRUE.
        EV_MSG = `salinan baru dibuat di $TMP`.
      WHEN 1.
        EV_MSG = `sudah ada`.
      WHEN 3.
        EV_MSG = `nama tidak diizinkan`.
      WHEN 4.
        EV_MSG = `tidak ada otorisasi`.
      WHEN OTHERS.
        EV_MSG = |gagal (subrc { SY-SUBRC })|.
    ENDCASE.
  ENDMETHOD.

  METHOD APPLY.
    DATA: LT_USE TYPE TT_EDIT,
          LT_OUT TYPE STRING_TABLE,
          LT_ROW TYPE TT_EDIT,
          LT_RUL TYPE STRING_TABLE,
          LV_OK  TYPE ABAP_BOOL,
          LV_MSG TYPE STRING,
          LV_TYP TYPE C LENGTH 1.
    CLEAR: ET_MAINS, ET_LOG.

    LOOP AT MO_SRC->MT_UNITS INTO DATA(LS_UNIT).
      " edit yang dipilih saja, tanpa yang berisiko E
      CLEAR LT_USE.
      DATA(LT_EDIT) = EDITS_OF( IV_UNIT = LS_UNIT-NAME IT_LINES = LS_UNIT-LINES ).
      LOOP AT LT_EDIT INTO DATA(LS_E) WHERE RISK <> 'E'.
        IF LINE_EXISTS( IT_CHG[ UNIT = LS_E-UNIT LINE = LS_E-ROW RULE = LS_E-RULE ] ).
          APPEND LS_E TO LT_USE.
        ENDIF.
      ENDLOOP.

      CLEAR LT_OUT.
      LOOP AT LS_UNIT-LINES INTO DATA(LV_LINE).
        DATA(LV_ROW) = SY-TABIX.
        LT_ROW = VALUE #( FOR E2 IN LT_USE WHERE ( ROW = LV_ROW ) ( E2 ) ).
        IF LT_ROW IS INITIAL.
          APPEND LV_LINE TO LT_OUT.
          CONTINUE.
        ENDIF.
        DATA(LV_NEW) = APPLY_EDITS( IV_LINE = LV_LINE IT_EDIT = LT_ROW ).
        CLEAR LT_RUL.
        LOOP AT LT_ROW INTO DATA(LS_R).
          IF NOT LINE_EXISTS( LT_RUL[ TABLE_LINE = CONV STRING( LS_R-RULE ) ] ).
            APPEND CONV STRING( LS_R-RULE ) TO LT_RUL.
          ENDIF.
        ENDLOOP.
        DATA(LV_RULES) = CONCAT_LINES_OF( TABLE = LT_RUL SEP = `,` ).
        APPEND |*\{ S4MIG { LV_RULES } { SY-DATUM } { SY-UNAME }| TO LT_OUT.
        APPEND |*{ LV_LINE }| TO LT_OUT.
        IF CONDENSE( LV_NEW ) IS NOT INITIAL.
          APPEND LV_NEW TO LT_OUT.
        ENDIF.
        APPEND `*} S4MIG` TO LT_OUT.
      ENDLOOP.

      " tipe objek dan penggantian nama (INCLUDE, REPORT) ke *_ECC6
      LV_TYP = 'I'.
      LOOP AT LT_OUT INTO DATA(LV_T1).
        DATA(LV_CP) = TO_UPPER( LCL_UTIL=>CODE_PART( LV_T1 ) ).
        IF LV_CP IS INITIAL.
          CONTINUE.
        ENDIF.
        IF LV_CP CP 'REPORT*' OR LV_CP CP 'PROGRAM*'.
          LV_TYP = '1'.
        ELSEIF LV_CP CP 'FUNCTION-POOL*'.
          LV_TYP = 'F'.
        ENDIF.
        EXIT.
      ENDLOOP.
      IF LV_TYP = 'F'.
        APPEND |{ LS_UNIT-NAME } dilewati: function pool belum didukung| TO ET_LOG.
        CONTINUE.
      ENDIF.

      DATA(LV_SEEN) = ABAP_FALSE.
      LOOP AT LT_OUT ASSIGNING FIELD-SYMBOL(<LV_O>).
        IF <LV_O> IS INITIAL OR SUBSTRING( VAL = <LV_O> OFF = 0 LEN = 1 ) = '*'.
          CONTINUE.
        ENDIF.
        DATA(LV_INC) = LCL_UTIL=>INCLUDE_OF( <LV_O> ).
        IF LV_INC IS NOT INITIAL AND MO_SRC->HAS( LV_INC ) = ABAP_TRUE.
          DATA(LV_INCS) = CONDENSE( CONV STRING( LV_INC ) ).
          DATA(LV_INCN) = CONDENSE( CONV STRING( COPY_NAME( LV_INC ) ) ).
          REPLACE FIRST OCCURRENCE OF LV_INCS IN <LV_O> WITH LV_INCN IGNORING CASE.
        ENDIF.
        IF LV_SEEN = ABAP_FALSE AND LV_TYP = '1'.
          DATA(LV_C2) = TO_UPPER( LCL_UTIL=>CODE_PART( <LV_O> ) ).
          IF LV_C2 CP 'REPORT*' OR LV_C2 CP 'PROGRAM*'.
            DATA(LV_ORIG) = CONDENSE( CONV STRING( LS_UNIT-NAME ) ).
            DATA(LV_NEWN) = CONDENSE( CONV STRING( COPY_NAME( LS_UNIT-NAME ) ) ).
            REPLACE FIRST OCCURRENCE OF LV_ORIG IN <LV_O> WITH LV_NEWN IGNORING CASE.
            LV_SEEN = ABAP_TRUE.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DATA(LV_NAME) = COPY_NAME( LS_UNIT-NAME ).
      WRITE_UNIT( EXPORTING IV_NAME = LV_NAME IV_ORIG = LS_UNIT-NAME IV_TYPE = LV_TYP
                            IT_LINES = LT_OUT
                  IMPORTING EV_OK = LV_OK EV_MSG = LV_MSG ).
      APPEND |{ LV_NAME }: { COND STRING( WHEN LV_OK = ABAP_TRUE THEN `OK` ELSE `GAGAL` ) } - { LV_MSG }|
             TO ET_LOG.
      IF LV_OK = ABAP_TRUE AND LV_TYP = '1'
         AND LINE_EXISTS( MO_SRC->MT_MAINS[ TABLE_LINE = CONV STRING( LS_UNIT-NAME ) ] ).
        APPEND CONV STRING( LV_NAME ) TO ET_MAINS.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* Runner: orkestrasi + tampilan ALV
*----------------------------------------------------------------------*
CLASS LCL_RUNNER DEFINITION FINAL.
  PUBLIC SECTION.
    DATA MV_TITLE TYPE STRING.
    METHODS RUN.
    METHODS ANALYZE
      IMPORTING IO_SRC TYPE REF TO LCL_SOURCE.
    METHODS DISPLAY.
    METHODS FIX.
  PRIVATE SECTION.
    TYPES: BEGIN OF TY_OWNER,
             UNIT TYPE PROGNAME,
             MAIN TYPE PROGNAME,
           END OF TY_OWNER,
           TT_OWNER TYPE HASHED TABLE OF TY_OWNER WITH UNIQUE KEY UNIT.
    DATA MO_SRC   TYPE REF TO LCL_SOURCE.
    DATA MT_FIND  TYPE TT_FIND.
    DATA MT_OWNER TYPE TT_OWNER.
    METHODS LAYER1.
    METHODS LAYER2.
    METHODS VERIFY
      IMPORTING IT_MAINS TYPE STRING_TABLE.
    METHODS SET_OWNER
      IMPORTING IV_UNIT  TYPE PROGNAME
                IV_MAIN  TYPE PROGNAME
                IV_DEPTH TYPE I.
    METHODS OWNER_OF
      IMPORTING IV_UNIT        TYPE PROGNAME
      RETURNING VALUE(RV_MAIN) TYPE PROGNAME.
    METHODS SET_COL
      IMPORTING IO_COLS TYPE REF TO CL_SALV_COLUMNS_TABLE
                IV_NAME TYPE LVC_FNAME
                IV_TEXT TYPE STRING.
ENDCLASS.

CLASS LCL_RUNNER IMPLEMENTATION.

  METHOD RUN.
    DATA LT_NAMES TYPE STANDARD TABLE OF PROGNAME WITH EMPTY KEY.
    DATA(LV_MODE) = COND TY_MODE( WHEN RB_FILE = ABAP_TRUE THEN 'FIL'
                                  WHEN RB_RFC  = ABAP_TRUE THEN 'RFC'
                                  ELSE 'ADB' ).
    MO_SRC = NEW #( IV_MODE = LV_MODE IV_DEST = P_DEST ).

    CASE LV_MODE.
      WHEN 'FIL'.
        MO_SRC->LOAD_FROM_FILES( ).
      WHEN 'RFC'.
        LOOP AT S_PROG INTO DATA(LS_PROG) WHERE SIGN = 'I' AND OPTION = 'EQ'.
          MO_SRC->LOAD_PROGRAM( IV_NAME = LS_PROG-LOW IV_IS_MAIN = ABAP_TRUE ).
        ENDLOOP.
      WHEN 'ADB'.
        SELECT NAME FROM TRDIR
          WHERE NAME IN @S_PROG AND ( SUBC = '1' OR SUBC = 'M' )
          INTO TABLE @LT_NAMES UP TO 500 ROWS.
        LOOP AT LT_NAMES INTO DATA(LV_NAME).
          MO_SRC->LOAD_PROGRAM( IV_NAME = LV_NAME IV_IS_MAIN = ABAP_TRUE ).
        ENDLOOP.
    ENDCASE.

    ANALYZE( MO_SRC ).
  ENDMETHOD.

  METHOD ANALYZE.
    MO_SRC = IO_SRC.
    IF MO_SRC->MT_UNITS IS INITIAL.
      MESSAGE 'Tidak ada source yang terbaca' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LOOP AT MO_SRC->MT_MAINS INTO DATA(LV_MAIN).
      SET_OWNER( IV_UNIT = CONV #( LV_MAIN ) IV_MAIN = CONV #( LV_MAIN ) IV_DEPTH = 0 ).
    ENDLOOP.

    IF P_L1 = ABAP_TRUE.
      LAYER1( ).
    ENDIF.
    IF P_L2 = ABAP_TRUE.
      LAYER2( ).
    ENDIF.

    " include/program yang dirujuk tapi tidak ada di sumber
    LOOP AT MO_SRC->MT_MISSING INTO DATA(LV_MISS).
      APPEND VALUE #( UNIT = CONV #( LV_MISS ) LAYER = 'L1' SEVERITY = 'W'
                      CODE = 'L1_SOURCE_MISSING' REF_OBJ = LV_MISS
                      DETAIL = |Source { LV_MISS } tidak ditemukan di sumber yang dipilih|
                      ACTION = `Masukkan ke daftar missing objects (deliverable)` ) TO MT_FIND.
    ENDLOOP.

    SORT MT_FIND BY MAIN UNIT LINE LAYER CODE REF_OBJ.
    DELETE ADJACENT DUPLICATES FROM MT_FIND COMPARING MAIN UNIT LINE LAYER CODE REF_OBJ.
  ENDMETHOD.

  METHOD SET_OWNER.
    IF IV_DEPTH > 20 OR LINE_EXISTS( MT_OWNER[ UNIT = IV_UNIT ] ).
      RETURN.
    ENDIF.
    INSERT VALUE #( UNIT = IV_UNIT MAIN = IV_MAIN ) INTO TABLE MT_OWNER.
    DATA(LT_LINES) = MO_SRC->LINES_OF( IV_UNIT ).
    LOOP AT LT_LINES INTO DATA(LV_LINE).
      DATA(LV_INC) = LCL_UTIL=>INCLUDE_OF( LV_LINE ).
      IF LV_INC IS NOT INITIAL AND MO_SRC->HAS( LV_INC ) = ABAP_TRUE.
        SET_OWNER( IV_UNIT = LV_INC IV_MAIN = IV_MAIN IV_DEPTH = IV_DEPTH + 1 ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD OWNER_OF.
    READ TABLE MT_OWNER INTO DATA(LS_OWNER) WITH TABLE KEY UNIT = IV_UNIT.
    IF SY-SUBRC = 0.
      RV_MAIN = LS_OWNER-MAIN.
    ENDIF.
  ENDMETHOD.

  METHOD LAYER1.
    DATA: LT_REF   TYPE TT_REF,
          LT_ONE   TYPE TT_REF,
          LT_LOCAL TYPE STRING_TABLE.

    LOOP AT MO_SRC->MT_UNITS INTO DATA(LS_UNIT).
      LT_ONE = LCL_SCAN=>SCAN( IV_UNIT = LS_UNIT-NAME IT_LINES = LS_UNIT-LINES ).
      APPEND LINES OF LT_ONE TO LT_REF.
    ENDLOOP.

    " class/interface lokal tidak dicek ke repository
    LOOP AT LT_REF INTO DATA(LS_LOCAL) WHERE KIND = 'LCLS'.
      APPEND LS_LOCAL-NAME TO LT_LOCAL.
    ENDLOOP.
    LOOP AT LT_LOCAL INTO DATA(LV_LOCAL).
      DELETE LT_REF WHERE KIND = 'CLAS' AND NAME = LV_LOCAL.
    ENDLOOP.
    DELETE LT_REF WHERE KIND = 'LCLS'.
    DELETE LT_REF WHERE KIND = 'CLAS' AND ( NAME CP 'LCL*' OR NAME CP 'LIF*' ).

    DATA(LO_DDIC) = NEW LCL_DDIC( P_DEST ).
    LO_DDIC->LOAD( LT_REF ).
    LOOP AT LT_REF INTO DATA(LS_REF).
      LO_DDIC->EVALUATE( EXPORTING IS_REF = LS_REF IV_MAIN = OWNER_OF( LS_REF-UNIT )
                         CHANGING  CT_FIND = MT_FIND ).
    ENDLOOP.
  ENDMETHOD.

  METHOD LAYER2.
    DATA LT_ONE TYPE TT_FIND.
    DATA(LO_SYN) = NEW LCL_SYNTAX( MO_SRC ).
    LOOP AT MO_SRC->MT_MAINS INTO DATA(LV_MAIN).
      LT_ONE = LO_SYN->CHECK( CONV #( LV_MAIN ) ).
      APPEND LINES OF LT_ONE TO MT_FIND.
    ENDLOOP.
  ENDMETHOD.

  METHOD SET_COL.
    TRY.
        DATA(LO_COL) = IO_COLS->GET_COLUMN( IV_NAME ).
        LO_COL->SET_SHORT_TEXT( CONV #( IV_TEXT ) ).
        LO_COL->SET_MEDIUM_TEXT( CONV #( IV_TEXT ) ).
        LO_COL->SET_LONG_TEXT( CONV #( IV_TEXT ) ).
      CATCH CX_SALV_NOT_FOUND ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD DISPLAY.
    IF MT_FIND IS INITIAL.
      MESSAGE 'Tidak ada temuan' TYPE 'S'.
      RETURN.
    ENDIF.
    GT_FIND = MT_FIND.
    TRY.
        CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = DATA(LO_ALV)
                                CHANGING  T_TABLE      = GT_FIND ).
        LO_ALV->GET_FUNCTIONS( )->SET_ALL( ABAP_TRUE ).
        DATA(LO_COLS) = LO_ALV->GET_COLUMNS( ).
        LO_COLS->SET_OPTIMIZE( ABAP_TRUE ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'MAIN'     IV_TEXT = `Program utama` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'UNIT'     IV_TEXT = `Include/unit` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'LINE'     IV_TEXT = `Baris` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'LAYER'    IV_TEXT = `Lapis` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'SEVERITY' IV_TEXT = `Sev` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'CODE'     IV_TEXT = `Kode temuan` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'REF_OBJ'  IV_TEXT = `Objek dirujuk` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'DETAIL'   IV_TEXT = `Detail` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'ACTION'   IV_TEXT = `Saran tindakan` ).
        LO_ALV->GET_DISPLAY_SETTINGS( )->SET_LIST_HEADER(
          CONV #( COND STRING( WHEN MV_TITLE IS NOT INITIAL
                               THEN |{ MV_TITLE }: { LINES( GT_FIND ) } temuan|
                               ELSE |ZS4CCA - { LINES( GT_FIND ) } temuan (L1 diff DDIC, L2 syntax S/4)| ) ) ).
        LO_ALV->DISPLAY( ).
      CATCH CX_SALV_MSG INTO DATA(LX_SALV).
        MESSAGE LX_SALV TYPE 'I'.
    ENDTRY.
  ENDMETHOD.

  METHOD FIX.
    DATA: LT_PRE   TYPE SALV_T_ROW,
          LT_SEL   TYPE TT_CHG,
          LT_MAINS TYPE STRING_TABLE,
          LT_LOG   TYPE STRING_TABLE,
          LV_ANS   TYPE C LENGTH 1.

    DATA(LO_FIX) = NEW LCL_FIXER( MO_SRC ).
    GT_CHG = LO_FIX->PROPOSE( ).
    IF GT_CHG IS INITIAL.
      MESSAGE 'Tidak ada usulan perbaikan otomatis' TYPE 'S'.
      RETURN.
    ENDIF.

    LOOP AT GT_CHG INTO DATA(LS_C).
      IF LS_C-RISK <> 'E'.
        APPEND SY-TABIX TO LT_PRE.
      ENDIF.
    ENDLOOP.

    TRY.
        CL_SALV_TABLE=>FACTORY( IMPORTING R_SALV_TABLE = DATA(LO_ALV)
                                CHANGING  T_TABLE      = GT_CHG ).
        LO_ALV->GET_FUNCTIONS( )->SET_ALL( ABAP_TRUE ).
        DATA(LO_SEL) = LO_ALV->GET_SELECTIONS( ).
        LO_SEL->SET_SELECTION_MODE( IF_SALV_C_SELECTION_MODE=>ROW_COLUMN ).
        LO_SEL->SET_SELECTED_ROWS( LT_PRE ).
        DATA(LO_COLS) = LO_ALV->GET_COLUMNS( ).
        LO_COLS->SET_OPTIMIZE( ABAP_TRUE ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'UNIT'   IV_TEXT = `Include/unit` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'LINE'   IV_TEXT = `Baris` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'RULE'   IV_TEXT = `Aturan` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'RISK'   IV_TEXT = `Risiko` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'BEFORE' IV_TEXT = `Sebelum` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'AFTER'  IV_TEXT = `Sesudah` ).
        SET_COL( IO_COLS = LO_COLS IV_NAME = 'NOTE'   IV_TEXT = `Catatan` ).
        LO_ALV->GET_DISPLAY_SETTINGS( )->SET_LIST_HEADER(
          CONV #( |ZS4CCA F3 - { LINES( GT_CHG ) } usulan (E = manual, W = periksa)| ) ).
        LO_ALV->DISPLAY( ).
        DATA(LT_ROWS) = LO_SEL->GET_SELECTED_ROWS( ).
      CATCH CX_SALV_MSG INTO DATA(LX_SALV).
        MESSAGE LX_SALV TYPE 'I'.
        RETURN.
    ENDTRY.

    LOOP AT LT_ROWS INTO DATA(LV_IDX).
      READ TABLE GT_CHG INTO DATA(LS_PICK) INDEX LV_IDX.
      IF SY-SUBRC = 0 AND LS_PICK-RISK <> 'E'.
        APPEND LS_PICK TO LT_SEL.
      ENDIF.
    ENDLOOP.
    IF LT_SEL IS INITIAL.
      MESSAGE 'Tidak ada baris yang diterapkan' TYPE 'S'.
      RETURN.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'ZS4CCA - Terapkan perbaikan'
        TEXT_QUESTION         = |Terapkan { LINES( LT_SEL ) } perbaikan? Salinan _ECC6 ditulis ke $TMP ADB. Program asli dan ECC tidak diubah.|
        TEXT_BUTTON_1         = 'Terapkan'
        TEXT_BUTTON_2         = 'Batal'
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = ' '
      IMPORTING
        ANSWER                = LV_ANS
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1
        OTHERS                = 2.
    IF SY-SUBRC <> 0 OR LV_ANS <> '1'.
      RETURN.
    ENDIF.

    LO_FIX->APPLY( EXPORTING IT_CHG = LT_SEL
                   IMPORTING ET_MAINS = LT_MAINS ET_LOG = LT_LOG ).
    CL_DEMO_OUTPUT=>DISPLAY( LT_LOG ).
    VERIFY( LT_MAINS ).
  ENDMETHOD.

  METHOD VERIFY.
    IF IT_MAINS IS INITIAL.
      RETURN.
    ENDIF.
    DATA(LO_VSRC) = NEW LCL_SOURCE( IV_MODE = 'ADB' ).
    LOOP AT IT_MAINS INTO DATA(LV_M).
      LO_VSRC->LOAD_PROGRAM( IV_NAME = CONV #( LV_M ) IV_IS_MAIN = ABAP_TRUE ).
    ENDLOOP.
    DATA(LO_V) = NEW LCL_RUNNER( ).
    LO_V->MV_TITLE = `Verifikasi salinan _ECC6 (L1 + L2 setelah perbaikan)`.
    LO_V->ANALYZE( LO_VSRC ).
    LO_V->DISPLAY( ).
  ENDMETHOD.

ENDCLASS.