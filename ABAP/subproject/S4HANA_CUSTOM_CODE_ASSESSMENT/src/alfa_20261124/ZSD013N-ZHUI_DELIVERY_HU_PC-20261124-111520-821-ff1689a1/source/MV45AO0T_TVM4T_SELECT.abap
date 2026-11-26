*---------------------------------------------------------------------*
*       MODULE TVM4T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVM4T_SELECT OUTPUT.

  PERFORM TVM4T_SELECT USING VBAP-MVGR4
                             SY-SUBRC.

ENDMODULE.