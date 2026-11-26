*---------------------------------------------------------------------*
*       FORM FCODE_ABBR                                               *
*---------------------------------------------------------------------*
*       Abbrechen auf dem Kopierauswahlbild                           *
*---------------------------------------------------------------------*
FORM FCODE_ABBR.
  PERFORM BELEG_ENTSPERREN USING VBAK-VBELN.
  PERFORM BELEG_INITIALISIEREN.
  PERFORM FCODE_LEAVE(SAPLV00F).
ENDFORM.