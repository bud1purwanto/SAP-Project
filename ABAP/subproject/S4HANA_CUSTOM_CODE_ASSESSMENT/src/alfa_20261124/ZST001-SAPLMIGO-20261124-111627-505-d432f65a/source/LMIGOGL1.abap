*----------------------------------------------------------------------*
*   INCLUDE LMIGOGL1                                                   *
*   Globally known object container
*----------------------------------------------------------------------*

CLASS lcl_migo_globals DEFINITION.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_cust,
        action TYPE goaction,
        refdoc TYPE refdoc,
        bwart  TYPE bwart,
      END OF ty_s_cust.
    CLASS-METHODS:
      class_constructor,
      kernel_refresh,
      cntl_error_handler
        FOR EVENT flush_error OF cl_gui_cfw.
    CLASS-DATA:
      kernel TYPE REF TO lcl_migo_kernel READ-ONLY,
*   Data to control the external call of MIGO. These fields are used
*   by the function module MIGO_DIALOG to propagate the data
*   into the INITIALIZATION-routine of dynpro 0001.
*   All settings related to dynpo elements (titlebar, GUI-status)
*   habe to be done in the dynpro itself, otherwise the status
*   of the caller is altered, and MIGO has nothing.
      external_call_active           TYPE abap_bool VALUE abap_false,
      external_call_leave_after_post TYPE abap_bool VALUE abap_false,
      external_call_action      TYPE goaction,
      external_call_refdoc      TYPE refdoc,
      external_call_okcode      TYPE syucomm,
      external_call_notree      TYPE abap_bool VALUE abap_false,
      external_call_deadend     TYPE abap_bool VALUE abap_false,
      external_call_first_round TYPE abap_bool VALUE abap_false,
      external_call_ebeln              TYPE ebeln,
      external_call_ebelp              TYPE ebelp,
      external_call_mblnr              TYPE mblnr,
      external_call_mjahr              TYPE mjahr,
      external_call_zeile              TYPE mblpo,
      external_call_transport          TYPE tknum,
      external_call_order_number       TYPE aufnr,
      external_call_order_item         TYPE co_posnr,
      external_call_transport_means    TYPE traty,
      external_call_transportident     TYPE traid,
      external_call_inbound_deliv      TYPE vbeln_vl,
      external_call_outbound_deliv     TYPE vbeln,
      external_call_reservation_numb   TYPE rsnum,
      external_call_reservation_item   TYPE rspos,

*     Internal table containing with the allowed combinations
*     of ACTIONs and REFDOCs for the current transaction code.
*     Used by the first line as well as be the defaults and
*     the function module interface for validity checks.
      t_cust TYPE STANDARD TABLE OF ty_s_cust,
*     Global fields for batches
      batch_level      TYPE kzdch,
      batch_conversion TYPE kzdws,
*     Global fields for documentary batch
      doc_batch_active TYPE xfeld,
*     Status of the GUI. If error set, no more control operations
*     must be triggered.
      cntl_error TYPE abap_bool,
*     Flag which says that we are an SAP system
      sap_system TYPE abap_bool,
*     The SY-TCODE of the application which started MIGO.
*     If MIGO is started via transaction code, it is this one.
*     If MIGO is started via function module, it is the
*     tcode of the caller.
      caller_sytcode TYPE sytcode,
*     BAdI MB_MIGO_BAdI: Reference to exithandler and table of
*     registered components
      if_badi TYPE REF TO if_ex_mb_migo_badi,
      t_badi  TYPE migo_badi_registration_table,
*     BAdI MB_MIGO_ITEM_BAdI: Reference to exithandler
      if_badi_item TYPE REF TO if_ex_mb_migo_item_badi,
*     Switch EhP4 development
      gv_mm_om1_sfws_sc_active TYPE abap_bool,
*     Retail switch
      migo_retail_allowed TYPE boolean,
*     Global fields for retail consignment handling
      retail_consignment_active  TYPE abap_bool,
      if_badi_retail_mb_me_csgmt TYPE REF TO if_ex_mb_me_csgmt_badi_sap.
ENHANCEMENT-POINT lmigogl_01 SPOTS es_saplmigo STATIC.
  PRIVATE SECTION.
    CLASS-METHODS:
      customizing_read,
      check_number_goitem_components,
      check_retail_consignment.
ENDCLASS.                    "lcl_migo_globals DEFINITION