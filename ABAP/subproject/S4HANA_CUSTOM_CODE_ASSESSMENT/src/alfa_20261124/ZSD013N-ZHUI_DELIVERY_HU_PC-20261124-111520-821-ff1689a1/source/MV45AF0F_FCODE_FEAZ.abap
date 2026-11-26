*---------------------------------------------------------------------*
*       FORM FCODE_FEAZ                                               *
*---------------------------------------------------------------------*
*       Aufruf der Fehlerbehandlungsliste                             *
*---------------------------------------------------------------------*
FORM FCODE_FEAZ.

  FCODE = 'FEFI'.
  PERFORM FCODE_BEARBEITEN.
  PERFORM XVBUV_ANZEIGEN(SAPMV45A).

ENDFORM.