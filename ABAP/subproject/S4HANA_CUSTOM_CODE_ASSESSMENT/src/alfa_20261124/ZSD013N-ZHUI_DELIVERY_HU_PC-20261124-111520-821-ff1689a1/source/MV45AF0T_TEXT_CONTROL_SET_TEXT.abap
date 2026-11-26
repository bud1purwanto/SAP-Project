*----------------------------------------------------------------------*
***INCLUDE MV45AF0T_TEXT_CONTROL_SET_TEXT .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_SET_TEXT_TABLE
*&---------------------------------------------------------------------*
*       Die Text Tabelle für den Text Control wird gefüllt
*----------------------------------------------------------------------*
form text_control_set_text_table.

* Texttabelle löschen
  refresh text_table.
* Wurde Text bereits eingegeben (oder gezogen)
  if xthead-tdspras cn ' *'.
* Sprachkennzeichen in der Indextabelle setzen
    perform ithead_aendern_sprache(sapfv45t).
* Lesen (aus Memory oder Datenbank)
    perform text_lesen(sapfv45t).
* Text in Tabelle für Text Control übertragen
    call function 'CONVERT_ITF_TO_STREAM_TEXT'
         tables
              itf_text    = tlinetab
              text_stream = text_table.
  endif.
* ... und den assoziierten Text dem Control bekanntmachen
  call method text_editor->set_text_as_r3table
    exporting
      table = text_table
    exceptions
      others = 1.

endform.                               " TEXT_CONTROL_SET_TEXT_TABLE