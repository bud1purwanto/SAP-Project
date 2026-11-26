*----------------------------------------------------------------------*
*   INCLUDE LMIGOKR1                                                   *
*----------------------------------------------------------------------*

* METHOD RESET
*----------------------------------------------------------------------*
* Used to reset the kernel (constructor at startup, changes
* of ACTION and REFDOC, new beginning, exiting).
*----------------------------------------------------------------------*
METHOD reset.
  DATA: ls_control TYPE ty_s_control.
* Tables
  CLEAR: pt_goitem,
         pt_goserial_kernel,
         pt_goserial_post,
         pt_gofreight_kernel,
         pt_mseg_nast.
* Fieldselection table
  CALL METHOD lcl_migo_screenmodification=>delete_all.
* Structures
  CLEAR: ps_gohead,
         ps_mkpf_nast.
* Fields
  CLEAR: p_line_id.
* LINE_ID assignment for SAPMM07M. Cleared because of:
* When reading a material document, the manager is working in
* MB_READ_MATERIAL_POSITIONS. Therefore, it counts up. If MIGO is
* resetted, the manager can be cleared, too, as there are no
* memories of the last MB_CREATE call.
  CALL METHOD cl_mmim_line_id_manager=>reset.

* MAA-DEV
  IF oref_detail_maa IS BOUND.
    CALL METHOD oref_detail_maa->reset_acc.
  ENDIF.

*-------Reset for external applications---------------

* Reset batch buffer.
* First of all, clear the flag which indicates in VB that the reset
* has already been done.
* Then call again to execute the reset.
* Reason: Once called, VB_INIT sets a flag which prevents further
* resets. This is necessary as our collegues from PUR also call
* VB_INIT at the early stages of MB_CREATE_GOODS_MOVEMENT. This reset
* has to be blocked because it would purge classification data
* entered in MIGO.
* However, if MIGO says RESET, this one is mandatory.
  CALL FUNCTION 'VB_INIT'
    EXPORTING
      init_reset = x.
  CALL FUNCTION 'VB_INIT'.

* reset batch derivation buffers
  CALL FUNCTION 'VBDRV_BUFFERFLUSH'.

* reset documentary batch data when active
  IF lcl_migo_globals=>doc_batch_active = abap_true AND
     oref_detail_doc_batch IS BOUND.     " object already exists
    CALL METHOD oref_detail_doc_batch->reset.
  ENDIF.
ENHANCEMENT-SECTION     lmigokr1_03 SPOTS es_saplmigo.
* Gerneric articles: always start with dynpro Table-Control
  g_tablev_current_dyn = '0200'.
END-ENHANCEMENT-SECTION.
* refresh messages
  CALL FUNCTION 'RV_MESSAGES_REFRESH'
    EXPORTING
      msg_kappl = 'ME'.
* Reset WM buffer
  CALL FUNCTION 'REFRESH_WM_DATA_ALL'.
* Reset QM buffer
  CALL FUNCTION 'QBCK_MIGO_REFRESH'.
* Brasilian refreshments
  CALL FUNCTION 'J_1B_IM_NF_REFRESH'.

* Central PUR refresh.
* It also contains ME_REFRESH_COMP_GOODS_RECEIPT,
* which is necessary for correct subcontracting component proposal.
  CALL FUNCTION 'ME_REFRESH_GOODS_RECEIPT'.

  CALL METHOD /spe/cl_inb_action_info=>reset.              "RSU741540

ENHANCEMENT-POINT lmigokr1_01 SPOTS es_saplmigo.

* Reset Foreign Trade Data
  CALL FUNCTION 'EXPIMP_TABLES_REFRESH'.


* BAdI: Reset
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    CALL METHOD lcl_migo_globals=>if_badi->reset.
  ENDIF.

* BAdI: Refresh log                                              ERP2005
  IF oref_badi_log IS BOUND.
    CALL METHOD oref_badi_log->refresh.
  ENDIF.

* Reset PP order data                                            "736384
  CALL FUNCTION 'CO_SF_DATA_RESET'.                         "736384
  CALL FUNCTION 'CO_BT_DATA_RESET'.                              "n1514304

*-------End of reset for external applications -----------

* Set mode once new
  ls_control = mode_get( ).
  CLEAR: ls_control-vgart, ls_control-new_line_mode.
  CLEAR: g_sub_general.
  CALL METHOD mode_set(
    is_control = ls_control
    i_unconditional = abap_true ).
* Scroll table control to the first column
ENHANCEMENT-SECTION     lmigokr1_02 SPOTS es_saplmigo.
  tv_goitem-left_col = 1.
END-ENHANCEMENT-SECTION.
* Derive new status. Must be AFTER mode_set because from mode_Set
* the field selection is rebuild and status_derive also modifies
* the fields on a higher level of granularity.
  CALL METHOD status_derive.
* Send message for reset
  def_sms 'KERNEL_RESET' space space.

ENHANCEMENT-POINT reset_01 SPOTS es_saplmigo.

ENDMETHOD.                    "reset

************************************************************************
* Breakpoint for the secret toolbar. Do not remove!
************************************************************************
METHOD break_point.
  BREAK-POINT.                                             "#EC NOBREAK
ENDMETHOD.                    "break_point