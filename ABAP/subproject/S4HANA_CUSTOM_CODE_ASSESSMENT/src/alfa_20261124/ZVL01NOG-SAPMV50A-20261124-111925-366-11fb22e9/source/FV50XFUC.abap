*----------------------------------------------------------------------*
*   INCLUDE FV50XFUC                                                   *
*----------------------------------------------------------------------*

include fv50utyp.

*&---------------------------------------------------------------------*
*&      Form  UC_FROM_FINAL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form uc_from_final_check.

  data: ls_msgty like sy-msgty value 'E',
        lf_msgty_checked type c,                            "n_532791
        lv_rcode like sy-subrc.

*-only inbound and outbound deliveries are being processed

  loop at xlikp where vbtyp na vbtyp_lief and
                      vbtyp na vbtyp_liav.
    exit.
  endloop.
  if sy-subrc eq 0 or ( likp-vbtyp na vbtyp_lief and
                        likp-vbtyp na vbtyp_liav ).
    refresh xvbuv.
    exit.
  endif.

* Uncompleteness data
  perform xvbuv_fill_final(sapfv50u).
*---are there any results, preventing document form saving ?

  loop at xvbuk where vbtyp ca vbtyp_delv and               "HP_374450
                      ( uvvls ca 'AB' or
                        uvvlk eq chara ).
    if lf_msgty_checked is initial.                         "v_n_532791
      perform message_steuerung
                  using        gs_mhpar
                               v50agl-msgvs
                               'VU'
                               '013'
                  changing     ls_msgty
                               lv_rcode.
      lf_msgty_checked = charx.
    endif.                                                  "^_n_532791

    perform finchdel_handling(sapfv50p) using
    xvbuk-vbeln space ls_msgty 'VU' '013'
    space space space space gt_finchdel.
*        VBELN PRUEFUNG MSGTY MSGID
*        MSGNO MSGV1 MSGV2 MSGV3 MSGV4 FINCHDEL
    check v50agl-sammelgang ne space.
    if v50agl-sammelgang ne space.
      perform uc_coll_proc_protocol using xvbuk-vbeln.
*   If the delivery change is initiated from an external system force
*   msg VU014 to the log to allow error analysis in the remote system
    elseif v50agl-no_rmsys_dlv_chg ne space.
      perform uc_remote_change_log using xvbuk-vbeln.
    endif.
  endloop.                             "xvbuk

endform.                               " UC_FROM_FINAL_CHECK


*&---------------------------------------------------------------------*
*&      Form  UC_COLL_PROC_PROTOCOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XVBUK_VBELN  text                                          *
*----------------------------------------------------------------------*
form uc_coll_proc_protocol using  p_vbeln like likp-vbeln.

  data: da_pvbuv type shp_pvbuv occurs 0 with header line.
  data: lv_msgty like sy-msgty,
        lv_rcode like sy-subrc.
  loop at xvbuv where vbeln eq p_vbeln and
                      updkz ne updkz_delete.
    perform uc_get_pvbuv(sapfv50u)
                                   using xvbuv
                                   changing da_pvbuv.
    append da_pvbuv.
  endloop.
  loop at da_pvbuv where vbeln eq p_vbeln and
                         uvvlk eq 'X'.
    if da_pvbuv-posnr ne posnr_low.
      read table xlips with key  vbeln = da_pvbuv-vbeln
                       posnr = da_pvbuv-posnr
                       updkz = updkz_new
              transporting vgbel vgpos.
      check sy-subrc eq 0.
      cvbak-vbeln = xlips-vgbel.
      perform message_handling_variabel(sapmv50a)
                                 using xlips-vgpos
                                       '014'
                                       'E'
                                       'VU'
                                       da_pvbuv-ddtext
                                       da_pvbuv-tbnam
                                       da_pvbuv-fdnam
                                       da_pvbuv-fehgr
                                       gs_mhpar
                                       v50agl-msgvs
                             changing  lv_msgty
                                       lv_rcode.
    else.
      loop at cvbls where vbeln_lif eq da_pvbuv-vbeln.
        cvbak-vbeln = cvbls-vbeln.
        perform message_handling_variabel(sapmv50a)
                              using posnr_low
                                    '014'
                                    'E'
                                    'VU'
                                    da_pvbuv-ddtext
                                    da_pvbuv-tbnam
                                    da_pvbuv-fdnam
                                    da_pvbuv-fehgr
                                    gs_mhpar
                                    v50agl-msgvs
                          changing  lv_msgty
                                    lv_rcode.
      endloop.
      if sy-subrc ne 0.
        clear cvbak-vbeln.
        perform message_handling_variabel(sapmv50a)
                              using posnr_low
                                    '014'
                                    'E'
                                    'VU'
                                    da_pvbuv-ddtext
                                    da_pvbuv-tbnam
                                    da_pvbuv-fdnam
                                    da_pvbuv-fehgr
                                    gs_mhpar
                                    v50agl-msgvs
                          changing  lv_msgty
                                    lv_rcode.
      endif.
    endif.
  endloop.                             "DA_PVBU

endform.                               " UC_COLL_PROC_PROTOCOL

*&---------------------------------------------------------------------*
*&      Form  uc_remote_change_log
*&---------------------------------------------------------------------*
*       Force message VU014 to the error log if incompleteness
*       check is done from a remote system
*----------------------------------------------------------------------*
*      -->P_XVBUK_VBELN  text
*----------------------------------------------------------------------*
form uc_remote_change_log using if_vbeln like xvbuk-vbeln.

  local: cvbak.
  data: ls_xvbuv like line of xvbuv,
        ls_pvbuv type shp_pvbuv,
        lt_pvbuv type standard table of shp_pvbuv.

  loop at xvbuv into ls_xvbuv
                where vbeln eq if_vbeln
                  and updkz ne updkz_delete.
    perform uc_get_pvbuv(sapfv50u) using    ls_xvbuv
                                   changing ls_pvbuv.
    append ls_pvbuv to lt_pvbuv.
  endloop.

  cvbak-vbeln = if_vbeln.
  loop at lt_pvbuv into ls_pvbuv
                   where vbeln eq if_vbeln
                     and uvvlk eq 'X'.
    perform message_vbfs_aufbauen using space
                                        ls_pvbuv-posnr
                                        '014'
                                        'I'
                                        'VU'
                                        ls_pvbuv-ddtext
                                        ls_pvbuv-tbnam
                                        ls_pvbuv-fdnam
                                        ls_pvbuv-fehgr.
  endloop.


endform.                    " uc_remote_change_log