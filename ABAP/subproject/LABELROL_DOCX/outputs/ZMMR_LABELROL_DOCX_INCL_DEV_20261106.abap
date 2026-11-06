CONSTANTS:  LV_LBUTIL_FTP_PATH    TYPE STRING VALUE '/spare/saplabel/saplabeldocx/utils',
            LV_LBUTIL_ACTIVE_PATH TYPE STRING VALUE '/spare/saplabel/saplabeldocx/utils/active_version'.

DATA:       LV_LBUTIL_ROOT_PATH   TYPE STRING VALUE 'C:\tslabel\docx\',
            LV_LBUTIL_LOG_PATH    TYPE STRING,
            LV_LBUTIL_PATH        TYPE STRING,
            LV_LBUTIL_FTP_FILE    TYPE STRING,
            LV_LBUTIL_ACTIVE_VER  TYPE STRING.

*&---------------------------------------------------------------------*
*&      Form  GET_ACTIVE_VERSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_ACTIVE_VERSION.
  STATICS : RCTR TYPE I.

  OPEN DATASET LV_LBUTIL_ACTIVE_PATH FOR INPUT IN TEXT MODE ENCODING UTF-8 MESSAGE MSG.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error opening' LV_LBUTIL_ACTIVE_PATH MSG.
  ENDIF.

  READ DATASET LV_LBUTIL_ACTIVE_PATH INTO LV_LBUTIL_ACTIVE_VER.
  CASE SY-SUBRC.
    WHEN 0.
      ADD 1 TO RCTR.
    WHEN 4.
      MESSAGE S001(ZK) WITH RCTR 'records read from' LV_LBUTIL_ACTIVE_PATH.
    WHEN OTHERS.
      MESSAGE E001(ZK) WITH 'Error reading' LV_LBUTIL_ACTIVE_PATH 'rc=' SY-SUBRC.
  ENDCASE.

  CLOSE DATASET LV_LBUTIL_ACTIVE_PATH.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error closing' LV_LBUTIL_ACTIVE_PATH 'rc=' SY-SUBRC.
  ELSE.
    CONCATENATE LV_LBUTIL_ROOT_PATH LV_LBUTIL_ACTIVE_VER INTO LV_LBUTIL_PATH .
    CONCATENATE LV_LBUTIL_ROOT_PATH 'log\labelutils.log' INTO LV_LBUTIL_LOG_PATH.
    MOVE LV_LBUTIL_ACTIVE_VER TO LV_LBUTIL_FTP_FILE.
  ENDIF.
ENDFORM.                    "GET_ACTIVE_VERSION

*&---------------------------------------------------------------------*
*&      Form  GET_MAPPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DESCRIPTION  text
*----------------------------------------------------------------------*
FORM GET_MAPPING USING DESCRIPTION.
  "Label Kanaoka/Green Express (GE)
  IF DESCRIPTION CS ' GE*'.
    IF IT_MAP-TEXT1 IS NOT INITIAL.
      ITAB-VINSIDE  = IT_MAP-TEXT1.
    ENDIF.
    IF IT_MAP-TEXT2 IS NOT INITIAL.
      ITAB-VOUTSIDE = IT_MAP-TEXT2.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_SPECIAL_TREATMENT

*&---------------------------------------------------------------------*
*&      Form  GET_HU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->HU_NO      text
*      -->TOT_ROL    text
*      -->TOT_BOX    text
*      -->WEIGHT     text
*      -->DATE       text
*      -->MONTH      text
*      -->YEAR       text
*----------------------------------------------------------------------*
FORM GET_HU USING TYPE PLANT HU_NO TOT_ROL TOT_BOX WEIGHT DATE MONTH YEAR.
  "For HU
  IF TYPE IS NOT INITIAL AND SY-TCODE EQ 'VL74'.
    PERFORM OUTPUT_FORMAT USING HU_NO CHANGING ITAB-VBATCH.

    "Set Weight
    ITAB-VTOTROL  = TOT_ROL.
    ITAB-VTOTBOX  = TOT_BOX.
    ITAB-VNWEIGHT = WEIGHT.
    CONDENSE ITAB-VNWEIGHT.
    PERFORM GET_CONVERSION USING 'WEIGHT' WEIGHT CHANGING ITAB-VLBS.

    "Set File FTP
    IF TYPE EQ 'BOX'.
      "HU Box
      CONCATENATE ITAB-PACK ITAB-LABEL INTO ITAB-LABEL.
    ELSE.
      "HU Pallet
      CONCATENATE 'PL' ITAB-LABEL INTO ITAB-LABEL.
    ENDIF.

    "Set Code HU
    DATA: V_PLANT_CODE(2),
          V_ERDAT(3).

    IF PLANT = '1000'.
      V_PLANT_CODE = 'WR'.
    ELSEIF PLANT = '2000'.
      V_PLANT_CODE = 'KR'.
    ELSEIF PLANT = '3000'.
      V_PLANT_CODE = 'JR'.
    ENDIF.
    CONCATENATE MONTH YEAR INTO V_ERDAT.
    IF TYPE EQ 'BOX'.
      CONCATENATE HU_NO V_PLANT_CODE V_ERDAT INTO ITAB-CODE SEPARATED BY '-'.
    ELSE.
      CONCATENATE HU_NO V_PLANT_CODE V_ERDAT DATE INTO ITAB-CODE SEPARATED BY '-'.
    ENDIF.
  ENDIF.
ENDFORM.                    "GET_HU

*&---------------------------------------------------------------------*
*&      Form  EXEC_UTIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_PARAM         text
*      -->LV_EXEC_SUCCESS  text
*----------------------------------------------------------------------*
FORM EXEC_UTIL USING LV_PARAM TYPE STRING CHANGING LV_EXEC_SUCCESS.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>EXECUTE
    EXPORTING
      APPLICATION            = LV_LBUTIL_PATH
      PARAMETER              = LV_PARAM
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

  MOVE ABAP_TRUE TO LV_EXEC_SUCCESS.
  IF SY-SUBRC NE 0.
    MOVE ABAP_FALSE TO LV_EXEC_SUCCESS.
  ENDIF.
ENDFORM.                    "exec_util

*&---------------------------------------------------------------------*
*&      Form  READ_LOG_UTIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->EXIST            text
*      -->LV_READ_SUCCESS  text
*      -->LV_READ_RES      text
*----------------------------------------------------------------------*
FORM READ_LOG_UTIL USING EXIST CHANGING LV_READ_SUCCESS LV_READ_RES .
  DATA: LT_RES      TYPE TABLE OF STRING WITH HEADER LINE,
        LV_RETCODE  TYPE I.

  WAIT UP TO '0.5' SECONDS.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME = LV_LBUTIL_LOG_PATH
      FILETYPE = 'ASC'
      CODEPAGE = '4110'
    TABLES
      DATA_TAB = LT_RES.

  CONCATENATE LINES OF LT_RES INTO LV_READ_RES SEPARATED BY CL_ABAP_CHAR_UTILITIES=>CR_LF.

  MOVE ABAP_TRUE TO LV_READ_SUCCESS.
  IF SY-SUBRC NE 0.
    MOVE ABAP_FALSE TO LV_READ_SUCCESS.
  ELSE.
    CL_GUI_FRONTEND_SERVICES=>FILE_DELETE(  EXPORTING FILENAME      = LV_LBUTIL_LOG_PATH
                                            CHANGING  RC            = LV_RETCODE
                                              EXCEPTIONS
                                                OTHERS              = 1 ).

  ENDIF.
ENDFORM.                    "read_log_utl

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_FTP_PATH    text
*      -->LV_LOCAL_PATH  text
*      -->LV_DL_SUCCESS  text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FE  USING LV_FTP_PATH   TYPE EPSF-EPSDIRNAM
                        LV_LOCAL_PATH TYPE STRING
                  CHANGING LV_DL_SUCCESS.

  CONSTANTS BLOCKSIZE TYPE I VALUE 524287.
  CONSTANTS PACKAGESIZE TYPE I VALUE 8.

  TYPES TY_DATABLOCK(BLOCKSIZE) TYPE X.

  DATA: LV_AS_FN        TYPE SAPB-SAPPFAD,
        LV_CL_FN        TYPE STRING,
        LV_BLOCK_LEN    TYPE I,
        LV_PACKAGE_LEN  TYPE I,
        LV_SUBRC        TYPE SY-SUBRC,
        LV_MSGV1        LIKE SY-MSGV1,
        LV_FIL          TYPE EPSF-EPSFILNAM,
        LV_DIR          TYPE EPSF-EPSDIRNAM,
        LS_DATA         TYPE TY_DATABLOCK,
        LT_DATA         TYPE STANDARD TABLE OF TY_DATABLOCK,
        LV_PROCESSED_SO_FAR TYPE P,
        LV_APPEND       TYPE C,
        LV_STATUS       TYPE STRING,
        LV_FILESIZE     TYPE P,
        LV_PERCENT      TYPE I.

  IF LV_FTP_PATH EQ SPACE AND LV_LOCAL_PATH EQ SPACE.
    MOVE LV_LBUTIL_PATH TO LV_CL_FN.
    MOVE LV_LBUTIL_FTP_PATH TO LV_DIR.
    MOVE LV_LBUTIL_FTP_FILE TO LV_FIL.

    CONCATENATE LV_LBUTIL_FTP_PATH '/' LV_LBUTIL_FTP_FILE INTO LV_AS_FN.
  ELSE.
    MOVE LV_FTP_PATH    TO LV_AS_FN.
    MOVE LV_LOCAL_PATH  TO LV_CL_FN.
  ENDIF.

  OPEN DATASET LV_AS_FN FOR INPUT IN BINARY MODE.
  IF SY-SUBRC <> 0.
    MOVE ABAP_FALSE TO LV_DL_SUCCESS.
    EXIT.
  ENDIF.

  CLOSE DATASET LV_AS_FN.

  CALL FUNCTION 'EPS_GET_FILE_ATTRIBUTES'
    EXPORTING
      FILE_NAME      = LV_FIL
      DIR_NAME       = LV_DIR
    IMPORTING
      FILE_SIZE_LONG = LV_FILESIZE.

  OPEN DATASET LV_AS_FN FOR INPUT IN BINARY MODE MESSAGE LV_MSGV1.
  IF SY-SUBRC <> 0.
    MESSAGE E048(CMS) WITH LV_AS_FN LV_MSGV1 RAISING FILE_READ_ERROR.
    EXIT.
  ENDIF.

  LV_PROCESSED_SO_FAR = 0.
  DO.
    REFRESH LT_DATA.
    LV_PACKAGE_LEN = 0.
    DO PACKAGESIZE TIMES.
      CLEAR LS_DATA.
      CLEAR LV_BLOCK_LEN.
      READ DATASET LV_AS_FN INTO LS_DATA MAXIMUM LENGTH BLOCKSIZE LENGTH LV_BLOCK_LEN.
      LV_SUBRC = SY-SUBRC.
      IF LV_BLOCK_LEN > 0.
        LV_PACKAGE_LEN = LV_PACKAGE_LEN + LV_BLOCK_LEN.
        APPEND LS_DATA TO LT_DATA.
      ENDIF.

      IF LV_SUBRC <> 0.
        EXIT.
      ENDIF.
    ENDDO.

    IF LV_PACKAGE_LEN > 0.
      IF LV_PROCESSED_SO_FAR = 0.
        LV_APPEND = ' '.
      ELSE.
        LV_APPEND = 'X'.
      ENDIF.
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          BIN_FILESIZE         = LV_PACKAGE_LEN
          FILENAME             = LV_CL_FN
          FILETYPE             = 'BIN'
          APPEND               = LV_APPEND
          SHOW_TRANSFER_STATUS = ABAP_FALSE
        TABLES
          DATA_TAB             = LT_DATA.

      LV_PROCESSED_SO_FAR = LV_PROCESSED_SO_FAR + LV_PACKAGE_LEN.
    ENDIF.

    IF LV_SUBRC <> 0.
      EXIT.
    ENDIF.
  ENDDO.

  IF LV_SUBRC EQ 0 OR LV_SUBRC EQ 4.
    MOVE ABAP_TRUE TO LV_DL_SUCCESS.
  ENDIF.

  CLOSE DATASET LV_AS_FN.
ENDFORM.                    "download_fe

*&---------------------------------------------------------------------*
*&      Form  CHECK_FILE_EXISTANCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_PATH        text
*      -->LV_FILE_EXIST  text
*----------------------------------------------------------------------*
FORM CHECK_FILE_EXISTANCE USING LV_PATH TYPE STRING CHANGING LV_FILE_EXIST.
  DATA LV_PATH_TEMP TYPE STRING.
  IF LV_PATH EQ SPACE.
    MOVE LV_LBUTIL_PATH TO LV_PATH_TEMP.
  ELSE.
    MOVE LV_PATH TO LV_PATH_TEMP.
  ENDIF.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = LV_PATH_TEMP
    RECEIVING
      RESULT               = LV_FILE_EXIST
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.
ENDFORM.                    "check_file_existance