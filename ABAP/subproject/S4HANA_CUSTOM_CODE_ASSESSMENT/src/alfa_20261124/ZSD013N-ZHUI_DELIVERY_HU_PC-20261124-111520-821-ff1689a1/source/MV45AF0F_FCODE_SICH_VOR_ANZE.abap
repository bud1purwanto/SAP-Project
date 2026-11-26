*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_ANZE                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Anzeige-        *
*       transaktion der Gruppe gesprungen.                            *
*       Der Ansprung dieser Routine wird über einen Dialog nach der   *
*       Eingabe des Kommandos 'Anzeigen' gesteuert. Der FCODE hierzu  *
*       ist 'SIAZ', er ist nur für die Folgebildst. definiert.        *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_ANZE.

  DATA: FSVA_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVA_FCODE = FCODE.
* Sicherung
  PERFORM BELEG_SICHERN USING SPACE
                              SY-SUBRC.

* Ursprünglichen FCODE ausführen
  CHECK FSVA_FCODE = FCODE.
  PERFORM FCODE_ANZE.

ENDFORM.