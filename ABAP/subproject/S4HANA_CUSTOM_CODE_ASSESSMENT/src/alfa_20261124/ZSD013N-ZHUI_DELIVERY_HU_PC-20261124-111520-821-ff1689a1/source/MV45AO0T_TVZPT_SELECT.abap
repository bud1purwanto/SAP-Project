*---------------------------------------------------------------------*
*       MODULE TVZPT_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen des Planabrufvorschrifttextes                            *
*---------------------------------------------------------------------*
MODULE TVZPT_SELECT OUTPUT.

  PERFORM TVZPT_SELECT USING VBAP-PLAVO
                             SPACE
                             SY-SUBRC.

ENDMODULE.