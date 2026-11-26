*eject
*---------------------------------------------------------------------*
*       MODULE COBL_SEND_PBO_VBAP                                     *
*---------------------------------------------------------------------*
*       Es wird für die Kostenrechnung                                *
*            der Kommunikationsbereich COBL gefüllt                   *
*                 und an den Codingblock weitergegeben                *
*---------------------------------------------------------------------*
MODULE COBL_SEND_PBO_VBAP OUTPUT.

  PERFORM COBL_SEND_PBO_VBAP(SAPFV45P).

ENDMODULE.