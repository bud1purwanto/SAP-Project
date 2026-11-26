*---------------------------------------------------------------------*
*       FORM FCODE_PORE_U0                                            *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Verfügbarkeitsprüfung von einer          *
*       Positionsübersicht aus                                        *
*---------------------------------------------------------------------*
FORM FCODE_PORE_U0.

  LOOP AT IVBAP WHERE SELKZ EQ CHARX.
* Position lesen und WA füllen
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING IVBAP-POSNR
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
* Verfügbarkeit prüfen
    PERFORM FCODE_PORE.
ENHANCEMENT-SECTION     FCODE_PORE_U0_01 SPOTS ES_SAPMV45A.
    PERFORM IVBAP-SELKZ_ABGEARBEITET(SAPFV45P) USING VBAP-POSNR.
END-ENHANCEMENT-SECTION.
  ENDLOOP.

* Nichts markiert, aber Cursor auf Positonszeile
  IF SY-SUBRC NE 0.
    PERFORM XVBAP_DETAIL(SAPFV45P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
    CHECK FCODE NE FCODE_GLEICHE_SEITE.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM FCODE_PORE.
  ENDIF.

* Ergebnisse der Gruppenprüfung abholen
  IF ATP_GRUPPENAUFRUF EQ CHARX.
    PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P) USING VERARB_HELL.
  ENDIF.

* Eventuell Liefergruppen neu bilden
  PERFORM FCODE_LGKO.

ENDFORM.