*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_AUFBEREITEN_E                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Partnertabelle aufbereiten aus Eingabe                               *
*----------------------------------------------------------------------*
FORM PARTNER_AUFBEREITEN_EINGABE.

*-Konditon prüfen und Konditonstext lesen ----------------------------*
  SELECT SINGLE * FROM TPAR WHERE PARVW = VBPA-PARVW.
  IF SY-SUBRC NE 0.
    MESSAGE E300 WITH VBPA-PARVW.
  ENDIF.

  SELECT SINGLE * FROM TPART WHERE SPRAS = SY-LANGU
                               AND PARVW = VBPA-PARVW.
  IF SY-SUBRC NE 0.
    MESSAGE E301 WITH SY-LANGU VBPA-PARVW.
  ENDIF.

*Partnernummer aus E/A-Felder in Tabellenfeld stellen
  CASE TPAR-NRART.
    WHEN 'KU'.
      MOVE VBPA-KUNNR TO RV50A-KTONR.
    WHEN 'LI'.
      MOVE VBPA-LIFNR TO RV50A-KTONR.
    WHEN 'PE'.
      MOVE VBPA-PERNR TO RV50A-KTONR.
    WHEN 'AP'.
      MOVE VBPA-PARNR TO RV50A-KTONR.
  ENDCASE.
ENDFORM.
*eject