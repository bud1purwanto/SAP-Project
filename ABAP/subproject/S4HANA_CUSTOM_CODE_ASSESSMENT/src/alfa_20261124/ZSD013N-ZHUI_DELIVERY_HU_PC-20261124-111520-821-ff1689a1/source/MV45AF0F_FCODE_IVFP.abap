*---------------------------------------------------------------------*
*       FORM FCODE_IVFP                                               *
*---------------------------------------------------------------------*
*       Anzeige Materialverfügbarkeit                                 *
*---------------------------------------------------------------------*
FORM FCODE_IVFP USING US_T185F US_T185 US_T185V.


  T185  = US_T185.
  T185F = US_T185F.
  T185V = US_T185V.

  IF VBAP-MATNR NE XVBAP-MATNR.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
  ENDIF.


  IF VBAP-WERKS EQ SPACE.
    MESSAGE I186 WITH VBAP-POSNR.
    EXIT.
  ENDIF.
  IF VBAP-MTVFP EQ SPACE OR
     VBAP-PROSA CA 'AC'.
    MESSAGE I278 WITH VBAP-POSNR.
    EXIT.
  ENDIF.

* Zusagedaten werden verwaltet
  IF NOT TVAK-DELCF IS INITIAL.
* Zusagedaten aus den Einteilungen löschen
      PERFORM VBEP_ZUSAGE_BERECHNEN(SAPFV45E) USING VBAP-VBELN
                                                    VBAP-POSNR
                                                    SPACE.
  ENDIF.

  PERFORM VERFUEGBARKEIT_ANZEIGEN(SAPFV45V).

* Zusagedaten wieder einmischen
  IF NOT TVAK-DELCF IS INITIAL.
    PERFORM VBEP_ZUSAGE_ERMITTELN(SAPFV45E) USING VBAP-VBELN
                                                  VBAP-POSNR.
  ENDIF.

  US_T185  = T185.
  US_T185F = T185F.
  US_T185V = T185V.

ENDFORM.