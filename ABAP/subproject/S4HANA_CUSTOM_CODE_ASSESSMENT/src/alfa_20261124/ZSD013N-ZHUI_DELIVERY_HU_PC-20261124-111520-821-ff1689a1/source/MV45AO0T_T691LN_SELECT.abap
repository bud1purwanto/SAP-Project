*eject.
*---------------------------------------------------------------------*
*       MODULE T691LN_SELECT                                          *
*---------------------------------------------------------------------*
*       Lesen der Texte zum Absicherungsschema und zur Absicherungsf. *
*---------------------------------------------------------------------*
MODULE T691LN_SELECT OUTPUT.

  PERFORM T691LN_SELECT USING VBKD-ABSSC
                              VBAP-ABFOR.

ENDMODULE.