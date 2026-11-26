*&---------------------------------------------------------------------*
*&      Form  TCTRL_UEIN_VERSAND_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Beschaffungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_UEIN_VERSAND_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_UEIN_VERSAND-LINES    = DA_TFILL.
  TCTRL_UEIN_VERSAND-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_UEIN_VERSAND'.

ENDFORM.                               " TCTRL_UEIN_VERSAND_INIT