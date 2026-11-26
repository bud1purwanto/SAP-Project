*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_BABA                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in das Objektklassen-  *
*       menü (VA00) zurückgesprungen.                                 *
*       Der Ansprung dieser Routine wird über einen Dialog nach der   *
*       Eingabe des Kommandos 'Beenden' gesteuert. Der FCODE hierzu   *
*       ist 'SIBA', er ist nur für die Folgebildst. definiert.        *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_BABA.

  DATA: FSVA_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVA_FCODE = FCODE.

* Export to Memory bei Call Dialog
* Aufruf z.B. aus VC01, IW51
  IF CALL_DIALOG NE SPACE.
    PERFORM CALL_DIALOG_EXPORT.
  ENDIF.

* Sicherung
  PERFORM BELEG_SICHERN USING SPACE
                              SY-SUBRC.

* Ursprünglichen FCODE ausführen
  CHECK FSVA_FCODE = FCODE.
  PERFORM FCODE_LEAVE(SAPLV00F).

ENDFORM.