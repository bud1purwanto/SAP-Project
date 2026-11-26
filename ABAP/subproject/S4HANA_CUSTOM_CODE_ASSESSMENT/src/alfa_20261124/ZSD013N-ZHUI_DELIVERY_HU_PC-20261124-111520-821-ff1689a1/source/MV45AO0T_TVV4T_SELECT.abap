*---------------------------------------------------------------------*
*       MODULE TVV4T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVV4T_SELECT OUTPUT.

  PERFORM TVV4T_SELECT USING VBAK-KVGR4
                             SY-SUBRC.

ENDMODULE.