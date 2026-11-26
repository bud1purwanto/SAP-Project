*---------------------------------------------------------------------*
*       MODULE TVLST_SELECT_KOPF                                      *
*---------------------------------------------------------------------*
*       Lesen Liefersperrentext                                       *
*---------------------------------------------------------------------*
MODULE TVLST_SELECT_KOPF OUTPUT.

  PERFORM TVLST_SELECT USING VBAK-LIFSK
                             SPACE
                             SY-SUBRC.

ENDMODULE.