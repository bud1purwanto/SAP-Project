*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_ERF_MAIS_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_U_ERF_MAIS_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_MAIS-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_U_ERF_MAIS_BLAETTERN INPUT