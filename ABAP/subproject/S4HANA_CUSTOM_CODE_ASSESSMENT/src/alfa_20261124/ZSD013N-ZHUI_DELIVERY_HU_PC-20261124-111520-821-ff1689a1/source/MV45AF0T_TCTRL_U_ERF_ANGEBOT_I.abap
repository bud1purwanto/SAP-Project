*&---------------------------------------------------------------------*
*&      Form  TCTRL_U_ERF_ANGEBOT_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Erfassungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_U_ERF_ANGEBOT_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_U_ERF_ANGEBOT-LINES    = DA_TFILL.
  TCTRL_U_ERF_ANGEBOT-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_U_ERF_ANGEBOT'.

ENDFORM.                               " TCTRL_U_ERF_ANGEBOT_INIT