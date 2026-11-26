*---------------------------------------------------------------------*
*       MODULE TVV3T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVV3T_SELECT OUTPUT.

  PERFORM TVV3T_SELECT USING VBAK-KVGR3
                             SY-SUBRC.

ENDMODULE.