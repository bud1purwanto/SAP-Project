*---------------------------------------------------------------------*
*       MODULE TVM2T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVM2T_SELECT OUTPUT.

  PERFORM TVM2T_SELECT USING VBAP-MVGR2
                             SY-SUBRC.

ENDMODULE.