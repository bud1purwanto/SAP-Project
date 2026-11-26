*&---------------------------------------------------------------------*
*&  Include           ZSDF_FAKTUR_PAJAK_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_RETRIEVAL .

  REFRESH : ITDATA.

  "- JIKA FAKTUR PAJAK STANDARD
  IF P_FSTD = 'X'.

    SELECT
      VBRK~VKORG AS VKORG
      VBRK~VBELN AS VBELN
      VBRK~FKDAT AS FKDAT
      VBRK~FKART AS FKART
      VBRK~FKSTO AS FKSTO
      VBRK~BUKRS AS BUKRS
      VBRK~WAERK AS WAERK
      VBRK~XBLNR AS XBLNR
      VBRP~VGBEL AS VGBEL
      VBRP~POSNR AS POSNR
      VBRP~AUBEL AS AUBEL
      VBRP~NETWR AS NETWR
      VBRP~FKIMG AS FKIMG
      VBRP~VRKME AS VRKME
      VBRP~VKBUR AS VKBUR
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VBRK
      JOIN VBRP ON VBRK~VBELN = VBRP~VBELN
      WHERE VBRK~FKART IN ('ZDIN', 'ZDSF', 'ZDSN', 'ZDSV', 'ZDSI') "Add by Fany at 15-May-2025 for Laminator Subcont Project
      AND VBRK~VKORG IN SO_VKORG
      AND VBRK~VBELN IN SO_VBELN
      AND VBRK~FKDAT IN SO_FKDAT
      AND VBRK~FKSTO IN P_FKSTO.

    "- JIKA NOTA RETUR
  ELSEIF P_NTRT = 'X'.

    SELECT
      VBRK~VKORG AS VKORG
      VBRK~VBELN AS VBELN
      VBRK~FKDAT AS FKDAT
      VBRK~FKART AS FKART
      VBRK~FKSTO AS FKSTO
      VBRK~BUKRS AS BUKRS
      VBRK~WAERK AS WAERK
      VBRK~XBLNR AS XBLNR
      VBRP~VGBEL AS VGBEL
      VBRP~POSNR AS POSNR
      VBRP~AUBEL AS AUBEL
      VBRP~NETWR AS NETWR
      VBRP~FKIMG AS FKIMG
      VBRP~VRKME AS VRKME
      VBRP~VKBUR AS VKBUR
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VBRK
      JOIN VBRP ON VBRK~VBELN = VBRP~VBELN
      WHERE VBRK~FKART IN ('ZDRE' , 'ZDG2')
      AND VBRK~VTWEG IN ('01' , '03') "add dist.channel 03"
      AND VBRK~VKORG IN SO_VKORG
      AND VBRK~VBELN IN SO_VBELN
      AND VBRK~FKDAT IN SO_FKDAT
      AND VBRK~FKSTO IN P_FKSTO.

    "- NOTA RETUR EXPORT
  ELSEIF P_NTRE = 'X'.

    SELECT
      VBRK~VKORG AS VKORG
      VBRK~VBELN AS VBELN
      VBRK~FKDAT AS FKDAT
      VBRK~FKART AS FKART
      VBRK~FKSTO AS FKSTO
      VBRK~BUKRS AS BUKRS
      VBRK~WAERK AS WAERK
*      VBRK~XBLNR AS XBLNR
*      VBRP~VGBEL AS VGBEL
      VBRP~POSNR AS POSNR
*      VBRP~AUBEL AS AUBEL
      VBRP~NETWR AS NETWR
      VBRP~FKIMG AS FKIMG
      VBRP~VRKME AS VRKME
      VBRP~VKBUR AS VKBUR
      INTO CORRESPONDING FIELDS OF TABLE ITDATA
      FROM VBRK
      JOIN VBRP ON VBRK~VBELN = VBRP~VBELN
      WHERE VBRK~FKART IN ('ZERE' , 'ZEG2')
        AND VBRK~VTWEG = '02'
        AND VBRK~VKORG IN SO_VKORG
        AND VBRK~VBELN IN SO_VBELN
        AND VBRK~FKDAT IN SO_FKDAT
        AND VBRK~FKSTO IN P_FKSTO.

  ENDIF.

  "Add For New Company
  READ TABLE ITDATA INDEX 1 INTO WA_DATA.
  IF SY-SUBRC = 0.
    IF WA_DATA-BUKRS = '9999'.
      V_TEXTCOMPANY = 'PT. Trias Sentosa, Tbk.'.
    ELSEIF WA_DATA-BUKRS = '9701'.
      V_TEXTCOMPANY = 'PT. Trias Toyobo Astria'.
    ELSEIF WA_DATA-BUKRS = '9800'.
      V_TEXTCOMPANY = 'PT. Unggul Niaga Sentosa'.
    ELSEIF WA_DATA-BUKRS = '6500' .
      V_TEXTCOMPANY = 'PT. Toyobo Trias Ecosyar'.
    ENDIF.
  ENDIF.

  LOOP AT ITDATA.
    IF ITDATA-FKART EQ 'ZDSF' OR ITDATA-FKART EQ 'ZDSN'.

    ELSE.
      SELECT SINGLE VBAK~BSTNK
        INTO ITDATA-BSTNK
        FROM VBAK
        INNER JOIN VBRP ON VBRP~AUBEL = VBAK~VBELN
        WHERE VBRP~VBELN = ITDATA-VBELN
          AND VBRP~POSNR = ITDATA-POSNR.
    ENDIF.

    "- Cancel
    IF ITDATA-FKSTO EQ 'X'.
      SELECT SINGLE VBRK~VBELN
        INTO ITDATA-SFAKN
        FROM VBRK
        WHERE VBRK~SFAKN = ITDATA-VBELN.
    ENDIF.

    "- Nama, Alamat
    SELECT SINGLE
      ADRC~NAME1
      ADRC~STREET
      ADRC~POST_CODE1
      ADRC~TEL_NUMBER
      ADRC~FAX_NUMBER
      INTO (ITDATA-NAME1, ITDATA-STREET, ITDATA-POST_CODE1, ITDATA-TEL_NUMBER, ITDATA-FAX_NUMBER)
      FROM ADRC
      INNER JOIN TVKO ON TVKO~ADRNR = ADRC~ADDRNUMBER
      INNER JOIN VBRK ON TVKO~VKORG = VBRK~VKORG
      WHERE VBRK~VBELN = ITDATA-VBELN.

    "- NPWP
    SELECT SINGLE T001Z~PAVAL
      INTO ITDATA-PAVAL
      FROM T001Z
      WHERE T001Z~BUKRS = ITDATA-BUKRS
        AND T001Z~PARTY = 'IDNPWP'.

    "- Tanggal Pengukuhan
    SELECT SINGLE T001Z~PAVAL
      INTO ITDATA-PAVAL2
      FROM T001Z
      WHERE T001Z~BUKRS = ITDATA-BUKRS
        AND T001Z~PARTY = 'IDTXRD'.

    "- Nama
    SELECT SINGLE T001Z~PAVAL
    INTO ITDATA-PAVAL3
    FROM T001Z
    WHERE T001Z~BUKRS = ITDATA-BUKRS
      AND T001Z~PARTY = 'IDSIGN'.

    "- Jabatan
    SELECT SINGLE T001Z~PAVAL
    INTO ITDATA-PAVAL4
    FROM T001Z
    WHERE T001Z~BUKRS = ITDATA-BUKRS
      AND T001Z~PARTY = 'SAPI01'.

    "- Tempat
    SELECT SINGLE T001Z~PAVAL
    INTO ITDATA-PAVAL5
    FROM T001Z
    WHERE T001Z~BUKRS = ITDATA-BUKRS
      AND T001Z~PARTY = 'SAPF08'.

    "- Alamat Penerima Pajak
    SELECT SINGLE
      ADRC~NAME1
      ADRC~NAME2
      ADRC~NAME3
      ADRC~NAME4
      ADRC~STREET
      ADRC~CITY1 AS ORT01
      ADRC~STR_SUPPL1
      ADRC~STR_SUPPL2
      ADRC~STR_SUPPL3
      ADRC~COUNTRY
      "ADRC~POST_CODE1
      INTO (ITDATA-ZNAME1, ITDATA-ZNAME2, ITDATA-ZNAME3, ITDATA-ZNAME4, ITDATA-ZSTREET, ITDATA-ORT01, ITDATA-STR_SUPPL1,
        ITDATA-STR_SUPPL2, ITDATA-STR_SUPPL3, ITDATA-COUNTRY)
      FROM ADRC
      INNER JOIN VBPA ON VBPA~ADRNR = ADRC~ADDRNUMBER
*      INNER JOIN VBRK ON VBRK~KUNRG = KNA1~KUNNR
      WHERE VBPA~VBELN = ITDATA-VBELN
        AND VBPA~PARVW EQ 'RE'.

*- address ship to
    PERFORM IS_SHIP.

    "- Sold to Party
    CLEAR : V_KUNAG.
    SELECT SINGLE VBRK~KUNAG
      INTO V_KUNAG
      FROM VBRK
      WHERE VBRK~VBELN = ITDATA-VBELN.

    "- Bill to Party
    CLEAR: V_BILL.
    SELECT SINGLE VBPA~KUNNR
      INTO V_BILL
      FROM VBPA
      WHERE VBPA~VBELN = ITDATA-VBELN AND
        VBPA~PARVW = 'RE'.

    "- Account group
    SELECT SINGLE KNA1~KTOKD KNA1~STCEG KNA1~PSTLZ
      INTO (ITDATA-KTOKD, ITDATA-STCEG, ITDATA-POST_CODE1)
      FROM KNA1
      WHERE KNA1~KUNNR = V_KUNAG.

    V_POST_CODE1 = ITDATA-POST_CODE1.

    "- NPWP
    SELECT SINGLE KNA1~STCEG
      INTO (ITDATA-STCEG)
      FROM KNA1
      WHERE KNA1~KUNNR = V_BILL.

    IF ITDATA-KTOKD EQ 'ZOTC'.
      CLEAR : ITDATA-STCEG.
      SELECT SINGLE VBPA~STCEG
      INTO ITDATA-STCEG
      FROM VBPA
      WHERE VBPA~VBELN = ITDATA-VBELN
        AND VBPA~PARVW EQ 'WE'.
    ENDIF.


    "- Country
    SELECT SINGLE T005T~LANDX50
      INTO ITDATA-LANDX50
      FROM T005T
      WHERE T005T~LAND1 = ITDATA-COUNTRY
        AND T005T~SPRAS EQ 'E'.

    "- edit for ref. nota retur export
    IF P_NTRE = 'X' OR
       P_NTRT = 'X'.
      "- Get SO Reference
      CLEAR : ZVBELV, V_AUART.
      SELECT SINGLE VBFA~VBELV FROM VBFA
        INTO ZVBELV
        WHERE VBFA~VBELN = ITDATA-VBELN
        AND VBFA~VBTYP_V IN ('K','H').

      "- Get SO Reference Type
      IF SY-SUBRC = 0.
        SELECT SINGLE VBAK~AUART
          FROM VBAK
          INTO V_AUART
          WHERE VBAK~VBELN = ZVBELV.
        IF ( V_AUART = 'ZDCD') OR
           ( V_AUART = 'ZDCM') OR
           ( V_AUART = 'ZECD') OR
           ( V_AUART = 'ZECM').
          ITDATA-VGBEL = ''.

        ELSEIF ( V_AUART = 'ZDRC') OR
               ( V_AUART = 'ZERC').

          SELECT SINGLE VBFA~VBELN
            FROM VBFA
            INTO ITDATA-VGBEL
            WHERE VBFA~VBELV =  ZVBELV
            AND VBFA~VBTYP_N = 'T' .
        ENDIF.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = ITDATA-POSNR
      IMPORTING
        OUTPUT = ITDATA-POSNR.


    "- Ref Invoice
    IF ITDATA-FKART EQ 'ZEG2'.
      V_VBELN = ITDATA-VBELN.
      PERFORM READ_TEXT USING 'Z135' 'VBBK' V_VBELN. "- IOC Number -> EXPORT CLAIM
      READ TABLE IT_LINE INTO WA_LINE.
      V_VBELV = WA_LINE-TDLINE.

    ELSEIF ITDATA-FKART EQ 'ZERE' OR
           ITDATA-FKART EQ 'ZDRE' OR
           ITDATA-FKART EQ 'ZDG2'.

      CLEAR : V_VBELV.
      SELECT SINGLE VBFA~VBELV
        INTO V_VBELV
        FROM VBFA
        WHERE VBFA~VBELN = ITDATA-VBELN
          AND VBFA~VBTYP_V EQ 'M'.

      IF V_VBELV EQ ''.
        CLEAR : V_VBELN.
        V_VBELN = ITDATA-VBELN.
        PERFORM READ_TEXT USING 'Z128' 'VBBK' V_VBELN. "- Reference Number by Billing
        READ TABLE IT_LINE INTO WA_LINE.
        V_VBELV = WA_LINE-TDLINE.

        IF V_VBELV EQ ''.
          CLEAR : V_VBELN.
          V_VBELN = ZVBELV.
          PERFORM READ_TEXT USING 'Z128' 'VBBK' V_VBELN. "- Reference Number by SO
          READ TABLE IT_LINE INTO WA_LINE.
          V_VBELV = WA_LINE-TDLINE.
        ENDIF.
      ENDIF.
    ENDIF.
    ITDATA-AUBEL = V_VBELV.

    CLEAR: V_BILLDATE, V_AUBEL.
    IF ITDATA-AUBEL IS NOT INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = ITDATA-AUBEL
        IMPORTING
          OUTPUT = V_AUBEL.

      SELECT SINGLE FKDAT INTO V_BILLDATE FROM VBRK WHERE VBELN EQ V_AUBEL.
    ELSE.
      V_BILLDATE = ITDATA-FKDAT.
    ENDIF.

    "2025
    IF V_BILLDATE+0(4) GE 2025 AND ( ITDATA-FKART NE 'ZERE' AND ITDATA-FKART NE 'ZEG2' ).
      SELECT SINGLE XBLNR INTO ITDATA-XBLNR
      FROM BKPF
     WHERE AWKEY EQ ITDATA-VBELN
       AND BUKRS EQ ITDATA-BUKRS.
    ENDIF.

    "- No Faktur
    CLEAR : V_TEMP1, V_TEMP2, V_TEMP3, V_TEMP4, V_TEMP5, V_TEMP6, V_XBLNR, ZVBELN.
    IF ITDATA-FKART EQ 'ZDG2' OR
       ITDATA-FKART EQ 'ZDRE'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELV
        IMPORTING
          OUTPUT = ZVBELN.

      SELECT SINGLE VBRK~XBLNR
        INTO V_XBLNR
        FROM VBRK
        WHERE VBRK~VBELN = ZVBELN.

      "2025 Faktur Baru
      IF V_BILLDATE+0(4) GE 2025 AND ( ITDATA-FKART NE 'ZERE' AND ITDATA-FKART NE 'ZEG2').
        SELECT SINGLE XBLNR INTO V_XBLNR
          FROM BKPF
         WHERE AWKEY EQ ZVBELN
           AND BUKRS EQ ITDATA-BUKRS.
      ENDIF.

      IF V_XBLNR NE '' AND V_BILLDATE+0(4) LT 2025.
        V_TEMP1 = V_XBLNR(3).
        V_TEMP2 = V_XBLNR+3(3).
        V_TEMP3 = V_XBLNR+6(2).
        V_TEMP4 = V_XBLNR+8(8).

        CONCATENATE V_TEMP1 '.' V_TEMP2 '-' V_TEMP3 '.' V_TEMP4  INTO ITDATA-XBLNR.
        CONDENSE ITDATA-XBLNR NO-GAPS.
      ELSEIF V_XBLNR NE '' AND V_BILLDATE+0(4) GE 2025.
        ITDATA-XBLNR = '0' && V_XBLNR.
      ELSE.
        ITDATA-XBLNR = ''.
      ENDIF.
    ELSEIF ITDATA-FKART EQ 'ZDIN' OR
           ITDATA-FKART EQ 'ZDSF' OR
           ITDATA-FKART EQ 'ZDSN'.

      "Dibawah 2025 Faktur Lama
      IF ITDATA-XBLNR NE '' AND V_BILLDATE+0(4) LT 2025.
        V_TEMP1 = ITDATA-XBLNR(3).
        V_TEMP2 = ITDATA-XBLNR+3(3).
        V_TEMP3 = ITDATA-XBLNR+6(2).
        V_TEMP4 = ITDATA-XBLNR+8(8).

        CONCATENATE V_TEMP1 '.' V_TEMP2 '-' V_TEMP3 '.' V_TEMP4  INTO ITDATA-XBLNR.
        CONDENSE ITDATA-XBLNR NO-GAPS.
      ELSEIF ITDATA-XBLNR NE '' AND V_BILLDATE+0(4) GE 2025.
        ITDATA-XBLNR = '0' && ITDATA-XBLNR.
      ENDIF.
    ELSE.
      IF ITDATA-XBLNR NE '' AND V_BILLDATE+0(4) GE 2025.
        ITDATA-XBLNR = '0' && ITDATA-XBLNR.
      ENDIF.
    ENDIF.

    "- Number of Print
    CLEAR : ZCOUNTER.
    SELECT SINGLE ZNAST~COUNTER
      INTO ZCOUNTER
      FROM ZNAST
      WHERE ZNAST~OBJKY2 = ITDATA-VBELN.

    ITDATA-PCOUNT = ZCOUNTER.

    ITDATA-ZPOSNR = ITDATA-POSNR.

    "- end of editing
    MODIFY ITDATA.
  ENDLOOP.

  DESCRIBE TABLE ITDATA LINES V_LINE.
ENDFORM.                    " DATA_RETRIEVAL




*&---------------------------------------------------------------------*
*&      Form  HEADER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HEADER_DATA .

  DATA: VL.
  VL = SY-VLINE.
*  WRITE : 'PT. TRIAS SENTOSA Tbk.'.
  WRITE : V_TEXTCOMPANY.
  "edit
  IF P_NTRE = 'X'.
    WRITE : / 'List of Nota Retur Export', 100 'Page : ', (2) SY-PAGNO.
  ELSEIF P_NTRT = 'X'.
    WRITE : / 'List of Nota Retur', 100 'Page : ', (2) SY-PAGNO.
  ELSE.
    WRITE : / 'List of Faktur Pajak Standar', 100 'Page : ', (2) SY-PAGNO.
  ENDIF.

  SKIP.
  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE : / SY-ULINE(200).
  WRITE : / VL NO-GAP, '', 'Bill. Doc   '  NO-GAP,
            VL NO-GAP, 'Item ' NO-GAP,
            VL NO-GAP, 'Bill. Date ' NO-GAP,
            VL NO-GAP, 'Type '   NO-GAP,
            VL NO-GAP, 'Tax No.               ' NO-GAP,
            VL NO-GAP, 'Tax Date   ' NO-GAP,
            VL NO-GAP, 'Print '  NO-GAP,
            VL NO-GAP, '(X)' NO-GAP,
            VL NO-GAP, 'Curr. ' NO-GAP,
            VL NO-GAP, 'DO No.    ' NO-GAP,
            VL NO-GAP, 'Ref.No.    ' NO-GAP,
            VL NO-GAP, 'PO No.               ' NO-GAP,
            VL NO-GAP, 'Cancel Billing' NO-GAP,
            VL NO-GAP, 'Customer City  ' NO-GAP,
            VL NO-GAP, 'Customer Name            ' NO-GAP,
            VL NO-GAP, 'SOFC' NO-GAP,
            VL NO-GAP.
  WRITE : / SY-ULINE(200).
  FORMAT RESET INTENSIFIED ON.

ENDFORM.                    " HEADER_DATA


*&---------------------------------------------------------------------*
*&      Form  DATA_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_DISPLAY USING VALUE(CHK).
  IF ITDATA[] IS INITIAL.
    MESSAGE 'No data selected.' TYPE 'I'.
    EXIT.
  ENDIF.

  SORT ITDATA ASCENDING BY VBELN ZPOSNR.
  SET PF-STATUS 'PFSTAT'.
  DATA : FLG, I TYPE I.
  VL = SY-VLINE.

  LOOP AT ITDATA INTO WA_DATA.
    MARK01  = CHK.
    AT NEW VBELN.
      FLG = 'X'.
    ENDAT.

    IF FLG EQ 'X'.
      WRITE : / VL NO-GAP, MARK01 AS CHECKBOX COLOR COL_NEGATIVE.
      WRITE : 6 WA_DATA-VBELN NO-GAP,
              VL NO-GAP, (5)  WA_DATA-POSNR NO-GAP,
              VL NO-GAP, (11) WA_DATA-FKDAT NO-GAP,
              VL NO-GAP, (5)  WA_DATA-FKART NO-GAP,
              VL NO-GAP, (22) WA_DATA-XBLNR NO-GAP,
              VL NO-GAP, (11) WA_DATA-FKDAT NO-GAP,
              VL NO-GAP, (6)  WA_DATA-PCOUNT NO-GAP,
              VL NO-GAP, (3)  WA_DATA-FKSTO NO-GAP CENTERED,
              VL NO-GAP, (6)  WA_DATA-WAERK NO-GAP,
              VL NO-GAP, (10) WA_DATA-VGBEL NO-GAP,
              VL NO-GAP, (11) WA_DATA-AUBEL NO-GAP,
              VL NO-GAP, (21) WA_DATA-BSTNK NO-GAP,
              VL NO-GAP, (14) WA_DATA-SFAKN NO-GAP,
              VL NO-GAP, (15) WA_DATA-ORT01 NO-GAP,
              VL NO-GAP, (25) WA_DATA-ZNAME1 NO-GAP,
              VL NO-GAP, (4) WA_DATA-VKBUR NO-GAP,
              VL NO-GAP.
      CLEAR : FLG.
    ELSE.
      WRITE : / VL NO-GAP,
              16 VL NO-GAP, (5)  WA_DATA-POSNR NO-GAP,
              VL NO-GAP, (11) WA_DATA-FKDAT NO-GAP,
              VL NO-GAP, (5)  WA_DATA-FKART NO-GAP,
              VL NO-GAP, (22) WA_DATA-XBLNR NO-GAP,
              VL NO-GAP, (11) WA_DATA-FKDAT NO-GAP,
              VL NO-GAP, (6)  WA_DATA-PCOUNT NO-GAP,
              VL NO-GAP, (3)  WA_DATA-FKSTO NO-GAP CENTERED,
              VL NO-GAP, (6)  WA_DATA-WAERK NO-GAP,
              VL NO-GAP, (10) WA_DATA-VGBEL NO-GAP,
              VL NO-GAP, (11) WA_DATA-AUBEL NO-GAP,
              VL NO-GAP, (21) WA_DATA-BSTNK NO-GAP,
              (15) VL NO-GAP,
              VL NO-GAP, (15) WA_DATA-ORT01 NO-GAP,
              VL NO-GAP, (25) WA_DATA-ZNAME1 NO-GAP,
              VL NO-GAP, (4) WA_DATA-VKBUR NO-GAP,
              VL NO-GAP.
    ENDIF.

  ENDLOOP.
  WRITE : / SY-ULINE(200).
  SET LEFT SCROLL-BOUNDARY COLUMN 16.

ENDFORM.                    " DATA_DISPLAY


*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UCOMM  text
*      -->P_RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND  USING    P_SY_UCOMM
                            P_RS_SELFIELD.

  CASE P_SY_UCOMM.
    WHEN 'SORTI'.
*      LEAVE TO TRANSACTION 'ZSD003'.
      LEAVE SCREEN.
    WHEN 'PRNT'.
      IF P_FSTD = 'X'.   "Print out with ZSD010
        MESSAGE 'No print out for Faktur Pajak Standar....!' TYPE 'I'.
      ELSE.
        PERFORM PRINT.
      ENDIF.
    WHEN 'PRV'.
      IF P_FSTD = 'X'.   "Print out with ZSD010
        MESSAGE 'No print out for Faktur Pajak Standar....!' TYPE 'I'.
      ELSE.
        PERFORM PREVIEW.
      ENDIF.
    WHEN 'SELECT'.
      MARK01 = 'X'.
      PERFORM MODIF_MARK USING MARK01.

    WHEN 'DESELECT'.
      MARK01 = ''.
      PERFORM MODIF_MARK USING MARK01.

    WHEN 'REFRESH'.
      PERFORM DATA_RETRIEVAL.
      PERFORM DATA_DISPLAY USING ''.

    WHEN 'DOCFLOW'.
      PERFORM GET_SELECTED.
      PERFORM DOC_FLOW.

  ENDCASE.

ENDFORM.                    " USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_SELECTED .
  CLEAR   : ITDATATEMP.
  REFRESH : ITDATATEMP.
  DESCRIBE LIST NUMBER OF LINES LN.

  COUNT = 0.
  DO LN TIMES.
    CLEAR MARK01.
    CLEAR WA_DATA-VBELN.
    READ LINE SY-INDEX FIELD VALUE MARK01.
    READ LINE SY-INDEX FIELD VALUE WA_DATA-VBELN.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.

    IF MARK01 = 'X'.
      ITDATATEMP-VBELN = WA_DATA-VBELN.
      COLLECT ITDATATEMP.
      COUNT = COUNT + 1.
    ENDIF.
  ENDDO.
ENDFORM.                    " GET_SELECTED


*&---------------------------------------------------------------------*
*&      Form  DOC_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOC_FLOW .
  LOOP AT ITDATATEMP INTO WADATATEMP.
    SET PARAMETER ID 'VF' FIELD WADATATEMP-VBELN.
    CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
  ENDLOOP.

ENDFORM.                    " DOC_FLOW


*&---------------------------------------------------------------------*
*&      Form  PREVIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREVIEW .
  PERFORM GET_SELECTED.
  LOOP AT ITDATATEMP.
    PERFORM DATA_PRINT.
    PERFORM DEFINE_FORM.
    PERFORM CALL_FORM USING V_FORMNAME.

    IF SY-SUBRC <> 0.

    ELSE.
      IF ZVBELN IS INITIAL.
        CLEAR : CONTROL_PARAMETERS, OUTPUT_OPTIONS, V_FKDAT.
        CONCATENATE V_TEMP3 V_TEMP2 V_TEMP1 INTO V_FKDAT SEPARATED BY '.'.
      ENDIF.

      PERFORM GET_TOTAL.

      CONTROL_PARAMETERS-NO_DIALOG = 'X'.
      CONTROL_PARAMETERS-PREVIEW   = 'X'.
      OUTPUT_OPTIONS-TDNOPRINT     = 'X'.
      CALL FUNCTION V_FUNCNAME
        EXPORTING
          CONTROL_PARAMETERS = CONTROL_PARAMETERS
          OUTPUT_OPTIONS     = OUTPUT_OPTIONS
          P_KODEFAKTUR       = V_KODEFAKTUR
          P_BELNR            = V_BELNR
          P_VBELV            = V_VBELV
          P_FKDAT            = V_FKDAT
          P_NAMAPKP          = V_NAMAPKP
          P_ALAMATPKP        = V_ALAMATPKP
          P_NPWPPKP          = V_NPWPPKP
          P_TPKP             = V_TPKP
          P_NAMAPBKP         = V_NAMAPBKP
          P_ALAMATPBKP       = V_ALAMATPBKP
          P_KOTAPBKP         = V_KOTAPBKP
          P_NPWPPBKP         = V_NPWPPBKP
          P_HJUSD            = V_HJUSD
          P_HJRP             = V_HJRP
          P_DUMUSD           = V_DUMUSD
          P_DUMRP            = V_DUMRP
          P_DPPUSD           = V_DPPUSD
          P_DPPRP            = V_DPPRP
          P_PERSEN           = V_PERSEN
          P_PPNUSD           = V_PPNUSD
          P_PPNRP            = V_PPNRP
          P_KOTANTGL         = V_KOTANTGL
          P_NAMA             = V_NAMA
          P_JABATAN          = V_JABATAN
          P_KURSUSD          = V_KURSUSD
          P_WAERS            = V_WAERS
          ZWAERS             = ZWAERS
          P_CURR             = V_CURR
          P_REMARKS          = V_REMARKS
          P_COUNTRY          = V_COUNTRY
          P_TEL              = V_TEL
          P_FAX              = V_FAX
          P_TOTAL_PPNUSD     = V_TOTAL_PPNUSD
          P_TOTAL_PPNRP      = V_TOTAL_PPNRP
          P_KMKNO            = V_KMKNO
          P_KMKDATE          = V_KMKDATE
          P_SIGN_JABATAN     = V_SIGN_JABATAN
          P_SIGN_NAMA        = V_SIGN_NAMA
          P_POSTCODE         = V_POST_CODE1
          P_TEXTCOMPANY      = V_TEXTCOMPANY  "Add New Company
        TABLES
          ITPRINT            = ITPRINT
        EXCEPTIONS
          FORMATTING_ERROR   = 1
          INTERNAL_ERROR     = 2
          SEND_ERROR         = 3
          USER_CANCELED      = 4
          OTHERS             = 5.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " PREVIEW


*&---------------------------------------------------------------------*
*&      Form  GET_CONF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CONF .
  CLEAR : V_CUOBJ, V_TYPE, V_THICK, V_WIDTH, V_LENGTH.
  SELECT SINGLE VBRP~CUOBJ
    INTO V_CUOBJ
    FROM VBRP
    WHERE VBRP~VBELN = ITDATA-VBELN
      AND VBRP~POSNR = ITDATA-POSNR.

  IF V_CUOBJ NE '000000000000000000'.
    REFRESH : ITCONF.
    CALL FUNCTION 'VC_I_GET_CONFIGURATION'
      EXPORTING
        INSTANCE            = V_CUOBJ
      TABLES
        CONFIGURATION       = ITCONF
      EXCEPTIONS
        INSTANCE_NOT_FOUND  = 1
        INTERNAL_ERROR      = 2
        NO_CLASS_ALLOCATION = 3
        INSTANCE_NOT_VALID  = 4
        OTHERS              = 5.
  ENDIF.

  "- Thickness
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZTHICKNESS'.
  IF SY-SUBRC = 0.
    V_THICK = ITCONF-ATWTB.
  ENDIF.

  "- Type
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZALIAS'.
  IF SY-SUBRC = 0.
    V_TYPE = ITCONF-ATWTB.
  ELSE.
    READ TABLE ITCONF WITH KEY ATNAM = 'ZZTYPE'.
    IF SY-SUBRC = 0.
*        V_TYPE = ITCONF-ATWTB.
      CONCATENATE ITCONF-ATWTB '-' V_THICK INTO V_TYPE.
    ENDIF.

  ENDIF.

  "- Width
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZWIDTH'.
  IF SY-SUBRC = 0.
    V_WIDTH = ITCONF-ATWTB.
  ENDIF.

  "- Length
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC = 0.
    V_LENGTH = ITCONF-ATWTB.
  ENDIF.

*- add by ALF: get KDMAT / PO NUmber
  PERFORM GET_PONO.

  IF V_TYPE EQ '' OR
     V_THICK EQ '' OR
     V_LENGTH EQ '' OR
     V_WIDTH EQ ''.

*- ALF: get material non batch
*- add by ALF: get KDMAT / PO NUmber
*    PERFORM GET_PONO.
    IF ITDATA-BUKRS NE '9800'.
      SELECT SINGLE MATNR INTO V_TYPE FROM VBRP WHERE VBELN = ITDATA-VBELN AND POSNR = ITDATA-POSNR.   "by ALF get mat non batch
      CONCATENATE V_TYPE V_KDMAT INTO V_KDMAT SEPARATED BY SPACE.
      CLEAR V_TYPE.
    ENDIF.

    SELECT SINGLE VBRP~ARKTX
       INTO ITDATA-ZITEM
       FROM VBRP
       WHERE VBRP~VBELN = ITDATA-VBELN
         AND VBRP~POSNR = ITDATA-POSNR.

    WRITE ITDATA-FKIMG TO ITPRINT-BSTNK DECIMALS 2.
    CONDENSE ITPRINT-BSTNK.
    CONCATENATE ITDATA-ZITEM '(' ITPRINT-BSTNK ITDATA-VRKME ')' INTO ITDATA-ZITEM SEPARATED BY SPACE.

  ELSEIF V_TYPE NE '' AND
     V_THICK NE '' AND
     V_LENGTH NE '' AND
     V_WIDTH NE ''.

    CONCATENATE V_WIDTH 'mm' INTO V_WIDTH.
    CONCATENATE V_LENGTH 'm' INTO V_LENGTH.

    READ TABLE ITCONF WITH KEY ATNAM = 'ZZALIAS'.
    IF SY-SUBRC = 0.
      CONCATENATE V_TYPE V_KDMAT INTO V_KDMAT SEPARATED BY SPACE.
      CONCATENATE V_WIDTH 'X' V_LENGTH INTO ITDATA-ZITEM SEPARATED BY SPACE.
      PERFORM ADD_CHAR.
    ELSE.
      CONCATENATE V_TYPE V_KDMAT INTO V_KDMAT SEPARATED BY SPACE.
      CONCATENATE V_WIDTH 'X' V_LENGTH INTO ITDATA-ZITEM SEPARATED BY SPACE.
      PERFORM ADD_CHAR.
    ENDIF.

    WRITE ITDATA-FKIMG TO ITPRINT-BSTNK DECIMALS 2.
    CONDENSE ITPRINT-BSTNK.
    CONCATENATE ITDATA-ZITEM '(' ITPRINT-BSTNK ITDATA-VRKME ')' INTO ITDATA-ZITEM SEPARATED BY SPACE.
  ENDIF.

ENDFORM.                    " GET_CONF



*&---------------------------------------------------------------------*
*&      Form  DATA_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DATA_PRINT .
  CLEAR   : ITPRINT, WAPRINT.
  REFRESH : ITPRINT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = ITDATATEMP-VBELN
    IMPORTING
      OUTPUT = ITDATATEMP-VBELN.

  CLEAR : V_COUNT, V_HJUSD, V_HJRP, V_CURR, V_USD, V_TOTAL_IDR, V_IDR.
  LOOP AT ITDATA WHERE VBELN = ITDATATEMP-VBELN.
    CLEAR : V_NETWR, V_NETWR2, V_NETWR3.
    ITDATATEMP-XBLNR  = ITDATA-XBLNR.
    ITDATATEMP-KURRF  = ITDATA-KURRF.
    ITDATATEMP-NAME1  = ITDATA-NAME1.
    ITDATATEMP-STREET = ITDATA-STREET.
    ITDATATEMP-POST_CODE1 = ITDATA-POST_CODE1.
    ITDATATEMP-TEL_NUMBER = ITDATA-TEL_NUMBER.
    ITDATATEMP-FAX_NUMBER = ITDATA-FAX_NUMBER.
    ITDATATEMP-CITY1  = ITDATA-CITY1.
    ITDATATEMP-PAVAL  = ITDATA-PAVAL.
    ITDATATEMP-PAVAL2 = ITDATA-PAVAL2.
    ITDATATEMP-PAVAL3 = ITDATA-PAVAL3.
    ITDATATEMP-PAVAL4 = ITDATA-PAVAL4.
    ITDATATEMP-PAVAL5 = ITDATA-PAVAL5.
    ITDATATEMP-ZNAME1 = ITDATA-ZNAME1.
    ITDATATEMP-ZNAME2 = ITDATA-ZNAME2.
    ITDATATEMP-ZNAME3 = ITDATA-ZNAME3.
    ITDATATEMP-ZNAME4 = ITDATA-ZNAME4.
    ITDATATEMP-ORT01  = ITDATA-ORT01.
    ITDATATEMP-STCEG  = ITDATA-STCEG.
    ITDATATEMP-FKDAT  = ITDATA-FKDAT.
    ITDATATEMP-ZSTREET = ITDATA-ZSTREET.
    ITDATATEMP-STR_SUPPL1 = ITDATA-STR_SUPPL1.
    ITDATATEMP-STR_SUPPL2 = ITDATA-STR_SUPPL2.
    ITDATATEMP-STR_SUPPL3 = ITDATA-STR_SUPPL3.
    ITDATATEMP-LANDX50    = ITDATA-LANDX50.

    V_POST_CODE1 = ITDATA-POST_CODE1.   "add by ALV at 07-10-2013

    V_WAERS = ITDATA-WAERK.
    CLEAR : V_TEMP1, V_TEMP2, V_TEMP3.
    V_TEMP1 = ITDATA-FKDAT(4).
    V_TEMP2 = ITDATA-FKDAT+4(2).
    V_TEMP3 = ITDATA-FKDAT+6(2).

    CONCATENATE V_TEMP3 V_TEMP2 V_TEMP1 INTO V_FKDAT SEPARATED BY '.'.

    "- Configuration
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = ITDATA-POSNR
      IMPORTING
        OUTPUT = ITDATA-POSNR.


    "- Kwantum
    CLEAR : V_FKIMG.
    IF ITDATA-VRKME EQ 'ROL'.
      V_FKIMG = ITDATA-FKIMG.
      WRITE V_FKIMG TO ITDATA-ZFKIMG.
    ELSE.
      WRITE ITDATA-FKIMG TO ITDATA-ZFKIMG.
    ENDIF.

    "- Harga Currency
    CLEAR : V_KNUMV, V_KPEIN, ZZKPEIN, ZWAERS, ZCOUNT, V_WAERS, ITDATA-KBETR.
    SELECT SINGLE VBRK~KNUMV
      INTO V_KNUMV
      FROM VBRK
      WHERE VBRK~VBELN = ITDATA-VBELN.

    IF ITDATA-FKART EQ 'ZDSF' OR
       ITDATA-FKART EQ 'ZDSN'.
      SELECT SINGLE KONV~KBETR KONV~KPEIN KONV~WAERS
      INTO (ITDATA-KBETR, V_KPEIN, ZWAERS)
      FROM KONV
      WHERE KONV~KNUMV = V_KNUMV
        AND KONV~KPOSN = ITDATA-POSNR
        AND KONV~KSCHL IN ('ZSCW', 'ZSCR')
        AND KONV~KBETR <> 0.

    ELSEIF ITDATA-FKART EQ 'ZDIN' OR
           ITDATA-FKART EQ 'ZEIN' OR
           ITDATA-FKART EQ 'ZDG2' OR
           ITDATA-FKART EQ 'ZEG2' OR
           ITDATA-FKART EQ 'ZERE' OR
           ITDATA-FKART EQ 'ZDRE' OR
           ITDATA-FKART EQ 'ZDSI'.    "Add by Fany at 15-May-2025 for Laminator Subcont Project
      SELECT SINGLE KONV~KBETR KONV~KPEIN KONV~WAERS
      INTO (ITDATA-KBETR, V_KPEIN, ZWAERS)
      FROM KONV
      WHERE KONV~KNUMV = V_KNUMV
        AND KONV~KPOSN = ITDATA-POSNR
        AND KONV~KSCHL IN ('ZD00', 'ZDD0', 'ZE00', 'ZED0', 'ZEC0')
        AND KONV~KBETR <> 0.

      IF ( V_AUART EQ 'ZECM' OR V_AUART EQ 'ZECD' ). "AND ITDATA-KBETR = 0.  "always get condition value
        SELECT SINGLE
          KONV~KWERT
          KONV~KPEIN
          KONV~WAERS
        INTO (ITDATA-KBETR, V_KPEIN, ZWAERS)
        FROM KONV
        WHERE KONV~KNUMV = V_KNUMV
          AND KONV~KPOSN = ITDATA-POSNR
          AND KONV~KSCHL IN ('ZEC0', 'ZED0').
      ENDIF.
    ENDIF.


    SELECT SINGLE VBRK~WAERK
      INTO V_WAERS
      FROM VBRK
      WHERE VBRK~VBELN = ITDATA-VBELN.

    "- Length KPEIN
    ZZKPEIN = V_KPEIN.
    CONDENSE ZZKPEIN NO-GAPS.
    ZCOUNT = STRLEN( ZZKPEIN ) - 1.

    CLEAR : ZKPEIN, ZNETWR.
    ZNETWR = ITDATA-KBETR.
    PERFORM AMOUNT USING ZWAERS ZNETWR.

    "- Price Currency
    IF V_WAERS EQ 'IDR'.
      V_IDR = V_NETWR / V_KPEIN.
      WRITE V_IDR TO ITDATA-ZKBETR.
    ELSE.
      IF ZCOUNT = 0 OR ZCOUNT = 1 OR ZCOUNT = 2.
        V_DEC2 = V_NETWR / V_KPEIN.
        WRITE V_DEC2 TO ITDATA-ZKBETR.
      ELSEIF ZCOUNT = 3.
        V_DEC3 = V_NETWR / V_KPEIN.
        WRITE V_DEC3 TO ITDATA-ZKBETR.
      ELSEIF ZCOUNT = 4.
        V_DEC4 = V_NETWR / V_KPEIN.
        WRITE V_DEC4 TO ITDATA-ZKBETR.
      ELSEIF ZCOUNT = 5.
        V_DEC5 = V_NETWR / V_KPEIN.
        WRITE V_DEC5 TO ITDATA-ZKBETR.
      ENDIF.
    ENDIF.

    ZKPEIN = V_NETWR / V_KPEIN.
    CONDENSE ITDATA-ZKBETR NO-GAPS.


    "- Total Currency
    PERFORM GET_EXCHANGE_RATE USING V_WAERS ZWAERS.
    IF V_AUART EQ 'ZECM' OR V_AUART EQ 'ZECD'.
      ITDATA-ZTOTAL = ITDATA-KBETR.
    ELSE.
      ITDATA-ZTOTAL = ZKPEIN * ITDATA-FKIMG.
    ENDIF.

    IF V_WAERS EQ 'IDR'.
      CLEAR : V_IDR.
      V_IDR = ITDATA-ZTOTAL.
      WRITE V_IDR TO ITDATA-ZZTOTAL.
    ELSE.
      ITDATA-ZTOTAL = ITDATA-ZTOTAL.
      WRITE ITDATA-ZTOTAL TO ITDATA-ZZTOTAL.
    ENDIF.
    CONDENSE ITDATA-ZZTOTAL NO-GAPS.

    "- Total USD
    IF V_WAERS EQ 'USD'.
      ITDATA-ZNETWR = ITDATA-ZZTOTAL.
    ELSEIF V_WAERS EQ 'IDR'.
      ITDATA-ZNETWR = ITDATA-ZZTOTAL.
    ELSE.
      PERFORM GET_EXCHANGE_RATE USING 'USD' V_WAERS.
      ITDATA-NETWR = ITDATA-ZTOTAL * V_EXCHR.
      WRITE ITDATA-NETWR TO ITDATA-ZNETWR.
      CONDENSE ITDATA-ZNETWR.
    ENDIF.


    "- Rupiah
    IF V_WAERS EQ 'IDR'.
      IF ITDATA-FKART NE 'ZDIN' AND
         ITDATA-FKART NE 'ZDSF' AND
         ITDATA-FKART NE 'ZDSN' AND
         ITDATA-FKART NE 'ZDSI'. " Add by Fany at 15-May-2025 for Laminator Subcont Project
        ITDATA-DMBTR  = 0.
        ITDATA-ZDMBTR = '0'.
      ELSE.
        WRITE ITDATA-ZNETWR TO ITDATA-ZDMBTR.
        ITDATA-DMBTR = ITDATA-ZTOTAL.
      ENDIF.

    ELSE.
      PERFORM GET_EXCHANGE_RATE USING 'IDR' V_WAERS.
      ITDATA-DMBTR = ITDATA-ZTOTAL * V_EXCHR.
      V_NETWR3     = ITDATA-DMBTR.
      WRITE V_NETWR3 TO ITDATA-ZDMBTR.
      CONDENSE ITDATA-ZDMBTR.
    ENDIF.

    "- Item
*    IF ITDATA-FKART EQ 'ZEG2'.
*
*      SELECT SINGLE VBRP~ARKTX
*        INTO ITDATA-ZITEM
*        FROM VBRP
*        WHERE VBRP~VBELN = ITDATA-VBELN
*          AND VBRP~POSNR = ITDATA-POSNR.
*    ELSE.
    PERFORM GET_CONF.
*    ENDIF.

    "- Kurs USD
    CLEAR : V_KURSUSD, V_NETWR4.
    V_NETWR4 = V_EXCHR.
    WRITE V_NETWR4 TO V_KURSUSD.
    CONDENSE V_KURSUSD.

    "- Total Rupiah
    IF V_WAERS EQ 'IDR'.
      IF ITDATA-FKART NE 'ZDIN' AND
         ITDATA-FKART NE 'ZDSF' AND
         ITDATA-FKART NE 'ZDSN' AND
         ITDATA-FKART NE 'ZDSI'. " Add by Fany at 15-May-2025 for Laminator Subcont Project
        V_HJRP = ''.
        V_KURSUSD = '-'.
      ELSE.
        V_HJRP = V_HJRP + ITDATA-DMBTR.
      ENDIF.
    ELSE.
      V_HJRP = V_HJRP + ITDATA-DMBTR.
    ENDIF.
    V_HJUSD = V_HJUSD + ITDATA-NETWR.

    "- Total Currency
    IF V_WAERS EQ 'IDR'.                           "- Jika Rupiah
      V_TOTAL_IDR = V_TOTAL_IDR + ITDATA-ZTOTAL.
      WRITE V_TOTAL_IDR TO V_CURR.
    ELSE.                                         "- Jika Curr Asing
      V_USD = V_USD + ITDATA-ZTOTAL.
      WRITE V_USD TO V_CURR.
    ENDIF.
    CONDENSE V_CURR.

    "- Number
    V_COUNT = V_COUNT + 1.
    ITDATA-ZNO = V_COUNT.

    MODIFY ITDATA.
    CLEAR : WAPRINT.

    WAPRINT-FKDAT   = ITDATA-FKDAT.
    WAPRINT-ZNO     = ITDATA-ZNO.
    WAPRINT-ZITEM   = ITDATA-ZITEM.
    WAPRINT-WAERK   = ITDATA-WAERK.
    WAPRINT-ZNETWR  = ITDATA-ZNETWR.
    WAPRINT-ZFKIMG  = ITDATA-ZFKIMG.
    WAPRINT-VRKME   = ITDATA-VRKME.
    WAPRINT-ZKBETR  = ITDATA-ZKBETR.
    WAPRINT-ZDMBTR  = ITDATA-ZDMBTR.
    WAPRINT-ZZTOTAL = ITDATA-ZZTOTAL.

    IF ITDATA-BUKRS = '9800'. "UNS
      ITPRINT = WAPRINT.

      CLEAR VBRP.
      SELECT SINGLE * INTO VBRP FROM VBRP WHERE VBELN = ITDATA-VBELN AND POSNR = ITDATA-POSNR.
      IF SY-SUBRC = 0.
        ITPRINT-ZITEM = VBRP-MATNR.
      ENDIF.
      APPEND ITPRINT.

      SELECT SINGLE MATKL INTO ITPRINT-ZITEM FROM MARA WHERE MATNR = ITPRINT-ZITEM.
      IF ITPRINT-ZITEM NE 'T10003'.    "Non Film
        CLEAR ITPRINT.
        ITPRINT-ZITEM = VBRP-ARKTX.
        APPEND ITPRINT.
      ENDIF.

      CLEAR ITPRINT.
      ITPRINT-ZITEM = V_KDMAT.
      WRITE ITDATA-FKIMG TO VBRP-MATWA.
      CONDENSE VBRP-MATWA.
      CONCATENATE V_KDMAT '(' VBRP-MATWA ITDATA-VRKME ')' INTO ITPRINT-ZITEM SEPARATED BY SPACE.
      APPEND ITPRINT.
      CLEAR VBRP.
    ELSE.
*- split material and description
      ITPRINT = WAPRINT.
      ITPRINT-ZITEM = V_KDMAT.
      CLEAR: V_KDMAT.
      APPEND ITPRINT.

      CLEAR ITPRINT.
      ITPRINT-ZITEM = WAPRINT-ZITEM.
      APPEND ITPRINT.
*- end of split material and description
    ENDIF.
  ENDLOOP.


  CLEAR : V_TEMP1, V_TEMP2,
          V_TEMP3, V_TEMP4,
          V_TEMP5, V_TEMP6, V_NETWR3,V_FKDATREF,V_BELNREF, IT_BILLREF[],ZNAME,TLINE[].

  "- Variable for Total
  CLEAR : V_PPNIDR.

  "- Persen PPN
  CLEAR : V_KNUMV, MWSKZ.
  SELECT SINGLE VBRK~KNUMV
    INTO V_KNUMV
    FROM VBRK
    WHERE VBRK~VBELN = ITDATATEMP-VBELN.

  SELECT SINGLE KONV~MWSK1
    INTO MWSKZ
    FROM KONV
    WHERE KONV~KNUMV = V_KNUMV
      AND KONV~KSCHL EQ 'ZPPN'.

  CASE MWSKZ+0(1).  "MWSKZ
    WHEN 'C'. "'C1' OR 'C2' OR 'C3'.
      PERFORM GET_PPN.
*      V_PERSEN = '10%'.
      V_PERSEN = V_PPN_TXT.
    WHEN OTHERS.
      V_PERSEN = ''.
  ENDCASE.


  "- Jumlah Persen Currency
  IF V_WAERS EQ 'IDR'.
    IF V_PERSEN NE ''.
*      V_PPNIDR =  ( 10 / 100 ) * V_TOTAL_IDR.
      V_PPNIDR =  ( V_PPN_PRC / 100 ) * V_TOTAL_IDR.
      WRITE V_PPNIDR TO V_PPNUSD.
      CONDENSE V_PPNUSD NO-GAPS.
    ELSE.
      V_PPNIDR = 0.
      V_PPNUSD = ''.
    ENDIF.
  ELSE.
    IF V_PERSEN NE ''.
*      V_PPNASING =  ( 10 / 100 ) * V_USD.
      V_PPNASING =  ( V_PPN_PRC / 100 ) * V_USD.
      WRITE V_PPNASING TO V_PPNUSD.
    ELSE.
      V_PPNASING = 0.
      V_PPNUSD   = ''.
    ENDIF.
  ENDIF.

  "- Total Currency + PPN
  IF V_WAERS EQ 'IDR'.
    V_IDR = V_TOTAL_IDR + V_PPNIDR.
    WRITE V_IDR TO V_TOTAL_PPNUSD.
  ELSE.
    V_USD = V_USD + V_PPNASING.
    WRITE V_USD TO V_TOTAL_PPNUSD.
  ENDIF.


  "- Jumlah Persen Rupiah
  IF V_WAERS EQ 'IDR'.
    IF ITDATA-FKART NE 'ZDIN' AND
       ITDATA-FKART NE 'ZDSF' AND
       ITDATA-FKART NE 'ZDSN' AND
       ITDATA-FKART NE 'ZDSI'.  "Add by Fany at 15-May-2025 for Laminator Subcont Project
      V_PPNRP = 0.
    ELSE.
      IF V_PERSEN NE ''.
*        V_PPNRP =  ( 10 / 100 ) * V_HJRP.
        V_PPNRP =  ( V_PPN_PRC / 100 ) * V_HJRP.
      ELSE.
        V_PPNRP = 0.
      ENDIF.
    ENDIF.

  ELSE.
    IF V_PERSEN NE ''.
*      V_PPNRP =  ( 10 / 100 ) * V_HJRP.
      V_PPNRP =  ( V_PPN_PRC / 100 ) * V_HJRP.
    ELSE.
      V_PPNRP = 0.
    ENDIF.
  ENDIF.

  V_TOTAL_PPNRP = V_HJRP + V_PPNRP.

  IF V_WAERS EQ 'IDR'.
    V_HJUSD = V_HJUSD * 100.
    WRITE V_HJUSD TO V_DPPRP.
  ENDIF.
  V_DPPUSD = V_HJUSD.

  "- KMK
  PERFORM GET_KMK.

  "- Billing Type
  CLEAR : V_FKART.
  SELECT SINGLE VBRK~FKART
    INTO V_FKART
    FROM VBRK
    WHERE VBRK~VBELN = ITDATATEMP-VBELN.

  "- Ref Invoice
  IF V_FKART EQ 'ZEG2'.
    V_VBELN = ITDATATEMP-VBELN.
    PERFORM READ_TEXT USING 'Z135' 'VBBK' V_VBELN. "- IOC Number -> EXPORT CLAIM
    READ TABLE IT_LINE INTO WA_LINE.
    V_VBELV = WA_LINE-TDLINE.

  ELSEIF V_FKART EQ 'ZERE' OR
         V_FKART EQ 'ZDRE' OR
         V_FKART EQ 'ZDG2'.

    CLEAR : V_VBELV.
    SELECT SINGLE VBFA~VBELV
      INTO V_VBELV
      FROM VBFA
      WHERE VBFA~VBELN = ITDATATEMP-VBELN
        AND VBFA~VBTYP_V EQ 'M'.

    IF V_VBELV EQ ''.
      CLEAR : V_VBELN.
      V_VBELN = ITDATATEMP-VBELN.
      PERFORM READ_TEXT USING 'Z128' 'VBBK' V_VBELN. "- Reference Number by Billing
      READ TABLE IT_LINE INTO WA_LINE.
      V_VBELV = WA_LINE-TDLINE.

      IF V_VBELV EQ ''.
        CLEAR : V_VBELN.
        V_VBELN = ZVBELV.
        PERFORM READ_TEXT USING 'Z128' 'VBBK' V_VBELN. "- Reference Number by SO
        READ TABLE IT_LINE INTO WA_LINE.
        V_VBELV = WA_LINE-TDLINE.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR : V_VBELN.
  V_VBELN = ITDATATEMP-VBELN.
  PERFORM READ_TEXT USING 'Z119' 'VBBK' V_VBELN. "- Remarks
  CLEAR: V_REMARKS.
  LOOP AT IT_LINE INTO WA_LINE.
    CONCATENATE V_REMARKS WA_LINE-TDLINE INTO V_REMARKS SEPARATED BY SPACE.
  ENDLOOP.

  CLEAR: V_BILLDATE, V_BILLDATE2, V_AUBEL.
  IF V_VBELV IS NOT INITIAL.
    IF V_FKART NE 'ZERE' AND V_FKART NE 'ZEG2'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELV
        IMPORTING
          OUTPUT = V_AUBEL.

      SELECT SINGLE FKDAT INTO V_BILLDATE FROM VBRK WHERE VBELN EQ V_AUBEL.

      V_BILLDATE2 = V_BILLDATE+6(2) && '.' && V_BILLDATE+4(2) && '.' && V_BILLDATE+0(4).
    ENDIF.
  ELSE.
    V_BILLDATE2 = V_FKDAT.
  ENDIF.

  "- No Faktur
  CLEAR : V_TEMP1, V_TEMP2, V_TEMP3, V_TEMP4, V_TEMP5, V_TEMP6, V_XBLNR, ZVBELN, V_BELNR.
  IF V_FKART EQ 'ZDG2' OR
     V_FKART EQ 'ZDRE'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = V_VBELV
      IMPORTING
        OUTPUT = ZVBELN.

    SELECT SINGLE VBRK~XBLNR
      INTO V_XBLNR
      FROM VBRK
      WHERE VBRK~VBELN = ZVBELN.

    IF V_BILLDATE2+6(4) GE 2025 AND ( V_FKART NE 'ZERE' AND V_FKART NE 'ZEG2').
      SELECT SINGLE XBLNR INTO V_XBLNR
        FROM BKPF
       WHERE AWKEY EQ ZVBELN.
    ENDIF.

    IF V_XBLNR NE '' AND V_BILLDATE2+6(4) LT 2025.
      V_TEMP1 = V_XBLNR(3).
      V_TEMP2 = V_XBLNR+3(3).
      V_TEMP3 = V_XBLNR+6(2).
      V_TEMP4 = V_XBLNR+8(8).

      CONCATENATE V_TEMP1 '.' V_TEMP2 '-' V_TEMP3 '.' V_TEMP4  INTO V_KODEFAKTUR.
      CONDENSE V_KODEFAKTUR NO-GAPS.
    ELSEIF V_XBLNR NE '' AND V_BILLDATE2+6(4) GE 2025.
      V_KODEFAKTUR = '0' && V_XBLNR.
    ENDIF.
  ELSE.
    V_KODEFAKTUR = ITDATATEMP-XBLNR.
  ENDIF.

  IF V_BILLDATE2+6(4) GE 2025.
    V_PERSEN = ''.
  ELSE.
    CONCATENATE ':' V_PERSEN INTO V_PERSEN SEPARATED BY SPACE.
  ENDIF.

  "- Tanda Tangan
  CLEAR : V_SIGN_JABATAN, V_SIGN_NAMA.
  IF V_FKART EQ 'ZERE' OR V_FKART EQ 'ZEG2'.
    SELECT SINGLE ZSIGN~JABATAN ZSIGN~NAMA
      INTO (V_SIGN_JABATAN, V_SIGN_NAMA)
      FROM ZSIGN
      WHERE ZSIGN~VTWEG EQ 'EX'
        AND ZSIGN~VKBUR EQ '0002'
        AND ZSIGN~VBTYP EQ 'O'
        AND ZSIGN~BUKRS EQ WA_DATA-BUKRS.

  ENDIF.

  "- Date Ref. Invoice
  IF V_FKART EQ 'ZDG2' OR
     V_FKART EQ 'ZEG2' OR
     V_FKART EQ 'ZERE' OR
     V_FKART EQ 'ZDRE'.

    CLEAR : ZFKDAT, V_FKDAT, V_TEMP1, V_TEMP2, V_TEMP3.
    SELECT SINGLE VBRK~FKDAT
      INTO ZFKDAT
      FROM VBRK
      WHERE VBRK~VBELN = ZVBELN.

    V_TEMP1 = ZFKDAT(4).
    V_TEMP2 = ZFKDAT+4(2).
    V_TEMP3 = ZFKDAT+6(2).

    CONCATENATE V_TEMP3 V_TEMP2 V_TEMP1 INTO V_FKDAT SEPARATED BY '.'.

  ENDIF.

  V_BELNR      = ITDATATEMP-VBELN.
  V_NAMAPKP    = ITDATATEMP-NAME1.
  V_TEL        = ITDATATEMP-TEL_NUMBER.
  V_FAX        = ITDATATEMP-FAX_NUMBER.

  CONCATENATE ITDATATEMP-STREET ITDATATEMP-CITY1 INTO V_ALAMATPKP SEPARATED BY ''.

  CLEAR : V_TEMP1, V_TEMP2, V_TEMP3, V_TEMP4, V_TEMP5, V_TEMP6.
  V_TEMP1 = ITDATATEMP-PAVAL(2).
  V_TEMP2 = ITDATATEMP-PAVAL+2(3).
  V_TEMP3 = ITDATATEMP-PAVAL+5(3).
  V_TEMP4 = ITDATATEMP-PAVAL+8(1).
  V_TEMP5 = ITDATATEMP-PAVAL+9(3).
  V_TEMP6 = ITDATATEMP-PAVAL+12(3).

  CONCATENATE V_TEMP1 '.' V_TEMP2 '.' V_TEMP3 '.' V_TEMP4 '-' V_TEMP5 '.' V_TEMP6 INTO V_NPWPPKP.
  CONDENSE V_NPWPPKP NO-GAPS.

  "add by ryan 28-08-2024, mengembalikan ke format awal, menghilangkan . dan - pada npwp
  V_NPWPPKP = ITDATATEMP-PAVAL.

  V_TPKP     = ITDATATEMP-PAVAL2.
  CONCATENATE ITDATATEMP-ZNAME1 ITDATATEMP-ZNAME2 ITDATATEMP-ZNAME3 ITDATATEMP-ZNAME4 INTO V_NAMAPBKP SEPARATED BY ''.
*  V_KOTAPBKP = ITDATATEMP-ORT01.
  IF ITDATATEMP-STR_SUPPL3 IS NOT INITIAL.
    CONCATENATE ITDATATEMP-STR_SUPPL2 ITDATATEMP-STR_SUPPL3 ITDATATEMP-ORT01 INTO V_KOTAPBKP SEPARATED BY SPACE.
  ELSE.
    CONCATENATE ITDATATEMP-STR_SUPPL2 ITDATATEMP-ORT01 INTO V_KOTAPBKP SEPARATED BY SPACE.
  ENDIF.
  V_NPWPPBKP = ITDATATEMP-STCEG.
  CONCATENATE ITDATATEMP-ZSTREET ITDATATEMP-STR_SUPPL1  INTO V_ALAMATPBKP SEPARATED BY ''.
  V_COUNTRY  = ITDATATEMP-LANDX50.
  V_NAMA     = ITDATATEMP-PAVAL3.
  V_JABATAN  = ITDATATEMP-PAVAL4.
  TRANSLATE V_NAMA TO UPPER CASE.
  TRANSLATE V_JABATAN TO UPPER CASE.

  CLEAR : V_TEMP1, V_TEMP2, V_TEMP3, V_TEMP4.
  V_TEMP1 = ITDATATEMP-FKDAT(4).
  V_TEMP2 = ITDATATEMP-FKDAT+4(2).
  V_TEMP3 = ITDATATEMP-FKDAT+6(2).
  CONCATENATE V_TEMP3 V_TEMP2 V_TEMP1 INTO V_TEMP4 SEPARATED BY '.'.
  CONCATENATE ITDATATEMP-PAVAL5 ',' INTO ITDATATEMP-PAVAL5.
  CONCATENATE ITDATATEMP-PAVAL5 V_TEMP4 INTO V_KOTANTGL SEPARATED BY SPACE.
  TRANSLATE V_KOTANTGL TO UPPER CASE.


ENDFORM.                    " DATA_PRINT


*&---------------------------------------------------------------------*
*&      Form  PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT .
  PERFORM GET_SELECTED.
  IF ITDATATEMP[] IS INITIAL .
    MESSAGE 'Select at least one data!' TYPE 'I'.
    EXIT.
  ENDIF.
  LOOP AT ITDATATEMP.
    PERFORM DATA_PRINT.
    PERFORM DEFINE_FORM.
    PERFORM CALL_FORM USING V_FORMNAME.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = V_FORMNAME
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = V_FUNCNAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.

    IF SY-SUBRC <> 0.

    ELSE.
      IF ZVBELN IS INITIAL.
        CLEAR : CONTROL_PARAMETERS, OUTPUT_OPTIONS, V_FKDAT.
        CONCATENATE V_TEMP3 V_TEMP2 V_TEMP1 INTO V_FKDAT SEPARATED BY '.'.
      ENDIF.

**--- update PPN 10%, get direct from DPP
*      CALL FUNCTION 'MOVE_CHAR_TO_NUM'
*        EXPORTING
*          CHR             = V_CURR
*        IMPORTING
*          NUM             = V_PPNASING
*        EXCEPTIONS
*          CONVT_NO_NUMBER = 1
*          CONVT_OVERFLOW  = 2
*          OTHERS          = 3.
*
*      V_HJRP = V_PPNASING * V_EXCHR.
**      V_PPNRP =  V_HJRP * ( 1 / 10 ).
*      V_PPNRP =  V_HJRP * ( V_PPN_PRC / 100 ).
*
**      V_PPNASING = V_PPNASING  *  ( 1 / 10 ).
*      V_PPNASING = V_PPNASING  *  ( V_PPN_PRC / 100 ).
*      WRITE V_PPNASING TO V_PPNUSD.
*      CLEAR: V_PPNASING.

      PERFORM GET_TOTAL.

*      CLEAR : CONTROL_PARAMETERS, OUTPUT_OPTIONS.
*      CONTROL_PARAMETERS-PREVIEW = 'X'.
*      OUTPUT_OPTIONS-TDNOPREV = 'X'.
      CONTROL_PARAMETERS-NO_DIALOG = 'X'.
      CALL FUNCTION V_FUNCNAME
        EXPORTING
          CONTROL_PARAMETERS   = CONTROL_PARAMETERS
          OUTPUT_OPTIONS       = OUTPUT_OPTIONS
          P_KODEFAKTUR         = V_KODEFAKTUR
          P_BELNR              = V_BELNR
          P_VBELV              = V_VBELV
          P_FKDAT              = V_FKDAT
          P_NAMAPKP            = V_NAMAPKP
          P_ALAMATPKP          = V_ALAMATPKP
          P_NPWPPKP            = V_NPWPPKP
          P_TPKP               = V_TPKP
          P_NAMAPBKP           = V_NAMAPBKP
          P_ALAMATPBKP         = V_ALAMATPBKP
          P_KOTAPBKP           = V_KOTAPBKP
          P_NPWPPBKP           = V_NPWPPBKP
          P_HJUSD              = V_HJUSD
          P_HJRP               = V_HJRP
          P_DUMUSD             = V_DUMUSD
          P_DUMRP              = V_DUMRP
          P_DPPUSD             = V_DPPUSD
          P_DPPRP              = V_DPPRP
          P_PERSEN             = V_PERSEN
          P_PPNUSD             = V_PPNUSD
          P_PPNRP              = V_PPNRP
          P_KOTANTGL           = V_KOTANTGL
          P_NAMA               = V_NAMA
          P_JABATAN            = V_JABATAN
          P_KURSUSD            = V_KURSUSD
          P_WAERS              = V_WAERS
          ZWAERS               = ZWAERS
          P_CURR               = V_CURR
          P_REMARKS            = V_REMARKS
          P_COUNTRY            = V_COUNTRY
          P_TEL                = V_TEL
          P_FAX                = V_FAX
          P_TOTAL_PPNUSD       = V_TOTAL_PPNUSD
          P_TOTAL_PPNRP        = V_TOTAL_PPNRP
          P_KMKNO              = V_KMKNO
          P_KMKDATE            = V_KMKDATE
          P_SIGN_JABATAN       = V_SIGN_JABATAN
          P_SIGN_NAMA          = V_SIGN_NAMA
          P_POSTCODE           = V_POST_CODE1
          P_TEXTCOMPANY        = V_TEXTCOMPANY  "Add New Company
        IMPORTING
          DOCUMENT_OUTPUT_INFO = DOCUMENT_OUTPUT_INFO
          JOB_OUTPUT_INFO	     = JOB_OUTPUT_INFO
          JOB_OUTPUT_OPTIONS   = JOB_OUTPUT_OPTIONS
        TABLES
          ITPRINT              = ITPRINT
        EXCEPTIONS
          FORMATTING_ERROR     = 1
          INTERNAL_ERROR       = 2
          SEND_ERROR           = 3
          USER_CANCELED        = 4
          OTHERS               = 5.
    ENDIF.

    PERFORM COUNT_PRINT.

  ENDLOOP.

ENDFORM.                    " PRINT


*&---------------------------------------------------------------------*
*&      Form  CALL_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_FORMNAME  text
*----------------------------------------------------------------------*
FORM CALL_FORM  USING    V_FORMNAME.
  "- Calling Form
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

ENDFORM.                    " CALL_FORM


*&---------------------------------------------------------------------*
*&      Form  MODIF_MARK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MARK01  text
*----------------------------------------------------------------------*
FORM MODIF_MARK  USING   MARK01.
  V_LINE = V_LINE + 7.
  DO V_LINE TIMES.
    CHECK SY-INDEX >= 7.
    READ LINE SY-INDEX.
    CHECK SY-SUBRC EQ 0.
    MODIFY LINE SY-INDEX FIELD VALUE MARK01.
  ENDDO.
ENDFORM.                    " MODIF_MARK


*&---------------------------------------------------------------------*
*&      Form  AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITDATA_WAERK  text
*      -->P_ITDATA_NETWR  text
*----------------------------------------------------------------------*
FORM AMOUNT  USING    WAERK
                      NETWR.

  CLEAR : V_NETWR, V_NETWR2.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY        = WAERK
      AMOUNT_INTERNAL = NETWR
    IMPORTING
      AMOUNT_DISPLAY  = V_NETWR
    EXCEPTIONS
      INTERNAL_ERROR  = 1
      OTHERS          = 2.

ENDFORM.                    " AMOUNT


*&---------------------------------------------------------------------*
*&      Form  READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1810   text
*      -->P_1811   text
*      -->P_ITDATATEMP_VBELN  text
*----------------------------------------------------------------------*
FORM READ_TEXT  USING    VALUE(P_ID)
                         VALUE(P_OBJECT)
                         P_VBELN.

  REFRESH : IT_LINE.
  CLEAR : WA_LINE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = P_ID
      LANGUAGE                = SY-LANGU
      NAME                    = P_VBELN
      OBJECT                  = P_OBJECT
    TABLES
      LINES                   = IT_LINE
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

ENDFORM.                    " READ_TEXT


*&---------------------------------------------------------------------*
*&      Form  GET_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1708   text
*      -->P_ZWAERS  text
*----------------------------------------------------------------------*
FORM GET_EXCHANGE_RATE  USING    VALUE(P_1708) ZWAERS.
  DATA: V_RATE  TYPE BAPI1093_0.

  CLEAR : V_EXCHR.
  CLEAR : V_RATE.
  CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
    EXPORTING
      RATE_TYPE  = 'M'
      FROM_CURR  = ZWAERS
      TO_CURRNCY = 'IDR'
      DATE       = ITDATA-FKDAT
    IMPORTING
      EXCH_RATE  = V_RATE.
  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'Currency Exchange Rates  Error!'.
    STOP.
  ENDIF.

  SELECT SINGLE KURSF INTO V_EXCHR
*    FROM BKPF JOIN VBRK ON BKPF~XBLNR = VBRK~XBLNR
    FROM BKPF JOIN VBRK ON BKPF~AWKEY = VBRK~VBELN
    WHERE AWKEY = ITDATA-VBELN.
  IF SY-SUBRC EQ 0.
    V_EXCHR = V_EXCHR *  V_RATE-TO_FACTOR.
  ELSE.
    MESSAGE I000(0K) WITH 'Currency Exchange Rates  Error!'.
    STOP.
  ENDIF.

ENDFORM.                    " GET_EXCHANGE_RATE

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


*&---------------------------------------------------------------------*
*&      Form  DEFINE_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEFINE_FORM .

  IF P_FSTD = 'X'. " Faktur Pajak Standard
    V_FORMNAME = 'ZSDF_FAKTUR_PAJAK'.

  ELSEIF P_NTRT = 'X'. "- Nota Retur
    V_FORMNAME = 'ZSDF_FAKTUR_PAJAKNR'.

  ELSEIF P_NTRE = 'X'. "- Nota Retur Export
    IF V_FKART EQ 'ZEG2'.
      V_FORMNAME = 'ZSDF_FAKTUR_PAJAKNCN'.
    ELSE.
      V_FORMNAME = 'ZSDF_FAKTUR_PAJAKNRE'.
    ENDIF.
  ENDIF.

ENDFORM.                    " DEFINE_FORM


*&---------------------------------------------------------------------*
*&      Form  COUNT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COUNT_PRINT .
  DATA : WA_PRINT TYPE ZNAST,
         V_COUNTER TYPE I.
  CLEAR : WA_PRINT, V_COUNTER.

  SELECT *
    INTO WA_PRINT
    FROM ZNAST
    WHERE ZNAST~OBJKY1 = ITDATATEMP-VBELN.
  ENDSELECT.

  V_COUNTER = WA_PRINT-COUNTER + 1.
  WA_PRINT-COUNTER = V_COUNTER.
  WA_PRINT-OBJKY1  = ITDATATEMP-VBELN.
  WA_PRINT-USER1   = SY-UNAME.

  IF SY-SUBRC = 0.
    UPDATE ZNAST FROM WA_PRINT.
  ELSEIF SY-SUBRC <> 0.
    INSERT INTO ZNAST VALUES WA_PRINT.
  ENDIF.
  COMMIT WORK AND WAIT.

ENDFORM.                   " COUNT_PRINT


*&---------------------------------------------------------------------*
*&      Form  GET_ZKMK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZKMK .
  CLEAR IT_ZKMK.
  REFRESH IT_ZKMK.

  SELECT *
    FROM ZKMK
    INTO CORRESPONDING FIELDS OF TABLE IT_ZKMK.
ENDFORM.                    " GET_ZKMK


*&---------------------------------------------------------------------*
*&      Form  CALL_SCREENKMK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREENKMK .
  CALL SCREEN '0100'.
ENDFORM.                    " CALL_SCREENKMK

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCKMK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TCKMK_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_ZKMK LINES TCKMK-LINES.
ENDMODULE.                    "TCKMK_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCKMK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TCKMK_GET_LINES OUTPUT.
  G_TCKMK_LINES = SY-LOOPC.
ENDMODULE.                    "TCKMK_GET_LINES OUTPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TCKMK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TCKMK_MODIFY INPUT.
  MODIFY IT_ZKMK
    FROM WA_ZKMK
    INDEX TCKMK-CURRENT_LINE.
ENDMODULE.                    "TCKMK_MODIFY INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TCKMK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE TCKMK_MARK INPUT.
  DATA: G_TCKMK_WA2 LIKE LINE OF IT_ZKMK.
  IF TCKMK-LINE_SEL_MODE = 1
  AND WA_ZKMK-SEL = 'X'.
    LOOP AT IT_ZKMK INTO G_TCKMK_WA2
      WHERE SEL = 'X'.
      G_TCKMK_WA2-SEL = ''.
      MODIFY IT_ZKMK
        FROM G_TCKMK_WA2
        TRANSPORTING SEL.
    ENDLOOP.
  ENDIF.
  MODIFY IT_ZKMK
    FROM WA_ZKMK
    INDEX TCKMK-CURRENT_LINE
    TRANSPORTING SEL.
ENDMODULE.                    "TCKMK_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TCKMK'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TCKMK_USER_COMMAND INPUT.
  OK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TCKMK'
                              'IT_ZKMK'
                              'SEL'
                     CHANGING OK_CODE.
  SY-UCOMM = OK_CODE.
ENDMODULE.                    "TCKMK_USER_COMMAND INPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_INSERT_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
  IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        ENTRY_ACT             = <TC>-TOP_LINE
        ENTRY_FROM            = 1
        ENTRY_TO              = <TC>-LINES
        LAST_PAGE_FULL        = 'X'
        LOOPS                 = <LINES>
        OK_CODE               = P_OK
        OVERLAPPING           = 'X'
      IMPORTING
        ENTRY_NEW             = L_TC_NEW_TOP_LINE
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO           = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS                = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines


*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZMSTATUS'.
  SET TITLEBAR 'Maintain KMK Status'.

ENDMODULE.                 " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
*  OK_CODE = SY-UCOMM.
*  CASE SY-UCOMM.
*    WHEN 'BACK'.
*      LEAVE TO SCREEN 0.
*    WHEN 'BTNINS'.
*      PERFORM INSERT_ROW USING 'TCKMK'
*                               'IT_ZKMK'
*                               'SEL'
*                      CHANGING OK_CODE.
*      SY-UCOMM = OK_CODE.
*    WHEN 'BTNDEL'.
*      PERFORM TDELETE_ROW.
*    WHEN 'BTNSV'.
*      PERFORM SAVE_DATA.
*  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*
**&---------------------------------------------------------------------*
**&      Form  INSERT_ROW
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_4087   text
**      -->P_4088   text
**      -->P_4089   text
**      <--P_OK_CODE  text
**----------------------------------------------------------------------*
*FORM INSERT_ROW USING P_TC_NAME TYPE DYNFNAM
*                         P_TABLE_NAME
*                         P_MARK_NAME
*                CHANGING P_OK      LIKE SY-UCOMM.
*
*  DATA : L_OK     TYPE SY-UCOMM,
*         L_OFFSET TYPE I.
*  SEARCH P_OK FOR P_TC_NAME.
*
*  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
*  L_OK = P_OK+L_OFFSET.
*
*  PERFORM FCODE_INSERT_ROW USING  P_TC_NAME
*                                  P_TABLE_NAME.
*  CLEAR P_OK.
*
*ENDFORM.                    " INSERT_ROW
*
*
**&---------------------------------------------------------------------*
**&      Form  SAVE_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM SAVE_DATA .
*  DATA : WA_KMK TYPE ZKMK ,
*       NO TYPE I, NO1 TYPE I.
*  DATA : IT_KMK1 LIKE STANDARD TABLE OF IT_ZKMK WITH HEADER LINE.
*
*  CLEAR : NO1.
*  CLEAR : IT_KMK1. REFRESH IT_KMK1.
*  IT_KMK1[] = IT_ZKMK[].
*  DELETE IT_KMK1 WHERE NOKMK EQ ''.
*
*  SORT IT_KMK1 BY CODE DESCENDING.
*  READ TABLE IT_KMK1 INDEX 1.
*  NO = IT_KMK1-CODE.
*  NO1 = NO.
*
*  LOOP AT IT_ZKMK WHERE CODE EQ ''.
*    NO = NO + 1.
*    IT_ZKMK-CODE = NO.
*    MODIFY IT_ZKMK.
*  ENDLOOP.
*
*  LOOP AT IT_ZKMK WHERE NOKMK NE ''.
*    CLEAR WA_KMK.
*    WA_KMK-CODE = IT_ZKMK-CODE.
*    WA_KMK-NOKMK = IT_ZKMK-NOKMK.
*    WA_KMK-DATEKMK = IT_ZKMK-DATEKMK.
*    WA_KMK-DATEFROM =  IT_ZKMK-DATEFROM.
*    WA_KMK-DATETO =  IT_ZKMK-DATETO.
*    IF WA_KMK-CODE <= NO1.
*      MODIFY ZKMK FROM WA_KMK.
*      COMMIT WORK.
*    ELSE.
*      INSERT INTO ZKMK VALUES WA_KMK.
*      COMMIT WORK.
*    ENDIF.
*  ENDLOOP.
*  REFRESH CONTROL 'TCKMK' FROM SCREEN '0100'.
*
*ENDFORM.                    " SAVE_DATA
*
*
**&---------------------------------------------------------------------*
**&      Form  TDELETE_ROW
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM TDELETE_ROW .
*  CLEAR WA_ZKMK.
*  LOOP AT IT_ZKMK WHERE SEL = 'X'.
*    DELETE FROM ZKMK WHERE NOKMK = IT_ZKMK-NOKMK AND
*                      CODE = IT_ZKMK-CODE.
*    COMMIT WORK.
*  ENDLOOP.
*  DELETE IT_ZKMK WHERE SEL EQ 'X'.
*  REFRESH CONTROL 'TCKMK' FROM SCREEN '0100'.
*
*ENDFORM.                    " TDELETE_ROW
*
*
**&---------------------------------------------------------------------*
**&      Form  GET_KMK
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM GET_KMK .
*
*  DATA : DATE TYPE SY-DATUM, FDATE(10), FFDAT(10),
*         BDATE TYPE SY-DATUM, EDATE TYPE SY-DATUM,
*         NOKMK LIKE ZKMK-NOKMK,
*         DD(2), MM(2), YYYY(4).
*  DATA : IT_KMK LIKE STANDARD TABLE OF ZKMK WITH HEADER LINE.
*
*  CLEAR : V_KMKNO, V_KMKDATE.
*  REFRESH : IT_KMK.
*  SELECT *
*    FROM ZKMK
*    INTO CORRESPONDING FIELDS OF TABLE IT_KMK.
*
*  IF IT_KMK[] IS NOT INITIAL .
*    LOOP AT IT_KMK.
*      CLEAR : BDATE, EDATE, DD, MM, YYYY.
*      SPLIT IT_KMK-DATEFROM AT '.' INTO DD MM YYYY.
*      CONCATENATE YYYY MM DD INTO BDATE.
*      CLEAR: DD, MM, YYYY.
*      SPLIT IT_KMK-DATETO AT '.' INTO DD MM YYYY.
*      CONCATENATE YYYY MM DD INTO EDATE.
*      IF ITDATATEMP-FKDAT >= BDATE AND ITDATATEMP-FKDAT <= EDATE.
*        V_KMKNO   = IT_KMK-NOKMK.
*        V_KMKDATE = IT_KMK-DATEKMK.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
*
*  ENDIF.
*
*ENDFORM.                    " GET_KMK


FORM GET_KMK.
  IF ITDATA-WAERK = 'IDR'.
    CLEAR: V_KMKNO, V_KMKDATE.
    EXIT.
  ENDIF.

  DATA: IT_KMK TYPE ZZKMK OCCURS 0 WITH HEADER LINE.
  DATA: V_DATE LIKE SY-DATUM.

  CONCATENATE V_FKDAT+6(4) V_FKDAT+3(2) V_FKDAT+0(2) INTO V_DATE.
  SELECT * FROM ZZKMK INTO TABLE IT_KMK WHERE DATERATE LE V_DATE.

  SORT IT_KMK DESCENDING BY DATEKMK.
  LOOP AT IT_KMK.
    CONCATENATE 'No.' IT_KMK-NOKMK INTO V_KMKNO SEPARATED BY SPACE.
    CONCATENATE IT_KMK-DATEKMK+6(2) IT_KMK-DATEKMK+4(2) IT_KMK-DATEKMK+0(4) INTO V_KMKDATE SEPARATED BY '-'.
    EXIT.
  ENDLOOP.
ENDFORM.                    "get_kmk


*&---------------------------------------------------------------------*
*&      Form  GET_PPN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PPN.
  DATA: V_ISDEC LIKE KONV-KBETR.
  CLEAR: V_PPN_PRC.
  SELECT SINGLE KBETR FROM KONV INTO V_PPN_PRC
    WHERE KNUMV = V_KNUMV AND KSCHL = 'ZPPN'.

  V_PPN_PRC = V_PPN_PRC / 10.
  V_ISDEC = FLOOR( V_PPN_PRC ).
  IF V_ISDEC NE V_PPN_PRC.
    V_PPN_TXT = V_PPN_PRC.
    WRITE V_PPN_PRC TO V_PPN_TXT DECIMALS 1.
  ELSE.
    V_PPN_TXT = V_PPN_PRC.
    WRITE V_PPN_PRC TO V_PPN_TXT DECIMALS 0.
  ENDIF.

  CONDENSE V_PPN_TXT.
  CONCATENATE V_PPN_TXT '%' INTO V_PPN_TXT.
ENDFORM.                    "get_ppn


*&---------------------------------------------------------------------*
*&      Form  is_ship
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM IS_SHIP.
  DATA: V_DATLT LIKE KNA1-DATLT.
  CLEAR: V_DATLT.

  SELECT SINGLE KNA1~DATLT INTO V_DATLT FROM VBRK JOIN KNA1 ON VBRK~KUNRG = KNA1~KUNNR
  WHERE VBRK~VBELN = ITDATA-VBELN AND KNA1~DATLT NE ''.

  TRANSLATE V_DATLT TO UPPER CASE.
  IF V_DATLT CA 'D'.
    SELECT SINGLE
    ADRC~STREET
    ADRC~CITY1 AS ORT01
    ADRC~STR_SUPPL1
    ADRC~STR_SUPPL2
    ADRC~STR_SUPPL3
    ADRC~COUNTRY
    "ADRC~POST_CODE1
    INTO (ITDATA-ZSTREET, ITDATA-ORT01, ITDATA-STR_SUPPL1,
      ITDATA-STR_SUPPL2, ITDATA-STR_SUPPL3, ITDATA-COUNTRY)
    FROM ADRC
    INNER JOIN VBPA ON VBPA~ADRNR = ADRC~ADDRNUMBER
    WHERE VBPA~VBELN = ITDATA-VBELN
      AND VBPA~PARVW EQ 'WE'.
  ENDIF.
ENDFORM.                    "is_ship



*&---------------------------------------------------------------------*
*&      Form  get_pono
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PONO.
  CLEAR V_KDMAT.
  SELECT SINGLE B~KDMAT INTO V_KDMAT
    FROM VBRP AS A JOIN VBAP AS B ON A~VGBEL = B~VBELN AND A~VGPOS = B~POSNR
    WHERE A~VBELN = ITDATA-VBELN AND A~POSNR = ITDATA-POSNR.
  IF ITDATA-BUKRS NE '9800'.
    IF V_KDMAT NE ''.
      CONCATENATE '( Cust mat:' V_KDMAT ')' INTO V_KDMAT SEPARATED BY SPACE.
    ENDIF.
  ENDIF.
ENDFORM.                    "get_pono



*&---------------------------------------------------------------------*
*&      Form  add_char
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_CHAR.
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZCORE'.
  IF SY-SUBRC = 0.
    CONCATENATE ITDATA-ZITEM ', Core: ' ITCONF-ATWRT ',' INTO ITDATA-ZITEM.
  ENDIF.
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZINSIDE'.
  IF SY-SUBRC = 0.
    CONCATENATE ITDATA-ZITEM 'Inside:' ITCONF-ATWTB INTO ITDATA-ZITEM SEPARATED BY SPACE.
  ENDIF.
  READ TABLE ITCONF WITH KEY ATNAM = 'ZZOUTSIDE'.
  IF SY-SUBRC = 0.
    CONCATENATE ITDATA-ZITEM ',' INTO ITDATA-ZITEM.
    CONCATENATE ITDATA-ZITEM 'Outside: ' ITCONF-ATWTB INTO ITDATA-ZITEM SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    "add_char


*&---------------------------------------------------------------------*
*&      Form  set_roundown
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL.
  DATA: I_TOTAL  LIKE VBRP-NETWR,
        V_CHAR30(30).
  CLEAR: VBRK.

  SELECT SINGLE * INTO VBRK FROM VBRK WHERE VBELN = V_VBELN.
*- EXIT get PPN from KONV for Kawsan berikat
  IF VBRK-TAXK1 = '8'.
    PERFORM GET_PPN_KNUMV.
  ENDIF.
*- end of EXIT get PPN from KONV for Kawsan berikat

  IF VBRK-WAERK = 'IDR'.
    WRITE VBRK-NETWR TO V_CURR CURRENCY VBRK-WAERK DECIMALS 0.
    WRITE VBRK-MWSBK TO V_PPNUSD CURRENCY VBRK-WAERK DECIMALS 0.
    I_TOTAL = VBRK-NETWR + VBRK-MWSBK.
    WRITE I_TOTAL TO V_TOTAL_PPNUSD CURRENCY VBRK-WAERK DECIMALS 0.

  ELSE.
*- doc curr
    WRITE VBRK-NETWR TO V_CURR DECIMALS 2.
    WRITE VBRK-MWSBK TO V_PPNUSD DECIMALS 2.
    I_TOTAL = VBRK-NETWR + VBRK-MWSBK.
    WRITE I_TOTAL TO V_TOTAL_PPNUSD DECIMALS 2.

*-local curr
    V_HJRP =  VBRK-NETWR * V_EXCHR.
    V_PPNRP =  FLOOR( VBRK-MWSBK * V_EXCHR ).
    V_TOTAL_PPNRP = V_HJRP + V_PPNRP.
  ENDIF.

ENDFORM.                    "set_roundown

*&---------------------------------------------------------------------*
*&      Form  get_ppn_knumv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM GET_PPN_KNUMV.
  DATA: V_KWERT LIKE KONV-KWERT.

  CLEAR: VBRK-MWSBK.
  SELECT KWERT INTO V_KWERT FROM KONV WHERE KNUMV = VBRK-KNUMV AND KSCHL = 'ZPPN'.
    VBRK-MWSBK = VBRK-MWSBK + V_KWERT.
  ENDSELECT.
ENDFORM.                    "get_ppn_kn "get_ppn_knumv

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOAD_DATA .
    IF ITDATA[] IS NOT INITIAL.
      PERFORM CONNECT_SQL.
      PERFORM INSERT_OLAP.
    ELSE.
      MESSAGE 'No Data selected !!' TYPE 'I'.
    ENDIF.
ENDFORM.                    " DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONNECT_SQL .
   DATA: CON_NAME        LIKE DBCON-CON_NAME,
         O_CX TYPE REF TO CX_ROOT,
         V_CX_MSG(500).

   IF S_CONN IS INITIAL.
     MESSAGE 'Enter DBCO Connection name...!' TYPE 'S' DISPLAY LIKE 'E'.
     STOP.
   ENDIF.

   SELECT SINGLE CON_NAME
     INTO CON_NAME
     FROM DBCON
    WHERE CON_NAME = S_CONN.
   IF SY-SUBRC NE 0.
     CONCATENATE 'Connection' S_CONN 'not found!' INTO V_CX_MSG SEPARATED BY SPACE.
     MESSAGE V_CX_MSG TYPE 'I'.
     STOP.
   ELSE.
   ENDIF.

   CLEAR: V_CX_MSG.
   TRY.
       EXEC SQL.
         SET CONNECTION :S_CONN
       ENDEXEC.

       EXEC SQL.
         CONNECT TO :S_CONN
       ENDEXEC.

     CATCH CX_ROOT INTO O_CX.
       V_CX_MSG = O_CX->GET_TEXT( ).

       IF V_CX_MSG EQ 'Error creating a secondary database connection'.
         V_CX_MSG = 'Please use SAP Windows server'.
       ENDIF.

       CONCATENATE 'Cannot establish the SQL connection: ' V_CX_MSG INTO V_CX_MSG SEPARATED BY SPACE.
       MESSAGE V_CX_MSG TYPE 'S' DISPLAY LIKE 'E'.
       LEAVE LIST-PROCESSING.
   ENDTRY.
ENDFORM.                    " CONNECT_SQL
*&---------------------------------------------------------------------*
*&      Form  INSERT_OLAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_OLAP .
    IF S_CONN IS NOT INITIAL.
     TRY .
         EXEC SQL.
           DELETE FROM XSD003
         ENDEXEC.

         EXEC SQL.
           COMMIT WORK
         ENDEXEC.

       CATCH CX_SY_NATIVE_SQL_ERROR.
         MESSAGE `Error in procedure execution delete` TYPE 'I'.
         RETURN.
     ENDTRY.

      TRY .
         LOOP AT ITDATA.
             EXEC SQL.
               INSERT INTO XSD003([Sales Organization], [Billing Document],[Billing Item],[Billing Date],[Billing Type],[Tax Number],[Tax Date],[Print],[Is Cancelled],[Currency],[Do Number], [Reference Number],[PO Number],[Cancel Billing],[Customer City],
[Customer Name],[SOFC])
               VALUES(:ITDATA-VKORG, :ITDATA-VBELN, :ITDATA-POSNR, :ITDATA-FKDAT,  :ITDATA-FKART, :ITDATA-XBLNR, :ITDATA-FKDAT, :ITDATA-PCOUNT, :ITDATA-FKSTO, :ITDATA-WAERK,
                :ITDATA-VGBEL, :ITDATA-AUBEL,  :ITDATA-BSTNK, :ITDATA-SFAKN, :ITDATA-ORT01, :ITDATA-ZNAME1, :ITDATA-VKBUR)
             ENDEXEC.
         ENDLOOP.

         EXEC SQL.
           COMMIT WORK
         ENDEXEC.

         EXEC SQL.
           EXEC [SP_MERGE_ZSD003]
         ENDEXEC.

         EXEC SQL.
           COMMIT WORK
         ENDEXEC.

         MESSAGE 'Data downloaded successfully!' TYPE 'S' DISPLAY LIKE 'I'.

       CATCH CX_SY_NATIVE_SQL_ERROR.
         MESSAGE 'Insert Error' TYPE 'I'.
         RETURN.
     ENDTRY.
  ENDIF.
ENDFORM.                    " INSERT_OLAP