*eject.
*---------------------------------------------------------------------*
*       MODULE TVTWT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Vertriebswegetext                                       *
*---------------------------------------------------------------------*
MODULE TVTWT_SELECT OUTPUT.

  PERFORM TVTWT_SELECT USING VBAK-VTWEG
                             SPACE
                             SY-SUBRC.

ENDMODULE.