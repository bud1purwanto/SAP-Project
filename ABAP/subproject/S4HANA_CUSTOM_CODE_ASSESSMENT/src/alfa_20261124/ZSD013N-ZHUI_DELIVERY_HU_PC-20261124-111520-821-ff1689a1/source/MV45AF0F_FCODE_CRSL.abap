*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_CRSL                                        *
*----------------------------------------------------------------------*

FORM FCODE_CRSL USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185F = H185F.
  T185  = H185.
  T185V = H185V.

  PERFORM CROSS_SELL_FCODE_POPUP(SAPFV45P).

  T185F-FCODE = FCODE_ZURUECK.
  H185F = T185F.
  H185  = T185.
  H185V = T185V.

ENDFORM.