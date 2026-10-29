*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_RETURN_PALLET_STOCK                             *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  21 December 2017                                     *
*&---------------------------------------------------------------------*

REPORT  ZMMR_RETURN_PALLET_STOCK.

TABLES: ZPALLETR, KNA1, MCHB, ZMAP_TYPE.

DATA: BEGIN OF IT_MCHB OCCURS 0,
      MATNR LIKE MCHB-MATNR,
      MAKTX LIKE MAKT-MAKTX,
      PALID LIKE MCHB-CHARG,
      WERKS LIKE MCHB-WERKS,
      LGORT LIKE MCHB-LGORT,
  END OF IT_MCHB.

DATA: BEGIN OF ITAB OCCURS 0.
        INCLUDE STRUCTURE ZPALLETR.
DATA: MATNR LIKE MCHB-MATNR,
      WERKS LIKE MCHB-WERKS,
      LGORT LIKE MCHB-LGORT,
*      NAME1 LIKE KNA1-NAME1,
*      AGENT LIKE LFA1-NAME1,  "agent/transporter name
*      AGING TYPE P LENGTH 4,
*      WEEKS TYPE P LENGTH 4 DECIMALS 1,
*      HULOC LIKE MCHB-LGORT,
      PLDATE LIKE SY-DATUM,  "pallet PO GRN date
      LICHA LIKE MCH1-LICHA,  "pallet PO GRN date
*      GRP TYPE P LENGTH 4 DECIMALS 0,
      TSTATUS TYPE STRING,
      TERMINAL(100),    " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
      MAKTX LIKE MAKT-MAKTX,    " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
      BOX(1).
DATA: END OF ITAB.

DATA: ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE,
      IT_XTABLE LIKE ITAB OCCURS 0 WITH HEADER LINE.

" Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
DATA: IT_TERMINAL LIKE ZMAP_TYPE OCCURS 0 WITH HEADER LINE.
" End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

DATA: ZANSWER TYPE C.

INCLUDE ZABAPALV.                " Include Function ALV.

" Add BY Stefan 10.07.2019 (RTP)
SELECTION-SCREEN BEGIN OF BLOCK CORE_OR_PALLET WITH FRAME TITLE TEXT-002.
PARAMETERS : P_RAD1 RADIOBUTTON GROUP RB1.
PARAMETERS : P_RAD2 RADIOBUTTON GROUP RB1.
PARAMETERS : P_RAD3 RADIOBUTTON GROUP RB1.  " Added by William at 16.04.2020 (Sideboard)
SELECTION-SCREEN END OF BLOCK CORE_OR_PALLET.
" End

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : P_MATNR FOR MCHB-MATNR.
SELECT-OPTIONS : P_PALID FOR ZPALLETR-PALID.
SELECT-OPTIONS : P_WERKS1 FOR ZPALLETR-WERKS1.
SELECT-OPTIONS : P_LGORT1 FOR ZPALLETR-LGORT1.
SELECT-OPTIONS : P_TRMNL1 FOR ZMAP_TYPE-TEXT1 LOWER CASE.
SELECTION-SCREEN END OF BLOCK BLK1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TRMNL1-LOW.
  PERFORM GET_F4_TERMINAL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TRMNL1-HIGH.
  PERFORM GET_F4_TERMINAL.

START-OF-SELECTION.
  " Add BY Stefan 10.07.2019 (RTP)
  IF P_RAD1 = 'X'.
    PERFORM F_GET_DATA.
    PERFORM F_DISPLAY_ALV.
  ELSEIF P_RAD2 = 'X'.
    SUBMIT ZMMR_RETURN_CORE_STOCK
    WITH P_MATNR IN P_MATNR
    WITH P_COREID IN P_PALID
    WITH P_WERKS IN P_WERKS1
    WITH P_LGORT IN P_LGORT1
    USING SELECTION-SCREEN 1000 AND RETURN.
    " Added by William at 16.04.2020 (Sideboard)
  ELSEIF P_RAD3 = 'X'.
    SUBMIT ZMMR_RETURN_BOARD_STOCK
    WITH P_MATNR IN P_MATNR
    WITH P_BOARD IN P_PALID
    WITH P_WERKS IN P_WERKS1
    WITH P_LGORT IN P_LGORT1
    USING SELECTION-SCREEN 1000 AND RETURN.
  ENDIF.
  " End

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA.
  " Modified by William at 25.02.2026 (add column Terminal for RTP Pallet)
  RANGES: R_LGORT1 FOR ZPALLETR-LGORT1.

  CLEAR: R_LGORT1.
  REFRESH: R_LGORT1.

  IF P_TRMNL1[] IS INITIAL.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_TERMINAL
      FROM ZMAP_TYPE
      WHERE DELETION NE 'X'
      AND TCODE = SY-TCODE
      AND TYPE = 'PALLET'
      AND OPT = 'TERMINAL'.

    IF P_LGORT1[] IS NOT INITIAL.
      APPEND LINES OF P_LGORT1 TO R_LGORT1.
    ENDIF.
  ELSE.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_TERMINAL
      FROM ZMAP_TYPE
      WHERE DELETION NE 'X'
      AND TCODE = SY-TCODE
      AND TYPE = 'PALLET'
      AND OPT = 'TERMINAL'
      AND TEXT1 IN P_TRMNL1.

    IF IT_TERMINAL[] IS NOT INITIAL.
      R_LGORT1-SIGN = 'I'.
      R_LGORT1-OPTION = 'EQ'.
      LOOP AT IT_TERMINAL.
        R_LGORT1-LOW = IT_TERMINAL-VALUE.
        APPEND R_LGORT1.
      ENDLOOP.
    ENDIF.
  ENDIF.
  " End modified by William at 25.02.2026 (add column Terminal for RTP Pallet)

  SELECT A~MATNR C~MAKTX A~CHARG AS PALID A~WERKS A~LGORT INTO CORRESPONDING FIELDS OF TABLE IT_MCHB
    FROM MCHB AS A JOIN MARA AS B ON A~MATNR = B~MATNR JOIN MAKT AS C ON A~MATNR = C~MATNR
    WHERE A~MATNR IN P_MATNR AND A~CHARG IN P_PALID AND B~MTART = 'ZRTP' AND
*          B~MATKL IN ('900001','900002','900003','900004','900005') AND " Change BY Stefan 10.07.2019 (RTP) Modified 16.08.2019
          B~MATKL IN ('900001','900002','900003') AND   "Change by Jarwo 21.08.2019
*          A~WERKS IN P_WERKS1 AND A~LGORT IN P_LGORT1 AND A~CLABS  > 0.
          A~WERKS IN P_WERKS1 AND A~LGORT IN R_LGORT1 AND A~CLABS  > 0. " Modified by William at 24.03.2026 (change method for RTP Pallet)
  SORT IT_MCHB BY PALID.

  IF SY-SUBRC NE 0.
    MESSAGE 'Data tidak ada...!' TYPE 'E'.
  ENDIF.

  " Modified by William at 24.03.2026 (change method for RTP Pallet)
  CLEAR: ITAB2.
  REFRESH: ITAB2.
  LOOP AT IT_MCHB.
    SELECT * UP TO 1 ROWS APPENDING CORRESPONDING FIELDS OF TABLE ITAB2 FROM ZPALLETR
      WHERE PALID = IT_MCHB-PALID
      AND STATUS IN ('P', 'E', 'C')
      ORDER BY DOCNO DESCENDING.
  ENDLOOP.
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE ITAB2 FROM ZPALLETR
*    FOR ALL ENTRIES IN IT_MCHB WHERE PALID = IT_MCHB-PALID
*    AND STATUS IN ('P', 'E', 'C').

*  IF SY-SUBRC NE 0.
  IF ITAB2[] IS INITIAL.
    LOOP AT IT_MCHB.
      ITAB-MATNR = IT_MCHB-MATNR.
      ITAB-MAKTX = IT_MCHB-MAKTX.
      ITAB-PALID = IT_MCHB-PALID.
      ITAB-WERKS = IT_MCHB-WERKS.
      ITAB-LGORT = IT_MCHB-LGORT.
      ITAB-TSTATUS = 'NEW'.

      " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
      CLEAR: ITAB-TERMINAL.
      READ TABLE IT_TERMINAL WITH KEY VALUE = ITAB-LGORT.
      IF SY-SUBRC EQ 0.
        ITAB-TERMINAL = IT_TERMINAL-TEXT1.
      ENDIF.
      " End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

      APPEND ITAB.
    ENDLOOP.
    EXIT.   "exit from get data
  ENDIF.
  " End modified by William at 24.03.2026 (change method for RTP Pallet)

  SORT ITAB2 BY STATUS.
  ITAB2-STATUS = '1'.
  MODIFY ITAB2 TRANSPORTING STATUS WHERE STATUS = 'E'.

  ITAB2-STATUS = '2'.
  MODIFY ITAB2 TRANSPORTING STATUS WHERE STATUS = 'P'.

  ITAB2-STATUS = '3'.
  MODIFY ITAB2 TRANSPORTING STATUS WHERE STATUS = 'C'.

  SORT ITAB2 BY STATUS.
  LOOP AT IT_MCHB.
    CLEAR: ITAB2, ITAB.

    ITAB-MATNR = IT_MCHB-MATNR.
    ITAB-MAKTX = IT_MCHB-MAKTX.
    ITAB-PALID = IT_MCHB-PALID.
    ITAB-WERKS = IT_MCHB-WERKS.
    ITAB-LGORT = IT_MCHB-LGORT.
    ITAB-ERDAT1 = ITAB2-ERDAT1.

    READ TABLE ITAB2 WITH KEY PALID = IT_MCHB-PALID
                              WERKS1 = IT_MCHB-WERKS.
    IF SY-SUBRC NE 0.
      READ TABLE ITAB2 WITH KEY PALID = IT_MCHB-PALID.
    ENDIF.

    IF ITAB2-STATUS = '1'.
      ITAB-TSTATUS = 'CUSTOMER'.
    ELSEIF ITAB2-STATUS = '2'.
      ITAB-TSTATUS = 'PACKING'.
    ELSEIF ITAB2-STATUS = '3'.
      ITAB-TSTATUS = 'FREE'.
      IF IT_MCHB-LGORT = '1810' OR IT_MCHB-LGORT = '2810' OR IT_MCHB-LGORT = '3810'.
        ITAB-TSTATUS = 'FREE (RETURN)'.
      ENDIF.
    ELSE.
      ITAB-TSTATUS = 'NEW'.
      IF IT_MCHB-LGORT = '1810' OR IT_MCHB-LGORT = '2810' OR IT_MCHB-LGORT = '3810'.
        ITAB-TSTATUS = 'NEW (RETURN)'.
      ENDIF.
    ENDIF.

    ITAB-DONUM = ITAB2-DONUM.
    APPEND ITAB.
  ENDLOOP.

  LOOP AT ITAB.
    SELECT SINGLE ERSDA LICHA INTO (ITAB-PLDATE, ITAB-LICHA) FROM MCH1 WHERE CHARG = ITAB-PALID.
    SELECT SINGLE LICHA INTO ITAB-LICHA FROM MCH1 WHERE MATNR = ITAB-MATNR AND CHARG = ITAB-PALID.
**- Aging and day to weeks
*    IF ITAB-STATUS = 'E' AND ITAB-ERDAT1 > '01.01.1900'.
*      ITAB-AGING = SY-DATUM - ITAB-ERDAT1.
*      ITAB-WEEKS = ITAB-AGING / 7.
*    ENDIF.

    " Added by William at 25.02.2026 (add column Terminal for RTP Pallet)
    CLEAR: ITAB-TERMINAL.
    READ TABLE IT_TERMINAL WITH KEY VALUE = ITAB-LGORT.
    IF SY-SUBRC EQ 0.
      ITAB-TERMINAL = IT_TERMINAL-TEXT1.
    ENDIF.
    " End added by William at 25.02.2026 (add column Terminal for RTP Pallet)

    MODIFY ITAB.
  ENDLOOP.

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
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'ITAB' :
   'MATNR'  '' ''  '' '10'  'Material'           '' ' ' '' '',
   'MAKTX'  '' ''  '' '20'  'Material Description'           '' ' ' '' '',
   'PALID'  '' ''  '' '10'  'Pallet ID'           '' ' ' '' '',
   'WERKS'  '' ''  '' '5'  'Plant'           '' ' ' '' '',
   'LGORT'  '' ''  '' '5'  'Sloc'           '' ' ' '' '',
   " Modified by William at 25.02.2026 (add column Terminal for RTP Pallet)
*   'LICHA'  '' ''  '' '10'  'No. SKEP'           '' ' ' '' '',
   'TSTATUS'  '' ''  '' '10'  'Status'           '' ' ' '' '',
   'PLDATE'  '' ''  '' '12'  'Pallet GR Date'           '' ' ' '' '',
   'TERMINAL'  '' ''  '' '20'  'Terminal'           '' ' ' '' ''.
  " End modified by William at 25.02.2026 (add column Terminal for RTP Pallet)
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
  SORT ITAB BY PALID.
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
    WHEN 'OLAP'.
*      CLEAR: IT_XTABLE.
*      REFRESH: IT_XTABLE.
*      IT_XTABLE[] = ITAB[].
*      DELETE IT_XTABLE WHERE BOX IS INITIAL.
*      IF IT_XTABLE[] IS INITIAL.
*        MESSAGE 'No data selected!' TYPE 'I' DISPLAY LIKE 'E'.
*      ELSE.
*        ZANSWER = ''.
*        CALL FUNCTION 'POPUP_TO_CONFIRM'
*          EXPORTING
*            TITLEBAR              = 'Confirmation'
*            TEXT_QUESTION         = 'Apakah anda yakin akan mengeksekusi data ini?'
*            TEXT_BUTTON_1         = 'Ya'
*            TEXT_BUTTON_2         = 'Tidak'
*            DEFAULT_BUTTON        = '2'
*            DISPLAY_CANCEL_BUTTON = ''
*          IMPORTING
*            ANSWER                = ZANSWER.
*
*        IF ZANSWER = 1.
*          PERFORM SUBMIT_PARAM_DL.
*        ENDIF.
*      ENDIF.

  ENDCASE.

  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
  " Remarked by William at 13.06.2023 (remove download to RTP server)
*  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
*  IF SY-SUBRC EQ 0.
*    SET PF-STATUS 'STANDARD_FS_OLAP'.
*  ELSE.
*    SET PF-STATUS 'STANDARD_FULLSCREEN'.
*  ENDIF.
  " End remarked by William at 13.06.2023 (remove download to RTP server)
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  SUBMIT_PARAM_DL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUBMIT_PARAM_DL.
*  RANGES: P_MATNR FOR MCHB-MATNR,
*          P_RTPID FOR MCHB-CHARG,
*          P_WERKS FOR MCHB-WERKS,
*          P_LGORT FOR MCHB-LGORT.
*
*  CLEAR: P_MATNR, P_RTPID, P_WERKS, P_LGORT.
*  REFRESH: P_MATNR, P_RTPID, P_WERKS, P_LGORT.
*
*  LOOP AT IT_XTABLE.
*    P_MATNR-SIGN = 'I'.
*    P_MATNR-OPTION = 'EQ'.
*    P_MATNR-LOW = IT_XTABLE-MATNR.
*    APPEND P_MATNR.
*    P_RTPID-SIGN = 'I'.
*    P_RTPID-OPTION = 'EQ'.
*    P_RTPID-LOW = IT_XTABLE-PALID.
*    APPEND P_RTPID.
*    P_WERKS-SIGN = 'I'.
*    P_WERKS-OPTION = 'EQ'.
*    P_WERKS-LOW = IT_XTABLE-WERKS.
*    APPEND P_WERKS.
*    P_LGORT-SIGN = 'I'.
*    P_LGORT-OPTION = 'EQ'.
*    P_LGORT-LOW = IT_XTABLE-LGORT.
*    APPEND P_LGORT.
*  ENDLOOP.
*
*  SUBMIT ZDL_STOCK_RTP
*  WITH P_MATNR IN P_MATNR
*  WITH P_RTPID IN P_RTPID
*  WITH P_WERKS IN P_WERKS
*  WITH P_LGORT IN P_LGORT
*  WITH P_TCODE EQ SY-TCODE
*  AND RETURN.

ENDFORM.                    "SUBMIT_PARAM_DL

*&---------------------------------------------------------------------*
*&      Form  GET_F4_TERMINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE      text
*      -->(P_POS)    text
*----------------------------------------------------------------------*
FORM GET_F4_TERMINAL.
  DATA: BEGIN OF IT_F4_TERMINAL OCCURS 0,
          TERMINAL LIKE ZMAP_TYPE-TEXT1, " Terminal
        END OF IT_F4_TERMINAL.
  DATA: V_STATUS TYPE HELP_INFO-DYNPROFLD.
  DATA: IT_RETURN TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE.

  SELECT DISTINCT ZMAP_TYPE~TEXT1 AS TERMINAL INTO CORRESPONDING FIELDS OF TABLE IT_F4_TERMINAL
    FROM ZMAP_TYPE
    WHERE DELETION NE 'X'
    AND TCODE = SY-TCODE
    AND TYPE = 'PALLET'
    AND OPT = 'TERMINAL'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD    = 'TERMINAL'
      DYNPPROG    = SY-CPROG
      DYNPNR      = SY-DYNNR
      DYNPROFIELD = 'X'
      VALUE_ORG   = 'S'
    TABLES
      VALUE_TAB   = IT_F4_TERMINAL.
ENDFORM.                    "GET_F4_TERMINAL