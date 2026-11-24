*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_LABELHU_WINDOWS                                 *
*&  Appl. Area :  MM                                                   *
*&  Created by :  J. Budi                                              *
*&  Created on :  11 July 2023                                         *
*&---------------------------------------------------------------------*

REPORT  ZMMR_LABELHU_KTNG.

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
      V_MESSAGE(50),
      V_ERR(1),
      V_HU_NUMBER LIKE ZDETAIL_KTNG-HUCOUNT,
      V_SUPPCD(2).

DATA: BEGIN OF IT_CHARG OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        MATNR LIKE MCHB-MATNR,
      END OF IT_CHARG.

DATA: IT_DETAIL_KTNG LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE,
      WA_DETAIL_KTNG LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE.


DATA: IT_TEMP_DETAIL_KTNG LIKE ZDETAIL_KTNG OCCURS 0 WITH HEADER LINE. "Add by Fany at 23-06-2025 case duplicate HU number validation
DATA: V_ISDUPLICATE(1). "Add by Fany at 23-06-2025 case duplicate HU Number validation
DATA: BEGIN OF IT_HU OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        EXIDV LIKE VEKP-EXIDV,
        UNVEL LIKE VEPO-UNVEL,
      END OF IT_HU.

DATA: BEGIN OF IT_HU2 OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        EXIDV LIKE VEKP-EXIDV,
        UNVEL LIKE VEPO-UNVEL,
      END OF IT_HU2.

PARAMETER: V_CHARG LIKE MCHB-CHARG,
           V_EXIDV LIKE MCHB-MATNR,
           V_MATNR LIKE MARA-MATNR,
           V_VBELN LIKE MSKA-VBELN,
           V_POSNR LIKE MSKA-POSNR,
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
      SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_MAP FROM ZMAP_LABEL WHERE CODE = V_TAB-ATWRT.
      IF SY-SUBRC EQ 0.
        READ TABLE IT_MAP INDEX 1.
        V_FORMNAME = IT_MAP-FORM_HU.
        V_SUPPCD  = IT_MAP-TEXT1.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.

    "Check SO
    SELECT SINGLE VBELN POSNR INTO (ITAB-VVBELN, ITAB-VPOSNR)
      FROM MSKA
     WHERE MATNR = IT_CHARG-MATNR
       AND CHARG = IT_CHARG-CHARG
       AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

    "Get Cust Material
    IF SY-SUBRC = 0.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VVBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VPOSNR
        IMPORTING
          OUTPUT = V_POSNR.
      CONCATENATE V_VBELN V_POSNR INTO ITAB-VSONUM_ITEM SEPARATED BY '/'.
    ENDIF.

    ITAB-VDERIVATIVEMS  = '00'.
    ITAB-VPOSITIONMS    = '00'.
    ITAB-VDERIVATIVESS  = '00'.
    ITAB-VPOSITIONSS    = '00'.

    PERFORM OUTPUT_FORMAT USING V_EXIDV CHANGING ITAB-VBATCH.

    "Get Main Characteristic
    LOOP AT V_TAB.
      IF V_TAB-ATNAM = 'ZZCODE'.
        ITAB-VTYPE = V_TAB-ATWTB.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-VTYPE = V_TAB-ATWRT.
        ENDIF.
        SPLIT ITAB-VTYPE AT '-' INTO ITAB-VTYPE ITAB-VTHICK.
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
      ELSEIF V_TAB-ATNAM = 'ZZINSIDE'.
        ITAB-VINSIDE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZOUTSIDE'.
        ITAB-VOUTSIDE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZCORE'.
        ITAB-VCORE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZEXPIREDLIVE'.
        ITAB-VLIVE = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZNOMORROLL'.
        ITAB-VROLL = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
        ITAB-VDERIVATIVEMS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
        ITAB-VPOSITIONMS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
        ITAB-VDERIVATIVESS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
        ITAB-VPOSITIONSS = V_TAB-ATWRT.
      ENDIF.
    ENDLOOP.

    CONCATENATE IT_CHARG-CHARG ITAB-VDERIVATIVEMS ITAB-VPOSITIONMS ITAB-VDERIVATIVESS ITAB-VPOSITIONSS INTO ITAB-VBARCODETRIAS.

    CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
      EXPORTING
        INPUT          = ITAB-VBARCODETRIAS
      IMPORTING
        OUTPUT         = ITAB-VBARCODETRIAS
      EXCEPTIONS
        INVALID_FORMAT = 1
        OTHERS         = 2.

    CONCATENATE IT_CHARG-CHARG '-' ITAB-VBARCODETRIAS INTO ITAB-VBARCTEXTTRIAS.

    ITAB-VTOTROL    = V_TOTRL.
    ITAB-VTOTBOX    = V_TOTBX.
    ITAB-VNWEIGHT   = V_TMWGHT.
    CONDENSE ITAB-VTOTROL.
    CONDENSE ITAB-VTOTBOX.
    CONDENSE ITAB-VNWEIGHT.
    PERFORM GET_CONVERSION USING 'WEIGHT' V_TMWGHT CHANGING ITAB-VLBS.
    PERFORM GET_HU_NUMBER.

    APPEND ITAB.
    CLEAR: ITAB.
  ENDLOOP.

ENDFORM.                    "GET_DATA_MAIN

*&---------------------------------------------------------------------*
*&      Form  GET_HU_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_HU_NUMBER.
  DATA: HDR    LIKE BAPIHUHEADER OCCURS 2 WITH HEADER LINE,
        ITM    LIKE BAPIHUITEM OCCURS 2 WITH HEADER LINE,
        HUNUMB LIKE BAPIHUNUMBER OCCURS 2 WITH HEADER LINE,
        RETRN  LIKE BAPIRET2 OCCURS 2 WITH HEADER LINE.

  REFRESH: HUNUMB, HDR, ITM, RETRN.
  CLEAR: V_HU_NUMBER, HUNUMB.

  PERFORM INPUT_FORMAT USING V_EXIDV CHANGING HUNUMB-HU_EXID.
  APPEND HUNUMB.

  CLEAR : IT_HU.
  REFRESH : IT_HU.

  SELECT B~CHARG A~EXIDV B~UNVEL INTO CORRESPONDING FIELDS OF TABLE IT_HU FROM VEKP AS A
        JOIN VEPO AS B ON A~VENUM = B~VENUM
         WHERE A~EXIDV = HUNUMB-HU_EXID.

  LOOP AT IT_HU. "Get batch inside HU Box
   IF IT_HU-CHARG IS INITIAL OR IT_HU-CHARG EQ ''.
     SELECT SINGLE A~CHARG INTO IT_HU-CHARG FROM VEPO AS A WHERE A~VENUM = IT_HU-UNVEL.
     MODIFY IT_HU.
   ENDIF.
  ENDLOOP.



*  CALL FUNCTION 'BAPI_HU_GETLIST'
*    EXPORTING
*      NOTEXT    = ''
*      ONLYKEYS  = ''
*    TABLES
*      HUNUMBERS = HUNUMB
*      HUHEADER  = HDR
*      HUITEM    = ITM
*      RETURN    = RETRN.
*
*  DELETE ITM WHERE HU_EXID NE HUNUMB-HU_EXID.
*  DELETE HDR WHERE HU_EXID NE HUNUMB-HU_EXID.

  LOOP AT IT_HU WHERE CHARG IS NOT INITIAL.
    CLEAR: IT_DETAIL_KTNG.
    REFRESH: IT_DETAIL_KTNG.
    CLEAR: IT_TEMP_DETAIL_KTNG.
    REFRESH: IT_TEMP_DETAIL_KTNG.
    CLEAR : V_ISDUPLICATE.
    V_ISDUPLICATE = 'X'.

    "Cek batch
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF IT_DETAIL_KTNG FROM ZDETAIL_KTNG WHERE BATCH = IT_HU-CHARG AND DELETION = ''.
    IF SY-SUBRC EQ 0.
      ITAB-VPARTNO = IT_DETAIL_KTNG-KTNGCODE.
      CONCATENATE '20' IT_DETAIL_KTNG-JRDATE+0(2) INTO ITAB-VPOSTDATE.
      CONCATENATE ITAB-VPOSTDATE IT_DETAIL_KTNG-JRDATE+2(2) IT_DETAIL_KTNG-JRDATE+4(2) INTO ITAB-VPOSTDATE SEPARATED BY '/'.

      IF IT_DETAIL_KTNG-NOHU NE ''.
        V_HU_NUMBER = IT_DETAIL_KTNG-HUCOUNT.
        ITAB-VBARCODECUST = IT_DETAIL_KTNG-NOHU.
        ITAB-VBARCTEXTCUST = IT_DETAIL_KTNG-HUCOUNT.
*        EXIT.
      ELSE.
        IF V_HU_NUMBER IS INITIAL.
          SELECT MAX( HUCOUNT ) INTO V_HU_NUMBER FROM ZDETAIL_KTNG WHERE JRDATE EQ IT_DETAIL_KTNG-JRDATE AND DELETION = ''.
          IF SY-SUBRC EQ 0.
            ADD 1 TO V_HU_NUMBER.
            PERFORM INPUT_FORMAT USING V_HU_NUMBER CHANGING V_HU_NUMBER.
          ENDIF.
        ENDIF.
        ITAB-VBARCTEXTCUST = V_HU_NUMBER.
        CONCATENATE 'P' IT_DETAIL_KTNG-KTNGCODE V_SUPPCD IT_DETAIL_KTNG-JRDATE '00' V_HU_NUMBER INTO ITAB-VBARCODECUST.
        PERFORM CHECK_DUPLICATE_NOHU USING V_HU_NUMBER IT_DETAIL_KTNG-KTNGCODE IT_DETAIL_KTNG-JRDATE IT_HU-EXIDV CHANGING ITAB-VBARCODECUST V_ISDUPLICATE.
        IF V_ISDUPLICATE NE 'X'.
          UPDATE ZDETAIL_KTNG SET HUCOUNT = V_HU_NUMBER NOHU = ITAB-VBARCODECUST WHERE BATCH = IT_HU-CHARG AND DELETION = ''.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "GET_HU_NUMBER
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
*&      Form  INPUT_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM INPUT_FORMAT USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "INPUT_FORMAT
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
    TABLES
      ITAB               = ITAB.
ENDFORM.                    "PRINT_DATA

FORM CHECK_DUPLICATE_NOHU USING V_HUCOUNT ITEMCODE JRDATE V_EXIDV CHANGING V_NOHU_NEW V_ISDUPLICATE.
  DATA : V_ISCHECKING TYPE C VALUE ''.
  WHILE V_ISCHECKING EQ ''.
    CLEAR : IT_TEMP_DETAIL_KTNG, IT_HU2.
    REFRESH : IT_TEMP_DETAIL_KTNG, IT_HU2.
    APPEND LINES OF IT_HU TO IT_HU2.
    CONCATENATE 'P' ITEMCODE V_SUPPCD JRDATE '00' V_HUCOUNT INTO V_NOHU_NEW.
    SELECT SINGLE * INTO CORRESPONDING FIELDS OF IT_TEMP_DETAIL_KTNG FROM ZDETAIL_KTNG WHERE NOHU = V_NOHU_NEW AND DELETION = ''.
    IF SY-SUBRC EQ 0.
       READ TABLE IT_HU2 WITH KEY CHARG = IT_TEMP_DETAIL_KTNG-BATCH.
       IF SY-SUBRC EQ 0 AND V_EXIDV EQ IT_HU2-EXIDV.
            V_ISCHECKING = 'X'.
            V_ISDUPLICATE = ''.
       ELSE.
            ADD 1 TO V_HUCOUNT.
            PERFORM INPUT_FORMAT USING V_HUCOUNT CHANGING V_HUCOUNT.
       ENDIF.
    ELSE.
       V_ISCHECKING = 'X'.
       V_ISDUPLICATE = ''.
    ENDIF.
  ENDWHILE.

ENDFORM.