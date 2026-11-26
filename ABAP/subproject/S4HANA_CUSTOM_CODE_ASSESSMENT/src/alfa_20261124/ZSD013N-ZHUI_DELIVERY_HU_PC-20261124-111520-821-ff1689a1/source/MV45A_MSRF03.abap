*&---------------------------------------------------------------------*
*&  Include           MV45A_MSRF03
*&---------------------------------------------------------------------*
*&  subroutines for checking item
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  msr_check_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form msr_check_item using uv_error type flag
                          uv_info type flag.

  if gr_msr_sales is not bound.
    return.
  endif.

  if vbap-matnr is initial and
     vbap-posnr is initial.
    return.
  endif.

  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) eq charx.
    perform msr_get_default.
    if gs_msr_sales_item ne gs_msr_sales_item_old.
      perform msr_set_replace_defaults.
    endif.
  endif.

  if not ( vbap-matnr ne *vbap-matnr or
           vbap-werks ne *vbap-werks or
           vbap-pstyv ne *vbap-pstyv or
           vbap-msr_ret_reason   ne *vbap-msr_ret_reason   or
           vbap-msr_refund_code  ne *vbap-msr_refund_code  or
           vbap-msr_approv_block ne *vbap-msr_approv_block or
           gs_msr_sales_item      ne gs_msr_sales_item_old ).
    return.
  endif.

  if vbap-matnr ne *vbap-matnr.
    perform msr_check_batch.
  endif.

  if vbap-msr_refund_code ne *vbap-msr_refund_code or
     vbap-msr_ret_reason ne *vbap-msr_ret_reason or
     gs_msr_sales_item-inspection_code ne gs_msr_sales_item_old-inspection_code or
     gs_msr_sales_item-cust_insp_code  ne gs_msr_sales_item_old-cust_insp_code  or
     ( gs_msr_sales_item-refund_type ne gs_msr_sales_item_old-refund_type and
       cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true ).
    perform confirm_rrc_change.
  endif.
  perform msr_get_default.
  perform msr_check_approval.
  perform msr_check_next_plant using uv_error uv_info.
  perform msr_check_vendor.
  perform msr_check_data using uv_error uv_info.

endform.                    "msr_check_item


*&---------------------------------------------------------------------*
*&      Form  msr_check_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form msr_check_batch.

  if gr_msr_sales is not bound.
    return.
  endif.

  if gs_msr_sales_item-mat_received eq charx and
     tvak-vbtyp eq if_msr_trc_c=>gc_doc_cat_ro.
    gr_msr_sales->check_batch(
        is_vbap           = vbap
        is_msr_sales_item = gs_msr_sales_item ).
    gr_msr_sales->check_serial(
        is_vbap           = vbap
        is_msr_sales_item = gs_msr_sales_item ).
  endif.

endform.                    "msr_check_batch


*&---------------------------------------------------------------------*
*&      Form  msr_check_approval
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form msr_check_approval.

  data:
    lv_plant_related    type flag.

  if gr_msr_sales is not bound.
    return.
  endif.

  if vbak-vbtyp = if_msr_trc_c=>gc_doc_cat_ro.
    if not vbap-werks is initial and
       vbap-msr_approv_block is initial and
       vbup-lfgsa ne 'B' and
       vbup-lfgsa ne 'C'.
      if ( svbap-tabix eq 0 and
           not vbap-matnr is initial ) or
         ( svbap-tabix > 0 and
           ( vbap-msr_approv_block ne *vbap-msr_approv_block or
             vbap-matnr ne *vbap-matnr or
             vbap-werks ne *vbap-werks or
             vbap-lgort ne *vbap-lgort or
             vbap-pstyv ne *vbap-pstyv ) ).
*       is the plant related to plant authorization check?
        gr_msr_sales->check_plant_related(
          exporting
            iv_plant   = vbap-werks
          importing
            ev_related = lv_plant_related ).
        if not lv_plant_related is initial.
*         check if the user is authorized for the plant
          authority-check
            object 'MSR_PLANT'
            id 'WERKS'
            field vbap-werks.
          if sy-subrc is not initial.
*           set default block
            vbap-msr_approv_block = if_msr_trc_c=>gc_approval_blocked.
            message w031(msr_sd) with vbap-werks vbap-posnr.
            message_collect_lord.
          endif.
        endif.
      endif.
    endif.
  endif.

endform.                    "msr_check_approval

*&---------------------------------------------------------------------*
*&      Form  MSR_CHECK_NEXT_PLANT
*&---------------------------------------------------------------------*
form msr_check_next_plant using uv_error type flag
                                uv_info type flag.

  data: ls_t001w type t001w.
  data: lv_like_error type char1.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.

  if not gv_msr_like_error is initial and
     gv_msr_fastchange is initial.
    lv_like_error = charx.
  endif.

* Check next plant and read description
  if not gs_msr_sales_item-next_plant is initial.
    if gs_msr_sales_item-next_plant eq vbap-werks.
      if not uv_error is initial.
        if not lv_like_error is initial.
          message s001(msr_sd) display like chare.
          return.
        else.
          message e001(msr_sd).
        endif.
      else.
        if not uv_info is initial.
          message i001(msr_sd).
        else.
          message w001(msr_sd).
        endif.
        message_collect_lord.
      endif.
    endif.
    call function 'T001W_READ'
      exporting
        werks    = gs_msr_sales_item-next_plant
      importing
        struct   = ls_t001w
      exceptions
        no_entry = 1
        others   = 2.
    if sy-subrc = 0.
      gs_msr_sales_item-next_plant_name = ls_t001w-name1.
    else.
      if not uv_error is initial.
        if not lv_like_error is initial.
          message s726(ct) with gs_msr_sales_item-next_plant
                           display like chare.
          return.
        else.
          set cursor field 'GS_MSR_SALES_ITEM-NEXT_PLANT'.
          message e726(ct) with gs_msr_sales_item-next_plant.
        endif.
      else.
        if not uv_info is initial.
          message i726(ct) with gs_msr_sales_item-next_plant.
        else.
          message w726(ct) with gs_msr_sales_item-next_plant.
        endif.
        message_collect_lord.
      endif.
    endif.
  else.
    clear:
      gs_msr_sales_item-next_plant_name,
      gs_msr_sales_item-transshipment,
      gs_msr_sales_item-multiple_plants.
  endif.

endform.                    " MSR_CHECK_NEXT_PLANT

*&---------------------------------------------------------------------*
*&      Form  MSR_CHECK_VENDOR
*&---------------------------------------------------------------------*
form msr_check_vendor.

  data:
    ls_lfa1             type lfa1.

  if gs_msr_sales_item-lifnr is not initial.
    clear gs_msr_sales_item-vendor_name.
*   Set vendor name
    call function 'LFA1_SINGLE_READ'
      exporting
        lfa1_lifnr = gs_msr_sales_item-lifnr
      importing
        wlfa1      = ls_lfa1
      exceptions
        not_found  = 1
        others     = 2.
    if sy-subrc = 0.
      gs_msr_sales_item-vendor_name  = ls_lfa1-name1.
      gs_msr_sales_item-vendor_adrnr = ls_lfa1-adrnr.
    else.
      set cursor field 'MSR_S_SD_ITEM-LIFNR'.
      message e753(me) with gs_msr_sales_item-lifnr.
    endif.
  else.
    gs_msr_sales_item-rma_vendor_req = abap_false.
    clear:
      gs_msr_sales_item-vendor_diff_adr,
      gs_msr_sales_item-vendor_name,
      gs_msr_sales_item-vendor_adrnr,
      gs_msr_sales_item-lifnr.
  endif.

endform.                    " MSR_CHECK_VENDOR

*&---------------------------------------------------------------------*
*&      Form  msr_get_default
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form msr_get_default.

  data:
    lv_defaults         type flag,
    lv_confirm          type flag,
    lv_cancel           type flag,
    lv_delta            type flag,
    lv_mat_received     type msr_material_received,
    lv_refund_control   type msr_refund_control,
    lv_refund_type      type msr_refund_type,
    lv_fu_code          type msr_fu_code,
    lv_ret_reason       type msr_returns_reason.

  if not gv_msr_defaults is initial.
    return.
  endif.


* new item => get default values
  if svbap-tabix eq 0.

*   text-position: set default fu_code "bulkreturn"
    if vbap-posar eq charb.
      clear gs_msr_sales_item-mat_received.
      clear gs_msr_sales_item-refund_control.
      gs_msr_sales_item-fu_code = if_msr_trc_c=>gc_code_bulkreturn.
      return.
    endif.

    lv_defaults = charx.

* plant is filled and has been changed => get default values
* no default values when plant has been cleared
  elseif vbap-werks ne *vbap-werks and vbap-werks is not initial.
    lv_defaults = charx.
* if returns fields are already filled => send confirmation popup
    if gs_msr_sales_item-mat_received   is not initial or
       gs_msr_sales_item-refund_control is not initial or
       gs_msr_sales_item-fu_code        is not initial.
      lv_confirm = charx.
    endif.

* if plant was empty          =>  no  confirmation popup
* if plant was already filled => send confirmation popup
    if *vbap-werks is not initial.
      lv_confirm = charx.
    endif.
  endif.

  if vbap-posar eq charb.
    return.
  endif.

  if not lv_defaults is initial.
* necessary for screen control
    gv_msr_defaults = charx.

* in case of LORD send system message instead of confirmation popup (otherwise booom)
    if call_activity eq gc_activity_lord and
       lv_confirm is not initial.
      clear lv_confirm.
      message i015(msr_sd) with vbap-posnr.
      message_collect_lord.
    endif.

* if values from customer exist -> no defaults
    if ( gs_msr_sales_item-mat_received   is not initial or
         gs_msr_sales_item-refund_control is not initial or
         gs_msr_sales_item-fu_code        is not initial ) and
         lv_confirm                       is initial.
      return.
    endif.

    gr_msr_sales->get_item_defaults(
      exporting
        iv_werks          = vbap-werks
        iv_vkbur          = vbak-vkbur
        iv_confirm        = lv_confirm
      importing
        ev_mat_received   = lv_mat_received
        ev_refund_control = lv_refund_control
        ev_refund_type    = lv_refund_type
        ev_fu_code        = lv_fu_code
        ev_ret_reason     = lv_ret_reason
        ev_cancel         = lv_cancel ).
    if lv_cancel is initial.
      if gs_msr_sales_item-mat_received eq gs_msr_sales_item_old-mat_received.
        gs_msr_sales_item-mat_received = lv_mat_received.
      endif.
      if gs_msr_sales_item-refund_control eq gs_msr_sales_item_old-refund_control.
        gs_msr_sales_item-refund_control = lv_refund_control.
      endif.

      if cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true and
         gs_msr_sales_item-refund_type eq gs_msr_sales_item_old-refund_type.
        gs_msr_sales_item-refund_type = lv_refund_type.
      endif.

      if gs_msr_sales_item-fu_code eq gs_msr_sales_item_old-fu_code.
        gs_msr_sales_item-fu_code = lv_fu_code.
      endif.
      if vbap-msr_ret_reason eq *vbap-msr_ret_reason.
        vbap-msr_ret_reason = lv_ret_reason.
      endif.
    endif.
  endif.

endform.                    "msr_get_default

*&---------------------------------------------------------------------*
*&      Form  MSR_CHECK_DATA
*&---------------------------------------------------------------------*
form msr_check_data using uv_error type flag
                          uv_info type flag.

  data: ls_message type bapiret2,
        lv_fehlerfeld type tbfdnam_vb,
        ls_next_plants type msr_s_next_plant,
        lt_next_plants type msr_t_next_plants.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.

  if vbap-lgort ne *vbap-lgort and
     not vbap-lgort is initial and
     not *vbap-lgort is initial.
    gr_msr_sales->check_storage_location(
      exporting
        is_vbap           = vbap
        is_msr_sales_item = gs_msr_sales_item ).
  endif.

* check fields on returns screen
  if gv_msr_fastchange is initial.
    gr_msr_sales->check_data(
      exporting
        is_vbak          = vbak
        is_vbap          = vbap
        is_sales_item    = gs_msr_sales_item
        it_vbep          = xvbep[]
        iv_vwpos         = xvbap-vwpos
        iv_check_ro_data = charx
      importing
        es_message       = ls_message ).
  else.
    gr_msr_sales->check_data(
      exporting
        is_vbak        = vbak
        is_vbap        = vbap
        is_sales_item  = gs_msr_sales_item
        it_vbep        = xvbep[]
        iv_vwpos       = xvbap-vwpos
      importing
        es_message    = ls_message ).
  endif.
  if ls_message is not initial.
    write ls_message-field to lv_fehlerfeld.
    gr_msr_sales->change_cursor_field( changing cv_fehlerfeld = lv_fehlerfeld ).
    set cursor field lv_fehlerfeld.
    if uv_error is initial.
      if ls_message-type eq chare.
        ls_message-type = charw.
        if not uv_info is initial.
          ls_message-type = chari.
        endif.
      endif.
    endif.
    if ls_message-type eq charw.                             "Corr
      ls_message-type = chari.                               "Corr
    endif.                                                   "Corr
    if not uv_error is initial and
       not gv_msr_like_error is initial and
       gv_msr_fastchange is initial.
      if ls_message-type eq chare.
        ls_message-type = chars.
        message id ls_message-id type ls_message-type number ls_message-number
                with ls_message-message_v1 ls_message-message_v2
                     ls_message-message_v3 ls_message-message_v4
                display like chare.
      else.
        message id ls_message-id type chars number ls_message-number
                with ls_message-message_v1 ls_message-message_v2
                     ls_message-message_v3 ls_message-message_v4
                display like ls_message-type.
      endif.
    else.
      message id ls_message-id type ls_message-type number ls_message-number
              with ls_message-message_v1 ls_message-message_v2
                   ls_message-message_v3 ls_message-message_v4.
    endif.
    message_collect_lord.
  endif.

endform.                    " MSR_CHECK_DATA