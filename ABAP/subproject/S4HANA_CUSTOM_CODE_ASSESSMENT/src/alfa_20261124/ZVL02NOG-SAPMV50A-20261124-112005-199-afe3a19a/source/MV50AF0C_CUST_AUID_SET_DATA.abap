*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_AUID_SET_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_auid_set_data
*&---------------------------------------------------------------------*
form cust_auid_set_data.

  call method gi_cust_tab_auid->transfer_data_to_subscreen
    exporting
      is_likp            = likp
      is_likpd           = likpd
      it_ylikp           = ylikp[]
      it_xvbuk           = xvbuk[]
      it_yvbuk           = yvbuk[]
      it_xvbup           = xvbup[]
      it_yvbup           = yvbup[]
      it_xlips           = xlips[]
      it_ylips           = ylips[]
      it_xvbpa           = xvbpa[]
      it_yvbpa           = yvbpa[]
      it_xvbfa           = xvbfa[]
      it_yvbfa           = yvbfa[]
      it_xvbadr          = xvbadr[]
      is_v50agl          = v50agl
      if_trtyp           = t180-trtyp
      if_tcode           = t180-tcode
    changing
      cs_v50agl_cust     = v50agl_cust.

endform.                    " cust_auid_set_data