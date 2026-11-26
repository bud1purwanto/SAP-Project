*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBKD_WAKTION_PRUEF                                *
*----------------------------------------------------------------------*
*       Die eingegebene Aktionsnummer wird geprüft
*----------------------------------------------------------------------*
  MODULE VBKD-WAKTION_PRUEFEN INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
    PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                               CHANGING LEAVE_WITHOUT_CHECK.
    CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

   PERFORM VBKD-WAKTION_PRUEFEN(SAPFV45K) CHANGING VBKD-WAKTION
                                                   SY-SUBRC.

  ENDMODULE.                            " VBKD-WAKTION_PRUEFEN  INPUT