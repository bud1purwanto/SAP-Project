***INCLUDE MV50AF0F_FCODE_SICH_VOR_VL01 .
*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_VL01                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Anlege-         *
*       transaktion der Gruppe gesprungen.                            *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_VL01.

  DATA: FSVV_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVV_FCODE = FCODE.
* Sicherung
  PERFORM BELEG_SICHERN USING CHARX.


* Ursprünglichen FCODE ausführen
  CHECK FSVV_FCODE = FCODE.
  LEAVE TO TRANSACTION 'VL01'.

ENDFORM.