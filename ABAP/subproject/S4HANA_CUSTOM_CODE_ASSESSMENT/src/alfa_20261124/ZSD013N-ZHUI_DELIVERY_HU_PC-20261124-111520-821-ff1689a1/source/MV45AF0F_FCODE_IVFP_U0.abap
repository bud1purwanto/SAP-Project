*---------------------------------------------------------------------*
*       FORM FCODE_IVFP_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Materialverfügbarkeit vom Übersichtsbild aus          *
*---------------------------------------------------------------------*
FORM FCODE_IVFP_U0.

  PERFORM XVBAP_DETAIL(SAPFV45P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
  IF FCODE NE FCODE_GLEICHE_SEITE.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
*   PERFORM FCODE_IVFP.
  ENDIF.

ENDFORM.