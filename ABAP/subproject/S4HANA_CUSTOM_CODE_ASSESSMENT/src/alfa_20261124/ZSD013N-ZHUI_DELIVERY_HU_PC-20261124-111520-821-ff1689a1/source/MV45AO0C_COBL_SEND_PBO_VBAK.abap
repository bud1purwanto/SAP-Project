*eject
*---------------------------------------------------------------------*
*       MODULE COBL_SEND_PBO_VBAK                                     *
*---------------------------------------------------------------------*
*       Es wird für die Kostenrechnung                                *
*            der Kommunikationsbereich COBL gefüllt                   *
*                 und an den Codingblock weitergegeben                *
*---------------------------------------------------------------------*
MODULE COBL_SEND_PBO_VBAK OUTPUT.

  PERFORM COBL_SEND_PBO_VBAK(SAPFV45P).

ENDMODULE.