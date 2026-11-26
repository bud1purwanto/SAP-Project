************************************************************************
*                                                                      *
* PAI Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "U" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE UEBERSICHT_ANSTEUERN                                   *
*---------------------------------------------------------------------*
*       Aufgrund der Lieferart  wird ein Übersichtsbild               *
*       vorgeschlagen                                                 *
*---------------------------------------------------------------------*
MODULE uebersicht_ansteuern.

  PERFORM uebersicht_ansteuern(sapfv50p).

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE UEBERSICHT_ILIPS_AUFBAUEN                              *
*---------------------------------------------------------------------*
*       Aufgrund der Liefersart wird ein Übersichtsbild               *
*       vorgeschlagen                                                 *
*---------------------------------------------------------------------*
MODULE uebersicht_ilips_auf.

  PERFORM ilips_aufbauen(sapfv50p).

ENDMODULE.
*eject

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_4005  INPUT
*&---------------------------------------------------------------------*
*       Universal entry screen for delivery processing
*----------------------------------------------------------------------*
MODULE user_command_4005 INPUT.

  PERFORM user_command_universal_entry USING fcode.

ENDMODULE.                             " USER_COMMAND_4005  INPUT