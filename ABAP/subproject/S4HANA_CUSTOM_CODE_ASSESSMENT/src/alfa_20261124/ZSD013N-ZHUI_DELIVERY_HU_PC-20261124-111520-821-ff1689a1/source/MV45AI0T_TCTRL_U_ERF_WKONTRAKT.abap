*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_ERF_WKONTRAKT_OS_BLAET(TERN)  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls (AKK)
*----------------------------------------------------------------------*
MODULE TCTRL_U_ERF_WKONTRAKT_OS_BLAET INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_WKONTRAKT_OS-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_U_ERF_WKONTRAKT_OS_BLAET(TERN) INPUT

*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_BST_WKONTRAKT_OS_BLAET(TERN)  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls (AKK)
*----------------------------------------------------------------------*
MODULE TCTRL_U_BST_WKONTRAKT_OS_BLAET INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_BST_WKONTRAKT_OS-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_U_BST_WKONTRAKT_OS_BLAET(TERN) INPUT