*---------------------------------------------------------------------*
*       MODULE TVM1T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVM1T_SELECT OUTPUT.

  PERFORM TVM1T_SELECT USING VBAP-MVGR1
                             SY-SUBRC.

ENDMODULE.