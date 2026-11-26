*---------------------------------------------------------------------*
*       MODULE TVFSP_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Fakturasperre zur Anzeige                               *
*---------------------------------------------------------------------*
MODULE TVFSP_SELECT OUTPUT.

* Fakturasperre
  PERFORM TVFSP_SELECT USING VBAP-FAKSP
                             SPACE
                             SY-SUBRC.

ENDMODULE.