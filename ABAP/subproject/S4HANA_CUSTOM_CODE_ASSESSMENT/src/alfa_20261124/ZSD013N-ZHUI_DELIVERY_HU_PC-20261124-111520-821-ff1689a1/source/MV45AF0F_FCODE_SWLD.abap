*---------------------------------------------------------------------*
*       FORM FCODE_SWLD                                               *
*---------------------------------------------------------------------*
*       Übernehmen Schnelländerung Lieferdatum in betroffene          *
*       Positionen                                                    *
*---------------------------------------------------------------------*
FORM FCODE_SWLD USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM SCHNELLAENDERUNG_EDATU(SAPFV45E).

  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENHANCEMENT-POINT FCODE_SWLD_10 SPOTS ES_SAPMV45A.
ENDFORM.