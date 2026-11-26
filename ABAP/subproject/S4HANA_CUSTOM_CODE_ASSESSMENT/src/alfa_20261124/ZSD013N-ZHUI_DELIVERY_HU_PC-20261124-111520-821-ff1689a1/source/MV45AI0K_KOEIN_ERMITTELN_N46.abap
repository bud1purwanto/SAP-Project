*----------------------------------------------------------------------*
***INCLUDE MV45AI0K_KOEIN_ERMITTELN_N46 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  KOEIN_ERMITTELN_N46  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE KOEIN_ERMITTELN_N46 INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM KOEIN_ERMITTELN_N46(SAPFV45P).

ENDMODULE.                             " KOEIN_ERMITTELN_N46  INPUT