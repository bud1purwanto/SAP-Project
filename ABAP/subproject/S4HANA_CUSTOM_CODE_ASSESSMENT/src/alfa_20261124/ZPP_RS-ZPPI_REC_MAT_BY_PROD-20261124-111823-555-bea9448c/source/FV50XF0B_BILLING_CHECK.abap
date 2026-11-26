*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BILLING_CHECK         (HP_205247)                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  billing_check
*&---------------------------------------------------------------------*
*       This routine is performed in case that the delivery is already
*       billed completely. It checks whether the requested changes are
*       allowed.
*----------------------------------------------------------------------*
form billing_check using is_likp type likpvb.

  data: lf_subrc like sy-subrc,
        lf_rcode like sy-subrc,
        lf_lfimg_new like lips-lgmng,
        lf_lfimg_old like lips-lgmng,
        ls_xvbup     like line of xvbup,
        lf_msgty like sy-msgty value 'E'.

  field-symbols: <ls_vbuk>  like vbukvb,
                 <ls_vbup>  like vbupvb,                    "n_550284
                 <ls_xlips> like line of xlips,
                 <ls_ylips> like line of ylips.

* Do not perform check in creation mode
  check t180-trtyp ne charh.

  read table xvbuk assigning <ls_vbuk>
                   with key vbeln = is_likp-vbeln.

ENHANCEMENT-POINT FV50XF0B_BILLING_CHECK_01 SPOTS ES_FV50XF0B_BILLING_CHECK INCLUDE BOUND.
  if <ls_vbuk>-fkstk ne space or                            "v_n_550284
     <ls_vbuk>-fkivk ne space.
  lf_subrc = 0.
  loop at xlips assigning <ls_xlips>
                where vbeln eq is_likp-vbeln.
ENHANCEMENT-POINT FV50XF0B_BILLING_CHECK_02 SPOTS ES_FV50XF0B_BILLING_CHECK INCLUDE BOUND.
    if <ls_xlips>-updkz eq updkz_old.
      continue.
    endif.
    if <ls_xlips>-updkz eq updkz_delete.
      read table yvbup assigning <ls_vbup>
                       with key vbeln = <ls_xlips>-vbeln
                                posnr = <ls_xlips>-posnr
                       binary search.
      if sy-subrc eq 0.                                     "n_567128
        if <ls_vbup>-fksta ca 'BC' or
           <ls_vbup>-fkivp ca 'BC'.
*         Item should be deleted although it has been billed
          lf_subrc = 4.
          exit.
        endif.
      endif.                                                "n_567128
    elseif <ls_xlips>-updkz eq updkz_new.
*     New item should be added although delivery is completely billed
      if ( <ls_vbuk>-fkstk eq 'C' or
           <ls_vbuk>-fkivk eq 'C' ) and
         <ls_xlips>-fkrel ne space.                         "n_631564
        lf_subrc = 4.
        exit.
      endif.
    elseif <ls_xlips>-updkz eq updkz_update.                "n_551417
*   Item has been changed
    read table ylips assigning <ls_ylips>
                     with key vbeln = <ls_xlips>-vbeln
                              posnr = <ls_xlips>-posnr.
    if ( <ls_ylips>-lfimg ne <ls_xlips>-lfimg and
         <ls_xlips>-kzpod eq space ) or
       <ls_ylips>-vrkme ne <ls_xlips>-vrkme or
       <ls_ylips>-charg ne <ls_xlips>-charg.
      read table xvbup assigning <ls_vbup>
                       with key vbeln = <ls_xlips>-vbeln
                                posnr = <ls_xlips>-posnr
                       binary search.
ENHANCEMENT-POINT FV50XF0B_BILLING_CHECK_03 SPOTS ES_FV50XF0B_BILLING_CHECK INCLUDE BOUND.
      if <ls_vbup>-fksta eq 'C' or
         <ls_vbup>-fkivp eq 'C'.
*       Item should be changed although it is billed
        lf_subrc = 4.
        exit.
      endif.
    endif.
    endif.                                                  "n_551417
  endloop.                                                  "^_n_550284
  elseif <ls_vbuk>-fkstk eq space.

*   Check whether sales order item has was billed (FKREL = G)
    lf_subrc = 0.
    loop at xlips assigning <ls_xlips>
                  where vbeln eq is_likp-vbeln
                    and vgbel ne space
                    and vgtyp ca vbtyp_auft
                    and uecha is initial.

      if <ls_xlips>-updkz eq updkz_old or
         <ls_xlips>-updkz eq updkz_new.
        continue.
      endif.

      perform tvap_select(sapmv50a) using <ls_xlips>-pstyv
                                    lf_subrc.
      check tvap-fkrel eq 'G'.

      read table xvbup into ls_xvbup
                       with key mandt = <ls_xlips>-mandt
                                vbeln = <ls_xlips>-vgbel
                                posnr = <ls_xlips>-vgpos
                       binary search.
      check ls_xvbup-fksaa ca 'BC'.

      if <ls_xlips>-updkz eq updkz_delete.
        lf_subrc = 8.
        exit.
      endif.
*     Item has been changed
      lf_lfimg_new = <ls_xlips>-lgmng + <ls_xlips>-kcmeng.
      read table ylips assigning <ls_ylips>
                       with key vbeln = <ls_xlips>-vbeln
                                posnr = <ls_xlips>-posnr.
      lf_lfimg_old = <ls_ylips>-lgmng + <ls_ylips>-kcmeng.
      if lf_lfimg_new ne lf_lfimg_old or
         <ls_ylips>-vrkme ne <ls_xlips>-vrkme.
        lf_subrc = 8.
        exit.
      endif.
    endloop.

  endif.

  if lf_subrc = 4.
    perform message_steuerung using  gs_mhpar
                                     v50agl-msgvs
                                     'VL'
                                     '186'
                            changing lf_msgty
                                     lf_rcode.
    check lf_msgty ne space.
    perform finchdel_handling(sapfv50p) using
                                is_likp-vbeln '01' lf_msgty 'VL' '186'
                                space space space space gt_finchdel.
  elseif lf_subrc = 8.
    perform message_steuerung using  gs_mhpar
                                     v50agl-msgvs
                                     'VL'
                                     '444'
                            changing lf_msgty
                                     lf_rcode.
    check lf_msgty ne space.
    perform finchdel_handling(sapfv50p) using
                                is_likp-vbeln '01' lf_msgty 'VL' '444'
                                <ls_xlips>-posnr space space
                                space gt_finchdel.
  endif.

endform.                               " billing_check