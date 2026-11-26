*---------------------------------------------------------------------*
*       MODULE TSPAT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Sparte zur Anzeige                                      *
*---------------------------------------------------------------------*
MODULE TSPAT_SELECT OUTPUT.

* Sparte
  PERFORM TSPAT_SELECT USING VBAP-SPART
                             SPACE
                             SY-SUBRC.
ENDMODULE.