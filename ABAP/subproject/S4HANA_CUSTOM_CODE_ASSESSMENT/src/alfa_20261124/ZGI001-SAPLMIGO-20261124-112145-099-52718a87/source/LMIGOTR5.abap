*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR5                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Constructor
************************************************************************
  METHOD constructor.
    DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
          lt_sending   TYPE lif_migo_frame~ty_t_message_ids,
          lt_okcodes   TYPE lif_migo_frame~ty_t_okcodes.         "216027

    CLEAR f_not_creatable.
    CLEAR f_is_visible.
    CLEAR p_running.
* Register in framework
    lif_migo_frame~class_id = 'MIGO_TREE'.
    APPEND 'MIGO_TREE_OPEN'        TO lt_receiving.
    APPEND 'MIGO_TREE_CLOSE'       TO lt_receiving.
    APPEND 'NEW_DOCUMENT'          TO lt_receiving.
    APPEND 'ALLOWED_DOCS_CHANGED'  TO lt_receiving.
    APPEND 'TREE_PREDOC_ADD'       TO lt_receiving.
    APPEND 'TREE_PREDOC_DELETE'    TO lt_receiving.
    APPEND 'TRANSACTION_LEAVE'     TO lt_receiving.
    APPEND 'KERNEL_RESET'          TO lt_receiving.

    APPEND 'MIGO_TREE_STATUS'     TO lt_sending.
    APPEND 'TREE_PREDOC_SELECTED' TO lt_sending.

    APPEND 'MIGO_OK_TREE_CONTEXT' TO lt_okcodes.                 "216027

    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer  = me
        it_receiving   = lt_receiving
        it_sending     = lt_sending
        it_okcodes     = lt_okcodes.                             "216027
* Report and screen data
    p_repid = i_repid.
    p_dynnr = i_dynnr.
    IF p_repid IS INITIAL. p_repid = sy-repid. ENDIF.
    IF p_dynnr IS INITIAL. p_dynnr = sy-dynnr. ENDIF.
* Read user parameters to find out whether the tree is open or closed.
* The importing parameter I_NOTREE deactivates the tree always.
    CREATE OBJECT oref_defaults EXPORTING i_action = 'MIGO_TREE'.
* Preset global defaults for the tree (overridden by user data)
    CALL METHOD oref_defaults->preset( i_element = 'DISPLAY'
                                    i_active  = x ).
    CALL METHOD oref_defaults->preset( i_element = 'WIDTH'
                                    i_active  = 160 ).
* Start if visible
    IF i_notree IS INITIAL AND oref_defaults->get( 'DISPLAY' ) = x.
      CALL METHOD tree_start.
    ENDIF.
  ENDMETHOD.

************************************************************************
* Message handler for the framework (inbound communication with MIGO)
************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: ls_data     TYPE ty_data,
        ls_message  TYPE lif_migo_frame~ty_s_message,
        l_highlight TYPE char1.
  FIELD-SYMBOLS: <ls_key> TYPE lcl_migo_kernel=>ty_s_refdockey.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE i_message_id.
    WHEN 'MIGO_TREE_OPEN'.
      IF f_is_visible = abap_false.
        CALL METHOD toggle_visibility.
      ENDIF.
    WHEN 'MIGO_TREE_CLOSE'.
      IF f_is_visible = abap_true.
        CALL METHOD toggle_visibility.
      ENDIF.
    WHEN 'NEW_DOCUMENT'.
      ASSIGN is_message-dref->* TO <ls_key>.
      CASE is_message-data1.
        WHEN 'R01'.
          ls_data-ebeln = <ls_key>-po_number.
          CALL METHOD history_object_add
            EXPORTING
              i_type      = c_purchase_order
              i_highlight = x
              is_data     = ls_data.
        WHEN 'R02'.
          CASE is_message-data2.
            WHEN 'POSTED'. l_highlight = space.
            WHEN OTHERS.   l_highlight = x.
          ENDCASE.
          ls_data-mblnr = <ls_key>-mat_doc.
          ls_data-mjahr = <ls_key>-doc_year.
          CALL METHOD history_object_add
            EXPORTING
              i_type      = c_material_document
              i_highlight = l_highlight
              is_data     = ls_data.
        WHEN 'R08'.
          ls_data-aufnr = <ls_key>-order_number.
          CALL METHOD history_object_add
            EXPORTING
              i_type      = c_order
              i_highlight = x
              is_data     = ls_data.
        WHEN 'R09'.
          ls_data-rsnum = <ls_key>-reservation_number.
          CALL METHOD history_object_add
            EXPORTING
              i_type      = c_reservation
              i_highlight = x
              is_data     = ls_data.

      ENDCASE.
*      CALL METHOD status_set.
    WHEN 'ALLOWED_DOCS_CHANGED' OR 'KERNEL_RESET'.
      CALL METHOD status_information.
    WHEN 'NEW_SEARCHRESULT'.
*     Open the tree to show the result
      IF f_is_visible = space.
        CALL METHOD toggle_visibility.
      ENDIF.
      CASE is_message-data1.
        WHEN 'R01'. CALL METHOD new_searchresult_po
                      EXPORTING
                        i_data = is_message-dref.
        WHEN 'R02'. CALL METHOD new_searchresult_matdoc
                      EXPORTING
                        i_data = is_message-dref.
      ENDCASE.
    WHEN 'TREE_PREDOC_ADD'.
      ASSIGN is_message-dref->* TO <ls_key>.
      ls_data-guid  = is_message-data1.
      ls_data-refid = <ls_key>-refid.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_predoc
          i_highlight = space
          is_data     = ls_data.
    WHEN 'TREE_PREDOC_DELETE'.
      ls_data-guid = is_message-data1.
      CALL METHOD history_object_delete
        EXPORTING
          i_type  = c_predoc
          is_data = ls_data.
    WHEN 'TRANSACTION_LEAVE'.
      CALL METHOD tree_state_save.
  ENDCASE.
ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE i_okcode.                                                 "216027
    WHEN 'MIGO_OK_TREE_CONTEXT'.                                 "216027
      CALL METHOD tree_object_take                               "216027
        EXPORTING                                                "216027
          i_node = p_node_key.                                   "216027
  ENDCASE.                                                       "216027
ENDMETHOD.