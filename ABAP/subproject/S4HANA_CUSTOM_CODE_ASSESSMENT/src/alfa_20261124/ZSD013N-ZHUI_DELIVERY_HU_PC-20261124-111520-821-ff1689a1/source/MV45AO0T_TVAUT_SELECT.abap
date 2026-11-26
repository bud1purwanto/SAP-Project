*---------------------------------------------------------------------*
*       MODULE TVAUT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Auftragsgrund                                           *
*---------------------------------------------------------------------*
MODULE TVAUT_SELECT OUTPUT.

  PERFORM TVAUT_SELECT USING VBAK-AUGRU
                             SPACE
                             SY-SUBRC.

ENDMODULE.