*&---------------------------------------------------------------------*
*&      Form  TCTRL_WK_KOPIER_EING_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_WK_KOPIER_EING_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
  TCTRL_WK_KOPIER_EING-LINES    = DA_TFILL.
  TCTRL_WK_KOPIER_EING-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_WK_KOPIER_EING'.

ENDFORM.                    " TCTRL_WK_KOPIER_EING_INIT