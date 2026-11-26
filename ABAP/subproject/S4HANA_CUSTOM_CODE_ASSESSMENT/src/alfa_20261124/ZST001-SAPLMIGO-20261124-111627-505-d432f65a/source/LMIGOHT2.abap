*----------------------------------------------------------------------*
*   INCLUDE LMIGOHT2                                                   *
*   HTML-help
*----------------------------------------------------------------------*

CLASS lcl_migo_html_help IMPLEMENTATION.

************************************************************************
* Register for the message to open the thing
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids.
  lif_migo_frame~class_id = 'MIGO_HTML_HELP'.
  APPEND 'MIGO_HTML_HELP_SHOW' TO lt_receiving.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_receiving = lt_receiving.
ENDMETHOD.

************************************************************************
* OK-code handling
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.

************************************************************************
* Message handling
************************************************************************
METHOD lif_migo_frame~message_handler.
  CASE i_message_id.
    WHEN 'MIGO_HTML_HELP_SHOW'.
      CALL METHOD show.
  ENDCASE.
ENDMETHOD.
************************************************************************
* Initialization of the docking container
************************************************************************
METHOD initialize.
  DATA: lt_doc_id_tab TYPE TABLE OF doc_id_struct,
        ls_doc_id_tab TYPE doc_id_struct.
  ls_doc_id_tab-key = 'MIGO1'.
  ls_doc_id_tab-id  = 'MMIM_MIGO1_HELP'.
  APPEND ls_doc_id_tab TO lt_doc_id_tab.
  CALL FUNCTION 'DOC_DISPLAY_INITIALIZE'
    EXPORTING
      repid           = c_repid
      dynnr           = '0001'
      display_state   = 'H'                                      "357197
      side            = 'R'                                      "357197
    TABLES
      doc_id_tab      = lt_doc_id_tab
    EXCEPTIONS
      internal_error  = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMETHOD.
************************************************************************
* Show the thing.
************************************************************************
METHOD show.
  DATA: l_state TYPE char1.
* Initialize
  CALL METHOD initialize.                                        "357197
* Get current state
  CALL FUNCTION 'DOC_DISPLAY_GET_STATE'
    EXPORTING
      repid                = c_repid
      dynnr                = '0001'
   IMPORTING
     display_state        = l_state
   EXCEPTIONS
     appl_not_found       = 1
     OTHERS               = 2.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
* Open if closed, close if open
  CASE l_state.
    WHEN h.
      CALL FUNCTION 'DOC_DISPLAY_TEXT'
        EXPORTING
          dockey  = 'MIGO1'
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
      CALL FUNCTION 'DOC_DISPLAY_UNHIDE'
        EXCEPTIONS
          error_message = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
    WHEN u.
      CALL FUNCTION 'DOC_DISPLAY_HIDE'.
  ENDCASE.
ENDMETHOD.





ENDCLASS.