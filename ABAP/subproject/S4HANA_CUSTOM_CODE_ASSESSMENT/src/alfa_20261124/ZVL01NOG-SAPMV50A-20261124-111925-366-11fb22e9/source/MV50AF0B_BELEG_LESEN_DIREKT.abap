*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_LESEN_DIREKT                                *
*----------------------------------------------------------------------*
FORM BELEG_LESEN_DIREKT USING IF_VBELN LIKE LIKP-VBELN.
  LIKP-VBELN = IF_VBELN.
  PERFORM BELEG_LESEN.
ENDFORM.