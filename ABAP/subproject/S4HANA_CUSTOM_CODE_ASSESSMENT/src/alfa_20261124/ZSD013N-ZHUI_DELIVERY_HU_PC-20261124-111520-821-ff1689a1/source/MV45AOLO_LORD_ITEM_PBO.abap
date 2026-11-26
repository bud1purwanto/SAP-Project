*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_ITEM_PBO
*&---------------------------------------------------------------------*

form svbap_aufbauen.

  refresh svbap.
  loop at ivbap.
    clear svbap.
    svbap-tabix = ivbap-tabix.
    append svbap.
  endloop.

endform.                    "svbap_aufbauen


*&---------------------------------------------------------------------*
*&      Form  lord_item_pbo_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*----------------------------------------------------------------------*
form lord_item_pbo_single using uv_tabix.

  data:ls_svbap like line of svbap,
       ls_svbep like line of svbep,
       lv_lines_ivbap type sy-tabix,
       lv_lines_svbap type sy-tabix,
       lv_lines_svbep type sy-tabix,
       lv_lines type sy-tabix.

  ivbap_tabix_aktuell = uv_tabix.
  describe table ivbap[] lines lv_lines_ivbap.
  describe table svbap[] lines lv_lines_svbap.
  describe table svbep[] lines lv_lines_svbep.

  while lv_lines_svbep < uv_tabix.
    lv_lines_svbep = lv_lines_svbep + 1.
    ls_svbep-tabix = 1.
    append ls_svbep to svbep.
  endwhile.
  while lv_lines_svbep > uv_tabix.
    delete svbep index lv_lines_svbep.
    lv_lines_svbep = lv_lines_svbep - 1.
  endwhile.
  delete svbep index lv_lines_svbep.

  clear rv45a-vbap_selkz.
  perform xvbap_lesen(sapfv45p) using char1.
  if uv_tabix <= lv_lines_svbap.
    lv_lines_svbap = lv_lines_svbap + 1.
    delete svbap index lv_lines_svbap.
  endif.
  perform ivbsn_aufbauen_position(sapfv45l) using vbap-posnr.
  perform xvbsn_lesen(sapfv45l).
  perform xkomv_lesen_n46(sapfv45p).
* perform status_lesen.
  perform tprit_select using vbap-lprio
                             space
                             sy-subrc.
* rv45a-edatu = vbep-edatu.
  call function 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    exporting
      internal_date   = vbep-edatu
      internal_period = vbep-prgrs
    importing
      external_date   = rv45a-etdat
      external_period = rv45a-prgbz.

  if tvak-kopgr eq 'WK' or
     tvak-kopgr eq 'WK1'.
    perform xkomv_lesen in program sapfv45p.
    vbap-waerk = vbak-waerk.
  endif.

endform.                    "lord_item_pbo_single


*&---------------------------------------------------------------------*
*&      Form  lord_item_pbo_child
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*      -->UV_TABIX   text
*----------------------------------------------------------------------*
form lord_item_pbo_child using uv_posnr
                               uv_tabix.

  clear uv_tabix.
  perform xvbap_lesen_allgemein(sapfv45p) using uv_posnr
                                                space
                                       changing svbap-tabix.
  if svbap-tabix <> 0.
    vbap = xvbap.
    move-corresponding xvbap to vbapd.
    perform tvap_select(sapmv45a) using xvbap-pstyv
                                        space
                                        sy-subrc.
  endif.
  uv_tabix = svbap-tabix.

endform.                    "lord_item_pbo_child


*&---------------------------------------------------------------------*
*&      Form  lord_item_pbo_ro
*&---------------------------------------------------------------------*
form lord_item_pbo_ro.

  data: lv_subrc type sy-subrc.

  perform tvrot_select using vbap-route
                             space
                             sy-subrc.

  perform tvstt_select using vbap-vstel
                             space
                             sy-subrc.

  perform t001w_select using vbap-werks
                             space
                             sy-subrc.

  perform tvapt_select using vbap-pstyv
                             space
                             sy-subrc.

  perform tspat_select using vbap-spart
                             space
                             sy-subrc.

  perform tvzbt_select using vbkd-zterm
                             space
                             sy-subrc.

  perform t042z_select using vbkd-zlsch
                             rv45a-bukrsl
                             space
                             sy-subrc.

  perform tvfsp_select using vbap-faksp
                             space
                             sy-subrc.

  perform t189t_select using vbkd-pltyp
                             space
                             sy-subrc.

  perform t188t_select using vbkd-konda
                             space
                             sy-subrc.

  perform t151t_select using vbkd-kdgrp
                             space
                             sy-subrc.

  perform t171t_select using vbkd-bzirk
                             space
                             sy-subrc.

  perform t176t_select using vbkd-bsark
                             space
                             sy-subrc
                             t176t-vtext_k.

  perform t178t_select using vbap-kondm
                             space
                             sy-subrc.

  perform t173t_select using vbkd-vsart
                             space
                             sy-subrc.

  perform t001l_select using vbap-werks
                             vbap-lgort
                    changing sy-subrc.

  perform tvagt_select using vbap-abgru
                             space
                             sy-subrc.

  perform t023t_select using vbap-matkl
                             sy-subrc.

  if not tvta-afind is initial.
    perform wakt_select(sapfv45k) using vbkd-waktion
                                        sy-subrc.
  endif.

  perform get_kztlf_t.

  perform get_posar_t.

  perform get_last_confirmation in program sapfv45e
                                using gv_edatu_last
                                      gv_mbdat_last
                                      gv_bmeng_last.

  if cl_ops_switch_check=>sd_sfws_sc2( ) eq abap_true.
    perform fill_item_read_only
            in program saplsls_lord
            using vbak
                  vbap.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc3( ) eq abap_true.
    perform tvsut_select using vbap-sugrd.
    perform maepv_select(sapfv45p) using vbap-matnr
                                         vbap-werks
                                         vbap-berid
                                         vbap-lgort
                                         space
                                         space
                                         lv_subrc.
  endif.

  perform rv45a-vsmng_ausgeben in program sapfv45p.

endform.                    "lord_item_pbo_ro


*&---------------------------------------------------------------------*
*&      Form  get_posar_t
*&---------------------------------------------------------------------*
form get_posar_t.

  data:
    lv_domval type domvalue_l.

  lv_domval = vbap-posar.
  call function 'RV_DOMAIN_VALUE_TEXTS'
    exporting
      domname  = 'POSAR'
      domvalue = lv_domval
      single   = ' '
    importing
      ddtext   = gv_posar_t.

endform.                    "get_kztlf_t


*&---------------------------------------------------------------------*
*&      Form  get_kztlf_t
*&---------------------------------------------------------------------*
form get_kztlf_t.

  data: lv_domtxt type dd07v-ddtext,
        lv_domval type dd07v-domvalue_l.

  lv_domval = vbap-kztlf.

  call function 'RV_DOMAIN_VALUE_TEXTS'
    exporting
      domname  = 'KZTLF'
      domvalue = lv_domval
      single   = ' '
    importing
      ddtext   = lv_domtxt.

  rv45a-kztlf_t = lv_domtxt.

endform.                    "get_kztlf_t


*&---------------------------------------------------------------------*
*&      Form  lord_ivstat_pbo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_ivstat_pbo.

  data: ls_text type textpool,
        lt_text type table of textpool.

  field-symbols:
    <lv_data>   type data.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform xvbup_uebersicht_vorbereiten(sapfv45p).

  lt_text = cl_lord_services=>get_textpool( iv_program = 'SAPLSLS_LORD' iv_langu = sy-langu ).

  gv_besta = vbup-besta.
  clear gv_besta_t.
* partially confirmed
  if vbap-kwmeng > vbap-kbmeng and
     vbap-kbmeng > 0 and
     gv_besta eq 'A'.
    gv_besta = 'B'.
    read table lt_text into ls_text with key key = '004'.
    gv_besta_t = ls_text-entry.
  endif.
* later confirmed
  if vbap-kwmeng eq vbap-kbmeng and
     vbap-kbmeng > 0 and
     gv_besta eq 'A'.
    gv_besta = 'B'.
    read table lt_text into ls_text with key key = '005'.
    gv_besta_t = ls_text-entry.
  endif.

  if gv_besta_t is initial.
    case gv_besta.
      when space.
        read table lt_text into ls_text with key key = '008'.
        gv_besta_t = ls_text-entry.
      when 'A'.
        read table lt_text into ls_text with key key = '006'.
        gv_besta_t = ls_text-entry.
      when 'B'.
        read table lt_text into ls_text with key key = '005'.
        gv_besta_t = ls_text-entry.
      when 'C'.
        read table lt_text into ls_text with key key = '007'.
        gv_besta_t = ls_text-entry.
    endcase.
  endif.

* Fill empty overall status text
  if vbstt-gbsta_bez is initial.
    read table lt_text into ls_text with key key = '010'.
    vbstt-gbsta_bez = ls_text-entry.
  endif.

* Fill all remaining empty texts with fallback text
  read table lt_text into ls_text with key key = '009'.
  do.
    assign component sy-index of structure vbstt to <lv_data>.
    if not sy-subrc is initial.
*     Reached last component
      exit.
    endif.
    if <lv_data> is initial.
*     Text is empty
      <lv_data> = ls_text-entry.
    endif.
  enddo.

endform.                    "lord_ivstat_pbo


*&---------------------------------------------------------------------*
*&      Form  lord_pstyv_multi_pbo
*&---------------------------------------------------------------------*
*       Check that item category is ready for change
*       for all relevant items
*----------------------------------------------------------------------*
form lord_pstyv_multi_pbo changing cv_display type sysubrc.

  data:
    ls_vbap  type vbap,
    ls_vbapd type vbapd,
    ls_xvbap type vbapvb.

* Init changing parameter
  clear cv_display.

* Get current item values
  ls_vbap  = vbap.
  ls_vbapd = vbapd.
  ls_xvbap = xvbap.

* Check all relevant items until we detect the first one where the
* item category cannot be changed anymore
  loop at xvbap
       where updkz ne updkz_delete
         and pvpos is initial
         and uepvw ne 'A'.
*   Set index and prepare item
    svbap-tabix = sy-tabix.
    perform vbap_bearbeiten_vorbereiten
            in program sapfv45p.
*   Check item category is changeable
    call function 'SD_FIELD_INPUT_CHECK'
      exporting
        tabname        = 'VBAP'
        fieldname      = 'PSTYV'
      importing
        display_status = cv_display.
    if not cv_display is initial.
*     This item's item category is read-only, skip the rest
      exit.
    endif.
  endloop.

* Reset previous item values
  vbap  = ls_vbap.
  vbapd = ls_vbapd.
  xvbap = ls_xvbap.

endform.                    "lord_pstyv_multi_pbo

*&---------------------------------------------------------------------*
*&      Form  lord_ivstat_pbo_cum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_ivstat_pbo_cum changing cs_lord_vbup_cum   like gs_lord_vbup_cum
                                  cs_lord_vbup_cum_bez like gs_lord_vbup_cum_bez.

  data: lt_text type table of textpool,
        ls_text type textpool.

  data: lt_vbfa  type vbfa_t,
        ls_vbfa  type vbfa,
        ls_vbup type vbup,
        ls_tvbst type tvbst,
        lv_wbsta type wbsta,
        lv_fksta type fksta.

  clear gs_lord_vbup_cum.
  clear gs_lord_vbup_cum_bez.

  if cs_lord_vbup_cum is initial or
     cs_lord_vbup_cum_bez is initial.

    clear cs_lord_vbup_cum.
    clear cs_lord_vbup_cum_bez.

*   fill necessary information
    cs_lord_vbup_cum-vbeln = cs_lord_vbup_cum_bez-vbeln = vbak-vbeln.
    cs_lord_vbup_cum-posnr = cs_lord_vbup_cum_bez-posnr = xvbap-posnr.

    lt_vbfa = xvbfa[].

*   for delivery relevance determine WBSTA
    if not vbup-lfsta is initial and
       not vbak-vbtyp eq 'W'.

*     read necessary texts
      lt_text = cl_lord_services=>get_textpool( iv_program = 'SAPLV75S' iv_langu = sy-langu ).

      loop at lt_vbfa into ls_vbfa where
                           vbelv   = vbak-vbeln  and
                           posnv   = xvbap-posnr and
                           vbtyp_v = vbak-vbtyp      .
        check ls_vbfa-vbtyp_n ca vbtyp_lief.
        clear ls_vbup.
        call function 'SD_VBUP_SINGLE_READ'
          exporting
            i_vbeln = ls_vbfa-vbeln
            i_posnr = ls_vbfa-posnn
          importing
            e_vbup  = ls_vbup
          exceptions
            others  = 1.
        if sy-subrc = 0.
          perform gi_fk_status in program saplv75s using ls_vbup-wbsta ls_vbup-fksta
                                 changing lv_wbsta
                                          lv_fksta.
        endif.
      endloop.
      move lv_wbsta to cs_lord_vbup_cum-wbsta.
      case cs_lord_vbup_cum-wbsta.
        when chara.
          read table lt_text into ls_text with key key = 'S48'.
        when charb.
          read table lt_text into ls_text with key key = 'S49'.
        when charc.
          read table lt_text into ls_text with key key = 'S50'.
        when space.
          ls_text-entry = vbstt-wbsta_bez.
      endcase.
      cs_lord_vbup_cum_bez-wbsta_bez = ls_text-entry.
    else.
*     if not delivery-relevant take xvbup values
      cs_lord_vbup_cum-wbsta = xvbup-wbsta.
      cs_lord_vbup_cum_bez-wbsta_bez = vbstt-wbsta_bez.
    endif.

    if xvbap-fkrel ne space and
       vbup-fksaa  is initial.
      move lv_fksta to cs_lord_vbup_cum-fksta.
    endif.
    if not cs_lord_vbup_cum-fksta is initial.
      ls_tvbst-tbnam = 'VBUP'.
      ls_tvbst-fdnam = 'FKSTA'.
      ls_tvbst-spras = sy-langu.
      ls_tvbst-statu = cs_lord_vbup_cum-fksta.
      call function 'RV_DOCUMENT_STATUS_TEXTS'
        exporting
          tvbst_wa = ls_tvbst
        importing
          text     = cs_lord_vbup_cum_bez-fksta_bez.
    else.
      cs_lord_vbup_cum_bez-fksta_bez = vbstt-fksta_bez.
    endif.
  endif.

  gs_lord_vbup_cum = cs_lord_vbup_cum.
  gs_lord_vbup_cum_bez = cs_lord_vbup_cum_bez.

endform.                    "lord_ivstat_pbo_cum


*&---------------------------------------------------------------------*
*&      Form  lord_item_check_available
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UF_AVAILABLE  text
*----------------------------------------------------------------------*
form lord_item_check_available using uf_available type flag.

  uf_available = charx.

* if VBTYP maintained for AUART equals "group contract",
* items are not available
  if cl_lord=>gv_vbtyp eq '0'. " 0 = group contract
    clear: uf_available.
  endif.

endform.                    "lord_item_check_available


*&---------------------------------------------------------------------*
*&      Form  get_item_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_NAME    text
*      -->UR_DATA    text
*----------------------------------------------------------------------*
form get_item_data using uv_name ur_data.

  field-symbols:
        <lr_data> type any.

  assign (uv_name) to <lr_data>.
  if sy-subrc = 0.
    ur_data = <lr_data>.
  endif.

endform.                    "get_item_data