*---------------------------------------------------------------------*
*       MODULE TKKAD_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Text zum Abgrenzungsschlüssel                           *
*---------------------------------------------------------------------*
MODULE TKKAD_SELECT OUTPUT.

  PERFORM TKKAD_SELECT USING VBAP-ABGRS
                             SY-SUBRC.
ENDMODULE.