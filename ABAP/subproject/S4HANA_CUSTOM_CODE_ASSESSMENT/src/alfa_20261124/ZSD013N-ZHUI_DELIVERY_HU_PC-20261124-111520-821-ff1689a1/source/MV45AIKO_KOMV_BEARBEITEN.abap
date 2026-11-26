*---------------------------------------------------------------------*
*       MODULE KOMV_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE KOMV_BEARBEITEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* nicht nach Änderung der AUART wegen V1206
  CHECK VBAK-AUART EQ *VBAK-AUART.

  PERFORM VBAP_LOESCHEN_SETZEN(SAPFV45P).
  PERFORM KOMV_BEARBEITEN(SAPFV45P).

ENDMODULE.