*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_ANLE                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Anlege-         *
*       transaktion der Gruppe gesprungen.                            *
*       Der Ansprung dieser Routine wird über einen Dialog nach der   *
*       Eingabe des Kommandos 'Anlegen' gesteuert. Der FCODE hierzu   *
*       ist 'SIAN', er ist nur für die Folgebildst. definiert.        *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_ANLE.

  DATA: FSVA_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVA_FCODE = FCODE.
* Sicherung
  PERFORM BELEG_SICHERN USING SPACE
                              SY-SUBRC.

* Ursprünglichen FCODE ausführen
  CHECK FSVA_FCODE = FCODE.
  PERFORM FCODE_ANLE.

ENDFORM.