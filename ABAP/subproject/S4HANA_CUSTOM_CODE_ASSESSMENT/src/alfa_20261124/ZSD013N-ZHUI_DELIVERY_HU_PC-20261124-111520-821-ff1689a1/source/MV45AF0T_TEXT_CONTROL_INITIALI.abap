*----------------------------------------------------------------------*
***INCLUDE MV45AF0T_TEXT_CONTROL_INITIALI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_INITIALISIEREN
*&---------------------------------------------------------------------*
*       Der Text Editor wird beim Erstaufruf initialisiert             *
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_INITIALISIEREN CHANGING CH_SUBRC.

  CH_SUBRC = 0.

* Text Control initialisieren
  CALL FUNCTION 'CONTROL_INIT'
       EXCEPTIONS
            CONTROL_INIT_ERROR = 01.
  CH_SUBRC = SY-SUBRC.
  CHECK CH_SUBRC EQ 0.
  TEXT_REPID = SY-REPID.

* Objekt Text_Editor erzeugen
  CREATE OBJECT TEXT_EDITOR
    EXPORTING
      REPID                      = TEXT_REPID
      DYNNR                      = SY-DYNNR
      DYNPRO_CONTAINER           = TEXT_CONTAINER
      WORDWRAP_MODE              =
          C_TEXTEDIT_CONTROL=>WORDWRAP_AT_FIXED_POSITION
      WORDWRAP_POSITION          = TEXT_LINE_LENGTH
      WORDWRAP_TO_LINEBREAK_MODE =
          C_TEXTEDIT_CONTROL=>TRUE
    EXCEPTIONS
      OTHERS = 1.
  CH_SUBRC = SY-SUBRC.
  CHECK CH_SUBRC EQ 0.
* Tool- und Statusbar abschalten
  CALL METHOD TEXT_EDITOR->SET_TOOLBAR_MODE
           exporting
               TOOLBAR_MODE = TEXT_EDITOR->FALSE
           EXCEPTIONS
               OTHERS = 1.
  CH_SUBRC = SY-SUBRC + CH_SUBRC.
  CALL METHOD TEXT_EDITOR->SET_STATUSBAR_MODE
           exporting
               STATUSBAR_MODE = TEXT_EDITOR->FALSE
           EXCEPTIONS
               OTHERS = 1.
  CH_SUBRC = SY-SUBRC + CH_SUBRC.
* register editor for event dblclick
  CALL METHOD TEXT_EDITOR->REGISTER_EVENT_DBLCLICK
         EXCEPTIONS
           OTHERS = 1.
  ch_subrc = sy-subrc + ch_subrc.

* Event_receiver object kreieren und Event Handlers
* für die Instanz Text_Editor von class c_textedit_control setzen
  CREATE OBJECT EVENT_RECEIVER.
  set handler event_receiver->event_handler_dblclick
              FOR TEXT_EDITOR.


ENDFORM.                               " TEXT_CONTROL_INITIALISIEREN