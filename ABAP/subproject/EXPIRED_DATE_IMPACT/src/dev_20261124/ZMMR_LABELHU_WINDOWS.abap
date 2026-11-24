*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_LABELHU_WINDOWS                                 *
*&  Appl. Area :  MM                                                   *
*&  Created by :  J. Budi                                              *
*&  Created on :  11 July 2023                                         *
*&---------------------------------------------------------------------*

REPORT  ZMMR_LABELHU_WINDOWS.

TABLES: MCHB.

DATA : V_FORMNAME TYPE TDSFNAME,
       V_FUNCNAME TYPE RS38L_FNAM,
       V_TAB TYPE API_VALI OCCURS 0 WITH HEADER LINE,
       CONTROL_PARAMETERS TYPE SSFCTRLOP,
       OUTPUT_OPTIONS TYPE SSFCOMPOP.

DATA: ITAB LIKE ZLABEL_WINDOWS OCCURS 0 WITH HEADER LINE.
DATA: IT_MAP LIKE ZMAP_LABEL OCCURS 0 WITH HEADER LINE.

DATA: V_DEF_INCH TYPE P DECIMALS 5 VALUE '0.03937',
      V_DEF_FEET TYPE P DECIMALS 2 VALUE '3.28',
      V_DEF_LBS TYPE P DECIMALS 4 VALUE '2.2046',
      V_DEF_GAU TYPE P DECIMALS 4 VALUE '4'.

DATA: TOCHAR TYPE P DECIMALS 0,
      TOCHAR1 TYPE P DECIMALS 3,
      TOCHAR2 TYPE P DECIMALS 2,
      TOSTRG TYPE STRING,
      V_POSTDATE LIKE SY-DATUM,
      V_EXPDATE LIKE SY-DATUM,
      V_CERTIFICATE1 LIKE AUSP-ATWRT,
      V_CERTIFICATE2 LIKE AUSP-ATWRT,
      V_CERTIFICATE3 LIKE AUSP-ATWRT,
      V_CERTIFICATE4 LIKE AUSP-ATWRT,
      V_LABELTYPE    LIKE AUSP-ATWRT, "Add Variabel Label Type by Fiqih - 27.01.2026
      V_MESSAGE(50),
      V_ERR(1).

DATA: BEGIN OF IT_CHARG OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        MATNR LIKE MCHB-MATNR,
      END OF IT_CHARG.

PARAMETER: V_CHARG LIKE MCHB-CHARG,
           V_EXIDV LIKE MCHB-MATNR,
           V_MATNR LIKE MARA-MATNR,
           V_TOTRL(4) NO-DISPLAY,             "Get Total Roll
           V_TOTBX(4) NO-DISPLAY,             "Get Total Box
           V_TMWGHT TYPE P DECIMALS 2.

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

  "Get data Batch & Material
  REFRESH: IT_CHARG.
  SELECT SINGLE CHARG MATNR INTO IT_CHARG FROM MCH1 WHERE CHARG = V_CHARG.
  IF SY-SUBRC = 0.
    APPEND IT_CHARG.
  ENDIF.
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
      V_LABELTYPE = V_TAB-ATWRT. "Add Variabel Label Type by Fiqih - 27.01.2026
      SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP FROM ZMAP_LABEL WHERE CODE = V_TAB-ATWRT.
      IF SY-SUBRC EQ 0.
        READ TABLE IT_MAP INDEX 1.
        V_FORMNAME = IT_MAP-FORM_HU.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

    "Get Main Characteristic
    SORT V_TAB BY ATNAM ASCENDING.
    LOOP AT V_TAB.
      PERFORM OUTPUT_FORMAT USING V_EXIDV CHANGING ITAB-VBATCH.
      IF V_TAB-ATNAM = 'ZZCODE'.
        ITAB-VTYPE = V_TAB-ATWTB.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-VTYPE = V_TAB-ATWRT.
        ENDIF.
      ELSEIF V_TAB-ATNAM = 'ZZTHICKNESS'.
        TOCHAR2 = V_TAB-ATFLV.
        TOSTRG = TOCHAR2.
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
      ELSEIF V_TAB-ATNAM = 'ZZSPECIALTOUCH-1'.
        ITAB-VBARCTEXTTRIAS = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZSPECIALTOUCH-2'.
        ITAB-VBARCODETRIAS = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZSPECIALTOUCH-3'.
        ITAB-VBARCODECUST = V_TAB-ATWTB.
        SPLIT ITAB-VBARCODECUST AT ':' INTO V_CERTIFICATE1 V_CERTIFICATE2 V_CERTIFICATE3 V_CERTIFICATE4.
        PERFORM CHECK_CERTIFICATE USING V_CERTIFICATE1.
        PERFORM CHECK_CERTIFICATE USING V_CERTIFICATE2.
        PERFORM CHECK_CERTIFICATE USING V_CERTIFICATE3.
        PERFORM CHECK_CERTIFICATE USING V_CERTIFICATE4.
      ENDIF.
    ENDLOOP.

    ITAB-VTOTROL    = V_TOTRL.
    ITAB-VTOTBOX    = V_TOTBX.
    ITAB-VNWEIGHT   = V_TMWGHT.
    CONDENSE ITAB-VTOTROL.
    CONDENSE ITAB-VTOTBOX.
    CONDENSE ITAB-VNWEIGHT.
    PERFORM GET_CONVERSION USING 'WEIGHT' V_TMWGHT CHANGING ITAB-VLBS.

    PERFORM CHECK_IMAGE.
    PERFORM CHECK_HEADER.
    PERFORM GET_SO.
    PERFORM GET_DATE.
    PERFORM GET_CORE.

    APPEND ITAB.
    CLEAR: ITAB.
  ENDLOOP.

ENDFORM.                    "GET_DATA_MAIN

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
*&      Form  CHECK_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_IMAGE.
  SELECT SINGLE TDNAME INTO ITAB-VIMAGE FROM STXBITMAPS WHERE TDID = 'BMAP' AND TDOBJECT = 'GRAPHICS' AND TDNAME = IT_MAP-TEXT1.
  IF SY-SUBRC NE 0 AND IT_MAP-TEXT1 IS NOT INITIAL.
    CONCATENATE 'Image' IT_MAP-TEXT1 'not found...!' INTO V_MESSAGE SEPARATED BY SPACE.
    MESSAGE V_MESSAGE TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    "CHECK_IMAGE

*&---------------------------------------------------------------------*
*&      Form  CHECK_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_HEADER.
  ITAB-VHEADER = IT_MAP-TEXT2.
ENDFORM.                    "CHECK_HEADER

*&---------------------------------------------------------------------*
*&      Form  CHECK_CERTIFICATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_IMAGE    text
*----------------------------------------------------------------------*
FORM CHECK_CERTIFICATE USING V_IMAGE.
  IF V_IMAGE IS NOT INITIAL.
    CONCATENATE 'Z' V_IMAGE INTO V_IMAGE.
    SELECT SINGLE TDNAME INTO V_IMAGE FROM STXBITMAPS WHERE TDID = 'BMAP' AND TDOBJECT = 'GRAPHICS' AND TDNAME = V_IMAGE.
    IF SY-SUBRC NE 0 AND V_IMAGE IS NOT INITIAL.
      CONCATENATE 'Certificate' V_IMAGE+1 'not found...!' INTO V_MESSAGE SEPARATED BY SPACE.
      MESSAGE V_MESSAGE TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_CERTIFICATE

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
  ELSE.
    V_EXPDATE = V_POSTDATE + ITAB-VLIVE.
    ITAB-VEXPDATE  = V_EXPDATE(4) && '.' && V_EXPDATE+4(2) && '.' && V_EXPDATE+6(2).
    ITAB-VPOSTDATE = V_POSTDATE(4) && '.' && V_POSTDATE+4(2) && '.' && V_POSTDATE+6(2).
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
  ELSEIF IT_MAP-TEXT5 EQ 'CORE3'.
    SPLIT ITAB-VCORE AT '(' INTO ITAB-VCORE V_CORE_SS.
    SHIFT V_CORE_SS BY 1 PLACES RIGHT.
    SHIFT V_CORE_SS LEFT DELETING LEADING SPACE.
    ITAB-VCORE = V_CORE_SS.
  ELSE.
    CLEAR ITAB-VCORE.
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
      MESSAGE 'SO item text not found, call the PPIC!' TYPE 'I' DISPLAY LIKE 'S'.
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
*&      Form  PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_DATA.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CONTROL_PARAMETERS-NO_DIALOG = 'X'.
  CONTROL_PARAMETERS-PREVIEW = 'X'.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
      IV_LABELTYPE       = V_LABELTYPE "Add Variabel Label Type by Fiqih - 27.01.2026
    TABLES
      ITAB               = ITAB.

ENDFORM.                    "PRINT_DATA