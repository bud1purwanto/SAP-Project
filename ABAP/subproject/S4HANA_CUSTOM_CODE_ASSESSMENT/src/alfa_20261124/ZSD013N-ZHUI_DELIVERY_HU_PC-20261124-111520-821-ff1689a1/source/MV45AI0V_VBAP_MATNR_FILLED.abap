*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAP_MATNR_FILLED                                 *
*----------------------------------------------------------------------*
*   das Feld VBAP-MATNR wurde gefüllt                                  *
*----------------------------------------------------------------------*
MODULE VBAP_MATNR_FILLED.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  GV_VBAP_MATNR_GEFUELLT = CHARX.

ENDMODULE.