*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_GRP_ANZEIG_FIELD_                             *
*----------------------------------------------------------------------*

MODULE MAT_GRP_ANZEIG_FIELD_SELECTION OUTPUT.
  IF ATP_CHECK IS INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'MAT_LISTE-AVQTY' OR
         SCREEN-NAME = 'MAT_LISTE-FULLAVDAT'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
*   Spaltenauswahl für Tabstrips aus Tablecontrol ableiten
    PERFORM MAT_GRP_ANZEIG_SPALTENAUSWAHL.
    ENDLOOP.
  ENDIF.
ENDMODULE.