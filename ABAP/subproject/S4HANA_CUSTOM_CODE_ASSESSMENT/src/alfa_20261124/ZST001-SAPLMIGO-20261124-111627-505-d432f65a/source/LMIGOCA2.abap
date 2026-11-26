*----------------------------------------------------------------------*
*   INCLUDE LMIGOCA2                                                   *
*   The multi-purpose control area of MIGO
*----------------------------------------------------------------------*
CLASS lcl_migo_controlarea IMPLEMENTATION.

************************************************************************
* Constructor. Create control.
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
        lt_sending   TYPE lif_migo_frame~ty_t_message_ids,
        lt_okcodes   TYPE lif_migo_frame~ty_t_okcodes.
* Framework registration
  lif_migo_frame~class_id = 'MIGO_CONTOLAREA'.
  APPEND 'NEW_SEARCHRESULT'      TO lt_receiving.
  APPEND 'TRANSACTION_LEAVE'     TO lt_receiving.
  APPEND 'KERNEL_MODE_CHANGED'   TO lt_receiving.
  APPEND 'ALLOWED_DOCS_CHANGED'  TO lt_receiving.
  APPEND 'SEARCHLIST_BUTTON'     TO lt_sending.
  APPEND 'MIGO_OK_SHOW_SEARCH'   TO lt_okcodes.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_receiving  = lt_receiving
      it_sending    = lt_sending
      it_okcodes    = lt_okcodes.
ENDMETHOD.

************************************************************************
* Message handler
************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: l_id TYPE ty_object_id,
        ls_child TYPE pty_s_children.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE i_message_id.
    WHEN 'TRANSACTION_LEAVE'.
      CALL METHOD state_save.
    WHEN 'NEW_SEARCHRESULT'.
      l_id = is_message-data1.
      CALL METHOD new_result
        EXPORTING
          i_id   = l_id
          i_dref = is_message-dref.
    WHEN 'KERNEL_MODE_CHANGED'.
      CALL METHOD mode_change_handler.
    WHEN 'ALLOWED_DOCS_CHANGED'.
      LOOP AT pt_children INTO ls_child.
        CALL METHOD ls_child-object->rebuild_toolbar.
      ENDLOOP.
  ENDCASE.
ENDMETHOD.

************************************************************************
* OK-code handling
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE i_okcode.
    WHEN 'MIGO_OK_SHOW_SEARCH'.
      CALL METHOD select_viewer( p_new_object_id ).
      CALL METHOD set_visible( abap_true ).
  ENDCASE.
ENDMETHOD.


************************************************************************
* Save the control state (extension).
************************************************************************
METHOD state_save.
  DATA: l_extension TYPE i.
* Only something to save if the control area has been created
  CHECK p_created = abap_true.                                   "377139
  CALL METHOD poref_container->get_extension
    IMPORTING extension = l_extension.
  CALL METHOD cl_gui_cfw=>flush.
  CALL METHOD poref_settings->set( i_element = 'EXTENSION'
                                   i_active  = l_extension ).
  CALL METHOD cl_mmim_userdefaults=>flush_all.
ENDMETHOD.

************************************************************************
* A new set of data has arrived. Check whether a viewer for the
* given ID already exists.
* If yes, just reshow it. If no, create it first.
************************************************************************
METHOD new_result.
  DATA: ls_child    TYPE pty_s_children,
        l_object    TYPE REF TO lcl_migo_griddisplay,
        l_lines     TYPE sytabix,
        l_extension TYPE i.                                      "377139
  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.
* Do nothing if there are no entries in the searchresult.
  ASSIGN i_dref->* TO <lt_table>.
  DESCRIBE TABLE <lt_table> LINES l_lines.
  IF l_lines = 0.
    MESSAGE s018.
    EXIT.
  ENDIF.
* Create the control area now                                    "377139
  IF p_created = abap_false.                                     "377139
*   User settings                                                "377139
    CREATE OBJECT poref_settings                                 "377139
      EXPORTING i_action = 'MIGO_CONTROLAREA'.                   "377139
    CALL METHOD poref_settings->preset( i_element = 'EXTENSION'  "377139
                                        i_active  = 100 ).       "377139
*   Creation of the container area with the last heigth.         "377139
    l_extension = poref_settings->get( 'EXTENSION' ).            "377139
    CREATE OBJECT poref_container                                "377139
      EXPORTING                                                  "377139
        side      = cl_gui_docking_container=>dock_at_bottom     "377139
        extension = l_extension.                                 "377139
    p_visible = abap_true.                                       "377139
    p_created = abap_true.                                       "377139
  ENDIF.                                                         "377139
* Access the display oject
  READ TABLE pt_children INTO ls_child
                         WITH KEY id = i_id.
* Create the object if necessary
  IF sy-subrc <> 0.
    ls_child-id = i_id.
    CREATE OBJECT ls_child-object
      EXPORTING
        i_id     = i_id
        i_parent = poref_container.
    APPEND ls_child TO pt_children.
  ENDIF.
* Transmit the new data
  CALL METHOD ls_child-object->new_data
    EXPORTING
      i_dref = i_dref.
* Make yourself and this specific control visible
  CALL METHOD select_viewer
    EXPORTING i_id = i_id.
  CALL METHOD set_visible( abap_true ).
ENDMETHOD.

************************************************************************
* Make the specified control visible
************************************************************************
METHOD select_viewer.
  DATA: l_any_visible TYPE abap_bool.
  FIELD-SYMBOLS: <ls_child> TYPE pty_s_children.
  l_any_visible = abap_false.
  LOOP AT pt_children ASSIGNING <ls_child>.
    IF <ls_child>-id = i_id.
      CALL METHOD <ls_child>-object->set_visible( abap_true ).
      l_any_visible = abap_true.
    ELSE.
      CALL METHOD <ls_child>-object->set_visible( abap_false ).
    ENDIF.
  ENDLOOP.
* If no appropriate viewer found, close the controlarea
  IF l_any_visible = abap_false.
    CALL METHOD set_visible( abap_false ).
  ENDIF.
ENDMETHOD.

************************************************************************
* Depending on the current state of MIGO, show the proper result
************************************************************************
METHOD mode_change_handler.
* Set new viewer if area is open
  p_new_object_id = lcl_migo_globals=>kernel->s_control-refdoc.
* Usually, ID = REFDOC is correct. But if refdoc = R08 (order),
* there is an exception: Goods issues for order are covered
* by "reservation"-search.
  IF p_new_object_id = 'R08' AND
     lcl_migo_globals=>kernel->s_control-action = 'A07'.
    p_new_object_id = 'R09'.
  ENDIF.
  IF p_visible = abap_true.
    CALL METHOD select_viewer( p_new_object_id ).
  ENDIF.
  CALL METHOD set_button_status.
ENDMETHOD.

************************************************************************
* Setting the visibility
************************************************************************
METHOD set_visible.
  IF i_visible <> p_visible.
    CALL METHOD poref_container->set_visible( i_visible ).
    p_visible = i_visible.
  ENDIF.
  CALL METHOD set_button_status.
ENDMETHOD.

************************************************************************
* Update the button status for "show searchresult"
************************************************************************
METHOD set_button_status.
  READ TABLE pt_children WITH KEY id = p_new_object_id
                         TRANSPORTING NO FIELDS.
  IF sy-subrc = 0 AND p_visible = abap_false.
    def_sms 'SEARCHLIST_BUTTON' abap_true space.
  ELSE.
    def_sms 'SEARCHLIST_BUTTON' abap_false space.
  ENDIF.
ENDMETHOD.

ENDCLASS.