*&---------------------------------------------------------------------*
*&      Form  TCTRL_PEIN_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_PEIN_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.
  IF SVBAP-TABIX > 0.
    READ TABLE XVBAP INDEX SVBAP-TABIX.
    LOOP AT IVBEP WHERE POSNR NE XVBAP-POSNR.
      DELETE TABLE IVBEP.
    ENDLOOP.
  ENDIF.
  DESCRIBE TABLE IVBEP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_PEIN-LINES    = DA_TFILL.
  TCTRL_PEIN-TOP_LINE = IVBEP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_PEIN'.

ENDFORM.                               " TCTRL_PEIN_INIT

*&---------------------------------------------------------------------*
*&      Form  TCTRL_PEIN_ABRUF_INIT
*&---------------------------------------------------------------------*
*       Initialisierung des Table Controls auf dem Einteilungsbild.
*       Es werden sowohl die Anzahl der Zeilen als auch die oberste
*       angezeigte Zeile gesetzt.
*----------------------------------------------------------------------*
FORM TCTRL_PEIN_ABRUF_INIT.

  DATA: DA_TFILL LIKE SY-TABIX.

  IF SVBAP-TABIX > 0.
    READ TABLE XVBAP INDEX SVBAP-TABIX.
    LOOP AT IVBEP WHERE POSNR NE XVBAP-POSNR.
      DELETE TABLE IVBEP.
    ENDLOOP.
  ENDIF.
  DESCRIBE TABLE IVBEP LINES DA_TFILL.
* Falls nicht Anzeige, unten eine freie Eingabezeile bereithalten
  IF T185F-TRTYP NE 'A'.
    DA_TFILL = DA_TFILL + 1.
  ENDIF.
  TCTRL_PEIN_ABRUF-LINES    = DA_TFILL.
  TCTRL_PEIN_ABRUF-TOP_LINE = IVBEP_TABIX_ZEILE_1.
  TCTRL_NAME = 'TCTRL_PEIN_ABRUF'.

ENDFORM.                               " TCTRL_PEIN_ABRUF_INIT