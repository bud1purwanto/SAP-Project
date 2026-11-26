*&---------------------------------------------------------------------*
*&  Include           ZPPI_PO_RAW_RECYCLE_O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  PERFORM F_INITIAL_SLOC_GI.
  SET PF-STATUS 'PF100'.
  SET TITLEBAR 'T100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'PF110' .
  SET TITLEBAR 'T110'.
ENDMODULE.                 " STATUS_0110  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'PF120'.
  SET TITLEBAR  'T120'.
ENDMODULE.                 " STATUS_0120  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TABCCTL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TABCCTL_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITDATA LINES TABCCTL-LINES.
ENDMODULE.                    "TABCCTL_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCORDER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TCORDER_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITORDER LINES TCORDER-LINES.
ENDMODULE.                    "TCORDER_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCORDER'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE TCORDER_GET_LINES OUTPUT.
  G_TCORDER_LINES = SY-LOOPC.
ENDMODULE.                    "TCORDER_GET_LINES OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TABCCTL_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TABCCTL_GET_LINES OUTPUT.
  G_TABCCTL_LINES = SY-LOOPC.

  IF WADATA-AUFNR NE ''.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'WADATA-SLOCGR'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " TABCCTL_GET_LINES  OUTPUT