*&---------------------------------------------------------------------*
*& Report  ZMMR_LABELROL_NONSAP
*&  Appl. Area :  Label
*&  Created by :  Oskar
*&  Created on :  17 July 2023
*&  Reference  :  ZMMR_LABELROL_NONSAP
*%---------------------------------------------------------------------*

REPORT  ZMMR_LABELROL_NONSAP.

TABLES: MCHB.

TYPES: BEGIN OF TY_ITAB,
  LABEL TYPE STRING,
  VBARCODE128 TYPE STRING,
  VROLL2 TYPE STRING.
        INCLUDE STRUCTURE ZLABEL_WINDOWS.
TYPES: END OF TY_ITAB.

DATA: BEGIN OF IT_CHARG OCCURS 0,
  CHARG LIKE MCHB-CHARG,
  MATNR LIKE MCHB-MATNR,
END OF IT_CHARG.

DATA: ITAB TYPE TABLE OF TY_ITAB WITH HEADER LINE.

DATA: WAAB TYPE TY_ITAB.

DATA: IT_MAP LIKE ZMAP_LABEL OCCURS 0 WITH HEADER LINE.

DATA: V_TAB TYPE API_VALI OCCURS 0 WITH HEADER LINE.

DATA: V_POSTDATE LIKE SY-DATUM,
      V_EXPDATE LIKE SY-DATUM,
      V_MESSAGE(50),
      V_ERR(1).

DATA: V_DEF_INCH TYPE P DECIMALS 5 VALUE '0.03937',
      V_DEF_FEET TYPE P DECIMALS 2 VALUE '3.28',
      V_DEF_LBS TYPE P DECIMALS 4 VALUE '2.2046',
      V_DEF_GAU TYPE P DECIMALS 4 VALUE '4'.

DATA: TOCHAR TYPE P DECIMALS 0,
      TOCHAR1 TYPE P DECIMALS 3,
      TOCHAR2 TYPE P DECIMALS 2,
      TOSTRG TYPE STRING.


SELECT-OPTIONS: P_CHARG FOR MCHB-CHARG.
PARAMETER: V_COPIES(3) DEFAULT '1'.

START-OF-SELECTION.
  PERFORM GET_DATA_MAIN.
  IF V_ERR EQ 'X'.
    MESSAGE V_MESSAGE TYPE 'I'.
    EXIT.
  ELSEIF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan' TYPE 'I'.
    EXIT.
  ELSE.
    PERFORM PRINT_DATA.
  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_MAIN.

  REFRESH: IT_CHARG.
  LOOP AT P_CHARG.
    SELECT SINGLE CHARG MATNR INTO IT_CHARG FROM MCH1
    WHERE CHARG = P_CHARG-LOW.
    IF SY-SUBRC = 0.
      APPEND IT_CHARG.
    ENDIF.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.

  LOOP AT IT_CHARG.

    IF IT_CHARG-CHARG IS NOT INITIAL AND IT_CHARG-MATNR IS NOT INITIAL.
      REFRESH V_TAB.
      CLEAR V_TAB.
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = IT_CHARG-MATNR
          I_VAL_CHARGE   = IT_CHARG-CHARG
        TABLES
          T_VAL_TAB      = V_TAB
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.
    ENDIF.

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP FROM ZMAP_LABEL WHERE CODE = V_TAB-ATWRT.
      IF SY-SUBRC EQ 0.
        READ TABLE IT_MAP INDEX 1.
      ENDIF.
    ENDIF.

    "Get Main Characteristic
    LOOP AT V_TAB.

      ITAB-VBATCH = IT_CHARG-CHARG.
      ITAB-VBARCODE128 = IT_CHARG-CHARG.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        ITAB-VTYPE = V_TAB-ATWTB.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-VTYPE = V_TAB-ATWRT.
        ENDIF.
      ELSEIF V_TAB-ATNAM = 'ZZTHICKNESS'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VTHICK = TOSTRG.
        PERFORM CONV_TO_CHAR USING ITAB-VTHICK.
        PERFORM GET_CONVERSION USING 'THICK' ITAB-VTHICK CHANGING ITAB-VGAUGE.
        PERFORM CONV_TO_CHAR USING ITAB-VGAUGE.
      ELSEIF V_TAB-ATNAM = 'ZZWIDTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VWIDTH = TOSTRG.
        PERFORM CONV_TO_CHAR USING ITAB-VWIDTH.
        PERFORM GET_CONVERSION USING 'WIDTH' ITAB-VWIDTH CHANGING ITAB-VINCHI.
        PERFORM CONV_TO_CHAR USING ITAB-VINCHI.
      ELSEIF V_TAB-ATNAM = 'ZZLENGTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VLENGTH = TOSTRG.
        PERFORM GET_CONVERSION USING 'LENGTH' ITAB-VLENGTH CHANGING ITAB-VFEET.
        PERFORM SEPARATOR_COMMA USING ITAB-VLENGTH.
        PERFORM SEPARATOR_COMMA USING ITAB-VFEET.
      ELSEIF V_TAB-ATNAM = 'ZZCONVERSIONROLLKG'.
        TOCHAR2 = V_TAB-ATFLV.
        ITAB-VNWEIGHT = TOCHAR2.
        CONDENSE ITAB-VNWEIGHT NO-GAPS.
        PERFORM CONV_TO_CHAR USING ITAB-VNWEIGHT.
        PERFORM GET_CONVERSION USING 'WEIGHT' ITAB-VNWEIGHT CHANGING ITAB-VLBS.
        PERFORM CONV_TO_CHAR USING ITAB-VLBS.
      ELSEIF V_TAB-ATNAM = 'ZZINSIDE'.
        ITAB-VINSIDE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZOUTSIDE'.
        ITAB-VOUTSIDE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZCORE'.
        ITAB-VCORE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZEXPIREDLIVE'.
        ITAB-VLIVE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZNOMORROLL'.
        ITAB-VROLL = V_TAB-ATWTB.
        ITAB-VROLL2 = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZSPLICE-1'.
        ITAB-VSPLICE1 = V_TAB-ATWTB.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        PERFORM GET_CONVERSION USING 'LENGTH' TOSTRG CHANGING ITAB-VSPFEET1.
        PERFORM SEPARATOR_COMMA USING ITAB-VSPLICE1.
        PERFORM SEPARATOR_COMMA USING ITAB-VSPFEET1.
      ELSEIF V_TAB-ATNAM = 'ZZSPLICE-2'.
        ITAB-VSPLICE2 = V_TAB-ATWTB.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        PERFORM GET_CONVERSION USING 'LENGTH' TOSTRG CHANGING ITAB-VSPFEET2.
        PERFORM SEPARATOR_COMMA USING ITAB-VSPLICE2.
        PERFORM SEPARATOR_COMMA USING ITAB-VSPFEET2.
      ELSEIF V_TAB-ATNAM = 'ZZLABEL'.
        ITAB-LABEL = V_TAB-ATWRT.
      ENDIF.
    ENDLOOP.

    PERFORM GET_SO.
    PERFORM GET_DATE.
    PERFORM GET_CORE.

    PERFORM ESCAPE_DOUBLE_QUOTES.

    DO V_COPIES TIMES.
      APPEND ITAB.
    ENDDO.
    CLEAR: ITAB.
  ENDLOOP.

ENDFORM.                    "GET_DATA_MAIN


*&---------------------------------------------------------------------*
*&      Form  PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_DATA.
  DATA: LV_PARAMETER  TYPE STRING,
        LV_RESULT TYPE STRING,
        LT_PARAMETERS TYPE TY_ITAB.

  DATA LO_SERIALIZER TYPE REF TO CL_TREX_JSON_SERIALIZER.
  DATA LV_PARAMETER_JSON TYPE STRING.
  DATA O_WRITER_ITAB TYPE REF TO CL_SXML_STRING_WRITER.

  LOOP AT ITAB INTO WAAB.
    LT_PARAMETERS = WAAB.
    O_WRITER_ITAB = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).

    CALL TRANSFORMATION ID
    SOURCE VALUES = LT_PARAMETERS
    RESULT XML O_WRITER_ITAB.

    CL_ABAP_CONV_IN_CE=>CREATE( )->CONVERT(
    EXPORTING
      INPUT = O_WRITER_ITAB->GET_OUTPUT( )
    IMPORTING
    DATA = LV_PARAMETER_JSON
          ).

    REPLACE ALL OCCURRENCES OF '"' IN LV_PARAMETER_JSON WITH '\"'.

    CONCATENATE '"' LV_PARAMETER_JSON '"' INTO LV_PARAMETER_JSON.

    CONCATENATE 'print --data=' LV_PARAMETER_JSON INTO LV_PARAMETER.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
      EXPORTING
        APPLICATION            = 'C:\tslabel\kanaoka\label.exe'
        PARAMETER              = LV_PARAMETER
        MINIMIZED              = 'X'
      EXCEPTIONS
        CNTL_ERROR             = 1
        ERROR_NO_GUI           = 2
        BAD_PARAMETER          = 3
        FILE_NOT_FOUND         = 4
        PATH_NOT_FOUND         = 5
        FILE_EXTENSION_UNKNOWN = 6
        ERROR_EXECUTE_FAILED   = 7
        SYNCHRONOUS_FAILED     = 8
        NOT_SUPPORTED_BY_GUI   = 9
        OTHERS                 = 10.

    IF SY-SUBRC NE 0.
      MESSAGE 'Print failed, please contact IT Administrator.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_CONVERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MODE          text
*      -->BERFORE_DATA  text
*      -->AFTER_DATA    text
*----------------------------------------------------------------------*
FORM GET_CONVERSION USING MODE BERFORE_DATA CHANGING AFTER_DATA.
  IF MODE EQ 'LENGTH'.
    CLEAR TOCHAR.
    TOCHAR  = BERFORE_DATA * V_DEF_FEET.
    AFTER_DATA = TOCHAR.
  ELSEIF MODE EQ 'WIDTH'.
    CLEAR TOCHAR2.
    TOCHAR2 = BERFORE_DATA * V_DEF_INCH.
    AFTER_DATA = TOCHAR2.
  ELSEIF MODE EQ 'WEIGHT'.
    CLEAR TOCHAR2.
    TOCHAR2 = BERFORE_DATA * V_DEF_LBS.
    AFTER_DATA = TOCHAR2.
  ELSEIF MODE EQ 'THICK'.
    CLEAR TOCHAR2.
    TOCHAR = BERFORE_DATA * V_DEF_GAU.
    AFTER_DATA = TOCHAR.
  ENDIF.

  CONDENSE AFTER_DATA.
ENDFORM.                    "GET_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  SEPARATOR_COMMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DATA       text
*----------------------------------------------------------------------*
FORM SEPARATOR_COMMA USING DATA.
  DATA: V_CURR LIKE TCURX-CURRKEY.

  V_CURR = DATA.

  CALL FUNCTION 'SD_CONVERT_CURRENCY_FORMAT'
    EXPORTING
      I_CURRENCY            = V_CURR
    CHANGING
      C_CURRENCY_EXT_FORMAT = DATA
    EXCEPTIONS
      WRONG_FORMAT          = 1
      OTHERS                = 2.

  REPLACE '.00' IN DATA WITH SPACE.
  CONDENSE DATA.
ENDFORM.                    "SEPARATOR_COMMA

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DATA       text
*----------------------------------------------------------------------*
FORM CONV_TO_CHAR USING DATA.
  DATA: V_IN TYPE P DECIMALS 2,
        V_DEC TYPE P DECIMALS 2,
        V_OUT(25).

  CLEAR: V_IN, V_DEC, V_OUT.

  V_IN = DATA.
  V_DEC = FRAC( V_IN ).

  IF V_DEC = 0.
    WRITE V_IN TO V_OUT NO-GROUPING DECIMALS 0.
  ELSE.
    WRITE V_IN TO V_OUT NO-GROUPING DECIMALS 2.
  ENDIF.

  CONDENSE V_OUT NO-GAPS.
  DATA = V_OUT.
ENDFORM.                    "CONV_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  GET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATE.
  CLEAR: V_POSTDATE, V_EXPDATE.

  CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
    EXPORTING
      MATNR = IT_CHARG-MATNR
      CHARG = IT_CHARG-CHARG
    IMPORTING
      PDATE = V_POSTDATE.

  IF IT_MAP-TEXT4 EQ 'USEDBEFORE'.
    V_EXPDATE = V_POSTDATE + ITAB-VLIVE.
    ITAB-VUSED = V_EXPDATE(4) && '.' && V_EXPDATE+4(2).
  ELSEIF IT_MAP-TEXT4 EQ 'MANUFDATE'.
    ITAB-VPOSTDATE = V_POSTDATE(4) && '.' && V_POSTDATE+4(2).
  ENDIF.

ENDFORM.                    "GET_DATE

*&---------------------------------------------------------------------*
*&      Form  GET_CORE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_CORE.
  DATA: V_CORE_SS(3) TYPE C.

  IF IT_MAP-TEXT5 EQ 'CORE1'.
  ELSEIF IT_MAP-TEXT5 EQ 'CORE2'.
    SPLIT ITAB-VCORE AT '(' INTO ITAB-VCORE V_CORE_SS.
    SHIFT V_CORE_SS BY 1 PLACES RIGHT.
    SHIFT V_CORE_SS LEFT DELETING LEADING SPACE.
    CONCATENATE V_CORE_SS '(' ITAB-VCORE ')' INTO ITAB-VCORE.
  ELSE.
    SPLIT ITAB-VCORE AT '(' INTO ITAB-VCORE V_CORE_SS.
    SHIFT V_CORE_SS BY 1 PLACES RIGHT.
    SHIFT V_CORE_SS LEFT DELETING LEADING SPACE.
    ITAB-VCORE = V_CORE_SS.
  ENDIF.

ENDFORM.                    "GET_CORE

*&---------------------------------------------------------------------*
*&      Form  GET_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_SO.
  DATA: V_TDNAME LIKE THEAD-TDNAME,
        IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE VBELN POSNR INTO (ITAB-VVBELN, ITAB-VPOSNR) FROM MSKA
   WHERE MATNR = IT_CHARG-MATNR
     AND CHARG = IT_CHARG-CHARG
     AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

  IF IT_MAP-TEXT3 CS 'SOTEXT'.
    CONCATENATE ITAB-VVBELN ITAB-VPOSNR INTO V_TDNAME.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = 'Z001'
        LANGUAGE                = 'E'
        NAME                    = V_TDNAME
        OBJECT                  = 'VBBP'
      TABLES
        LINES                   = IT_LINES
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.

    IF SY-SUBRC = 0.
      LOOP AT IT_LINES.
        IF IT_LINES-TDLINE+0(2) = 'L2'.
          ITAB-VFEET = IT_LINES-TDLINE+3(20).
        ELSEIF IT_LINES-TDLINE+0(2) = 'W2'.
          ITAB-VINCHI  = IT_LINES-TDLINE+3(20).
        ELSEIF IT_LINES-TDLINE+0(2) = 'N2'.
          ITAB-VLBS  = IT_LINES-TDLINE+3(20).
        ELSEIF IT_LINES-TDLINE+0(2) = 'T2'.
          ITAB-VGAUGE = IT_LINES-TDLINE+3(20).
        ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE 'SO item text not found, call the PPIC!' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF IT_MAP-TEXT3 CS 'ALL'.
    SELECT SINGLE KDMAT INTO ITAB-VPOINT FROM VBAP WHERE VBELN = ITAB-VVBELN AND POSNR = ITAB-VPOSNR.
    SELECT SINGLE BSTNK INTO ITAB-VPARTNO FROM VBAK WHERE VBELN EQ ITAB-VVBELN.
  ELSE.
    IF IT_MAP-TEXT3 CS 'PONUMBER'.
      SELECT SINGLE KDMAT INTO ITAB-VPOINT FROM VBAP WHERE VBELN = ITAB-VVBELN AND POSNR = ITAB-VPOSNR.
    ENDIF.

    IF IT_MAP-TEXT3 CS 'PARTNO'.
      SELECT SINGLE BSTNK INTO ITAB-VPARTNO FROM VBAK WHERE VBELN EQ ITAB-VVBELN.
    ENDIF.
  ENDIF.

  PERFORM OUTPUT_FORMAT USING ITAB-VVBELN CHANGING ITAB-VVBELN.
  PERFORM OUTPUT_FORMAT USING ITAB-VPOSNR CHANGING ITAB-VPOSNR.

  IF ITAB-VVBELN IS NOT INITIAL AND ITAB-VPOSNR IS NOT INITIAL.
    ITAB-VSONUM_ITEM = ITAB-VVBELN && '/' && ITAB-VPOSNR.
  ENDIF.
ENDFORM.                    "GET_SO


*&---------------------------------------------------------------------*
*&      Form  OUTPUT_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM OUTPUT_FORMAT USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "OUTPUT_FORMAT

*&---------------------------------------------------------------------*
*&      Form  escape_double_quotes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ESCAPE_DOUBLE_QUOTES.
  REPLACE ALL OCCURRENCES OF '"' IN ITAB-VCORE WITH '#INCH'.
ENDFORM.                    "escape_double_quotes