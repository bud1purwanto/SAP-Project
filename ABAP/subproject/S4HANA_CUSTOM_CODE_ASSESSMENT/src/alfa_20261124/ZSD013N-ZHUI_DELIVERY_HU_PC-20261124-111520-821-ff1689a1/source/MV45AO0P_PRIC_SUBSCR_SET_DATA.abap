*----------------------------------------------------------------------*
***INCLUDE MV45AO0P_PRIC_SUBSCR_SET_DATA .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PRICING_SUBSCREEN_SET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module pricing_subscreen_set_data output.

  data: da_ctrl_grey type xfeld.        "suppress output
  data: lv_no_changes type xfeld.

* Nur im Positionsfall auf Textposition pruefen
  clear da_ctrl_grey.         "seems to be a global(!) field here
  if pricing_header is initial.
    if vbap-posar = charb.
      da_ctrl_grey = 'X'.
    endif.
  endif.

* Payment Service Provider
  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
    if t180-trtyp eq charv and
     vbak-sppaym eq cv_sppaym01 and
     gr_paysp is bound.
      if pricing_header is initial.
        call method gr_paysp->get_change_mode_group
          exporting
          iv_group_id     = cl_sls_paysp_integration=>cv_group_id_cond
            iv_trtyp      = t180-trtyp
            is_vbak       = vbak
            is_vbap       = vbap
            is_vbkd       = vbkd
            is_tvak       = tvak
            is_tvap       = tvap
          importing
            ev_no_changes = lv_no_changes.
      else.
        call method gr_paysp->get_change_mode_group
          exporting
          iv_group_id     = cl_sls_paysp_integration=>cv_group_id_cond
            iv_trtyp      = t180-trtyp
            is_vbak       = vbak
            is_vbkd       = vbkd
            is_tvak       = tvak
          importing
            ev_no_changes = lv_no_changes.
      endif.
      if lv_no_changes eq abap_true.
        display_mode = 'X'.
      endif.
    endif.
  endif.

ENHANCEMENT-SECTION     PRICING_SUBSCREEN_SET_DATA_10 SPOTS ES_SAPMV45A.
  call function 'PRICING_SUBSCREEN_SET_DATA'
    exporting
      comm_head_i  = tkomk
      comm_item_i  = tkomp
      trtyp_i      = t185f-trtyp
      display_only = display_mode
      ctrl_grey    = da_ctrl_grey
    tables
      tkomv        = xkomv
    exceptions
      error        = 1
      others       = 2.
END-ENHANCEMENT-SECTION.


  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endmodule.                 " PRICING_SUBSCREEN_SET_DATA  OUTPUT