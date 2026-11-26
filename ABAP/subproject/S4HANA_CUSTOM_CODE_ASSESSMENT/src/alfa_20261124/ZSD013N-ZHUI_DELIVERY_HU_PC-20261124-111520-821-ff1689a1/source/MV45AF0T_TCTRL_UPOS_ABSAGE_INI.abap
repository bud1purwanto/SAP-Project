*&---------------------------------------------------------------------*
*&      Form  TCTRL_UPOS_ABSAGE_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Erfassungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_UPOS_ABSAGE_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_UPOS_ABSAGE-LINES    = DA_TFILL.
  TCTRL_UPOS_ABSAGE-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_UPOS_ABSAGE'.

ENDFORM.                               " TCTRL_UPOS_ABSAGE_INIT