*&---------------------------------------------------------------------*
*&      Form  FCODE_KPAR_GUI46
*&---------------------------------------------------------------------*
*       Übergang zum Kopfpartnerbild via Subscreen
*----------------------------------------------------------------------*
FORM FCODE_KPAR_GUI46.

  PERFORM PARTNER_PREPARE USING CHARH.

ENHANCEMENT-POINT FCODE_KPAR_GUI46_10 SPOTS ES_SAPMV45A.
ENDFORM.                               " FCODE_KPAR_GUI46