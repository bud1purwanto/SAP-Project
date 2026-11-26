*&---------------------------------------------------------------------*
*&  Include           MV45AFFE_FELDAUSWAHL_LORD
*&---------------------------------------------------------------------*

form feldauswahl_lord using uv_object.

  data: loop(3) value 'LOO'.
  data: l_sd_sales_basic_exit type ref to if_ex_badi_sd_sales_basic,
        l_badi_sd_sales_basic type ref to badi_sd_sales_basic,
        active type xfeld,
        da_display_status like sy-subrc.
  data: lv_panel type panel.
  data: lv_no_new type flag,
        lv_sc1    type boole_d.

  gs_screen = screen.

* Get state of EHP2 SD-BF
  lv_sc1 = cl_ops_switch_check=>sd_sfws_sc1( ).

  if lv_sc1 eq abap_true.
*   EHP2-BF is on
    if tvak-kopgr eq 'LP' or
       tvak-kopgr eq 'WK' or
       tvak-kopgr eq 'WK1'.
      if uv_object eq 'ITEM'.
        if screen-name eq 'VBAP-SKOPF'.
          screen-active = 1.
          screen-group3 = '048'.
          gs_screen = screen.
        endif.
      endif.
    endif.
  endif.

  if screen-group2 eq loop.
    if uv_object ne 'ITEM' and
       uv_object ne 'SLINE'.
      screen = gs_screen.
      exit.
    endif.
    if rv45a-zeile_leer ne space and
       screen-group3 ne space.
      perform feldauswahl_leere_zeilen.
      gs_screen = screen.
    endif.
    if not rv45a-zeile_leer is initial.
      if lv_sc1 eq abap_true.
*       EHP2-BF is on
        perform get_input_mode_empty_line.
      endif.
      perform field_control_empty_line.
      clear lv_no_new.
      if uv_object eq 'ITEM'.
        perform item_no_new(sapfv45p) using lv_no_new.
      endif.
      if uv_object eq 'SLINE'.
        perform sline_no_new(sapfv45e) using lv_no_new.
      endif.
      if not lv_no_new is initial.
        gs_screen-input = 0.
      endif.
      screen = gs_screen.
      exit.
    endif.
  else.
*    if uv_object ne 'HEAD'.
*      screen = gs_screen.
*      exit.
*    endif.
  endif.

  if screen-group3 ne space.
    perform feldauswahl_sonderregeln.
  endif.

  perform feldauswahl_status using screen-name
                             changing da_display_status.

  perform fieldmodification_rev_reg.

  if gs_ops_switch_check-ops_sfws_sc_advret1 eq charx.
    if uv_object eq 'MSR'.
      lv_panel = t185v-panel.
      t185v-panel = 'PMSR'.
      perform feldauswahl_msr changing screen.
      t185v-panel = lv_panel.
    endif.
  endif.

  if lv_sc1 eq abap_true.
*   EHP2-BF is on
    if tvak-kopgr eq 'LP' or
       tvak-kopgr eq 'WK' or
       tvak-kopgr eq 'WK1'.
      if uv_object eq 'ITEM'.
        if screen-name eq 'RV45A-KWMENG' or
           screen-name eq 'VBAP-VRKME' or
           screen-name eq 'RV45A-ETDAT' or
           screen-name eq 'RV45A-PRGBZ'.
          screen-active = 0.
        endif.
      endif.
    endif.
  endif.

  call function 'GET_HANDLE_SD_SALES_BASIC'
    importing
      er_badi = l_badi_sd_sales_basic
      active  = active.

  if active = charx.
    if not l_badi_sd_sales_basic is initial.
      try.
          call badi l_badi_sd_sales_basic->maintain_screen
            exporting
              ft180    = t180
              fvbak    = vbak
              fvbap    = vbap
              fxvbup   = xvbup[]
              fxvbuk   = xvbuk[]
              fxvbap   = xvbap[]
              fxvbpa   = xvbpa[]
            changing
              f_screen = screen.
        catch cx_badi.
      endtry.
    endif.
  endif.

  call customer-function '004'
       exporting
            i_screen_name      = screen-name
            i_vbap             = vbap
            i_vbup             = xvbup
            i_screen_group4    = screen-group4
            i_t180_aktyp       = t180-aktyp
       changing
            c_screen_active    = screen-active
            c_screen_invisible = screen-invisible
            c_screen_input     = screen-input.

  perform userexit_field_modification.

  if lv_sc1 eq abap_true.
*   EHP2-BF is on
    if uv_object eq 'HEAD'.
      if t180-trtyp eq charh and
         ( screen-name eq 'VBAK-VKORG' or
           screen-name eq 'VBAK-VTWEG' or
           screen-name eq 'VBAK-SPART' ) and
         ( vbak-vkorg is initial or
           vbak-vtweg is initial or
           vbak-spart is initial ).
        screen-input = 1.
      endif.
      if screen-name eq 'KUAGV-KUNNR' and
         kuagv-kunnr is initial.
        screen-required = 1.
      endif.
    endif.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc2( ) eq abap_true.
*   As of ERP 6.03-BF, field EAN11
*   - is available
*   - is not always read-only in LORD environment
    if uv_object   eq 'ITEM'       and
       screen-name eq 'VBAP-EAN11'.
      screen-active     =
      screen-display_3d = 1.
*     Rules:
*     a) Read only, if 1) Display mode or 2) Item is rejected or 3) Item is deleted or 4) item
*        w/o material or 5) sub item
*     b) Ready for change, if a) does not apply and 1) Item is new or 2) there exists more than
*        one EAN/UPC for the given combination of material and unit
      if   t180-trtyp  eq chara         or
           xvbup-absta ca 'C'           or
           xvbup-updkz eq updkz_delete  or
           vbap-uepos  gt 0             or
         ( vbap-posnr  gt 0       and
           rv45a-mabnr is initial     ).
*       Set read-only
        screen-input = 0.
      else.
        if vbap-posnr                                               eq '000000'  or
           cl_lord_services=>is_multi_ean( iv_matnr = rv45a-mabnr
                                           iv_vrkme = vbap-vrkme  ) eq abap_true.
*         Set ready-for-change
          screen-input = 1.
        else.
*         Set read-only
          screen-input = 0.
        endif.
      endif.
    endif.
    if uv_object eq 'ITEM'.
      if screen-name eq 'VBAPD-POSGUID'.
        screen-active = 1.
        screen-input = 0.
        if t180-trtyp          ne chara                              and
           gv_lord_scenario_id eq cl_lord_co=>sc_scm_par_get_service and
           svbap-tabix         eq 0.
          screen-input = 1.
        endif.
      endif.
    endif.
  endif.

  modify screen.

endform.                    "feldauswahl_lord


*&---------------------------------------------------------------------*
*&      Form  get_input_mode_empty_line
*&---------------------------------------------------------------------*
form get_input_mode_empty_line.

  if vbak-vbtyp cn vbtyp_ange and
     vbak-vbtyp cn vbtyp_anfr.
    if screen-name eq 'VBAP-AWAHR' or
       screen-name eq 'VBAP-GRPOS'.
      screen-active = 0.
      modify screen.
      gs_screen = screen.
    endif.
  endif.
  if vbak-vbtyp ca 'GKL'.
    if screen-name eq 'RV45A-KWMENG' or
       screen-name eq 'VBAP-VRKME'.
      if svbap-tabix = 0 and
         t180-trtyp ne chara.
        screen-active = 0.
        modify screen.
        gs_screen = screen.
      endif.
    endif.
  else.
    if screen-name eq 'VBAP-ZIEME' or
       screen-name eq 'VBAP-ZMENG'.
      if svbap-tabix = 0 and
         t180-trtyp ne chara.
        screen-active = 0.
        modify screen.
        gs_screen = screen.
      endif.
    endif.
  endif.

endform.                    "get_input_mode_empty_line