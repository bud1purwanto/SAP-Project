*----------------------------------------------------------------------*
*   INCLUDE MV45AI0S_STATUS_AENDERN                                    *
*----------------------------------------------------------------------*
MODULE STATUS_AENDERN INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM STATUS_AENDERN_AUS_UEBERSICHT. " Temporär inaktiv, Weiterentw

ENDMODULE.