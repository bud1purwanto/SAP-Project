*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_TEXT_DETERMINATION_CO                   *
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  text_determination_complete (n_610917)
*&--------------------------------------------------------------------*
form text_determination_complete
     using if_final_check_execute type c.

  data: begin of ls_tvuvs_no_dl,
          uvprs like tvuvs-uvprs,
        end   of ls_tvuvs_no_dl,
        ls_tvuvs_wa type shp_tvuvs_wa,                      "ECC 600
        ls_tvuvs          like ls_tvuvs_wa,
        ls_xvbuk         like line of xvbuk,
        ls_yvbuk         like line of yvbuk,
        ls_xvbup         like line of xvbup,
        ls_yvbup         like line of yvbup,
        lf_xvbuk_tabix   like sy-tabix,
        lf_msgty         like sy-msgty value 'E',
        lf_msgty_checked type c,
        lf_cancel        like sy-subrc,
        lf_subrc         like sy-subrc.

* Exit if text determination is not desired at all or already performed
  if v50agl-no_head_text_determine eq charx and
     v50agl-no_item_text_determine eq charx.
    exit.
  endif.

  refresh: gt_finchdel, gt_r_autlf_del.

  loop at xlikp.

*   Get delivery type for current header
    perform tvlk_select(sapmv50a) using xlikp-lfart
                                        space
                                        lf_subrc.

*   Call text determination for each delivery separately
    move-corresponding xlikp to likp.
    perform likp_fuellen_texte_sammelgang(sapfv50k).
    perform lips_fuellen_texte_sammelgang(sapfv50p).

*   If mandatory texts are missing update incompletion status
    loop at xvbuv transporting no fields
                  where vbeln eq likp-vbeln
                    and tdid  ne space.
      exit.
    endloop.
    check sy-subrc eq 0.

*   Update incompletion status of the processed deliveries
*   Header single status
    read table xvbuk into ls_xvbuk
                     with key vbeln = likp-vbeln
                     binary search.
    lf_xvbuk_tabix = sy-tabix.
    ls_yvbuk = ls_xvbuk.
    move-corresponding ls_xvbuk to ls_tvuvs_no_dl.
    clear ls_tvuvs_wa.
    move-corresponding ls_tvuvs_wa to ls_xvbuk.
    loop at xvbuv where vbeln eq ls_xvbuk-vbeln
                    and posnr eq posnr_low
                    and updkz ne updkz_delete.
      perform read_tvuvs(sapfv50u) using    xvbuv-statg
                                   changing ls_tvuvs.
      overlay ls_tvuvs_wa with ls_tvuvs.
    endloop.
    translate ls_tvuvs_wa using 'XA C'.
    move-corresponding ls_tvuvs_wa    to ls_xvbuk.
    move-corresponding ls_tvuvs_no_dl to ls_xvbuk.
    if ls_xvbuk ne ls_yvbuk and
       ls_xvbuk-updkz eq updkz_old.
      read table yvbuk with key mandt = sy-mandt
                                vbeln = ls_xvbuk-vbeln
                       binary search.
      if sy-subrc ne 0.              "the only expected case
        insert ls_yvbuk into yvbuk index sy-tabix.
      endif.
      ls_xvbuk-updkz = updkz_update.
    endif.
    modify xvbuk from ls_xvbuk index lf_xvbuk_tabix.

*   Item single status
    read table xvbup with key vbeln = likp-vbeln
                     binary search
                     transporting no fields.
    loop at xvbup into ls_xvbup
                  from sy-tabix.
      if ls_xvbup-vbeln ne likp-vbeln.
        exit.
      endif.
      ls_yvbup = ls_xvbup.
      move-corresponding ls_xvbup to ls_tvuvs_no_dl.
      clear ls_tvuvs_wa.
      move-corresponding ls_tvuvs_wa to ls_xvbup.
      loop at xvbuv where vbeln eq ls_xvbup-vbeln
                      and posnr eq xvbup-posnr
                      and updkz ne updkz_delete.
        perform read_tvuvs(sapfv50u) using    xvbuv-statg
                                     changing ls_tvuvs.
        overlay ls_tvuvs_wa with ls_tvuvs.
      endloop.
      translate ls_tvuvs_wa using 'XA C'.
      move-corresponding ls_tvuvs_wa    to ls_xvbup.
      move-corresponding ls_tvuvs_no_dl to ls_xvbup.
      if ls_xvbup ne ls_yvbup and
         ls_xvbup-updkz eq updkz_old.
        read table yvbup with key mandt = sy-mandt
                                  vbeln = ls_xvbup-vbeln
                                  posnr = ls_xvbup-posnr
                         binary search.
        if sy-subrc ne 0.              "the only expected case
          insert ls_yvbup into yvbup index sy-tabix.
        endif.
        ls_xvbup-updkz = updkz_update.
      endif.
      modify xvbup from ls_xvbup.
    endloop.

*   Cumulated header status
    call function 'WS_UNCOMPL_STATUS'
      exporting
        f_vbeln = likp-vbeln
        f_vbtyp = likp-vbtyp
      tables
        fxvbuk  = xvbuk
        fyvbuk  = yvbuk
        fxvbup  = xvbup
        fyvbup  = yvbup
        fxvbuv  = xvbuv.

  endloop.

* Are there mandatory texts preventing the delivery from saving?
  if if_final_check_execute ne space.
    loop at xvbuk into ls_xvbuk
                  where vbtyp ca vbtyp_delv
                    and ( uvvls ca 'AB' or uvvlk eq chara ).

      if lf_msgty_checked is initial.
        perform message_steuerung
                    using        gs_mhpar
                                 v50agl-msgvs
                                 'VU'
                                 '013'
                    changing     lf_msgty
                                 lf_subrc.
        lf_msgty_checked = charx.
      endif.

      perform finchdel_handling(sapfv50p) using
           xvbuk-vbeln space lf_msgty 'VU' '013'
           space space space space gt_finchdel.
*          VBELN PRUEFUNG MSGTY MSGID
*          MSGNO MSGV1 MSGV2 MSGV3 MSGV4 FINCHDEL
      perform uc_coll_proc_protocol using ls_xvbuk-vbeln.

    endloop.
    if not gt_finchdel[] is initial.
      perform final_check_execute using lf_cancel.
    endif.
  endif.

endform.                    "text_determination_complete