***INCLUDE MV50AF0F_FCODE_IBST_UO .
*---------------------------------------------------------------------*
*       FORM FCODE_IBST_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Bestände vom Übersichtsbild aus                       *
*---------------------------------------------------------------------*
FORM FCODE_IBST_U0.

* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
  IF FCODE NE FCODE_GLEICHE_SEITE.
    PERFORM FCODE_IBST.
  ENDIF.

ENDFORM.