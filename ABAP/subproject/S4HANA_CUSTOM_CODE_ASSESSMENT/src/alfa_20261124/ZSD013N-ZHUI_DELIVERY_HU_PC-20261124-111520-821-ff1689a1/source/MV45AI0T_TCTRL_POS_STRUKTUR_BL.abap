*&---------------------------------------------------------------------*
*&      Module  TCTRL_POS_STRUKTUR_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_POS_STRUKTUR_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_POS_STRUKTUR-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_POS_STRUKTUR_BLAETTERN  INPUT