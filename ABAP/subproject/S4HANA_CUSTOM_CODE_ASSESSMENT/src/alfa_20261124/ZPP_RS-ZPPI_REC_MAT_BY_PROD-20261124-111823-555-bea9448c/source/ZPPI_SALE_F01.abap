*&---------------------------------------------------------------------*
*&  Include           ZPPI_SALE_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_DATA .
  CLEAR   : V_DATE, V_DELIVERY , CDELIVERY.
  CLEAR   : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET, IT_MSEG_TEMP.
  REFRESH : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET, IT_BWART, IT_MSEG_TEMP.
  CONCATENATE SY-DATUM SY-UZEIT INTO V_DATE.

  WA_DATES-TIMETYPE      = 'WSHDRWADAT'.
  WA_DATES-TIMESTAMP_UTC = V_DATE.
  WA_DATES-TIMEZONE      = 'UTC+7'.
  APPEND WA_DATES TO IT_DATES.

**  SELECT MSEG~BWART
**    INTO CORRESPONDING FIELDS OF TABLE IT_BWART
**    FROM MSEG
**    WHERE MSEG~MBLNR IN S_MBLNR.

**  LOOP AT IT_BWART.
**    IF IT_BWART-BWART NE '531'.
**      MESSAGE 'Material Document contains another movement type' TYPE 'W'.
**      EXIT.
**    ENDIF.
**  ENDLOOP.

  IF S_MBLNR[] IS INITIAL.
    MESSAGE 'Fill material document number' TYPE 'W'.
    LEAVE TO SCREEN 0.
  ENDIF.

  SELECT
   MSEG~MBLNR
   MSEG~ZEILE
   MSEG~MATNR
   MSEG~MENGE
   MSEG~MEINS
   MSEG~LGORT
   INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
   FROM MSEG
   WHERE MSEG~MBLNR IN S_MBLNR
     AND MSEG~MJAHR = ZMJAHR
     AND MSEG~BWART IN ('531', '561').

  IF IT_MSEG[] IS INITIAL.
    MESSAGE 'No data selected.' TYPE 'I'.
    LEAVE TO SCREEN 0.
  ENDIF.

  CLEAR : V_LGORT, WA_MSEG.
  READ TABLE IT_MSEG INDEX 1 INTO WA_MSEG.
  IF SY-SUBRC = 0.
    V_LGORT = WA_MSEG-LGORT.
  ENDIF.

  IT_MSEG_TEMP[] = IT_MSEG[].

  SORT IT_MSEG ASCENDING BY MATNR.
  DELETE ADJACENT DUPLICATES FROM IT_MSEG COMPARING MATNR.

  CLEAR : V_POSNR.
  LOOP AT IT_MSEG.
    CLEAR : V_MBLNR, ZMATNR, V_MENGE.

    SELECT SINGLE MVKE~MATNR
      INTO ZMATNR
      FROM MVKE
      WHERE MVKE~MATNR = IT_MSEG-MATNR.

    IF SY-SUBRC <> 0.
      CONCATENATE 'Sales data for material' IT_MSEG-MATNR 'not maintain yet.' INTO ZTEXT SEPARATED BY SPACE.
      MESSAGE ZTEXT TYPE 'E'.
      EXIT.
    ENDIF.

    LOOP AT IT_MSEG_TEMP WHERE MATNR = IT_MSEG-MATNR.
      SELECT SINGLE ZTLOG_SALE~MBLNR
        INTO V_MBLNR
        FROM ZTLOG_SALE
        WHERE ZTLOG_SALE~MBLNR = IT_MSEG-MBLNR
          AND ZTLOG_SALE~NOREF NE ''.

      IF SY-SUBRC = 0.
        MESSAGE 'Mat.Doc have been created' TYPE 'E'.
        EXIT.
      ENDIF.

      IF IT_MSEG_TEMP-LGORT NE V_LGORT.
        MESSAGE 'Material Document contains different Sloc.' TYPE 'E'.
        EXIT.
      ENDIF.

      V_MENGE = V_MENGE + IT_MSEG_TEMP-MENGE.
    ENDLOOP.

    IT_MSEG-MENGE = V_MENGE.

    WRITE IT_MSEG-MENGE TO IT_MSEG-CMENGE.
    CONDENSE IT_MSEG-CMENGE NO-GAPS.
    V_POSNR = V_POSNR + 10.
    IT_MSEG-POSNR = V_POSNR.
    MODIFY IT_MSEG.

    CLEAR : WA_DLV_ITEMS, WA_MSEG.
    READ TABLE IT_MSEG INTO WA_MSEG.

    WA_DLV_ITEMS-REF_ITEM   = WA_MSEG-POSNR.
    WA_DLV_ITEMS-MATERIAL   = WA_MSEG-MATNR.
    WA_DLV_ITEMS-DLV_QTY    = WA_MSEG-MENGE.
    WA_DLV_ITEMS-SALES_UNIT = WA_MSEG-MEINS.
    WA_DLV_ITEMS-PLANT      = ZWERKS.
    WA_DLV_ITEMS-STGE_LOC   = ZLGORT.

    APPEND WA_DLV_ITEMS TO IT_DLV_ITEMS.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATENOREF'
    EXPORTING
      SHIP_POINT           = ZVSTEL
      DLV_TYPE             = 'ZSCF'
      SALESORG             = ZVKORG
      DISTR_CHAN           = ZVTWEG
      DIVISION             = ZSPART
      SHIP_TO              = KNA1-KUNNR
      DATE_USAGE           = '0'
*     DEBUG_FLG            =
*     NO_DEQUEUE           = ' '
*   IMPORTING
*     DELIVERY             =
*     NUM_DELIVERIES       =
    TABLES
      DATES                = IT_DATES
      DLV_ITEMS            = IT_DLV_ITEMS
*     SERIAL_NUMBERS       =
*     EXTENSION_IN         =
*     DELIVERIES           =
*     CREATED_ITEMS        =
*     EXTENSION_OUT        =
      RETURN               = IT_RET.

  DATA: LS_SUBRC TYPE SY-SUBRC.
  LS_SUBRC = 0.

  LOOP AT IT_RET.
    IF IT_RET-TYPE EQ 'E' AND LS_SUBRC EQ 0.
      LS_SUBRC = 1.
    ENDIF.

    IF IT_RET-TYPE EQ 'S' AND IT_RET-ID EQ 'VL'.
      V_DELIVERY = IT_RET-MESSAGE.
    ENDIF.
  ENDLOOP.

  DELETE IT_RET WHERE ID = 'BAPI'.
  SORT IT_RET ASCENDING BY NUMBER.
  DELETE ADJACENT DUPLICATES FROM IT_RET COMPARING NUMBER.

  "- Commit
  IF LS_SUBRC EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    MESSAGE 'Delivery Created' TYPE 'I'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = V_DELIVERY
      IMPORTING
        OUTPUT = V_DELIVERY.

    CDELIVERY = V_DELIVERY.

    IF ZPENGEMUDI NE ''.
      CLEAR : WA_LINE, IT_LINE.
      REFRESH : IT_LINE.
      WA_LINE-TDLINE = ZPENGEMUDI.
      APPEND WA_LINE TO IT_LINE.

      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          FID         = 'Z114'
          FLANGUAGE   = SY-LANGU
          FNAME       = CDELIVERY
          FOBJECT     = 'VBBK'
          SAVE_DIRECT = 'X'
          FFORMAT     = '*'
        TABLES
          FLINES      = IT_LINE
        EXCEPTIONS
          NO_INIT     = 1
          NO_SAVE     = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.
    ENDIF.

    IF ZKENDARAAN NE ''.
      CLEAR : WA_LINE, IT_LINE.
      REFRESH : IT_LINE.
      WA_LINE-TDLINE = ZKENDARAAN.
      APPEND WA_LINE TO IT_LINE.

      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          FID         = 'Z115'
          FLANGUAGE   = SY-LANGU
          FNAME       = CDELIVERY
          FOBJECT     = 'VBBK'
          SAVE_DIRECT = 'X'
          FFORMAT     = '*'
        TABLES
          FLINES      = IT_LINE
        EXCEPTIONS
          NO_INIT     = 1
          NO_SAVE     = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.
    ENDIF.

    IF ZSKP NE ''.
      CLEAR : WA_LINE, IT_LINE.
      REFRESH : IT_LINE.
      WA_LINE-TDLINE = ZSKP.
      APPEND WA_LINE TO IT_LINE.

      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          FID         = 'Z111'
          FLANGUAGE   = SY-LANGU
          FNAME       = CDELIVERY
          FOBJECT     = 'VBBK'
          SAVE_DIRECT = 'X'
          FFORMAT     = '*'
        TABLES
          FLINES      = IT_LINE
        EXCEPTIONS
          NO_INIT     = 1
          NO_SAVE     = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.
    ENDIF.

      "- header text
      CLEAR : WA_LINE, IT_LINE.
      REFRESH : IT_LINE.
      LOOP AT IT_MSEG_TEMP.
        CONCATENATE IT_MSEG_TEMP-MBLNR ZMJAHR INTO WA_LINE-TDLINE SEPARATED BY '/'.
        APPEND WA_LINE TO IT_LINE.
      ENDLOOP.

      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          FID         = 'Z123'
          FLANGUAGE   = SY-LANGU
          FNAME       = CDELIVERY
          FOBJECT     = 'VBBK'
          SAVE_DIRECT = 'X'
          FFORMAT     = '*'
        TABLES
          FLINES      = IT_LINE
        EXCEPTIONS
          NO_INIT     = 1
          NO_SAVE     = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.

      "- NIK
      CLEAR : WA_LINE, IT_LINE.
      REFRESH : IT_LINE.
      WA_LINE-TDLINE = ZNIK.
      APPEND WA_LINE TO IT_LINE.

      CALL FUNCTION 'CREATE_TEXT'
        EXPORTING
          FID         = 'Z113'
          FLANGUAGE   = SY-LANGU
          FNAME       = CDELIVERY
          FOBJECT     = 'VBBK'
          SAVE_DIRECT = 'X'
          FFORMAT     = '*'
        TABLES
          FLINES      = IT_LINE
        EXCEPTIONS
          NO_INIT     = 1
          NO_SAVE     = 2
          OTHERS      = 3.
      IF SY-SUBRC <> 0.
*   Implement suitable error handling here
      ENDIF.

  ENDIF.

ENDFORM.                    " UPLOAD_DATA


*&---------------------------------------------------------------------*
*&      Form  CHANGE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_DATA .
  DATA : N    TYPE N,
         LN   TYPE I,
         TEMP TYPE I,
         VAL  TYPE I,
         V_FIELD(040),
         V_NAME LIKE THEAD-TDNAME,
         ZDATE(10).

**  LOOP AT IT_MSEG.
**    CLEAR : IT_LINE.
**    REFRESH : IT_LINE.
**
**    CONCATENATE IT_MSEG-MBLNR IT_MSEG-ZEILE ZMJAHR INTO IT_LINE-TDLINE SEPARATED BY '/'.
**    COLLECT IT_LINE.
**
**    CONCATENATE CDELIVERY IT_MSEG-POSNR INTO V_NAME.
**
**    CALL FUNCTION 'CREATE_TEXT'
**      EXPORTING
**        FID         = 'Z001'
**        FLANGUAGE   = SY-LANGU
**        FNAME       = V_NAME
**        FOBJECT     = 'VBBP'
**        SAVE_DIRECT = 'X'
**        FFORMAT     = '*'
**      TABLES
**        FLINES      = IT_LINE
**      EXCEPTIONS
**        NO_INIT     = 1
**        NO_SAVE     = 2
**        OTHERS      = 3.
**    IF SY-SUBRC <> 0.
***     Implement suitable error handling here
**    ENDIF.
**
**  ENDLOOP.

  "- CTU_PARAMS
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

*  IF FLAG2 = 'X'.
*    V_DD = ZWADAT_+6(2).
*    V_MM = ZWADAT_+4(2).
*    V_YY = ZWADAT_(4).
*  ELSE.
    V_DD = LIKP-ERDAT+6(2).
    V_MM = LIKP-ERDAT+4(2).
    V_YY = LIKP-ERDAT(4).
*  ENDIF.


  CLEAR : IT_BDCDATA.
  REFRESH : IT_BDCDATA.
  CONCATENATE V_DD V_MM V_YY INTO ZDATE SEPARATED BY '.'.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-VBELN'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                V_DELIVERY.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIPSD-PIKMG(02)'.

  N = 0.
  VAL = 0.
  CLEAR : LN, TEMP.
  DESCRIBE TABLE IT_MSEG LINES LN.
  LOOP AT IT_MSEG.
    N = N + 1.
    VAL = VAL + 1.
    IF N > 8.
      PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=NPAG_T'.
      TEMP = ( LN - 8 ).
      LN   = TEMP.
      IF TEMP >= 8.
        N = 1.
        VAL = 1.
      ELSE.
        N = ( 8 - TEMP ) + 1.
        VAL = N.
      ENDIF.
    ENDIF.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                   '/00'.
    CLEAR : V_FIELD.
    CONCATENATE 'LIPSD-PIKMG(0' N ')' INTO V_FIELD.
    PERFORM BDC_FIELD      USING V_FIELD
                           IT_MSEG-CMENGE.
  ENDLOOP.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=T\01'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIPSD-PIKMG(02)'.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-WADAT_IST'.
  PERFORM BDC_FIELD       USING 'LIKP-WADAT_IST'
                                 ZDATE.

  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=T\04'.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'LIKP-ROUTE'.
  PERFORM BDC_FIELD       USING 'LIKP-ROUTE'
                                 LIKP-ROUTE.
  PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SICH_T'.

  CALL TRANSACTION 'VL02N' USING IT_BDCDATA
                                 OPTIONS FROM OPT
                                 MESSAGES INTO IT_BDCMSGCOLL.

  COMMIT WORK AND WAIT.

ENDFORM.                    " CHANGE_DATA


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
  IT_BDCDATA-PROGRAM = PROG.
  IT_BDCDATA-DYNPRO  = SCR.
  IT_BDCDATA-DYNBEGIN = 'X'.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_DYNPRO

*&--------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*          -->FNAM       text
*          -->FVAL       text
* ---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR IT_BDCDATA.
  IT_BDCDATA-FNAM = FNAM.
  IT_BDCDATA-FVAL  = FVAL.
  APPEND IT_BDCDATA.
ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA .
  DATA : V_MAX TYPE N LENGTH 10.
  DATA : V_SEQ LIKE ZTLOG_SALE-SEQ.
  DATA : V_MBLNR LIKE ZTLOG_SALE-MBLNR.
  CLEAR : V_MAX.
  SELECT
    MSEG~MBLNR
    INTO CORRESPONDING FIELDS OF TABLE IT_ERROR
    FROM MSEG
    WHERE MSEG~MBLNR IN S_MBLNR
      AND MSEG~MJAHR = ZMJAHR.

  SELECT MAX( ZTLOG_SALE~SEQ )
    INTO V_MAX
    FROM ZTLOG_SALE.

  IF SY-SUBRC <> 0.
    V_MAX = 0.
  ENDIF.

  SORT IT_ERROR ASCENDING BY MBLNR.
  DELETE ADJACENT DUPLICATES FROM IT_ERROR COMPARING MBLNR.

  LOOP AT IT_ERROR.
    CLEAR : WA_ERROR, V_MBLNR.
    V_MAX = V_MAX + 1.

    "- Check MatDoc
    SELECT SINGLE ZTLOG_SALE~MBLNR
      INTO V_MBLNR
      FROM ZTLOG_SALE
      WHERE ZTLOG_SALE~MBLNR = IT_ERROR-MBLNR.

    IF SY-SUBRC = 0.
      SELECT SINGLE ZTLOG_SALE~SEQ
        INTO IT_ERROR-SEQ
        FROM ZTLOG_SALE
        WHERE ZTLOG_SALE~MBLNR = V_MBLNR.
    ENDIF.

    IF IT_ERROR-SEQ = 0.
      IT_ERROR-SEQ = V_MAX.
    ENDIF.
    MODIFY IT_ERROR.

    WA_ERROR-SEQ   = IT_ERROR-SEQ.
    WA_ERROR-MBLNR = IT_ERROR-MBLNR.
    WA_ERROR-LGORT = ZLGORT.
    LOOP AT IT_RET.
      IF WA_ERROR-SEQ = 0.
        WA_ERROR-SEQ = V_MAX.
      ENDIF.
      WA_ERROR-NOREF = V_DELIVERY.
      WA_ERROR-KOSTK = V_KOSTK.
      WA_ERROR-MJAHR = ZMJAHR.
      WA_ERROR-KUNNR = KNA1-KUNNR.
      WA_ERROR-ROUTE = LIKP-ROUTE.
      WA_ERROR-BUDAT = LIKP-ERDAT.
      WA_ERROR-WERKS = ZWERKS.
      WA_ERROR-VSTEL = ZVSTEL.
      WA_ERROR-ZNIK  = ZNIK.
      WA_ERROR-ZPENGEMUDI = ZPENGEMUDI.
      WA_ERROR-ZKENDARAAN = ZKENDARAAN.
      WA_ERROR-ZSKP       = ZSKP.
      WA_ERROR-ERDAT = SY-DATUM.
      WA_ERROR-ERZET = SY-UZEIT.
      WA_ERROR-ERNAM = SY-UNAME.
      WA_ERROR-MSGTYP = IT_RET-TYPE.
      WA_ERROR-MSGID = IT_RET-ID.
      WA_ERROR-MSGNR = IT_RET-NUMBER.
      WA_ERROR-MESSAGE = IT_RET-MESSAGE.

      IF WA_ERROR-MSGTYP = 'S'.
        WA_ERROR-ICON = '@08@'.
      ELSEIF WA_ERROR-MSGTYP = 'E'.
        WA_ERROR-ICON = '@0A@'.
      ENDIF.

      CLEAR : V_SEQ.
      SELECT SINGLE ZTLOG_SALE~SEQ
        INTO V_SEQ
        FROM ZTLOG_SALE
        WHERE ZTLOG_SALE~SEQ =  WA_ERROR-SEQ.

      IF SY-SUBRC <> 0.
        INSERT INTO ZTLOG_SALE VALUES WA_ERROR.
      ELSE.
        UPDATE ZTLOG_SALE FROM WA_ERROR.
      ENDIF.

      COMMIT WORK AND WAIT.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " SAVE_DATA