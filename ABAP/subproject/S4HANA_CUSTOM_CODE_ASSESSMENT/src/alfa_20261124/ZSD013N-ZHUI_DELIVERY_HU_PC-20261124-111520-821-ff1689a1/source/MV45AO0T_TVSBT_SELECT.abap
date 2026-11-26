*eject.
*---------------------------------------------------------------------*
*       MODULE TVSBT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Text zur Versandbedingung                               *
*---------------------------------------------------------------------*
MODULE TVSBT_SELECT OUTPUT.

  PERFORM TVSBT_SELECT USING VBAK-VSBED
                             SPACE
                             SY-SUBRC.

ENDMODULE.