*eject
*---------------------------------------------------------------------*
*       MODULE BELEG_SUCHEN                                           *
*---------------------------------------------------------------------*
*       Materialbeleg über 'Materialbelege zum Material' suchen.      *
*---------------------------------------------------------------------*
MODULE BELEG_SUCHEN.
  DATA: FLAG(1).
  FLAG  = 'X'.
  EXPORT FLAG TO MEMORY ID 'MB51_FLAG'.
  CALL TRANSACTION 'MB51'.
  GET PARAMETER ID 'MBN' FIELD RM07M-MBLNR.
  GET PARAMETER ID 'MJA' FIELD RM07M-MJAHR.
ENDMODULE.