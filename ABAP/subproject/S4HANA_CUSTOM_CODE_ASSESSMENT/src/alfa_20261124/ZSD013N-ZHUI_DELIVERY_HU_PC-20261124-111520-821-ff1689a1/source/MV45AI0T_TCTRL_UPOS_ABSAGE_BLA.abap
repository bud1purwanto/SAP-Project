*&---------------------------------------------------------------------*
*&      Module  TCTRL_UPOS_ABSAGE_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_UPOS_ABSAGE_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_UPOS_ABSAGE-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_UPOS_ABSAGE_BLAETTERN  INPUT