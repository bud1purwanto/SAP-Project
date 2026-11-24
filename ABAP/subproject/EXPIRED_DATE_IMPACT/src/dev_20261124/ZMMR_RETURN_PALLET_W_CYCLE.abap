*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_RETURN_PALLET                                   *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  09 November 2017                                     *
*&---------------------------------------------------------------------*

REPORT  ZMMR_RETURN_PALLET_W_CYCLE.

TABLES: ZPALLETR, KNA1, VEKP, ZCORER, MCHB, ZBOARDR, MARA. "Add BY Stefan 10.07.2019 (RTP), Modified by William at 17.04.2020 (Sideboard)

DATA: BEGIN OF ITAB OCCURS 0.
        INCLUDE STRUCTURE ZPALLETR.
DATA: ERDAT LIKE VEKP-ERDAT,   " HU create on
      MATNR LIKE MCHB-MATNR,
      NAME1 LIKE KNA1-NAME1,
      AGENT LIKE LFA1-NAME1,  "agent/transporter name
      AGING TYPE P LENGTH 4,
      WEEKS TYPE P LENGTH 4 DECIMALS 1,
      HULOC LIKE MCHB-LGORT,
      PLDATE LIKE SY-DATUM,  "pallet PO GRN date
      GRP TYPE P LENGTH 4 DECIMALS 0,
      TSTATUS(10),
      ZLOT(50),               "Added by AKBAR 06.11.2019 (Add Lot No GG)
      CYCLE TYPE I,         " Added by William at 24.02.2026 (New layout)
      TERMINAL(100),    " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
      MAKTX LIKE MAKT-MAKTX,    " Added by William at 25.02.2026 (add column Material Description for RTP Pallet)
      BOX(1).
DATA: END OF ITAB.

"Start - Added by AKBAR 06.11.2019 (Add Lot No GG)
DATA : BEGIN OF IT_HU OCCURS 0,
        VENUM LIKE VEKP-VENUM,
        EXIDV LIKE VEKP-EXIDV,
        MATNR  LIKE MARA-MATNR,
        CHARG  LIKE LIPS-CHARG,
        LWEDT  LIKE SY-DATUM,
        ZZEXPR LIKE SY-DATUM,
        KDMAT LIKE VBAP-KDMAT,
        ZLOT(50),
      END OF IT_HU.

DATA: BEGIN OF IT_STD OCCURS 0,
    PART LIKE ZHMS-EXIDV,
    PALID LIKE ZHMS-PALID,
    QTY TYPE P DECIMALS 0,
END OF IT_STD.

DATA: BEGIN OF IT_HUQTY OCCURS 0,
    EXIDV LIKE VEKP-EXIDV,
    QTY TYPE P DECIMALS 0,
END OF IT_HUQTY.
"End - Added by AKBAR 06.11.2019 (Add Lot No GG)

DATA: BEGIN OF IT_KNA1 OCCURS 0, "with header line,
  KUNNR LIKE KNA1-KUNNR,
  NAME1 LIKE KNA1-NAME1,
  END OF IT_KNA1.

DATA: BEGIN OF IT_LFA1 OCCURS 0, "with header line,
  LIFNR LIKE LFA1-LIFNR,
  NAME1 LIKE LFA1-NAME1,
  END OF IT_LFA1.

*-
DATA: BEGIN OF IT_STATUS OCCURS 0,
  STATUS  TYPE CHAR10, " LIKE ZPALLETR-STATUS,
  DESC  TYPE CHAR30, "
 END OF IT_STATUS.
DATA : V_STATUS TYPE HELP_INFO-DYNPROFLD.
DATA: IT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.
*-

" Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
DATA: IT_TERMINAL LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
" End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

INCLUDE ZABAPALV.                " Include Function ALV.
" Edit By Stefan 10.07.2019 (RTP)
*SELECTION-SCREEN BEGIN OF BLOCK BLK0 WITH FRAME TITLE TEXT-001.
*PARAMETERS : R_PALLET RADIOBUTTON GROUP R_UP USER-COMMAND AC DEFAULT 'X',
*             R_CORE RADIOBUTTON GROUP R_UP,
*             R_BOARD RADIOBUTTON GROUP R_UP.  " Added by William at 17.04.2020 (Sideboard)
*SELECTION-SCREEN END OF BLOCK BLK0.

*" Added by William at 24.02.2026 (New layout)
*SELECTION-SCREEN BEGIN OF BLOCK BLK4 WITH FRAME TITLE TEXT-003.
*PARAMETERS : R_LYT1 RADIOBUTTON GROUP R_VW MODIF ID LYT USER-COMMAND AC DEFAULT 'X',
*             R_LYT2 RADIOBUTTON GROUP R_VW MODIF ID LYT.
*SELECTION-SCREEN END OF BLOCK BLK4.
*" End added by William at 24.02.2026 (New layout)

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS :  P_MATNR FOR MARA-MATNR MODIF ID PAL,        " Added by William at 24.02.2026 (New layout)
                  P_PALID FOR ZPALLETR-PALID MODIF ID PAL.
*                  P_TKNUM FOR ZPALLETR-TKNUM MODIF ID PAL,
*                  P_EXIDV FOR ZPALLETR-EXIDV MODIF ID PAL,
*                  P_HUDATE FOR VEKP-ERDAT MODIF ID PAL,
*                  P_WERKS1 FOR ZPALLETR-WERKS1 MODIF ID PAL,
*                  P_LGORT1 FOR ZPALLETR-LGORT1 MODIF ID PAL,
*                  P_ERDAT1 FOR ZPALLETR-ERDAT1 MODIF ID PAL,
*                  P_KUNNR FOR KNA1-KUNNR MODIF ID PAL,
*                  P_STATUS FOR ZPALLETR-STATUS MODIF ID PAL.
*SELECT-OPTIONS : P_ERDAT2 FOR ZPALLETR-ERDAT2 MODIF ID PAL.   "GRN Date
" End - Edit By Stefan 10.07.2019 (RTP)
*SELECTION-SCREEN SKIP 1.
*PARAMETERS: P_DEL AS CHECKBOX MODIF ID PAL.
*PARAMETERS: P_LOT AS CHECKBOX MODIF ID PAL.

SELECTION-SCREEN END OF BLOCK BLK1.
"Add BY Stefan 10.07.2019 (RTP)
*SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-001.
*SELECT-OPTIONS :  P_PERIOD FOR SY-DATUM MODIF ID COR,
*                  P_CHARG FOR MCHB-CHARG MODIF ID COR,
*                  P_COREID FOR ZCORER-COREID NO INTERVALS MODIF ID COR,
*                  P_WERKS FOR MCHB-WERKS NO INTERVALS MODIF ID COR,
*                  P_LGORT FOR MCHB-LGORT NO INTERVALS MODIF ID COR,
*                  P_STAT FOR ZCORER-STATUS NO INTERVALS MODIF ID COR.
**SELECTION-SCREEN SKIP 1.
**PARAMETERS :      P_MAXHIT TYPE INT2 DEFAULT 10 OBLIGATORY MODIF ID COR. "Modify by: "Stefan on 29.10.2019
*
*"Start Added by ALDI 24.02.2020 (Add filter to delete remark cancel & change)
*SELECTION-SCREEN SKIP 1.
*PARAMETERS: P_CSR AS CHECKBOX MODIF ID COR.
*PARAMETERS: P_CCI AS CHECKBOX MODIF ID COR.
*"END ADD BY ALDI 24.02.2020
*
*SELECTION-SCREEN END OF BLOCK BLK2.

" Added by William at 17.04.2020 (Sideboard)
*SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-001.
*SELECT-OPTIONS :  P_BOARD FOR ZBOARDR-BOARDID MODIF ID BRD,
*                  P_TKNUM3 FOR ZBOARDR-TKNUM MODIF ID BRD,
*                  P_EXIDV3 FOR ZBOARDR-EXIDV MODIF ID BRD,
*                  P_ERDAT3 FOR VEKP-ERDAT MODIF ID BRD,
*                  P_WERKS3 FOR ZBOARDR-WERKS MODIF ID BRD,
*                  P_LGORT3 FOR ZBOARDR-LGORT MODIF ID BRD,
*                  P_ERSDA3 FOR ZBOARDR-ERSDA MODIF ID BRD,
*                  P_KUNNR3 FOR KNA1-KUNNR MODIF ID BRD,
*                  P_STAT3 FOR ZBOARDR-STATUS MODIF ID BRD,
*                  P_DATEGR FOR ZBOARDR-ERSDAGR MODIF ID BRD.
*
*SELECTION-SCREEN SKIP 1.
*PARAMETERS: P_DEL3 AS CHECKBOX MODIF ID BRD.
*SELECTION-SCREEN END OF BLOCK BLK3.
" End added by William at 17.04.2020 (Sideboard)

" Modified by William at 17.04.2020 (Sideboard)

AT SELECTION-SCREEN OUTPUT.
*  IF R_PALLET = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-GROUP1 = 'COR'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*      IF SCREEN-GROUP1 = 'BRD'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ELSEIF R_CORE = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-GROUP1 = 'PAL'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*      IF SCREEN-GROUP1 = 'BRD'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ELSEIF R_BOARD = 'X'.
*    LOOP AT SCREEN.
*      IF SCREEN-GROUP1 = 'PAL'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*      IF SCREEN-GROUP1 = 'COR'.
*        SCREEN-INPUT = 0.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
  " End modified by William at 17.04.2020 (Sideboard)
  "End - Add BY Stefan 10.07.2019 (RTP)

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_STATUS-LOW.
*  PERFORM GET_F4 USING 'LOW'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_STATUS-HIGH.
*  PERFORM GET_F4 USING 'HIGH'.

START-OF-SELECTION.
  PERFORM F_GET_DATA.
*  IF P_LOT = 'X'.
*    PERFORM F_GET_LOT.        "Added by AKBAR 06.11.2019 (Add Lot No GG)
*  ENDIF.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA.
  " Added by William at 24.02.2026 (New layout)
  DATA: ITAB_TEMP1 LIKE ITAB OCCURS 0 WITH HEADER LINE.
  DATA: ITAB_TEMP2 LIKE ITAB OCCURS 0 WITH HEADER LINE.
  DATA: ITAB_TEMP3 LIKE ITAB OCCURS 0 WITH HEADER LINE.
  DATA: V_CYCLE TYPE I.
  " End added by William at 24.02.2026 (New layout)

  " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_TERMINAL
    FROM ZMAP_TYPE
    WHERE DELETION NE 'X'
    AND TCODE = SY-TCODE
    AND TYPE = 'PALLET'
    AND OPT = 'TERMINAL'.
  " End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

  " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
  IF P_MATNR[] IS INITIAL.
    SELECT A~DOCNO A~PALID A~EXIDV A~TKNUM A~DONUM A~MBLNR1 A~WERKS1 A~LGORT1 A~ERDAT1
           A~ERZET1 A~USNAM1 A~SONUM A~POSNR  A~KUNNR A~MBLNR2 A~WERKS2 A~LGORT2
           A~ERDAT2 A~DRIVER A~NOPOL A~ERZET2 A~USNAM2 A~TDLNR A~WERKS3 A~LGORT3 A~ERDAT3 A~STATUS A~CHG_NAME
           A~CHG_DATE A~SMBLN A~REMARK B~ERDAT
      INTO CORRESPONDING FIELDS OF TABLE ITAB
      FROM ZPALLETR AS A JOIN VEKP AS B ON A~EXIDV = B~EXIDV
      WHERE A~PALID IN P_PALID.
  ELSE.
    SELECT A~DOCNO A~PALID A~EXIDV A~TKNUM A~DONUM A~MBLNR1 A~WERKS1 A~LGORT1 A~ERDAT1
           A~ERZET1 A~USNAM1 A~SONUM A~POSNR  A~KUNNR A~MBLNR2 A~WERKS2 A~LGORT2
           A~ERDAT2 A~DRIVER A~NOPOL A~ERZET2 A~USNAM2 A~TDLNR A~WERKS3 A~LGORT3 A~ERDAT3 A~STATUS A~CHG_NAME
           A~CHG_DATE A~SMBLN A~REMARK B~ERDAT C~MATNR E~MAKTX
      INTO CORRESPONDING FIELDS OF TABLE ITAB
      FROM ZPALLETR AS A JOIN VEKP AS B ON A~EXIDV = B~EXIDV
                         JOIN MCH1 AS C ON A~PALID = C~CHARG
                         JOIN MCHA AS D ON C~MATNR = D~MATNR AND C~CHARG = D~CHARG
                         JOIN MAKT AS E ON D~MATNR = E~MATNR
      WHERE A~PALID IN P_PALID
      AND C~MATNR IN P_MATNR.
  ENDIF.
  " End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

*  SELECT A~DOCNO A~PALID A~EXIDV A~TKNUM A~DONUM A~MBLNR1 A~WERKS1 A~LGORT1 A~ERDAT1
*         A~ERZET1 A~USNAM1 A~SONUM A~POSNR  A~KUNNR A~MBLNR2 A~WERKS2 A~LGORT2
*         A~ERDAT2 A~DRIVER A~NOPOL A~ERZET2 A~USNAM2 A~TDLNR A~WERKS3 A~LGORT3 A~ERDAT3 A~STATUS A~CHG_NAME
*         A~CHG_DATE A~SMBLN A~REMARK B~ERDAT C~MATNR E~MAKTX
*    INTO CORRESPONDING FIELDS OF TABLE ITAB
*    FROM ZPALLETR AS A JOIN VEKP AS B ON A~EXIDV = B~EXIDV
*                       JOIN MCH1 AS C ON A~PALID = C~CHARG
*                       JOIN MCHA AS D ON C~MATNR = D~MATNR AND C~CHARG = D~CHARG
*                       JOIN MAKT AS E ON D~MATNR = E~MATNR
*    WHERE A~PALID IN P_PALID
*    AND C~MATNR IN P_MATNR.

  IF SY-SUBRC NE 0.
    MESSAGE 'Data tidak ada...!' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*  IF P_DEL EQ ''.
*    DELETE ITAB WHERE STATUS = 'L'.
*  ENDIF.

*- get Pallet Name
  LOOP AT ITAB.
    " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
    IF ITAB-PALID IS NOT INITIAL.
      IF P_MATNR[] IS INITIAL.
        SELECT SINGLE MCH1~MATNR MAKT~MAKTX INTO (ITAB-MATNR, ITAB-MAKTX) FROM MCH1
          JOIN MAKT ON MCH1~MATNR = MAKT~MATNR
          WHERE MCH1~CHARG = ITAB-PALID.
      ELSE.
        SELECT SINGLE MCH1~MATNR MAKT~MAKTX INTO (ITAB-MATNR, ITAB-MAKTX) FROM MCH1
          JOIN MCHA ON MCH1~MATNR = MCHA~MATNR AND MCH1~CHARG = MCHA~CHARG
          JOIN MAKT ON MCHA~MATNR = MAKT~MATNR
          WHERE MCH1~CHARG = ITAB-PALID
          AND MCHA~WERKS = ITAB-WERKS1.
      ENDIF.
      " End added by William at 25.02.2026 (add column Terminal for RTP Pallet)
*      SELECT SINGLE MCH1~MATNR MAKT~MAKTX INTO (ITAB-MATNR, ITAB-MAKTX) FROM MCH1
*        JOIN MAKT ON MCH1~MATNR = MAKT~MATNR
*        WHERE MCH1~CHARG = ITAB-PALID.
      MODIFY ITAB.
    ENDIF.
  ENDLOOP.

  SELECT KUNNR NAME1 INTO TABLE IT_KNA1 FROM KNA1
    FOR ALL ENTRIES IN ITAB WHERE KUNNR = ITAB-KUNNR.

  SELECT LIFNR NAME1 INTO TABLE IT_LFA1 FROM LFA1
    FOR ALL ENTRIES IN ITAB WHERE LIFNR = ITAB-TDLNR.

  LOOP AT ITAB.
    CLEAR: IT_KNA1.
    READ TABLE IT_KNA1 WITH KEY KUNNR = ITAB-KUNNR.
    ITAB-NAME1 = IT_KNA1-NAME1.

*- PO GR date
    SELECT SINGLE ERSDA INTO ITAB-PLDATE FROM MCH1 WHERE CHARG = ITAB-PALID.

*- Aging and day to weeks
    IF ITAB-STATUS = 'E' AND ITAB-ERDAT1 > '01.01.1900'.
      ITAB-AGING = SY-DATUM - ITAB-ERDAT1.
      ITAB-WEEKS = ITAB-AGING / 7.
    ENDIF.

    IF ITAB-STATUS = 'P'.
*- sloc HU
      SELECT SINGLE VEPO~LGORT INTO ITAB-HULOC
        FROM VEKP JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
        WHERE EXIDV = ITAB-EXIDV AND VEPO~LGORT NE ''.
    ENDIF.

    MODIFY ITAB.
  ENDLOOP.

*- customer name
  LOOP AT IT_KNA1.
    READ TABLE ITAB WITH KEY KUNNR = IT_KNA1-KUNNR.
    IF SY-SUBRC = 0.
      ITAB-NAME1 = IT_KNA1-NAME1.
      MODIFY ITAB TRANSPORTING NAME1 WHERE KUNNR = IT_KNA1-KUNNR.
    ENDIF.
  ENDLOOP.

*- transporter name
  LOOP AT IT_LFA1.
    READ TABLE ITAB WITH KEY TDLNR = IT_LFA1-LIFNR.
    IF SY-SUBRC = 0.
      ITAB-AGENT = IT_LFA1-NAME1.
      MODIFY ITAB TRANSPORTING AGENT WHERE TDLNR = IT_LFA1-LIFNR.
    ENDIF.
  ENDLOOP.

  ITAB-GRP = 1.
  MODIFY ITAB TRANSPORTING GRP WHERE GRP NE 1.

  ITAB-TSTATUS = 'PACKING'.
  MODIFY ITAB TRANSPORTING TSTATUS WHERE STATUS = 'P'.
  ITAB-TSTATUS = 'CUSTOMER'.
  MODIFY ITAB TRANSPORTING TSTATUS WHERE STATUS = 'E'.
  ITAB-TSTATUS = 'COMPLETE'.
  MODIFY ITAB TRANSPORTING TSTATUS WHERE STATUS = 'C'.
  ITAB-TSTATUS = 'DELETED'.
  MODIFY ITAB TRANSPORTING TSTATUS WHERE STATUS = 'L'.

  " Added by William at 24.02.2026 (New layout)
  CLEAR: ITAB_TEMP1, ITAB_TEMP2, ITAB_TEMP3, V_CYCLE.
  REFRESH: ITAB_TEMP1, ITAB_TEMP2, ITAB_TEMP3.

  ITAB_TEMP1[] = ITAB[].
  SORT ITAB_TEMP1 BY PALID ASCENDING.
  DELETE ADJACENT DUPLICATES FROM ITAB_TEMP1 COMPARING PALID.
  LOOP AT ITAB_TEMP1.
    " Get data per pallet
    LOOP AT ITAB WHERE PALID = ITAB_TEMP1-PALID.
      MOVE-CORRESPONDING ITAB TO ITAB_TEMP2.
      APPEND ITAB_TEMP2.
    ENDLOOP.

    " Count how many cycle pallet is already COMPLETE
    V_CYCLE = 0.
    LOOP AT ITAB_TEMP2 WHERE STATUS = 'C'.
      V_CYCLE = V_CYCLE + 1.
    ENDLOOP.

    " Get last status based on delivery date per pallet
*    SORT ITAB_TEMP2 BY ERDAT DESCENDING ERDAT1 DESCENDING.
    SORT ITAB_TEMP2 BY DOCNO DESCENDING.
    READ TABLE ITAB_TEMP2 INDEX 1.
    MOVE-CORRESPONDING ITAB_TEMP2 TO ITAB_TEMP3.

    " Set cycle
    ITAB_TEMP3-CYCLE = V_CYCLE.

    " Get Position of Terminal Pallet
*    DATA: V_WERKS LIKE MCHB-WERKS.
*    DATA: V_LGORT LIKE MCHB-LGORT.
*
*    CLEAR: V_WERKS, V_LGORT.
*    V_WERKS = ITAB_TEMP3-WERKS1.
*    IF ITAB_TEMP3-WERKS2 IS NOT INITIAL.
*      V_WERKS = ITAB_TEMP3-WERKS2.
*    ENDIF.
*
*    SELECT SINGLE LGORT INTO V_LGORT FROM MCHB
*      WHERE CHARG = ITAB_TEMP3-PALID
*        AND WERKS = V_WERKS
*        AND CLABS > 0.
*
*    IF V_LGORT IS NOT INITIAL.
*      CLEAR: ITAB_TEMP3-TERMINAL.
*      READ TABLE IT_TERMINAL WITH KEY VALUE = V_LGORT.
*      IF SY-SUBRC EQ 0.
*        ITAB_TEMP3-TERMINAL = IT_TERMINAL-TEXT1.
*      ENDIF.
*    ENDIF.

    CLEAR: ITAB_TEMP3-TERMINAL.
    IF ITAB_TEMP3-LGORT3 IS NOT INITIAL.
      READ TABLE IT_TERMINAL WITH KEY VALUE = ITAB_TEMP3-LGORT3.
      IF SY-SUBRC EQ 0.
        ITAB_TEMP3-TERMINAL = IT_TERMINAL-TEXT1.
      ENDIF.
    ENDIF.

    " Get last unpack date based on delivery date per pallet
    SORT ITAB_TEMP2 BY ERDAT3 DESCENDING.
    READ TABLE ITAB_TEMP2 INDEX 1.
    IF SY-SUBRC EQ 0.
      ITAB_TEMP3-ERDAT3 = ITAB_TEMP2-ERDAT3.
    ENDIF.

    APPEND ITAB_TEMP3.

    CLEAR: ITAB_TEMP2, ITAB_TEMP3.
    REFRESH: ITAB_TEMP2.
  ENDLOOP.

  ITAB[] = ITAB_TEMP3[].
  CLEAR: ITAB_TEMP1, ITAB_TEMP2, ITAB_TEMP3.
  REFRESH: ITAB_TEMP1, ITAB_TEMP2, ITAB_TEMP3.
  " End added by William at 24.02.2026 (New layout)
ENDFORM.                    "f_get_data


*--- Display Items
FORM F_DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.

  " Added by William at 24.02.2026 (New layout)
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
  'MATNR'  '' ''  '' '16'  'Packing Name'           '' ' ' '' '',
  'MAKTX'  '' ''  '' '25'  'Packing Description'           '' ' ' '' '',
  'PALID'  '' ''  '' '10'  'Pallet ID'           '' ' ' '' '',
  'ERDAT1'  '' ''  '' '12'  'Last Delv. Date'           '' ' ' '' '',
  'NAME1'  '' ''  '' '25'  'Last Customer Name'           '' ' ' '' '',
  'TSTATUS'  '' ''  '' '10'  'Last Status Cycle'           '' ' ' '' '',
  'CYCLE'  '' ''  '' '5'  'Total Usage'           '' ' ' '' '',
  'TERMINAL'  '' ''  '' '20'  'Last Unpack Location (Terminal)'           '' ' ' '' '',
  'ERDAT3'  '' ''  '' '10'  'Last Unpack Date'           '' ' ' '' ''.

  T_FIELDCAT-NO_ZERO     = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CYCLE'.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'PALID'.
  " End added by William at 24.02.2026 (New layout)

  T_FIELDCAT-NO_ZERO     = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'ZLOT'.
ENDFORM.                    " f_field_catalog


*&---------------------------------------------------------------------*
*&      Form  f_layout
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
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " f_layout


*&---------------------------------------------------------------------*
*&      Form  f_list_detail
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
      T_OUTTAB                 = ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " f_list_detail

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.

  SY-LSIND = 0.
  CASE FU_UCOMM.
*    WHEN 'PRINT'.
*      REFRESH TORD.
*      CLEAR: V_COUNT, V_TEMP, TORD.
*

  ENDCASE.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS



*&---------------------------------------------------------------------*
*&      Form  GET_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE      text
*      -->(P_POS)    text
*----------------------------------------------------------------------*
FORM GET_F4 USING VALUE(P_POS).
  IF IT_STATUS IS INITIAL.
    IT_STATUS-STATUS = 'P'.   IT_STATUS-DESC = 'Packed'.         APPEND IT_STATUS.
    IT_STATUS-STATUS = 'E'.   IT_STATUS-DESC = 'At  Customer'.   APPEND IT_STATUS.
    IT_STATUS-STATUS = 'C'.   IT_STATUS-DESC = 'Completed'.      APPEND IT_STATUS.
    IT_STATUS-STATUS = 'L'.   IT_STATUS-DESC = 'Deleted / Cancelled'.      APPEND IT_STATUS.
  ENDIF.

  CASE P_POS.
    WHEN 'LOW'.
      V_STATUS = 'P_STATUS-LOW'.
    WHEN 'HIGH'.
      V_STATUS = 'P_STATUS-HIGH'.
  ENDCASE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'STATUS'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'X'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_STATUS.
ENDFORM.                    "get_f4
*&---------------------------------------------------------------------*
*&      Form  F_GET_LOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GET_LOT .

  DATA: IT_EXIDV TYPE HUM_EXIDV_T,
        IT_VEPO LIKE VEPOVB OCCURS 0,
        WA_VEPO TYPE VEPOVB OCCURS 0 WITH HEADER LINE.
  DATA: V_VENUM LIKE VEKP-VENUM.

  DATA: BEGIN OF IT_ERSDA OCCURS 0,
        MATNR LIKE MCH1-MATNR,
        CHARG LIKE MCH1-CHARG,
*        ERSDA LIKE MCH1-ERSDA,
        LWEDT LIKE MCH1-LWEDT,
        END OF IT_ERSDA.

  DATA I_BATCH LIKE API_VALI OCCURS 0 WITH HEADER LINE.
  DATA: V_VLIVE TYPE P DECIMALS 0,
        V_PDATE LIKE SY-DATUM,                 "Berisi tanggal GR batch dengan format MM/YYYY
        V_EDATE LIKE SY-DATUM,                "Berisi tanggal Used Before Batch dengan format MM/YYYY
        V_PALID LIKE ZHMS-PALID,
        V_PRTNO(25),
        V_STD(1).

  DATA: V_CEK01 LIKE VEKP-EXIDV.

  LOOP AT ITAB.
    CLEAR : IT_HU, ITAB-ZLOT.
    REFRESH: IT_HU.

    SELECT VEKP~VENUM VEKP~EXIDV VEPO~MATNR VEPO~CHARG
      INTO CORRESPONDING FIELDS OF TABLE IT_HU
      FROM VEKP JOIN VEPO ON VEKP~VENUM = VEPO~VENUM
     WHERE VEKP~EXIDV = ITAB-EXIDV.

    IF SY-SUBRC EQ 0.

      IF ITAB-STATUS = 'L'.           "Status Free
        ITAB-ZLOT = ''.
        MODIFY ITAB.
        CONTINUE.
      ELSEIF ITAB-KUNNR NE '1142000000' AND ITAB-KUNNR NE '1142000002' AND
             ITAB-KUNNR NE '1141000025' AND ITAB-KUNNR NE '1141000104' AND
             ITAB-KUNNR NE ''.        "Bukan Customer GG
        ITAB-ZLOT = ''.
        MODIFY ITAB.
        CONTINUE.
      ENDIF.

*     get part
      PERFORM F_QTY_PART.

*     get material hirarcichal HU
      PERFORM F_MATNR_HIRHU.

*     get Lot GG
      CLEAR: IT_EXIDV, IT_VEPO, WA_VEPO, V_VENUM, IT_ERSDA, V_CEK01.
      LOOP AT IT_HU.
        CLEAR: V_VLIVE, V_PDATE, V_EDATE, V_PALID, V_STD.
        REFRESH: I_BATCH.

        APPEND IT_HU-EXIDV TO IT_EXIDV.

        CALL FUNCTION 'HU_GET_HUS_DB'
          EXPORTING
            IT_HU_NUMBERS = IT_EXIDV
          IMPORTING
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

*       get live
        READ TABLE IT_HU WITH KEY MATNR = ''.
        IF SY-SUBRC = 0.
          ITAB-ZLOT = ''.
          MODIFY ITAB.
          CONTINUE.
        ELSE.

          "Start - Added by Akbar 20.01.2020 (Update Expd Date & Prod Date)
          "get prod date
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

          "get expd date
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

        ENDIF.

        "Modified by Akbar 23.01.2020 (Re-Update Expd Date & Prod Date by batch)
        IF V_CEK01 = IT_HU-EXIDV.
          CONTINUE.
        ENDIF.

*    -- palid
        SELECT PALID INTO V_PALID FROM ZHMS WHERE EXIDV = IT_HU-EXIDV ORDER BY PALID DESCENDING.
        ENDSELECT.
        IF SY-SUBRC NE 0. "reprint
          IT_HU-ZLOT = 'Label A4 belum di cetak'.
          MODIFY IT_HU TRANSPORTING ZLOT WHERE EXIDV = IT_HU-EXIDV.

          ITAB-ZLOT = IT_HU-ZLOT.
          MODIFY ITAB.

          CONTINUE.
        ENDIF.

*    -- get standard
        SELECT SINGLE KDMAT INTO IT_HU-KDMAT FROM VBAP
        WHERE VBELN = ITAB-SONUM AND POSNR = ITAB-POSNR.

        READ TABLE IT_STD WITH KEY PART = IT_HU-KDMAT.
        IF SY-SUBRC NE 0.
          CONCATENATE 'Master Part' IT_HU-KDMAT 'tidak ada' INTO IT_HU-ZLOT SEPARATED BY SPACE.
          MODIFY IT_HU TRANSPORTING ZLOT WHERE EXIDV = IT_HU-EXIDV.

          ITAB-ZLOT = IT_HU-ZLOT.
          MODIFY ITAB.

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

*    -- Update lot
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

        ITAB-ZLOT = IT_HU-ZLOT.
        MODIFY ITAB.

        V_CEK01 = IT_HU-EXIDV.
      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_GET_LOT
*&---------------------------------------------------------------------*
*&      Form  F_QTY_PART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_QTY_PART .

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

ENDFORM.                    " F_QTY_PART
*&---------------------------------------------------------------------*
*&      Form  F_MATNR_HIRHU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_MATNR_HIRHU .

  DATA : HDR    LIKE BAPIHUHEADER OCCURS 2 WITH HEADER LINE,
         ITM    LIKE BAPIHUITEM OCCURS 2 WITH HEADER LINE,
         HUNUMB LIKE BAPIHUNUMBER OCCURS 2 WITH HEADER LINE,
         RETRN  LIKE BAPIRET2 OCCURS 2 WITH HEADER LINE.

  LOOP AT IT_HU WHERE MATNR EQ ''.

    HUNUMB-HU_EXID = IT_HU-EXIDV.
    APPEND HUNUMB.

    CALL FUNCTION 'BAPI_HU_GETLIST'
      EXPORTING
        NOTEXT    = ' '
        ONLYKEYS  = ''
      TABLES
        HUNUMBERS = HUNUMB
        HUHEADER  = HDR
        HUITEM    = ITM
        RETURN    = RETRN.

    IF SY-SUBRC = 0.
      LOOP AT ITM WHERE MATERIAL NE ''.
        IT_HU-MATNR = ITM-MATERIAL.
        IT_HU-CHARG = ITM-BATCH.
      ENDLOOP.
      MODIFY IT_HU.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_MATNR_HIRHU