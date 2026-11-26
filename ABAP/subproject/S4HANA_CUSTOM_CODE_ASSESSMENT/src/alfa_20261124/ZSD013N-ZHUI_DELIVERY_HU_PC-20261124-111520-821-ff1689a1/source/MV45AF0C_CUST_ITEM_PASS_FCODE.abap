*&---------------------------------------------------------------------*
*&  Include           MV45AF0C_CUST_ITEM_PASS_FCODE                    *
*&---------------------------------------------------------------------*

form cust_item_pass_fcode.
  data: l_sd_cust_item_exit   type ref to if_ex_badi_sd_tab_cust_i,
          active type xfeld.

  call function 'GET_HANDLE_SD_TAB_CUST_I'
    importing
      handle = l_sd_cust_item_exit
      active = active.

  if active = 'X'.
    call method l_sd_cust_item_exit->pass_fcode_to_subscreen
      exporting
        f_fcode_same_page = fcode_gleiche_seite
        f_fcode           = fcode.
  endif.

endform.