**---------------------------------------------------------------------*
** Report  ZFIR_AR_AGING_PIUTANG
**
** Description      : Report AR Aging Piutang
**
** Application Area - FI
** ABAPer           - Hisar Sianturi
** Date             - October 29, 2012
** Copy from        - ZFI_AR_AGING_PIUTANG_P
**----------------------------------------------------------------------*
** Amendment History
** ~~~~~~~~~~~~~~~~~
** Ref | Date     | Programmer  | Correction | Description
** ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
**----------------------------------------------------------------------*

REPORT  ZFIR_AR_AGING_PIUTANG NO STANDARD PAGE HEADING  LINE-SIZE 200.

TABLES : BSIK, LFA1, BKPF, BSEG, ZBSIK, T052, LFB1, KNA1, BSID, KNB1, KNKK,
         TVKO, KNVP, T003T, PA0002.   " Added by William at 28.09.2020 (Update included table for BSID data)
TYPE-POOLS : SLIS.

DATA: BEGIN OF V_BSID OCCURS 10,
        BOX(1),
        KTOKD LIKE KNA1-KTOKD, "account group
        TODAY LIKE SY-DATUM,
        AGING(16),
        DUE_DATE  TYPE D,
        " Added by William at 28.09.2020 (New column for BSID)
        NAME1(100),
        LTEXT LIKE T003T-LTEXT,
        SALES LIKE PA0002-CNAME,
        EMPLY LIKE PA0002-CNAME,
        ZDMBTR TYPE P LENGTH 16 DECIMALS 2,
        ZWRBTR TYPE P LENGTH 16 DECIMALS 2,
        ZDMBE2 TYPE P LENGTH 16 DECIMALS 2.
" End added by William at 28.09.2020 (New column for BSID)
        INCLUDE STRUCTURE BSIDEXT.
DATA:   END OF V_BSID.

DATA: BEGIN OF X_BSID OCCURS 10,
        DUE_DATE  TYPE D.
        INCLUDE STRUCTURE BSIDEXT.
DATA: END OF X_BSID.

DATA: BEGIN OF V_BKPF OCCURS 10.
        INCLUDE STRUCTURE BKPF_LINE.
DATA: END OF V_BKPF.

DATA: BEGIN OF ITAB OCCURS 10,
        NOMER TYPE I,
        KUNNR LIKE KNA1-KUNNR,
        KTOKD LIKE KNA1-KTOKD, "account Group
        NAME1 LIKE KNA1-NAME1,
        ZTERM LIKE KNB1-ZTERM,
        AMO0  TYPE P LENGTH 16 DECIMALS 2,            "Amount jumlah
        AMO1  TYPE P LENGTH 16 DECIMALS 2,            "Amount <0 hari
        AMO2  TYPE P LENGTH 16 DECIMALS 2,            "Amount 1-30 hari
        AMO2A  TYPE P LENGTH 16 DECIMALS 2,            "Amount 16-30 hari
        AMO3  TYPE P LENGTH 16 DECIMALS 2,            "Amount 31-60 hari
        AMO4  TYPE P LENGTH 16 DECIMALS 2,            "Amount 61-90 hari
*        AMO5  TYPE P LENGTH 16 DECIMALS 2,            "Amount >90 hari
        AMO6 TYPE P LENGTH 16 DECIMALS 2,             "Amount 91 - 120 hari (Tambahan)
*        AMO7 TYPE P LENGTH 16 DECIMALS 2,             "Amount > 120 hari (Tambahan)

        AMO7 TYPE P LENGTH 16 DECIMALS 2,             "Amount 121-150 hari
        AMO8 TYPE P LENGTH 16 DECIMALS 2,            "Amount 151-180 hari
        AMO9 TYPE P LENGTH 16 DECIMALS 2,            "Amount 181-210 hari
        AMO10 TYPE P LENGTH 16 DECIMALS 2,           "Amount 211-240 hari
        AMO11 TYPE P LENGTH 16 DECIMALS 2,           "Amount 241-270 hari
        AMO12 TYPE P LENGTH 16 DECIMALS 2,           "Amount 271-300 hari
        AMO13 TYPE P LENGTH 16 DECIMALS 2,           "Amount 301-330 hari
        AMO14 TYPE P LENGTH 16 DECIMALS 2,           "Amount 331-360 hari
        AMO15 TYPE P LENGTH 16 DECIMALS 2,           "Amount >360   hari


        TOT_AMO TYPE P LENGTH 16 DECIMALS 2,          "Total Amount (Tambahan)
        DP    TYPE P LENGTH 16 DECIMALS 2,            "DP Amount
        KLIMK LIKE KNKK-KLIMK,
        CURR LIKE KNVV-WAERS,                         "Currency (Tambahan)
        BUKRS LIKE BSID-BUKRS,
        BOX(1),
      END OF ITAB.

DATA: WRBTR TYPE P LENGTH 16 DECIMALS 2,
      DMBTR TYPE P LENGTH 16 DECIMALS 2,
      DMBE2 TYPE P LENGTH 16 DECIMALS 2.
DATA: WRBTR_1 TYPE P LENGTH 16 DECIMALS 2,
      DMBTR_1 TYPE P LENGTH 16 DECIMALS 2,
      DMBE2_1 TYPE P LENGTH 16 DECIMALS 2.

DATA: NOMER TYPE I,
      DUE TYPE I,
      L_BSID TYPE I. " Added by William at 28.09.2020

DATA: V_BELNR LIKE BSID-BELNR,
      V_REBZG LIKE BSID-REBZG,
      V_DMBTR LIKE BSID-DMBTR,
      V_WRBTR LIKE BSID-WRBTR,
      " Added by William at 28.09.2020 (for additional data from BSID)
      V_PARVW LIKE KNVP-PARVW,
      V_NAME1 LIKE ADRC-NAME1,
      V_NAME2 LIKE ADRC-NAME2.
" End added by William at 28.09.2020 (for additional data from BSID)

DATA: VARDATE TYPE SY-DATUM,
      VARTIME(8) TYPE C,
      VARDATETIME(20) TYPE C,
      VARBREAK TYPE C.  " Added by William at 28.09.2020 (for exit program mechanism)

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: BUKRS FOR BSIK-BUKRS OBLIGATORY DEFAULT '9999',
                KUNNR FOR KNA1-KUNNR,
                CURR FOR ZBSIK-NOMER MATCHCODE OBJECT ZBSIK_HELP
                OBLIGATORY.
PARAMETERS : P_DATE LIKE SY-DATUM DEFAULT SY-DATUM.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
PARAMETERS : P_1 RADIOBUTTON GROUP RB1.
PARAMETERS : P_2 RADIOBUTTON GROUP RB1.
SELECTION-SCREEN END OF BLOCK 2.

"Add By Jarwo 16.02.2017
*SELECTION-SCREEN BEGIN OF BLOCK 3 WITH FRAME TITLE TEXT-003.
*PARAMETERS : P_3 RADIOBUTTON GROUP RB2.
*PARAMETERS : P_4 RADIOBUTTON GROUP RB2.
*SELECTION-SCREEN END OF BLOCK 3.

INCLUDE ZABAPALV.

START-OF-SELECTION.
*  IF P_4 = 'X'.
*    AUTHORITY-CHECK OBJECT 'ZOLAP'
*             ID 'ACTVT' FIELD '01'
*             ID 'ZTCODE' FIELD 'ZFI017'.
*    IF SY-SUBRC <> 0.
*      MESSAGE 'No Authorization to download data...!'  TYPE 'I'. "#EC NOTEXT
*      EXIT.
*    ENDIF.
*  ENDIF.

  PERFORM GET_DATA.
  " Added by William at 28.09.2020 (Check if GET_DATA process is failed)
  IF VARBREAK = 'X'.
    EXIT.
  ENDIF.
  " End added by William at 28.09.2020 (Check if GET_DATA process is failed)
  V_BSID-TODAY = SY-DATUM.
  MODIFY V_BSID TRANSPORTING TODAY WHERE TODAY NE'11111111'.
  V_BSID-BLDAT = '19000101'.
  MODIFY V_BSID TRANSPORTING BLDAT WHERE BLDAT = 00000000 OR BLDAT = ''.
  V_BSID-BUDAT = '19000101'.
  MODIFY V_BSID TRANSPORTING BUDAT WHERE BUDAT = 00000000 OR BUDAT = ''.
  V_BSID-DUE_DATE = '19000101'.
  MODIFY V_BSID TRANSPORTING DUE_DATE WHERE DUE_DATE = 00000000 OR DUE_DATE = ''.
  V_BSID-TODAY = '19000101'.
  MODIFY V_BSID TRANSPORTING TODAY WHERE TODAY = 00000000 OR TODAY = ''.

  "Modify By Jarwo 16.02.2017
*  IF P_3 = 'X'.
  IF P_1 = 'X'.
    PERFORM F_DISPLAY_ALV.
  ELSEIF P_2 = 'X'.
    PERFORM F_DISPLAY_ALV2.
  ENDIF.
*  ELSEIF P_4 = 'X'.
*    PERFORM CHECK_SERVER.
*    PERFORM CONNECT_SQL.
*    IF P_1 = 'X'.
*      PERFORM INSERT_SQL_PERIODE.
*    ELSEIF P_2 = 'X'.
*      PERFORM INSERT_SQL_LINE.
*    ENDIF.
*  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  CLEAR V_BSID.
  REFRESH V_BSID.
  SELECT * INTO CORRESPONDING FIELDS OF V_BSID FROM BSID
  WHERE BUKRS IN BUKRS AND
        KUNNR IN KUNNR AND
        KUNNR NE SPACE AND
        BLDAT <= P_DATE      .

    CLEAR T052. "Add by Afir
    SELECT SINGLE * FROM T052 WHERE ZTERM = V_BSID-ZTERM.

    " Modified by William at 09.10.2020 (Repairing due date and aging calculation)
    IF V_BSID-ZFBDT IS NOT INITIAL.
      V_BSID-DUE_DATE = V_BSID-ZFBDT + T052-ZTAG1.
      V_BSID-AGING    = V_BSID-DUE_DATE - SY-DATUM.
    ENDIF.
    " End modified by William at 09.10.2020 (Repairing due date and aging calculation)

    SELECT SINGLE KTOKD INTO V_BSID-KTOKD FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.

    " Added by William at 28.09.2020 (Get additional data based from BSID)
    " Get Doc. Type Description
    SELECT SINGLE LTEXT INTO V_BSID-LTEXT
      FROM T003T
      WHERE
      BLART = V_BSID-BLART
      AND SPRAS = 'EN'.

    " Get Sales Employee
    PERFORM CHANGE_PARVW USING 'SE' CHANGING V_PARVW.
    SELECT SINGLE PA0002~CNAME INTO V_BSID-SALES
      FROM TVKO
      JOIN KNVP ON TVKO~VKORG = KNVP~VKORG
      JOIN PA0002 ON KNVP~PERNR = PA0002~PERNR
      WHERE
      TVKO~BUKRS = V_BSID-BUKRS
      AND KNVP~KUNNR = V_BSID-KUNNR
      AND KNVP~PARVW = V_PARVW.

    " Get Employee Responsible
    PERFORM CHANGE_PARVW USING 'ER' CHANGING V_PARVW.
    SELECT SINGLE PA0002~CNAME INTO V_BSID-EMPLY
      FROM TVKO
      JOIN KNVP ON TVKO~VKORG = KNVP~VKORG
      JOIN PA0002 ON KNVP~PERNR = PA0002~PERNR
      WHERE
      TVKO~BUKRS = V_BSID-BUKRS
      AND KNVP~KUNNR = V_BSID-KUNNR
      AND KNVP~PARVW = V_PARVW.

    " Get Customer Name
    SELECT SINGLE ADRC~NAME1 INTO V_NAME1
      FROM KNA1
      JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
      WHERE KNA1~KUNNR = V_BSID-KUNNR.

    SELECT SINGLE ADRC~NAME2 INTO V_NAME2
      FROM KNA1
      JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
      WHERE KNA1~KUNNR = V_BSID-KUNNR.

    CONCATENATE V_NAME1 ' ' V_NAME2 INTO V_BSID-NAME1.
    " End added by William at 28.09.2020 (Get additional data based from BSID)

    MOVE-CORRESPONDING V_BSID TO X_BSID.
    APPEND V_BSID.
    CLEAR V_BSID.
    APPEND X_BSID.
    CLEAR X_BSID.
  ENDSELECT.

  SELECT * INTO CORRESPONDING FIELDS OF V_BSID
  FROM BSAD WHERE BUKRS IN BUKRS AND
                  KUNNR IN KUNNR AND
                  KUNNR NE SPACE AND
                  AUGDT > P_DATE AND
                  BLDAT <= P_DATE.

    CLEAR T052. "Add by Afir
    SELECT SINGLE * FROM T052 WHERE ZTERM = V_BSID-ZTERM.

    " Modified by William at 09.10.2020 (Repairing due date and aging calculation)
    IF V_BSID-ZFBDT IS NOT INITIAL.
      V_BSID-DUE_DATE = V_BSID-ZFBDT + T052-ZTAG1.
      V_BSID-AGING    = V_BSID-DUE_DATE - SY-DATUM.
    ENDIF.
    " End modified by William at 09.10.2020 (Repairing due date and aging calculation)

    SELECT SINGLE KTOKD INTO V_BSID-KTOKD FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.

    " Added by William at 28.09.2020 (Get additional data based from BSID)
    " Get Doc. Type Description
    SELECT SINGLE LTEXT INTO V_BSID-LTEXT
      FROM T003T
      WHERE
      BLART = V_BSID-BLART
      AND SPRAS = 'EN'.

    " Get Sales Employee
    PERFORM CHANGE_PARVW USING 'SE' CHANGING V_PARVW.
    SELECT SINGLE PA0002~CNAME INTO V_BSID-SALES
      FROM TVKO
      JOIN KNVP ON TVKO~VKORG = KNVP~VKORG
      JOIN PA0002 ON KNVP~PERNR = PA0002~PERNR
      WHERE
      TVKO~BUKRS = V_BSID-BUKRS
      AND KNVP~KUNNR = V_BSID-KUNNR
      AND KNVP~PARVW = V_PARVW.

    " Get Employee Responsible
    PERFORM CHANGE_PARVW USING 'ER' CHANGING V_PARVW.
    SELECT SINGLE PA0002~CNAME INTO V_BSID-EMPLY
      FROM TVKO
      JOIN KNVP ON TVKO~VKORG = KNVP~VKORG
      JOIN PA0002 ON KNVP~PERNR = PA0002~PERNR
      WHERE
      TVKO~BUKRS = V_BSID-BUKRS
      AND KNVP~KUNNR = V_BSID-KUNNR
      AND KNVP~PARVW = V_PARVW.

    " Get Customer Name
    SELECT SINGLE ADRC~NAME1 INTO V_NAME1
      FROM KNA1
      JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
      WHERE KNA1~KUNNR = V_BSID-KUNNR.

    SELECT SINGLE ADRC~NAME2 INTO V_NAME2
      FROM KNA1
      JOIN ADRC ON KNA1~ADRNR = ADRC~ADDRNUMBER
      WHERE KNA1~KUNNR = V_BSID-KUNNR.

    CONCATENATE V_NAME1 ' ' V_NAME2 INTO V_BSID-NAME1.
    " End added by William at 28.09.2020 (Get additional data based from BSID)

    MOVE-CORRESPONDING V_BSID TO X_BSID.
    APPEND V_BSID.
    CLEAR V_BSID.
    APPEND X_BSID.
    CLEAR X_BSID.
  ENDSELECT.

  " Added by William at 28.09.2020 (Check for BSID data)
  CLEAR: L_BSID.
  DESCRIBE TABLE V_BSID LINES L_BSID.
  IF L_BSID EQ 0.
    MESSAGE 'No data!' TYPE 'I'.
    VARBREAK = 'X'.
    EXIT.
  ENDIF.
  " End added by William at 28.09.2020 (Check for BSID data)

  REFRESH V_BKPF.
  SELECT * INTO CORRESPONDING FIELDS OF V_BKPF FROM BKPF
  FOR ALL ENTRIES IN V_BSID WHERE BUKRS IN BUKRS AND BELNR = V_BSID-BELNR AND
        ( XSTOV NE '' OR STODT NE '' OR STBLG NE '' ).
    APPEND V_BKPF.
    CLEAR V_BKPF.
  ENDSELECT.

  SORT V_BKPF BY BELNR.
  READ TABLE V_BKPF INDEX 1.
  IF SY-SUBRC = 0.
    LOOP AT V_BSID.
      READ TABLE V_BKPF WITH KEY BUKRS = V_BSID-BUKRS
                                 BELNR = V_BSID-BELNR.

      IF SY-SUBRC <> 0.
        DELETE V_BSID WHERE BUKRS = V_BSID-BUKRS AND BELNR = V_BSID-BELNR.
        CLEAR V_BSID.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT V_BSID BY KUNNR BELNR.
  REFRESH ITAB.
  CLEAR ITAB.

* add by ALF at 17-11-2006
  LOOP AT V_BSID WHERE SHKZG EQ 'H'.
    V_BSID-DMBTR = V_BSID-DMBTR * -1.
    V_BSID-WRBTR = V_BSID-WRBTR * -1.
    V_BSID-DMBE2 = V_BSID-DMBE2 * -1.

    MODIFY V_BSID TRANSPORTING DMBTR WRBTR DMBE2 WHERE BELNR = V_BSID-BELNR AND BUZEI = V_BSID-BUZEI AND GJAHR = V_BSID-GJAHR AND BUKRS = V_BSID-BUKRS.
  ENDLOOP.

  LOOP AT X_BSID WHERE SHKZG EQ 'H'.
    X_BSID-DMBTR = X_BSID-DMBTR * -1.
    X_BSID-WRBTR = X_BSID-WRBTR * -1.
    X_BSID-DMBE2 = X_BSID-DMBE2 * -1.

    MODIFY X_BSID TRANSPORTING DMBTR WRBTR DMBE2 WHERE BELNR = X_BSID-BELNR AND BUZEI = X_BSID-BUZEI AND GJAHR = X_BSID-GJAHR.
  ENDLOOP.
* end of ALF

  " Added by William at 01.10.2020 (testing V_BSID)
*  SORT V_BSID BY DMBTR DESCENDING.

  LOOP AT V_BSID.
    IF V_BSID-REBZG NE SPACE AND V_BSID-BLART = 'DZ'.
      READ TABLE X_BSID WITH KEY BELNR = V_BSID-REBZG
                                 KUNNR = V_BSID-KUNNR
                                 REBZJ = V_BSID-REBZJ.

      IF SY-SUBRC = 0.
        IF V_BSID-WAERS = 'IDR'.
          WRBTR = X_BSID-WRBTR * 100.
          DMBTR = X_BSID-DMBTR * 100.
          DMBE2 = X_BSID-DMBE2 * 100.
          WRBTR_1 = V_BSID-WRBTR * 100.
          DMBTR_1 = V_BSID-DMBTR * 100.
          DMBE2_1 = V_BSID-DMBE2 * 100.

*          IF v_bsid-shkzg = 'H'.
*            dmbtr_1 = dmbtr_1 * -1.
*            dmbe2_1 = dmbe2_1 * -1.
*          ENDIF.
*          IF x_bsid-shkzg = 'H'.
*            dmbtr = dmbtr * -1.
*            dmbe2 = dmbe2 * -1.
*          ENDIF.

        ELSE.                              "Non IDR
          WRBTR = X_BSID-WRBTR.
          DMBTR = X_BSID-DMBTR.
          DMBE2 = X_BSID-DMBE2.
          WRBTR_1 = V_BSID-WRBTR.
          DMBTR_1 = V_BSID-DMBTR.
          DMBE2_1 = V_BSID-DMBE2.

*          IF v_bsid-shkzg = 'H'.
*            dmbtr_1 = dmbtr_1 * -1.
*            dmbe2_1 = dmbe2_1 * -1.
*          ENDIF.
*          IF x_bsid-shkzg = 'H'.
*            dmbtr = dmbtr * -1.
*            dmbe2 = dmbe2 * -1.
*          ENDIF.
        ENDIF.
        PERFORM F_INSERT_AMOUNT_KZ.

      ELSE.                                        "no Invoice ref.
        IF V_BSID-WAERS = 'IDR'.
          WRBTR = X_BSID-WRBTR * 100.
          DMBTR = X_BSID-DMBTR * 100.
          DMBE2 = X_BSID-DMBE2 * 100.
          WRBTR_1 = V_BSID-WRBTR * 100.
          DMBTR_1 = V_BSID-DMBTR * 100.
          DMBE2_1 = V_BSID-DMBE2 * 100.
        ELSE.
          WRBTR = X_BSID-WRBTR.
          DMBTR = X_BSID-DMBTR.
          DMBE2 = X_BSID-DMBE2.
          WRBTR_1 = V_BSID-WRBTR.
          DMBTR_1 = V_BSID-DMBTR.
          DMBE2_1 = V_BSID-DMBE2.
        ENDIF.
        PERFORM F_INSERT_AMOUNT.
      ENDIF.

    ELSEIF V_BSID-BSCHL = '21' AND V_BSID-KIDNO = SPACE.   " Credit Memo
      READ TABLE X_BSID WITH KEY BELNR = V_BSID-ZUONR
                                 KUNNR = V_BSID-KUNNR.

      IF SY-SUBRC = 0.
        IF V_BSID-WAERS = 'IDR'.
          WRBTR = X_BSID-WRBTR * 100.
          DMBTR = X_BSID-DMBTR * 100.
          DMBE2 = X_BSID-DMBE2 * 100.
          WRBTR_1 = V_BSID-WRBTR * 100.
          DMBTR_1 = V_BSID-DMBTR * 100.
          DMBE2_1 = V_BSID-DMBE2 * 100.

*          IF v_bsid-shkzg = 'H'.
          DMBTR_1 = DMBTR_1 * -1.
          DMBE2_1 = DMBE2_1 * -1.
*          ENDIF.
*          IF x_bsid-shkzg = 'H'.
          DMBTR = DMBTR * -1.
          DMBE2 = DMBE2 * -1.
*          ENDIF.


          WRBTR_1 = WRBTR + WRBTR_1.
          DMBTR_1 = DMBTR + DMBTR_1.
          DMBE2_1 = DMBE2 + DMBE2_1.
        ELSE.                                    "else '21' non 'IDR'
          WRBTR = X_BSID-WRBTR.
          DMBTR = X_BSID-DMBTR.
          DMBE2 = X_BSID-DMBE2.
          WRBTR_1 = V_BSID-WRBTR.
          DMBTR_1 = V_BSID-DMBTR.
          DMBE2_1 = V_BSID-DMBE2.

*          IF v_bsid-shkzg = 'H'.
          DMBTR_1 = DMBTR_1 * -1.
          DMBE2_1 = DMBE2_1 * -1.
*          ENDIF.
*          IF x_bsid-shkzg = 'H'.
          DMBTR = DMBTR * -1.
          DMBE2 = DMBE2 * -1.
*          ENDIF.

          WRBTR_1 = WRBTR + WRBTR_1.
          DMBTR_1 = DMBTR + DMBTR_1.
          DMBE2_1 = DMBE2 + DMBE2_1.
        ENDIF.
        PERFORM F_INSERT_AMOUNT_KZ.

        DELETE V_BSID WHERE BELNR = V_BSID-ZUONR.
      ELSE.                                        "no Assignment
        IF V_BSID-WAERS = 'IDR'.
          WRBTR = X_BSID-WRBTR * 100.
          DMBTR = X_BSID-DMBTR * 100.
          DMBE2 = X_BSID-DMBE2 * 100.
          WRBTR_1 = V_BSID-WRBTR * 100.
          DMBTR_1 = V_BSID-DMBTR * 100.
          DMBE2_1 = V_BSID-DMBE2 * 100.

          DMBTR_1 = DMBTR_1 * -1.
          DMBE2_1 = DMBE2_1 * -1.
          DMBTR = DMBTR * -1.
          DMBE2 = DMBE2 * -1.

        ELSE.
          WRBTR = X_BSID-WRBTR.
          DMBTR = X_BSID-DMBTR.
          DMBE2 = X_BSID-DMBE2.
          WRBTR_1 = V_BSID-WRBTR.
          DMBTR_1 = V_BSID-DMBTR.
          DMBE2_1 = V_BSID-DMBE2.

          DMBTR_1 = DMBTR_1 * -1.
          DMBE2_1 = DMBE2_1 * -1.
          DMBTR = DMBTR * -1.
          DMBE2 = DMBE2 * -1.

        ENDIF.
        PERFORM F_INSERT_AMOUNT.
      ENDIF.
    ELSE.                                 " non Credit Memo pk-21
      IF V_BSID-WAERS = 'IDR'.
        WRBTR = X_BSID-WRBTR * 100.
        DMBTR = X_BSID-DMBTR * 100.
        DMBE2 = X_BSID-DMBE2 * 100.
        WRBTR_1 = V_BSID-WRBTR * 100.
        DMBTR_1 = V_BSID-DMBTR * 100.
        DMBE2_1 = V_BSID-DMBE2 * 100.
      ELSE.
        WRBTR = X_BSID-WRBTR.
        DMBTR = X_BSID-DMBTR.
        DMBE2 = X_BSID-DMBE2.
        WRBTR_1 = V_BSID-WRBTR.
        DMBTR_1 = V_BSID-DMBTR.
        DMBE2_1 = V_BSID-DMBE2.
      ENDIF.
      PERFORM F_INSERT_AMOUNT.
    ENDIF.

    " Added by William at 30.09.2020 (fixing Doc. and Loc. Amount with IDR currency)
*    V_BSID-DMBTR = DMBTR_1.
    V_BSID-ZDMBTR = DMBTR_1.
    V_BSID-ZWRBTR = WRBTR_1.
    V_BSID-ZDMBE2 = DMBE2_1.
    MODIFY V_BSID.
*    ENDIF.
  ENDLOOP.

  DELETE ITAB WHERE NAME1 = SPACE AND
                    ZTERM = SPACE AND
                    AMO0  = 0 AND
                    AMO1  = 0 AND
                    AMO2  = 0 AND
                    AMO2A  = 0 AND
                    AMO3  = 0 AND
                    AMO4  = 0 AND
                    AMO6 = 0 AND
                    AMO7 = 0.
*                    AMO5  = 0.

  LOOP AT ITAB.
*    ITAB-AMO0 = ITAB-AMO0.
*    ITAB-AMO1 = ITAB-AMO1.
*    ITAB-AMO2 = ITAB-AMO2.
*    ITAB-AMO3 = ITAB-AMO3.
*    ITAB-AMO4 = ITAB-AMO4.
**    ITAB-AMO5 = ITAB-AMO5.
*    ITAB-AMO6 = ITAB-AMO6.
*    ITAB-AMO7 = ITAB-AMO7.
    ITAB-TOT_AMO = ITAB-AMO2A + ITAB-AMO3 + ITAB-AMO4 + ITAB-AMO6 + ITAB-AMO7 +
                   ITAB-AMO8 + ITAB-AMO9 + ITAB-AMO10 + ITAB-AMO11 + ITAB-AMO12 +
                   ITAB-AMO13 + ITAB-AMO14 + ITAB-AMO15.

    SELECT SINGLE ZTERM INTO ITAB-ZTERM FROM KNVV WHERE KUNNR = ITAB-KUNNR.
    SELECT SINGLE KLIMK INTO ITAB-KLIMK FROM KNKK WHERE KUNNR = ITAB-KUNNR.
    MODIFY ITAB TRANSPORTING ZTERM DP KLIMK TOT_AMO WHERE KUNNR = ITAB-KUNNR
                                                      AND BUKRS = ITAB-BUKRS.
  ENDLOOP.

ENDFORM.                    "get_data
*  PERFORM f_display_alv.

*&---------------------------------------------------------------------*
*&      Form  f_insert_amount
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM  F_INSERT_AMOUNT.
  CASE CURR-LOW.
    WHEN '1'.
      SELECT SINGLE * FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.
      SELECT SINGLE * FROM KNB1 WHERE KUNNR = V_BSID-KUNNR.
      ITAB-KUNNR = KNA1-KUNNR.
      ITAB-NAME1 = KNA1-NAME1.
      ITAB-KTOKD = KNA1-KTOKD.
      ITAB-CURR = 'IDR'.
      IF V_BSID-WAERS NE 'IDR'.
        DMBTR = DMBTR * 100.
        DMBTR_1 = DMBTR_1 * 100.
      ELSE.
        DMBE2 = DMBE2 / 100.
        DMBE2_1 = DMBE2_1 / 100.
      ENDIF.

*      IF v_bsid-shkzg = 'H'.
*        dmbtr_1 = dmbtr_1 * -1.
*      ENDIF.

      IF V_BSID-UMSKZ NE SPACE AND V_BSID-UMSKZ NE 'F'.
* Changed due to wrong of logic
        ITAB-DP = DMBTR_1.
      ELSE.
        ITAB-AMO0 = DMBTR_1.

        DUE = P_DATE - V_BSID-DUE_DATE.
        IF DUE < 0. " change by irma 1-1-2013
          ITAB-AMO1 = DMBTR_1.
*        ELSEIF due >= 0 AND due < 16.
*          itab-amo2 = dmbtr_1.
        ELSEIF DUE >= 0 AND DUE <= 30.
          ITAB-AMO2A = DMBTR_1.
        ELSEIF DUE > 30 AND DUE <= 60.
          ITAB-AMO3 = DMBTR_1.
        ELSEIF DUE > 60 AND DUE <= 90.
          ITAB-AMO4 = DMBTR_1.
*        ELSEIF DUE > 90.
*          ITAB-AMO5 = DMBTR_1.
          "Add By Jarwo
        ELSEIF DUE > 90 AND DUE <= 120.
          ITAB-AMO6 = DMBTR_1.
        ELSEIF DUE > 120 AND DUE <= 150.
          ITAB-AMO7 = DMBTR_1.
        ELSEIF DUE > 150 AND DUE <= 180.
          ITAB-AMO8 = DMBTR_1.
        ELSEIF DUE > 180 AND DUE <= 210.
          ITAB-AMO9 = DMBTR_1.
        ELSEIF DUE > 210 AND DUE <= 240.
          ITAB-AMO10 = DMBTR_1.
        ELSEIF DUE > 240 AND DUE <= 270.
          ITAB-AMO11 = DMBTR_1.
        ELSEIF DUE > 270 AND DUE <= 300.
          ITAB-AMO12 = DMBTR_1.
        ELSEIF DUE > 300 AND DUE <= 330.
          ITAB-AMO13 = DMBTR_1.
        ELSEIF DUE > 330 AND DUE <= 360.
          ITAB-AMO14 = DMBTR_1.
        ELSEIF DUE > 360.
          ITAB-AMO15 = DMBTR_1.
        ENDIF.
      ENDIF.

    WHEN '2'.
      SELECT SINGLE * FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.
      SELECT SINGLE * FROM KNB1 WHERE KUNNR = V_BSID-KUNNR.
      ITAB-KUNNR = KNA1-KUNNR.
      ITAB-NAME1 = KNA1-NAME1.
      ITAB-KTOKD = KNA1-KTOKD.
      ITAB-CURR = 'USD'.
      IF V_BSID-WAERS NE 'IDR'.
        DMBTR = DMBTR * 100.
        DMBTR_1 = DMBTR_1 * 100.
      ELSE.
        DMBE2 = DMBE2 / 100.
        DMBE2_1 = DMBE2_1 / 100.
      ENDIF.
*      IF v_bsid-shkzg = 'H'.
*        dmbe2_1 = dmbe2_1 * -1.
*      ENDIF.

      IF V_BSID-UMSKZ NE SPACE AND V_BSID-UMSKZ NE 'F'.
        ITAB-DP = DMBE2_1.
      ELSE.
        ITAB-AMO0 = DMBE2_1.

        DUE = P_DATE - V_BSID-DUE_DATE.
        IF DUE < 0. " change by Irma
          ITAB-AMO1 = DMBE2_1.
*        ELSEIF due >= 0 AND due < 16.
*          itab-amo2 = dmbe2_1.
        ELSEIF DUE >= 0 AND DUE <= 30.
          ITAB-AMO2A = DMBE2_1.
        ELSEIF DUE > 30 AND DUE <= 60.
          ITAB-AMO3 = DMBE2_1.
        ELSEIF DUE > 60 AND DUE <= 90.
          ITAB-AMO4 = DMBE2_1.
*        ELSEIF DUE > 90.
*          ITAB-AMO5 = DMBE2_1.
          "Add By Jarwo
        ELSEIF DUE > 90 AND DUE <= 120.
          ITAB-AMO6 = DMBE2_1.
        ELSEIF DUE > 120 AND DUE <= 150.
          ITAB-AMO7 = DMBE2_1.
        ELSEIF DUE > 151 AND DUE <= 180.
          ITAB-AMO8 = DMBE2_1.
        ELSEIF DUE > 180 AND DUE <= 210.
          ITAB-AMO9 = DMBE2_1.
        ELSEIF DUE > 210 AND DUE <= 240.
          ITAB-AMO10 = DMBE2_1.
        ELSEIF DUE > 240 AND DUE <= 270.
          ITAB-AMO11 = DMBE2_1.
        ELSEIF DUE > 270 AND DUE <= 300.
          ITAB-AMO12 = DMBE2_1.
        ELSEIF DUE > 300 AND DUE <= 330.
          ITAB-AMO13 = DMBE2_1.
        ELSEIF DUE > 330 AND DUE <= 360.
          ITAB-AMO14 = DMBE2_1.
        ELSEIF DUE > 360.
          ITAB-AMO15 = DMBE2_1.
        ENDIF.
      ENDIF.
  ENDCASE.

  ITAB-BUKRS = V_BSID-BUKRS.
  COLLECT ITAB.
  CLEAR ITAB.
ENDFORM.                    "f_insert_amount

*&---------------------------------------------------------------------*
*&      Form  f_insert_amount_kz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM  F_INSERT_AMOUNT_KZ.
  CASE CURR-LOW.
    WHEN '1'.
      SELECT SINGLE * FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.
      SELECT SINGLE * FROM KNB1 WHERE KUNNR = V_BSID-KUNNR.
      ITAB-KUNNR = KNA1-KUNNR.
      ITAB-NAME1 = KNA1-NAME1.
      ITAB-KTOKD = KNA1-KTOKD.
      ITAB-CURR = 'IDR'.

      IF V_BSID-WAERS NE 'IDR'.
        DMBTR = DMBTR * 100.
        DMBTR_1 = DMBTR_1 * 100.
      ELSE.
        DMBE2 = DMBE2 / 100.
        DMBE2_1 = DMBE2_1 / 100.
      ENDIF.

      IF V_BSID-UMSKZ NE SPACE AND V_BSID-UMSKZ NE 'F'.
        ITAB-DP = DMBTR_1.
      ELSE.
        ITAB-AMO0 = DMBTR_1.

        DUE = P_DATE - X_BSID-DUE_DATE.
        IF DUE < 0.
          ITAB-AMO1 = DMBTR_1.
*        ELSEIF due >= 0 AND due < 16.
*          itab-amo2 = dmbtr_1.
        ELSEIF DUE >= 0 AND DUE <= 30.
          ITAB-AMO2A = DMBTR_1.
        ELSEIF DUE > 30 AND DUE <= 60.
          ITAB-AMO3 = DMBTR_1.
        ELSEIF DUE > 60 AND DUE <= 90.
          ITAB-AMO4 = DMBTR_1.
*        ELSEIF DUE > 90.
*          ITAB-AMO5 = DMBTR_1.
          "Add By Jarwo
        ELSEIF DUE > 90 AND DUE <= 120.
          ITAB-AMO6 = DMBTR_1.
        ELSEIF DUE > 120 AND DUE <= 150.
          ITAB-AMO7 = DMBTR_1.
        ELSEIF DUE > 150 AND DUE <= 180.
          ITAB-AMO8 = DMBTR_1.
        ELSEIF DUE > 180 AND DUE <= 210.
          ITAB-AMO9 = DMBTR_1.
        ELSEIF DUE > 210 AND DUE <= 240.
          ITAB-AMO10 = DMBTR_1.
        ELSEIF DUE > 240 AND DUE <= 270.
          ITAB-AMO11 = DMBTR_1.
        ELSEIF DUE > 270 AND DUE <= 300.
          ITAB-AMO12 = DMBTR_1.
        ELSEIF DUE > 300 AND DUE <= 330.
          ITAB-AMO13 = DMBTR_1.
        ELSEIF DUE > 330 AND DUE <= 360.
          ITAB-AMO14 = DMBTR_1.
        ELSEIF DUE > 360.
          ITAB-AMO15 = DMBTR_1.
        ENDIF.
      ENDIF.

    WHEN '2'.
      SELECT SINGLE * FROM KNA1 WHERE KUNNR = V_BSID-KUNNR.
      SELECT SINGLE * FROM KNB1 WHERE KUNNR = V_BSID-KUNNR.
      ITAB-KUNNR = KNA1-KUNNR.
      ITAB-NAME1 = KNA1-NAME1.
      ITAB-KTOKD = KNA1-KTOKD.
      ITAB-CURR = 'USD'.

      IF V_BSID-WAERS NE 'IDR'.
        DMBTR = DMBTR * 100.
        DMBTR_1 = DMBTR_1 * 100.
      ELSE.
        DMBE2 = DMBE2 / 100.
        DMBE2_1 = DMBE2_1 / 100.
      ENDIF.

      IF V_BSID-UMSKZ NE SPACE AND V_BSID-UMSKZ NE 'F'.
        ITAB-DP = DMBE2_1.
      ELSE.
        ITAB-AMO0 = DMBE2_1.

        DUE = P_DATE - X_BSID-DUE_DATE.
        IF DUE < 0.
          ITAB-AMO1 = DMBE2_1.
*        ELSEIF due >= 0 AND due < 16.
*          itab-amo2 = dmbe2_1.
        ELSEIF DUE >= 0 AND DUE <= 30.
          ITAB-AMO2A = DMBE2_1.
        ELSEIF DUE > 30 AND DUE <= 60.
          ITAB-AMO3 = DMBE2_1.
        ELSEIF DUE > 60 AND DUE <= 90.
          ITAB-AMO4 = DMBE2_1.
*        ELSEIF DUE > 90.
*          ITAB-AMO5 = DMBE2_1.
          "Add By Jarwo
        ELSEIF DUE > 90 AND DUE <= 120.
          ITAB-AMO6 = DMBE2_1.
        ELSEIF DUE > 120 AND DUE <= 150.
          ITAB-AMO7 = DMBE2_1.
        ELSEIF DUE > 150 AND DUE <= 180.
          ITAB-AMO8 = DMBE2_1.
        ELSEIF DUE > 180 AND DUE <= 210.
          ITAB-AMO9 = DMBE2_1.
        ELSEIF DUE > 210 AND DUE <= 240.
          ITAB-AMO10 = DMBE2_1.
        ELSEIF DUE > 240 AND DUE <= 270.
          ITAB-AMO11 = DMBE2_1.
        ELSEIF DUE > 270 AND DUE <= 300.
          ITAB-AMO12 = DMBE2_1.
        ELSEIF DUE > 300 AND DUE <= 330.
          ITAB-AMO13 = DMBE2_1.
        ELSEIF DUE > 330 AND DUE <= 360.
          ITAB-AMO14 = DMBE2_1.
        ELSEIF DUE > 360.
          ITAB-AMO15 = DMBE2_1.
        ENDIF.
      ENDIF.
  ENDCASE.

  ITAB-BUKRS = V_BSID-BUKRS.
  COLLECT ITAB.
  CLEAR ITAB.
ENDFORM.                    "f_insert_amount_kz

*&---------------------------------------------------------------------*
*&      Form  f_display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM F_DISPLAY_ALV .
  DATA: L_FIELDCAT TYPE SLIS_FIELDCAT_ALV, L_REPID LIKE SY-REPID,
        L_SAVE VALUE 'A'.

  L_REPID = SY-REPID.
  PERFORM F_EVENT_BUILD.
  PERFORM F_COMMENT_BUILD.
  PERFORM F_LAYOUT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'KUNNR'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 1.
  L_FIELDCAT-OUTPUTLEN = 15.
  L_FIELDCAT-REPTEXT_DDIC = 'Customer Code'.
  L_FIELDCAT-KEY     = 'X'.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'NAME1'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 2.
  L_FIELDCAT-OUTPUTLEN = 30.
  L_FIELDCAT-REPTEXT_DDIC = 'Customer Name'.
  L_FIELDCAT-KEY     = 'X'.
  L_FIELDCAT-HOTSPOT       = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZTERM'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 3.
  L_FIELDCAT-OUTPUTLEN = 5.
  L_FIELDCAT-REPTEXT_DDIC = 'TOP'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO0'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 4.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Balance Amount'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO1'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 5.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' < 0 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

*  CLEAR l_fieldcat.
*  l_fieldcat-fieldname = 'AMO2'.
*  l_fieldcat-tabname   = 'ITAB'.
*  l_fieldcat-row_pos   = 1.
*  l_fieldcat-col_pos   = 6.
*  l_fieldcat-outputlen = 16.
*  l_fieldcat-reptext_ddic = ' 1 - 15 '.
*  APPEND l_fieldcat TO t_fieldcat.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO2A'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 7.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 0 - 30 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO3'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 8.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 31 - 60 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO4'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 9.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 61 - 90 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'AMO5'.
*  L_FIELDCAT-TABNAME   = 'ITAB'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = 10.
*  L_FIELDCAT-OUTPUTLEN = 16.
*  L_FIELDCAT-REPTEXT_DDIC = ' > 90 '.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO6'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 10.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 91 - 120 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO7'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 121 - 150 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO8'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 151 - 180 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO9'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 181 - 210 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO10'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 211 - 240 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO11'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 241 - 270 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO12'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 271 - 300 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO13'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 301 - 330 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO14'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' 331 - 360 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AMO15'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 11.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = ' > 360 '.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'TOT_AMO'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 12.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Overdue Amount'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'DP'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 13.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'DP Amount'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'KLIMK'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = 14.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Credit Limit'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BUKRS'.
  L_FIELDCAT-TABNAME   = 'ITAB'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 10.
  L_FIELDCAT-REPTEXT_DDIC = 'Comp. Code'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = L_REPID
      I_SAVE                   = L_SAVE
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
*     it_sort                  = t_sort
      IS_LAYOUT                = WA_LAYOUT
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      IT_FIELDCAT              = T_FIELDCAT[]
    TABLES
      T_OUTTAB                 = ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    "f_display_alv



*&---------------------------------------------------------------------*
*&      Form  f_display_alv2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_DISPLAY_ALV2.
  DATA: L_FIELDCAT TYPE SLIS_FIELDCAT_ALV, L_REPID LIKE SY-REPID,
        L_SAVE VALUE 'A'.

  L_REPID = SY-REPID.

  PERFORM F_EVENT_BUILD.
  PERFORM F_COMMENT_BUILD.
  PERFORM F_LAYOUT.

  CLEAR L_FIELDCAT-COL_POS.

  " Added by William at 01.10.2020 (moved column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BUKRS'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 10.
  L_FIELDCAT-REPTEXT_DDIC = 'Comp. Code'.
  L_FIELDCAT-KEY     = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 01.10.2020 (moved column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BELNR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Doc. Number'.
  L_FIELDCAT-KEY     = 'X'.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BUZEI'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 3.
  L_FIELDCAT-REPTEXT_DDIC = 'Line Item'.
  L_FIELDCAT-KEY     = 'X'.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'GJAHR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 4.
  L_FIELDCAT-REPTEXT_DDIC = 'Fiscal Year'.
  L_FIELDCAT-KEY     = 'X'.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'MONAT'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 2.
  L_FIELDCAT-REPTEXT_DDIC = 'Period'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Edited by William at 01.10.2020 (remove PK)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'KUNNR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 15.
  L_FIELDCAT-REPTEXT_DDIC = 'Customer Code'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'NAME1'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 100.
  L_FIELDCAT-REPTEXT_DDIC = 'Customer Name'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZUONR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Assignment'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Adding by William at 08.10.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'XBLNR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Reference'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Adding by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'VBELN'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Billing Doc.'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 01.10.2020 (moved column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'BELNR'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 12.
*  L_FIELDCAT-REPTEXT_DDIC = 'Doc. Number'.
*  L_FIELDCAT-KEY     = ''.
*  L_FIELDCAT-HOTSPOT       = 'X'.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BLART'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 5.
  L_FIELDCAT-REPTEXT_DDIC = 'Type'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'LTEXT'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 20.
  L_FIELDCAT-REPTEXT_DDIC = 'Doc. Type Desc.'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'UMSKZ'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 1.
  L_FIELDCAT-REPTEXT_DDIC = 'Special G/L Ind.'.
  L_FIELDCAT-KEY     = ''.
  L_FIELDCAT-HOTSPOT       = 'X'.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BLDAT'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Doc. Date'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'BUDAT'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Post. Date'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'DUE_DATE'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Due. Date'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'TODAY'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Today'.  " Modified by William at 08.10.2020
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AGING'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 5.
  L_FIELDCAT-REPTEXT_DDIC = 'Aging'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZTERM'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Term'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 28.09.2020 (duplicate column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'TODAY'.  "'DUE_DATE'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 12.
*  L_FIELDCAT-REPTEXT_DDIC = 'Due Date'.
*  L_FIELDCAT-KEY     = ''.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZWRBTR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 18.
  L_FIELDCAT-REPTEXT_DDIC = 'Doc. Amount'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 01.10.2020 (moved column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'WAERS'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 5.
  L_FIELDCAT-REPTEXT_DDIC = 'Curr.'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZDMBTR'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 18.
  L_FIELDCAT-REPTEXT_DDIC = 'Loc. Amount'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'ZDMBE2'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 16.
  L_FIELDCAT-REPTEXT_DDIC = 'Loc. Amount 2'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 01.10.2020 (moved column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'WAERS'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 5.
*  L_FIELDCAT-REPTEXT_DDIC = 'Curr.'.
*  L_FIELDCAT-KEY     = ''.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 01.10.2020 (moved column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'AUGBL'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 12.
*  L_FIELDCAT-REPTEXT_DDIC = 'Clearing Doc.'.
*  L_FIELDCAT-KEY     = ''.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 01.10.2020 (moved column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'SGTXT'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 12.
*  L_FIELDCAT-REPTEXT_DDIC = 'Text'.
*  L_FIELDCAT-KEY     = ''.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'SALES'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 80.
  L_FIELDCAT-REPTEXT_DDIC = 'Sales Employee'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 28.09.2020 (Adding new column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'EMPLY'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 80.
  L_FIELDCAT-REPTEXT_DDIC = 'Employee Responsible'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 01.10.2020 (moved column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'AUGBL'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Clearing Doc.'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Added by William at 01.10.2020 (moved column)
  CLEAR L_FIELDCAT.
  L_FIELDCAT-FIELDNAME = 'SGTXT'.
  L_FIELDCAT-TABNAME   = 'V_BSID'.
  L_FIELDCAT-ROW_POS   = 1.
  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
  L_FIELDCAT-OUTPUTLEN = 12.
  L_FIELDCAT-REPTEXT_DDIC = 'Text'.
  L_FIELDCAT-KEY     = ''.
  APPEND L_FIELDCAT TO T_FIELDCAT.

  " Remarked by William at 01.10.2020 (moved column)
*  CLEAR L_FIELDCAT.
*  L_FIELDCAT-FIELDNAME = 'BUKRS'.
*  L_FIELDCAT-TABNAME   = 'V_BSID'.
*  L_FIELDCAT-ROW_POS   = 1.
*  L_FIELDCAT-COL_POS   = L_FIELDCAT-COL_POS + 1.
*  L_FIELDCAT-OUTPUTLEN = 10.
*  L_FIELDCAT-REPTEXT_DDIC = 'Comp. Code'.
*  L_FIELDCAT-KEY     = ''.
*  APPEND L_FIELDCAT TO T_FIELDCAT.

  SY-TITLE = 'Customer List Item'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = L_REPID
      I_SAVE                   = L_SAVE
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
*     it_sort                  = t_sort
      IS_LAYOUT                = WA_LAYOUT
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      IT_FIELDCAT              = T_FIELDCAT[]
    TABLES
      T_OUTTAB                 = V_BSID
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  f_event_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_EVENT_BUILD.
  DATA: L_EVENT TYPE SLIS_ALV_EVENT.

*  l_event-name = slis_ev_top_of_page.
*  l_event-form = v_top_of_page.
*  APPEND l_event TO t_events.

ENDFORM.  "f_event_build

*&---------------------------------------------------------------------*
*&      Form  f_comment_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_COMMENT_BUILD.
  DATA: L_LINE TYPE SLIS_LISTHEADER.

*  l_line-typ  = 'H'.
*  l_line-info = 'PT. Trias Sentosa,Tbk'.
*  APPEND l_line TO t_top_of_page.
*
*  CLEAR l_line.
*  l_line-typ  = 'S'.
*  l_line-key  = 'Stock on hand: '.
*  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) INTO l_line-info.
*  APPEND l_line TO t_top_of_page.

ENDFORM.  "f_comment_build


*********************  Link to Document *******************************
FORM USER_COMMAND USING UCOMM LIKE SY-UCOMM
                             SELFIELD TYPE SLIS_SELFIELD.
  CASE UCOMM.
    WHEN '&DTL'.
      READ TABLE ITAB INDEX SELFIELD-TABINDEX.
      CHECK SY-SUBRC EQ 0.
*      CASE selfield-sel_tab_field.
*        WHEN 'ITAB-KUNNR'.
*          SET PARAMETER ID 'KUN' FIELD itab-kunnr.
*          CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.
*      ENDCASE.
    WHEN '&IC1'. "add by Irma On 21-12-2012
      IF SELFIELD-TABNAME = 'ITAB'.
        READ TABLE ITAB INDEX SELFIELD-TABINDEX.
        CHECK SY-SUBRC EQ 0.
        SUBMIT RFITEMAR WITH DD_KUNNR-LOW = ITAB-KUNNR
                        WITH DD_BUKRS-LOW = '9999'
                        WITH PA_STIDA = P_DATE AND RETURN.
      ELSEIF SELFIELD-TABNAME = 'V_BSID'.
        READ TABLE V_BSID INDEX SELFIELD-TABINDEX.
        CHECK SY-SUBRC EQ 0.
        CASE SELFIELD-SEL_TAB_FIELD.
          WHEN 'V_BSID-KUNNR'. " fbl5n
            SUBMIT RFITEMAR WITH DD_KUNNR-LOW = V_BSID-KUNNR
                            WITH DD_BUKRS-LOW = '9999'
                            WITH PA_STIDA = P_DATE AND RETURN.
          WHEN 'V_BSID-ZUONR'. "assignment(VF03)
            SET PARAMETER ID 'VF' FIELD V_BSID-ZUONR.
            CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
          WHEN 'V_BSID-BELNR'. "fb03
            SET PARAMETER ID 'BLN' FIELD V_BSID-BELNR.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
    WHEN 'LIST'.

  ENDCASE.
ENDFORM.                    " USER_COMMAND



*&---------------------------------------------------------------------*
*&      Form  f_gui_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_EXTAB   text
*----------------------------------------------------------------------*
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  REFRESH FT_EXTAB.
  CLEAR FT_EXTAB.
  APPEND 'DETAIL' TO FT_EXTAB.

  SET PF-STATUS 'STANDARD_FULLSCREEN1' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS


*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " f_layout

*&---------------------------------------------------------------------*
*&      Form  CHECK_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SERVER.
  IF SY-HOST = 'TRIASWIN2008' OR SY-HOST = 'SAPTRPKR'.
  ELSE.
    STOP.
  ENDIF.
ENDFORM.                    "CHECK_SERVER

*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONNECT_SQL.
  EXEC SQL.
    CONNECT TO 'TRIASDB04' AS 'DBOLAP'
  ENDEXEC.

  EXEC SQL.
    SET CONNECTION 'DBOLAP'
  ENDEXEC.

  CLEAR: VARDATE, VARTIME, VARDATETIME.
  VARDATE = SY-DATUM.
  WRITE SY-UZEIT TO VARTIME.
  CONCATENATE VARDATE VARTIME INTO VARDATETIME SEPARATED BY SPACE.
ENDFORM.                    "CONNECT_SQL

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL_LINE.
  " Remarked by William at 02.10.2020 (fixing data BSID for download data)
*  DELETE V_BSID WHERE KTOKD EQ 'ZOTH'.
*  DELETE V_BSID WHERE KTOKD EQ 'ZOTC'.

  EXEC SQL.
    DELETE FROM XZFI017_LITEM
  ENDEXEC.

  EXEC SQL.
    COMMIT WORK
  ENDEXEC.

  LOOP AT V_BSID.

    PERFORM MOVENEGATIVE CHANGING V_BSID-AGING.

    " Updated by William at 29.09.2020 (update download data Customer Line Item)
    EXEC SQL.
      INSERT INTO XZFI017_LITEM
      ( COMPANYCODE, DOCUMENTNUMBER, LINEITEM, FISCALYEAR, PERIOD,
        CUSTOMERNUMBER, CUSTOMERNAME, ASSIGNMENT, REFERENCE, BILLINGDOCUMENT,
        DOCUMENTTYPE, DOCUMENTTYPEDESC, [SPECIAL G/L IND.], DOCUMENTDATE, POSTINGDATE,
        DUEDATE, TODAY, AGING, TERM, DOCAMOUNT,
        DOCCURRENCY, LOCALAMOUNT1, LOCALAMOUNT2, SALESEMPLOYEE, EMPLOYEERESPONSIBLE,
        CLEARINGDOC, TEXT, LASTUPDATE)
      VALUES
      ( :V_BSID-BUKRS, :V_BSID-BELNR, :V_BSID-BUZEI, :V_BSID-GJAHR, :V_BSID-MONAT,
        :V_BSID-KUNNR, :V_BSID-NAME1, :V_BSID-ZUONR, :V_BSID-XBLNR, :V_BSID-VBELN,
        :V_BSID-BLART, :V_BSID-LTEXT, :V_BSID-UMSKZ, :V_BSID-BLDAT, :V_BSID-BUDAT,
        :V_BSID-DUE_DATE, :V_BSID-TODAY, :V_BSID-AGING, :V_BSID-ZTERM, :V_BSID-ZWRBTR,
        :V_BSID-WAERS, :V_BSID-ZDMBTR, :V_BSID-ZDMBE2, :V_BSID-SALES, :V_BSID-EMPLY,
        :V_BSID-AUGBL, :V_BSID-SGTXT, :VARDATETIME)
    ENDEXEC.
    " End updated by William at 29.09.2020 (update download data Customer Line Item)
  ENDLOOP.

  EXEC SQL.
    COMMIT WORK
  ENDEXEC.

  MESSAGE 'Customer Line Item data successfully downloaded!' TYPE 'I'. " Added by William at 30.09.2020 (message for download data)

ENDFORM.                    "INSERT_SQL_LINE

*&---------------------------------------------------------------------*
*&      Form  INSERT_SQL_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_SQL_PERIODE.

  DATA :  V_AMO0(16) TYPE C,
          V_AMO1(16) TYPE C,
          V_AMO2A(16) TYPE C,
          V_AMO3(16) TYPE C,
          V_AMO4(16) TYPE C,
*          V_AMO5(16) TYPE C,
          V_AMO6(16) TYPE C,
          V_AMO7(16) TYPE C,
          V_TOT(16) TYPE C,
          V_DP(16) TYPE C,
          V_KLIMK(16) TYPE C.

  DELETE ITAB WHERE KTOKD EQ 'ZOTH'.
  DELETE ITAB WHERE KTOKD EQ 'ZOTC'.

  LOOP AT ITAB.
    V_AMO0 = ITAB-AMO0.
    V_AMO1 = ITAB-AMO1.
    V_AMO2A = ITAB-AMO2A.
    V_AMO3 = ITAB-AMO3.
    V_AMO4 = ITAB-AMO4.
*    V_AMO5 = ITAB-AMO5.
    V_AMO6 = ITAB-AMO6.
    V_AMO7 = ITAB-AMO7.
    V_TOT = ITAB-TOT_AMO.
    V_DP = ITAB-DP.
    V_KLIMK = ITAB-KLIMK.

    PERFORM MOVENEGATIVE CHANGING V_AMO0.
    PERFORM MOVENEGATIVE CHANGING V_AMO1.
    PERFORM MOVENEGATIVE CHANGING V_AMO2A.
    PERFORM MOVENEGATIVE CHANGING V_AMO3.
    PERFORM MOVENEGATIVE CHANGING V_AMO4.
*    PERFORM MOVENEGATIVE CHANGING V_AMO5.
    PERFORM MOVENEGATIVE CHANGING V_AMO6.
    PERFORM MOVENEGATIVE CHANGING V_AMO7.
    PERFORM MOVENEGATIVE CHANGING V_TOT.
    PERFORM MOVENEGATIVE CHANGING V_DP.
    PERFORM MOVENEGATIVE CHANGING V_KLIMK.

    EXEC SQL.
      INSERT INTO XZFI017_PERIODE
      ( [CUSTOMER NUMBER], [CUSTOMER NAME], [TOP], [BALANCE AMOUNT], [<=0], [1-30],
        [31-60], [61-90], [91-120], [>120], [DP AMOUNT], [CREDIT LIMIT], CURR, [OVERDUE AMOUNT], LASTUPDATE, COMPANYCODE )
      VALUES
      ( :ITAB-KUNNR, :ITAB-NAME1, :ITAB-ZTERM, :V_AMO0, :V_AMO1, :V_AMO2A,
        :V_AMO3, :V_AMO4, :V_AMO6, :V_AMO7, :V_DP, :V_KLIMK, :ITAB-CURR, :V_TOT, :VARDATETIME, :ITAB-BUKRS )
    ENDEXEC.
  ENDLOOP.

  EXEC SQL.
    COMMIT WORK
  ENDEXEC.

  MESSAGE 'Customer in Periode data successfully downloaded!' TYPE 'I'. " Added by William at 30.09.2020 (message for download data)

ENDFORM.                    "INSERT_SQL_PERIODE

*&---------------------------------------------------------------------*
*&      Form  MOVENEGATIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FIELD    text
*----------------------------------------------------------------------*
FORM MOVENEGATIVE CHANGING P_FIELD.
  CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
    CHANGING
      VALUE = P_FIELD.
ENDFORM.                    "MOVENEGATIVE

*&---------------------------------------------------------------------*
*&      Form  CHANGE_PARVW
*&---------------------------------------------------------------------*
*       Added by William at 28.09.2020
*----------------------------------------------------------------------*
*      -->P_INPUT  text
*      <--P_OUTPUT  text
*----------------------------------------------------------------------*
FORM CHANGE_PARVW  USING    P_INPUT
                   CHANGING P_OUTPUT.

  CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
    EXPORTING
      INPUT  = P_INPUT
    IMPORTING
      OUTPUT = P_OUTPUT
    .  "  CONVERSION_EXIT_PARVW_INPUT

ENDFORM.                    " CHANGE_PARVW