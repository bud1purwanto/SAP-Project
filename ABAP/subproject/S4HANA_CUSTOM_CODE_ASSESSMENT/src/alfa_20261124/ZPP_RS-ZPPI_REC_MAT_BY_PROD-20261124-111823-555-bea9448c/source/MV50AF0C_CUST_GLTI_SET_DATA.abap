*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_GLTI_SET_DATA                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_glti_set_data
*&---------------------------------------------------------------------*
form cust_glti_set_data.

  field-symbols: <ls_xlips> like line of xlips.              "v_n_761503

  loop at xlips assigning <ls_xlips>                        "v_n_1414410
       where vbeln = xlips-vbeln
       and   posnr = xlips-posnr
       and   updkz ne updkz_delete.
    exit.
  endloop.                                                  "^_n_1414410

  xlips-chmult = <ls_xlips>-chmult.
* line deleted                                      ^_n_761503/n_1223305
  move-corresponding <ls_xlips> to lipsd.                     "n_1223305
  call method gi_cust_tab_glti->transfer_data_to_subscreen
    exporting
      is_likp        = likp
      is_likpd       = likpd
      is_lips        = lips
      is_lipsd       = lipsd
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
      cs_v50agl_cust = v50agl_cust.

  perform lips_bearbeiten_vorbereiten(sapfv50p).

endform.                    " cust_glti_set_data