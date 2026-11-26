*&---------------------------------------------------------------------*
*&  Include           MV45AF0C_CUST_ITEM_SET_DATA                      *
*&---------------------------------------------------------------------*

form cust_item_set_data.

  data: l_sd_cust_item_exit   type ref to if_ex_badi_sd_tab_cust_i,
          active type xfeld.

  call function 'GET_HANDLE_SD_TAB_CUST_I'
    importing
      handle = l_sd_cust_item_exit
      active = active.

  if active = 'X'.
    call method l_sd_cust_item_exit->transfer_data_to_subscreen
      exporting
        ft180   = t180
        f_vbap  = vbap
        f_vbkd  = vbkd
        f_tabix = svbap-tabix
      changing
        f_rv45a = rv45a
        fyvblb  = yvblb[]
        fxvblb  = xvblb[]
        fyvbadr = yvbadr[]
        fxvbadr = xvbadr[]
        fyvbfa  = yvbfa[]
        fyvbep  = yvbep[]
        fyvbkd  = yvbkd[]
        fyvbpa  = yvbpa[]
        fyvbuk  = yvbuk[]
        fyvbup  = yvbup[]
        fyfpla  = yfpla[]
        fyfplt  = yfplt[]
        fvbak   = vbak
        fxvbap  = xvbap[]
        fxkomv  = xkomv[]
        fxvbapf = xvbapf[]
        fxvbfa  = xvbfa[]
        fxvbep  = xvbep[]
        fxvbkd  = xvbkd[]
        fxvbpa  = xvbpa[]
        fxvbuk  = xvbuk[]
        fxvbup  = xvbup[]
        fxfpla  = xfpla[]
        fxfplt  = xfplt[]
        fyvbak  = yvbak
        fyvbapf = yvbapf[]
        fyvbap  = yvbap[]
        f_r185d = r185d.

  endif.


endform.                    "cust_item_set_data