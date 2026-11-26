*---------------------------------------------------------------------*
*       MODULE VBSN_FZDAT_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Die Änderungsstandtabelle darf entweder nur FZs oder Termine  *
*       enthalten.                                                    *
*---------------------------------------------------------------------*
MODULE VBSN_FZDAT_PRUEFEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBSN_FZDAT_PRUEFEN(SAPFV45L).

ENDMODULE.