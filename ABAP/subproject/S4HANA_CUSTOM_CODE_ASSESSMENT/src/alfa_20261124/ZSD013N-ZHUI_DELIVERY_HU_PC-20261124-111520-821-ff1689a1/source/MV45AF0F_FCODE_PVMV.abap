*---------------------------------------------------------------------*
*       FORM FCODE_PVMV                                               *
*---------------------------------------------------------------------*
*       Menge aus Produktvorschlag vorschlagen                        *
*---------------------------------------------------------------------*
FORM FCODE_PVMV.

* Produktvorschlag aktiv ?
  CHECK NOT DPP_ACTIVE IS INITIAL.

  DPP_QUANTITY = CHARX.

* Menge übernehmen und 'echte' Positionen erzeugen
  LOOP AT XVBAP WHERE UPDKZ   <> UPDKZ_DELETE
                  AND PVPOS   <> SPACE
                  AND PVMNG01 <> 0
                  AND KWMENG  =  0.

* Bearbeiten der Positionsdaten
    SVBAP-TABIX = SY-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    RV45A-KWMENG = XVBAP-PVMNG01.
    PERFORM VBAP_FUELLEN(SAPFV45P).
    PERFORM VBAP_BEARBEITEN(SAPFV45P).
* Bearbeiten der Einteilungsdaten
    SVBEP-TABIX = 0.
    PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).
    VBEP-WMENG = XVBAP-PVMNG01.
    PERFORM VBEP_FUELLEN(SAPFV45E).
    PERFORM VBEP-CMENG_ERMITTELN(SAPFV45E).
    PERFORM VBEP_BEARBEITEN(SAPFV45E).
* Abschlußbearbeitung
    VBAP_ENDE_BEARBEITUNG    = CHARX.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
    VBAP_PRUEFEN             = CHARX.
    PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).

  ENDLOOP.

  CLEAR DPP_QUANTITY.

* Die Auftragsmengen aus dem letzten Auftrag wurden vorgeschlagen
  IF SY-SUBRC EQ 0.
    MESSAGE S220(V2).
  ENDIF.

ENDFORM.