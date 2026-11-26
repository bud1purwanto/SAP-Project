*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S07                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_set_ilips_data
*&---------------------------------------------------------------------*
*       This routine is used for external PERFORMs from BAdIs
*---------------------------------------------------------------------*
form spe_set_ilips_data tables ct_ilips_ext structure /spe/ret_ilips.

  data: ls_ilips     type /spe/ret_ilips,
        ls_ilips_ext type /spe/ret_ilips.

  loop at ct_ilips_ext into ls_ilips_ext.
    read table ilips with key posnr = ls_ilips_ext-posnr
                     into ls_ilips
                     binary search.
    if sy-subrc eq 0.
      ls_ilips-selkz = ls_ilips_ext-selkz.
      modify ilips from ls_ilips index sy-tabix.
    endif.
  endloop.

endform.                    " spe_set_ilips_data