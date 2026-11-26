*---------------------------------------------------------------------*
*       MODULE VBAP_BEARBEITEN_ENDE                                   *
*---------------------------------------------------------------------*
*       Bearbeiten der Auftragsposition nach allen Einteilungen       *
*---------------------------------------------------------------------*
MODULE VBAP_BEARBEITEN_ENDE.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* Bei Löschen im Anlegen innerhalb des Loops wird der ursprüngliche
* Fcode wieder hergestellt, damit nicht am Bildende vorher angekreuzte
* Positionen mitgelöscht werden, oder wenn in einer Folgezeile eine
* Warnung kommt
  IF SVBAP-TABIX EQ 0 AND
     FCODE = FCODE_XVBAP_LOESCHEN.
    FCODE = XVBAP_LOOP_FCODE.
  ENDIF.

* nur wenn eine Position bearbeitet werden soll, dh. VBAP_FUELLEN lief
  CHECK: SVBAP-TABIX > 0,
         T180-TRTYP NE CHARA.

* Kennzeichen löschen setzen
  PERFORM VBAP_LOESCHEN_SETZEN(SAPFV45P).
  IF XVBAP_LOESCHEN_BEI_ANLEGEN NE SPACE AND
    SVBAP-TABIX > 0.
    PERFORM XVBAP_LOESCHEN(SAPFV45P) USING VBAP-POSNR.
    FCODE = XVBAP_LOOP_FCODE.
    EXIT.
  ENDIF.

  CHECK XVBAP_LOESCHEN EQ SPACE.
* Bei Löschen wird die Form intern aufgerufen

  PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).

ENDMODULE.