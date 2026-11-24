*&---------------------------------------------------------------------*
*&  Include           ZSDI_UP_QUOT_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  CREATE_QUOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*INCLUDE ZABAPALV.

FORM CREATE_QUOT .

  ITAB2[] = ITAB[].
  DELETE ADJACENT DUPLICATES FROM ITAB COMPARING ZPO.

  LOOP AT ITAB.
    CLEAR : T_QUOTE_HEADER_IN, TAB_QUOTE_PARTNR, RETURN, RETURN2, WA_ITAB, TAB_QUOT_COND.
    REFRESH : RETURN, RETURN2.

    IF ITAB-ZVKORG NE '6500'. "ADD FOR NEW COMPANY
      MESSAGE 'Sales Organization is Does Not Exist on TTE!' TYPE 'I' .
      LEAVE SCREEN.
    ENDIF.

    IF ITAB-ZUOM EQ ''.
      MESSAGE 'Masukkan UOM' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZCURR EQ ''.
      MESSAGE 'Masukkan Currency' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZCUST EQ ''.
      MESSAGE 'Masukkan Customer Search Term' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZROUTE EQ ''.
      MESSAGE 'Masukkan Route' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZPRICE EQ ''.
      MESSAGE 'Masukkan Unit Price' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZUOMPRICE EQ ''.
      MESSAGE 'Masukkan UOM Price' TYPE 'E'.
      EXIT.
    ENDIF.


    IF ITAB-ZFG EQ ''.
      MESSAGE 'Masukkan Finish Good Indicator' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZFG EQ '1'.
      IF ITAB-ZTYPE EQ ''.
        MESSAGE 'Masukkan Type Film' TYPE 'E'.
        EXIT.
      ENDIF.

      IF ITAB-ZTHICK EQ ''.
        MESSAGE 'Masukkan Thickness Film' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDIF.

    IF ITAB-ZINOUT EQ ''.
      MESSAGE 'Masukkan Inhouse Indicator' TYPE 'E'.
      EXIT.
    ENDIF.

    CLEAR : V_ZPI.
    V_ZPI = ITAB-ZPI.


    READ TABLE ITAB INDEX SY-TABIX INTO WA_ITAB.
    IF SY-SUBRC = 0.
      V_DLVDATE = WA_ITAB-ZDLVDATE.
    ENDIF.

    T_QUOTE_HEADER_IN-SALES_ORG  = '6500'.
    T_QUOTE_HEADER_IN-DIVISION   = '00'.
    T_QUOTE_HEADER_IN-DISTR_CHAN = '02'.
    T_QUOTE_HEADER_IN-PURCH_DATE = SY-DATUM.
    T_QUOTE_HEADER_IN-DOC_TYPE   = 'ZEQT'.

    IF ITAB-ZPO NE ''.
**      TRANSLATE ITAB-ZPO TO UPPER CASE.
      T_QUOTE_HEADER_IN-PURCH_NO_C = ITAB-ZPO.
    ENDIF.

    CLEAR : DD, MM, YYYY.
    SPLIT V_DLVDATE AT '.' INTO DD MM YYYY.
    CONCATENATE YYYY MM DD INTO T_QUOTE_HEADER_IN-REQ_DATE_H.

    IF ITAB-ZLC NE ''.
      TRANSLATE ITAB-ZLC TO UPPER CASE.
      T_QUOTE_HEADER_IN-ORD_REASON = ITAB-ZLC.
    ENDIF.

    IF ITAB-ZPIDATE NE ''.
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB-ZPIDATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO T_QUOTE_HEADER_IN-QT_VALID_T.
    ENDIF.

    IF T_QUOTE_HEADER_IN-QT_VALID_T < SY-DATUM.
      MESSAGE 'Cek Tanggal PI Kembali (Valid To)' TYPE 'E'.
      EXIT.
    ENDIF.

    IF ITAB-ZINCO1 NE ''.
      TRANSLATE ITAB-ZINCO1 TO UPPER CASE.
      T_QUOTE_HEADER_IN-INCOTERMS1 = ITAB-ZINCO1.
    ENDIF.

    IF ITAB-ZINCO2 NE ''.
      TRANSLATE ITAB-ZINCO2 TO UPPER CASE.
      T_QUOTE_HEADER_IN-INCOTERMS2 = ITAB-ZINCO2.
    ENDIF.



    IF ITAB-ZTERM NE ''.
      TRANSLATE ITAB-ZTERM  TO UPPER CASE.
      T_QUOTE_HEADER_IN-PMNTTRMS   = ITAB-ZTERM.
    ENDIF.


    "- Fill Partner
    "- Sold-to party
    IF ITAB-ZCUST NE ''.
      CLEAR : V_KUNNR_SOLD, WA_QUOTE_PARTNR.
      SELECT SINGLE KNA1~KUNNR
        INTO V_KUNNR_SOLD
        FROM KNA1
        INNER JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
        WHERE ADRC~SORT1 = ITAB-ZCUST.

      WA_QUOTE_PARTNR-PARTN_ROLE = 'AG'.
      WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SOLD.
      INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
    ENDIF.



    "- Ship-to party
    IF ITAB-ZSHIPH NE ''.
      IF ITAB-ZSHIPH NE ITAB-ZCUST.
        CLEAR : V_KUNNR_SHIP, WA_QUOTE_PARTNR.
        SELECT SINGLE KNA1~KUNNR
          INTO V_KUNNR_SHIP
          FROM KNA1
          INNER JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
          INNER JOIN KNVV ON KNA1~KUNNR = KNVV~KUNNR
          WHERE ADRC~SORT1 = ITAB-ZSHIPH AND KNVV~VKORG = '6500'.

        WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
        WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SHIP.
        INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
      ENDIF.
    ELSE.
      V_KUNNR_SHIP = V_KUNNR_SOLD.
    ENDIF.

*** UPDATE FROM PST_ANTHONY FOR MONICA
    IF ITAB-ZINCO2 IS INITIAL.
      SELECT SINGLE KNVV~INCO2 INTO (ITAB-ZINCO2)
        FROM KNVV
        WHERE KNVV~KUNNR = V_KUNNR_SHIP.

      TRANSLATE ITAB-ZINCO2 TO UPPER CASE.
      T_QUOTE_HEADER_IN-INCOTERMS2 = ITAB-ZINCO2.
    ENDIF.
****

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


    "- HEADER

    IF ITAB-ZSHP NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZSHP'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZSHP.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZDPS NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZDPS'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZDPS.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZDSV NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZDSV'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZDSV.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZDSC NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZDSC'.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZDSC.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZSFR NE ''.
      CLEAR: V_SFR1, V_SFR2.
      SPLIT ITAB-ZSFR AT '.' INTO V_SFR1 V_SFR2.
      IF V_SFR1 NE '0'.
        CLEAR : WA_QUOT_COND.
        WA_QUOT_COND-COND_TYPE   = 'ZSFR'.
        WA_QUOT_COND-COND_VALUE  = ITAB-ZSFR.
        WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
        WA_QUOT_COND-ITM_NUMBER  = '000000'.
        INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
      ENDIF.
    ENDIF.

    IF ITAB-ZOTH NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZEXC'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZOTH.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZIN1 NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZIN1'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZIN1.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZIN2 NE ''.
      IF ITAB-ZIN1 NE ''.
        MESSAGE 'Condition type ZIN1 (Insurance non statistical) sudah ada, ZIN2 tidak bisa diisikan.' TYPE 'E'.
      ELSE.
        CLEAR : WA_QUOT_COND.
        WA_QUOT_COND-COND_TYPE   = 'ZIN2'.
        WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
        WA_QUOT_COND-COND_VALUE  = ITAB-ZIN2.
        WA_QUOT_COND-ITM_NUMBER  = '000000'.
        INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
      ENDIF.

    ENDIF.

    IF ITAB-ZFR1 NE ''.
      CLEAR : WA_QUOT_COND.
      WA_QUOT_COND-COND_TYPE   = 'ZFR1'.
      WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
      WA_QUOT_COND-COND_VALUE  = ITAB-ZFR1.
      WA_QUOT_COND-ITM_NUMBER  = '000000'.
      INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
    ENDIF.

    IF ITAB-ZFR2 NE ''.
      IF ITAB-ZFR1 NE ''.
        MESSAGE 'Condition type ZFR1 (Freight non statistical) sudah ada, ZFR2 tidak bisa diisikan.' TYPE 'E'.
      ELSE.
        CLEAR : WA_QUOT_COND.
        WA_QUOT_COND-COND_TYPE   = 'ZFR2'.
        WA_QUOT_COND-CURRENCY    = ITAB-ZCURR.
        WA_QUOT_COND-COND_VALUE  = ITAB-ZFR2.
        WA_QUOT_COND-ITM_NUMBER  = '000000'.
        INSERT WA_QUOT_COND INTO TABLE TAB_QUOT_COND.
      ENDIF.
    ENDIF.

    CLEAR : V_POSNR, V_CONFIG.
    CLEAR : TAB_ITEMS, TAB_QUOTE_REF, TAB_QUOTE_REFINST, TAB_QUOTE_INST, TAB_QUOTE_VALUE, RETURN.
    LOOP AT ITAB2 WHERE ZPO = ITAB-ZPO.

      V_CONFIG = V_CONFIG + 10.
      V_POSNR  = V_POSNR  + 10.

      "- FILL ITEMS
      WA_ITEM-ITM_NUMBER = V_POSNR.
      WA_ITEM-PLANT      = 'TTE'.

*** "- Ship-to party
      IF ITAB2-ZSHIP NE ''.
        IF ITAB2-ZSHIP NE ITAB2-ZSHIPH.
          CLEAR : V_KUNNR_SHIP_ITEM, WA_QUOTE_PARTNR.
          SELECT SINGLE KNA1~KUNNR
            INTO V_KUNNR_SHIP_ITEM
            FROM KNA1
            INNER JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
            WHERE ADRC~SORT1 = ITAB2-ZSHIP.

          WA_QUOTE_PARTNR-PARTN_ROLE = 'WE'.
          WA_QUOTE_PARTNR-PARTN_NUMB = V_KUNNR_SHIP_ITEM.
          WA_QUOTE_PARTNR-ITM_NUMBER = V_POSNR.
          INSERT WA_QUOTE_PARTNR INTO TABLE TAB_QUOTE_PARTNR.
        ENDIF.
      ENDIF.

      "- Material
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
        WA_ITEM-MATERIAL  = ITAB2-ZRAW.
      ENDIF.

      "- Route
      WA_ITEM-ROUTE = ITAB2-ZROUTE.

      "- Incoterm Item
      WA_ITEM-INCOTERMS1 = ITAB2-ZINCO3.

      DATA: ZINCO4 TYPE KNVV-INCO2.

      "- Edit by PST_MONICA 27.02.2013

*      IF ITAB-ZINCO3 IS NOT INITIAL.
*       SELECT SINGLE KNVV~INCO2 INTO (ZINCO4)
*         FROM KNVV
*         WHERE KNVV~KUNNR = V_KUNNR_SHIP.
*      ENDIF.
      WA_ITEM-INCOTERMS2 = ITAB-ZINCO2.

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


      IF ITAB2-ZUOMPRICE NE ''.
        TRANSLATE ITAB2-ZUOMPRICE TO UPPER CASE.
        IF ITAB2-ZUOMPRICE CS 'KG'.
          ITAB2-ZUOMPRICE = 'KG'.
        ELSEIF ITAB2-ZUOMPRICE CS 'LB'.
          ITAB2-ZUOMPRICE = 'LB'.
        ELSEIF ITAB2-ZUOMPRICE CS 'PC'.
          ITAB2-ZUOMPRICE = 'PC'.
        ELSEIF ITAB2-ZUOMPRICE CS 'SH'.
          ITAB2-ZUOMPRICE = 'SH'.
        ELSEIF ITAB2-ZUOMPRICE CS 'M2'.
          ITAB2-ZUOMPRICE = 'M2'.
        ELSEIF ITAB2-ZUOMPRICE CS 'ROL'.
          ITAB2-ZUOMPRICE = 'ROL'.
        ELSEIF ITAB2-ZUOMPRICE CS 'PAC'.
          ITAB2-ZUOMPRICE = 'PAK'.
        ELSE.
          MESSAGE 'Uom price does not exist' TYPE 'E'.
        ENDIF.
      ENDIF.
      MODIFY ITAB2.

      IF ITAB2-ZFG NE ''.
        IF ITAB2-ZFG EQ '1'.
          WA_ITEM-ITEM_CATEG = 'ZAGC'.
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
      WA_ITEMS_SCHED-REQ_QTY    = 1.
      INSERT WA_ITEMS_SCHED INTO TABLE TAB_ITEMS_SCHED.


      IF WA_QUOT_COND-COND_TYPE EQ 'ZE00' AND  WA_QUOT_COND-ITM_NUMBER NE '000000'.
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

        WA_QUOTE_INST-INST_ID    = INST_ID.
        WA_QUOTE_INST-CONFIG_ID  = V_CONFIG.
        WA_QUOTE_INST-OBJ_TYPE   = 'MARA'.
        WA_QUOTE_INST-CLASS_TYPE = 300.
        WA_QUOTE_INST-OBJ_KEY    = V_MATNR.
        WA_QUOTE_INST-QUANTITY   = 1.
        INSERT WA_QUOTE_INST INTO TABLE TAB_QUOTE_INST.

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
      "- CALL BAPI
      CALL FUNCTION 'BAPI_QUOTATION_CREATEFROMDATA2'
        EXPORTING
          QUOTATION_HEADER_IN     = T_QUOTE_HEADER_IN
          BEHAVE_WHEN_ERROR       = 'P'
        IMPORTING
          SALESDOCUMENT           = SALESORDERNUMBER
        TABLES
          QUOTATION_ITEMS_IN      = TAB_ITEMS
          QUOTATION_SCHEDULES_IN  = TAB_ITEMS_SCHED
          QUOTATION_PARTNERS      = TAB_QUOTE_PARTNR
          QUOTATION_CFGS_REF      = TAB_QUOTE_REF
          QUOTATION_CFGS_REFINST  = TAB_QUOTE_REFINST
          QUOTATION_CFGS_INST     = TAB_QUOTE_INST
          QUOTATION_CONDITIONS_IN = TAB_QUOT_COND
          QUOTATION_CFGS_VALUE    = TAB_QUOTE_VALUE
          RETURN                  = RETURN.


      IF ITAB-ZCUST NE ''.
        SELECT SINGLE KNA1~KUNNR
        INTO V_KUNNR2
        FROM KNA1
        WHERE KNA1~KUNNR = V_KUNNR_SOLD.

        IF SY-SUBRC <> 0.
          RETURN2-TYPE    = 'E'.
          CONCATENATE 'Customer with search term' ITAB-ZCUST 'not found' INTO RETURN2-MESSAGE SEPARATED BY SPACE.
          COLLECT RETURN2.
        ENDIF.
      ENDIF.

      IF ITAB-ZCUST NE ITAB-ZSHIPH AND
         ITAB-ZSHIPH NE ''.
        SELECT SINGLE KNA1~KUNNR
        INTO V_KUNNR2
        FROM KNA1
        WHERE KNA1~KUNNR = V_KUNNR_SHIP.

        IF SY-SUBRC <> 0.
          RETURN2-TYPE    = 'E'.
          CONCATENATE 'Customer with search term' ITAB-ZSHIPH 'not found' INTO RETURN2-MESSAGE SEPARATED BY SPACE.
          COLLECT RETURN2.
        ENDIF.
      ENDIF.

    ENDIF.

    IF ITAB-ZPO EQ ''.
      RETURN2-TYPE    = 'E'.
      RETURN2-MESSAGE = 'PO number can not empty'.
      COLLECT RETURN2.
    ENDIF.

    LOOP AT RETURN INTO WA_RETURN WHERE TYPE = 'E'.
      IF SY-SUBRC = 0.
        CLEAR : FLAG.
        FLAG = 'X'.
      ENDIF.
    ENDLOOP.


    "- COMMIT
    IF SALESORDERNUMBER NE '' AND FLAG NE 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.


      PERFORM CHANGE_CONDITION.

      PERFORM CHANGE_QUOT.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      CLEAR SALESORDERNUMBER.
      DELETE RETURN WHERE TYPE NE 'E'.
    ENDIF.

    LOOP AT RETURN INTO WA_RETURN.
      IT_ERROR-TYPE    = WA_RETURN-TYPE.
      IT_ERROR-ID      = WA_RETURN-ID.
      IT_ERROR-NUMBER  = WA_RETURN-NUMBER.
      IT_ERROR-MESSAGE = WA_RETURN-MESSAGE.
      IT_ERROR-VBELN   = SALESORDERNUMBER.
      IT_ERROR-ZPO     = ITAB-ZPO.
      COLLECT IT_ERROR.
    ENDLOOP.

    CLEAR : WA_RETURN.
    LOOP AT RETURN2 INTO WA_RETURN.
      IT_ERROR-TYPE    = WA_RETURN-TYPE.
      IT_ERROR-MESSAGE = WA_RETURN-MESSAGE.
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

  ENDLOOP.
  PERFORM WRITE_ERROR.

ENDFORM.                    "CREATE_QUOT


*&---------------------------------------------------------------------*
*&      Form  WRITE_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_ERROR .
  PERFORM F_FIELD_CATALOG_ERROR.
  PERFORM F_LAYOUT_ERROR.
  PERFORM F_LIST_DETAIL_ERROR.
ENDFORM.                    " WRITE_ERROR


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_ERROR .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_ERROR' :
   'ICON'    '' ''  '' '4'   'Icon '          '' ' ' '' '',
   'TYPE'    '' ''  '' '6'   'Status '          '' ' ' '' '',
   'ID'      '' ''  '' '12'  'Message ID'     '' ' ' '' '',
   'VBELN'   '' ''  '' '20'  'Quotation (PI Number)' '' 'X' '' '',
   'NUMBER'  '' ''  '' '14'  'Message Number'   '' ' ' '' '',
   'ZPO'     '' ''  '' '20' 'PO Number'           '' ' ' '' '',
   'MESSAGE' '' ''  '' '100' 'Remaks'           '' ' ' '' ''.

ENDFORM.                    " F_FIELD_CATALOG_ERROR


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT_ERROR .
  CLEAR WA_LAYOUT.
*  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.

ENDFORM.                    " F_LAYOUT_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_ERROR .
  PERFORM BUILD_SORTCAT.

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_ERROR'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_ERROR'
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
      T_OUTTAB                 = IT_ERROR
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  D_REPID = SY-REPID.

ENDFORM.                    " F_LIST_DETAIL_ERROR

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_ERROR USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_QUOTATION'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_ERROR USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN '&IC1'.
      CLEAR : WA_ERROR.
      READ TABLE IT_ERROR INTO WA_ERROR INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_ERROR-VBELN'.
          IF WA_ERROR-VBELN NE ''.
            SET PARAMETER ID 'AGN' FIELD WA_ERROR-VBELN.
            CALL TRANSACTION 'VA23' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
    WHEN 'DETAIL'.
      CLEAR : TAB_QUOT.
      REFRESH : TAB_QUOT.

      IT_ER[] = IT_ERROR[].
      DELETE IT_ER WHERE BOX NE 'X'.

      SORT IT_ER ASCENDING BY VBELN.
      DELETE ADJACENT DUPLICATES FROM IT_ER COMPARING VBELN.

      IF IT_ER[] IS INITIAL .
        MESSAGE 'No Data Selected, select at least one line.' TYPE 'I'.
        EXIT.
      ENDIF.

      LOOP AT IT_ER.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = IT_ER-VBELN
          IMPORTING
            OUTPUT = IT_ER-VBELN.

        TAB_QUOT-VBELN = IT_ER-VBELN.
        APPEND TAB_QUOT.
      ENDLOOP.

      EXPORT TAB_QUOT TO MEMORY ID 'TAB_QUOT'.
      SUBMIT ZSDR_QUOTATION_LIST AND RETURN.

  ENDCASE.

ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  CHANGE_QUOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_QUOT.
  DATA : N TYPE N.
  DATA : V_FIELD TYPE STRING.

  "- CTU_PARAMS
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

  CLEAR   : IT_BDCDATA, V_KTEXT, V_ZSO, V_MONTH, V_1, V_2.
  REFRESH : IT_BDCDATA.

  V_1 = '0'.
  V_2 = 0.
  V_MM = SY-DATUM+4(2).
  CALL FUNCTION 'CONVERT_NUMBER'
    EXPORTING
      TDLCOUNT   = V_MM
      TDNUMBERIN = 'ROMAN'
      TDUPPER    = 'X'
      TDNUMFIXC  = V_1
      TDNUMOUTL  = V_2
    IMPORTING
      STRING     = V_MONTH
*     LENGTH     =
    .

  CLEAR : ZNAME.
  ZNAME = SALESORDERNUMBER.

  CLEAR : DD, MM, YYYY.
  CLEAR : V_SAMPLE.
  DD   = SY-DATUM+6(2).
  MM   = SY-DATUM+4(2).
  YYYY = SY-DATUM(4).

  CONCATENATE DD MM YYYY INTO V_SAMPLE SEPARATED BY '.'.

  PERFORM CRT_TEXT USING 'Z109' ZNAME ZOBJECT.


  CLEAR : V_TEMP1, V_TEMP2.
  V_ZSO = SALESORDERNUMBER+6(4).
  IF V_ZPI NE ''.
    CONCATENATE 'REF. PI' V_ZPI INTO V_TEMP1 SEPARATED BY '/'.
    CONCATENATE V_ZSO V_MONTH SY-DATUM+2(2) INTO V_TEMP2 SEPARATED BY '/'.
    CONCATENATE V_TEMP1 V_TEMP2 INTO V_KTEXT SEPARATED BY SPACE.

  ENDIF.

  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '0102'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'VBAK-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'VBAK-VBELN'
                                SALESORDERNUMBER.

  CLEAR   : N, V_POSNR.
  LOOP AT ITAB2 WHERE ZPO = ITAB-ZPO.
    CLEAR : V_QTY, V_QTY1, V_TEMP, V_CUOBJ, V_NTGEW, IT_CUOBJ.
    REFRESH : IT_CUOBJ.
    V_POSNR = V_POSNR + 10.

    "- Text: Order Indicator
    CLEAR : V_SAMPLE.
    IF ITAB2-ZINORDER NE '' AND ITAB2-ZINORDER EQ 'S'.
      V_SAMPLE = 'SAMPLE'.
    ELSEIF ITAB2-ZINORDER NE '' AND ITAB2-ZINORDER EQ 'R'.
      V_SAMPLE = 'REPLACEMENT'.
    ENDIF.
    CONCATENATE ZNAME V_POSNR INTO ZNAME.
    CONDENSE ZNAME NO-GAPS.
    PERFORM CRT_TEXT USING 'Z104' ZNAME ZOBJECT.

    "- Text: End User
    CLEAR: V_SAMPLE, ZNAME.
    IF ITAB2-ZEND NE ''.
      V_SAMPLE = ITAB2-ZEND.
      ZNAME = SALESORDERNUMBER.
      PERFORM CRT_TEXT USING 'Z134' ZNAME ZOBJECT.

    ENDIF.


    "- Configuration
*    SELECT SINGLE VBAP~CUOBJ
*      INTO V_CUOBJ
*      FROM VBAP
*      WHERE VBAP~VBELN = SALESORDERNUMBER
*        AND VBAP~POSNR = V_POSNR.
*
*
*    IF ITAB2-ZUOM CS 'KG' OR ITAB2-ZUOM CS 'M2' OR ITAB2-ZUOM CS 'LB'.
*      CALL FUNCTION 'VC_I_GET_CONFIGURATION'
*        EXPORTING
*          INSTANCE            = V_CUOBJ
*        TABLES
*          CONFIGURATION       = IT_CUOBJ
*        EXCEPTIONS
*          INSTANCE_NOT_FOUND  = 1
*          INTERNAL_ERROR      = 2
*          NO_CLASS_ALLOCATION = 3
*          INSTANCE_NOT_VALID  = 4
*          OTHERS              = 5.
*      IF SY-SUBRC <> 0.
**             Implement suitable error handling here
*      ENDIF.
*
*      IF ITAB2-ZUOM CS 'KG'.
*        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
*        IF SY-SUBRC = 0.
*          V_TEMP = IT_CUOBJ-ATWRT.
*        ENDIF.
*      ELSEIF ITAB2-ZUOM CS 'M2'.
*        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZTOTALM2'.
*        IF SY-SUBRC = 0.
*          V_TEMP = IT_CUOBJ-ATWRT.
*        ENDIF.
*      ELSEIF ITAB2-ZUOM CS 'LB'.
*        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZORDERQTYWRITE'.
*        IF SY-SUBRC = 0.
*          V_TEMP = IT_CUOBJ-ATWRT.
*        ENDIF.
*      ENDIF.
*
*      SPLIT V_TEMP AT '' INTO V_QTY V_QTY1.
*
*    ELSEIF ITAB2-ZUOM CS 'PAK'.
*      V_QTY = ITAB2-ZNOPACK.
*    ELSEIF ITAB2-ZUOM CS 'ROL'.
*      V_QTY = ITAB2-ZNOROLL.
*    ENDIF.


    N = N + 1.

    IF N > 2.
      N = 1.
      PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=P+'.
    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'VBAK-KTEXT'
                                   V_KTEXT.

*    IF ITAB2-ZFG EQ '0'.
*      CLEAR : V_FIELD.
*      CONCATENATE 'RV45A-KWMENG(0' N ')' INTO V_FIELD.
*      PERFORM BDC_FIELD       USING V_FIELD
*                                    ITAB2-ZRQUAN. "- qty
*    ELSE.
*      CLEAR : V_FIELD.
*      CONCATENATE 'RV45A-KWMENG(0' N ')' INTO V_FIELD.
*      PERFORM BDC_FIELD       USING V_FIELD
*                                    V_QTY. "- qty
*    ENDIF.

    PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=PBES'.

    CLEAR : V_FIELD.
    CONCATENATE 'RV45A-VBAP_SELKZ(0' N ')' INTO V_FIELD.
    PERFORM BDC_FIELD       USING V_FIELD
                                  'X'.

    PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4003'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'VBAP-POSEX'.
    IF ITAB2-ZPOLINE NE ''.
      PERFORM BDC_FIELD       USING 'VBAP-POSEX'
                                  ITAB2-ZPOLINE.
    ENDIF.
    PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4003'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/EBACK'.
  ENDLOOP.


  PERFORM BDC_DYNPRO      USING 'SAPMV45A' '4001'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH'.

  CLEAR : V_VBELN.
  SELECT SINGLE VBUV~VBELN
    INTO V_VBELN
    FROM VBUV
    WHERE VBUV~VBELN = SALESORDERNUMBER.

  IF SY-SUBRC = 0.
    PERFORM BDC_DYNPRO      USING 'SAPLSPO2' '0101'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=OPT1'.
  ENDIF.

  CALL TRANSACTION 'VA22' USING IT_BDCDATA
                          OPTIONS FROM OPT
                          MESSAGES INTO IT_BDCMSGCOLL.


ENDFORM.                    " CHANGE_QUOT

*&--------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&--------------------------------------------------------------------*
*           text
*---------------------------------------------------------------------*
*          -->PROG       text
*          -->SCR        text
*---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROG SCR.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-PROGRAM  = PROG.
  IT_BDCDATA-DYNPRO   = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*&--------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*          -->FNAM       text
*          -->FVAL       text
*          -->FVAL       text
* --------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM  = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  BUILD_SORTCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORTCAT .
  CLEAR: T_SORT.
  REFRESH: T_SORT.

  T_SORT-SPOS      = 1.
  T_SORT-FIELDNAME = 'ZPO'.
  T_SORT-UP = 'X'.
  APPEND T_SORT.

ENDFORM.                    " BUILD_SORTCAT


*&---------------------------------------------------------------------*
*&      Form  CHANGE_CONDITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_CONDITION .

  CLEAR : V_POSNR, V_QTY, V_QTY1, V_TEMP, V_CUOBJ, V_NTGEW, IT_CUOBJ,ZZWEIGTHTOT.
  REFRESH : IT_BAPICOND, IT_BAPICONDX, IT_BAPISDITM, IT_BAPISDITMX.
  LOOP AT ITAB2 WHERE ZPO = ITAB-ZPO.
    CLEAR : V_CUOBJ, V_QTY, V_QTY1, V_TEMP.
    REFRESH : IT_CUOBJ.
    V_POSNR = V_POSNR + 10.

    "- Configuration
    SELECT SINGLE VBAP~CUOBJ
      INTO V_CUOBJ
      FROM VBAP
      WHERE VBAP~VBELN = SALESORDERNUMBER
        AND VBAP~POSNR = V_POSNR.

    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = V_CUOBJ
      TABLES
        CONFIGURATION       = IT_CUOBJ
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.


    "- CONDITIONS
    CLEAR : V_UNIT, V_COUNT, C_PRICE, C_PRICE1.
    SPLIT ITAB2-ZPRICE AT '.' INTO C_PRICE C_PRICE1.
    V_COUNT = STRLEN( C_PRICE1 ).

    IF V_COUNT = 0.
      V_UNIT = 1.
    ELSEIF V_COUNT = 1.
      V_UNIT = 1.
    ELSEIF V_COUNT = 2.
      V_UNIT = 1.
    ELSEIF V_COUNT = 3.
      V_UNIT = 1000.
    ELSEIF V_COUNT = 4.
      V_UNIT = 10000.
    ELSEIF V_COUNT > 4.
      V_UNIT = 10000.
    ENDIF.

    IF ITAB2-ZINORDER EQ 'R' OR ITAB2-ZINORDER EQ 'S'.

      IF ITAB2-ZSFR NE ''.

        CLEAR: V_SFR1, V_SFR2.
        SPLIT ITAB2-ZSFR AT '.' INTO V_SFR1 V_SFR2.

        IF V_SFR1 NE '0'.
          IT_BAPICOND-ITM_NUMBER = V_POSNR.
          IT_BAPICOND-COND_TYPE  = 'Z100'.
          COLLECT IT_BAPICOND.

          IT_BAPICONDX-ITM_NUMBER = V_POSNR.
          IT_BAPICONDX-COND_TYPE  = 'Z100'.
          COLLECT IT_BAPICONDX.
        ENDIF.

      ENDIF.

      IF C_PRICE EQ '0'.

        IF ITAB2-ZCURR NE 'IDR'.
          ITAB2-ZPRICE = '0.01'.
        ELSE.
          ITAB2-ZPRICE = 1.
        ENDIF.


      ENDIF.
    ENDIF.


    IF ITAB2-ZUOM CS 'M2' OR ITAB2-ZUOM CS 'LB'.

      READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
      IF SY-SUBRC = 0.
        V_TEMP = IT_CUOBJ-ATWRT.
      ENDIF.

      SPLIT V_TEMP AT '' INTO V_QTY V_QTY1.

      PERFORM GET_DEC_NOTATION CHANGING RIBUAN PULUHAN.
      REPLACE RIBUAN WITH '' INTO V_QTY.
      CONDENSE V_QTY NO-GAPS.

      IT_BAPISDITM-ITM_NUMBER = V_POSNR.
      IT_BAPISDITM-NET_WEIGHT = V_QTY.
      IT_BAPISDITM-GROSS_WGHT = V_QTY.
      COLLECT IT_BAPISDITM.

      IT_BAPISDITMX-ITM_NUMBER = V_POSNR.
      IT_BAPISDITMX-UPDATEFLAG = 'X'.
      IT_BAPISDITMX-NET_WEIGHT = 'X'.
      IT_BAPISDITMX-GROSS_WGHT = 'X'.
      COLLECT IT_BAPISDITMX.

      CLEAR : V_TEMP, V_QTY, V_QTY1.

    ENDIF.



    IF ITAB2-ZUOM CS 'KG' AND ITAB2-ZUOMPRICE CS 'ROL'.

      READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC = 0.
        V_TEMP = IT_CUOBJ-ATWRT.
      ENDIF.
      SPLIT V_TEMP AT '' INTO V_QTY V_QTY1.

      V_DEC = ITAB2-ZPRICE / V_QTY * V_UNIT.

      DATA: V_DECS TYPE STRING.
      V_DECS = V_DEC.

      CLEAR : V_UNIT, V_COUNT, C_PRICE, C_PRICE1.
      SPLIT V_DECS AT '.' INTO C_PRICE C_PRICE1.
      V_COUNT = STRLEN( C_PRICE1 ).

      IF V_COUNT = 0.
        V_UNIT = 1.
      ELSEIF V_COUNT = 1.
        V_UNIT = 1.
      ELSEIF V_COUNT = 2.
        V_UNIT = 1.
      ELSEIF V_COUNT = 3.
        V_UNIT = 1000.
      ELSEIF V_COUNT = 4.
        V_UNIT = 10000.
      ELSEIF V_COUNT > 4.
        V_UNIT = 10000.
      ENDIF.

      IT_BAPICOND-ITM_NUMBER = V_POSNR.
      IT_BAPICOND-COND_TYPE  = 'ZE00'.
      IT_BAPICOND-COND_VALUE = V_DEC * V_UNIT.
      IT_BAPICOND-COND_UNIT  = ITAB2-ZUOM.
      IT_BAPICOND-COND_P_UNT = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'M2' AND ITAB2-ZUOMPRICE CS 'ROL'.
      READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZTOTALM2'.
      IF SY-SUBRC = 0.
        V_TEMP = IT_CUOBJ-ATWRT.
      ENDIF.
      SPLIT V_TEMP AT '' INTO V_QTY V_QTY1.


      IT_BAPICOND-ITM_NUMBER = V_POSNR.
      IT_BAPICOND-COND_TYPE  = 'ZE00'.
      IT_BAPICOND-COND_VALUE = ITAB2-ZPRICE / ( V_QTY / ITAB2-ZNOROLL ) * V_UNIT.
      IT_BAPICOND-COND_UNIT  = ITAB2-ZUOM.
      IT_BAPICOND-COND_P_UNT = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'LB' AND ITAB2-ZUOMPRICE CS 'ROL'.
      READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      IF SY-SUBRC = 0.
        V_TEMP = IT_CUOBJ-ATWRT.
      ENDIF.
      SPLIT V_TEMP AT '' INTO V_QTY V_QTY1.

      IT_BAPICOND-ITM_NUMBER = V_POSNR.
      IT_BAPICOND-COND_TYPE  = 'ZE00'.
      IT_BAPICOND-COND_VALUE = ( ITAB2-ZPRICE / V_QTY ) * V_UNIT.
      IT_BAPICOND-COND_UNIT  = 'KG'.
      IT_BAPICOND-COND_P_UNT = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'KG' AND ITAB2-ZUOMPRICE CS 'KG'.

      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'KG'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.


    ELSEIF ITAB2-ZUOM CS 'ROL' AND ITAB2-ZUOMPRICE CS 'ROL'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'ROL'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'M2' AND ITAB2-ZUOMPRICE CS 'M2'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'M2'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'LB' AND ITAB2-ZUOMPRICE CS 'LB'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'LB'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'ROL' AND ITAB2-ZUOMPRICE CS 'KG'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'KG'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'ROL' AND ITAB2-ZUOMPRICE CS 'M2'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'M2'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'LB' AND ITAB2-ZUOMPRICE CS 'KG'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'KG'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'M2' AND ITAB2-ZUOMPRICE CS 'KG'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'KG'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'KG' AND ITAB2-ZUOMPRICE CS 'M2'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'M2'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'PAK' AND ITAB2-ZUOMPRICE CS 'PAK'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'PAK'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.

    ELSEIF ITAB2-ZUOM CS 'PAK' AND ITAB2-ZUOMPRICE CS 'KG'.
      IT_BAPICOND-COND_TYPE   = 'ZE00'.
      IT_BAPICOND-ITM_NUMBER  = V_POSNR.
      IT_BAPICOND-COND_VALUE  = ITAB2-ZPRICE * V_UNIT.
      IT_BAPICOND-COND_P_UNT  = V_UNIT.
      IT_BAPICOND-CURRENCY    = ITAB2-ZCURR.
      IT_BAPICOND-COND_UNIT   = 'KG'.
      COLLECT IT_BAPICOND.

      IT_BAPICONDX-ITM_NUMBER = V_POSNR.
      IT_BAPICONDX-COND_TYPE  = 'ZE00'.
      IT_BAPICONDX-UPDATEFLAG = 'X'.
      IT_BAPICONDX-COND_VALUE = 'X'.
      IT_BAPICONDX-COND_UNIT  = 'X'.
      IT_BAPICONDX-COND_P_UNT = 'X'.
      IT_BAPICONDX-CURRENCY   = 'X'.
      COLLECT IT_BAPICONDX.
    ENDIF.


    "add by whika for Insert Order Qty from Schedule Line Item
    "Date : 22/08/2016
    "semangat kawan
    IF ITAB2-ZUOM CS 'KG' OR ITAB2-ZUOM CS 'M2' OR ITAB2-ZUOM CS 'LB'.
      CLEAR IT_CUOBJ-ATWRT.
      IF ITAB2-ZUOM CS 'KG'.
        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
        IF SY-SUBRC = 0.
          V_TEMP = IT_CUOBJ-ATWRT.
        ENDIF.
      ELSEIF ITAB2-ZUOM CS 'M2'.
        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZTOTALM2'.
        IF SY-SUBRC = 0.
          V_TEMP = IT_CUOBJ-ATWRT.
        ENDIF.
      ELSEIF ITAB2-ZUOM CS 'LB'.
        READ TABLE IT_CUOBJ WITH KEY ATNAM = 'ZZORDERQTY'.
        IF SY-SUBRC = 0.
          REPLACE ALL OCCURRENCES OF ',' IN IT_CUOBJ-ATWRT WITH ' '.
          V_TEMP = IT_CUOBJ-ATWRT * ITAB2-ZNOROLL.
        ENDIF.
      ENDIF.

    ELSEIF ITAB2-ZUOM CS 'PAK'.
      V_TEMP = ITAB2-ZNOPACK.
    ELSEIF ITAB2-ZUOM CS 'ROL'.
      V_TEMP = ITAB2-ZNOROLL.
    ENDIF.

    IF ITAB2-ZFG EQ '0'.
      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
        EXPORTING
          CHR             = ITAB2-ZRQUAN
        IMPORTING
          NUM             = ZZWEIGTHTOT
        EXCEPTIONS
          CONVT_NO_NUMBER = 1
          CONVT_OVERFLOW  = 2
          OTHERS          = 3.
    ELSE.
      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
        EXPORTING
          CHR             = V_TEMP
        IMPORTING
          NUM             = ZZWEIGTHTOT
        EXCEPTIONS
          CONVT_NO_NUMBER = 1
          CONVT_OVERFLOW  = 2
          OTHERS          = 3.
    ENDIF.

    IF ITAB2-ZFG EQ '0'.
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB2-ZDLVDATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-ITM_NUMBER = V_POSNR.
      WA_ITEMS_SCHED-SCHED_LINE  = 1.
      WA_ITEMS_SCHED-REQ_QTY = ZZWEIGTHTOT.
*    WA_ITEMS_SCHED-REQ_DATE = WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-DATE_TYPE  = '1'.
      APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
      CLEAR WA_ITEMS_SCHED.

      WA_SCHEDULES_INX-ITM_NUMBER = V_POSNR.
      WA_SCHEDULES_INX-SCHED_LINE  = 1.
      WA_SCHEDULES_INX-UPDATEFLAG = 'U'.
      WA_SCHEDULES_INX-REQ_QTY = 'X'.
      WA_SCHEDULES_INX-REQ_DATE = 'X'.
      APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
      CLEAR WA_SCHEDULES_INX.
    ELSE.
      CLEAR : DD, MM, YYYY.
      SPLIT ITAB2-ZDLVDATE AT '.' INTO DD MM YYYY.
      CONCATENATE YYYY MM DD INTO WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-ITM_NUMBER = V_POSNR.
      WA_ITEMS_SCHED-SCHED_LINE  = 1.
      WA_ITEMS_SCHED-REQ_QTY = ZZWEIGTHTOT.
*    WA_ITEMS_SCHED-REQ_DATE = WA_ITEMS_SCHED-REQ_DATE.
      WA_ITEMS_SCHED-DATE_TYPE  = '1'.
      APPEND WA_ITEMS_SCHED TO TAB_ITEMS_SCHED.
      CLEAR WA_ITEMS_SCHED.

      WA_SCHEDULES_INX-ITM_NUMBER = V_POSNR.
      WA_SCHEDULES_INX-SCHED_LINE  = 1.
      WA_SCHEDULES_INX-UPDATEFLAG = 'U'.
      WA_SCHEDULES_INX-REQ_QTY = 'X'.
      WA_SCHEDULES_INX-REQ_DATE = 'X'.
      APPEND WA_SCHEDULES_INX TO TAB_SCHEDULES_INX.
      CLEAR WA_SCHEDULES_INX.
    ENDIF.

  ENDLOOP.

  IF IT_BAPICOND[] IS NOT INITIAL.
    PERFORM UPLOAD_CHANGE.
  ENDIF.

ENDFORM.                    " CHANGE_CONDITION


*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_CHANGE .
  REFRESH : IT_BAPISDH1X, IT_RETURN.

  IT_BAPISDH1X-UPDATEFLAG = 'U'.
  COLLECT IT_BAPISDH1X.

  CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
    EXPORTING
      SALESDOCUMENT    = SALESORDERNUMBER
      ORDER_HEADER_INX = IT_BAPISDH1X
    TABLES
      RETURN           = IT_RETURN
      CONDITIONS_IN    = IT_BAPICOND
      CONDITIONS_INX   = IT_BAPICONDX
      ORDER_ITEM_IN    = IT_BAPISDITM
      ORDER_ITEM_INX   = IT_BAPISDITMX
      SCHEDULE_LINESX  = TAB_SCHEDULES_INX
      SCHEDULE_LINES   = TAB_ITEMS_SCHED.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      WAIT = 'X'.


ENDFORM.                    " UPLOAD_CHANGE


*&---------------------------------------------------------------------*
*&      Form  CRT_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1854   text
*      -->P_ZNAME  text
*      -->P_ZOBJECT  text
*----------------------------------------------------------------------*
FORM CRT_TEXT  USING    VALUE(P_1854)
                        P_ZNAME
                        P_ZOBJECT.

  CLEAR   : IT_LINE.
  REFRESH : IT_LINE.

  CASE P_1854.
    WHEN 'Z109'.
      CONCATENATE DD MM YYYY INTO IT_LINE-TDLINE SEPARATED BY '.'.
      COLLECT IT_LINE.
      P_ZOBJECT = 'VBBK'.
    WHEN 'Z104'.
      IT_LINE-TDLINE = V_SAMPLE.
      COLLECT IT_LINE.
      P_ZOBJECT = 'VBBP'.
    WHEN 'Z134'.
      IT_LINE-TDLINE = V_SAMPLE.
      COLLECT IT_LINE.
      P_ZOBJECT = 'VBBK'.
  ENDCASE.

  IF V_SAMPLE NE ''.
    CALL FUNCTION 'CREATE_TEXT'
      EXPORTING
        FID         = P_1854
        FLANGUAGE   = SY-LANGU
        FNAME       = P_ZNAME
        FOBJECT     = P_ZOBJECT
        SAVE_DIRECT = 'X'
        FFORMAT     = '*'
      TABLES
        FLINES      = IT_LINE
      EXCEPTIONS
        NO_INIT     = 1
        NO_SAVE     = 2
        OTHERS      = 3.

  ENDIF.



ENDFORM.                    " CRT_TEXT


*&---------------------------------------------------------------------*
*&      Form  GET_DEC_NOTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_RIBUAN  text
*      <--P_PULUHAN  text
*----------------------------------------------------------------------*
FORM GET_DEC_NOTATION  CHANGING RIBUAN
                                PULUHAN.

  DATA: USR01_EXP LIKE USR01.

  CALL FUNCTION 'CETA_USR01_READ'
    EXPORTING
      BNAME     = SY-UNAME
    IMPORTING
      USR01_EXP = USR01_EXP
    EXCEPTIONS
      NO_ENTRY  = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

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

ENDFORM.                    " GET_DEC_NOTATION