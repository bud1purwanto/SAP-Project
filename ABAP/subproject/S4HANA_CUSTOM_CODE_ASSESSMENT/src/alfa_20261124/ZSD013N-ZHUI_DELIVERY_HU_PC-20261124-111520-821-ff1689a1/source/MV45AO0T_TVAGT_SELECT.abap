*---------------------------------------------------------------------*
*       MODULE TVAGT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Absagegrund zur Anzeige                                 *
*---------------------------------------------------------------------*
MODULE TVAGT_SELECT OUTPUT.

* Absagegrund
  PERFORM TVAGT_SELECT USING VBAP-ABGRU
                             SPACE
                             SY-SUBRC.

ENDMODULE.