*---------------------------------------------------------------------*
*       FORM FCODE_RANG                                               *
*---------------------------------------------------------------------*
*       Ein Angebot soll kopiert werden.                              *
*---------------------------------------------------------------------*
FORM FCODE_RANG USING T185F T185 T185V.

  CLEAR CVBRK.
  CLEAR CVBPA. REFRESH CVBPA.

ENHANCEMENT-POINT FCODE_RANG_01 SPOTS ES_SAPMV45A.
  PERFORM BELEG_KOPIEREN USING T185F T185 T185V.

ENDFORM.