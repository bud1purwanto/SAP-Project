*eject.
*---------------------------------------------------------------------*
*       MODULE T023T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Text zur Warengruppe                                    *
*---------------------------------------------------------------------*
MODULE T023T_SELECT OUTPUT.

  PERFORM T023T_SELECT USING VBAP-MATKL
                             SY-SUBRC.

ENDMODULE.