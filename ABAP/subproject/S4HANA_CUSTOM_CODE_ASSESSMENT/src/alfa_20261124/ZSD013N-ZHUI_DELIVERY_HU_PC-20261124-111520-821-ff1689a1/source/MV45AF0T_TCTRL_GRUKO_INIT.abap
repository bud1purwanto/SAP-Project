*---------------------------------------------------------------------*
*       FORM TCTRL_GRUKO_INIT                                         *
*---------------------------------------------------------------------*
*      Initialisierung des Table Controls auf dem Erfassungsbild.
*      Es werden sowohl die Anzahl der Zeilen als auch die oberste
*      angezeigte Zeile gesetzt.
*---------------------------------------------------------------------*
FORM TCTRL_GRUKO_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

* Tabix fuer Lesen auf Tabix der ersten Zeile der Seite setzen
  IF GRUKO_TABIX_ZEILE_1 EQ 0.
    GRUKO_TABIX_AKTUELL = 1.
  ELSE.
    GRUKO_TABIX_AKTUELL = GRUKO_TABIX_ZEILE_1.
  ENDIF.

  DESCRIBE TABLE GRUKO LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
* if t185f-trtyp ne 'A'.
*   da_tfill = da_tfill + 1.
* endif.
  TCTRL_GRUKO-LINES = DA_TFILL.
  TCTRL_GRUKO-TOP_LINE = GRUKO_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_GRUKO'.
ENDFORM.                               " TCTRL_GRUKO_INIT