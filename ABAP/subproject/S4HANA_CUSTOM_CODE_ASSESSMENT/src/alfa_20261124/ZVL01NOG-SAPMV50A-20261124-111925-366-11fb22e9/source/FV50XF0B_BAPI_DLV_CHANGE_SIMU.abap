*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BAPI_DLV_CHANGE_SIMU                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  bapi_dlv_change_simulate
*&---------------------------------------------------------------------*
*       Call BAPI delivery change in simulation mode (no db update)
*----------------------------------------------------------------------*
*      is_XLIKP  delivery header
*----------------------------------------------------------------------*
form bapi_dlv_change_simulate
     using    is_xlikp like likpvb
     changing cf_dlv_chg_requested type xfeld.              "n_539326

* line deleted                                               n_539326
  data: lt_return like bapiret2 occurs 0.
  data: ls_ylikp like likpvb.
  data: ls_xlikp like likpvb.
  data: ls_lecmoff type lecmoff.                            "n_548928
  data: lt_vbpa type standard table of vbpavb with header line.
  field-symbols: <ls_return> type bapiret2.

* Check whether delivery change management is active; avoid recursive
* calls of the simulation
  check not v50agl-dlv_change is initial and
        v50agl-no_rmsys_dlv_chg eq space.                   "n_539326

* Read current status of the emergency flag to take into account changes
* during dialog processing. Note that only the DEactivation of the
* change management is of interest here in order to avoid unnecessary
* and time consuming calls of the simulation module
  if v50agl-dlv_change_off eq space.                        "v_n_548928
    select single * from lecmoff
                    into ls_lecmoff
                    where lgnum eq is_xlikp-lgnum.
    if sy-subrc eq 0 and
       ls_lecmoff-cmoff ne space.
      v50agl-dlv_change_off = charx.
    endif.
  endif.                                                    "^_n_548928

* It is not allowed to delete all items without deleting the whole
* delivery because the reference to the related document is lost
  if likp-vlstk eq charb and ylikp_updkz ne updkz_delete.
    loop at xlips transporting no fields
                  where updkz ca 'UI '.
    endloop.
    if sy-subrc ne 0.
      perform finchdel_handling(sapfv50p) using
                                is_xlikp-vbeln '05' 'E' 'VL' '443'
                                space space space space gt_finchdel.
      exit.
    endif.
  endif.

  ls_xlikp = is_xlikp.

  read table ylikp into ls_ylikp with key vbeln = ls_xlikp-vbeln.

  lt_vbpa[] = xvbpa[].
  loop at yvbpa into lt_vbpa
                where updkz eq updkz_delete.
    append lt_vbpa.
  endloop.
  sort lt_vbpa by vbeln posnr parvw.

* Check for relevant changes in the delivery
  call function 'SHP_BAPI_DELIVERY_CHANGE_CHECK'
    exporting
      it_likp_new      = ls_xlikp
      it_likp          = ls_ylikp
    importing
      ef_chg_requested = cf_dlv_chg_requested
    tables
      it_lips_new      = xlips
      it_lips          = ylips
      it_vbpa          = lt_vbpa
      it_vbadr         = xvbadr
      it_xvbuk         = xvbuk                   "n_522151
      it_serno_change  = gt_serno_change.

  check cf_dlv_chg_requested ne space and
        v50agl-dlv_change_off eq space.          "n_539326

  if ls_xlikp-updkz = updkz_delete and
     ls_xlikp-lgnum is initial.
*      warehouse number is missing, restore from YLIKP
    read table ylikp into ls_ylikp with key vbeln = xlikp-vbeln.
    if sy-subrc = 0.
      ls_xlikp-lgnum = ls_ylikp-lgnum.
    endif.
  endif.

* simulate in delivery save process with update indicator
  call function 'SHP_BAPI_DELIVERY_CHANGE_SIMU'
    exporting
      is_xlikp              = ls_xlikp
      is_ylikp              = ls_ylikp
      if_upd_ind            = 'X'
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
      system_failure        = 2
      others                = 3.

* In case of communication errors switch change management off
* (customizing settings will be evaluated later)
  if sy-subrc eq 1 or sy-subrc eq 2.
    v50agl-dlv_change_off = charx.
  endif.

  loop at lt_return assigning <ls_return>.
    if sy-tabix eq 1.
*     Write explaining message to log to make clear that messages
*     belong to the REMOTE system
      clear cvbfs.
      cvbfs-vbeln = ls_xlikp-vbeln.
      cvbfs-posnr = posnr_low.
      cvbfs-msgid = 'VL'.
      cvbfs-msgno = '437'.
      cvbfs-msgty = 'I'.
      append cvbfs.
    endif.
    if <ls_return>-type ca 'EAX'.
      if v50agl-kommirueckmeldung ne space.
        perform finchdel_handling(sapfv50p) using
                                    ls_xlikp-vbeln
                                    '05'
                                    'E'
                                    'VL'
                                    '496'
                                    space
                                    space
                                    space
                                    space
                                    gt_finchdel.
      else.
        perform finchdel_handling(sapfv50p) using
                                    ls_xlikp-vbeln
                                    '05'
                                    'E'
                                    'VL'
                                    '403'
                                    space
                                    space
                                    space
                                    space
                                    gt_finchdel.
      endif.
    endif.
*   Collect all messages from the remote system in the delivery's error
*   log
    clear cvbfs.
    cvbfs-vbeln = ls_xlikp-vbeln.
    cvbfs-posnr = posnr_low.
    cvbfs-msgid = <ls_return>-id.
    cvbfs-msgno = <ls_return>-number.
    cvbfs-msgty = <ls_return>-type.
    cvbfs-msgv1 = <ls_return>-message_v1.
    cvbfs-msgv2 = <ls_return>-message_v2.
    cvbfs-msgv3 = <ls_return>-message_v3.
    cvbfs-msgv4 = <ls_return>-message_v4.
*   Due to the remote call technique error messages may appear twice
    collect cvbfs.
  endloop.

endform.                               " bapi_dlv_change_simulate