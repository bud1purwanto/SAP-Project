*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_AUFBEREITEN_A                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Partnertabelle im PBO zur Anzeige aufbereiten                        *
*----------------------------------------------------------------------*
FORM PARTNER_AUFBEREITEN_ANZEIGE.

*-Partnerverwendung prüfen und Partnerverwendungstext lesen
  SELECT SINGLE * FROM TPAR WHERE PARVW = VBPA-PARVW.
  IF SY-SUBRC NE 0.
    MESSAGE ID 'VP' TYPE 'E' NUMBER 120  WITH VBPA-PARVW.
  ENDIF.

  SELECT SINGLE * FROM TPART WHERE SPRAS = SY-LANGU
                               AND PARVW = VBPA-PARVW.
  IF SY-SUBRC NE 0.
    MESSAGE ID 'VP' TYPE 'E' NUMBER 121 WITH VBPA-PARVW.
  ENDIF.

*Partnernummer in E/A-Felder stellen
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