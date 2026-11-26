*---------------------------------------------------------------------*
*       FORM FCODE_SLPR                                               *
*---------------------------------------------------------------------*
*       Übernehmen Schnelländerung Lieferpriorität in die             *
*       betroffenen Positionen                                        *
*---------------------------------------------------------------------*
FORM FCODE_SLPR USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM SCHNELLAENDERUNG_VBAP-LPRIO(SAPFV45P).

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.