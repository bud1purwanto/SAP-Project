*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_VORBEREI                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   PBO Bearbeitungsroutine für den Text Edit Control                  *
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_VORBEREITEN.

  DATA: DA_RC LIKE SY-SUBRC VALUE 0.
  STATICS: ISSUED_MESSAGE.

* Wurde im Customizing Textfindung ein Scratchpad-Text eingestellt?
  IF NOT TVAK-TDID IS INITIAL.
    IF TEXT_CONTROL_AVAILABLE EQ CHARX.
* Beim ersten Aufruf muß der Texteditor initialisiert werden
    IF TEXT_EDITOR IS INITIAL.
      PERFORM TEXT_CONTROL_INITIALISIEREN CHANGING DA_RC.
      IF DA_RC NE 0.
        MESSAGE S844.
        CLEAR TEXT_CONTROL_AVAILABLE.
          ISSUED_MESSAGE = CHARX.
        EXIT.
      ENDIF.
    ENDIF.

* Text in die Kopfzeile der XTHEAD stellen (falls vorhanden)
    PERFORM TEXT_CONTROL_XTHEAD_AUFBAUEN CHANGING DA_RC.
* Text-Header wurde nicht gefunden.
    IF DA_RC EQ 1.
      CLEAR TEXT_CONTROL_AVAILABLE.
      MESSAGE I248(VC) WITH TVAK-TDID TVAK-TXTGR.
      EXIT.
    ENDIF.

* Text lesen und dem Control bekanntmachen
    PERFORM TEXT_CONTROL_SET_TEXT_TABLE.

* Eingabebereitschaft des Text Control ermitteln
    PERFORM TEXT_CONTROL_EINGABEBEREIT.

* Am Ende aller Operationen am Text Editor: Mit Flush aktualisieren
    CALL METHOD C_TEXTEDIT_CONTROL=>FLUSH
        EXCEPTIONS
          OTHERS = 1.

* Textbezeichner lesen (für Dynprofeld TTXIT-TDTEXT)
    IF TTXIT-TDID NE TVAK-TDID OR
       TTXIT-TDOBJECT NE 'VBBK'.
      SELECT SINGLE * FROM TTXIT WHERE TDID = TVAK-TDID AND
                                       TDOBJECT = 'VBBK' AND
                                       TDSPRAS = SY-LANGU.
    ENDIF.
    ELSE.
      IF ISSUED_MESSAGE IS INITIAL.
        MESSAGE S802(VC).
        ISSUED_MESSAGE = CHARX.
      ENDIF.
    ENDIF.
* Kein Scratchpad-Text gemäß TVAK
  ELSE.
* Ist der Scratchpad-Text noch da? Dann zerstören!
    IF NOT TEXT_EDITOR IS INITIAL.
      CALL METHOD TEXT_EDITOR->DESTROY_CONTROL
        EXCEPTIONS
          OTHERS = 1.
      CALL METHOD C_TEXTEDIT_CONTROL=>FLUSH
        EXCEPTIONS
          OTHERS = 1.
      CLEAR TEXT_EDITOR.
    ENDIF.
  ENDIF.

ENDFORM.