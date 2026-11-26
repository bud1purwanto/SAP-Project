*---------------------------------------------------------------------*
*       MODULE TVV1T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVV1T_SELECT OUTPUT.

  PERFORM TVV1T_SELECT USING VBAK-KVGR1
                             SY-SUBRC.

ENDMODULE.