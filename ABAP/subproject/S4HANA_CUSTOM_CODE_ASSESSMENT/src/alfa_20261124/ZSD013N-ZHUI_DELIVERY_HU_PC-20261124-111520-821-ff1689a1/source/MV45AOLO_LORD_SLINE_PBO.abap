*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_SLINE_PBO
*&---------------------------------------------------------------------*

form lord_sline_pbo_multi.

  ivbep_tabix_zeile_1 = 1.
  perform ivbep_aufbauen_position(sapfv45e) using vbap-posnr.
  perform xvbep_aufsetzen(sapfv45e).
  perform xvbsn_aufsetzen(sapfv45l).
  perform ivbsn_aufbauen_position(sapfv45l) using vbap-posnr.
  perform xvbsn_lesen(sapfv45l).
  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform svbep_aufbauen.

endform.                    "lord_sline_pbo_multi


*&---------------------------------------------------------------------*
*&      Form  lord_sline_pbo_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*----------------------------------------------------------------------*
form lord_sline_pbo_single using uv_tabix.

  data: lv_lines_svbep type sy-tabix.

  ivbep_tabix_aktuell = uv_tabix.

  clear vbepd-vsmng.
  perform xvbep_lesen(sapfv45e).
  if svbep-tabix <> 0.
    describe table svbep lines lv_lines_svbep.
    delete svbep index lv_lines_svbep.
  endif.

  call function 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    exporting
      internal_date   = vbep-edatu
      internal_period = vbep-prgrs
    importing
      external_date   = rv45a-etdat
      external_period = rv45a-prgbz.

endform.                    "lord_sline_pbo_single


*&---------------------------------------------------------------------*
*&      Form  lord_sline_pbo_single_ro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_sline_pbo_single_ro.

  if not vbep-aufnr is initial.
    perform t003p_select using t459k-auart
                               space
                               sy-subrc.
  else.
    clear t003p-txt.
  endif.

  if not vbep-bsart is initial.
    perform t161t_select using vbep-bsart
                               vbep-bstyp
                               space
                               sy-subrc.
  else.
    clear t161t-batxt.
  endif.

endform.                    "lord_sline_pbo_single_ro


*&---------------------------------------------------------------------*
*&      Form  lord_sline_input_mode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_sline_input_mode.

  perform feldauswahl_lord using 'SLINE'.

  if vbep-etenr = 0.
    if ( not vbap-abgru is initial ) or
       ( not vbap-grkor is initial and
         ivbep_tabix_aktuell > 1 ) or
       ( vbap-prosa ne space and
         vbapd-srcps  ne srcps_mainitem or
         vbapd-natrab ca natrab_min_qty or
         vbapd-natrab ca natrab_drein or
         vbap-uepvw   ca natrab_drein ) or
       ( ( vbak-autlf ne space or vbap-kztlf eq charc ) and
         ivbep_tabix_aktuell > 1 ).
      screen-input = 0.
    endif.
    if svbep-tabix = 0 and
       not vbap-grkor is initial.
      screen-input = 0.
    endif.
    if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
      if not gs_msr_sales_item-display_only is initial.
        screen-input = 0.
      endif.
    endif.
  endif.

endform.                    "lord_sline_input_mode


*&---------------------------------------------------------------------*
*&      Form  svbep_aufbauen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form svbep_aufbauen.

  refresh svbep.
  loop at ivbep.
    clear svbep.
    svbep-tabix = ivbep-tabix.
    append svbep.
  endloop.

endform.                    "svbep_aufbauen