*eject.
*---------------------------------------------------------------------*
*       MODULE T176T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Bestellart                                              *
*---------------------------------------------------------------------*
MODULE T176T_SELECT OUTPUT.

  PERFORM T176T_SELECT USING VBKD-BSARK
                             SPACE
                             SY-SUBRC
                             T176T-VTEXT_K.

ENDMODULE.