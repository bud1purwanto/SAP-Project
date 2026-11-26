*---------------------------------------------------------------------*
*       MODULE TVM3T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVM3T_SELECT OUTPUT.

  PERFORM TVM3T_SELECT USING VBAP-MVGR3
                             SY-SUBRC.

ENDMODULE.