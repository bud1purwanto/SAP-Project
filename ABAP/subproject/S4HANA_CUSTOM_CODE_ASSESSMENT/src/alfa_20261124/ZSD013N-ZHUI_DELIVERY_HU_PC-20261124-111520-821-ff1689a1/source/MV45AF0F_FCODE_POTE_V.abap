*---------------------------------------------------------------------*
*       FORM FCODE_POTE_V                                             *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Gesamtnetzterminierung über T185V        *
*       Retten der Bildfolge wegen Montage mit Fertigungsauftrag      *
*---------------------------------------------------------------------*
FORM FCODE_POTE_V USING H185F STRUCTURE T185F
                        H185  STRUCTURE T185
                        H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM FCODE_POTE.

  T185F-FCODE = FCODE_ZURUECK.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.