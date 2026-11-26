*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_OVER_PASS_FCODE                    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_over_pass_fcode
*&---------------------------------------------------------------------*
form cust_over_pass_fcode.

  call method gi_cust_tab_over->pass_fcode_to_subscreen
    exporting
      if_fcode_same_page = fcode_gleiche_seite
      if_fcode           = fcode.

endform.                    " cust_over_pass_fcode