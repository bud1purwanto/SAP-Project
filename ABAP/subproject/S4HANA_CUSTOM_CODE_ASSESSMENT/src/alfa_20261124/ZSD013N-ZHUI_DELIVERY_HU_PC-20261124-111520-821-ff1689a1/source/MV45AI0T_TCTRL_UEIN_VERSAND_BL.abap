*&---------------------------------------------------------------------*
*&      Module  TCTRL_UEIN_VERSAND_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Angleichung des Blättern-Zeigers mit dem Table Control
*----------------------------------------------------------------------*
MODULE TCTRL_UEIN_VERSAND_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_UEIN_VERSAND-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_UEIN_VERSAND_BLAETTERN  INPUT