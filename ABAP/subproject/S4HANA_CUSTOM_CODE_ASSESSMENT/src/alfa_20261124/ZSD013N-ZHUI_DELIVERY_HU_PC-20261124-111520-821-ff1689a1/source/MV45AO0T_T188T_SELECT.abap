*eject.
*---------------------------------------------------------------------*
*       MODULE T188T_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen der Konditionsgruppe                                    *
*---------------------------------------------------------------------*
MODULE T188T_SELECT OUTPUT.

  PERFORM T188T_SELECT USING VBKD-KONDA
                             SPACE
                             SY-SUBRC.

ENDMODULE.