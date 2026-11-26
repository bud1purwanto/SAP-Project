*eject.
*---------------------------------------------------------------------*
*       MODULE T001W_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen des Werkstextes                                         *
*---------------------------------------------------------------------*
MODULE T001W_SELECT OUTPUT.

  PERFORM T001W_SELECT USING VBAP-WERKS
                             SPACE
                             SY-SUBRC.

ENDMODULE.