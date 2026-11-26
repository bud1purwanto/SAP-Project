*&---------------------------------------------------------------------*
*&      Form  TAXI_ACTIVATE_TAB
*&---------------------------------------------------------------------*
*       Bringt den zu übergebenen semantischen Funktionscode gehören-
*       den Tabstrip-Reiter in den Vordergrund und speichert diesen
*       Funktionscode anschließend in der Tabelle der Bildgruppen-
*       attribute.
*----------------------------------------------------------------------*
FORM TAXI_ACTIVATE_TAB
   TABLES   TA_SCREEN_GROUPS  LIKE TAXI_SCREEN_GROUPS[]
                              "Tabelle der Bildgruppenattribute
   USING    US_FCODE          LIKE TAXI_PARAMS-FCODE
                              "FCode aus Folgebildsteuerung
            US_SCREEN_GROUP   LIKE TAXI_SCREEN_GROUP
                              "aktuelle Bildgruppe
   CHANGING CH_TABSTRIP       LIKE TAXI_TABSTRIP.
                              "Tabstrip-Control zur aktuellen Bildgruppe

* Reiteraktivierung veranlassen
  CALL FUNCTION 'TAXI_ACTIVATE_TAB'
     EXPORTING
          FCODE                     = US_FCODE
     CHANGING
          TABSTRIP                  = CH_TABSTRIP
     EXCEPTIONS
          NO_TAB_FCODE = 1
          OTHERS       = 2.

* Ist der ausgelöste Funktionscode überhaupt ein Reiter-Funktionscode ?
  IF SY-SUBRC NE 1.
* Falls ja, FCode in der Tabelle der Bildgruppenattribute ablegen
     LOOP AT TAXI_SCREEN_GROUPS
           WHERE SCREEN_GROUP = US_SCREEN_GROUP.
        TAXI_SCREEN_GROUPS-TAB_FCODE = US_FCODE.
        MODIFY TAXI_SCREEN_GROUPS.
     ENDLOOP.
  ENDIF.

ENDFORM.                               " TAXI_ACTIVATE_TAB