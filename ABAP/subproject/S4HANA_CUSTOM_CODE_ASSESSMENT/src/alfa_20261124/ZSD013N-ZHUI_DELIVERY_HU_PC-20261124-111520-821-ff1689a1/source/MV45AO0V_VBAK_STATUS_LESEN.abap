*eject
*---------------------------------------------------------------------*
*&      Module  VBAK_STATUS_LESEN  OUTPUT
*&---------------------------------------------------------------------*
*       Die System- und Anwenderstatus werden ins Dynpro gestellt      *
*----------------------------------------------------------------------*
MODULE VBAK_STATUS_LESEN OUTPUT.

  PERFORM STATUS_TEXT_EDIT(SAPFV45P) USING VBAK-OBJNR.

ENDMODULE.