*eject
FORM FPLAN_ABSAGEN_ERMITTELN USING    US_TVAG LIKE TVAG
                             CHANGING CH_ABSAGEN.
* Wenn ein Absagegrund sitzt, wird das Flag CH_ABSAGEN nach folgender
* Matrix gesetzt:
* CH_ABSAGEN              :  A   B   A     C    D    C
*------------------------------------------------------
* Fakturarelevanz         :  X   X   X    ' '  ' '  ' '
* Statistisch     Y/X/' ' :  Y   X  ' '    Y    X   ' '
*------------------------------------------------------
* Achtung diese Routine ist redundant in der Faktura (LV60AF0F)
*------------------------------------------------------

  MOVE SPACE TO CH_ABSAGEN.
  IF US_TVAG-FK_ERL EQ CHARX.
    IF US_TVAG-KOWRR CA ' Y'.
*     Werte werden übernommen oder statistisch nutzbar
      MOVE CHARA TO CH_ABSAGEN.
    ELSE.
*     Werte nicht nutzbar
      MOVE CHARB TO CH_ABSAGEN.
    ENDIF.
  ELSE.
    IF US_TVAG-KOWRR CA ' Y'.
*     Werte werden übernommen oder statistisch nutzbar
      MOVE CHARC TO CH_ABSAGEN.
    ELSE.
*     Werte nicht nutzbar
      MOVE CHARD TO CH_ABSAGEN.
    ENDIF.
  ENDIF.
ENDFORM.