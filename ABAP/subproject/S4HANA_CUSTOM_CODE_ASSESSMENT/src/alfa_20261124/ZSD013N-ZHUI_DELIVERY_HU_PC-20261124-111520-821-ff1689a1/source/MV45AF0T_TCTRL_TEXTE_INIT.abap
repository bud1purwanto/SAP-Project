*&---------------------------------------------------------------------*
*&      Form  TCTRL_TEXTE_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_TEXTE_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE ITHEAD LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_TEXTE-LINES    = DA_TFILL.
  TCTRL_TEXTE-TOP_LINE = ITHEAD_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_TEXTE'.

ENDFORM.                    " TCTRL_TEXTE_INIT