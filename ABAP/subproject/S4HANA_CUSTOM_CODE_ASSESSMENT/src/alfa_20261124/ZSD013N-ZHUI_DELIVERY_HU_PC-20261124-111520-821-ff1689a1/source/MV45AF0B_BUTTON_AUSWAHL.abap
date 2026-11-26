*&---------------------------------------------------------------------*
*&      Form  BUTTON_AUSWAHL
*&---------------------------------------------------------------------*
*       Auswahl der eingabebereiten Drucktasten auf dem Dynpro anhand
*       der cua_exclude Tabelle. Alle Tasten, die nicht in der Tabelle
*       vorkommen, sind eingabebereit. Voraussetzung ist die Kenn-
*       zeichnung durch screen-group2='BTN'
*----------------------------------------------------------------------*
FORM BUTTON_AUSWAHL.

  DATA: BTN_FCODE LIKE T185F-FCODE.

  LOOP AT SCREEN.
    CASE SCREEN-GROUP2.
      WHEN 'BTN'.
        SCREEN-INPUT = 1.            "Default: Taste ist eingabebereit.
        BTN_FCODE = SCREEN-NAME.
        SHIFT BTN_FCODE BY 3 PLACES.
* Ist der Button zur Zeit erlaubt?
        LOOP AT CUA_EXCLUDE.
          IF BTN_FCODE = CUA_EXCLUDE-FUNCTION.
            SCREEN-INPUT = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        MODIFY SCREEN.
      WHEN 'BTA'.
        SCREEN-ACTIVE = 1.           "Default: Taste ist sichtbar.
        BTN_FCODE = SCREEN-NAME.
        SHIFT BTN_FCODE BY 3 PLACES.
* Ist der Button zur Zeit erlaubt?
        LOOP AT CUA_EXCLUDE.
          IF BTN_FCODE = CUA_EXCLUDE-FUNCTION.
            SCREEN-ACTIVE = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        MODIFY SCREEN.
      WHEN 'BTB'.
        SCREEN-INPUT = 1.            "Default: Taste ist eingabebereit.
        SCREEN-ACTIVE = 1.           "Default: Taste ist sichtbar.
        BTN_FCODE = SCREEN-NAME.
        SHIFT BTN_FCODE BY 3 PLACES.
* Ist der Button zur Zeit erlaubt?
        LOOP AT CUA_EXCLUDE.
          IF BTN_FCODE = CUA_EXCLUDE-FUNCTION.
            SCREEN-INPUT  = 0.
            SCREEN-ACTIVE = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        MODIFY SCREEN.
    ENDCASE.

ENHANCEMENT-POINT BUTTON_AUSWAHL_01 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT BUTTON_AUSWAHL_10 SPOTS ES_SAPMV45A.






  ENDLOOP.

ENDFORM.                               " BUTTON_AUSWAHL