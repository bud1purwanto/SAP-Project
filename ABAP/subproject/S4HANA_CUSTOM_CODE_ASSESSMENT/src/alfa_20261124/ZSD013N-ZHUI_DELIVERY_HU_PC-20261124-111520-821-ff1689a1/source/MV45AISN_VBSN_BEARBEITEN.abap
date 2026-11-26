*---------------------------------------------------------------------*
*       MODULE VBSN_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten der Änderungsstandposition                         *
*---------------------------------------------------------------------*
MODULE VBSN_BEARBEITEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBSN_BEARBEITEN(SAPFV45L).

ENDMODULE.