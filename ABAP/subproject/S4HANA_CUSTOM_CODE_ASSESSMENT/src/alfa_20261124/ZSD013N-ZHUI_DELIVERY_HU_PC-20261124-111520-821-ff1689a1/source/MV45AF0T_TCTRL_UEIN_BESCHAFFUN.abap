*&---------------------------------------------------------------------*
*&      Form  TCTRL_UEIN_BESCHAFFUNG_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Beschaffungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*       text
*----------------------------------------------------------------------*
FORM TCTRL_UEIN_BESCHAFFUNG_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBEP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_UEIN_BESCHAFFUNG-LINES    = DA_TFILL.
  TCTRL_UEIN_BESCHAFFUNG-TOP_LINE = IVBEP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_UEIN_BESCHAFFUNG'.

ENDFORM.                               " TCTRL_UEIN_BESCHAFFUNG_INIT