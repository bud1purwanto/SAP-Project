*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_FELDAUSW                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*       Diese Routine steuert die Eingabebereitschaft der Elemente     *
*       des Dynpro SAPMV45A 4950, mit Ausnahme der Eingabebereitschaft *
*       des Texteditors selbst. Diese wird bereits im Modul            *
*       Text_Control_Vorbereiten festgelegt.                           *
*       Der vorliegende Modul stößt auch den DESTROY_CONTROL an, wenn  *
*       der Texteditor nicht mehr verfügbar ist.                       *
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_FELDAUSWAHL.

* Bildmodifikationen
  LOOP AT SCREEN.

* Text entsperren
    IF SCREEN-NAME = 'BT_TCEN'.
      IF TEXT_CONTROL_REFERIERT IS INITIAL OR
         T180-TRTYP EQ CHARA.
        SCREEN-ACTIVE = 0.
      ENDIF.
    ENDIF.

* Text löschen
    IF SCREEN-NAME = 'BT_TCLO'.
      IF T180-TRTYP = CHARA.
        SCREEN-ACTIVE = 0.
      ENDIF.
    ENDIF.

* Alle Screen-Felder zumachen, wenn Text Edit Control nicht mehr da
    IF TVAK-TDID IS INITIAL OR
       TEXT_EDITOR IS INITIAL OR
       TEXT_CONTROL_AVAILABLE IS INITIAL.
      SCREEN-ACTIVE = 0.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

* Wenn Text Editor nicht mehr verfügbar: Zerstören!
  IF TEXT_CONTROL_AVAILABLE IS INITIAL AND
     NOT TEXT_EDITOR IS INITIAL.
* Gegebenenfalls sind die Methoden nicht ausführbar
* daher Exceptions abfangen!
    CALL METHOD TEXT_EDITOR->DESTROY_CONTROL
      EXCEPTIONS
        OTHERS = 1.
    CALL METHOD C_TEXTEDIT_CONTROL=>FLUSH
      EXCEPTIONS
        OTHERS = 1.
    CLEAR TEXT_EDITOR.
  ENDIF.

ENDFORM.