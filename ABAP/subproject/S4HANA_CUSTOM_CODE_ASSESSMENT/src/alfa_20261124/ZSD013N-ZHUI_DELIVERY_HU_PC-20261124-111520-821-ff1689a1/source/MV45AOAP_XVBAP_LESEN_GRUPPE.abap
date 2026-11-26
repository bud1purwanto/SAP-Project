*---------------------------------------------------------------------*
*       MODULE XVBAP_LESEN_GRUPPE                                     *
*---------------------------------------------------------------------*
*       Tabelle XVBAP fuer Bildschirmanzeige lesen, es wird die letzte*
*       Einteilung mit bestätigter Menge zur Verfügung gestellt       *
*       --> für Anzeige auf Bild Liefergruppen relevant               *
*---------------------------------------------------------------------*
MODULE XVBAP_LESEN_GRUPPE OUTPUT.

  PERFORM XVBAP_LESEN(SAPFV45P) USING CHAR2.

ENDMODULE.