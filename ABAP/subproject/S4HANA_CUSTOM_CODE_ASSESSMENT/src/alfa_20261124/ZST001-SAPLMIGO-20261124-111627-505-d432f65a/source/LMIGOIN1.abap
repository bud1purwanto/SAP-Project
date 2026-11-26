*----------------------------------------------------------------------*
***INCLUDE LMIGOIN1 .
*----------------------------------------------------------------------*

************************************************************************
* Initialization of the classes.
* This coding is executed only once (either at transaction start
* or upon the FIRST call to MIGO_DIALOG within the current
* internal mode).
************************************************************************
FORM initialization.
  DATA: lt_action TYPE STANDARD TABLE OF es_action.
  STATICS: l_done TYPE abap_bool VALUE abap_false.
  CHECK l_done = abap_false.
  l_done = abap_true.
  def_info 'MIGO Initialization' space.                     "#EC NOTEXT
* Prefetch for user defaults
  APPEND 'MIGO_CONTROLAREA'    TO lt_action.
  APPEND 'MIGO_DEBUG'          TO lt_action.
  APPEND 'MIGO_DEFAULTS'       TO lt_action.
  APPEND 'MIGO_DETAIL'         TO lt_action.
  APPEND 'MIGO_DETAIL_TOGGLER' TO lt_action.
  APPEND 'MIGO_FIRSTLINE'      TO lt_action.
  APPEND 'MIGO_HEADER'         TO lt_action.
  APPEND 'MIGO_HEADER_TOGGLER' TO lt_action.
  APPEND 'MIGO_TV_TOGGLER'     TO lt_action.
  APPEND 'MIGO_PEOPLE'         TO lt_action.
  APPEND 'MIGO_TIPS'           TO lt_action.
  APPEND 'MIGO_BOM'            TO lt_action.
  APPEND 'MIGO_TREE'           TO lt_action.
ENHANCEMENT-POINT LMIGOIN1_03 SPOTS ES_SAPLMIGO.
  CALL METHOD cl_mmim_userdefaults=>prefetch
    EXPORTING
      it_action = lt_action.
  CALL METHOD lcl_migo_frame=>queue_messages.
*   Create objects:
  CREATE OBJECT oref_header_toggler TYPE lcl_migo_toggler
    EXPORTING
      i_name             = 'MIGO_HEADER_TOGGLER'
      i_active_dyn       = '0101'
      i_inactive_dyn     = '0102'
      i_subscreen_dyn    = '0100'
      i_okcode_open      = 'MIGO_OK_HEADER_OPEN'
      i_okcode_close     = 'MIGO_OK_HEADER_CLOSE'
      i_message_open     = 'HEADER_OPEN'
      i_global_current   = 'G_HEADER_CURRENT_DYN'
      i_global_subscreen = 'G_HEADER_SUBSCREEN'.
  CREATE OBJECT oref_tv_toggler TYPE lcl_migo_toggler
    EXPORTING
      i_name             = 'MIGO_TV_TOGGLER'
      i_active_dyn       = '0201'
      i_inactive_dyn     = '0200'
      i_subscreen_dyn    = '0220'
      i_okcode_open      = 'MIGO_OK_GA_OPEN'
      i_okcode_close     = 'MIGO_OK_GA_CLOSE'
      i_message_open     = 'GA_OPEN'
      i_global_current   = 'G_TABLEV_CURRENT_DYN'
      i_global_subscreen = 'G_TABLEV_SUBSCREEN'.
ENHANCEMENT-POINT LMIGOIN1_02 SPOTS ES_SAPLMIGO.
  CREATE OBJECT oref_detail_toggler TYPE lcl_migo_toggler
    EXPORTING
      i_name             = 'MIGO_DETAIL_TOGGLER'
      i_active_dyn       = '0301'
      i_inactive_dyn     = '0302'
      i_subscreen_dyn    = '0300'
      i_okcode_open      = 'MIGO_OK_DETAIL_OPEN'
      i_okcode_close     = 'MIGO_OK_DETAIL_CLOSE'
      i_message_open     = 'ITEMDETAIL_OPEN'
      i_global_current   = 'G_DETAIL_CURRENT_DYN'
      i_global_subscreen = 'G_DETAIL_SUBSCREEN'.
ENHANCEMENT-POINT LMIGOIN1_04 SPOTS ES_SAPLMIGO.
  CREATE OBJECT oref_trace TYPE lcl_migo_trace.
  CREATE OBJECT oref_status TYPE lcl_migo_status.
  CREATE OBJECT oref_nota_fiscal TYPE lcl_migo_nota_fiscal.
  CREATE OBJECT oref_titlebar TYPE lcl_migo_titlebar.
  CREATE OBJECT oref_firstline TYPE lcl_migo_firstline.
  CREATE OBJECT oref_doc_log TYPE lcl_migo_log.
  CREATE OBJECT oref_defaults TYPE lcl_migo_defaults.
  CREATE OBJECT oref_bom TYPE lcl_migo_bom.
  CREATE OBJECT oref_tip TYPE lcl_migo_tip.
  CREATE OBJECT oref_log TYPE lcl_migo_log.
  CREATE OBJECT oref_atp_log TYPE lcl_migo_log.      "703419
  CREATE OBJECT oref_badi_log TYPE lcl_migo_log.      "ERP2005
  CREATE OBJECT oref_predocument TYPE lcl_migo_predocument.
  CREATE OBJECT oref_environment TYPE lcl_migo_environment.
  CREATE OBJECT oref_dynprolocator TYPE lcl_migo_dynprolocator.
  CREATE OBJECT oref_html_help TYPE lcl_migo_html_help.
  CREATE OBJECT oref_tree TYPE lcl_migo_tree
    EXPORTING
      i_notree = lcl_migo_globals=>external_call_notree.
  CREATE OBJECT oref_controlarea TYPE lcl_migo_controlarea.
  CREATE OBJECT oref_search TYPE lcl_migo_search.
  CREATE OBJECT oref_header TYPE lcl_migo_header.
  CREATE OBJECT oref_header_general TYPE lcl_migo_header_general.
  CREATE OBJECT oref_header_vendor TYPE lcl_migo_header_vendor .
  CREATE OBJECT oref_header_people TYPE lcl_migo_header_people .
  CREATE OBJECT oref_header_docinfo TYPE lcl_migo_header_docinfo.
  CREATE OBJECT oref_header_import TYPE lcl_migo_header_import .

  CREATE OBJECT oref_detail TYPE lcl_migo_detail.
  CREATE OBJECT oref_detail_material TYPE lcl_migo_detail_material.
  CREATE OBJECT oref_detail_quantity TYPE lcl_migo_detail_quantity.
  CREATE OBJECT oref_detail_po TYPE lcl_migo_detail_po.
  CREATE OBJECT oref_detail_order TYPE lcl_migo_detail_order.
  CREATE OBJECT oref_detail_partners TYPE lcl_migo_detail_partners.
  CREATE OBJECT oref_detail_transfer TYPE lcl_migo_detail_transfer.
  CREATE OBJECT oref_detail_trans TYPE lcl_migo_detail_trans.
  CREATE OBJECT oref_detail_takeit TYPE lcl_migo_detail_takeit.
  CREATE OBJECT oref_detail_batch TYPE lcl_migo_detail_batch.
  CREATE OBJECT oref_detail_doc_batch TYPE lcl_migo_detail_doc_batch.
  CREATE OBJECT oref_detail_output TYPE lcl_migo_detail_output.
  CREATE OBJECT oref_detail_dest TYPE lcl_migo_detail_dest.
  CREATE OBJECT oref_detail_account TYPE lcl_migo_detail_account.
  CREATE OBJECT oref_detail_maa TYPE lcl_migo_detail_maa.               "MAA-DEV
  CREATE OBJECT oref_detail_freight TYPE lcl_migo_detail_freight.
  CREATE OBJECT oref_detail_import TYPE lcl_migo_detail_import.
  CREATE OBJECT oref_detail_taxes TYPE lcl_migo_detail_taxes.
  CREATE OBJECT oref_detail_serial_numbers
    TYPE lcl_migo_detail_serial_numbers.
  CREATE OBJECT oref_serial_container
    TYPE cl_gui_custom_container
    EXPORTING
      container_name = 'CONT_SERIAL_ALV'.
  CREATE OBJECT oref_detail_ga TYPE lcl_migo_detail_ga.
  CREATE OBJECT oref_detail_wm TYPE lcl_migo_detail_wm.
  CREATE OBJECT oref_detail_ewm TYPE lcl_migo_detail_ewm.
  CREATE OBJECT oref_detail_po_sc TYPE lcl_migo_detail_po_sc.        "Outsourced Manufacturing EhP 4
  CREATE OBJECT oref_detail_reservation
    TYPE lcl_migo_detail_reservation.
  CREATE OBJECT oref_detail_ext_int TYPE lcl_migo_detail_ext_int.      "EHP606 CFB

  CREATE OBJECT oref_tableview TYPE lcl_migo_tableview.
  CREATE OBJECT oref_tableview_buttons
    TYPE lcl_migo_tableview_buttons.
  CREATE OBJECT oref_screenmanager TYPE lcl_migo_screenmanager.
  CREATE OBJECT oref_split_quantity TYPE lcl_migo_split_quantity.
  CREATE OBJECT oref_determine_stock TYPE lcl_migo_determine_stock.
  CREATE OBJECT oref_arch TYPE lcl_migo_arch.

ENHANCEMENT-POINT INITIALIZATION_01 SPOTS ES_SAPLMIGO.
  CALL METHOD lcl_migo_frame=>process_messages.
* MIGO: GO!!!
  CALL METHOD lcl_migo_globals=>kernel->reset.
ENHANCEMENT-SECTION     LMIGOIN1_01 SPOTS ES_SAPLMIGO.
  g_tablev_current_dyn = g_tablev_current_dyn.
END-ENHANCEMENT-SECTION.
  g_detail_current_dyn = g_detail_current_dyn.
  g_header_subscreen   = g_header_subscreen.
  g_header_current_dyn = g_header_current_dyn.
  g_tablev_current_dyn = g_tablev_current_dyn.
* Enhancement below supposed to change value of g_firstline_screen
ENHANCEMENT-POINT INITIALIZATION_02 SPOTS ES_SAPLMIGO.

* MAA2 Begin
* if business function multi account assignment is active
  IF cl_ops_switch_check=>mm_sfws_maa( ) IS NOT INITIAL AND
      NOT go_mmim_maa_2 IS BOUND.
* get instance of class CL_MMIM_MAA_2
    go_mmim_maa_2 = cl_mmim_maa_2=>get_singleton_instance( ).
  ENDIF.
* MAA2 End

ENDFORM.                    " INITIALIZATION
************************************************************************
* If this is the first loop over 0001 and data from an external caller
* are available, feed them into MIGO
************************************************************************
FORM take_data_from_migo_dialog.
  DATA: ls_control TYPE lcl_migo_kernel=>ty_s_control,
        ls_message TYPE lif_migo_frame=>ty_s_message.
* Run only at first time.
  CHECK lcl_migo_globals=>external_call_first_round = abap_true.
* Reset flag: Next loop --> Runs only once
  lcl_migo_globals=>external_call_first_round = abap_false.
* Switch mode
  ls_control = lcl_migo_globals=>kernel->mode_get( ).
  ls_control-action = lcl_migo_globals=>external_call_action.
  ls_control-refdoc = lcl_migo_globals=>external_call_refdoc.
  CALL METHOD lcl_migo_globals=>kernel->mode_set
    EXPORTING
      is_control = ls_control.
* Call RESET to set up the correct STATUS
  CALL METHOD lcl_migo_globals=>kernel->reset.
* Set dynpro data
  godynpro-po_number    = lcl_migo_globals=>external_call_ebeln.
  godynpro-po_item      = lcl_migo_globals=>external_call_ebelp.
  godynpro-mat_doc      = lcl_migo_globals=>external_call_mblnr.
  godynpro-doc_year     = lcl_migo_globals=>external_call_mjahr.
  godynpro-transport    = lcl_migo_globals=>external_call_transport.
  godynpro-order_number = lcl_migo_globals=>external_call_order_number.
  godynpro-order_item   = lcl_migo_globals=>external_call_order_item.
  godynpro-transport_means    =
                    lcl_migo_globals=>external_call_transport_means.
  godynpro-transportident     =
                    lcl_migo_globals=>external_call_transportident.
  godynpro-inbound_delivery   =
                    lcl_migo_globals=>external_call_inbound_deliv.
  godynpro-outbound_delivery  =
                    lcl_migo_globals=>external_call_outbound_deliv.
  godynpro-reservation_number =
                    lcl_migo_globals=>external_call_reservation_numb.
  godynpro-reservation_item   =
                    lcl_migo_globals=>external_call_reservation_item.

* Send the OK-code if available.
  IF lcl_migo_globals=>external_call_okcode <> space.
    CALL METHOD lcl_migo_frame=>okcode_dispatch
      EXPORTING
        i_okcode = lcl_migo_globals=>external_call_okcode.
  ENDIF.
* If ZEILE given, open the detail set the item.
  IF NOT lcl_migo_globals=>external_call_zeile IS INITIAL.
    CALL METHOD lcl_migo_frame=>message_send
      EXPORTING
        i_message_id     = 'ITEMDETAIL_OPEN'
        i_system_message = abap_true.
    ls_message-data1 = lcl_migo_globals=>external_call_zeile.
    CALL METHOD lcl_migo_frame=>message_send
      EXPORTING
        i_message_id     = 'ITEMDETAIL_LINE_SET'
        i_system_message = abap_true
        is_message       = ls_message.
  ENDIF.
ENDFORM.                    " TAKE_DATA_FROM_MIGO_DIALOG