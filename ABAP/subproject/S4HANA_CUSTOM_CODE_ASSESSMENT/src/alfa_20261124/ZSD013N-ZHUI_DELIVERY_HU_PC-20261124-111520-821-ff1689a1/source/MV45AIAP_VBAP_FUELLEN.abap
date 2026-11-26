*---------------------------------------------------------------------*
*       MODULE VBAP_FUELLEN                                           *
*---------------------------------------------------------------------*
*       VBAP mit Vorschlagswerten aus den Stammdaten beim             *
*       Anlegen füllen                                                *
*---------------------------------------------------------------------*
MODULE VBAP_FUELLEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* Hilfsvariable vbapin-vrkme wird zur neuen Gewichtsermittlung benötigt.
  IF VBAPIN-VRKME IS INITIAL.
    VBAPIN-VRKME = VBAP-VRKME.
  ENDIF.

  PERFORM VBAP-PSTYV_PRUEFEN_AENDERUNG(SAPFV45P).

  PERFORM VBAP_FUELLEN(SAPFV45P).

ENDMODULE.