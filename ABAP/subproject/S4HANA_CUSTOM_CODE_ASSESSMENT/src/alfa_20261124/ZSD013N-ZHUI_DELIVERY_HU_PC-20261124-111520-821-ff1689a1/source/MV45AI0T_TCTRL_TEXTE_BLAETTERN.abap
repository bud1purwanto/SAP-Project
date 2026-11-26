*&---------------------------------------------------------------------*
*&      Module  TCTRL_TEXTE_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_TEXTE_BLAETTERN INPUT.

  ITHEAD_TABIX_ZEILE_1 = TCTRL_TEXTE-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_TEXTE_BLAETTERN  INPUT