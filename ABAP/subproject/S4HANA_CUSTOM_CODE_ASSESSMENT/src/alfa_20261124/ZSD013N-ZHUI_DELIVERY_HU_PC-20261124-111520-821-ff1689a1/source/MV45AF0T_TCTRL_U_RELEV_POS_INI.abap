*&---------------------------------------------------------------------*
*&      Form  TCTRL_U_RELEV_POS_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_U_RELEV_POS_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_U_RELEV_POS-LINES    = DA_TFILL.
  TCTRL_U_RELEV_POS-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_U_RELEV_POS'.

ENDFORM.                    " TCTRL_U_RELEV_POS_INIT