*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUST_GLTR_PASS_FCODE                    *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  cust_gltr_pass_fcode
*&---------------------------------------------------------------------*
form cust_gltr_pass_fcode.

  call method gi_cust_tab_gltr->pass_fcode_to_subscreen
    exporting
      if_fcode_same_page = fcode_gleiche_seite
      if_fcode           = fcode.


endform.                    " cust_gltr_pass_fcode