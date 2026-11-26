*&---------------------------------------------------------------------*
*&      Form  TAXI_GOTO_FC_DSH
*&---------------------------------------------------------------------*
*  FC_DSH: Forecast Delivery Schedule Header = Lieferabrufkopf
*          Bildgruppe PL
*----------------------------------------------------------------------*
FORM TAXI_GOTO_FC_DSH.

* Auszulösenden FCode aus den Bildgruppenattributen lesen.
  READ TABLE TAXI_SCREEN_GROUPS
     WITH KEY SCREEN_GROUP = C_TAXI_SCRGRP_FC_DSH.
  FCODE = TAXI_SCREEN_GROUPS-TAB_FCODE.

* Verzweigung auf ausgeblendeten Reiter verhindern ....
* 1. Tabelle inaktiver Reiter-FCodes füllen.
  PERFORM CUA_SETZEN.
* 2. Prüfen, ob auszulösender FCode zu inaktivem Reiter gehört.
  READ TABLE TAXI_INACTIVE_FCODES WITH KEY FCODE = FCODE.
* 3. Falls dem so ist, FCode umsetzen auf Default-FCode.
  IF SY-SUBRC = 0.
    FCODE = C_TAXI_DEFAULT_ITEM_FCODE.
  ENDIF.

  PERFORM FCODE_BEARBEITEN.

ENDFORM.