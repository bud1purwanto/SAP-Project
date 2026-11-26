*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TRANSAKTMENU_INIT                                 *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TRANSAKTMENU_INIT                                        *
*---------------------------------------------------------------------*
*       Transaktion VL00 initialisiern                                *
*---------------------------------------------------------------------*
FORM TRANSAKTMENU_INIT.

*---------------------------------------------------------------------*
*   Transaktionssteuerung aus Tabelle 180
*---------------------------------------------------------------------*
  SELECT SINGLE * FROM T180 WHERE TCODE EQ SY-TCODE.
  IF SY-SUBRC NE 0.
    MESSAGE E015 WITH SY-TCODE.
  ENDIF.

*---------------------------------------------------------------------*
*   Definition von Parametern für die Bildfolgesteuerung:
*   - Standardfunktionscodes: gleiche Seite
*   - Verarbeitungsortes
*   - Arbeitsgebiet und Aktivitaetsklassifizierung
*   - CUA-Parameter fuer Action-Bar und Titel holen
*---------------------------------------------------------------------*
  FCODE = FCODE_GLEICHE_SEITE.

  PERFORM FOLGEBILDSTEUERUNG_INIT.

ENDFORM.
*eject































