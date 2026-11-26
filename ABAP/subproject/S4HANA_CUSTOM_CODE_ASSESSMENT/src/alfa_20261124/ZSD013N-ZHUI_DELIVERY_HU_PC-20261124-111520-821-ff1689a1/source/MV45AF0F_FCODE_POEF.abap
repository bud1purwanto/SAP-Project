*---------------------------------------------------------------------*
*       FORM FCODE_POEF                                               *
*---------------------------------------------------------------------*
*       Ändern der Effectivity-Bewertung                              *
*---------------------------------------------------------------------*
FORM FCODE_POEF USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM EFFECTIVITY_FCODE_CHANGE(SAPFV45S).

  T185F-FCODE = FCODE.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.