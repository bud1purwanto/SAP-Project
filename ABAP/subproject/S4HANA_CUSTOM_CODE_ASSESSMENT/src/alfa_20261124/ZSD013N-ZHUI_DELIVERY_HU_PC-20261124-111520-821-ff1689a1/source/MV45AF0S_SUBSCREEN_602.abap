*eject
*---------------------------------------------------------------------*
*       FORM SUBSCREEN_602                                            *
*---------------------------------------------------------------------*
*       Ermitteln Subscreen für Dynpro 602 Lieferdaten Lieferpläne    *
*       mit Abrufen                                                   *
*---------------------------------------------------------------------*
FORM SUBSCREEN_602.

  CASE VBAK-VBKLT.
    WHEN SPACE.
      DYNPRO_SUB = '1602'.
    WHEN VBKLT_LP_EDL.
      DYNPRO_SUB = '2602'.
    WHEN VBKLT_LP_AUSL_AUFT.
      DYNPRO_SUB = '3602'.
  ENDCASE.

ENDFORM.