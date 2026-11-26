*&---------------------------------------------------------------------*
*&  Include           MV45AF0C_CUST_ACTIVATE_TAB                       *
*&---------------------------------------------------------------------*
form cust_activate_tab.
  data: l_sd_cust_head_exit   type ref to if_ex_badi_sd_tab_cust_h,
        active_h type xfeld,
        l_sd_cust_item_exit   type ref to if_ex_badi_sd_tab_cust_i,
        active_i type xfeld.

  if sy-dyngr = 'LIST'.
* deactivate :
    perform taxi_deactivate_tab using fcode_cust_header.
    perform taxi_deactivate_tab using fcode_cust_item.
  endif.

* screen extension header detail
  if sy-dyngr = 'KOPF'.
    call function 'GET_HANDLE_SD_TAB_CUST_H'
      importing
        handle = l_sd_cust_head_exit
        active = active_h.
    if active_h = 'X' .
      clear gs_cust_tab-head_program.
      clear gs_cust_tab-head_dynpro.
      call method l_sd_cust_head_exit->activate_tab_page
        exporting
          f_vbak    = vbak
        importing
          f_caption = gs_cust_tab-head_caption
          f_program = gs_cust_tab-head_program
          f_dynpro  = gs_cust_tab-head_dynpro.

      if gs_cust_tab-head_program is initial or
         gs_cust_tab-head_dynpro  is initial.
        gs_cust_tab-head_program = 'SAPMV45A'.
        gs_cust_tab-head_dynpro  = '4312'.
        perform taxi_deactivate_tab using fcode_cust_header.
      endif.
    else.
* Add at least an empty dynpro
      gs_cust_tab-head_program = 'SAPMV45A'.
      gs_cust_tab-head_dynpro  = '4312'.
      perform taxi_deactivate_tab using fcode_cust_header.
    endif.
  endif.

* screen extension item detail
  if sy-dyngr = 'POSI'.
    call function 'GET_HANDLE_SD_TAB_CUST_I'
      importing
        handle = l_sd_cust_item_exit
        active = active_i.
    if active_i = 'X' .
      clear gs_cust_tab-item_program.
      clear gs_cust_tab-item_dynpro.
      call method l_sd_cust_item_exit->activate_tab_page
        exporting
          f_vbap    = vbap
        importing
          f_caption = gs_cust_tab-item_caption
          f_program = gs_cust_tab-item_program
          f_dynpro  = gs_cust_tab-item_dynpro.

      if gs_cust_tab-item_program is initial or
         gs_cust_tab-item_dynpro  is initial.
        gs_cust_tab-item_program = 'SAPMV45A'.
        gs_cust_tab-item_dynpro  = '4312'.
        perform taxi_deactivate_tab using fcode_cust_item.
      endif.
    else.
* Add at least an empty dynpro
      gs_cust_tab-head_program = 'SAPMV45A'.
      gs_cust_tab-head_dynpro  = '4312'.
      perform taxi_deactivate_tab using fcode_cust_item.
    endif.
  endif.



endform.                    "CUST_ACTIVATE_TAB