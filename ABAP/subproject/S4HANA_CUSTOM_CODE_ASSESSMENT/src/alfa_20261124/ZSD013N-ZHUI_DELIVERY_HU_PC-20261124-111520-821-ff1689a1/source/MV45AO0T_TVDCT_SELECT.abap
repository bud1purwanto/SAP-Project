*---------------------------------------------------------------------*
*       MODULE TVDCT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Lieferzeit                                              *
*---------------------------------------------------------------------*
MODULE TVDCT_SELECT OUTPUT.

  PERFORM TVDCT_SELECT USING VBKD-DELCO
                             SPACE
                             SY-SUBRC.

ENDMODULE.