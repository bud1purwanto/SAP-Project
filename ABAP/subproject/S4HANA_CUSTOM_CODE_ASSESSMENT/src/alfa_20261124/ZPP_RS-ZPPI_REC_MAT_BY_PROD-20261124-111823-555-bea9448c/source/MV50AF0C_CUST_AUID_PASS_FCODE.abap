*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_AUID_PASS_FCODE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_auid_pass_fcode
*&---------------------------------------------------------------------*
form cust_auid_pass_fcode.

  call method gi_cust_tab_auid->pass_fcode_to_subscreen
    exporting
      if_fcode_same_page = fcode_gleiche_seite
      if_fcode           = fcode.


endform.                    " cust_auid_pass_fcode