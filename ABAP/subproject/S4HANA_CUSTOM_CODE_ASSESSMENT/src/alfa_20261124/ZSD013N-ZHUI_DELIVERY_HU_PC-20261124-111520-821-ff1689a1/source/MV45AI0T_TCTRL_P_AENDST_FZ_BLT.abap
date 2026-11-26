*&---------------------------------------------------------------------*
*&      Module  TCTRL_P_AENDST_FZ_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_P_AENDST_FZ_BLAETTERN INPUT.

  IVBSN_TABIX_ZEILE_1 = TCTRL_P_AENDST_FZ-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_P_AENDST_FZ_BLAETTERN INPUT