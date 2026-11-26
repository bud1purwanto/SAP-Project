*eject.
*---------------------------------------------------------------------*
*       MODULE T189T_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen der Preislistengruppe                                   *
*---------------------------------------------------------------------*
MODULE T189T_SELECT OUTPUT.

  PERFORM T189T_SELECT USING VBKD-PLTYP
                             SPACE
                             SY-SUBRC.

ENDMODULE.