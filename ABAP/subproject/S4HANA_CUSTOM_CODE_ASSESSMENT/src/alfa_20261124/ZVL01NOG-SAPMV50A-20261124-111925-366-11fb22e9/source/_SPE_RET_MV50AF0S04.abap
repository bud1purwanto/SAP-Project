*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S04                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_split_docflow_update
*&---------------------------------------------------------------------*
*       Write split delivery to document flow
*----------------------------------------------------------------------*
form spe_split_docflow_update  using it_flow type ledspd_flow_t.

  data: ls_xlikp_new type likpvb,
        ls_xlikp_old type likpvb,
        ls_flow      type ledspd_flow,
        ls_vbfa      type vbfa.

  field-symbols: <ls_xlips> type lipsvb.

  loop at it_flow into ls_flow
                  where updkz eq 'I'.
    loop at xlips assigning <ls_xlips>
                  where vbeln eq ls_flow-vbeln_new
                    and posnr eq ls_flow-posnr_new
                    and updkz ne updkz_delete.
      exit.
    endloop.
    check sy-subrc eq 0.
    if ls_xlikp_new-vbeln ne <ls_xlips>-vbeln.
      read table xlikp into ls_xlikp_new with key vbeln = <ls_xlips>-vbeln.
    endif.
    if ls_xlikp_old-vbeln ne ls_flow-vbeln.
      read table xlikp into ls_xlikp_old with key vbeln = <ls_xlips>-vbeln.
    endif.
    ls_vbfa-mandt   = sy-mandt.
    ls_vbfa-vbelv   = ls_flow-vbeln.
    ls_vbfa-posnv   = ls_flow-posnr.
    ls_vbfa-vbeln   = ls_flow-vbeln_new.
    ls_vbfa-posnn   = ls_flow-posnr_new.
    ls_vbfa-vbtyp_n = ls_xlikp_new-vbtyp.
    ls_vbfa-rfmng   = ls_flow-lgmng.
    ls_vbfa-meins   = <ls_xlips>-meins.
    ls_vbfa-erdat   = <ls_xlips>-erdat.
    ls_vbfa-erzet   = <ls_xlips>-erzet.
    ls_vbfa-vbtyp_v = ls_xlikp_old-vbtyp.
    ls_vbfa-matnr   = <ls_xlips>-matnr.
    ls_vbfa-rfmng_flo = ls_flow-lgmng * <ls_xlips>-umvkn / <ls_xlips>-umvkz.
    ls_vbfa-rfmng_flt = ls_flow-lgmng.
    ls_vbfa-vrkme     = <ls_xlips>-vrkme.
    call function 'RV_XVBFA_MAINTAIN'
      exporting
        fvbfa                  = ls_vbfa
        f_vorgang              = space
        i_do_not_rebuild_vbapf = charx
      tables
        fxvbfa                 = xvbfa
        fyvbfa                 = yvbfa.
  endloop.

endform.                    " spe_split_docflow_update