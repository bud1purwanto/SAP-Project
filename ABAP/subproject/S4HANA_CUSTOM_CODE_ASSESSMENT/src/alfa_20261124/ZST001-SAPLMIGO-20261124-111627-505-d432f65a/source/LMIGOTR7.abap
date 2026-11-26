*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR7                                                   *
*----------------------------------------------------------------------*
************************************************************************
* Switch tree on/off
************************************************************************
  METHOD toggle_visibility.
    CHECK f_not_creatable IS INITIAL.
    IF f_is_visible = space.
* Start the tree if necessary
      IF p_running IS INITIAL.
        CALL METHOD tree_start.
        CHECK f_not_creatable IS INITIAL.
      ELSE.
        CALL METHOD oref_tree->frontend_update.
        CALL METHOD oref_docking->set_visible EXPORTING visible = '1'.
        def_sms 'MIGO_TREE_STATUS' 'VISIBILITY' abap_true.
      ENDIF.
      f_is_visible = x.
    ELSE.
      CALL METHOD oref_docking->set_visible EXPORTING visible = '0'.
      CLEAR f_is_visible.
      def_sms 'MIGO_TREE_STATUS' 'VISIBILITY' abap_false.
    ENDIF.
* Save the new setting.
    CALL METHOD oref_defaults->set( i_element = 'DISPLAY'
                                 i_active  = f_is_visible ).
    CALL METHOD cl_mmim_userdefaults=>flush_all.
  ENDMETHOD.
************************************************************************
* Modify the button bar, delete unused buttons, add new ones
************************************************************************
  METHOD button_bar.
    DATA: l_quick TYPE iconquick,
          l_text  TYPE text40.
    CALL METHOD oref_tree->get_toolbar_object
      IMPORTING er_toolbar = oref_toolbar.
* Hierarchy button
*    l_quick = text-111.                   "Sorting searchresult
*    CALL METHOD oref_toolbar->add_button
*      EXPORTING
*        fcode     = 'OK_HIERARCHY'
*        icon      = c_icon_hierarchy
*        quickinfo = l_quick
*        butn_type = cntb_btype_button.
* Delete-button
    l_quick = text-116.                   "Sorting searchresult
    CALL METHOD oref_toolbar->add_button
      EXPORTING
        fcode     = 'OK_DELETE'
        icon      = c_icon_delete
        quickinfo = l_quick
        butn_type = cntb_btype_button.
* Separator to avoid that the nice hierarchy button disappears
    CALL METHOD oref_toolbar->add_button
      EXPORTING
        fcode     = ''
        icon      = ''
        quickinfo = ''
        butn_type = cntb_btype_sep.
* Close tree (the Rolf-Button)
    l_quick = text-108.                   "Kill list
    CALL METHOD oref_toolbar->add_button
      EXPORTING
        fcode     = 'OK_CLOSE'
        icon      = c_icon_close
        quickinfo = l_quick
        butn_type = cntb_btype_button.
* Need to be disabled here instead during tree constructor because
* I want the functions to be available in the context menu
*    CALL METHOD oref_toolbar->delete_button( '&COLLAPSE' ).
*    CALL METHOD oref_toolbar->delete_button( '&EXPAND' ).
* Set handler function
    SET HANDLER toolbar_event FOR oref_toolbar.
  ENDMETHOD.
************************************************************************
* Save the status of expanded and collapsed nodes and the width
************************************************************************
  METHOD tree_state_save.
    DATA: lt_state    TYPE lvc_t_nkey.
    DATA: l_active    TYPE es_active,
          l_extension TYPE i,
          ls_nodes    TYPE pty_nodes.
  CHECK p_running <> space.
* Read all nodes with expanded subtree...
    CALL METHOD oref_tree->get_expanded_nodes
      CHANGING
        ct_expanded_nodes = lt_state.
* ...and tree width
    CALL METHOD oref_docking->get_extension
      IMPORTING
        extension = l_extension.
* Get the data from the frontend IMMEDEATELY
    CALL METHOD cl_gui_cfw=>flush.
* Check for each node in the tree whether it is COLLAPSED. If yes,
* add the number to the user settings
    CLEAR l_active.
    LOOP AT pt_nodes INTO ls_nodes.
      READ TABLE lt_state WITH KEY table_line = ls_nodes-node
                               TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        CONCATENATE l_active ls_nodes-object INTO l_active
          SEPARATED BY space.
      ENDIF.
    ENDLOOP.
* Save data
    CALL METHOD oref_defaults->set( i_element = 'EXPANSION'
                                 i_active  = l_active ).
    CALL METHOD oref_defaults->set( i_element = 'WIDTH'
                                 i_active  = l_extension ).
    CALL METHOD cl_mmim_userdefaults=>flush_all.
  ENDMETHOD.
************************************************************************
* Load the tree state (expanded/collapsed subtrees, width)
************************************************************************
  METHOD tree_state_load.
    DATA: l_state           TYPE es_active,
          l_object          TYPE object_type,
          lt_collapsed      LIKE pt_nodes,
          ls_collapsed_node TYPE pty_nodes,
          ls_nodes          TYPE pty_nodes,
          ls_cust           TYPE lcl_migo_globals=>ty_s_cust,
          lt_refdoc         TYPE STANDARD TABLE OF refdoc,
          ls_layout         TYPE lvc_s_lacn,
          l_refdoc          TYPE refdoc.
* Expand all nodes first. This is necessary to collapse them after-
* wards according to the user settings. Without this -->
* "Relative node for insert not found" or something similar.
    LOOP AT pt_nodes INTO ls_nodes.
      CALL METHOD oref_tree->expand_node
        EXPORTING
          i_node_key    = ls_nodes-node
          i_level_count = 99.
    ENDLOOP.
    CLEAR lt_collapsed.
    l_state = oref_defaults->get( 'EXPANSION' ).
    IF NOT l_state IS INITIAL.
      SPLIT l_state AT space INTO TABLE lt_collapsed.
    ENDIF.
* Start collapsing beginning from the bottom
    SORT lt_collapsed BY object DESCENDING.
    LOOP AT lt_collapsed INTO ls_collapsed_node.
      READ TABLE pt_nodes INTO ls_nodes
        WITH KEY object = ls_collapsed_node-object.
      IF sy-subrc = 0.
        CALL METHOD oref_tree->collapse_subtree
          EXPORTING
            i_node_key = ls_nodes-node.
      ENDIF.
    ENDLOOP.
* The searchresult is initially always empty and therefore closed
    READ TABLE pt_nodes INTO ls_nodes WITH KEY object = c_searchresult.
    IF sy-subrc = 0.
      CALL METHOD oref_tree->collapse_subtree
        EXPORTING
          i_node_key = ls_nodes-node.
    ENDIF.
*   Disable all nodes completely whose REFDOC's are not possible
*   in the current MIGO at all. Used e.g. for MIGO_GO, which
*   has only "Order" and "Materialdocument".
*   List of possible refdocs.
    LOOP AT lcl_migo_globals=>t_cust INTO ls_cust.
      COLLECT ls_cust-refdoc INTO lt_refdoc.
    ENDLOOP.
    ls_layout-hidden   = x.
    ls_layout-u_hidden = x.
*   Check all nodes of the tree for presence (predoc always)
    LOOP AT pt_nodes INTO ls_nodes WHERE object <> c_predoc.
      CASE ls_nodes-object.
        WHEN c_purchase_order.    l_refdoc = 'R01'.
        WHEN c_material_document. l_refdoc = 'R02'.
        WHEN c_order.             l_refdoc = 'R08'.
        WHEN c_reservation.       l_refdoc = 'R09'.
      ENDCASE.
      READ TABLE lt_refdoc WITH KEY table_line = l_refdoc
                 TRANSPORTING NO FIELDS.
      CHECK sy-subrc <> 0.
      CALL METHOD oref_tree->change_node
        EXPORTING
          i_node_key     = ls_nodes-node
          i_outtab_line  = space
          is_node_layout = ls_layout.
    ENDLOOP.
  ENDMETHOD.
************************************************************************
* Give the tree an update on the actual status of MIGO.
* Needed to determine which documents can be selected (POs or
* material documents), and to reset the red colour in the tree
* upon initialization).
************************************************************************
  METHOD status_information.
    DATA: lt_allowed TYPE TABLE OF object_type,
          l_type TYPE object_type,
          ls_data TYPE ty_data,
          ls_layout TYPE lvc_s_lacn,
          l_update  TYPE c.
* Temporary table cleared if tree not running and lines = 0
    IF p_running = space AND
       lcl_migo_globals=>kernel->s_status-lines = 0.
      CLEAR pt_pretable.
    ENDIF.
* Leave if tree not running.
    CHECK p_running = x.
    CLEAR lt_allowed.
* Predocuments are allowed if no lines are in the table
    IF lcl_migo_globals=>kernel->s_status-allowed_predoc = abap_true.
      APPEND c_predoc TO lt_allowed.
    ENDIF.
* Allowed refdocs
  CASE lcl_migo_globals=>kernel->s_status-allowed_refdoc.
    WHEN 'R01'. APPEND c_purchase_order    TO lt_allowed.
    WHEN 'R08'. APPEND c_order             TO lt_allowed.
    WHEN 'R09'. APPEND c_reservation       TO lt_allowed.
    WHEN 'R02'. APPEND c_material_document TO lt_allowed.
  ENDCASE.
* Update only if change since last call
    CLEAR l_update.
    IF lt_allowed <> pt_allowed_objects.
      l_update = x.
      CLEAR ls_layout.
      ls_layout-u_style = x.
* Gray out
      ls_layout-style = c_style_inactive.
      LOOP AT pt_allowed_objects INTO l_type.
        READ TABLE lt_allowed WITH KEY table_line = l_type
                              TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          LOOP AT pt_data INTO ls_data WHERE type = l_type
                                        AND take = x
                                        AND style <> c_style_highlight.
            CALL METHOD oref_tree->change_node
              EXPORTING
                i_node_key     = ls_data-node
                i_outtab_line  = space
                is_node_layout = ls_layout.
            ls_data-style = ls_layout-style.
            MODIFY pt_data FROM ls_data TRANSPORTING style.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
* Activate
      ls_layout-style = c_style_default.
      LOOP AT lt_allowed INTO l_type.
        READ TABLE pt_allowed_objects WITH KEY table_line = l_type
                                     TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          LOOP AT pt_data INTO ls_data WHERE type = l_type
                                        AND take = x
                                        AND style <> c_style_highlight.
            CALL METHOD oref_tree->change_node
              EXPORTING
                i_node_key     = ls_data-node
                i_outtab_line  = space
                is_node_layout = ls_layout.
            ls_data-style = ls_layout-style.
            MODIFY pt_data FROM ls_data TRANSPORTING style.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      pt_allowed_objects = lt_allowed.
    ENDIF.
* Clear red colour when number of lines = 0.
    IF lcl_migo_globals=>kernel->s_status-lines = 0.
      l_update = x.
      CLEAR ls_layout.
      ls_layout-u_style = x.
      LOOP AT pt_data INTO ls_data WHERE style = c_style_highlight.
        READ TABLE pt_allowed_objects WITH KEY table_line = ls_data-type
                                     TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          ls_layout-style = c_style_default.
        ELSE.
          ls_layout-style = c_style_inactive.
        ENDIF.
        CALL METHOD oref_tree->change_node
          EXPORTING
            i_node_key     = ls_data-node
            i_outtab_line  = space
            is_node_layout = ls_layout.
        ls_data-style = ls_layout-style.
        MODIFY pt_data FROM ls_data TRANSPORTING style.
      ENDLOOP.
    ENDIF.
* Inform the frontend
    IF l_update = x AND f_is_visible <> space.
      CALL METHOD oref_tree->frontend_update.
    ENDIF.
  ENDMETHOD.
************************************************************************
* Handler for events in the toolbar.
* Not much actually, but can become more...
************************************************************************
  METHOD toolbar_event.
    CASE fcode.
      WHEN 'OK_HIERARCHY'.
        CALL METHOD hierarchy_set.
      WHEN 'OK_CLOSE'.
        CALL METHOD toggle_visibility.
      WHEN 'OK_DELETE'.
        CALL METHOD delete_from_buttonbar.
    ENDCASE.
  ENDMETHOD.
************************************************************************
* Events within the tree are registered
************************************************************************
  METHOD tree_events.
    DATA: lt_events TYPE cntl_simple_events,
          l_event   TYPE cntl_simple_event.
    CLEAR lt_events.
* This on is necessary to open/close subtrees
    l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
    l_event-appl_event = space.
    APPEND l_event TO lt_events.
* Context menu on header
    l_event-eventid =
                  cl_gui_column_tree=>eventid_header_context_men_req.
    l_event-appl_event = space.
    APPEND l_event TO lt_events.
* Context menu on node
    l_event-eventid =
                  cl_gui_column_tree=>eventid_node_context_menu_req.
    l_event-appl_event = space.
    APPEND l_event TO lt_events.
* Double click
    l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
    l_event-appl_event = x.
    APPEND l_event TO lt_events.
* Register
    CALL METHOD oref_tree->set_registered_events
      EXPORTING
        events  = lt_events.
* Handlers
    SET HANDLER tree_double_click    FOR oref_tree.
    SET HANDLER context_menu_request FOR oref_tree.
    SET HANDLER context_menu_select  FOR oref_tree.
  ENDMETHOD.
************************************************************************
* Wrapper to call TREE_OBJECT_TAKE
************************************************************************
  METHOD tree_double_click.
    CALL METHOD tree_object_take
      EXPORTING
        i_node = node_key.
  ENDMETHOD.
************************************************************************
* Handler for the double click or context menu function "TAKE"
* Depending on the type of node:
* a) If unselectanble parent: Expand/collapse
* b) If selectable -> Return data
* c) If nothing -> Issue message to user
************************************************************************
  METHOD tree_object_take.
    DATA: ls_data     TYPE ty_data,
          lt_expanded TYPE lvc_t_nkey,
          lt_children TYPE lvc_t_nkey,
          ls_key      TYPE lcl_migo_kernel=>ty_s_refdockey.
* Read node data
    READ TABLE pt_data INTO ls_data WITH KEY node = i_node.
    CHECK sy-subrc = 0.                              "to avoid CFW dumps
* Expand/collapse, if this item contains children
    IF ls_data-take IS INITIAL.
      CALL METHOD oref_tree->get_children
        EXPORTING
          i_node_key = i_node
        IMPORTING
          et_children = lt_children.
      CALL METHOD oref_tree->get_expanded_nodes
        CHANGING
          ct_expanded_nodes = lt_expanded.
      CALL METHOD cl_gui_cfw=>flush.
      READ TABLE lt_children INDEX 1 TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        READ TABLE lt_expanded WITH KEY table_line = i_node
                               TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          CALL METHOD oref_tree->collapse_subtree
            EXPORTING
              i_node_key = i_node.
        ELSE.
          CALL METHOD oref_tree->expand_node
            EXPORTING
              i_node_key = i_node
              i_level_count = 1.
        ENDIF.
        EXIT.
      ENDIF.
    ENDIF.
* Check whether selection is allowed.
    IF ls_data-take = x.
      READ TABLE pt_allowed_objects WITH KEY table_line = ls_data-type
                                   TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
*       Call the kernel to read in the document
        CASE ls_data-type.
          WHEN c_purchase_order.
            ls_key-po_number = ls_data-ebeln.
            ls_key-po_item   = ls_data-ebelp.
*           the plant can be used as an additional selection criteria
*           and has to be read from the dynpro.                 ERP 10
            ls_key-po_werks  = godynpro-po_werks.
            CALL METHOD lcl_migo_globals=>kernel->ref_document_read
              EXPORTING
                i_refdoc = 'R01'
                is_key   = ls_key.
          WHEN c_order.
            ls_key-order_number = ls_data-aufnr.
            CALL METHOD lcl_migo_globals=>kernel->ref_document_read
              EXPORTING
                i_refdoc = 'R08'
                is_key   = ls_key.
          WHEN c_reservation.
            ls_key-reservation_number = ls_data-rsnum.
            CALL METHOD lcl_migo_globals=>kernel->ref_document_read
              EXPORTING
                i_refdoc = 'R09'
                is_key   = ls_key.
          WHEN c_material_document.
            ls_key-mat_doc  = ls_data-mblnr.
            ls_key-doc_year = ls_data-mjahr.
            CALL METHOD lcl_migo_globals=>kernel->ref_document_read
              EXPORTING
                i_refdoc = 'R02'
                is_key   = ls_key.
          WHEN c_predoc.
            def_sms 'TREE_PREDOC_SELECTED' ls_data-guid space.
        ENDCASE.
        EXIT.
      ENDIF.
    ENDIF.
* Nothing appropriate found --> Message to user
    MESSAGE s019(migo).
  ENDMETHOD.
************************************************************************
* Request for context menu
* Depending on the actual node, contextual new function can be added.
************************************************************************
  METHOD context_menu_request.
    DATA: ls_data TYPE ty_data,
          lt_disable TYPE ui_functions,
          l_text TYPE gui_text.
    READ TABLE pt_data INTO ls_data WITH KEY node = node_key.
    CHECK sy-subrc = 0.                              "To avoid surprises
* Lines with TAKE-flag can be copied, theoretically...
    IF ls_data-take = x.
      l_text = 'Take ojbect'(109).
      CALL METHOD menu->add_function
        EXPORTING
          fcode = 'OK_TAKE'
          text  = l_text.
      CALL METHOD menu->add_separator.
    ENDIF.
* Deletion functions depending on node hierarchy (only history section)
    CLEAR l_text.
    CASE determine_scope( node_key ).
      WHEN c_single.  l_text = 'Delete entry'(115).
      WHEN c_section. l_text = 'Delete section'(114).
      WHEN c_all.     l_text = 'Delete all sections'(113).
    ENDCASE.
* Add text to menu
    IF l_text <> space.
      CALL METHOD menu->add_function
        EXPORTING
          fcode = 'OK_DELETE'
          text  = l_text.
    ENDIF.
* Disable functions depending on node type.
    CLEAR lt_disable.
* Is this an allowed object?
    READ TABLE pt_allowed_objects WITH KEY table_line = ls_data-type
                                 TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND 'OK_TAKE' TO lt_disable.
    ENDIF.
* Disable
    CALL METHOD menu->disable_functions
      EXPORTING
        fcodes = lt_disable.
  ENDMETHOD.
************************************************************************
* Execution of context menu function
************************************************************************
  METHOD context_menu_select.
    CASE fcode.
      WHEN 'OK_TAKE'.
*       The context menu is executed before PAI. The action has
*       to be delayed until the end of PAI due to problems with
*       field transport. The call to SET_NEW_OK_CODE triggers PAI.
        p_node_key = node_key.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'MIGO_OK_TREE_CONTEXT'.
      WHEN 'OK_DELETE'.
        CALL METHOD delete_history
          EXPORTING
            i_node  = node_key.
    ENDCASE.
  ENDMETHOD.
************************************************************************
* Delete-Button on the button-bar.
* Needs to find out which line is selected and sets the proper
* scope for the deletion routine.
************************************************************************
  METHOD delete_from_buttonbar.
    DATA: lt_selected TYPE lvc_t_nkey,
          l_node      TYPE lvc_nkey,
          ls_data     TYPE ty_data.
* Get selected node
    CALL METHOD oref_tree->get_selected_nodes
      CHANGING
        ct_selected_nodes = lt_selected.
    CALL METHOD cl_gui_cfw=>flush.
    READ TABLE lt_selected INTO l_node INDEX 1.
    CHECK sy-subrc = 0.
* Execute the deletion.
    CALL METHOD delete_history( l_node ).
  ENDMETHOD.