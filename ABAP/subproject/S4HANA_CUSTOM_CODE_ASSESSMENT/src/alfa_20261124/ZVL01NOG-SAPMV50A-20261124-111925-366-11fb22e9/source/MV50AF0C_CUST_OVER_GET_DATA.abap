*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_OVER_GET_DATA                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_over_get_data
*&---------------------------------------------------------------------*
form cust_over_get_data.

  call method gi_cust_tab_over->transfer_data_from_subscreen
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

* Filter FCODES that cannot be processed by the delivery dialogue
  perform subscreen_fcode_filter changing fcode.

endform.                    " cust_over_get_data