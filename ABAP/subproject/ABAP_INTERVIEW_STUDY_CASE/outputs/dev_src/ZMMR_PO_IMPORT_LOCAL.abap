"&---------------------------------------------------------------------*
"& Report  ZMMR_PO_IMPORT
"&
"&---------------------------------------------------------------------*
"& improve ZMM052 --> ZMMR_IMPORT
"& Abaper : Alexs & Yulius
"& Development Date : 28-03-2016
"&---------------------------------------------------------------------*

REPORT  ZMMR_PO_IMPORT_LOCAL.
INCLUDE ZABAPALV.

TABLES : EKKO, EIPO, EKET, EKPO, KONV, MARA, LFA1, MSEG.

DATA : BEGIN OF IT_TRACK OCCURS 0,
          LIFNR LIKE EKKO-LIFNR,
          NAME1 LIKE LFA1-NAME1,
          WERKS LIKE EKPO-WERKS,  " Added by William at 07.08.2020
          EBELN LIKE EKKO-EBELN,
          EBELP LIKE EKPO-EBELP,
          JEBELP LIKE EIPO-EXPOS,
          EINDT LIKE EKET-EINDT,
          BEDAT LIKE EKKO-BEDAT,
          TXZ01 LIKE EKPO-TXZ01,
          MATNR LIKE MARA-MATNR,
          MENGE LIKE EKPO-MENGE,
          NACNU LIKE EIPO-NACNU,
          NACDA LIKE EIPO-NACDA,
          PRONU LIKE EIPO-PRONU,
          PRODA LIKE EIPO-PRODA,
          NACN4 LIKE EIPO-NACN4,
          NACN2 LIKE EIPO-NACN2,
          NAUE2 LIKE EIPO-NAUE2,
          NACD2 LIKE EIPO-NACD2,
          TEXT1 LIKE EIPO-TEXT1,
          TEXT2 LIKE EIPO-TEXT2,
          TEXT3 LIKE EIPO-TEXT3,
          NACN5 LIKE EIPO-NACN5,
          NACN3 LIKE EIPO-NACN3,
          NACD3 LIKE EIPO-NACD3,
          NAUE3 LIKE EIPO-NAUE3,
          EXNUM LIKE EKKO-EXNUM,
          EXPOS LIKE EIPO-EXPOS,
          ELIKZ LIKE EKPO-ELIKZ,
          NETPR TYPE P DECIMALS 4,  " Modified by William at 12.04.2021
          PEINH LIKE EKPO-PEINH,
          KNUMV LIKE EKKO-KNUMV,
          KWERT TYPE P DECIMALS 4,  " Modified by William at 12.04.2021
          ZKAWRT LIKE KONV-KAWRT,  "% BEA MASUK
          WAERS LIKE EKKO-WAERS,
          BUDAT LIKE RBKP-BUDAT,  "INVOICE POSTING DATE
          IWAERS LIKE RBKP-WAERS,  "CURRENCY INVOICE
          RMWWR TYPE P DECIMALS 4,  "INVOICE AMOUNT " Modified by William at 12.04.2021
          HBKID LIKE RBKP-HBKID,  "BANK DEVISA
          TOP   LIKE RBKP-ZFBDT,  "TOP(TANGGAL JATUH TEMPO)
          DMENGE LIKE MSEG-MENGE,  "DELIVERY QTY
          AUGDT LIKE BSAK-AUGDT,  "PAYMENT DATE
          AUGBL LIKE BSAK-AUGBL,  "PAYMENT DOC. NUMBER
          WRBTR TYPE P DECIMALS 4,  "PAYMENT AMOUNT " Modified by William at 12.04.2021
          BELNR LIKE BSIK-BELNR,  "MATERIAL DOCUMENT
          BUZEI LIKE BSIK-BUZEI,  "MATERIAL DOCUMENT ITEM
          GJAHR LIKE BSIK-GJAHR,  "MATERIAL DOCUMENT YEAR
          AWKEY LIKE BKPF-AWKEY,  "KEY TO GET MAT DOC
          ZBELNR LIKE BSIK-BELNR,  "MAT DOC TO GET PAYMENT DATE
          CANCEL(1) TYPE C,
          MEINS LIKE EKPO-MEINS,  "UoM
          PREFN LIKE EIPO-PREFN,
          PREDU LIKE EIPO-PREDU,
          ZBDESC(25), "ADD BY ALEXS 15-DES-2015
          LOEKZ LIKE EKPO-LOEKZ,
          BUKRS LIKE EKKO-BUKRS, "add for new company
          EKORG LIKE EKKO-EKORG, " Added by William at 12.04.2021
       END OF IT_TRACK.

DATA : BEGIN OF ZRBKP OCCURS 0,
        EBELN LIKE EKBE-EBELN,
        EBELP LIKE EKBE-EBELP,
        BUDAT LIKE RBKP-BUDAT,
        BELNR LIKE EKBE-BELNR,
        BUZEI LIKE EKBE-BUZEI,
        WAERS LIKE RBKP-WAERS,
        RMWWR LIKE RBKP-RMWWR,
        HBKID LIKE RBKP-HBKID,
        ZFBDT LIKE RBKP-ZFBDT,
        ZBD1T LIKE RBKP-ZBD1T,
        GJAHR LIKE RBKP-GJAHR,
        STBLG LIKE RBKP-STBLG,      "DOCUMENT REVERSAL
        STJAH LIKE RBKP-STJAH,      "DOCUMENT YEAR
        AWKEY(40),
       END OF ZRBKP.

DATA: BEGIN OF IT_EIKP OCCURS 0,
        NACNU TYPE EIPO-NACNU,
        NACD2 TYPE EIPO-NACD2,
        NACDA TYPE EIPO-NACDA,
        PRONU TYPE EIPO-PRONU,
        PRODA TYPE EIPO-PRODA,
        NACN4 TYPE EIPO-NACN4,
        NACN2 TYPE EIPO-NACN2,
        NAUE2 TYPE EIPO-NAUE2,
        TEXT1 TYPE EIPO-TEXT1,
        TEXT2 TYPE EIPO-TEXT2,
        TEXT3 TYPE EIPO-TEXT3,
        NACN5 TYPE EIPO-NACN5,
        NACN3 TYPE EIPO-NACN3,
        NACD3 TYPE EIPO-NACD3,
        NAUE3 TYPE EIPO-NAUE3,
        PREFN TYPE EIPO-PREFN,
        PREDU TYPE EIPO-PREDU,
        EXNUM TYPE EIPO-EXNUM,
        EXPOS TYPE EIPO-EXPOS,
        REFNR TYPE EIKP-REFNR,
      END OF IT_EIKP.

DATA : BEGIN OF IT_EIPO OCCURS 0,
          EBELN LIKE EKKO-EBELN,
          EBELP LIKE EKPO-EBELP,
          EXNUM LIKE EIPO-EXNUM,
          EXPOS LIKE EIPO-EXPOS,
        END OF IT_EIPO.

DATA :ZBKPF LIKE STANDARD TABLE OF BKPF WITH HEADER LINE,
       AMT_IN  TYPE WMTO_S-AMOUNT,
       AMT_DIS TYPE WMTO_S-AMOUNT,
       Z101   LIKE MSEG-MENGE,
       Z102   LIKE MSEG-MENGE,
       TOTGR  LIKE MSEG-MENGE,
       V_CHARG LIKE EKET-CHARG,
       Z_BATCH TYPE TDLINE,
       V_AUTHOR(1) VALUE 'N'.

DATA :TMP_TRACK LIKE IT_TRACK OCCURS 0 WITH HEADER LINE.

DATA: KDY_VAL_ALL(36) VALUE '/110/120/130/380/210/215/220/610/310',
      KDY_VAL_TWO(8)  VALUE '/110/310',
      KDY_VAL_ONE(4)  VALUE '/310'.       "\BE 151610/1996

FIELD-SYMBOLS : <FS_ITEM1> LIKE LINE OF IT_TRACK,
                <FS_ITEM2> LIKE LINE OF IT_TRACK.

RANGES : P_ELIKZ FOR EKPO-ELIKZ.

" Added by William at 07.08.2020 (to support dowload data)
DATA: LT_DBCON               LIKE DBCON OCCURS 0 WITH HEADER LINE,
      LV_DBS_CONNECTION      TYPE DBCON-CON_NAME.
" End added by William at 07.08.2020

*---STANDARD SELECTION SCREEN
SELECTION-SCREEN BEGIN OF BLOCK PO WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BUKRS FOR EKKO-BUKRS.  "add for new company
SELECT-OPTIONS: S_EKORG FOR EKKO-EKORG.  " Added by William at 12.04.2021
SELECT-OPTIONS: S_EBELN FOR EKKO-EBELN.
SELECT-OPTIONS: S_LIFNR FOR LFA1-LIFNR.
SELECT-OPTIONS: S_BEDAT FOR EKKO-BEDAT.
SELECT-OPTIONS: S_MATNR FOR MARA-MATNR.
SELECT-OPTIONS: S_EINDT FOR EKET-EINDT.
SELECT-OPTIONS: S_NACD2 FOR EIPO-NACD2.
SELECT-OPTIONS: S_NACNU FOR EIPO-NACNU.
SELECT-OPTIONS: S_NACN3 FOR EIPO-NACN3.
SELECTION-SCREEN END OF BLOCK PO.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-002.
PARAMETERS: R1 RADIOBUTTON GROUP RAD1 DEFAULT 'X'.
PARAMETERS: R2 RADIOBUTTON GROUP RAD1.
PARAMETERS: R3 RADIOBUTTON GROUP RAD1.
SELECTION-SCREEN END OF BLOCK B1.

" Added by William at 07.08.2020 (to support download data)
SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
PARAMETERS: P_SCR RADIOBUTTON GROUP TGT DEFAULT 'X',
            P_OLP RADIOBUTTON GROUP TGT.
SELECTION-SCREEN END OF BLOCK BLOCK3.
" End added by William at 20.07.2020

" Added by William at 07.08.2020 (check authorization for OLAP)

AT SELECTION-SCREEN OUTPUT.
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'P_OLP'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  " End added by William at 07.08.2020

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM CEK_AUTHOR.
  " Modified by William at 07.08.2020 (to support download data)
  IF P_SCR = 'X'.
    PERFORM SET_ALV.
  ELSEIF P_OLP = 'X'.
    PERFORM TO_OLAP.
  ENDIF.
  " End modified by William at 07.08.2020 (to support download data)

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  IF R2 IS NOT INITIAL.
    P_ELIKZ-SIGN = 'I'.
    P_ELIKZ-OPTION = 'NE'.
    P_ELIKZ-LOW = 'X'.
    APPEND P_ELIKZ.
  ELSEIF R3 IS NOT INITIAL.
    P_ELIKZ-SIGN = 'I'.
    P_ELIKZ-OPTION = 'EQ'.
    P_ELIKZ-LOW = 'X'.
    APPEND P_ELIKZ.
  ENDIF.

  "FILTER PIB NO
  IF S_NACN3 IS NOT INITIAL.
    SELECT EKKO~EBELN
           EIPO~EXNUM
           EIPO~EXPOS
    FROM EIPO INNER JOIN EKKO ON EIPO~EXNUM = EKKO~EXNUM
      INTO CORRESPONDING FIELDS OF TABLE IT_EIPO
      WHERE NACN3 IN S_NACN3 AND NACD2 IN S_NACD2 AND NACNU IN S_NACNU AND BUKRS IN S_BUKRS. "add for new company

    IF IT_EIPO[] IS NOT INITIAL.
      LOOP AT IT_EIPO.
        IT_EIPO-EBELP = IT_EIPO-EXPOS+1(5).
        MODIFY IT_EIPO.
      ENDLOOP.
      SELECT  EKPO~EBELN AS EBELN EKPO~EBELP AS EBELP EKPO~EBELP AS JEBELP
              EKPO~WERKS AS WERKS " Added by William at 07.08.2020
              EKPO~LOEKZ AS LOEKZ EKPO~MATNR AS MATNR EKPO~TXZ01 AS TXZ01
              EKPO~MENGE AS MENGE EKPO~NETPR AS NETPR EKPO~PEINH AS PEINH
              EKPO~ELIKZ AS ELIKZ EKKO~LIFNR AS LIFNR EKKO~BEDAT AS BEDAT
              EKKO~EXNUM AS EXNUM EKET~EINDT AS EINDT EKKO~KNUMV AS KNUMV
              EKKO~WAERS AS WAERS LFA1~NAME1 AS NAME1 EKPO~MEINS EKKO~BUKRS AS BUKRS "add for new company
              EKKO~EKORG AS EKORG " Added by William at 12.04.2021
         INTO CORRESPONDING FIELDS OF TABLE IT_TRACK
         FROM EKPO INNER JOIN EKKO ON EKPO~EBELN = EKKO~EBELN
                   INNER JOIN EKET ON EKPO~EBELN = EKET~EBELN AND EKPO~EBELP = EKET~EBELP
                   INNER JOIN LFA1 ON LFA1~LIFNR = EKKO~LIFNR
         FOR ALL ENTRIES IN IT_EIPO
         WHERE EKKO~EBELN = IT_EIPO-EBELN AND EKPO~EBELP = IT_EIPO-EBELP AND
               EKKO~EKORG IN S_EKORG AND EKKO~BSTYP = 'F' AND EKKO~LIFNR <> ' ' AND EKPO~LOEKZ NE 'L' AND " Modified by William at 12.04.2021 (change POrg. baaed on parameter)
               EKPO~EBELN IN S_EBELN AND EKKO~LIFNR IN S_LIFNR AND EKKO~BEDAT IN S_BEDAT AND
               EKPO~MATNR IN S_MATNR AND EKET~EINDT IN S_EINDT AND EKPO~ELIKZ IN P_ELIKZ AND EKKO~BUKRS IN S_BUKRS. "add for new company
      IF SY-SUBRC <> 0.
        MESSAGE 'DATA NOT FOUND' TYPE 'S'.
      ENDIF.
    ELSE.
      MESSAGE 'DATA NOT FOUND' TYPE 'S'.
    ENDIF.
  ELSEIF S_NACD2 IS NOT INITIAL OR S_NACNU IS NOT INITIAL.
    SELECT EKKO~EBELN
           EIPO~EXNUM
           EIPO~EXPOS
    FROM EIPO INNER JOIN EKKO ON EIPO~EXNUM = EKKO~EXNUM
      INTO CORRESPONDING FIELDS OF TABLE IT_EIPO
      WHERE NACD2 IN S_NACD2 AND NACNU IN S_NACNU AND BUKRS IN S_BUKRS. "add for new company

    IF IT_EIPO[] IS NOT INITIAL.
      LOOP AT IT_EIPO.
        IT_EIPO-EBELP = IT_EIPO-EXPOS+1(5).
        MODIFY IT_EIPO.
      ENDLOOP.
      SELECT  EKPO~EBELN AS EBELN EKPO~EBELP AS EBELP EKPO~EBELP AS JEBELP
              EKPO~WERKS AS WERKS " Added by William at 07.08.2020
              EKPO~LOEKZ AS LOEKZ EKPO~MATNR AS MATNR EKPO~TXZ01 AS TXZ01
              EKPO~MENGE AS MENGE EKPO~NETPR AS NETPR EKPO~PEINH AS PEINH
              EKPO~ELIKZ AS ELIKZ EKKO~LIFNR AS LIFNR EKKO~BEDAT AS BEDAT
              EKKO~EXNUM AS EXNUM EKET~EINDT AS EINDT EKKO~KNUMV AS KNUMV
              EKKO~WAERS AS WAERS LFA1~NAME1 AS NAME1 EKPO~MEINS EKKO~BUKRS AS BUKRS "add for new company
              EKKO~EKORG AS EKORG " Added by William at 12.04.2021
         INTO CORRESPONDING FIELDS OF TABLE IT_TRACK
         FROM EKPO INNER JOIN EKKO ON EKPO~EBELN = EKKO~EBELN
                   INNER JOIN EKET ON EKPO~EBELN = EKET~EBELN AND EKPO~EBELP = EKET~EBELP
                   INNER JOIN LFA1 ON LFA1~LIFNR = EKKO~LIFNR
         FOR ALL ENTRIES IN IT_EIPO
         WHERE EKKO~EBELN = IT_EIPO-EBELN AND EKPO~EBELP = IT_EIPO-EBELP AND
               EKKO~EKORG IN S_EKORG AND EKKO~BSTYP = 'F' AND EKKO~LIFNR <> ' ' AND EKPO~LOEKZ NE 'L' AND " Modified by William at 12.04.2021 (change POrg. baaed on parameter)
               EKPO~EBELN IN S_EBELN AND EKKO~LIFNR IN S_LIFNR AND EKKO~BEDAT IN S_BEDAT AND
               EKPO~MATNR IN S_MATNR AND EKET~EINDT IN S_EINDT AND EKPO~ELIKZ IN P_ELIKZ AND EKKO~BUKRS IN S_BUKRS. "add for new company
      IF SY-SUBRC <> 0.
        MESSAGE 'DATA NOT FOUND' TYPE 'S'.
      ENDIF.
    ELSE.
      MESSAGE 'DATA NOT FOUND' TYPE 'S'.
    ENDIF.

  ELSE.
    SELECT EKPO~EBELN AS EBELN EKPO~EBELP AS EBELP EKPO~EBELP AS JEBELP
           EKPO~WERKS AS WERKS " Added by William at 07.08.2020
           EKPO~LOEKZ AS LOEKZ EKPO~MATNR AS MATNR EKPO~TXZ01 AS TXZ01
           EKPO~MENGE AS MENGE EKPO~NETPR AS NETPR EKPO~PEINH AS PEINH
           EKPO~ELIKZ AS ELIKZ EKKO~LIFNR AS LIFNR EKKO~BEDAT AS BEDAT
           EKKO~EXNUM AS EXNUM EKET~EINDT AS EINDT EKKO~KNUMV AS KNUMV
           EKKO~WAERS AS WAERS LFA1~NAME1 AS NAME1 EKPO~MEINS EKKO~BUKRS AS BUKRS "add for new company
           EKKO~EKORG AS EKORG " Added by William at 12.04.2021
    INTO CORRESPONDING FIELDS OF TABLE IT_TRACK
    FROM EKPO INNER JOIN EKKO ON EKPO~EBELN = EKKO~EBELN
              INNER JOIN EKET ON EKPO~EBELN = EKET~EBELN AND EKPO~EBELP = EKET~EBELP
              INNER JOIN LFA1 ON LFA1~LIFNR = EKKO~LIFNR
    WHERE EKKO~EKORG IN S_EKORG AND EKKO~BSTYP = 'F' AND EKKO~LIFNR <> ' ' AND EKPO~LOEKZ NE 'L' AND  " Modified by William at 12.04.2021 (change POrg. baaed on parameter)
          EKPO~EBELN IN S_EBELN AND EKKO~LIFNR IN S_LIFNR AND
          EKKO~BEDAT IN S_BEDAT AND EKPO~MATNR IN S_MATNR AND
          EKET~EINDT IN S_EINDT AND EKPO~ELIKZ IN P_ELIKZ AND EKKO~BUKRS IN S_BUKRS. "add for new company
  ENDIF.

  IF IT_TRACK[] IS NOT INITIAL.
    SELECT EIPO~NACNU EIPO~NACD2 EIPO~NACDA EIPO~PRONU EIPO~PRODA EIPO~NACN4 EIPO~NACN2 EIPO~NAUE2
           EIPO~TEXT1 EIPO~TEXT2 EIPO~TEXT3 EIPO~NACN5 EIPO~NACN3 EIPO~NACD3 EIPO~NAUE3 EIPO~PREFN EIPO~PREDU EIPO~EXNUM EIKP~REFNR EIPO~EXPOS
     INTO CORRESPONDING FIELDS OF TABLE IT_EIKP
     FROM EIPO INNER JOIN EIKP ON EIPO~EXNUM = EIKP~EXNUM
     FOR ALL ENTRIES IN IT_TRACK
     WHERE EIPO~EXNUM = IT_TRACK-EXNUM AND EIPO~EXPOS = IT_TRACK-JEBELP AND EIKP~REFNR = IT_TRACK-EBELN.

    LOOP AT IT_EIKP.
      CLEAR IT_TRACK.
      IT_TRACK-NACNU = IT_EIKP-NACNU.
      IT_TRACK-NACD2 = IT_EIKP-NACD2.
      IT_TRACK-NACDA = IT_EIKP-NACDA.
      IT_TRACK-PRONU = IT_EIKP-PRONU.
      IT_TRACK-PRODA = IT_EIKP-PRODA.
      IT_TRACK-NACN4 = IT_EIKP-NACN4.
      IT_TRACK-NACN2 = IT_EIKP-NACN2.
      IT_TRACK-NAUE2 = IT_EIKP-NAUE2.
      IT_TRACK-TEXT1 = IT_EIKP-TEXT1.
      IT_TRACK-TEXT2 = IT_EIKP-TEXT2.
      IT_TRACK-TEXT3 = IT_EIKP-TEXT3.
      IT_TRACK-NACN5 = IT_EIKP-NACN5.
      IT_TRACK-NACN3 = IT_EIKP-NACN3.
      IT_TRACK-NACD3 = IT_EIKP-NACD3.
      IT_TRACK-NAUE3 = IT_EIKP-NAUE3.
      IT_TRACK-PREFN = IT_EIKP-PREFN.
      IT_TRACK-PREDU = IT_EIKP-PREDU.
      MODIFY IT_TRACK TRANSPORTING NACNU  NACD2 NACDA PRONU PRODA NACN4 NACN2 NAUE2 TEXT1 TEXT2 TEXT3 NACN5 NACN3 NACD3 NAUE3 PREFN PREDU
                      WHERE EXNUM = IT_EIKP-EXNUM AND JEBELP = IT_EIKP-EXPOS AND EBELN = IT_EIKP-REFNR.
    ENDLOOP.
    SORT IT_TRACK ASCENDING BY EBELN EBELP JEBELP.

    DELETE ADJACENT DUPLICATES FROM IT_TRACK COMPARING EBELN EBELP.

    SELECT RBKP~BUDAT AS BUDAT
           RBKP~WAERS AS WAERS
           RBKP~RMWWR AS RMWWR
           RBKP~HBKID AS HBKID
           RBKP~ZBD1T AS ZBD1T
           RBKP~ZFBDT AS ZFBDT
           RBKP~GJAHR AS GJAHR
           EKBE~EBELN AS EBELN
           EKBE~EBELP AS EBELP
           EKBE~BELNR AS BELNR
           EKBE~BUZEI AS BUZEI
   FROM RBKP
   JOIN EKBE ON RBKP~BELNR = EKBE~BELNR
            AND RBKP~GJAHR = EKBE~GJAHR         "Added by Akbar 12.02.2019 (untuk menyesuaikan fiscal year)
   JOIN EKKO ON EKKO~EBELN = EKBE~EBELN
   INTO CORRESPONDING FIELDS OF TABLE ZRBKP
   FOR ALL ENTRIES IN IT_TRACK
   WHERE EKBE~BEWTP = 'Q' AND EKBE~EBELN = IT_TRACK-EBELN AND EKBE~EBELP = IT_TRACK-EBELP.

    SORT ZRBKP ASCENDING BY EBELN EBELP BELNR.
    TMP_TRACK[] = IT_TRACK[].
    LOOP AT ZRBKP.
      READ TABLE IT_TRACK WITH  KEY EBELN = ZRBKP-EBELN  EBELP = ZRBKP-EBELP.
      MOVE-CORRESPONDING IT_TRACK TO TMP_TRACK.
      CONCATENATE ZRBKP-BELNR ZRBKP-GJAHR INTO ZRBKP-AWKEY.
      TMP_TRACK-BUDAT = ZRBKP-BUDAT.
      TMP_TRACK-IWAERS = ZRBKP-WAERS.
      TMP_TRACK-RMWWR = ZRBKP-RMWWR.
      TMP_TRACK-HBKID = ZRBKP-HBKID.
      TMP_TRACK-TOP   = ZRBKP-ZFBDT + ZRBKP-ZBD1T.
      TMP_TRACK-BELNR = ZRBKP-BELNR.
      TMP_TRACK-BUZEI = ZRBKP-BUZEI.
      TMP_TRACK-GJAHR = ZRBKP-GJAHR.
      TMP_TRACK-AWKEY = ZRBKP-AWKEY.
      APPEND TMP_TRACK.
      DELETE TMP_TRACK WHERE EBELN = ZRBKP-EBELN AND EBELP = ZRBKP-EBELP AND BUDAT EQ '00000000'.
    ENDLOOP.  "ENDLOOP AT ZRBKP.

    DELETE TMP_TRACK WHERE BUDAT EQ '00000000'.
    DELETE ADJACENT DUPLICATES FROM TMP_TRACK COMPARING BELNR.

    LOOP AT TMP_TRACK.
      MOVE-CORRESPONDING TMP_TRACK TO IT_TRACK.
      APPEND IT_TRACK.
      DELETE IT_TRACK WHERE BUDAT EQ '00000000' AND EBELN = TMP_TRACK-EBELN AND EBELP = TMP_TRACK-EBELP.
    ENDLOOP.


    "GET Payment Date, Payment Doc. Number, Payment Amount
    SELECT  BKPF~BELNR AS BELNR
            BKPF~AWKEY AS AWKEY
    FROM BKPF
      INTO CORRESPONDING FIELDS OF TABLE ZBKPF
      FOR ALL ENTRIES IN IT_TRACK
      WHERE AWKEY = IT_TRACK-AWKEY AND AWTYP = 'RMRP'.

    IF LINES( ZBKPF ) > 0.
      LOOP AT ZBKPF.
        LOOP AT IT_TRACK WHERE AWKEY = ZBKPF-AWKEY.
          SELECT DISTINCT AUGDT AUGBL WRBTR
            FROM BSAK
            INTO (IT_TRACK-AUGDT, IT_TRACK-AUGBL, IT_TRACK-WRBTR)
            WHERE BSAK~BELNR = ZBKPF-BELNR.
          ENDSELECT.
          MODIFY IT_TRACK.
        ENDLOOP.  "ENDLOOP IT_TRACK
      ENDLOOP.  "ENDLOOP ZBKPF
    ENDIF.  "ENDIF ZBKPF > 0

  ENDIF.
  "DELETE REVERSAL ACCOUNTING DOCUMENT
  CLEAR: ZRBKP. REFRESH: ZRBKP.

  SELECT  RBKP~BELNR AS BELNR
          RBKP~STBLG AS STBLG
          RBKP~STJAH AS STJAH
    FROM RBKP
    INTO CORRESPONDING FIELDS OF TABLE ZRBKP
    FOR ALL ENTRIES IN IT_TRACK
    WHERE BELNR = IT_TRACK-BELNR.

  LOOP AT ZRBKP WHERE STBLG NE ''.
    DELETE IT_TRACK WHERE BELNR = ZRBKP-STBLG AND GJAHR = ZRBKP-STJAH.
  ENDLOOP.

  LOOP AT IT_TRACK.
    "GET NET PRICE SESUAI DISPLAY
    CLEAR : AMT_IN, AMT_DIS.
    MOVE IT_TRACK-NETPR TO AMT_IN.

    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY        = IT_TRACK-WAERS
        AMOUNT_INTERNAL = AMT_IN
      IMPORTING
        AMOUNT_DISPLAY  = AMT_DIS.

    IT_TRACK-NETPR = AMT_DIS.
    MODIFY IT_TRACK.
    "END GET NET PRICE SESUAI DISPLAY


    "GET BEA MASUK
    SELECT KONV~KWERT AS KWERT
      FROM KONV
      INTO IT_TRACK-KWERT
      WHERE KONV~KNUMV = IT_TRACK-KNUMV AND KONV~KPOSN = IT_TRACK-EBELP AND KONV~KSCHL = 'ZT07'.
      CLEAR : AMT_IN, AMT_DIS.
      MOVE IT_TRACK-KWERT TO AMT_IN.

      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
          CURRENCY        = IT_TRACK-WAERS
          AMOUNT_INTERNAL = AMT_IN
        IMPORTING
          AMOUNT_DISPLAY  = AMT_DIS.

      MOVE AMT_DIS TO IT_TRACK-KWERT.
      IT_TRACK-ZKAWRT = ( IT_TRACK-KWERT / ( ( IT_TRACK-NETPR / IT_TRACK-PEINH ) * IT_TRACK-MENGE ) ) * 100.
      MODIFY IT_TRACK.
    ENDSELECT.
    "END GET BEA MASUK

    "GET DELIVERY QTY
    SELECT SUM( MSEG~ERFMG ) INTO Z101
      FROM MSEG
      WHERE EBELN = IT_TRACK-EBELN AND EBELP = IT_TRACK-EBELP AND BWART = '101'.

    SELECT SUM( MSEG~ERFMG ) INTO Z102
      FROM MSEG
      WHERE EBELN = IT_TRACK-EBELN AND EBELP = IT_TRACK-EBELP AND BWART = '102'.

    TOTGR = Z101 - Z102.

    IT_TRACK-DMENGE = TOTGR.
    MODIFY IT_TRACK.
    "END GET DELIVERY QTY

    "GET PRICE SESUAI DISPLAY
    CLEAR : AMT_IN, AMT_DIS.
    MOVE IT_TRACK-RMWWR TO AMT_IN.

    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY        = IT_TRACK-IWAERS
        AMOUNT_INTERNAL = AMT_IN
      IMPORTING
        AMOUNT_DISPLAY  = AMT_DIS.

    IT_TRACK-RMWWR = AMT_DIS.
    MODIFY IT_TRACK.

    CLEAR : AMT_IN, AMT_DIS.
    MOVE IT_TRACK-WRBTR TO AMT_IN.

    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY        = IT_TRACK-IWAERS
        AMOUNT_INTERNAL = AMT_IN
      IMPORTING
        AMOUNT_DISPLAY  = AMT_DIS.

    IT_TRACK-WRBTR = AMT_DIS.
    MODIFY IT_TRACK.
    "END GET PRICE SESUAI DISPLAY

    "GET BATCH DESC
    CLEAR: V_CHARG,Z_BATCH.
    IF IT_TRACK-MATNR = 'RPV' OR IT_TRACK-MATNR = 'RPC' OR IT_TRACK-MATNR = 'RPM'
    OR IT_TRACK-MATNR = 'CPV' OR IT_TRACK-MATNR = 'CPC' OR IT_TRACK-MATNR = 'CPM'.  " Added by William at 06.10.2022 (Add new material OPP CPP)
      SELECT SINGLE CHARG INTO V_CHARG FROM EKET WHERE EBELN = IT_TRACK-EBELN AND EBELP = IT_TRACK-EBELP.
      IF SY-SUBRC NE 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'Z_GET_BATCH_DESC'
      EXPORTING
        CHARG = V_CHARG
        MATNR = IT_TRACK-MATNR
      IMPORTING
        ZDESC = Z_BATCH.
    IT_TRACK-ZBDESC = Z_BATCH.
    MODIFY IT_TRACK.
    "END GET BATCH DESC
  ENDLOOP.

ENDFORM.                    "GET_DATA

*&--------------------------------------------------------------------*
*&Set Layout Report
FORM SET_ALV.
  CLEAR : WA_LAYOUT.
  DATA : G_SAVE VALUE 'A'.
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_SELINFOS = 'X'.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT_BOX USING WA_LAYOUT.
  PERFORM EVENTTAB_BUILD USING T_EVENTS[].
  WA_VARIANTE-REPORT = D_REPID.
  PERFORM BUILD_FIELDCAT.
  PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].
  PERFORM F_SORT.
*  PERFORM BUILD_SORTCAT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
*     I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
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
      T_OUTTAB                 = IT_TRACK.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "SET_ALV

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT.
  REFRESH T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_WT_FRZ  USING 'IT_TRACK' :
        'LIFNR' '' '' C_NO '10' 'Vendor' '' 'X' '',
        'NAME1' '' '' C_NO '40' 'Vendor Name ' '' '' '',
        'EKORG'   ''  ''  C_NO  '4'   'Purchasing Organization'  ''  ''   '', " Added by William at 12.04.2021
        'BUKRS'   ''  ''  C_NO  '12'   'Company Code'  ''  ''   '', "add for new company
        'WERKS'   ''  ''  C_NO  '8'   'Plant'  ''  ''   '',  " Added by William at 07.08.2020
        'EBELN' '' '' C_NO '10' 'PO Number' '' 'X' '',
        'EBELP'   ''  ''  C_NO  '5'   'PO Item'  ''   ''   'CENTER',
        'BEDAT'   ''  ''  C_NO  '12'   'PO Date'  ''  ''   '',
        'EINDT'   ''  ''  C_NO  '12'   'Delivery Date'  ''  ''   ''.

  PERFORM F_ALV_FIELDCATG  USING 'IT_TRACK' :
        'MATNR'   ''  ''  C_NO  '18'   'Material Number'  ''  ''   '',
        'ZBDESC'   ''  ''  C_NO  '25'   'Material Type Description'  ''  ''   '',
        'TXZ01'   ''  ''  C_NO  '40'   'Description'  ''  ''   '',
        'MENGE'   ''  ''  C_NO  '13'   'Qty'  ''  ''   'RIGHT',
        'MEINS'   ''  ''  C_NO  '4'   'UoM'  ''  ''   'CENTER',
        'NACNU'   ''  ''  C_NO  '40'   'L/C No'  ''  ''   '',
        'NACDA'   ''  ''  C_NO  '12'   'L/C Date'  ''  ''   '',
        'PRONU'   ''  ''  C_NO  '40'   'Invoice No'  ''  ''   '',
        'PRODA'   ''  ''  C_NO  '12'   'Invoice Date'  ''  ''   '',
        'BUDAT'   ''  ''  C_NO  '12'   'Invoice Posting Date'  ''  ''   '',
        'IWAERS'  ''  ''  C_NO  '5'   'Invoice Curr.'  ''  ''   '',
        'RMWWR'   ''  ''  C_NO  '40'   'Invoice Amount'  ''  ''   '',
        'HBKID'   ''  ''  C_NO  '5'   'Bank Devisa'  ''  ''   '',
        'TOP'     ''  ''  C_NO  '12'   'TOP(Tanggal Jatuh Tempo)'  ''  ''   '',
        'DMENGE'  ''  ''  C_NO  '13'   'Delivery Qty'  ''  ''   '',
        'NACN4'   ''  ''  C_NO  '40'   'Vessel - Voyage'  ''  ''   '',
        'NACN2'   ''  ''  C_NO  '40'   'B/L No'  ''  ''   '',
        'NAUE2'   ''  ''  C_NO  '40'   'ETD'  ''  ''   '',
        'NACD2'   ''  ''  C_NO  '12'   'ETA'  ''  ''   '',
        'TEXT1'   ''  ''  C_NO  '13'   'Container Qty'  ''  ''   '',
        'TEXT2'   ''  ''  C_NO  '2'   'Container Size'  ''  ''   '',
        'NACN5'   ''  ''  C_NO  '25'   'Packing Type'  ''  ''   '',
        'NACN3'   ''  ''  C_NO  '25'   'PIB'  ''  ''   '',
        'NACD3'   ''  ''  C_NO  '12'   'PIB date'  ''  ''   '',
        'NAUE3'   ''  ''  C_NO  '12'   'SPPB'  ''  ''   '',
        'ZKAWRT'   ''  ''  C_NO  '15'   'Bea Masuk(%)'  ''  ''   'CENTER',
        'TEXT3'   ''  ''  C_NO  '50'   'EMKL'  ''  ''   '',
        'AUGDT'   ''  ''  C_NO  '12'   'Payment Date'  ''  ''   '',
        'AUGBL'   ''  ''  C_NO  '10'   'Payment Doc. Number'  ''  ''   '',
        'WRBTR'   ''  ''  C_NO  '13'   'Payment Amount'  ''  ''   '',
        'PREFN'   ''  ''  C_NO  '12'   'NoReg. SSPCP'  ''  ''   '',
        'PREDU'   ''  ''  C_NO  '12'   'SSPCP Date'  ''  ''   ''.

  IF     V_AUTHOR NE 'Y'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'RMWWR'.
    DELETE T_FIELDCAT WHERE FIELDNAME = 'WRBTR'.
  ENDIF.
ENDFORM.                    " BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*
*       text - SORT KODE VENDOR DAN PO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SORT .
  T_SORT-SPOS        = '1'.
  T_SORT-FIELDNAME   = 'LIFNR'.
  T_SORT-TABNAME     = 'IT_TRACK'.
  APPEND T_SORT.

  T_SORT-SPOS        = '2'.
  T_SORT-FIELDNAME   = 'EBELN'.
  T_SORT-TABNAME     = 'IT_TRACK'.
  APPEND T_SORT.
ENDFORM.                    " F_SORT

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT_BOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM LAYOUT_INIT_BOX USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.
  RS_LAYOUT-INFO_FIELDNAME     = 'LINE_COLOR'.
ENDFORM.                    "LAYOUT_INIT_BOX

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.

  CLEAR LS_LINE.
  REFRESH LT_TOP_OF_PAGE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = 'Report Purchase Order with ETA Date'.  " Modified by William at 12.04.2021
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text Download File
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      I_LOGO             = ' '
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
  DATA : LS_EVENT TYPE SLIS_ALV_EVENT.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = RT_EVENTS.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                            INTO LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_UCOMM     text
*      -->FU_SELFIELD  text
*----------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&IC1'.
      READ TABLE IT_TRACK INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_ITEM1>.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_TRACK-EBELN'.
          IF <FS_ITEM1>-EBELN NE ' '.
            SET PARAMETER ID 'BES' FIELD <FS_ITEM1>-EBELN.
            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.

      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_TRACK-LIFNR'.
          IF <FS_ITEM1>-LIFNR NE ' '.
            SET PARAMETER ID 'LIF' FIELD <FS_ITEM1>-LIFNR.
            SET PARAMETER ID 'EKO' FIELD 'TPOI'.
            SET PARAMETER ID 'BUK' FIELD '9999'.
            SET PARAMETER ID 'KDY' FIELD KDY_VAL_ALL.
            CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  CEK_AUTHOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_AUTHOR .
  DATA: BEGIN OF IT_EKKO OCCURS 0,
        BSART LIKE EKKO-BSART,
        EBELN LIKE EKKO-EBELN,
        DELET(1),
    END OF IT_EKKO.

  DATA: BEGIN OF IT_BSART OCCURS 0,
        BSART LIKE EKKO-BSART,
        DELET(1),
    END OF IT_BSART.

  REFRESH: IT_EKKO, IT_BSART.

  IF IT_TRACK[] IS INITIAL.
    EXIT.
  ENDIF.

  SELECT BSART EBELN INTO TABLE IT_EKKO FROM EKKO
    FOR ALL ENTRIES IN IT_TRACK WHERE EBELN = IT_TRACK-EBELN.

  IF SY-SUBRC NE 0.
    EXIT.
  ELSE.
    V_AUTHOR = 'Y'.
  ENDIF.

  LOOP AT IT_EKKO.
    IT_BSART-BSART = IT_EKKO-BSART.
    COLLECT IT_BSART.
  ENDLOOP.

  LOOP AT IT_BSART.
    AUTHORITY-CHECK OBJECT 'M_BEST_BSA'
             ID 'ACTVT' FIELD '03'
             ID 'BSART' FIELD IT_BSART-BSART.
    IF SY-SUBRC NE 0.
      IT_BSART-DELET = 'X'.
      MODIFY IT_BSART.
      IT_EKKO-DELET = 'X'.
      MODIFY IT_EKKO TRANSPORTING DELET WHERE BSART = IT_BSART-BSART.
    ENDIF.
  ENDLOOP.


  LOOP AT IT_BSART WHERE DELET NE 'X'.
    AUTHORITY-CHECK OBJECT 'M_BEST_BSA'
             ID 'ACTVT' FIELD '09'
             ID 'BSART' FIELD IT_BSART-BSART.
    IF SY-SUBRC NE 0.
      V_AUTHOR = 'N'.
    ENDIF.
  ENDLOOP.

  LOOP AT IT_EKKO WHERE DELET = 'X'.
    DELETE IT_TRACK WHERE EBELN = IT_EKKO-EBELN.
  ENDLOOP.
ENDFORM.                    " CEK_AUTHOR

*&---------------------------------------------------------------------*
*&      Form  TO_OLAP
*&---------------------------------------------------------------------*
*       Added by William at 07.08.2020 (to support download data)
*----------------------------------------------------------------------*
FORM TO_OLAP.
  LV_DBS_CONNECTION = 'TRIASDB04'.

  SELECT SINGLE * INTO LT_DBCON
  FROM DBCON
  WHERE CON_NAME = LV_DBS_CONNECTION.

  IF LT_DBCON-DBMS = 'MSS'.
    TRY.

      EXEC SQL.
        CONNECT TO :LV_DBS_CONNECTION
      ENDEXEC.

      IF SY-SUBRC <> 0.
        RAISE EXCEPTION TYPE CX_SY_NATIVE_SQL_ERROR.
      ENDIF.

      EXEC SQL.
        DELETE FROM XMM052
      ENDEXEC.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

      LOOP AT IT_TRACK.
        IF IT_TRACK-BEDAT IS INITIAL.
          IT_TRACK-BEDAT = '19000101'.
        ENDIF.
        IF IT_TRACK-EINDT IS INITIAL.
          IT_TRACK-EINDT = '19000101'.
        ENDIF.
        IF IT_TRACK-NACDA IS INITIAL.
          IT_TRACK-NACDA = '19000101'.
        ENDIF.
        IF IT_TRACK-PRODA IS INITIAL.
          IT_TRACK-PRODA = '19000101'.
        ENDIF.
        IF IT_TRACK-BUDAT IS INITIAL.
          IT_TRACK-BUDAT = '19000101'.
        ENDIF.
        IF IT_TRACK-TOP IS INITIAL.
          IT_TRACK-TOP = '19000101'.
        ENDIF.
        IF IT_TRACK-NAUE2 IS INITIAL.
          IT_TRACK-NAUE2 = '19000101'.
        ENDIF.
        IF IT_TRACK-NACD2 IS INITIAL.
          IT_TRACK-NACD2 = '19000101'.
        ENDIF.
        IF IT_TRACK-NACD3 IS INITIAL.
          IT_TRACK-NACD3 = '19000101'.
        ENDIF.
        IF IT_TRACK-AUGDT IS INITIAL.
          IT_TRACK-AUGDT = '19000101'.
        ENDIF.
        IF IT_TRACK-PREDU IS INITIAL.
          IT_TRACK-PREDU = '19000101'.
        ENDIF.

        SHIFT IT_TRACK-EBELP LEFT DELETING LEADING '0'.
        SHIFT IT_TRACK-MATNR LEFT DELETING LEADING '0'.

        " Modified by William at 12.04.2021
        EXEC SQL.
          INSERT INTO
            XMM052(VENDOR,
                   VENDORNAME,
                   [PURCH.ORG],
                   COMPANYCODE,
                   PLANT,
                   PONUMBER,
                   POITEM,
                   PODATE,
                   DELIVERYDATE,
                   MATERIALNUMBER,
                   MATTYPEDESCRIPTION,
                   DESCRIPTION,
                   QTY,
                   UOM,
                   LCNO,
                   LCDATE,
                   INVOICENO,
                   INVOICEDATE,
                   INVOICEPOSTINGDATE,
                   INVOICECURR,
                   INVOICEAMOUNT,
                   BANKDEVISA,
                   TOP,
                   DELIVERYQTY,
                   VESSELVOYAGE,
                   BLNO,
                   ETD,
                   ETA,
                   CONTAINERQTY,
                   CONTAINERSIZE,
                   PACKINGTYPE,
                   PIB,
                   PIBDATE,
                   SPPB,
                   BEAMASUK,
                   EMKL,
                   PAYMENTDATE,
                   PAYMENTDOCNUMBER,
                   PAYMENTAMOUNT,
                   NOREGSSPCP,
                   SSPCPDATE)
          VALUES  (:IT_TRACK-LIFNR,
                   :IT_TRACK-NAME1,
                   :IT_TRACK-EKORG,
                   :IT_TRACK-BUKRS,
                   :IT_TRACK-WERKS,
                   :IT_TRACK-EBELN,
                   :IT_TRACK-EBELP,
                   :IT_TRACK-BEDAT,
                   :IT_TRACK-EINDT,
                   :IT_TRACK-MATNR,
                   :IT_TRACK-ZBDESC,
                   :IT_TRACK-TXZ01,
                   :IT_TRACK-MENGE,
                   :IT_TRACK-MEINS,
                   :IT_TRACK-NACNU,
                   :IT_TRACK-NACDA,
                   :IT_TRACK-PRONU,
                   :IT_TRACK-PRODA,
                   :IT_TRACK-BUDAT,
                   :IT_TRACK-IWAERS,
                   :IT_TRACK-RMWWR,
                   :IT_TRACK-HBKID,
                   :IT_TRACK-TOP,
                   :IT_TRACK-DMENGE,
                   :IT_TRACK-NACN4,
                   :IT_TRACK-NACN2,
                   :IT_TRACK-NAUE2,
                   :IT_TRACK-NACD2,
                   :IT_TRACK-TEXT1,
                   :IT_TRACK-TEXT2,
                   :IT_TRACK-NACN5,
                   :IT_TRACK-NACN3,
                   :IT_TRACK-NACD3,
                   :IT_TRACK-NAUE3,
                   :IT_TRACK-ZKAWRT,
                   :IT_TRACK-TEXT3,
                   :IT_TRACK-AUGDT,
                   :IT_TRACK-AUGBL,
                   :IT_TRACK-WRBTR,
                   :IT_TRACK-PREFN,
                   :IT_TRACK-PREDU)
        ENDEXEC.
        " End modified by William at 12.04.2021
      ENDLOOP.

      EXEC SQL.
        COMMIT WORK.
      ENDEXEC.

      EXEC SQL.
        DISCONNECT :LV_DBS_CONNECTION
      ENDEXEC.

      MESSAGE 'Data berhasil di-download!' TYPE 'I'.
    ENDTRY.
  ENDIF.
ENDFORM.                    "TO_OLAP
