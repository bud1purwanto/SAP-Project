***INCLUDE MV50AF0F_FCODE_SICH_VOR_VL04 .
*---------------------------------------------------------------------*
*       FORM FCODE_SICH_VOR_VL04                                      *
*---------------------------------------------------------------------*
*       Sichern des Gesamtbeleges, danach wird in die Bearbeitung     *
*       des Liefervorrates gesprungen.                                *
*---------------------------------------------------------------------*
FORM FCODE_SICH_VOR_VL04.

  DATA: FSVV_FCODE LIKE FCODE.

* FCode merken, falls Fehlerprotokoll bearbeitet wurde
  FSVV_FCODE = FCODE.
* Sicherung
  PERFORM BELEG_SICHERN USING CHARX.


* Ursprünglichen FCODE ausführen
  CHECK FSVV_FCODE = FCODE.
  LEAVE TO TRANSACTION 'VL04'.

ENDFORM.