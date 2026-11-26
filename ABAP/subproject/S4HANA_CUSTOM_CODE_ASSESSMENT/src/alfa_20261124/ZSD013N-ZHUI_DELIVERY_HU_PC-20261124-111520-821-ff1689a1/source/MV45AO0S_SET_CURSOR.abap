*eject
*---------------------------------------------------------------------*
*       MODULE SET_CURSOR                                             *
*---------------------------------------------------------------------*
*       Der Cursor wird ergonomisch auf die Materialnummer gesetzt    *
*       ab 4.6A ex. ein allround-Feld RV45A-MABNR                     *
*---------------------------------------------------------------------*
MODULE SET_CURSOR OUTPUT.

ENHANCEMENT-POINT SET_CURSOR_10 SPOTS ES_SAPMV45A.
  PERFORM SET_CURSOR USING 'RV45A-MABNR'.
*  PERFORM SET_CURSOR USING 'VBAP-MATNR'.


ENDMODULE.