*&---------------------------------------------------------------------*
*&      Module  TCTRL_PEIN_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Angleichung des Blättern-Zeigers mit dem Table Control (AKK)
*----------------------------------------------------------------------*
MODULE TCTRL_PEIN_BLAETTERN INPUT.

  IVBEP_TABIX_ZEILE_1 = TCTRL_PEIN-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

  IF TC_SELLINE IS INITIAL             " The cursor is in item header
     AND FCODE EQ 'SHLI'.              " action is double click
    FCODE = 'ITEM'.                    " so we don't change screen
  ENDIF.

ENDMODULE.                 " TCTRL_PEIN_BLAETTERN  INPUT

*&---------------------------------------------------------------------*
*&      Module  TCTRL_PEIN_ABRUF_BLAETTERN  INPUT
*&---------------------------------------------------------------------*
*       Angleichung des Blättern-Zeigers mit dem Table Control (AKK)
*----------------------------------------------------------------------*
MODULE TCTRL_PEIN_ABRUF_BLAETTERN INPUT.

  IVBEP_TABIX_ZEILE_1 = TCTRL_PEIN_ABRUF-TOP_LINE.
  GET CURSOR LINE TC_SELLINE.

ENDMODULE.                 " TCTRL_PEIN_ABRUF_BLAETTERN  INPUT