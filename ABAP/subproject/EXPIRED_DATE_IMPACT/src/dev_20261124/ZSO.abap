*&---------------------------------------------------------------------*
*& Report  ZSO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSO.

INCLUDE ZABAPALV.

DATA: TAB_ITEMS_INX TYPE TABLE OF BAPISDITMX,
      WA_ITEMS_INX TYPE BAPISDITMX.

DATA: TAB_SCHEDULES_INX TYPE TABLE OF BAPISCHDLX,
      WA_SCHEDULES_INX TYPE BAPISCHDLX.

DATA: T_QUOTE_HEADER_IN TYPE BAPISDHD1 OCCURS 0 WITH HEADER LINE.

DATA: TAB_ITEMS TYPE TABLE OF BAPISDITM,
      WA_ITEM TYPE BAPISDITM.

DATA: TAB_ITEMS_SCHED TYPE TABLE OF BAPISCHDL,
      WA_ITEMS_SCHED TYPE BAPISCHDL.

DATA: TAB_QUOTE_REF TYPE TABLE OF BAPICUCFG,
      WA_QUOTE_REF LIKE LINE OF TAB_QUOTE_REF.

DATA: TAB_QUOTE_REFINST TYPE TABLE OF BAPICUREF,
      WA_QUOTE_REFINST TYPE BAPICUREF.

DATA: TAB_QUOTE_INST TYPE TABLE OF BAPICUINS,
      WA_QUOTE_INST LIKE LINE OF TAB_QUOTE_INST.

DATA: TAB_QUOTE_PARTOF TYPE TABLE OF BAPICUPRT,
      WA_QUOTE_PARTOF LIKE LINE OF TAB_QUOTE_PARTOF.

DATA: TAB_QUOTE_VALUE TYPE TABLE OF BAPICUVAL,
      WA_QUOTE_VALUE LIKE LINE OF TAB_QUOTE_VALUE.

DATA: WA_QUOTE_PARTNR TYPE BAPIPARNR,
      TAB_QUOTE_PARTNR TYPE TABLE OF BAPIPARNR.

DATA: TAB_QUOT_COND TYPE TABLE OF BAPICOND,
      WA_QUOT_COND  TYPE BAPICOND.

DATA: TAB_COND TYPE TABLE OF BAPICCCONDITIONITEM,
      WA_COND  TYPE BAPICCCONDITIONITEM.

DATA: RETURN  TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      RETURN2 TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE,
      WA_RETURN TYPE BAPIRET2.

DATA : IT_BAPICOND TYPE BAPICOND OCCURS 0 WITH HEADER LINE,
       IT_BAPICONDX TYPE BAPICONDX OCCURS 0 WITH HEADER LINE,
       IT_BAPISDITM TYPE BAPISDITM OCCURS 0 WITH HEADER LINE,
       IT_BAPISDITMX TYPE BAPISDITMX OCCURS 0 WITH HEADER LINE,
       IT_BAPISDH1X TYPE BAPISDH1X OCCURS 0 WITH HEADER LINE,
       IT_RETURN TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE.

DATA : IT_SCHDL TYPE TABLE OF BAPISCHDL,
       WA_SCHED TYPE BAPISCHDL OCCURS 0 WITH HEADER LINE  ,
       LT_SCHDLX TYPE TABLE OF BAPISCHDLX WITH HEADER LINE.

DATA : SALESORDERNUMBER TYPE VBELN.
DATA : IT_ENTRIES TYPE VTENTRIES OCCURS 0 WITH HEADER LINE.
DATA : IT_TEMP TYPE VTENTRIES OCCURS 0 WITH HEADER LINE.
DATA : WA_TEMP LIKE LINE OF IT_TEMP.

DATA : V_VTLINENO LIKE VTENTRIES-VTLINENO.
DATA : V_VTVALUE  LIKE VTENTRIES-VTVALUE.
DATA : V_THICK(10).

TYPES : BEGIN OF IT_ERROR,
         BOX(1),
         ICON(4),
         ID      LIKE BAPIRET2-ID,
         TYPE    LIKE BAPIRET2-TYPE,
         VBELN   LIKE LIKP-VBELN,
         NUMBER  LIKE BAPIRET2-NUMBER,
         ZPO(40),
         MESSAGE LIKE BAPIRET2-MESSAGE,
       END OF IT_ERROR.

DATA  :  IT_ERROR  TYPE IT_ERROR OCCURS 0 WITH HEADER LINE,
          WA_ERROR  LIKE LINE OF IT_ERROR.

DATA :
       ZWEIGHT TYPE P DECIMALS 3,
       ZROLL TYPE ATWTB,
       ZSATUAN(5) TYPE C,
       ZCONVERSIONROLLKG TYPE ATWTB,
       ZTOTALM2 TYPE ATWTB,
       ZORDERQTY TYPE ATWTB,
       ZMSG(100) TYPE C,
       ZITEM(3) TYPE C,
       ZTEMP TYPE P DECIMALS 2,
       IT_BASEUNIT TYPE T006 OCCURS 0.
TYPES : BEGIN OF TAB_QUOT,
          VBELN LIKE VBAK-VBELN,
        END OF TAB_QUOT.

DATA : TAB_QUOT TYPE TAB_QUOT OCCURS 0 WITH HEADER LINE.

TYPES : BEGIN OF ITAB,
          ZORDTYPE(10),
          ZSLSORG(10),
          ZDISTCHANEL(10),
          ZDIVISION(10),
          ZPO(35),
          ZSOITEM(5),
          ZSHPPOINT(100),
          ZSCHLINE(2),
          ZDLVDATE(10),
          ZCUST(20),
          ZSHIPH(20),
          ZPODATE(10),
          ZPOLINE(6),
          ZTYPE(75),
          ZTHICK(75),
          ZUOM(75),
          ZCORE(75),
          ZNOROLL(75),
          ZTYPLBL(75),
          ZTREAT(75),
          ZWIDTH(75),
          ZLENGTH(75),
          ZCRITERIA(75),
          ZEXTLENGTH(75),
          ZPACK(75),
          ZPRICE(75),
          ZCURR(75),
          ZUOMPRICE(75),
          ZNOPACK(75),
          ZSPACK(75),
          ZKDPACK(75),
          ZSPECIALTOUCH1(75),
          ZSPECIALTOUCH2(75),
          ZSPECIALTOUCH3(75),
          ZALIAS(75),
          ZCUSTMATNUM(100),
          ZORDREASON(100),
          ZFG(10),
          ZINOUT(1),
          ZINORDER(1),
          ZROUTE(6),
        END OF ITAB.

DATA : ITAB  TYPE ITAB OCCURS 0 WITH HEADER LINE,
       WA_ITAB LIKE LINE OF ITAB.
DATA : IT_DETAIL TYPE ITAB OCCURS 0 WITH HEADER LINE,
       WA_DETAIL LIKE LINE OF ITAB.

DATA : V_CONFIG LIKE BAPICUVAL-CONFIG_ID,
       V_DLVDATE(10),
       V_ZPO(20).

DATA : INST_ID          TYPE CHAR8 VALUE '00000001',
       OBJ_TYPE         TYPE CHAR4 VALUE 'MARA',
       CLASS_TYPE       VALUE 300,
       FNAME            TYPE STRING,
       FPATH            TYPE IBIPPARMS-PATH,
       N                TYPE I.

DATA : V_KUNNR LIKE KNA1-KUNNR.
DATA : V_KUNNR_SOLD LIKE KNA1-KUNNR.
DATA : V_KUNNR_SHIP LIKE KNA1-KUNNR.
DATA : V_KUNNR_SHIP_ITEM LIKE KNA1-KUNNR.
DATA : V_WAERS LIKE KNVV-WAERS.
DATA : V_MATNR LIKE MARA-MATNR,
       V_MATNR2 LIKE MARA-MATNR.
DATA : V_KTEXT(60).
DATA : V_VBELN LIKE VBUV-VBELN.

DATA:ZCUOBJ LIKE VBAP-CUOBJ,
     V_CUOBJ LIKE VBAP-CUOBJ,
     ZVBELN2 LIKE VBAK-VBELN,
     ZKGPERROL TYPE STRING,
     ZPENYEBUT TYPE STRING,
     ZPEMBILANG TYPE STRING,
     ZTOTALWEIGHT TYPE ATWTB,
     Z_TEXT1(30) ,
     Z_TEXT2(30),
     Z_WEIGHT(30),
     Z_WEIGHT1 LIKE VBAP-NTGEW,
     Z_WEIGHT2 TYPE P LENGTH 13 DECIMALS 4,
     Z_TOTAL TYPE P LENGTH 15 DECIMALS 3.

DATA : FLAG TYPE C.

DATA : IT_TEMP2 LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
       LEN TYPE I,
       V_RIB TYPE STRING,
       V_PUL TYPE STRING.

TYPES : BEGIN OF T_MSG,
          PONUM TYPE VBAK-BSTNK,
          ITEM TYPE VBAP-POSNR,
          MESSAGE TYPE BAPIRET2-MESSAGE,
       END OF T_MSG.

DATA : IT_MSG TYPE T_MSG OCCURS 0 WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
PARAMETER : P_SOURCE TYPE STRING.
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
  PERFORM CHECK_DATA.
  IF FLAG <> 'X'.
    PERFORM CREATE_SO.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA .
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = P_SOURCE
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB.
ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .

  LOOP AT ITAB INTO WA_ITAB.
    IF WA_ITAB-ZCORE EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Diameter Core'.
    ENDIF.

    IF WA_ITAB-ZWIDTH EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Lebar Roll'.
    ENDIF.

    IF WA_ITAB-ZLENGTH EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Panjang Roll'.
    ENDIF.

    IF WA_ITAB-ZTREAT EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Treatment Film'.
    ENDIF.

    IF WA_ITAB-ZCUST EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Sold to Party'.
    ENDIF.

    IF WA_ITAB-ZCUST EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Ship to Party'.
    ENDIF.

    IF WA_ITAB-ZFG EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Finish Good Indicator'.
    ENDIF.

    IF WA_ITAB-ZTYPE EQ '1'.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Tipe Film'.
    ENDIF.

    IF WA_ITAB-ZTHICK EQ ''.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Masukkan Thickness Film'.
    ENDIF.

    SELECT SINGLE KNA1~KUNNR INTO V_KUNNR_SOLD FROM KNA1 WHERE KNA1~KUNNR = WA_ITAB-ZCUST.
    IF SY-SUBRC > 0.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Sold to Party does not exist'.
    ELSE.
      SELECT SINGLE KNVV~WAERS INTO V_WAERS FROM KNVV WHERE KNVV~KUNNR = V_KUNNR_SOLD.
      IF SY-SUBRC > 0.
        PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Invalid Currency'.
      ENDIF.
    ENDIF.

    IF WA_ITAB-ZSHIPH EQ ''.
      WA_ITAB-ZSHIPH = WA_ITAB-ZCUST.
    ENDIF.

    SELECT SINGLE KNA1~KUNNR INTO V_KUNNR_SHIP FROM KNA1 WHERE KNA1~KUNNR = WA_ITAB-ZSHIPH.
    IF SY-SUBRC > 0.
      PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Ship to Party does not exist'.
    ENDIF.

    IF WA_ITAB-ZFG EQ '1'.
      CLEAR : IT_ENTRIES.
      REFRESH : IT_ENTRIES.
      CALL FUNCTION 'CARD_TABLE_READ_ENTRIES'
        EXPORTING
          VAR_TABLE       = 'ZZCODE'
        TABLES
          VAR_TAB_ENTRIES = IT_ENTRIES
        EXCEPTIONS
          ERROR           = 1
          OTHERS          = 2.


      DELETE IT_ENTRIES WHERE VTCHARACT = 'ZZEXPIREDLIVE'
                           OR VTCHARACT = 'ZZDENSITY'.
      IT_TEMP[] = IT_ENTRIES[].
      DELETE IT_ENTRIES WHERE VTVALUE NE WA_ITAB-ZTYPE.

      FIND '.' IN WA_ITAB-ZTHICK.
      IF SY-SUBRC NE 0.
        CONCATENATE WA_ITAB-ZTHICK '.0' INTO V_THICK.
        CONDENSE V_THICK NO-GAPS.
      ELSE.
        V_THICK = WA_ITAB-ZTHICK.
        CONDENSE V_THICK NO-GAPS.
      ENDIF.

      LOOP AT IT_ENTRIES.
        CLEAR : WA_TEMP.
        LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = IT_ENTRIES-VTLINENO
                                       AND VTCHARACT = 'ZZTHICKNESS'
                                       AND VTVALUE   = V_THICK.
          CLEAR : V_VTLINENO.
          V_VTLINENO = WA_TEMP-VTLINENO.
        ENDLOOP.
      ENDLOOP.

      CLEAR : WA_TEMP.
      LOOP AT IT_TEMP INTO WA_TEMP WHERE VTLINENO  = V_VTLINENO
                                     AND VTCHARACT = 'ZZCODE'.
        CLEAR : V_VTVALUE.
        V_VTVALUE = WA_TEMP-VTVALUE.
      ENDLOOP.

      CLEAR : V_MATNR, V_MATNR2.
      TRANSLATE WA_ITAB-ZINOUT TO UPPER CASE.

      IF WA_ITAB-ZINOUT EQ 'I'.
        CONCATENATE 'SR' V_VTVALUE 'I' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ELSEIF WA_ITAB-ZINOUT EQ 'O'.
        CONCATENATE 'SR' V_VTVALUE 'O' INTO V_MATNR.
        CONDENSE V_MATNR NO-GAPS.
      ENDIF.

      SELECT SINGLE MARA~MATNR
        INTO V_MATNR2
        FROM MARA
        WHERE MARA~MATNR = V_MATNR.

      IF SY-SUBRC <> 0.
        PERFORM FILLMSG USING WA_ITAB-ZPO WA_ITAB-ZSOITEM 'Material does not exist'.
      ENDIF.
    ENDIF.

    CLEAR : WA_ITAB.
  ENDLOOP.

  IF IT_MSG[] IS NOT INITIAL.
    FLAG = 'X'.
    MESSAGE 'Upload Error' TYPE 'I'.
    PERFORM F_FIELD_CATALOG_ERROR.
    PERFORM F_LAYOUT_ERROR.
    PERFORM F_LIST_DETAIL_ERROR.
  ENDIF.
ENDFORM.                    " CHECK_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_SO .
  IT_DETAIL[] = ITAB[].
  SORT ITAB BY ZPO.
  DELETE ADJACENT DUPLICATES FROM ITAB COMPARING ZPO.

  LOOP AT ITAB INTO WA_ITAB.
    CLEAR : T_QUOTE_HEADER_IN, TAB_QUOTE_PARTNR, RETURN, RETURN2, TAB_QUOT_COND.
    REFRESH : RETURN, RETURN2.
*   "START HEADER
    T_QUOTE_HEADER_IN-SALES_ORG  = WA_ITAB-ZSLSORG.
    T_QUOTE_HEADER_IN-DIVISION   = WA_ITAB-ZDIVISION.
    T_QUOTE_HEADER_IN-DISTR_CHAN = WA_ITAB-ZDISTCHANEL.
    T_QUOTE_HEADER_IN-PURCH_DATE = SY-DATUM.
    T_QUOTE_HEADER_IN-DOC_TYPE   = WA_ITAB-ZORDTYPE.
    T_QUOTE_HEADER_IN-PURCH_NO_C = WA_ITAB-ZPO.
    T_QUOTE_HEADER_IN-CURRENCY = WA_ITAB-ZCURR.
    T_QUOTE_HEADER_IN-ORD_REASON = WA_ITAB-ZORDREASON.
    PERFORM CHANGEDATE USING WA_ITAB-ZDLVDATE CHANGING  T_QUOTE_HEADER_IN-REQ_DATE_H.
    PERFORM CHANGEDATE USING WA_ITAB-ZPODATE CHANGING T_QUOTE_HEADER_IN-QT_VALID_T.
    APPEND T_QUOTE_HEADER_IN.
*   "END HEADER

*   "START PARTNER
    WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_ITAB-ZCUST.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.

    WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
    WA_QUOTE_PARTNR-PARTN_NUMB = WA_ITAB-ZSHIPH.
    APPEND WA_QUOTE_PARTNR TO TAB_QUOTE_PARTNR.
*   "END PARTNER

    CLEAR :  V_CONFIG.
    CLEAR : TAB_ITEMS, TAB_QUOTE_REF, TAB_QUOTE_REFINST, TAB_QUOTE_INST, TAB_QUOTE_VALUE, RETURN.

    LOOP AT IT_DETAIL INTO WA_DETAIL WHERE ZPO = WA_ITAB-ZPO.
      V_CONFIG = WA_DETAIL-ZSOITEM.
*     "START ITEM
      WA_ITEM-ITM_NUMBER = WA_DETAIL-ZSOITEM.
      WA_ITEM-PLANT = '2000'.
      WA_ITEM-MATERIAL  = V_MATNR.
      WA_ITEM-SHIP_POINT = WA_DETAIL-ZSHPPOINT.
      WA_ITEM-CUST_MAT35 = WA_DETAIL-ZCUSTMATNUM.
      WA_ITEM-SALES_UNIT = WA_DETAIL-ZUOM.
      IF WA_DETAIL-ZFG EQ '1'.
        WA_ITEM-ITEM_CATEG = 'ZP'.
      ELSEIF WA_DETAIL-ZFG EQ '0'.
        WA_ITEM-ITEM_CATEG = 'ZAGN'.
      ENDIF.
      WA_ITEM-PO_ITM_NO  = WA_DETAIL-ZSOITEM.
      WA_ITEM-TARGET_QTY = 1.
      APPEND WA_ITEM TO TAB_ITEMS.
*     "END ITEM

*     "START SCHEDULE LINE
      PERFORM CHANGEDATE USING WA_ITAB-ZDLVDATE CHANGING WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
      WA_ITEMS_SCHED-SCHED_LINE = 1.
      WA_ITEMS_SCHED-REQ_QTY    = 2000.
      PERFORM CHANGEDATE USING WA_ITAB-ZDLVDATE CHANGING WA_ITEMS_SCHED-DLV_DATE.
      APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.

      WA_SCHEDULES_INX-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
      WA_SCHEDULES_INX-SCHED_LINE = 1.
      WA_SCHEDULES_INX-REQ_QTY    = 'X'.
      WA_SCHEDULES_INX-REQ_DATE    = 'X'.
      WA_SCHEDULES_INX-DLV_DATE = 'X'.
      APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.

      PERFORM CHANGEDATE USING WA_ITAB-ZDLVDATE CHANGING WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
      WA_ITEMS_SCHED-SCHED_LINE = 1.
      WA_ITEMS_SCHED-REQ_QTY    = 2000.
      PERFORM CHANGEDATE USING WA_ITAB-ZDLVDATE CHANGING WA_ITEMS_SCHED-DLV_DATE.
      APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.

      WA_SCHEDULES_INX-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
      WA_SCHEDULES_INX-SCHED_LINE = 2.
      WA_SCHEDULES_INX-REQ_QTY    = 'X'.
      WA_SCHEDULES_INX-REQ_DATE    = 'X'.
      WA_SCHEDULES_INX-DLV_DATE = 'X'.
      APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.

*     "END SCHEDULE LINE

      IF WA_DETAIL-ZFG EQ '1'.
*     "START CONFIGURATION
        WA_QUOTE_REF-POSEX     = WA_DETAIL-ZSOITEM.
        WA_QUOTE_REF-ROOT_ID   = INST_ID.
        WA_QUOTE_REF-CONFIG_ID = V_CONFIG.
        APPEND WA_QUOTE_REF TO TAB_QUOTE_REF.
*     "END CONFIGURATION

*     "START REFINST
        WA_QUOTE_REFINST-POSEX     = WA_DETAIL-ZSOITEM.
        WA_QUOTE_REFINST-CONFIG_ID = V_CONFIG.
        WA_QUOTE_REFINST-INST_ID   = INST_ID.
        APPEND WA_QUOTE_REFINST TO TAB_QUOTE_REFINST.
*     "END REFINST

*        WA_QUOTE_INST-INST_ID    = INST_ID.
*        WA_QUOTE_INST-CONFIG_ID  = V_CONFIG.
*        WA_QUOTE_INST-OBJ_TYPE   = 'MARA'.
*        WA_QUOTE_INST-CLASS_TYPE = 300.
*        WA_QUOTE_INST-OBJ_KEY    = V_MATNR.
*        WA_QUOTE_INST-QUANTITY   = 2000.
*        INSERT WA_QUOTE_INST INTO TABLE TAB_QUOTE_INST.

*      "START ATTRIBUTE VALUES
        IF WA_DETAIL-ZTYPE NE ''.
          PERFORM FILL_CHAR USING 'ZZTYPE' WA_DETAIL-ZTYPE.
        ENDIF.

        IF WA_DETAIL-ZLENGTH NE ''.
          IF WA_DETAIL-ZUOM CS 'PAK'.
            PERFORM FILL_CHAR USING 'ZZLENGTHSHT' WA_DETAIL-ZLENGTH.
          ELSE.
            PERFORM FILL_CHAR USING 'ZZLENGTH' WA_DETAIL-ZLENGTH.
          ENDIF.
        ENDIF.

        IF WA_DETAIL-ZWIDTH NE ''.
          PERFORM FILL_CHAR USING 'ZZWIDTH' WA_DETAIL-ZWIDTH.
        ENDIF.

        IF WA_DETAIL-ZEXTLENGTH NE ''.
          PERFORM FILL_CHAR USING 'ZZEXLENGTH' WA_DETAIL-ZEXTLENGTH.
        ENDIF.

        "TYPE LABEL
        IF WA_DETAIL-ZTYPLBL NE ''.
          PERFORM FILL_CHAR USING 'ZZLABEL' WA_DETAIL-ZTYPLBL.
        ENDIF.

        "KODE PACK
        IF WA_DETAIL-ZKDPACK NE ''.
          PERFORM FILL_CHAR USING 'ZZPACKINGCODE' WA_DETAIL-ZKDPACK.
        ENDIF.

        IF WA_DETAIL-ZUOM CS 'PAK'.
          IF WA_DETAIL-ZNOPACK NE ''.
            PERFORM FILL_CHAR USING 'ZZNUMOFPACK' WA_DETAIL-ZNOPACK.
          ENDIF.

          IF WA_DETAIL-ZSPACK NE ''.
            PERFORM FILL_CHAR USING 'ZZNUMBEROFSHEET' WA_DETAIL-ZPACK.
          ENDIF.

        ELSEIF WA_DETAIL-ZUOM CS 'ROL' OR
               WA_DETAIL-ZUOM CS 'LB' OR
               WA_DETAIL-ZUOM CS 'M2' OR
               WA_DETAIL-ZUOM CS 'KG'.

          IF WA_DETAIL-ZNOROLL NE ''.
            PERFORM FILL_CHAR USING 'ZZNUMBEROFROLL' WA_DETAIL-ZNOROLL.
          ENDIF.

        ENDIF.

        IF WA_DETAIL-ZCORE NE ''.
          PERFORM FILL_CHAR USING 'ZZCORE' WA_DETAIL-ZCORE.
        ENDIF.

        "ALIAS
        IF WA_DETAIL-ZALIAS NE ''.
          PERFORM FILL_CHAR USING 'ZZALIAS' WA_DETAIL-ZALIAS.
        ENDIF.

*        IF ITAB2-ZSHPPOINT NE ''.
*          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
*          WA_QUOTE_VALUE-INST_ID   = INST_ID.
*          WA_QUOTE_VALUE-CHARC     = 'ZZALIAS'.
*          WA_QUOTE_VALUE-VALUE     = ITAB2-ZALIAS.
*          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
*        ENDIF.

        "specialtouch-1
        IF WA_DETAIL-ZSPECIALTOUCH1 NE ''.
          PERFORM FILL_CHAR USING 'ZZSPECIALTOUCH-1' WA_DETAIL-ZSPECIALTOUCH1.
        ENDIF.

        "specialtouch-2
        IF WA_DETAIL-ZSPECIALTOUCH2 NE ''.
          PERFORM FILL_CHAR USING 'ZZSPECIALTOUCH-2' WA_DETAIL-ZSPECIALTOUCH2.
        ENDIF.

        "specialtouch-3
        IF WA_DETAIL-ZSPECIALTOUCH3 NE ''.
          PERFORM FILL_CHAR USING 'ZZSPECIALTOUCH-3' WA_DETAIL-ZSPECIALTOUCH3.
        ENDIF.
        "AMMOUNT
*        IF ITAB2-ZAMOUNT NE ''.
*          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
*          WA_QUOTE_VALUE-INST_ID   = INST_ID.
*          WA_QUOTE_VALUE-CHARC     = 'ZZAMOUNT'.
*          WA_QUOTE_VALUE-VALUE     = ITAB2-ZAMOUNT.
*          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
*        ENDIF.

        IF WA_DETAIL-ZTREAT NE ''.
          PERFORM FILL_CHAR USING 'ZZTREATMENT' WA_DETAIL-ZTREAT.
        ENDIF.

        IF WA_DETAIL-ZPACK NE ''.
          PERFORM FILL_CHAR USING 'ZZPACKING' WA_DETAIL-ZPACK.
        ENDIF.

        IF WA_DETAIL-ZCRITERIA NE ''.
          PERFORM FILL_CHAR USING 'ZZCRITERIA' WA_DETAIL-ZCRITERIA.
        ENDIF.
*      "END ATTRIBUTE VALUES

*      "START AMOUNT
        IF WA_DETAIL-ZPRICE NE ''.
          CLEAR : WA_QUOT_COND.
          WA_QUOT_COND-COND_TYPE   = 'ZPRICE'.
*      WA_QUOT_COND-CURRENCY    = ITAB-ZPRICE.
          WA_QUOT_COND-COND_VALUE  = 100.
          WA_QUOT_COND-ITM_NUMBER  = V_CONFIG.
          APPEND WA_QUOT_COND TO TAB_QUOT_COND.
        ENDIF.
*     "END AMOUNT
      ENDIF.
    ENDLOOP.

    IF WA_DETAIL-ZPO NE ''.
      CALL FUNCTION 'SD_SALESDOCUMENT_CREATE'
        EXPORTING
*         SALESDOCUMENT           =
          SALES_HEADER_IN         = T_QUOTE_HEADER_IN
*         SALES_HEADER_INX        =
*         SENDER                  =
*         BINARY_RELATIONSHIPTYPE = ' '
*         INT_NUMBER_ASSIGNMENT   = ' '
*         BEHAVE_WHEN_ERROR       = ' '
*         LOGIC_SWITCH            = ' '
*         BUSINESS_OBJECT         = ' '
*         TESTRUN                 =
*         CONVERT_PARVW_AUART     = ' '
*         STATUS_BUFFER_REFRESH   = 'X'
*         CALL_ACTIVE             = ' '
        IMPORTING
          SALESDOCUMENT_EX        = SALESORDERNUMBER
*         SALES_HEADER_OUT        =
*         SALES_HEADER_STATUS     =
        TABLES
          RETURN                  = RETURN
          SALES_ITEMS_IN          = TAB_ITEMS
*         SALES_ITEMS_INX         =
          SALES_PARTNERS          = TAB_QUOTE_PARTNR
          SALES_SCHEDULES_IN      = TAB_ITEMS_SCHED
          SALES_SCHEDULES_INX     = TAB_SCHEDULES_INX
*         SALES_CONDITIONS_IN     = TAB_COND
*         SALES_CONDITIONS_INX    =
          SALES_CFGS_REF          = TAB_QUOTE_REF
          SALES_CFGS_INST         = TAB_QUOTE_INST
*         SALES_CFGS_PART_OF      =
          SALES_CFGS_VALUE        = TAB_QUOTE_VALUE
*         SALES_CFGS_BLOB         =
*         SALES_CFGS_VK           =
          SALES_CFGS_REFINST      = TAB_QUOTE_REFINST
*         SALES_CCARD             =
*         SALES_TEXT              =
*         SALES_KEYS              =
*         SALES_CONTRACT_IN       =
*         SALES_CONTRACT_INX      =
*         EXTENSIONIN             =
*         PARTNERADDRESSES        =
*         SALES_SCHED_CONF_IN     =
*         ITEMS_EX                =
*         SCHEDULE_EX             =
*         BUSINESS_EX             =
*         INCOMPLETE_LOG          =
*         EXTENSIONEX             =
*         CONDITIONS_EX           =
*         PARTNERS_EX             =
*         TEXTHEADERS_EX          =
*         TEXTLINES_EX            =
*         BATCH_CHARC             =
*         CAMPAIGN_ASGN           =
*         CONDITIONS_KONV_EX      =
        .

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      PERFORM CHANGE_SO.
    ENDIF.
    LOOP AT RETURN INTO WA_RETURN.
      IT_ERROR-TYPE    = WA_RETURN-TYPE.
      IT_ERROR-ID      = WA_RETURN-ID.
      IT_ERROR-NUMBER  = WA_RETURN-NUMBER.
      IT_ERROR-MESSAGE = WA_RETURN-MESSAGE.
      IT_ERROR-VBELN   = SALESORDERNUMBER.
      IT_ERROR-ZPO     = WA_DETAIL-ZPO.
      COLLECT IT_ERROR.
    ENDLOOP.

    LOOP AT IT_ERROR.
      IF IT_ERROR-TYPE EQ 'S' AND IT_ERROR-NUMBER NE '311'.
        DELETE IT_ERROR.
        CONTINUE.
      ENDIF.

      IF IT_ERROR-TYPE EQ 'E'.
        IT_ERROR-ICON = '@0A@'.
      ELSEIF IT_ERROR-TYPE EQ 'S'.
        IT_ERROR-ICON = '@08@'.
      ELSEIF IT_ERROR-TYPE EQ 'W'.
        IT_ERROR-ICON = '@09@'.
      ELSEIF IT_ERROR-TYPE EQ 'I'.
        IT_ERROR-ICON = '@08@'.
      ENDIF.
      MODIFY IT_ERROR.
    ENDLOOP.

    CLEAR : WA_DETAIL.
  ENDLOOP.
  PERFORM WRITE_ERROR.
ENDFORM.                    " CREATE_SO
*&---------------------------------------------------------------------*
*&      Form  CHANGE_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_SO .
  CLEAR ZCUOBJ.
  CLEAR IT_TEMP2.
  REFRESH IT_TEMP2.

  SELECT SINGLE VBAP~CUOBJ
        INTO V_CUOBJ
        FROM VBAP
        WHERE VBAP~VBELN = SALESORDERNUMBER
          AND VBAP~POSNR = WA_DETAIL-ZSOITEM.

  ZCUOBJ =  V_CUOBJ.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = ZCUOBJ
    TABLES
      CONFIGURATION       = IT_TEMP2
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.

  "Untuk Mencari Penyebut
  READ TABLE IT_TEMP2 WITH KEY ATNAM = 'ZZPENYEBUTBARU'.
  IF SY-SUBRC = 0.
  ENDIF.

  ZPENYEBUT = IT_TEMP2-ATWRT.

  IF ZPENYEBUT NE ''.
    SPLIT ZPENYEBUT AT SPACE INTO ZPENYEBUT Z_TEXT1.

    DATA : USR01_EXP LIKE USR01.
    DATA : RIBUAN   TYPE C,
           PULUHAN  TYPE C,
           VPUL     TYPE STRING,
           VRIB     TYPE STRING.

    CLEAR : USR01_EXP, RIBUAN, PULUHAN.
    CALL FUNCTION 'CETA_USR01_READ'
      EXPORTING
        BNAME     = SY-UNAME
      IMPORTING
        USR01_EXP = USR01_EXP
      EXCEPTIONS
        NO_ENTRY  = 1
        OTHERS    = 2.

    IF USR01_EXP-DCPFM EQ ''.
      RIBUAN  = '.'.
      PULUHAN = ','.
    ELSEIF USR01_EXP-DCPFM EQ 'X'.
      RIBUAN  = ','.
      PULUHAN = '.'.
    ELSEIF USR01_EXP-DCPFM EQ 'Y'.
      RIBUAN  = SPACE.
      PULUHAN = ','.
    ENDIF.

    REPLACE RIBUAN WITH '' INTO ZPENYEBUT.
    CONDENSE ZPENYEBUT NO-GAPS.
  ENDIF.

  " Untuk Mencari Pembilang
  READ TABLE IT_TEMP2 WITH KEY ATNAM = 'ZZPEMBILANGBARU'.
  IF SY-SUBRC = 0.
  ENDIF.

  ZPEMBILANG = IT_TEMP2-ATWRT.

  IF ZPEMBILANG NE ''.
    SPLIT ZPEMBILANG AT SPACE INTO ZPEMBILANG Z_TEXT2.

    CLEAR : USR01_EXP, RIBUAN, PULUHAN.
    CALL FUNCTION 'CETA_USR01_READ'
      EXPORTING
        BNAME     = SY-UNAME
      IMPORTING
        USR01_EXP = USR01_EXP
      EXCEPTIONS
        NO_ENTRY  = 1
        OTHERS    = 2.

    IF USR01_EXP-DCPFM EQ ''.
      RIBUAN  = '.'.
      PULUHAN = ','.
    ELSEIF USR01_EXP-DCPFM EQ 'X'.
      RIBUAN  = ','.
      PULUHAN = '.'.
    ELSEIF USR01_EXP-DCPFM EQ 'Y'.
      RIBUAN  = SPACE.
      PULUHAN = ','.
    ENDIF.

    REPLACE RIBUAN WITH '' INTO ZPEMBILANG.
    CONDENSE ZPEMBILANG NO-GAPS.
  ENDIF.

* RUMUS Diambil Dari Dependency
*   $SELF.ZZCONVERSIONROLLKG = ZZPEMBILANGBARU / ZZPENYEBUTBARU,
*
*   $SELF.ZZWEIGTHTOTAL = ZZNUMBEROFROLL * ZZCONVERSIONROLLKG

  DATA: ZPYBT(5) TYPE P DECIMALS 2,
        ZPBG(5) TYPE P DECIMALS 2,
        ZJMLROLL TYPE P,
        ZZCONV(5) TYPE P DECIMALS 2,
        ZZWEIGTHTOT(5) TYPE P DECIMALS 2.

  ZJMLROLL = WA_DETAIL-ZNOROLL.
  ZPYBT = ZPENYEBUT.
  ZPBG = ZPEMBILANG.
  ZZCONV = ZPBG / ZPYBT.
*      ZZWEIGTHTOT = ZJMLROLL * ZZCONV.

  CASE WA_DETAIL-ZUOM.
    WHEN 'KG'.
      ZZWEIGTHTOT = ZJMLROLL * ZZCONV.
    WHEN 'ROL'.
      ZZWEIGTHTOT = ZJMLROLL.
    WHEN 'M2'.
      READ TABLE IT_TEMP2 WITH KEY ATNAM = 'ZZTOTALM2'.
      SPLIT IT_TEMP2-ATWTB AT SPACE INTO ZTOTALM2 ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZTOTALM2 WITH SPACE.
      ZTEMP = ZTOTALM2.

      CALL FUNCTION 'ROUND'
        EXPORTING
          DECIMALS = 3
          INPUT    = ZTEMP
          SIGN     = '+'
        IMPORTING
          OUTPUT   = ZZWEIGTHTOT.
*    WHEN 'LB'.
*      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZORDERQTY'.
*      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZORDERQTY ZSATUAN.
*      ZWEIGHT = ZORDERQTY * ZROLL.
*    WHEN OTHERS.
*      ZWEIGHT = XVBAP-KWMENG.
  ENDCASE.

  PERFORM CHANGEDATE USING WA_DETAIL-ZDLVDATE CHANGING WA_ITEMS_SCHED-REQ_DATE.

*  IT_SCHDL-ITM_NUMBER  = V_POSNR.
*  WA_SCHED-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
*  WA_SCHED-SCHED_LINE = 1.
*  WA_SCHED-REQ_QTY    = ZZWEIGTHTOT.
*  INSERT WA_SCHED INTO TABLE IT_SCHDL.
**    APPEND WA_SCHED.
*
*  IT_BAPISDITM-ITM_NUMBER  = WA_DETAIL-ZSOITEM.
*  IT_BAPISDITM-MATERIAL  = V_MATNR.
*  APPEND IT_BAPISDITM.


  WA_SCHED-ITM_NUMBER = WA_DETAIL-ZSOITEM.
  WA_SCHED-SCHED_LINE  = '1'.
  WA_SCHED-REQ_QTY = ZZWEIGTHTOT.
  WA_SCHED-REQ_DATE = WA_ITEMS_SCHED-REQ_DATE.
  WA_SCHED-DATE_TYPE  = '1'.
  APPEND WA_SCHED.
  CLEAR WA_SCHED.

  LT_SCHDLX-ITM_NUMBER = WA_DETAIL-ZSOITEM.
  LT_SCHDLX-SCHED_LINE  = '1'.
  LT_SCHDLX-UPDATEFLAG = 'U'.
  LT_SCHDLX-REQ_QTY = 'X'.
  LT_SCHDLX-REQ_DATE = 'X'.
  APPEND LT_SCHDLX.
  CLEAR LT_SCHDLX.

*  WA_QUOTE_INST-INST_ID    = INST_ID.
*  WA_QUOTE_INST-CONFIG_ID  = V_CONFIG.
*  WA_QUOTE_INST-OBJ_TYPE   = 'MARA'.
*  WA_QUOTE_INST-CLASS_TYPE = 300.
*  WA_QUOTE_INST-OBJ_KEY    = V_MATNR.
*  WA_QUOTE_INST-QUANTITY   = ZZWEIGTHTOT.
*  INSERT WA_QUOTE_INST INTO TABLE TAB_QUOTE_INST.
  PERFORM UPLOAD_CHANGE.
ENDFORM.                    " CHANGE_SO
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_CHANGE .
  REFRESH : IT_BAPISDH1X, IT_RETURN, IT_SCHDL.

  IT_BAPISDH1X-UPDATEFLAG = 'U'.
  COLLECT IT_BAPISDH1X.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      SALESDOCUMENT    = SALESORDERNUMBER
      ORDER_HEADER_INX = IT_BAPISDH1X
    TABLES
      RETURN           = IT_RETURN
*     CONDITIONS_IN    = IT_BAPICOND
*     CONDITIONS_INX   = IT_BAPICONDX
*     ORDER_ITEM_IN    = IT_BAPISDITM
*     ORDER_ITEM_INX   = IT_BAPISDITMX
      SCHEDULE_LINESX  = LT_SCHDLX
      SCHEDULE_LINES   = WA_SCHED.
*      ORDER_CFGS_INST  = TAB_QUOTE_INST.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.
ENDFORM.                    " UPLOAD_CHANGE
*&---------------------------------------------------------------------*
*&      Form  FILL_CHAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CHAR       text
*      -->VALUE      text
*----------------------------------------------------------------------*
FORM FILL_CHAR USING CHAR TYPE BAPICUVAL-CHARC
                     VALUE TYPE ITAB-ZSPECIALTOUCH1.
  WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
  WA_QUOTE_VALUE-INST_ID   = INST_ID.
  WA_QUOTE_VALUE-CHARC     = CHAR.
  WA_QUOTE_VALUE-VALUE     = VALUE.
  APPEND WA_QUOTE_VALUE TO TAB_QUOTE_VALUE.
  CLEAR WA_QUOTE_VALUE.
ENDFORM.                    "FILL_CHAR
*&---------------------------------------------------------------------*
*&      Form  CHANGEDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INP      text
*      -->P_OUT      text
*----------------------------------------------------------------------*
FORM CHANGEDATE USING P_INP CHANGING P_OUT.
  CALL FUNCTION 'CONVERSION_EXIT_SDATE_INPUT'
    EXPORTING
      INPUT  = P_INP
    IMPORTING
      OUTPUT = P_OUT.
ENDFORM.                    "CHANGEDATE
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_ERROR .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_MSG' :
   'PONUM'    '' ''  '' '8'   'PO Number '          '' ' ' '' '',
   'ITEM'    '' ''  '' '6'   'Item '          '' ' ' '' '',
   'MESSAGE'      '' ''  '' '30'  'Message'     '' ' ' '' ''.
ENDFORM.                    "F_FIELD_CATALOG_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT_ERROR .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    "F_LAYOUT_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_ERROR .
  D_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = D_REPID
      IS_LAYOUT          = WA_LAYOUT
      IT_FIELDCAT        = T_FIELDCAT[]
    TABLES
      T_OUTTAB           = IT_MSG
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.                    "F_LIST_DETAIL_ERROR
*&---------------------------------------------------------------------*
*&      Form  FILLMSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO         text
*      -->ITEM       text
*      -->MESSAGE    text
*----------------------------------------------------------------------*
FORM FILLMSG USING PO TYPE ITAB-ZPO
                   ITEM TYPE ITAB-ZSOITEM
                   MESSAGE TYPE T_MSG-MESSAGE.
  IT_MSG-PONUM = PO.
  IT_MSG-ITEM = ITEM.
  IT_MSG-MESSAGE = MESSAGE.
  APPEND IT_MSG.
  CLEAR IT_MSG.
ENDFORM.                    "FILLMSG
*&---------------------------------------------------------------------*
*&      Form  WRITE_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_ERROR .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_ERROR' :
   'ICON'    '' ''  '' '4'   'Icon '          '' ' ' '' '',
   'TYPE'    '' ''  '' '6'   'Status '          '' ' ' '' '',
   'ID'      '' ''  '' '12'  'Message ID'     '' ' ' '' '',
   'VBELN'   '' ''  '' '20'  'SO Number' '' 'X' '' '',
   'NUMBER'  '' ''  '' '14'  'Message Number'   '' ' ' '' '',
   'ZPO'     '' ''  '' '20'  'PO Number'           '' ' ' '' '',
   'MESSAGE' '' ''  '' '100' 'Remaks'           '' ' ' '' ''.

  CLEAR WA_LAYOUT.
*  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-CELL_MERGE = 'X'.

  CLEAR: T_SORT.
  REFRESH: T_SORT.

  T_SORT-SPOS      = 1.
  T_SORT-FIELDNAME = 'ZPO'.
  T_SORT-UP = 'X'.
  APPEND T_SORT.

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
*     I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_ERROR'
*     I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_ERROR'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
*     IT_EVENTS                = T_EVENTS[]
*     IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_ERROR
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  D_REPID = SY-REPID.
ENDFORM.                    " WRITE_ERROR