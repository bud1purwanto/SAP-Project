*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_HEAD_GET_DATA                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_head_get_data
*&---------------------------------------------------------------------*
form cust_head_get_data.

  data: ls_likp like likp,                                  "v_n_755113
        ls_likpd like likpd.

  ls_likp = likp.
  ls_likpd = likpd.                                         "^_n_755113

  call method gi_cust_tab_head->transfer_data_from_subscreen
    exporting
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
    changing
      cs_likp        = likp
      cs_likpd       = likpd
      cf_fcode       = fcode
      cs_v50agl_cust = v50agl_cust.

  if likp ne ls_likp or                                      "v_n_755113
     likpd ne ls_likpd.
    r185d-dataloss = charx.
  endif.                                                     "^_n_755113

* Filter FCODES that cannot be processed by the delivery dialogue
  perform subscreen_fcode_filter changing fcode.

endform.                    " cust_head_get_data