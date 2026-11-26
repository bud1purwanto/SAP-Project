*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CALL_BADI_CHANGE_FCOD                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_badi_change_fcode_attrib
*&---------------------------------------------------------------------*
form call_badi_change_fcode_attrib.

  data: lt_cua_exclude type shp_cua_exclude_t,
        ls_cua_exclude type shp_cua_exclude.

  check not gi_badi_delivery is initial.           "n_530754/n_637289

  call method gi_badi_delivery->change_fcode_attributes
    exporting
      if_trtyp        = t180-trtyp
      if_tcode        = t180-tcode
      is_v50agl       = v50agl
      if_screen_group = taxi_screen_group(1)
      if_panel        = taxi_panel
      it_ylikp        = ylikp[]
      it_xlips        = xlips[]
      it_ylips        = ylips[]
      it_xvbpa        = xvbpa[]
      it_yvbpa        = yvbpa[]
      it_xvbfa        = xvbfa[]
      it_yvbfa        = yvbfa[]
      it_xvbuk        = xvbuk[]
      it_yvbuk        = yvbuk[]
      it_xvbup        = xvbup[]
      it_yvbup        = yvbup[]
      is_lips         = lips
      is_lipsd        = lipsd
      is_likp         = likp
      is_likpd        = likpd
    changing
      ct_cua_exclude  = lt_cua_exclude
      cs_v50agl_cust  = v50agl_cust.

  loop at lt_cua_exclude into ls_cua_exclude.
    perform cua_fcode_allow using ls_cua_exclude-function no.
  endloop.

endform.                    " call_badi_change_fcode_attrib