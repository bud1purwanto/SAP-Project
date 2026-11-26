*----------------------------------------------------------------------*
***INCLUDE ZPPI_REC_MAT_BY_PROD_O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.
  SET PF-STATUS 'PROD_STAT1000'.
  SET TITLEBAR  'PROD_TITLE1000'.

ENDMODULE.                 " STATUS_1000  OUTPUT




*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1510 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1510 AS SUBSCREEN.
  SELECT-OPTIONS : S_VBELN FOR LIKP-VBELN,
                   S_WERKS FOR LIKP-WERKS NO-EXTENSION NO INTERVALS,
                   S_LGORT FOR LIPS-LGORT NO-EXTENSION NO INTERVALS,
                   S_WADAT FOR LIKP-WADAT_IST,
                   S_KUNNR FOR LIKP-KUNNR.
  SELECTION-SCREEN END OF SCREEN 1510.
ENDMODULE.                 " SEL_SCR_1510  OUTPUT







*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1610  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1610 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1610 AS SUBSCREEN.
*    SELECTION-SCREEN BEGIN OF BLOCK BLOCK3 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS : P_VBELN FOR LIKP-VBELN,
                   P_KUNNR FOR LIKP-KUNNR,
                   P_WADAT FOR LIKP-WADAT_IST,
                   P_WERKS FOR T001W-WERKS,
                   P_ERNAM FOR LIKP-ERNAM,
                   P_ERDAT FOR LIKP-ERDAT.
*    SELECTION-SCREEN END OF BLOCK BLOCK3.
  SELECTION-SCREEN END OF SCREEN 1610 .

ENDMODULE.                 " SEL_SCR_1610  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.

  DATA IT_EXCLUDE TYPE TABLE OF SY-UCOMM.

  REFRESH IT_EXCLUDE.
  IF IT_TIMBANG[] IS INITIAL.
    APPEND 'TESTRUN' TO IT_EXCLUDE.
    APPEND 'EXECUTE' TO IT_EXCLUDE.
  ENDIF.

  SET PF-STATUS 'PROD_STAT1100' EXCLUDING IT_EXCLUDE.
  SET TITLEBAR  'PROD_TITLE1100'.

  PERFORM INITIAL_LGORT.


ENDMODULE.                 " STATUS_1100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1110 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1110  AS SUBSCREEN.
**  SELECTION-SCREEN BEGIN OF BLOCK BLOCK7 WITH FRAME TITLE TEXT-001.
**  SELECT-OPTIONS : S_PDATE FOR SY-DATUM NO-EXTENSION NO INTERVALS DEFAULT SY-DATUM,
**                   S_PLANT FOR MARC-WERKS NO-EXTENSION NO INTERVALS,
**                   S_MATNR FOR MARC-MATNR NO-EXTENSION NO INTERVALS,
**                   S_SLOCA FOR MARD-LGORT NO-EXTENSION NO INTERVALS,
**                   S_SLOCT FOR MARD-LGORT NO-EXTENSION NO INTERVALS.
*
  PARAMETERS :   S_PDATE TYPE SY-DATUM DEFAULT SY-DATUM.
*                 S_PLANT TYPE MARC-WERKS ,
*                 S_MATNR TYPE MARC-MATNR ,
*                 S_SLOCA TYPE MARD-LGORT ,
*                 S_SLOCT TYPE MARD-LGORT .
**  SELECTION-SCREEN END OF BLOCK BLOCK7.
*
  SELECTION-SCREEN END OF SCREEN 1110 .
ENDMODULE.                 " SEL_SCR_1110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1600 OUTPUT.
  SET PF-STATUS 'PROD_STAT1610'.
  SET TITLEBAR 'PROD_TITLE1610'.

ENDMODULE.                 " STATUS_1600  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_1500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1500 OUTPUT.
  SET PF-STATUS 'PROD_STAT1510'.
  SET TITLEBAR 'PROD_TITLE1510'.

ENDMODULE.                 " STATUS_1500  OUTPUT



*&---------------------------------------------------------------------*
*&      Module  STATUS_1400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1400 OUTPUT.
  SET PF-STATUS 'PROD_STAT1400'.
  SET TITLEBAR 'PROD_TITLE1400'.

ENDMODULE.                 " STATUS_1400  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1410  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1410 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1410 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK BLOCK4 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : SE_VBELN FOR LIKP-VBELN,
                   SE_WERKS FOR LIKP-WERKS NO-EXTENSION NO INTERVALS,
                   SE_LGORT FOR LIPS-LGORT NO-EXTENSION NO INTERVALS,
                   SE_WADAT FOR LIKP-WADAT_IST,
                   SE_KUNNR FOR LIKP-KUNNR.
  SELECTION-SCREEN END OF BLOCK BLOCK4.

  SELECTION-SCREEN BEGIN OF BLOCK BLOCK5 WITH FRAME TITLE TEXT-005.
  PARAMETERS : RB1 RADIOBUTTON GROUP GRP1,
               RB2 RADIOBUTTON GROUP GRP1,
               RB3 RADIOBUTTON GROUP GRP1.
  SELECTION-SCREEN END OF BLOCK BLOCK5.

  SELECTION-SCREEN END OF SCREEN 1410.

ENDMODULE.                 " SEL_SCR_1410  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1300 OUTPUT.
  CLEAR : WA_EXECUTION.
  SET PF-STATUS 'PROD_STAT1300'.
  SET TITLEBAR  'PROD_TITLE1300'.

  ZMJAHR = SY-DATUM(4).
  ZWADAT = SY-DATUM.
  ZVKORG = '1000'.
  ZVTWEG = '01'.
  ZSPART = '19'.

  SELECT SINGLE TVKOT~VTEXT
    INTO ZVTEXT1
    FROM TVKOT
    WHERE TVKOT~VKORG = ZVKORG
      AND TVKOT~SPRAS = 'E'.

  SELECT SINGLE TVTWT~VTEXT
    INTO ZVTEXT2
    FROM TVTWT
    WHERE TVTWT~VTWEG = ZVTWEG
      AND TVTWT~SPRAS = 'E'.

  SELECT SINGLE TSPAT~VTEXT
    INTO ZVTEXT3
    FROM TSPAT
    WHERE TSPAT~SPART = ZSPART
      AND TSPAT~SPRAS = 'E'.

*  BREAK-POINT.
  "CEK APAKAH SUDAH ADA MATERIAL DOKUMEN TIMBANG
*    IF R_MATDOC[] IS NOT INITIAL.
*      S_MBLNR[] = R_MATDOC[].
*    ENDIF.

*  IF T_MATDOC[] IS NOT INITIAL.
**    S_MBLNR[] = R_MATDOC[].
*
*    LOOP AT T_MATDOC.
*      CLEAR WR_MATDOC.
*      WR_MATDOC-SIGN   = 'I'.
*      WR_MATDOC-OPTION = 'EQ'.
*      WR_MATDOC-LOW    = T_MATDOC-MATDOC.
*      APPEND WR_MATDOC TO S_MBLNR.
*    ENDLOOP.
*
*
*  ENDIF.


ENDMODULE.                 " STATUS_1300  OUTPUT


*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_TIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_TIMBANG_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_TIMBANG LINES TC_TIMBANG-LINES.
ENDMODULE.                    "TC_TIMBANG_CHANGE_TC_ATTR OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1310  OUTPUT
*&---------------------------------------------------------------------*
*       NOTE : COMMENT BY RIMBUN
*----------------------------------------------------------------------*
**MODULE SEL_SCR_1310 OUTPUT.
**  SELECTION-SCREEN BEGIN OF SCREEN 1310 AS SUBSCREEN.
**  SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-004.
**  SELECT-OPTIONS : S_MBLNR FOR MKPF-MBLNR. " DEFAULT '0' OBLIGATORY.
**  SELECTION-SCREEN END OF BLOCK BLOCK2.
**  SELECTION-SCREEN END OF SCREEN 1310.
**
**ENDMODULE.                 " SEL_SCR_1310  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1200 OUTPUT.
  SET PF-STATUS 'PROD_STAT1200'.
  SET TITLEBAR 'PROD_TITLE1200'.

ENDMODULE.                 " STATUS_1200  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1210  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1210 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1210  AS SUBSCREEN.
*    PARAMETERS :   S_PDATE TYPE SY-DATUM DEFAULT SY-DATUM.
  SELECT-OPTIONS : S_IDLOG FOR ZTLOGTIMBANG-ZIDLOG NO INTERVALS NO-EXTENSION,
                   S_ITEM FOR ZTLOGTIMBANG-ZITEMLOG NO INTERVALS NO-EXTENSION,
                   S_BUDAT FOR MKPF-BUDAT NO-EXTENSION,
*                  S_EDATE FOR MKPF-CPUDT NO-EXTENSION,
*                  S_ETIME FOR MKPF-CPUTM NO-EXTENSION,
                   S_UID   FOR MKPF-USNAM NO INTERVALS NO-EXTENSION,
                   S_LPLANT FOR MSEG-WERKS NO INTERVALS NO-EXTENSION.
  SELECTION-SCREEN END OF SCREEN 1210 .

ENDMODULE.                 " SEL_SCR_1210  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_1211  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1211 OUTPUT.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.

  REFRESH ITAB_EXCLUDE.
*  IF RL1 = 'X'.
*    SET TITLEBAR 'PROD_TITLE12111'.
*  ELSEIF RL2 = 'X'.
  APPEND 'C_TEST' TO ITAB_EXCLUDE.
  APPEND 'C_EXE' TO ITAB_EXCLUDE.
  SET TITLEBAR 'PROD_TITLE12112'.
*  ENDIF.

  SET PF-STATUS 'PROD_STAT1211' EXCLUDING ITAB_EXCLUDE..

ENDMODULE.                 " STATUS_1211  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LTIMBANG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_LTIMBANG_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITLOGTIMBANG LINES TC_LTIMBANG-LINES.
ENDMODULE.                    "TC_LTIMBANG_CHANGE_TC_ATTR OUTPUT


*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_1710  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_1710 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 1710 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK BLOCK7 WITH FRAME TITLE TEXT-004.
  SELECT-OPTIONS : S_MBLNR_ FOR MKPF-MBLNR. " DEFAULT '0' OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK BLOCK7.
  SELECTION-SCREEN END OF SCREEN 1710.

  IF FLAG EQ 'X'.
    PERFORM GET_SELECTED.
    CLEAR : S_MBLNR_.
    REFRESH : S_MBLNR_.
    LOOP AT IT_EXECUTION.
      S_MBLNR_-SIGN   = 'I'.
      S_MBLNR_-OPTION = 'EQ'.
      S_MBLNR_-LOW    = IT_EXECUTION-MBLNR.
      COLLECT S_MBLNR_.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " SEL_SCR_1710  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_1700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1700 OUTPUT.
**  SET PF-STATUS 'PROD_STAT1700'.
  SET PF-STATUS 'PF-7000'.
  SET TITLEBAR 'TITLE7000'.

  ZVKORG_ = '1000'.
  ZVTWEG_ = '01'.
  ZSPART_ = '19'.

  SELECT SINGLE TVKOT~VTEXT
    INTO ZVTEXT1_
    FROM TVKOT
    WHERE TVKOT~VKORG = ZVKORG_
      AND TVKOT~SPRAS = 'E'.

  SELECT SINGLE TVTWT~VTEXT
    INTO ZVTEXT2_
    FROM TVTWT
    WHERE TVTWT~VTWEG = ZVTWEG_
      AND TVTWT~SPRAS = 'E'.

  SELECT SINGLE TSPAT~VTEXT
    INTO ZVTEXT3_
    FROM TSPAT
    WHERE TSPAT~SPART = ZSPART_
      AND TSPAT~SPRAS = 'E'.

  CLEAR : WA_EXECUTION.
  IF IT_EXECUTION[] IS NOT INITIAL AND FLAG = 'X'.
    READ TABLE IT_EXECUTION INDEX 1 INTO WA_EXECUTION.
    IF SY-SUBRC = 0.
**      IF ZKUNNR EQ ''.
**        ZKUNNR = WA_EXECUTION-KUNNR.
**      ENDIF.
**
**      IF ZROUTE EQ ''.
**        ZROUTE = WA_EXECUTION-ROUTE.
**      ENDIF.
**
**      IF ZWERKS EQ ''.
**        ZWERKS = WA_EXECUTION-WERKS.
**      ENDIF.
**
**      IF ZLGORT EQ ''.
**        ZLGORT = WA_EXECUTION-LGORT.
**      ENDIF.
**
**      IF ZPENGEMUDI EQ ''.
**        ZPENGEMUDI = WA_EXECUTION-ZPENGEMUDI.
**      ENDIF.
**
**      IF ZKENDARAAN EQ ''.
**        ZKENDARAAN = WA_EXECUTION-ZKENDARAAN.
**      ENDIF.
**
**      IF ZSKP EQ ''.
**        ZSKP = WA_EXECUTION-ZSKP.
**      ENDIF

      ZMJAHR_     = WA_EXECUTION-MJAHR.
      LIKP-ERDAT  = WA_EXECUTION-BUDAT.
      KNA1-KUNNR  = WA_EXECUTION-KUNNR.
      LIKP-ROUTE  = WA_EXECUTION-ROUTE.
      ZWERKS_     = WA_EXECUTION-WERKS.
      ZLGORT_     = WA_EXECUTION-LGORT.
      ZPENGEMUDI_ = WA_EXECUTION-ZPENGEMUDI.
      ZSKP_       = WA_EXECUTION-ZSKP.
      ZKENDARAAN_ = WA_EXECUTION-ZKENDARAAN.

      CLEAR : ZNAME1_.
      SELECT SINGLE KNA1~NAME1
        INTO ZNAME1_
        FROM KNA1
        WHERE KNA1~KUNNR = KNA1-KUNNR.
    ENDIF.
    CLEAR : FLAG.
  ENDIF.



ENDMODULE.                 " STATUS_1700  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7000 OUTPUT.
  SET PF-STATUS 'PF-7000'.
  SET TITLEBAR 'TITLE7000'.

ENDMODULE.                 " STATUS_7000  OUTPUT