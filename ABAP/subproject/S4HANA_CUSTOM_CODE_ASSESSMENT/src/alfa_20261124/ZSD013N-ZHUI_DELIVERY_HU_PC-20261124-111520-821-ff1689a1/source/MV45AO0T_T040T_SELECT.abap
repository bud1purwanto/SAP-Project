*---------------------------------------------------------------------*
*       MODULE T040T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Text zur Mahnsperre                                     *
*---------------------------------------------------------------------*
MODULE T040T_SELECT OUTPUT.

  PERFORM T040T_SELECT USING VBKD-MANSP
                             SY-SUBRC.

ENDMODULE.