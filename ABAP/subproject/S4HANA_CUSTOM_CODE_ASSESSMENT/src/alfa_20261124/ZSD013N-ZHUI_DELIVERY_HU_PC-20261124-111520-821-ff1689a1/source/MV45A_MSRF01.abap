*----------------------------------------------------------------------*
* INCLUDE MV45AF_MSRF01
* Advanced returns related form routines
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MSR_INIT
*&---------------------------------------------------------------------*
form msr_init.

  data ls_vbap              type vbap.
  data lv_change_mode       type flag.

* Create MSR instance
  cl_msr_sales=>create_instance(
    exporting
      is_vbak       = vbak
      is_tvak       = tvak
    importing
      er_msr_sales  = gr_msr_sales ).
  if gr_msr_sales is bound.
*   Create tracking and inspection instances
    gr_msr_sales->init_va_transaction( is_tvak = tvak ).
*   Get next document number if requested in customizing
    if tvak-msr_next_number = chari.
      perform msr_get_next_doc_no.
    endif.
    if t180-trtyp ne chara.
      lv_change_mode = abap_true.
    endif.
    loop at xvbap where updkz ne chard.
      move-corresponding xvbap to ls_vbap.
      gr_msr_sales->get_msr_item_data(
        exporting
          is_vbak           = vbak
          is_vbap           = ls_vbap
          iv_change_mode    = lv_change_mode
          it_xvbpa          = xvbpa[] ).
    endloop.
  endif.

endform.                    " MSR_INIT

*&---------------------------------------------------------------------*
*&      Form  MSR_READ_ITEM
*&---------------------------------------------------------------------*
form msr_read_item.

  data:
    lv_change_mode      type xfeld.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.

  if vbap-posnr is initial.
    clear gs_msr_sales_item.
    return.
  endif.
  if t180-trtyp ne chara.
    lv_change_mode = abap_true.
  endif.
* Get MSR item data
  gr_msr_sales->get_msr_item_data(
    exporting
      is_vbap           = vbap
      is_vbak           = vbak
      iv_change_mode    = lv_change_mode
      iv_split_id       = gv_msr_copy_split_id
      it_xvbpa          = xvbpa[]
      iv_kopieren       = kopieren                   "1633208
    importing
      es_msr_sales_item = gs_msr_sales_item
    changing
      cv_msr_ret_reason   = vbap-msr_ret_reason      "1633208
      cv_msr_refund_code  = vbap-msr_refund_code     "1633208
      cv_msr_approv_block = vbap-msr_approv_block ). "1633208

  if vbak-msr_id is initial.
    vbak-msr_id = gs_msr_sales_item-msr_id.
  endif.

endform.                    " MSR_READ_ITEM

*&---------------------------------------------------------------------*
*&      Form  MSR_SET_ICONS
*&---------------------------------------------------------------------*
form msr_set_icons.

  data:
    lv_text             type string,
    lv_icon             type string.

  data:  lt_dd07v_atp   type table of dd07v,
         lt_dd07v_n     type table of dd07v.

  field-symbols: <ls_dd07v_a>     type dd07v.


* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.
* Set icon for next plant
  if gs_msr_sales_item-multiple_plants is initial.
    lv_icon = 'ICON_ENTER_MORE'.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_text = text-p01.
      when chara.
        lv_text = text-p03.
    endcase.
  else.
    lv_icon = 'ICON_DISPLAY_MORE'.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_text = text-p02.
      when chara.
        lv_text = text-p03.
    endcase.
  endif.
* Create icon for next plant
  if gv_iconname_nplant ne lv_icon or
     gv_iconname_nplant eq space.
    gv_iconname_nplant = lv_icon.
    call function 'ICON_CREATE'
      exporting
        name                  = lv_icon
        text                  = space
        info                  = lv_text
      importing
        result                = gv_next_plants_icon
      exceptions
        icon_not_found        = 01
        outputfield_too_short = 02
        others                = 99.
    if sy-subrc <> 0.
      move space to gv_next_plants_icon.
    endif.
  endif.
* Set icon for vendor address
  if gs_msr_sales_item-vendor_diff_adr is initial.
    lv_icon = 'ICON_ENTER_MORE'.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_text = text-v01.
      when chara.
        lv_text = text-v03.
    endcase.
  else.
    lv_icon = 'ICON_DISPLAY_MORE'.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_text = text-v02.
      when chara.
        lv_text = text-v03.
    endcase.
  endif.
* Create icon for vendor address
  if gv_iconname_vendor ne lv_icon or
     gv_iconname_vendor eq space.
    gv_iconname_vendor = lv_icon.
    call function 'ICON_CREATE'
      exporting
        name                  = lv_icon
        text                  = space
        info                  = lv_text
      importing
        result                = gv_vendor_address_icon
      exceptions
        icon_not_found        = 01
        outputfield_too_short = 02
        others                = 99.
    if sy-subrc ne 0.
      move space to gv_vendor_address_icon.
    endif.
  endif.
* Set icon for inspection text maintenance
  if gs_msr_sales_item-insp_short_text is initial and
     gs_msr_sales_item-display_only is initial.
    lv_icon = 'ICON_CREATE_TEXT'.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_text = text-in1.
      when chara.
        lv_text = text-in3.
    endcase.
  else.
*   Set tooltip
    case t180-trtyp.
      when charh or charv.
        lv_icon = 'ICON_CHANGE_TEXT'.
        lv_text = text-in2.
      when chara.
        lv_icon = 'ICON_DISPLAY_TEXT'.
        lv_text = text-in3.
    endcase.
  endif.
* Create icon for inspection text maintenance
  if gv_iconname_insp ne lv_icon or
     gv_iconname_insp eq space.
    gv_iconname_insp = lv_icon.
    call function 'ICON_CREATE'
      exporting
        name                  = lv_icon
        text                  = space
        info                  = lv_text
      importing
        result                = gv_inspection_text_icon
      exceptions
        icon_not_found        = 01
        outputfield_too_short = 02
        others                = 99.
    if sy-subrc ne 0.
      move space to gv_inspection_text_icon.
    endif.
  endif.

* Set icon for customer inspection comment
  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) is not initial.
    if gs_msr_sales_item-cust_insp_comm is initial and
       gs_msr_sales_item-display_only is initial.
      lv_icon = 'ICON_CREATE_TEXT'.
*     Set tooltip
      case t180-trtyp.
        when charh or charv.
          lv_text = text-in1.
        when chara.
          lv_text = text-in3.
      endcase.
    else.
*     Set tooltip
      case t180-trtyp.
        when charh or charv.
          lv_icon = 'ICON_CHANGE_TEXT'.
          lv_text = text-in2.
        when chara.
          lv_icon = 'ICON_DISPLAY_TEXT'.
          lv_text = text-in3.
      endcase.
    endif.

* Create icon for inspection text maintenance
    if gv_iconname_custinsp ne lv_icon or
       gv_iconname_custinsp eq space.
      gv_iconname_custinsp = lv_icon.
      call function 'ICON_CREATE'
        exporting
          name                  = lv_icon
          text                  = space
          info                  = lv_text
        importing
          result                = pb_cust_insp_text_icon
        exceptions
          icon_not_found        = 01
          outputfield_too_short = 02
          others                = 99.
      if sy-subrc ne 0.
        move space to pb_cust_insp_text_icon.
      endif.
    endif.

* Replacement Material: ATP Overview Button
    call function 'ICON_CREATE'
      exporting
        name                  = 'ICON_AVAILABILITY_DISPLAY'
        text                  = space
        info                  = text-140
      importing
        result                = pb_atp_overview
      exceptions
        icon_not_found        = 01
        outputfield_too_short = 02
        others                = 99.

* Replacement Material: ATP Check Button
    call function 'ICON_CREATE'
      exporting
        name                  = 'ICON_AVAILABILITY_CHECK'
        text                  = space
        info                  = text-141
      importing
        result                = pb_atp_check
      exceptions
        icon_not_found        = 01
        outputfield_too_short = 02
        others                = 99.

  endif.

endform.                    " MSR_SET_ICONS


*&---------------------------------------------------------------------*
*&      Form  MSR_FCODE
*&---------------------------------------------------------------------*
form msr_fcode.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.

  case fcode.
*   Next plant pop-up
    when fcode_msr_next_plants.
      gr_msr_sales->maintain_next_plants(
        exporting
          is_vbap           = vbap
          is_vbak           = vbak
          iv_ta_type        = t180-trtyp
          is_tvak           = tvak
        changing
          cs_msr_sales_item = gs_msr_sales_item ).
      fcode = fcode_gleiche_seite.
*   Vendor different address pop-up
    when fcode_msr_vendor_adrs.
      gr_msr_sales->maintain_vendor_address(
        exporting
          is_vbap           = vbap
          is_vbak           = vbak
          iv_ta_type        = t180-trtyp
          is_tvak           = tvak
        changing
          cs_msr_sales_item = gs_msr_sales_item ).
      fcode = fcode_gleiche_seite.
*   Inspection comment editor pop-up
    when fcode_msr_insp_text.
      gr_msr_sales->maintain_inspection_text(
        exporting
          is_vbap    = vbap
          is_vbak    = vbak
          iv_ta_type = t180-trtyp
          is_tvak    = tvak
        changing
          cs_msr_sales_item = gs_msr_sales_item ).

      fcode = fcode_gleiche_seite.

    when fcode_msr_cust_insp_comm.
      gr_msr_sales->maintain_inspection_text(
        exporting
          is_vbap      = vbap
          is_vbak      = vbak
          iv_ta_type   = t180-trtyp
          is_tvak      = tvak
          iv_cust_insp = abap_true
        changing
          cs_msr_sales_item = gs_msr_sales_item ).

      fcode = fcode_gleiche_seite.
*   Not allowed to call tracking screen for a new item in change mode
    when fcode_msr_tracking_item.
      if t180-trtyp eq if_msr_trc_c=>gc_ta_type_change and
         ( vbapd-updkz eq if_msr_trc_c=>gc_update_flag_insert or
           fcode eq fcode_new_item ).
        fcode = fcode_gleiche_seite.
      endif.

* Replacement Material
    when fcode_msr_atp_overview.

      call method cl_msr_lfe_helper=>show_atp_overview
        exporting
          iv_matnr = gs_msr_sales_item-replace_matnr
          iv_werks = gs_msr_sales_item-paying_plant.

      fcode = fcode_gleiche_seite.

* Replacement Material
    when fcode_msr_atp_check.

      perform msr_process_item.
      fcode = fcode_gleiche_seite.

    when 'PMSR'. " set item selection of subscreen "Returns Control" for usage
      " of button "Return Details", if cursor is in empty row in table control
      perform xvbap_markieren(sapfv45p).

  endcase.

endform.                    " MSR_FCODE

*&---------------------------------------------------------------------*
*&      Form  MSR_GET_NEXT_DOC_NO
*&---------------------------------------------------------------------*
form msr_get_next_doc_no.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.

  if not vbak-vbeln is initial.
    return.
  endif.
* Get next document number
  gr_msr_sales->get_next_doc_no(
    exporting
      iv_numki = tvak-numki
    importing
      ev_vbeln = vbak-vbeln ).
* Update globals
  perform vbeln_uebernehmen in program sapmv45a.

endform.                    " MSR_GET_NEXT_DOC_NO

*&---------------------------------------------------------------------*
*&      Form  MSR_DISPLAY_TRACKING_ITEM
*&---------------------------------------------------------------------*
form msr_display_tracking_item.

  data:
    lv_vbeln            type vbeln_va,
    lv_posnr            type posnr_va.

  field-symbols:
    <ls_xvbap>          type vbapvb.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.
  if vbak-vbtyp eq if_msr_trc_c=>gc_doc_cat_cmr.
    read table xvbap
      assigning <ls_xvbap>
      index item_detail_tabix.
    if sy-subrc = 0.
      lv_vbeln = <ls_xvbap>-vgbel.
      lv_posnr = <ls_xvbap>-vgpos.
    else.
*     internal error -> no tracking display possible
      message id 'CX_MSR_TRC' type 'E' number 086.
    endif.
  else.
    lv_vbeln = vbak-vbeln.
    read table xvbap assigning <ls_xvbap>
      index item_detail_tabix.
    if sy-subrc = 0.
      lv_posnr = <ls_xvbap>-posnr.
    else.
*     internal error -> no tracking display possible
      message id 'CX_MSR_TRC' type 'E' number 086.
    endif.
  endif.
  gr_msr_sales->display_tracking_details(
    iv_vbeln = lv_vbeln
    iv_posnr = lv_posnr ).

endform.                    "MSR_DISPLAY_TRACKING_ITEM

*&---------------------------------------------------------------------*
*&      Form  MSR_DISPLAY_TRACKING_ALL
*&---------------------------------------------------------------------*
form msr_display_tracking_all.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.
  gr_msr_sales->display_tracking_details( iv_vbeln = vbak-vbeln ).

endform.                    "MSR_DISPLAY_TRACKING_ALL

*&---------------------------------------------------------------------*
*&      Form  MSR_SET_ITEM_DEFAULTS
*&---------------------------------------------------------------------*
form  msr_set_item_defaults.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.
  gr_msr_sales->set_item_defaults(
    changing cs_item_defaults = gs_item_default ).

endform.                    "MSR_SET_ITEM_DEFAULTS


*&---------------------------------------------------------------------*
*&      Form  CONFIRM_RRC_CHANGE
*&---------------------------------------------------------------------*
form confirm_rrc_change.

  if gr_msr_sales is not bound.
    return.
  endif.
  gr_msr_sales->confirm_rrc_change(
    exporting
      is_msr_sales_item  = gs_msr_sales_item
      is_tvak            = tvak
      is_t180            = t180
      is_vbap            = vbap
    importing
      ev_msr_refund_code = vbap-msr_refund_code ).

endform.                    " CONFIRM_RRC_CHANGE


*&---------------------------------------------------------------------*
*&      Form  MSR_CHG_FCODE
*&---------------------------------------------------------------------*
form msr_chg_fcode.

* Only if sales class of Advanced Returns was instantiated
  if gr_msr_sales is not bound.
    return.
  endif.
* The user may click on the item overview screen via working
* on table control. If do so, change strange fcodes to 'Enter':
* Next plant pop-up, Vendor different address pop-up,
* Inspection comment editor pop-up
  if fcode eq fcode_msr_next_plants or
     fcode eq fcode_msr_vendor_adrs or
     fcode eq fcode_msr_insp_text.
    fcode = fcode_gleiche_seite.
  endif.

  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) is not initial.
    if fcode eq fcode_msr_cust_insp_comm.
      fcode = fcode_gleiche_seite.
    endif.
  endif.

endform.                    " MSR_CHG_FCODE

*&---------------------------------------------------------------------*
*&      Form  msr_process_item
*&---------------------------------------------------------------------*
form msr_process_item.

  data: ls_next_plants type msr_s_next_plant,
        lt_next_plants type msr_t_next_plants.
  data: ls_message type bapiret2,
        lt_messages type bapirettab.

  if gr_msr_sales is not bound.
    return.
  endif.

  if not gv_msr_fastchange is initial.
    if gs_msr_sales_fastchange-next_plant is not initial and
       gs_msr_sales_fastchange-next_plants is initial.
      ls_next_plants-counter       = '01'.
      ls_next_plants-next_plant    = gs_msr_sales_fastchange-next_plant.
      ls_next_plants-transshipment = gs_msr_sales_fastchange-transshipment.
      append ls_next_plants to lt_next_plants.
    else.
      lt_next_plants = gs_msr_sales_fastchange-next_plants.
    endif.
  endif.

  if not kopieren is initial and
    gs_msr_sales_item is initial.
    perform msr_read_item.
  else.
    if gv_msr_error is initial.
      gr_msr_sales->process_item(
        exporting
          is_vbak           = vbak
          is_xvbap          = xvbap
          it_next_plants    = lt_next_plants
          iv_split_id       = gv_msr_copy_split_id
          it_xvbpa          = xvbpa[]
        importing
          et_messages       = lt_messages
        changing
          cs_msr_sales_item = gs_msr_sales_item
          cs_vbap           = vbap ).
      loop at lt_messages into ls_message.
        ls_message-type = chari.
        message id ls_message-id type ls_message-type number ls_message-number
                with ls_message-message_v1 ls_message-message_v2
                     ls_message-message_v3 ls_message-message_v4.
        exit.
      endloop.
    else.
      if gv_msr_like_error is initial.
        gr_msr_sales->process_item(
          exporting
            is_vbak           = vbak
            is_xvbap          = xvbap
            it_next_plants    = lt_next_plants
            iv_split_id       = gv_msr_copy_split_id
            it_xvbpa          = xvbpa[]
          changing
            cs_msr_sales_item = gs_msr_sales_item
            cs_vbap           = vbap ).
      else.
        gr_msr_sales->process_item(
          exporting
            is_vbak           = vbak
            is_xvbap          = xvbap
            it_next_plants    = lt_next_plants
            iv_split_id       = gv_msr_copy_split_id
            it_xvbpa          = xvbpa[]
          importing
            et_messages       = lt_messages
          changing
            cs_msr_sales_item = gs_msr_sales_item
            cs_vbap           = vbap ).
        loop at lt_messages into ls_message.
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
          exit.
        endloop.
      endif.
    endif.
  endif.

endform.                    "msr_process_item