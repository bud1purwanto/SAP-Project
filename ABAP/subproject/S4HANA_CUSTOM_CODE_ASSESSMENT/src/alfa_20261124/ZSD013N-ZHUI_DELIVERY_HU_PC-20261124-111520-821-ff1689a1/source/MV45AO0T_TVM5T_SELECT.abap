*---------------------------------------------------------------------*
*       MODULE TVM5T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVM5T_SELECT OUTPUT.

  PERFORM TVM5T_SELECT USING VBAP-MVGR5
                             SY-SUBRC.

ENDMODULE.