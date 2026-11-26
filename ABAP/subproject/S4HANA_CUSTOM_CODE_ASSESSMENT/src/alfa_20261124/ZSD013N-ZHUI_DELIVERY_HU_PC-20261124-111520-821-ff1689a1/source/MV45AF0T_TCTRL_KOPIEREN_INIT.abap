*&---------------------------------------------------------------------*
*&      Form  TCTRL_KOPIEREN_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_KOPIEREN_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  DESCRIBE TABLE IVBAP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
*  if t185f-trtyp ne 'A'.
*    da_tfill = da_tfill + 1.
*  endif.
  TCTRL_KOPIEREN-LINES    = DA_TFILL.
  TCTRL_KOPIEREN-TOP_LINE = IVBAP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_KOPIEREN'.

ENDFORM.                               " TCTRL_KOPIEREN_INIT

*&---------------------------------------------------------------------*
*&      Form  TCTRL_KOPIEREN_MODIFY
*&---------------------------------------------------------------------*
*       Ausblenden einzelner Spalten des Table-Controls
*----------------------------------------------------------------------*
FORM TCTRL_KOPIEREN_MODIFY.

  DATA: WA_TCTRL_KOPIEREN LIKE LINE OF TCTRL_KOPIEREN-COLS.

* Nicht benötigte Spalten ausblenden
    LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE AND
                        ERLRE EQ CON_ERLRE_WERTKONTRAKT.
      EXIT.
    ENDLOOP.
* Es existieren keine Wertkontraktpositionen --> ausblenden
    IF SY-SUBRC NE 0.
      LOOP AT TCTRL_KOPIEREN-COLS INTO WA_TCTRL_KOPIEREN
                          WHERE SCREEN-NAME = 'MATERW'     OR
                                SCREEN-NAME = 'VBAP-SKOPF' OR
                                SCREEN-NAME = 'VBAP-PRODH'.
        WA_TCTRL_KOPIEREN-INVISIBLE = CHARX.
        MODIFY TCTRL_KOPIEREN-COLS FROM WA_TCTRL_KOPIEREN.
      ENDLOOP.
    ENDIF.


ENDFORM.                               " TCTRL_KOPIEREN_MODIFY