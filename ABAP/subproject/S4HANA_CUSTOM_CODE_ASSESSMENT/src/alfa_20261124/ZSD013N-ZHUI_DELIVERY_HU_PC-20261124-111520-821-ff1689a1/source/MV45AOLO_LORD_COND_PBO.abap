*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_COND_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  lord_cond_head_pbo
*&---------------------------------------------------------------------*
form lord_cond_head_pbo.

  local: r185d-dataloss.

  perform xvbak_initialisieren(sapfv45k).
  perform vbak_bearbeiten_vorbereiten(sapfv45k).
  perform preisfindung_gesamt(sapmv45a) using chara.
* perform pricing_prepare_head(saplsls_lord).
  perform pricing_prepare_head.

endform.                    "lord_cond_head_pbo


*&---------------------------------------------------------------------*
*&      Form  lord_cond_item_pbo
*&---------------------------------------------------------------------*
form lord_cond_item_pbo.

  perform xvbak_initialisieren(sapfv45k).
* perform pricing_prepare_item(saplsls_lord).
  perform pricing_prepare_item.

endform.                    "lord_cond_item_pbo


*&---------------------------------------------------------------------*
*&      Form  pricing_prepare_head
*&---------------------------------------------------------------------*
form pricing_prepare_head.

  data: lf_ctrl_grey type xfeld,
        lf_display_mode type xfeld.

  local: vbak-knumv.

  if not cl_lord=>gv_vbeln_saved is initial and
     not cl_lord=>gf_no_init is initial.
    if xvbak_updkz eq chari.
      clear vbak-knumv.
    endif.
  endif.

  pricing_header = charx.

  perform preisfindung_vorbereiten(sapfv45p) using 'K'.

  if tkomk-trtyp na 'BHV'.
    lf_display_mode = 'X'.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true and
     t180-trtyp eq charv and
     vbak-sppaym eq cv_sppaym01 and
     gr_paysp is bound.
    call method gr_paysp->get_change_mode_group
      exporting
        iv_group_id   = cl_sls_paysp_integration=>cv_group_id_cond
        iv_trtyp      = t180-trtyp
        is_vbak       = vbak
        is_vbkd       = vbkd
        is_tvak       = tvak
      importing
        ev_no_changes = lf_display_mode.
  endif.

  call function 'PRICING_SUBSCREEN_SET_DATA'
    exporting
      comm_head_i  = tkomk
      comm_item_i  = tkomp
      trtyp_i      = t180-trtyp
      display_only = lf_display_mode
      ctrl_grey    = lf_ctrl_grey
    tables
      tkomv        = xkomv
    exceptions
      error        = 1
      others       = 2.

endform.                    " pricing_prepare_head


*&---------------------------------------------------------------------*
*&      Form  pricing_prepare_item
*&---------------------------------------------------------------------*
form pricing_prepare_item.

  data: lf_ctrl_grey type xfeld,
        lf_display_mode type xfeld.

  local: vbak-knumv.

  if not cl_lord=>gv_vbeln_saved is initial and
     not cl_lord=>gf_no_init is initial.
    if xvbak_updkz eq chari.
      clear vbak-knumv.
    endif.
  endif.

  clear pricing_header.

  if svbap-tabix > 0.
    read table xvbap index svbap-tabix.
  endif.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  if vbap-posar ne charb.
    perform preisfindung_vorbereiten(sapfv45p) using 'P'.
    if tkomp-kaend_typ(1) = '*'.
      lf_display_mode = 'X'.
    endif.
    if vbak-vbklt = vbklt_rech_korr.
      if ( vbak-vbtyp = vbtyp_ganf and vbap-shkzg = charx  and
           not vbap-vgpos is initial                           ) or
         ( vbak-vbtyp = vbtyp_lanf and vbap-shkzg = charx  and
           not vbap-vgpos is initial                           ).
        lf_display_mode = 'X'.
      endif.
    endif.
  endif.

  if vbap-posar = charb.
    lf_ctrl_grey = 'X'.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true and
     t180-trtyp eq charv and
     vbak-sppaym eq cv_sppaym01 and
     gr_paysp is bound.
    call method gr_paysp->get_change_mode_group
      exporting
        iv_group_id   = cl_sls_paysp_integration=>cv_group_id_cond
        iv_trtyp      = t180-trtyp
        is_vbak       = vbak
        is_vbap       = vbap
        is_vbkd       = vbkd
        is_tvak       = tvak
        is_tvap       = tvap
      importing
        ev_no_changes = lf_display_mode.
  endif.

  call function 'PRICING_SUBSCREEN_SET_DATA'
    exporting
      comm_head_i  = tkomk
      comm_item_i  = tkomp
      trtyp_i      = t180-trtyp
      display_only = lf_display_mode
      ctrl_grey    = lf_ctrl_grey
    tables
      tkomv        = xkomv
    exceptions
      error        = 1
      others       = 2.

endform.                    " pricing_prepare_item


*&---------------------------------------------------------------------*
*&      Form  pricing_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form pricing_get_data.

  if pricing_header is initial.
    check vbap-posar ne charb.
  endif.

  call function 'PRICING_SUBSCREEN_GET_DATA'
    importing
      comm_head_e      = tkomk
      comm_item_e      = tkomp
      calculation_type = global_pricing_type
    tables
      tkomv            = xkomv
      tkomp            = tkomp
    exceptions
      error            = 1
      others           = 2.

  t185f-trtyp = t180-trtyp.

  if not pricing_header is initial.
    perform preisfindung_nachbereiten_kopf(sapfv45p).
  else.
    perform preisfindung_nachbereiten_pos(sapfv45p) using t185f
                                                          t185
                                                          t185v.
  endif.

endform.                    " pricing_get_data