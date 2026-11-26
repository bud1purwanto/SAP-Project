*----------------------------------------------------------------------*
*   INCLUDE LMIGOGD2                                                   *
*   ALV grid encapsulation
*----------------------------------------------------------------------*

CLASS lcl_migo_griddisplay IMPLEMENTATION.

************************************************************************
* Create the ALV grid
************************************************************************
METHOD constructor.
  CREATE OBJECT poref_grid
    EXPORTING i_parent      = i_parent
              i_appl_events = abap_true.
  p_visible = abap_true.
  p_running = abap_false.
  p_my_id   = i_id.
  SET HANDLER toolbar_build_handler FOR poref_grid.
  SET HANDLER menu_handler          FOR poref_grid.
  SET HANDLER click_handler         FOR poref_grid.
  CALL METHOD tables_build.
ENDMETHOD.


************************************************************************
* New data have arrived. If the control is new, call
* SET_TABLE_FOR_FIRST_DISPLAY. Otherwise, use TABLE_REFRESH.
************************************************************************
METHOD new_data.
  FIELD-SYMBOLS: <lt_data> TYPE ANY.
  ASSIGN i_dref->* TO <lt_data>.
* Copy the delivered table to have all data class-local.
  CASE p_my_id.
    WHEN 'R01'.
      pt_pos = <lt_data>.
      ASSIGN pt_pos     TO <lt_data>.
    WHEN 'R02'.
      pt_matdocs = <lt_data>.
      ASSIGN pt_matdocs TO <lt_data>.
    WHEN 'R08'.
      pt_order   = <lt_data>.
      ASSIGN pt_order TO <lt_data>.
    WHEN 'R09'.
      pt_reservation   = <lt_data>.
      ASSIGN pt_reservation TO <lt_data>.
  ENDCASE.
  IF p_running = abap_false.
    CALL METHOD poref_grid->set_table_for_first_display
      EXPORTING
        is_variant           = ps_variant
        it_toolbar_excluding = pt_excluding
        is_layout            = ps_layout
        i_save               = 'A'
        i_default            = 'X'
      CHANGING
        it_fieldcatalog = pt_fieldcat
        it_sort         = pt_sort
        it_outtab       = <lt_data>.
    p_running = abap_true.
  ELSE.
    CALL METHOD poref_grid->refresh_table_display.
  ENDIF.
ENDMETHOD.


************************************************************************
* Set visibility
************************************************************************
METHOD set_visible.
  IF i_visible <> p_visible.
    CALL METHOD poref_grid->set_visible( i_visible ).
    p_visible = i_visible.
  ENDIF.
ENDMETHOD.


************************************************************************
* Create the field catalog, layout, ...
************************************************************************
METHOD tables_build.
  DATA: ls_fieldcat TYPE lvc_s_fcat,
        ls_sort     TYPE lvc_s_sort.

  DEFINE d_add.
    clear ls_fieldcat.
    ls_fieldcat-fieldname  = &1.
    ls_fieldcat-ref_table  = &2.
    ls_fieldcat-qfieldname = &3.
    ls_fieldcat-no_out     = &4.
    if &1 = 'NAME1' and &2 = 'LFA1'.                             "411519
      ls_fieldcat-rollname = 'ELIFN'.                            "411519
    endif.                                                       "411519
    if &1 = 'MAKTX' and &2 = 'EKPO'.
      ls_fieldcat-ref_field = 'TXZ01'.
    endif.
    if &1 = 'NAMEW' and &2 = 'T001W'.                            "411519
      ls_fieldcat-ref_field = 'NAME1'.                           "411519
      ls_fieldcat-rollname  = 'RESWK'.                           "411519
    endif.                                                       "411519
    if &1 = 'WERKS_NAME'.                                        "411519
      ls_fieldcat-ref_field = 'NAME1'.                           "411519
      ls_fieldcat-rollname  = 'WERKS_D'.                         "411519
    endif.                                                       "411519
    if &1 = 'NAME1' and &2 = 'T001W'.                            "411519
      ls_fieldcat-rollname = 'WERKS_D'.                          "411519
    endif.                                                       "411519
    append ls_fieldcat to pt_fieldcat.
  END-OF-DEFINITION.

* The same in the format used by RM07RESL to have the same database
  DEFINE def_add.
    clear ls_fieldcat.
    ls_fieldcat-fieldname     = &1.
    ls_fieldcat-ref_field     = &2.
    ls_fieldcat-ref_table     = &3.
    ls_fieldcat-no_out        = &4.
    ls_fieldcat-qfieldname    = &5.
    append ls_fieldcat to pt_fieldcat.
  END-OF-DEFINITION.
* Sorting information
  DEFINE d_sort.
    clear ls_sort.
    ls_sort-spos      = &1.
    ls_sort-fieldname = &2.
    ls_sort-up        = &3.
    ls_sort-down      = &4.
    append ls_sort to pt_sort.
  END-OF-DEFINITION.

  CASE p_my_id.
*   Fieldcatalog for purchase orders
    WHEN 'R01'.
      d_add 'NAME1' 'LFA1' space   space.
      d_add 'LIFNR' 'EKKO' space   x.
      d_add 'RESWK' 'EKKO' space   x.
      d_add 'NAMEW' 'T001W' space   x.
      d_add 'EBELN' 'EKPO' space   space.
      d_add 'ERNAM' 'EKKO' space   x.
      d_add 'EBELP' 'EKPO' space   space.
      d_add 'MAKTX' 'EKPO' space   space.
      d_add 'MATNR' 'EKPO' space   x.
      d_add 'IDNLF' 'EKPO' space   x.
      d_add 'EAN11' 'EKPO' space   x.
      d_add 'WERKS'      'EKPO'  space x.                        "411519
      d_add 'WERKS_NAME' 'T001W' space x.                        "411519
      d_add 'LGORT'      'EKPO'  space x.                        "411519
      d_add 'LGOBE'      'T001L' space x.                        "411519
      d_add 'MATKL'      'EKPO'  space x.                        "411519
      d_add 'WGBEZ'      'T023T' space x.                        "411519
      d_add 'KNTTP'      'EKPO'  space x.                        "411519
      d_add 'KNTTX'      'T163I' space x.                        "411519
      d_add 'EINDT' 'EKET' space   space.
      d_add 'MENGE' 'EKPO' 'MEINS' space.
      d_add 'MEINS' 'EKPO' space   space.
      d_add 'WEMNG' 'EKET' 'MEINS' space.

      d_sort 1 'NAME1' x space.
      d_sort 2 'EBELN' x space.
      d_sort 3 'EBELP' x space.

      ps_variant-report = c_repid.
      ps_variant-handle = 'SRPO'.  " SeRrch PO

      ps_layout-sel_mode = 'C'.  "Multiple lines
*   Fieldcatalog for material documents
    WHEN 'R02'.
      d_add 'MATNR' 'MSEG'  space   space.
      d_add 'MAKTX' 'MAKT'  space   space.
      d_add 'WERKS' 'MSEG'  space   space.
      d_add 'NAME1' 'T001W' space   x.
      d_add 'LGORT' 'MSEG'  space   space.
      d_add 'CHARG' 'MSEG'  space   x.                           "351455
      d_add 'BWTAR' 'MSEG'  space   x.                           "351455
      d_add 'BWART' 'MSEG'  space   space.
      d_add 'SOBKZ' 'MSEG'  space   space.
      d_add 'BTEXT' 'T156T' space   x.
      d_add 'MBLNR' 'MKPF'  space   space.
      d_add 'MJAHR' 'MKPF'  space   space.
      d_add 'ZEILE' 'MSEG'  space   space.
      d_add 'BUDAT' 'MKPF'  space   space.
      d_add 'ERFMG' 'MSEG'  'ERFME' space.
      d_add 'ERFME' 'MSEG'  space   space.
      d_add 'LIFNR' 'MSEG'  space   x.
      d_add 'VGART' 'MKPF'  space   x.

      d_sort 1 'MATNR' x     space.
      d_sort 2 'MAKTX' x     space.
      d_sort 3 'WERKS' x     space.
      d_sort 4 'BUDAT' space x.

      ps_variant-report = c_repid.
      ps_variant-handle = 'SRMD'.   "SeArch MaterialDocument

      ps_layout-sel_mode = space. "Only one line at a time!
*   Production orders (goods receipt)
    WHEN 'R08'.
      d_add 'AUFNR' 'AUFK'   space   space.
      d_add 'POSNR' 'AFPO'   space   space.
      d_add 'DGLTS' 'AFPO'   space   space.
      d_add 'GAMNG' 'CAUFV'  'GMEIN' space.
      d_add 'WEMNG' 'AFPO'   'GMEIN' space.
      d_add 'GMEIN' 'CAUFV'  space   space.
      d_add 'DWERK' 'AFPO'   space   space.
      d_add 'STTXT' 'CAUFVD' space   space.

      d_sort 1 'AUFNR' x space.
      d_sort 2 'POSNR' x space.

      ps_variant-report = c_repid.
      ps_variant-handle = 'SROR'.  " SeRrch ORders

      ps_layout-sel_mode = 'C'.  "Multiple lines
*   Reservations (and goods issue for productoin order)
    WHEN 'R09'.
*     Fieldcatalog from RM07RESL
      INCLUDE rm07resl_fieldcat.

      d_sort 1 'RSNUM_I' x space.
      d_sort 2 'RSPOS_I' x space.
      d_sort 3 'RSART_I' x space.                                "203543

      ps_variant-report = c_repid.
      ps_variant-handle = 'SRRS'.

      ps_layout-sel_mode       = 'C'.
      ps_layout-info_fname     = 'COLOR'.
  ENDCASE.

* Toolbar functions excluding
* APPEND cl_gui_alv_grid=>mc_fc_sum    TO pt_excluding.          "723251
  APPEND cl_gui_alv_grid=>mc_fc_subtot TO pt_excluding.


ENDMETHOD.

************************************************************************
* Toolbar building
************************************************************************
METHOD toolbar_build_handler.
  DATA: ls_toolbar TYPE stb_button.
* Creation of new buttons
  CLEAR ls_toolbar.
  ls_toolbar-butn_type = cntb_btype_sep.
  APPEND ls_toolbar TO e_object->mt_toolbar.

  CLEAR ls_toolbar.
  ls_toolbar-butn_type = cntb_btype_button.
  ls_toolbar-function  = 'TAKE'.
  ls_toolbar-icon      = '@14@'.
  ls_toolbar-quickinfo = text-109.
  APPEND ls_toolbar TO e_object->mt_toolbar.

  CLEAR ls_toolbar.
  ls_toolbar-butn_type = cntb_btype_sep.
  APPEND ls_toolbar TO e_object->mt_toolbar.

  CLEAR ls_toolbar.
  ls_toolbar-butn_type = cntb_btype_button.
  ls_toolbar-function  = 'CLOSE'.
  ls_toolbar-icon      = '@3X@'.
  ls_toolbar-quickinfo = text-019.
  APPEND ls_toolbar TO e_object->mt_toolbar.
* Disabling/Enabling the "TAKE" button always
  READ TABLE e_object->mt_toolbar INTO ls_toolbar
                                  WITH KEY function = 'TAKE'.
  CASE lcl_migo_globals=>kernel->s_status-allowed_refdoc.
    WHEN 'R08'.
*     If "orders" are allowed, we have to check whether we are
*     out for goods issues or goods receipts.
      IF ( lcl_migo_globals=>kernel->s_control-action = 'A01' AND
           p_my_id = 'R08' )                                  OR
         ( lcl_migo_globals=>kernel->s_control-action = 'A07' AND
           p_my_id = 'R09' ).
        ls_toolbar-disabled = space.
      ELSE.
        ls_toolbar-disabled = x.
      ENDIF.
    WHEN OTHERS.
*     In all other cases, the name of the viewer corresponds to the
*     refdoc-ID.
      IF lcl_migo_globals=>kernel->s_status-allowed_refdoc  = p_my_id.
        ls_toolbar-disabled = space.
      ELSE.
        ls_toolbar-disabled = x.
      ENDIF.
  ENDCASE.

  MODIFY e_object->mt_toolbar FROM ls_toolbar INDEX sy-tabix.
ENDMETHOD.

************************************************************************
* Handling for menu functions
************************************************************************
METHOD menu_handler.
  CASE e_ucomm.
    WHEN 'CLOSE'.
      CALL METHOD oref_controlarea->set_visible( space ).
    WHEN 'TAKE'.
      CALL METHOD objects_take.
  ENDCASE.
ENDMETHOD.

************************************************************************
* Handler for double click
************************************************************************
METHOD click_handler.
  CALL METHOD objects_take
    EXPORTING i_column = e_column.
ENDMETHOD.


************************************************************************
* Toolbar rebuilding
************************************************************************
METHOD rebuild_toolbar.
  CALL METHOD poref_grid->set_toolbar_interactive.
ENDMETHOD.

************************************************************************
* Read the selected objects
************************************************************************
METHOD objects_take.
  DATA: lt_rows   TYPE lvc_t_row,
        ls_row    TYPE lvc_s_row,
        ls_po     TYPE lcl_migo_search=>ty_s_purchase_order,
        ls_matdoc TYPE lcl_migo_search=>ty_s_materialdocument,
        ls_order  TYPE lcl_migo_search=>ty_s_order,
        ls_reservation TYPE lcl_migo_search=>ty_s_reservation,
        ls_key    TYPE lcl_migo_kernel=>ty_s_refdockey,
        l_refdoc  TYPE refdoc.
* Security check: Object reading allowed? Necessary to stop
* double clicking on material document if not allowed.
  IF p_my_id <> lcl_migo_globals=>kernel->s_status-allowed_refdoc    AND
     NOT ( lcl_migo_globals=>kernel->s_status-allowed_refdoc = 'R08' AND
           lcl_migo_globals=>kernel->s_control-action        = 'A07' AND
           p_my_id                                           = 'R09' ).
    MESSAGE s019.
    EXIT.
  ENDIF.
* Read selected rows
  CALL METHOD poref_grid->get_selected_rows
    IMPORTING et_index_rows = lt_rows.

  LOOP AT lt_rows INTO ls_row.
    CLEAR ls_key.
    CASE p_my_id.
      WHEN 'R01'.
        READ TABLE pt_pos INTO ls_po INDEX ls_row-index.
        ls_key-po_number = ls_po-ebeln.
        ls_key-po_item   = ls_po-ebelp.
      WHEN 'R02'.
        READ TABLE pt_matdocs INTO ls_matdoc INDEX ls_row-index.
        ls_key-mat_doc  = ls_matdoc-mblnr.
        ls_key-doc_year = ls_matdoc-mjahr.
      WHEN 'R08'.
        READ TABLE pt_order INTO ls_order INDEX ls_row-index.
        ls_key-order_number = ls_order-aufnr.
        ls_key-order_item   = ls_order-posnr.
      WHEN 'R09'.
        READ TABLE pt_reservation
                   INTO ls_reservation INDEX ls_row-index.
        ls_key-reservation_number = ls_reservation-rsnum_i.
        ls_key-reservation_item   = ls_reservation-rspos_i.
        ls_key-reservation_type   = ls_reservation-rsart_i.
    ENDCASE.
    l_refdoc = p_my_id.
    CALL METHOD lcl_migo_globals=>kernel->ref_document_read
      EXPORTING
        i_refdoc = l_refdoc
        is_key   = ls_key.
  ENDLOOP.
ENDMETHOD.

ENDCLASS.