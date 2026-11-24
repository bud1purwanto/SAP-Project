REPORT ZLABELROL_CHANGE_90.

INCLUDE ZABAPALV.
INCLUDE ZLABEL_ZEBRA_INCL.
*INCLUDE ZMMR_LABELROL_INCL.

DATA: V_COPIES(3) VALUE 1.

DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      IT_LAYOUT TYPE SLIS_LAYOUT_ALV,
      T_SORTS TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.

TYPES: BEGIN OF ITAB,
      CHARG LIKE MSEG-CHARG,
      VNEWROLL(28),
      GRDATE(10),
      VOLDROLL(28),
      MATNR LIKE MSEG-MATNR,
      VLABEL(8),
      BOX(1),
      CHECK(1),
      END OF ITAB.

DATA : ITAB TYPE ITAB OCCURS 0 WITH HEADER LINE,
      ITAB2 TYPE ITAB OCCURS 0 WITH HEADER LINE.
*       V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE.

DATA: VX_ATNROL LIKE CABN-ATINN,
      VX_ATNLABEL LIKE CABN-ATINN.

******INCLUDE*******
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
       V_BARCODE LIKE AFPO-ABLAD.

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
       V_LABEL(10),
       V_LABELCEK(10).
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
DATA: V_PARTNO LIKE VBAP-KDMAT,
      V_ROW TYPE P,
      V_GETMATRTYPE TYPE STRING.


DATA: V_IS_ZEBRA_LABELROL(1).

*- Check using manufdate
DATA : V_GETMANUF TYPE STRING. "Added by Fany 28.01.2025 (Validation to display manufacturing date in label)

*********************

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
PARAMETER : P_SOURCE TYPE STRING OBLIGATORY.
SELECTION-SCREEN END OF BLOCK BLOCK1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SOURCE.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MODE             = 'O'
      TITLE            = 'Select File'
    IMPORTING
      FILENAME         = P_SOURCE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.
  PERFORM UPLOAD_DATA.
  PERFORM GETROLL.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = P_SOURCE
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB.
ENDFORM.                    "UPLOAD_DATA


*&---------------------------------------------------------------------*
*&      Form  GETROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GETROLL.

  LOOP AT ITAB.
    SELECT SINGLE MATNR INTO ITAB-MATNR FROM MCHA WHERE CHARG = ITAB-CHARG.

    SELECT SINGLE ATINN INTO VX_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
    SELECT SINGLE ATINN INTO VX_ATNLABEL FROM CABN WHERE ATNAM = 'ZZLABEL'.

    SELECT SINGLE  AUSP~ATWRT INTO ITAB-VOLDROLL
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = ITAB-MATNR AND MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = VX_ATNROL.

    SELECT SINGLE  AUSP~ATWRT INTO ITAB-VLABEL
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = ITAB-MATNR AND MCH1~CHARG = ITAB-CHARG AND AUSP~ATINN = VX_ATNLABEL.

    MODIFY ITAB TRANSPORTING VOLDROLL MATNR VLABEL WHERE CHARG = ITAB-CHARG.
  ENDLOOP.

  SORT ITAB BY VLABEL.

ENDFORM.                    "GETROLL


*&---------------------------------------------------------------------*
*&      Form  NEW_TEXT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NEW_TEXT_DATA.

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(8),
         V_S_WIDTH(4),
         V_S_LENGTH(8),
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
         V_S_LBS(10),
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
         V_LEN_GAUGE(2) VALUE 5,
         V_LEN_CORE(2) VALUE 10,
         V_LEN_IN_OUT(2) VALUE 15,
         V_LEN_NORMAL(2) VALUE 8,
         V_LEN_LENGTH(2) VALUE 6,
         V_LEN_FEET(2) VALUE 7,
         V_LEN_WIDTH(2) VALUE 4,
         V_LEN_INCH(2) VALUE 6,
*mode 3 decimal x
         V_LEN_WEIGHT(2) VALUE 8,
         V_LEN_LBS(2) VALUE 9,
         V_STRLEN(2),
         V_LEN_SOITEM(2) VALUE 17.

*mode decimal 3
  DATA : V_WEIGHT TYPE P DECIMALS 2,
         V_LENGTH TYPE P DECIMALS 2,
         V_LENGTH_SS(9) TYPE C,
         V_WIDTH  TYPE P DECIMALS 2,
         V_WIDTH_SS(9) TYPE C,
         V_SPLICE2_MIRING TYPE P DECIMALS 2,
         V_SPLICE1_MIRING TYPE P DECIMALS 2,
         V_TREAT_SS(24) TYPE C,
         V_CORE_SS(3) TYPE C,
         V_WEIGHT_SS(9) TYPE C.

  DATA : V_LOTNO(40) TYPE C,
        V_NUM TYPE P,
        V_CRITERIAGRD(1) TYPE C.


  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM, V_TAB.
  REFRESH : V_TAB.

  V_LABELTYPE = ITAB2-VLABEL.

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = ITAB2-MATNR AND
  CHARG = ITAB2-CHARG AND
  ( KALAB > 0 OR  KAINS > 0 OR  KASPE > 0 ).

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

  CLEAR : V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_ZZPACKING,
          V_LABELTYPE.

*Mod for new Slitting Perdana
*W mean SS
*M mean MS

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = ITAB2-MATNR
      I_VAL_CHARGE   = ITAB2-CHARG
    TABLES
      T_VAL_TAB      = V_TAB
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.

  V_DERIVATIVEMS = '00'.
  V_POSITIONMS = '00'.
  V_DERIVATIVESS = '00'.
  V_POSITIONSS = '00'.

  LOOP AT V_TAB.
    IF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
      V_DERIVATIVEMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
      V_POSITIONMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
      V_DERIVATIVESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
      V_POSITIONSS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
      V_GRADE = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSPLICE-1'.
      V_NUM = V_TAB-ATFLV.
      V_SPLICE1_D = V_NUM.
    ELSEIF V_TAB-ATNAM = 'ZZSPLICE-2'.
      V_NUM = V_TAB-ATFLV.
      V_SPLICE2_D = V_NUM.
    ENDIF.
  ENDLOOP.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZCRITERIA'.
  IF SY-SUBRC = 0.
    V_CRITERIAGRD = V_TAB-ATWRT.
  ENDIF.

  CONCATENATE ITAB2-CHARG V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS  V_POSITIONSS INTO V_BARCODE.

  CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
    EXPORTING
      INPUT          = V_BARCODE
    IMPORTING
      OUTPUT         = V_BARCODE
    EXCEPTIONS
      INVALID_FORMAT = 1
      OTHERS         = 2.

*Get Net weight...
  PERFORM GET_NET_WEIGHT.

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

      PERFORM MOD_WEIGHT_ALIAS USING ITAB2-MATNR ITAB2-CHARG V_WERKS V_TYPE.

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
*    ELSEIF v_tab-atnam = 'ZZTYPE'.
*      v_type  = v_tab-atwtb.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.
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
*    IF v_zzconversionmtrkg IS NOT INITIAL.
    V_TAB-ATNAM = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
*    ENDIF.
  ELSE.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
*    ENDIF.
  ENDIF.
*----------------------/


  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.


  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.

*- diskresi ROLLNO
  READ TABLE ITAB WITH KEY CHARG = ITAB2-CHARG.
   IF ITAB2-VNEWROLL NE ''.
    V_ROLLNO = ITAB2-VNEWROLL.
   ENDIF.

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
*    v_tab-atwtb = v_charg.
    IF V_LABELTYPE = 'D113' OR V_LABELTYPE = 'B113'.
      PERFORM SNW_ROLL_BARCODE.
    ELSE.
      V_TAB-ATWTB = V_BARCODE.
    ENDIF.

    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
*    v_tab-atwtb = v_charg.
    V_TAB-ATWTB = V_BARCODE.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC1'.
*    v_tab-atwtb = v_charg.
    CONCATENATE ITAB2-CHARG '-' V_BARCODE INTO V_CHARG_LONG.
    V_TAB-ATWTB = V_CHARG_LONG.
    APPEND V_TAB.

*Add Expired Date
*    SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg AND matnr EQ v_matnr.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = ITAB2-MATNR
        CHARG = ITAB2-CHARG
      IMPORTING
        PDATE = V_POSTDATE.

*- diskresi GR date
    READ TABLE ITAB WITH KEY CHARG = ITAB2-CHARG.
    IF ITAB-GRDATE NE ''.
      CONCATENATE ITAB-GRDATE+6(4) ITAB-GRDATE+3(2) ITAB-GRDATE+0(2) INTO V_POSTDATE.
    ENDIF.

    IF SY-SUBRC = 0.
      CLEAR : V_GETMANUF.
      SELECT SINGLE TEXT5 INTO "Added by Fany 23.01.2025
      V_GETMANUF
      FROM ZMAP_LABEL WHERE
      CODE = V_LABELORIG AND TYPE = 'DOS' AND TEXT5 = 'MANUF'.

*Senawang and others (Manufacturing Date : YYYY.MM)
      IF V_GETMANUF NE ''.
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.
*Mag-Data (Manufacturing Date : DD/MM/YYYY)
      ELSEIF ( V_LABELTYPE = 'A113' OR V_LABELTYPE = 'E109' ).
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4)  INTO V_TAB-ATWTB.
        APPEND V_TAB.
      "Case new label manuf and expired
      ELSEIF ( V_LABELTYPE = 'A162' OR V_LABELTYPE = 'C126' OR V_LABELTYPE = 'D131').
        V_TAB-ATNAM = 'ZZMANUFDATE'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

        V_EXPDATE = V_POSTDATE + V_LIVE.
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

      ELSE.
*Other (Used Before :)
          IF V_LABELTYPE = 'D201' OR V_LABELTYPE = 'D205' OR V_LABELTYPE = 'D206' OR V_LABELTYPE = 'D207' OR V_LABELTYPE = 'D208'.
          ELSEIF V_LABELTYPE = 'D121'.
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
             CODE = V_LABELTYPE AND TYPE = 'DOS'.
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
          ENDIF.    "no expired date
      ENDIF.


    ENDIF.


*Mod Left Justified
* Clear
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    V_TAB-ATNAM = 'ZZSPLICE-1'.
*Get The Splices At 1st Value(M -> Feet)

    PERFORM CONV_TO_CHAR USING V_SPLICE1_D.
    V_SPLICE1 = V_SPLICE1_D * V_C_FEET.
    WRITE V_SPLICE1 TO V_S_SPLICE1.
    V_SPLICE1_MIRING = V_SPLICE1_D.
    WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.

    IF V_SPLICE1_D = 0.
      V_TAB-ATWTB = ''.
      V_S_SPLICE1 = ''.
    ENDIF.
    PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                  V_TAB-ATWTB.
*    ENDIF.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZSPLICE-2'.
    PERFORM CONV_TO_CHAR USING V_SPLICE2_D.
    V_SPLICE2 = V_SPLICE2_D * V_C_FEET.
    WRITE V_SPLICE2 TO V_S_SPLICE2.
    V_SPLICE2_MIRING = V_SPLICE2_D.
    WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.

    IF V_SPLICE2_D = 0.
      V_TAB-ATWTB = ''.
      V_S_SPLICE2 = ''.
    ENDIF.
    PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                  V_TAB-ATWTB.
*    ENDIF.
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
          V_S_LBS.

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

* Set conversion & Left Justified...
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
*        PERFORM right_justified USING v_len_mic
*                                      v_tab-atwtb.

        V_THICKNESS = V_TAB-ATWTB.

*Prepare For Alias
        CONDENSE V_THICKNESS NO-GAPS.

        CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.

        V_TAB-ATWTB = ''.
        V_S_GAUGE = ''.


      ENDIF.

*Mod Left Justified
* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.

        IF V_LABELTYPE = 'A129' OR V_LABELTYPE = 'A302' OR V_LABELTYPE = 'A303'.
          PERFORM GET_INCH_FR_SO USING V_S_INCH.
        ELSE.
          V_INCH =   V_TAB-ATWTB * V_C_INCH.
          WRITE V_INCH TO V_S_INCH.
        ENDIF.

        V_WIDTH = V_TAB-ATWTB.
*        WRITE v_width TO v_tab-atwtb.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_WIDTH
                                      V_TAB-ATWTB.

        WRITE V_TAB-ATWTB TO V_S_WIDTH.
        CONDENSE V_S_WIDTH NO-GAPS.

      ENDIF.
*Mod Left Justified
* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_FEET.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        WRITE V_LENGTH TO V_S_LENGTH.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                      V_TAB-ATWTB.
        WRITE V_TAB-ATWTB TO V_S_LENGTH.
        CONDENSE V_S_LENGTH NO-GAPS.

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
        WRITE V_LBS TO V_S_LBS.
        V_WEIGHT = V_TAB-ATWTB.
        WRITE V_WEIGHT TO V_TAB-ATWTB.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        CONCATENATE V_TAB-ATWTB 'CORE' INTO V_TAB-ATWTB.
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
  CLEAR : V_LOTNO.

  IF ( V_LABELTYPE = 'B114' OR V_LABELTYPE = 'E108' OR V_LABELTYPE = 'C110' OR V_LABELTYPE = 'D115' OR
       V_LABELTYPE = 'A109' OR V_LABELTYPE = 'A148' OR V_LABELTYPE = 'C111' OR V_LABELTYPE = 'C111' OR
       V_LABELTYPE = 'F107' OR V_LABELTYPE = 'D116' OR V_LABELTYPE = 'D119').

    CONCATENATE V_TYPE '-' V_THICKNESS '/' V_S_WIDTH 'mm /' V_S_LENGTH 'm' INTO V_LOTNO SEPARATED BY SPACE..
  ENDIF.

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

      APPEND TEXT_DATA.
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
        IF V_LABELTYPE = 'A302' OR V_LABELTYPE = 'A303'.
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
*      write v_splice1 to v_s_splice1.
*      v_s_splice1 = v_splice1.
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
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZLOTNUMBER'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_LOTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.

      ELSEIF V_ZLABEL-ATNAM = 'ZZODR'.
        DATA: V_BSTKD_E LIKE VBKD-BSTKD_E,
              V_CHAR10 TYPE N LENGTH 10.  "like vbak-vbeln.

        V_CHAR10 = V_VBELN.

        IF V_LABELTYPE = 'J120' OR V_LABELTYPE = 'J121' OR V_LABELTYPE = 'A305' OR V_LABELTYPE = 'A308' OR
           V_LABELTYPE = 'J122' OR V_LABELTYPE = 'J123' OR V_LABELTYPE = 'A309' OR
           V_LABELTYPE = 'B215' OR V_LABELTYPE = 'B216' OR V_LABELTYPE = 'B223' OR
           V_LABELTYPE = 'D213' OR V_LABELTYPE = 'D214' OR V_LABELTYPE = 'D219'.

          SELECT SINGLE BSTKD_E INTO V_BSTKD_E FROM VBKD WHERE VBELN = V_CHAR10 AND POSNR = ''.

          IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_BSTKD_E '<ETX>' INTO TEXT_DATA-STR_TEXT.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.


      APPEND TEXT_DATA.
    ENDLOOP.

*- add part for A261
    IF V_LABELTYPE = 'A129'.
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
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width / Part No.' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTYPE'.
        IF SY-SUBRC = 0.
          TEXT_DATA-STR_TEXT = V_ZLABEL-DATA2.
        ENDIF.

        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC = 0.
          CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_ZLABEL-DATA2 'mm' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT ' / ' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ELSE.
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTYPE'.
        IF SY-SUBRC = 0.
          TEXT_DATA-STR_TEXT = V_ZLABEL-DATA2.
        ENDIF.

        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC = 0.
          CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_ZLABEL-DATA2 'mm' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.
    ENDIF.

    PERFORM ADD_PART_A214.

    CLEAR : V_GETMATRTYPE .
     SELECT SINGLE TEXT3 INTO
       V_GETMATRTYPE
       FROM ZMAP_LABEL WHERE
       CODE = V_LABELTYPE AND TYPE = 'DOS' AND TEXT3 = 'MATRTYPE'.

     IF  V_GETMATRTYPE NE ''.
       PERFORM GET_MATRLTYPE.
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
*  CONCATENATE file_dir  v_labeltype '.BAT' INTO file_b.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*get image filename.
*  CONCATENATE file_dir v_labeltype '.IMG' INTO file_i.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.


ENDFORM.                    "new_text_data


*&---------------------------------------------------------------------*
*&      Form  ADD_PART_A214
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_PART_A214.
  IF V_LABELTYPE = 'A214' OR  V_LABELTYPE = 'A215'  OR  V_LABELTYPE = 'E201'.
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
ENDFORM.                    "add_part_a214

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
  ELSE.
    MESSAGE 'BATCH BUTUH DATA SO' TYPE 'E' DISPLAY LIKE 'A'.
  ENDIF.
ENDFORM.                    "get_inch_fr_so

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_TAB_ATWTB  text
*----------------------------------------------------------------------*
FORM CONV_TO_CHAR  USING    V_TAB_ATWTB.
  V_TEST = V_TAB_ATWTB.
  REPLACE ALL OCCURRENCES OF '.00' IN V_TEST WITH ' '.
  REPLACE ALL OCCURRENCES OF ',' IN V_TEST WITH ' '.
  V_TAB-ATWTB = V_TEST.
ENDFORM.                    "CONV_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  CONV_TO_CHAR_3_DEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_TAB_ATWTB  text
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
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
  IF SY-SUBRC = 0.
    V_SUM_NETWEIGHT = V_TAB-ATFLV.
  ENDIF.
ENDFORM.                    " get_net_weight

*&---------------------------------------------------------------------*
*&      Form  MOD_WEIGHT_ALIAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_MATNR    text
*      -->V_CHARG    text
*      -->V_WERKS    text
*      -->V_TYPE     text
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
ENDFORM.                    "MOD_WEIGHT_ALIAS

*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_LENGTH   text
*      -->V_VALUE    text
*----------------------------------------------------------------------*
FORM RIGHT_JUSTIFIED  USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    "RIGHT_JUSTIFIED


*&---------------------------------------------------------------------*
*&      Form  RIGHT_JUSTIFIED_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_LENGTH   text
*      -->V_VALUE    text
*----------------------------------------------------------------------*
FORM RIGHT_JUSTIFIED_3  USING V_LENGTH
                            V_VALUE.
  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.

*  REPLACE ALL OCCURRENCES OF '.0' IN v_value WITH ' '.
  V_STRLEN = V_LENGTH - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    "RIGHT_JUSTIFIED_3


*&---------------------------------------------------------------------*
*&      Form  SNW_ROLL_BARCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SNW_ROLL_BARCODE .
  CONDENSE V_ROLLNO NO-GAPS.
  V_TAB-ATWTB = V_ROLLNO.

ENDFORM.                    " snw_roll_barcode


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
   'VLABEL'  '' ''  '' '25'  'Label'        '' ' ' '' '' ,
   'CHARG'  '' ''  '' '10'  'Batch'           '' '' '' '',
   'VOLDROLL'  '' ''  '' '25'  'Old Roll'        '' ' ' '' '',
   'VNEWROLL'  '' ''  '' '25'  'New Roll'        '' ' ' '' '',
   'GRDATE'  '' ''  '' '10'  'GR Date'        '' ' ' '' '',
   'MATNR'  '' ''  '' '25'  'Material'        '' ' ' '' ''.

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG'.

  LOOP AT ITAB WHERE VNEWROLL NE ''.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'VOLDROLL'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'VNEWROLL'.
  ENDIF.

  LOOP AT ITAB WHERE GRDATE NE ''.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC NE 0.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'GRDATE'.
  ENDIF.
ENDFORM.                    " f_field_catalog

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_LABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_TYPES   text
*      -->FU_FNAME   text
*      -->FU_REFTB   text
*      -->FU_REFLD   text
*      -->FU_NOOUT   text
*      -->FU_OUTLN   text
*      -->FU_FLTXT   text
*      -->FU_DOSUM   text
*      -->FU_HOTSP   text
*      -->FU_JUST    text
*      -->FU_ICON    text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_LABEL USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON
                                FU_CHK
                                FU_EDIT.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  T_FIELDCAT-CHECKBOX      = FU_CHK.
  T_FIELDCAT-INPUT          = 'X'.
  T_FIELDCAT-EDIT          = FU_EDIT.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " f_layout


*&---------------------------------------------------------------------*
*&      Form  f_list_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " f_list_detail


*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  CLEAR : ITAB2, V_ROW, V_LABELCEK, V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, TEXT_DATA, TEXT_DATA2, IT,
          V_LABELIMGOLD,V_LABELIMGNEW.
  REFRESH : ITAB2, V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, TEXT_DATA, TEXT_DATA2, IT.

  CASE FU_UCOMM.
    WHEN 'PRINT'.
      ITAB2[] = ITAB[].
      READ TABLE ITAB INDEX 1.
      V_LABELCEK = ITAB-VLABEL.
      LOOP AT ITAB.
        PERFORM CEK_TIPELABEL USING ITAB-VLABEL.
        IF V_LABELCEK NE ITAB-VLABEL.
          MESSAGE 'DATA UPLOAD HARUS TIPE LABEL YANG SAMA' TYPE 'E' DISPLAY LIKE 'A'.
        ENDIF.
      ENDLOOP.

      DELETE ITAB2 WHERE BOX IS INITIAL.
      DESCRIBE TABLE ITAB2 LINES V_ROW.
      IF V_ROW > 5.
        MESSAGE 'MAKSIMAL CETAK 5 BATCH' TYPE 'E' DISPLAY LIKE 'A'.
      ENDIF.

      "Check using zebra printer or not
      PERFORM CHECK_USING_ZEBRA CHANGING V_IS_ZEBRA_LABELROL.

      LOOP AT ITAB2 WHERE BOX = 'X'.
        PERFORM NEW_TEXT_DATA.
        PERFORM F_EXIT_LABEL.
        AT LAST.
          PERFORM DOWNLOAD_DATA.
          PERFORM GETFRSRV_B.
          PERFORM PRINT.
          REFRESH: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, TEXT_DATA, TEXT_DATA2, IT.
          CLEAR: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, TEXT_DATA, TEXT_DATA2, IT.
        ENDAT.

      ENDLOOP.
  ENDCASE.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*

*&      Form  F_EXIT_LABEL

*&---------------------------------------------------------------------*

*       text

*----------------------------------------------------------------------*

FORM F_EXIT_LABEL.
  DATA: V_CHARG1 LIKE V_TAB-ATWRT.
  DATA: V_CHARG2 LIKE V_TAB-ATWRT.
  DATA: LT_MAP_LABEL LIKE ZMAP_LABEL OCCURS 0 WITH HEADER LINE.
  DATA: EXECUTE(1).

  "Mapping Deconvert
  SELECT * INTO CORRESPONDING FIELDS OF TABLE LT_MAP_LABEL FROM ZMAP_LABEL WHERE TEXT1 = 'CONVB64'.

  IF SY-SUBRC NE 0. "Jika semua label sudah menerapkan, tinggal menghapus data di table dengan text1 CONVB64
    EXECUTE = 'X'.
  ELSE.

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC EQ 0.
      READ TABLE LT_MAP_LABEL WITH KEY CODE = V_TAB-ATWRT TEXT1 = 'CONVB64'.
      IF SY-SUBRC EQ 0.
        EXECUTE = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

*- exit-001
  IF EXECUTE = 'X'.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZBARC1'.
    SPLIT V_TAB-ATWTB AT '-' INTO V_CHARG1 V_CHARG2.
    LOOP AT TEXT_DATA.
      IF TEXT_DATA-STR_TEXT CS '<STX><ESC>F"BARC  "<LF>' AND TEXT_DATA-STR_TEXT CS V_CHARG2.
        CONCATENATE '<STX><ESC>F"BARC  "<LF>' V_CHARG1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        MODIFY TEXT_DATA.
      ENDIF.

      IF TEXT_DATA-STR_TEXT CS 'STX><ESC>F"BARC1 "' AND TEXT_DATA-STR_TEXT CS V_TAB-ATWTB.
        CONCATENATE '<STX><ESC>F"BARC1 "<LF>' V_CHARG1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        MODIFY TEXT_DATA.
      ENDIF.

      IF TEXT_DATA-STR_TEXT CS 'STX><ESC>F"BCROLL"'.
        TEXT_DATA-STR_TEXT = '<STX><ESC>F"BCROLL"<LF><ETX>'.
        MODIFY TEXT_DATA.
      ENDIF.
    ENDLOOP.
  ENDIF.
*- exit-002



ENDFORM.                    "F_EXIT_LABEL


*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS


*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*       text
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
*&      Form  PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT .
  CLEAR : V_RETURNCODE.
  IF V_IS_ZEBRA_LABELROL EQ 'X'. "Execute program if file zebra.zpl found.
*  Change emulation in zebra printer
    PERFORM CHANGE_ZEBRA_EMULATION USING 'APL-I'.
    WAIT UP TO 8 SECONDS.
    IF SY-SUBRC EQ 0.
*  Print label to zebra
        PERFORM PRINT_ZEBRA CHANGING V_RETURNCODE.
     ENDIF.
   ELSE.

*    CONCATENATE pfn  v_labeltype  '.BAT' INTO file_batch.
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



*&---------------------------------------------------------------------*
*&      Form  GETFRSRV_B
*&---------------------------------------------------------------------*
*       text
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
*&      Form  XFER2IT
*&---------------------------------------------------------------------*
*       text
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
ENDFORM.                    "XFER2IT

*&---------------------------------------------------------------------*
*&      Form  DSREAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DSN        text
*      -->REC        text
*----------------------------------------------------------------------*
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

*&---------------------------------------------------------------------*
*&      Form  DSCLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DSN        text
*----------------------------------------------------------------------*
FORM DSCLOSE
USING DSN TYPE C.
  CLOSE DATASET DSN.
  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error closing' DSN 'rc=' SY-SUBRC.
  ENDIF.
ENDFORM.                    "DSCLOSE

*&---------------------------------------------------------------------*
*&      Form  GETFRSRV_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GETFRSRV_F.
  CONCATENATE PFN  V_LABELTYPE '.TAX' INTO FILE_DOWNLOAD.
  SFN = FILE_F.
  REFRESH IT.
  PERFORM DSOPEN_INPUT_TEXT USING SFN.
  PERFORM XFER2IT.
ENDFORM. "getfrsrv_f


DEFINE DSFORM_OPEN1.
*&---------------------------------------------------------------------*
*&      Form  DSOPEN_&1_&2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DSN        text
*----------------------------------------------------------------------*
FORM DSOPEN_&1_&2 USING DSN TYPE C.
  DATA MSG(80).
* open dataset dsn for &1 in &2 mode message msg.
  OPEN DATASET DSN FOR &1 IN &2 MODE ENCODING DEFAULT MESSAGE MSG.

  IF SY-SUBRC <> 0.
    MESSAGE E001(ZK) WITH 'Error opening' DSN MSG.
  ENDIF.
ENDFORM. "dsopen_&1_&2

END-OF-DEFINITION.

*dsform_open input text.
DSFORM_OPEN1 INPUT TEXT.
***DSFORM_OPEN INPUT BINARY.
****dsform_open output text.
***DSFORM_OPEN1 OUTPUT TEXT.
***DSFORM_OPEN OUTPUT BINARY.

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_FRSRV
*&---------------------------------------------------------------------*
*       text
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
*&      Form  CEK_TIPELABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_TIPELABEL USING VTIPELABEL.
  IF (
VTIPELABEL = 'B002' OR VTIPELABEL = 'B003' OR VTIPELABEL = 'B004' OR VTIPELABEL = 'B025' OR
VTIPELABEL = 'B021' OR VTIPELABEL = 'B022' OR VTIPELABEL = 'B023' OR VTIPELABEL = 'B024' OR
VTIPELABEL = 'B026' OR VTIPELABEL = 'B027' OR VTIPELABEL = 'B029' OR VTIPELABEL = 'B030' OR
VTIPELABEL = 'D009' OR VTIPELABEL = 'D010' OR VTIPELABEL = 'B013' OR VTIPELABEL = 'B014' OR
VTIPELABEL = 'B015' OR VTIPELABEL = 'B016' OR VTIPELABEL = 'A011' OR VTIPELABEL = 'A012' OR
VTIPELABEL = 'A013' OR VTIPELABEL = 'B017' OR VTIPELABEL = 'B018' OR VTIPELABEL = 'B031' OR
VTIPELABEL = 'A014' OR VTIPELABEL = 'A015' OR VTIPELABEL = 'A016' OR VTIPELABEL = 'A017' OR
VTIPELABEL = 'A018' OR VTIPELABEL = 'A019' OR VTIPELABEL = 'B020' OR VTIPELABEL = 'A010' OR
VTIPELABEL = 'D020' OR VTIPELABEL = 'A020' OR VTIPELABEL = 'A021' OR VTIPELABEL = 'L001' OR
VTIPELABEL = 'L002' OR VTIPELABEL = 'L003' OR VTIPELABEL = 'L004' OR VTIPELABEL = 'L005' OR
VTIPELABEL = 'D013' OR VTIPELABEL = 'D014' OR VTIPELABEL = 'D015' OR VTIPELABEL = 'G001' OR
VTIPELABEL = 'L011' OR VTIPELABEL = 'A009' OR VTIPELABEL = 'K100' OR VTIPELABEL = 'K101' OR
VTIPELABEL = 'K102' OR VTIPELABEL = 'K103' OR VTIPELABEL = 'K110' OR VTIPELABEL = 'K120' OR
VTIPELABEL = 'K140' OR VTIPELABEL = 'K150' OR VTIPELABEL = 'K160' OR VTIPELABEL = 'K130' OR
VTIPELABEL = 'A300' OR VTIPELABEL = 'A301' OR VTIPELABEL = 'A304' OR VTIPELABEL = 'A305' OR
VTIPELABEL = 'A211' OR VTIPELABEL = 'A212' OR VTIPELABEL = 'A213' ).
    MESSAGE 'TIPE LABEL BUKAN STANDAR LABEL' TYPE 'E' DISPLAY LIKE 'A'.
  ENDIF.

ENDFORM.                    "CEK_TIPELABEL



FORM GET_MATRLTYPE.
  CLEAR: V_PARTNO.
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
    CONCATENATE '<STX><ESC>F"PART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.
    APPEND TEXT_DATA.
  ENDIF.

ENDFORM.                    "GET_MATRLTYPE