FUNCTION ZPOPUP_TO_CONFIRM .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(TITLEBAR) DEFAULT SPACE
*"     VALUE(DIAGNOSE_OBJECT) LIKE  DOKHL-OBJECT DEFAULT SPACE
*"     VALUE(TEXT_QUESTION)
*"     VALUE(TEXT_BUTTON_1) DEFAULT 'Ja'(001)
*"     VALUE(ICON_BUTTON_1) LIKE  ICON-NAME DEFAULT SPACE
*"     VALUE(TEXT_BUTTON_2) DEFAULT 'Nein'(002)
*"     VALUE(ICON_BUTTON_2) LIKE  ICON-NAME DEFAULT SPACE
*"     VALUE(DEFAULT_BUTTON) DEFAULT '1'
*"     VALUE(DISPLAY_CANCEL_BUTTON) DEFAULT 'X'
*"     VALUE(USERDEFINED_F1_HELP) LIKE  DOKHL-OBJECT DEFAULT SPACE
*"     VALUE(START_COLUMN) LIKE  SY-CUCOL DEFAULT 25
*"     VALUE(START_ROW) LIKE  SY-CUROW DEFAULT 6
*"     VALUE(POPUP_TYPE) LIKE  ICON-NAME OPTIONAL
*"     REFERENCE(IV_QUICKINFO_BUTTON_1) TYPE  TEXT132 DEFAULT SPACE
*"     REFERENCE(IV_QUICKINFO_BUTTON_2) TYPE  TEXT132 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(ANSWER)
*"  TABLES
*"      PARAMETER STRUCTURE  SPAR OPTIONAL
*"  EXCEPTIONS
*"      TEXT_NOT_FOUND
*"----------------------------------------------------------------------

DATA: overlay_header LIKE thead.                          "*029u
*       l_parameter    LIKE spar OCCURS 0 WITH HEADER LINE. "*029d

* Initialisieren der Parameter
  answer = 'A'.
  clear:   button_1, button_2, button_3, button_4.
  clear:   dynp_loops.

  clear:   text_tab1, text_tab2, textlines, exclude.
  refresh: text_tab1, text_tab2, textlines, exclude.

  title             = titlebar.                             "B20K071317
  fragetext         = text_question.
  move text_button_1 to button_1(12).
  move text_button_2 to button_2(12).
  option            = default_button.
  cancel_option     = display_cancel_button.
  userdefined_f1_id = userdefined_f1_help.
  start_zeile       = start_row.
  start_spalte      = start_column.
  text_tab2_index   = 1.
  icon_popup_type   = popup_type.                           "B20K062151

* Typ des Popup bestimmen                                  "B20K062151
  perform type_of_popup changing icon_popup_type.           "B20K062151

* Der folgende Parameter hält die Fensterbreite variabel.
  if userdefined_f1_id ne space.
    textlength = 57.
  else.
    textlength = 48.
  endif.

*015i-
* Parameterliste sortieren
  IF NOT parameter[] IS INITIAL.
    MOVE parameter[] TO l_parameter[].
    LOOP AT l_parameter.                                    "*034i
      SHIFT l_parameter-value LEFT DELETING LEADING space.  "*034i
      MODIFY l_parameter.                                   "*034i
    ENDLOOP.                                                "*034i
    SORT l_parameter.
  ENDIF.
*015i-

**Inhalt des Textbausteins beschaffen
  if diagnose_object ne space.
    call function 'DOCU_GET_FOR_F1HELP'
         exporting
              id       = docu_id_dialog_text
              langu    = sy-langu
              object   = diagnose_object
         importing
              head     = overlay_header
         tables
              line     = textlines
         exceptions
              ret_code = 04.

    case sy-subrc.
      when 4.
        move text-101 to textlines-tdline.                  "B20K074949
        append textlines.                                   "B20K074949
        clear textlines.                                    "B20K074949
        append textlines.                                   "B20K074949
*        message e130 raising text_not_found.               "B20K074949
    endcase.

*   Parameter in den Diagnosetext einfügen
    if not parameter[] is initial.
*015d+
* Diese Sortierung muß vorverlegt werden, da sie später
* außerhalb der IF-ENDIF-Abfrage nochmals benötigt wird.
*      MOVE parameter[] TO l_parameter[].
*      SORT l_parameter.
*015d-
      perform insert_params tables textlines l_parameter.
    endif.

*   Umsetzen des Dokuments aus der SE 61 in eine interne Tabelle.
    perform move_docu_to_itab tables textlines text_tab2.

  endif.

*015i+
* Parameter in den Fragetext schreiben.
  IF NOT l_parameter[] IS INITIAL.
    PERFORM replace_parameters TABLES   l_parameter
                               CHANGING fragetext.
  ENDIF.
*015i-

**Initialisieren der Drucktasten
  if display_cancel_button = space.
    move 'CANC' to exclude.
    append exclude.
  endif.
  if userdefined_f1_id ne space.
    icon_button_3 = 'ICON_INFORMATION'.
    button_3 = 'Info'(201).
    if display_cancel_button = 'X'.
      icon_button_4 = 'ICON_CANCEL'.
      button_4 = 'Abbrechen'(200).
    endif.
  elseif display_cancel_button = 'X'.
*    icon_button_3 = 'ICON_CANCEL'.
    button_3 = 'Normal'(200).
  endif.

* Belegen der Drucktasten mit Icons
  if icon_button_1 ne space.
    perform append_icon_to_button
            using    icon_button_1
                     iv_quickinfo_button_1                  "*048i
            changing button_1.
  ELSEIF NOT iv_quickinfo_button_1 IS INITIAL.              "*048i
    PERFORM append_quickinfo_to_button                      "*048i
            USING    iv_quickinfo_button_1                  "*048i
            CHANGING button_1.                              "*048i
  endif.

  if icon_button_2 ne space.
    perform append_icon_to_button
            using    icon_button_2
                     iv_quickinfo_button_2                  "*048i
            changing button_2.
  ELSEIF NOT iv_quickinfo_button_2 IS INITIAL.              "*048i
    PERFORM append_quickinfo_to_button                      "*048i
            USING    iv_quickinfo_button_2                  "*048i
            CHANGING button_2.                              "*048i
  endif.

  if icon_button_3 ne space.
    perform append_icon_to_button
            using    icon_button_3
                     space                                  "*048i
            changing button_3.
  endif.

  if icon_button_4 ne space.
    perform append_icon_to_button
            using    icon_button_4
                     space                                  "*048i
            changing button_4.
  endif.


* Aufbereitung des Fragetextes und Berechnung der Dynprogröße
  perform format_text tables text_tab1
                      using fragetext.

  perform calculate_screen_size
              using
                 textlength
                 start_spalte
                 start_zeile
              changing
                 tab_len1
                 tab_len2
                 end_spalte
                 end_zeile
                 dynpro_nummer.


* Aufruf der Dialog-Dynpros

  call screen dynpro_nummer starting at start_spalte start_zeile
                            ending   at end_spalte   end_zeile.


  answer = antwort.

ENDFUNCTION.