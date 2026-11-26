*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CALL_BADI_CHANGE_FIEL                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_badi_change_field_attrib
*&---------------------------------------------------------------------*
form call_badi_change_field_attrib
     changing ct_field_attrib type shp_screen_attributes_t.

  check not gi_badi_delivery is initial.           "n_530754/n_637289

  call method gi_badi_delivery->change_field_attributes
    exporting
      is_v50agl           = v50agl
      if_trtyp            = t180-trtyp
      if_tcode            = t180-tcode
      if_screen_group     = taxi_screen_group(1)
      if_panel            = taxi_panel
      it_ylikp            = ylikp[]
      it_xlips            = xlips[]
      it_ylips            = ylips[]
      it_xvbpa            = xvbpa[]
      it_yvbpa            = yvbpa[]
      it_xvbfa            = xvbfa[]
      it_yvbfa            = yvbfa[]
      it_xvbuk            = xvbuk[]
      it_yvbuk            = yvbuk[]
      it_xvbup            = xvbup[]
      it_yvbup            = yvbup[]
      is_lips             = lips
      is_lipsd            = lipsd
      is_likp             = likp
      is_likpd            = likpd
    changing
      ct_field_attributes = ct_field_attrib
      cs_v50agl_cust      = v50agl_cust.

  sort ct_field_attrib by name.

endform.                    " call_badi_change_field_attrib