*eject.
*&---------------------------------------------------------------------*
*&      Module  RV45A_TVAPT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Lesen Positionstypentext
*----------------------------------------------------------------------*
MODULE RV45A_TVAPT_SELECT OUTPUT.

  PERFORM TVAPT_SELECT USING RV45A-PSTYV
                             SPACE
                             SY-SUBRC.

ENDMODULE.