************************************************************************
*                                                                      *
* PAI Module Kundenauftragsabwicklung                                  *
*     Module alphabetisch geordnet; hier mit "U" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE UEBERSICHT_ANSTEUERN                                   *
*---------------------------------------------------------------------*
*       Aufgrund der Auftragsart wird ein Übersichtsbild              *
*       vorgeschlagen                                                 *
*---------------------------------------------------------------------*
MODULE UEBERSICHT_ANSTEUERN.

  perform beleg_lesen_logic.

  PERFORM UEBERSICHT_ANSTEUERN(SAPFV45P).

ENDMODULE.
*eject