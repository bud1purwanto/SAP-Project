*&---------------------------------------------------------------------*
*&  Include           ZPPI_RESLIT_ROLL_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7000 OUTPUT.
   SET PF-STATUS 'ZSTAT_7000'.
   SET TITLEBAR  'ZTITLE_7000'.
ENDMODULE.                 " STATUS_7000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SEL_SCREEN_MAINTAIN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE SEL_SCREEN_MAINTAIN OUTPUT.

*  SELECTION-SCREEN BEGIN OF SCREEN 7110 AS SUBSCREEN." NO INTERVALS.
*  SELECTION-SCREEN BEGIN OF BLOCK blck_maintain WITH FRAME TITLE text-020.
*    select-options:
*                  so_plant for t001w-werks NO-EXTENSION NO INTERVALS,
*                  so_batch for mchb-charg,
*                  so_posdt for mkpf-budat  DEFAULT sy-datum NO-EXTENSION NO INTERVALS,
*                  so_nik   for plogi-objid NO-EXTENSION NO INTERVALS.
*  SELECTION-SCREEN END OF BLOCK blck_maintain.
*  SELECTION-SCREEN END OF SCREEN 7110.

*ENDMODULE.                 " SEL_SCREEN_MAINTAIN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_7100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7100 OUTPUT.
  CLEAR: fcode.
  REFRESH: fcode.
  APPEND 'POST' TO fcode.
  APPEND 'PRINT' TO fcode.
  SET PF-STATUS 'ZSTAT_7100' EXCLUDING fcode.
  SET TITLEBAR 'ZTITLE_7100'.
  LOOP AT SCREEN.
    CHECK screen-name = 'BTN_RST'.
      screen-invisible = 1.
      MODIFY SCREEN.
      EXIT.
  ENDLOOP.
  IF MGODIS = 'X'.
    SET PF-STATUS 'ZSTAT_7100'.
    LOOP AT SCREEN.
      CHECK screen-name = 'BTN_MGO'.
        screen-invisible = 1.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'BTN_RST'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'TC_MAINTAIN_MARK'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'TC_MAINTAIN_DEMARK'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'TC_MAINTAIN_DELETE'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'TC_MAINTAIN_PREVIOUS'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    LOOP AT SCREEN.
      CHECK screen-name = 'TC_MAINTAIN_NEXT'.
        screen-invisible = 0.
        MODIFY SCREEN.
        EXIT.
    ENDLOOP.
    IF sy-dynnr = 7110.
      LOOP AT SCREEN.
        CHECK SCREEN-NAME = 'SO_PLANT-LOW'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
          EXIT.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_7100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_7300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7300 OUTPUT.
  SET PF-STATUS 'ZSTAT_7300'.
  SET TITLEBAR 'ZTITLE_7300'.
ENDMODULE.                 " STATUS_7300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_7200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7200 OUTPUT.
  SET PF-STATUS 'ZSTAT_7200'.
  SET TITLEBAR 'ZTITLE_7200'.
ENDMODULE.                 " STATUS_7200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_7220  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_7220 OUTPUT.
  SET PF-STATUS 'ZSTAT_7220'.
  SET TITLEBAR 'ZTITLE_7220'.
ENDMODULE.                 " STATUS_7220  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_MAINTAIN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_MAINTAIN_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_MAINTAIN LINES TC_MAINTAIN-lines.
**Kalau table controlnya kosong,maka di invisible
  IF TC_MAINTAIN-LINES = 0.
    TC_MAINTAIN-INVISIBLE = 'X'.
  ELSE.
    TC_MAINTAIN-INVISIBLE    = ''.
    IF OK_CODE = 'BTN_MGO'.
      TC_MAINTAIN-TOP_LINE     = 1.
      TC_MAINTAIN-CURRENT_LINE = 1.
      TC_MAINTAIN-LEFT_COL     = 0.
    ENDIF.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_MAINTAIN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TC_MAINTAIN_GET_LINES OUTPUT.
  G_TC_MAINTAIN_LINES = SY-LOOPC.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC_MAINTAIN_MODIF_FIELD  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_MAINTAIN_MODIF_FIELD OUTPUT.

  IF WA_MAINTAIN-hdrlvl ne 'X'.
    LOOP AT SCREEN.
      CHECK SCREEN-NAME = 'WA_MAINTAIN-MTRPO' OR SCREEN-NAME = 'WA_MAINTAIN-VERID'.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " TC_MAINTAIN_MODIF_FIELD  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_CANCEL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC_CANCEL_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE IT_DISPLAY LINES TC_CANCEL-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_CANCEL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TC_CANCEL_GET_LINES OUTPUT.
  G_TC_CANCEL_LINES = SY-LOOPC.
ENDMODULE.