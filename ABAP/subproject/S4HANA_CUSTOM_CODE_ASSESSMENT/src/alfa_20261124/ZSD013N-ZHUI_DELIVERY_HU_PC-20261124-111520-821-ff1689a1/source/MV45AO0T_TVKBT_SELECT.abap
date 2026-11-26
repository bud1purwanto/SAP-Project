*eject.
*---------------------------------------------------------------------*
*       MODULE TVKBT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Verkaufsbürotext                                        *
*---------------------------------------------------------------------*
MODULE TVKBT_SELECT OUTPUT.

  PERFORM TVKBT_SELECT USING VBAK-VKBUR
                             SPACE
                             SY-SUBRC.

ENDMODULE.