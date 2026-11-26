*---------------------------------------------------------------------*
*       MODULE TVKOT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Verkaufsorganisation                                    *
*---------------------------------------------------------------------*
MODULE TVKOT_SELECT OUTPUT.

  PERFORM TVKOT_SELECT USING VBAK-VKORG
                             SPACE
                             SY-SUBRC.

ENDMODULE.