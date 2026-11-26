*&---------------------------------------------------------------------*
*&      Form  TAXI_GOTO_OVERVIEW
*&---------------------------------------------------------------------*
*       NModul, Aufruf aus Folgebildsteuerung, falls Funktioncode "OVRV"
*       (Übersicht) ausgelöst wurde
*----------------------------------------------------------------------*
*       Setzt den Funktionscode in den in den Attributen zur Bildgruppe
*       "U0" gespeicherten semantischen Reiterfunktionscode um und
*       ruft Folgebildsteuerung erneut auf.
*----------------------------------------------------------------------*
FORM TAXI_GOTO_OVERVIEW.

  READ TABLE TAXI_SCREEN_GROUPS
     WITH KEY SCREEN_GROUP = C_TAXI_SCRGRP_OVERVIEW.
  FCODE = TAXI_SCREEN_GROUPS-TAB_FCODE.
  PERFORM FCODE_BEARBEITEN.

ENDFORM.