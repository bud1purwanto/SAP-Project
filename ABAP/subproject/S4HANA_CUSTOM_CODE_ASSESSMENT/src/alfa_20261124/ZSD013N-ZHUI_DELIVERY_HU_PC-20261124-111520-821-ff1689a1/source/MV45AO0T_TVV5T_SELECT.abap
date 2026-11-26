*---------------------------------------------------------------------*
*       MODULE TVV5T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVV5T_SELECT OUTPUT.

  PERFORM TVV5T_SELECT USING VBAK-KVGR5
                             SY-SUBRC.

ENDMODULE.