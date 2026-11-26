*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CALL_BADI_ACTIVATE_TA                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_badi_activate_tab_page
*&---------------------------------------------------------------------*
*       Additional tab pages are active if caption provided by method
*       ACTIVATE_TAB_PAGE is not SPACE
*----------------------------------------------------------------------*
form call_badi_activate_tab_page.

  data: lf_screen_group  like taxi_params-screen_group,
        lf_varname       type fieldname,
        lf_index_numc(2) type n,
        lf_fcode_in      type fcode,
        lf_fcode_out     type fcode.

  field-symbols: <lf_customer_tab> like shp_cust_tab_page-tab_w.

  check t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.

* Create BAdI instances for dialog processing
* Notes 530754, 536540, 545270, 572145 replaced             "v_n_637289
* Customer tab page header detail
  if gi_cust_tab_head is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_CUST_HEAD'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_head
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Customer tab page item detail
  if gi_cust_tab_item is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_CUST_ITEM'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_item
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Customer tab page item overview
  if gi_cust_tab_over is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_CUST_OVER'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_over
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* SCEM header page
  if gi_cust_tab_scem is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_SCEM_HEAD'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_scem
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Global trade header page
  if gi_cust_tab_gltr is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_GLTR_HEAD'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_gltr
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Global trade item page
  if gi_cust_tab_glti is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_GLTR_ITEM'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_glti
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.
*                                                           "^_n_637289
* Auto-ID header detail
  if gi_cust_tab_auid is initial.
    call method cl_exithandler=>get_instance
      exporting
        exit_name                     = 'LE_SHP_TAB_AUID_HEAD'
        null_instance_accepted        = 'X'
      changing
        instance                      = gi_cust_tab_auid
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.
    if sy-subrc ne 0.
      message id sy-msgid type 'A' number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

  clear gs_cust_tab.
* Determine tab page intended to be used for BAdI extensions
  do 4 times.
    case sy-index.
      when 1.
        lf_screen_group = 'W'.
      when 2.
        lf_screen_group = 'H'.
      when 3.
        lf_screen_group = 'I'.
      when 4.
        lf_screen_group = 'C'.
    endcase.
    concatenate 'GS_CUST_TAB-TAB_' lf_screen_group into lf_varname.
    assign (lf_varname) to <lf_customer_tab>.

*   Build name for screen groups
*   - Outbound deliveries: W0, H0, I0, C0
*   - Inbound deliveries: WI, HI, II, CI
    if t180-tcode cs 'VL3'.
      concatenate lf_screen_group 'I' into lf_screen_group.
    else.
      concatenate lf_screen_group '0' into lf_screen_group.
    endif.
*   Initialize tab control for current screen group
    call function 'TAXI_CREATE_CAPTIONS'
      exporting
        program                 = 'SAPMV50A'
        screen_group            = lf_screen_group
      exceptions
        no_tabs_for_screengroup = 1
        no_caption_for_fcode    = 2
        others                  = 3.

    if sy-subrc ne 0.
      message a347 with 'SAPMV50A' lf_screen_group.
    endif.
*   Search for the tab with fcode containing string CUS_T. This is the
*   tab intended for customer use. The appropriate tab name (T\nn) is
*   stored in the administration structure GS_CUST_TAB for each screen
*   group
    do 32 times.
      lf_index_numc = sy-index.
      concatenate c_prefix_captions_field lf_index_numc
                  into lf_fcode_in.

      call function 'TAXI_CONVERT_FCODE'
        exporting
          fcode_in        = lf_fcode_in
        importing
          fcode_out       = lf_fcode_out
        exceptions
          fcode_not_found = 1
          others          = 2.
      if sy-subrc ne 0.
        exit.
      endif.
      if lf_fcode_out cs 'CUS_T'.
        <lf_customer_tab> = lf_fcode_in.
      endif.
*     Determine position of add-on tab pages on header and on item level
      case lf_screen_group(1).
        when 'H'.
          if lf_fcode_out cs 'SCM_T'.  "SCEM
            gs_cust_tab-tab_s = lf_fcode_in.
          endif.
          if lf_fcode_out cs 'GLT_T'.  "GLTR
            gs_cust_tab-tab_g = lf_fcode_in.
          endif.
          if lf_fcode_out cs 'AID_T'.  "Auto-ID
            gs_cust_tab-tab_a = lf_fcode_in.
          endif.
        when 'I'.
          if lf_fcode_out cs 'GLT_T'.  "GLTR
            gs_cust_tab-tab_t = lf_fcode_in.
          endif.
        when 'C'.                                           "n_540985
          if lf_fcode_out cs 'GLT_T'.  "GLTR
            gs_cust_tab-tab_r = lf_fcode_in.
          endif.
      endcase.
    enddo.
  enddo.

* Call BAdI methods for customer tab activation
* Additional tab page on header detail
  if not gi_cust_tab_head is initial.              "n_530754/n_637289
    call method gi_cust_tab_head->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-head_caption
        ef_position    = gs_cust_tab-head_position
        ef_program     = gs_cust_tab-head_program
        ef_dynpro      = gs_cust_tab-head_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-head_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-head_position le 0.
        gs_cust_tab-head_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-head_program is initial or
         gs_cust_tab-head_dynpro  is initial.
        gs_cust_tab-head_program = 'SAPMV50A'.
        gs_cust_tab-head_dynpro  = '2900'.
      endif.
    endif.                                                  "n_530754
  endif.

* Additional tab page on item detail
  if not gi_cust_tab_item is initial.              "n_530754/n_637289
    call method gi_cust_tab_item->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-item_caption
        ef_position    = gs_cust_tab-item_position
        ef_program     = gs_cust_tab-item_program
        ef_dynpro      = gs_cust_tab-item_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-item_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-item_position le 0.
        gs_cust_tab-item_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-item_program is initial or
         gs_cust_tab-item_dynpro  is initial.
        gs_cust_tab-item_program = 'SAPMV50A'.
        gs_cust_tab-item_dynpro  = '2900'.
      endif.
    endif.
  endif.                                                    "n_530754

* Additional tab page on item overview
  if not gi_cust_tab_over is initial.              "n_530754/n_637289
    call method gi_cust_tab_over->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-over_caption
        ef_position    = gs_cust_tab-over_position
        ef_program     = gs_cust_tab-over_program
        ef_dynpro      = gs_cust_tab-over_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-over_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-over_position le 0.
        gs_cust_tab-over_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-over_program is initial or
         gs_cust_tab-over_dynpro  is initial.
        gs_cust_tab-over_program = 'SAPMV50A'.
        gs_cust_tab-over_dynpro  = '2900'.
      endif.
    endif.
  endif.                                                    "n_530754

* Additional tab page for SCEM data
  if not gi_cust_tab_scem is initial.              "n_530754/n_637289
    call method gi_cust_tab_scem->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-scem_caption
        ef_position    = gs_cust_tab-scem_position
        ef_program     = gs_cust_tab-scem_program
        ef_dynpro      = gs_cust_tab-scem_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-scem_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-scem_position le 0.
        gs_cust_tab-scem_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-scem_program is initial or
         gs_cust_tab-scem_dynpro  is initial.
        gs_cust_tab-scem_program = 'SAPMV50A'.
        gs_cust_tab-scem_dynpro  = '2900'.
      endif.
    endif.
  endif.                                                    "n_530754

* Additional tab page for global trade data (head)
  if not gi_cust_tab_gltr is initial.              "n_530754/n_637289
    call method gi_cust_tab_gltr->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-gltr_caption
        ef_position    = gs_cust_tab-gltr_position
        ef_program     = gs_cust_tab-gltr_program
        ef_dynpro      = gs_cust_tab-gltr_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-gltr_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-gltr_position le 0.
        gs_cust_tab-gltr_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-gltr_program is initial or
         gs_cust_tab-gltr_dynpro  is initial.
        gs_cust_tab-gltr_program = 'SAPMV50A'.
        gs_cust_tab-gltr_dynpro  = '2900'.
      endif.
    endif.
  endif.                                                    "n_530754

* Additional tab page for global trade data (item)
  if not gi_cust_tab_glti is initial.              "n_530754/n_637289
    call method gi_cust_tab_glti->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-glti_caption
        ef_position    = gs_cust_tab-glti_position
        ef_program     = gs_cust_tab-glti_program
        ef_dynpro      = gs_cust_tab-glti_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

* Check consistency
    if gs_cust_tab-glti_caption ne space.
*   If no reasonable position is provided by method additional tab is
*   placed as last tab
      if gs_cust_tab-glti_position le 0.
        gs_cust_tab-glti_position = 99.
      endif.
*   If no subscreen is given send at least empty screen as default
      if gs_cust_tab-glti_program is initial or
         gs_cust_tab-glti_dynpro  is initial.
        gs_cust_tab-glti_program = 'SAPMV50A'.
        gs_cust_tab-glti_dynpro  = '2900'.
      endif.
    endif.
  endif.                                                    "n_530754

* Additional tab page for auto-id data (head)
  if not gi_cust_tab_auid is initial.
    call method gi_cust_tab_auid->activate_tab_page
      exporting
        is_likp        = likp
        is_likpd       = likpd
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      importing
        ef_caption     = gs_cust_tab-auid_caption
        ef_position    = gs_cust_tab-auid_position
        ef_program     = gs_cust_tab-auid_program
        ef_dynpro      = gs_cust_tab-auid_dynpro
      changing
        cs_v50agl_cust = v50agl_cust.

*   Check consistency
    if gs_cust_tab-glti_caption ne space.
*     If no reasonable position is provided by method additional tab is
*     placed as last tab
      if gs_cust_tab-glti_position le 0.
        gs_cust_tab-glti_position = 99.
      endif.
*      If no subscreen is given send at least empty screen as default
      if gs_cust_tab-glti_program is initial or
         gs_cust_tab-glti_dynpro  is initial.
        gs_cust_tab-glti_program = 'SAPMV50A'.
        gs_cust_tab-glti_dynpro  = '2900'.
      endif.
    endif.
  endif.

endform.                    " call_badi_activate_tab_page