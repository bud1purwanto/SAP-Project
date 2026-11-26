*&---------------------------------------------------------------------*
*&      Form  TCTRL_POS_STRUKTUR_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*       text
*----------------------------------------------------------------------*
FORM TCTRL_POS_STRUKTUR_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_POS_STRUKTUR-LINES    = DA_TFILL.
  TCTRL_POS_STRUKTUR-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_POS_STRUKTUR'.

ENDFORM.                    " TCTRL_POS_STRUKTUR_INIT