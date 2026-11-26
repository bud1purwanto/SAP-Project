*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR6                                                   *
*----------------------------------------------------------------------*
************************************************************************
* Create docking container, start tree, read history, ...
************************************************************************
  METHOD tree_start.
    DATA: l_extension  TYPE i,
          ls_variant   TYPE disvariant,
          lt_toolbar_excluding TYPE ui_functions.
    CHECK p_running IS INITIAL.                  "Leave if already there
* Get default tree extension (width)
    l_extension = oref_defaults->get( 'WIDTH' ).
* Create docking control
    CREATE OBJECT oref_docking
      EXPORTING
        repid     = p_repid
        dynnr     = p_dynnr
        extension = l_extension
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      CALL METHOD say_goodbye.
      EXIT.
    ENDIF.
* Start invisible to have the tree closed in case of CNTL_ERROR
    CALL METHOD oref_docking->set_visible
      EXPORTING
        visible = '0'.
* Create tree
    CREATE OBJECT oref_tree
      EXPORTING
        parent              = oref_docking
        node_selection_mode = cl_gui_column_tree=>node_sel_mode_single
        item_selection      = space
        no_html_header      = x
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      CALL METHOD say_goodbye.
      EXIT.
    ENDIF.
    CALL METHOD fieldcatalog_build.
* Prepare header data
    ps_header-width     = 30.
    ps_header-width_pix = ''.
    ps_header-heading   = text-101.
* Exclude some buttons
    CLEAR lt_toolbar_excluding.
    APPEND '&CALC'       TO lt_toolbar_excluding.
    APPEND '&FIND'       TO lt_toolbar_excluding.
    APPEND '&PRINT_BACK' TO lt_toolbar_excluding.
    APPEND '&PRINT_PREV' TO lt_toolbar_excluding.
    APPEND '&COL0'       TO lt_toolbar_excluding.
* Start tree
    CLEAR: pt_data, pt_tree.
    CLEAR ls_variant.
    ls_variant-report = p_repid.
    CALL METHOD oref_tree->set_table_for_first_display
      EXPORTING
        is_hierarchy_header  = ps_header
        i_save               = 'A'
        i_default            = x
        is_variant           = ls_variant
        it_toolbar_excluding = lt_toolbar_excluding
      CHANGING
        it_outtab            = pt_tree
        it_fieldcatalog      = pt_fc
      EXCEPTIONS
        OTHERS               = 1.
    IF sy-subrc <> 0.
      CALL METHOD say_goodbye.
      EXIT.
    ENDIF.
* The whole control business seems to run.
    f_not_creatable = space.
    f_is_visible    = x.
    p_running       = x.
* Prepare the tree for initial display
    CALL METHOD skeleton_build.
    CALL METHOD history_read.
    CALL METHOD button_bar.
    CALL METHOD tree_events.
    CALL METHOD tree_state_load.
    CALL METHOD sortmaster_build.
* Finally, the docking control can be opened
    CALL METHOD oref_docking->set_visible
      EXPORTING
        visible = '1'.
    CALL METHOD oref_tree->frontend_update.
    CALL METHOD status_information.
* Send message that the tree is visible now
    def_sms 'MIGO_TREE_STATUS' 'VISIBILITY' abap_true.
  ENDMETHOD.                    "tree_start
************************************************************************
* Tree cannot be created. Message, set flags, and exit
************************************************************************
  METHOD say_goodbye.
    f_not_creatable = x.
    f_is_visible    = space.
    p_running       = space.
    MESSAGE s017(migo).
  ENDMETHOD.                    "say_goodbye
************************************************************************
* Destroy tree, save current settings (width, expansion state)
************************************************************************
  METHOD destroy.
    CHECK p_running = x.
    CALL METHOD tree_state_save.
    IF NOT oref_tree IS INITIAL.
      CALL METHOD oref_tree->free.
    ENDIF.
    IF NOT oref_docking IS INITIAL.
      CALL METHOD oref_docking->free.
    ENDIF.
    FREE: oref_tree, oref_docking, oref_defaults.
*    CALL METHOD cl_gui_cfw=>flush.
  ENDMETHOD.                    "destroy
************************************************************************
* Insert the administrative nodes into the tree
* and save to numbers of the top-level-nodes
************************************************************************
  METHOD skeleton_build.
    DATA: l_level0 TYPE lvc_nkey,
          l_level1 TYPE lvc_nkey,
          l_level2 TYPE lvc_nkey,
          ls_nodes TYPE pty_nodes.
* Searchresult path
*    CALL METHOD add_hierarchy
*      EXPORTING
*        i_top    = c_searchresult
*        i_type   = space
*        i_dummy  = space
*        i_parent = ''
*        i_icon   = c_icon_none
*        i_text   = text-100              "Search result
*      IMPORTING
*        e_key    = l_level0.
*    ls_nodes-object = c_searchresult.
*    ls_nodes-node   = l_level0.
*    APPEND ls_nodes TO pt_nodes.
*    CALL METHOD add_hierarchy
*      EXPORTING
*        i_top    = c_searchresult
*        i_type   = space
*        i_dummy  = x
*        i_parent = l_level0
*        i_icon   = c_icon_none
*        i_text   = text-105              "No data available
*      IMPORTING
*        e_key    = l_level1.
* History path
*    CALL METHOD add_hierarchy
*      EXPORTING
*        i_top    = c_history
*        i_type   = space
*        i_dummy  = space
*        i_parent = ''
*        i_icon   = c_icon_none
*        i_text   = text-101               "History
*      IMPORTING
*        e_key   = l_level0.
*    ls_nodes-object = c_history.
*    ls_nodes-node   = l_level0.
*    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_purchase_order
        i_dummy  = space
        i_parent = ''
        i_icon   = c_icon_none
        i_text   = text-102             "Purchase orders
      IMPORTING
        e_key    = l_level1.
    ls_nodes-object = c_purchase_order.
    ls_nodes-node   = l_level1.
    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_purchase_order
        i_dummy  = x
        i_parent = l_level1
        i_icon   = c_icon_none
        i_text   = text-105                 "No data available
      IMPORTING
        e_key    = l_level2.
* Orders
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_order
        i_dummy  = space
        i_parent = l_level0
        i_icon   = c_icon_none
        i_text   = text-120             "Orders
      IMPORTING
        e_key    = l_level1.
    ls_nodes-object = c_order.
    ls_nodes-node   = l_level1.
    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_order
        i_dummy  = x
        i_parent = l_level1
        i_icon   = c_icon_none
        i_text   = text-105                 "No data available
      IMPORTING
        e_key    = l_level2.
* Reserations
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_reservation
        i_dummy  = space
        i_parent = l_level0
        i_icon   = c_icon_none
        i_text   = text-121
      IMPORTING
        e_key    = l_level1.
    ls_nodes-object = c_reservation.
    ls_nodes-node   = l_level1.
    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_reservation
        i_dummy  = x
        i_parent = l_level1
        i_icon   = c_icon_none
        i_text   = text-105                 "No data available
      IMPORTING
        e_key    = l_level2.
* Material documents
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_material_document
        i_dummy  = space
        i_parent = l_level0
        i_icon   = c_icon_none
        i_text   = text-103                 "Material documents
      IMPORTING
        e_key    = l_level1.
    ls_nodes-object = c_material_document.
    ls_nodes-node   = l_level1.
    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_material_document
        i_dummy  = x
        i_parent = l_level1
        i_icon   = c_icon_none
        i_text   = text-105                 "No data available
      IMPORTING
        e_key    = l_level2.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_predoc
        i_dummy  = space
        i_parent = l_level0
        i_icon   = c_icon_none
        i_text   = text-104                 "Stored data
      IMPORTING
        e_key    = l_level1.
    ls_nodes-object = c_predoc.
    ls_nodes-node   = l_level1.
    APPEND ls_nodes TO pt_nodes.
    CALL METHOD add_hierarchy
      EXPORTING
        i_top    = c_history
        i_type   = c_predoc
        i_dummy  = x
        i_parent = l_level1
        i_icon   = c_icon_none
        i_text   = text-105                  "No data available
      IMPORTING
        e_key    = l_level2.
  ENDMETHOD.                    "skeleton_build
************************************************************************
* Add a node to the tree and save the returned nodeID for further use
************************************************************************
  METHOD add_hierarchy.
    DATA: ls_layout TYPE lvc_s_layn,
          ls_data   TYPE ty_data.
    CLEAR ls_layout.
    ls_layout-n_image   = i_icon.
    ls_layout-exp_image = i_icon.
    CLEAR ls_data.
    ls_data-top   = i_top.
    ls_data-type  = i_type.
    ls_data-dummy = i_dummy.
* Add the node
    CALL METHOD oref_tree->add_node
      EXPORTING
        i_relat_node_key = i_parent
        i_relationship   = cl_gui_column_tree=>relat_last_child
        i_node_text      = i_text
        is_node_layout   = ls_layout
        is_outtab_line   = space
      IMPORTING
        e_new_node_key   = e_key.
* Save the new nodeID
    ls_data-node = e_key.
    APPEND ls_data TO pt_data.
  ENDMETHOD.                    "add_hierarchy
************************************************************************
* Read user objects and fill them into the tree
************************************************************************
  METHOD history_read.
    DATA: lt_objects         TYPE TABLE OF esruocom,
          lt_objects_inverse TYPE TABLE OF esruocom,
          ls_objects         TYPE esruocom,
          ls_data            TYPE ty_data,
          BEGIN OF ls_matdoc,
            mblnr TYPE mblnr,
            mjahr TYPE mjahr,
          END OF ls_matdoc,
          lt_predoc TYPE TABLE OF mmim_predoc_org,
          ls_predoc TYPE mmim_predoc_org.
* Read the history of purchase orders
    CALL FUNCTION 'ES_READ_USER_OBJECTS'
      EXPORTING
        iobject_typ = 'BUS2012'
        maxanz      = c_history_length
        maxstore    = c_history_length
      TABLES
        iesruo      = lt_objects_inverse.
* Invert the sequence to have the newest entries on top
    CLEAR lt_objects.
    LOOP AT lt_objects_inverse INTO ls_objects.
      INSERT ls_objects INTO lt_objects INDEX 1.
    ENDLOOP.
    LOOP AT lt_objects INTO ls_objects.
      CLEAR ls_data.
      ls_data-ebeln = ls_objects-object_id.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_purchase_order
          i_highlight = space
          is_data     = ls_data
          i_local     = x.
    ENDLOOP.
* Read the history of other orders
    CALL FUNCTION 'ES_READ_USER_OBJECTS'
      EXPORTING
        iobject_typ = 'BUS2048'
        maxanz      = c_history_length
        maxstore    = c_history_length
      TABLES
        iesruo      = lt_objects_inverse.
* Invert the sequence to have the newest entries on top
    CLEAR lt_objects.
    LOOP AT lt_objects_inverse INTO ls_objects.
      INSERT ls_objects INTO lt_objects INDEX 1.
    ENDLOOP.
    LOOP AT lt_objects INTO ls_objects.
      CLEAR ls_data.
      ls_data-aufnr = ls_objects-object_id.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_order
          i_highlight = space
          is_data     = ls_data
          i_local     = x.
    ENDLOOP.
* Read the history of reservations
    CALL FUNCTION 'ES_READ_USER_OBJECTS'
      EXPORTING
        iobject_typ = 'BUS2093'
        maxanz      = c_history_length
        maxstore    = c_history_length
      TABLES
        iesruo      = lt_objects_inverse.
* Invert the sequence to have the newest entries on top
    CLEAR lt_objects.
    LOOP AT lt_objects_inverse INTO ls_objects.
      INSERT ls_objects INTO lt_objects INDEX 1.
    ENDLOOP.
    LOOP AT lt_objects INTO ls_objects.
      CLEAR ls_data.
      ls_data-rsnum = ls_objects-object_id.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_reservation
          i_highlight = space
          is_data     = ls_data
          i_local     = x.
    ENDLOOP.
* Material documents
    CALL FUNCTION 'ES_READ_USER_OBJECTS'
      EXPORTING
        iobject_typ = 'BUS2017'
        maxanz      = c_history_length
        maxstore    = c_history_length
      TABLES
        iesruo      = lt_objects_inverse.
    CLEAR lt_objects.
    LOOP AT lt_objects_inverse INTO ls_objects.
      INSERT ls_objects INTO lt_objects INDEX 1.
    ENDLOOP.
    LOOP AT lt_objects INTO ls_objects.
      CLEAR ls_data.
      ls_matdoc     = ls_objects-object_id.
      ls_data-mblnr = ls_matdoc-mblnr.
      ls_data-mjahr = ls_matdoc-mjahr.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_material_document
          i_highlight = space
          is_data     = ls_data
          i_local     = x.
    ENDLOOP.
* Stored data
    SELECT * FROM mmim_predoc_org INTO TABLE lt_predoc
      WHERE uname = sy-uname
        AND repid = c_repid.
* Ann.: Access by 'SAPLMIGO' is incorrect, because the tree
* does not belong to MIGO. But as long as MIGO is the only user,
* it's o.k.
    SORT lt_predoc BY datlo timlo.
    LOOP AT lt_predoc INTO ls_predoc.
      CLEAR ls_data.
      ls_data-guid   = ls_predoc-guid.
      ls_data-refid  = ls_predoc-refid.
      CALL METHOD history_object_add
        EXPORTING
          i_type      = c_predoc
          i_highlight = space
          is_data     = ls_data
          i_local     = x.
    ENDLOOP.
  ENDMETHOD.                    "history_read
************************************************************************
* Add a history object to the tree. If already within the list,
* move to top. If new, add on top and delete too old entries.
************************************************************************
  METHOD history_object_add.
    DATA: l_text    TYPE lvc_value,
          ls_layout TYPE lvc_s_layn,
          ls_data   TYPE ty_data,
          ls_nodes  TYPE pty_nodes,
          l_count   TYPE i,
          l_override(1) TYPE c,
          cl_change TYPE REF TO /sappspro/cl_numbers,
          lf_active TYPE boolean.
    .
* If the tree is not running yet, add the objects to a
* temporary table containing all entries that have to be marked
* red upon tree start
    IF p_running = space AND i_highlight = x.
      APPEND is_data TO pt_pretable.
    ENDIF.
* If the tree is not running, there is nothing more to do here.
    CHECK p_running = x.
    CLEAR ls_layout.
* Delete the NODATA line, if still present
    READ TABLE pt_data INTO ls_data WITH KEY top    = c_history
                                            type   = i_type
                                            dummy  = x.
    IF sy-subrc = 0.
      DELETE pt_data INDEX sy-tabix.
      CALL METHOD oref_tree->delete_subtree
        EXPORTING
          i_node_key = ls_data-node.
    ENDIF.
* Determine the insertion style. If the document is contained in the
* table of items to be highlighted, this overrides other settings.
    l_override = space.
    CASE i_type.
      WHEN c_purchase_order.
        READ TABLE pt_pretable WITH KEY ebeln = is_data-ebeln
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0. l_override = x. ENDIF.
      WHEN c_order.
        READ TABLE pt_pretable WITH KEY aufnr = is_data-aufnr
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0. l_override = x. ENDIF.
      WHEN c_reservation.
        READ TABLE pt_pretable WITH KEY rsnum = is_data-rsnum
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0. l_override = x. ENDIF.
      WHEN c_material_document.
        READ TABLE pt_pretable WITH KEY mblnr = is_data-mblnr
          TRANSPORTING NO FIELDS.
        IF sy-subrc = 0. l_override = x. ENDIF.
    ENDCASE.
    IF i_highlight = x OR l_override = x.
      ls_layout-style = c_style_highlight.
    ELSE.
      READ TABLE pt_allowed_objects WITH KEY table_line = i_type
                                   TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        ls_layout-style = c_style_default.
      ELSE.
        ls_layout-style = c_style_inactive.
      ENDIF.
    ENDIF.
* Append the new entry to the correct subtree as top item
    CLEAR ls_data.
    CASE i_type.
      WHEN c_purchase_order.
        WRITE is_data-ebeln TO l_text.

* check if long procurement number is active                                        1
        CLEAR: lf_active.
        CREATE OBJECT cl_change.

        CALL METHOD cl_change->is_active
          RECEIVING
            rv_active = lf_active.

        IF lf_active = 'X'.
          TRY.
              l_text =
              /sappspro/cl_numbers=>lookup( is_data-ebeln ).
            CATCH /sappspro/cx_number_not_found.
*             number does not exist.
          ENDTRY.
        ENDIF.

        ls_layout-n_image   = c_icon_none.
        ls_layout-exp_image = c_icon_none.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_purchase_order
                                                take  = x
                                                ebeln = is_data-ebeln
                                                TRANSPORTING node.
      WHEN c_order.
        WRITE is_data-aufnr TO l_text.
        ls_layout-n_image   = c_icon_none.
        ls_layout-exp_image = c_icon_none.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_order
                                                take  = x
                                                aufnr = is_data-aufnr
                                                TRANSPORTING node.
      WHEN c_reservation.
*     RSNUM has no ALPHA in the domain, as all other known fields do.
        WRITE is_data-rsnum TO l_text USING EDIT MASK '==ALPHA'.
        ls_layout-n_image   = c_icon_none.
        ls_layout-exp_image = c_icon_none.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_reservation
                                                take  = x
                                                rsnum = is_data-rsnum
                                                TRANSPORTING node.
      WHEN c_material_document.
        WRITE is_data-mblnr TO l_text.
        ls_layout-n_image = c_icon_none.
        ls_layout-exp_image = c_icon_none.
        READ TABLE pt_data INTO ls_data WITH KEY top  = c_history
                                                type = c_material_document
                                                take = x
                                               mblnr = is_data-mblnr
                                                TRANSPORTING node.
      WHEN c_predoc.
        l_text = is_data-refid.                             "381402
        IF l_text+39 <> '_'.                                "381402
*       No template
          ls_layout-n_image   = c_icon_none.                "381402
          ls_layout-exp_image = c_icon_none.                "381402
        ELSE.                                               "381402
*       Template: Show icon and remove the (dirty) indicator char
          ls_layout-n_image   = c_icon_favorite.            "381402
          ls_layout-exp_image = c_icon_favorite.            "381402
          l_text+39 = ' '.                                  "381402
        ENDIF.                                              "381402
        READ TABLE pt_data INTO ls_data WITH KEY top = c_history
                                               type = c_predoc
                                               take = x
                                             guid  = is_data-guid
                                             TRANSPORTING node.
    ENDCASE.
* Delete the old entry from the tree (refers to the READs above)
    IF sy-subrc = 0.
      DELETE pt_data INDEX sy-tabix.
      CALL METHOD oref_tree->delete_subtree
        EXPORTING
          i_node_key = ls_data-node.
    ENDIF.
* Add the new item
    READ TABLE pt_nodes INTO ls_nodes WITH KEY object = i_type.
    ls_data = is_data.
    ls_data-top   = c_history.
    ls_data-type  = i_type.
    ls_data-take  = x.
    ls_data-style = ls_layout-style.
    CALL METHOD oref_tree->add_node
      EXPORTING
        i_relat_node_key = ls_nodes-node
        i_relationship   = cl_gui_column_tree=>relat_first_child
        i_node_text      = l_text
        is_node_layout   = ls_layout
        is_outtab_line   = space
      IMPORTING
        e_new_node_key   = ls_data-node.
* Store the nodeID
    INSERT ls_data INTO pt_data INDEX 1.
* Delete all entries that exceed the maximum number of objects
    CLEAR l_count.
    LOOP AT pt_data INTO ls_data WHERE top  = c_history
                                  AND type = i_type
                                  AND take = x.
      l_count = l_count + 1.
      IF l_count > c_history_length.
        CALL METHOD oref_tree->delete_subtree
          EXPORTING
            i_node_key = ls_data-node.
        DELETE pt_data.
      ENDIF.
    ENDLOOP.
* Send the data to the tree, if the tree is  visible
    IF i_local IS INITIAL AND f_is_visible <> space.
      CALL METHOD oref_tree->frontend_update.
    ENDIF.
  ENDMETHOD.                    "history_object_add
************************************************************************
* Delete a history object. Much easier than adding one...
************************************************************************
  METHOD history_object_delete.
    DATA: ls_data  TYPE ty_data,
          ls_nodes TYPE pty_nodes.
    CHECK p_running = x.
    CASE i_type.
      WHEN c_purchase_order.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_purchase_order
                                                take  = x
                                                ebeln = is_data-ebeln
                                                TRANSPORTING node.
      WHEN c_order.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_order
                                                take  = x
                                                aufnr = is_data-aufnr
                                                TRANSPORTING node.
      WHEN c_reservation.
        READ TABLE pt_data INTO ls_data WITH KEY top   = c_history
                                                type  = c_reservation
                                                take  = x
                                                rsnum = is_data-rsnum
                                                TRANSPORTING node.
      WHEN c_material_document.
        READ TABLE pt_data INTO ls_data WITH KEY top  = c_history
                                              type = c_material_document
                                                take = x
                                               mblnr = is_data-mblnr
                                                TRANSPORTING node.
      WHEN c_predoc.
        READ TABLE pt_data INTO ls_data WITH KEY top = c_history
                                               type = c_predoc
                                               take = x
                                              guid  = is_data-guid
                                             TRANSPORTING node.
    ENDCASE.
    CHECK sy-subrc = 0.                                 "Leave if no hit
* Delete the node in the tree and the internal table
    CALL METHOD oref_tree->delete_subtree
      EXPORTING
        i_node_key = ls_data-node.
    DELETE pt_data WHERE node = ls_data-node.
* Maybe it is necessary to insert a new "Empty" flag.
    READ TABLE pt_data WITH KEY top  = c_history
                               type = i_type
                               take = x
                               TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      READ TABLE pt_nodes INTO ls_nodes WITH KEY object = i_type.
      CALL METHOD add_hierarchy
        EXPORTING
          i_top    = c_history
          i_type   = i_type
          i_dummy  = x
          i_parent = ls_nodes-node
          i_icon   = c_icon_none
          i_text   = text-105.                 "No data available
    ENDIF.
* Update frontend only if necessary
    IF i_local IS INITIAL AND f_is_visible <> space.
      CALL METHOD oref_tree->frontend_update.
    ENDIF.
  ENDMETHOD.                    "history_object_delete
************************************************************************
* This routine determines the type of a given node in the history
* section.
************************************************************************
  METHOD determine_scope.
    DATA: ls_data TYPE ty_data.
    CLEAR e_scope.
    READ TABLE pt_data INTO ls_data WITH KEY node = i_node
                                   TRANSPORTING top take type dummy.
    CHECK sy-subrc = 0.                              "To avoid surprises
* Works only for "real" entries in the history section
    CHECK ls_data-top = c_history.
    CHECK ls_data-dummy = space.
* What am I?
    IF ls_data-take = x.
      e_scope = c_single.
    ELSEIF ls_data-take = space AND ls_data-type <> space.
      e_scope = c_section.
    ELSEIF ls_data-take = space AND ls_data-type = space.
      e_scope = c_all.
    ENDIF.
  ENDMETHOD.                    "determine_scope

************************************************************************
* Deleting lines in the history section
************************************************************************
  METHOD delete_history.
    DATA: ls_data TYPE ty_data.
    FIELD-SYMBOLS: <wa> TYPE ty_data.
    READ TABLE pt_data INTO ls_data WITH KEY node = i_node.
    CASE determine_scope( i_node ).
      WHEN c_single.
        CALL METHOD delete_history_single
          EXPORTING
            i_node = i_node.
      WHEN c_section.
        LOOP AT pt_data ASSIGNING <wa> WHERE top  = c_history
                                        AND type = ls_data-type
                                        AND take = x.
          CALL METHOD delete_history_single
            EXPORTING
              i_node = <wa>-node.
        ENDLOOP.
      WHEN c_all.
        LOOP AT pt_data ASSIGNING <wa> WHERE top = c_history
                                        AND take = x.
          CALL METHOD delete_history_single
            EXPORTING
              i_node = <wa>-node.
        ENDLOOP.
    ENDCASE.
* Update database for user objects (makes MODIFY FROM TABLE).
* Executed in DELETE_HISTORY_SINGLE this would cause a lot
* of DB operations for scopes C_SECTION and C_ALL.
    IF ls_data-type <> c_predoc.
      CALL FUNCTION 'ES_SAVE_USER_OBJECTS'
        EXPORTING
          i_no_refresh = x.
    ENDIF.
* Update tree
    IF f_is_visible <> space.
      CALL METHOD oref_tree->frontend_update.
    ENDIF.
  ENDMETHOD.                    "delete_history
************************************************************************
* Delete a single line form the history section and perform
* the necessary operations on the database
************************************************************************
  METHOD delete_history_single.
    DATA: ls_data TYPE ty_data,
          l_typ   TYPE esruo_s-object_typ,
          l_id    TYPE esruo_s-object_id,
          BEGIN OF ls_matdoc,
            mblnr TYPE mblnr,
            mjahr TYPE mjahr,
          END OF ls_matdoc.
    READ TABLE pt_data INTO ls_data WITH KEY node = i_node
                                            top  = c_history
                                            take = x.
    CHECK sy-subrc = 0.
    CALL METHOD history_object_delete
      EXPORTING
        i_type  = ls_data-type
        is_data = ls_data
        i_local = x.
* Delete data from the database
    CASE ls_data-type.
      WHEN c_predoc.
*       Currently, the tree itself deletes the data on the
*       database. Maybe this could be done in the predocument
*       maintenance class?
        DELETE FROM mmim_predoc_org WHERE guid = ls_data-guid.
        CALL METHOD cl_mmim_datastore=>delete( ls_data-guid ).
*       BAdI: Delete
        IF NOT lcl_migo_globals=>if_badi IS INITIAL.        "552774
          CALL METHOD lcl_migo_globals=>if_badi->hold_data_delete
            EXPORTING
              i_guid = ls_data-guid.
        ENDIF.                                              "552774
      WHEN c_purchase_order.
        l_typ = 'BUS2012'.
        l_id  = ls_data-ebeln.
      WHEN c_order.
        l_typ = 'BUS2048'.
        l_id  = ls_data-aufnr.
      WHEN c_reservation.
        l_typ = 'BUS2093'.
        l_id  = ls_data-rsnum.
      WHEN c_material_document.
        l_typ = 'BUS2017'.
        ls_matdoc-mblnr = ls_data-mblnr.
        ls_matdoc-mjahr = ls_data-mjahr.
        l_id  = ls_matdoc.
    ENDCASE.
    IF ls_data-type <> c_predoc.
* Only buffer update. Transfer to database triggered by DELETE_HISTORY
      CALL FUNCTION 'ES_DELETE_USER_OBJECTS'
        EXPORTING
          iobject_typ = l_typ
          iobject_id  = l_id.
    ENDIF.
  ENDMETHOD.                    "delete_history_single