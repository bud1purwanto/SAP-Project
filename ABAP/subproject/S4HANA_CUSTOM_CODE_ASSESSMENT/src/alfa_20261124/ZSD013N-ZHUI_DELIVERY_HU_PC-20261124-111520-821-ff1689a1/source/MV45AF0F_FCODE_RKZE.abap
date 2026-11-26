*---------------------------------------------------------------------*
*       FORM FCODE_RKZE                                               *
*---------------------------------------------------------------------*
*       Status 'KZEN' für Reparaturabwicklung manuell setzen          *
*---------------------------------------------------------------------*
FORM FCODE_RKZE.

* Setzen Kaufmännisch zu entscheiden
  PERFORM STATUS_SETZEN(SAPFV45P)
    USING STATUS_KZEN CHARX.
  PERFORM STATUS_LOESCHEN(SAPFV45P)
    USING STATUS_KENT CHARX.

* Setzen Repariert
  PERFORM STATUS_SETZEN(SAPFV45P)
    USING STATUS_REPA CHARX.
  PERFORM STATUS_LOESCHEN(SAPFV45P)
    USING STATUS_IREP CHARX.
  PERFORM STATUS_LOESCHEN(SAPFV45P)
    USING STATUS_TREP CHARX.

ENDFORM.