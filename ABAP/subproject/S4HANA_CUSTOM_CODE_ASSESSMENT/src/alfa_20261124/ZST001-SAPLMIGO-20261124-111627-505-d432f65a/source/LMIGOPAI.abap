*----------------------------------------------------------------------*
***INCLUDE LMIGOPAI .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PAI_OKCODE_DISPATCH  INPUT
*&---------------------------------------------------------------------*
MODULE pai_okcode_dispatch INPUT.
  def_info 'PAI Dynpro 0001 end' space.                     "#EC NOTEXT
  CALL METHOD lcl_migo_frame=>process_messages.
  CALL METHOD lcl_migo_frame=>okcode_dispatch( okcode ).
ENDMODULE.                             " PAI_OKCODE_DISPATCH  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview INPUT.
  CALL METHOD oref_tableview->pai.
ENDMODULE.                             " PAI_TABLEVIEW  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_LOOP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_loop INPUT.
  CALL METHOD oref_tableview->pai_loop.
ENDMODULE.                             " PAI_TABLEVIEW_LOOP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_SPLIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_split INPUT.
  CALL METHOD oref_split_quantity->pai_exit.
ENDMODULE.                             " PAI_TABLEVIEW_SPLIT INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_SPLIT_START  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_split_start INPUT.
  CALL METHOD oref_split_quantity->pai.
ENDMODULE.                 " PAI_TABLEVIEW_SPLIT_START  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_SPLIT_LOOP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_split_loop INPUT.
  CALL METHOD oref_split_quantity->pai_loop.
ENDMODULE.                             " PAI_TABLEVIEW_SPLIT_LOOP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_SPLIT_END  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_split_end INPUT.
  CALL METHOD oref_split_quantity->pai_end.
ENDMODULE.                             " PAI_TABLEVIEW_SPLIT_END  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_TABLEVIEW_GA  INPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip Retail generic articles
*----------------------------------------------------------------------*
MODULE pai_tableview_ga INPUT.
  CALL METHOD oref_detail_ga->pai.
ENDMODULE.                             " PAI_TABLEVIEW_GA  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_MIGO_FIRSTLINE  INPUT
*&---------------------------------------------------------------------*
MODULE pai_migo_firstline INPUT.
  CALL METHOD oref_firstline->pai.
ENDMODULE.                             " PAI_MIGO_FIRSTLINE  INPUT
*&---------------------------------------------------------------------
*&      Module  PAI_MIGO_FIRSTLINE_SOBKZ  INPUT
*&---------------------------------------------------------------------
*       Change of default special stock directly on MIGO screen
*----------------------------------------------------------------------
MODULE pai_firstline_bwart_sobkz .
  CALL METHOD oref_firstline->pai_mvt_sobkz_change.
ENDMODULE.                    "pai_firstline_bwart_sobkz
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER  INPUT
*&---------------------------------------------------------------------*
*       Header carrier
*----------------------------------------------------------------------*
MODULE pai_header INPUT.
  CALL METHOD oref_header->pai.
ENDMODULE.                             " PAI_HEADER  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_GENERAL  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip general
*----------------------------------------------------------------------*
MODULE pai_header_general INPUT.
  CALL METHOD oref_header_general->pai.
ENDMODULE.                             " PAI_HEADER_GENERAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_GENERAL_FRBNR  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip general: on request for frbnr (bill of lading)
*----------------------------------------------------------------------*
MODULE pai_header_general_frbnr INPUT.
  CALL METHOD oref_header_general->pai_frbnr.
ENDMODULE.                             " PAI_HEADER_GENERAL_FRBNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_GENERAL_XBLNR  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip general: on request for xblnr (external documt)
*----------------------------------------------------------------------*
MODULE pai_header_general_xblnr INPUT.
  CALL METHOD oref_header_general->pai_xblnr.
ENDMODULE.                             " PAI_HEADER_GENERAL_XBLNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_GENERAL_WEVER  INPUT    - note 315434
*&---------------------------------------------------------------------*
*       Header tabstrip general: on request for wever (print version)
*----------------------------------------------------------------------*
MODULE pai_header_general_wever INPUT.                      "315434
  CALL METHOD oref_header_general->pai_wever.
ENDMODULE.                             " PAI_HEADER_GENERAL_WEVER  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_VENDOR  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip vendor
*----------------------------------------------------------------------*
MODULE pai_header_vendor INPUT.
  CALL METHOD oref_header_vendor->pai.
ENDMODULE.                             " PAI_HEADER_VENDOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_PEOPLE  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip people
*----------------------------------------------------------------------*
MODULE pai_header_people INPUT.
  CALL METHOD oref_header_people->pai.
ENDMODULE.                             " PAI_HEADER_PEOPLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_PEOPLE_SEARCH  INPUT
*&---------------------------------------------------------------------*
*       Search contact person on request
*----------------------------------------------------------------------*
MODULE pai_header_people_search INPUT.
  CALL METHOD oref_header_people->pai_header_people_search.
ENDMODULE.                             " PAI_HEADER_PEOPLE_SEARCH  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_DOCINFO  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip document info
*----------------------------------------------------------------------*
MODULE pai_header_docinfo INPUT.
  CALL METHOD oref_header_docinfo->pai.
ENDMODULE.                             " PAI_HEADER_DOCINFO  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_IMPORT  INPUT
*&---------------------------------------------------------------------*
*       Header tabstrip import
*----------------------------------------------------------------------*
MODULE pai_header_import INPUT.
  CALL METHOD oref_header_import->pai.
ENDMODULE.                             " PAI_HEADER_IMPORT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_IMPORT_POPUP  INPUT
*&---------------------------------------------------------------------*
*       Header import popup
*----------------------------------------------------------------------*
MODULE pai_header_import_popup INPUT.
  CALL METHOD oref_header_import->pai_popup.
ENDMODULE.                             " PAI_HEADER_IMPORT_POPUP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_HEADER_IMPORT_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Header import popup
*----------------------------------------------------------------------*
MODULE pai_header_import_exit INPUT.
  CALL METHOD oref_header_import->pai_exit.
ENDMODULE.                             " PAI_HEADER_IMPORT_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_GET  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail INPUT.
  CALL METHOD oref_detail->pai.
ENDMODULE.                             " PAI_DETAIL_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_GET  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_get INPUT.
  CALL METHOD oref_detail->pai_get.
ENDMODULE.                             " PAI_DETAIL_GET  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_MATERIAL INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_material INPUT.
  CALL METHOD oref_detail_material->pai.
ENDMODULE.                             " PAI_DETAIL_MATERIAL INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_QUANTITY INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_quantity INPUT.
  CALL METHOD oref_detail_quantity->pai.
ENDMODULE.                             " PAI_DETAIL_QUANTITY INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_PO INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_po INPUT.
  CALL METHOD oref_detail_po->pai.
ENDMODULE.                             " PAI_DETAIL_PO INPUT

* begin of Outsourced Manufacturing EhP 4

*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_PO_SC INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_po_sc INPUT.
  CALL METHOD oref_detail_po_sc->pai.
ENDMODULE.                             " PAI_DETAIL_PO_SC INPUT

* end of Outsourced Manufacturing EhP 4

*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_BATCH INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_batch INPUT.
  CALL METHOD oref_detail_batch->pai.
ENDMODULE.                             " PAI_DETAIL_BATCH INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_DOC_BATCH INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_doc_batch INPUT.
  CALL METHOD oref_detail_doc_batch->pai.
ENDMODULE.                             " PAI_DETAIL_DOC_BATCH INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_DEST INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_dest INPUT.
  CALL METHOD oref_detail_dest->pai.
ENDMODULE.                             " PAI_DETAIL_DEST INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_ACCOUNT INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_account INPUT.
  CALL METHOD oref_detail_account->pai.
ENDMODULE.                             " PAI_DETAIL_ACCOUNT INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_ACCOUNT_RECEIVE INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_account_receive INPUT.
  CALL METHOD oref_detail_account->pai_detail_account_receive.
ENDMODULE.                 " PAI_DETAIL_ACCOUNT_RECEIVE INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_SERIAL_NUMBERS INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_serial_numbers INPUT.
  CALL METHOD oref_detail_serial_numbers->pai.
ENDMODULE.                             " PAI_DETAIL_SERIAL_NUMBERS INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_SERIAL_NUMB_AFTER INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_serial_numb_after   INPUT.
  CALL METHOD oref_detail_serial_numbers->pai_after_loop.
ENDMODULE.                             " PAI_DETAIL_SERIAL_NUMBERS INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_SERIAL_NUMBERS_LOOP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_serial_numbers_loop INPUT.
  CALL METHOD oref_detail_serial_numbers->pai_loop.
ENDMODULE.                 " PAI_DETAIL_SERIAL_NUMBERS_LOOP INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_FREIGHT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_freight INPUT.
  CALL METHOD oref_detail_freight->pai.
ENDMODULE.                             " PAI_DETAIL_FREIGHT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_FREIGHT_LOOP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_freight_loop INPUT.
  CALL METHOD oref_detail_freight->pai_loop.
ENDMODULE.                             " PAI_DETAIL_FREIGHT_LOOP INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_IMPORT  INPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip import
*----------------------------------------------------------------------*
MODULE pai_detail_import INPUT.
  CALL METHOD oref_detail_import->pai.
ENDMODULE.                             " PAI_DETAIL_IMPORT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_IMPORT_POPUP  INPUT
*&---------------------------------------------------------------------*
*       Detail import popup
*----------------------------------------------------------------------*
MODULE pai_detail_import_popup INPUT.
  CALL METHOD oref_detail_import->pai_popup.
ENDMODULE.                             " PAI_DETAIL_IMPORT_POPUP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_IMPORT_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Detail import popup
*----------------------------------------------------------------------*
MODULE pai_detail_import_exit INPUT.
  CALL METHOD oref_detail_import->pai_exit.
ENDMODULE.                             " PAI_DETAIL_IMPORT_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_TAXES  INPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip import
*----------------------------------------------------------------------*
MODULE pai_detail_taxes INPUT.
  CALL METHOD oref_detail_taxes->pai.
ENDMODULE.                             " PAI_DETAIL_TAXES  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_WM  INPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip warehouse management
*----------------------------------------------------------------------*
MODULE pai_detail_wm INPUT.
  CALL METHOD oref_detail_wm->pai.
ENDMODULE.                             " PAI_DETAIL_WM  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_FIRSTLINE_SUBSCREEN  INPUT
*&---------------------------------------------------------------------*
MODULE pai_firstline_subscreen INPUT.
  CALL METHOD oref_firstline->pai.
ENDMODULE.                             " PAI_FIRSTLINE_SUBSCREEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_DEFAULTS_POPUP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_popup INPUT.
  CALL METHOD oref_defaults->pai.
ENDMODULE.                             " PAI_DEFAULTS_POPUP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DEFAULTS_WERKS  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_werks INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = godefault-def_werks
      c_planttext = godefault-def_name1.
ENDMODULE.                             " PAI_DEFAULTS_WERKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DEFAULTS_LGORT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_lgort INPUT.
  CALL FUNCTION 'MM_SLOC_CONVERT'
    CHANGING
      c_plant     = godefault-def_werks
      c_planttext = godefault-def_name1
      c_sloc      = godefault-def_lgort
      c_sloctext  = godefault-def_lgobe.
ENDMODULE.                             " PAI_DEFAULTS_LGORT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DEFAULTS_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_exit INPUT.
  CALL METHOD oref_defaults->exit_command.
ENDMODULE.                             " PAI_DEFAULTS_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE pai_exit_command INPUT.
  def_info 'PAI Dynpro 0001 end via EXIT-COMMAND' space.    "#EC NOTEXT
  CALL METHOD lcl_migo_frame=>process_messages.
  CALL METHOD lcl_migo_frame=>okcode_dispatch( okcode ).
ENDMODULE.                             " PAI_EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_PO_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_po_exit INPUT.
  CALL METHOD oref_search->pai_exit.
ENDMODULE.                             " PAI_SEARCH_PO_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_PO  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_po INPUT.
  CALL METHOD oref_search->pai.
ENDMODULE.                             " PAI_SEARCH_PO  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_PO_MAKTX  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_po_maktx INPUT.
  CALL FUNCTION 'MM_MAKTX_CONVERT'
    EXPORTING
      i_spras     = sy-langu
      i_direction = x
    CHANGING
      c_matnr     = gosearch_po-matnr
      c_maktx     = gosearch_po-maktx.
ENDMODULE.                             " PAI_SEARCH_PO_MAKTX  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_PO_PLANT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_po_plant INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = gosearch_po-reswk
      c_planttext = gosearch_po-reswkname.
ENDMODULE.                             " PAI_SEARCH_PO_PLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_PO_VENDOR  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_po_vendor INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    CHANGING
      vendor     = gosearch_po-lifnr
      vendorname = gosearch_po-vendorname.
ENDMODULE.                             " PAI_SEARCH_PO_VENDOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DUMMY  INPUT
*&---------------------------------------------------------------------*
MODULE pai_dummy INPUT.
* Only needed to trick the dynpro field transport
ENDMODULE.                             " PAI_DUMMY  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_MAKTX_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_maktx_convert INPUT.
  CALL FUNCTION 'MM_MAKTX_CONVERT'
    EXPORTING
      i_spras     = sy-langu
      i_direction = x
    CHANGING
      c_matnr     = goitem-matnr
      c_maktx     = goitem-maktx.
ENHANCEMENT-POINT LMIGOPAI_03 SPOTS ES_SAPLMIGO .
ENDMODULE.                             " PAI_MAKTX_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_PLANT_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_plant_convert INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = goitem-werks
      c_planttext = goitem-name1.
ENDMODULE.                             " PAI_PLANT_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_sloc_convert INPUT.
  CALL FUNCTION 'MM_SLOC_CONVERT'
    CHANGING
      c_plant     = goitem-werks
      c_planttext = goitem-name1
      c_sloc      = goitem-lgort
      c_sloctext  = goitem-lgobe.
ENDMODULE.                             " PAI_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_VENDOR_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_vendor_convert INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    EXPORTING
      bukrs      = space
    CHANGING
      vendor     = goitem-lifnr
      vendorname = goitem-vendorname.
ENDMODULE.                             " PAI_VENDOR_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_FREIGHT_VENDOR_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_freight_vendor_convert INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    EXPORTING
      bukrs      = space
    CHANGING
      vendor     = gofreight-lifnr
      vendorname = gofreight-vendorname.
ENDMODULE.                 " PAI_FREIGHT_VENDOR_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_CUSTOMER_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_customer_convert INPUT.
  CALL FUNCTION 'MM_CUSTOMER_CONVERT'
    EXPORTING
      bukrs        = space
    CHANGING
      customer     = goitem-kunnr
      customername = goitem-custname.

ENDMODULE.                             " PAI_VENDOR_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_LINE_FIND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_detail_line_find INPUT.
  CALL METHOD oref_detail->line_find.
ENDMODULE.                             " PAI_DETAIL_LINE_FIND  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SPLIT_QYT_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_split_qyt_sloc_convert  INPUT.
  CALL METHOD oref_split_quantity->pai_convert.
ENDMODULE.                 " PAI_SPLIT_QYT_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_0001_START  INPUT
*&---------------------------------------------------------------------*
MODULE pai_0001_start INPUT.
  def_info 'PAI Dynpro 0001 start' space.                   "#EC NOTEXT
* During PAI, no messages must be sent. Therefore, queueing is
* activates. Deactivation occurs in MODULE pai_okcode_dispatch.
  CALL METHOD lcl_migo_frame=>queue_messages.
* Clear cursor position
  CALL METHOD lcl_migo_cursor=>clear.
ENDMODULE.                             " PAI_0001_START  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_0001_END  INPUT
*&      After all viewers have done their line_checks
*&---------------------------------------------------------------------*
MODULE pai_0001_end INPUT.
  CALL METHOD lcl_migo_globals=>kernel->change_all_items.
ENDMODULE.                             " PAI_0001_END    INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_EMATN_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE pai_ematn_check INPUT.
* No functionality yet
ENDMODULE.                             " PAI_EMATN_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_ORD_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_ord_exit INPUT.
  CALL METHOD oref_search->pai_exit.
ENDMODULE.                             " PAI_SEARCH_ORD_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_ORD  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_ord INPUT.
  CALL METHOD oref_search->pai.
ENDMODULE.                             " PAI_SEARCH_ORD  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_ORD_MAKTX  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_ord_maktx INPUT.
  CALL FUNCTION 'MM_MAKTX_CONVERT'
    EXPORTING
      i_spras     = sy-langu
      i_direction = x
    CHANGING
      c_matnr     = gosearch_ord-matnr
      c_maktx     = gosearch_ord-maktx.
ENDMODULE.                             " PAI_SEARCH_ORD_MAKTX  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_ORD_PLANT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_ord_plant INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = gosearch_ord-werks
      c_planttext = gosearch_ord-name1.
ENDMODULE.                             " PAI_SEARCH_ORD_PLANT  INPUT
*&---------------------------------------------------------------------
*&      Module  PAI_DETAIL_ORDER  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_order INPUT.
  CALL METHOD oref_detail_order->pai.
ENDMODULE.                             " PAI_DETAIL_ORDER  INPUT
*&---------------------------------------------------------------------
*&      Module  PAI_DETAIL_TRANSFER  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_transfer INPUT.
  CALL METHOD oref_detail_transfer->pai.
ENDMODULE.                             " PAI_DETAIL_TRANSFER INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_BOM_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_bom_exit INPUT.
  CALL METHOD oref_bom->exit_command.
ENDMODULE.                             " PAI_BOM_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_BOM_POPUP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_bom_popup INPUT.
  CALL METHOD oref_bom->pai.
ENDMODULE.                             " PAI_BOM_POPUP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DEFAULTS_LOOP  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_loop INPUT.
  CALL METHOD oref_defaults->pai_loop.
ENDMODULE.                             " PAI_DEFAULTS_LOOP  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_RES_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_res_exit INPUT.
  CALL METHOD oref_search->pai_exit.
ENDMODULE.                             " PAI_SEARCH_RES_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_SEARCH_RES  INPUT
*&---------------------------------------------------------------------*
MODULE pai_search_res INPUT.
  CALL METHOD oref_search->pai.
ENDMODULE.                             " PAI_SEARCH_RES  INPUT
*&---------------------------------------------------------------------
*&      Module  PAI_DETAIL_RESERVATION  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_reservation INPUT.
  CALL METHOD oref_detail_reservation->pai.
ENDMODULE.                             " PAI_DETAIL_RESERVATION  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_TAKEIT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_takeit INPUT.
  CALL METHOD oref_detail_takeit->pai.
ENDMODULE.                             " PAI_DETAIL_TAKEIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_PARTNERS  INPUT
*&---------------------------------------------------------------------*
*       Detail Tabstrip Partners
*----------------------------------------------------------------------*
MODULE pai_detail_partners INPUT.
  CALL METHOD oref_detail_partners->pai.
ENDMODULE.                             " PAI_DETAIL_PARTNERS  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_tip  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tip INPUT.
  CALL METHOD oref_tip->pai.
ENDMODULE.                 " pai_tip  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_tableview_buttons  INPUT
*&---------------------------------------------------------------------*
MODULE pai_tableview_buttons INPUT.
  CALL METHOD oref_tableview_buttons->pai.
ENDMODULE.                 " pai_tableview_buttons  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_ummaktx_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_ummaktx_convert INPUT.
  CALL FUNCTION 'MM_MAKTX_CONVERT'
    EXPORTING
      i_spras     = sy-langu
      i_direction = x
    CHANGING
      c_matnr     = goitem-ummat
      c_maktx     = goitem-ummaktx.
ENDMODULE.                 " pai_ummaktx_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_transplant_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_transplant_convert INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = goitem-umwrk
      c_planttext = goitem-umname1.
ENDMODULE.                 " pai_transplant_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_transsloc_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_transsloc_convert INPUT.
  CLEAR goitem-umlgo.                                       "note 608593
ENDMODULE.                 " pai_transsloc_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_transfer_fields  INPUT
*&---------------------------------------------------------------------*
MODULE pai_transfer_fields INPUT.
  CALL METHOD oref_detail->pai_transfer_fields_fill.
ENDMODULE.                 " pai_transfer_fields  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_GODYNPRO_MAKTX_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_godynpro_maktx_convert INPUT.
  CALL FUNCTION 'MM_MAKTX_CONVERT'
    EXPORTING
      i_spras     = sy-langu
      i_direction = x
    CHANGING
      c_matnr     = godynpro-matnr
      c_maktx     = godynpro-maktx.
ENDMODULE.                           " PAI_GODYNPRO_MAKTX_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_GODYNPRO_PLANT_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_godynpro_plant_convert INPUT.
  CALL FUNCTION 'MM_PLANT_CONVERT'
    CHANGING
      c_plant     = godynpro-werks
      c_planttext = godynpro-name1.
ENDMODULE.                           " PAI_GODYNPRO_PLANT_CONVERT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_GODYNPRO_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
MODULE pai_godynpro_sloc_convert INPUT.
  CALL FUNCTION 'MM_SLOC_CONVERT'
    CHANGING
      c_plant     = godynpro-werks
      c_planttext = godynpro-name1
      c_sloc      = godynpro-lgort
      c_sloctext  = godynpro-lgobe.
ENDMODULE.                           " PAI_GODYNPRO_SLOC_CONVERT  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_godynpro_vendor_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_godynpro_vendor_convert INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    EXPORTING
      bukrs      = space
    CHANGING
      vendor     = godynpro-mat_lifnr
      vendorname = godynpro-mat_vendorname.
ENDMODULE.                 " pai_godynpro_vendor_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_goitem_vendor_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_goitem_vendor_convert INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    EXPORTING
      bukrs      = space
    CHANGING
      vendor     = goitem-mat_lifnr
      vendorname = goitem-mat_vendorname.
ENDMODULE.                 " pai_goitem_vendor_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_godynpro_ummat_vendor_conv  INPUT
*&---------------------------------------------------------------------*
MODULE pai_ummat_vendor_convert INPUT.
  CALL FUNCTION 'MM_VENDOR_CONVERT'
    EXPORTING
      bukrs      = space
    CHANGING
      vendor     = goitem-ummat_lifnr
      vendorname = goitem-ummat_vendorname.
ENDMODULE.                 " pai_godynpro_ummat_vendor_conv  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_godynpro_customer_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_godynpro_customer_convert INPUT.
  CALL FUNCTION 'MM_CUSTOMER_CONVERT'
    EXPORTING
      bukrs        = space
    CHANGING
      customer     = godynpro-mat_kunnr
      customername = godynpro-mat_custname.
ENDMODULE.                 " pai_godynpro_customer_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_goitem_customer_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_goitem_customer_convert INPUT.
  CALL FUNCTION 'MM_CUSTOMER_CONVERT'
    EXPORTING
      bukrs        = space
    CHANGING
      customer     = goitem-mat_kunnr
      customername = goitem-mat_custname.
ENDMODULE.                 " pai_goitem_customer_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_ummat_customer_convert  INPUT
*&---------------------------------------------------------------------*
MODULE pai_ummat_customer_convert INPUT.
  CALL FUNCTION 'MM_CUSTOMER_CONVERT'
    EXPORTING
      bukrs        = space
    CHANGING
      customer     = goitem-ummat_kunnr
      customername = goitem-ummat_custname.
ENDMODULE.                 " pai_ummat_customer_convert  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_stock_identifier_set  INPUT
*&---------------------------------------------------------------------*
MODULE pai_stock_identifier_set INPUT.
  CALL METHOD lcl_migo_globals=>kernel->umsok_get
    EXPORTING
      i_error_type = 'S'
    CHANGING
      c_sobkz      = goitem-sobkz
      cs_goitem    = goitem.
ENDMODULE.                 " pai_stock_identifier_set  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_defaults_transfer_loop  INPUT
*&---------------------------------------------------------------------*
MODULE pai_defaults_transfer_loop INPUT.
  CALL METHOD oref_defaults->pai_transfer_loop.
ENDMODULE.                 " pai_defaults_transfer_loop  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_defaults_transfer  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_defaults_transfer INPUT.
  CALL METHOD oref_defaults->pai_transfer.
ENDMODULE.                 " pai_defaults_transfer  INPUT
*&---------------------------------------------------------------------*
*&      Module  rule_changed  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_rule_changed INPUT.
  CALL METHOD oref_defaults->update_flag_set.
ENDMODULE.                 " rule_changed  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_detail_trans  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_trans INPUT.
  CALL METHOD oref_detail_trans->pai.
ENDMODULE.                 " pai_detail_trans  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_detail_sobkz_project  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_sobkz_project INPUT.
  CALL METHOD oref_detail_trans->pai.
ENDMODULE.                 " pai_detail_sobkz_project  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_detail_sobkz_supplier  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_sobkz_supplier INPUT.
  CALL METHOD oref_detail_trans->pai.
ENDMODULE.                 " pai_detail_sobkz_supplier  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_detail_sobkz_customer  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_sobkz_customer INPUT.
  CALL METHOD oref_detail_trans->pai.
ENDMODULE.                 " pai_detail_sobkz_customer  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_detail_sobkz_sales_order  INPUT
*&---------------------------------------------------------------------*
MODULE pai_detail_sobkz_sales_order INPUT.
  CALL METHOD oref_detail_trans->pai.
ENDMODULE.                 " pai_detail_sobkz_sales_order  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_new_line_check  INPUT
*&---------------------------------------------------------------------*
MODULE pai_new_line_check INPUT.
  CALL METHOD oref_defaults->pai_new_line_check.
ENDMODULE.                 " new_line_check  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_check_mvt_sobkz  INPUT
*----------------------------------------------------------------------*
*  Check the defaults for bwart and sokz if they have been changed
*  directly on MIGO screen
*&---------------------------------------------------------------------*
MODULE pai_firstline_check INPUT.
  CALL METHOD oref_firstline->pai_mvt_sobkz_check.
ENDMODULE.                 " pai_check_mvt_sobkz  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_umsok_get  INPUT
*&---------------------------------------------------------------------*
*       used in tableview of screen 0200
*----------------------------------------------------------------------*
MODULE pai_umsok_get INPUT.
  CALL METHOD lcl_migo_globals=>kernel->umsok_get
    EXPORTING
      i_error_type = 'E'
    CHANGING
      c_sobkz      = goitem-sobkz
      cs_goitem    = goitem.
ENDMODULE.                 " pai_umsok_get  INPUT
*&---------------------------------------------------------------------*
*&      Module  pai_allowed_mvt_check  INPUT
*&---------------------------------------------------------------------*
*       Check if the entered movement type is valid
*----------------------------------------------------------------------*
MODULE pai_allowed_mvt_check INPUT.
  CHECK goitem-bwart IS NOT INITIAL.
  CALL METHOD lcl_migo_buffer=>allowed_mvt_check
    EXPORTING
      i_bwart     = goitem-bwart
    EXCEPTIONS
      not_allowed = 1.
  IF sy-subrc = 1.
    MESSAGE e062 WITH goitem-bwart.
  ENDIF.
ENDMODULE.                 " pai_allowed_mvt_check  INPUT




ENHANCEMENT-POINT LMIGOPAI_02 SPOTS ES_SAPLMIGO STATIC.

*&---------------------------------------------------------------------*
*&      Module  PAI_5100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_5100 INPUT.
ENHANCEMENT-POINT PAI_5100_01 SPOTS ES_SAPLMIGO.
ENDMODULE.                 " PAI_5100  INPUT

*&---------------------------------------------------------------------*
*&      Module  POV_GOITEM_FIELD  INPUT
*&---------------------------------------------------------------------*
*       used F4-help for batch
*----------------------------------------------------------------------*
MODULE pov_goitem_field INPUT.

  IF oref_field_help IS INITIAL.
    CREATE OBJECT oref_field_help.
  ENDIF.
  oref_field_help->f4_help_field( ).

ENDMODULE.                 " POV_GOITEM_FIELD  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_EXT_INT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_DETAIL_EXT_INT INPUT.  " EHP606 CFB
  CALL METHOD oref_detail_ext_int->pai.
ENDMODULE.                 " PAI_DETAIL_EXT_INT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_CHECK_SOBKZ  INPUT
*&---------------------------------------------------------------------*
MODULE pai_check_sobkz INPUT.                               "SIT 1583699
  CALL METHOD oref_detail_dest->pai_subscr_chk_sobkz.
ENDMODULE.                             " PAI_CHECK_SOBKZ  INPUT