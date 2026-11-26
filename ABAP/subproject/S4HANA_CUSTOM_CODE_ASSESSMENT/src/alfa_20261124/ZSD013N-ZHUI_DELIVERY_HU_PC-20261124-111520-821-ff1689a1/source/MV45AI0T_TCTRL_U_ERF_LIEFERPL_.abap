*----------------------------------------------------------------------*
*   INCLUDE MV45AI0T_TCTRL_U_ERF_LIEFERPL_                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_ERF_Lieferpl_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_U_ERF_LIEFERPL_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_LIEFERPLAN-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_U_ERF_LIEFERPL_BLAETTERN INPUT