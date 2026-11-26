*---------------------------------------------------------------------*
*       MODULE TVSTT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen des Versandstellentextes                                *
*---------------------------------------------------------------------*
MODULE TVSTT_SELECT OUTPUT.

  PERFORM TVSTT_SELECT USING VBAP-VSTEL
                             SPACE
                             SY-SUBRC.

ENDMODULE.