*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_AEND                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Änderungs-      *
*       transaktion der Gruppe gesprungen.                            *
*       Der Ansprung dieser Routine wird über einen Dialog nach der   *
*       Eingabe des Kommandos 'Ändern' gesteuert. Der FCODE hierzu    *
*       ist 'SIAE', er ist nur für die Folgebildst. definiert.        *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_AEND.

  DATA: FSVA_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVA_FCODE = FCODE.
  PERFORM BELEG_SICHERN USING SPACE
                              SY-SUBRC.

* Ursprünglichen FCODE ausführen
  CHECK FSVA_FCODE = FCODE.
  PERFORM FCODE_AEND.

ENDFORM.