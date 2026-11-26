*&---------------------------------------------------------------------*
*&  Include           ZHUI_TRS_HU_DV_O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'PF100'.
  SET TITLEBAR  'TL100'.
  CLEAR OKCODE.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'PF110'.
  SET TITLEBAR 'T110'.

ENDMODULE.                 " STATUS_0110  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TCHU'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TCHU_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE ITDATA LINES TCHU-LINES.
ENDMODULE.                    "TCHU_CHANGE_TC_ATTR OUTPUT