*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_125                                          *
*---------------------------------------------------------------------*
*       Die IDOC-Nummer wird bei Einplanen übernommen.                *
*       Bei Dialog ist das Feld auf dem Dynpro unsichtbar.            *
*---------------------------------------------------------------------*
FORM FELDAUSWAHL_125.
  LOOP AT SCREEN.
    IF ( SY-BINPT IS INITIAL OR NOT CATTAKTIV IS INITIAL ) .
      IF SCREEN-NAME = 'RV45Z-DOCNUM'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'RV45Z-MSGVS'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.