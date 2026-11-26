*---------------------------------------------------------------------*
*       MODULE T040A_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Text zum Mahnschlüssel                                  *
*---------------------------------------------------------------------*
MODULE T040A_SELECT OUTPUT.

  PERFORM T040A_SELECT USING VBKD-MSCHL
                             SY-SUBRC.

ENDMODULE.