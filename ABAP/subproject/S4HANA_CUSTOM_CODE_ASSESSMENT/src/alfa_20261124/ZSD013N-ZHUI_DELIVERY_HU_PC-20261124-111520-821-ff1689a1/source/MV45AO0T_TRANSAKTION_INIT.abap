*---------------------------------------------------------------------*
*       MODULE TRANSAKTION_INIT                                       *
*---------------------------------------------------------------------*
*       Initialwerte auf Anforderungsbild setzen.                     *
*---------------------------------------------------------------------*
MODULE TRANSAKTION_INIT OUTPUT.

  PERFORM TRANSAKTION_INIT USING SY-TCODE.

ENDMODULE.