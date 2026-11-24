INCLUDE ZLABEL_ZEBRA_INCL.
TABLES : ZLABEL ,
*/---Added on 150405---
         ZLABELMAPIMAGE, ZALIAS, ZCONSTANT .
*---------------------/


CONSTANTS : V_C_GAUGE VALUE 4,

            V_C_INCH_INTER  TYPE P DECIMALS 5 VALUE '0.0395',
            V_C_INCH  TYPE P DECIMALS 5 VALUE '0.03937',
            V_C_FEET  TYPE P DECIMALS 2 VALUE '3.28',
            V_C_FEET_INTER_BOPET  TYPE P DECIMALS 5 VALUE '3.28',
            V_C_FEET_INTER  TYPE P DECIMALS 5 VALUE '3.27976',
            V_C_LBS  TYPE P DECIMALS 4 VALUE '2.2046'.

DATA : V_L1(12),
       V_L2(12),
       V_W1(12),
       V_W2(12),
       V_N1(12),
       V_N2(12),
       V_S1(12),
       V_S2(12),
       V_T1(12),
       V_T2(12),
       V_P1(10),
       V_J1(10),
       V_F1(24),
       V_F2(24),
       V_F3(24),
       V_F4(24).

DATA : POSI(3).

DATA : V_CHARG LIKE VBDPL-CHARG,
       V_MATNR LIKE MARA-MATNR,
       V_WERKS LIKE VBDPL-WERKS,
       V_DOCNO LIKE MSEG-MBLNR,
       V_YEAR  LIKE MSEG-MJAHR,
       V_LGORT LIKE MSKA-LGORT,
       V_CHARG_TTA LIKE VBDPL-CHARG,
       V_MATNR_TTA LIKE MARA-MATNR.

DATA : V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE,
       V_TAB2   TYPE API_CHAR OCCURS 0 WITH HEADER LINE,
       V_TAB3   TYPE API_CH_ATT OCCURS 0 WITH HEADER LINE.
DATA : V_ZLABEL LIKE ZLABEL OCCURS 0 WITH HEADER LINE.

*/---changed on 150405---
*table map image
DATA : V_ZLABELMAPIMAGE LIKE ZLABELMAPIMAGE OCCURS 0 WITH HEADER LINE.
*-----------------------/


DATA : BEGIN OF TEXT_DATA OCCURS 0,
            STR_TEXT(255),
       END OF TEXT_DATA.

DATA : BEGIN OF TEXT_DATA2 OCCURS 0,
            STR_TEXT(255),
       END OF TEXT_DATA2.

DATA : V_TABIX LIKE SY-TABIX,
       V_RETURNCODE TYPE I,
       V_FLAG_LABELTYPE(6) VALUE 'false'.

DATA : V_PRODLINE LIKE API_VALI-ATWTB,
       V_TYPE     LIKE API_VALI-ATWTB,
       V_MONTHYEAR LIKE API_VALI-ATWTB,
       V_SEQUENCENBR LIKE API_VALI-ATWTB,
       V_CODE LIKE API_VALI-ATWTB,
       V_GRADE LIKE API_VALI-ATWRT,
       V_DERIVATIVEMS LIKE API_VALI-ATWTB,
       V_POSITIONMS LIKE API_VALI-ATWTB,
       V_DERIVATIVESS LIKE API_VALI-ATWTB,
       V_POSITIONSS LIKE API_VALI-ATWTB,
*Criteria grade, 2 for second grade
       V_CRITERIA(1) VALUE ' ',
       V_ROLLNO(30).

*DATA : c_tmpupload LIKE dxfields-longpath VALUE '/usr/sap/D3D/SYS/global'.

DATA : SFN LIKE DXFIELDS-LONGPATH. " server file name

DATA : PFN TYPE STRING VALUE 'C:\tslabel\'.

DATA : IT(1000) OCCURS 100 WITH HEADER LINE.

DATA : FILE_F LIKE DXFIELDS-LONGPATH,
       FILE_I LIKE DXFIELDS-LONGPATH,
       FILE_B LIKE DXFIELDS-LONGPATH ,
       FILE_D TYPE STRING VALUE 'C:\tslabel\DATA.DAX',
       FILE_BATCH(125).

DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
DATA : V_LABELTYPE(10),
       V_LABEL(10).
DATA : FILE_DOWNLOAD TYPE STRING.

* // Data for Convert Value
DATA : V_DEL(4) VALUE 'kg/m',
       V_DOT(1) VALUE ',',
       V_1(20),
       V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
       V_S_GAUGE(8),
       V_S_GAUGE_INTER(40),
       V_INCH  TYPE P DECIMALS 2 ,
       V_S_INCH(20),
       V_S_INCH_INTER(40),
       V_FEET  TYPE P DECIMALS 2,
*for D009/iterfilm
       V_FEET_INTER TYPE P,
       V_S_FEET(20),
       V_S_FEET_INTER(40),

*mode 3 decimal
*------{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_lbs  TYPE p DECIMALS 3,
       V_LBS  TYPE P DECIMALS 2,
*------}
       V_S_LBS(20),
       V_S_LBS_INTER(40),
       V_SPLICE1_INTER  TYPE P,
       V_SPLICE1  TYPE P DECIMALS 2,
       V_S_SPLICE1(20),
       V_SPLICE2_INTER  TYPE P,
       V_SPLICE2  TYPE P DECIMALS 2,
       V_S_SPLICE2(20),
       V_TEST(100) VALUE 39,
       V_INFO_ERROR(100) TYPE C.
*mode 1 decimal - 5 digit
DATA : V_LEN_MIC(2) VALUE 8,
*mode 2 decimal - 5 digit
       V_LEN_GAUGE(2) VALUE 8,
       V_LEN_CORE(2) VALUE 10,
       V_LEN_IN_OUT(2) VALUE 15,
       V_LEN_NORMAL(2) VALUE 8,
*mode 3 decimal x
       V_LEN_WEIGHT(2) VALUE 9,
       V_STRLEN(2),
       V_LEN_SOITEM(2) VALUE 17.

DATA : V_FLAG_ZZALIAS(1) VALUE '',
       V_ZZPACKING(10),
       V_FLAG_WEIGHT_ZZALIAS(1) VALUE ''.

DATA : V_MAGRV LIKE VEKP-MAGRV,
       V_EXIDV LIKE VEKP-EXIDV,
       V_BOX_NO(40),
       V_TOT_ROLL(4),
       V_TOT_BOX(4),
       V_TOT_QTYSHEET(20) VALUE 0.
*mode decimal 3
DATA :
*---{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_weight TYPE p DECIMALS 3,
       V_WEIGHT TYPE P DECIMALS 2,
*---}
       V_LENGTH TYPE P DECIMALS 2,
       V_WIDTH  TYPE P DECIMALS 2,
       V_SPLICE2_MIRING TYPE P DECIMALS 2,
       V_SPLICE1_MIRING TYPE P DECIMALS 2.
*DATA : v_i_atwtb(16) TYPE p.


DATA : V_ERDAT_DD(2),
       V_ERDAT_MM(2),
       V_ERDAT_YY(1),
       V_ERDAT(3),
       V_PLANT_CODE(2).

DATA : V_KALAB LIKE MSKA-KALAB,
       V_KAINS LIKE MSKA-KAINS,
       V_KASPE LIKE MSKA-KASPE,
       V_CLABS LIKE MCHB-CLABS,
       V_CINSM LIKE MCHB-CINSM,
       V_CEINM LIKE MCHB-CEINM,
       V_CSPEM LIKE MCHB-CSPEM,
*------{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_sum_netweight TYPE p DECIMALS 3.
       V_SUM_NETWEIGHT TYPE P DECIMALS 2.
*------}

*/---changed on 150405---
*       v_zzconversionmtrkg(10).
*-----------------------/

DATA : V_THICKNESS LIKE API_VALI-ATWTB.

*/---added on 150405--- for changed label logo
DATA : V_LABELIMGNEW(6) VALUE '0000',
       V_LABELIMGOLD(6) VALUE '0000',
       V_LABELORIG(6) VALUE '0000',
       V_IMAGE(20).
*-----------------------/

DATA : V_S_SUM_QTYSHEET(20),
       V_SUM_QTYSHEET TYPE P DECIMALS 2,
       V_SUM_NETWEIGHT_TEMP TYPE P DECIMALS 3.
.

DATA : WA_LENGT LIKE ZALIAS-LENGT,
       WA_WIDTH LIKE ZALIAS-WIDTH,
       WA_THICK LIKE ZALIAS-THICK,
       WA_DENSI LIKE ZALIAS-DENSI.

*for SO Number and Item
DATA : V_SONUM_ITEM(17),
       V_VBELN LIKE MSKA-VBELN,
       V_POSNR LIKE MSKA-POSNR.
*Interfilm
DATA : I_GAUGE(30) TYPE C,
       I_MICRON(30) TYPE C,
       I_MILI(30) TYPE C,
       I_METERS(30) TYPE C,
       I_LBS(30) TYPE C,
       I_KGS(30) TYPE C,
       I_INCH(30) TYPE C,
       I_FEET(30) TYPE C,
       I_WEIGHT(30) TYPE C,
       V_INFO_THICKNESS(20) TYPE C.


*for Expired Live
DATA : V_LIVE TYPE P,
       V_EXPDATE TYPE MKPF-BUDAT,
       V_POSTDATE TYPE MKPF-BUDAT.

*- Part number
DATA: V_PARTNO LIKE VBAP-KDMAT.

*- Check zebra
DATA: V_IS_ZEBRA(1) TYPE C.

*- Check using manufdate
DATA : V_GETMANUF TYPE STRING. "Added by Fany 23.01.2025 (Validation to display manufacturing date in label)

" Start Add by Fiqih 26.03.2026 (RTP)
*- Check using RTP Pallet
DATA: GV_IS_RTP(1)  TYPE C, " Flag untuk cek apakah HU pallet menggunakan Pallet RTP.
      LV_INJECT_STR TYPE STRING,
      LV_SHIFT_UP   TYPE I,
      LV_GAP_DOWN   TYPE I.
" End Add by Fiqih 26.03.2026 (RTP)
*&---------------------------------------------------------------------*
*&      Form  download_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_DATA .
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME                = FILE_D
      FILETYPE                = 'ASC'
      WRITE_FIELD_SEPARATOR   = 'X'
    TABLES
      DATA_TAB                = TEXT_DATA    " internal table containing data
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.
  IF SY-SUBRC <> 0.
*    MESSAGE e000 WITH 'Download data file error'.

    CASE SY-SUBRC.
      WHEN 1.
        V_INFO_ERROR = 'file_write_error'.
      WHEN 2.
        V_INFO_ERROR = 'no_batch'.
      WHEN 3.
        V_INFO_ERROR = 'gui_refuse_filetransfer'.
      WHEN 4.
        V_INFO_ERROR = 'invalid_type'.
      WHEN 5.
        V_INFO_ERROR = 'no_authority'.
      WHEN 6.
        V_INFO_ERROR = 'unknown_error'.
      WHEN 7.
        V_INFO_ERROR = 'header_not_allowed'.
      WHEN 8.
        V_INFO_ERROR = 'separator_not_allowed'.
      WHEN 9.
        V_INFO_ERROR = 'filesize_not_allowed'.
      WHEN 10.
        V_INFO_ERROR = 'header_too_long'.
      WHEN 11.
        V_INFO_ERROR = 'dp_error_create'.
      WHEN 12.
        V_INFO_ERROR = 'dp_error_send'.
      WHEN 13.
        V_INFO_ERROR = 'dp_error_write'.
      WHEN 14.
        V_INFO_ERROR = 'unknown_dp_error'.
      WHEN 15.
        V_INFO_ERROR = 'access_denied'.
      WHEN 16.
        V_INFO_ERROR = 'dp_out_of_memory'.
      WHEN 17.
        V_INFO_ERROR = 'disk_full'.
      WHEN 18.
        V_INFO_ERROR = 'dp_timeout'.
      WHEN 19.
        V_INFO_ERROR = 'file_not_found'.
      WHEN 20.
        V_INFO_ERROR = 'dataprovider_exception'.
      WHEN 21.
        V_INFO_ERROR = 'control_flush_error'.
      WHEN 22.
        V_INFO_ERROR = 'OTHERS'.
    ENDCASE.
    MESSAGE E000(0K) WITH 'Download data file error, cause : ' V_INFO_ERROR.
  ENDIF.
ENDFORM.                    " download_data


*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT .

  "added for print using zebra
  CLEAR V_RETURNCODE.
  PERFORM CHECK_USING_ZEBRA CHANGING V_IS_ZEBRA.
*  IF LV_ISZEBRA EQ 1. "Execute program if file zebra.zpl found.
  IF V_IS_ZEBRA EQ 'X'. "Execute program if file zebra.zpl found.
    "Change emulation in zebra printer
    PERFORM CHANGE_ZEBRA_EMULATION USING 'APL-I'.
    WAIT UP TO 10 SECONDS.
    IF SY-SUBRC EQ 0.
      "Print label to zebra
      PERFORM PRINT_ZEBRA CHANGING V_RETURNCODE.
    ENDIF.
  ELSE.
*   CONCATENATE pfn 'T001'  '.BAT' INTO file_batch.
    CONCATENATE PFN  V_LABELTYPE  '.BAT' INTO FILE_BATCH.
    CALL FUNCTION 'GUI_RUN'
      EXPORTING
*       command    = file_batch
        COMMAND    = 'DATA.BAT'
        CD         = 'C:\tslabel\'
      IMPORTING
        RETURNCODE = V_RETURNCODE.
  ENDIF.

  IF V_RETURNCODE <> 0.
*    MESSAGE e000 WITH 'RUN batch file error'.
    MESSAGE I000(0K) WITH 'Run Batch File Error'.
    STOP.
  ENDIF.
  WAIT UP TO 1 SECONDS.
ENDFORM.                    " print

*-macro-for-form-definition-------------------------------------------*


DEFINE DSFORM_OPEN.
*---------------------------------------------------------------------*
* FORM dsopen_&1_&2 *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
* --> DSN *
*---------------------------------------------------------------------*
FORM DSOPEN_&1_&2 USING DSN TYPE C.
  DATA MSG(80).
  OPEN DATASET DSN FOR &1 IN &2 MODE MESSAGE MSG.

  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error opening' DSN MSG.
  ENDIF.
ENDFORM.                               "dsopen_&1_&2

END-OF-DEFINITION.

*-macro-for-form-definition-------------------------------------------*
DEFINE DSFORM_OPEN1.
*---------------------------------------------------------------------*
* FORM dsopen_&1_&2 *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
* --> DSN *
*---------------------------------------------------------------------*
FORM DSOPEN_&1_&2 USING DSN TYPE C.
  DATA MSG(80).
* open dataset dsn for &1 in &2 mode message msg.
  OPEN DATASET DSN FOR &1 IN &2 MODE ENCODING DEFAULT MESSAGE MSG.

  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error opening' DSN MSG.
  ENDIF.
ENDFORM. "dsopen_&1_&2
END-OF-DEFINITION.


*---------------------------------------------------------------------*
*dsform_open input text.
DSFORM_OPEN1 INPUT TEXT.
DSFORM_OPEN INPUT BINARY.
*dsform_open output text.
DSFORM_OPEN1 OUTPUT TEXT.
DSFORM_OPEN OUTPUT BINARY.

*--------------------------------------------------------------------
FORM DSREAD USING DSN TYPE C CHANGING REC.

  STATICS: RCTR TYPE I.

  READ DATASET DSN INTO REC.
  CASE SY-SUBRC.
    WHEN 0.
      ADD 1 TO RCTR.
    WHEN 4.
      MESSAGE S001(ZK) WITH RCTR 'records read from' DSN.
    WHEN OTHERS.
      MESSAGE E001(ZK) WITH 'Error reading' DSN 'rc=' SY-SUBRC.
  ENDCASE.
ENDFORM. "dsread

*--------------------------------------------------------------------
FORM DSWRITE USING DSN TYPE C REC.

  STATICS: RCTR TYPE I.

  TRANSFER REC TO DSN.
  CASE SY-SUBRC.
    WHEN 0.
      ADD 1 TO RCTR.
* New Code for the permission {
      DATA T_IBTCXPM TYPE STANDARD TABLE OF BTCXPM WITH HEADER LINE.
      DATA W_STATUS LIKE EXTCMDEXEX-STATUS.
      DATA W_PARAM LIKE SXPGCOLIST-PARAMETERS.

      DATA: BEGIN OF T_SPOOLID OCCURS 0 ,
      RQIDENT LIKE TSP01-RQIDENT ,
      RQCLIENT LIKE TSP01-RQCLIENT,
      RQO1NAME LIKE TSP01-RQO1NAME,
      END OF T_SPOOLID .

      DATA: BEGIN OF T_MESSAGE OCCURS 0,
      RQIDENT LIKE TSP01-RQIDENT,
      TEXT(80) TYPE C,
      END OF T_MESSAGE.

* Forms UNIX OS command - for output file
      CONCATENATE '666'
      SFN
      INTO W_PARAM
      SEPARATED BY SPACE.

      CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
        EXPORTING
          COMMANDNAME                = 'ZCHMOD'
          ADDITIONAL_PARAMETERS      = W_PARAM
        IMPORTING
          STATUS                     = W_STATUS
        TABLES
          EXEC_PROTOCOL              = T_IBTCXPM
        EXCEPTIONS
          NO_PERMISSION              = 1
          COMMAND_NOT_FOUND          = 2
          PARAMETERS_TOO_LONG        = 3
          WRONG_CHECK_CALL_INTERFACE = 5
          PROGRAM_START_ERROR        = 6
          PARAMETER_EXPECTED         = 9
          TOO_MANY_PARAMETERS        = 10
          OTHERS                     = 15.

      IF SY-SUBRC NE 0.
        MOVE T_SPOOLID-RQIDENT TO T_MESSAGE-RQIDENT.
        MOVE 'Error in Unix command execution chmod'(009)
        TO T_MESSAGE-TEXT.
        APPEND T_MESSAGE.
        CLEAR T_MESSAGE.
* continue.
      ENDIF.


*}

    WHEN OTHERS.
      MESSAGE E001(ZK) WITH 'Error writing to' DSN 'rc=' SY-SUBRC.
  ENDCASE.
ENDFORM. "dswrite

*--------------------------------------------------------------------
FORM DSCLOSE
USING DSN TYPE C.
  CLOSE DATASET DSN.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error closing' DSN 'rc=' SY-SUBRC.
  ENDIF.
ENDFORM. "dsclose
*&---------------------------------------------------------------------*
*&      Form  xfer2it
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM XFER2IT.
  WHILE SY-SUBRC = 0.
    PERFORM DSREAD USING SFN CHANGING IT.
    IF SY-SUBRC <> 0.
      EXIT.
    ENDIF.
    APPEND IT.
  ENDWHILE.
  PERFORM DSCLOSE USING SFN.
ENDFORM.                                                    "xfer2it
*&---------------------------------------------------------------------*
*&      Form  download_frsrv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_FRSRV .
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME              = FILE_DOWNLOAD
      FILETYPE              = 'ASC'
      WRITE_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB              = IT
    EXCEPTIONS
      FILE_OPEN_ERROR       = 1
      FILE_WRITE_ERROR      = 2
      INVALID_FILESIZE      = 3
      INVALID_TABLE_WIDTH   = 4
      INVALID_TYPE          = 5
      NO_BATCH              = 6
      UNKNOWN_ERROR         = 7
      OTHERS                = 8.
*  PERFORM checkrc USING 'WS_DOWNLOAD'.
ENDFORM.                    " download_frsrv


*&---------------------------------------------------------------------*
*&      Form  getfrsrv_f
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETFRSRV_F.
  CONCATENATE PFN  V_LABELTYPE '.TAX' INTO FILE_DOWNLOAD.
  SFN = FILE_F.
  REFRESH IT.
  PERFORM DSOPEN_INPUT_TEXT USING SFN.
  PERFORM XFER2IT.
*  PERFORM download_frsrv.
ENDFORM. "getfrsrv_f


*&---------------------------------------------------------------------*
*&      Form  getfrsrv_b
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETFRSRV_B.
  CONCATENATE PFN  'DATA' '.BAT' INTO FILE_DOWNLOAD.

  SFN = FILE_B.
  REFRESH IT.
  PERFORM DSOPEN_INPUT_TEXT USING SFN.
  PERFORM XFER2IT.
  PERFORM DOWNLOAD_FRSRV.
ENDFORM. "getfrsrv_b


*&---------------------------------------------------------------------*
*&      Form  getfrsrv_i
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETFRSRV_I.
*  CONCATENATE pfn 'T001' '.IMG' INTO file_download.
  CONCATENATE PFN V_LABELTYPE '.IMG' INTO FILE_DOWNLOAD.
  SFN = FILE_I.
  REFRESH IT.
  PERFORM DSOPEN_INPUT_TEXT USING SFN.
  PERFORM XFER2IT.
  PERFORM DOWNLOAD_FRSRV.
ENDFORM. "getfrsrv_i

*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM RIGHT_JUSTIFIED  USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

*  REPLACE ALL OCCURRENCES OF '.0' IN v_value WITH ' '.
  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    " RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM RIGHT_JUSTIFIED_3  USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

*  REPLACE ALL OCCURRENCES OF '.0' IN v_value WITH ' '.
  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    " RIGHT_JUSTIFIED

*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED_NO_GAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM RIGHT_JUSTIFIED_NO_GAP  USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
*  CONDENSE v_value NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

*  REPLACE ALL OCCURRENCES OF '.0' IN v_value WITH ' '.
  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  TRANSLATE V_VALUE TO UPPER CASE.
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    " RIGHT_JUSTIFIED

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_TAB_atwtb  text
*      <--V_atwtb_LENGTH  text
*----------------------------------------------------------------------*
FORM CONV_TO_CHAR  USING    V_TAB_ATWTB.
  V_TEST = V_TAB_ATWTB.
  REPLACE ALL OCCURRENCES OF '.00' IN V_TEST WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN V_TEST WITH ' '.
  V_TAB-ATWTB = V_TEST.
ENDFORM.                    " CONV_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_TAB_atwtb  text
*      <--V_atwtb_LENGTH  text
*----------------------------------------------------------------------*
FORM CONV_TO_CHAR_3_DEC  USING    V_TAB_ATWTB.
  V_TEST = V_TAB_ATWTB.
  REPLACE ALL OCCURRENCES OF '.000' IN V_TEST WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN V_TEST WITH ''.
  V_TAB-ATWTB = V_TEST.
ENDFORM.                    " CONV_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  tyb_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM tyb_text_data .
*  DATA : v_ty_rolln(10),
*         v_ty_lotn(6),
*         v_ty_text1(30),
*         v_ty_text2(30),
*         v_s_thickness(3),v_s_width(5),v_s_length(6),
*         v_ty_lower123(3).
*
*
*  CONCATENATE file_dir  'DATA' '.BAT' INTO file_b.
*  CONCATENATE file_dir  v_labeltype '.TAX' INTO file_f.
*
**Get Net weight...
*  PERFORM get_net_weight.
*  CLEAR : v_flag_zzalias,
*          v_type,
*          v_labeltype,
*          posi.
**/---Changed on 150405---
**          v_zzconversionmtrkg.
**-----------------------/
*
*  SORT v_tab BY atnam.
*  LOOP AT v_tab.
*
** Reset v_flag_zzalias to ''.
*    v_flag_zzalias = ''.
*
*    IF v_tab-atnam = 'ZZALIAS'.
*      v_type = v_tab-atwrt.
*      v_flag_zzalias = 'X'.
*      READ TABLE v_tab WITH KEY atnam = 'ZZTYPE'.
*      IF sy-subrc = 0.
*        v_tab-atwrt = v_type.
*        MODIFY v_tab  INDEX sy-tabix TRANSPORTING atwrt.
*      ENDIF.
*    ENDIF.
*
*
*
*    IF v_flag_zzalias <> 'X'.
*      IF v_tab-atnam = 'ZZTYPE'.
*        v_type = v_tab-atwrt.
*      ENDIF.
*    ENDIF.
*
*    IF v_tab-atnam = 'ZZLABEL'.
*      v_labeltype = v_tab-atwrt.
*      v_labelimgnew = v_tab-atwrt.
*    ENDIF.
*
*
*
*
**/---changed on 150405---
*
****ZZCONVERSIONMTRKG
**    IF v_tab-atnam = 'ZZCONVERSIONMTRKG'.
***      v_ZZCONVERSIONMTRKG = v_tab-atwtb.
**      SHIFT v_tab-atwtb LEFT DELETING LEADING space.
**      SPLIT v_tab-atwtb AT v_del INTO v_zzconversionmtrkg v_1.
**    ENDIF.
*
**----------------------/
*    IF v_tab-atnam = 'ZZPRDDATE'.
*      CONCATENATE v_tab-atwtb+9(1) v_tab-atwtb+3(2) INTO v_ty_lower123.
*    ENDIF.
*
*
*    IF v_tab-atnam = 'ZZCUSTROLLNMBR'.
*      v_ty_rolln = v_tab-atwrt.
*    ENDIF.
*
*    IF v_tab-atnam = 'ZZLOTNUMBER'.
*      PERFORM right_justified USING 6
*                                    v_tab-atwrt.
*
*      v_ty_lotn = v_tab-atwrt.
*    ENDIF.
*
*
*  ENDLOOP.
*
*  READ TABLE v_tab WITH KEY atnam = 'ZZLENGTH'.
*  IF sy-subrc <> 0.
*    v_tab-atnam = 'ZZLENGTH'.
*    v_s_length = v_tab-atwtb.
*    SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*    APPEND v_tab.
*  ELSE.
*    v_s_length = v_tab-atwtb.
*    SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*    MODIFY v_tab INDEX sy-tabix.
*  ENDIF.
*
*
**Getting the data atnam from table zlabel.
*  SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE v_zlabel
*  FROM zlabel.
*
*  SORT v_zlabel BY atnam.
*  LOOP AT v_zlabel.
*    v_tabix = sy-tabix.
*    CLEAR v_tab-atwtb.
*    READ TABLE v_tab WITH KEY atnam = v_zlabel-atnam.
*    IF sy-subrc = 0.
*
*      IF v_zlabel-atnam = 'ZZTHICKNESS'.
*        SPLIT v_tab-atwtb AT v_dot INTO v_tab-atwtb v_1.
*        PERFORM conv_to_char USING v_tab-atwtb.
*
*        PERFORM ty_right_justified USING 2
*                                      v_tab-atwtb.
*        REPLACE ALL OCCURRENCES OF '.0' IN v_tab-atwtb WITH ' '.
*
*        v_s_thickness = v_tab-atwtb.
*      ENDIF.
*
*      IF v_zlabel-atnam = 'ZZWIDTH'.
*        PERFORM ty_right_justified USING 4
*                                      v_tab-atwtb.
*        v_s_width = v_tab-atwtb.
*      ENDIF.
*
*      IF v_zlabel-atnam = 'ZZLENGTH'.
*        PERFORM ty_right_justified USING 5
*                                      v_tab-atwtb.
*
*        v_s_length = v_tab-atwtb.
*      ENDIF.
*
*      v_zlabel-data2 = v_tab-atwtb.
*    ELSE.
*      v_zlabel-data2 = ' '.
*    ENDIF.
*
*    MODIFY v_zlabel INDEX v_tabix TRANSPORTING data2.
*  ENDLOOP.
*
*
**/---Added on 150405---
**cek previouly label
*
*  IF v_labelimgold <> v_labelimgnew.
*
**clear image and format to text-data---------------------
*    REFRESH text_data2.
*    CLEAR text_data2.
*
*    CONCATENATE file_dir  'CLEAR.TAX' INTO file_f.
*
*    PERFORM getfrsrv_f.
*    text_data2[] = it[].
*
*    LOOP AT text_data2.
*      text_data-str_text = text_data2-str_text.
*
*      APPEND text_data.
*    ENDLOOP.
*
*
*    SELECT imag1
*      INTO CORRESPONDING FIELDS OF TABLE v_zlabelmapimage
*      FROM zlabelmapimage
*      WHERE kode = v_labelimgnew.
*
*
*    LOOP AT v_zlabelmapimage.
**load image to text-data---------------------
*      REFRESH text_data2.
*      CLEAR text_data2.
*
*      CONCATENATE file_dir  v_zlabelmapimage-imag1 '.TAX' INTO file_f.
*
*      PERFORM getfrsrv_f.
*      text_data2[] = it[].
*
*      LOOP AT text_data2.
*        text_data-str_text = text_data2-str_text.
*
*        APPEND text_data.
*      ENDLOOP.
*
*    ENDLOOP.
*
*  ENDIF.
*
**---------------------/
*
*
*
*******
**  DO v_copies TIMES.
*  REFRESH text_data2.
*  CLEAR text_data2.
*
*  CONCATENATE file_dir  v_labeltype '.TAX' INTO file_f.
*
*  PERFORM getfrsrv_f.
*  text_data2[] = it[].
*
*  LOOP AT text_data2.
*    text_data-str_text = text_data2-str_text.
*    IF sy-tabix = 2.
*      SHIFT text_data-str_text+7  RIGHT BY 2 PLACES .
*      ADD 1 TO posi.
*      text_data-str_text+6(3) = posi.
*    ENDIF.
*
*    APPEND text_data.
*  ENDLOOP.
*
*******
*
*******
**/---changed on 150405---
*  CONCATENATE v_type v_s_thickness INTO v_ty_text1 SEPARATED BY space.
*  CONCATENATE v_ty_text1 v_s_width v_s_length 'AT' INTO v_ty_text1.
**-----------------------/
*
*  CONDENSE v_ty_rolln.
*  CONDENSE v_ty_lotn.
**    CONCATENATE v_ty_lower123 v_ty_rolln v_ty_lotn '000' INTO v_ty_text2.
*  CONCATENATE v_ty_lower123 v_ty_rolln+0(9) v_ty_lotn '000' INTO v_ty_text2.
*
*
*
**Condition for start and end syntax label command.
*  text_data-str_text = '<STX><ESC>E1,1<CAN><ETX>'.
*  APPEND text_data.
*
**Combine all command into internal table.
*  LOOP AT v_zlabel.
*    IF v_zlabel-atnam = 'ZZBARC1'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_rolln '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZBARC2'.
*      IF v_labeltype = 'B021'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AT' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B002' OR v_labeltype = 'B022'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 '  <ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B023'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AL' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B024'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AC' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B025'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AR' '<ETX>' INTO text_data-str_text.
*      ELSE.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 '<ETX>' INTO text_data-str_text.
*      ENDIF.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZBARC3'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text2 '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZROLL1'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_rolln '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZROLL2'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_rolln '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZTEXT1'.
*      IF v_labeltype = 'B021'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AT' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B002' OR v_labeltype = 'B022'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 '  <ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B023'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AL' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B024'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AC' '<ETX>' INTO text_data-str_text.
*      ELSEIF v_labeltype = 'B025'.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 'AR' '<ETX>' INTO text_data-str_text.
*      ELSE.
*        CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text1 '<ETX>' INTO text_data-str_text.
*      ENDIF.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZTEXT2'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_text2 '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZFILM'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_type '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZLOTNUMBER'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_ty_lotn '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
**clear data
*    ELSEIF v_zlabel-atnam = 'ZZGRADE'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 '' '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZINSIDE'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 '' '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ELSEIF v_zlabel-atnam = 'ZZOUTSIDE'.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 '' '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*
*    ELSE.
*      CONCATENATE '<STX><ESC>' v_zlabel-data1 v_zlabel-data2 '<ETX>' INTO text_data-str_text.
*      APPEND text_data.
*    ENDIF.
*  ENDLOOP.
**Conditiion for end syntax label command.
*  CONCATENATE '<STX><RS>' v_copies '<ETX>' INTO text_data-str_text.
**  text_data-str_text = '<STX><RS>1<ETX>'.
*  APPEND text_data.
*
*  text_data-str_text = '<STX><US>1<ETX>'.
*  APPEND text_data.
*
*  text_data-str_text = '<STX><ETB><ETX>'.
*  APPEND text_data.
*
**  ENDDO.
*
*ENDFORM.                    " tyb_text_data
*&---------------------------------------------------------------------*
*&      Form  get_net_weight
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NET_WEIGHT .
*Get Net weight...
*Cek whether v_sum_netweight_temp <> 0 -> fill from ZHU Box & Pallet
*-- Begin of MD01
  DATA: BEGIN OF LT_MSKA OCCURS 0,
        MATNR LIKE MSKA-MATNR,
        WERKS LIKE MSKA-WERKS,
        LGORT LIKE MSKA-LGORT,
        CHARG LIKE MSKA-CHARG,
        SOBKZ LIKE MSKA-SOBKZ,
        VBELN LIKE MSKA-VBELN,
        POSNR LIKE MSKA-POSNR,
        KALAB LIKE MSKA-KALAB,
        KAINS LIKE MSKA-KAINS,
        KASPE LIKE MSKA-KASPE,
        KALAB1 TYPE ZGSGEW,
        KAINS1 TYPE ZGSGEW,
        KASPE1 TYPE ZGSGEW,
        END OF LT_MSKA,
        BEGIN OF LT_MCHB OCCURS 0,
        MATNR LIKE MCHB-MATNR,
        WERKS LIKE MCHB-WERKS,
        LGORT LIKE MCHB-LGORT,
        CHARG LIKE MCHB-CHARG,
        CLABS LIKE MCHB-CLABS,
        CINSM LIKE MCHB-CINSM,
        CEINM LIKE MCHB-CEINM,
        CSPEM LIKE MCHB-CSPEM,
        CLABS1 TYPE ZGSGEW,
        CINSM1 TYPE ZGSGEW,
        CEINM1 TYPE ZGSGEW,
        CSPEM1 TYPE ZGSGEW,
        END OF LT_MCHB.
*-- End of MD01

  IF V_SUM_NETWEIGHT_TEMP EQ SPACE.

    CLEAR : V_KALAB,
            V_KAINS,
            V_KASPE,
            V_CLABS,
            V_CINSM,
            V_CEINM,
            V_CSPEM,
            V_SUM_NETWEIGHT.

*-- Begin of MD01
    SELECT MATNR WERKS LGORT CHARG SOBKZ VBELN POSNR KALAB KAINS KASPE
    INTO TABLE LT_MSKA
    FROM MSKA
    WHERE MATNR = V_MATNR AND
          WERKS = V_WERKS AND
          CHARG = V_CHARG.
    LOOP AT LT_MSKA.
      LT_MSKA-KALAB1 = LT_MSKA-KALAB.
      LT_MSKA-KAINS1 = LT_MSKA-KAINS.
      LT_MSKA-KASPE1 = LT_MSKA-KASPE.
      ADD: LT_MSKA-KALAB1 TO V_KALAB,
           LT_MSKA-KAINS1 TO V_KAINS,
           LT_MSKA-KASPE1 TO V_KASPE.
    ENDLOOP.

    SELECT MATNR WERKS LGORT CHARG CLABS CINSM CEINM CSPEM
    INTO TABLE LT_MCHB
    FROM MCHB
    WHERE MATNR = V_MATNR AND
          WERKS = V_WERKS AND
          CHARG = V_CHARG.
    LOOP AT LT_MCHB.
      LT_MCHB-CLABS1 = LT_MCHB-CLABS.
      LT_MCHB-CINSM1 = LT_MCHB-CINSM.
      LT_MCHB-CEINM1 = LT_MCHB-CEINM.
      LT_MCHB-CSPEM1 = LT_MCHB-CSPEM.
      ADD: LT_MCHB-CLABS1 TO V_CLABS,
           LT_MCHB-CINSM1 TO V_CINSM,
           LT_MCHB-CEINM1 TO V_CEINM,
           LT_MCHB-CSPEM1 TO V_CSPEM.
    ENDLOOP.

*-- End of MD01

    V_SUM_NETWEIGHT = V_KALAB + V_KAINS + V_KASPE +
                      V_CLABS + V_CINSM + V_CEINM +
                      V_CSPEM.

  ENDIF.

ENDFORM.                    " get_net_weight

*&---------------------------------------------------------------------*
*&      Form  cleardotcomma
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_TAB_ATWTB  text
*----------------------------------------------------------------------*
FORM CLEARDOTCOMMA  USING    V_TY_INPUT.
  V_TEST = V_TY_INPUT.
  CONDENSE V_TEST NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.' IN V_TEST WITH ''.
  REPLACE ALL OCCURRENCES OF ',' IN V_TEST WITH ''.
  V_TY_INPUT = V_TEST.
ENDFORM.                    " cleardotcomma

*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM TY_RIGHT_JUSTIFIED USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.
  REPLACE ALL OCCURRENCES OF '.0' IN V_VALUE WITH ' '.

  PERFORM CLEARDOTCOMMA USING V_VALUE.

  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    " RIGHT_JUSTIFIED

*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM TY_LEFT_JUSTIFIED USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.

  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).

  DO V_STRLEN TIMES.
    CONCATENATE ' ' V_VALUE INTO V_VALUE.
  ENDDO.

ENDFORM.                    " RIGHT_JUSTIFIED


*&---------------------------------------------------------------------*
*&      Form  mod_weight_alias
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_MATNR  text
*      -->P_V_CHARG  text
*      -->P_V_WERKS  text
*      -->P_V_TYPE  text
*----------------------------------------------------------------------*
FORM MOD_WEIGHT_ALIAS  USING    V_MATNR
                                V_CHARG
                                V_WERKS
                                V_TYPE.


  SELECT SINGLE LENGT WIDTH THICK DENSI
  INTO (WA_LENGT, WA_WIDTH, WA_THICK, WA_DENSI)
  FROM ZALIAS
  WHERE
  MATNR = V_MATNR AND
  CHARG = V_CHARG AND
  WERKS = V_WERKS AND
  ZALIA = V_TYPE.

  IF SY-SUBRC = 0.
* check weight of box or pallet,
    IF V_SUM_NETWEIGHT_TEMP EQ SPACE.
      V_SUM_NETWEIGHT = ( WA_LENGT * WA_WIDTH * WA_THICK * WA_DENSI ) / 1000000.
    ENDIF.

    V_FLAG_WEIGHT_ZZALIAS = 'X'.
  ENDIF.
ENDFORM.                    " mod_weight_alias


*&---------------------------------------------------------------------*
*&      Form  new_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM NEW_TEXT_DATA .

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.

* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(20),
         V_S_INCH_INTER(40),
         V_FEET  TYPE P DECIMALS 2,
*for D009/iterfilm
         V_FEET_INTER TYPE P,
         V_S_FEET(20),
         V_S_FEET_INTER(40),

*mode 3 decimal
*------{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_lbs  TYPE p DECIMALS 3,
         V_LBS  TYPE P DECIMALS 2,
*------}
         V_S_LBS(20),
         V_S_LBS_INTER(40),
         V_SPLICE1_INTER  TYPE P,
         V_SPLICE1  TYPE P DECIMALS 2,
         V_S_SPLICE1(20),
         V_SPLICE2_INTER  TYPE P,
         V_SPLICE2  TYPE P DECIMALS 2,
         V_S_SPLICE2(20),
         V_TEST(100) VALUE 39,
         V_INFO_ERROR(100) TYPE C,
         V_INFO_THICKNESS(20) TYPE C.
*mode 1 decimal - 5 digit
  DATA : V_LEN_MIC(2) VALUE 8,
*mode 2 decimal - 5 digit
         V_LEN_GAUGE(2) VALUE 8,
         V_LEN_CORE(2) VALUE 10,
         V_LEN_IN_OUT(2) VALUE 15,
         V_LEN_NORMAL(2) VALUE 8,
*mode 3 decimal x
         V_LEN_WEIGHT(2) VALUE 8,
         V_STRLEN(2),
         V_LEN_SOITEM(2) VALUE 17,
         V_LEN_WIDTH(2) VALUE 4,
         V_LEN_INCH(2) VALUE 6,
         V_LEN_LENGTH(2) VALUE 6,
         V_LEN_FEET(2) VALUE 7,
         V_LEN_LBS(2) VALUE 9.

*mode decimal 3
  DATA :
*---{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_weight TYPE p DECIMALS 3,
         V_WEIGHT TYPE P DECIMALS 2,
*---}
         V_LENGTH TYPE P DECIMALS 2,
         V_WIDTH  TYPE P DECIMALS 2,
         V_SPLICE2_MIRING TYPE P DECIMALS 2,
         V_SPLICE1_MIRING TYPE P DECIMALS 2.
*DATA : v_i_atwtb(16) TYPE p.

  DATA :
        V_CORE_SS(3) TYPE C, "Added by AKBAR 15.03.2019 (Type label SANYO EPac)
        V_STOUCH1 TYPE STRING, "Added by AKBAR 13.11.2019 (label SANYO EPac add barcode film)
        V_TABIX_TEMP TYPE SY-TABIX. "Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

 DATA  : V_TEMP(20). " Add by Fany at 16-May-2025 for Laminator Subcont Project
 DATA: IT_TEMPZCODE TYPE TABLE OF STRING WITH HEADER LINE. " Add by Fany at 16-May-2025 for Laminator Subcont Project

* Get SO NUmber and Item from last Batch
  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM.

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = V_MATNR AND
  WERKS = V_WERKS AND
*    lgort = v_lgort and
  CHARG = V_CHARG AND
  ( KALAB > 0 OR
  KAINS > 0 OR
  KASPE > 0 ).


  IF SY-SUBRC = 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_VBELN
      IMPORTING
        OUTPUT = V_VBELN.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_POSNR
      IMPORTING
        OUTPUT = V_POSNR.


    CONCATENATE V_VBELN V_POSNR INTO V_SONUM_ITEM SEPARATED BY '/'.

  ENDIF.



*Get Net weight...
  PERFORM GET_NET_WEIGHT.
  CLEAR :
*          v_erdat_mm,
*          v_erdat_yy,
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_GRADE,
          V_DERIVATIVEMS,
          V_DERIVATIVESS,
          V_POSITIONMS,
          V_POSITIONSS,
          V_ZZPACKING,
          V_LABELTYPE.
* ZZALIAS is the first priority...
* if zzalias ne space then zzalias = zztype...
  SORT V_TAB BY ATNAM.


* Reset v_flag_zzalias to ''
  V_FLAG_ZZALIAS = ''.

* reset wa alias
  WA_LENGT = SPACE.
  WA_WIDTH = SPACE.
  WA_THICK = SPACE.
  WA_DENSI = SPACE.
  V_FLAG_WEIGHT_ZZALIAS = ''.


  LOOP AT V_TAB.

    IF V_TAB-ATNAM = 'ZZALIAS'.

      V_TYPE = V_TAB-ATWRT.
      V_FLAG_ZZALIAS = 'X'.

      PERFORM MOD_WEIGHT_ALIAS USING V_MATNR V_CHARG V_WERKS V_TYPE.


      READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        V_TAB-ATWRT = V_TYPE.
        V_TAB-ATWTB = V_TYPE.
        MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
      ENDIF.
    ENDIF.

    IF V_FLAG_ZZALIAS <> 'X'.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        V_TYPE = V_TAB-ATWRT.
      ENDIF.
    ENDIF.

* Get the roll No...
    IF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PRODLINE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
      V_GRADE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
      V_DERIVATIVEMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
      V_POSITIONMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
      V_DERIVATIVESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
      V_POSITIONSS = V_TAB-ATWRT.
*}

*get label type value
    ELSEIF V_TAB-ATNAM = 'ZZLABEL'.
      V_LABELTYPE = V_TAB-ATWRT.
      V_LABELIMGNEW = V_TAB-ATWRT.
      V_LABELORIG = V_TAB-ATWRT.
    ENDIF.

* For print Slit Roll, ignore zzpacking...
    IF V_TAB-ATNAM = 'ZZPACKING'.
      IF SY-CPROG = 'ZPPPPRINTLABEL' OR SY-TCODE = 'MB90'.
        V_ZZPACKING = ' '.
        CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
      ELSEIF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
        IF V_MAGRV = 'BOX'.
          V_ZZPACKING = V_TAB-ATWRT.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ELSE.
          V_ZZPACKING = 'PL'.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ENDIF.
      ENDIF.
    ENDIF.

*For Roll Expired Live
    IF V_TAB-ATNAM = 'ZZEXPIREDLIVE'.
      V_LIVE = ''.
      V_LIVE = V_TAB-ATWTB.
    ENDIF.

  ENDLOOP.

  "---------------------------------------------------
  "Start Add Bothside Treatment by Fiqih (29.04.2026)
* Get Bothside Treatment...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZINSIDE'.
  IF SY-SUBRC = 0.
    DATA: LV_TEXT2(20) TYPE C,
          LV_TEXT4(20) TYPE C,
          LV_LABELCODE(4) TYPE C.

    "Ambil Kode Labelnya Saja
    LV_LABELCODE = V_LABELTYPE+2.

    SELECT SINGLE  TEXT2 TEXT4
      INTO (LV_TEXT2, LV_TEXT4)
      FROM ZMAP_LABEL
      WHERE CODE EQ LV_LABELCODE.

    CONDENSE V_TYPE.
    IF V_TYPE NE '' AND LV_TEXT2 NE '' AND V_TYPE CS LV_TEXT2.
      V_TAB-ATWTB = LV_TEXT4.
    ENDIF.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.
  "End Add Bothside Treatment by Fiqih (29.04.2026)

* Weight is getting from formula...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC <> 0.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELORIG = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      PERFORM GET_ACTWEIGHT CHANGING V_SUM_NETWEIGHT.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

    IF V_LABELORIG = 'SB10' OR V_LABELORIG = 'K100' OR V_LABELORIG = 'KA01'.
      DATA V_ROUND_WEIGHT TYPE P DECIMALS 1.
      V_TAB-ATNAM    = 'ZZWEIGHT'.
      V_ROUND_WEIGHT = V_SUM_NETWEIGHT.
      V_TAB-ATWTB    = V_ROUND_WEIGHT.
    ELSE.
      V_TAB-ATNAM = 'ZZWEIGHT'.
      V_TAB-ATWTB = V_SUM_NETWEIGHT.
    ENDIF.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELORIG = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      V_TABIX_TEMP = SY-TABIX.
      PERFORM GET_ACTWEIGHT CHANGING V_SUM_NETWEIGHT.

      SY-TABIX = V_TABIX_TEMP.
      V_TAB-ATNAM = 'ZZWEIGHT'.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELORIG = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      PERFORM GET_ACTLENGTH CHANGING V_TAB-ATWTB.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

*    IF v_zzconversionmtrkg IS NOT INITIAL.
    V_TAB-ATNAM = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
*    ENDIF.
  ELSE.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELORIG = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      V_TABIX_TEMP = SY-TABIX.
      PERFORM GET_ACTLENGTH CHANGING V_TAB-ATWTB.

      SY-TABIX = V_TABIX_TEMP.
      V_TAB-ATNAM = 'ZZLENGTH'.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
*    ENDIF.
  ENDIF.
*----------------------/

* Start Add by Fany at 16-May-2025 For Laminator Subcont Project
  IF V_LABELORIG = 'G104'.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
      IF SY-SUBRC EQ 0.
         CLEAR : IT_TEMPZCODE.
         CLEAR : V_TEMP.
         SPLIT V_TAB-ATWRT AT SPACE INTO TABLE IT_TEMPZCODE.
         READ TABLE IT_TEMPZCODE INDEX LINES( IT_TEMPZCODE ).
          IF SY-SUBRC EQ 0.
             V_TEMP = IT_TEMPZCODE.
             IF V_TEMP NE ''.
               READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
               IF SY-SUBRC = 0.
                 V_TAB-ATWRT = V_TEMP.
                 V_TAB-ATWTB = V_TEMP.
                 MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
               ENDIF.
             ENDIF.
          ENDIF.
      ENDIF.
  ENDIF.
* End Add by Fany at 16-May-2025 For Laminator Subcont Project

*Get Roll No...
*  CONCATENATE v_prodline v_type v_monthyear v_sequencenbr INTO v_rollno SEPARATED BY space.
* Modified (PRA) 14/03/05
  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.

* Only for t-code vl74...
  IF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
* Barcode Box No(from exidv plant and erdat)...
    CLEAR V_PLANT_CODE.
    IF V_WERKS = '1000'.
      V_PLANT_CODE = 'WR'.
    ELSEIF V_WERKS = '2000'.
      V_PLANT_CODE = 'KR'.
    ELSEIF V_WERKS = '3000'.
      V_PLANT_CODE = 'JR'.
    ELSEIF V_WERKS = 'TTA2'. "Added by AKBAR 24.10.2019 (New label type for TTA)
      V_PLANT_CODE = 'TA'.
    ELSEIF V_WERKS = 'TTE'. "Added by AKBAR 30.10.2019 (New label type for TTE)
      V_PLANT_CODE = 'TE'.
    ENDIF.


    CONCATENATE V_ERDAT_MM V_ERDAT_YY INTO V_ERDAT.

    IF V_ZZPACKING <> 'PL'.
      CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.
    ELSE.
      CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT V_ERDAT_DD INTO V_BOX_NO SEPARATED BY '-'.
    ENDIF.

*Barcode box no.
    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_EXIDV.
    APPEND V_TAB.

    "Start Added by AKBAR 15.03.2019 (Type label SANYO EPac)
    IF V_LABELORIG = 'SE01' OR V_LABELORIG = 'SE02' OR V_LABELORIG = 'SE03' OR V_LABELORIG = 'SE04' OR V_LABELORIG = 'SE05'.
      V_TAB-ATNAM = 'ZZBARC1'.
      V_TAB-ATWTB = V_SUM_NETWEIGHT.
      PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
      V_LBS = V_TAB-ATWTB * V_C_LBS.
      WRITE V_LBS TO V_TAB-ATWTB.
      PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT
                                      V_TAB-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
      APPEND V_TAB.
    ENDIF.
    "End Added by AKBAR 15.03.2019 (Type label SANYO EPac)

*Total roll
    V_TAB-ATNAM = 'ZZTOTRL'.
    V_TAB-ATWTB = V_TOT_ROLL.
    APPEND V_TAB.

*Total box.
    V_TAB-ATNAM = 'ZZTOTBX'.
    V_TAB-ATWTB = V_TOT_BOX.
    APPEND V_TAB.

* Pallet or Box no...
    IF V_MAGRV = 'BOX'.
      V_TAB-ATNAM = 'ZZBOX'.
      V_TAB-ATWTB = V_BOX_NO.

      APPEND V_TAB.
    ELSEIF V_MAGRV = 'PLT'.
      V_TAB-ATNAM = 'ZZPALET'.
      V_TAB-ATWTB = V_BOX_NO.
      APPEND V_TAB.
    ENDIF.

*Add Expired Date
    CLEAR: V_POSTDATE.
    IF V_CHARG+0(1) = '9'.   "Get Expired from TTA
      V_CHARG_TTA = V_CHARG.
      V_CHARG_TTA+0(1) = '0'.
      SELECT SINGLE MATNR INTO V_MATNR_TTA FROM MCH1 WHERE CHARG = V_CHARG_TTA.
      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = V_MATNR_TTA
          CHARG = V_CHARG_TTA
        IMPORTING
          PDATE = V_POSTDATE.
      IF V_POSTDATE = '00000000'.
        MESSAGE 'Batch TTA tidak ditemukan..!' TYPE 'E'.
      ENDIF.
    ELSE.
      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = V_MATNR
          CHARG = V_CHARG
        IMPORTING
          PDATE = V_POSTDATE.
    ENDIF.

    IF SY-SUBRC = 0.
      CLEAR : V_GETMANUF.
      SELECT SINGLE TEXT5 INTO "Added by Fany 23.01.2025
        V_GETMANUF
      FROM ZMAP_LABEL WHERE
      CODE = V_LABELORIG AND TYPE = 'DOS' AND TEXT5 = 'MANUF'.

      IF V_GETMANUF NE ''.
*        V_TAB-ATNAM = 'ZZEX'.
*        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
*        APPEND V_TAB.

        "Start Add New Label A172 by Fiqih 15/06/2026 - For DIsplay Manuf Date DD.MM.YYYY
        IF V_LABELORIG = 'A172'.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_POSTDATE+6(2) '.' V_POSTDATE+4(2) '.' V_POSTDATE+0(4) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        "End Add New Label A172 by Fiqih 15/06/2026 - For DIsplay Manuf Date DD.MM.YYYY
        ELSE.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        ENDIF.

*Mag-Data (Manufacturing Date : DD/MM/YYYY)
      ELSEIF ( V_LABELORIG = 'A113' OR V_LABELORIG = 'E109' ).
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4)  INTO V_TAB-ATWTB.
        APPEND V_TAB.
        "Case new label manuf and expired
      ELSEIF ( V_LABELORIG = 'A162' OR V_LABELORIG = 'C126' OR V_LABELORIG = 'D131' OR V_LABELORIG = 'G104' OR V_LABELORIG = 'G105').
        V_TAB-ATNAM = 'ZZMANUFDATE'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

        V_EXPDATE = V_POSTDATE + V_LIVE.
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.
      ELSE.
          IF V_LABELORIG = 'D201' OR V_LABELORIG = 'D205'      "without Peoduction date
            OR V_LABELORIG = 'D206' OR V_LABELORIG = 'D207' OR V_LABELORIG = 'D208'.   "Added by AKBAR 30.08.2019 (Type D206) & Type D207 at 11.12.2019
          ELSEIF V_LABELORIG = 'D121'. "Condition for label CKI, conditional expired live. Add by Fany 18.08.2025
             DATA : V_MAPEXP_BY_TYPE TYPE STRING.
             DATA : V_TYPE_TEMP(30).
             DATA : V_LIVE_TEMP(2).
             DATA : BEGIN OF IT_MAPEXP_BY_TYPE OCCURS 0,
                        TYPE_MONTH(30),
                    END OF IT_MAPEXP_BY_TYPE.
             READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
             SELECT SINGLE TEXT5 INTO
             V_MAPEXP_BY_TYPE
             FROM ZMAP_LABEL WHERE
             CODE = V_LABELORIG AND TYPE = 'DOS'.
             IF V_MAPEXP_BY_TYPE NE ''.
               SPLIT V_MAPEXP_BY_TYPE AT ',' INTO TABLE IT_MAPEXP_BY_TYPE.
               LOOP AT IT_MAPEXP_BY_TYPE.
                 SPLIT IT_MAPEXP_BY_TYPE-TYPE_MONTH AT '+' INTO V_TYPE_TEMP V_LIVE_TEMP.
                 IF V_TYPE_TEMP EQ V_TAB-ATWRT.
                   V_EXPDATE = V_POSTDATE + ( V_LIVE_TEMP * 30 ).
                   V_TAB-ATNAM = 'ZZEX'.
                   CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
                   APPEND V_TAB.
                   EXIT.
                 ENDIF.
               ENDLOOP.
             ENDIF.
          ELSE.
            IF V_LIVE <> ''.
              V_EXPDATE = V_POSTDATE + V_LIVE.
              V_TAB-ATNAM = 'ZZEX'.
              CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
              APPEND V_TAB.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDIF.


  ELSE.
*Roll no and barcode roll no.
    V_TAB-ATNAM = 'ZZROLLNO'.
    V_TAB-ATWTB = V_ROLLNO.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBCROLL'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.



  ENDIF.



**EX value
*  v_tab-atnam = 'ZZEX'.
*  v_tab-atwtb = 'EX'.
*  APPEND v_tab.

*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

* Do the conversion...
  CLEAR : V_S_INCH,
          V_S_GAUGE,
          V_S_FEET,
          V_S_LBS,
          V_S_SPLICE1,
          V_S_SPLICE2.

* Loop zlabel for conversion (Inch, Feet, Lbs, Gauge)
* And update the data which is not the conversion's value...
* Conversion value will be transfer to text file after this looping condition...
  SORT V_ZLABEL BY ATNAM.
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.
    CLEAR V_TAB-ATWTB.

    READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
    IF SY-SUBRC = 0.
* split/erase "kg" from net weight.
      IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        SPLIT V_TAB-ATWTB AT V_DEL INTO V_TAB-ATWTB V_1.
      ENDIF.

* Set conversion & Right Justified...
* Get the Thickness value(Mic -> Gauge)
      IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.

        IF V_FLAG_ZZALIAS <> 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_THICK.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ENDIF.


        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

        V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
        WRITE V_GAUGE TO V_S_GAUGE.
        V_THICKNESS = V_TAB-ATWTB.

*For Alias
        CONDENSE V_THICKNESS NO-GAPS.

        IF V_LABELORIG = 'A147' OR V_LABELORIG = 'A148' OR V_LABELORIG = 'A172'.
          CONCATENATE V_THICKNESS ' mic.' INTO V_INFO_THICKNESS.
        ELSE.
          CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.
        ENDIF.

        V_TAB-ATWTB = ''.
        V_S_GAUGE = ''.

      ENDIF.

* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH .
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        IF V_LABELORIG = 'A129' OR  V_LABELORIG = 'A302' OR  V_LABELORIG = 'A303' OR V_LABELORIG = 'A306'.
          PERFORM GET_INCH_FR_SO USING V_S_INCH.
        ELSE.
          V_INCH =   V_TAB-ATWTB * V_C_INCH.
          WRITE V_INCH TO V_S_INCH.
        ENDIF.

        V_WIDTH = V_TAB-ATWTB.
*        WRITE v_width TO v_tab-atwtb.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_WIDTH
                                      V_TAB-ATWTB.
      ENDIF.

* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.

        IF V_LABELORIG = 'B211' OR V_LABELORIG = 'B212' OR V_LABELORIG = 'B222'
          OR V_LABELORIG = 'D211' OR V_LABELORIG = 'D212' OR V_LABELORIG = 'D218'.
          PERFORM GET_FEET_FR_SO USING V_S_FEET.
        ELSE.
          V_FEET   = V_TAB-ATWTB * V_C_FEET.
          WRITE V_FEET TO V_S_FEET.
        ENDIF.

        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                       V_TAB-ATWTB.

*        ENDIF.
      ENDIF.

* Get The Length Value(MM -> Inch) For SheetLine
* Replace Feet to Inch in format

      IF V_ZLABEL-ATNAM = 'ZZLENGTHSHT'.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_INCH.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.


* Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.

*        PERFORM conv_to_char USING v_tab-atwtb.
        PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
        V_LBS = V_TAB-ATWTB * V_C_LBS.

        IF V_LABELORIG = 'SB10' OR V_LABELORIG = 'K100' OR V_LABELORIG = 'KA01'.
          DATA: V_ROUND_WEIGHT2 TYPE P DECIMALS 1,
                V_ROUND_LBS     TYPE P DECIMALS 1.
          PERFORM CONVERSION_WEIGHT USING V_LBS CHANGING V_ROUND_LBS.
          WRITE V_ROUND_LBS TO V_S_LBS.
          V_ROUND_WEIGHT2 = V_TAB-ATWTB.
          WRITE V_ROUND_WEIGHT2 TO V_TAB-ATWTB.
        ELSE.
          V_WEIGHT = V_TAB-ATWTB.
          WRITE V_WEIGHT TO V_TAB-ATWTB.
          WRITE V_LBS TO V_S_LBS.
        ENDIF.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Get The Splices At 1st Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-1'.
      ENDIF.

*Get The Splices At 2nd Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
      ENDIF.

*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        "Start Added by AKBAR 15.03.2019 (Type label SANYO EPac)
        IF V_LABELORIG = 'SE01' OR V_LABELORIG = 'SE02' OR V_LABELORIG = 'SE03' OR V_LABELORIG = 'SE04' OR V_LABELORIG = 'SE05'.
          SPLIT V_TAB-ATWTB AT '(' INTO V_TAB-ATWTB V_CORE_SS.
          SHIFT V_CORE_SS BY 1 PLACES RIGHT.
          SHIFT V_CORE_SS LEFT DELETING LEADING SPACE.
          CONCATENATE V_CORE_SS '(' V_TAB-ATWTB ')' INTO V_TAB-ATWTB.
        ELSE.
          CONCATENATE V_TAB-ATWTB 'CORE' INTO V_TAB-ATWTB.
        ENDIF.
        "End Added by AKBAR 15.03.2019 (Type label SANYO EPac)
      ENDIF.

*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
        IF V_FLAG_ZZALIAS <> 'X'.

          CONCATENATE V_TAB-ATWRT  V_THICKNESS INTO V_TAB-ATWTB SEPARATED BY '-' .
          CONDENSE V_TAB-ATWTB NO-GAPS.
        ELSE.
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB.
        ENDIF.


      ENDIF.

*Clean Grade Value
      IF V_ZLABEL-ATNAM = 'ZZGRADE'.
        V_TAB-ATWTB = ''.
      ENDIF.


* Criteria Grade for all label except toyobo
      IF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        IF V_TAB-ATWRT = '2'.
          V_CRITERIA = '.'.
        ELSE.
          V_CRITERIA = ' '.
        ENDIF.
      ENDIF.

*//
      V_ZLABEL-DATA2 = V_TAB-ATWTB.

*---
    ELSEIF V_ZLABEL-ATNAM = 'ZZODR'.
      DATA: V_BSTKD_E LIKE VBKD-BSTKD_E,
            V_CHAR10 TYPE N LENGTH 10.  "like vbak-vbeln.

      V_CHAR10 = V_VBELN.

      IF V_LABELORIG = 'J120' OR V_LABELORIG = 'J121' OR V_LABELORIG = 'A305' OR V_LABELORIG = 'A308' OR
         V_LABELORIG = 'J122' OR V_LABELORIG = 'J123' OR V_LABELORIG = 'A309' OR
         V_LABELORIG = 'B215 ' OR V_LABELORIG = 'B216 ' OR V_LABELORIG = 'B223' OR
         V_LABELORIG = 'D213' OR V_LABELORIG = 'D214' OR V_LABELORIG = 'D219'.

        SELECT SINGLE BSTKD_E INTO V_BSTKD_E FROM VBKD WHERE VBELN = V_CHAR10.

        IF SY-SUBRC = 0.
*            CONCATENATE '<STX><ESC>' v_zlabel-data1 v_bstkd '<ETX>' INTO text_data-str_text.
          V_ZLABEL-DATA2 = V_BSTKD_E.
        ENDIF.
      ENDIF.

*---
    ELSE.
      V_ZLABEL-DATA2 = ' '.
    ENDIF.

    MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
  ENDLOOP.

  IF V_LABELORIG = 'A147' OR V_LABELORIG = 'A148' OR V_LABELORIG = 'A172'.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
    IF SY-SUBRC = 0.
      V_ZLABEL-DATA2 = V_TAB-ATWRT.
      MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZTHICKNESS' .
    ENDIF.
  ENDIF.

  IF V_LABEL = 'BKA211' OR V_LABEL = 'PLA211' OR
     V_LABEL = 'BKA212' OR V_LABEL = 'PLA212' OR
     V_LABEL = 'BKA213' OR V_LABEL = 'PLA213'.
    PERFORM F_INSIDE.
  ENDIF.

*/---Added on 150405---
*cek previouly label

  IF V_LABELIMGOLD <> V_LABELIMGNEW.

*clear image and format to text-data---------------------
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      APPEND TEXT_DATA.
    ENDLOOP.


    SELECT IMAG1
      INTO CORRESPONDING FIELDS OF TABLE V_ZLABELMAPIMAGE
      FROM ZLABELMAPIMAGE
      WHERE KODE = V_LABELIMGNEW ORDER BY IMAG1.


    LOOP AT V_ZLABELMAPIMAGE.
*load image to text-data---------------------
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
        APPEND TEXT_DATA.
      ENDLOOP.

    ENDLOOP.

  ENDIF.



******
  DO V_COPIES TIMES.
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      IF SY-TABIX = 2.
        SHIFT TEXT_DATA-STR_TEXT+7  RIGHT BY 2 PLACES .
        ADD 1 TO POSI.
        TEXT_DATA-STR_TEXT+6(3) = POSI.
      ENDIF.

      " Start add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)
      " 1. Eksekusi Subroutine (Hanya membuat baris baru)
      IF GV_IS_RTP = 'X'.
        LV_SHIFT_UP = 15. " P_SHIFT_UP (Naikkan Pallet No 20 dots)
        LV_GAP_DOWN = 30. " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
        PERFORM ADJUST_AND_INJECT_TEXT USING    'Pallet No.:'           " P_ANCHOR (Teks yg dicari)
                                                'Returnable Packaging'  " P_INJECT (Teks yg diinjeksi)
                                                'H199,TXT199'           " P_NEW_ID (ID unik TXT baru)
                                                LV_SHIFT_UP             " P_SHIFT_UP (Naikkan Pallet No 20 dots)
                                                LV_GAP_DOWN             " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
                                       CHANGING TEXT_DATA-STR_TEXT
                                                LV_INJECT_STR.
      ENDIF.

      " 2. APPEND BARIS ORIGINAL (Teks Pallet No.: yg sudah naik)
      APPEND TEXT_DATA.

      " 3. APPEND BARIS BARU (Teks RTP) KE TEXT_DATA
      IF LV_INJECT_STR IS NOT INITIAL.
        TEXT_DATA-STR_TEXT = LV_INJECT_STR.
        APPEND TEXT_DATA.     " Tambahkan Baris text RTP ke TEXT_DATA
        CLEAR LV_INJECT_STR.  " Bersihkan agar tidak ikut ke-append di loop berikutnya
      ENDIF.
      " End add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)

    ENDLOOP.

******

*Condition for start and end syntax label command.
    TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.
    APPEND TEXT_DATA.

*Combine all command into internal table.
    LOOP AT V_ZLABEL.
* Get the strlen variable and substract from v_strlen for purpose right justified.
      IF V_ZLABEL-ATNAM = 'ZZTEXT1'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_INFO_THICKNESS '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETX'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_FEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
        IF V_LABELORIG = 'A302' OR V_LABELORIG = 'A303' OR V_LABELORIG = 'A306'.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_INCH V_S_INCH.
        ENDIF.

        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING V_LEN_LBS "v_len_normal
                                      V_S_LBS.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_GAUGE
                                      V_S_GAUGE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_GAUGE '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS1'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_SPLICE1.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS2'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_SPLICE2.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_CRITERIA '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
       V_ZLABEL-ATNAM = 'ZZSOITEM'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_SOITEM
                                      V_SONUM_ITEM.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_SONUM_ITEM '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_SUM_QTYSHEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SUM_QTYSHEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

*-- add customer part number
    IF V_LABELTYPE = 'PLA129'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_POSNR
        IMPORTING
          OUTPUT = V_POSNR.

      CLEAR: V_PARTNO.
      SELECT SINGLE KDMAT INTO V_PARTNO FROM VBAP WHERE VBELN = V_VBELN AND POSNR = V_POSNR.

      IF V_PARTNO NE ''.
        CONCATENATE '<STX><ESC>F"PART  "<LF>Part no. ' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
        CONCATENATE '<STX><ESC>F"BPART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.
    ENDIF.


    IF V_LABELTYPE = 'PLA214' OR  V_LABELTYPE = 'PLA215' OR  V_LABELTYPE = 'PLE201' OR
      V_LABELTYPE = 'BKA214' OR  V_LABELTYPE = 'BKA215'  OR V_LABELTYPE = 'BKE201' OR V_LABELTYPE = 'PLA113'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_POSNR
        IMPORTING
          OUTPUT = V_POSNR.

      CLEAR: V_PARTNO.
      SELECT SINGLE KDMAT INTO V_PARTNO FROM VBAP WHERE VBELN = V_VBELN AND POSNR = V_POSNR.

      IF V_PARTNO NE ''.
        CONCATENATE '<STX><ESC>F"PART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.

    ENDIF.

    " Start Add by Fiqih 10.11.2025
*   Untuk semua jenis HU
    IF V_LABELORIG = 'A169' OR V_LABELORIG = 'A170'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_POSNR
        IMPORTING
          OUTPUT = V_POSNR.

      CLEAR: V_PARTNO.
      SELECT SINGLE KDMAT INTO V_PARTNO FROM VBAP WHERE VBELN = V_VBELN AND POSNR = V_POSNR.

      IF V_PARTNO NE ''.
        CONCATENATE '<STX><ESC>F"PART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.

    ENDIF.
    " End Add by Fiqih 10.11.2025

*-- end of customer part number

    "Start - Added by AKBAR 13.11.2019 (label SANYO EPac add barcode film)
    IF V_LABELORIG = 'SE01' OR V_LABELORIG = 'SE02' OR V_LABELORIG = 'SE03' OR V_LABELORIG = 'SE04' OR V_LABELORIG = 'SE05'.

      "untuk mengambil data Special Touch 1
      CLEAR: V_STOUCH1.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC = 0.
        V_STOUCH1 = V_TAB-ATWRT.
      ELSE.
        MESSAGE 'Special Touch - 1 belum memiliki data' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CLEAR: TEXT_DATA-STR_TEXT.
      TEXT_DATA-STR_TEXT = V_STOUCH1.
      CONCATENATE '<STX><ESC>F"FBARC  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

    ENDIF.
    "End - Added by AKBAR 13.11.2019 (label SANYO EPac add barcode film)

* Start Add by Fany 16-May-2025 Laminator Subscont Project
    IF V_LABELORIG = 'G104'.
       READ TABLE V_TAB WITH KEY ATNAM = 'ZZPOCUSTOMER'.
        IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>F"POCKI "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
            APPEND TEXT_DATA.
         ENDIF.

       READ TABLE V_TAB WITH KEY ATNAM = 'ZZSKU'.
        IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>F"SKU   "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
            APPEND TEXT_DATA.
        ENDIF.
    ENDIF.

    IF V_LABELORIG = 'G105'.
       DATA : V_CUST LIKE KNA1-NAME1.
       READ TABLE V_TAB WITH KEY ATNAM = 'ZZPOCUSTOMER'.
        IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>F"POCKI "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
            APPEND TEXT_DATA.
         ENDIF.

       READ TABLE V_TAB WITH KEY ATNAM = 'ZZCUSTOMER'.
        IF SY-SUBRC = 0.
          SELECT SINGLE NAME1 FROM KNA1
            INTO V_CUST WHERE KUNNR = V_TAB-ATWRT.

          IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>F"CUST  "<LF>' V_CUST '<ETX>' INTO TEXT_DATA-STR_TEXT.
            APPEND TEXT_DATA.
          ENDIF.
        ENDIF.
    ENDIF.


* End Enhancement for LAMI CKI.

*-- Add Packing weight for A212
    IF V_LABELORIG = 'A211' OR V_LABELORIG = 'A212' OR V_LABELORIG = 'A213'.
      PERFORM GET_TEXT.
    ENDIF.

* Number of copies...
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

  ENDDO.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.

ENDFORM.                    " new_text_data


**&---------------------------------------------------------------------*
**&      Form  get_inch_fr_so
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM GET_TEXT.
  DATA: V_SONUM1 LIKE VBAP-VBELN,  "TYPE p LENGTH 10,
         V_SONUM2 LIKE VBAP-POSNR,  " TYPE p LENGTH 6,
         V_TDNAME LIKE THEAD-TDNAME.

  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.
  DATA: V_WCORE(12),
        V_WBOKS(12),
        V_WPALT(12),
        V_WGROS(12),
        V_CORE TYPE P DECIMALS 2,
                V_BOKS TYPE P DECIMALS 2,
        V_PALT TYPE P DECIMALS 2,
        V_GROS TYPE P DECIMALS 2.

  SELECT SINGLE VBELN POSNR INTO (V_SONUM1, V_SONUM2)
  FROM MSKA
  WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

  CONCATENATE V_SONUM1 V_SONUM2 INTO V_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  CLEAR: V_WCORE, V_WBOKS, V_WPALT, V_WGROS, V_CORE, V_BOKS, V_PALT, V_GROS.

  LOOP AT IT_LINES.
    IF IT_LINES-TDLINE+0(2) = 'WC'.
      V_CORE = IT_LINES-TDLINE+3(17).
    ELSEIF IT_LINES-TDLINE+0(2) = 'WB'.
      V_BOKS = IT_LINES-TDLINE+3(17).
    ELSEIF IT_LINES-TDLINE+0(2) = 'WP'.
      V_PALT = IT_LINES-TDLINE+3(17).
    ENDIF.
  ENDLOOP.


  IF V_LABEL = 'BKA211' OR  V_LABEL = 'BKA212' OR  V_LABEL = 'BKA213'.
    V_CORE = V_CORE * V_TOT_ROLL.
    V_GROS = V_BOKS + V_CORE + V_SUM_NETWEIGHT.
  ELSEIF V_LABEL = 'PLA211' OR V_LABEL = 'PLA212' OR V_LABEL = 'PLA213'.
    V_CORE = V_CORE * V_TOT_ROLL.
    V_BOKS = V_BOKS * V_TOT_BOX.
    V_GROS = V_PALT + V_CORE + V_BOKS + V_SUM_NETWEIGHT.
  ENDIF.

  V_WGROS = V_GROS.
  V_WCORE = V_CORE.
  V_WBOKS = V_BOKS.
  V_WPALT = V_PALT + V_BOKS.

  CONDENSE V_WCORE.
  CONDENSE V_WBOKS.
  CONDENSE V_WPALT.
  CONDENSE V_WGROS.
  CONCATENATE V_WCORE 'Kg' INTO V_WCORE SEPARATED BY SPACE.
  CONCATENATE V_WBOKS 'Kg' INTO V_WBOKS SEPARATED BY SPACE.
  CONCATENATE V_WPALT 'Kg' INTO V_WPALT SEPARATED BY SPACE.
  CONCATENATE V_WGROS 'Kg' INTO V_WGROS SEPARATED BY SPACE.
  WRITE V_WCORE TO V_WCORE RIGHT-JUSTIFIED.
  WRITE V_WBOKS TO V_WBOKS RIGHT-JUSTIFIED.
  WRITE V_WPALT TO V_WPALT RIGHT-JUSTIFIED.
  WRITE V_WGROS TO V_WGROS RIGHT-JUSTIFIED.

  IF V_LABEL = 'BKA211' OR V_LABEL = 'BKA212' OR  V_LABEL = 'BKA213'.
    CONCATENATE '<STX><ESC>F"WCORE "<LF>Core WT:' V_WCORE '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
    CONCATENATE '<STX><ESC>F"WPACK "<LF>Box WT :' V_WBOKS '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
    CONCATENATE '<STX><ESC>F"WGROS "<LF>GW Box :' V_WGROS '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
  ELSEIF V_LABEL = 'PLA211' OR V_LABEL = 'PLA212' OR V_LABEL = 'PLA213'.
    CONCATENATE '<STX><ESC>F"WCORE "<LF>Core WT   :' V_WCORE '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
    CONCATENATE '<STX><ESC>F"WPACK "<LF>Packing WT:' V_WPALT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
    CONCATENATE '<STX><ESC>F"WGROS "<LF>GW Pallet :' V_WGROS '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
  ENDIF.
ENDFORM.                    "


*&---------------------------------------------------------------------*
*&      Form  f_inside
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_INSIDE. "concatenate inside and outside
  DATA: V_INOUT(50).
  CLEAR: V_ZLABEL.
  READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZOUTSIDE'.
  V_INOUT = V_ZLABEL-DATA2.

  CLEAR: V_ZLABEL.
  READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZOUTSIDE'.
  CONCATENATE V_ZLABEL-DATA2 '/' V_INOUT INTO V_ZLABEL-DATA2.
  MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZINSIDE'.

  CLEAR: V_ZLABEL-DATA2.
  MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZOUTSIDE'.
ENDFORM.                    "f_inside

*&---------------------------------------------------------------------*
*&      Form  inter_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INTER_TEXT_DATA .
* Get SO NUmber and Item from last Batch
  DATA : "v_aufnr_inter TYPE afpo-aufnr,
         V_AUFNR_INTER_COMBINE TYPE AFPO-AUFNR,
         V_AUFNR_INTER_ORIGINAL TYPE AFPO-AUFNR,
         V_CHARG_DIGITREF TYPE AFPO-CHARG,
         V_AUFNR_TEMP TYPE AFPO-AUFNR.

  DATA : ITAB_CONSTANT LIKE ZCONSTANT.
  DATA :
        V_C_FEET_INTER_BOPET  TYPE P DECIMALS 5  VALUE '3.2801',
        V_C_INCH_INTER  TYPE P DECIMALS 7 VALUE '0.0392100',
        V_C_LBS  TYPE P DECIMALS 4 VALUE '2.2046',
        V_C_GAUGE VALUE 4,
        V_PART(40) TYPE C.

  CLEAR: V_VBELN, V_POSNR, V_SONUM_ITEM.

**Get Original batch from zdigitref
*  SELECT SINGLE aufnr FROM zdigitref
*  INTO v_aufnr_inter_original
*  WHERE charg EQ v_charg.
*
*  SELECT SINGLE charg FROM zdigitref
*  INTO v_charg_digitref
*  WHERE zdigitref~aufnr EQ v_aufnr_inter_original.
*
**Get Constant modified zpp001s get from digitctl
*  CONCATENATE '00' v_charg_digitref INTO v_aufnr_temp.
*
*  SELECT SINGLE * FROM zconstant
*  INTO itab_constant
*  WHERE zconstant~aufnr EQ v_aufnr_temp.
*
*  IF sy-subrc = 0.
*    IF itab_constant-mf_length <> ''.
*      v_c_feet_inter_bopet = itab_constant-mf_length.
*    ENDIF.
*
*    IF itab_constant-mi_width <> ''.
*      v_c_inch_inter  = itab_constant-mi_width.
*    ENDIF.
*
*    IF itab_constant-kl_weight <> ''.
*      v_c_lbs  = itab_constant-kl_weight.
*    ENDIF.
*
*    IF itab_constant-mg_thick <> ''.
*      v_c_gauge = itab_constant-mg_thick.
*    ENDIF.
*
*    v_part = itab_constant-info1.
*  ENDIF.
*

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = V_MATNR AND
  WERKS = V_WERKS AND
  CHARG = V_CHARG AND
  ( KALAB > 0 OR
  KAINS > 0 OR
  KASPE > 0 ).


  IF SY-SUBRC = 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_VBELN
      IMPORTING
        OUTPUT = V_VBELN.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_POSNR
      IMPORTING
        OUTPUT = V_POSNR.


    CONCATENATE V_VBELN V_POSNR INTO V_SONUM_ITEM SEPARATED BY '/'.

  ENDIF.

*Get Net weight...
  PERFORM GET_NET_WEIGHT.
  CLEAR :
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_GRADE,
          V_DERIVATIVEMS,
          V_DERIVATIVESS,
          V_POSITIONMS,
          V_POSITIONSS,
          V_ZZPACKING,
          V_LABELTYPE.
* ZZALIAS is the first priority...
  SORT V_TAB BY ATNAM.

* Reset v_flag_zzalias to ''
  V_FLAG_ZZALIAS = ''.

* reset wa alias
  WA_LENGT = SPACE.
  WA_WIDTH = SPACE.
  WA_THICK = SPACE.
  WA_DENSI = SPACE.
  V_FLAG_WEIGHT_ZZALIAS = ''.


  LOOP AT V_TAB.

    IF V_TAB-ATNAM = 'ZZALIAS'.

      V_TYPE = V_TAB-ATWRT.
      V_FLAG_ZZALIAS = 'X'.

      PERFORM MOD_WEIGHT_ALIAS USING V_MATNR V_CHARG V_WERKS V_TYPE.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        V_TAB-ATWRT = V_TYPE.
        V_TAB-ATWTB = V_TYPE.
        MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
      ENDIF.
    ENDIF.

    IF V_FLAG_ZZALIAS <> 'X'.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        V_TYPE = V_TAB-ATWRT.
      ENDIF.
    ENDIF.


* Get the roll No...
    IF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PRODLINE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.

*( 27/06/06 Remove from characteristics)

    ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
      V_GRADE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
      V_DERIVATIVEMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
      V_POSITIONMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
      V_DERIVATIVESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
      V_POSITIONSS = V_TAB-ATWRT.
*}

*get label type value
    ELSEIF V_TAB-ATNAM = 'ZZLABEL'.
      V_LABELTYPE = V_TAB-ATWRT.
      V_LABELIMGNEW = V_TAB-ATWRT.
      V_LABELORIG = V_TAB-ATWRT.
    ENDIF.

* For print Slit Roll, ignore zzpacking...
    IF V_TAB-ATNAM = 'ZZPACKING'.
      IF SY-CPROG = 'ZPPPPRINTLABEL' OR SY-TCODE = 'MB90'.
        V_ZZPACKING = ' '.
        CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
      ELSEIF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
        IF V_MAGRV = 'BOX'.
          V_ZZPACKING = V_TAB-ATWRT.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ELSE.
          V_ZZPACKING = 'PL'.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Weight is getting from formula...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC <> 0.
    V_TAB-ATNAM = 'ZZWEIGHT'.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.


  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.
    V_TAB-ATNAM = 'ZZLENGTH'.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.
*----------------------/

*Get Roll No...
  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.


* Only for t-code vl74...
  IF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
* Barcode Box No(from exidv plant and erdat)...
    CLEAR V_PLANT_CODE.
    IF V_WERKS = '1000'.
      V_PLANT_CODE = 'WR'.
    ELSEIF V_WERKS = '2000'.
      V_PLANT_CODE = 'KR'.
    ELSEIF V_WERKS = '3000'.
      V_PLANT_CODE = 'JR'.
    ENDIF.

    CONCATENATE V_ERDAT_MM V_ERDAT_YY INTO V_ERDAT.

    CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.

*Barcode box no.
    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_EXIDV.
    APPEND V_TAB.
*Total roll
    V_TAB-ATNAM = 'ZZTOTRL'.
    V_TAB-ATWTB = V_TOT_ROLL.
    APPEND V_TAB.

*Total box.
    V_TAB-ATNAM = 'ZZTOTBX'.
    V_TAB-ATWTB = V_TOT_BOX.
    APPEND V_TAB.

* Pallet or Box no...
    IF V_MAGRV = 'BOX'.
      V_TAB-ATNAM = 'ZZBOX'.
      V_TAB-ATWTB = V_BOX_NO.

      APPEND V_TAB.
    ELSEIF V_MAGRV = 'PLT'.
      V_TAB-ATNAM = 'ZZPALET'.
      V_TAB-ATWTB = V_BOX_NO.
      APPEND V_TAB.
    ENDIF.
  ELSE.
*Roll no and barcode roll no.
    V_TAB-ATNAM = 'ZZROLLNO'.
    V_TAB-ATWTB = V_ROLLNO.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

*Add Interfilm Part Number
    V_TAB-ATNAM = 'ZZBASE'.
    V_TAB-ATWTB = V_PART.
    APPEND V_TAB.

  ENDIF.


*** get constant from SONUM text
  DATA: V_SONUM1 LIKE VBAP-VBELN,  "TYPE p LENGTH 10,
        V_SONUM2 LIKE VBAP-POSNR,  " TYPE p LENGTH 6,
        V_TDNAME LIKE THEAD-TDNAME.

  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE VBELN POSNR INTO (V_SONUM1, V_SONUM2)
  FROM MSKA
  WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

  CONCATENATE V_SONUM1 V_SONUM2 INTO V_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  IF SY-SUBRC = 0.

    LOOP AT IT_LINES.
      IF IT_LINES-TDLINE+0(2) = 'L1'.
        V_L1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'L2'.
        V_L2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'W1'.
        V_W1  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'W2'.
        V_W2  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'N1'.
        V_N1  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'N2'.
        V_N2  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'S1'.
        V_S1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'S2'.
        V_S2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'T1'.
        V_T1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'T2'.
        V_T2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'P1'.
        V_P1 = IT_LINES-TDLINE+3(10).
      ELSEIF IT_LINES-TDLINE+0(2) = 'J1'.
        V_J1 = IT_LINES-TDLINE+3(10).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F1'.
        V_F1 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F2'.
        V_F2 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F3'.
        V_F3 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F4'.
        V_F4 = IT_LINES-TDLINE+3(24).
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

* Do the conversion...
  CLEAR : V_S_INCH,
          V_S_GAUGE,
          V_S_FEET,
          V_S_LBS,
          V_S_SPLICE1,
          V_S_SPLICE2.

* Loop zlabel for conversion (Inch, Feet, Lbs, Gauge)
* And update the data which is not the conversion's value...
* Conversion value will be transfer to text file after this looping condition...
  SORT V_ZLABEL BY ATNAM.
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.
    CLEAR V_TAB-ATWTB.

    READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
    IF SY-SUBRC = 0.
* split/erase "kg" from net weight.
      IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        IF ( V_LABELORIG EQ 'L001' OR V_LABELORIG EQ 'L002' OR V_LABELORIG EQ 'L003'
         OR V_LABELORIG EQ 'L004' OR V_LABELORIG EQ 'L005' OR V_LABELORIG EQ 'G001' OR V_LABELORIG EQ 'L011' OR V_LABELORIG EQ 'L012' )
         AND SY-TCODE = 'VL74'.
          REPLACE ALL OCCURRENCES OF ',' IN V_N1 WITH ''.
          V_TAB-ATWTB = V_N1 * V_TOT_ROLL.
        ELSE.
          SPLIT V_TAB-ATWTB AT V_DEL INTO V_TAB-ATWTB V_1.
        ENDIF.
      ENDIF.

* Set conversion & Right Justified...
* Get the Thickness value(Mic -> Gauge)
      IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.

        IF V_FLAG_ZZALIAS <> 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_THICK.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ENDIF.

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010'  OR V_LABELORIG EQ 'D013'
            OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
            OR  V_LABELORIG EQ 'B013' OR V_LABELORIG EQ 'B014' OR  V_LABELORIG EQ 'B015' OR V_LABELORIG EQ 'B016'
            OR V_LABELORIG EQ 'A010' OR V_LABELORIG EQ 'A011' OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013').
*Interfillm
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

          V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
          WRITE V_GAUGE TO V_S_GAUGE.

          PERFORM RIGHT_JUSTIFIED USING V_LEN_MIC
                                        V_TAB-ATWTB.

          CONDENSE V_S_GAUGE NO-GAPS.

          V_THICKNESS = V_TAB-ATWTB.
        ELSE.


          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

          V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
          WRITE V_GAUGE TO V_S_GAUGE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_MIC
                                        V_TAB-ATWTB.
          V_THICKNESS = V_TAB-ATWTB.

*--------Add by Afir
          CONDENSE V_THICKNESS NO-GAPS.
          CONDENSE V_S_GAUGE NO-GAPS.

          IF V_LABELORIG = 'A147' OR V_LABELORIG = 'A148' OR V_LABELORIG = 'A172'.
            CONCATENATE V_THICKNESS ' mic.' INTO V_INFO_THICKNESS.
          ELSE.
            CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.
          ENDIF.

          V_TAB-ATWTB = ''.
          V_S_GAUGE = ''.
*--------End by Afir
        ENDIF.


      ENDIF.

* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH.
        ENDIF.

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'B013' OR V_LABELORIG EQ 'B014' OR  V_LABELORIG EQ 'B015' OR V_LABELORIG EQ 'B016'
          OR V_LABELORIG EQ 'A010' OR V_LABELORIG EQ 'A011' OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013'
            ).
*Interfillm
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_INCH =   V_TAB-ATWTB * V_C_INCH_INTER.

          WRITE V_INCH TO V_S_INCH.

          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_S_INCH.
          CONDENSE V_S_INCH NO-GAPS.



          V_WIDTH = V_TAB-ATWTB.
          WRITE V_WIDTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.


          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_INCH =   V_TAB-ATWTB * V_C_INCH.
          WRITE V_INCH TO V_S_INCH.
          V_WIDTH = V_TAB-ATWTB.
          WRITE V_WIDTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'B013' OR V_LABELORIG EQ 'B014' OR  V_LABELORIG EQ 'B015' OR V_LABELORIG EQ 'B016'
          OR V_LABELORIG EQ 'A010' OR V_LABELORIG EQ 'A011' OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013'
            ).
*Interfillm
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_FEET_INTER  = V_TAB-ATWTB * V_C_FEET_INTER_BOPET.
          WRITE V_FEET_INTER TO V_S_FEET.


          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_S_FEET.
          CONDENSE V_S_FEET NO-GAPS.


          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_FEET   = V_TAB-ATWTB * V_C_FEET.
          WRITE V_FEET TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

* Get The Length Value(MM -> Inch) For SheetLine
* Replace Feet to Inch in format

      IF V_ZLABEL-ATNAM = 'ZZLENGTHSHT'.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_INCH.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.


* Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'B013' OR V_LABELORIG EQ 'B014' OR  V_LABELORIG EQ 'B015' OR V_LABELORIG EQ 'B016'
          OR V_LABELORIG EQ 'A010' OR V_LABELORIG EQ 'A011' OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013'
            ).

*Interfillm
          READ TABLE V_TAB WITH KEY ATNAM = 'ZZTOTRL'.
          IF SY-SUBRC = 0.
            REPLACE ALL OCCURRENCES OF ',' IN V_N1 WITH ''.
            V_TAB-ATWTB = V_N1 * V_TAB-ATWTB.
            PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT V_TAB-ATWTB.
            V_ZLABEL-DATA2 = V_TAB-ATWTB.
          ENDIF.

        ELSE.

*        PERFORM conv_to_char USING v_tab-atwtb.
          PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
          V_LBS = V_TAB-ATWTB * V_C_LBS.
          WRITE V_LBS TO V_S_LBS.
          V_WEIGHT = V_TAB-ATWTB.
          WRITE V_WEIGHT TO V_TAB-ATWTB.
*mode 3 decimal
          PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.


*Get The Splices At 1st Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-1'.
        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013' ).
*Interfillm

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE1_INTER = V_TAB-ATWTB * V_C_FEET_INTER_BOPET.
          WRITE V_SPLICE1_INTER TO V_S_SPLICE1.
          V_SPLICE1_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE1 = V_TAB-ATWTB * V_C_FEET.
          WRITE V_SPLICE1 TO V_S_SPLICE1.
          V_SPLICE1_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

*Get The Splices At 2nd Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013' ).
*Interfillm

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE2_INTER = V_TAB-ATWTB * V_C_FEET_INTER_BOPET.
          WRITE V_SPLICE2_INTER TO V_S_SPLICE2.
          V_SPLICE2_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE2 = V_TAB-ATWTB * V_C_FEET.
          WRITE V_SPLICE2 TO V_S_SPLICE2.
          V_SPLICE2_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.

      ENDIF.

*Core
      IF V_ZLABEL-ATNAM = 'ZZCORE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013')
 AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE
'ZHU005' ).
*Interfilm
          CONCATENATE V_TAB-ATWRT '"' INTO V_TAB-ATWRT.
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB. "PERFORM right_justified USING 1 v_tab-atwrt.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_CORE
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Inside & Outside
      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELTYPE EQ 'D013'
          OR V_LABELTYPE EQ 'D014' OR V_LABELTYPE EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013')
AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE
'ZHU005' ).
*Interfilm
          IF V_TAB-ATWTB = 'NONE'.
            V_TAB-ATWTB = ''.
          ENDIF.
        ELSE.
          PERFORM RIGHT_JUSTIFIED_NO_GAP USING V_LEN_IN_OUT
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
        IF V_FLAG_ZZALIAS <> 'X'.

          CONCATENATE V_TAB-ATWRT  V_THICKNESS INTO V_TAB-ATWTB SEPARATED BY '-' .
          CONDENSE V_TAB-ATWTB NO-GAPS.
        ELSE.
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB.
        ENDIF.


      ENDIF.

*Clean Grade Value
      IF V_ZLABEL-ATNAM = 'ZZGRADE'.
        V_TAB-ATWTB = ''.
      ENDIF.

* Criteria Grade for all label except toyobo
      IF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        IF V_TAB-ATWRT = '2'.
          V_CRITERIA = '.'.
        ELSE.
          V_CRITERIA = ' '.
        ENDIF.
      ENDIF.

*//
      V_ZLABEL-DATA2 = V_TAB-ATWTB.
    ELSE.                              "atnam tidak ada dala v_tab

*--- Get The NetWeight Value(LBS)
      IF V_ZLABEL-ATNAM = 'ZZLBS'.
        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          OR V_LABELORIG EQ 'B013' OR V_LABELORIG EQ 'B014' OR  V_LABELORIG EQ 'B015' OR V_LABELORIG EQ 'B016'
          OR V_LABELORIG EQ 'A010' OR V_LABELORIG EQ 'A011' OR V_LABELORIG EQ 'A012' OR V_LABELORIG EQ 'A013').

          READ TABLE V_TAB WITH KEY ATNAM = 'ZZTOTRL'.
          IF SY-SUBRC = 0.
            REPLACE ALL OCCURRENCES OF ',' IN V_N2 WITH ''.
            V_N2 = V_N2 * V_TAB-ATWTB.
            PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT V_N2.
            V_ZLABEL-DATA2 = V_N2.
          ENDIF.
        ELSE.           "Selain ZCONSTANT
        ENDIF.

      ELSE.                        "selain ZZLBS
        V_ZLABEL-DATA2 = ' '.
      ENDIF.

    ENDIF.
    MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = V_ZLABEL-ATNAM.
  ENDLOOP.

*Mod Interfilm
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.

*Mod Thickness
    IF V_ZLABEL-ATNAM = 'ZZGAUGE'.
*      CONCATENATE i_gauge ' gauge ' '( ' i_micron ' micron )' INTO i_gauge.
      CONCATENATE V_T2 ' gauge ' '( ' I_MICRON ' micron )' INTO I_GAUGE.
      V_ZLABEL-DATA2 = I_GAUGE.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Width
    IF V_ZLABEL-ATNAM = 'ZZINCHX'.
*      CONCATENATE i_inch '"' '( ' i_mili ' mm )' INTO i_inch.
      CONCATENATE V_W2 '"' '( ' I_MILI ' mm )' INTO I_INCH.
      V_ZLABEL-DATA2 = I_INCH.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Length
    IF V_ZLABEL-ATNAM = 'ZZFEETX'.
*      CONCATENATE i_feet ' feet ' '( ' i_meters ' meters )' INTO i_feet.
      CONCATENATE V_L2 ' feet ' '( ' I_METERS ' meters )' INTO I_FEET.
      V_ZLABEL-DATA2 = I_FEET.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Weight
    IF V_ZLABEL-ATNAM = 'ZZLBS'.
      CONCATENATE V_ZLABEL-DATA2 ' lbs ' '( ' I_KGS ' kgs )' INTO I_LBS.
      V_ZLABEL-DATA2 = I_LBS.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
      IF V_W1 NE ''.
        V_ZLABEL-DATA2 = V_W1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZLENGTH'.
      IF V_W1 NE ''.
        V_ZLABEL-DATA2 = V_L1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
      IF V_W1 NE ''.
        V_ZLABEL-DATA2 = V_T1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZMT2'.
      IF V_S1 NE ''.
        V_ZLABEL-DATA2 = V_S1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZFT2'.
      IF V_S2 NE ''.
        V_ZLABEL-DATA2 = V_S2.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZBASE'.
      IF V_P1 NE ''.
        V_ZLABEL-DATA2 = V_P1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZCOAT'.
      IF V_J1 NE ''.
        V_ZLABEL-DATA2 = V_J1.
        MODIFY V_ZLABEL INDEX V_TABIX.
      ENDIF.
    ENDIF.

  ENDLOOP.

*/---Added on 150405---
*cek previouly label

  IF V_LABELIMGOLD <> V_LABELIMGNEW.

*clear image and format to text-data---------------------
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      APPEND TEXT_DATA.
    ENDLOOP.


    SELECT IMAG1
      INTO CORRESPONDING FIELDS OF TABLE V_ZLABELMAPIMAGE
      FROM ZLABELMAPIMAGE
      WHERE KODE = V_LABELIMGNEW ORDER BY IMAG1.


    LOOP AT V_ZLABELMAPIMAGE.
*load image to text-data---------------------
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.

        APPEND TEXT_DATA.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

*---------------------/




******
  DO V_COPIES TIMES.
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      IF SY-TABIX = 2.
        SHIFT TEXT_DATA-STR_TEXT+7  RIGHT BY 2 PLACES .
        ADD 1 TO POSI.
        TEXT_DATA-STR_TEXT+6(3) = POSI.
      ENDIF.

      " Start add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)
      " 1. Eksekusi Subroutine (Hanya membuat baris baru)
      IF GV_IS_RTP = 'X'.
        LV_SHIFT_UP = 15. " P_SHIFT_UP (Naikkan Pallet No 20 dots)
        LV_GAP_DOWN = 30. " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
        PERFORM ADJUST_AND_INJECT_TEXT USING    'Pallet No.:'           " P_ANCHOR (Teks yg dicari)
                                                'Returnable Packaging'  " P_INJECT (Teks yg diinjeksi)
                                                'H199,TXT199'           " P_NEW_ID (ID unik TXT baru)
                                                LV_SHIFT_UP             " P_SHIFT_UP (Naikkan Pallet No 20 dots)
                                                LV_GAP_DOWN             " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
                                       CHANGING TEXT_DATA-STR_TEXT
                                                LV_INJECT_STR.
      ENDIF.

      " 2. APPEND BARIS ORIGINAL (Teks Pallet No.: yg sudah naik)
      APPEND TEXT_DATA.

      " 3. APPEND BARIS BARU (Teks RTP) KE TEXT_DATA
      IF LV_INJECT_STR IS NOT INITIAL.
        TEXT_DATA-STR_TEXT = LV_INJECT_STR.
        APPEND TEXT_DATA.     " Tambahkan Baris text RTP ke TEXT_DATA
        CLEAR LV_INJECT_STR.  " Bersihkan agar tidak ikut ke-append di loop berikutnya
      ENDIF.
      " End add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)

    ENDLOOP.

******

*Condition for start and end syntax label command.
    TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.
    APPEND TEXT_DATA.

*Combine all command into internal table.
    DATA: V_TEMP TYPE P DECIMALS 2, V_TEMPT(12).
    LOOP AT V_ZLABEL.
      CLEAR: V_TEMP, V_TEMPT.

      IF V_ZLABEL-ATNAM = 'ZZFEETX'.
*Interfilm
        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELTYPE EQ 'D013'
          OR V_LABELTYPE EQ 'D014' OR V_LABELTYPE EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013' ).

          CONCATENATE V_S_FEET ' feet ' '( ' I_METERS ' meters )' INTO V_S_FEET_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_L2 '<ETX>' INTO TEXT_DATA-STR_TEXT.


        ENDIF.


      ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
*Interfilm
        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELTYPE EQ 'D013'
          OR V_LABELTYPE EQ 'D014' OR V_LABELTYPE EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013').

          CONCATENATE V_S_INCH '" ' '( ' I_MILI ' mm )' INTO V_S_INCH_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_W2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.


      ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*Interfilm
        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELTYPE EQ 'D013'
          OR V_LABELTYPE EQ 'D014' OR V_LABELTYPE EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013').
          CONCATENATE V_S_LBS ' lbs ' '( ' I_KGS ' kgs )' INTO V_S_LBS_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSE.
          IF ( V_LABELORIG EQ 'L001' OR V_LABELORIG EQ 'L002' OR V_LABELORIG EQ 'L003'
           OR V_LABELORIG EQ 'L004' OR V_LABELORIG EQ 'L005' OR V_LABELORIG EQ 'G001' OR V_LABELORIG EQ 'L011' OR V_LABELORIG EQ 'L012')
           AND SY-TCODE = 'VL74'.
            REPLACE ALL OCCURRENCES OF ',' IN V_N2 WITH ''.
            V_TEMP = V_N2 * V_TOT_ROLL.
            WRITE V_TEMP TO V_TEMPT.

            CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TEMPT '<ETX>' INTO TEXT_DATA-STR_TEXT.
          ELSE.
            CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_N2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
          ENDIF.
        ENDIF.


      ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
*Interfilm
        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELTYPE EQ 'D013'
          OR V_LABELTYPE EQ 'D014' OR V_LABELTYPE EQ 'D015'
          OR V_LABELTYPE EQ 'B013' OR V_LABELTYPE EQ 'B014' OR  V_LABELTYPE EQ 'B015' OR V_LABELTYPE EQ 'B016'
          OR V_LABELTYPE EQ 'A010' OR V_LABELTYPE EQ 'A011' OR V_LABELTYPE EQ 'A012' OR V_LABELTYPE EQ 'A013').

          CONCATENATE V_S_GAUGE ' gauge ' '( ' I_MICRON ' micron )' INTO V_S_GAUGE_INTER.

          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_GAUGE_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_T2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS1'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL V_S_SPLICE1.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS2'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL V_S_SPLICE2.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_CRITERIA '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZSOITEM'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_SOITEM V_SONUM_ITEM.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_SONUM_ITEM '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL V_S_SUM_QTYSHEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SUM_QTYSHEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
*-------
      ELSEIF V_ZLABEL-ATNAM = 'ZZFT2'.
        IF ( V_LABELORIG EQ 'L001' OR V_LABELORIG EQ 'L002' OR V_LABELORIG EQ 'L003'
         OR V_LABELORIG EQ 'L004' OR V_LABELORIG EQ 'L005' OR V_LABELORIG EQ 'G001' OR V_LABELORIG EQ 'L011' OR V_LABELORIG EQ 'L012')
         AND SY-TCODE = 'VL74'.
          V_TEMPT = V_S2.
          REPLACE ',' IN V_TEMPT WITH ''.
          V_TEMP = V_TEMPT * V_TOT_ROLL.
          WRITE V_TEMP TO V_TEMPT DECIMALS 0.
          CONDENSE V_TEMPT.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TEMPT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
      ELSEIF V_ZLABEL-ATNAM = 'ZZMT2'.
        IF ( V_LABELORIG EQ 'L001' OR V_LABELORIG EQ 'L002' OR V_LABELORIG EQ 'L003'
         OR V_LABELORIG EQ 'L004' OR V_LABELORIG EQ 'L005' OR V_LABELORIG EQ 'G001' OR V_LABELORIG EQ 'L011' OR V_LABELORIG EQ 'L012')
         AND SY-TCODE = 'VL74'.
          CLEAR V_TEMP.
          V_TEMPT = V_S1.
          REPLACE ',' IN V_TEMPT WITH ''.
          V_TEMP = V_TEMPT * V_TOT_ROLL.
          WRITE V_TEMP TO V_TEMPT DECIMALS 0.
          CONDENSE V_TEMPT.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TEMPT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
*------
      ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT1'.
        IF V_LABELORIG EQ 'L012' AND SY-TCODE = 'VL74'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_INFO_THICKNESS '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
*------
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

* Number of copies...
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

  ENDDO.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.
ENDFORM.                    " inter_text_data





*&---------------------------------------------------------------------*
*&      Form  text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TEXT_DATA.

* Get SO NUmber and Item from last Batch
  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM.

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = V_MATNR AND
  WERKS = V_WERKS AND
  CHARG = V_CHARG AND
  ( KALAB > 0 OR
  KAINS > 0 OR
  KASPE > 0 ).


  IF SY-SUBRC = 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_VBELN
      IMPORTING
        OUTPUT = V_VBELN.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_POSNR
      IMPORTING
        OUTPUT = V_POSNR.


    CONCATENATE V_VBELN V_POSNR INTO V_SONUM_ITEM SEPARATED BY '/'.

  ENDIF.



*Get Net weight...
  PERFORM GET_NET_WEIGHT.
  CLEAR :
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_GRADE,
          V_DERIVATIVEMS,
          V_DERIVATIVESS,
          V_POSITIONMS,
          V_POSITIONSS,
          V_ZZPACKING,
          V_LABELTYPE.
  SORT V_TAB BY ATNAM.


* Reset v_flag_zzalias to ''
  V_FLAG_ZZALIAS = ''.

* reset wa alias
  WA_LENGT = SPACE.
  WA_WIDTH = SPACE.
  WA_THICK = SPACE.
  WA_DENSI = SPACE.
  V_FLAG_WEIGHT_ZZALIAS = ''.


  LOOP AT V_TAB.

    IF V_TAB-ATNAM = 'ZZALIAS'.

      V_TYPE = V_TAB-ATWRT.
      V_FLAG_ZZALIAS = 'X'.

      PERFORM MOD_WEIGHT_ALIAS USING V_MATNR V_CHARG V_WERKS V_TYPE.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        V_TAB-ATWRT = V_TYPE.
        V_TAB-ATWTB = V_TYPE.
        MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
      ENDIF.
    ENDIF.

    IF V_FLAG_ZZALIAS <> 'X'.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        V_TYPE = V_TAB-ATWRT.
      ENDIF.
    ENDIF.

* Get the roll No...
    IF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PRODLINE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
      V_GRADE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
      V_DERIVATIVEMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
      V_POSITIONMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
      V_DERIVATIVESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
      V_POSITIONSS = V_TAB-ATWRT.
*}

*get label type value
    ELSEIF V_TAB-ATNAM = 'ZZLABEL'.
      V_LABELTYPE = V_TAB-ATWRT.
      V_LABELIMGNEW = V_TAB-ATWRT.
      V_LABELORIG = V_TAB-ATWRT.
    ENDIF.

* For print Slit Roll, ignore zzpacking...
    IF V_TAB-ATNAM = 'ZZPACKING'.
      IF SY-CPROG = 'ZPPPPRINTLABEL' OR SY-TCODE = 'MB90'.
        V_ZZPACKING = ' '.
        CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
      ELSEIF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
        IF V_MAGRV = 'BOX'.
          V_ZZPACKING = V_TAB-ATWRT.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ELSE.
          V_ZZPACKING = 'PL'.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Weight is getting from formula...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC <> 0.
    V_TAB-ATNAM = 'ZZWEIGHT'.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.
    V_TAB-ATNAM = 'ZZLENGTH'.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.
*----------------------/

*Get Roll No...
* Modified (PRA) 14/03/05
  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.

* Only for t-code vl74...
  IF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
* Barcode Box No(from exidv plant and erdat)...
    CLEAR V_PLANT_CODE.
    IF V_WERKS = '1000'.
      V_PLANT_CODE = 'WR'.
    ELSEIF V_WERKS = '2000'.
      V_PLANT_CODE = 'KR'.
    ELSEIF V_WERKS = '3000'.
      V_PLANT_CODE = 'JR'.
    ENDIF.

    CONCATENATE V_ERDAT_MM V_ERDAT_YY INTO V_ERDAT.

    CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.

*Barcode box no.
    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_EXIDV.
    APPEND V_TAB.
*Total roll
    V_TAB-ATNAM = 'ZZTOTRL'.
    V_TAB-ATWTB = V_TOT_ROLL.
    APPEND V_TAB.

*Total box.
    V_TAB-ATNAM = 'ZZTOTBX'.
    V_TAB-ATWTB = V_TOT_BOX.
    APPEND V_TAB.

* Pallet or Box no...
    IF V_MAGRV = 'BOX'.
      V_TAB-ATNAM = 'ZZBOX'.
      V_TAB-ATWTB = V_BOX_NO.

      APPEND V_TAB.
    ELSEIF V_MAGRV = 'PLT'.
      V_TAB-ATNAM = 'ZZPALET'.
      V_TAB-ATWTB = V_BOX_NO.
      APPEND V_TAB.
    ENDIF.
  ELSE.
*Roll no and barcode roll no.
    V_TAB-ATNAM = 'ZZROLLNO'.
    V_TAB-ATWTB = V_ROLLNO.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBCROLL'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

  ENDIF.


*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

* Do the conversion...
  CLEAR : V_S_INCH,
          V_S_GAUGE,
          V_S_FEET,
          V_S_LBS,
          V_S_SPLICE1,
          V_S_SPLICE2.

  SORT V_ZLABEL BY ATNAM.
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.
    CLEAR V_TAB-ATWTB.

    READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
    IF SY-SUBRC = 0.
* split/erase "kg" from net weight.
      IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        SPLIT V_TAB-ATWTB AT V_DEL INTO V_TAB-ATWTB V_1.
      ENDIF.

* Set conversion & Right Justified...
* Get the Thickness value(Mic -> Gauge)
      IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.

        IF V_FLAG_ZZALIAS <> 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_THICK.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ENDIF.


        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

        V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
        WRITE V_GAUGE TO V_S_GAUGE.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_MIC
                                      V_TAB-ATWTB.
        V_THICKNESS = V_TAB-ATWTB.

      ENDIF.

* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH .
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_INCH =   V_TAB-ATWTB * V_C_INCH.
        WRITE V_INCH TO V_S_INCH.
        V_WIDTH = V_TAB-ATWTB.
        WRITE V_WIDTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.

* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
        OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
        ).
*Interfillm
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_FEET_INTER  = V_TAB-ATWTB * V_C_FEET_INTER.
          WRITE V_FEET_INTER TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_FEET   = V_TAB-ATWTB * V_C_FEET.
          WRITE V_FEET TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

* Get The Length Value(MM -> Inch) For SheetLine
* Replace Feet to Inch in format

      IF V_ZLABEL-ATNAM = 'ZZLENGTHSHT'.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_INCH.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.


* Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.

*        PERFORM conv_to_char USING v_tab-atwtb.
        PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
        V_LBS = V_TAB-ATWTB * V_C_LBS.
        WRITE V_LBS TO V_S_LBS.
        V_WEIGHT = V_TAB-ATWTB.
        WRITE V_WEIGHT TO V_TAB-ATWTB.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Get The Splices At 1st Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-1'.
        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
        OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
        ).
*Interfillm

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE1_INTER = V_TAB-ATWTB * V_C_FEET_INTER.
          WRITE V_SPLICE1_INTER TO V_S_SPLICE1.
          V_SPLICE1_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE1 = V_TAB-ATWTB * V_C_FEET.
          WRITE V_SPLICE1 TO V_S_SPLICE1.
          V_SPLICE1_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

*Get The Splices At 2nd Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
).
*Interfillm

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE2_INTER = V_TAB-ATWTB * V_C_FEET_INTER.
          WRITE V_SPLICE2_INTER TO V_S_SPLICE2.
          V_SPLICE2_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
          V_SPLICE2 = V_TAB-ATWTB * V_C_FEET.
          WRITE V_SPLICE2 TO V_S_SPLICE2.
          V_SPLICE2_MIRING = V_TAB-ATWTB.
          WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

*Core
      IF V_ZLABEL-ATNAM = 'ZZCORE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
          )
        AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Interfilm
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB. "PERFORM right_justified USING 1 v_tab-atwrt.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_CORE
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Inside & Outside
      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELORIG EQ 'D013'
          OR V_LABELORIG EQ 'D014' OR V_LABELORIG EQ 'D015'
        )
        AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Interfilm
        ELSE.
          PERFORM RIGHT_JUSTIFIED_NO_GAP USING V_LEN_IN_OUT
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
        IF V_FLAG_ZZALIAS <> 'X'.

          CONCATENATE V_TAB-ATWRT  V_THICKNESS INTO V_TAB-ATWTB SEPARATED BY '-' .
          CONDENSE V_TAB-ATWTB NO-GAPS.
        ELSE.
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB.
        ENDIF.


      ENDIF.

*Clean Grade Value
      IF V_ZLABEL-ATNAM = 'ZZGRADE'.
        V_TAB-ATWTB = ''.
      ENDIF.

* Criteria Grade for all label except toyobo
      IF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        IF V_TAB-ATWRT = '2'.
          V_CRITERIA = '.'.
        ELSE.
          V_CRITERIA = ' '.
        ENDIF.
      ENDIF.

*//
      V_ZLABEL-DATA2 = V_TAB-ATWTB.
    ELSE.
      V_ZLABEL-DATA2 = ' '.
    ENDIF.

    MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
  ENDLOOP.

*/---Added on 150405---
*cek previouly label

  IF V_LABELIMGOLD <> V_LABELIMGNEW.

*clear image and format to text-data---------------------
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.

      APPEND TEXT_DATA.
    ENDLOOP.


    SELECT IMAG1
      INTO CORRESPONDING FIELDS OF TABLE V_ZLABELMAPIMAGE
      FROM ZLABELMAPIMAGE
      WHERE KODE = V_LABELIMGNEW ORDER BY IMAG1.


    LOOP AT V_ZLABELMAPIMAGE.
*load image to text-data---------------------
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.

        APPEND TEXT_DATA.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

*---------------------/




******
  DO V_COPIES TIMES.
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      IF SY-TABIX = 2.
        SHIFT TEXT_DATA-STR_TEXT+7  RIGHT BY 2 PLACES .
        ADD 1 TO POSI.
        TEXT_DATA-STR_TEXT+6(3) = POSI.
      ENDIF.

      " Start add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)
      " 1. Eksekusi Subroutine (Hanya membuat baris baru)
      IF GV_IS_RTP = 'X'.
        LV_SHIFT_UP = 15. " P_SHIFT_UP (Naikkan Pallet No 20 dots)
        LV_GAP_DOWN = 30. " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
        PERFORM ADJUST_AND_INJECT_TEXT USING    'Pallet No.:'           " P_ANCHOR (Teks yg dicari)
                                                'Returnable Packaging'  " P_INJECT (Teks yg diinjeksi)
                                                'H199,TXT199'           " P_NEW_ID (ID unik TXT baru)
                                                LV_SHIFT_UP             " P_SHIFT_UP (Naikkan Pallet No 20 dots)
                                                LV_GAP_DOWN             " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
                                       CHANGING TEXT_DATA-STR_TEXT
                                                LV_INJECT_STR.
      ENDIF.

      " 2. APPEND BARIS ORIGINAL (Teks Pallet No.: yg sudah naik)
      APPEND TEXT_DATA.

      " 3. APPEND BARIS BARU (Teks RTP) KE TEXT_DATA
      IF LV_INJECT_STR IS NOT INITIAL.
        TEXT_DATA-STR_TEXT = LV_INJECT_STR.
        APPEND TEXT_DATA.     " Tambahkan Baris text RTP ke TEXT_DATA
        CLEAR LV_INJECT_STR.  " Bersihkan agar tidak ikut ke-append di loop berikutnya
      ENDIF.
      " End add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)

    ENDLOOP.

******

*Condition for start and end syntax label command.
    TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.
    APPEND TEXT_DATA.

*Combine all command into internal table.
    LOOP AT V_ZLABEL.
* Get the strlen variable and substract from v_strlen for purpose right justified.

      IF V_ZLABEL-ATNAM = 'ZZFEETX'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_FEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_INCH.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING V_LEN_WEIGHT "v_len_normal
                                      V_S_LBS.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_GAUGE
                                      V_S_GAUGE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_GAUGE '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS1'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_SPLICE1.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS2'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_SPLICE2.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_CRITERIA '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
       V_ZLABEL-ATNAM = 'ZZSOITEM'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_SOITEM
                                      V_SONUM_ITEM.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_SONUM_ITEM '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_SUM_QTYSHEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SUM_QTYSHEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

* Number of copies...
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

  ENDDO.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
*  CONCATENATE file_dir  v_labeltype '.BAT' INTO file_b.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*get image filename.
*  CONCATENATE file_dir v_labeltype '.IMG' INTO file_i.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.




ENDFORM.                    "text_data


*&---------------------------------------------------------------------*
*&      Form  GET_INCH_FR_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_S_INCH   text
*----------------------------------------------------------------------*
FORM GET_INCH_FR_SO USING V_S_INCH.
  DATA: V_SONUM1 LIKE VBAP-VBELN,  "TYPE p LENGTH 10,
         V_SONUM2 LIKE VBAP-POSNR,  " TYPE p LENGTH 6,
         V_TDNAME LIKE THEAD-TDNAME.

  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE VBELN POSNR INTO (V_SONUM1, V_SONUM2)
  FROM MSKA
  WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

  CONCATENATE V_SONUM1 V_SONUM2 INTO V_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  IF SY-SUBRC = 0.
    READ TABLE IT_LINES WITH KEY TDLINE+0(2) = 'W2'.
    IF SY-SUBRC = 0.
      V_S_INCH = IT_LINES-TDLINE+3(20).
    ENDIF.
  ENDIF.
ENDFORM.                    "get_inch_fr_so
*&---------------------------------------------------------------------*
*&      Form  GET_ACTWEIGHT
*&---------------------------------------------------------------------*
*       text

FORM GET_FEET_FR_SO USING V_S_FEET.
  DATA: V_SONUM1 LIKE VBAP-VBELN,  "TYPE p LENGTH 10,
         V_SONUM2 LIKE VBAP-POSNR,  " TYPE p LENGTH 6,
         V_TDNAME LIKE THEAD-TDNAME.

  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE VBELN POSNR INTO (V_SONUM1, V_SONUM2)
  FROM MSKA
  WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

  CONCATENATE V_SONUM1 V_SONUM2 INTO V_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  IF SY-SUBRC = 0.
    READ TABLE IT_LINES WITH KEY TDLINE+0(2) = 'L2'.
    IF SY-SUBRC = 0.
      V_S_FEET = IT_LINES-TDLINE+3(20).
    ENDIF.
  ENDIF.
ENDFORM.                    "GET_FEET_FR_SO
*----------------------------------------------------------------------*
*      -->P_V_SUM_NETWEIGHT  text
*
*----------------------------------------------------------------------*
FORM GET_ACTWEIGHT  USING    P_ACTWEIG.

  DATA: V_STOUCH3     TYPE STRING,
        V_ACTLENG(30) TYPE C,
        V_ACTWEIG(30) TYPE C,
        V_ACTCORE(30) TYPE C.

  DATA : V_TAB_ACT TYPE API_VALI OCCURS 0 WITH HEADER LINE.
  DATA : DMESSAGE(100).

  DATA : BEGIN OF IT_BATCH_ACTUAL OCCURS 0,
            BATCH_CHARG       TYPE CHARG_D,
            BATCH_ACTWEIG     TYPE P DECIMALS 2,
         END OF IT_BATCH_ACTUAL.

  CLEAR : P_ACTWEIG.

  LOOP AT LVBPLP.
    IF LVBPLP-UNVEL <> SPACE. "pallet/tumpukan
      LOOP AT LVBPLP WHERE VENUM = LVBPLP-UNVEL.
        IF LVBPLP-UNVEL <> SPACE. "tumpukan
          LOOP AT LVBPLP WHERE VENUM = LVBPLP-UNVEL.

            CLEAR V_TAB_ACT.
            REFRESH V_TAB_ACT.

            CALL FUNCTION 'QC01_BATCH_VALUES_READ'
              EXPORTING
                I_VAL_MATNR    = V_MATNR
                I_VAL_WERKS    = V_WERKS
                I_VAL_CHARGE   = LVBPLP-CHARG
                I_LANGUAGE     = SY-LANGU
                I_DATE         = SY-DATUM
              TABLES
                T_VAL_TAB      = V_TAB_ACT
              EXCEPTIONS
                NO_CLASS       = 01
                INTERNAL_ERROR = 02
                NO_VALUES      = 03
                NO_CHARS       = 04.

            IF SY-SUBRC = 0.
              CLEAR: V_ACTLENG, V_ACTWEIG, V_ACTCORE, V_STOUCH3.
              READ TABLE V_TAB_ACT WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
              IF SY-SUBRC = 0.
                V_STOUCH3 = V_TAB_ACT-ATWRT.
                SPLIT V_STOUCH3 AT '-' INTO V_ACTLENG V_ACTWEIG V_ACTCORE.

                "Get Act Weight
                REPLACE ALL OCCURRENCES OF ',' IN V_ACTWEIG WITH SPACE.
                CONDENSE V_ACTWEIG NO-GAPS.
                IT_BATCH_ACTUAL-BATCH_ACTWEIG = V_ACTWEIG.
              ELSE.
                CONCATENATE 'Batch' LVBPLP-CHARG 'belum memiliki data aktual..!!' INTO DMESSAGE SEPARATED BY SPACE.
                MESSAGE DMESSAGE TYPE 'I'.
                LEAVE LIST-PROCESSING.
              ENDIF.
            ENDIF.

            IT_BATCH_ACTUAL-BATCH_CHARG = LVBPLP-CHARG.
            APPEND IT_BATCH_ACTUAL.
          ENDLOOP.
        ELSE.
          CLEAR V_TAB_ACT.
          REFRESH V_TAB_ACT.

          CALL FUNCTION 'QC01_BATCH_VALUES_READ'
            EXPORTING
              I_VAL_MATNR    = V_MATNR
              I_VAL_WERKS    = V_WERKS
              I_VAL_CHARGE   = LVBPLP-CHARG
              I_LANGUAGE     = SY-LANGU
              I_DATE         = SY-DATUM
            TABLES
              T_VAL_TAB      = V_TAB_ACT
            EXCEPTIONS
              NO_CLASS       = 01
              INTERNAL_ERROR = 02
              NO_VALUES      = 03
              NO_CHARS       = 04.

          IF SY-SUBRC = 0.
            CLEAR: V_ACTLENG, V_ACTWEIG, V_ACTCORE, V_STOUCH3.
            READ TABLE V_TAB_ACT WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
            IF SY-SUBRC = 0.
              V_STOUCH3 = V_TAB_ACT-ATWRT.
              SPLIT V_STOUCH3 AT '-' INTO V_ACTLENG V_ACTWEIG V_ACTCORE.

              "Get Act Weight
              REPLACE ALL OCCURRENCES OF ',' IN V_ACTWEIG WITH SPACE.
              CONDENSE V_ACTWEIG NO-GAPS.
              IT_BATCH_ACTUAL-BATCH_ACTWEIG = V_ACTWEIG.
            ELSE.
              CONCATENATE 'Batch' LVBPLP-CHARG 'belum memiliki data aktual..!!' INTO DMESSAGE SEPARATED BY SPACE.
              MESSAGE DMESSAGE TYPE 'I'.
              LEAVE LIST-PROCESSING.
            ENDIF.
          ENDIF.

          IT_BATCH_ACTUAL-BATCH_CHARG = LVBPLP-CHARG.
          APPEND IT_BATCH_ACTUAL.
        ENDIF.
      ENDLOOP.
    ELSE.
      CLEAR V_TAB_ACT.
      REFRESH V_TAB_ACT.

      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = V_MATNR
          I_VAL_WERKS    = V_WERKS
          I_VAL_CHARGE   = LVBPLP-CHARG
          I_LANGUAGE     = SY-LANGU
          I_DATE         = SY-DATUM
        TABLES
          T_VAL_TAB      = V_TAB_ACT
        EXCEPTIONS
          NO_CLASS       = 01
          INTERNAL_ERROR = 02
          NO_VALUES      = 03
          NO_CHARS       = 04.

      IF SY-SUBRC = 0.
        CLEAR: V_ACTLENG, V_ACTWEIG, V_ACTCORE, V_STOUCH3.
        READ TABLE V_TAB_ACT WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
        IF SY-SUBRC = 0.
          V_STOUCH3 = V_TAB_ACT-ATWRT.
          SPLIT V_STOUCH3 AT '-' INTO V_ACTLENG V_ACTWEIG V_ACTCORE.

          "Get Act Weight
          REPLACE ALL OCCURRENCES OF ',' IN V_ACTWEIG WITH SPACE.
          CONDENSE V_ACTWEIG NO-GAPS.
          IT_BATCH_ACTUAL-BATCH_ACTWEIG = V_ACTWEIG.
        ELSE.
          CONCATENATE 'Batch' LVBPLP-CHARG 'belum memiliki data aktual..!!' INTO DMESSAGE SEPARATED BY SPACE.
          MESSAGE DMESSAGE TYPE 'I'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDIF.

      IT_BATCH_ACTUAL-BATCH_CHARG = LVBPLP-CHARG.
      APPEND IT_BATCH_ACTUAL.
    ENDIF.
  ENDLOOP.

  "Get SUM of Actual Weight
  LOOP AT IT_BATCH_ACTUAL.
    P_ACTWEIG = IT_BATCH_ACTUAL-BATCH_ACTWEIG + P_ACTWEIG.
  ENDLOOP.

ENDFORM.                    " GET_ACTWEIGHT
*&---------------------------------------------------------------------*
*&      Form  GET_ACTLENGTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_V_TAB_ATWTB  text
*----------------------------------------------------------------------*
FORM GET_ACTLENGTH  CHANGING P_ACTLENG.

  DATA: V_STOUCH3     TYPE STRING,
        V_ACTLENG(30) TYPE C,
        V_ACTWEIG(30) TYPE C,
        V_ACTCORE(30) TYPE C.

  CLEAR: V_ACTLENG, V_ACTWEIG, V_ACTCORE, V_STOUCH3.
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
  IF SY-SUBRC = 0.
    V_STOUCH3 = V_TAB-ATWRT.
    SPLIT V_STOUCH3 AT '-' INTO V_ACTLENG V_ACTWEIG V_ACTCORE.

    "Get Act Length
    P_ACTLENG = V_ACTLENG.

  ENDIF.

ENDFORM.                    " GET_ACTLENGTH

"Start Add by Fiqih 27.03.2026 (RTP)
*&---------------------------------------------------------------------*
*&      Form  ADJUST_AND_INJECT_TEXT
*&---------------------------------------------------------------------*
* Menggeser posisi Y ke atas dan menginjeksi baris teks baru
*----------------------------------------------------------------------*
FORM ADJUST_AND_INJECT_TEXT USING    P_ANCHOR      TYPE CLIKE  " Teks yg dicari (cth: 'Pallet No.:')
                                     P_INJECT      TYPE CLIKE  " Teks yg ditambahkan (cth: 'RTP')
                                     P_NEW_ID      TYPE CLIKE  " ID Baru (cth: 'H999,TXTRTP')
                                     P_SHIFT_UP    TYPE I      " Jarak geser ke atas (dots)
                                     P_GAP_DOWN    TYPE I      " Jarak teks baru ke bawah (dots)
                            CHANGING C_STR_TEXT    TYPE CLIKE  " Baris template yg sedang diproses
                                     C_INJECT_LINE TYPE CLIKE. " String penampung baris baru

  DATA: LV_O_POS       TYPE I,
        LV_S_POS       TYPE I,
        LV_LEN         TYPE I,
        LV_COORD       TYPE STRING,
        LV_NEW_COORD   TYPE STRING,
        LV_X           TYPE STRING,
        LV_Y           TYPE STRING,
        LV_Y_INT       TYPE I,
        LV_Y_ANCHOR    TYPE I,
        LV_Y_INJECT    TYPE I,
        LV_Y_ANCHOR_S  TYPE STRING,
        LV_Y_INJECT_S  TYPE STRING.

  CLEAR C_INJECT_LINE.

  " Jika baris ini mengandung teks jangkar kita
  IF C_STR_TEXT CS P_ANCHOR.

    " Cari posisi awal koordinat (ditandai dengan ';o')
    FIND ';o' IN C_STR_TEXT MATCH OFFSET LV_O_POS.
    IF SY-SUBRC = 0.
      LV_O_POS = LV_O_POS + 2.

      " Cari posisi akhir koordinat (ditandai dengan ';')
      FIND ';' IN SECTION OFFSET LV_O_POS OF C_STR_TEXT MATCH OFFSET LV_S_POS.
      IF SY-SUBRC = 0.
        LV_LEN = LV_S_POS - LV_O_POS.
        LV_COORD = C_STR_TEXT+LV_O_POS(LV_LEN). " Dapatkan string koordinat asli (cth: '956,671')

        " Pisahkan nilai X dan Y
        SPLIT LV_COORD AT ',' INTO LV_X LV_Y.

        " 1. Kalkulasi Y baru untuk Anchor (Naik = Dikurangi)
        LV_Y_INT = LV_Y.
        LV_Y_ANCHOR = LV_Y_INT - P_SHIFT_UP.
        LV_Y_ANCHOR_S = LV_Y_ANCHOR.
        CONDENSE LV_Y_ANCHOR_S NO-GAPS.

        " 2. Kalkulasi Y untuk Teks Baru (Turun dari Anchor yg baru = Ditambah)
        LV_Y_INJECT = LV_Y_ANCHOR + P_GAP_DOWN.
        LV_Y_INJECT_S = LV_Y_INJECT.
        CONDENSE LV_Y_INJECT_S NO-GAPS.

        " 3. Update koordinat di baris original (Anchor)
        CONCATENATE LV_X ',' LV_Y_ANCHOR_S INTO LV_NEW_COORD.
        REPLACE FIRST OCCURRENCE OF LV_COORD IN C_STR_TEXT WITH LV_NEW_COORD.

        " 4. Buat baris baru untuk teks yang diinjeksi
        " Catatan: Parameter font h3;w2 diset standar, bisa Anda ganti jika kebesaran/kekecilan
        CONCATENATE '<STX>' P_NEW_ID ';o' LV_X ',' LV_Y_INJECT_S ';f0;h1;w1;c2;b0;d3,' P_INJECT ';<ETX>'
               INTO C_INJECT_LINE.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
