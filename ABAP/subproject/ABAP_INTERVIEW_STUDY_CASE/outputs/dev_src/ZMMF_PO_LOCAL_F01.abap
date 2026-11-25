*&---------------------------------------------------------------------*
*&  Include           ZMMF_PO_LOCAL_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  entry_neu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*----------------------------------------------------------------------*
DATA: IS_SAME_OTYPE(1).      "tidak boleh reprint dengan output beda

*&---------------------------------------------------------------------*
*&      Form  ENTRY_NEU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ENT_RETCO  text
*      -->ENT_SCREEN text
*----------------------------------------------------------------------*
FORM ENTRY_NEU USING ENT_RETCO ENT_SCREEN.
  PERFORM CEK_OUTPUT_TYPE.
  IF IS_SAME_OTYPE NE 'X'.
    CLEAR RETCODE.
    XSCREEN = ENT_SCREEN.
    PERFORM F_PROCESSING.
    IF RETCODE NE 0.
      ENT_RETCO = 1.
    ELSE.
      ENT_RETCO = 0.
    ENDIF.
  ENDIF.
ENDFORM.                    "entry_neu

*&---------------------------------------------------------------------*
*&      Form  f_processing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PROCESSING .

  PERFORM F_SELECT_DATA.

  READ TABLE IT_PO INDEX 1.

  PERFORM F_FIND_DATA_VENDOR.

  PERFORM F_FIND_DATA_PLANT.

  PERFORM F_FIND_DATA_SLOC.

  PERFORM F_FIND_DATA_PO_NO.

  PERFORM F_ADDITIONAL_DATA.

  PERFORM F_FIND_ITEM_DATA.

  PERFORM F_GET_INFORECORD.   "case of subcont

  PERFORM F_PO_RETURN.        "case of po return

  PERFORM F_CALL_SMARTFORMS.

ENDFORM.                    " f_processing
*&---------------------------------------------------------------------*
*&      Form  f_find_data_vendor
*&---------------------------------------------------------------------*
*       text

*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_VENDOR.
  DATA : VKTOKK LIKE LFA1-KTOKK,
         VHNUM LIKE ADRC-HOUSE_NUM1.

  SELECT SINGLE LFA1~NAME1
    LFA1~STRAS
    LFA1~ORT01
    LFA1~PSTLZ
    LFA1~TELF1
    LFA1~TELFX
    LFA1~KTOKK "EDIT BY JEFF
    INTO (P_VENDOR, P_ADDRESS,P_ORT01,P_PSTLZ,P_TELP,P_FAX , VKTOKK)
    FROM LFA1
    WHERE LIFNR = IT_PO-LIFNR.

  CONCATENATE P_ORT01 P_PSTLZ INTO P_CITY SEPARATED BY SPACE.
*  EDIT BY JEFF 04-01-2013******************
  IF VKTOKK = 'ZOTI'.
    SELECT SINGLE ADRC~NAME1 STREET HOUSE_NUM1 CITY1 POST_CODE1 TEL_NUMBER FAX_NUMBER
      INTO (P_VENDOR, P_ADDRESS,VHNUM,P_ORT01,P_PSTLZ,P_TELP,P_FAX )
    FROM ADRC
      JOIN EKKO ON EKKO~ADRNR = ADRC~ADDRNUMBER
      JOIN LFA1 ON LFA1~LIFNR = EKKO~LIFNR
    WHERE EBELN = IT_PO-EBELN AND
          LFA1~LIFNR = IT_PO-LIFNR AND
          KTOKK = 'ZOTI'.

    IF P_VENDOR EQ '*'.
      CLEAR P_VENDOR.
    ENDIF.
    IF P_ADDRESS EQ '*'.
      CLEAR P_ADDRESS.
    ENDIF.
    IF VHNUM EQ '*'.
      CLEAR VHNUM.
    ENDIF.
    IF P_ORT01 EQ '*'.
      CLEAR P_ORT01.
    ENDIF.
    IF P_PSTLZ EQ '*'.
      CLEAR P_PSTLZ.
    ENDIF.
    IF P_TELP EQ '*'.
      CLEAR P_TELP.
    ENDIF.
    IF P_FAX EQ '*'.
      CLEAR P_FAX.
    ENDIF.

    CONCATENATE P_ADDRESS VHNUM INTO P_ADDRESS SEPARATED BY SPACE.
    CONCATENATE P_ORT01 P_PSTLZ INTO P_CITY SEPARATED BY SPACE.
  ENDIF.
*  END EDIT BY JEFF 04-01-2013**************

ENDFORM.                    " f_find_data_vendor
*&---------------------------------------------------------------------*
*&      Form  f_find_data_plant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_PLANT .

  SELECT SINGLE T001W~NAME1
    T001W~ADRNR
    FROM T001W
    INTO (P_NAME_WERKS,P_ADRNR)
    WHERE WERKS = IT_PO-WERKS.
  WRITE IT_PO-WERKS TO P_WERKS.

  SELECT SINGLE ADRC~STREET
    ADRC~CITY1
    ADRC~POST_CODE1
    INTO (P_ADDRESS_PLANT, P_CITY1, P_POST_CODE1)
     FROM ADRC WHERE ADDRNUMBER = P_ADRNR.

  CONCATENATE P_CITY1 P_POST_CODE1 INTO P_CITY_PLANT SEPARATED BY SPACE.


ENDFORM.                    " f_find_data_plant
*&---------------------------------------------------------------------*
*&      Form  f_find_Data_sloc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_SLOC .

  CLEAR T001L.
  SELECT SINGLE T001L~LGOBE
    INTO P_LGORT_TEXT
    FROM T001L
    WHERE WERKS = IT_PO-WERKS AND
    LGORT = IT_PO-LGORT.

  WRITE IT_PO-LGORT TO P_LGORT.

ENDFORM.                    " f_find_Data_sloc
*&--------------------------------------------------------------------*
*&      Form  f_find_data_po_no
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_DATA_PO_NO .


  WRITE IT_PO-EBELN TO P_EBELN.

  CONCATENATE IT_PO-AEDAT+6(2) '-' IT_PO-AEDAT+4(2) '-' IT_PO-AEDAT+0(4)
  INTO P_DATE_PO.

  CONCATENATE SY-DATUM+6(2) '-' SY-DATUM+4(2) '-' SY-DATUM+0(4)
  INTO P_DATE_PRT.

  P_DATE_PAY = IT_PO-TEXT1.

ENDFORM.                    " f_find_data_po_no

*&---------------------------------------------------------------------*
*&      Form  f_find_item_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIND_ITEM_DATA.

  DATA : LC_KBETR LIKE KONV-KBETR,
         LC_KBETR2 LIKE KONV-KBETR,   "ADD BY JALU 06.02.2013 - TAMBAH KONDISI SELAIN %
         LC_KWERT LIKE KONV-KWERT.


  DATA : LC_SUBTOTAL LIKE KONV-KWERT,
         LC_SUBDIC   LIKE KONV-KWERT.

  DATA : LC_BASE_AMOUNT LIKE KONV-KWERT.
  DATA : LC_TAX_AMOUNT  LIKE KONV-KWERT,
         LC_TOTAL_ORDER LIKE KONV-KWERT.

  REFRESH : I_ZPO_LOCAL.

  PERFORM F_ADD_KSCHL.


  CLEAR :  LC_SUBTOTAL,
           LC_SUBDIC.

  SORT IT_PO BY EBELN EBELP.
  LOOP AT IT_PO.
    PERFORM F_GET_ITEM_TEXT USING IT_PO-EBELN IT_PO-EBELP
                            CHANGING I_ZPO_LOCAL-ZTEXT.

    WRITE IT_PO-EBELP  TO I_ZPO_LOCAL-ZNO.
    WRITE IT_PO-MENGE  TO I_ZPO_LOCAL-ZMENGE UNIT IT_PO-MEINS LEFT-JUSTIFIED.
    WRITE IT_PO-MEINS  TO I_ZPO_LOCAL-ZMEINS LEFT-JUSTIFIED.
    WRITE IT_PO-MATNR  TO I_ZPO_LOCAL-ZMATNR LEFT-JUSTIFIED.

    CLEAR MAKT.
    SELECT SINGLE MAKTX INTO MAKT-MAKTX FROM MAKT
    WHERE MATNR = IT_PO-MATNR.

    IF MAKT-MAKTX = SPACE.
      WRITE IT_PO-TXZ01 TO I_ZPO_LOCAL-ZDESCRIPTION LEFT-JUSTIFIED.
    ELSE.
      WRITE MAKT-MAKTX  TO I_ZPO_LOCAL-ZDESCRIPTION LEFT-JUSTIFIED.
    ENDIF.
    WRITE IT_PO-BANFN TO I_ZPO_LOCAL-ZPRNO LEFT-JUSTIFIED.
    WRITE IT_PO-BEDNR TO I_ZPO_LOCAL-ZFANO LEFT-JUSTIFIED.

    READ TABLE IT_EKET WITH KEY EBELN = IT_PO-EBELN
                                EBELP = IT_PO-EBELP.
    IF SY-SUBRC EQ 0.
      CONCATENATE IT_EKET-EINDT+6(2) '-' IT_EKET-EINDT+4(2) '-' IT_EKET-EINDT+2(2) INTO
      I_ZPO_LOCAL-ZEINDT.
    ENDIF.

* unit Price
    CLEAR LC_KBETR.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          ( KSCHL = 'PB00' OR KSCHL = 'PBXX' ).
      LC_KBETR = LC_KBETR + IT_KONV-KBETR.
    ENDLOOP.

    WRITE LC_KBETR TO I_ZPO_LOCAL-ZUNITPRICE CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

* unitdisc
    CLEAR : LC_KBETR, LC_KBETR2.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          KSCHL IN R_KSCHL AND KSCHL NE 'HB01'.

*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
      IF IT_KONV-WAERS NE ''.
        LC_KBETR2 = LC_KBETR2 + IT_KONV-KBETR.
        IT_KONV-DISC2 = LC_KBETR2.
      ELSE.
        LC_KBETR = LC_KBETR + IT_KONV-KBETR.
        IT_KONV-DISC1 = LC_KBETR.
      ENDIF.
      MODIFY IT_KONV.
*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
    ENDLOOP.

*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
    LOOP AT IT_KONV WHERE DISC1 NE '0.00' AND KNUMV = IT_PO-KNUMV AND KPOSN = IT_PO-EBELP.
      IT_KONV-DISC1 = IT_KONV-DISC1 / 10.
      WRITE IT_KONV-DISC1 TO I_ZPO_LOCAL-ZUNITDISC EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
      I_ZPO_LOCAL-ZWAERS = '%'.
    ENDLOOP.

    LOOP AT IT_KONV WHERE DISC2 NE '0.00' AND KNUMV = IT_PO-KNUMV AND KPOSN = IT_PO-EBELP.
      DATA  : V_NEWAMOUNT LIKE WMTO_S-AMOUNT.
      CLEAR : V_NEWAMOUNT.
      V_NEWAMOUNT = IT_KONV-DISC2.
      CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
          CURRENCY        = IT_PO-WAERS
          AMOUNT_INTERNAL = V_NEWAMOUNT
        IMPORTING
          AMOUNT_DISPLAY  = V_NEWAMOUNT.
      IT_KONV-DISC2 = V_NEWAMOUNT.
      WRITE IT_KONV-DISC2 TO I_ZPO_LOCAL-ZUNITDISC2 EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
    ENDLOOP.
*--------------------------------------------------------------------*EDIT BY JALU 06.02.2013
*    IF IT_KONV-WAERS = SPACE AND LC_KBETR <> SPACE.
*      LC_KBETR = LC_KBETR / 10.
*      WRITE LC_KBETR TO I_ZPO_LOCAL-ZUNITDISC EXPONENT 2 DECIMALS 2 LEFT-JUSTIFIED.
*      I_ZPO_LOCAL-ZWAERS = '%'.
*
*    ELSEIF LC_KBETR = 0.
*      I_ZPO_LOCAL-ZUNITDISC = ''.
*    ELSE.
*    ENDIF.

*total price
    CLEAR LC_KWERT.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          ( KSCHL = 'PB00' OR KSCHL = 'PBXX' ).

      LC_KWERT = LC_KWERT + IT_KONV-KWERT.
    ENDLOOP.
    WRITE LC_KWERT TO I_ZPO_LOCAL-ZTOTALPRICE CURRENCY IT_PO-WAERS.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

    LC_SUBTOTAL = LC_SUBTOTAL + LC_KWERT.

*total disc
    CLEAR LC_KWERT.
    LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                          KPOSN = IT_PO-EBELP AND
                          KSCHL IN R_KSCHL.

      LC_KWERT = LC_KWERT + IT_KONV-KWERT.
    ENDLOOP.
    WRITE LC_KWERT TO I_ZPO_LOCAL-ZTOTALDISC CURRENCY IT_PO-WAERS NO-GAP.
    CONDENSE I_ZPO_LOCAL-ZTOTALDISC.
    IF LC_KWERT <> 0.
      REPLACE ALL OCCURRENCES OF '-' IN I_ZPO_LOCAL-ZTOTALDISC WITH ' '.
      CONCATENATE '-' I_ZPO_LOCAL-ZTOTALDISC INTO I_ZPO_LOCAL-ZTOTALDISC.
    ENDIF.
    WRITE IT_PO-WAERS TO I_ZPO_LOCAL-WAERS.

    LC_SUBDIC = LC_SUBDIC + LC_KWERT.

* find last po.
    IF IT_PO-MATNR <> ''.


      READ TABLE IT_ADD_LAST WITH KEY MATNR = IT_PO-MATNR.
      IF SY-SUBRC EQ 0.
        CLEAR LFA1.
        SELECT SINGLE NAME1 INTO LFA1-NAME1 FROM LFA1
        WHERE LIFNR = IT_ADD_LAST-LIFNR.
        IF SY-SUBRC EQ 0.
          WRITE LFA1-NAME1 TO I_ZPO_LOCAL-ZLASTVENDOR.
        ENDIF.
      ENDIF.

*--- find last price by material
      CLEAR: IT_KONV_LAST.
      SELECT A~KNUMV B~EBELP INTO (IT_KONV_LAST-KNUMV, IT_KONV_LAST-KPOSN)
        FROM EKKO AS A JOIN EKPO AS B ON B~EBELN = A~EBELN
        WHERE B~MATNR = IT_PO-MATNR
         AND B~LOEKZ = '' AND A~EBELN < IT_PO-EBELN
         AND A~FRGZU = 'X'
        ORDER BY A~KNUMV ASCENDING.
      ENDSELECT.

      IF SY-SUBRC = 0.
        CLEAR LC_KBETR.
        SELECT SINGLE KBETR WAERS INTO (LC_KBETR, IT_KONV_LAST-WAERS) FROM KONV
        WHERE KNUMV = IT_KONV_LAST-KNUMV AND KPOSN = IT_KONV_LAST-KPOSN AND
                                         ( KSCHL = 'PB00' OR KSCHL = 'PBXX').

* get kurs
        DATA: V_KURS LIKE RKB1K-EXCHR.
        CLEAR: V_KURS, V_NEWAMOUNT.

        IF IT_PO-WAERS NE IT_KONV_LAST-WAERS.
* convert to IDR
          IF IT_KONV_LAST-WAERS = 'IDR'.
            LC_KBETR = LC_KBETR.
          ELSE.
            CALL FUNCTION 'RKC_SINGLE_EXCHANGE_RATE_GET'
              EXPORTING
                DATUM         = SY-DATUM
                KURST         = 'M'
                NCURR         = 'IDR'
                VCURR         = IT_KONV_LAST-WAERS
              IMPORTING
                EXCHR         = V_KURS
              EXCEPTIONS
                NO_RATE_FOUND = 1
                OTHERS        = 2.

            LC_KBETR = LC_KBETR * V_KURS.
          ENDIF.

          V_NEWAMOUNT = LC_KBETR.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = IT_KONV_LAST-WAERS
              AMOUNT_INTERNAL = V_NEWAMOUNT
            IMPORTING
              AMOUNT_DISPLAY  = V_NEWAMOUNT.
          LC_KBETR = V_NEWAMOUNT.

* convert from IDR
          IF IT_PO-WAERS EQ 'IDR'.
            LC_KBETR = LC_KBETR.
          ELSE.
            CALL FUNCTION 'RKC_SINGLE_EXCHANGE_RATE_GET'
              EXPORTING
                DATUM         = SY-DATUM
                KURST         = 'M'
                NCURR         = 'IDR'
                VCURR         = IT_PO-WAERS
              IMPORTING
                EXCHR         = V_KURS
              EXCEPTIONS
                NO_RATE_FOUND = 1
                OTHERS        = 2.

            LC_KBETR = LC_KBETR * 1 / V_KURS.
          ENDIF.
        ELSE.
          V_NEWAMOUNT = LC_KBETR.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = IT_KONV_LAST-WAERS
              AMOUNT_INTERNAL = V_NEWAMOUNT
            IMPORTING
              AMOUNT_DISPLAY  = V_NEWAMOUNT.
          LC_KBETR = V_NEWAMOUNT.
        ENDIF.    " no same currency
*--- end of get kurs

        IF SY-SUBRC = 0.
          WRITE LC_KBETR TO I_ZPO_LOCAL-ZLASTPRICE. "CURRENCY it_po-waers.
        ENDIF.
      ENDIF.
      CLEAR: IT_KONV_LAST.
*---
    ENDIF.

    APPEND I_ZPO_LOCAL.
    CLEAR  I_ZPO_LOCAL.

  ENDLOOP.

  WRITE LC_SUBTOTAL TO P_SUBTOTAL CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.
  WRITE LC_SUBDIC   TO P_DISCOUNT CURRENCY IT_PO-WAERS LEFT-JUSTIFIED.

  IF LC_KBETR <> 0.
    REPLACE ALL OCCURRENCES OF '-' IN P_DISCOUNT WITH ' '.
    CONCATENATE '-' P_DISCOUNT  INTO  P_DISCOUNT.
  ENDIF.

* tax
  CLEAR LC_BASE_AMOUNT.
  LC_BASE_AMOUNT  = LC_SUBTOTAL + LC_SUBDIC.

  CLEAR LC_TAX_AMOUNT.
  LOOP AT IT_PO WHERE MWSKZ NE SPACE.
    IF IT_PO-MWSKZ = 'V0'.
      LC_TAX_AMOUNT = 0.
    ELSEIF IT_PO-MWSKZ = 'V1'.
      LC_TAX_AMOUNT = LC_BASE_AMOUNT * ( 10 / 100 ).
    ENDIF.
    EXIT.
  ENDLOOP.
  WRITE LC_TAX_AMOUNT TO P_TAX CURRENCY IT_PO-WAERS.

*freight
  CLEAR LC_KWERT.
  LOOP AT IT_KONV WHERE KNUMV = IT_PO-KNUMV AND
                        KPOSN = IT_PO-EBELP    AND
                        KSCHL = 'ZS01'.

    LC_KWERT = LC_KWERT + IT_KONV-KBETR.
  ENDLOOP.
  WRITE LC_KWERT TO P_FREIGHT CURRENCY IT_PO-WAERS.


  LC_TOTAL_ORDER = LC_SUBTOTAL + LC_SUBDIC + LC_TAX_AMOUNT + LC_KWERT .

  WRITE LC_TOTAL_ORDER TO P_TOTAL_ORDER CURRENCY IT_PO-WAERS.


ENDFORM.                    " f_find_item_data
*&---------------------------------------------------------------------*
*&      Form  f_add_kschl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADD_KSCHL .

  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'HB01'.
  R_KSCHL-HIGH   =  'HB01'.
  APPEND R_KSCHL.

  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RA00'.
  R_KSCHL-HIGH   =  'RA00'.
  APPEND R_KSCHL.


  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RA01'.
  R_KSCHL-HIGH   =  'RA01'.
  APPEND R_KSCHL.


  R_KSCHL-SIGN   =  'I'.
  R_KSCHL-OPTION =  'EQ'.
  R_KSCHL-LOW    =  'RB00'.
  R_KSCHL-HIGH   =  'RB00'.
  APPEND R_KSCHL.



ENDFORM.                    " f_add_kschl
*&---------------------------------------------------------------------*
*&      Form  f_get_last_month_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_LAST_MONTH_DATE .

  REFRESH R_DATE.
  V_DATUM_END = V_DATUM_END - 1.

  R_DATE-SIGN   =  'I'.
  R_DATE-OPTION =  'BT'.
  R_DATE-HIGH   =  IT_PO-AEDAT. "sy-datum.
  R_DATE-LOW    =  V_DATUM_END.
  APPEND R_DATE.

ENDFORM.                    " f_get_last_month_date
*&---------------------------------------------------------------------*
*&      Form  f_additional_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ADDITIONAL_DATA .
* addtional column.
  LOOP AT IT_PO.

    READ TABLE IT_LAST_PO WITH KEY MATNR = IT_PO-MATNR.
    IF SY-SUBRC EQ 0.
      MOVE: IT_LAST_PO-MATNR TO IT_ADD_LAST-MATNR,
            IT_LAST_PO-EBELP TO IT_ADD_LAST-EBELP,
            IT_LAST_PO-EBELN TO IT_ADD_LAST-EBELN,
            IT_LAST_PO-MEINS TO IT_ADD_LAST-MEINS,
            IT_LAST_PO-KNUMV TO IT_ADD_LAST-KNUMV,
            IT_LAST_PO-LIFNR TO IT_ADD_LAST-LIFNR.
      APPEND IT_ADD_LAST.
    ENDIF.
  ENDLOOP.

  IF IT_ADD_LAST[] IS NOT INITIAL.
    SELECT KNUMV  KPOSN  KSCHL
           KBETR  KWERT  WAERS
    INTO TABLE IT_KONV_LAST
    FROM KONV FOR ALL ENTRIES IN IT_ADD_LAST
    WHERE KNUMV  = IT_ADD_LAST-KNUMV.
  ENDIF.


ENDFORM.                    " f_additional_data
*&---------------------------------------------------------------------*
*&      Form  f_select_Data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_DATA .
  CLEAR : P_VENDOR, P_ADDRESS, P_CITY, P_TELP, P_FAX, P_WERKS, P_NAME_WERKS, P_ADDRESS_PLANT, P_SUBTOTAL, P_FREIGHT,
          P_CITY_PLANT, P_LGORT, P_LGORT_TEXT, P_EBELN, P_DATE_PO, P_DATE_PRT, P_DISCOUNT, P_TAX, P_TOTAL_ORDER.


  REFRESH : IT_PO, IT_EKET, IT_KONV.
  SELECT
      A~EBELN A~EKORG A~WAERS A~AEDAT A~LIFNR A~KNUMV A~ZTERM A~BSART
      B~WERKS B~LGORT B~EBELP B~MENGE B~MEINS B~MATNR
      B~TXZ01 B~BEDNR B~BANFN B~MEINS B~MWSKZ
      C~TEXT1
      APPENDING CORRESPONDING FIELDS OF TABLE IT_PO
      FROM EKKO AS A INNER JOIN EKPO AS B
             ON A~EBELN = B~EBELN
              JOIN T052U AS C ON A~ZTERM = C~ZTERM
             WHERE A~EBELN = NAST-OBJKY+0(10) AND B~LOEKZ = ''.

  IF NOT IT_PO[] IS INITIAL.
    READ TABLE IT_PO INDEX 1.

    SELECT EBELN EBELP EINDT INTO TABLE IT_EKET
    FROM EKET WHERE EBELN = IT_PO-EBELN.


    SELECT KNUMV  KPOSN  KSCHL
           KBETR  KWERT  WAERS
    INTO TABLE IT_KONV
    FROM KONV FOR ALL ENTRIES IN IT_PO
    WHERE KNUMV  = IT_PO-KNUMV.

    SELECT NETPR NETWR INTO (IT_KONV-NETPR, IT_KONV-NETWR)
    FROM EKPO FOR ALL ENTRIES IN IT_PO WHERE EBELN = IT_PO-EBELN AND  LOEKZ = ''.
    ENDSELECT.
  ENDIF.


* last po base on material number
  DATA: TEMP LIKE EKKO-EBELN.
  CLEAR IT_LAST_PO1.
  REFRESH IT_LAST_PO1.

  TEMP = IT_PO-EBELN.
  SELECT
    A~EBELN A~AEDAT A~LIFNR A~KNUMV
    B~WERKS B~LGORT
    B~MENGE B~MEINS B~MATNR
    B~TXZ01 B~BEDNR B~BANFN
    B~MEINS B~MWSKZ B~EBELP

    APPENDING CORRESPONDING FIELDS OF TABLE IT_LAST_PO
    FROM EKKO AS A INNER JOIN EKPO AS B
           ON B~EBELN = A~EBELN
    WHERE B~MATNR  = IT_PO-MATNR AND
          B~EBELN  < TEMP AND B~LOEKZ = ''
          AND B~MATNR NE ''
    ORDER BY A~EBELN DESCENDING.

  PERFORM F_GET_REV_DOC.
ENDFORM.                    " f_select_Data
*&---------------------------------------------------------------------*
*&      Form  f_call_smartforms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CALL_SMARTFORMS .

  IF NOT *TNAPR-SFORM IS INITIAL.
    V_FORMNAME = *TNAPR-SFORM.
  ENDIF.

  PERFORM F_SMARTFORMS_CONFIGURE.

  READ TABLE IT_PO INDEX 1.
  V_FORMNAME  = 'ZMMF_PO_LOCAL'.

* Get Function Module name of SmartForms
* --------------------------------------
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC = 0.

    PERFORM F_GET_TERM_PAYMENT.

    PERFORM F_GET_HEADER_TEXT.

    IF IT_PO-BSART = 'PO06'.
      PERFORM F_GET_SCHE_LINES.

      CALL FUNCTION V_FUNCNAME
        EXPORTING
          CONTROL_PARAMETERS = I_SSFCTRLOP
          OUTPUT_OPTIONS     = I_SSFCOMPOP
          S_VENDOR           = P_VENDOR
          S_ADDRESS          = P_ADDRESS
          S_CITY             = P_CITY
          S_TELP             = P_TELP
          S_FAX              = P_FAX
          S_WERKS            = P_WERKS
          S_NAME_WERKS       = P_NAME_WERKS
          S_ADDRESS_PLANT    = P_ADDRESS_PLANT
          S_CITY_PLANT       = P_CITY_PLANT
          S_LGORT            = P_LGORT
          S_LGORT_TEXT       = P_LGORT_TEXT
          S_EBELN            = P_EBELN
          S_DATE_PO          = P_DATE_PO
          S_DATE_PRT         = P_DATE_PRT
          S_PAY1             = P_TERM
          S_SUBTOTAL         = P_SUBTOTAL
          S_DISCOUNT         = P_DISCOUNT
          S_TAX              = P_TAX
          S_FREIGHT          = P_FREIGHT
          S_TOTAL_ORDER      = P_TOTAL_ORDER
          S_FLAG_PREV        = I_SSFCTRLOP-PREVIEW
          P_WAERS            = IT_PO-WAERS
          PO_TYPE            = V_POTYPE
          V_REV              = V_REV
        TABLES
          I_ZPO_LOCAL        = I_ZPO_LOCAL
          IT_EKET            = IT_DELV.
    ELSE.
      CALL FUNCTION V_FUNCNAME
        EXPORTING
          CONTROL_PARAMETERS = I_SSFCTRLOP
          OUTPUT_OPTIONS     = I_SSFCOMPOP
          S_VENDOR           = P_VENDOR
          S_ADDRESS          = P_ADDRESS
          S_CITY             = P_CITY
          S_TELP             = P_TELP
          S_FAX              = P_FAX
          S_WERKS            = P_WERKS
          S_NAME_WERKS       = P_NAME_WERKS
          S_ADDRESS_PLANT    = P_ADDRESS_PLANT
          S_CITY_PLANT       = P_CITY_PLANT
          S_LGORT            = P_LGORT
          S_LGORT_TEXT       = P_LGORT_TEXT
          S_EBELN            = P_EBELN
          S_DATE_PO          = P_DATE_PO
          S_DATE_PRT         = P_DATE_PRT
          S_PAY1             = P_TERM
          S_SUBTOTAL         = P_SUBTOTAL
          S_DISCOUNT         = P_DISCOUNT
          S_TAX              = P_TAX
          S_FREIGHT          = P_FREIGHT
          S_TOTAL_ORDER      = P_TOTAL_ORDER
          S_FLAG_PREV        = I_SSFCTRLOP-PREVIEW
          P_WAERS            = IT_PO-WAERS
          PO_TYPE            = V_POTYPE
          V_REV              = V_REV
        TABLES
          I_ZPO_LOCAL        = I_ZPO_LOCAL.
    ENDIF.

  ENDIF.


ENDFORM.                    " f_call_smartforms
*&---------------------------------------------------------------------*
*&      Form  f_smartforms_configure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SMARTFORMS_CONFIGURE .
  DATA: XDEVICE(10) TYPE C,
          XDIALOG.                 "Hilfsfeld Formular

  CLEAR: I_SSFCOMPOP.
  CLEAR: I_SSFCTRLOP.

  MOVE-CORRESPONDING NAST TO I_SSFCOMPOP.
  I_SSFCOMPOP-TDTITLE   = NAST-TDCOVTITLE.
  I_SSFCOMPOP-TDFAXUSER = NAST-USNAM.

*- Ausgabemedium festlegen --------------------------------------------*
  CASE NAST-NACHA.
    WHEN '2'.
      XDEVICE = 'TELEFAX'.
      IF NAST-TELFX EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELFX.
        IF NOT NAST-TLAND IS INITIAL.
          I_SSFCOMPOP-TDTELELAND = NAST-TLAND.
        ENDIF.
      ENDIF.
    WHEN '3'.
      XDEVICE = 'TELETEX'.
      IF NAST-TELTX EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELTX.
      ENDIF.
    WHEN '4'.
      XDEVICE = 'TELEX'.
      IF NAST-TELX1 EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDTELENUM  = NAST-TELX1.
      ENDIF.
    WHEN '5'.
* N/a
    WHEN OTHERS.
      XDEVICE = 'PRINTER'.
      IF NAST-LDEST EQ SPACE.
        XDIALOG = C_FLAG.
      ELSE.
        I_SSFCOMPOP-TDDEST   = NAST-LDEST.
      ENDIF.
  ENDCASE.

* Bei Probedruck, wenn das Medium keine Drucker ist.        " 361152
  IF NAST-SNDEX EQ C_FLAG AND
     NAST-NACHA NE '1'.                                     " 361152
    XDEVICE = 'PRINTER'.                                    " 361152
    IF NAST-LDEST EQ SPACE.                                 " 361152
      XDIALOG = C_FLAG.                                     " 361152
    ELSE.                                                   " 361152
      I_SSFCOMPOP-TDDEST   = NAST-LDEST.                    " 361152
    ENDIF.                                                  " 361152
  ENDIF.                                                    " 361152
  I_SSFCOMPOP-TDCOVER    = NAST-TDOCOVER.
  I_SSFCOMPOP-TDCOPIES   = NAST-ANZAL.
  I_SSFCOMPOP-TDDATASET  = NAST-DSNAM.
  I_SSFCOMPOP-TDSUFFIX1  = NAST-DSUF1.
  I_SSFCOMPOP-TDSUFFIX2  = NAST-DSUF2.
  I_SSFCOMPOP-TDSENDDATE = NAST-VSDAT.
  I_SSFCOMPOP-TDSENDTIME = NAST-VSURA.

  IF SY-XCODE = '9AUS' OR SY-XCODE = '9ANZ'.
*   Set Display SmartForm directly
*   ------------------------------
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = ' '.
    I_SSFCOMPOP-TDNOPRINT = SPACE.
    I_SSFCOMPOP-TDIMMED   = NAST-DIMME.
    I_SSFCOMPOP-TDDELETE  = NAST-DELET.
    I_SSFCOMPOP-TDNEWID   = C_FLAG.                         " 99282
  ELSEIF SY-XCODE = '9ANZ'.
    I_SSFCOMPOP-TDNOPRINT = C_FLAG.
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = C_FLAG.
    I_SSFCOMPOP-TDIMMED   = SPACE.
    I_SSFCOMPOP-TDNEWID   = SPACE.                          " 99282
  ELSEIF SY-XCODE EQ 'DRPR' OR                              " 361152
           NAST-SNDEX EQ C_FLAG.                            " 361152

    I_SSFCOMPOP-TDNOPRINT  = SPACE.                         " 361152
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCOMPOP-TDNOPREV  = C_FLAG.
    I_SSFCOMPOP-TDCOPIES   = 1.
    I_SSFCOMPOP-TDIMMED    = 'X'.
    I_SSFCOMPOP-TDDELETE   = NAST-DELET.
    I_SSFCOMPOP-TDNEWID    = C_FLAG.                        " 99282

  ELSE.
    I_SSFCTRLOP-NO_DIALOG = C_FLAG.
    I_SSFCTRLOP-PREVIEW   = C_FLAG.
    I_SSFCOMPOP-TDNOPRINT = 'X'.
    I_SSFCOMPOP-TDIMMED   = ' '.
    I_SSFCOMPOP-TDDELETE  = NAST-DELET.
    I_SSFCOMPOP-TDNEWID   = C_FLAG.                         " 99282
  ENDIF.

ENDFORM.                    " f_smartforms_configure

*&---------------------------------------------------------------------*
*&      Form  f_get_term_payment
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_TERM_PAYMENT .

  SELECT SINGLE T052U~TEXT1
    INTO P_TERM
    FROM T052U
    JOIN EKKO ON T052U~ZTERM = EKKO~ZTERM
    WHERE EKKO~EBELN = IT_PO-EBELN
    AND T052U~SPRAS = 'E'.
ENDFORM.                    " f_get_term_payment

*&---------------------------------------------------------------------*
*&      Form  f_get_item_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_ITEM_TEXT USING EBELN EBELP
                     CHANGING TEXT.

  CLEAR : V_TDNAME.
  CONCATENATE EBELN EBELP INTO V_TDNAME.
  CLEAR I_LINES.
  REFRESH I_LINES.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'
      LANGUAGE  = 'E'
      NAME      = V_TDNAME
      OBJECT    = 'EKPO'
    IMPORTING
      HEADER    = THEAD
    TABLES
      LINES     = I_LINES
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      NOT_FOUND = 4
      OBJECT    = 5.


  DELETE I_LINES
     WHERE  TDLINE EQ SPACE.

  CLEAR TEXT.
  LOOP AT I_LINES.
    CONCATENATE TEXT I_LINES-TDLINE INTO TEXT SEPARATED BY SPACE.
  ENDLOOP.

ENDFORM.                    " f_get_term_payment



*--- get consignmrnt price
FORM F_GET_INFORECORD.
  CLEAR:  V_POTYPE.

  DATA: BEGIN OF IT_EKPO OCCURS 0,
        EBELN LIKE EKPO-EBELN,
        EBELP LIKE EKPO-EBELP,
        INFNR LIKE EKPO-INFNR,
        NETPR LIKE EINE-NETPR,
        WAERS LIKE EINE-WAERS,
        MWSKZ LIKE EINE-MWSKZ,   "Tax code
        END OF IT_EKPO.
  DATA: T_SUBTOTAL LIKE EINE-NETPR,
        T_DISCOUNT  LIKE EINE-NETPR,
        T_TAX  LIKE EINE-NETPR,
        T_FREIGHT  LIKE EINE-NETPR,
        T_TOTAL_ORDER  LIKE EINE-NETPR.

  SELECT A~EBELN A~EBELP A~INFNR B~NETPR B~WAERS B~MWSKZ INTO TABLE IT_EKPO
  FROM ( EKPO AS A JOIN EINE AS B ON A~INFNR = B~INFNR AND B~WERKS = P_WERKS ) JOIN EKKO AS C ON A~EBELN = C~EBELN
  WHERE A~EBELN = P_EBELN AND C~BSART = 'PO12'.

  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.

  V_POTYPE = 'Consignment'.
  CLEAR: P_SUBTOTAL, P_DISCOUNT, P_TAX, P_FREIGHT, P_TOTAL_ORDER.
  LOOP AT I_ZPO_LOCAL.
    READ TABLE IT_EKPO WITH KEY EBELP = I_ZPO_LOCAL-ZNO.
    IF SY-SUBRC = 0.
      WRITE IT_EKPO-NETPR TO I_ZPO_LOCAL-ZUNITPRICE CURRENCY IT_EKPO-WAERS.
      IT_EKPO-NETPR = IT_EKPO-NETPR * I_ZPO_LOCAL-ZMENGE.
      WRITE IT_EKPO-NETPR TO  I_ZPO_LOCAL-ZTOTALPRICE CURRENCY IT_EKPO-WAERS.
      MODIFY I_ZPO_LOCAL.

      T_SUBTOTAL = T_SUBTOTAL + IT_EKPO-NETPR.
    ENDIF.
  ENDLOOP.

  IF IT_EKPO-MWSKZ = 'V0'.
    T_TAX = 0.
  ELSEIF IT_EKPO-MWSKZ = 'V1'.
    T_TAX = T_SUBTOTAL * ( 10 / 100 ).
  ENDIF.
  WRITE T_TAX TO  P_TAX CURRENCY IT_EKPO-WAERS.

  WRITE T_SUBTOTAL TO  P_SUBTOTAL CURRENCY IT_EKPO-WAERS.
  T_TOTAL_ORDER = T_SUBTOTAL - T_DISCOUNT + T_TAX + T_FREIGHT.
  WRITE T_TOTAL_ORDER TO  P_TOTAL_ORDER CURRENCY IT_EKPO-WAERS.

ENDFORM.                    "f_get_inforecord



*--- case of PO return
FORM F_PO_RETURN.
  DATA: BEGIN OF IT_RETURN OCCURS 0,
        EBELN LIKE EKPO-EBELN,
        RETPO LIKE EKPO-RETPO,
        END OF IT_RETURN.

  SELECT EBELN RETPO INTO TABLE IT_RETURN
    FROM EKPO WHERE EBELN = P_EBELN AND LOEKZ = ''.

  IF SY-SUBRC = 0.
    READ TABLE IT_RETURN WITH KEY RETPO = 'X'.

    IF SY-SUBRC = 0.
      READ TABLE IT_RETURN WITH KEY RETPO = ''.

      IF SY-SUBRC = 0.
        CLEAR VBSART.
        SELECT SINGLE EKKO~BSART
          FROM EKKO
          INTO VBSART
          WHERE EKKO~EBELN = P_EBELN.

        IF VBSART = 'PO19'.
          V_POTYPE = 'R E T U R N'.
        ENDIF.
      ELSE.

        CLEAR VBSART.
        SELECT SINGLE EKKO~BSART
          FROM EKKO
          INTO VBSART
          WHERE EKKO~EBELN = P_EBELN.

        IF VBSART = 'PO19'.
          V_POTYPE = 'R E T U R N'.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "f_po_return


*--- get Delivery schedule line data.
FORM F_GET_SCHE_LINES.
  DATA: V_COUNT LIKE SY-TABIX.

  SELECT EBELN EBELP EINDT MENGE
  INTO CORRESPONDING FIELDS OF TABLE IT_DELV
  FROM EKET WHERE EBELN = P_EBELN.

  LOOP AT I_ZPO_LOCAL.
    CLEAR V_COUNT.
    LOOP AT IT_DELV WHERE EBELN = P_EBELN AND EBELP = I_ZPO_LOCAL-ZNO.
      V_COUNT = V_COUNT + 1.
    ENDLOOP.
    IF V_COUNT < 2.
      DELETE IT_DELV WHERE EBELN = P_EBELN AND EBELP = I_ZPO_LOCAL-ZNO.
    ELSE.
      I_ZPO_LOCAL-ZEINDT = ''.
      MODIFY I_ZPO_LOCAL.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_get_sche_lines


*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_HEADER_TEXT .

  CLEAR : V_TDNAME.
  V_TDNAME = IT_PO-EBELN.
  REFRESH I_LINES.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'
      LANGUAGE  = 'E'
      NAME      = V_TDNAME
      OBJECT    = 'EKKO'
    IMPORTING
      HEADER    = THEAD
    TABLES
      LINES     = I_LINES
    EXCEPTIONS
      ID        = 1
      LANGUAGE  = 2
      NAME      = 3
      NOT_FOUND = 4
      OBJECT    = 5.


  DELETE I_LINES
     WHERE  TDLINE EQ SPACE.

  REFRESH IT_HTEXT.
  LOOP AT I_LINES.
    WA_HTEXT-TDLINE = I_LINES-TDLINE.
    APPEND WA_HTEXT TO IT_HTEXT.
  ENDLOOP.
ENDFORM.                    " F_GET_HEADER_TEXT


*&---------------------------------------------------------------------*
*&      Form  F_GET_REV_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_REV_DOC .
  DATA : IS_CHANGE(1) TYPE C.
  REFRESH : ITHREV, ITIREV.
  CLEAR : WAREV, V_REV.

  SELECT CDHDR~OBJECTID AS NOPO
    CDHDR~CHANGENR AS NODOC
    INTO CORRESPONDING FIELDS OF TABLE ITHREV
    FROM CDHDR
    WHERE CDHDR~OBJECTCLAS = 'EINKBELEG'
    AND CDHDR~OBJECTID = NAST-OBJKY+0(10).

  LOOP AT ITHREV.
    REFRESH ITIREV.

    SELECT CDPOS~OBJECTID AS NOPO
      CDPOS~CHANGENR AS NODOC
      CDPOS~FNAME AS FNAME
      INTO CORRESPONDING FIELDS OF TABLE ITIREV
      FROM CDPOS
      WHERE CDPOS~OBJECTCLAS = 'EINKBELEG'
      AND CDPOS~OBJECTID = ITHREV-NOPO
      AND CDPOS~CHANGENR = ITHREV-NODOC.

    "CEK PERUBAHAN DATA
    "HARGA DAN QTY, TERMS OF PAYMENT, DESKRIPSI.
    CLEAR IS_CHANGE.
    LOOP AT ITIREV WHERE FNAME = 'F07 E'
      OR FNAME = 'MENGE'
      OR FNAME = 'F01 E'
      OR FNAME = 'NETPR'
      OR FNAME = 'ZTERM'.

      IS_CHANGE = 'X'.

    ENDLOOP.

    IF IS_CHANGE = 'X'.
      ITHREV-FLAG = 'X'.
    ENDIF.
    MODIFY ITHREV.

  ENDLOOP.

  DELETE ITHREV WHERE FLAG NE 'X'.
  DESCRIBE TABLE ITHREV LINES REV.

  IF REV <> 0.
    V_REV = REV.
    CONDENSE V_REV NO-GAPS.
    CONCATENATE 'rev' V_REV INTO V_REV.
  ENDIF.


ENDFORM.                    " F_GET_REV_DOC


*&---------------------------------------------------------------------*
*&      Form  CEK_OUTPUT_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CEK_OUTPUT_TYPE.
  DATA: WA_NAST LIKE NAST OCCURS 0  WITH HEADER LINE.
  DATA: V_MSG(100).
  CLEAR IS_SAME_OTYPE.
  SELECT SINGLE * INTO WA_NAST FROM NAST WHERE KAPPL = 'EF' AND VSTAT = '1' AND OBJKY = NAST-OBJKY. "AND KSCHL NE NAST-KSCHL.
  IF SY-SUBRC = 0 AND WA_NAST-KSCHL NE NAST-KSCHL.
    IS_SAME_OTYPE = 'X'.
    CONCATENATE 'Sudah pernah dicetak dengan output type' WA_NAST-KSCHL 'PO no:' NAST-OBJKY INTO V_MSG SEPARATED BY SPACE.
    MESSAGE V_MSG TYPE 'I'.
  ELSE.
    IS_SAME_OTYPE = ''.
  ENDIF.
ENDFORM.                    "cek_output_type
