*&---------------------------------------------------------------------*
*&  Include           ZHUR_ROLL_LIST_BY_DEL_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  CLEAR   : IT_HU, IT_HUM.
  REFRESH : IT_HU, IT_HUM.

  "Add by pst_hisar 14-12-12
  CLEAR : TBWART,TLFART.
  REFRESH : TBWART,TLFART.
  IF P_DELCUS EQ 'X'.
    CLEAR TBWART.
    TBWART-SIGN = 'I'.
    TBWART-OPTION = 'EQ'.
    TBWART-LOW = '903'.
    APPEND TBWART.

    CLEAR TBWART.
    TBWART-SIGN = 'I'.
    TBWART-OPTION = 'EQ'.
    TBWART-LOW = '601'.
    APPEND TBWART.

    CLEAR TBWART.
    TBWART-SIGN = 'I'.
    TBWART-OPTION = 'EQ'.
    TBWART-LOW = '631'.
    APPEND TBWART.

    CLEAR TBWART.
    TBWART-SIGN = 'I'.
    TBWART-OPTION = 'EQ'.
    TBWART-LOW = '633'.
    APPEND TBWART.

    CLEAR TLFART.
    TLFART-SIGN = 'I'.
    TLFART-OPTION = 'EQ'.
    TLFART-LOW = 'ZELF'.
    APPEND TLFART.

    CLEAR TLFART.
    TLFART-SIGN = 'I'.
    TLFART-OPTION = 'EQ'.
    TLFART-LOW = 'ZDLF'.
    APPEND TLFART.

  ENDIF.
  "end add by pst_hisar

**  SELECT
**    HUMSEG~VENUM  AS VENUM
**    MKPF~LE_VBELN AS VBELN
**    VEKP~EXIDV
**    VEKP~MAGRV
**    VEKP~UEVEL
**    LIPS~POSNR
**    LIPS~UECHA
**    LIPS~LFIMG
**    INTO CORRESPONDING FIELDS OF TABLE IT_HUM
**    FROM HUMSEG
**    INNER JOIN MKPF ON HUMSEG~MBLNR = MKPF~MBLNR
**    INNER JOIN VEKP ON VEKP~VENUM   = HUMSEG~VENUM
**    INNER JOIN LIKP ON MKPF~LE_VBELN = LIKP~VBELN
**    INNER JOIN LIPS ON LIKP~VBELN = LIPS~VBELN
**    WHERE LIKP~VBELN IN S_VBELN
**      AND LIKP~WADAT_IST IN S_WADATI
**      AND LIKP~WADAT IN S_WADAT
**      AND LIPS~MTART IN S_MTART
**      AND LIKP~LFART IN S_LFART
**      AND VEKP~EXIDV IN S_EXIDV.
***
***SORT IT_HUM ASCENDING BY VBELN POSNR.
***DELETE ADJACENT DUPLICATES FROM IT_HUM COMPARING VBELN POSNR.
***DELETE IT_HUM WHERE LFIMG = 0.


  "- from HUMSEG
  SELECT
    HUMSEG~VENUM  AS VENUM
    HUMSEG~MBLNR
    MSEG~VBELN_IM AS VBELN
    MSEG~VBELP_IM AS POSNR
    LIPS~UECHA
    LIPS~QPLOS

**    MKPF~LE_VBELN AS VBELN
**    VEPO~VBELN
**    VEPO~POSNR
**    LIPS~POSNR
**    LIPS~UECHA
**    LIPS~LFIMG

    INTO CORRESPONDING FIELDS OF TABLE IT_HUM
    FROM HUMSEG
    INNER JOIN MSEG ON HUMSEG~MBLNR = MSEG~MBLNR AND HUMSEG~MBLPO = MSEG~ZEILE
    INNER JOIN LIKP ON MSEG~VBELN_IM = LIKP~VBELN
    INNER JOIN LIPS ON MSEG~VBELN_IM = LIPS~VBELN AND MSEG~VBELP_IM = LIPS~POSNR
    WHERE MSEG~VBELN_IM IN S_VBELN
      AND LIKP~WADAT_IST IN S_WADATI
      AND LIKP~WADAT IN S_WADAT
      AND LIPS~MTART IN S_MTART
      AND LIKP~LFART IN S_LFART
      AND LIPS~BWART IN TBWART "Add by pst_hisar 17-12-12
      AND LIKP~LFART IN TLFART. "Add by pst_hisar 17-12-12


  SORT IT_HUM ASCENDING BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM IT_HUM COMPARING VBELN POSNR.

  "- from LIKP
  SELECT
    LIKP~VBELN
    LIPS~POSNR
    LIPS~UECHA
    LIPS~LFIMG
    LIPS~QPLOS
*    LIPS~BWART  "Add by pst_hisar 17-12-12

  INTO CORRESPONDING FIELDS OF TABLE IT_HU
*  FROM LIKP
  FROM LIPS
*  INNER JOIN LIPS ON LIKP~VBELN = LIPS~VBELN
  JOIN LIKP ON LIKP~VBELN = LIPS~VBELN
  INNER JOIN VBUK ON LIKP~VBELN = VBUK~VBELN
    WHERE LIKP~VBELN IN S_VBELN
      AND LIKP~WADAT_IST IN S_WADATI
      AND LIKP~WADAT IN S_WADAT
      AND LIPS~MTART IN S_MTART
      AND LIKP~LFART IN S_LFART
      AND LIPS~BWART IN TBWART "Add by pst_hisar 17-12-12
      AND LIKP~LFART IN TLFART. "Add by pst_hisar 17-12-12
*      AND VBUK~WBSTK NE 'C'.

  SORT IT_HU ASCENDING BY VBELN POSNR.
  DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN POSNR.
  DELETE IT_HU WHERE LFIMG = 0.

  LOOP AT IT_HUM.
    APPEND IT_HUM TO IT_HU.
  ENDLOOP.

  SORT IT_HU ASCENDING BY VBELN POSNR LFIMG.
  DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN POSNR.

*SORT IT_HU ASCENDING BY VBELN POSNR.
*DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN POSNR.

  LOOP AT IT_HU ASSIGNING <FS_HU>.
    "- ODO Item
    IF <FS_HU>-UECHA EQ ''.
      <FS_HU>-ZPOSNR = <FS_HU>-POSNR.
      <FS_HU>-POSNR  = ''.
    ELSE.
      <FS_HU>-ZPOSNR = <FS_HU>-UECHA.
    ENDIF.
*  ENDLOOP.
*Tambahan by Bandi
*  IF LINES( IT_HU ) > 0.
*    SELECT
*      LIKP~VBELN AS ZVBELN
*      LIKP~LFART AS ZLFART
*      LIKP~WADAT AS ZWADAT
*      LIKP~WADAT_IST AS ZWADAT_IST
*      LIKP~BLDAT AS ZBLDAT
*      LIKP~ERDAT AS ZERDAT
*      LIKP~KUNAG AS ZKUNAG
*      FROM LIKP
*      INTO CORRESPONDING FIELDS OF TABLE IT_LIKP
*      FOR ALL ENTRIES IN IT_HU
*      WHERE LIKP~VBELN = IT_HU-VBELN.
*  ENDIF.

*  IF LINES( IT_HU ) > 0.
*    SELECT
*      LIPS~VBELN AS ZVBELN
*      LIPS~POSNR AS ZPOSNR
*      LIPS~MATNR AS ZMATNR
*      LIPS~WERKS AS ZWERKS
*      LIPS~VRKME AS ZVRKME
*      LIPS~LGORT AS ZLGORT
*      LIPS~BWART AS ZBWART
*      FROM LIPS
*      INTO CORRESPONDING FIELDS OF TABLE IT_LIPS
*      FOR ALL ENTRIES IN IT_HU
*      WHERE LIPS~VBELN = IT_HU-VBELN AND
*            LIPS~POSNR = IT_HU-ZPOSNR.
*  ENDIF.

*  LOOP AT IT_HU ASSIGNING <FS_HU>.
    "- GI Status
    SELECT SINGLE VBUK~WBSTK
      INTO <FS_HU>-WBSTK
      FROM VBUK
      WHERE VBUK~VBELN = <FS_HU>-VBELN.

    CASE <FS_HU>-WBSTK.
      WHEN ''.
        <FS_HU>-ZWBSTK = 'Not Relevant'.
      WHEN 'A'.
        <FS_HU>-ZWBSTK = 'Not yet processed'.
      WHEN 'B'.
        <FS_HU>-ZWBSTK = 'Partially processed'.
      WHEN 'C'.
        <FS_HU>-ZWBSTK = 'Completely processed'.
    ENDCASE.

    IF <FS_HU>-POSNR NE ''.
      "- DO Qty
      SELECT SINGLE LIPS~LFIMG
        INTO <FS_HU>-LFIMG
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-POSNR.
    ELSE.
      "- DO Qty
      SELECT SINGLE LIPS~LFIMG
        INTO <FS_HU>-LFIMG
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-ZPOSNR.
    ENDIF.


    "- HU Box
    IF <FS_HU>-VENUM EQ ''.
      IF <FS_HU>-POSNR NE ''.
        SELECT SINGLE VEKP~EXIDV
        INTO <FS_HU>-ZEXIDV
        FROM VEKP
        JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
        WHERE VEPO~VBELN = <FS_HU>-VBELN
          AND VEPO~POSNR = <FS_HU>-POSNR
          AND VEKP~MAGRV = 'BOX'.

        IF <FS_HU>-ZEXIDV EQ ''.
          SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-EXIDV
          FROM VEKP
          JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
          WHERE VEPO~VBELN = <FS_HU>-VBELN
            AND VEPO~POSNR = <FS_HU>-POSNR
            AND VEKP~MAGRV = 'PLT'.
        ENDIF.


      ELSE.
        SELECT SINGLE VEKP~EXIDV
        INTO <FS_HU>-ZEXIDV
        FROM VEKP
        JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
        WHERE VEPO~VBELN = <FS_HU>-VBELN
          AND VEPO~POSNR = <FS_HU>-ZPOSNR
          AND VEKP~MAGRV = 'BOX'.

        IF <FS_HU>-ZEXIDV EQ ''.
          SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-EXIDV
          FROM VEKP
          JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
          WHERE VEPO~VBELN = <FS_HU>-VBELN
            AND VEPO~POSNR = <FS_HU>-ZPOSNR
            AND VEKP~MAGRV = 'PLT'.
        ENDIF.

      ENDIF.
      IF <FS_HU>-EXIDV EQ ''.
        "- HU Pallet
        CLEAR : V_UEVEL.
        SELECT SINGLE VEKP~UEVEL
          INTO V_UEVEL
          FROM VEKP
          WHERE VEKP~EXIDV = <FS_HU>-ZEXIDV.

        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-EXIDV
          FROM VEKP
          WHERE VEKP~VENUM = V_UEVEL.
      ENDIF.

    ELSE.
      SELECT SINGLE VEKP~MAGRV
        INTO <FS_HU>-MAGRV
        FROM VEKP
        WHERE VEKP~VENUM = <FS_HU>-VENUM.

      IF <FS_HU>-MAGRV EQ 'BOX'.
        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-ZEXIDV
          FROM VEKP
          WHERE VEKP~VENUM = <FS_HU>-VENUM.

        CLEAR : V_UEVEL.
        SELECT SINGLE VEKP~UEVEL
          INTO V_UEVEL
          FROM VEKP
          WHERE VEKP~EXIDV = <FS_HU>-ZEXIDV.

        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-EXIDV
          FROM VEKP
          WHERE VEKP~VENUM = V_UEVEL.

      ELSEIF <FS_HU>-MAGRV EQ 'PLT'.
        SELECT SINGLE VEKP~EXIDV
          INTO <FS_HU>-EXIDV
          FROM VEKP
          WHERE VEKP~VENUM = <FS_HU>-VENUM.
      ENDIF.

    ENDIF.


    "- HU Pallet
**    IF <FS_HU>-ZEXIDV NE ''.
**
**    ELSE.
**      SELECT SINGLE VEKP~EXIDV
**      INTO <FS_HU>-EXIDV
**      FROM VEKP
**      JOIN VEPO ON VEPO~VENUM = VEKP~VENUM
**      WHERE VEPO~VBELN = <FS_HU>-VBELN
**        AND VEPO~POSNR = <FS_HU>-POSNR
**        AND VEKP~MAGRV = 'PLT'.
**    ENDIF.
***
***    IF <FS_HU>-EXIDV EQ ''.
***      CLEAR : V_UEVEL.
***      SELECT SINGLE HUMSEG~VENUM
***        INTO V_UEVEL
***        FROM HUMSEG
***        INNER JOIN MKPF ON MKPF~MBLNR = HUMSEG~MBLNR
***        INNER JOIN LIPS ON LIPS~VBELN = MKPF~LE_VBELN
***        WHERE LIPS~VBELN = <FS_HU>-VBELN.
***    ENDIF.


***    SELECT SINGLE VEKP~EXIDV
***      INTO <FS_HU>-EXIDV
***      FROM VEKP
***      JOIN VEPO ON VEPO~VBELN = VEKP~VPOBJKEY
***      WHERE VEPO~VBELN = <FS_HU>-VBELN
***        AND VEPO~POSNR = <FS_HU>-POSNR
***        AND VEKP~MAGRV = 'PLT'.

    IF <FS_HU>-EXIDV NOT IN S_EXIDV.
      DELETE IT_HU.
      CONTINUE.
    ENDIF.

    "- Shippment
    SELECT SINGLE VTTP~TKNUM
      INTO <FS_HU>-TKNUM
      FROM VTTP
      WHERE VTTP~VBELN = <FS_HU>-VBELN.

    IF <FS_HU>-TKNUM NOT IN S_TKNUM.
      DELETE IT_HU.
      CONTINUE.
    ENDIF.



***    CLEAR : V_VENUM, V_UNVEL.
***    SELECT SINGLE VEKP~VENUM
***      INTO V_VENUM
***      FROM VEKP
***      WHERE VEKP~EXIDV = <FS_HU>-EXIDV.
***
***    SELECT SINGLE VEPO~UNVEL
***      INTO V_UNVEL
***      FROM VEPO
***      WHERE VEPO~VENUM = V_VENUM.
***
***    IF SY-SUBRC = 0.
***      SELECT SINGLE VEKP~EXIDV
***        INTO <FS_HU>-ZEXIDV
***        FROM VEKP
***        WHERE VEKP~VENUM = V_UNVEL.
***    ENDIF.

*    READ TABLE IT_LIPS WITH KEY ZVBELN = <FS_HU>-VBELN
*                                ZPOSNR = <FS_HU>-ZPOSNR.
*
*    READ TABLE IT_LIKP WITH KEY ZVBELN = <FS_HU>-VBELN.

    "- Material Number
*    <FS_HU>-MATNR = IT_LIPS-ZMATNR.
    SELECT SINGLE LIPS~MATNR
      INTO <FS_HU>-MATNR
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-VBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    "- Plant
*    <FS_HU>-WERKS = IT_LIPS-ZWERKS.
    SELECT SINGLE LIPS~WERKS
      INTO <FS_HU>-WERKS
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-VBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    "- Batch
    IF <FS_HU>-UECHA NE ''.
      SELECT SINGLE LIPS~CHARG
        INTO <FS_HU>-CHARG
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-POSNR.
    ELSEIF <FS_HU>-UECHA EQ ''.
      SELECT SINGLE LIPS~CHARG
        INTO <FS_HU>-CHARG
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-ZPOSNR.
    ENDIF.

    "- Qty Roll
    IF <FS_HU>-CHARG NE ''.
      <FS_HU>-ZQTY = '1'.
    ENDIF.



    "- DO Type
*    <FS_HU>-LFART = IT_LIKP-ZLFART.
    SELECT SINGLE LIKP~LFART
      INTO <FS_HU>-LFART
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- DO Qty
*    <FS_HU>-VRKME = IT_LIPS-ZVRKME.
    SELECT SINGLE LIPS~VRKME
      INTO <FS_HU>-VRKME
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-VBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    "- Delivery Date
*    <FS_HU>-WADAT = IT_LIKP-ZWADAT.
    SELECT SINGLE LIKP~WADAT
      INTO <FS_HU>-WADAT
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- Actual GI Date
*    <FS_HU>-WADAT_IST = IT_LIKP-ZWADAT_IST.
    SELECT SINGLE LIKP~WADAT_IST
      INTO <FS_HU>-WADAT_IST
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- DO Created Date
*    <FS_HU>-BLDAT = IT_LIKP-ZBLDAT.
    SELECT SINGLE LIKP~BLDAT
      INTO <FS_HU>-BLDAT
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- DO Created On
*    <FS_HU>-ERDAT = IT_LIKP-ZERDAT.
    SELECT SINGLE LIKP~ERDAT
      INTO <FS_HU>-ZERDAT
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- Storage Location
*    <FS_HU>-LGORT = IT_LIPS-ZLGORT.
    SELECT SINGLE LIPS~LGORT
      INTO <FS_HU>-LGORT
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-VBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    "- Movement Type
*    <FS_HU>-BWART = IT_LIPS-ZBWART.
    SELECT SINGLE LIPS~BWART
      INTO <FS_HU>-BWART
      FROM LIPS
      WHERE LIPS~VBELN = <FS_HU>-VBELN
        AND LIPS~POSNR = <FS_HU>-ZPOSNR.

    "- Net Weight
    IF <FS_HU>-UECHA NE ''.
      SELECT SINGLE LIPS~NTGEW
        INTO <FS_HU>-NTGEW
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-POSNR.
    ELSEIF <FS_HU>-UECHA EQ ''.
      SELECT SINGLE LIPS~NTGEW
        INTO <FS_HU>-NTGEW
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-ZPOSNR.
    ENDIF.

    "- Weight Unit
    IF <FS_HU>-UECHA NE ''.
      SELECT SINGLE LIPS~GEWEI
        INTO <FS_HU>-GEWEI
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-POSNR.
    ELSEIF <FS_HU>-UECHA EQ ''.
      SELECT SINGLE LIPS~GEWEI
        INTO <FS_HU>-GEWEI
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN
          AND LIPS~POSNR = <FS_HU>-ZPOSNR.
    ENDIF.

    "- Production Date
    SELECT SINGLE MCH1~LWEDT
      INTO <FS_HU>-LWEDT
      FROM MCH1
      WHERE MCH1~CHARG = <FS_HU>-CHARG
        AND MCH1~MATNR = <FS_HU>-MATNR.

    "- SO Number
    IF <FS_HU>-LFART EQ 'ZDLF' OR <FS_HU>-LFART EQ 'ZELF' OR <FS_HU>-LFART EQ 'ZLR'.
      SELECT SINGLE LIPS~VGBEL
        INTO <FS_HU>-VBELV
        FROM LIPS
        WHERE LIPS~VBELN = <FS_HU>-VBELN.
    ELSE.
      CLEAR : V_SONUM, V_VBELN.
      SELECT SINGLE VEPO~SONUM
        INTO V_SONUM
        FROM VEPO
        WHERE VEPO~VBELN = <FS_HU>-VBELN.

      <FS_HU>-VBELV = V_SONUM(10).

      SELECT SINGLE VBAK~VBELN
        INTO V_VBELN
        FROM VBAK
        WHERE VBAK~VBELN = <FS_HU>-VBELV.

      IF SY-SUBRC <> 0.
        <FS_HU>-VBELV = ''.
      ENDIF.

    ENDIF.

***    SELECT SINGLE VBFA~VBELV
***      INTO <FS_HU>-VBELV
***      FROM VBFA
***      WHERE VBFA~VBELN = <FS_HU>-VBELN
***        AND VBFA~POSNN = <FS_HU>-ZPOSNR
***        AND VBFA~VBTYP_N = 'J'.

    "- SO Item
    SELECT SINGLE VBFA~POSNV
      INTO <FS_HU>-POSNV
      FROM VBFA
      WHERE VBFA~VBELN = <FS_HU>-VBELN
        AND VBFA~POSNN = <FS_HU>-ZPOSNR
        AND VBFA~VBTYP_N = 'J'.

    "- SO Type
    SELECT SINGLE VBAK~AUART
      INTO <FS_HU>-AUART
      FROM VBAK
      WHERE VBAK~VBELN = <FS_HU>-VBELV.

    "- SO Type Description
    SELECT SINGLE TVAKT~BEZEI
      INTO <FS_HU>-BEZEI
      FROM TVAKT
      WHERE TVAKT~AUART = <FS_HU>-AUART
        AND TVAKT~SPRAS EQ 'E'.

    "- Sales Employee
    SELECT SINGLE PA0001~ENAME
      INTO <FS_HU>-ENAME
      FROM PA0001
      INNER JOIN VBPA ON PA0001~PERNR = VBPA~PERNR
      WHERE VBPA~PARVW EQ 'VE'
        AND VBPA~VBELN = <FS_HU>-VBELV.

    "- Sold to Party
*    <FS_HU>-KUNAG = IT_LIKP-ZKUNAG.
    SELECT SINGLE LIKP~KUNAG
      INTO <FS_HU>-KUNAG
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    "- Sold to Party Name
    SELECT SINGLE ADRC~NAME1
      INTO <FS_HU>-NAME1
      FROM ADRC
      INNER JOIN VBPA ON ADRC~ADDRNUMBER = VBPA~ADRNR
      WHERE VBPA~VBELN = <FS_HU>-VBELN
        AND VBPA~PARVW EQ 'AG'.

    "- Document Category
    CLEAR : V_VBTYP.
    SELECT SINGLE LIKP~VBTYP
      INTO V_VBTYP
      FROM LIKP
      WHERE LIKP~VBELN = <FS_HU>-VBELN.

    IF V_VBTYP EQ '7'.
      "- Vendor
      SELECT SINGLE LIKP~LIFNR
        INTO <FS_HU>-KUNNR
        FROM LIKP
        WHERE LIKP~VBELN = <FS_HU>-VBELN.

      "- Name
      SELECT SINGLE KNA1~NAME1
        INTO <FS_HU>-ZNAME1
        FROM KNA1
        WHERE KNA1~LIFNR = <FS_HU>-KUNNR.

    ELSE.
      "- Ship to Party
      SELECT SINGLE LIKP~KUNNR
        INTO <FS_HU>-KUNNR
        FROM LIKP
        WHERE LIKP~VBELN = <FS_HU>-VBELN.

      "- Ship to Party Name
      SELECT SINGLE ADRC~NAME1
        INTO <FS_HU>-ZNAME1
        FROM ADRC
        INNER JOIN VBPA ON ADRC~ADDRNUMBER = VBPA~ADRNR
        WHERE VBPA~VBELN = <FS_HU>-VBELN
          AND VBPA~PARVW EQ 'WE'.
    ENDIF.



    "- PO Number
    SELECT SINGLE VBAK~BSTNK
      INTO <FS_HU>-BSTNK
      FROM VBAK
      WHERE VBAK~VBELN = <FS_HU>-VBELV.

    IF <FS_HU>-BSTNK EQ ''.
      SELECT SINGLE VBKD~BSTKD
        INTO <FS_HU>-BSTNK
        FROM VBKD
        WHERE VBKD~VBELN = <FS_HU>-VBELV.
    ENDIF.

    CLEAR : V_VBELV.
    V_VBELV = <FS_HU>-VBELV.
    IF V_VBELV NE ''.
      "- PI Number
      CLEAR : IT_LINE.
      REFRESH : IT_LINE.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
         CLIENT                        = SY-MANDT
          ID                            = 'Z101'
          LANGUAGE                      = SY-LANGU
          NAME                          = V_VBELV
          OBJECT                        = 'VBBK'
*             ARCHIVE_HANDLE                = 0
*             LOCAL_CAT                     = ' '
*           IMPORTING
*             HEADER                        =
*             OLD_LINE_COUNTER              =
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
*       Implement suitable error handling here
      ENDIF.

      READ TABLE IT_LINE INDEX 1.
      IF SY-SUBRC = 0.
        <FS_HU>-ZPINUM = IT_LINE-TDLINE.
      ENDIF.
    ENDIF.

    "- HU Date
    SELECT SINGLE VEKP~ERDAT
      INTO <FS_HU>-ERDAT
      FROM VEKP
      WHERE VEKP~EXIDV = <FS_HU>-EXIDV.

    CALL FUNCTION 'VB_INIT'
      EXPORTING
        INIT_RESET = 'X'.


    "- Characteristic
    CLEAR : IT_DETAIL.
    REFRESH : IT_DETAIL.
*Tambahan by Bandi
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR    = <FS_HU>-MATNR
        I_VAL_WERKS    = <FS_HU>-WERKS
        I_VAL_CHARGE   = <FS_HU>-CHARG
      TABLES
        T_VAL_TAB      = IT_DETAIL
      EXCEPTIONS
        NO_CLASS       = 1
        INTERNAL_ERROR = 2
        NO_VALUES      = 3
        NO_CHARS       = 4
        OTHERS         = 5.
*    CALL FUNCTION 'VB_BATCH_GET_DETAIL'
*      EXPORTING
*        MATNR                    = <FS_HU>-MATNR
*        CHARG                    = <FS_HU>-CHARG
*        WERKS                    = <FS_HU>-WERKS
*        GET_CLASSIFICATION       = 'X'
**        EXISTENCE_CHECK          =
**        READ_FROM_BUFFER         =
**        NO_CLASS_INIT            = ' '
**        LOCK_BATCH               = ' '
**      IMPORTING
**        YMCHA                    =
**        CLASSNAME                =
*      TABLES
*         CHAR_OF_BATCH            = IT_DETAIL
*      EXCEPTIONS
*        NO_MATERIAL              = 1
*        NO_BATCH                 = 2
*        NO_PLANT                 = 3
*        MATERIAL_NOT_FOUND       = 4
*        PLANT_NOT_FOUND          = 5
*        NO_AUTHORITY             = 6
*        BATCH_NOT_EXIST          = 7
*        LOCK_ON_BATCH            = 8
*        OTHERS                   = 9
*              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    "- Type
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZTYPE = IT_DETAIL-ATWTB.
    ENDIF.

    "- Thickness
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZTHICKNESS'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZTHICK = IT_DETAIL-ATWTB.
    ENDIF.

    "- Width
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZWIDTH'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZWIDTH = IT_DETAIL-ATWTB.
    ENDIF.

    "- Length
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZLENGTH = IT_DETAIL-ATWTB.
    ENDIF.

    "- Nomor Roll
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZROLL = IT_DETAIL-ATWTB.
    ENDIF.

    "- Expire Live
    CLEAR : V_EXPR.
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
    IF SY-SUBRC = 0 AND <FS_HU>-LWEDT NE '00000000'.
      V_EXPR = IT_DETAIL-ATWTB.
      <FS_HU>-ZZEXPR = <FS_HU>-LWEDT + V_EXPR.
    ENDIF.

    "- Treatment
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZTREATMENT'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZTREAT = IT_DETAIL-ATWTB.
    ENDIF.

    "- Core
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZCORE'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZCORE = IT_DETAIL-ATWTB.
    ENDIF.

    "- Sistem Packing
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZPACKING'.
    IF SY-SUBRC = 0.
      <FS_HU>-ZZPACK = IT_DETAIL-ATWTB.
    ENDIF.

    "- Criteria
    IF P_CHECK EQ 'X'.
      READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZCRITERIA'.
      IF SY-SUBRC = 0.
        <FS_HU>-ZZCRITERIA = IT_DETAIL-ATWTB.
      ENDIF.
    ELSE.
      <FS_HU>-ZZCRITERIA = ''.
    ENDIF.

*    BEGIN ADD BY PST_HISAR 14-12-12

    "- Alias
    READ TABLE IT_DETAIL WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC EQ 0.
      <FS_HU>-ZZALIAS = IT_DETAIL-ATWTB.
    ENDIF.
    IF <FS_HU>-LFART EQ 'ZLR'.
      SELECT SINGLE PRUEFLOS INTO <FS_HU>-QPLOS
        FROM QALS
        WHERE CHARG = <FS_HU>-CHARG.
    ENDIF.
    IF <FS_HU>-QPLOS IS NOT INITIAL.
      SELECT SINGLE QAVE~VCODE INTO <FS_HU>-VCODE
        FROM QAVE
        WHERE PRUEFLOS = <FS_HU>-QPLOS.
*        JOIN LIPS ON LIPS~QPLOS = QAVE~PRUEFLOS
*        WHERE LIPS~VBELN = <FS_HU>-VBELN.
      IF <FS_HU>-VCODE IS INITIAL.
        <FS_HU>-INSPSTATUS = 'Belum diinspeksi'.
      ELSEIF <FS_HU>-VCODE EQ 'P'.
        <FS_HU>-INSPSTATUS = 'PASS'.
      ELSEIF <FS_HU>-VCODE EQ 'H'.
        <FS_HU>-INSPSTATUS = 'HOLD'.
      ELSEIF <FS_HU>-VCODE EQ 'A'.
        <FS_HU>-INSPSTATUS = 'Accepted'.
      ELSEIF <FS_HU>-VCODE EQ 'R'.
        <FS_HU>-INSPSTATUS = 'Rejected'.
      ENDIF.
    ELSE.
      <FS_HU>-INSPSTATUS = 'Tidak Perlu Diinspeksi'.
    ENDIF.
*    END ADD BY PST_HISAR 14-12-12


*    MODIFY IT_HU.
  ENDLOOP.

  SORT IT_HU ASCENDING BY VBELN ZPOSNR POSNR.
  DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN ZPOSNR POSNR.

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
  IF IT_HU[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAY_DATA


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_HU' :
       'WADAT_IST'   ''  ''  ''  10   'Actual GI Date'    ''   ''  ''  '',
       'VBELN'   ''  ''  ''  10   'DO Number'  ''   ''  ''  '',
       'ZPOSNR'   ''  ''  ''  8   'DO Item'  ''   ''  ''  '',
       'POSNR'   ''  ''  ''  12   'DO Sub Item'  ''   ''  ''  '',
       'VBELV'   ''  ''  ''  12   'SO Number'  ''   ''  ''  '',
       'POSNV'   ''  ''  ''  6   'SO Item'  ''   ''  ''  '',
       'EXIDV'   ''  ''  '' 11   'HU Pallet'  ''   ''  ''  '' ,
       'ZEXIDV'   ''  ''  ''  11    'HU Box'    ''   ''  ''  '',
       'ZZTYPE'   ''  ''  ''  18   'Tipe'   ''   ''  ''  '',
       'ZZTHICK'   ''  ''  ''  6   'Thickness'   ''   ''  ''  '',
       'ZZWIDTH'   ''  ''  ''   7   'Width '       ''   ''  ''  '',
       'ZZLENGTH'   ''  ''  ''   7   'Length '       ''   ''  ''  '',
       'ZZROLL'   ''  ''  ''  18   'Roll Number'  ''   ''  ''  '',
       'ZQTY'   ''  ''  ''  3   'Qty Roll'  ''   ''  ''  '',
       'LGORT'   ''  ''  ''  5   'Sloc'   ''  ''  ''  '',
       'WERKS'   ''  ''  ''  5   'Plant'   ''  ''  ''  '',
       'ZZEXPR'   ''  ''  ''  12   'Expired Date' ''   ''  ''  '',
       'LWEDT'   ''  ''  ''  10   'Production Date'    ''   ''  ''  '',
       'BSTNK'   ''  ''  ''  12   'PO Number'  ''   ''  ''  '',
       'ZPINUM'   ''  ''  ''  20   'PI Number'  ''   ''  ''  '',
       'ENAME'   ''  ''  ''  20   'Sales Employee'  ''   ''  ''  '',
       'KUNAG'   ''  ''  ''  12   'Sold to Party'  ''   ''  ''  '',
       'NAME1'   ''  ''  ''  35   'Sold to Party Name'  ''   ''  ''  '',
       'ZZCRITERIA'   ''  ''  '' 12   'Criteria Grade'  ''   ''  ''  '' ,
       'AUART'   ''  ''  ''  6   'SO Type'   ''   ''  ''  '',
       'BEZEI'   ''  ''  ''  18   'SO Type Description'   ''   ''  ''  '',
       'MATNR'   ''  ''  ''  16   'Material Number'   ''   ''  ''  '',
       'ZZTREAT'   ''  ''  '' 10   'Treatment '       ''   ''  ''  '',
       'ZZCORE'   ''  ''  ''  10   'Core '       ''   ''  ''  '',
       'ZZPACK'   ''  ''  ''  10   'Sistem Packing'  ''   ''  ''  '',
       'ZZALIAS'   ''  ''  ''  10   'Alias'  ''   ''  ''  '',  " ADD BY PST_HISAR 14-12-12
       'CHARG'   ''  ''  ''  10   'Batch'  ''   ''  ''  '',
       'QPLOS'   ''  ''  ''  25   'Inspection Lot'  ''   ''  ''  '',  " ADD BY PST_HISAR 14-12-12
       'INSPSTATUS'   ''  ''  ''  25   'Status Inspection'  ''   ''  ''  '',  " ADD BY PST_HISAR 14-12-12
       'ERDAT'   ''  ''  ''  10   'HU Date'   ''  ''  ''  '',
       'LFART'   ''  ''  ''  6   'DO Type'   ''  ''  ''  '',
       'WADAT'   ''  ''  ''  12   'Delivery Date' ''   ''  ''  '',
       'TKNUM'   ''  ''  ''  15   'Shipment Number'  ''   ''  ''  '',
       'KUNNR'   ''  ''  ''  12   'Ship to Party'  ''   ''  ''  '',
       'ZNAME1'   ''  ''  ''  35   'Ship to Party Name'  ''   ''  ''  '',
       'LFIMG'   ''  ''  ''  10   'DO Qty'  ''   ''  ''  '',
       'VRKME'   ''  ''  ''  6   'Sales Unit' ''   ''  ''  '',
       'NTGEW'   ''  ''  ''  10   'Net Weight'    ''   ''  ''  '',
       'GEWEI'   ''  ''  ''  6   'Weight Unit'  ''   ''  ''  '',
       'ZWBSTK'   ''  ''  ''  20   'GI Status'  ''   ''  ''  '',
       'BWART'   ''  ''  ''  6   'Movement Type'  ''   ''  ''  '',
       'BLDAT'   ''  ''  ''  15   'DO Created Date'  ''   ''  ''  '',
       'ZERDAT'   ''  ''  ''  15   'DO Created On'  ''   ''  ''  ''.
*       'ZNAME1'   ''  ''  ''  15   'HU Created On'  ''   ''  ''  ''.
ENDFORM.                    " F_FIELD_CATALOG


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
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
*  WA_LAYOUT-BOX_TABNAME = 'T_HEADER'.
*  WA_LAYOUT-EXPAND_FIELDNAME = 'EXPAND'.
*  wa_layout-expand_all = 'X'.
**  WA_LAYOUT-CELL_MERGE = 'X'.
*  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'

ENDFORM.                    " F_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
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
      T_OUTTAB                 = IT_HU
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_ROLL'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  DATA : LT_HUS  TYPE HUM_VENUM_T.
***  DATA : WA_VBAP LIKE LINE OF IT_VBAP.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&REFRESH'.
      PERFORM GET_DATA.
      PERFORM DISPLAY_DATA.
***      READ TABLE IT_VBAP INTO WA_VBAP INDEX FU_SELFIELD-TABINDEX.
***      CASE FU_SELFIELD-SEL_TAB_FIELD.
***        WHEN 'IT_VBAP-VBELN'.
***          SET PARAMETER ID 'AUN' FIELD WA_VBAP-VBELN.
***          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
***        WHEN 'IT_VBAP-EXIDV'.
*****          PERFORM DISPLAY_HANDLING_UNIT USING WA_DATA-LENUM.
***      ENDCASE.
***    WHEN  'CREATE'.
***      PERFORM CREATE_DELIVERY.
  ENDCASE.

**  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND