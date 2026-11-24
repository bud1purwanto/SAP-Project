*----------------------------------------------------------------------*
* Report     ZHUR_ROLL_LIST_BY_DEL_GG
*----------------------------------------------------------------------*
* Application Area  : SD
* ABAPer            : Mualifi
* Date              : October 6th, 2015
* Description       : HU Roll List by Del & Ship with GG LOT number
* Note              : ref from ZHUR_ROLL_LIST_BY_DEL
*----------------------------------------------------------------------*

REPORT  ZHUR_ROLL_LIST_BY_DEL_GG.

TABLES : LIKP, LIPS, VEKP, VTTP, VBPA, ADRC, PA0001.

DATA  : V_VENUM LIKE VEKP-VENUM,
        V_UNVEL LIKE VEPO-UNVEL,
        V_VBELV LIKE THEAD-TDNAME,
        V_SONUM LIKE VEPO-SONUM,
        V_VBELN LIKE VBAK-VBELN,
        V_UEVEL LIKE VEKP-UEVEL,
        V_VBTYP LIKE LIKP-VBTYP,
        V_PALID LIKE ZPALLETR-PALID, "Added by Akbar 06.02.2019 (untuk kolom baru, No. Pallet Trias)
        V_EXPR(004),
        VKNKLI LIKE KNKK-KNKLI,
        VDUEDT TYPE SY-DATUM,
        VAGING TYPE C LENGTH 10.

DATA  : IT_DETAIL TYPE CLBATCH OCCURS 0 WITH HEADER LINE.
DATA  : IT_LINE   TYPE TLINE OCCURS 0 WITH HEADER LINE.

TYPES : BEGIN OF IT_HU,
          BOX(1),
          MBLNR LIKE MKPF-MBLNR,
          VEPOS LIKE HUMSEG-VEPOS,
          VENUM LIKE VEKP-VENUM,
          EXIDV LIKE VEKP-EXIDV,
          ZEXIDV LIKE VEKP-EXIDV,
          MAGRV  LIKE VEKP-MAGRV,
          UEVEL  LIKE VEKP-UEVEL,
          TKNUM  LIKE VTTP-TKNUM,
          VBELN  LIKE VTTP-VBELN,
          UECHA  LIKE LIPS-POSNR,
          POSNR  LIKE LIPS-POSNR,
          ZPOSNR LIKE LIPS-POSNR,
          LFIMG  LIKE LIPS-LFIMG,
          MATNR  LIKE MARA-MATNR,
          CHARG  LIKE LIPS-CHARG,
          WERKS  LIKE LIPS-WERKS,
          LGORT  LIKE LIPS-LGORT,
          LWEDT  LIKE SY-DATUM,
          BSTNK  LIKE VBKD-BSTKD,
          VBELV  LIKE VBFA-VBELV,
          POSNV  LIKE VBFA-POSNV,
          AUART  LIKE VBAK-AUART,
          BEZEI  LIKE TVAKT-BEZEI,
          ENAME  LIKE PA0001-ENAME,
          KUNAG  LIKE LIKP-KUNAG,
          KUNNR  LIKE LIKP-KUNNR,
          NAME1  LIKE ADRC-NAME1,
          ZNAME1 LIKE ADRC-NAME1,
          ERDAT  LIKE VEKP-ERDAT,
          LFART  LIKE LIKP-LFART,
          WADAT  LIKE LIKP-WADAT,
          WADAT_IST LIKE LIKP-WADAT_IST,
          BLDAT  LIKE LIKP-BLDAT,
          ZERDAT LIKE LIKP-ERDAT,
          BWART  LIKE LIPS-BWART,
          NTGEW  LIKE LIPS-NTGEW,
          GEWEI  LIKE LIPS-GEWEI,
          VRKME  LIKE LIPS-VRKME,
          WBSTK  LIKE VBUK-WBSTK,
          PSTYV  LIKE LIPS-PSTYV,
          ZWBSTK(25),
          ZQTY TYPE P DECIMALS 0, "LIKE LIPS-LFIMG,
          ZPINUM(20),
          ZZTYPE(25),
          ZZTHICK(25),
          ZZWIDTH(25),
          ZZLENGTH(25),
          ZZROLL(30),
          ZZEXPR LIKE SY-DATUM,
          ZZTREAT(25),
          ZZCORE(25),
          ZZPACK(25),
          ZZCRITERIA(25),
          ZZALIAS(25), "Add by pst_hisar 14-12-12
          VCODE LIKE QAVE-VCODE, "Add by pst_hisar 14-12-12
          INSPSTATUS(25), "Add by pst_hisar 14-12-12
          QPLOS LIKE LIPS-QPLOS, "Add by pst_hisar 17-12-12
          VSTAT(15) TYPE C, "add by pst_anthony
          CMFRE LIKE LIKP-CMFRE, "add by pst_anthony
          PARTIAL(5),
          KDMAT LIKE VBAP-KDMAT,
          ZLOT(50),
          PALID LIKE ZPALLETR-PALID, "Added by Akbar 01.02.2019 (untuk kolom baru, No. Pallet Trias)
        END OF IT_HU.

DATA: BEGIN OF IT_BLOCK OCCURS 0,
        KUNNR LIKE BSID-KUNNR,
        ZFBDT LIKE BSID-ZFBDT,
        ZBD1T LIKE BSID-ZBD1T,
        WRBTR LIKE BSID-WRBTR,
        SHKZG LIKE BSID-SHKZG,
        VDUEDT TYPE SY-DATUM,
      END OF IT_BLOCK.

DATA: BEGIN OF IT_STD OCCURS 0,
      PART LIKE ZHMS-EXIDV,   "VBAP-KDMAT,
      PALID LIKE ZHMS-PALID,
      QTY TYPE P DECIMALS 0,
  END OF IT_STD.

DATA: BEGIN OF IT_HUQTY OCCURS 0,
      EXIDV LIKE VEKP-EXIDV,
      QTY TYPE P DECIMALS 0, "LIKE LIPS-LFIMG,
  END OF IT_HUQTY.

DATA: BEGIN OF IT_KUNNR OCCURS 0,
        KUNNR LIKE KNKK-KUNNR,
END OF IT_KUNNR.

TYPES : BEGIN OF IT_EXIDV,
          VENUM LIKE VEKP-VENUM,
          EXIDV LIKE VEKP-EXIDV,
        END OF IT_EXIDV.

RANGES: TBWART FOR LIPS-BWART. "ADD BY PST_HISAR 14-12-12
RANGES: TLFART FOR LIKP-LFART. "ADD BY PST_HISAR 17-12-12
DATA : V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZHUR_ROLL_LIST_BY_DEL'.

DATA : IT_HU TYPE IT_HU OCCURS 0 WITH HEADER LINE,
       IT_BLOCK2 LIKE IT_BLOCK OCCURS 0 WITH HEADER LINE.

DATA : IT_HUM TYPE IT_HU OCCURS 0 WITH HEADER LINE.
DATA : IT_EXIDV TYPE IT_EXIDV OCCURS 0 WITH HEADER LINE.
DATA: V_MSEG(100).
DATA: V_PRTNO(25).


SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_VBELN  FOR LIKP-VBELN OBLIGATORY,
                 S_WADAT  FOR LIKP-WADAT ,"OBLIGATORY,
                 S_WADATI FOR LIKP-WADAT_IST,
                 S_MTART  FOR LIPS-MTART,
                 S_LFART  FOR LIKP-LFART,
                 S_EXIDV  FOR VEKP-EXIDV,
                 S_TKNUM  FOR VTTP-TKNUM,
                 S_ERDAT  FOR LIKP-ERDAT,
                 S_PSTYV  FOR LIPS-PSTYV.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.

DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
FIELD-SYMBOLS : <FS_HU> LIKE LINE OF IT_HU.
FIELD-SYMBOLS : <FS_HUM> LIKE LINE OF IT_HU.
FIELD-SYMBOLS : <FS_CHAR> LIKE LINE OF IT_CHAR.
DATA : ATFLV1 TYPE P LENGTH 5 DECIMALS 1,
       ATFLV2 TYPE P LENGTH 9.

INCLUDE ZABAPALV.

*INCLUDE ZHUR_ROLL_LIST_BY_DEL_TOP.
INCLUDE Z_PROG_INFO.
*INCLUDE ZHUR_ROLL_LIST_BY_DEL_F01.


START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM GET_LOT.
  PERFORM GET_PALID.  "Added by Akbar 06.02.2019 (untuk kolom baru, No. Pallet Trias)
  PERFORM DISPLAY_DATA.

END-OF-SELECTION.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA .

  CLEAR   : IT_HU, IT_HUM.
  REFRESH : IT_HU, IT_HUM.

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

*    "- Production Date
*    IF <FS_HU>-CHARG EQ '' OR <FS_HU>-MATNR EQ ''.
*    ELSE.
*      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
*        EXPORTING
*          MATNR = <FS_HU>-MATNR
*          CHARG = <FS_HU>-CHARG
*        IMPORTING
*          PDATE = <FS_HU>-LWEDT.
*    ENDIF.

    "- SO Number
    IF <FS_HU>-LFART EQ 'ZDLF' OR <FS_HU>-LFART EQ 'ZELF' OR <FS_HU>-LFART EQ 'ZLR'.
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

*        "- Expire Live
*        CLEAR : V_EXPR.
*        READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXPIREDLIVE' ASSIGNING <FS_CHAR>.
*        IF SY-SUBRC = 0 AND <FS_HU>-LWEDT NE '00000000'.
*          MOVE <FS_CHAR>-ATFLV TO ATFLV2.
*          V_EXPR = ATFLV2.
*          <FS_HU>-ZZEXPR = <FS_HU>-LWEDT + V_EXPR.
*        ENDIF.

      ENDIF.  "sy-subc ne 0
    ENDIF.   "charg ne ''

    SELECT SINGLE KDMAT INTO <FS_HU>-KDMAT FROM VBAP
      WHERE VBELN = <FS_HU>-VBELV AND POSNR = <FS_HU>-POSNV.

    CONDENSE <FS_HU>-KDMAT.
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
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_HU' :
       'VBELN'   ''  ''  ''  10   'DO Number'  ''   ''  ''  '',
       'BSTNK'   ''  ''  ''  12   'PO Number'  ''   ''  ''  '',
       'EXIDV'   ''  ''  '' 12   'Batch Number'  ''   ''  ''  '' ,
       'ZZROLL'   ''  ''  ''  28   'Roll Number'  ''   ''  ''  '',
       'ZZTYPE'   ''  ''  ''  8   'Tipe'   ''   ''  ''  '',
       'ZZTHICK'   ''  ''  ''  8   'Thickness'   ''   ''  ''  '',
       'ZZWIDTH'   ''  ''  ''   8   'Width '       ''   ''  ''  '',
       'ZZLENGTH'   ''  ''  ''   8   'Length '       ''   ''  ''  '',
       'ZQTY'   ''  ''  ''  8   'Total'  ''   ''  ''  '',
       'KDMAT'   ''  ''  ''  20   'GG Part Number (OPR)'  ''   ''  ''  '',
       'LWEDT'   ''  ''  ''  12   'Prod. Date'    ''   ''  ''  '',
       'ZZEXPR'   ''  ''  ''  12   'Expired Date'    ''   ''  ''  '',
       'ZLOT'   ''  ''  ''  42   'Lot. No. GG '  ''   ''  ''  '',
       'PALID'   ''  ''  ''  15  'No. Pallet Trias' ''''  ''  '' ''.  "Added by Akbar 06.02.2019 (untuk kolom baru, No. Pallet Trias)

  T_FIELDCAT-NO_ZERO = 'X'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'VBELN'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'EXIDV'.
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

  REFRESH: IT_HU, IT_HUQTY, IT_EXIDV.
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
*&      Form  get_lot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LOT.
* use ZHU021
  DATA: IT_EXIDV TYPE HUM_EXIDV_T,
        IT_VEPO LIKE VEPOVB OCCURS 0,
        WA_VEPO TYPE VEPOVB OCCURS 0 WITH HEADER LINE.
  DATA: V_VENUM LIKE VEKP-VENUM.

*--- HU items
  DATA: BEGIN OF IT_ERSDA OCCURS 0,
        MATNR LIKE MCH1-MATNR,
        CHARG LIKE MCH1-CHARG,
*        ERSDA LIKE MCH1-ERSDA,
        LWEDT LIKE MCH1-LWEDT,
        END OF IT_ERSDA.
  DATA: V_NTGEW LIKE VEKP-NTGEW.

  DATA I_BATCH LIKE API_VALI OCCURS 0 WITH HEADER LINE.
  DATA: V_VLIVE TYPE P DECIMALS 0,
        V_PDATE LIKE SY-DATUM,                 "Berisi tanggal GR batch dengan format MM/YYYY
        V_EDATE LIKE SY-DATUM,                "Berisi tanggal Used Before Batch dengan format MM/YYYY
        V_PALID LIKE ZHMS-PALID,
        V_STD(1).

  DATA: V_CEK01 LIKE VEKP-EXIDV.

  PERFORM QTY_PART.

  CLEAR: IT_EXIDV, IT_VEPO, WA_VEPO, V_VENUM, IT_ERSDA, V_NTGEW, V_CEK01.
  LOOP AT IT_HU. "update by hu
    CLEAR: V_VLIVE, V_PDATE, V_EDATE, V_PALID, V_STD.
    REFRESH: I_BATCH.

    APPEND IT_HU-EXIDV TO IT_EXIDV.

    CALL FUNCTION 'HU_GET_HUS_DB'
      EXPORTING
        IT_HU_NUMBERS = IT_EXIDV
      IMPORTING
*       ET_HU_HEADER  =
        ET_HU_ITEMS   = IT_VEPO.


    V_VENUM = IT_HU-VENUM.
    LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
      IF WA_VEPO-SONUM = ''.
        V_VENUM = WA_VEPO-UNVEL.
        LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
          EXIT.
        ENDLOOP.
      ENDIF.
      EXIT.
    ENDLOOP.

"Start - Added by Akbar 20.01.2020 (Update Expd Date & Prod Date)
* get prod date
    IF IT_HU-CHARG EQ '' OR IT_HU-MATNR EQ ''.
      DELETE IT_VEPO WHERE VEMNG = 0.
      SELECT MATNR CHARG LWEDT INTO TABLE IT_ERSDA FROM MCH1
      FOR ALL ENTRIES IN IT_VEPO WHERE CHARG = IT_VEPO-CHARG.

      SORT IT_ERSDA BY LWEDT DESCENDING.
      READ TABLE IT_ERSDA INDEX 1.
      V_PDATE = IT_ERSDA-LWEDT.
    ELSE.
      CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
        EXPORTING
          MATNR = IT_HU-MATNR
          CHARG = IT_HU-CHARG
        IMPORTING
          PDATE = V_PDATE.
    ENDIF.

* get expd date
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR  = IT_HU-MATNR
        I_VAL_CHARGE = IT_HU-CHARG
      TABLES
        T_VAL_TAB    = I_BATCH.
    IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
        READ TABLE I_BATCH WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
        IF SY-SUBRC = 0.
          V_VLIVE = I_BATCH-ATWRT.
        ENDIF.

      V_EDATE = V_PDATE + V_VLIVE.

      IT_HU-ZZEXPR = V_EDATE.
      IT_HU-LWEDT = V_PDATE.

      MODIFY IT_HU TRANSPORTING ZZEXPR LWEDT WHERE CHARG = IT_HU-CHARG. "Modified by Akbar 23.01.2020 (Re-Update Expd Date & Prod Date by batch)
    ENDIF.
"End - Added by Akbar 20.01.2020 (Update Expd Date & Prod Date)

    "Modified by Akbar 23.01.2020 (Re-Update Expd Date & Prod Date by batch)
    IF V_CEK01 = IT_HU-EXIDV.
      CONTINUE.
    ENDIF.

*-- palid
    SELECT PALID INTO V_PALID FROM ZHMS WHERE EXIDV = IT_HU-EXIDV ORDER BY PALID DESCENDING.
    ENDSELECT.
    IF SY-SUBRC NE 0. "reprint
      IT_HU-ZLOT = 'Label A4 belum di cetak'.
      MODIFY IT_HU TRANSPORTING ZLOT WHERE EXIDV = IT_HU-EXIDV.
      CONTINUE.
    ENDIF.

*-- get standard
    READ TABLE IT_STD WITH KEY PART = IT_HU-KDMAT.
    IF SY-SUBRC NE 0.
      CONCATENATE 'Master Part' IT_HU-KDMAT 'tidak ada' INTO IT_HU-ZLOT SEPARATED BY SPACE.
      MODIFY IT_HU TRANSPORTING ZLOT WHERE EXIDV = IT_HU-EXIDV.
      CONTINUE.
    ENDIF.

    READ TABLE IT_HUQTY WITH KEY EXIDV = IT_HU-EXIDV.
    IF SY-SUBRC = 0.
      IF IT_STD-QTY = IT_HUQTY-QTY.
        V_STD = '1'.
      ELSE.
        V_STD = '0'.
      ENDIF.
    ELSE.
    ENDIF.

*-- pdate lot
    V_PRTNO = IT_HU-KDMAT.

    CONDENSE V_PRTNO NO-GAPS.
    SHIFT V_PRTNO RIGHT DELETING TRAILING SPACE.
    TRANSLATE V_PRTNO USING ' 0'.

    CONCATENATE V_PRTNO
    V_EDATE+6(2) V_EDATE+4(2) V_EDATE+2(2)
    V_PDATE+6(2) V_PDATE+4(2) V_PDATE+2(2)
    V_PALID V_STD
    INTO IT_HU-ZLOT.

    MODIFY IT_HU TRANSPORTING ZLOT WHERE EXIDV = IT_HU-EXIDV.

    V_CEK01 = IT_HU-EXIDV.
  ENDLOOP.   " by hu
ENDFORM.                    "get_lot


*&---------------------------------------------------------------------*
*&      Form  qty_part
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM QTY_PART.
  SELECT EXIDV PALID INTO TABLE IT_STD FROM ZHMS
    WHERE NOCOA = 'MASTER PART GUDANG GARAM'.

  LOOP AT IT_STD.
    IT_STD-QTY = IT_STD-PALID.
    MODIFY IT_STD.
  ENDLOOP.

  SORT IT_HU BY EXIDV.
  LOOP AT IT_HU.
    IT_HUQTY-QTY = 1.
    IT_HUQTY-EXIDV = IT_HU-EXIDV.
    COLLECT IT_HUQTY.
  ENDLOOP.
ENDFORM.                    "qty_part

*&---------------------------------------------------------------------*
*&      Form  get_palid
*&---------------------------------------------------------------------*
*       text
*-      Added by Akbar 06.02.2019 (untuk kolom baru, No. Pallet Trias)
*----------------------------------------------------------------------*
FORM GET_PALID.
  SORT IT_HU BY EXIDV.
  CLEAR: IT_HUM.
  LOOP AT IT_HU.
    IF IT_HUM-EXIDV = IT_HU-EXIDV.
      IT_HU-PALID = V_PALID.
      MODIFY IT_HU TRANSPORTING PALID WHERE EXIDV = IT_HU-EXIDV.
      CONTINUE.
    ENDIF.

    SELECT SINGLE ZPALLETR~PALID
      INTO V_PALID
      FROM ZPALLETR
      WHERE EXIDV = IT_HU-EXIDV.
    IF SY-SUBRC = 0.
      IT_HU-PALID = V_PALID.
      MODIFY IT_HU TRANSPORTING PALID WHERE EXIDV = IT_HU-EXIDV.
      IT_HUM-EXIDV = IT_HU-EXIDV.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_palid