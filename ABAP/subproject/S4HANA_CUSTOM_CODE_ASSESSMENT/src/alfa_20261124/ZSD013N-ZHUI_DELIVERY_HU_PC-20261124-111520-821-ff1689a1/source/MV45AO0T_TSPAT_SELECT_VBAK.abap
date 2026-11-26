*---------------------------------------------------------------------*
*       MODULE TSPAT_SELECT_VBAK                                      *
*---------------------------------------------------------------------*
*       Lesen Sparte zur Anzeige                                      *
*---------------------------------------------------------------------*
MODULE TSPAT_SELECT_VBAK OUTPUT.

* Sparte
  PERFORM TSPAT_SELECT USING VBAK-SPART
                             SPACE
                             SY-SUBRC.
ENDMODULE.