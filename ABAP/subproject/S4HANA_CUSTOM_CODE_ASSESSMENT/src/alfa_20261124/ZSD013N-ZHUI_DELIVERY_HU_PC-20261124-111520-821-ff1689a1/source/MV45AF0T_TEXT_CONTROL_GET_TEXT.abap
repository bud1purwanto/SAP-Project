*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_GET_TEXT                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Texttabelle vom Text Editor in SAPSCRIPT Tabelle transportieren    *
*----------------------------------------------------------------------*
form text_control_get_text_table.

* Texttabelle aus Control abholen
  refresh text_table.
  call method text_editor->get_text_as_r3table
              importing
                table = text_table
              exceptions
                others = 1.

* SAPSCRIPT-Tabelle präparieren
  call function 'CONVERT_STREAM_TO_ITF_TEXT'
       tables
            text_stream = text_table
            itf_text    = tlinetab.

endform.