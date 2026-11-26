*---------------------------------------------------------------------*
*       MODULE EXT_NUMMER_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Die externe Belegnummer wird auf Gültigkeit geprüft.          *
*---------------------------------------------------------------------*
MODULE EXT_NUMMER_PRUEFEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBAK-VBELN_PRUEFEN(SAPFV45K).
  PERFORM VBELN_UEBERNEHMEN.

ENDMODULE.