*----------------------------------------------------------------------*
*   INCLUDE MV45AI0R_RV45A_MABNR_FILLED                                *
*----------------------------------------------------------------------*
*   das Feld RV45A-MABNR wurde gefüllt                                 *
*----------------------------------------------------------------------*
MODULE RV45A_MABNR_FILLED.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  GV_RV45A_MABNR_GEFUELLT = CHARX.

ENDMODULE.