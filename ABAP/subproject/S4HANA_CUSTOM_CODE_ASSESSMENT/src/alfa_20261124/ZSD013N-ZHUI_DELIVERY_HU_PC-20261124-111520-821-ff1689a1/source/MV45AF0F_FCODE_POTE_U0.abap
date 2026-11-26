*---------------------------------------------------------------------*
*       FORM FCODE_POTE_U0                                            *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Gesamtnetzterminierung von einer         *
*       Positionsübersicht aus                                        *
*---------------------------------------------------------------------*
FORM FCODE_POTE_U0.

  LOOP AT IVBAP WHERE SELKZ EQ CHARX.

* Position lesen und WA füllen
    PERFORM XVBAP_LESEN_DIREKT(SAPFV45P) USING IVBAP-POSNR
                                               SVBAP-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
* Gesamtnetzterminierung durchführen
    PERFORM FCODE_POTE.
    PERFORM IVBAP-SELKZ_ABGEARBEITET(SAPFV45P) USING VBAP-POSNR.
    SY-SUBRC = 0.
  ENDLOOP.

* Nichts markiert, aber Cursor auf Positionszeile
  IF SY-SUBRC > 0.
    PERFORM XVBAP_DETAIL(SAPFV45P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
    CHECK FCODE NE FCODE_GLEICHE_SEITE.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM FCODE_POTE.
  ENDIF.

* Eventuell Liefergruppen neu bilden
  PERFORM FCODE_LGKO.

ENDFORM.