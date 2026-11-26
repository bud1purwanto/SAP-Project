*&---------------------------------------------------------------------*
*&      FORM  WERTKONTRAKTUEBERNAHME_POS
*&---------------------------------------------------------------------*
*       Übernahme von Materialien aus Wertkontrakt, Sortiment zum      *
*       Wertkontrakt oder eingegebenen Materialien zum Wertkontrakt    *
*       in einen Abrufauftrag.                                         *
*----------------------------------------------------------------------*
FORM  WERTKONTRAKTUEBERNAHME_POS CHANGING US_SUBRC.

  DATA: DA_WKKOP LIKE TVCPA-WKKOP,
        DA_PSTYN LIKE TVCPA-PSTYN.

* IVBAP muß aufgebaut werden mit allen Positionen, die neu hinzugekommen
* sind (UPDKZ = 'I') oder die Selektionskennzeichen haben.
* Das Selektionskennzeichen muß anschließend gesetzt werden.

  CLEAR US_SUBRC.

* Nur durchführen, wenn Wertkontraktposition involviert ist
  READ TABLE XVBAP WITH KEY ERLRE = CON_ERLRE_WERTKONTRAKT.
  CHECK SY-SUBRC = 0.

* Selektionskennzeichen bei nicht kopierbaren WK-Positionen entfernen
  LOOP AT IVBAP.
    IF IVBAP-SELKZ EQ SELEKTIERT.
* Wenn in Kopiersteuerung das Kopieren des Wertkontraktmaterials
* verboten ist, aus Selektionskennzeichen zurücksetzen
      READ TABLE XVBAP INDEX IVBAP-TABIX.
      IF XVBAP-ERLRE EQ CON_ERLRE_WERTKONTRAKT.
        PERFORM WERTKONTRAKT_KOPIEREN_PRUEFEN USING DA_WKKOP
                                                    TVCPA-AUARN
                                                    TVCPA-AUARV
                                                    TVCPA-FKARV
                                                    SPACE
                                                    XVBAP-PSTYV
                                                    DA_PSTYN.
*       Es darf nicht kopiert werden
        IF DA_WKKOP EQ CHARA.
          CLEAR IVBAP-SELKZ.
          MODIFY IVBAP.
          US_SUBRC = 1.
*       Es darf kopiert werden
        ELSE.
          READ TABLE XVBAP INDEX IVBAP-TABIX.
          XVBAP-VGPOS_WK = XVBAP-POSNR.
          MODIFY XVBAP INDEX IVBAP-TABIX.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF US_SUBRC = 1.
    EXIT.
  ENDIF.

* Nicht selektierte Einträge aus IVBAP entfernen
  LOOP AT IVBAP.
    IF IVBAP-SELKZ NE SELEKTIERT.
      DELETE IVBAP.
    ENDIF.
  ENDLOOP.

* Setzen des Selektionskennzeichens
  RV45A-VBAP_SELKZ = SELEKTIERT.
* Neu hinzugekommene Positionen in IVBAP aufnehmen
  LOOP AT XVBAP WHERE UPDKZ EQ UPDKZ_NEW.
    PERFORM WERTKONTRAKT_DATENUEBERNAHME.
    VBAP = XVBAP.
    PERFORM IVBAP_ANLEGEN(SAPFV45P) USING SY-TABIX.
  ENDLOOP.
  CLEAR RV45A-VBAP_SELKZ.

ENDFORM.                    "WERTKONTRAKTUEBERNAHME_POS