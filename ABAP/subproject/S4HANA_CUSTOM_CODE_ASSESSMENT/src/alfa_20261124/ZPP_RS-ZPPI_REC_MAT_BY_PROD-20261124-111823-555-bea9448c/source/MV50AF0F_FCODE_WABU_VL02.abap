***INCLUDE MV50AF0F_FCODE_WABU_VL02 .
*---------------------------------------------------------------------*
*       FORM FCODE_WABU_VL02                                          *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges                                     *
*---------------------------------------------------------------------*
FORM FCODE_WABU_VL02.

ENHANCEMENT-SECTION     FCODE_WABU_VL02_01 SPOTS ES_SAPMV50A.
  PERFORM WARENAUSGANG_BUCHEN(SAPFV50W).
  PERFORM FCODE_SICH_OHNE_CHECK.
END-ENHANCEMENT-SECTION.

*APO: safety first
  PERFORM NMODUL_FOR_TCODE_APO.

ENDFORM.