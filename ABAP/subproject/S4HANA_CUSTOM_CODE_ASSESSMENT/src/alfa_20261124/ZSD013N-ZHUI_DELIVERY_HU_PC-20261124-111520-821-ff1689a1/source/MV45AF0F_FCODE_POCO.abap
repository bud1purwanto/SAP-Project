*---------------------------------------------------------------------*
*       FORM FCODE_POCO                                               *
*---------------------------------------------------------------------*
*       Konfiguration angefordert per FCODE -> Verändern,             *
*                                              Objektnummer vorhanden *
*---------------------------------------------------------------------*
FORM FCODE_POCO USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

  PERFORM CONFIGURATION_FCODE_CHANGE(SAPFV45S).


ENHANCEMENT-POINT FCODE_POCO_01 SPOTS ES_SAPMV45A.

  T185F-FCODE = FCODE.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.