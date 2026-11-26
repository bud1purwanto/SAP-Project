*&---------------------------------------------------------------------*
*&      Form  TCTRL_P_AENDST_DT_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Positionsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_P_AENDST_DT_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBSN LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_P_AENDST_DT-LINES    = DA_TFILL.
  TCTRL_P_AENDST_DT-TOP_LINE = IVBSN_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_P_AENDST_DT'.

ENDFORM.                               " TCTRL_P_AENDST_DT_INIT