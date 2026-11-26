*---------------------------------------------------------------------*
*       MODULE VERTRIEBSBEREICH_PR                                    *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Vertriebsbereich                              *
*---------------------------------------------------------------------*
MODULE VERTRIEBSBEREICH_PR.

  PERFORM TVTA_SELECT USING VBAK-VKORG
                            VBAK-VTWEG
                            VBAK-SPART.

ENDMODULE.