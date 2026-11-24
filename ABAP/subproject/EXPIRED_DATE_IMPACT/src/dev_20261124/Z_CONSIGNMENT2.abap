*&---------------------------------------------------------------------*
*& Report  Z_CONSIGNMENT2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_CONSIGNMENT2.

"------------------TOP
INCLUDE ZABAPALV.

TABLES : LIKP, LIPS, VEKP, VTTP, VBPA, ADRC, PA0001.

DATA  : V_VENUM LIKE VEKP-VENUM,
        V_UNVEL LIKE VEPO-UNVEL,
        V_VBELV LIKE THEAD-TDNAME,
        V_SONUM LIKE VEPO-SONUM,
        V_VBELN LIKE VBAK-VBELN,
        V_UEVEL LIKE VEKP-UEVEL,
        V_VBTYP LIKE LIKP-VBTYP,
        V_EXPR(004),
        VKNKLI LIKE KNKK-KNKLI,
        VDUEDT TYPE SY-DATUM,
        VAGING TYPE C LENGTH 10.

DATA  : IT_DETAIL TYPE CLBATCH OCCURS 0 WITH HEADER LINE.
DATA  : IT_LINE   TYPE TLINE OCCURS 0 WITH HEADER LINE.

**TYPES : BEGIN OF IT_HUM,
**          VENUM LIKE VEKP-VENUM,
**          EXIDV LIKE VEKP-EXIDV,
**          VBELN LIKE LIKP-VBELN,
**        END OF IT_HUM.

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
          ZQTY(10),
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
        END OF IT_HU.

DATA : BEGIN OF IT_HU_EDITED OCCURS 0, "ATTACHMENT
        ZNAME1 LIKE ADRC-NAME1, "Ship To Party Name
        WADAT  LIKE LIKP-WADAT, "Tgl Kirim (Fill up)
        VBELN  LIKE VTTP-VBELN, "DO Number (Fill Up)
        BSTNK  LIKE VBKD-BSTKD, "PO Number (Fill Up)
        VBELV  LIKE VBFA-VBELV, "SO Number (Fill Up)
        POSNV  LIKE VBFA-POSNV, "SO Item (fill Up)
        AUART  LIKE VBAK-AUART, "Tipe
        ZZTHICK(25), "Thickness
        ZZWIDTH(25), "Width
        ZZLENGTH(25), "Length
        EXIDV LIKE VEKP-EXIDV, "HU Pallet
        CHARG  LIKE LIPS-CHARG, "Batch
        ZZROLL(30), "Roll Number
        ZDELIVISSDATE LIKE LIKP-WADAT, "Tgl Kirim (Issue)
        ZDOISSNUM LIKE LIPS-VBELN, "DO Number (Issue)
        ZQTY TYPE I, "Sum Of Qty Roll
        NTGEW  LIKE LIPS-NTGEW, "Sum Of Net Wight
       END OF IT_HU_EDITED.

DATA: BEGIN OF IT_BLOCK OCCURS 0,
        KUNNR LIKE BSID-KUNNR,
        ZFBDT LIKE BSID-ZFBDT,
        ZBD1T LIKE BSID-ZBD1T,
        WRBTR LIKE BSID-WRBTR,
        SHKZG LIKE BSID-SHKZG,
        VDUEDT TYPE SY-DATUM,
      END OF IT_BLOCK.

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
***DATA : IT_ITEM TYPE IT_ITEM OCCURS 0 WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : S_VBELN  FOR LIKP-VBELN,
                 S_WADAT  FOR LIKP-WADAT ,"OBLIGATORY,
                 S_WADATI FOR LIKP-WADAT_IST,
                 S_MTART  FOR LIPS-MTART,
                 S_LFART  FOR LIKP-LFART,
                 S_EXIDV  FOR VEKP-EXIDV,
                 S_TKNUM  FOR VTTP-TKNUM,
                 S_ERDAT  FOR LIKP-ERDAT,
                 S_PSTYV  FOR LIPS-PSTYV.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_CHECK AS CHECKBOX.
PARAMETERS: P_DELCUS AS CHECKBOX.
**              P3 RADIOBUTTON GROUP GRP2 DEFAULT 'X',
**              P4 RADIOBUTTON GROUP GRP2.
SELECTION-SCREEN END OF BLOCK BLOCK2.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-003.
*PARAMETERS: P2 RADIOBUTTON DEFAULT 'X'.
PARAMETERS: P1 RADIOBUTTON GROUP GRP1 DEFAULT 'X',
            P2 RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN END OF BLOCK BLOCK3.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.

DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
FIELD-SYMBOLS : <FS_HU> LIKE LINE OF IT_HU.
FIELD-SYMBOLS : <FS_HUM> LIKE LINE OF IT_HU.
FIELD-SYMBOLS : <FS_CHAR> LIKE LINE OF IT_CHAR.
DATA : ATFLV1 TYPE P LENGTH 5 DECIMALS 1,
       ATFLV2 TYPE P LENGTH 9.

*- OLAP
DATA: LV_DBS_CONNECTION      TYPE DBCON-CON_NAME VALUE 'TRIASDB',
       LV_CURRENT_CONNECTION  TYPE DBCON-CON_NAME.
TABLES: CE18888.

DATA DBTYPE TYPE DBCON_DBMS.

"--------------------------F01

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

    PERFORM OUTPUT USING <FS_HU>-EXIDV.
    PERFORM OUTPUT USING <FS_HU>-ZEXIDV.
    PERFORM OUTPUT USING <FS_HU>-VBELV.
    PERFORM OUTPUT USING <FS_HU>-POSNV.
    PERFORM OUTPUT USING <FS_HU>-VBELN.
    PERFORM OUTPUT USING <FS_HU>-ZPOSNR.

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

  PERFORM EDIT_DATA. "ATTACHMENT
  PERFORM F_FIELD_CATALOG2. "ATTACHMENT
  PERFORM F_LAYOUT2. "ATTACHMENT
  PERFORM F_LIST_DETAIL2. "ATTACHMENT

  "PERFORM F_FIELD_CATALOG.
  "PERFORM F_LAYOUT.
  "PERFORM F_LIST_DETAIL.
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
       'CMFRE'   ''  ''  ''  15   'Released Dlv Date' '' ''  ''  ''.
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


START-OF-SELECTION.
  PERFORM GET_DATA.
  IF P1 = 'X'.
    PERFORM DISPLAY_DATA.
  ELSE.
    "PERFORM TO_OLAP.
  ENDIF.

END-OF-SELECTION.

FORM EDIT_DATA.
  CLEAR IT_HU_EDITED.
  REFRESH IT_HU_EDITED.
  LOOP AT IT_HU.
    MOVE-CORRESPONDING IT_HU TO IT_HU_EDITED.
    APPEND IT_HU_EDITED.
    CLEAR IT_HU_EDITED.
  ENDLOOP.
ENDFORM.

FORM F_FIELD_CATALOG2.
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON2 USING 'IT_HU_EDITED' :
       'ZNAME1'   ''  ''  ''  35   'Ship to Party Name'  ''   ''  ''  '', "Ship To Party Name
       'WADAT'   ''  ''  ''  12   'Tgl Kirim (fill Up)' ''   ''  ''  '', "Tgl Kirim (Fill up)
       'VBELN'   ''  ''  ''  10   'DO Number (Fill Up)'  ''   ''  ''  '', "DO Number (Fill Up)
       'BSTNK'   ''  ''  ''  12   'PO Number (Fill Up)'  ''   ''  ''  '', "PO Number (Fill Up)
       'VBELV'   ''  ''  ''  12   'SO Number (Fill Up)'  ''   ''  ''  '', "SO Number (Fill Up)
       'POSNV'   ''  ''  ''  6   'SO Item (Fill Up)'  ''   ''  ''  '', "SO Item (fill Up)
       'AUART'   ''  ''  ''  6   'Tipe'   ''   ''  ''  '', "Tipe
       'ZZTHICK'   ''  ''  ''  6   'Thickness'   ''   ''  ''  '', "Thickness
       'ZZWIDTH'   ''  ''  ''   7   'Width '       ''   ''  ''  '', "Width
       'ZZLENGTH'   ''  ''  ''   7   'Length '       ''   ''  ''  '', "Length
       'EXIDV'   ''  ''  '' 11   'HU Pallet'  ''   ''  ''  '' , "HU Pallet
       'CHARG'   ''  ''  ''  10   'Batch'  ''   ''  ''  '',
       'ZZROLL'   ''  ''  ''  18   'Roll Number'  ''   ''  ''  '',
       'ZDELIVISSDATE'   ''  ''  ''  20   'Tgl Kirim (Issue)'  ''   ''  ''  '',
       'ZDOISSNUM'   ''  ''  ''  20   'DO Number (Issue)'  ''   ''  ''  '',
       'ZQTY'   ''  ''  ''  3   'Sum Of Qty Roll'  'X'   ''  ''  '',
       'NTGEW'   ''  ''  ''  10   'Sum Of Net Wight'    'X'   ''  ''  ''.
ENDFORM.

FORM F_LAYOUT2.
*  CLEAR WA_LAYOUT.
*  WA_LAYOUT-ZEBRA = 'X'.
*  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
*  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
*  WA_LAYOUT-TOTALS_TEXT = 'Total'.
*  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.

*  WA_LAYOUT-BOX_TABNAME = 'T_HEADER'.
*  WA_LAYOUT-EXPAND_FIELDNAME = 'EXPAND'.
*  wa_layout-expand_all = 'X'.
**  WA_LAYOUT-CELL_MERGE = 'X'.
*  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'

  T_SORT-FIELDNAME = 'ZNAME1'.
  T_SORT-SPOS = 1.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'WADAT'.
  T_SORT-SPOS = 2.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'VBELN'.
  T_SORT-SPOS = 3.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'BSTNK'.
  T_SORT-SPOS = 4.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'VBELV'.
  T_SORT-SPOS = 5.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'POSNV'.
  T_SORT-SPOS = 6.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'AUART'.
  T_SORT-SPOS = 7.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'ZZTHICK'.
  T_SORT-SPOS = 8.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'ZZWIDTH'.
  T_SORT-SPOS = 9.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'ZZLENGTH'.
  T_SORT-SPOS = 10.
  APPEND T_SORT.
  T_SORT-FIELDNAME = 'EXIDV'.
  T_SORT-SPOS = 11.
  APPEND T_SORT.
ENDFORM.

FORM F_LIST_DETAIL2.
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
      T_OUTTAB                 = IT_HU_EDITED
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.