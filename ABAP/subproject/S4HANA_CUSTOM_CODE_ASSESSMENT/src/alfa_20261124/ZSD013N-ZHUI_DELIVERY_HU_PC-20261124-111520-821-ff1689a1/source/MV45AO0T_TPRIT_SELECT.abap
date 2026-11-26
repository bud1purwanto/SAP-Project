*---------------------------------------------------------------------*
*       MODULE TPRIT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Lieferprioritätstext zur Anzeige                        *
*---------------------------------------------------------------------*
MODULE TPRIT_SELECT OUTPUT.

  PERFORM TPRIT_SELECT USING VBAP-LPRIO
                             SPACE
                             SY-SUBRC.
ENDMODULE.