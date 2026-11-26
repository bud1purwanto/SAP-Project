*---------------------------------------------------------------------*
*       MODULE KOMV_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE KOMV_UNTERLEGEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM KOMV_UNTERLEGEN(SAPFV45P).

ENDMODULE.