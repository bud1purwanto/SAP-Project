*---------------------------------------------------------------------*
*       FORM SUBSCREEN_600                                            *
*---------------------------------------------------------------------*
*       Ermitteln Subscreen für Dynpro 600 Lieferdaten Lieferpläne    *
*       mit Abrufen                                                   *
*---------------------------------------------------------------------*
FORM SUBSCREEN_600.

  IF VBAK-VBKLT EQ VBKLT_LP_AUSL_AUFT.
    DYNPRO_SUB = '3600'.
  ELSE.
    IF VBAK-VBTYP EQ 'F'.
      DYNPRO_SUB = '2600'.
    ELSE.
      DYNPRO_SUB = '1600'.
    ENDIF.
  ENDIF.

ENDFORM.