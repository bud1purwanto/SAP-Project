*---------------------------------------------------------------------*
*       MODULE TVFSP_SELECT_KOPF                                      *
*---------------------------------------------------------------------*
*       Lesen Fakturasperre zur Anzeige                               *
*---------------------------------------------------------------------*
MODULE TVFSP_SELECT_KOPF OUTPUT.

* Fakturasperre
  PERFORM TVFSP_SELECT USING VBAK-FAKSK
                             SPACE
                             SY-SUBRC.

ENDMODULE.