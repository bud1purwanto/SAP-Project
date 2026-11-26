*eject.
*---------------------------------------------------------------------*
*       MODULE T003P_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen der Auftragsart für PP-Aufträge                         *
*---------------------------------------------------------------------*
MODULE T003P_SELECT OUTPUT.

  PERFORM T003P_SELECT USING T459K-AUART
                             SPACE
                             SY-SUBRC.

ENDMODULE.