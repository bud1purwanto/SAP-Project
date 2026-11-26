*&---------------------------------------------------------------------*
*&      Form  TAXI_GOTO_HEAD
*&---------------------------------------------------------------------*
*       NModul, Aufruf aus Folgebildsteuerung, falls Funktioncode "HEAD"
*       (Kopfdetails) ausgelöst wurde.
*----------------------------------------------------------------------*
*       Setzt den Funktionscode in den in den Attributen zur Bildgruppe
*       "K0" gespeicherten semantischen Reiterfunktionscode um und
*       ruft Folgebildsteuerung erneut auf.
*----------------------------------------------------------------------*
FORM TAXI_GOTO_HEAD.

  READ TABLE TAXI_SCREEN_GROUPS
     WITH KEY SCREEN_GROUP = C_TAXI_SCRGRP_HEAD.
* bei voriger Bearbeitung des Unvollständigkeitsbilds in
* Auslieferungsaufträgen darf hier nicht auf den
* Auslieferungsauftrags-Unvollständigkeitsreiter positioniert werden,
* weil dieser nur im Unvollständigkeitsdialog angesprungen werden darf
  if TAXI_SCREEN_GROUPS-TAB_FCODE eq fcode_unvollst_ausl_auft.
* Reiter neu positionieren
    TAXI_SCREEN_GROUPS-TAB_FCODE = FCODE_KAUFMANN_KOPF.
    modify TAXI_SCREEN_GROUPS index sy-tabix.
  endif.
  FCODE = TAXI_SCREEN_GROUPS-TAB_FCODE.
  PERFORM FCODE_BEARBEITEN.

ENDFORM.