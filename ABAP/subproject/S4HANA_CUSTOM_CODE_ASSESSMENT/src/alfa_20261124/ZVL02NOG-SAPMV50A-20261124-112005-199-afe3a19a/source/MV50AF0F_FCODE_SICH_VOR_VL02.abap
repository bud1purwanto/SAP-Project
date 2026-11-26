***INCLUDE MV50AF0F_FCODE_SICH_VOR_VL02 .
*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_VL02                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Änderungs-      *
*       transaktion der Gruppe gesprungen.                            *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_VL02.

  DATA: FSVV_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVV_FCODE = FCODE.
  PERFORM BELEG_SICHERN USING CHARX.


* Ursprünglichen FCODE ausführen
  CHECK FSVV_FCODE = FCODE.
  LEAVE TO TRANSACTION 'VL02'.

ENDFORM.