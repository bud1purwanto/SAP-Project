*---------------------------------------------------------------------*
*       FORM FCODE_IMAT_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Material vom Übersichtsbild aus                       *
*---------------------------------------------------------------------*
FORM FCODE_IMAT_U0.

  PERFORM XVBAP_DETAIL(SAPFV45P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
  IF FCODE NE FCODE_GLEICHE_SEITE.
    PERFORM FCODE_IMAT.
  ENDIF.

ENDFORM.