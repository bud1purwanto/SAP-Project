*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S09                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_get_first_tc_line
*&---------------------------------------------------------------------*
*       This routine is used for external PERFORMs from BAdIs
*---------------------------------------------------------------------*
form spe_get_first_tc_line changing cf_top_line like sy-stepl.

  if ilips_tabix_zeile_1 ge 0.
    cf_top_line = ilips_tabix_zeile_1.
  endif.

endform.                    " spe_get_first_tc_line