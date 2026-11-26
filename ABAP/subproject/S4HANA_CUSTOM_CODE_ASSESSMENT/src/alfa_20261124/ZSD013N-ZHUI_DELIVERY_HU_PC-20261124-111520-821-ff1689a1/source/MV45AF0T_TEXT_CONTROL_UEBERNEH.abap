*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_UEBERNEH                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   PAI Bearbeitungsroutine des Text Edit Control                      *
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_UEBERNEHMEN.

* Nur wenn Text Control gemäß Customizing eingestellt und kein
* Referenztext.
  CHECK NOT TVAK-TDID IS INITIAL AND
        TEXT_CONTROL_AVAILABLE EQ CHARX AND
        TEXT_CONTROL_READY_FOR_INPUT EQ CHARX.

* Texttabelle aus Control abholen
    PERFORM TEXT_CONTROL_GET_TEXT_TABLE.

* SAPSCRIPT Tabelle ablegen
    PERFORM TEXT_TABLE_UEBERNEHMEN(SAPFV45T) USING TVAK-TDID.

ENDFORM.