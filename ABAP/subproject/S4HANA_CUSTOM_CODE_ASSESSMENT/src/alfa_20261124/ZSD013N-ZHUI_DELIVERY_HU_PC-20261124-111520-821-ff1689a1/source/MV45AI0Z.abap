************************************************************************
*                                                                      *
* PAI Module Kundenauftragsabwicklung                                  *
*     Module alphabetisch geordnet; hier mit "Z" beginnend             *
*                                                                      *
************************************************************************
*eject

MODULE ZAHLUNGSKARTEN_PRUEFEN INPUT.
  PERFORM ZAHLUNGSKARTEN_PRUEFEN.
  CHECK CCDATA-DATBI NE *CCDATA-DATBI.
  PERFORM ZAHLUNGSKARTEN_DATUM_PRUEFEN.
ENDMODULE.
*eject