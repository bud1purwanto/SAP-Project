*----------------------------------------------------------------------*
***INCLUDE ZPPI_REC_MAT_BY_PROD_F01.
*----------------------------------------------------------------------*
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
  CLEAR   : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET.
  REFRESH : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET, IT_BWART.
  CONCATENATE SY-DATUM SY-UZEIT INTO V_DATE.

  WA_DATES-TIMETYPE      = 'WSHDRWADAT'.
  WA_DATES-TIMESTAMP_UTC = V_DATE.
  WA_DATES-TIMEZONE      = 'UTC+7'.
  APPEND WA_DATES TO IT_DATES.

  SELECT MSEG~BWART
    INTO CORRESPONDING FIELDS OF TABLE IT_BWART
    FROM MSEG
    WHERE MSEG~MBLNR IN S_MBLNR.

**  LOOP AT IT_BWART.
**    IF IT_BWART-BWART NE '531'.
**      MESSAGE 'Material Document contains another movement type' TYPE 'W'.
**      EXIT.
**    ENDIF.
**  ENDLOOP.

  IF S_MBLNR[] IS INITIAL.
    MESSAGE 'Fill material document number' TYPE 'W'.
    LEAVE TO SCREEN 1300.
  ENDIF.

  SELECT
   MSEG~MBLNR
   MSEG~ZEILE
   MSEG~MATNR
   MSEG~MENGE
   MSEG~MEINS
   INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
   FROM MSEG
   WHERE MSEG~MBLNR IN S_MBLNR
     AND MSEG~MJAHR = ZMJAHR
     AND MSEG~BWART IN ('531', '561').

  IF IT_MSEG[] IS INITIAL.
    MESSAGE 'No data selected.' TYPE 'I'.
    LEAVE TO SCREEN 1300.
  ENDIF.


  CLEAR : V_POSNR.
  LOOP AT IT_MSEG.
    CLEAR : V_MBLNR, ZMATNR.

    SELECT SINGLE MVKE~MATNR
    INTO ZMATNR
    FROM MVKE
    WHERE MVKE~MATNR = IT_MSEG-MATNR.

    IF SY-SUBRC <> 0.
      CONCATENATE 'Sales data for material' IT_MSEG-MATNR 'not maintain yet.' INTO ZTEXT SEPARATED BY SPACE.
      MESSAGE ZTEXT TYPE 'E'.
      EXIT.
    ENDIF.

    SELECT SINGLE ZTLOG_SALE~MBLNR
      INTO V_MBLNR
      FROM ZTLOG_SALE
      WHERE ZTLOG_SALE~MBLNR = IT_MSEG-MBLNR
        AND ZTLOG_SALE~NOREF NE ''.

    IF SY-SUBRC = 0.
      MESSAGE 'Mat.Doc have been created' TYPE 'E'.
      EXIT.
    ENDIF.

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
      SHIP_TO              = ZKUNNR
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
  DATA : N TYPE N,
         LN TYPE I,
         TEMP TYPE I,
         VAL TYPE I,
         V_FIELD(040),
         V_NAME LIKE THEAD-TDNAME,
         ZDATE(10).


  REFRESH : IT_LINE.
  LOOP AT IT_MSEG.
    CLEAR : IT_LINE.
    REFRESH : IT_LINE.

    CONCATENATE IT_MSEG-MBLNR IT_MSEG-ZEILE ZMJAHR INTO IT_LINE-TDLINE SEPARATED BY '/'.
    COLLECT IT_LINE.

    CONCATENATE CDELIVERY IT_MSEG-POSNR INTO V_NAME.

    CALL FUNCTION 'CREATE_TEXT'
      EXPORTING
        FID         = 'Z102'
        FLANGUAGE   = SY-LANGU
        FNAME       = V_NAME
        FOBJECT     = 'VBBP'
        SAVE_DIRECT = 'X'
        FFORMAT     = '*'
      TABLES
        FLINES      = IT_LINE
      EXCEPTIONS
        NO_INIT     = 1
        NO_SAVE     = 2
        OTHERS      = 3.
    IF SY-SUBRC <> 0.
*     Implement suitable error handling here
    ENDIF.

  ENDLOOP.

  "- CTU_PARAMS
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

  IF FLAG2 = 'X'.
    V_DD = LIKP-ERDAT+6(2).
    V_MM = LIKP-ERDAT+4(2).
    V_YY = LIKP-ERDAT(4).
  ELSE.
    V_DD = ZWADAT+6(2).
    V_MM = ZWADAT+4(2).
    V_YY = ZWADAT(4).
  ENDIF.


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
                                 ZROUTE.
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
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR : IT_LIKP.
  SELECT
    LIKP~VBELN
    LIPS~POSNR
    LIKP~KUNNR
    LIPS~MATNR
    LIPS~ARKTX
    LIPS~LFIMG
    LIPS~VRKME
    LIKP~ROUTE
    LIKP~WADAT_IST
    LIKP~WERKS
    LIKP~VSTEL
    LIPS~LGORT
    LIKP~VKORG
    LIPS~VTWEG
    LIPS~SPART

    INTO CORRESPONDING FIELDS OF TABLE IT_LIKP
    FROM LIKP
    INNER JOIN LIPS ON LIKP~VBELN = LIPS~VBELN
    INNER JOIN VBUK ON LIPS~VBELN = VBUK~VBELN
    WHERE LIKP~VBELN IN S_VBELN
      AND LIKP~WERKS IN S_WERKS
      AND LIPS~LGORT IN S_LGORT
      AND LIKP~WADAT_IST IN S_WADAT
      AND LIKP~KUNNR IN S_KUNNR
      AND VBUK~WBSTK EQ 'C'
      AND LIKP~LFART EQ 'ZSCF'.

  LOOP AT IT_LIKP.
    CLEAR : V_VBELN.
    "- GI Status
    IT_LIKP-ZGI = 'GI Completely processed'.

    "- Document Number
    SELECT SINGLE MKPF~MBLNR
      INTO IT_LIKP-MBLNR
      FROM MKPF
      WHERE MKPF~XBLNR = IT_LIKP-VBELN.

    "- Document Year
    SELECT SINGLE MKPF~MJAHR
      INTO IT_LIKP-MJAHR
      FROM MKPF
      WHERE MKPF~XBLNR = IT_LIKP-VBELN.

    "- Customer Name
    SELECT SINGLE KNA1~NAME1
      INTO IT_LIKP-NAME1
      FROM KNA1
      WHERE KUNNR = IT_LIKP-KUNNR.

    V_VBELN = IT_LIKP-VBELN.

    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nama Pengemudi
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z114'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_LIKP-ZPENGEMUDI = IT_LINE-TDLINE.
    ELSE.
      IT_LIKP-ZPENGEMUDI = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Kendaraan
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z115'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_LIKP-ZKENDARAAN = IT_LINE-TDLINE.
    ELSE.
      IT_LIKP-ZKENDARAAN = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nomor SKP
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z111'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_LIKP-ZSKP = IT_LINE-TDLINE.
    ELSE.
      IT_LIKP-ZSKP = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nomor SKP
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z117'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_LIKP-ZINFORMATION = IT_LINE-TDLINE.
    ELSE.
      IT_LIKP-ZINFORMATION = ''.
    ENDIF.

    MODIFY IT_LIKP.
  ENDLOOP.

  SORT IT_LIKP BY VBELN POSNR.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  IF IT_LIKP[] IS INITIAL.
    MESSAGE 'No data selected.' TYPE 'I'.
    EXIT.
  ENDIF.
  PERFORM F_FIELD_CATALOG_COPY.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.

ENDFORM.                    " DISPLAY_DATA


*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_PRINT .
  SELECT
    LIKP~VBELN
    LIKP~KUNNR
    KNA1~NAME1
    LIKP~LFART
    INTO CORRESPONDING FIELDS OF TABLE IT_PRINT
    FROM LIKP
    INNER JOIN KNA1 ON LIKP~KUNNR = KNA1~KUNNR
    INNER JOIN VBUK ON LIKP~VBELN = VBUK~VBELN
    WHERE LIKP~VBELN IN P_VBELN
      AND LIKP~KUNNR IN P_KUNNR
      AND LIKP~WADAT_IST IN P_WADAT
      AND LIKP~ERNAM IN P_ERNAM
      AND LIKP~ERDAT IN P_ERDAT
      AND VBUK~WBSTK EQ 'C'
      AND LIKP~LFART IN ('ZSCF','ZSFD'). "Add By Afir 15.04.2020 for SJ Pembuangan Scrap

  SORT IT_PRINT ASCENDING BY VBELN.

ENDFORM.                    " GET_DATA_PRINT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA_PRINT .
  PERFORM F_FIELD_CATALOG_PRINT.
  PERFORM F_LAYOUT_PRINT.
  PERFORM F_LIST_DETAIL_PRINT.

ENDFORM.                    " DISPLAY_DATA_PRINT


*&---------------------------------------------------------------------*
*&      Form  PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_DATA .

  IT_TEMP[] = IT_PRINT[].
  DELETE IT_TEMP WHERE BOX NE 'X'.

  SELECT
    LIKP~VBELN
    LIKP~WADAT_IST
    LIPS~WERKS
    LIPS~POSNR
    LIPS~MATNR
    LIPS~ARKTX
    LIPS~LFIMG
    LIPS~VRKME
    KNA1~NAME1
    KNA1~ORT01

    INTO CORRESPONDING FIELDS OF TABLE IT_FORM
    FROM LIKP
    INNER JOIN LIPS ON LIKP~VBELN = LIPS~VBELN
    INNER JOIN KNA1 ON LIKP~KUNNR = KNA1~KUNNR
    FOR ALL ENTRIES IN IT_TEMP
    WHERE LIKP~VBELN = IT_TEMP-VBELN.


  LOOP AT IT_FORM.
    CLEAR : V_VBELN, P_DEC.
    SELECT SINGLE ADRC~STREET
      INTO IT_FORM-STREET
      FROM ADRC
      INNER JOIN KNA1 ON ADRC~ADDRNUMBER = KNA1~ADRNR
      INNER JOIN LIKP ON KNA1~KUNNR = LIKP~KUNNR
      WHERE LIKP~VBELN = IT_FORM-VBELN.

    SELECT SINGLE ADRC~STR_SUPPL1
      INTO IT_FORM-STR_SUPPL1
      FROM ADRC
      INNER JOIN KNA1 ON ADRC~ADDRNUMBER = KNA1~ADRNR
      INNER JOIN LIKP ON KNA1~KUNNR = LIKP~KUNNR
      WHERE LIKP~VBELN = IT_FORM-VBELN.

    SELECT SINGLE T005T~LANDX
      INTO IT_FORM-LANDX
      FROM T005T
      INNER JOIN KNA1 ON KNA1~LAND1 = T005T~LAND1
      INNER JOIN LIKP ON KNA1~KUNNR = LIKP~KUNNR
      WHERE LIKP~VBELN = IT_FORM-VBELN
        AND T005T~SPRAS EQ 'EN'.

    SELECT SUM( LIPS~LFIMG )
      INTO IT_FORM-ZTOTAL
      FROM LIPS
      WHERE LIPS~VBELN = IT_FORM-VBELN.

**-  get Header Text
*    V_VBELN = IT_FORM-VBELN.
*
*    CLEAR : IT_LINE.
*    REFRESH IT_LINE.
*    "- Nama Pengemudi
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
**         CLIENT                        = SY-MANDT
*        ID                            = 'Z114'
*        LANGUAGE                      = SY-LANGU
*        NAME                          = V_VBELN
*        OBJECT                        = 'VBBK'
**         ARCHIVE_HANDLE                = 0
**         LOCAL_CAT                     = ' '
**       IMPORTING
**         HEADER                        =
**         OLD_LINE_COUNTER              =
*      TABLES
*        LINES                         = IT_LINE
*     EXCEPTIONS
*       ID                            = 1
*       LANGUAGE                      = 2
*       NAME                          = 3
*       NOT_FOUND                     = 4
*       OBJECT                        = 5
*       REFERENCE_CHECK               = 6
*       WRONG_ACCESS_TO_ARCHIVE       = 7
*       OTHERS                        = 8
*              .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    READ TABLE IT_LINE INDEX 1.
*    IF SY-SUBRC = 0.
*      IT_FORM-ZPENGEMUDI = IT_LINE-TDLINE.
*    ELSE.
*      IT_FORM-ZPENGEMUDI = ''.
*    ENDIF.
*
*
*    CLEAR : IT_LINE.
*    REFRESH IT_LINE.
*    "- Kendaraan
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
**         CLIENT                        = SY-MANDT
*        ID                            = 'Z115'
*        LANGUAGE                      = SY-LANGU
*        NAME                          = V_VBELN
*        OBJECT                        = 'VBBK'
**         ARCHIVE_HANDLE                = 0
**         LOCAL_CAT                     = ' '
**       IMPORTING
**         HEADER                        =
**         OLD_LINE_COUNTER              =
*      TABLES
*        LINES                         = IT_LINE
*     EXCEPTIONS
*       ID                            = 1
*       LANGUAGE                      = 2
*       NAME                          = 3
*       NOT_FOUND                     = 4
*       OBJECT                        = 5
*       REFERENCE_CHECK               = 6
*       WRONG_ACCESS_TO_ARCHIVE       = 7
*       OTHERS                        = 8
*              .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    READ TABLE IT_LINE INDEX 1.
*    IF SY-SUBRC = 0.
*      IT_FORM-ZKENDARAAN = IT_LINE-TDLINE.
*    ELSE.
*      IT_FORM-ZKENDARAAN = ''.
*    ENDIF.
*
*
*    CLEAR : IT_LINE.
*    REFRESH IT_LINE.
*    "- Nomor SKP
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
**         CLIENT                        = SY-MANDT
*        ID                            = 'Z111'
*        LANGUAGE                      = SY-LANGU
*        NAME                          = V_VBELN
*        OBJECT                        = 'VBBK'
**         ARCHIVE_HANDLE                = 0
**         LOCAL_CAT                     = ' '
**       IMPORTING
**         HEADER                        =
**         OLD_LINE_COUNTER              =
*      TABLES
*        LINES                         = IT_LINE
*     EXCEPTIONS
*       ID                            = 1
*       LANGUAGE                      = 2
*       NAME                          = 3
*       NOT_FOUND                     = 4
*       OBJECT                        = 5
*       REFERENCE_CHECK               = 6
*       WRONG_ACCESS_TO_ARCHIVE       = 7
*       OTHERS                        = 8
*              .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    READ TABLE IT_LINE INDEX 1.
*    IF SY-SUBRC = 0.
*      IT_FORM-ZSKP = IT_LINE-TDLINE.
*    ELSE.
*      IT_FORM-ZSKP = ''.
*    ENDIF.
*
*
*    CLEAR : IT_LINE.
*    REFRESH IT_LINE.
*    "- Nomor SKP
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
**         CLIENT                        = SY-MANDT
*        ID                            = 'Z010'
*        LANGUAGE                      = SY-LANGU
*        NAME                          = V_VBELN
*        OBJECT                        = 'VBBK'
**         ARCHIVE_HANDLE                = 0
**         LOCAL_CAT                     = ' '
**       IMPORTING
**         HEADER                        =
**         OLD_LINE_COUNTER              =
*      TABLES
*        LINES                         = IT_LINE
*     EXCEPTIONS
*       ID                            = 1
*       LANGUAGE                      = 2
*       NAME                          = 3
*       NOT_FOUND                     = 4
*       OBJECT                        = 5
*       REFERENCE_CHECK               = 6
*       WRONG_ACCESS_TO_ARCHIVE       = 7
*       OTHERS                        = 8
*              .
*    IF SY-SUBRC <> 0.
** Implement suitable error handling here
*    ENDIF.
*
*    READ TABLE IT_LINE INDEX 1.
*    IF SY-SUBRC = 0.
**      IT_FORM-ZREMARKS = IT_LINE-TDLINE.
*      V_REMARKS = IT_LINE-TDLINE.
*    ELSE.
**      IT_FORM-ZREMARKS = ''.
*      V_REMARKS = ''.
*    ENDIF.

    CONCATENATE IT_FORM-VBELN IT_FORM-POSNR INTO V_INFO.
    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Item Information
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z103'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_INFO
        OBJECT                        = 'VBBP'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_FORM-ZINFORMATION = IT_LINE-TDLINE.
    ELSE.
      IT_FORM-ZINFORMATION = ''.
    ENDIF.

    P_DEC = IT_FORM-LFIMG .
    WRITE P_DEC TO IT_FORM-CLFIMG.
    CONDENSE IT_FORM-CLFIMG NO-GAPS.

    MODIFY IT_FORM.
  ENDLOOP.

  PERFORM GET_HDR_TEXT.

ENDFORM.                    " PRINT_DATA


*&---------------------------------------------------------------------*
*&      Form  CALL_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_FORM .
  DATA : V_SUM TYPE P DECIMALS 2,
         CSUM(15),
         PRINT_COUNTER TYPE C LENGTH 3.
  CLEAR : I_SSFCTRLOP.
  IT_FORM_PRINT[] = IT_FORM[].
  I_SSFCTRLOP-DEVICE    = 'PRINTER'.
  I_SSFCTRLOP-PREVIEW   = 'X'.
  IF PRINT EQ 'X'.
    I_SSFCOMPOP-TDNOPREV = 'X'.
    I_SSFCOMPOP-TDNOPRINT = ''.
  ELSEIF PREVIEW EQ 'X'.
    I_SSFCOMPOP-TDNOPRINT = 'X'.
    I_SSFCOMPOP-TDNOPREV = ''.
  ENDIF.

  LOOP AT IT_TEMP.
    DATA : IT_ZNAST LIKE ZNAST.
    CLEAR : IT_FORM, WA_FORM, PRINT_COUNTER, IT_ZNAST,NIK.
    REFRESH IT_FORM.

    CLEAR : IT_LINE,V_VBELN.
    REFRESH IT_LINE.
    V_VBELN = IT_TEMP-VBELN.
    "- GET NIK
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z113'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      NIK = IT_LINE-TDLINE.
    ELSE.
      NIK = ''.
    ENDIF.
    SHIFT NIK LEFT DELETING LEADING '0'.


    CLEAR : NO, V_SUM.
    LOOP AT IT_FORM_PRINT WHERE VBELN = IT_TEMP-VBELN.
      NO = NO + 1.
      IT_FORM_PRINT-ZNO = NO.

      V_SUM = V_SUM + IT_FORM_PRINT-LFIMG.

      MODIFY IT_FORM_PRINT.

      READ TABLE IT_FORM_PRINT INTO WA_FORM.
      APPEND WA_FORM TO IT_FORM.
    ENDLOOP.

    WRITE V_SUM TO CSUM.
    CONDENSE CSUM NO-GAPS.

    SELECT SINGLE COUNTER INTO PRINT_COUNTER
      FROM ZNAST
      WHERE OBJKY1 = IT_TEMP-VBELN.
    IF SY-SUBRC EQ 0.
      CONDENSE PRINT_COUNTER.
      PRINT_COUNTER = PRINT_COUNTER + 1.
    ELSE.
      PRINT_COUNTER =  1.
    ENDIF.
    CONDENSE PRINT_COUNTER.
    IF PRINT_COUNTER LT 10.
      CONCATENATE '00' PRINT_COUNTER INTO PRINT_COUNTER.
    ELSEIF PRINT_COUNTER LT 100.
      CONCATENATE '0' PRINT_COUNTER INTO PRINT_COUNTER.
      CONDENSE PRINT_COUNTER.
    ENDIF.
    LOOP AT IT_FORM INTO WA_FORM.
      EXIT.
    ENDLOOP.

    "- Calling Smartform
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME                 = 'ZPPF_REC_MAT_BY_PROD'
*           VARIANT                  = ' '
*           DIRECT_CALL              = ' '
     IMPORTING
        FM_NAME                  = FM_NAME
*         EXCEPTIONS
*           NO_FORM                  = 1
*           NO_FUNCTION_MODULE       = 2
*           OTHERS                   = 3
              .

    CLEAR: V_STITLE, V_TITLE, V_SKP. "Add By Afir 15.04.2020 for SJ Pembuangan Scrap
    IF IT_PRINT-LFART = 'ZSCF'.
      V_TITLE  = 'SURAT JALAN'.
      V_STITLE   = 'Scrap Sale'.
      V_SKP    = 'SKP No.'.
      CONCATENATE ':    'WA_FORM-ZSKP INTO WA_FORM-ZSKP SEPARATED BY SPACE.
    ELSEIF IT_PRINT-LFART = 'ZSFD'.
      V_TITLE  = 'SURAT IJIN PENGELUARAN BARANG'.
      V_STITLE = '(Waste Film)'.
      V_SKP    = ''.
      WA_FORM-ZSKP = ''.
    ENDIF.

    CALL FUNCTION FM_NAME
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS     = I_SSFCOMPOP
        IF_FORM            = WA_FORM
        CSUM               = CSUM
        PRINT_COUNTER      = PRINT_COUNTER
        NIK                = NIK
        V_STITLE           = V_STITLE "Add By Afir 15.04.2020 for SJ Pembuangan Scrap
        V_TITLE            = V_TITLE  "Add By Afir 15.04.2020 for SJ Pembuangan Scrap
        V_SKP              = V_SKP    "Add By Afir 15.04.2020 for SJ Pembuangan Scrap
        V_REMARKS          = V_REMARKS
      TABLES
        IT_FORM            = IT_FORM.

    IF PRINT EQ 'X'.
      IF PRINT_COUNTER GT 1.
        UPDATE ZNAST SET COUNTER = PRINT_COUNTER USER2 = SY-UNAME
        WHERE OBJKY1 = IT_TEMP-VBELN.
      ELSEIF PRINT_COUNTER EQ 1.
        IT_ZNAST-OBJKY1 = IT_TEMP-VBELN.
        IT_ZNAST-USER1 = SY-UNAME.
        IT_ZNAST-COUNTER = 1.
        INSERT ZNAST FROM IT_ZNAST.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " CALL_FORM


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
**      WA_ERROR-ZEILE = ZMJAHR.
      WA_ERROR-KUNNR = ZKUNNR.
      WA_ERROR-ROUTE = ZROUTE.
      WA_ERROR-BUDAT = ZWADAT.
      WA_ERROR-WERKS = ZWERKS.
      WA_ERROR-VSTEL = ZVSTEL.
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


*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ALL .
  DATA : V_WBSTK LIKE VBUK-WBSTK.
  CLEAR : IT_ALL.
  REFRESH : IT_ALL.

  SELECT
    NOREF
    MBLNR
    MJAHR
    KUNNR
    ROUTE
*    BUDAT
    WERKS
    LGORT
    VSTEL
    ZPENGEMUDI
    ZKENDARAAN
    ZSKP
    ERDAT
    ERZET
    ERNAM
    MESSAGE
    ICON
    INTO CORRESPONDING FIELDS OF TABLE IT_ALL
    FROM ZTLOG_SALE
    WHERE ZTLOG_SALE~NOREF IN SE_VBELN
      AND ZTLOG_SALE~WERKS IN SE_WERKS
      AND ZTLOG_SALE~LGORT IN SE_LGORT
      AND ZTLOG_SALE~BUDAT IN SE_WADAT
      AND ZTLOG_SALE~KUNNR IN SE_KUNNR.

  LOOP AT IT_ALL.
    SELECT SINGLE LIKP~WADAT_IST
      INTO IT_ALL-BUDAT
      FROM LIKP
      WHERE LIKP~VBELN = IT_ALL-NOREF.

    IF IT_ALL-BUDAT EQ '00000000'.
      SELECT SINGLE ZTLOG_SALE~BUDAT
      INTO IT_ALL-BUDAT
      FROM ZTLOG_SALE
      WHERE ZTLOG_SALE~NOREF = IT_ALL-NOREF.
    ENDIF.

    CLEAR : V_WBSTK.
    SELECT SINGLE VBUK~WBSTK
      INTO V_WBSTK
      FROM VBUK
      WHERE VBUK~VBELN = IT_ALL-NOREF.

    CASE V_WBSTK.
      WHEN ''.
        IT_ALL-WBSTK = 'Not Relevant'.
      WHEN 'A'.
        IT_ALL-WBSTK = 'Not yet processed'.
      WHEN 'B'.
        IT_ALL-WBSTK = 'Partially processed'.
      WHEN 'C'.
        IT_ALL-WBSTK = 'Completely processed'.
    ENDCASE.

    IF V_WBSTK NE 'C'.
      IT_ALL-ICON = '@09@'.
    ENDIF.

    IF IT_ALL-NOREF EQ ''.
      IT_ALL-ICON = '@0A@'.
    ENDIF.

    MODIFY IT_ALL.
  ENDLOOP.

  IF RB2 = 'X'.
    DELETE IT_ALL WHERE ICON NE '@09@'.
  ELSEIF RB3 = 'X'.
    DELETE IT_ALL WHERE ICON NE '@0A@'.
  ENDIF.

ENDFORM.                    " GET_DATA_ALL
*&---------------------------------------------------------------------*
*&      Form  POP_UP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POP_UP .
  DATA : SEL LIKE SVAL OCCURS 0 WITH HEADER LINE,
         RETRN.
  DATA : ZDATE(10), ZZDATE(10).

  CLEAR : SEL, WA_EXECUTION.
  REFRESH : SEL.

  SELECT LIKP~WADAT_IST AS BUDAT
    INTO CORRESPONDING FIELDS OF TABLE IT_BUDAT
    FROM LIKP
    FOR ALL ENTRIES IN IT_EXECUTION
    WHERE LIKP~VBELN = IT_EXECUTION-NOREF.

  SORT IT_EXECUTION DESCENDING BY BUDAT.
  READ TABLE IT_EXECUTION INDEX 1 INTO WA_EXECUTION.
  IF SY-SUBRC = 0.
    ZZDATE = WA_EXECUTION-BUDAT.
  ENDIF.

  CLEAR : SY-UCOMM.
  SEL-TABNAME    = 'MKPF'.
  SEL-FIELDNAME  = 'BUDAT'.
  SEL-VALUE      = SY-DATUM.
  APPEND SEL.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE     = 'Define Date'
      START_COLUMN    = '28'
      START_ROW       = '10'
    IMPORTING
      RETURNCODE      = RETRN
    TABLES
      FIELDS          = SEL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.


  READ TABLE SEL  WITH KEY FIELDNAME = 'BUDAT'.
  IF SY-SUBRC = 0.
    ZDATE = SEL-VALUE.
  ENDIF.

  IF ZDATE EQ ''.
    MESSAGE 'Date must be filled' TYPE 'E'.
    EXIT.
  ENDIF.

  V_DD = ZDATE+6(2).
  V_MM = ZDATE+4(2).
  V_YY = ZDATE(4).
  CONCATENATE V_DD V_MM V_YY INTO VDATE SEPARATED BY '.'.

ENDFORM.                    " POP_UP


*&---------------------------------------------------------------------*
*&      Form  GI_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GI_DATA .
  PERFORM GET_SELECTED.

  "- CTU_PARAMS
  OPT-DISMODE  = 'E'.
  OPT-UPDMODE  = 'S'.
  OPT-RACOMMIT = 'X'.
  OPT-DEFSIZE  = 'X'.

  LOOP AT IT_EXECUTION.
    CLEAR   IT_BDCDATA.
    REFRESH IT_BDCDATA.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '4004'.
    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIKP-VBELN'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM BDC_FIELD       USING 'LIKP-VBELN'
                                   IT_EXECUTION-NOREF.

    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=T\04'.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=T\01'.

    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '/00'.

    PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                  'LIKP-WADAT_IST'.
    PERFORM BDC_FIELD       USING 'LIKP-WADAT_IST'
                                   VDATE.
    PERFORM BDC_DYNPRO      USING 'SAPMV50A' '1000'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                  '=WABU_T'.

    CALL TRANSACTION 'VL02N' USING IT_BDCDATA
                             OPTIONS FROM OPT
                             MESSAGES INTO IT_BDCMSGCOLL.

  ENDLOOP.
  COMMIT WORK.
  CALL SCREEN 1400.
ENDFORM.                    " GI_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED .
  CLEAR : IT_EXECUTION.
  REFRESH : IT_EXECUTION.

  IT_EXECUTION[] = IT_ALL[].
  DELETE IT_EXECUTION WHERE BOX NE 'X'.
*  SORT IT_EXECUTION ASCENDING BY MBLNR.
*  DELETE ADJACENT DUPLICATES FROM IT_EXECUTION COMPARING MBLNR.

ENDFORM.                    " GET_SELECTED

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_TEST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_TEST .

  CLEAR   : IT_MSEG, IT_DLV_ITEMS, IT_DATES, IT_RET, V_DATE.
  REFRESH : IT_MSEG, IT_DLV_ITEMS, IT_DATES, IT_RET.
  CONCATENATE SY-DATUM SY-UZEIT INTO V_DATE.

  WA_DATES-TIMETYPE      = 'WSHDRWADAT'.
  WA_DATES-TIMESTAMP_UTC = V_DATE.
  WA_DATES-TIMEZONE      = 'UTC+7'.
  APPEND WA_DATES TO IT_DATES.

  SELECT
   MSEG~MBLNR
   MSEG~ZEILE
   MSEG~MATNR
   MSEG~MENGE
   MSEG~MEINS
   INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
   FROM MSEG
   WHERE MSEG~MBLNR IN S_MBLNR_
     AND MSEG~MJAHR = ZMJAHR_
     AND MSEG~BWART IN ('531', '561').

  IF IT_MSEG[] IS INITIAL.
    MESSAGE 'No data selected. Data not contain mvmt type 531.' TYPE 'I'.
    LEAVE TO SCREEN 1700.
  ENDIF.


  CLEAR : V_POSNR.
  LOOP AT IT_MSEG.
    CLEAR : ZMATNR, ZTEXT.

    SELECT SINGLE MVKE~MATNR
      INTO ZMATNR
      FROM MVKE
      WHERE MVKE~MATNR = IT_MSEG-MATNR.

    IF SY-SUBRC <> 0.
      CONCATENATE 'Sales data for material' IT_MSEG-MATNR 'not maintain yet.' INTO ZTEXT SEPARATED BY SPACE.
      MESSAGE ZTEXT TYPE 'E'.
      EXIT.
    ENDIF.

**      WRITE IT_EXECUTION-MENGE TO IT_EXECUTION-CMENGE.
**      CONDENSE IT_EXECUTION-CMENGE NO-GAPS.
    V_POSNR = V_POSNR + 10.
    IT_MSEG-POSNR = V_POSNR.
    MODIFY IT_MSEG.

    CLEAR : WA_DLV_ITEMS, WA_MSEG.
    READ TABLE IT_MSEG INTO WA_MSEG.

    WA_DLV_ITEMS-REF_ITEM   = WA_MSEG-POSNR.
    WA_DLV_ITEMS-MATERIAL   = WA_MSEG-MATNR.
    WA_DLV_ITEMS-DLV_QTY    = WA_MSEG-MENGE.
    WA_DLV_ITEMS-SALES_UNIT = WA_MSEG-MEINS.
    WA_DLV_ITEMS-PLANT      = ZWERKS_.
    WA_DLV_ITEMS-STGE_LOC   = ZLGORT_.
**      WA_DLV_ITEMS-STGE_LOC   = '1301'.

    APPEND WA_DLV_ITEMS TO IT_DLV_ITEMS.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATENOREF'
    EXPORTING
      SHIP_POINT           = ZVSTEL_
      DLV_TYPE             = 'ZSCF'
      SALESORG             = ZVKORG_
      DISTR_CHAN           = ZVTWEG_
      DIVISION             = ZSPART_
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

  IF V_DELIVERY NE ''.
    MESSAGE 'Test run success.' TYPE 'S'.
  ELSE.
    MESSAGE 'Test run failed.' TYPE 'W'.
  ENDIF.

ENDFORM.                    " UPLOAD_TEST


*&---------------------------------------------------------------------*
*&      Form  INITIAL_LGORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIAL_LGORT .

  CLEAR S_SLOCT.
  IF S_PLANT = '1000'.
    S_SLOCT = '1700'.
  ELSEIF S_PLANT = '2000'.
    S_SLOCT = '2700'.
  ELSEIF S_PLANT = 'TTA2'.  " ADD NEW COMPANY
    S_SLOCT = '2700'.
*  ELSEIF S_PLANT = 'TTE2'.  " ADD NEW COMPANY
*    S_SLOCT = '2700'.
  ELSE.
    S_SLOCT = ''.
  ENDIF.
ENDFORM.                    " INITIAL_LGORT


*&---------------------------------------------------------------------*
*&      Form  COPYDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_COPYDATA .

  PERFORM INITIAL_LGORT.

  PERFORM F_CHECK_NIK CHANGING L_ERRNO.

  IF L_ERRNO = -1.
    MESSAGE MESSAGE TYPE 'I' DISPLAY LIKE 'W'.

  ELSE.

    IF IT_TIMBANG[] IS NOT INITIAL.
      MESSAGE 'Data telah dicopy' TYPE 'I'.
    ELSE.

      IF S_PLANT IS INITIAL.
        IF S_MATNR IS INITIAL.
          IF S_SLOCA IS INITIAL.
            MESSAGE 'Isi Plant, Material, dan SLoc Asal !' TYPE 'I'.
          ELSE.
            MESSAGE 'Isi Plant dan Material!' TYPE 'I'.
          ENDIF.
        ELSE.
          MESSAGE 'Isi Plant !' TYPE 'I'.
        ENDIF.
      ELSE.
        IF S_MATNR IS INITIAL.
          IF S_SLOCA IS INITIAL.
            MESSAGE 'Isi Material, dan SLoc Asal !' TYPE 'I'.
          ELSE.
            MESSAGE 'Isi Material!' TYPE 'I'.
          ENDIF.
        ELSE.
          IF S_SLOCA IS INITIAL..
            MESSAGE 'Isi SLoc Asal!' TYPE 'I'.
          ELSE.

            PERFORM F_GET_RANGE_SLOC.

            IF S_SLOCA NOT IN R_SLOCA.
              CLEAR VMSG.
              CONCATENATE 'SLoc asal bukan SLoc Raw Recycle  di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
              MESSAGE VMSG TYPE 'I' DISPLAY LIKE 'W'.
            ELSE.


              PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.
              IF L_ERRNO <> -1.
                CLEAR WA_TIMBANG.
                WA_TIMBANG-MATNR = S_MATNR.
                WA_TIMBANG-WERKS = S_PLANT.
                WA_TIMBANG-LGORT = S_SLOCT.
                WA_TIMBANG-LGORA = S_SLOCA.
                APPEND WA_TIMBANG TO IT_TIMBANG.

                LOOP AT IT_TIMBANG.

                  SELECT SINGLE MARA~MEINS
                    INTO IT_TIMBANG-MEINS
                    FROM MARA
                    WHERE MARA~MATNR = IT_TIMBANG-MATNR.


                  SELECT SINGLE MAKT~MAKTX
                    INTO IT_TIMBANG-MAKTX
                    FROM MAKT
                    WHERE MATNR = IT_TIMBANG-MATNR.

                  IT_TIMBANG-NO = SY-TABIX.

                  MODIFY IT_TIMBANG.
                ENDLOOP.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.                    " COPYDATA

*&---------------------------------------------------------------------*
*&      Form  F_TESTRUN
*&---------------------------------------------------------------------*
FORM F_TESTRUN .
  CLEAR : IS_TEST_RUN.
  IS_TEST_RUN = 'X'.

  IF IT_TIMBANG[] IS INITIAL.
    MESSAGE 'Tidak ada data.' TYPE 'I'.
  ELSE.

    PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.
    IF L_ERRNO <> -1.
      PERFORM F_VALIDATE_TIMBANG CHANGING L_ERRNO.
      IF L_ERRNO <> -1.
*        BREAK-POINT.
        PERFORM F_GETORDERGI CHANGING L_ERRNO.
        IF L_ERRNO = -1.

*-- add by Yulius on 08.10.2017 case salah pembebanan
          "TAMBAHKAN KONDISI JIKA TIDAK ADA SESUAI DATA TIMBANG
*          PERFORM F_DATATIMBANG CHANGING L_ERRNO.
*
*          IF L_ERRNO = -1.
*            MESSAGE 'Data tidak tersedia.' TYPE 'I'.
*          ELSE.
*            PERFORM F_FIELD_CATALOG.
*            PERFORM F_LAYOUT_TIMBANG.
*            PERFORM F_LIST_DETAILTIMBANG.
*          ENDIF.

          MESSAGE 'Data tidak tersedia.' TYPE 'I'.
*-- end of add by Yulius on 08.10.2017 case salah pembebanan

        ELSE.
          PERFORM F_FIELD_CATALOG.
          PERFORM F_LAYOUT_TIMBANG.
          PERFORM F_LIST_DETAILTIMBANG.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.                    " F_TESTRUN
*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAILTIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAILTIMBANG .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_LIKP BY VBELN POSNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_TB'
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_TB'
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
      T_OUTTAB                 = IT_ORDERGI
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAILTIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_TIMBANG
*&---------------------------------------------------------------------*
FORM F_VALIDATE_TIMBANG  CHANGING FI_RET.

  IF S_MATNR = ''.
    MESSAGE 'Material yang akan ditimbang tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
    FI_RET = -1.
  ELSE.

    PERFORM F_GET_RANGE_SLOC.

    LOOP AT IT_TIMBANG.

      "cek material
      IF IT_TIMBANG-MATNR = ''.
        MESSAGE 'Material yang akan ditimbang tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
        FI_RET = -1.
      ELSE.

        "cek quantity gross dan quantity wadah
        IF IT_TIMBANG-GROSS < IT_TIMBANG-WADAH.
          MESSAGE 'Berat Wadah tidak boleh lebih besar dari Gross Qty' TYPE 'S' DISPLAY LIKE 'E'.
          FI_RET = -1.

        ELSE.
          "cek apakah quantity 0
          IF IT_TIMBANG-MENGE IS INITIAL.
            MESSAGE 'Quantity tidak boleh nol' TYPE 'S' DISPLAY LIKE 'E'.
            FI_RET = -1.
          ELSE.
            "CEK SLOC ASAL
            IF IT_TIMBANG-LGORA NOT IN R_SLOCA.
              CLEAR VMSG.
              CONCATENATE 'SLoc asal bukan SLoc Raw Recycle  di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
              MESSAGE VMSG TYPE 'S' DISPLAY LIKE 'E'.
              FI_RET = -1.
            ELSE.
              "cek bagian
              IF IT_TIMBANG-BAGIAN IS INITIAL.
                CLEAR VMSG.
                MESSAGE 'Bagian tidak boleh kosong' TYPE 'S' DISPLAY LIKE 'E'.
                FI_RET = -1.
              ELSE.

                IF IT_TIMBANG-BAGIAN NOT IN R_BAGIAN.
                  CLEAR VMSG.
                  MESSAGE 'Bagian harus diisi dengan SLT,PRS,RCL,OTH,RND, atau GUD' TYPE 'S' DISPLAY LIKE 'E'.
                  FI_RET = -1.
                ELSE.
                  FI_RET = 1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " F_VALIDATE_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  DELETEDATA
*&---------------------------------------------------------------------*
FORM F_DELETEDATA .
  IF IT_TIMBANG[] IS INITIAL.
    MESSAGE 'Tidak ada data yang akan dihapus' TYPE 'I'.
  ELSE.
    DELETE IT_TIMBANG WHERE FLAG = 'X'.

    IF SY-SUBRC <> 0.
      REFRESH IT_TIMBANG[].
    ENDIF.
  ENDIF.

ENDFORM.                    " DELETEDATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_RANGE_SLOC
*&---------------------------------------------------------------------*
*       Get range of SLoc Asal
*----------------------------------------------------------------------*
FORM F_GET_RANGE_SLOC .

  REFRESH : TSLOC, R_SLOCA.
  CLEAR :WR_SLOC.

  SELECT DISTINCT ZRRLGORT AS SLOCA
    LGOBE AS DESC
    INTO CORRESPONDING FIELDS OF TABLE TSLOC
    FROM ZTMAP_SLOCRR
    JOIN T001L
    ON ZTMAP_SLOCRR~ZRRLGORT = T001L~LGORT
    WHERE ZTMAP_SLOCRR~WERKS = S_PLANT.

  LOOP AT TSLOC.
    WR_SLOC-SIGN   = 'I'.
    WR_SLOC-OPTION = 'EQ'.
    WR_SLOC-LOW    = TSLOC-SLOCA.
    APPEND WR_SLOC TO R_SLOCA.
  ENDLOOP.


ENDFORM.                    " F_GET_RANGE_SLOC
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE
*&---------------------------------------------------------------------*
*       Execute Timbang Scrap
*----------------------------------------------------------------------*
FORM F_EXECUTETIMBANG .
  CLEAR IS_TEST_RUN.

  IF IT_TIMBANG[] IS INITIAL.
    MESSAGE 'Tidak ada data.' TYPE 'I'.
  ELSE.

    PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.

    IF L_ERRNO <> -1.


      PERFORM F_VALIDATE_TIMBANG CHANGING L_ERRNO.
      IF L_ERRNO <> -1.
        PERFORM F_CHECK_MATERIAL CHANGING L_ERRNO.
        IF L_ERRNO <> -1.
          PERFORM F_GETORDERGI CHANGING L_ERRNO.

          IF L_ERRNO = -1.
*-- add by Yulius on 08.10.2017 case salah pembebanan
            "TAMBAH KONDISI JIKA TIDAK ADA SESUAI DATA TIMBANG
*            PERFORM F_DATATIMBANG CHANGING L_ERRNO.
*
*            IF L_ERRNO = -1.
*              MESSAGE 'Tidak ada Material yang akan ditimbang.' TYPE 'I'.
*            ELSE.
*              PERFORM F_EXEPROPORTION.
*              PERFORM F_FIELD_CATALOG.
*              PERFORM F_LAYOUT_TIMBANG.
*              PERFORM F_LIST_DETAILTIMBANG.
*            ENDIF.

            MESSAGE 'Tidak ada Material yang akan ditimbang.' TYPE 'I'.
*-- end of add by Yulius on 08.10.2017 case salah pembebanan

          ELSE.
            PERFORM F_EXEPROPORTION.

            PERFORM F_FIELD_CATALOG.
            PERFORM F_LAYOUT_TIMBANG.
            PERFORM F_LIST_DETAILTIMBANG.
          ENDIF.
        ELSE.
          MESSAGE 'Material tidak bisa ditimbang.' TYPE 'I' DISPLAY LIKE 'I'.
        ENDIF.

      ENDIF.
    ENDIF.


  ENDIF.
ENDFORM.                    " F_EXECUTE


*&---------------------------------------------------------------------*
*&      Form  F_SEARCHHELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SEARCHHELP .
  DATA :  BEGIN OF ITCUST OCCURS 0,
          KUNNR LIKE KNA1-KUNNR,
          NAME1 LIKE KNA1-NAME1,
        END OF ITCUST.

  REFRESH ITCUST.
  SELECT KUNNR
      NAME1
    INTO CORRESPONDING FIELDS OF TABLE ITCUST
    FROM KNA1.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'KUNNR'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'ZKUNNR'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = ITCUST.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " F_SEARCHHELP


*&---------------------------------------------------------------------*
*&      Form  F_GETORDERGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_ORDERGR  text
*----------------------------------------------------------------------*
FORM F_GETORDERGI CHANGING P_ERRNO.
  DATA : L_MATNR,
         ITTEMPORD TYPE TABLE OF ITORDER WITH HEADER LINE,
         L_AUFNR TYPE AUFK-AUFNR,
         L_APERIOD TYPE SYDATUM.

  "ADDED BY FATHIR ON 17.06.2020
  " range temporary untuk Matdoc
  RANGES: R_TMPMD FOR MSEG-MBLNR.

  "GET SLOC.
  PERFORM F_GET_SLOCA.

  CLEAR L_APERIOD.
  CONCATENATE  S_PDATE+0(4) S_PDATE+4(2)  '01' INTO L_APERIOD.

  REFRESH IT_ORDERGI.
  CLEAR P_ERRNO.

  "Add tuning

  SELECT RAR_A_MATNR AS LOW INTO CORRESPONDING FIELDS OF TABLE T_MATNR
   FROM ZTMAP_FGRRECYCLE
    WHERE FGR_B_MATNR = S_MATNR
    AND WERKS EQ S_PLANT.   "ADD NEW COMPANY

  IF SY-SUBRC = 0.
    T_MATNR-SIGN = 'I'.
    T_MATNR-OPTION = 'EQ'.
    MODIFY T_MATNR TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
  ENDIF.

  V_BUDAT_LOW = L_APERIOD.
  V_BUDAT_HIGH = S_PDATE.

  CLEAR : T_BUDAT.
  T_BUDAT-SIGN = 'I'.
  T_BUDAT-OPTION = 'EQ'.
  T_BUDAT-LOW = V_BUDAT_LOW.
  APPEND T_BUDAT.
  CLEAR : T_BUDAT.

  WHILE V_BUDAT_LOW < V_BUDAT_HIGH.
    V_BUDAT_LOW = V_BUDAT_LOW + 1.

    T_BUDAT-SIGN = 'I'.
    T_BUDAT-OPTION = 'EQ'.
    T_BUDAT-LOW = V_BUDAT_LOW.
    APPEND T_BUDAT.
    CLEAR : T_BUDAT.
  ENDWHILE.

  "CHANGED BY FATHIR ON 17.06.2020
  " ubah get matdoc recycle, loop by BUDAT
  LOOP AT T_BUDAT.

    CLEAR: R_TMPMD.
    REFRESH: R_TMPMD.

    SELECT MKPF~MBLNR AS LOW INTO CORRESPONDING FIELDS OF TABLE R_TMPMD
      FROM MKPF JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR
      WHERE MKPF~XBLNR = '' AND MKPF~BUDAT = T_BUDAT-LOW AND
             MSEG~BWART IN ('531','532') AND MSEG~WERKS = S_PLANT AND MSEG~LGORT IN R_SLOC.

    APPEND LINES OF R_TMPMD TO T_MBLNR.

  ENDLOOP.

  IF SY-SUBRC = 0.
    T_MBLNR-SIGN = 'I'.
    T_MBLNR-OPTION = 'EQ'.
    MODIFY T_MBLNR TRANSPORTING SIGN OPTION WHERE LOW IS NOT INITIAL.
  ENDIF.
  "End tuning


  "GET DATA ORDER WITH MOV. TYPE 531 AND 532
  IF T_MBLNR[] IS NOT INITIAL.
    SELECT DISTINCT
      MSEG~AUFNR
      MSEG~MATNR
      MSEG~MBLNR
      MSEG~BWART
      MKPF~BKTXT
      MSEG~MENGE
      MSEG~LGORT AS SLOC
      MSEG~CHARG
      INTO CORRESPONDING FIELDS OF TABLE IT_ORDERGI
      FROM MSEG
      JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
      JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
*    JOIN ZTMAP_FGRRECYCLE ON MSEG~MATNR = ZTMAP_FGRRECYCLE~RAR_A_MATNR
      WHERE MSEG~MBLNR IN T_MBLNR "MSEG~WERKS = S_PLANT
      AND MSEG~BWART IN ('531','532')
      "AND MKPF~BKTXT NE ''
      "AND MKPF~BUDAT BETWEEN L_APERIOD AND S_PDATE
      "AND MKPF~XBLNR = ''
      "AND MSEG~LGORT IN R_SLOC
      AND AUFK~AUART IN ('ZP01','ZP02','ZP03','ZP04','ZP05','ZP06','ZP07','ZP08',
                         'ZP09','ZP10','ZP11','ZP12','ZRR1','ZRR2','ZTR1','ZTR2','ZTR7',      "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                         " Added by William at 02.08.2022 (OPP7 CPP1)
                         'ZP13','ZP14','ZP15','ZP16','ZP17','ZP18',
                         'ZTR8','ZTR9','ZTRA','ZTRB','ZTRC')
                         " End added by William at 02.08.2022 (OPP7 CPP1)
      "AND ZTMAP_FGRRECYCLE~FGR_B_MATNR = S_MATNR.
      AND MSEG~MATNR IN T_MATNR.
  ENDIF.
  LOOP AT IT_ORDERGI.
    CLEAR V_MATDOC.
    SELECT SINGLE ZTLOGTIMBANG~ZOLDMD
      INTO V_MATDOC
      FROM ZTLOGTIMBANG
      WHERE ZTLOGTIMBANG~ZOLDMD = IT_ORDERGI-MBLNR.

    IF SY-SUBRC = 0.
      DELETE IT_ORDERGI.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  SORT IT_ORDERGI BY BKTXT AUFNR.
  REFRESH ITTEMPORD.
  ITTEMPORD[] = IT_ORDERGI[].
  DELETE ADJACENT DUPLICATES FROM ITTEMPORD COMPARING BKTXT .

  "CEK CANCEL OR POSTING GI
  LOOP AT ITTEMPORD.
    CLEAR : L_POSTING,L_CANCEL.

    LOOP AT IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT.

      CLEAR : IS_TIMBANG, V_MATDOC.

      IF IT_ORDERGI-BWART = '531'.
        L_POSTING = L_POSTING + 1.
      ELSE.
        L_CANCEL = L_CANCEL + 1.
      ENDIF.


      MODIFY IT_ORDERGI.
    ENDLOOP.

    IF L_POSTING = L_CANCEL.
      DELETE IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT.
      DELETE ITTEMPORD.
      CONTINUE.
    ELSE.

      CLEAR L_MBLNR.
      SELECT MAX( MSEG~MBLNR )
        INTO L_MBLNR
        FROM MSEG
        JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
        WHERE MSEG~MATNR = ITTEMPORD-MATNR
        AND MSEG~AUFNR = ITTEMPORD-AUFNR
        AND MSEG~BWART = '531'
        AND MKPF~BKTXT = ITTEMPORD-BKTXT
        AND MSEG~LGORT = ITTEMPORD-SLOC
        AND MKPF~XBLNR = ''.

      DELETE IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT AND MBLNR NE L_MBLNR.

    ENDIF.
  ENDLOOP.

  CLEAR L_TOTAL.
  LOOP AT IT_ORDERGI.
    L_TOTAL = L_TOTAL + IT_ORDERGI-MENGE.
  ENDLOOP.

  CLEAR LINE_B.
  DESCRIBE TABLE IT_ORDERGI LINES LINE_B.

  CLEAR : LSUM.
  LOOP AT IT_TIMBANG.
    CLEAR WAORDER.
    READ TABLE IT_ORDERGI INTO WAORDER INDEX 1.

    LOOP AT IT_ORDERGI.

      IF SY-TABIX NE LINE_B.
        IT_ORDERGI-ZPROPORSI = ( IT_ORDERGI-MENGE / L_TOTAL ) * IT_TIMBANG-MENGE.
        LSUM = LSUM + IT_ORDERGI-ZPROPORSI.
      ELSE.
        IT_ORDERGI-ZPROPORSI = IT_TIMBANG-MENGE - LSUM.
      ENDIF.

      IT_ORDERGI-ZNETQY = IT_TIMBANG-MENGE.
      IT_ORDERGI-BMATNR = S_MATNR.

      IF IT_ORDERGI-ETYPE = 'E'.
        IT_ORDERGI-ZSTAT = GCF_E1.
      ELSE.
        IT_ORDERGI-ZSTAT = GCF_S1.
      ENDIF.
      IT_ORDERGI-SLOC = S_SLOCA.
      MODIFY IT_ORDERGI.
    ENDLOOP.

    "- 09JAN2013
    CLEAR IS_NEXT.
    PERFORM F_CHECK_STOCK.
    "- 09JAN2013
    PERFORM F_GET_RAW_RECYCLE.

    WHILE IS_NEXT = ''.
      PERFORM F_CHECK_STOCK.

      PERFORM F_GET_RAW_RECYCLE.
    ENDWHILE.

  ENDLOOP.
  IF IT_ORDERGI[] IS INITIAL.
    P_ERRNO = -1.
  ENDIF.

ENDFORM.                    " F_GETORDERGR


*&---------------------------------------------------------------------*
*&      Form  F_GETPROPORTION
*&---------------------------------------------------------------------*
FORM F_EXEPROPORTION .

  DATA : VMSG LIKE MESSAGE,
         L_ITEM  TYPE ZTLOGTIMBANG-ZITEMLOG.

  CLEAR : L_TOTAL, L_ITEM.

  "GET GR PROPORTION.

  LOOP AT IT_TIMBANG.

    PERFORM F_GET_DOC_TIMBANG.

    DATA : LS_SUBRC    TYPE SY-SUBRC.
    CLEAR : GMHEADER, GMITEM, L_ERRNO, MATDOC.
    REFRESH : GMITEM, IT_RET.

    LOOP AT IT_ORDERGI.
      L_ITEM = L_ITEM + 1.
      IF IT_ORDERGI-ETYPE <> 'E'.

        PERFORM F_CREATE_GMVS USING '531' '532'
                             S_PLANT
                             IT_ORDERGI-CHARG
                             S_SLOCT
                             S_SLOCA
                             IT_ORDERGI-AUFNR
                             S_MATNR
                             IT_ORDERGI-MATNR
                             IT_ORDERGI-ZPROPORSI
                             IT_ORDERGI-MBLNR
                             L_ITEM
                             IT_TIMBANG-BAGIAN
                             CHANGING L_ERRNO
                             VMSG.

      ELSE.
        IT_ORDERGI-ZPROPORSI = 0.
      ENDIF.

      MODIFY IT_ORDERGI.
    ENDLOOP.

    "CALL BAPI
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        GOODSMVT_HEADER  = GMHEADER
        GOODSMVT_CODE    = '03'
      IMPORTING
        MATERIALDOCUMENT = MATDOC
      TABLES
        GOODSMVT_ITEM    = GMITEM
        RETURN           = IT_RET.

    CLEAR L_ERRNO.
    READ TABLE IT_RET WITH KEY TYPE = 'E'.
    IF SY-SUBRC = 0. "4

      L_ERRNO = -1.
      CLEAR MESSAGE.
      MESSAGE = 'Posting GI Material Timbang Gagal!'.

      LOOP AT IT_ORDERGI.
        IT_ORDERGI-EMSG     = MESSAGE.
        IT_ORDERGI-ETYPE    = 'E'.
        IT_ORDERGI-ZSTAT = GCF_E1.

        MODIFY IT_ORDERGI.
      ENDLOOP.

    ELSE.

      IF MATDOC = ''.
        MESSAGE = 'Posting GI Material Timbang Gagal!'.

      ELSE.
        CLEAR MESSAGE.
        CONCATENATE 'Posting GI Material Timbang berhasil dengan Material Dokumen' MATDOC INTO MESSAGE SEPARATED BY SPACE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        "MATERIAL DOCUMENT TIMBANG FOR SALE
        CLEAR WA_MATDOC.
        WA_MATDOC-MATDOC = MATDOC.
        APPEND WA_MATDOC TO T_MATDOC.

        CLEAR : V_TOTAL, L_ITEM.
        LOOP AT IT_ORDERGI.
          L_ITEM = L_ITEM + 1.
          V_TOTAL = V_TOTAL + IT_ORDERGI-ZPROPORSI.
          PERFORM F_CREATE_LOGTIMBANG USING '531'
                                      S_PLANT
                                      S_SLOCT
                                      IT_ORDERGI-AUFNR
                                      S_MATNR
                                      IT_ORDERGI-MBLNR
                                      MATDOC
                                      L_ITEM
                                      IT_TIMBANG-BAGIAN
                                      IT_ORDERGI-ZPROPORSI.

          PERFORM F_CREATE_LOGTIMBANG USING '532'
                                           S_PLANT
                                           S_SLOCA
                                           IT_ORDERGI-AUFNR
                                           IT_ORDERGI-MATNR
                                           IT_ORDERGI-MBLNR
                                           MATDOC
                                           L_ITEM
                                           IT_TIMBANG-BAGIAN
                                           IT_ORDERGI-ZPROPORSI.

          VMSG = MESSAGE.

          IF IT_RET[] IS NOT INITIAL.
            LOOP AT IT_RET.
              IT_ORDERGI-ETYPE    = IT_RET-TYPE.
              IT_ORDERGI-EID      = IT_RET-ID.
              IT_ORDERGI-ENUMBER  = IT_RET-NUMBER.
              IT_ORDERGI-EMSG     = IT_RET-MESSAGE.
              IT_ORDERGI-ZSTAT = GCF_E1.
            ENDLOOP.

          ELSE.
            IT_ORDERGI-EMSG     = VMSG.
            IF VMSG CP '*gagal*'.
              IT_ORDERGI-ETYPE    = 'E'.
              IT_ORDERGI-ZSTAT = GCF_E1.
            ELSE.
              IT_ORDERGI-ZSTAT = GCF_S1.
            ENDIF.

          ENDIF.

          MODIFY IT_ORDERGI.
        ENDLOOP.

        READ TABLE IT_ORDERGI WITH KEY ETYPE    = 'E'.

        IF SY-SUBRC = 0.

        ELSE.
          CLEAR : WA_ORDERF.
          REFRESH IT_ORDERF.
          WA_ORDERF-MATNR = IT_TIMBANG-MATNR.

          SELECT SINGLE  MARA~MEINS MAKT~MAKTX
            INTO (WA_ORDERF-UOM, WA_ORDERF-MAKTX)
            FROM MARA
            JOIN MAKT ON MARA~MATNR = MAKT~MATNR
            WHERE MAKT~MATNR = WA_ORDERF-MATNR.


          WA_ORDERF-QTY   = IT_TIMBANG-MENGE.
          APPEND WA_ORDERF TO IT_ORDERF.
          PERFORM F_PRINT_DATA_TIMBANG.

        ENDIF.

      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_GETPROPORTION


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_GMV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3714   text
*      -->P_S_PLANT  text
*      -->P_IT_ORDERGR_CHARG  text
*      -->P_IT_ORDERGR_SLOC  text
*      -->P_IT_ORDERGR_AUFNR  text
*      -->P_IT_ORDERGR_MATNR  text
*      -->P_IT_ORDERGR_ZPROPORSI  text
*----------------------------------------------------------------------*
FORM F_CREATE_GMV  USING
                            P_MTYPE
                            P_PLANT
                            P_CHARG
                            P_SLOC
                            P_AUFNR
                            P_MATNR
                            P_ZPROPORSI
                            P_MBLNR
                            P_LITEM
                            P_BAGIAN
                            P_PRCTR
                  CHANGING P_ERRNO.

  DATA : LS_SUBRC    TYPE SY-SUBRC.
  CLEAR : GMHEADER, GMITEM, P_ERRNO.
  REFRESH : GMITEM.

  "FILL  HEADER DATA
  GMHEADER-PSTNG_DATE = SY-DATUM.
  GMHEADER-DOC_DATE = SY-DATUM.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_CHARG
    IMPORTING
      OUTPUT = P_CHARG.

  GMITEM-PLANT      = P_PLANT.
  IF P_MTYPE = '531'.
    GMITEM-BATCH      = P_CHARG.
  ENDIF.

  GMITEM-STGE_LOC   = P_SLOC.
  GMITEM-WITHDRAWN  = 'X'.
  GMITEM-MOVE_TYPE  = P_MTYPE.
  GMITEM-ENTRY_UOM  = 'KG'.
  GMITEM-ORDERID    = P_AUFNR.
  GMITEM-MATERIAL   = P_MATNR.
  GMITEM-ENTRY_QNT  = P_ZPROPORSI.
  APPEND GMITEM.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = GMHEADER
      GOODSMVT_CODE    = '03'
    IMPORTING
      MATERIALDOCUMENT = MATDOC
    TABLES
      GOODSMVT_ITEM    = GMITEM
      RETURN           = IT_RET.

  READ TABLE IT_RET WITH KEY TYPE = 'E'.

  IF SY-SUBRC NE 0.

    P_ERRNO = -1.
    CLEAR MESSAGE.
    CONCATENATE 'Posting GI' P_AUFNR 'Gagal!' INTO MESSAGE SEPARATED BY SPACE.
    MESSAGE MESSAGE TYPE 'I'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE. "4

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

  ENDIF.

ENDFORM.                    " F_CREATE_GMV

*&---------------------------------------------------------------------*
*&      Form  F_GET_DOC_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DOC_TIMBANG .
  CLEAR L_DOCNO.

  "GET LAST DOCUMENT TIMBANG
  SELECT MAX( ZTLOGTIMBANG~ZIDLOG )
    INTO L_DOCNO
    FROM ZTLOGTIMBANG.

  IF SY-SUBRC <> 0.
    L_DOCNO = 1.
  ELSE.
    ADD 1 TO L_DOCNO.
  ENDIF.

ENDFORM.                    " F_GET_DOC_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_LOGTIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MTYPE  text
*      -->P_P_PLANT  text
*      -->P_P_SLOC  text
*      -->P_P_AUFNR  text
*      -->P_P_MATNR  text
*      -->P_MATDOC  text
*      -->P_P_ZPROPORSI  text
*----------------------------------------------------------------------*
FORM F_CREATE_LOGTIMBANG  USING    P_P_MTYPE
                                   P_P_PLANT
                                   P_P_SLOC
                                   P_P_AUFNR
                                   P_P_MATNR
                                   P_P_MBLNR
                                   P_MATDOC
                                   P_P_L_ITEM
                                   P_P_BAGIAN
                                   P_P_ZPROPORSI.

  "GET POSTING DATE NEW MATERIAL DOCUMENT.
  CLEAR : V_BUDAT, V_CPUDT, V_CPUTM.
  SELECT SINGLE MKPF~BUDAT MKPF~CPUDT MKPF~CPUTM
    INTO (V_BUDAT, V_CPUDT, V_CPUTM)
    FROM MKPF
    WHERE MKPF~MBLNR = P_MATDOC.

  CLEAR WA_LOG_TIMBANG.
  WA_LOG_TIMBANG-ZIDLOG   = L_DOCNO.
  WA_LOG_TIMBANG-ZITEMLOG = P_P_L_ITEM.
  WA_LOG_TIMBANG-ZOLDMD   = P_P_MBLNR.
  WA_LOG_TIMBANG-ZNEWMD   = P_MATDOC.
  WA_LOG_TIMBANG-ZBWART   = P_P_MTYPE.
  WA_LOG_TIMBANG-ZAUFNR   = P_P_AUFNR.
  WA_LOG_TIMBANG-ZMATNR   = P_P_MATNR.
  WA_LOG_TIMBANG-ZQTY     = P_P_ZPROPORSI.
  WA_LOG_TIMBANG-ZBAGIAN  = P_P_BAGIAN.
  WA_LOG_TIMBANG-ZWERKS   = P_P_PLANT.
  WA_LOG_TIMBANG-ZLGORT   = P_P_SLOC.
  WA_LOG_TIMBANG-ZBUDAT   = V_BUDAT.
  WA_LOG_TIMBANG-ZCPUDT   = V_CPUDT.
  WA_LOG_TIMBANG-ZCPUTM   = V_CPUTM.
  WA_LOG_TIMBANG-ZUSNAM   = S_NIKP.

  INSERT ZTLOGTIMBANG FROM WA_LOG_TIMBANG.
  COMMIT WORK AND WAIT.

ENDFORM.                    " F_CREATE_LOGTIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_TIMBANG
*&---------------------------------------------------------------------*

FORM F_LAYOUT_TIMBANG .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " F_LAYOUT_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_GMVS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3795   text
*      -->P_3796   text
*      -->P_S_PLANT  text
*      -->P_IT_ORDERGI_CHARG  text
*      -->P_S_SLOCA  text
*      -->P_IT_ORDERGI_SLOC  text
*      -->P_IT_ORDERGI_AUFNR  text
*      -->P_IT_ORDERGI_MATNR  text
*      -->P_IT_ORDERGI_ZPROPORSI  text
*      -->P_IT_ORDERGI_MBLNR  text
*      -->P_L_ITEM  text
*      -->P_IT_TIMBANG_BAGIAN  text
*      -->P_IT_TIMBANG_PRCTR  text
*      <--P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_CREATE_GMVS  "TABLES PIT_RET STRUCTURE BAPIRET2
                    USING    P_MTYPE1
                             P_MTYPE2
                             P_PLANT
                             P_CHARG
                             P_S_SLOCT
                             P_SLOC
                             P_AUFNR
                             P_S_MATNR
                             P_MATNR
                             P_ZPROPORSI
                             P_MBLNR
                             P_LITEM
                             P_BAGIAN
                    CHANGING P_ERRNO
                      P_MSG.


  "FILL  HEADER DATA
  GMHEADER-PSTNG_DATE = S_PDATE .
  GMHEADER-DOC_DATE = S_PDATE.
  GMHEADER-REF_DOC_NO = 'TIMBANG SCRAP'.

  SHIFT S_NIKP LEFT DELETING LEADING ''.
  SHIFT S_NIKPR LEFT DELETING LEADING ''.
  CONCATENATE S_NIKP '/' S_NIKPR INTO GMHEADER-HEADER_TXT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_CHARG
    IMPORTING
      OUTPUT = P_CHARG.

  "DATA FOR ITEM WITH MOVM. TYPE 531
  GMITEM-PLANT      = P_PLANT.
  GMITEM-STGE_LOC   = P_S_SLOCT .
  GMITEM-WITHDRAWN  = 'X'.
  GMITEM-MOVE_TYPE  = P_MTYPE1.
  GMITEM-ENTRY_UOM  = 'KG'.
  GMITEM-ORDERID    = P_AUFNR.
  GMITEM-MATERIAL   = P_S_MATNR.
  GMITEM-ENTRY_QNT  = P_ZPROPORSI.
  GMITEM-GR_RCPT    = 'TIMBANG'.
  APPEND GMITEM.

  "DATA FOR ITEM WITH MOVM. TYPE 532
  GMITEM-STGE_LOC   = P_SLOC."P_S_SLOCA.
  GMITEM-WITHDRAWN  = 'X'.
  GMITEM-MOVE_TYPE  = P_MTYPE2.
  GMITEM-ENTRY_UOM  = 'KG'.
  GMITEM-ORDERID    = P_AUFNR.
  GMITEM-MATERIAL   = P_MATNR.
  GMITEM-ENTRY_QNT  = P_ZPROPORSI.
  GMITEM-GR_RCPT    = 'TIMBANG'.
  APPEND GMITEM.

ENDFORM.                    " F_CREATE_GMVS


*&---------------------------------------------------------------------*
*&      Form  F_CEK_MATDOC
*&---------------------------------------------------------------------*
FORM F_CEK_MATDOC  CHANGING P_ERRNO.

  LOOP AT IT_ORDERGI.
    CLEAR V_MATDOC.

    SELECT SINGLE ZTLOGTIMBANG~ZOLDMD
      INTO V_MATDOC
      FROM ZTLOGTIMBANG
      WHERE ZTLOGTIMBANG~ZOLDMD = IT_ORDERGI-MBLNR.

    IF SY-SUBRC = 0.
      DELETE IT_ORDERGI.
      CONTINUE.
    ENDIF.

    MODIFY IT_ORDERGI.
  ENDLOOP.

  IF IT_ORDERGI[] IS INITIAL.
    P_ERRNO = -1.
  ELSE.

    LOOP AT IT_ORDERGI.
      CLEAR V_MATDOC.

      SELECT SINGLE AUFM~MBLNR
        INTO V_MATDOC
        FROM AUFM
        WHERE AUFM~MBLNR = IT_ORDERGI-MBLNR
        AND AUFM~WEMPF = 'TIMBANG'.

      IF SY-SUBRC = 0.
        DELETE IT_ORDERGI.
        CONTINUE.
      ENDIF.

      MODIFY IT_ORDERGI.
    ENDLOOP.

    IF IT_ORDERGI[] IS INITIAL.
      P_ERRNO = -1.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_CEK_MATDOC

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOG
*&---------------------------------------------------------------------*
FORM F_DISPLAY_LOG .

  PERFORM F_GET_LOG_TIMBANG CHANGING L_ERRNO.

  IF L_ERRNO = -1.
    MESSAGE 'Tidak Ada Data.' TYPE 'I'.
  ELSE.
    PERFORM F_DISPLAY_LOGTIMBANG.
  ENDIF.

ENDFORM.                    " F_DISPLAY_LOG


*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_ERRNO  text
*----------------------------------------------------------------------*
FORM F_GET_LOG_TIMBANG  CHANGING P_ERRNO.
  REFRESH ITLOGTIMBANG.
  CLEAR P_ERRNO.
  IF RL1 = 'X'.
    SELECT * FROM ZTLOGTIMBANG
      INTO CORRESPONDING FIELDS OF TABLE ITLOGTIMBANG
      WHERE ZIDLOG IN S_IDLOG
      AND ZITEMLOG IN S_ITEM
      AND ZBUDAT   IN S_BUDAT
      AND ZUSNAM   IN  S_UID
      AND ZWERKS   IN S_LPLANT
      AND ZIND NE 'C'.

  ELSE.
    SELECT * FROM ZTLOGTIMBANG
      INTO CORRESPONDING FIELDS OF TABLE ITLOGTIMBANG
      WHERE ZIDLOG IN S_IDLOG
      AND ZITEMLOG IN S_ITEM
      AND ZBUDAT   IN S_BUDAT
      AND ZUSNAM   IN  S_UID
      AND ZWERKS   IN S_LPLANT.


  ENDIF.

  LOOP AT ITLOGTIMBANG.
    IF ITLOGTIMBANG-ZIND = 'C'.
      ITLOGTIMBANG-STAT = ICON_RED_LIGHT.
    ELSE.
      ITLOGTIMBANG-STAT = ICON_GREEN_LIGHT.
    ENDIF.
    MODIFY ITLOGTIMBANG.
  ENDLOOP.


  IF ITLOGTIMBANG[] IS INITIAL.
    P_ERRNO = -1.
  ELSE.
    SORT ITLOGTIMBANG DESCENDING BY ZNEWMD.
  ENDIF.

ENDFORM.                    " F_GET_LOG_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_LOGTIMBANG
*&---------------------------------------------------------------------*

FORM F_DISPLAY_LOGTIMBANG .
  PERFORM F_FIELD_CATALOG_LT.
  PERFORM F_LAYOUT_TIMBANG.
  PERFORM F_LIST_DETAIL_LTIMBANG.
ENDFORM.                    " F_DISPLAY_LOGTIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LT
*&---------------------------------------------------------------------*
FORM F_FIELD_CATALOG_LT .
  REFRESH : T_FIELDCAT.

  T_FIELDCAT-FIELDNAME   = 'MARK'.
  T_FIELDCAT-SELTEXT_M   = 'Mark'.
  T_FIELDCAT-INPUT     = 'X'.
  T_FIELDCAT-EDIT     = 'X'.
  T_FIELDCAT-CHECKBOX = 'X'.
  APPEND T_FIELDCAT.

  PERFORM F_ALV_FIELDCATG_ICON USING 'ITLOGTIMBANG' :
         'STAT'   ''  ''  ''  ''  'Status'      ''   ''  ''  '' ,
         'ZIDLOG'   ''  ''  ''  ''  'Doc. Timbang No.'      ''   ''  ''  '' ,
         'ZITEMLOG' ''  ''  ''  ''  'Item No.'     ''   ''  ''  '',
         'ZOLDMD'   ''  ''  ''  ''  'Material Doc.'         ''   ''  ''  '',
         'ZNEWMD'   ''  ''  ''  ''  'Material Doc. Timbang' ''   ''  ''  '',
         'ZBWART'   ''  ''  ''  ''  'Movement Type'         ''   ''  ''  '',
         'ZAUFNR'   ''  ''  ''  ''  'Process Order'         ''   ''  ''  '',
         'ZMATNR'   ''  ''  ''  ''  'Material'              ''   ''  ''  '',
         'ZQTY'     ''  ''  ''  ''  'Qty. Timbang'              ''   ''  ''  '',
         'ZLGORT'   ''  ''  ''  ''  'Sloc'                  ''   ''  ''  '',
         'ZWERKS'   ''  ''  ''  ''  'Plant'                 ''   ''  ''  '',
         'ZBAGIAN'  ''  ''  ''  ''  'Bagian'                ''   ''  ''  '',
         'ZBUDAT'   ''  ''  ''  ''  'Posting Date'          ''   ''  ''  '',
         'ZCPUDT'   ''  ''  ''  ''  'Entered in'            ''   ''  ''  '',
         'ZCPUTM'   '' ''   ''  ''  'Entered at'            '' ' ' '' '',
         'ZUSNAM'   '' ''   ''  ''  'Username'              '' ' ' '' '',
         'ZIND'     '' ''   ''  ''  'Cancel Indicator'              '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG_LT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LTIMBANG
*&---------------------------------------------------------------------*
FORM F_LIST_DETAIL_LTIMBANG .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_LIKP BY VBELN POSNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_LT'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUSL'
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
      T_OUTTAB                 = ITLOGTIMBANG
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL_LTIMBANG

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUSL USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.
  SET PF-STATUS 'PF1200'.

ENDFORM.                    "F_GUI_STATUSL
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_ALL
*&---------------------------------------------------------------------*
FORM F_SELECT_ALL .
  LOOP AT ITLOGTIMBANG.
    ITLOGTIMBANG-MARK = 'X'.
    MODIFY ITLOGTIMBANG.
  ENDLOOP.
ENDFORM.                    " F_SELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  F_DESELECT_ALL
*&---------------------------------------------------------------------*
FORM F_DESELECT_ALL .
  LOOP AT ITLOGTIMBANG.
    ITLOGTIMBANG-MARK = ''.
    MODIFY ITLOGTIMBANG.
  ENDLOOP.
ENDFORM.                    " F_DESELECT_ALL


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_MATERIAL
*&---------------------------------------------------------------------*

FORM F_CHECK_MATERIAL  CHANGING P_L_ERRNO.
  CLEAR : P_L_ERRNO, V_MATKL.

  IF S_MATNR = ''.
    MESSAGE 'Isi Material' TYPE 'I' DISPLAY LIKE 'W'.
    P_L_ERRNO = -1.
  ELSE.

    "CEK MATERIAL GROUP
    SELECT SINGLE MARA~MATNR
    INTO V_MATNR
    FROM MARA
    WHERE MARA~MATNR = S_MATNR
    AND MARA~MATKL IN ('B00502','B00504').

    IF SY-SUBRC <> 0.
      MESSAGE 'Material bukan merupakan FG-Sisa RcycleJual maupun FG-Waste Film Jual' TYPE 'I'.
      P_L_ERRNO = -1.
    ELSE.
      "CEK PLANT
      CLEAR V_MATNR.
      SELECT SINGLE MARD~MATNR
      INTO V_MATNR
      FROM MARD
      WHERE MARD~MATNR = S_MATNR
      AND MARD~WERKS = S_PLANT.

      IF SY-SUBRC <> 0.
        CLEAR VMSG.
        CONCATENATE 'Material tidak berada di Plant' S_PLANT INTO VMSG SEPARATED BY SPACE.
        MESSAGE VMSG TYPE 'I'.
        P_L_ERRNO = -1.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_MATERIAL


*&---------------------------------------------------------------------*
*&      Form  F_DATATIMBANG
*&---------------------------------------------------------------------*

FORM F_DATATIMBANG  CHANGING P_ERRNO.
  DATA : L_MATNR,
         ITTEMPORD TYPE TABLE OF ITORDER WITH HEADER LINE,
         L_AUFNR TYPE AUFK-AUFNR,
         L_APERIOD TYPE SYDATUM,
         VLINES TYPE I.

  PERFORM F_GET_SLOCA.

  CLEAR : VLINES, L_APERIOD.
  CONCATENATE  S_PDATE+0(4) S_PDATE+4(2)  '01' INTO L_APERIOD.

  REFRESH IT_ORDERGI.
  CLEAR P_ERRNO.

  "GET DATA ORDER WITH ORDER TYPE IN ('ZP01', ... , 'ZP02')
  IF T_MBLNR[] IS NOT INITIAL.
    SELECT DISTINCT
      MSEG~AUFNR
      MSEG~MATNR
      MSEG~MBLNR
      MSEG~BWART
      MKPF~BKTXT
      MSEG~MENGE
      MSEG~LGORT AS SLOC
      MSEG~CHARG
      AUFK~AUART
      INTO CORRESPONDING FIELDS OF TABLE IT_ORDERGI
      FROM MSEG
      JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
      JOIN AUFK ON MSEG~AUFNR = AUFK~AUFNR
      WHERE MSEG~MBLNR IN T_MBLNR
      AND MSEG~BWART IN ('531','532')
*    AND BKTXT NE ''
      "AND MKPF~BUDAT BETWEEN L_APERIOD AND S_PDATE
      AND AUFK~AUART IN ('ZP01', 'ZP02','ZP03','ZP04','ZP04','ZP05','ZP06','ZP07','ZP08','ZP09','ZP10','ZP12',     "ADDED EXLAM 11.01.2019 - ADD ORDER TYPE ZP12 & ZTR7
                         'ZP13','ZP14','ZP15','ZP16','ZP17','ZP18').  " Added by William at 02.08.2022 (OPP7 CPP1)
*    AND MSEG~LGORT IN R_SLOC
*    AND MKPF~XBLNR = ''.
  ENDIF.
  "add
  LOOP AT IT_ORDERGI.
    CLEAR V_MATDOC.
    SELECT SINGLE ZTLOGTIMBANG~ZOLDMD
      INTO V_MATDOC
      FROM ZTLOGTIMBANG
      WHERE ZTLOGTIMBANG~ZOLDMD = IT_ORDERGI-MBLNR.

    IF SY-SUBRC = 0.
      DELETE IT_ORDERGI.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  SORT IT_ORDERGI BY BKTXT AUFNR.
  REFRESH ITTEMPORD.
  ITTEMPORD[] = IT_ORDERGI[].
  DELETE ADJACENT DUPLICATES FROM ITTEMPORD COMPARING BKTXT .

  "CEK CANCEL OR POSTING GI
  LOOP AT ITTEMPORD.
    CLEAR : L_POSTING,L_CANCEL.

    LOOP AT IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT.

      CLEAR : IS_TIMBANG, V_MATDOC.

      IF IT_ORDERGI-BWART = '531'.
        L_POSTING = L_POSTING + 1.
      ELSE.
        L_CANCEL = L_CANCEL + 1.
      ENDIF.
      MODIFY IT_ORDERGI.
    ENDLOOP.

    IF L_POSTING = L_CANCEL.
      DELETE IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT.
      DELETE ITTEMPORD.
      CONTINUE.
    ELSE.
      CLEAR L_MBLNR.
      SELECT MAX( MSEG~MBLNR )
        INTO L_MBLNR
        FROM MSEG
        JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR
        WHERE MSEG~MATNR = ITTEMPORD-MATNR
        AND MSEG~AUFNR = ITTEMPORD-AUFNR
        AND MSEG~BWART = '531'
        AND MKPF~BKTXT = ITTEMPORD-BKTXT
        AND MSEG~LGORT = ITTEMPORD-SLOC
        AND MKPF~XBLNR = ''.

      DELETE IT_ORDERGI WHERE BKTXT = ITTEMPORD-BKTXT AND MBLNR NE L_MBLNR.
    ENDIF.
  ENDLOOP.

*  SORT ORDER
  SORT IT_ORDERGI BY AUART.
  DESCRIBE TABLE IT_ORDERGI LINES VLINES.

  IF VLINES > 3.
    DELETE  IT_ORDERGI FROM 4 TO VLINES.
  ENDIF.

  CLEAR L_TOTAL.
  LOOP AT IT_ORDERGI.
    L_TOTAL = L_TOTAL + IT_ORDERGI-MENGE.
  ENDLOOP.

  CLEAR : LINE_B, LSUM.
  DESCRIBE TABLE IT_ORDERGI LINES LINE_B.
  LOOP AT IT_TIMBANG.

    CLEAR WAORDER.
    READ TABLE IT_ORDERGI INTO WAORDER INDEX 1.
    LOOP AT IT_ORDERGI.

      IF SY-TABIX NE LINE_B.
        IT_ORDERGI-ZPROPORSI = ( IT_ORDERGI-MENGE / L_TOTAL ) * IT_TIMBANG-MENGE.
        LSUM = LSUM + IT_ORDERGI-ZPROPORSI.
      ELSE.
        IT_ORDERGI-ZPROPORSI = IT_TIMBANG-MENGE - LSUM.
      ENDIF.

      IT_ORDERGI-ZNETQY = IT_TIMBANG-MENGE.
      IT_ORDERGI-BMATNR = S_MATNR.

      IF IT_ORDERGI-ETYPE = 'E'.
        IT_ORDERGI-ZSTAT = GCF_E1.
      ELSE.
        IT_ORDERGI-ZSTAT = GCF_S1.

      ENDIF.
      IT_ORDERGI-SLOC = S_SLOCA.
      MODIFY IT_ORDERGI.
    ENDLOOP.


    CLEAR IS_NEXT.
    PERFORM F_CHECK_STOCK.

    PERFORM F_GET_RAW_RECYCLE.

    WHILE IS_NEXT = ''.
      PERFORM F_CHECK_STOCK.

      PERFORM F_GET_RAW_RECYCLE.
    ENDWHILE.

  ENDLOOP.


  IF IT_ORDERGI[] IS INITIAL.
    P_ERRNO = -1.
  ENDIF.
ENDFORM.                    " F_DATATIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_CANCEL_TIMBANG
*&---------------------------------------------------------------------*

FORM F_CANCEL_TIMBANG .

  DATA : V_MJAHR TYPE MKPF-MJAHR.

  REFRESH ITTLOGTIMBANG.

  ITTLOGTIMBANG[] = ITLOGTIMBANG[].
  DELETE ITTLOGTIMBANG WHERE MARK <> 'X'.

  IF ITTLOGTIMBANG[] IS INITIAL.
    MESSAGE 'Pilih Material Dokumen yang Akan di-Cancel.' TYPE 'I'.
  ELSE.

    SORT ITTLOGTIMBANG BY ZNEWMD.
    DELETE ADJACENT DUPLICATES FROM ITTLOGTIMBANG COMPARING  ZNEWMD.

    LOOP AT ITTLOGTIMBANG.

      CLEAR : V_MATNR, V_MENGE.
      SELECT SINGLE MSEG~MATNR
        MSEG~MENGE
        INTO (V_MATNR, V_MENGE)
        FROM MSEG
        WHERE MSEG~BWART = '531'
        AND MSEG~MBLNR = ITTLOGTIMBANG-ZNEWMD.

      CLEAR V_LABST.
      SELECT SINGLE MARD~LABST
        INTO V_LABST
        FROM MARD
        WHERE MARD~MATNR = V_MATNR
        AND MARD~LGORT = ITTLOGTIMBANG-ZLGORT.

      IF V_LABST = 0 OR V_LABST < V_MENGE.
        CLEAR VMSG.
        CONCATENATE 'Quantity Stock untuk Material Dokumen' ITTLOGTIMBANG-ZNEWMD 'tidak cukup.' INTO VMSG SEPARATED BY SPACE.
        MESSAGE VMSG TYPE 'I' DISPLAY LIKE 'W'.
      ELSE.

        CLEAR V_MJAHR.
        SELECT SINGLE MKPF~MJAHR
          INTO V_MJAHR
          FROM MKPF
          WHERE MKPF~MBLNR = ITTLOGTIMBANG-ZNEWMD.

        REFRESH : THEADER, IT_RET.
        CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
          EXPORTING
            MATERIALDOCUMENT    = ITTLOGTIMBANG-ZNEWMD
            MATDOCUMENTYEAR     = V_MJAHR
            GOODSMVT_PSTNG_DATE = SY-DATUM
          IMPORTING
            GOODSMVT_HEADRET    = THEADER
          TABLES
            RETURN              = IT_RET.

        READ TABLE IT_RET WITH KEY TYPE = 'E'.

        IF SY-SUBRC = 0.
          CLEAR VMSG.
          CONCATENATE 'Material Dokumen' ITTLOGTIMBANG-ZNEWMD 'Gagal di-Cancel.' INTO VMSG SEPARATED BY SPACE.
          MESSAGE VMSG TYPE 'I' DISPLAY LIKE 'W'.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.


          REFRESH IT_LOG_TIMBANG.
          SELECT  * FROM ZTLOGTIMBANG
            INTO CORRESPONDING FIELDS OF TABLE IT_LOG_TIMBANG
            WHERE ZTLOGTIMBANG~ZIDLOG = ITTLOGTIMBANG-ZIDLOG
            AND ZTLOGTIMBANG~ZNEWMD = ITTLOGTIMBANG-ZNEWMD.

          IF SY-SUBRC = 0.
            CLEAR WA_LOG_TIMBANG.
            LOOP AT IT_LOG_TIMBANG INTO WA_LOG_TIMBANG.
              WA_LOG_TIMBANG-ZIND = 'C'.

              UPDATE ZTLOGTIMBANG FROM WA_LOG_TIMBANG.
              COMMIT WORK AND WAIT.
            ENDLOOP.
          ENDIF.
          CLEAR VMSG.
          CONCATENATE 'Material Dokumen' ITTLOGTIMBANG-ZNEWMD 'Berhasil di-Cancel.' INTO VMSG SEPARATED BY SPACE.
          MESSAGE VMSG TYPE 'I' .

          PERFORM F_GET_LOG_TIMBANG CHANGING L_ERRNO.
        ENDIF.
      ENDIF.
    ENDLOOP.

    REFRESH CONTROL 'TC_LTIMBANG' FROM SCREEN '1211'.

  ENDIF.

ENDFORM.                    " F_CANCEL_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_TEST_CTIMBANG
*&---------------------------------------------------------------------*
FORM F_TEST_CTIMBANG .

  REFRESH ITTLOGTIMBANG.

  ITTLOGTIMBANG[] = ITLOGTIMBANG[].
  DELETE ITTLOGTIMBANG WHERE MARK <> 'X'.

  IF ITTLOGTIMBANG[] IS INITIAL.
    MESSAGE 'Pilih Material Dokumen yang Akan di-Cancel.' TYPE 'I'.
  ELSE.

    SORT ITTLOGTIMBANG BY ZNEWMD.
    DELETE ADJACENT DUPLICATES FROM ITTLOGTIMBANG COMPARING  ZNEWMD.

    LOOP AT ITTLOGTIMBANG.

      CLEAR : V_MATNR, V_MENGE.
      SELECT SINGLE MSEG~MATNR
        MSEG~MENGE
        INTO (V_MATNR, V_MENGE)
        FROM MSEG
        WHERE MSEG~BWART = '531'
        AND MSEG~MBLNR = ITTLOGTIMBANG-ZNEWMD.

      CLEAR V_LABST.
      SELECT SINGLE MARD~LABST
        INTO V_LABST
        FROM MARD
        WHERE MARD~MATNR = V_MATNR
        AND MARD~LGORT = ITTLOGTIMBANG-ZLGORT.

      IF V_LABST = 0 OR V_LABST < V_MENGE.
        ITTLOGTIMBANG-ETYPE    = 'E'.
        ITTLOGTIMBANG-EMSG     = 'Quantity Stock tidak cukup.'.
      ENDIF.

      IF ITTLOGTIMBANG-ETYPE  = 'E'.
        ITTLOGTIMBANG-ASTAT = GCF_E1.
      ELSE.
        ITTLOGTIMBANG-ASTAT = GCF_S1.
      ENDIF.

      MODIFY ITTLOGTIMBANG.
    ENDLOOP.

    REFRESH CONTROL 'TC_LTIMBANG' FROM SCREEN '1211'.

    PERFORM F_FIELD_CATALOGL.
    PERFORM F_LAYOUT_TIMBANG.
    PERFORM F_LIST_DETAILLTIMBANG.
  ENDIF.
ENDFORM.                    " F_TEST_CTIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOGL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOGL .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITTLOGTIMBANG' :
         'ASTAT'       '' ''  ''  ''  'Status'            ''   ''  ''  '',
         'ZIDLOG'      ''  ''  ''  ''  'No. Dokumen Timbang'     ''   ''  ''  '',
         'ZITEMLOG'      ''  ''  ''  ''  'Item Dokumen Timbang' ''   ''  ''  '',
         'ZOLDMD'     ''  ''  ''  ''  'Material Dokumen'          ''   ''  ''  '',
         'ZNEWMD'      ''  ''  ''  ''  'Material Dokumen Timbang'      ''   ''  ''  '',
         'ZAUFNR'      ''  ''  ''  ''  'Order'          ''   ''  ''  '',
         'ZMATNR'       ''  ''  ''  ''  'Material'              ''   ''  ''  '',
         'ZLGORT'      ''  ''  ''  ''  'SLoc'          ''   ''  ''  '',
         'ZWERKS'     ''  ''  ''  ''  'Plant'          ''   ''  ''  '',
         'ZBAGIAN'  ''  ''  ''  ''  'Bagian'       ''   ''  ''  '',
         'ZUSNAM'  ''  ''  ''  ''  'User Name'       ''   ''  ''  '',
         'ZIND'  ''  ''  ''  ''  'Cancel Indicator'       ''   ''  ''  '',
         'ETYPE'      ''  ''  ''  ''  'Msg. Type'         ''   ''  ''  '',
         'EID'        ''  ''  ''  ''  'Msg. ID'           ''   ''  ''  '',
         'ENUMBER'    ''  ''  ''  ''  'Msg. No.'          ''   ''  ''  '',
         'EMSG'       ''  ''  ''  ''  'Msg. Text'         ''   ''  ''  ''.
ENDFORM.                    " F_FIELD_CATALOGL


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAILLTIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAILLTIMBANG .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_LIKP BY VBELN POSNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = ''
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = T_FIELDCAT[]
      IT_EVENTS               = T_EVENTS[]
      IT_EVENT_EXIT           = T_EVENT_EXIT[]
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IS_VARIANT              = WA_VARIANTE
      IS_PRINT                = T_PRINT
      IT_SORT                 = T_SORT[]
      IT_EXCLUDING            = T_EXCLUDING[]
      I_BYPASSING_BUFFER      = 'X'
    TABLES
      T_OUTTAB                = ITTLOGTIMBANG
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAILLTIMBANG


*&---------------------------------------------------------------------*
*&      Form  UPLOAD_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOAD_RUN .
  CLEAR   : V_DATE, V_DELIVERY , CDELIVERY.
  CLEAR   : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET.
  REFRESH : IT_MSEG, IT_DATES, IT_DLV_ITEMS, IT_RET, IT_BWART.
  CONCATENATE SY-DATUM SY-UZEIT INTO V_DATE.

  WA_DATES-TIMETYPE      = 'WSHDRWADAT'.
  WA_DATES-TIMESTAMP_UTC = V_DATE.
  WA_DATES-TIMEZONE      = 'UTC+7'.
  APPEND WA_DATES TO IT_DATES.

  SELECT MSEG~BWART
    INTO CORRESPONDING FIELDS OF TABLE IT_BWART
    FROM MSEG
    WHERE MSEG~MBLNR IN S_MBLNR_.

**  LOOP AT IT_BWART.
**    IF IT_BWART-BWART NE '531'.
**      MESSAGE 'Material Document contains another movement type' TYPE 'W'.
**      EXIT.
**    ENDIF.
**  ENDLOOP.

  IF S_MBLNR_[] IS INITIAL.
    MESSAGE 'Fill material document number' TYPE 'W'.
    LEAVE TO SCREEN 1700.
  ENDIF.

  SELECT
   MSEG~MBLNR
   MSEG~ZEILE
   MSEG~MATNR
   MSEG~MENGE
   MSEG~MEINS
   INTO CORRESPONDING FIELDS OF TABLE IT_MSEG
   FROM MSEG
   WHERE MSEG~MBLNR IN S_MBLNR_
     AND MSEG~MJAHR = ZMJAHR_
     AND MSEG~BWART IN ('531', '561').

  IF IT_MSEG[] IS INITIAL.
    MESSAGE 'No data selected. Data not contain mvmt type 531.' TYPE 'I'.
    LEAVE TO SCREEN 1700.
  ENDIF.

  CLEAR : V_POSNR.
  LOOP AT IT_MSEG.
    CLEAR : V_MBLNR, ZMATNR.

    SELECT SINGLE MVKE~MATNR
    INTO ZMATNR
    FROM MVKE
    WHERE MVKE~MATNR = IT_MSEG-MATNR.

    IF SY-SUBRC <> 0.
      CONCATENATE 'Sales data for material' IT_MSEG-MATNR 'not maintain yet.' INTO ZTEXT SEPARATED BY SPACE.
      MESSAGE ZTEXT TYPE 'E'.
      EXIT.
    ENDIF.

    SELECT SINGLE ZTLOG_SALE~MBLNR
      INTO V_MBLNR
      FROM ZTLOG_SALE
      WHERE ZTLOG_SALE~MBLNR = IT_MSEG-MBLNR
        AND ZTLOG_SALE~NOREF NE ''.

    IF SY-SUBRC = 0.
      MESSAGE 'Mat.Doc have been created' TYPE 'E'.
      EXIT.
    ENDIF.

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
    WA_DLV_ITEMS-PLANT      = ZWERKS_.
    WA_DLV_ITEMS-STGE_LOC   = ZLGORT_.

    APPEND WA_DLV_ITEMS TO IT_DLV_ITEMS.
  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATENOREF'
    EXPORTING
      SHIP_POINT           = ZVSTEL_
      DLV_TYPE             = 'ZSCF'
      SALESORG             = ZVKORG_
      DISTR_CHAN           = ZVTWEG_
      DIVISION             = ZSPART_
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

  ENDIF.

ENDFORM.                    " UPLOAD_RUN


*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_RUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_DATA_RUN .
  DATA : V_MAX TYPE N LENGTH 10.
  DATA : V_SEQ LIKE ZTLOG_SALE-SEQ.
  DATA : V_MBLNR LIKE ZTLOG_SALE-MBLNR.
  CLEAR : V_MAX.
  SELECT
    MSEG~MBLNR
    INTO CORRESPONDING FIELDS OF TABLE IT_ERROR
    FROM MSEG
    WHERE MSEG~MBLNR IN S_MBLNR_
      AND MSEG~MJAHR = ZMJAHR_.

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
    WA_ERROR-LGORT = ZLGORT_.
    LOOP AT IT_RET.
      IF WA_ERROR-SEQ = 0.
        WA_ERROR-SEQ = V_MAX.
      ENDIF.
      WA_ERROR-NOREF = V_DELIVERY.
      WA_ERROR-KOSTK = V_KOSTK.
      WA_ERROR-MJAHR = ZMJAHR_.
      WA_ERROR-KUNNR = KNA1-KUNNR.
      WA_ERROR-ROUTE = LIKP-ROUTE.
      WA_ERROR-BUDAT = LIKP-ERDAT.
      WA_ERROR-WERKS = ZWERKS_.
      WA_ERROR-VSTEL = ZVSTEL_.
      WA_ERROR-ZPENGEMUDI = ZPENGEMUDI_.
      WA_ERROR-ZKENDARAAN = ZKENDARAAN_.
      WA_ERROR-ZSKP       = ZSKP_.
      WA_ERROR-ERDAT = SY-DATUM.
      WA_ERROR-ERZET = SY-UZEIT.
      WA_ERROR-ERNAM = SY-UNAME.
      WA_ERROR-MSGTYP  = IT_RET-TYPE.
      WA_ERROR-MSGID   = IT_RET-ID.
      WA_ERROR-MSGNR   = IT_RET-NUMBER.
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

ENDFORM.                    " SAVE_DATA_RUN


*&---------------------------------------------------------------------*
*&      Form  F_GET_SLOCA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_SLOCA .

  REFRESH IT_SLOC.
  SELECT ZTMAP_SLOCRR~ZWPLGORT AS SLOC
    INTO CORRESPONDING FIELDS OF TABLE IT_SLOC
    FROM ZTMAP_SLOCRR
    WHERE ZTMAP_SLOCRR~ZRRLGORT =    S_SLOCA.

  REFRESH  R_SLOC.
  LOOP AT IT_SLOC.
    W_RSLOC-SIGN   = 'I'.
    W_RSLOC-OPTION = 'EQ'.
    W_RSLOC-LOW    = IT_SLOC-SLOC.
    APPEND W_RSLOC TO R_SLOC.
  ENDLOOP.

ENDFORM.                    " F_GET_SLOCA

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_TB USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.
  SET PF-STATUS 'PFTIMBANG' EXCLUDING ITAB_EXCLUDE.
ENDFORM.                    " F_GUI_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_TB USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN 'PRINT'.
      PERFORM F_PRINT_DATA_TIMBANG.
    WHEN 'C_PRINT'.
      PERFORM F_PRINT.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_LT USING FU_UCOMM LIKE SY-UCOMM
                 	         FU_SELFIELD TYPE SLIS_SELFIELD.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  CASE FU_UCOMM.
    WHEN 'C_PRINT'.
      PERFORM F_PRINT.
    WHEN 'SALL'.
      PERFORM F_SALL_LT.
    WHEN 'DSAL'.
      PERFORM F_DSAL_LT.

  ENDCASE.
  FU_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA_TIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PRINT_DATA_TIMBANG .
  DATA: VCOMPANY(50).
  LOOP AT IT_ORDERF INTO WA_ORDERF.
    EXIT.
  ENDLOOP.

  IF S_PLANT EQ '1000' OR S_PLANT EQ '2000'.
    VCOMPANY = 'PT. TRIAS SENTOSA'.
  ELSEIF S_PLANT EQ 'TTA2'.
    VCOMPANY = 'PT. TRIAS TOYOBO ASTRIA'.
  ENDIF.

  CLEAR FM_NAME.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME = 'ZPPF_TIMBANG_SCRAP'
    IMPORTING
      FM_NAME  = FM_NAME.

  CALL FUNCTION FM_NAME
    EXPORTING
      VMATDOC    = MATDOC
      VBUDAT     = V_BUDAT
      VCPUTM     = V_CPUTM
      VNIKP      = S_NIKPR "GANTI
      VNIKPR     = S_NIKP
      VCOMPANY   = VCOMPANY
      IF_TIMBANG = WA_ORDERF
    TABLES
      IT_TIMBANG = IT_ORDERF.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " F_PRINT_DATA_TIMBANG


*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PRINT .
  DATA : VBKTXT TYPE MKPF-BKTXT.
  "ITTICKED
  "ITLOGTIMBANG
  READ TABLE ITLOGTIMBANG WITH  KEY MARK = 'X'.
  IF SY-SUBRC <> 0.
    MESSAGE 'Pilih data yang akan diprint' TYPE 'I' DISPLAY LIKE 'W'.

  ELSE.
    REFRESH ITTICKED.
    ITTICKED[] = ITLOGTIMBANG[].
    DELETE ITTICKED WHERE MARK NE 'X'.

    SORT ITTICKED BY ZNEWMD.
    DELETE ADJACENT DUPLICATES FROM ITTICKED COMPARING ZNEWMD.

    LOOP AT ITTICKED.
      CLEAR : WA_ORDERF.
      REFRESH IT_ORDERF.
*      WA_ORDERF-MATNR = IT_TIMBANG-MATNR.

      SELECT SINGLE ZTLOGTIMBANG~ZMATNR
        INTO WA_ORDERF-MATNR
        FROM ZTLOGTIMBANG
        WHERE ZTLOGTIMBANG~ZNEWMD = ITTICKED-ZNEWMD
        AND ZTLOGTIMBANG~ZBWART = '531'.


      SELECT SINGLE  MARA~MEINS MAKT~MAKTX
        INTO (WA_ORDERF-UOM, WA_ORDERF-MAKTX)
        FROM MARA
        JOIN MAKT ON MARA~MATNR = MAKT~MATNR
        WHERE MAKT~MATNR = WA_ORDERF-MATNR.

      CLEAR : MATDOC, V_BUDAT, V_CPUTM, S_NIKP, S_NIKPR.

      MATDOC = ITTICKED-ZNEWMD.
      V_BUDAT = ITTICKED-ZBUDAT.
      V_CPUTM = ITTICKED-ZCPUTM.

      CLEAR VBKTXT.
      SELECT SINGLE MKPF~BKTXT
        INTO VBKTXT
        FROM MKPF
        WHERE MKPF~MBLNR = ITTICKED-ZNEWMD.

      SPLIT VBKTXT AT '/' INTO S_NIKP S_NIKPR.

      SELECT SUM( ZTLOGTIMBANG~ZQTY )
        INTO WA_ORDERF-QTY
        FROM ZTLOGTIMBANG
        WHERE ZTLOGTIMBANG~ZNEWMD = ITTICKED-ZNEWMD
         AND ZTLOGTIMBANG~ZBWART = '531'.
*      WA_ORDERF-QTY   = IT_TIMBANG-MENGE.
      APPEND WA_ORDERF TO IT_ORDERF.
      PERFORM F_PRINT_DATA_TIMBANG.

*      LOOP AT IT_ORDERF INTO WA_ORDERF.
*        EXIT.
*      ENDLOOP.
*
*      CLEAR FM_NAME.
*      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*        EXPORTING
*          FORMNAME = 'ZPPF_TIMBANG_SCRAP'
*        IMPORTING
*          FM_NAME  = FM_NAME.
*
*      CALL FUNCTION FM_NAME
*        EXPORTING
*          VMATDOC    = MATDOC
*          VBUDAT     = V_BUDAT
*          VCPUTM     = V_CPUTM
*          VNIKP      = S_NIKP
*          VNIKPR     = S_NIKPR
*          IF_TIMBANG = WA_ORDERF
*        TABLES
*          IT_TIMBANG = IT_ORDERF.
*      IF SY-SUBRC <> 0.
** Implement suitable error handling here
*      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_PRINT


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NIK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_NIK CHANGING P_L_ERRNO.
  DATA : VPERNR TYPE PA0001-PERNR.
  CLEAR : VPERNR, P_L_ERRNO.

  "cek nik pengirim.
  SELECT SINGLE PA0001~PERNR
    FROM PA0001
    INTO VPERNR
    WHERE PA0001~PERNR = S_NIKP.

  IF SY-SUBRC <> 0.
    P_L_ERRNO = -1.
    CLEAR MESSAGE.
    MESSAGE =  'NIK Pengirim Salah.' .

    CLEAR : VPERNR.
    "cek nik penerima.
    SELECT SINGLE PA0001~PERNR
      FROM PA0001
      INTO VPERNR
      WHERE PA0001~PERNR = S_NIKPR.

    IF SY-SUBRC <> 0.
      CLEAR MESSAGE.
      MESSAGE = 'NIK Pengirim dan NIK Penerima Salah.' .
    ENDIF.

  ELSE.
    CLEAR : VPERNR.
    "cek nik penerima.
    SELECT SINGLE PA0001~PERNR
      FROM PA0001
      INTO VPERNR
      WHERE PA0001~PERNR = S_NIKPR.

    IF SY-SUBRC <> 0.
      P_L_ERRNO = -1.
      CLEAR MESSAGE.
      MESSAGE = 'NIK Penerima Salah.' .
    ENDIF.

  ENDIF.


ENDFORM.                    " F_CHECK_NIK


*&---------------------------------------------------------------------*
*&      Form  F_SALL_LT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SALL_LT .
  LOOP AT ITLOGTIMBANG.
    ITLOGTIMBANG-MARK = 'X'.
    MODIFY ITLOGTIMBANG TRANSPORTING MARK.
  ENDLOOP.
ENDFORM.                    " F_SALL_LT

*&---------------------------------------------------------------------*
*&      Form  F_DSAL_LT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DSAL_LT .
  LOOP AT ITLOGTIMBANG.
    ITLOGTIMBANG-MARK = ''.
    MODIFY ITLOGTIMBANG TRANSPORTING MARK.
  ENDLOOP.
ENDFORM.                    " F_DSAL_LT


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_STOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_STOCK .

  REFRESH IT_ORDTEMP.
  IT_ORDTEMP[] = IT_ORDERGI[].
  SORT IT_ORDTEMP BY MATNR.
  DELETE ADJACENT DUPLICATES FROM IT_ORDTEMP COMPARING MATNR.

  LOOP AT IT_ORDTEMP.

    CLEAR L_TOTAL.
    LOOP AT IT_ORDERGI WHERE MATNR = IT_ORDTEMP-MATNR.
      L_TOTAL = L_TOTAL + IT_ORDERGI-ZPROPORSI.
    ENDLOOP.

    SELECT SINGLE MARD~LABST
      INTO IT_ORDTEMP-STOCK
      FROM MARD
      WHERE MARD~MATNR = IT_ORDTEMP-MATNR
      AND MARD~LGORT = S_SLOCA
      AND  MARD~WERKS = S_PLANT.

    IF IT_ORDTEMP-STOCK <  L_TOTAL.

*        IF IS_TEST_RUN = 'X'.
*          LOOP AT IT_ORDERGI WHERE MATNR = IT_ORDTEMP-MATNR.
*            IT_ORDERGI-ETYPE    = 'E'.
*            IT_ORDERGI-EID      = ''.
*            IT_ORDERGI-ENUMBER  = ''.
*            IT_ORDERGI-EMSG     = 'Quantity Stock lebih kecil dari quantity yang akan ditimbang'.
*            IT_ORDERGI-ZSTAT = GCF_E1.
*            MODIFY IT_ORDERGI.
*          ENDLOOP.
*        ELSE.
      DELETE IT_ORDERGI WHERE MATNR = IT_ORDTEMP-MATNR.
*        ENDIF.


    ENDIF.

  ENDLOOP.
ENDFORM.                    " F_CHECK_STOCK


*&---------------------------------------------------------------------*
*&      Form  F_GET_RAW_RECYCLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_RAW_RECYCLE .

  " CEK IF QTY ALOKASI = 0
  CLEAR :  LINE_A.
  DELETE IT_ORDERGI WHERE ZPROPORSI = 0.
  DESCRIBE TABLE IT_ORDERGI LINES LINE_A.

*  WHILE IS_NEXT = ''.
  IF LINE_A <> 0 AND LINE_A <> LINE_B.

    CLEAR L_TOTAL.
    LOOP AT IT_ORDERGI.
      L_TOTAL = L_TOTAL + IT_ORDERGI-MENGE.
    ENDLOOP.

    CLEAR : LSUM.
    LOOP AT IT_ORDERGI.

      IT_ORDERGI-ZPROPORSI = ( IT_ORDERGI-MENGE / L_TOTAL ) * IT_TIMBANG-MENGE.

      IF SY-TABIX = LINE_A.
*            WAORDER-ZPROPORSI = IT_TIMBANG-MENGE - LSUM. "09JAN2013
        IT_ORDERGI-ZPROPORSI = IT_TIMBANG-MENGE - LSUM.
      ELSE.
        LSUM = LSUM + IT_ORDERGI-ZPROPORSI.
      ENDIF.

      IT_ORDERGI-ZNETQY = IT_TIMBANG-MENGE.
      IT_ORDERGI-BMATNR = S_MATNR.
      IT_ORDERGI-SLOC = S_SLOCA.
      MODIFY IT_ORDERGI.
    ENDLOOP.

    CLEAR LINE_B.
    DESCRIBE TABLE IT_ORDERGI LINES LINE_B.

  ELSE.
    IS_NEXT = 'X'.
  ENDIF.
*  ENDWHILE.


ENDFORM.                    " F_GET_RAW_RECYCLE


*&---------------------------------------------------------------------*
*&      Form  get_hdr_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_HDR_TEXT.
  LOOP AT IT_FORM.

*-  get Header Text
    V_VBELN = IT_FORM-VBELN.

    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nama Pengemudi
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z114'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_FORM-ZPENGEMUDI = IT_LINE-TDLINE.
    ELSE.
      IT_FORM-ZPENGEMUDI = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Kendaraan
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z115'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_FORM-ZKENDARAAN = IT_LINE-TDLINE.
    ELSE.
      IT_FORM-ZKENDARAAN = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nomor SKP
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z111'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    READ TABLE IT_LINE INDEX 1.
    IF SY-SUBRC = 0.
      IT_FORM-ZSKP = IT_LINE-TDLINE.
    ELSE.
      IT_FORM-ZSKP = ''.
    ENDIF.


    CLEAR : IT_LINE.
    REFRESH IT_LINE.
    "- Nomor SKP
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*         CLIENT                        = SY-MANDT
        ID                            = 'Z010'
        LANGUAGE                      = SY-LANGU
        NAME                          = V_VBELN
        OBJECT                        = 'VBBK'
*         ARCHIVE_HANDLE                = 0
*         LOCAL_CAT                     = ' '
*       IMPORTING
*         HEADER                        =
*         OLD_LINE_COUNTER              =
      TABLES
        LINES                         = IT_LINE
     EXCEPTIONS
       ID                            = 1
       LANGUAGE                      = 2
       NAME                          = 3
       NOT_FOUND                     = 4
       OBJECT                        = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
       OTHERS                        = 8
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    CLEAR V_REMARKS.
    LOOP AT IT_LINE.
      CONCATENATE V_REMARKS IT_LINE-TDLINE INTO V_REMARKS SEPARATED BY SPACE.
    ENDLOOP.

*    READ TABLE IT_LINE INDEX 1.
*    IF SY-SUBRC = 0.
**      IT_FORM-ZREMARKS = IT_LINE-TDLINE.
*      V_REMARKS = IT_LINE-TDLINE.
*    ELSE.
**      IT_FORM-ZREMARKS = ''.
*      V_REMARKS = ''.
*    ENDIF.

    MODIFY IT_FORM TRANSPORTING ZPENGEMUDI ZKENDARAAN ZSKP WHERE VBELN = IT_FORM-VBELN.
    EXIT.
  ENDLOOP.
ENDFORM.                    "get_hdr_text