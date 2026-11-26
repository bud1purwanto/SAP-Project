*&---------------------------------------------------------------------*
*&      Module  TCTRL_KOPIEREN_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_KOPIEREN_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_KOPIEREN-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_KOPIEREN_BLAETTERN  INPUT