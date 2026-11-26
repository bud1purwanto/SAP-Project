*----------------------------------------------------------------------*
*   INCLUDE LMIGOGL2                                                   *
*   GLobals
*----------------------------------------------------------------------*

CLASS lcl_migo_globals IMPLEMENTATION.
************************************************************************
* Create the global classes
************************************************************************
  METHOD class_constructor.
    DATA: vim_system_type(10) TYPE c,
          l_badis_1 TYPE i,
          l_badis_2 TYPE i.

* Type of system
    CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'transport/systemtype'
                       ID 'VALUE' FIELD vim_system_type.
    IF vim_system_type = 'SAP'.
      sap_system = abap_true.
    ENDIF.
* We set the tcode to SY-TCODE. If called from outside and using
* new rollarea, the function module MIGO_DIALOG will overwrite
* this later.
    caller_sytcode = sy-tcode.
* Create kernel
    CREATE OBJECT kernel TYPE lcl_migo_kernel.
* Read global settings
    CALL METHOD customizing_read.
    CALL METHOD check_number_goitem_components.
    CALL FUNCTION 'VB_BATCH_DEFINITION'
      IMPORTING
        kzdch = batch_level
        kzdws = batch_conversion.
* documentary batch active in client?
    CALL FUNCTION 'VBDBBF_ACTIVE_CHECK_GENERAL'
      IMPORTING
        ev_docubatch_active = doc_batch_active
      EXCEPTIONS
        OTHERS              = 0.
* Register handler method for CNTL_ERROR
    cntl_error = abap_false.
    SET HANDLER cntl_error_handler.
* retail consignment handling active, if active
* get an instance of BAdI MB_ME_CSGMT_BADI_SAP
    CALL METHOD check_retail_consignment.
* BAdI: Get instance (BAdI MB_MIGO_BADI interface)
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'MB_MIGO_BADI'
        null_instance_accepted = x
      CHANGING
        instance               = if_badi.
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      CALL METHOD if_badi->init
        CHANGING
          ct_init = t_badi.
      DESCRIBE TABLE t_badi LINES l_badis_1.
      IF l_badis_1 > 5.
        MESSAGE a047.
      ENDIF.
      SORT t_badi BY class_id.
      DELETE ADJACENT DUPLICATES FROM t_badi.
      DESCRIBE TABLE t_badi LINES l_badis_2.
      IF l_badis_1 <> l_badis_2.
        MESSAGE a048.
      ENDIF.
    ENDIF.
* BAdI: Get instance (BAdI MB_MIGO_ITEM_BADI interface)
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'MB_MIGO_ITEM_BADI'
        null_instance_accepted = x
      CHANGING
        instance               = if_badi_item.
ENHANCEMENT-POINT class_constructor_01 SPOTS es_saplmigo.
  ENDMETHOD.                    "class_constructor
************************************************************************
* A possibility to get an entirely new kernel
* Is not used for the time being (4.6B)
************************************************************************
  METHOD kernel_refresh.
    FREE kernel.
    CREATE OBJECT kernel TYPE lcl_migo_kernel.
  ENDMETHOD.                    "kernel_refresh

************************************************************************
* Create the internal customozing table.
* It contains the valid combinations of action and refdoc, derived
* a) From an internal default combination scheme
* b) The customizing, which is able to delete entries.
************************************************************************
  METHOD customizing_read.
    DATA: l_action_list          TYPE string,
          l_refdoc_list          TYPE string,
          lt_action              TYPE TABLE OF goaction,
          lt_refdoc              TYPE TABLE OF refdoc,
          l_action               TYPE goaction,
          l_refdoc               TYPE refdoc,
          ls_cust                TYPE ty_s_cust,
          ls_cust_action         TYPE migo_cust_action,
          ls_cust_refdoc         TYPE migo_cust_refdoc,
          lv_sc_po_transfer      TYPE abap_bool VALUE abap_false,
          lr_badi_sc_po_transfer TYPE REF TO mb_migo_sc_po_transfer.

*   Call internal BAdI whether any switched implementation exists
*   which enables using a purchase order as reference in case of a transfer
    TRY.
      GET BADI lr_badi_sc_po_transfer.
      CALL BADI lr_badi_sc_po_transfer->enable_sc_po_transfer
        CHANGING cv_sc_po_transfer_enabled = lv_sc_po_transfer.
    CATCH cx_badi_not_implemented.
      lv_sc_po_transfer = abap_false.
    ENDTRY.
*   Create the default entries. These are the superset of all allowed
*   combinations. Customizing can only delete entries.
    l_action_list = 'A01 A02 A03 A04 A05 A06 A07 A08 A09 A10 A11'.
    SPLIT l_action_list AT ' ' INTO TABLE lt_action.
    LOOP AT lt_action INTO l_action.
      CASE l_action.
        WHEN 'A01'.
          l_refdoc_list = 'R01 R02 R04 R05 R06 R07 R08 R09 R10'.
        WHEN 'A02'. l_refdoc_list = 'R02 R03'.
        WHEN 'A03'. l_refdoc_list = 'R02'.
        WHEN 'A04'. l_refdoc_list = 'R02'.
        WHEN 'A05'. l_refdoc_list = 'R02'.
        WHEN 'A06'. l_refdoc_list = 'R02 R03'.
        WHEN 'A07'. l_refdoc_list = 'R01 R02 R08 R09 R10'.
        WHEN 'A08'.
          IF lv_sc_po_transfer EQ abap_true.
            l_refdoc_list = 'R01 R02 R09 R10'.
          ELSE.
            l_refdoc_list = 'R02 R09 R10'.
          ENDIF.
        WHEN 'A09'. l_refdoc_list = 'R02 R10'.
        WHEN 'A10'. l_refdoc_list = 'R02 R10'.
        WHEN 'A11'. l_refdoc_list = 'R01'.
      ENDCASE.
      SPLIT l_refdoc_list AT ' ' INTO TABLE lt_refdoc.
      LOOP AT lt_refdoc INTO l_refdoc.
        ls_cust-action = l_action.
        ls_cust-refdoc = l_refdoc.
        APPEND ls_cust TO t_cust.
      ENDLOOP.
    ENDLOOP.
*   Read the customizing and eliminate found entries which are
*   deselected.
    SELECT * FROM migo_cust_action INTO ls_cust_action
             WHERE tcode = caller_sytcode.
      IF ls_cust_action-active = space.
        DELETE t_cust WHERE action = ls_cust_action-action.
      ELSE.
        SELECT * FROM migo_cust_refdoc INTO ls_cust_refdoc
                 WHERE tcode  = ls_cust_action-tcode
                   AND action = ls_cust_action-action.
          IF ls_cust_refdoc-active = space.
            DELETE t_cust WHERE action = ls_cust_refdoc-action
                            AND refdoc = ls_cust_refdoc-refdoc.
          ENDIF.
        ENDSELECT.
      ENDIF.
    ENDSELECT.
* Switch EhP4 Development
    IF cl_ops_switch_check=>mm_om1_sfws_sc( ) EQ cl_ops_switch_check=>switch_active_true.
      gv_mm_om1_sfws_sc_active = abap_true.
    ENDIF.
  ENDMETHOD.                    "customizing_read
************************************************************************
* Handler method for FLUSH_ERROR of CL_GUI_CFW.
* If CNTL_ERROR is set, not more operation with control elements
* should be executed.
* In MIGO, this is done by testing this flag in the message handlers
* if the affected components.
************************************************************************
  METHOD cntl_error_handler.
    IF cntl_error = abap_false.
      MESSAGE i017(migo).
    ENDIF.
    cntl_error = abap_true.
  ENDMETHOD.                    "cntl_error_handler


************************************************************************
* Check how many components are in GOITEM and compare to the number
* stored in this method.
*
* This check shall remind you that our retail colleagues have a
* copy of GOITEM containing a subset of field for tied empties
* handling in the method LCL_MIGO_KERNEL->GOODS_MVMT_FULL_DATA_MIX_IN.
* Futhermore you have to check if you have to clear this item when
* cancelling a material document.
*
* Every time a new field is appended to GOITEM, its relevance has
* to be considered by them. Unfortunately, this can easily happen if
* any of the included structures in GOITEM is modified. Therefore,
* it is possible that this message suddenly comes up in
* productive customer systems by corrections of other components
* which do not recognize that MIGO afterwards needs to check their
* changes.
*
* What to do: If you encounter this error, you are probably the first
*             one to start MIGO after the change in GOITEM.
*             Increase the value below
*             to the value received in the error message. Then
*             consult a collegue of retail in MM-IM to finally
*             decide whether they need special treatment of the
*             field in their coding.
************************************************************************
  METHOD check_number_goitem_components.
*   List of notes which up to now modified this value.
*   All of these notes have to be implemented!!!!!!!
*   Note  209343 (EPRIO and RULES)
*   Note  313811 (KZBAA)
*   Note  314765 (XSTBW)
*   SDP 4.62     (XAUTO)
*   Note  319194 (BUSTR)
*   Note  321534 (ETENS)
*   Note  330860 (WEANZ + WEANZX)
*   Note  381405 (RES_SOBKZ)
*   Note  398683 (BWART_RETPO)
*   Note  552271 (LEINDT)
*   Note  556499 (XAUTOPO)
*   documentary batch (DOCUBATCH_CONTROL, DOCUBATCH_CHARG,
*                      DOCUBATCH_MULT_ENTRIES)
    DATA:
      lt_goitem TYPE STANDARD TABLE OF x031l WITH KEY fieldname,
      lt_gocobl TYPE STANDARD TABLE OF x031l,
      ls_x031l  TYPE x031l,
      l_lines  TYPE i.
ENHANCEMENT-POINT lmigogl2_01 SPOTS es_saplmigo.
* Compute GOITEM \ GOCOBL
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'GOITEM'
      TABLES
        x031l_tab = lt_goitem
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'GOCOBL'
      TABLES
        x031l_tab = lt_gocobl
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*   If CI_COBL does not exist, this is no error.
      CLEAR lt_gocobl.
    ENDIF.
    LOOP AT lt_gocobl INTO ls_x031l.
      DELETE TABLE lt_goitem
                   WITH TABLE KEY fieldname = ls_x031l-fieldname.
    ENDLOOP.
  ENDMETHOD.                    "check_number_goitem_components

************************************************************************
* Check if retail consignment handling is active, if so some special
* things are possible for retail articles e.g. structured article with
* special stock ind. K and automatic determination of vendor and
* special stock indicator for GR with PO (or Delivery)
************************************************************************
  METHOD check_retail_consignment.
    DATA: ls_tcurm TYPE tcurm.
    SELECT SINGLE * FROM tcurm INTO ls_tcurm.
    CHECK sy-subrc = 0.
    IF NOT ls_tcurm-cons_hnd IS INITIAL.
      CALL METHOD cl_exithandler=>get_instance(
        EXPORTING
          exit_name              = 'MB_ME_CSGMT_BADI_SAP'
          null_instance_accepted = 'X'
        CHANGING
          instance               = if_badi_retail_mb_me_csgmt ).
      IF if_badi_retail_mb_me_csgmt IS NOT INITIAL.
        retail_consignment_active = abap_true.
      ENDIF.
    ELSE.
      retail_consignment_active = abap_false.
    ENDIF.
  ENDMETHOD.                    "check_retail_consignment

ENDCLASS.                    "lcl_migo_globals IMPLEMENTATION