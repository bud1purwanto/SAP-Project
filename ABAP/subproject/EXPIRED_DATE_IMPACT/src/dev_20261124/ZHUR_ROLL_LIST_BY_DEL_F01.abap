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
  DATA: BEGIN OF IT_ZNAVIS  OCCURS 0, "with header line,
        ITEM   LIKE ZNAVIS-ITEM,
        TYPE   LIKE ZNAVIS-TYPE,
        WIDTH  LIKE ZNAVIS-WIDTH,
        LENGTH LIKE ZNAVIS-LENGTH,
    END OF IT_ZNAVIS.

  TABLES: ZNAVIS.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_DATA .

    SELECT ITEM TYPE WIDTH LENGTH INTO TABLE IT_ZNAVIS FROM ZNAVIS WHERE NOTE = 'MASTER KTNG'.

    CLEAR   : IT_HU, IT_HUM, VATNTRNMS,VATNPOSMS,VATNTRNSS,VATNPOSSS.
    REFRESH : IT_HU, IT_HUM.

    SELECT SINGLE ATINN INTO VATNTRNMS FROM CABN WHERE ATNAM = 'ZZDERIVATIVEMS'.
    SELECT SINGLE ATINN INTO VATNPOSMS FROM CABN WHERE ATNAM = 'ZZPOSITIONMS'.
    SELECT SINGLE ATINN INTO VATNTRNSS FROM CABN WHERE ATNAM = 'ZZDERIVATIVESS'.
    SELECT SINGLE ATINN INTO VATNPOSSS FROM CABN WHERE ATNAM = 'ZZPOSITIONSS'.

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

    "Add by J. Budi at 16 May 2025 for Subcontracting Lamintate
    IF P_SUBCON EQ 'X'.
      CLEAR TLFART.
      TLFART-SIGN = 'I'.
      TLFART-OPTION = 'EQ'.
      TLFART-LOW = 'ZDDS'.
      APPEND TLFART.

      CLEAR TLFART.
      TLFART-SIGN = 'I'.
      TLFART-OPTION = 'EQ'.
      TLFART-LOW = 'ZDRD'.
      APPEND TLFART.
    ENDIF.

    "- from HUMSEG
    SELECT
      HUMSEG~VENUM  AS VENUM
      HUMSEG~MBLNR
      MSEG~VBELN_IM AS VBELN
      MSEG~VBELP_IM AS POSNR
      LIPS~UECHA
      LIPS~QPLOS
      LIPS~PSTYV

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
        AND LIKP~ERDAT IN S_ERDAT "add by pst_adhy 8-1-13
        AND LIPS~BWART IN TBWART "Add by pst_hisar 17-12-12
        AND LIKP~LFART IN TLFART "Add by pst_hisar 17-12-12
        AND LIPS~PSTYV IN S_PSTYV.


    SORT IT_HUM DESCENDING BY VBELN POSNR VENUM.
    DELETE ADJACENT DUPLICATES FROM IT_HUM COMPARING VBELN POSNR.

    "- from LIKP
    SELECT
      LIKP~VBELN
      LIPS~POSNR
      LIPS~UECHA
      LIPS~LFIMG
      LIPS~QPLOS
      LIPS~PSTYV

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
        AND LIKP~ERDAT IN S_ERDAT "add by pst_adhy 8-1-13
        AND LIPS~BWART IN TBWART "Add by pst_hisar 17-12-12
        AND LIKP~LFART IN TLFART "Add by pst_hisar 17-12-12
        AND LIPS~PSTYV IN S_PSTYV.
*      AND VBUK~WBSTK NE 'C'.

    SORT IT_HU ASCENDING BY VBELN POSNR.
    DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN POSNR.
    DELETE IT_HU WHERE LFIMG = 0.

    LOOP AT IT_HUM ASSIGNING <FS_HUM>.
      APPEND <FS_HUM> TO IT_HU.
    ENDLOOP.

    SORT IT_HU ASCENDING BY VBELN POSNR LFIMG.
    DELETE ADJACENT DUPLICATES FROM IT_HU COMPARING VBELN POSNR.


    LOOP AT IT_HU ASSIGNING <FS_HU> .
      "- ODO Item
      IF <FS_HU>-UECHA EQ ''.
        <FS_HU>-ZPOSNR = <FS_HU>-POSNR.
        <FS_HU>-POSNR  = ''.
      ELSE.
        <FS_HU>-ZPOSNR = <FS_HU>-UECHA.
      ENDIF.

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



      IF S_EXIDV IS NOT INITIAL.
        IF <FS_HU>-EXIDV NOT IN S_EXIDV.
          DELETE IT_HU.
          CONTINUE.
        ENDIF.
      ENDIF.

      "- Shippment
      SELECT SINGLE VTTP~TKNUM
        INTO <FS_HU>-TKNUM
        FROM VTTP
        WHERE VTTP~VBELN = <FS_HU>-VBELN.

      IF S_TKNUM IS NOT INITIAL.
        IF <FS_HU>-TKNUM NOT IN S_TKNUM.
          DELETE IT_HU.
          CONTINUE.
        ENDIF.
      ENDIF.

      "- Material Number , Plant, DO Qty, Storage Location, Movement Type
      SELECT SINGLE LIPS~MATNR LIPS~WERKS LIPS~VRKME LIPS~LGORT LIPS~BWART
        INTO (<FS_HU>-MATNR, <FS_HU>-WERKS, <FS_HU>-VRKME, <FS_HU>-LGORT, <FS_HU>-BWART)
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

      CLEAR : V_VBTYP.
      "- DO Type, Delivery Date, Actual GI Date, DO Created Date, DO Created On, Sold to Party, Document Category
      SELECT SINGLE LIKP~LFART LIKP~WADAT LIKP~WADAT_IST LIKP~BLDAT LIKP~ERDAT LIKP~KUNAG LIKP~VBTYP LIKP~CMFRE
        INTO (<FS_HU>-LFART, <FS_HU>-WADAT, <FS_HU>-WADAT_IST, <FS_HU>-BLDAT, <FS_HU>-ZERDAT, <FS_HU>-KUNAG, V_VBTYP, <FS_HU>-CMFRE)
        FROM LIKP
        WHERE LIKP~VBELN = <FS_HU>-VBELN.


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

*- change by ALF
      "- Production Date
*    SELECT SINGLE MCH1~LWEDT
*      INTO <FS_HU>-LWEDT
*      FROM MCH1
*      WHERE MCH1~CHARG = <FS_HU>-CHARG
*        AND MCH1~MATNR = <FS_HU>-MATNR.
      IF <FS_HU>-CHARG EQ '' OR <FS_HU>-MATNR EQ ''.
      ELSE.
        CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
          EXPORTING
            MATNR = <FS_HU>-MATNR
            CHARG = <FS_HU>-CHARG
          IMPORTING
            PDATE = <FS_HU>-LWEDT.
      ENDIF.
*- end of ALF

      "- SO Number
      IF <FS_HU>-LFART EQ 'ZDLF' OR <FS_HU>-LFART EQ 'ZELF' OR <FS_HU>-LFART EQ 'ZLR' OR <FS_HU>-LFART EQ 'ZDDS' OR <FS_HU>-LFART EQ 'ZDRD'.
        SELECT SINGLE LIPS~VGBEL
          INTO <FS_HU>-VBELV
          FROM LIPS
          WHERE LIPS~VBELN = <FS_HU>-VBELN
            AND LIPS~POSNR = <FS_HU>-POSNR.

        "- SO Item
        SELECT SINGLE LIPS~VGPOS
          INTO <FS_HU>-POSNV
          FROM LIPS
          WHERE LIPS~VBELN = <FS_HU>-VBELN
            AND LIPS~POSNR = <FS_HU>-POSNR.

      ELSEIF <FS_HU>-LFART EQ 'HTP' OR <FS_HU>-LFART EQ 'ZLO' OR <FS_HU>-LFART EQ 'ZSCF' OR <FS_HU>-LFART EQ 'ZSCN' OR <FS_HU>-LFART EQ 'ZSPB'.
        <FS_HU>-VBELV = ''.
        <FS_HU>-POSNV = ''.
      ENDIF.


      "- SO Type, PO Number
      SELECT SINGLE VBAK~AUART VBAK~BSTNK
        INTO (<FS_HU>-AUART, <FS_HU>-BSTNK)
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


      "- Sold to Party Name
      SELECT SINGLE ADRC~NAME1
        INTO <FS_HU>-NAME1
        FROM ADRC
        INNER JOIN VBPA ON ADRC~ADDRNUMBER = VBPA~ADRNR
        WHERE VBPA~VBELN = <FS_HU>-VBELN
          AND VBPA~PARVW EQ 'AG'.

      IF <FS_HU>-CMFRE IS NOT INITIAL.
        <FS_HU>-VSTAT = 'RELEASED'.
      ELSE.
        IF <FS_HU>-AUART EQ 'ZDOR'.
          CLEAR IT_BLOCK. REFRESH IT_BLOCK.

          SELECT SINGLE KNKK~KNKLI INTO (VKNKLI)
            FROM KNKK
            WHERE KNKK~KUNNR = <FS_HU>-KUNAG.

          SELECT KNKK~KUNNR
            INTO CORRESPONDING FIELDS OF TABLE IT_KUNNR
            FROM KNKK
            WHERE KNKK~KNKLI = VKNKLI.

          LOOP AT IT_KUNNR.
            SELECT BSID~KUNNR BSID~ZFBDT BSID~ZBD1T BSID~WRBTR BSID~SHKZG
              INTO CORRESPONDING FIELDS OF TABLE IT_BLOCK2
              FROM BSID
              JOIN KNA1 ON KNA1~KUNNR = BSID~KUNNR
              WHERE BSID~KUNNR = IT_KUNNR-KUNNR
              AND   BSID~ZBD1T >= 0
              AND   KNA1~KTOKD IN ('ZLAF', 'ZLOE', 'ZLTP').
            APPEND LINES OF IT_BLOCK2 TO IT_BLOCK.
          ENDLOOP.

          IF IT_BLOCK[] IS NOT INITIAL.

            SORT IT_BLOCK ASCENDING BY KUNNR ZBD1T.
            LOOP AT IT_BLOCK.
              IF IT_BLOCK-SHKZG = 'H' OR IT_BLOCK-SHKZG = 'S' AND IT_BLOCK-WRBTR < 0.
                DELETE IT_BLOCK.
              ELSE.
                IT_BLOCK-VDUEDT = IT_BLOCK-ZFBDT + IT_BLOCK-ZBD1T.
                MODIFY IT_BLOCK.
              ENDIF.
            ENDLOOP.

            SORT IT_BLOCK ASCENDING BY KUNNR VDUEDT.
            READ TABLE IT_BLOCK INDEX 1.
            VDUEDT = IT_BLOCK-VDUEDT.
            VAGING = SY-DATUM - IT_BLOCK-VDUEDT.
            IF VAGING GE 30.
              <FS_HU>-VSTAT = 'BLOCKED'.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDIF.


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
      IF <FS_HU>-LFART EQ 'ZNL' OR <FS_HU>-LFART EQ 'ZSL'.
        SELECT SINGLE LIPS~VGBEL
          INTO <FS_HU>-BSTNK
          FROM LIPS
          WHERE LIPS~VBELN = <FS_HU>-VBELN.
      ELSE.
        SELECT SINGLE VBKD~BSTKD
          INTO <FS_HU>-BSTNK
          FROM VBKD
          WHERE VBKD~VBELN = <FS_HU>-VBELV.

        IF <FS_HU>-BSTNK EQ ''.
          SELECT SINGLE BSTNK
            INTO <FS_HU>-BSTNK
            FROM VBAK
            WHERE VBELN = <FS_HU>-VBELV.
        ENDIF.
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

      "- Pallet Plastic Add by Carfin 24.01.2019
      SELECT SINGLE ZPALLETR~PALID
        INTO <FS_HU>-PALID
        FROM VEKP INNER JOIN ZPALLETR ON VEKP~EXIDV = ZPALLETR~EXIDV
        WHERE VEKP~EXIDV = <FS_HU>-EXIDV.
      "- Pallet Plastic Add by Carfin 24.01.2019


      IF <FS_HU>-CHARG NE ''.
        CLEAR : IT_CHAR.
        REFRESH : IT_CHAR.
        CALL FUNCTION 'ZCHARACTERISTICS_ZSD024'
          EXPORTING
            I_VAL_MATNR  = <FS_HU>-MATNR
            I_VAL_CHARGE = <FS_HU>-CHARG
          TABLES
            T_VAL_TAB    = IT_CHAR
          EXCEPTIONS
            NO_OBJECT    = 1
            NO_VALUES    = 2.

        IF SY-SUBRC EQ '0'.
          "- Type
          READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'  ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            <FS_HU>-ZZTYPE = <FS_CHAR>-ATWRT.
          ENDIF.

          "- Thickness
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTHICKNESS' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV1.
            WRITE ATFLV1 TO <FS_HU>-ZZTHICK.
          ENDIF.

          "- Width
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            WRITE ATFLV2 TO <FS_HU>-ZZWIDTH.
          ENDIF.

          "- Length
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZLENGTH' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            WRITE ATFLV2 TO <FS_HU>-ZZLENGTH.
          ENDIF.

          "- Nomor Roll
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZNOMORROLL' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            <FS_HU>-ZZROLL = <FS_CHAR>-ATWRT.
          ENDIF.

          "- Expire Live
          CLEAR : V_EXPR.
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXPIREDLIVE' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0 AND <FS_HU>-LWEDT NE '00000000'.
            MOVE <FS_CHAR>-ATFLV TO ATFLV2.
            V_EXPR = ATFLV2.
            <FS_HU>-ZZEXPR = <FS_HU>-LWEDT + V_EXPR.
          ENDIF.

          "- Treatment
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTREATMENT' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            <FS_HU>-ZZTREAT = <FS_CHAR>-ATWRT.
          ENDIF.

          "- Core
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZCORE' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            <FS_HU>-ZZCORE = <FS_CHAR>-ATWTB.
          ENDIF.

          "- Sistem Packing
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZPACKING' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC = 0.
            <FS_HU>-ZZPACK = <FS_CHAR>-ATWTB.
          ENDIF.

          "- Criteria
          IF P_CHECK EQ 'X'.
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZCRITERIA' ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              <FS_HU>-ZZCRITERIA = <FS_CHAR>-ATWTB.
            ENDIF.
          ELSE.
            <FS_HU>-ZZCRITERIA = ''.
          ENDIF.

*      BEGIN ADD BY PST_HISAR 14-12-12

          "- Alias
          READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZALIAS' ASSIGNING <FS_CHAR>.
          IF SY-SUBRC EQ 0.
            <FS_HU>-ZZALIAS = <FS_CHAR>-ATWRT.
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
*          JOIN LIPS ON LIPS~QPLOS = QAVE~PRUEFLOS
*          WHERE LIPS~VBELN = IT_HU-VBELN.
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
*      END ADD BY PST_HISAR 14-12-12
        ENDIF.
      ENDIF.

      "- Status Inspection Partial
      SELECT SINGLE QAVE~VCODE
        INTO <FS_HU>-PARTIAL
        FROM QAVE
        INNER JOIN QALT ON QAVE~PRUEFLOS = QALT~PRUEFLOS AND QAVE~TEILLOS = QALT~TEILLOS
        WHERE QALT~CHARG = <FS_HU>-CHARG
          AND QALT~PRUEFLOS = <FS_HU>-QPLOS.

      IF <FS_HU>-PARTIAL EQ 'P'.
        <FS_HU>-PARTIAL = 'PASS'.
      ELSEIF <FS_HU>-PARTIAL EQ 'H'.
        <FS_HU>-PARTIAL = 'HOLD'.
      ENDIF.

      PERFORM GET_COMPCODE.  "Add for new company
      PERFORM GET_BARCODE.   "get barcode di label

      PERFORM OUTPUT USING <FS_HU>-EXIDV.
      PERFORM OUTPUT USING <FS_HU>-ZEXIDV.
      IF P_SLDATE EQ ''.
        PERFORM OUTPUT USING <FS_HU>-VBELV.
        PERFORM OUTPUT USING <FS_HU>-POSNV.
      ENDIF.
      PERFORM OUTPUT USING <FS_HU>-VBELN.
      PERFORM OUTPUT USING <FS_HU>-ZPOSNR.

    ENDLOOP.

    IF S_BUKRS IS NOT INITIAL.
      DELETE IT_HU WHERE BUKRS NOT IN S_BUKRS.
    ENDIF.

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

    IF P_SLDATE = 'X'.
      PERFORM GET_SCHLINE.
    ENDIF.

    IF P_KTNG = 'X'.
      PERFORM GET_KTNG_CODE.
    ENDIF.

    IF P_TOYOBO ='X'. "add by rey (toyobo noroll and lot number)
      PERFORM GETDATA_TOYOBO.
    ENDIF.

    IF P_ACTWGT = 'X'.
      PERFORM GET_ACTUAL_WEIGHT.
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
    PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_HU' :
         'WADAT_IST'   ''  ''  ''  10   'Actual GI Date'    ''   ''  ''  '',
         'VBELN'   ''  ''  ''  10   'DO Number'  ''   ''  ''  '',
         'BUKRS'   ''  ''  ''  12   'Company Code'  ''   ''  ''  '',  "add for new company
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
         'PARTIAL'  ''  ''  ''  18   'Status Partial Lot'  ''   ''  ''  '',
         'ERDAT'   ''  ''  ''  10   'HU Date'   ''  ''  ''  '',
         'LFART'   ''  ''  ''  6   'DO Type'   ''  ''  ''  '',
         'PSTYV'   ''  ''  ''  8   'Item Category'   ''  ''  ''  '',
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
         'BLDAT'   ''  ''  ''  15   'Document Date'  ''   ''  ''  '',
         'ZERDAT'   ''  ''  ''  15   'DO Created On'  ''   ''  ''  '',
         'VSTAT'   ''  ''  ''  15   'Status Block'    ''  ''  ''  '',
         'CMFRE'   ''  ''  ''  15   'Released Dlv Date' '' ''  ''  '',
         'EDATU'   ''  ''  ''  15   'SchLine Date' '' ''  ''  '',
         'LOTNOTYB'   ''  ''  ''  20   'TOYOBO Lot Number'  ''   ''  ''  '', "ADD BY REY (TOYOBO LOT NUMBER)
         'ROLLNOTYB'   ''  ''  ''  20   'TOYOBO Roll Number'  ''   ''  ''  '', "ADD BY REY (TOYOBO ROLL NUMBER)
        'ROLLNO'   ''  ''  ''  35   'KT&G Roll Number'  ''   ''  ''  '', "ADD BY GANI (KT&G ROLL NUMBER)
        'MESSAGE'   ''  ''  ''  35   'Keterangan'  ''   ''  ''  '', "ADD BY GANI (KT&G ROLL NUMBER)
        'VBARCODE'   ''  ''  ''  25   'Text Barcode'  ''   ''  ''  '', "ADD BY GANI (barcode di label)
        'PALID'   ''  ''  ''  15   'No. Pallet Trias'  ''   ''  ''  '', "ADD BY CARFIN 24.01.2019
        'AWEIGHT'   ''  ''  ''  15   'Actual Weight'  ''   ''  ''  '',
        'ALENGTH'   ''  ''  ''  15   'Actual Length'  ''   ''  ''  ''.

    IF P_SLDATE NE 'X'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'EDATU'.
    ENDIF.

    IF P_TOYOBO NE 'X'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'LOTNOTYB'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'ROLLNOTYB'.
    ENDIF.

    IF P_KTNG NE 'X'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'ROLLNO'.
    ENDIF.

    IF P_ACTWGT NE 'X'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'ALENGTH'.
      DELETE T_FIELDCAT WHERE FIELDNAME = 'AWEIGHT'.
    ENDIF.
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
    ENDCASE.

  ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1973   text
*      -->P_1974   text
*      -->P_1975   text
*      -->P_1976   text
*      -->P_1977   text
*      -->P_10     text
*      -->P_1979   text
*      -->P_1980   text
*      -->P_1981   text
*      -->P_1982   text
*      -->P_1983   text
*----------------------------------------------------------------------*
  FORM F_ALV_FIELDCATG_ICON2 USING FU_TYPES
                                  FU_FNAME
                                  FU_REFTB
                                  FU_REFLD
                                  FU_NOOUT
                                  FU_OUTLN
                                  FU_FLTXT
                                  FU_DOSUM
                                  FU_HOTSP
                                  FU_JUST
                                  FU_ICON.


    CLEAR: T_FIELDCAT.
    T_FIELDCAT-TABNAME       = FU_TYPES.
    T_FIELDCAT-FIELDNAME     = FU_FNAME.
    T_FIELDCAT-REF_TABNAME   = FU_REFTB.
    T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
    T_FIELDCAT-NO_OUT        = FU_NOOUT.
    T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
    T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
    T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
    T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
    T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
    T_FIELDCAT-DO_SUM        = FU_DOSUM.
    T_FIELDCAT-HOTSPOT       = FU_HOTSP.
    T_FIELDCAT-JUST          = FU_JUST.
    T_FIELDCAT-ICON          = FU_ICON.
    T_FIELDCAT-NO_ZERO       = ''.
    APPEND T_FIELDCAT.
    CLEAR T_FIELDCAT.

  ENDFORM.                    " F_ALV_FIELDCATG_ICON2


*&---------------------------------------------------------------------*
*&      Form  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_HU>_EXIDV  text
*      <--P_<FS_HU>_EXIDV  text
*----------------------------------------------------------------------*
  FORM OUTPUT  USING    PARAM.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PARAM
      IMPORTING
        OUTPUT = PARAM.
  ENDFORM.                    " OUTPUT




*&---------------------------------------------------------------------*
*&      Form  to_olap
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM TO_OLAP.
    SELECT SINGLE DBMS
           FROM DBCON
           INTO DBTYPE
           WHERE CON_NAME = LV_DBS_CONNECTION.

    IF DBTYPE = 'MSS'.
      TRY.

        EXEC SQL.
          CONNECT TO :LV_DBS_CONNECTION

        ENDEXEC.
        IF SY-SUBRC <> 0.
          RAISE EXCEPTION TYPE CX_SY_NATIVE_SQL_ERROR.
        ENDIF.

        EXEC SQL.
          DELETE FROM XZSD024
        ENDEXEC.

        EXEC SQL.
          COMMIT WORK
        ENDEXEC.

        LOOP AT IT_HU.
          EXEC SQL.
            INSERT INTO
              XZSD024(COL001, COL002, COL003, COL004,
        COL005, COL006, COL007, COL008, COL009, COL010, COL011, COL012,
        COL013, COL014, COL015, COL016, COL017, COL018, COL019, COL020,
        COL021, COL022, COL023, COL024, COL025, COL026, COL027, COL028,
        COL029, COL030, COL031, COL032, COL033, COL034, COL035, COL036,
        COL037, COL038, COL039, COL040, COL041, COL042, COL043, COL044,
        COL045, COL046, COL047, COL048, COL049, COL050, COL051, COL052)

            VALUES(:IT_HU-WADAT_IST, :IT_HU-VBELN, :IT_HU-ZPOSNR, :IT_HU-POSNR,
        :IT_HU-VBELV, :IT_HU-POSNV, :IT_HU-EXIDV, :IT_HU-ZEXIDV, :IT_HU-ZZTYPE, :IT_HU-ZZTHICK, :IT_HU-ZZWIDTH, :IT_HU-ZZLENGTH,
        :IT_HU-ZZROLL, :IT_HU-ZQTY, :IT_HU-LGORT, :IT_HU-WERKS, :IT_HU-ZZEXPR, :IT_HU-LWEDT, :IT_HU-BSTNK, :IT_HU-ZPINUM,
        :IT_HU-ENAME, :IT_HU-KUNAG, :IT_HU-NAME1, :IT_HU-ZZCRITERIA, :IT_HU-AUART, :IT_HU-BEZEI, :IT_HU-MATNR, :IT_HU-ZZTREAT,
        :IT_HU-ZZCORE, :IT_HU-ZZPACK, :IT_HU-ZZALIAS, :IT_HU-CHARG, :IT_HU-QPLOS, :IT_HU-INSPSTATUS, :IT_HU-PARTIAL, :IT_HU-ERDAT,
        :IT_HU-LFART, :IT_HU-PSTYV, :IT_HU-WADAT, :IT_HU-TKNUM, :IT_HU-KUNNR, :IT_HU-ZNAME1, :IT_HU-LFIMG, :IT_HU-VRKME,
        :IT_HU-NTGEW, :IT_HU-GEWEI, :IT_HU-ZWBSTK, :IT_HU-BWART, :IT_HU-BLDAT, :IT_HU-ZERDAT, :IT_HU-VSTAT, :IT_HU-CMFRE)

          ENDEXEC.
        ENDLOOP.

        EXEC SQL.
          COMMIT WORK.
        ENDEXEC.

        EXEC SQL.
          DISCONNECT :LV_CURRENT_CONNECTION
        ENDEXEC.
      ENDTRY.
    ENDIF.
  ENDFORM.                    "to_olap


*&---------------------------------------------------------------------*
*&      Form  GET_KTNG_CODE
*&---------------------------------------------------------------------*
*       ADD BY GANI (KT&G ROLL NUMBER)
*----------------------------------------------------------------------*
  FORM GET_KTNG_CODE.
    DATA: IT_KTNG LIKE ZDETAIL_KTNG,
          V_SONUM LIKE ZDETAIL_KTNG-SONUM,   "Added by AKBAR 18.12.2019 (KT&G case SO to SO)
          V_SITEM LIKE ZDETAIL_KTNG-SOITEM,  "Added by AKBAR 18.12.2019 (KT&G case SO to SO)
          V_LEN TYPE I,
          V_CREATE LIKE SY-DATUM,
          V_CUTOFF LIKE SY-DATUM VALUE '20220210'.

    LOOP AT IT_HU.
      CLEAR: IT_KTNG, V_SONUM, V_SITEM, V_LEN, V_CREATE. "Added by AKBAR 18.12.2019 (KT&G case SO to SO)

      "Start - Added by AKBAR 18.12.2019 (KT&G case SO to SO)
      PERFORM INPUT_FORMAT USING IT_HU-VBELV CHANGING V_SONUM.
      PERFORM INPUT_FORMAT USING IT_HU-POSNV CHANGING V_SITEM.
      "End - Added by AKBAR 18.12.2019 (KT&G case SO to SO)

      SELECT SINGLE * INTO IT_KTNG FROM ZDETAIL_KTNG WHERE BATCH EQ IT_HU-CHARG
             AND SONUM EQ V_SONUM AND SOITEM EQ V_SITEM AND DELETION EQ ''. "Added by AKBAR 18.12.2019 (KT&G case SO to SO)

      IF SY-SUBRC EQ 0.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            DATE_EXTERNAL = IT_KTNG-CREATE_ON
          IMPORTING
            DATE_INTERNAL = V_CREATE.
      ENDIF.

      IF V_CREATE GE V_CUTOFF.
        IT_HU-ROLLNO = IT_KTNG-NOROLL.
      ELSE.
        IF IT_KTNG-KTNGCODE NE ''.
          V_LEN = STRLEN( IT_KTNG-JRNUMB ) - 3.
          IT_KTNG-JRNUMB = IT_KTNG-JRNUMB+V_LEN(3).
          V_LEN = STRLEN( IT_KTNG-TS ) - 1.
          IT_KTNG-TS = IT_KTNG-TS+V_LEN(1).
        ENDIF.

        CONCATENATE IT_KTNG-KTNGCODE '-' IT_KTNG-COMPANY '-' IT_KTNG-JRDATE '-' IT_KTNG-JRNUMB '-'
                    IT_KTNG-MIDROLL '-' IT_KTNG-SLITT_MCHN '-' IT_KTNG-TS '-' IT_KTNG-PS INTO IT_HU-ROLLNO.

      ENDIF.
      MODIFY: IT_HU.
      CLEAR: IT_HU.
    ENDLOOP.
  ENDFORM.                    "GET_CUST_BARCODE

*&---------------------------------------------------------------------*
*&      Form  GETDATA_TOYOBO
*&---------------------------------------------------------------------*
*       ADD BY REY (TOYOBO ROLL NUMBER & LOT NUMBER)
*----------------------------------------------------------------------*
  FORM GETDATA_TOYOBO.

    CLEAR: V_ROLTYB, V_LOTTYB.

    SELECT SINGLE ATINN INTO V_ROLTYB FROM CABN WHERE ATNAM = 'ZZNOROLLTOYOBO'.
    SELECT SINGLE ATINN INTO V_LOTTYB FROM CABN WHERE ATNAM = 'ZZNOLOTTOYOBO'.

    LOOP AT IT_HU.
      SELECT SINGLE  AUSP~ATWRT INTO IT_HU-ROLLNOTYB
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = IT_HU-MATNR AND MCH1~CHARG = IT_HU-CHARG AND AUSP~ATINN = V_ROLTYB.

      SELECT SINGLE  AUSP~ATWRT INTO IT_HU-LOTNOTYB
      FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
      WHERE MCH1~MATNR = IT_HU-MATNR AND MCH1~CHARG = IT_HU-CHARG AND AUSP~ATINN = V_LOTTYB.

      MODIFY IT_HU TRANSPORTING ROLLNOTYB LOTNOTYB.
*    CLEAR: IT_HU-ROLLNOTYB , IT_HU-LOTNOTYB.
      CLEAR: IT_HU.
    ENDLOOP.



  ENDFORM.                    "GETDATA_TOYOBO


*&---------------------------------------------------------------------*
*&      Form  GET_COMPCODE
*&---------------------------------------------------------------------*
*       Add for new company
*----------------------------------------------------------------------*
  FORM GET_COMPCODE.
    DATA: ZVBELN LIKE LIPS-VBELN,
            ZPOSNR LIKE LIPS-POSNR,
            ZVGBEL LIKE LIPS-VGBEL,
            ZVKORG LIKE LIKP-VKORG.

    CLEAR: ZVBELN, ZPOSNR, ZVGBEL.

    IF <FS_HU>-UECHA EQ ''.
      ZVBELN = <FS_HU>-VBELN.
      ZPOSNR = <FS_HU>-ZPOSNR.
    ELSE.
      ZVBELN = <FS_HU>-VBELN.
      ZPOSNR = <FS_HU>-POSNR.
    ENDIF.

*    SELECT SINGLE LIPS~VGBEL
*      INTO ZVGBEL
*      FROM LIPS
*      WHERE LIPS~VBELN = ZVBELN
*      AND LIPS~POSNR = ZPOSNR.

*    SELECT SINGLE TVKO~BUKRS
*      INTO (<FS_HU>-BUKRS)
*      FROM VBAK JOIN TVKO ON VBAK~VKORG = TVKO~VKORG
*      WHERE VBAK~VBELN = ZVGBEL.

    SELECT SINGLE LIKP~VKORG
      INTO ZVKORG
      FROM LIKP JOIN LIPS ON LIKP~VBELN = LIPS~VBELN
      WHERE LIPS~VBELN = ZVBELN
      AND LIPS~POSNR = ZPOSNR.

    SELECT SINGLE TVKO~BUKRS
      INTO (<FS_HU>-BUKRS)
      FROM TVKO
      WHERE TVKO~VKORG = ZVKORG.

  ENDFORM.                    "GET_COMPCODE


*&---------------------------------------------------------------------*
*&      Form  GET_BARCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_BARCODE.

    VTRNMS = '00'.
    VPOSMS = '00'.
    VTRNSS = '00'.
    VPOSSS = '00'.

    "GET TURUNAN MS
    SELECT SINGLE  AUSP~ATWRT INTO VTRNMS
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE MCH1~MATNR = <FS_HU>-MATNR AND MCH1~CHARG = <FS_HU>-CHARG AND AUSP~ATINN = VATNTRNMS.

    "GET POSISI MS
    SELECT SINGLE  AUSP~ATWRT INTO VPOSMS
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE MCH1~MATNR = <FS_HU>-MATNR AND MCH1~CHARG = <FS_HU>-CHARG AND AUSP~ATINN = VATNPOSMS.

    "GET TURUNAN SS
    SELECT SINGLE  AUSP~ATWRT INTO VTRNSS
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE MCH1~MATNR = <FS_HU>-MATNR AND MCH1~CHARG = <FS_HU>-CHARG AND AUSP~ATINN = VATNTRNSS.

    "GET POSISI SS
    SELECT SINGLE  AUSP~ATWRT INTO VPOSSS
        FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
        WHERE MCH1~MATNR = <FS_HU>-MATNR AND MCH1~CHARG = <FS_HU>-CHARG AND AUSP~ATINN = VATNPOSSS.

    CONCATENATE <FS_HU>-CHARG VTRNMS VPOSMS VTRNSS VPOSSS INTO <FS_HU>-VBARCODE.

    CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
      EXPORTING
        INPUT          = <FS_HU>-VBARCODE
      IMPORTING
        OUTPUT         = <FS_HU>-VBARCODE
      EXCEPTIONS
        INVALID_FORMAT = 1
        OTHERS         = 2.

    IF SY-SUBRC = 0.

    ENDIF.

  ENDFORM.                    "GET_BARCODE


*&---------------------------------------------------------------------*
*&      Form  GET_SCHLINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_SCHLINE.
    DATA: BEGIN OF IT_SCHLINE,
          VBELN LIKE VBEP-VBELN,
          POSNR LIKE VBEP-POSNR,
          ETENR LIKE VBEP-ETENR,
          EDATU LIKE VBEP-EDATU,
          WMENG LIKE VBEP-WMENG,
          VRKME LIKE VBAP-VRKME,
          CUOBJ LIKE VBAP-CUOBJ,
          ZROLL TYPE P,
          END OF IT_SCHLINE.

    DATA: IT_VBEP LIKE IT_SCHLINE OCCURS 0 WITH HEADER LINE,
          IT_CHAR LIKE CONF_OUT OCCURS 0 WITH HEADER LINE.

    DATA: ZCONV TYPE ATWTB,
          ZSATUAN(5) TYPE C,
          ZTOTALM2(25) TYPE C,
          ZORDERQTY(25) TYPE C,
          ZWEIGHTSO(25) TYPE C,
          VCOUNT TYPE P.

    CLEAR: IT_VBEP.
    REFRESH: IT_VBEP.

    IF IT_HU[] IS INITIAL.
      EXIT.
    ENDIF.

    SELECT VBEP~VBELN VBEP~POSNR VBEP~ETENR VBEP~EDATU VBEP~WMENG VBAP~VRKME VBAP~CUOBJ
      INTO CORRESPONDING FIELDS OF TABLE IT_VBEP
      FROM VBEP JOIN VBAP ON VBEP~VBELN = VBAP~VBELN AND VBEP~POSNR = VBAP~POSNR
      FOR ALL ENTRIES IN IT_HU
      WHERE VBEP~VBELN = IT_HU-VBELV AND VBEP~POSNR = IT_HU-POSNV AND VBEP~WMENG <> 0.

    SORT IT_VBEP BY VBELN POSNR ETENR ASCENDING.
    SORT IT_HU BY WADAT_IST VBELN ZPOSNR CHARG  ASCENDING.

    LOOP AT IT_VBEP.
      CLEAR: IT_CHAR, ZCONV, ZSATUAN, ZTOTALM2, ZORDERQTY, ZWEIGHTSO, IT_HU.
      REFRESH: IT_CHAR.

      CALL FUNCTION 'VC_I_GET_CONFIGURATION'
        EXPORTING
          INSTANCE            = IT_VBEP-CUOBJ
        TABLES
          CONFIGURATION       = IT_CHAR
        EXCEPTIONS
          INSTANCE_NOT_FOUND  = 1
          INTERNAL_ERROR      = 2
          NO_CLASS_ALLOCATION = 3
          INSTANCE_NOT_VALID  = 4
          OTHERS              = 5.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
      SPLIT IT_CHAR-ATWTB AT SPACE INTO ZCONV ZSATUAN.
      REPLACE ALL OCCURRENCES OF ',' IN ZCONV WITH SPACE.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZTOTALM2'.
      ZTOTALM2 = IT_CHAR-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN ZTOTALM2 WITH ' '.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZORDERQTY'.
      ZORDERQTY = IT_CHAR-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN ZORDERQTY WITH ' '.

      READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWEIGTHTOTAL'.
      ZWEIGHTSO = IT_CHAR-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN ZWEIGHTSO WITH ' '.

      IF IT_VBEP-VRKME EQ 'KG'.
        IT_VBEP-ZROLL = IT_VBEP-WMENG / ZCONV. "KONVERSI KE ROLL
      ELSEIF IT_VBEP-VRKME EQ 'M2'.
        IT_VBEP-ZROLL = ( IT_VBEP-WMENG / ZTOTALM2 ) * ZWEIGHTSO.
      ELSEIF IT_VBEP-VRKME EQ 'ROL'.
        IT_VBEP-ZROLL = IT_VBEP-WMENG.
      ELSEIF IT_VBEP-VRKME EQ 'LB'.
        IT_VBEP-ZROLL = IT_VBEP-WMENG / ZORDERQTY.
      ELSEIF IT_VBEP-VRKME EQ 'PAK'.
        IT_VBEP-ZROLL = ZWEIGHTSO.
      ENDIF.

      VCOUNT = 1.
      LOOP AT IT_HU WHERE VBELV = IT_VBEP-VBELN AND POSNV = IT_VBEP-POSNR AND EDATU IS INITIAL.
        IF IT_HU-WADAT_IST IS NOT INITIAL.
          IF VCOUNT LE IT_VBEP-ZROLL.
            IT_HU-EDATU = IT_VBEP-EDATU.
            PERFORM OUTPUT USING IT_HU-VBELV.
            PERFORM OUTPUT USING IT_HU-POSNV.
            MODIFY IT_HU TRANSPORTING VBELV POSNV EDATU WHERE CHARG EQ IT_HU-CHARG.
            VCOUNT = VCOUNT + 1.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT IT_HU WHERE WADAT_IST IS INITIAL.
      PERFORM OUTPUT USING IT_HU-VBELV.
      PERFORM OUTPUT USING IT_HU-POSNV.
      MODIFY IT_HU TRANSPORTING VBELV POSNV WHERE CHARG EQ IT_HU-CHARG.
    ENDLOOP.

  ENDFORM.                    "GET_SCHLINE


*&---------------------------------------------------------------------*
*&      Form  get_actual_weight
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM GET_ACTUAL_WEIGHT.
    DATA: V_ATINN LIKE CABN-ATINN,
          STOUCH3 LIKE AUSP-ATWRT,
          V_CHAR1(20), V_CHAR2(20), V_CHAR3(20), V_NUM1 TYPE P.

    SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZSPECIALTOUCH-3'.
    LOOP AT IT_HU.
      SELECT SINGLE A~ATWRT INTO STOUCH3
        FROM AUSP AS A JOIN MCH1 AS B ON A~OBJEK = B~CUOBJ_BM
         WHERE B~CHARG = IT_HU-CHARG AND A~ATINN = '0000000850'.
      IF SY-SUBRC = 0.
        SPLIT STOUCH3 AT '-' INTO V_CHAR1 V_CHAR2 V_CHAR3.
        IF V_CHAR1 CO '0123456789. '.
          IT_HU-ALENGTH = V_CHAR1.
        ELSE.
          IT_HU-ALENGTH = 0.
        ENDIF.

        IF V_CHAR2 CO '0123456789. '.
          IT_HU-AWEIGHT = V_CHAR2.
        ELSE.
          IT_HU-AWEIGHT = 0.
        ENDIF.

        MODIFY IT_HU.
      ENDIF.
    ENDLOOP.
  ENDFORM.                    "get_actual_weight
*&---------------------------------------------------------------------*
*&      Form  INPUT_FORMAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_SONUM  text
*      <--P_V_SONUM  text
*----------------------------------------------------------------------*
  FORM INPUT_FORMAT  USING    P_VARIN
                     CHANGING P_VAROUT.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = P_VARIN
      IMPORTING
        OUTPUT = P_VAROUT.

  ENDFORM.                    " INPUT_FORMAT