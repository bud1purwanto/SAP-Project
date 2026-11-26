*---------------------------------------------------------------------*
*       MODULE VBEP_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten der Einteilungsposition                            *
*---------------------------------------------------------------------*
MODULE VBEP_BEARBEITEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBEP_BEARBEITEN(SAPFV45E).

ENDMODULE.