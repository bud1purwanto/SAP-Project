*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_ITEM_GET_DATA                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_item_get_data
*&---------------------------------------------------------------------*
form cust_item_get_data.

  data: ls_likp like likp,                                  "v_n_755113
        ls_likpd like likpd,
        ls_lips like lips,                                 "v_n_1611383
        ls_lipsd like lipsd,
        ls_v50agl_cust like v50agl_cust.                   "^_n_1611383

  ls_likp = likp.
  ls_likpd = likpd.                                         "^_n_755113
  ls_lips = lips.                                          "v_n_1611383
  ls_lipsd = lipsd.
  ls_v50agl_cust = v50agl_cust.                            "^_n_1611383

  call method gi_cust_tab_item->transfer_data_from_subscreen
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
      cs_v50agl_cust = v50agl_cust
      cs_lips        = lips
      cs_lipsd       = lipsd.

  if likp ne ls_likp or                                      "v_n_755113
     likpd ne ls_likpd.
    r185d-dataloss = charx.
  endif.                                                     "^_n_755113

* call lips_bearbeiten only in case of relevant changes     "v_n_1611383
  if likp        ne ls_likp  or
     likpd       ne ls_likpd or
     lips        ne ls_lips  or
     lipsd       ne ls_lipsd or
     v50agl_cust ne ls_v50agl_cust.                         "^_n_1611383
    perform lips_bearbeiten(sapfv50p).
  endif.                                                      "n_1611383

* Filter FCODES that cannot be processed by the delivery dialogue
  perform subscreen_fcode_filter changing fcode.

endform.                    " cust_item_get_data