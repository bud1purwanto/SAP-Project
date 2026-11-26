*eject
*---------------------------------------------------------------------*
*       MODULE VBSN_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       Der alte Änderungsstand wird unter die Eingabedaten gelegt    *
*---------------------------------------------------------------------*
MODULE VBSN_UNTERLEGEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBSN_UNTERLEGEN(SAPFV45L).

ENDMODULE.