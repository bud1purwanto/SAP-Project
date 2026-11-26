*---------------------------------------------------------------------*
*       MODULE TVAPT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Positionstypentext                                      *
*---------------------------------------------------------------------*
MODULE TVAPT_SELECT OUTPUT.

  PERFORM TVAPT_SELECT USING VBAP-PSTYV
                             SPACE
                             SY-SUBRC.

ENDMODULE.