***INCLUDE MV45AO0F_FAUF_STATUS_LESEN .
*&---------------------------------------------------------------------*
*&      Module  FAUF_STATUS_LESEN  OUTPUT
*&---------------------------------------------------------------------*
*       System- und Anwenderstatus bereitstellen
*----------------------------------------------------------------------*
MODULE FAUF_STATUS_LESEN OUTPUT.

  PERFORM FAUF_STATUS_LESEN(SAPFV45E) USING VBEP-AUFNR.

ENDMODULE.                 " FAUF_STATUS_LESEN  OUTPUT