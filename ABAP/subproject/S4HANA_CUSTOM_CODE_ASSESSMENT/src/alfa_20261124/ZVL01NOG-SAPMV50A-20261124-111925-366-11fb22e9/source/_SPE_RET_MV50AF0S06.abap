*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S06                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_get_ilips_data
*&---------------------------------------------------------------------*
*       This routine is used for external PERFORMs from BAdIs
*---------------------------------------------------------------------*
form spe_get_ilips_data tables ct_ilips_mv50a structure /spe/ret_ilips.

  data: ls_ilips type /spe/ret_ilips.

  refresh ct_ilips_mv50a.
  loop at ilips into ls_ilips.
    append ls_ilips to ct_ilips_mv50a.
  endloop.

endform.                    " spe_get_ilips_data