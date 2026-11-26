*&---------------------------------------------------------------------*
*&      Module  TCTRL_U_ERF_ANGEBOT_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Anpassen des Tabellenzeigers an die Scroll-Position des
*       Table Controls
*----------------------------------------------------------------------*
MODULE TCTRL_U_ERF_ANGEBOT_BLAETTERN INPUT.

  IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_ANGEBOT-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

  IF TC_SELLINE IS INITIAL             " The cursor is in heade screen
     AND FCODE EQ 'ITEM'.              " action is double click
    FCODE = 'KKAU'.                    " so we go to head detail
  ENDIF.

ENDMODULE.                 " TCTRL_U_ERF_ANGEBOT_BLAETTERN  INPUT