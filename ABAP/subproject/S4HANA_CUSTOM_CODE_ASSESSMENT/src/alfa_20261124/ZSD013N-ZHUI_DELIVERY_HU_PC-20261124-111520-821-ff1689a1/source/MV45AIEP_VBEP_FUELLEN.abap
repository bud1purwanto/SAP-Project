*---------------------------------------------------------------------*
*       MODULE VBEP_FUELLEN                                           *
*---------------------------------------------------------------------*
*       VBEP mit Vorschlagswerten aus den Stammdaten füllen           *
*---------------------------------------------------------------------*
MODULE VBEP_FUELLEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* Nur im Dialogfall bei geändertem Positionstyp: ETTYP zurücksetzen
  IF VBAP-PSTYV NE *VBAP-PSTYV OR
* Rückänderung Positionstyp nach E-Meldung (TAN->ZAN->TAN)
     VBAP-BEDAE NE *VBAP-BEDAE.
* Nicht wenn gleichzeitig der ETTYP manuell geändert wurde
    IF VBEP-ETTYP EQ *VBEP-ETTYP.
      CLEAR VBEP-ETTYP.
    ENDIF.
  ENDIF.

  PERFORM VBEP_FUELLEN(SAPFV45E).

ENDMODULE.