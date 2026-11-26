*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_MSR_PBO
*&---------------------------------------------------------------------*

form lord_msr_pbo.

  perform vbap_bearbeiten_vorbereiten in program sapfv45p.
  perform xvbep_lesen_erste(sapfv45e) using char_.
  perform vbep_bearbeiten_vorbereiten(sapfv45e).
  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
    msr_s_sales_item-replace_matnr = gs_msr_sales_item-replace_matnr.
    msr_s_sales_item-paying_plant = gs_msr_sales_item-paying_plant.
  endif.

endform.                    "lord_msr_pbo


*&---------------------------------------------------------------------*
*&      Form  lord_msr_pbo_ro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_msr_pbo_ro.

  data: ls_insp_codes type msr_s_insp_codes,
        lt_insp_codes type msr_t_insp_codes.

  clear gs_msr_sales_descr.

  if gr_msr_sales is initial.
    return.
  endif.

  if not gs_msr_sales_item-fu_code is initial.
    gs_msr_sales_descr-fu_code_t = cl_msr_def_db=>get_fu_code_text( gs_msr_sales_item-fu_code ).
  endif.

  if not vbap-msr_refund_code is initial.
    gs_msr_sales_descr-refund_code_t = gr_msr_sales->get_refund_code_text( iv_refund_code = vbap-msr_refund_code ).
  endif.

  if not gs_msr_sales_item-refund_control is initial.
    gs_msr_sales_descr-refund_control_t = gr_msr_sales->get_refund_control_text( iv_refund_control = gs_msr_sales_item-refund_control ).
  endif.

  if not vbap-msr_approv_block is initial.
    gs_msr_sales_descr-approv_block_t = gr_msr_sales->get_approv_block_text( iv_approv_block = vbap-msr_approv_block ).
  endif.

  if not vbap-msr_ret_reason is initial.
    gs_msr_sales_descr-returns_reason_t = gr_msr_sales->get_returns_reason_text( iv_returns_reason = vbap-msr_ret_reason ).
  endif.

  if not gs_msr_sales_item-inspection_code is initial.
    gr_msr_sales->get_insp_codes(
      exporting
        iv_language   = sy-langu
      importing
        et_insp_codes = lt_insp_codes ).
    sort lt_insp_codes by code.
    read table lt_insp_codes
         into ls_insp_codes
         with key code = gs_msr_sales_item-inspection_code
         binary search.
    if sy-subrc = 0.
      gs_msr_sales_descr-inspection_code_t = ls_insp_codes-kurztext.
    endif.
  endif.

  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) eq abap_true.
    if not gs_msr_sales_item-nfu_code is initial.
      gs_msr_sales_descr-nfu_code_t = cl_msr_def_db=>get_fu_code_text( gs_msr_sales_item-nfu_code ).
    endif.
  endif.

endform.                    "lord_msr_pbo_ro


*&---------------------------------------------------------------------*
*&      Form  lord_msr_check_available
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_AVAILABLE  text
*----------------------------------------------------------------------*
form lord_msr_check_available using uf_available type flag.

  clear uf_available.

  if gr_msr_sales is not initial.
    uf_available = charx.
  endif.

endform.                    "lord_msr_check_available


*&---------------------------------------------------------------------*
*&      Form  msr_get_insp_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TEXT        text
*      -->UV_INPUT_MODE  text
*----------------------------------------------------------------------*
form msr_get_insp_text using uv_text type string
                             uv_display_mode type char1
                             uf_extern type flag.

  data: lv_text type string,
        lt_text type tfpfields,
        ls_text like line of lt_text.
  data: lv_display_mode type flag,
        lv_change_mode type flag.

  field-symbols:
        <ls_comment> type msr_s_insp_comment,
        <ls_comment_cust> type msr_s_insp_comment_cust.

  clear: uv_text.

  if gr_msr_sales is not bound.
    return.
  endif.

  clear ls_text.
  if uf_extern is initial.
    read table cl_msr_insp=>gr_msr_insp->mt_comments
         assigning <ls_comment>
         with key vbeln = vbap-vbeln
                  posnr = vbap-posnr.
    if sy-subrc = 0.
      lt_text = <ls_comment>-table_content.
      ls_text = gs_msr_sales_item-insp_short_text.
    endif.
  else.
    read table cl_msr_insp=>gr_msr_insp->mt_comments_cust
         assigning <ls_comment_cust>
         with key sd_vbeln = vbap-vbeln
                  sd_posnr = vbap-posnr.
    if sy-subrc = 0.
      lt_text = <ls_comment_cust>-table_content_cust.
      ls_text = gs_msr_sales_item-cust_insp_comm.
    endif.
  endif.

  if lt_text is initial.
    if not ls_text is initial.
      append ls_text to lt_text.
      lv_text = ls_text.
    endif.
  else.
    modify lt_text from ls_text index 1.
    loop at lt_text into ls_text.
      if lv_text is not initial.
        concatenate lv_text cl_abap_char_utilities=>newline into lv_text.
      endif.
      concatenate lv_text ls_text into lv_text.
    endloop.
  endif.

  if ( t180-trtyp eq charv and
       tvak-vbtyp = if_msr_trc_c=>gc_doc_cat_cmr ) or
     t180-trtyp eq chara or
     gs_msr_sales_item-display_only = abap_true.
    lv_change_mode = abap_false.
    cl_msr_insp=>gr_msr_insp->get_change_mode_status( importing ev_change_mode = lv_change_mode ).
  else.
    lv_change_mode = abap_true.
  endif.

  if not lv_change_mode is initial.
    lv_display_mode = space.
  else.
    lv_display_mode = charx.
  endif.

  uv_text = lv_text.
  uv_display_mode = lv_display_mode.

endform.                    "msr_get_insp_text


*&---------------------------------------------------------------------*
*&      Form  msr_get_next_plants
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UT_NEXT_PLANT  text
*----------------------------------------------------------------------*
form msr_get_next_plants using ut_next_plant type msr_t_next_plant_get
                               uv_display type flag.

  if gr_msr_sales is not bound.
    return.
  endif.

  gr_msr_sales->maintain_next_plants(
    exporting
      is_vbap           = vbap
      is_vbak           = vbak
      iv_ta_type        = t180-trtyp
      is_tvak           = tvak
      iv_no_dialog      = charx
    importing
      et_next_plant_get = ut_next_plant
      ev_display_only   = uv_display
    changing
      cs_msr_sales_item = gs_msr_sales_item ).

endform.                    "msr_get_next_plants