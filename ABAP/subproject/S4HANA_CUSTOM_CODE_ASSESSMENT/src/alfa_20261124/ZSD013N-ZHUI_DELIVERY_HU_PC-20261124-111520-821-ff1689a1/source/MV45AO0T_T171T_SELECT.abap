*eject.
*---------------------------------------------------------------------*
*       MODULE T171T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen des Bezirks                                             *
*---------------------------------------------------------------------*
MODULE T171T_SELECT OUTPUT.

  PERFORM T171T_SELECT USING VBKD-BZIRK
                             SPACE
                             SY-SUBRC.

ENDMODULE.