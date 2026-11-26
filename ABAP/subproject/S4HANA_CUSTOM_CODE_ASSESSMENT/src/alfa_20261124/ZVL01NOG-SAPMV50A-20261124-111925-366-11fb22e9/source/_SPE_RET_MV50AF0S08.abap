*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S08                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_first_tc_line
*&---------------------------------------------------------------------*
*       This routine is used for external PERFORMs from BAdIs
*---------------------------------------------------------------------*
form spe_first_tc_line using if_top_line like sy-stepl.

  if if_top_line ge 0.
    ilips_tabix_zeile_1 = if_top_line.
  endif.

endform.                    " spe_first_tc_line