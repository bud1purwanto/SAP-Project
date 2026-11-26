*---------------------------------------------------------------------*
*       MODULE ANLIEFERTERMIN_PRUEFEN                                 *
*---------------------------------------------------------------------*
*       Der Anliefertermin wird geprüft.                              *
*---------------------------------------------------------------------*
MODULE ANLIEFERTERMIN_PRUEF.

  DATA: DA_EZEIT LIKE VBEP-EZEIT,
        DA_EDATU LIKE VBEP-EDATU.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  IF SVBEP-TABIX > 0.
* Beim Anlegen läuft die Routine aus VBEP_FUELLEN.
    PERFORM ANLIEFERTERMIN_PRUEFEN(SAPFV45E) USING VBEP-PRGRS
                                                   VBEP-EDATU
                                                   VBEP-EZEIT
                                                   VBEP-CMENG
                                                   VBEP-BMENG
                                                   CHARX
                                                   DA_EDATU
                                                   DA_EZEIT
                                                   SY-SUBRC.
  ENDIF.

  PERFORM TEILLIEFERUNG_PRUEFEN(SAPFV45E).


ENDMODULE.