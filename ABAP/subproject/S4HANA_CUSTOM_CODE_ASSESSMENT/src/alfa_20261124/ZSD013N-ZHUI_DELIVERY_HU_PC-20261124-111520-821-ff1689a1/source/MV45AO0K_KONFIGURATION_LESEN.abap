*---------------------------------------------------------------------*
*       MODULE KONFIGURATION_LESEN                                    *
*---------------------------------------------------------------------*
*       Lesen Konfigurationsdaten                                     *
*---------------------------------------------------------------------*
MODULE KONFIGURATION_LESEN OUTPUT.

  PERFORM KONFIGURATION_LESEN(SAPFV45P) USING VBAP-POSNR
                                              VBAP-CUOBJ.

ENDMODULE.