*---------------------------------------------------------------------*
*       MODULE TVLST_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Liefersperrentext                                       *
*---------------------------------------------------------------------*
MODULE TVLST_SELECT OUTPUT.

  PERFORM TVLST_SELECT USING VBEP-LIFSP
                             SPACE
                             SY-SUBRC.

ENDMODULE.