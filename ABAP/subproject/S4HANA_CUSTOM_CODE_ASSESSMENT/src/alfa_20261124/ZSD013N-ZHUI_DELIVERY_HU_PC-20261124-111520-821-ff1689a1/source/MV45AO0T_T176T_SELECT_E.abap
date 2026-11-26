*eject.
*---------------------------------------------------------------------*
*       MODULE T176T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Bestellart                                              *
*---------------------------------------------------------------------*
MODULE T176T_SELECT_E OUTPUT.

  PERFORM T176T_SELECT USING VBKD-BSARK_E
                             SPACE
                             SY-SUBRC
                             T176T-VTEXT_E.

ENDMODULE.