MODULE vbep_edatu_pruefen INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBEP_EDATU_PRUEFEN(SAPFV45E).


ENDMODULE.                 " vbep_edatu_pruefen  INPUT