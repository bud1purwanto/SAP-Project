*&---------------------------------------------------------------------*
*&      Form  TAXI_GOTO_SHEDLINE
*&---------------------------------------------------------------------*
*       NModul, Aufruf aus Folgebildsteuerung, falls Funktioncode "SHLI"
*       (Einteilung-Detail) ausgelöst wurde
*----------------------------------------------------------------------*
*       Setzt den Funktionscode in den in den Attributen zur Bildgruppe
*       "P1" gespeicherten semantischen Reiterfunktionscode um und
*       ruft Folgebildsteuerung erneut auf.
*----------------------------------------------------------------------*
FORM TAXI_GOTO_SHEDLINE.

  READ TABLE TAXI_SCREEN_GROUPS
     WITH KEY SCREEN_GROUP = C_TAXI_SCRGRP_SCHEDLINE.
  FCODE = TAXI_SCREEN_GROUPS-TAB_FCODE.
  PERFORM FCODE_BEARBEITEN.

ENDFORM.