*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_RV45A_MABNR                           *
*----------------------------------------------------------------------*

FORM FELDAUSWAHL_RV45A_MAB.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'RV45A-MABNR' OR SCREEN-NAME = 'TEXT_RV45A_MABNR'.
      IF TVAK-ERMAT NE CHARA.
*       es wird nicht mit Materialbestellnummer gearbeitet
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.


























