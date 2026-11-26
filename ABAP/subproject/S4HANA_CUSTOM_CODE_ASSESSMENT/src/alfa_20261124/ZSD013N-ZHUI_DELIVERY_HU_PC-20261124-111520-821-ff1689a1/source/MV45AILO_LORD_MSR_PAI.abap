*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_MSR_PAI
*&---------------------------------------------------------------------*


form get_values_insp_code using ut_helpvalue type shsvaltab.

  data: lt_helpvalue type shsvaltab,
        ls_helpvalue type shsvalstr.
  data: ls_insp_codes type msr_s_insp_codes,
        lt_insp_codes type msr_t_insp_codes.

  clear ut_helpvalue.

  if gr_msr_sales is not bound.
    return.
  endif.

  gr_msr_sales->get_insp_codes(
    exporting
      iv_language   = sy-langu
    importing
      et_insp_codes = lt_insp_codes ).

  loop at lt_insp_codes into ls_insp_codes.
    clear ls_helpvalue.
    ls_helpvalue-key = ls_insp_codes-code.
    ls_helpvalue-value = ls_insp_codes-kurztext.
    if ls_helpvalue-value is initial.
      ls_helpvalue-value = ls_helpvalue-key.
    endif.
    collect ls_helpvalue into lt_helpvalue.
  endloop.

  ut_helpvalue = lt_helpvalue.

endform.                    "get_values_insp_code



*&---------------------------------------------------------------------*
*&      Form  set_replace_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_replace_matnr.

  gs_msr_sales_item-replace_matnr = msr_s_sales_item-replace_matnr.
  gs_msr_sales_item-paying_plant = msr_s_sales_item-paying_plant.


endform.                    "set_replace_matnr



*&---------------------------------------------------------------------*
*&      Form  msr_set_insp_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TEXT    text
*----------------------------------------------------------------------*
form msr_set_insp_text using uv_text type string
                             uf_extern type flag.

  data: lv_cust_insp type flag.
  data: lv_text type tdline,
        lt_text type tfpfields,
        lv_string type string,
        lt_string type standard table of string.

  if gr_msr_sales is not bound.
    return.
  endif.

  lv_string = uv_text.
  split lv_string
        at cl_abap_char_utilities=>newline
        into table lt_string.
  clear lv_string.
  loop at lt_string into lv_string.
    do.
      lv_text = lv_string.
      append lv_text to lt_text.
      shift lv_string by 132 places.
      if lv_string is initial.
        exit.
      endif.
    enddo.
  endloop.

  if not uf_extern is initial.
    lv_cust_insp = charx.
  endif.

  gr_msr_sales->maintain_inspection_text(
    exporting
      is_vbap      = vbap
      is_vbak      = vbak
      iv_ta_type   = t180-trtyp
      is_tvak      = tvak
      iv_nodialog  = charx
      it_text      = lt_text
      iv_cust_insp = lv_cust_insp
    changing
      cs_msr_sales_item = gs_msr_sales_item ).

endform.                    "msr_set_insp_text



*&---------------------------------------------------------------------*
*&      Form  msr_set_next_plants
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UT_NEXT_PLANT  text
*----------------------------------------------------------------------*
form msr_set_next_plants using ut_next_plant type msr_t_next_plant_set.

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
      it_next_plant_set = ut_next_plant
    changing
      cs_msr_sales_item = gs_msr_sales_item ).

  r185d-dataloss = charx.

endform.                    "msr_set_next_plants