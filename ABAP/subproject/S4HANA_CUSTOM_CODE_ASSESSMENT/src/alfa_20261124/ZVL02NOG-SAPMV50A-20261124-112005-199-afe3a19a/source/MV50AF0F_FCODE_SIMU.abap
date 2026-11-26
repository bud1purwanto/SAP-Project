*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_SIMU                                        *
*----------------------------------------------------------------------*
form fcode_simu.

  data: ls_save_xlips like line of xlips,
        ls_save_lips  like lips,
        ls_save_ilips like ilips,
        ls_save_slips like slips,
        ls_ylikp      like likpvb,
        ls_xlikp      like likpvb,                          "n_576318
        ls_likpvb     like likpvb,
        lf_dlv_chg_requested type c,
        lt_vbpa type standard table of vbpavb with header line,
        lf_display_error_log type c,
        ls_return like bapiret2,
        lt_return like bapiret2 occurs 0.

* If delivery change management is inactive or delivery is not relevant
* for distribution : Exit
  if not ( v50agl-dlv_change eq charx or
           ( likp-vlstk ca 'AD' and likp-verursys eq space ) ).
    exit.
  endif.

  if v50agl-dlv_change ne space.
    if v50agl-dlv_change_off eq space.
      ls_save_xlips = xlips.
      ls_save_lips  = lips.
      ls_save_ilips = ilips.
      ls_save_slips = slips.
      move-corresponding ylikp to ls_ylikp.
      move-corresponding likp  to ls_xlikp.                 "n_576318
      ls_xlikp-updkz = xlikp_updkz.

      lt_vbpa[] = xvbpa[].
      loop at yvbpa into lt_vbpa
                    where updkz eq updkz_delete.
        append lt_vbpa.
      endloop.
      sort lt_vbpa by vbeln posnr parvw.

      call function 'SHP_BAPI_DELIVERY_CHANGE_CHECK'
        exporting
          it_likp_new      = ls_xlikp                       "n_576318
          it_likp          = ls_ylikp
        importing
          ef_chg_requested = lf_dlv_chg_requested
        tables
          it_lips_new      = xlips
          it_lips          = ylips
          it_vbpa          = lt_vbpa
          it_vbadr         = xvbadr
          it_xvbuk         = xvbuk                   "n_522151
          it_serno_change  = gt_serno_change.


      if lf_dlv_chg_requested is initial.
*     no RFC change call necessary
        v50agl-no_rmsys_dlv_chg = charx.
        message i438.
        exit.
      else.
        v50agl-no_rmsys_dlv_chg = space.
      endif.

      call function 'SHP_BAPI_DELIVERY_CHANGE_SIMU'
        exporting
          is_xlikp              = xlikp
          is_ylikp              = ls_ylikp
          if_decspli            = v50agl-split
          is_v50agl             = v50agl
        tables
          it_lips               = xlips
          it_vbfa               = xvbfa
          it_vbpa               = lt_vbpa
          it_vbadr              = xvbadr
          it_serno_change       = gt_serno_change
          it_yvbup              = yvbup
          it_xvbup              = xvbup
          it_yvbuk              = yvbuk
          it_xvbuk              = xvbuk
          et_return             = lt_return
        exceptions
          communication_failure = 1
          system_failure        = 2.

      if sy-subrc ne 0.
        ls_return-number     = '480'.
        ls_return-type       = 'E'.
        ls_return-id         = 'VL'.
        ls_return-message_v1 = space.
        ls_return-message_v2 = space.
        ls_return-message_v3 = space.
        ls_return-message_v4 = space.
        append ls_return to lt_return.
*       Avoid that the user has to wait again if the document is saved
        if not likp-verursys is initial.
          v50agl-dlv_change_off = charx.
        endif.
      endif.
    else.
*     Change management is already deactivated
      ls_return-number     = '480'.
      ls_return-type       = 'E'.
      ls_return-id         = 'VL'.
      ls_return-message_v1 = space.
      ls_return-message_v2 = space.
      ls_return-message_v3 = space.
      ls_return-message_v4 = space.
      append ls_return to lt_return.
    endif.

*   Send all errors as information messages (E-messages are not
*   helpful here)
    sort lt_return by id number message_v1 message_v2
                      message_v3 message_v4.
    delete adjacent duplicates from lt_return
                               comparing id number
                                         message_v1 message_v2
                                         message_v3 message_v4.
    refresh cvbfs.
    loop at lt_return into ls_return.
      cvbak-vbeln = likp-vbeln.
      perform message_vbfs_aufbauen using space
                                          posnr_low
                                          ls_return-number
                                          ls_return-type
                                          ls_return-id
                                          ls_return-message_v1
                                          ls_return-message_v2
                                          ls_return-message_v3
                                          ls_return-message_v4.
      lf_display_error_log = charx.
    endloop.
    if sy-subrc ne 0.
      message i439.
    endif.
*   Restore old workareas (are maybe overwritten by function modules)
    xlips = ls_save_xlips.
    lips  = ls_save_lips.
    ilips = ls_save_ilips.
    slips = ls_save_slips.
  elseif likp-vlstk ca 'AD' and
         likp-verursys eq space.
    move-corresponding likp  to ls_likpvb.
    move-corresponding likpd to ls_likpvb.
    refresh cvbfs.
    call function 'SHP_CHECK_DISTRIB_PERMISSION'
      exporting
        is_likpvb                = ls_likpvb
        if_lips_sorted           = space
      tables
        it_lipsvb                = xlips
        it_vbukvb                = xvbuk
        it_vbpavb                = xvbpa
        ct_vbfs                  = cvbfs
      exceptions
        distribution_not_allowed = 1
        others                   = 2.
    if sy-subrc ne 0.
      lf_display_error_log = charx.
    else.
      message i456.
    endif.

  endif.
  if lf_display_error_log eq charx.
    perform fcode_feaz.
  endif.

endform.                    "fcode_simu