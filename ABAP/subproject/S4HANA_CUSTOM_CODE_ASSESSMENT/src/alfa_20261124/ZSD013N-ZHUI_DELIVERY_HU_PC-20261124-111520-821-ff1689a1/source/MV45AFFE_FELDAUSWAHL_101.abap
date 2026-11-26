*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_101                                   *
*----------------------------------------------------------------------*
FORM FELDAUSWAHL_101.
  LOOP AT SCREEN.
    IF SY-BINPT IS INITIAL OR NOT CATTAKTIV IS INITIAL.
      IF SCREEN-NAME = 'RV45A-DOCNUM'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
      IF T180-TRVOG = CHAR5.
        IF SCREEN-NAME = 'VBAK-VKORG' OR
           SCREEN-NAME = 'VBAK-VTWEG' OR
           SCREEN-NAME = 'VBAK-SPART'.
          SCREEN-REQUIRED = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.