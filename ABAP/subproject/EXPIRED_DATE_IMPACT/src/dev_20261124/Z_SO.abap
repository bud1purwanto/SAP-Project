*----------------------------------------------------------------------*
* Interface ZSD_UPLOAD_SO
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : Program Upload SO
*
* Application Area - SD
* ABAPer           - Whika Yudha Sasita
* Date             - June 30, 2016
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*----------------------------------------------------------------------*
REPORT Z_SO.

INCLUDE ZABAPALV.

DATA: T_QUOTE_HEADER_IN TYPE BAPISDHD1.

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

DATA: IT_BAPICOND TYPE BAPICOND OCCURS 0 WITH HEADER LINE,
      IT_BAPICONDX TYPE BAPICONDX OCCURS 0 WITH HEADER LINE,
      IT_BAPISDITM TYPE BAPISDITM OCCURS 0 WITH HEADER LINE,
      IT_BAPISDITMX TYPE BAPISDITMX OCCURS 0 WITH HEADER LINE,
      IT_BAPISDH1X TYPE BAPISDH1X OCCURS 0 WITH HEADER LINE,
      IT_RETURN TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE.

DATA: IT_SCHDL TYPE TABLE OF BAPISCHDL,
      WA_SCHED TYPE BAPISCHDL OCCURS 0 WITH HEADER LINE  ,
      LT_SCHDLX TYPE TABLE OF BAPISCHDLX WITH HEADER LINE.

DATA: SALESORDERNUMBER TYPE VBELN,
      IT_ENTRIES TYPE VTENTRIES OCCURS 0 WITH HEADER LINE,
      IT_TEMP TYPE VTENTRIES OCCURS 0 WITH HEADER LINE,
      WA_TEMP LIKE LINE OF IT_TEMP.

DATA: V_VTLINENO LIKE VTENTRIES-VTLINENO,
      V_VTVALUE  LIKE VTENTRIES-VTVALUE,
      V_THICK(10).
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

DATA:  IT_ERROR  TYPE IT_ERROR OCCURS 0 WITH HEADER LINE,
       WA_ERROR  LIKE LINE OF IT_ERROR.

DATA: ZWEIGHT TYPE P DECIMALS 3,
      ZROLL TYPE ATWTB,
      ZSATUAN(5) TYPE C,
      ZCONVERSIONROLLKG TYPE ATWTB,
      ZTOTALM2 TYPE ATWTB,
      ZORDERQTY TYPE ATWTB,
      ZMSG(100) TYPE C,
      ZITEM(3) TYPE C,
      ZTEMP TYPE P DECIMALS 2,
      IT_BASEUNIT TYPE T006 OCCURS 0.

TYPES: BEGIN OF TAB_SO,
          VBELN LIKE VBAK-VBELN,
        END OF TAB_SO.

DATA : TAB_SO TYPE TAB_SO OCCURS 0 WITH HEADER LINE.

TYPES : BEGIN OF ITAB,
          ZORDTYPE(10),
          ZSLSORG(10),
          ZDISTCHANEL(10),
          ZDIVISION(10),
          ZPO(35),
          ZSOITEM(10),
          ZSHPPOINT(100),
          ZSCHLINE(2),
          ZDLVDATE(10),
          ZCUST(20),
          ZSHIPH(20),
          ZPODATE(10),
          ZPOLINE(6),
          ZTYPE(10),
          ZTHICK(10),
          ZUOM(20),
          ZCORE(10),
          ZNOROLL(10),
          ZTYPLBL(10),
          ZTREAT(10),
          ZWIDTH(20),
          ZLENGTH(10),
          ZCRITERIA(10),
          ZEXTLENGTH(100),
          ZPACK(10),
          ZPRICE(20),
          ZCURR(10),
          ZUOMPRICE(90),
          ZNOPACK(13),
          ZSPACK(13),
          ZKDPACK(13),
          ZSPECIALTOUCH1(75),
          ZSPECIALTOUCH2(75),
          ZSPECIALTOUCH3(75),
          ZALIAS(50),
          ZCUSTMATNUM(100),
          ZORDREASON(100),
          ZFG(10),
          ZINOUT(1),
          ZINORDER(1),
          ZROUTE(6),
        END OF ITAB.

DATA : ITAB  TYPE ITAB OCCURS 0 WITH HEADER LINE.
DATA : ITAB2 TYPE ITAB OCCURS 0 WITH HEADER LINE.
DATA : WA_ITAB LIKE LINE OF ITAB.

DATA : V_POSNR  LIKE LIPS-POSNR,
       V_CONFIG LIKE BAPICUVAL-CONFIG_ID,
       V_DLVDATE(10),
       V_ZPO(20).

DATA : INST_ID          TYPE CHAR8 VALUE '00000001',
       OBJ_TYPE         TYPE CHAR4 VALUE 'MARA',
       CLASS_TYPE       VALUE 300,
       FNAME            TYPE STRING,
       FPATH            TYPE IBIPPARMS-PATH,
       DD               TYPE C LENGTH 2,
       MM               TYPE C LENGTH 2,
       YYYY             TYPE C LENGTH 4,
       N                TYPE I.

DATA : V_KUNNR LIKE KNA1-KUNNR.
DATA : V_KUNNR_SOLD LIKE KNA1-KUNNR.
DATA : V_KUNNR_SHIP LIKE KNA1-KUNNR.
DATA : V_KUNNR_SHIP_ITEM LIKE KNA1-KUNNR.
DATA : V_KUNNR2 LIKE KNA1-KUNNR.
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

DATA: FLAG TYPE C.

DATA: IT_TEMP2 LIKE CONF_OUT OCCURS 0 WITH HEADER LINE,
       LEN TYPE I,
       V_RIB TYPE STRING,
       V_PUL TYPE STRING.

TYPES: BEGIN OF T_MSG,
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
FORM CREATE_SO.
  LOOP AT ITAB.
    CLEAR : T_QUOTE_HEADER_IN, TAB_QUOTE_PARTNR, RETURN, RETURN2, WA_ITAB, TAB_QUOT_COND.
    REFRESH : RETURN, RETURN2.

    IF ITAB-ZCORE EQ ''.
      MESSAGE 'Masukkan Diamter Core' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZWIDTH EQ ''.
      MESSAGE 'Masukkan Lebar Roll' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZLENGTH EQ ''.
      MESSAGE 'Masukkan Panjang Roll' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZTREAT EQ ''.
      MESSAGE 'Masukkan Treatment Film' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZCUST EQ ''.
      MESSAGE 'Masukkan Sold To Party' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZCUST EQ ''.
      MESSAGE 'Masukkan Ship To Party' TYPE 'E'.
      EXIT.
    ENDIF.

*    IF ITAB-ZFG EQ ''.
*      MESSAGE 'Masukkan Finish Good Indicator' TYPE 'E'.
*      EXIT.
*    ENDIF.

    IF ITAB-ZTYPE EQ '1'.
      IF ITAB-ZTYPE EQ ''.
        MESSAGE 'Masukkan Type Film' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-ZTHICK EQ ''.
        MESSAGE 'Masukkan Thickness Film' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDIF.

    CLEAR : V_ZPO.
    V_ZPO = ITAB-ZPO.

    READ TABLE ITAB INDEX SY-TABIX INTO WA_ITAB.
    IF SY-SUBRC = 0.
      V_DLVDATE = WA_ITAB-ZDLVDATE.
    ENDIF.

    ITAB2[] = ITAB[].
    DELETE ADJACENT DUPLICATES FROM ITAB COMPARING ZPO.
    T_QUOTE_HEADER_IN-SALES_ORG  = ITAB-ZSLSORG.
    T_QUOTE_HEADER_IN-DIVISION   = ITAB-ZDIVISION.
    T_QUOTE_HEADER_IN-DISTR_CHAN = ITAB-ZDISTCHANEL.
    T_QUOTE_HEADER_IN-PURCH_DATE = SY-DATUM.
    T_QUOTE_HEADER_IN-DOC_TYPE   = ITAB-ZORDTYPE.

    IF ITAB-ZPO NE ''.
**      TRANSLATE ITAB-ZPO TO UPPER CASE.
      T_QUOTE_HEADER_IN-PURCH_NO_C = ITAB-ZPO.
    ENDIF.

    CLEAR : DD, MM, YYYY.
    SPLIT V_DLVDATE AT '.' INTO DD MM YYYY.
    CONCATENATE YYYY MM DD INTO T_QUOTE_HEADER_IN-REQ_DATE_H.

    IF ITAB-ZPODATE NE ''.
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB-ZPODATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO T_QUOTE_HEADER_IN-QT_VALID_T.
    ENDIF.

    IF ITAB-ZCUST NE ''.
      CLEAR : V_KUNNR_SOLD, WA_QUOTE_PARTNR.
      SELECT SINGLE KNA1~KUNNR
        INTO V_KUNNR_SOLD
        FROM KNA1
        WHERE KNA1~KUNNR = ITAB-ZCUST.

      WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
      WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SOLD.
      INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
    ENDIF.

    "sold to party
    IF ITAB-ZCUST NE ''.
      CLEAR : V_KUNNR_SOLD, WA_QUOTE_PARTNR.
      SELECT SINGLE KNA1~KUNNR
        INTO V_KUNNR_SOLD
        FROM KNA1
        WHERE KNA1~KUNNR = ITAB-ZCUST.

      WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
      WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SOLD.
      INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
    ENDIF.

    "ship to party
    IF ITAB-ZSHIPH NE ''.
      IF ITAB-ZSHIPH NE ITAB-ZCUST.
        CLEAR : V_KUNNR_SHIP, WA_QUOTE_PARTNR.
        SELECT SINGLE KNA1~KUNNR
          INTO V_KUNNR_SHIP
          FROM KNA1
          WHERE KNA1~KUNNR = ITAB-ZSHIPH.

        WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
        WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SHIP.
        INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
      ENDIF.
    ELSE.
      V_KUNNR_SHIP = V_KUNNR_SOLD.
    ENDIF.

    "po date
    IF ITAB-ZPODATE NE ''.
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB-ZPODATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO T_QUOTE_HEADER_IN-QT_VALID_T.
    ENDIF.

    "- Currency
    IF ITAB-ZCURR NE ''.
      TRANSLATE ITAB-ZCURR TO UPPER CASE.
      IF ITAB-ZCURR CS 'USD'.
        ITAB-ZCURR = 'USD'.
      ELSEIF ITAB-ZCURR CS 'JPY'.
        ITAB-ZCURR = 'JPY'.
      ELSEIF ITAB-ZCURR CS 'IDR'.
        ITAB-ZCURR = 'IDR'.
      ELSEIF ITAB-ZCURR CS 'EUR'.
        ITAB-ZCURR = 'EUR'.
      ELSEIF ITAB-ZCURR CS 'SGD'.
        ITAB-ZCURR = 'SGD'.
      ELSEIF ITAB-ZCURR CS 'GBP'.
        ITAB-ZCURR = 'GBP'.
      ENDIF.
    ENDIF.

    SELECT SINGLE KNVV~WAERS
      INTO V_WAERS
      FROM KNVV
      WHERE KNVV~KUNNR = V_KUNNR_SOLD.

    IF V_WAERS NE ITAB-ZCURR.
      T_QUOTE_HEADER_IN-CURRENCY = ITAB-ZCURR.
    ENDIF.

    IF ITAB-ZORDREASON NE ''.
*      TRANSLATE ITAB-ZORDREASON TO UPPER CASE.
      T_QUOTE_HEADER_IN-ORD_REASON = ITAB-ZORDREASON.
    ENDIF.

    CLEAR : V_POSNR, V_CONFIG.
    CLEAR : TAB_ITEMS, TAB_QUOTE_REF, TAB_QUOTE_REFINST, TAB_QUOTE_INST, TAB_QUOTE_VALUE, RETURN.
    LOOP AT ITAB2 WHERE ZPO = ITAB-ZPO.

      V_CONFIG = ITAB2-ZSOITEM..
      V_POSNR  = ITAB2-ZSOITEM.

      "- FILL ITEMS
      WA_ITEM-ITM_NUMBER = V_POSNR.
      WA_ITEM-PLANT      = '2000'.


      "- Mencari Material
      IF ITAB2-ZFG EQ '1'.
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

        DELETE IT_ENTRIES WHERE VTVALUE NE ITAB2-ZTYPE.

        FIND '.' IN ITAB2-ZTHICK.
        IF SY-SUBRC NE 0.
          CONCATENATE ITAB2-ZTHICK '.0' INTO V_THICK.
          CONDENSE V_THICK NO-GAPS.
        ELSE.
          V_THICK = ITAB2-ZTHICK.
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
        TRANSLATE ITAB2-ZINOUT TO UPPER CASE.

        IF ITAB2-ZINOUT EQ 'I'.
          CONCATENATE 'SR' V_VTVALUE 'I' INTO V_MATNR.
          CONDENSE V_MATNR NO-GAPS.
        ELSEIF ITAB2-ZINOUT EQ 'O'.
          CONCATENATE 'SR' V_VTVALUE 'O' INTO V_MATNR.
          CONDENSE V_MATNR NO-GAPS.
        ENDIF.

        SELECT SINGLE MARA~MATNR
          INTO V_MATNR2
          FROM MARA
          WHERE MARA~MATNR = V_MATNR.

        IF SY-SUBRC <> 0.
          MESSAGE 'Material does not exist' TYPE 'E'.
          EXIT.
        ENDIF.

        WA_ITEM-MATERIAL  = V_MATNR.
      ELSEIF ITAB2-ZFG EQ '0'.
*        WA_ITEM-MATERIAL  = ITAB2-ZRAW.
      ENDIF.
      " End Mencari Material

      "- Route
*      WA_ITEM-ROUTE = ITAB2-ZROUTE.

      "shipping Point
      WA_ITEM-SHIP_POINT = ITAB2-ZSHPPOINT.

      "Customer material number
      WA_ITEM-CUST_MAT35 = ITAB2-ZCUSTMATNUM.
      "- Incoterm Item
*      WA_ITEM-INCOTERMS1 = ITAB2-ZINCO3.

*      DATA: ZINCO4 TYPE KNVV-INCO2.

      "- Edit by PST_MONICA 27.02.2013

*      IF ITAB-ZINCO3 IS NOT INITIAL.
*       SELECT SINGLE KNVV~INCO2 INTO (ZINCO4)
*         FROM KNVV
*         WHERE KNVV~KUNNR = V_KUNNR_SHIP.
*      ENDIF.
*      WA_ITEM-INCOTERMS2 = ITAB-ZINCO2.

      IF ITAB2-ZUOM NE ''.
        TRANSLATE ITAB2-ZUOM TO UPPER CASE.
        IF ITAB2-ZUOM CS 'KG'.
          ITAB2-ZUOM = 'KG'.
          WA_ITEM-SALES_UNIT = 'KG'.
        ELSEIF ITAB2-ZUOM CS 'LB'.
          ITAB2-ZUOM = 'LB'.
          WA_ITEM-SALES_UNIT = 'LB'.
        ELSEIF ITAB2-ZUOM CS 'PC'.
          ITAB2-ZUOM = 'PC'.
          WA_ITEM-SALES_UNIT = 'PC'.
        ELSEIF ITAB2-ZUOM CS 'SH'.
          ITAB2-ZUOM = 'SH'.
          WA_ITEM-SALES_UNIT = 'SH'.
        ELSEIF ITAB2-ZUOM CS 'M2'.
          ITAB2-ZUOM = 'M2'.
          WA_ITEM-SALES_UNIT = 'M2'.
        ELSEIF ITAB2-ZUOM CS 'ROL'.
          ITAB2-ZUOM = 'ROL'.
          WA_ITEM-SALES_UNIT = 'ROL'.
        ELSEIF ITAB2-ZUOM CS 'PAC'.
          ITAB2-ZUOM = 'PAK'.
          WA_ITEM-SALES_UNIT = 'PAK'.
        ENDIF.
      ENDIF.


*      IF ITAB2-ZUOMPRICE NE ''.
*        TRANSLATE ITAB2-ZUOMPRICE TO UPPER CASE.
*        IF ITAB2-ZUOMPRICE CS 'KG'.
*          ITAB2-ZUOMPRICE = 'KG'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'LB'.
*          ITAB2-ZUOMPRICE = 'LB'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'PC'.
*          ITAB2-ZUOMPRICE = 'PC'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'SH'.
*          ITAB2-ZUOMPRICE = 'SH'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'M2'.
*          ITAB2-ZUOMPRICE = 'M2'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'ROL'.
*          ITAB2-ZUOMPRICE = 'ROL'.
*        ELSEIF ITAB2-ZUOMPRICE CS 'PAC'.
*          ITAB2-ZUOMPRICE = 'PAK'.
*        ELSE.
*          MESSAGE 'Uom price does not exist' TYPE 'E'.
*        ENDIF.
*      ENDIF.
*      MODIFY ITAB2.

      IF ITAB2-ZFG NE ''.
        IF ITAB2-ZFG EQ '1'.
*          WA_ITEM-ITEM_CATEG = 'ZAGC'. "QUOTATION
          WA_ITEM-ITEM_CATEG = 'ZP'.
        ELSEIF ITAB2-ZFG EQ '0'.
          WA_ITEM-ITEM_CATEG = 'ZAGN'.
        ENDIF.
      ENDIF.

      WA_ITEM-PO_ITM_NO  = V_POSNR.
      WA_ITEM-TARGET_QTY = 1.
      INSERT WA_ITEM INTO TABLE TAB_ITEMS.

      "- SCHEDULE LINE
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB2-ZDLVDATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-ITM_NUMBER  = V_POSNR.
      WA_ITEMS_SCHED-SCHED_LINE = 1.
      WA_ITEMS_SCHED-REQ_QTY    = 2000.
      INSERT WA_ITEMS_SCHED INTO TABLE TAB_ITEMS_SCHED.


      IF WA_QUOT_COND-COND_TYPE EQ 'ZD00' AND  WA_QUOT_COND-ITM_NUMBER NE '000000'.
        WA_QUOT_COND-CURRENCY    = ITAB2-ZCURR.
        INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
      ENDIF.

      IF ITAB2-ZFG EQ '1'.
        "- CREATE CONFIGURATION
        WA_QUOTE_REF-POSEX     = V_POSNR.
        WA_QUOTE_REF-ROOT_ID   = INST_ID.
        WA_QUOTE_REF-CONFIG_ID = V_CONFIG.
        INSERT WA_QUOTE_REF INTO TABLE TAB_QUOTE_REF.

        "- REFINST
        WA_QUOTE_REFINST-POSEX     = V_POSNR.
        WA_QUOTE_REFINST-CONFIG_ID = V_CONFIG.
        WA_QUOTE_REFINST-INST_ID   = INST_ID.
        INSERT WA_QUOTE_REFINST INTO TABLE TAB_QUOTE_REFINST.

*        WA_QUOTE_INST-INST_ID    = INST_ID.
*        WA_QUOTE_INST-CONFIG_ID  = V_CONFIG.
*        WA_QUOTE_INST-OBJ_TYPE   = 'MARA'.
*        WA_QUOTE_INST-CLASS_TYPE = 300.
*        WA_QUOTE_INST-OBJ_KEY    = V_MATNR.
*        WA_QUOTE_INST-QUANTITY   = 2000.
*        INSERT WA_QUOTE_INST INTO TABLE TAB_QUOTE_INST.

        "- ATTRIBUTE VALUES
        IF ITAB2-ZTYPE NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZTYPE'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZTYPE.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.


        IF ITAB2-ZLENGTH NE ''.
          IF ITAB2-ZUOM CS 'PAK'.
            WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
            WA_QUOTE_VALUE-INST_ID   = INST_ID.
            WA_QUOTE_VALUE-CHARC     = 'ZZLENGTHSHT'.
            WA_QUOTE_VALUE-VALUE     = ITAB2-ZLENGTH.
            INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
          ELSE.
            WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
            WA_QUOTE_VALUE-INST_ID   = INST_ID.
            WA_QUOTE_VALUE-CHARC     = 'ZZLENGTH'.
            WA_QUOTE_VALUE-VALUE     = ITAB2-ZLENGTH.
            INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
          ENDIF.

        ENDIF.

        IF ITAB2-ZWIDTH NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZWIDTH'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZWIDTH.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        IF ITAB2-ZEXTLENGTH NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZEXLENGTH'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZEXTLENGTH.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.


        "amount
        IF ITAB2-ZPRICE NE ''.
          CLEAR : WA_QUOT_COND.
          WA_QUOT_COND-COND_TYPE   = 'ZPRICE'.
*      WA_QUOT_COND-CURRENCY    = ITAB-ZPRICE.
          WA_QUOT_COND-COND_VALUE  = 100.
          WA_QUOT_COND-ITM_NUMBER  = V_CONFIG.
          INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
        ENDIF.

        "TYPE LABEL
        IF ITAB2-ZTYPLBL NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZLABEL'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZTYPLBL.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        "KODE PACK
        IF ITAB2-ZKDPACK NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZPACKINGCODE'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZKDPACK.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        IF ITAB2-ZUOM CS 'PAK'.
          IF ITAB2-ZNOPACK NE ''.
            WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
            WA_QUOTE_VALUE-INST_ID   = INST_ID.
            WA_QUOTE_VALUE-CHARC     = 'ZZNUMOFPACK'.
            WA_QUOTE_VALUE-VALUE     = ITAB2-ZNOPACK.
            INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
          ENDIF.

          IF ITAB2-ZSPACK NE ''.
            WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
            WA_QUOTE_VALUE-INST_ID   = INST_ID.
            WA_QUOTE_VALUE-CHARC     = 'ZZNUMBEROFSHEET'.
            WA_QUOTE_VALUE-VALUE     = ITAB2-ZSPACK.
            INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
          ENDIF.

        ELSEIF ITAB2-ZUOM CS 'ROL' OR
               ITAB2-ZUOM CS 'LB' OR
               ITAB2-ZUOM CS 'M2' OR
               ITAB2-ZUOM CS 'KG'.

          IF ITAB2-ZNOROLL NE ''.
            WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
            WA_QUOTE_VALUE-INST_ID   = INST_ID.
            WA_QUOTE_VALUE-CHARC     = 'ZZNUMBEROFROLL'.
            WA_QUOTE_VALUE-VALUE     = ITAB2-ZNOROLL.
            INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
          ENDIF.

        ENDIF.

        IF ITAB2-ZCORE NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZCORE'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZCORE.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        "ALIAS
        IF ITAB2-ZALIAS NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZALIAS'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZALIAS.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

*        IF ITAB2-ZSHPPOINT NE ''.
*          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
*          WA_QUOTE_VALUE-INST_ID   = INST_ID.
*          WA_QUOTE_VALUE-CHARC     = 'ZZALIAS'.
*          WA_QUOTE_VALUE-VALUE     = ITAB2-ZALIAS.
*          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
*        ENDIF.

        "specialtouch-1
        IF ITAB2-ZSPECIALTOUCH1 NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZSPECIALTOUCH-1'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZSPECIALTOUCH1.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        "specialtouch-2
        IF ITAB2-ZSPECIALTOUCH2 NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZSPECIALTOUCH-2'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZSPECIALTOUCH1.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.


        "specialtouch-3
        IF ITAB2-ZSPECIALTOUCH3 NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZSPECIALTOUCH-3'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZSPECIALTOUCH3.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.
        "AMMOUNT
*        IF ITAB2-ZAMOUNT NE ''.
*          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
*          WA_QUOTE_VALUE-INST_ID   = INST_ID.
*          WA_QUOTE_VALUE-CHARC     = 'ZZAMOUNT'.
*          WA_QUOTE_VALUE-VALUE     = ITAB2-ZAMOUNT.
*          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
*        ENDIF.

        IF ITAB2-ZTREAT NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZTREATMENT'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZTREAT.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        IF ITAB2-ZPACK NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZPACKING'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZPACK.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

        IF ITAB2-ZCRITERIA NE ''.
          WA_QUOTE_VALUE-CONFIG_ID = V_CONFIG.
          WA_QUOTE_VALUE-INST_ID   = INST_ID.
          WA_QUOTE_VALUE-CHARC     = 'ZZCRITERIA'.
          WA_QUOTE_VALUE-VALUE     = ITAB2-ZCRITERIA.
          INSERT WA_QUOTE_VALUE INTO TABLE TAB_QUOTE_VALUE.
        ENDIF.

      ENDIF.

    ENDLOOP.


    IF ITAB-ZPO NE ''.
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
*         SALES_SCHEDULES_INX     =
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
*      PERFORM CHANGE_SO.
    ENDIF.
  ENDLOOP.
  PERFORM WRITE_ERROR.

ENDFORM.                    "CREATE_QUOT
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