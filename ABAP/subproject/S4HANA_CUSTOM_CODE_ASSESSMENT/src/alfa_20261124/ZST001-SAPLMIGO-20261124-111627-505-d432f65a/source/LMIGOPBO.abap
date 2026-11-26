*----------------------------------------------------------------------*
***INCLUDE LMIGOPBO .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PBO_INITILIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_initilization OUTPUT.
  PERFORM initialization.                           "Classes
  PERFORM take_data_from_migo_dialog.          "Process data
ENDMODULE.                 " PBO_INITILIZATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_USERDEFAULTS_FLUSH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_userdefaults_flush OUTPUT.
  CALL METHOD cl_mmim_userdefaults=>flush_all.
ENDMODULE.                 " PBO_USERDEFAULTS_FLUSH  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_MIGO_FIRSTLINE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_migo_firstline OUTPUT.
  CALL METHOD oref_firstline->pbo.
ENDMODULE.                 " PBO_MIGO_FIRSTLINE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_TABLEVIEW  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tableview OUTPUT.
  CALL METHOD oref_tableview->pbo.
 ENHANCEMENT-POINT PBO_TABLEVIEW_01 SPOTS ES_SAPLMIGO.
ENDMODULE.                 " PBO_TABLEVIEW  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_TABLEVIEW_LOOP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tableview_loop OUTPUT.
  CALL METHOD oref_tableview->pbo_loop.
  ENHANCEMENT-POINT PBO_TABLEVIEW_LOOP_01 SPOTS ES_SAPLMIGO.
ENDMODULE.                 " PBO_TABLEVIEW_LOOP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_TABLEVIEW_SPLIT  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tableview_split OUTPUT.
  CALL METHOD oref_split_quantity->pbo.
ENDMODULE.                 " PBO_TABLEVIEW  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_TABLEVIEW_SPLIT_LOOP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tableview_split_loop OUTPUT.
  CALL METHOD oref_split_quantity->pbo_loop.
ENDMODULE.                 " PBO_TABLEVIEW_LOOP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_TABLEVIEW_GA  OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip Retail generic articles
*----------------------------------------------------------------------*
MODULE pbo_tableview_ga OUTPUT.
  CALL METHOD oref_detail_ga->pbo.
ENDMODULE.                 " PBO_TABLEVIEW_GA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*       Header carrier
*----------------------------------------------------------------------*
MODULE pbo_header OUTPUT.
   CALL METHOD oref_header->pbo.
ENDMODULE.                 " PBO_HEADER  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_GENERAL  OUTPUT
*&---------------------------------------------------------------------*
*       Header tabstrip general
*----------------------------------------------------------------------*
MODULE pbo_header_general OUTPUT.
  CALL METHOD oref_header_general->pbo.
ENDMODULE.                 " PBO_HEADER_GENERAL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_VENDOR  OUTPUT
*&---------------------------------------------------------------------*
*       Header tabstrip vendor
*----------------------------------------------------------------------*
MODULE pbo_header_vendor OUTPUT.
  CALL METHOD oref_header_vendor->pbo.
ENDMODULE.                 " PBO_HEADER_VENDOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_PEOPLE  OUTPUT
*&---------------------------------------------------------------------*
*       Header tabstrip people
*----------------------------------------------------------------------*
MODULE pbo_header_people OUTPUT.
  CALL METHOD oref_header_people->pbo.
ENDMODULE.                 " PBO_HEADER_PEOPLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_DOCINFO  OUTPUT
*&---------------------------------------------------------------------*
*       Header tabstrip document info
*----------------------------------------------------------------------*
MODULE pbo_header_docinfo OUTPUT.
  CALL METHOD oref_header_docinfo->pbo.
ENDMODULE.                 " PBO_HEADER_DOCINFO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_IMPORT  OUTPUT
*&---------------------------------------------------------------------*
*       Header tabstrip import
*----------------------------------------------------------------------*
MODULE pbo_header_import OUTPUT.
  CALL METHOD oref_header_import->pbo.
ENDMODULE.                 " PBO_HEADER_IMPORT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_HEADER_IMPORT_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*       Header import popup
*----------------------------------------------------------------------*
MODULE pbo_header_import_popup OUTPUT.
  CALL METHOD oref_header_import->pbo_popup.
ENDMODULE.                 " PBO_HEADER_IMPORT_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail OUTPUT.
  CALL METHOD oref_detail->pbo.
ENDMODULE.                 " PBO_DETAIL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_MATERIAL OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_material OUTPUT.
  CALL METHOD oref_detail_material->pbo.
ENDMODULE.                 " PAI_DETAIL_MATERIAL OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_DETAIL_QUANTITY OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_quantity OUTPUT.
  CALL METHOD oref_detail_quantity->pbo.
ENDMODULE.                 " PAI_DETAIL_QUANTITY OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_PO       OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip purchase order
*----------------------------------------------------------------------*
MODULE pbo_detail_po OUTPUT.
  CALL METHOD oref_detail_po->pbo.
ENDMODULE.                 " PBO_DETAIL_PO OUTPUT

* begin of Outsourced Manufacturing EhP 4

*&      Module  PBO_DETAIL_PO       OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip purchase order
*----------------------------------------------------------------------*
MODULE pbo_detail_po_sc OUTPUT.
  CALL METHOD oref_detail_po_sc->pbo.
ENDMODULE.                 " PBO_DETAIL_PO_SC OUTPUT


MODULE pbo_detail_po_sc_loop OUTPUT.
  CALL METHOD oref_detail_po_sc->pbo_loop.
ENDMODULE.

* end of Outsourced Manufacturing EhP 4

*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_BATCH    OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip batch
*----------------------------------------------------------------------*
MODULE pbo_detail_batch OUTPUT.
  CALL METHOD oref_detail_batch->pbo.
ENDMODULE.                 " PBO_DETAIL_BATCH OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_DOC_BATCH    OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip batch
*----------------------------------------------------------------------*
MODULE pbo_detail_doc_batch OUTPUT.
  CALL METHOD oref_detail_doc_batch->pbo.
ENDMODULE.                 " PBO_DETAIL_BATCH OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_DEST     OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip destination
*----------------------------------------------------------------------*
MODULE pbo_detail_dest OUTPUT.
  CALL METHOD oref_detail_dest->pbo.
ENDMODULE.                 " PBO_DETAIL_DEST OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_ACCOUNT         OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip destination
*----------------------------------------------------------------------*
MODULE pbo_detail_account OUTPUT.
  CALL METHOD oref_detail_account->pbo.
ENDMODULE.                 " PBO_DETAIL_ACCOUNT OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_MAA             OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip multiple account assignment : MAA-DEV
*----------------------------------------------------------------------*
MODULE pbo_detail_maa OUTPUT.
  CALL METHOD oref_detail_maa->pbo.
ENDMODULE.                 " PBO_DETAIL_MAA OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_SERIAL_NUMBERS     OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip serial numbers
*----------------------------------------------------------------------*
MODULE pbo_detail_serial_numbers OUTPUT.
  CALL METHOD oref_detail_serial_numbers->pbo.
ENDMODULE.                 " PBO_DETAIL_SERIAL_NUMBERS OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_SERIAL_NUMBERS_LOOP OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_serial_numbers_loop OUTPUT.
  CALL METHOD oref_detail_serial_numbers->pbo_loop.
ENDMODULE.             " PBO_DETAIL_SERIAL_NUMBERS_LOOP OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_FREIGHT     OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip freight
*----------------------------------------------------------------------*
MODULE pbo_detail_freight OUTPUT.
  CALL METHOD oref_detail_freight->pbo.
ENDMODULE.                 " PBO_DETAIL_FREIGHT OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_FREIGHT_LOOP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_freight_loop OUTPUT.
  CALL METHOD oref_detail_freight->pbo_loop.
ENDMODULE.                 " PBO_DETAIL_FREIGHT_LOOP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_IMPORT_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*       Detail import popup
*----------------------------------------------------------------------*
MODULE pbo_detail_import_popup OUTPUT.
  CALL METHOD oref_detail_import->pbo_popup.
ENDMODULE.                 " PBO_DETAIL_IMPORT_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_IMPORT  OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip import
*----------------------------------------------------------------------*
MODULE pbo_detail_import OUTPUT.
  CALL METHOD oref_detail_import->pbo.
ENDMODULE.                 " PBO_DETAIL_IMPORT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_TAXES  OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip taxes
*----------------------------------------------------------------------*
MODULE pbo_detail_taxes OUTPUT.
  CALL METHOD oref_detail_taxes->pbo.
ENDMODULE.                 " PBO_DETAIL_TAXES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_WM  OUTPUT
*&---------------------------------------------------------------------*
*       Detail tabstrip warehouse management
*----------------------------------------------------------------------*
MODULE pbo_detail_wm OUTPUT.
  CALL METHOD oref_detail_wm->pbo.
ENDMODULE.                 " PBO_DETAIL_WM  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_FIRSTLINE_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_firstline_subscreen OUTPUT.
  CALL METHOD oref_firstline->pbo.
ENDMODULE.                 " PBO_FIRSTLINE_SUBSCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DEFAULTS_POPUP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_defaults_popup OUTPUT.
  CALL METHOD oref_defaults->pbo.
ENDMODULE.                 " PBO_DEFAULTS_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SEARCH_PO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_search_po OUTPUT.
  CALL METHOD oref_search->pbo.
ENDMODULE.                 " PBO_SEARCH_PO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SEARCH_ORD  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_search_ord OUTPUT.
  CALL METHOD oref_search->pbo.
ENDMODULE.                 " PBO_SEARCH_ORD  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_ORDER  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_order OUTPUT.
  CALL METHOD oref_detail_order->pbo.
ENDMODULE.                 " PBO_DETAIL_ORDER  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_TRANSFER OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_transfer OUTPUT.
  CALL METHOD oref_detail_transfer->pbo.
ENDMODULE.                 " PBO_DETAIL_TRANSFER  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_BOM_POPUP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_bom_popup OUTPUT.
  CALL METHOD oref_bom->pbo.
ENDMODULE.                 " PBO_BOM_POPUP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DEFAULTS_LOOP  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_defaults_loop OUTPUT.
  CALL METHOD oref_defaults->pbo_loop.
ENDMODULE.                 " PBO_DEFAULTS_LOOP  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_SEARCH_RES  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_search_res OUTPUT.
  CALL METHOD oref_search->pbo.
ENDMODULE.                 " PBO_SEARCH_RES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_RESERVATION  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_reservation OUTPUT.
  CALL METHOD oref_detail_reservation->pbo.
ENDMODULE.                 " PBO_DETAIL_RESERVATION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_TAKEIT  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_takeit OUTPUT.
  CALL METHOD oref_detail_takeit->pbo.
ENDMODULE.                 " PBO_DETAIL_TAKEIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_PARTNERS  OUTPUT
*&---------------------------------------------------------------------*
*       Detail Tabstrip Partners
*----------------------------------------------------------------------*
MODULE pbo_detail_partners OUTPUT.
  CALL METHOD oref_detail_partners->pbo.
ENDMODULE.                 " PBO_DETAIL_PARTNERS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_DEST_SUB_SELECT  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_detail_dest_sub_select OUTPUT.
  CALL METHOD oref_detail_dest->pbo_subscreen_select.
ENDMODULE.                 " PBO_DETAIL_DEST_SUB_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_tip  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tip OUTPUT.
  CALL METHOD oref_tip->pbo.
ENDMODULE.                 " pbo_tip  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_tableview_buttons  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo_tableview_buttons OUTPUT.
  CALL METHOD oref_tableview_buttons->pbo.
ENDMODULE.                 " pbo_tableview_buttons  OUTPUT
ENHANCEMENT-POINT PBO_TABLEVIEW_BUTTONS_01 SPOTS ES_SAPLMIGO STATIC.
*&---------------------------------------------------------------------*
*&      Module  pbo_frame_text_set  OUTPUT
*&---------------------------------------------------------------------*
module pbo_frame_text_set OUTPUT.
  CALL METHOD oref_detail_trans->pbo_frame_text_set.
endmodule.                 " pbo_frame_text_set  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_godynpro_fill  OUTPUT
*&---------------------------------------------------------------------*
module pbo_godynpro_fill output.
  CALL METHOD oref_detail->pbo_godynpro_fill.
endmodule.                 " pbo_godynpro_fill  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_stock_identifier_set  OUTPUT
*&---------------------------------------------------------------------*
module pbo_stock_identifier_set OUTPUT.
  call method oref_detail_trans->pbo_stock_identifier_set.
endmodule.                 " pbo_stock_identifier_set  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_defaults_transfer_loop  OUTPUT
*&---------------------------------------------------------------------*
module pbo_defaults_transfer_loop output.
  CALL METHOD oref_defaults->pbo_transfer_loop.
endmodule.                 " pbo_defaults_transfer_loop  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_defaults_transfer_popup  OUTPUT
*&---------------------------------------------------------------------*
module pbo_defaults_transfer_popup output.
  CALL METHOD oref_defaults->pbo_transfer.
endmodule.                 " pbo_defaults_transfer_popup  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_detail_trans  OUTPUT
*&---------------------------------------------------------------------*
module pbo_detail_trans output.
  CALL METHOD oref_detail_trans->pbo.
endmodule.                 " pbo_detail_trans  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_detail_sobkz_project  OUTPUT
*&---------------------------------------------------------------------*
module pbo_detail_sobkz_project output.
  CALL METHOD oref_detail_trans->pbo.
endmodule.                 " pbo_detail_sobkz_project  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_detail_sobkz_supplier  OUTPUT
*&---------------------------------------------------------------------*
module pbo_detail_sobkz_supplier output.
  CALL METHOD oref_detail_trans->pbo.
endmodule.                 " pbo_detail_sobkz_supplier  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_detail_sobkz_customer  OUTPUT
*&---------------------------------------------------------------------*
module pbo_detail_sobkz_customer output.
  CALL METHOD oref_detail_trans->pbo.
endmodule.                 " pbo_detail_sobkz_customer  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_detail_sobkz_sales_order  OUTPUT
*&---------------------------------------------------------------------*
module pbo_detail_sobkz_sales_order output.
  CALL METHOD oref_detail_trans->pbo.
endmodule.                 " pbo_detail_sobkz_sales_order  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  pbo_subscreen_set  OUTPUT
*&---------------------------------------------------------------------*
module pbo_subscreen_set output.
   CALL METHOD oref_detail_material->subscreen_set.
endmodule.                 " pbo_subscreen_set  OUTPUT
*----------------------------------------------------------------------*
*      MODULE pbo_detail_serial_numbers_container OUTPUT         "637093
*----------------------------------------------------------------------*
*      Detail tabstrip serial numbers from posted pi-document    "637093
*----------------------------------------------------------------------*
MODULE pbo_detail_serial_container OUTPUT.                       "637093
  CALL METHOD oref_detail_serial_numbers->pbo_show_inv.          "637093
ENDMODULE.             " pbo_detail_serial_container  OUTPUT     "637093

ENHANCEMENT-POINT LMIGOPBO_01 SPOTS ES_SAPLMIGO STATIC.


*&---------------------------------------------------------------------*
*&      Module  pbo_5100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_5100 OUTPUT.
ENHANCEMENT-POINT PBO_5100_01 SPOTS ES_SAPLMIGO.
ENDMODULE.                 " pbo_5100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_DETAIL_EXT_INT  OUTPUT  EHP 606 CFB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_DETAIL_EXT_INT OUTPUT.
  CALL METHOD oref_detail_ext_int->pbo.
ENDMODULE.                 " PBO_DETAIL_EXT_INT  OUTPUT