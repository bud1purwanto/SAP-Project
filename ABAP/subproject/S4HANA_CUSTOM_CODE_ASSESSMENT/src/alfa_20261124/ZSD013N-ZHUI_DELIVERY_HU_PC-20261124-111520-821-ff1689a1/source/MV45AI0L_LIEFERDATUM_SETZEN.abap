*---------------------------------------------------------------------*
*       MODULE LIEFERDATUM_SETZEN                                     *
*---------------------------------------------------------------------*
*       Ein manuell gesetztes Lieferdatum wird in die Liefergruppe    *
*       übernommen                                                    *
*---------------------------------------------------------------------*
MODULE LIEFERDATUM_SETZEN.

  PERFORM LIEFERGRUPPENDATUM_SETZEN(SAPFV45V) USING VERARB_HELL.

ENDMODULE.