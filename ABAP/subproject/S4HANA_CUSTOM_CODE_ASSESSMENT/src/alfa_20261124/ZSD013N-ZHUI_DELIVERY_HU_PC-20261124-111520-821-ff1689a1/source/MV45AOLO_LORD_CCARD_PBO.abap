*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_CCARD_PBO
*&---------------------------------------------------------------------*

form lord_ccard_pbo_multi.

  local: tvak-fpart.
  include fv45ploc.

  data: da_vbap_tabix like svbap-tabix,
        ls_tvcaa type tvcaa.


  check not ( vbak-rplnr is initial and t180-trtyp eq chara ).

  call function 'SD_CCARD_TVCAA_SELECT'
    exporting
      i_tvak  = tvak
    importing
      e_tvcaa = ls_tvcaa.

*  credit_check_ccard_simul_mode = charx.    " lgko runs in simul. mode
*  perform fcode_lgko.
*  credit_check_ccard_simul_mode = space.
*
*  perform preisfindung_gesamt using chara.

  clear fplaa.
  move-corresponding vbak to fplaa.
  move-corresponding vbak to kompax.
  move vbak-waerk         to fplaa-waerk.
  move kurgv-kunnr        to fplaa-kunrg.
  move tvak-ccpgr         to fplaa-ccpga.

  clear fplaa-mwsbk.
  loop at xvbap where kowrr is initial
                  and updkz ne updkz_delete.
    add xvbap-mwsbp to fplaa-mwsbk.
  endloop.

  perform xvbuk_lesen(sapfv45k) using vbak-vbeln.

  if not svbuk_subrc is initial.
    perform xvbuk_uebersicht_vorbereiten(sapfv45k).
  endif.

  read table xfpla
       with key fplnr = vbak-rplnr
       binary search.
  if sy-subrc ne 0.
    clear xfpla.
  endif.

  if t180-trtyp ne chara.
*    perform credit_redo_availability.
  endif.
  perform offene_werte_ermitteln tables open_values
                                 using charx da_vbap_tabix.
  perform authorization_value_split tables open_values .

  if t180-trtyp ne chara.
    call function 'SD_CCARD_GET_OPEN_DELIVERIES'
      exporting
        i_vbak_vbeln = vbak-vbeln
      tables
        i_s132       = open_values
        fxvbap       = xvbap
        fxvbfa       = xvbfa.
    call function 'SD_CCARD_GET_OPEN_BILLINGS'
      exporting
        i_vbeln = vbak-vbeln
      tables
        i_s132  = open_values
        fxvbuk  = xvbuk
        fxvbfa  = xvbfa.
  endif.
  read table xfpla
       with key fplnr = vbak-rplnr
       binary search.
  if sy-subrc ne 0.
    clear xfpla.
  endif.

  call function 'SD_CCARD_SET_FACTOR'
    exporting
      i_source  = '1'          "Sales Order
      i_vbak    = vbak
      i_xfpla   = xfpla
    tables
      t_xfplt   = xfplt
      t_bezs132 = open_values.
  call function 'SD_CCARD_GET_NEXT_COST'
    exporting
      i_source  = '1'          "Sales Order
      i_vbtyp   = vbak-vbtyp
    importing
      e_bezs132 = open_values
      e_cost    = fplaa-leiwr
    tables
      t_bezs132 = open_values
    exceptions
      no_costs  = 4.
  if sy-subrc = 0.
    fplaa-cmngv = open_values-sptag.
    if fplaa-cmngv is initial.
      fplaa-cmngv = sy-datlo.
    endif.
  else.
    clear fplaa-leiwr.
    clear fplaa-cmngv.
  endif.

  move vbak-netwr to kompax-netwr.

  call function 'SD_CCARD_DATA_PUT'
    exporting
      iv_trtyp          = t180-trtyp
      iv_fplnr          = vbak-rplnr
      iv_waers          = vbak-waerk
      iv_fpart          = tvak-rpart
      is_fplaa          = fplaa
      if_upd_fpla       = upd_fpla
      if_upd_fplt       = upd_fplt
      is_kompax         = kompax
      it_xfpla          = xfpla[]
      it_yfpla          = yfpla[]
      it_xfplt          = xfplt[]
      it_yfplt          = yfplt[]
      if_called_by_lord = 'X'.

endform.                    "lord_ccard_pbo_multi


*&---------------------------------------------------------------------*
*&      Form  ccard_check_available
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UF_AVAILABLE  text
*----------------------------------------------------------------------*
form ccard_check_available using uf_available
                                 uf_message.

  uf_available = charx.

  do.
    if call_activity eq gc_activity_lord.
      if tvak-rpart is initial.
        if not uf_message is initial.
        endif.
        clear uf_available.
        exit.
      endif.
      if t180-trtyp eq chara and
         vbak-rplnr is initial.
        clear uf_available.
        exit.
      endif.
    endif.
    if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
      if vbak-sppaym eq cv_sppaym01.
        if not uf_message is initial.
          message i015(sls_paysp).
          message_collect_lord.
        endif.
        clear uf_available.
        exit.
      endif.
    endif.
    exit.
  enddo.

endform.                    "ccard_check_available


*&---------------------------------------------------------------------*
*&      Form  lord_ccard_pbo_multi_after
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_ccard_pbo_multi_after.

  refresh open_values.

endform.                    "lord_ccard_pbo_multi_after