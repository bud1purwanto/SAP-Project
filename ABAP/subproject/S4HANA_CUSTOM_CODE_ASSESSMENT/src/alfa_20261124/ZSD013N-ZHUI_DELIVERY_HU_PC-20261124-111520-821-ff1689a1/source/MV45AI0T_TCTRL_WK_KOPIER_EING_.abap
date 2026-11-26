*&---------------------------------------------------------------------*
*&      Module  TCTRL_WK_KOPIER_EING_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_WK_KOPIER_EING_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_WK_KOPIER_EING-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_WK_KOPIER_EING_BLAETTERN  INPUT