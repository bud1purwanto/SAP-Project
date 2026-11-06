*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_LABELROL_DOCX
*&  Appl. Area :  Label
*&  Created by :  Oskar, J. Budi
*&  Created on :  10 November 2023
*%---------------------------------------------------------------------*

REPORT  ZMMR_LABELROL_DOCX.

TABLES: MCHB.

TYPES: BEGIN OF TY_ITAB,
        LABEL TYPE STRING,
        LDESC TYPE STRING,
        PACK TYPE STRING,
        CODE TYPE STRING.
        INCLUDE STRUCTURE ZLABEL_WINDOWS.
TYPES: END OF TY_ITAB.

DATA: BEGIN OF IT_CHARG OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        MATNR LIKE MCHB-MATNR,
END OF IT_CHARG.

DATA: ITAB TYPE TABLE OF TY_ITAB WITH HEADER LINE,
      IT_MAP LIKE ZMAP_LABEL OCCURS 0 WITH HEADER LINE,
      V_TAB TYPE API_VALI OCCURS 0 WITH HEADER LINE.

DATA: V_POSTDATE LIKE SY-DATUM,
      V_EXPDATE LIKE SY-DATUM,
      V_MESSAGE(50),
      V_TEMP(20),
      V_ERR(1),
      MSG(50).

DATA: V_DEF_INCH      TYPE P DECIMALS 5 VALUE '0.03937',
      V_DEF_FEET      TYPE P DECIMALS 2 VALUE '3.28',
      V_DEF_LBS       TYPE P DECIMALS 4 VALUE '2.2046',
      V_DEF_GAU       TYPE P DECIMALS 4 VALUE '4'.

DATA: TOCHAR          TYPE P DECIMALS 0,
      TOCHAR1         TYPE P DECIMALS 3,
      TOCHAR2         TYPE P DECIMALS 2,
      TOSTRG          TYPE STRING.

DATA: LV_LBUTIL_EXIST TYPE ABAP_BOOL,
      LV_DL_FE        TYPE ABAP_BOOL.

DATA: GS_DOCX_DATA    TYPE XSTRING,
      LV_DOCUMENT     TYPE XSTRING,
      FTP_PATH        LIKE DXFIELDS-LONGPATH ,
      FTP_DEFAULT     TYPE STRING VALUE '/spare/saplabel/saplabeldocx/',
      LV_LOG_BASE     TYPE STRING VALUE 'C:\tslabel\docx\log',
      LV_LOG_DIR      TYPE STRING VALUE 'C:\tslabel\docx\log\report',
      LV_VBATCH       TYPE STRING,
      LV_LOG_DIR_FILE TYPE STANDARD TABLE OF FILE_INFO,
      LV_DIR_FILE     TYPE FILE_INFO,
      LV_LOG_DIR_COUN TYPE I,
      LV_DEL_PATH     TYPE STRING,
      LV_RETCODE      TYPE I.


DATA: IT_TEMPZCODE TYPE TABLE OF STRING WITH HEADER LINE.

INCLUDE ZMMR_LABELROL_DOCX_INCL.

SELECT-OPTIONS: P_CHARG FOR MCHB-CHARG.
PARAMETER: V_COPIES(3) DEFAULT '1',
           V_CHARG    LIKE MCHB-CHARG  NO-DISPLAY,
           V_EXIDV    LIKE MCHB-MATNR  NO-DISPLAY,
           V_MATNR    LIKE MARA-MATNR  NO-DISPLAY,
           V_WERKS    LIKE VBDPL-WERKS NO-DISPLAY,
           V_MAGRV    LIKE VEKP-MAGRV  NO-DISPLAY,
           V_TOTRL(4) NO-DISPLAY,             "Get Total Roll
           V_TOTBX(4) NO-DISPLAY,             "Get Total Box
           V_DATDD(2) NO-DISPLAY,
           V_DATMM(2) NO-DISPLAY,
           V_DATYY(1) NO-DISPLAY,
           V_TMWGHT   NO-DISPLAY TYPE P DECIMALS 2.

START-OF-SELECTION.
  IF LV_LBUTIL_ACTIVE_VER EQ SPACE.
    PERFORM GET_ACTIVE_VERSION.
  ENDIF.

  PERFORM CHECK_FILE_EXISTANCE USING SPACE CHANGING LV_LBUTIL_EXIST.
  IF LV_LBUTIL_EXIST EQ ABAP_FALSE.
    PERFORM DOWNLOAD_FE USING SPACE SPACE CHANGING LV_DL_FE.
    IF LV_DL_FE EQ ABAP_FALSE.
      MESSAGE 'Failing when updating labelutils, please contact IT.' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM GET_DATA_MAIN.
  IF V_ERR EQ 'X'.
    MESSAGE V_MESSAGE TYPE 'I'.
    EXIT.
  ELSEIF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan' TYPE 'I'.
    EXIT.
  ELSE.
    PERFORM CLEAN_WORKING_DIR.
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
  "For Roll
  IF P_CHARG[] IS NOT INITIAL.
    LOOP AT P_CHARG.
      SELECT SINGLE CHARG MATNR INTO IT_CHARG FROM MCH1
      WHERE CHARG = P_CHARG-LOW.
      IF SY-SUBRC = 0.
        APPEND IT_CHARG.
      ENDIF.
    ENDLOOP.
  ELSE.
    "For HU
    SELECT SINGLE CHARG MATNR INTO IT_CHARG FROM MCH1 WHERE CHARG = V_CHARG.
    IF SY-SUBRC = 0.
      APPEND IT_CHARG.
    ENDIF.
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
      ENDIF.
    ENDIF.

    ITAB-VBATCH = IT_CHARG-CHARG.

    "Get Main Characteristic
    LOOP AT V_TAB.
      IF V_TAB-ATNAM = 'ZZCODE'.
        ITAB-VTYPE = V_TAB-ATWTB.
        DATA : V_SEPARATOR TYPE C VALUE '-'.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-VTYPE = V_TAB-ATWRT.
        ENDIF.
        CLEAR : V_TEMP.
        SPLIT ITAB-VTYPE AT V_SEPARATOR INTO TABLE IT_TEMPZCODE.
        IF LINES( IT_TEMPZCODE ) > 1.
          DELETE IT_TEMPZCODE INDEX LINES( IT_TEMPZCODE ).
        ENDIF.
        LOOP AT IT_TEMPZCODE.
           IF SY-TABIX EQ 1.
             CONCATENATE V_TEMP IT_TEMPZCODE INTO V_TEMP.
           ELSE.
             CONCATENATE V_TEMP IT_TEMPZCODE INTO V_TEMP SEPARATED BY V_SEPARATOR.
           ENDIF.
        ENDLOOP.
        ITAB-VTYPE = V_TEMP.
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
        ITAB-LDESC = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZPACKING'.
        ITAB-PACK = V_TAB-ATWRT.
      ENDIF.
    ENDLOOP.

    PERFORM GET_SO.
    PERFORM GET_DATE.
    PERFORM GET_CORE.
    PERFORM GET_MAPPING   USING ITAB-LDESC.
    PERFORM GET_HU        USING V_MAGRV V_WERKS V_EXIDV V_TOTRL V_TOTBX V_TMWGHT V_DATDD V_DATMM V_DATYY.
    PERFORM GET_ENCODE128 USING ITAB-VBATCH CHANGING ITAB-VBARCODETRIAS.

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

* Read template on SFTP
  LOOP AT ITAB.
    FTP_PATH = FTP_DEFAULT && ITAB-LABEL && '.docx'.
    CONCATENATE ITAB-VBATCH '.docx' INTO LV_VBATCH.

    PERFORM LOAD_TEMPLATE_XSTRING USING
                                  FTP_PATH
                                CHANGING
                                  GS_DOCX_DATA.

    ZCL_LABEL_DOCX=>GET_DOCUMENT(
      IV_TEMPLATE   = GS_DOCX_DATA
      IV_PATH       = LV_LOG_BASE
      IV_FILE_NAME  = LV_VBATCH
      IV_DATA       = ITAB
    ).

  ENDLOOP.

ENDFORM.                    "PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  CLEAN_WORKING_DIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CLEAN_WORKING_DIR.
  CL_GUI_FRONTEND_SERVICES=>DIRECTORY_LIST_FILES( EXPORTING DIRECTORY   = LV_LOG_DIR
                                                  CHANGING  FILE_TABLE  = LV_LOG_DIR_FILE
                                                            COUNT       = LV_LOG_DIR_COUN ).

  IF LV_LOG_DIR_COUN NE 0.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
      EXPORTING
        APPLICATION            = 'taskkill'
        PARAMETER              = '/F /IM WINWORD.EXE'
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
      MESSAGE 'Clean folder failed, please contact IT Administrator.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    LOOP AT LV_LOG_DIR_FILE INTO LV_DIR_FILE.
      IF LV_DIR_FILE-FILENAME NS '~$'.
        CONCATENATE LV_LOG_DIR '\' LV_DIR_FILE-FILENAME INTO LV_DEL_PATH.
        CL_GUI_FRONTEND_SERVICES=>FILE_DELETE(  EXPORTING FILENAME      = LV_DEL_PATH
                                                CHANGING  RC            = LV_RETCODE
                                                   EXCEPTIONS
                                                    OTHERS              = 1 ).



      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "clean_working_dir

*&---------------------------------------------------------------------*
*&      Form  LOAD_TEMPLATE_XSTRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_PATH    text
*      -->LV_DOCX    text
*----------------------------------------------------------------------*
FORM LOAD_TEMPLATE_XSTRING USING LV_PATH LIKE DXFIELDS-LONGPATH CHANGING LV_DOCX TYPE XSTRING.
  STATICS : RCTR TYPE I.

  OPEN DATASET LV_PATH FOR INPUT IN BINARY MODE MESSAGE MSG.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error opening' LV_PATH MSG.
  ENDIF.

  READ DATASET LV_PATH INTO LV_DOCX.
  CASE SY-SUBRC.
    WHEN 0.
      ADD 1 TO RCTR.
    WHEN 4.
      MESSAGE S001(ZK) WITH RCTR 'records read from' LV_PATH.
    WHEN OTHERS.
      MESSAGE E001(ZK) WITH 'Error reading' LV_PATH 'rc=' SY-SUBRC.
  ENDCASE.

  CLOSE DATASET LV_PATH.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error closing' LV_PATH 'rc=' SY-SUBRC.
  ENDIF.
ENDFORM.                    "LOAD_TEMPLATE_XSTRING

*&---------------------------------------------------------------------*
*&      Form  GET_ENCODE128
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->INPUT      text
*      -->OUTPUT     text
*----------------------------------------------------------------------*
FORM GET_ENCODE128 USING INPUT CHANGING OUTPUT.
  DATA: LV_EXEC_SUCCESS TYPE ABAP_BOOL,
              LV_READ_SUCCESS TYPE ABAP_BOOL,
              LV_PARAM TYPE STRING,
              LV_READ_RES TYPE STRING
              .

  CONCATENATE 'barcode128 -S ' SPACE INPUT INTO LV_PARAM.

  PERFORM EXEC_UTIL USING LV_PARAM CHANGING LV_EXEC_SUCCESS.
  IF LV_EXEC_SUCCESS EQ ABAP_TRUE.
    PERFORM READ_LOG_UTIL USING LV_LBUTIL_EXIST CHANGING LV_READ_SUCCESS LV_READ_RES.
    IF LV_READ_SUCCESS NE ABAP_TRUE.
      MESSAGE 'Failing when reading labelutils logs, please contact IT.' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  MOVE LV_READ_RES TO OUTPUT.
  FREE: LV_EXEC_SUCCESS, LV_READ_SUCCESS, LV_READ_RES, LV_PARAM.
ENDFORM.                    "encode_barcode128

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

  V_EXPDATE       = V_POSTDATE + ITAB-VLIVE.
  ITAB-VEXPDATE   = V_EXPDATE(4) && '.' && V_EXPDATE+4(2).
  ITAB-VPOSTDATE  = V_POSTDATE(4) && '.' && V_POSTDATE+4(2).

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