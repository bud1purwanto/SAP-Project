*---------------------------------------------------------------------*
*       MODULE TVZBT_SELECT                                            *
*---------------------------------------------------------------------*
*       Lesen des Zahlungsbedingungstextes                            *
*---------------------------------------------------------------------*
MODULE TVZBT_SELECT OUTPUT.

  PERFORM TVZBT_SELECT USING VBKD-ZTERM
                             SPACE
                             SY-SUBRC.

ENDMODULE.