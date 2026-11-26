*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_PBO9001
*&---------------------------------------------------------------------*

*&spwizard: output module for tc 'CTLTAB_PINS'. do not change this line!
*&spwizard: update lines for equivalent scrollbar
MODULE CTLTAB_PINS_CHANGE_TC_ATTR OUTPUT.
  IF D_DISPMODE = C_DISP_NEW.
    CTLTAB_PINS-LINES = 100.

  ELSEIF D_DISPMODE = C_DISP_CHANGE.
    DESCRIBE TABLE ITAB_PINS LINES CTLTAB_PINS-LINES.
    ADD 1 TO CTLTAB_PINS-LINES.

  ELSE.
    DESCRIBE TABLE ITAB_PINS LINES CTLTAB_PINS-LINES.

  ENDIF.

ENDMODULE.                    "CTLTAB_PINS_change_tc_attr OUTPUT

*&spwizard: output module for tc 'CTLTAB_PINS'. do not change this line!
*&spwizard: get lines of tablecontrol
MODULE CTLTAB_PINS_GET_LINES OUTPUT.
  G_CTLTAB_PINS_LINES = SY-LOOPC.

ENDMODULE.                    "CTLTAB_PINS_get_lines OUTPUT


*&---------------------------------------------------------------------*
*&      Module  DISPMODE_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPMODE_9001 OUTPUT.
  PERFORM F_DISPMODE_9001.
ENDMODULE.                 " DISPMODE_9001  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9001 OUTPUT.
  CLEAR: SY-UCOMM, OK_CODE.
  PERFORM F_STATUS_9001.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_9001  OUTPUT