*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_MENUE_FM                          *
*&---------------------------------------------------------------------*

form fcode_menue_fm.
* Call SD BAdI
  data: l_sd_sales_exit   type ref to if_ex_badi_sd_menue_fm,
        active_fm type xfeld.

  call function 'GET_HANDLE_SD_MENUE_FM'
    importing
      handle = l_sd_sales_exit
      active = active_fm.

  if active_fm = charx.
    call method l_sd_sales_exit->call_fcode_fm
      exporting
        i_vbak = vbak.
  endif.
endform.                    "FCODE_MENUE_FM