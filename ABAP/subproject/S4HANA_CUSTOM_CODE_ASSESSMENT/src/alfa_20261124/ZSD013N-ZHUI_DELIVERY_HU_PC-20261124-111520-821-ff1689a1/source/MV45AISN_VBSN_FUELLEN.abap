*---------------------------------------------------------------------*
*       MODULE VBSN_FUELLEN                                           *
*---------------------------------------------------------------------*
*       VBSN mit Vorschlagswerten aus den Stammdaten füllen           *
*---------------------------------------------------------------------*
MODULE VBSN_FUELLEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBSN_FUELLEN(SAPFV45L).

ENDMODULE.