*&---------------------------------------------------------------------*
*& Report  ZPPI_TRANSFER_WASTE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPI_TRANSFER_WASTE.
INCLUDE ZABAPALV.

TABLES : T001W, MARA, T001L, MAKT.

CONSTANTS : C_ICON_SUCCESS TYPE ICON-ID VALUE '@08@',
            C_ICON_ERROR TYPE ICON-ID VALUE '@0A@'.

DATA :   S_PLANT  TYPE MSEG-WERKS,
         S_MATNR  TYPE MARC-MATNR,
         S_SLOCA  TYPE MARD-LGORT,
         S_SLOCT  TYPE MARD-LGORT.

DATA : BEGIN OF TSLOCA OCCURS 0,
        SLOCA   LIKE T001L-LGORT,
        DESC    LIKE T001L-LGOBE,
       END OF TSLOCA.

DATA : BEGIN OF TSLOCT OCCURS 0,
        SLOCT   LIKE T001L-LGORT,
        DESC    LIKE T001L-LGOBE,
       END OF TSLOCT.

DATA : BEGIN OF TMATNR OCCURS 0,
        MATNR   LIKE MARA-MATNR,
        MAKTX   LIKE MAKT-MAKTX,
       END OF TMATNR.

DATA : BEGIN OF IT_STOCK OCCURS 0,
          MARK(1)   TYPE C,
          MATNR     TYPE MARA-MATNR,
          MAKTX     TYPE MAKT-MAKTX,
          WERKS     TYPE MARD-WERKS,
          SLOCA     TYPE MARD-LGORT,
          SLOCT     TYPE MARD-LGORT,
          UMLME     TYPE MARD-UMLME,
          UMLME_OLD TYPE MARD-UMLME,
          MEINS     TYPE MARA-MEINS,
          MBLNR     TYPE MSEG-MBLNR,
          ZMSG      TYPE STRING,
          ICON      TYPE ICON-ID,
        END OF IT_STOCK.

DATA : WA_STOCK LIKE LINE OF IT_STOCK.
DATA : L_ERROR(1),
       ZANSWER TYPE C.

DATA :  GOODSMVT_HEADER   LIKE  BAPI2017_GM_HEAD_01,
        GOODSMVT_CODE     LIKE  BAPI2017_GM_CODE,
        TESTRUN           LIKE  BAPI2017_GM_GEN-TESTRUN,
        GOODSMVT_ITEM     LIKE  BAPI2017_GM_ITEM_CREATE OCCURS 0 WITH HEADER LINE,
        RETURN            LIKE  BAPIRET2 OCCURS 0 WITH HEADER LINE,
        MATERIALDOCUMENT  TYPE  BAPI2017_GM_HEAD_RET-MAT_DOC,
        MATDOCUMENTYEAR   TYPE  BAPI2017_GM_HEAD_RET-DOC_YEAR.

DATA : WA_RETURN LIKE LINE OF RETURN.

"DATA FOR RANGE SLOC ASAL.
RANGES : R_SLOCA  FOR  T001L-LGORT.

START-OF-SELECTION.
  CALL SCREEN 1100.

END-OF-SELECTION.


*----------------------------------------------------------------------*
*  MODULE SEL_SCR_1110 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE SEL_SCR_1110 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1110 AS SUBSCREEN.
  PARAMETERS      : P_WERKS TYPE T001W-WERKS OBLIGATORY.
  SELECT-OPTIONS  : P_MATNR FOR MARA-MATNR NO INTERVALS.
  SELECT-OPTIONS  : P_SLOCA FOR T001L-LGORT NO INTERVALS.
  PARAMETERS      : P_SLOCT TYPE C LENGTH 4.
  PARAMETERS      : NOZERO AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF SCREEN 1110 .
ENDMODULE.                 " SEL_SCR_1110  OUTPUT

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_MATNR-LOW.
  PERFORM F4_MATNR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_MATNR-HIGH.
  PERFORM F4_MATNR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SLOCA-LOW.
  PERFORM F4_SLOCA.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_SLOCA-HIGH.
  PERFORM F4_SLOCA.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'P_SLOCT'.
      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*----------------------------------------------------------------------*
*  MODULE STATUS_1100 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS 'PROD_STAT1100'.
  SET TITLEBAR  'PROD_TITLE1100'.
  PERFORM INITIAL_LGORT.
ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  INITIAL_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INITIAL_LGORT .
  CLEAR P_SLOCT.
  IF P_WERKS = '1000'.
    P_SLOCT = '1700'.
  ELSEIF P_WERKS = '2000'.
    P_SLOCT = '2700'.
  ELSEIF P_WERKS = 'TTA2'.
    P_SLOCT = '2700'.
  ELSEIF P_WERKS = 'TTE'.
    P_SLOCT = '2700'.
  ELSE.
    P_SLOCT = ''.
  ENDIF.
  IF P_SLOCT IS NOT INITIAL.
    SELECT SINGLE LGOBE FROM T001L INTO T001L-OIH_LICNO WHERE LGORT EQ P_SLOCT AND WERKS EQ P_WERKS.
  ENDIF.
ENDFORM.                    " INITIAL_LGORT

*&---------------------------------------------------------------------*
*&      Form  F4_MATNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_MATNR.

  DATA : BEGIN OF IT_F4 OCCURS 0,
          MATNR TYPE MARA-MATNR,
          MAKTX TYPE MAKT-MAKTX,
         END OF IT_F4.

  DATA: XDYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD WITH HEADER LINE,
        DYNAME LIKE D020S-PROG.

  DYNAME = SY-REPID.
  XDYNPFIELDS-FIELDNAME = 'P_WERKS'.
  APPEND XDYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = DYNAME
      DYNUMB               = '1110'
      TRANSLATE_TO_UPPER   = 'X'
    TABLES
      DYNPFIELDS           = XDYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC = 0.
    READ TABLE XDYNPFIELDS WITH KEY FIELDNAME = 'P_WERKS'.
    IF SY-SUBRC = 0.
      S_PLANT = XDYNPFIELDS-FIELDVALUE.
    ENDIF.
  ENDIF.

  IF S_PLANT IS INITIAL.
    MESSAGE 'Masukkan Plant terlebih dahulu' TYPE 'I'.
    EXIT.
  ENDIF.

  SELECT MARA~MATNR MAKT~MAKTX
    INTO CORRESPONDING FIELDS OF TABLE IT_F4
    FROM MARA
      JOIN MAKT ON MARA~MATNR = MAKT~MATNR
      JOIN MARC ON MARA~MATNR = MARC~MATNR
    WHERE MARA~MATKL IN ('B00504','B00506','B00508')
       AND MARC~WERKS = S_PLANT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'MATNR'
      DYNPROFIELD = 'P_MATNR'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_F4.
ENDFORM.                    "F4_MATNR

*&---------------------------------------------------------------------*
*&      Form  F4_SLOCA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_SLOCA.

  DATA : BEGIN OF IT_F4 OCCURS 0,
          SLOCA   LIKE T001L-LGORT,
          DESC    LIKE T001L-LGOBE,
         END OF IT_F4.

  DATA: XDYNPFIELDS TYPE STANDARD TABLE OF DYNPREAD WITH HEADER LINE,
        DYNAME LIKE D020S-PROG.

  DYNAME = SY-REPID.
  XDYNPFIELDS-FIELDNAME = 'P_WERKS'.
  APPEND XDYNPFIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = DYNAME
      DYNUMB               = '1110'
      TRANSLATE_TO_UPPER   = 'X'
    TABLES
      DYNPFIELDS           = XDYNPFIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

  IF SY-SUBRC = 0.
    READ TABLE XDYNPFIELDS WITH KEY FIELDNAME = 'P_WERKS'.
    IF SY-SUBRC = 0.
      S_PLANT = XDYNPFIELDS-FIELDVALUE.
    ENDIF.
  ENDIF.

  IF S_PLANT IS INITIAL.
    MESSAGE 'Masukkan Plant terlebih dahulu' TYPE 'I'.
    EXIT.
  ENDIF.

  SELECT DISTINCT ZRRLGORT AS SLOCA LGOBE AS DESC
   INTO CORRESPONDING FIELDS OF TABLE IT_F4
   FROM ZTMAP_SLOCRR
    JOIN T001L ON ZTMAP_SLOCRR~ZRRLGORT = T001L~LGORT AND ZTMAP_SLOCRR~WERKS = T001L~WERKS
   WHERE ZTMAP_SLOCRR~WERKS = S_PLANT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'SLOCA'
      DYNPROFIELD = 'P_SLOCA'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_F4.
ENDFORM.                    "F4_SLOCA

*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_1100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1100 INPUT.
  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'COPY'.
      PERFORM GET_DATA.
    WHEN 'EXECUTE'.
      CLEAR ZANSWER.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = 'Confirmation'
          TEXT_QUESTION         = 'Apakah Anda Yakin akan Melakukan Transfer pada Data yang dipilih?'
          TEXT_BUTTON_1         = 'Ya'
          TEXT_BUTTON_2         = 'Tidak'
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = ''
        IMPORTING
          ANSWER                = ZANSWER.

      IF ZANSWER = 1.
        PERFORM PROCESS_DATA.
      ENDIF.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1100  INPUT

*----------------------------------------------------------------------*
*  MODULE GET_DESC_INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE GET_DESC_INPUT.
  IF P_WERKS IS NOT INITIAL AND P_WERKS NE '*'.
    SELECT SINGLE NAME1 FROM T001W INTO T001W-NAME1 WHERE WERKS EQ P_WERKS.
  ELSE.
    CLEAR T001W-NAME1.
  ENDIF.
  IF P_MATNR IS NOT INITIAL AND P_MATNR-LOW NE '*'..
    READ TABLE P_MATNR INDEX 1.
    SELECT SINGLE MAKTX FROM MAKT INTO MAKT-MAKTX WHERE  MATNR EQ P_MATNR-LOW.
  ELSE.
    CLEAR MAKT-MAKTX.
  ENDIF.
  IF P_SLOCA IS NOT INITIAL AND P_SLOCA-LOW NE '*'.
    READ TABLE P_SLOCA INDEX 1.
    SELECT SINGLE LGOBE FROM T001L INTO T001L-LGOBE WHERE LGORT EQ P_SLOCA-LOW AND WERKS EQ P_WERKS.
  ELSE.
    CLEAR T001L-LGOBE.
  ENDIF.
ENDMODULE.                    "GET_DESC_INPUT



*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.

  REFRESH : IT_STOCK.
  PERFORM INITIAL_LGORT.

  IF P_SLOCA[] IS INITIAL.
    SELECT DISTINCT ZRRLGORT AS LOW
      INTO CORRESPONDING FIELDS OF TABLE R_SLOCA
      FROM ZTMAP_SLOCRR
      JOIN T001L ON ZTMAP_SLOCRR~ZRRLGORT = T001L~LGORT AND ZTMAP_SLOCRR~WERKS = T001L~WERKS
      WHERE ZTMAP_SLOCRR~WERKS = P_WERKS.

    R_SLOCA-SIGN = 'I'.
    R_SLOCA-OPTION = 'EQ'.
    MODIFY R_SLOCA TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
  ENDIF.

  IF NOZERO IS INITIAL.
    SELECT MARD~MATNR MAKT~MAKTX MARD~LGORT AS SLOCA MARD~WERKS MARD~UMLME MARD~UMLME AS UMLME_OLD MARA~MEINS
      INTO CORRESPONDING FIELDS OF TABLE IT_STOCK
      FROM MARD JOIN MAKT ON MARD~MATNR = MAKT~MATNR
          JOIN MARA ON MARD~MATNR = MARA~MATNR
      WHERE LGORT IN P_SLOCA AND WERKS = P_WERKS
            AND MARA~MATNR IN P_MATNR
            AND LGORT IN R_SLOCA
            AND MARA~MATKL IN ('B00504','B00506','B00508').
  ELSE.
    SELECT MARD~MATNR MAKT~MAKTX MARD~LGORT AS SLOCA MARD~WERKS MARD~UMLME MARD~UMLME AS UMLME_OLD MARA~MEINS
      INTO CORRESPONDING FIELDS OF TABLE IT_STOCK
      FROM MARD JOIN MAKT ON MARD~MATNR = MAKT~MATNR
          JOIN MARA ON MARD~MATNR = MARA~MATNR
      WHERE LGORT IN P_SLOCA
            AND WERKS = P_WERKS
            AND MARA~MATNR IN P_MATNR
            AND LGORT IN R_SLOCA
            AND MARA~MATKL IN ('B00504','B00506','B00508')
            AND UMLME > 0.
  ENDIF.
  IT_STOCK-SLOCT = P_SLOCT.
  MODIFY IT_STOCK TRANSPORTING SLOCT WHERE MATNR IS NOT INITIAL.

  IF IT_STOCK[] IS INITIAL.
    MESSAGE 'No Data Found' TYPE 'I'.
  ENDIF.

ENDFORM.                    "GET_DATA


*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PROCESS_DATA.
  CLEAR L_ERROR.
  READ TABLE IT_STOCK WITH KEY MARK = 'X'.
  IF SY-SUBRC = 0.

    LOOP AT IT_STOCK WHERE MARK = 'X'.
*      IF IT_STOCK-UMLME_OLD LE 0.
*        MESSAGE 'Quantity sudah habis / 0 (Nol)' TYPE 'I'.
*        L_ERROR = 1.
*        EXIT.
*      ELSE.
      IF IT_STOCK-UMLME > IT_STOCK-UMLME_OLD.
        MESSAGE 'Quantity yang dipindah melebihi stock yang ada' TYPE 'I'.
        L_ERROR = 1.
        EXIT.
      ENDIF.
*      ENDIF.
    ENDLOOP.

    CHECK L_ERROR <> 1.

    LOOP AT IT_STOCK WHERE MARK = 'X'.

      CLEAR   : GOODSMVT_HEADER, GOODSMVT_CODE, TESTRUN, GOODSMVT_ITEM, RETURN, MATERIALDOCUMENT,MATDOCUMENTYEAR.
      REFRESH :  GOODSMVT_ITEM, RETURN.

      GOODSMVT_HEADER-PSTNG_DATE  = SY-DATUM.
      GOODSMVT_HEADER-DOC_DATE    = SY-DATUM.
      GOODSMVT_HEADER-REF_DOC_NO  = 'TRANSFER WASTE'.
      GOODSMVT_CODE = '04'.

      GOODSMVT_ITEM-PLANT       = IT_STOCK-WERKS.
      GOODSMVT_ITEM-MATERIAL    = IT_STOCK-MATNR.
      GOODSMVT_ITEM-STGE_LOC    = IT_STOCK-SLOCA.
      GOODSMVT_ITEM-MOVE_TYPE   = '315'.
      GOODSMVT_ITEM-ENTRY_QNT   = IT_STOCK-UMLME.
      GOODSMVT_ITEM-ENTRY_UOM   = IT_STOCK-MEINS.
      GOODSMVT_ITEM-MOVE_STLOC  = IT_STOCK-SLOCA.
      APPEND GOODSMVT_ITEM.

      GOODSMVT_ITEM-PLANT       = IT_STOCK-WERKS.
      GOODSMVT_ITEM-MATERIAL    = IT_STOCK-MATNR.
      GOODSMVT_ITEM-STGE_LOC    = IT_STOCK-SLOCA.
      GOODSMVT_ITEM-MOVE_TYPE   = '311'.
      GOODSMVT_ITEM-ENTRY_QNT   = IT_STOCK-UMLME.
      GOODSMVT_ITEM-ENTRY_UOM   = IT_STOCK-MEINS.
      GOODSMVT_ITEM-MOVE_STLOC  = IT_STOCK-SLOCT.
      APPEND GOODSMVT_ITEM.

      CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
        EXPORTING
          GOODSMVT_HEADER  = GOODSMVT_HEADER
          GOODSMVT_CODE    = GOODSMVT_CODE
        IMPORTING
          MATERIALDOCUMENT = MATERIALDOCUMENT
          MATDOCUMENTYEAR  = MATDOCUMENTYEAR
        TABLES
          GOODSMVT_ITEM    = GOODSMVT_ITEM
          RETURN           = RETURN.

      IF MATERIALDOCUMENT IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
        CONCATENATE 'Posting  Transfer Material berhasil dengan Material Dokumen' MATERIALDOCUMENT INTO IT_STOCK-ZMSG SEPARATED BY SPACE.
        IT_STOCK-ICON = C_ICON_SUCCESS.
        IT_STOCK-MBLNR = MATERIALDOCUMENT.
        IT_STOCK-UMLME_OLD = IT_STOCK-UMLME_OLD - IT_STOCK-UMLME.
      ELSE.
        READ TABLE RETURN WITH KEY TYPE = 'E'.
        IT_STOCK-ZMSG = RETURN-MESSAGE.
        IT_STOCK-ICON = C_ICON_ERROR.
      ENDIF.

      MODIFY IT_STOCK TRANSPORTING UMLME_OLD MBLNR ZMSG ICON WHERE MATNR = IT_STOCK-MATNR
                                                    AND SLOCA = IT_STOCK-SLOCA
                                                    AND UMLME = IT_STOCK-UMLME.
    ENDLOOP.
  ELSE.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.
  DELETE IT_STOCK WHERE MARK IS INITIAL.
  PERFORM DISPLAY_RESULT.

ENDFORM.                    "PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_RESULT.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "DISPLAY_RESULT

*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_WT_FRZ  USING 'IT_STOCK' :
    'ICON'  ''  ''  ''  '6'  'Indicator' ''  ' ' ''   ,
    'MATNR'  ''  ''  ''  '15'  'Material Number' ''  ' ' ''  ,
    'MAKTX'  ''  ''  ''  '30'  'Material Description'  ''  ' ' '' ,
    'WERKS'  ''  ''  ''  '4'  'Plant' ''  ' ' ''   ,
    'SLOCA'  ''  ''  ''  '8'  'SLoc Asal'  ''  ' ' '' .
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_SO' :
   'SLOCT'  ''  ''  ''  '8'  'SLoc Tujuan' ''  ' ' '' ''  ,
    'UMLME'  ''  ''  ''  '10'  'Qty Transfer'  ''  ' ' '' '' ,
    'MBLNR'  ''  ''  ''  '15'  'Material Document'  ''  ' ' '' '' ,
    'ZMSG'  ''  ''  ''  '75'  'Message'  ''  ' ' '' ''.

ENDFORM.                    " f_field_catalog

*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
*  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-INFO_FIELDNAME    = 'COLOR'.
  WA_LAYOUT-COLTAB_FIELDNAME  = 'CELLCOLOR'.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IT_EVENTS                = T_EVENTS[]
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_EXCLUDING             = T_EXCLUDING[]
    TABLES
      T_OUTTAB                 = IT_STOCK
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " f_list_detail

*&---------------------------------------------------------------------*
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    "F_GUI_STATUS

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_STOCK' ITSELF
CONTROLS: TC_STOCK TYPE TABLEVIEW USING SCREEN 1100.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_STOCK'
DATA:     G_TC_STOCK_LINES  LIKE SY-LOOPC.
DATA:     OK_CODE LIKE SY-UCOMM.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_STOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_STOCK_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_STOCK LINES TC_STOCK-LINES.
ENDMODULE.                    "TC_STOCK_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_STOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TC_STOCK_GET_LINES OUTPUT.
  G_TC_STOCK_LINES = SY-LOOPC.
ENDMODULE.                    "TC_STOCK_GET_LINES OUTPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_STOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC_STOCK_MODIFY INPUT.
  MODIFY IT_STOCK INDEX TC_STOCK-CURRENT_LINE.
ENDMODULE.                    "TC_STOCK_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_STOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TC_STOCK_MARK INPUT.
  DATA: G_TC_STOCK_WA2 LIKE LINE OF IT_STOCK.
  IF TC_STOCK-LINE_SEL_MODE = 1 AND IT_STOCK-MARK = 'X'.
    LOOP AT IT_STOCK INTO G_TC_STOCK_WA2 WHERE MARK = 'X'.
      G_TC_STOCK_WA2-MARK = ''.
      MODIFY IT_STOCK FROM G_TC_STOCK_WA2 TRANSPORTING MARK.
    ENDLOOP.
  ENDIF.
  MODIFY IT_STOCK INDEX TC_STOCK-CURRENT_LINE TRANSPORTING MARK.
ENDMODULE.                    "TC_STOCK_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_STOCK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC_STOCK_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC_STOCK' 'IT_STOCK' 'MARK' CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TC_STOCK_USER_COMMAND INPUT

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM  P_TABLE_NAME P_MARK_NAME CHANGING P_OK LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME P_TABLE_NAME P_MARK_NAME   .
      CLEAR P_OK.
    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME P_TABLE_NAME P_MARK_NAME .
      CLEAR P_OK.
  ENDCASE.

ENDFORM.                              " USER_OK_TC


*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME P_TABLE_NAME P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.
*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME  P_TABLE_NAME P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.
*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines