*---------------------------------------------------------------------*
*       MODULE TVV2T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Gruppentext                                             *
*---------------------------------------------------------------------*
MODULE TVV2T_SELECT OUTPUT.

  PERFORM TVV2T_SELECT USING VBAK-KVGR2
                             SY-SUBRC.

ENDMODULE.