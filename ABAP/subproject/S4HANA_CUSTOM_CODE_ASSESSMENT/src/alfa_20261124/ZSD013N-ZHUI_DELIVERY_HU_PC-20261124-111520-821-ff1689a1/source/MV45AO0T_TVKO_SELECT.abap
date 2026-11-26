*---------------------------------------------------------------------*
*       MODULE TVKO_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen Daten zur Verkaufsorganisation                          *
*---------------------------------------------------------------------*
MODULE TVKO_SELECT OUTPUT.

  PERFORM TVKO_SELECT USING VBAK-VKORG
                            SPACE
                            SY-SUBRC.

ENDMODULE.