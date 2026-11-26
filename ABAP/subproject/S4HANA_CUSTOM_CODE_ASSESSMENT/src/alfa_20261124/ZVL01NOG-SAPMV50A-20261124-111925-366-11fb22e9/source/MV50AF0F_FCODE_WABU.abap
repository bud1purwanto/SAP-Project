***INCLUDE MV50AF0F_FCODE_WABU .
*---------------------------------------------------------------------*
*       FORM FCODE_WABU                                               *
*---------------------------------------------------------------------*
*       Buchen des Warenausgang                                       *
*---------------------------------------------------------------------*
FORM FCODE_WABU.
ENHANCEMENT-POINT EHP604_FCODE_WABU_01 SPOTS ES_SAPMV50A.

ENHANCEMENT-SECTION     FCODE_WABU_01 SPOTS ES_SAPMV50A.
  PERFORM WARENAUSGANG_BUCHEN(SAPFV50W).
  PERFORM FCODE_SICH_OHNE_CHECK.
END-ENHANCEMENT-SECTION.

ENDFORM.