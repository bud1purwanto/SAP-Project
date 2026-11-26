*&---------------------------------------------------------------------*
*&  Include      ZMMR_LABELROL_INCL                                    *
*----------------------------------------------------------------------*
INCLUDE ZLABEL_ZEBRA_INCL.
TABLES : ZLABEL ,
         ZLABELMAPIMAGE, ZALIAS, ZCONSTANT .
CONSTANTS : V_C_GAUGE VALUE 4,
            V_C_INCH  TYPE P DECIMALS 5 VALUE '0.03937',
            V_C_FEET  TYPE P DECIMALS 2 VALUE '3.28',
            V_C_FEET_INTER  TYPE P DECIMALS 5 VALUE '3.27976',
            V_C_LBS  TYPE P DECIMALS 4 VALUE '2.2046',
            V_C_INCH_INTER  TYPE P DECIMALS 5 VALUE '0.0395',
            V_C_FEET_INTER_BOPET  TYPE P DECIMALS 5 VALUE '3.28'.

*Interfilm
DATA : I_GAUGE(30) TYPE C,
       I_MICRON(30) TYPE C,
       I_MILI(30) TYPE C,
       I_METERS(30) TYPE C,
       I_LBS(30) TYPE C,
       I_KGS(30) TYPE C,
       I_INCH(30) TYPE C,
       I_FEET(30) TYPE C,
       I_WEIGHT(30) TYPE C.

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
       V_P1(10),   "part
       V_J1(10),   "job
       V_F1(24),
       V_F2(24),
       V_F3(24),
       V_F4(24).

DATA : POSI(3).

DATA : V_CHARG LIKE VBDPL-CHARG,
       V_CHARG_LONG LIKE AFPO-ABLAD,
       V_MATNR LIKE MARA-MATNR,
       V_WERKS LIKE VBDPL-WERKS,
       V_DOCNO LIKE MSEG-MBLNR,
       V_YEAR  LIKE MSEG-MJAHR,
       V_LGORT LIKE MSKA-LGORT,
       V_BARCODE LIKE AFPO-ABLAD,
       V_DOCNO2 LIKE ZCORER-DOCNO.

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
       V_SPLICE1_D LIKE API_VALI-ATWTB,
       V_SPLICE2_D LIKE API_VALI-ATWTB,
       V_ZCONV TYPE P DECIMALS 3,

*Criteria grade, 2 for second grade
       V_CRITERIA(1) VALUE ' ',
       V_ROLLNO(30).

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
       V_LABELMAP(10),
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
       V_LENGTH_SS(9) TYPE C,
       V_WIDTH  TYPE P DECIMALS 2,
       V_WIDTH_SS(9) TYPE C,
       V_SPLICE2_MIRING TYPE P DECIMALS 2,
       V_SPLICE1_MIRING TYPE P DECIMALS 2,
       V_TREAT_SS(24) TYPE C,
       V_CORE_SS(3) TYPE C,
       V_WEIGHT_SS(9) TYPE C.


DATA :
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
       V_SUM_NETWEIGHT TYPE P DECIMALS 2,
       V_SUM_NETWEIGHT_ZCONV TYPE P DECIMALS 2.
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

*for Expired Live
DATA : V_LIVE TYPE P,
       V_EXPDATE TYPE MKPF-BUDAT,
       V_POSTDATE TYPE MKPF-BUDAT.

*- part number
DATA: V_PARTNO LIKE VBAP-KDMAT.

*- RTP Core
DATA: FCN_ERRNO TYPE N.
DATA: VINFO(100).

"Add By Jarwo 22.07.2019
DATA: BEGIN OF IT_CORE OCCURS 0,
        COREID LIKE ZCORER-COREID,
        WERKS LIKE ZCORER-WERKS,
        TYPERTP TYPE C LENGTH 10,
        WIDTHRTP TYPE C LENGTH 3,
        BOX(1),
      END OF IT_CORE.

DATA: BEGIN OF IT_CORE_DISPLAY OCCURS 0,
        COREID LIKE ZCORER-COREID,
        WERKS LIKE ZCORER-WERKS,
      END OF IT_CORE_DISPLAY.

DATA: WA_CORE LIKE LINE OF IT_CORE,
      WA_CORE_DISPLAY LIKE LINE OF IT_CORE_DISPLAY.

DATA: V_IS_ZEBRA(1) TYPE C.
*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT .
*Check if file zebra.zpl is exists or not. If it exists, use zebra printer
*NB : zebra_zpl.txt is file that contain zpl command
   CLEAR V_RETURNCODE.
   PERFORM CHECK_USING_ZEBRA CHANGING V_IS_ZEBRA.
*   IF LV_ISZEBRA EQ 1. "Execute program if file zebra.zpl found.
   IF V_IS_ZEBRA EQ 'X'. "Execute program if file zebra.zpl found.
*  Change emulation in zebra printer
    PERFORM CHANGE_ZEBRA_EMULATION USING 'APL-I'.
    WAIT UP TO 10 SECONDS.
    IF SY-SUBRC EQ 0.
*  Print label to zebra
        PERFORM PRINT_ZEBRA CHANGING V_RETURNCODE.
     ENDIF.
   ELSE.
*   CONCATENATE pfn  v_labeltype  '.BAT' INTO file_batch.
    CALL FUNCTION 'GUI_RUN'
      EXPORTING
        COMMAND    = 'DATA.BAT'
        CD         = 'C:\tslabel\'
      IMPORTING
        RETURNCODE = V_RETURNCODE.
       WAIT UP TO 1 SECONDS.
   ENDIF.

  IF V_RETURNCODE <> 0.
    MESSAGE I000(0K) WITH 'Run Batch File Error'.
    STOP.

  ENDIF.

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
ENDFORM. "getfrsrv_f


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
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

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
*&      Form  get_net_weight
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NET_WEIGHT .
**Get Net weight...
**Cek whether v_sum_netweight_temp <> 0 -> fill from ZHU Box & Pallet
**-- Begin of MD01
*  DATA: BEGIN OF lt_mska OCCURS 0,
*        matnr LIKE mska-matnr,
*        werks LIKE mska-werks,
*        lgort LIKE mska-lgort,
*        charg LIKE mska-charg,
*        sobkz LIKE mska-sobkz,
*        vbeln LIKE mska-vbeln,
*        posnr LIKE mska-posnr,
*        kalab LIKE mska-kalab,
*        kains LIKE mska-kains,
*        kaspe LIKE mska-kaspe,
*        kalab1 TYPE zgsgew,
*        kains1 TYPE zgsgew,
*        kaspe1 TYPE zgsgew,
*        END OF lt_mska,
*        BEGIN OF lt_mchb OCCURS 0,
*        matnr LIKE mchb-matnr,
*        werks LIKE mchb-werks,
*        lgort LIKE mchb-lgort,
*        charg LIKE mchb-charg,
*        clabs LIKE mchb-clabs,
*        cinsm LIKE mchb-cinsm,
*        ceinm LIKE mchb-ceinm,
*        cspem LIKE mchb-cspem,
*        clabs1 TYPE zgsgew,
*        cinsm1 TYPE zgsgew,
*        ceinm1 TYPE zgsgew,
*        cspem1 TYPE zgsgew,
*        END OF lt_mchb.
**-- End of MD01
*
*  IF v_sum_netweight_temp EQ space.
*
*    CLEAR : v_kalab,
*            v_kains,
*            v_kaspe,
*            v_clabs,
*            v_cinsm,
*            v_ceinm,
*            v_cspem,
*            v_sum_netweight.
*
**-- Begin of MD01
*    SELECT matnr werks lgort charg sobkz vbeln posnr kalab kains kaspe
*    INTO TABLE lt_mska
*    FROM mska
*    WHERE matnr = v_matnr AND
*          werks = v_werks AND
*          charg = v_charg.
*    LOOP AT lt_mska.
*      lt_mska-kalab1 = lt_mska-kalab.
*      lt_mska-kains1 = lt_mska-kains.
*      lt_mska-kaspe1 = lt_mska-kaspe.
*      ADD: lt_mska-kalab1 TO v_kalab,
*           lt_mska-kains1 TO v_kains,
*           lt_mska-kaspe1 TO v_kaspe.
*    ENDLOOP.
*
*    SELECT matnr werks lgort charg clabs cinsm ceinm cspem
*    INTO TABLE lt_mchb
*    FROM mchb
*    WHERE matnr = v_matnr AND
*          werks = v_werks AND
*          charg = v_charg.
*    LOOP AT lt_mchb.
*      lt_mchb-clabs1 = lt_mchb-clabs.
*      lt_mchb-cinsm1 = lt_mchb-cinsm.
*      lt_mchb-ceinm1 = lt_mchb-ceinm.
*      lt_mchb-cspem1 = lt_mchb-cspem.
*      ADD: lt_mchb-clabs1 TO v_clabs,
*           lt_mchb-cinsm1 TO v_cinsm,
*           lt_mchb-ceinm1 TO v_ceinm,
*           lt_mchb-cspem1 TO v_cspem.
*    ENDLOOP.
*
**-- End of MD01
*    v_sum_netweight = v_kalab + v_kains + v_kaspe +
*                      v_clabs + v_cinsm + v_ceinm +
*                      v_cspem.
*
** mod for digitctl
*    IF v_zconv <> 0.
*      v_sum_netweight = v_zconv.
*    ENDIF.
*
*  ENDIF.
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
  IF SY-SUBRC = 0.
    V_SUM_NETWEIGHT = V_TAB-ATFLV.
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
*  shift v_value by v_strlen places right.

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
*&      Form  snw_roll_barcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SNW_ROLL_BARCODE .
  CONDENSE V_ROLLNO NO-GAPS.
  V_TAB-ATWTB = V_ROLLNO.

ENDFORM.                    " snw_roll_barcode



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

*    MESSAGE i000(0k) WITH 'Download data file error, error : ' v_info_error.
*    STOP.
  ENDIF.

ENDFORM.                    " download_data

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
  CONCATENATE PFN V_LABELTYPE '.IMG' INTO FILE_DOWNLOAD.
  SFN = FILE_I.
  REFRESH IT.
  PERFORM DSOPEN_INPUT_TEXT USING SFN.
  PERFORM XFER2IT.
  PERFORM DOWNLOAD_FRSRV.
ENDFORM. "getfrsrv_i
*&---------------------------------------------------------------------*
*&      Form  CEK_RTP_CORE
*&---------------------------------------------------------------------*
*       Added for RTP Core by Carfin 18.02.2019
*----------------------------------------------------------------------*
FORM CEK_RTP_CORE CHANGING FCN_ERRNO TYPE N.

  DATA: ZSVAL LIKE STANDARD TABLE OF SVAL WITH HEADER LINE,
        LT_ZCORER LIKE STANDARD TABLE OF ZCORER WITH HEADER LINE,
        LT_MSKA LIKE STANDARD TABLE OF MSKA WITH HEADER LINE,
        LT_MCHB LIKE STANDARD TABLE OF MCHB WITH HEADER LINE,
        LT_ZBATCHISTORY LIKE STANDARD TABLE OF ZBATCHISTORY WITH HEADER LINE,
        WA_ZCORER LIKE LINE OF LT_ZCORER,
        WA_ZCORER2 LIKE LINE OF LT_ZCORER,
        LV_CHARG_TEMP(15) TYPE C,
        LV_ANSWER TYPE C,
        LV_MSG(125),
        LV_STATUS(1),
        LV_POPUP(1),
        LV_COREID LIKE MCH1-CHARG,
        LV_VBELN LIKE MSKA-VBELN,
        LV_POSNR LIKE MSKA-POSNR,
        LV_WERKS LIKE MCHB-WERKS,
        LV_ATINN LIKE CABN-ATINN,
        LV_PCKCODE LIKE AUSP-ATWRT,
        LV_NOROLL LIKE AUSP-ATWRT,  "Add By Jarwo 12.07.2019
        LV_CHARVAL LIKE AUSP-ATWRT, "Add By Jarwo 15.07.2019
        LV_MAX_SEQ LIKE ZCORER-SEQNO,
        LV_MAX_SEQ_2 LIKE ZCORER-SEQNO,
        LV_TERMINAL LIKE ZCORER-ZUSER,
        LV_IP LIKE USR41-TERMINAL,
        LV_CUOBJ LIKE VEPO-CUOBJ.
  CLEAR: V_VBELN, V_POSNR, FCN_ERRNO, LV_CUOBJ, LV_PCKCODE, LV_WERKS.

  FCN_ERRNO = 0.
*- Step-step berikut digunakan untuk menentukan apakah perlu menampilkan pop up Input Core atau tidak.
*- Step 1: Cek Stok Batch.
  SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = V_CHARG AND ( CLABS > 0 OR CINSM > 0 OR CEINM > 0 OR CSPEM > 0 ).
  SELECT SINGLE * INTO LT_MSKA FROM MSKA WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).
  IF LT_MCHB IS INITIAL AND LT_MSKA IS INITIAL.
    EXIT.
  ELSE.
    IF LT_MCHB IS NOT INITIAL.
      LV_WERKS = LT_MCHB-WERKS.
    ELSEIF LT_MSKA IS NOT INITIAL.
      LV_WERKS = LT_MSKA-WERKS.
    ENDIF.
  ENDIF.

*- Step 2: Cek apakah ZZPACKINGCODE mengandung CP006
  SELECT SINGLE ATINN INTO LV_ATINN FROM CABN WHERE ATNAM = 'ZZPACKINGCODE'.

  SELECT SINGLE AUSP~ATWRT INTO LV_PCKCODE
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = V_MATNR AND MCH1~CHARG = V_CHARG AND AUSP~ATINN = LV_ATINN.


  IF LV_PCKCODE+1(1) CA 'C'.      "Modify by: James Budi on 25.09.2019
    "Add by Jarwo 15.07.2019
    CLEAR: LV_CHARVAL.
    SELECT SINGLE CHAR_VALUE FROM ZMAPP_RTP
      INTO LV_CHARVAL
      WHERE CATEGORY = 'ZZPACKINGCODE' AND
            INT_CHAR = LV_PCKCODE.

    IF NOT LV_CHARVAL CA 'C'.     "Modify by: James Budi on 25.09.2019
      EXIT.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.
  "Add by Jarwo 15.07.2019

  "Add By Jarwo 12.07.2019
  "Get Nomor Roll
  CLEAR: LV_NOROLL.
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOMORROLL'.
  LV_NOROLL = V_TAB-ATWRT.
  "Add By Jarwo 12.07.2019

*- Step 3: Ambil terminal User
  CALL FUNCTION 'TERMINAL_ID_GET'
    EXPORTING
      USERNAME             = SY-UNAME
    IMPORTING
      TERMINAL             = LV_IP
    EXCEPTIONS
      MULTIPLE_TERMINAL_ID = 1
      NO_TERMINAL_FOUND    = 2
      OTHERS               = 3.

  CONCATENATE: SY-UNAME ';' LV_IP INTO LV_TERMINAL.

*- Step 4: Cek apakah Roll sudah terikat dengan RTP Core
  SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER WHERE CHARG = V_CHARG.
  SELECT MAX( SEQNO ) INTO LV_MAX_SEQ_2 FROM ZCORER WHERE DOCNO = V_CHARG AND DOCTYPE = 'CH'.


*- Step 4.1: Jika batch tercatat di tabel ZCORER
  IF LV_MAX_SEQ > LV_MAX_SEQ_2.
    CLEAR: LT_ZCORER, WA_ZCORER, WA_ZCORER2.
    REFRESH: LT_ZCORER.

    SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE SEQNO = LV_MAX_SEQ.

    IF SY-SUBRC = 0.
*- Step 5: Cek data Master Core untuk diambil status terakhirnya.
      SELECT SINGLE * INTO WA_ZCORER2 FROM ZCORER WHERE COREID = WA_ZCORER-COREID AND CHARG = 'MASTER'.

      IF SY-SUBRC = 0.
        IF WA_ZCORER2-STATUS = 'R' OR WA_ZCORER2-STATUS = 'B' OR WA_ZCORER2-STATUS = 'C' OR WA_ZCORER2-STATUS = 'I'.
*- Step 6: Ambil Batch terakhir yang terikat dr Core ID yg bersangkutan.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZCORER UP TO 1 ROWS
          FROM ZCORER
          WHERE
            COREID = WA_ZCORER2-COREID AND
            CHARG <> 'MASTER' AND
            CHARG <> '' AND
            WERKS = WA_ZCORER2-WERKS  "Add By Jarwo 16.07.2019
          ORDER BY SEQNO DESCENDING.

          READ TABLE LT_ZCORER INDEX 1.

*- Step 7: Cek apakah Batch yang akan di-print sama dengan Batch terakhir yang terikat Core ID.
          IF LT_ZCORER-CHARG = V_CHARG. "Jika IYA
            LV_POPUP = ''.

*- Step 8: Cek apakah pernah di FREE TO SO
            IF WA_ZCORER2-STATUS = 'B'.
              IF LT_MSKA IS NOT INITIAL AND LT_MCHB IS INITIAL.

                CLEAR: LV_PCKCODE.
                SELECT SINGLE CUOBJ INTO LV_CUOBJ FROM VBAP WHERE VBELN = LT_MSKA-VBELN AND POSNR = LT_MSKA-POSNR.
                SELECT SINGLE C~ATWRT INTO LV_PCKCODE
                  FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
                  JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
                  WHERE A~INSTANCE EQ LV_CUOBJ AND C~ATINN EQ LV_ATINN.

                "Add By Jarwo 15.07.2019
                CLEAR: LV_CHARVAL.
                SELECT SINGLE CHAR_VALUE FROM ZMAPP_RTP
                  INTO LV_CHARVAL
                  WHERE CATEGORY = 'ZZPACKINGCODE' AND
                        INT_CHAR = LV_PCKCODE.
                "Add By Jarwo 15.07.2019

*                IF LV_PCKCODE+0(2) EQ 'CP'.
                IF LV_CHARVAL CA 'C'.        "Modify by: James Budi on 25.09.2019
                  LV_STATUS = 'R'.
                ELSE.
                  MESSAGE 'Batch menggunakan RTP Core namun terikat SO bukan untuk RTP Core!' TYPE 'I'.
                  FCN_ERRNO = 4.
                  EXIT.
                ENDIF.

                CLEAR: WA_ZCORER.

                SELECT MAX( SEQNO ) INTO WA_ZCORER-SEQNO FROM ZCORER.

                WA_ZCORER-SEQNO = WA_ZCORER-SEQNO + 1.
                WA_ZCORER-COREID = LT_ZCORER-COREID.
                WA_ZCORER-CHARG = V_CHARG.
                WA_ZCORER-WERKS = LT_ZCORER-WERKS.
                WA_ZCORER-STATUS = LV_STATUS.
                WA_ZCORER-DOCTYPE = 'SO'. "MD: Material Document, SO: Sales Order, DO: Delivery Order
                WA_ZCORER-DOCNO = LT_MSKA-VBELN.
                WA_ZCORER-POSNR = LT_MSKA-POSNR.
                WA_ZCORER-ERSDA = SY-DATUM.
                WA_ZCORER-ERZET = SY-UZEIT.
                WA_ZCORER-ZUSER = LV_TERMINAL.
                WA_ZCORER-REMARK = 'Free-to-SO'.

                MODIFY ZCORER FROM WA_ZCORER.
                COMMIT WORK.

                CLEAR: WA_ZCORER.
                SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.

                IF SY-SUBRC = 0.
                  WA_ZCORER-STATUS = LV_STATUS.
                  WA_ZCORER-ERSDA = SY-DATUM. "Add By Jarwo 16.07.2019
                  WA_ZCORER-ERZET = SY-UZEIT. "Add By Jarwo 16.07.2019
                  WA_ZCORER-ZUSER = LV_TERMINAL.  "Add By Jarwo 16.07.2019
                  MODIFY ZCORER FROM WA_ZCORER.
                  COMMIT WORK.
                ENDIF.
              ENDIF.
            ELSEIF WA_ZCORER2-STATUS = 'R'.
*- Step 9: Cek apakah pernah di SO TO FREE
              IF LT_MCHB IS NOT INITIAL AND LT_MSKA IS INITIAL.
                CLEAR: WA_ZCORER.

                SELECT MAX( SEQNO ) INTO WA_ZCORER-SEQNO FROM ZCORER.

                WA_ZCORER-SEQNO = WA_ZCORER-SEQNO + 1.
                WA_ZCORER-COREID = LT_ZCORER-COREID.
                WA_ZCORER-CHARG = V_CHARG.
                WA_ZCORER-WERKS = LT_ZCORER-WERKS.
                WA_ZCORER-STATUS = 'B'.
                WA_ZCORER-ERSDA = SY-DATUM.
                WA_ZCORER-ERZET = SY-UZEIT.
                WA_ZCORER-ZUSER = LV_TERMINAL.
                WA_ZCORER-REMARK = 'SO-to-Free'.

                MODIFY ZCORER FROM WA_ZCORER.
                COMMIT WORK.

                CLEAR: WA_ZCORER.
                SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.

                IF SY-SUBRC = 0.
                  WA_ZCORER-STATUS = 'B'.
                  WA_ZCORER-ERSDA = SY-DATUM. "Add By Jarwo 16.07.2019
                  WA_ZCORER-ERZET = SY-UZEIT. "Add By Jarwo 16.07.2019
                  WA_ZCORER-ZUSER = LV_TERMINAL.  "Add By Jarwo 16.07.2019
                  MODIFY ZCORER FROM WA_ZCORER.
                  COMMIT WORK.
                ENDIF.
*- Step 10: Cek apakah pernah di SO TO SO
              ELSEIF LT_MSKA IS NOT INITIAL.
*- Step 11: Cek apakah SO sebelumnya berbeda dengan SO yg saat ini.
                IF LT_ZCORER-DOCNO <> LT_MSKA-VBELN OR LT_ZCORER-POSNR <> LT_MSKA-POSNR.
                  CLEAR: LV_PCKCODE.
                  SELECT SINGLE CUOBJ INTO LV_CUOBJ FROM VBAP WHERE VBELN = LT_MSKA-VBELN AND POSNR = LT_MSKA-POSNR.
                  SELECT SINGLE C~ATWRT INTO LV_PCKCODE
                    FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
                    JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
                    WHERE A~INSTANCE EQ LV_CUOBJ AND C~ATINN EQ LV_ATINN.

                  "Add By Jarwo 15.07.2019
                  CLEAR: LV_CHARVAL.
                  SELECT SINGLE CHAR_VALUE FROM ZMAPP_RTP
                    INTO LV_CHARVAL
                    WHERE CATEGORY = 'ZZPACKINGCODE' AND
                          INT_CHAR = LV_PCKCODE.
                  "Add By Jarwo 15.07.2019

*                  IF LV_PCKCODE+0(2) EQ 'CP'.
                  IF LV_CHARVAL CA 'C'.           "Change By Jarwo 15.07.2019   "Modify by: James Budi on 25.09.2019
                    LV_STATUS = 'R'.
                  ELSE.
                    MESSAGE 'Batch menggunakan RTP Core namun terikat SO bukan untuk RTP Core!' TYPE 'I'.
                    FCN_ERRNO = 4.
                    EXIT.
                  ENDIF.

                  CLEAR: WA_ZCORER.

                  SELECT MAX( SEQNO ) INTO WA_ZCORER-SEQNO FROM ZCORER.

                  WA_ZCORER-SEQNO = WA_ZCORER-SEQNO + 1.
                  WA_ZCORER-COREID = LT_ZCORER-COREID.
                  WA_ZCORER-CHARG = V_CHARG.
                  WA_ZCORER-WERKS = LT_ZCORER-WERKS.
                  WA_ZCORER-STATUS = LV_STATUS.
                  WA_ZCORER-DOCTYPE = 'SO'. "MD: Material Document, SO: Sales Order, DO: Delivery Order
                  WA_ZCORER-DOCNO = LT_MSKA-VBELN.
                  WA_ZCORER-POSNR = LT_MSKA-POSNR.
                  WA_ZCORER-ERSDA = SY-DATUM.
                  WA_ZCORER-ERZET = SY-UZEIT.
                  WA_ZCORER-ZUSER = LV_TERMINAL.
                  WA_ZCORER-REMARK = 'SO TO SO'.

                  MODIFY ZCORER FROM WA_ZCORER.
                  COMMIT WORK.

                  CLEAR: WA_ZCORER.
                  SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.

                  IF SY-SUBRC = 0.
                    WA_ZCORER-STATUS = LV_STATUS.
                    WA_ZCORER-ERSDA = SY-DATUM. "Add By Jarwo 16.07.2019
                    WA_ZCORER-ERZET = SY-UZEIT. "Add By Jarwo 16.07.2019
                    WA_ZCORER-ZUSER = LV_TERMINAL.  "Add By Jarwo 16.07.2019
                    MODIFY ZCORER FROM WA_ZCORER.
                    COMMIT WORK.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            LV_POPUP = 'X'.
          ENDIF.
        ELSE.
          LV_POPUP = 'X'.
        ENDIF.
      ELSE.
        LV_POPUP = 'X'.
      ENDIF.
    ELSE.
      LV_POPUP = 'X'.
    ENDIF.
  ELSE.
*- Step 4.2: Jika batch tidak tercatat maka ada kemungkinan hasil Batch change grade
    SELECT SINGLE * INTO LT_ZBATCHISTORY FROM ZBATCHISTORY WHERE NCHARG = V_CHARG.

    IF SY-SUBRC = 0. "Jika ada data di ZBATCHISTORY
      CLEAR: LT_ZCORER, LV_MAX_SEQ.
      REFRESH: LT_ZCORER.

*- Step 4.2.1: Unrest Core dari SR awal sebelum Change Grade
      SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_ZCORER UP TO 1 ROWS
        FROM ZCORER
        WHERE
          CHARG = LT_ZBATCHISTORY-CHARG AND
          WERKS = LT_ZBATCHISTORY-WERKS    "Add By Jarwo 16.07.2019
        ORDER BY SEQNO DESCENDING.

      IF SY-SUBRC = 0.
        CLEAR: WA_ZCORER.
        READ TABLE LT_ZCORER INDEX 1.
        SELECT MAX( SEQNO ) INTO LV_MAX_SEQ FROM ZCORER.

        WA_ZCORER-SEQNO = LV_MAX_SEQ + 1.
        WA_ZCORER-COREID = LT_ZCORER-COREID.
        WA_ZCORER-WERKS = LT_ZCORER-WERKS. "Plant Batch SR
        WA_ZCORER-STATUS = 'U'.
        WA_ZCORER-ERSDA = SY-DATUM.
        WA_ZCORER-ERZET = SY-UZEIT.
        WA_ZCORER-ZUSER = LV_TERMINAL.
        WA_ZCORER-REMARK = 'Dilepas karena Change Grade'.
        MODIFY ZCORER FROM WA_ZCORER.
        COMMIT WORK.

        CLEAR: WA_ZCORER.
        SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.

        WA_ZCORER-STATUS = 'U'.
        WA_ZCORER-ERSDA = SY-DATUM. "Add By Jarwo 16.07.2019
        WA_ZCORER-ERZET = SY-UZEIT. "Add By Jarwo 16.07.2019
        WA_ZCORER-ZUSER = LV_TERMINAL.  "Add By Jarwo 16.07.2019
        MODIFY ZCORER FROM WA_ZCORER.
        COMMIT WORK.

*- Step 4.2.2: Ikatkan Core ID dengan Batch baru
        CLEAR: LV_VBELN, LV_POSNR, LV_STATUS, WA_ZCORER.
        SELECT MAX( SEQNO ) INTO WA_ZCORER-SEQNO FROM ZCORER.

        IF LT_MSKA IS NOT INITIAL.
          CLEAR: LV_PCKCODE.
          SELECT SINGLE CUOBJ INTO LV_CUOBJ FROM VBAP WHERE VBELN = LT_MSKA-VBELN AND POSNR = LT_MSKA-POSNR.
          SELECT SINGLE C~ATWRT INTO LV_PCKCODE
            FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
            JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
            WHERE A~INSTANCE EQ LV_CUOBJ AND C~ATINN EQ LV_ATINN.

          "Add By Jarwo 15.07.2019
          CLEAR: LV_CHARVAL.
          SELECT SINGLE CHAR_VALUE FROM ZMAPP_RTP
            INTO LV_CHARVAL
            WHERE CATEGORY = 'ZZPACKINGCODE' AND
                  INT_CHAR = LV_PCKCODE.
          "Add By Jarwo 15.07.2019

*          IF LV_PCKCODE+0(2) EQ 'CP'.
          IF LV_CHARVAL CA 'C'.        "Change By Jarwo 15.07.2019   "Modify by: James Budi on 25.09.2019
            LV_STATUS = 'R'.
            WA_ZCORER-DOCTYPE = 'SO'. "MD: Material Document, SO: Sales Order, DO: Delivery Order
          ELSE.
            MESSAGE 'Batch menggunakan RTP Core namun terikat SO bukan untuk RTP Core!' TYPE 'I'.
            FCN_ERRNO = 4.
            EXIT.
          ENDIF.
        ELSE.
          LV_STATUS = 'B'.
        ENDIF.

        WA_ZCORER-SEQNO = WA_ZCORER-SEQNO + 1.
        WA_ZCORER-COREID = LT_ZCORER-COREID.
        WA_ZCORER-CHARG = V_CHARG.
        WA_ZCORER-WERKS = LT_ZCORER-WERKS.
        WA_ZCORER-STATUS = LV_STATUS.
        WA_ZCORER-DOCNO = LV_VBELN.
        WA_ZCORER-POSNR = LV_POSNR.
        WA_ZCORER-ERSDA = SY-DATUM.
        WA_ZCORER-ERZET = SY-UZEIT.
        WA_ZCORER-ZUSER = LV_TERMINAL.
        WA_ZCORER-REMARK = 'Batch Hasil Change Grade'.
        MODIFY ZCORER FROM WA_ZCORER.
        COMMIT WORK.

        CLEAR: WA_ZCORER.
        SELECT SINGLE * INTO WA_ZCORER FROM ZCORER WHERE COREID = LT_ZCORER-COREID AND CHARG = 'MASTER'.

        WA_ZCORER-STATUS = LV_STATUS.
        WA_ZCORER-ERSDA = SY-DATUM. "Add By Jarwo 15.07.2019
        WA_ZCORER-ERZET = SY-UZEIT. "Add By Jarwo 15.07.2019
        WA_ZCORER-ZUSER = LV_TERMINAL.  "Add By Jarwo 15.07.2019
        MODIFY ZCORER FROM WA_ZCORER.
        COMMIT WORK.

        LV_POPUP = ''.
      ELSE.
        LV_POPUP = 'X'.
      ENDIF.
    ELSE.
      LV_POPUP = 'X'.
    ENDIF.
  ENDIF.


*- Step-step berikut digunakan untuk mengikatakan Core ID dengan batch.
*- Step 1: jika belum terikat dg RTP core, tampil Pop Up input RTP Core
  IF LV_POPUP = 'X'.
    CLEAR: ZSVAL.
    ZSVAL-TABNAME   = 'MCHB'.
    ZSVAL-FIELDNAME = 'CHARG'.
    ZSVAL-FIELDTEXT = 'Batch SR'.
    ZSVAL-FIELD_ATTR = '02'.
    ZSVAL-NOVALUEHLP = 'X'.
    ZSVAL-VALUE     = V_CHARG.
    APPEND ZSVAL.

    "Add By Jarwo 12.07.2019
    CLEAR: ZSVAL.
    ZSVAL-TABNAME   = 'AUSP'.
    ZSVAL-FIELDNAME = 'ATWRT'.
    ZSVAL-FIELDTEXT = 'Nomor Roll'.
    ZSVAL-FIELD_ATTR = '02'.
    ZSVAL-NOVALUEHLP = 'X'.
    ZSVAL-VALUE     = LV_NOROLL.
    APPEND ZSVAL.

    CLEAR: ZSVAL.
    ZSVAL-TABNAME   = 'MCH1'.
    ZSVAL-FIELDNAME = 'CHARG'.
    ZSVAL-FIELDTEXT = 'Core ID'.
    ZSVAL-FIELD_OBL = 'X'.
    APPEND ZSVAL.

    SELECT SINGLE DOCNO FROM ZCORER INTO V_DOCNO2 WHERE COREID EQ 'NON RTP' AND DOCTYPE EQ 'CH' AND DOCNO EQ V_CHARG.

    IF V_DOCNO2 IS INITIAL.
      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
*         NO_VALUE_CHECK  = ' '
          POPUP_TITLE     = 'Masukkan nomor Core ID'
          START_COLUMN    = '5'
          START_ROW       = '5'
        IMPORTING
          RETURNCODE      = LV_ANSWER
        TABLES
          FIELDS          = ZSVAL
        EXCEPTIONS
          ERROR_IN_FIELDS = 1
          OTHERS          = 2.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        EXIT.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.

    IF LV_ANSWER = 'A' . "Jika Pop Up di-cancel
      FCN_ERRNO = 4.
      EXIT.
    ELSE.
      DATA: V_VAL LIKE SVAL-VALUE. "Start add by Afir 08-01-2019
      READ TABLE ZSVAL WITH KEY TABNAME = 'MCH1' FIELDNAME = 'CHARG'.
      V_VAL = ZSVAL-VALUE.

      IF V_VAL EQ 'NON'.
        CLEAR LT_ZCORER.
        SELECT MAX( SEQNO ) INTO LT_ZCORER-SEQNO FROM ZCORER.

        LT_ZCORER-COREID = 'NON RTP'.
        LT_ZCORER-SEQNO = LT_ZCORER-SEQNO + 1.
        LT_ZCORER-DOCTYPE = 'CH'.
        LT_ZCORER-DOCNO = V_CHARG.
        LT_ZCORER-WERKS = LV_WERKS.
        LT_ZCORER-ERSDA = SY-DATUM.
        LT_ZCORER-ERZET = SY-UZEIT.
        LT_ZCORER-ZUSER = LV_TERMINAL.
        LT_ZCORER-REMARK = 'Aktual bukan RTP Core'.

        MODIFY ZCORER FROM LT_ZCORER.
        COMMIT WORK AND WAIT.
        EXIT.
      ENDIF. "End Add by Afir 08-01-2019

      READ TABLE ZSVAL WITH KEY FIELDTEXT = 'Core ID'.
      CONCATENATE '%' ZSVAL-VALUE INTO LV_CHARG_TEMP.
*      LV_CHARG_TEMP = ZSVAL-VALUE.  "Change By Jarwo 12.07.2019

      "Add By Jarwo 22.07.2019 Pop Up pilih ID Core
      CLEAR: IT_CORE, IT_CORE_DISPLAY.
      REFRESH: IT_CORE, IT_CORE_DISPLAY.
      SELECT COREID WERKS FROM ZCORER
        INTO CORRESPONDING FIELDS OF TABLE IT_CORE
        WHERE COREID LIKE LV_CHARG_TEMP AND
              CHARG = 'MASTER' AND WERKS EQ LV_WERKS.

      LOOP AT IT_CORE.
        IF IT_CORE-COREID(2) = 'CP'.
          IT_CORE-TYPERTP = 'Plastic Core'.
        ELSEIF IT_CORE-COREID(2) = 'CB'.
          IT_CORE-TYPERTP = 'Iron Core'.
        ELSE.
          IT_CORE-TYPERTP = 'Plastic Core'.
        ENDIF.

        IT_CORE-WIDTHRTP = IT_CORE-COREID+2(3).
        MODIFY IT_CORE.
      ENDLOOP.

      DATA: L_LINES TYPE I.
      DESCRIBE TABLE IT_CORE LINES L_LINES.

      IF L_LINES > 1.
        CONCATENATE 'Telah ditemukan beberapa' ZSVAL-VALUE 'RTP(ID). Mohon pilih salah satu.' INTO VINFO SEPARATED BY SPACE.
        SET PARAMETER ID 'VINFO' FIELD VINFO.

        CALL SCREEN 100 STARTING AT 75 3.

        IF IT_CORE_DISPLAY[] IS INITIAL.
          FCN_ERRNO = 4.
          EXIT.
        ENDIF.
      ELSEIF L_LINES = 0.
        CONCATENATE 'Tidak ditemukan RTP Core' ZSVAL-VALUE INTO LV_MSG SEPARATED BY SPACE.
        MESSAGE LV_MSG TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      READ TABLE IT_CORE_DISPLAY INDEX 1.
      IF SY-SUBRC = 0.
        LV_CHARG_TEMP = IT_CORE_DISPLAY-COREID.
        LV_WERKS = IT_CORE_DISPLAY-WERKS.
      ENDIF.
      "Add By Jarwo 22.07.2019

*- Step 2: Cek apakah memang batch untuk RTP Core
*      SELECT SINGLE CHARG INTO LV_COREID FROM MCH1 WHERE MATNR LIKE 'PPCB%' AND CHARG LIKE LV_CHARG_TEMP.
      SELECT SINGLE COREID INTO LV_COREID FROM ZCORER WHERE COREID LIKE LV_CHARG_TEMP AND CHARG = 'MASTER' AND WERKS = LV_WERKS. "Change By Jarwo 16.07.2019
      IF SY-SUBRC NE 0.
        CONCATENATE 'Core ID' ZSVAL-VALUE 'bukan material RTP Core' INTO LV_MSG SEPARATED BY SPACE.
        MESSAGE LV_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
      ENDIF.

*- Step 3: Cek apakah stok Core Platic ada
      CLEAR: LT_MCHB.
      REFRESH: LT_MCHB.
*      SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = LV_COREID AND CLABS > 0.
      SELECT SINGLE * INTO LT_MCHB FROM MCHB WHERE CHARG = LV_COREID AND CLABS > 0 AND WERKS = LV_WERKS.  "Change By Jarwo 16.07.2019
      IF SY-SUBRC NE 0.
        CONCATENATE 'Core ID' LV_COREID 'tidak memiliki Stok..!' INTO LV_MSG SEPARATED BY SPACE.
        MESSAGE LV_MSG TYPE 'I'.
        FCN_ERRNO = 4.
        EXIT.
*      ELSEIF LT_MCHB-LGORT = '2212'.
*        "Step 8: Cek apakah Core ada di Customer.
*        CONCATENATE 'Core ID' LV_COREID 'sedang ada di Customer..!' INTO LV_MSG SEPARATED BY SPACE.
*        MESSAGE LV_MSG TYPE 'I'.
*        FCN_ERRNO = 4.
*        EXIT.
      ELSE.
*- Step 4: Cek apakah Core ID sedang terikat dengan Batch SR / JR.
*        SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER' AND STATUS NOT IN ('N', 'U').
        SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER' AND STATUS NOT IN ('N', 'U') AND WERKS = LV_WERKS. "Change By Jarwo 16.07.2019
        IF SY-SUBRC = 0.
          IF LT_ZCORER-STATUS = 'R' OR LT_ZCORER-STATUS = 'B'.
            CONCATENATE 'Core ID' LV_COREID 'sedang terikat dengan Roll!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'C'.
            CONCATENATE 'Core ID' LV_COREID 'masih berada di Customer!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'I'.
            CONCATENATE 'Core ID' LV_COREID 'masih berstatus Inquality!' INTO LV_MSG SEPARATED BY SPACE.
          ELSEIF LT_ZCORER-STATUS = 'D'.
            CONCATENATE 'Core ID' LV_COREID 'berstatus Damage!' INTO LV_MSG SEPARATED BY SPACE.
          ENDIF.

          MESSAGE LV_MSG TYPE 'I'.
          FCN_ERRNO = 4.
          EXIT.
        ELSE.
*- Step 5: Cek Apakah Batch terikat SO
          CLEAR: LV_STATUS, LV_VBELN, LV_POSNR, LT_ZCORER.

          SELECT MAX( SEQNO ) INTO LT_ZCORER-SEQNO FROM ZCORER.

          IF LT_MSKA IS NOT INITIAL.
            CLEAR: LV_PCKCODE.
            SELECT SINGLE CUOBJ INTO LV_CUOBJ FROM VBAP WHERE VBELN = LT_MSKA-VBELN AND POSNR = LT_MSKA-POSNR.
            SELECT SINGLE C~ATWRT INTO LV_PCKCODE
              FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
              JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
              WHERE A~INSTANCE EQ LV_CUOBJ AND C~ATINN EQ LV_ATINN.

            "Add By Jarwo 15.07.2019
            CLEAR: LV_CHARVAL.
            SELECT SINGLE CHAR_VALUE FROM ZMAPP_RTP
              INTO LV_CHARVAL
              WHERE CATEGORY = 'ZZPACKINGCODE' AND
                    INT_CHAR = LV_PCKCODE.
            "Add By Jarwo 15.07.2019

            IF LV_CHARVAL CA 'C'. "Change By Jarwo 15.07.2019    "Modify by: James Budi on 25.09.2019
              LV_STATUS = 'R'.
              LT_ZCORER-DOCTYPE = 'SO'. "MD: Material Document, SO: Sales Order, DO: Delivery Order
              LV_VBELN = LT_MSKA-VBELN.
              LV_POSNR = LT_MSKA-POSNR.
            ELSE.
              MESSAGE 'Batch menggunakan RTP Core namun terikat SO bukan untuk RTP Core!' TYPE 'I'.
              FCN_ERRNO = 4.
              EXIT.
            ENDIF.

*            LV_VBELN = LT_MSKA-VBELN.
*            LV_POSNR = LT_MSKA-POSNR.
*            LV_STATUS = 'R'.
*            LT_ZCORER-DOCTYPE = 'SO'. "MD: Material Document, SO: Sales Order, DO: Delivery Order
          ELSE.
            LV_STATUS = 'B'.
          ENDIF.

          LT_ZCORER-SEQNO = LT_ZCORER-SEQNO + 1.
          LT_ZCORER-COREID = LV_COREID.
          LT_ZCORER-CHARG = V_CHARG.
          LT_ZCORER-WERKS = LV_WERKS.
          LT_ZCORER-STATUS = LV_STATUS.
          LT_ZCORER-DOCNO = LV_VBELN.
          LT_ZCORER-POSNR = LV_POSNR.
          LT_ZCORER-ERSDA = SY-DATUM.
          LT_ZCORER-ERZET = SY-UZEIT.
          LT_ZCORER-ZUSER = LV_TERMINAL.

          MODIFY ZCORER FROM LT_ZCORER.
          COMMIT WORK AND WAIT.

          IF SY-SUBRC = 0.
            CLEAR: LT_ZCORER.
*            SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER'.
            SELECT SINGLE * INTO LT_ZCORER FROM ZCORER WHERE COREID = LV_COREID AND CHARG = 'MASTER' AND WERKS = LV_WERKS.  "Change By Jarwo 16.07.2019

            IF SY-SUBRC = 0.
              LT_ZCORER-STATUS = LV_STATUS.
              LT_ZCORER-ERSDA = SY-DATUM. "Add by Jarwo 16.07.2019
              LT_ZCORER-ERZET = SY-UZEIT. "Add by Jarwo 16.07.2019
              LT_ZCORER-ZUSER = LV_TERMINAL.  "Add by Jarwo 16.07.2019
              MODIFY ZCORER FROM LT_ZCORER.
              COMMIT WORK.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "CEK_RTP_CORE

*&SPWIZARD: DECLARATION OF TABLECONTROL 'IT_CORER' ITSELF
CONTROLS: IT_CORER TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: OUTPUT MODULE FOR TC 'IT_CORER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE IT_CORER_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_CORE LINES IT_CORER-LINES.
ENDMODULE.                    "IT_CORER_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: INPUT MODUL FOR TC 'IT_CORER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE IT_CORER_MARK INPUT.
  DATA: G_IT_CORER_WA2 LIKE LINE OF IT_CORE.
  IF IT_CORER-LINE_SEL_MODE = 1
  AND WA_CORE-BOX = 'X'.
    LOOP AT IT_CORE INTO G_IT_CORER_WA2
      WHERE BOX = 'X'.
      G_IT_CORER_WA2-BOX = ''.
      MODIFY IT_CORE
        FROM G_IT_CORER_WA2
        TRANSPORTING BOX.
    ENDLOOP.
  ENDIF.
  MODIFY IT_CORE
    FROM WA_CORE
    INDEX IT_CORER-CURRENT_LINE
    TRANSPORTING BOX.
ENDMODULE.                    "IT_CORER_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'PFPOPUP'.
  GET PARAMETER ID 'VINFO' FIELD VINFO.
*  SET TITLEBAR 'xxx'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CASE SY-UCOMM.
    WHEN '&ACC'.
      REFRESH: IT_CORE_DISPLAY.

      LOOP AT IT_CORE WHERE BOX = 'X'.
        CLEAR WA_CORE_DISPLAY.
        WA_CORE_DISPLAY-COREID = IT_CORE-COREID.
        WA_CORE_DISPLAY-WERKS = IT_CORE-WERKS.

        APPEND WA_CORE_DISPLAY TO IT_CORE_DISPLAY.
      ENDLOOP.
      LEAVE TO SCREEN 0.
    WHEN '&CAN'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT