*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR8                                                   *
*----------------------------------------------------------------------*
************************************************************************
* Adding a new searchresult.
* Prepares data and hierarchy and calles SEARCHRESULT_UPDATE
************************************************************************
  METHOD searchresult_add.
    DATA: l_element   TYPE es_element,
          l_active    TYPE es_active,
          lt_sort     TYPE TABLE OF pty_sort,
          ls_sort     TYPE pty_sort.
    CHECK p_running = x.
* Copy external table into local buffer
    pt_search   = it_result.
    p_sorttype = i_type.
* Default sorting order according to type of searchresult
* For the meaning of the cryptic symbols like "00U" etc. please
* see the commentary block of METHOD SORTMASTER_BUILD.
    CLEAR pt_sort.
    CASE p_sorttype.
      WHEN c_purchase_order.
        l_element = 'SORT_PO'.
        APPEND '00U' TO pt_sort.
        APPEND '01U' TO pt_sort.
        APPEND '02U' TO pt_sort.
      WHEN c_material_document.
        l_element = 'SORT_MATDOC'.
        APPEND '03U' TO pt_sort.
        APPEND '05U' TO pt_sort.
    ENDCASE.
* Try to find a previous user setting
    l_active = oref_defaults->get( l_element ).
    IF NOT l_active IS INITIAL.
      SPLIT l_active AT ' ' INTO TABLE lt_sort.
* Eliminate all entries that are not allowed as sortfields for the
* actual type (avoids errors due to wrong entries in ESDUS)
      LOOP AT lt_sort INTO ls_sort.
        READ TABLE pt_sortmaster WITH KEY type = p_sorttype
                                         field_id = ls_sort-field_id
                                         TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          DELETE lt_sort.
        ENDIF.
      ENDLOOP.
* If at least one entry remains, keep the sorting order
      READ TABLE lt_sort INDEX 1 TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        pt_sort = lt_sort.
      ENDIF.
    ENDIF.
* Build searchresult
    CALL METHOD searchresult_update
      EXPORTING
        i_type = i_type.
  ENDMETHOD.

************************************************************************
* The data from the data table are sorted according to the type
* of documents and inserted into the tree. Old searchresults are
* cleared.
************************************************************************
  METHOD searchresult_update.
    DATA: ls_nodes       TYPE pty_nodes,
          ls_data        TYPE ty_data,
          ls_sort        TYPE pty_sort,
          ls_result      TYPE ty_data,
          ls_result_old  TYPE ty_data,
          ls_result_tree TYPE ty_data,
          ls_layout      TYPE lvc_s_layn,
          l_depth        TYPE i,
          l_expand_level TYPE i,
          l_loopindex    TYPE i,
          l_parent_index,
          l_topnode      TYPE lvc_nkey,
          l_parent       TYPE lvc_nkey,
          l_changed,
          l_name1(20),
          l_name2(20),
          l_value TYPE lvc_value,
          lt_intsort TYPE TABLE OF pty_sortmaster,
          ls_intsort TYPE pty_sortmaster.
    FIELD-SYMBOLS: <f1> TYPE ANY, <f2> TYPE ANY.
    CHECK p_running = x.
* Create the internal table used to create the searchresult. The global
* table pt_sort contains the field identifiers and their sorting
* order (UP/DOWN). The created table contains: fieldname, icon,
* takeable, parentness, ...
  CLEAR lt_intsort.
  CLEAR l_depth.
  LOOP AT pt_sort INTO ls_sort.
    READ TABLE pt_sortmaster INTO ls_intsort WITH KEY
                                     type     = i_type
                                     field_id = ls_sort-field_id.
    l_depth = l_depth + 1.
    ls_intsort-cnt    = l_depth.
    ls_intsort-order  = ls_sort-order.
    APPEND ls_intsort TO lt_intsort.
  ENDLOOP.
* Delete the entire old searchtree
    READ TABLE pt_nodes INTO ls_nodes
       WITH KEY object = c_searchresult.
    CALL METHOD oref_tree->delete_subtree
      EXPORTING
        i_node_key = ls_nodes-node.
    DELETE pt_nodes WHERE object = c_searchresult.
    DELETE pt_data  WHERE top    = c_searchresult.
* Add the new top level node for searchresults
    CLEAR ls_layout.
    ls_layout-n_image   = c_icon_none.
    ls_layout-exp_image = c_icon_none.
    CALL METHOD oref_tree->add_node
      EXPORTING
        i_relat_node_key = ''
        i_relationship   = cl_gui_column_tree=>relat_first_child
        i_node_text      = text-100            "Search result
        is_node_layout   = ls_layout
      IMPORTING
        e_new_node_key   = ls_nodes-node.
    ls_nodes-object = c_searchresult.
    APPEND ls_nodes TO pt_nodes.
    CLEAR ls_data.
    ls_data-node = ls_nodes-node.
    ls_data-top  = c_searchresult.
    APPEND ls_data TO pt_data.
    l_topnode = ls_nodes-node.
* Sort resulttable according to the sorting key
    SORT lt_intsort BY cnt DESCENDING.
    LOOP AT lt_intsort INTO ls_intsort.
      IF     ls_intsort-order = 'U'.
        SORT pt_search STABLE BY (ls_intsort-fieldname) ASCENDING.
      ELSEIF ls_intsort-order = 'D'.
        SORT pt_search STABLE BY (ls_intsort-fieldname) DESCENDING.
      ENDIF.
    ENDLOOP.
* Build search tree hierarchy
    SORT lt_intsort BY cnt.
    DESCRIBE TABLE lt_intsort LINES l_depth.
    CLEAR ls_result_old.
    LOOP AT pt_search INTO ls_result.
      l_loopindex = sy-tabix.
* Loop at all hierarchies
      DO l_depth TIMES.
* Check whether there has been a change in the n-th hierarchy level
        CLEAR l_changed.
        DO sy-index TIMES.
          READ TABLE lt_intsort INTO ls_intsort WITH KEY
                                               cnt = sy-index.
       CONCATENATE 'LS_RESULT-'     ls_intsort-fieldname INTO l_name1.
       CONCATENATE 'LS_RESULT_OLD-' ls_intsort-fieldname INTO l_name2.
          ASSIGN (l_name1) TO <f1>.
          ASSIGN (l_name2) TO <f2>.
          IF <f1> <> <f2>.
            l_changed = x.
          ENDIF.
        ENDDO.
* Get also lines starting with top level hierarchy SPACE:
        IF l_loopindex = 1.
          l_changed = x.
        ENDIF.
* If there was a change, add the node as child of the next higher level
        IF l_changed = x.
          l_parent_index = sy-index - 1.
          READ TABLE lt_intsort INTO ls_intsort INDEX l_parent_index.
          IF sy-subrc = 0.
            l_parent = ls_intsort-node.
          ELSE.
            l_parent = l_topnode.
          ENDIF.
* Get layout data for the new node
          READ TABLE lt_intsort INTO ls_intsort INDEX sy-index.
          ls_layout-n_image   = ls_intsort-image.
          ls_layout-exp_image = ls_intsort-image.
          WRITE <f1> TO l_value.
          ls_data = ls_result.
          ls_data-top = c_searchresult.
          ls_data-type = i_type.
          ls_data-take = ls_intsort-take.
          IF i_type = c_purchase_order.
            WRITE ls_data-menge UNIT ls_data-meins TO ls_data-menge_c.
          ENDIF.
          WRITE ls_data-wemng UNIT ls_data-meins TO ls_data-wemng_c.
* This is undynamic: Appending EBELN clear EBELP,
*                    appending MBLNR clear ZEILE.
* Allows selection of the entire PO or individual positions
          CASE ls_intsort-fieldname.
            WHEN 'EBELN'. CLEAR ls_data-ebelp.
            WHEN 'MBLNR'. CLEAR ls_data-zeile.
          ENDCASE.
          IF ls_intsort-list = x.
            ls_result_tree = ls_data.
          ELSE.
            CLEAR ls_result_tree.
          ENDIF.
* Determine linestyle (e.g. gray for material documents with
* document type <> WE)
          ls_layout-style = c_style_default.
          IF i_type = c_material_document.
            IF ls_data-vgart <> 'WE' AND ls_data-take = x.
              ls_layout-style = c_style_inactive.
              ls_data-take    = space.
            ENDIF.
          ENDIF.
* Add node to tree
          CALL METHOD oref_tree->add_node
            EXPORTING
              i_relat_node_key = l_parent
              i_relationship   = cl_gui_column_tree=>relat_last_child
              i_node_text      = l_value
              is_node_layout   = ls_layout
              is_outtab_line   = ls_result_tree
            IMPORTING
              e_new_node_key   = ls_data-node.
          APPEND ls_data TO pt_data.
* Update the received node key into the hierarchy info table
          ls_intsort-node = ls_data-node.
          MODIFY lt_intsort FROM ls_intsort
                                   INDEX sy-index TRANSPORTING node.
        ENDIF.
      ENDDO.
      ls_result_old = ls_result.
    ENDLOOP.
* If searchresult empty, add dummy text
    IF sy-subrc <> 0.
      CLEAR ls_data.
      ls_data-top = c_searchresult.
      ls_data-dummy = x.
      l_value = text-106.
      CLEAR ls_layout.
      ls_layout-n_image   = c_icon_none.
      ls_layout-exp_image = c_icon_none.
      CALL METHOD oref_tree->add_node
        EXPORTING
          i_relat_node_key = l_topnode
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = l_value
          is_node_layout   = ls_layout
          is_outtab_line   = ls_data
        IMPORTING
           e_new_node_key   = ls_data-node.
      APPEND ls_data TO pt_data.
    ENDIF.
* Expand the searchresult up to the first level that is selectable
    READ TABLE lt_intsort WITH KEY take = x TRANSPORTING NO FIELDS.
    l_expand_level = sy-tabix.
    CALL METHOD oref_tree->expand_node
      EXPORTING
        i_node_key = l_topnode
        i_level_count = l_expand_level.
    CALL METHOD oref_tree->frontend_update.
  ENDMETHOD.
************************************************************************
* Present a popup to show the actual sorting order in the searchresult
* section of the tree and allow rearrangement.
************************************************************************
  METHOD hierarchy_set.
    DATA: lt_fc   TYPE lvc_t_fcat,
          ls_fc   TYPE lvc_s_fcat,
          lt_sort TYPE lvc_t_sort,
          ls_sort TYPE lvc_s_sort,
          ls_intsort TYPE pty_sort,
          ls_sortmaster TYPE pty_sortmaster,
          l_element TYPE es_element,
          l_active  TYPE es_active,
          ls_settings TYPE esduscom.
* If there is no searchresult in the tree, send an information
  IF p_sorttype IS INITIAL.
    MESSAGE i022(migo).
    EXIT.
  ENDIF.
* Get actual fieldcatalog (contains the visible fields and THE TEXTS)
    CALL METHOD oref_tree->get_frontend_fieldcatalog
      IMPORTING
        et_fieldcatalog = lt_fc.
    CALL METHOD cl_gui_cfw=>flush.
* Eliminate fields that are not selectable according to the mastertable
* and create the initial sort order
    LOOP AT lt_fc INTO ls_fc.
      READ TABLE pt_sortmaster WITH KEY type      = p_sorttype
                                       fieldname = ls_fc-fieldname
                                       TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        DELETE lt_fc.
      ENDIF.
    ENDLOOP.
* Convert the actual sorting order into ALV represenatation
    LOOP AT pt_sort INTO ls_intsort.
      READ TABLE pt_sortmaster INTO ls_sortmaster
          WITH KEY type = p_sorttype
                   field_id = ls_intsort-field_id
                   TRANSPORTING fieldname.
      READ TABLE lt_fc INTO ls_fc
                WITH KEY fieldname = ls_sortmaster-fieldname.
      CLEAR ls_sort.
      MOVE-CORRESPONDING ls_fc TO ls_sort.
      CASE ls_intsort-order.
        WHEN 'U'. ls_sort-up   = x.
        WHEN 'D'. ls_sort-down = x.
      ENDCASE.
      APPEND ls_sort TO lt_sort.
    ENDLOOP.
* Call dialog popup
    CALL FUNCTION 'LVC_SORT_DIALOG'
      EXPORTING
        it_fieldcat      = lt_fc
      CHANGING
        ct_sort          = lt_sort
      EXCEPTIONS
        OTHERS           = 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
* If there was a change, rebuild pt_sort.
    CLEAR pt_sort.
    LOOP AT lt_sort INTO ls_sort.
      READ TABLE pt_sortmaster INTO ls_sortmaster
          WITH KEY type = p_sorttype
                   fieldname = ls_sort-fieldname
                   TRANSPORTING field_id.
      CLEAR ls_intsort.
      ls_intsort-field_id = ls_sortmaster-field_id.
      CASE ls_sort-up.
        WHEN     x. ls_intsort-order = 'U'.
        WHEN space. ls_intsort-order = 'D'.
      ENDCASE.
      APPEND ls_intsort TO pt_sort.
    ENDLOOP.
* Save the new configuration in the user defaults
    CLEAR: l_element, l_active.
    CASE p_sorttype.
      WHEN c_purchase_order.    l_element = 'SORT_PO'.
      WHEN c_material_document. l_element = 'SORT_MATDOC'.
    ENDCASE.
    LOOP AT pt_sort INTO ls_intsort.
      CONCATENATE l_active ls_intsort INTO l_active SEPARATED BY ' '.
    ENDLOOP.
    CALL METHOD oref_defaults->set( i_element = l_element
                                 i_active  = l_active ).
    CALL METHOD cl_mmim_userdefaults=>flush_all.
* Rebuild the tree
    CALL METHOD searchresult_update
      EXPORTING
        i_type = p_sorttype.
  ENDMETHOD.

************************************************************************
* Create the master sort table.
* It contains all information needed by the program to allow
* on the fly modification of the hierarchy in the seachresult
* branch of the tree.
*
* The fields in this table are:
* -----------------------------
* TYPE          Keyarea for sortresult types PO's, MatDocs, ...
* FIELD_ID      2-character short-name for a fieldname
* FIELDNAME     Name of the field in the searchresulttable
* TAKE          This element can be taken into MIGO via double click
* LIST          This element has the item structure in the tree filled
* IMAGE         The image appearing in front of the node
*
* The correspondence between short-name and fieldname:
* ----------------------------------------------------
* 00  NAME1     Name of the vendor
* 01  EBELN     Purchase order number
* 02  EBELP     Purchase order position
* 03  MBLNR     Material document number
* 04  MJAHR     Year of material document
* 05  ZEILE     Line in material document
* 06  MATNR     Material number
* 07  MAKTX     Material short text
* 08  IDNLF     Material identification of vendor
* 09  EAN11     European article number
* 10  LIFNR     Vendor number
* 11  RESWK     Delivering plant
* 12  EINDT     Delivery date of position
* 13  ERNAM     Name of creator of purchase order
************************************************************************
  METHOD sortmaster_build.
    DATA: ls TYPE pty_sortmaster.
    CLEAR pt_sortmaster.

* Purchase orders
    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '10'.
    ls-fieldname = 'LIFNR'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '00'.
    ls-fieldname = 'NAME1'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '01'.
    ls-fieldname = 'EBELN'.
    ls-take      = x.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '02'.
    ls-fieldname = 'EBELP'.
    ls-take      = x.
    ls-image     = c_icon_none.
    ls-list      = x.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '06'.
    ls-fieldname = 'MATNR'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '07'.
    ls-fieldname = 'MAKTX'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '08'.
    ls-fieldname = 'IDNLF'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '09'.
    ls-fieldname = 'EAN11'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '11'.
    ls-fieldname = 'RESWK'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '12'.
    ls-fieldname = 'EINDT'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_purchase_order.
    ls-field_id  = '13'.
    ls-fieldname = 'ERNAM'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.


* Material documents
    CLEAR ls.
    ls-type      = c_material_document.
    ls-field_id  = '03'.
    ls-fieldname = 'MBLNR'.
    ls-take      = x.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_material_document.
    ls-field_id  = '05'.
    ls-fieldname = 'ZEILE'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = x.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_material_document.
    ls-field_id  = '06'.
    ls-fieldname = 'MATNR'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_material_document.
    ls-field_id  = '07'.
    ls-fieldname = 'MAKTX'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

    CLEAR ls.
    ls-type      = c_material_document.
    ls-field_id  = '10'.
    ls-fieldname = 'LIFNR'.
    ls-take      = space.
    ls-image     = c_icon_none.
    ls-list      = space.
    APPEND ls TO pt_sortmaster.

  ENDMETHOD.
************************************************************************
* Create the fieldcatalog for the ALV tree.
* With release 4.6C, the searchresults are presented in an ALV grid
* control. The tree structure is only used for document lists --> no
* fieldcatalog necessary.
* Without any fieldcatalog --> dump ==> We fill a dummy entry.
************************************************************************
  METHOD fieldcatalog_build.
    DATA: ls_fc TYPE lvc_s_fcat.
    CLEAR pt_fc.

    CLEAR: ls_fc.
    ls_fc-fieldname = 'LIFNR'.
    ls_fc-ref_table = 'EKKO'.
    ls_fc-rollname  = 'BB_LIFNR'.
    ls_fc-no_out    = x.
    APPEND ls_fc TO pt_fc.

*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'NAME1'.
*    ls_fc-ref_table = 'LFA1'.
*    ls_fc-rollname  = 'BB_LIFTX'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'RESWK'.
*    ls_fc-ref_table = 'EKKO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'EBELN'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'EBELP'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'EINDT'.
*    ls_fc-ref_table = 'EKET'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'ERNAM'.
*    ls_fc-ref_table = 'EKKO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MBLNR'.
*    ls_fc-ref_table = 'MSEG'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MJAHR'.
*    ls_fc-ref_table = 'MSEG'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'ZEILE'.
*    ls_fc-ref_table = 'MSEG'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MATNR'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MAKTX'.
*    ls_fc-ref_table = 'MAKT'.
*    ls_fc-colddictxt = 'L'.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'IDNLF'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'EAN11'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-no_out    = x.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MENGE_C'.
*    ls_fc-rollname  = 'BSMNG'.
*    ls_fc-just      = 'R'.
*    ls_fc-outputlen    = 16.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'WEMNG_C'.
*    ls_fc-rollname  = 'WEEMG'.
*    ls_fc-just      = 'R'.
*    ls_fc-outputlen = 16.
*    APPEND ls_fc TO pt_fc.
*
*    CLEAR: ls_fc.
*    ls_fc-fieldname = 'MEINS'.
*    ls_fc-ref_table = 'EKPO'.
*    ls_fc-outputlen = 6.
*    APPEND ls_fc TO pt_fc.


  ENDMETHOD.
************************************************************************
* Evaluate a new searchresult for purchase orders
************************************************************************
METHOD new_searchresult_po.
  DATA: ls_pos  TYPE ty_data,
        lt_pos  TYPE TABLE OF ty_data,
        ls_list TYPE lcl_migo_search=>ty_s_purchase_order.
  FIELD-SYMBOLS: <lt_data> TYPE lcl_migo_search=>ty_t_purchase_order.
  ASSIGN i_data->* TO <lt_data>.
  LOOP AT <lt_data> INTO ls_list.
    MOVE-CORRESPONDING ls_list TO ls_pos.
    APPEND ls_pos TO lt_pos.
  ENDLOOP.
  CALL METHOD searchresult_add
    EXPORTING
      i_type    = c_purchase_order
      it_result = lt_pos.
ENDMETHOD.

************************************************************************
* Evaluate a new searchresult incoming by message
************************************************************************
METHOD new_searchresult_matdoc.
  DATA: ls_pos  TYPE ty_data,
        lt_pos  TYPE TABLE OF ty_data,
        ls_list TYPE lcl_migo_search=>ty_s_materialdocument.
  FIELD-SYMBOLS: <lt_data> TYPE lcl_migo_search=>ty_t_materialdocument.
  ASSIGN i_data->* TO <lt_data>.
  LOOP AT <lt_data> INTO ls_list.
    MOVE-CORRESPONDING ls_list TO ls_pos.
    ls_pos-wemng = ls_list-erfmg.
    ls_pos-meins = ls_list-erfme.
    APPEND ls_pos TO lt_pos.
  ENDLOOP.
  CALL METHOD searchresult_add
    EXPORTING
      i_type    = c_material_document
      it_result = lt_pos.
ENDMETHOD.