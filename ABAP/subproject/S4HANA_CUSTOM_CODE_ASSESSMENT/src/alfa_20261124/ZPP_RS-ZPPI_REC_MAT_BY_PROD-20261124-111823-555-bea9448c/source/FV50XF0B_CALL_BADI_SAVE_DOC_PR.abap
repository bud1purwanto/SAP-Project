*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_CALL_BADI_SAVE_DOC_PR                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_badi_save_doc_prep
*&---------------------------------------------------------------------*
form call_badi_save_doc_prep.

  data: lt_badi_log            type shp_badi_error_log_t,
        ls_badi_log            type shp_badi_error_log,
        ls_xlips               like line of xlips,            "n_1235633
        lf_cvbak_vbeln like cvbak-vbeln,                      "n_1127865
        lf_force_status_update type c.

  data: l_hdall LIKE VBUP-HDALL,                            "v_n_1492661
        l_posnr LIKE LIPS-POSNR.                            "^_n_1492661

  check not gi_badi_delivery is initial.           "n_530754/n_637289

  call method gi_badi_delivery->save_document_prepare
    exporting
      it_xvbuk               = xvbuk[]
      it_yvbuk               = yvbuk[]
      it_xvbup               = xvbup[]
      it_yvbup               = yvbup[]
      is_v50agl              = v50agl
      if_trtyp               = t180-trtyp
      if_tcode               = t180-tcode
    changing
      ct_xlikp               = xlikp[]
      ct_ylikp               = ylikp[]
      ct_xlips               = xlips[]
      ct_ylips               = ylips[]
      ct_xvbpa               = xvbpa[]
      ct_yvbpa               = yvbpa[]
      ct_xvbfa               = xvbfa[]
      ct_yvbfa               = yvbfa[]
      ct_xvbadr              = xvbadr[]
      cf_force_status_update = lf_force_status_update
      cs_v50agl_cust         = v50agl_cust
      ct_log                 = lt_badi_log.

* If status relevant changes are performed in user exit a status update
* can be triggered
  if lf_force_status_update ne space.
    SORT xlips BY mandt vbeln posnr updkz.                  "v_n_1554722
*   According to note 1492661 in XLIPS entries with UPDKZ = 'D'
*   come earlier than entries with UPDKZ = 'I' for the same VBELN
*   and POSNR, thus sort by UPDKZ is necessary in addition  "^_n_1554722
* lines replaced                                              v_n_659367
    loop at xlikp.
      move-corresponding xlikp to likp.

      if xlikp-updkz ne updkz_delete.

        call function 'RV_XVBAPF_CREATE'
          exporting
            vbeln   = xlikp-vbeln
          tables
            fxvbapf = xvbapf
            fxvbfa  = xvbfa.

        perform warenempfaenger_bereitstellen(sapmv50a).

        loop at xlips where vbeln eq xlikp-vbeln.
          if xlips-updkz ne updkz_delete.
            call function 'LIPS_STATUS_MAINTAIN'
              exporting
                f_likp   = likp
                f_posnr  = xlips-posnr
                land1_we = kuwev-land1
              tables
                fxlips   = xlips
                fxvbapf  = xvbapf
                fxvbup   = xvbup
                fyvbup   = yvbup
                fxvbfa   = xvbfa.                               "XAN-SPE

* in case there are two items in XLIPS with the same POSNR  "v_n_1492661
* (UPDKZ = D and I), on-hold status (VBUP-HDALL) of the
* deleted item is assigned to the item with UPDKZ = I.
            if l_posnr eq xlips-posnr and
               xlips-updkz eq updkz_new.
               read table xvbup with key vbeln = xlips-vbeln
                                         posnr = xlips-posnr.
                if sy-subrc = 0.
                 xvbup-hdall = l_hdall.
                 modify xvbup index sy-tabix.
                endif.
            endif.                                          "^_n_1492661.                                          "^_n_1492661

*
          else.
            if T180-TRTYP eq CHARV.                           "n_1235633
              CALL FUNCTION 'RV_XVBUP_DELETE'
              EXPORTING
                F_POSNR       = xlips-posnr
                F_VBELN       = xlips-vbeln
              TABLES
                FXVBUP        = xvbup
                FYVBUP        = yvbup.

* save XVBUP-HDALL of the deleted item                      "v_n_1492661
                 l_hdall = xvbup-hdall.
                 l_posnr = xlips-posnr.                     "^_n_1492661
                      .
            else.                                           "v_n_1235633
              ls_xlips = xlips.
              loop at xlips                                   "n_1236790
                   where vbeln = ls_xlips-vbeln
                     and posnr = ls_xlips-posnr
                     and updkz ne updkz_delete.
              endloop.
              if sy-subrc ne 0.
                CALL FUNCTION 'RV_XVBUP_DELETE'
                  EXPORTING
                    F_POSNR       = xlips-posnr
                    F_VBELN       = xlips-vbeln
                  TABLES
                    FXVBUP        = xvbup
                    FYVBUP        = yvbup.


              endif.
            endif.                                          "^_n_1235633
          endif.
        endloop.
      else.
        CALL FUNCTION 'RV_XVBUK_DELETE'
          EXPORTING
            F_VBELN       = xlikp-vbeln
          TABLES
            FXVBUK        = xvbuk
            FYVBUK        = yvbuk
                  .
      endif.
    endloop.                                                 "^_n_659367
*   Update header status of all processed deliveries
    perform xvbuk_pflegen(sapfv50k).

  endif.

* Message handling of messages issued by the BAdI
* Background processing (collective run):
* - All messages not of type A and X are transfered to error log
* Dialog processing:
* - Error messages are not allowed and transformed to 'A' messages
* - Warnings are changed to information messages if goods movements
*   posting is active
* - Messages of other types are issued
  if v50agl-sammelgang eq charx.
    lf_cvbak_vbeln = cvbak-vbeln.                              "n_1127865
    loop at lt_badi_log into ls_badi_log.
      if ls_badi_log-msgty ca 'AX'.
        message id     ls_badi_log-msgid
                type   ls_badi_log-msgty
                number ls_badi_log-msgno
                with   ls_badi_log-msgv1
                       ls_badi_log-msgv2
                       ls_badi_log-msgv3
                       ls_badi_log-msgv4.
      else.
        vbsk-ernum = vbsk-ernum + 1.
        cvbak-vbeln = ls_badi_log-vbeln.                      "n_1127865
        perform message_vbfs_aufbauen using vbsk-sammg
                                            ls_badi_log-posnr "n_1127865
                                            ls_badi_log-msgno
                                            ls_badi_log-msgty
                                            ls_badi_log-msgid
                                            ls_badi_log-msgv1
                                            ls_badi_log-msgv2
                                            ls_badi_log-msgv3
                                            ls_badi_log-msgv4.
      endif.
    endloop.
    cvbak-vbeln = lf_cvbak_vbeln.                             "n_1127865
  else.
    loop at lt_badi_log into ls_badi_log.
      case ls_badi_log-msgty.
        when 'E'.
          message id     ls_badi_log-msgid
                  type   'A'
                  number ls_badi_log-msgno
                  with   ls_badi_log-msgv1
                         ls_badi_log-msgv2
                         ls_badi_log-msgv3
                         ls_badi_log-msgv4.
        when 'W'.
          if v50agl-warenausgang     ne space or
             v50agl-warenausg_storno ne space.
            message id     ls_badi_log-msgid
                    type   'I'
                    number ls_badi_log-msgno
                    with   ls_badi_log-msgv1
                           ls_badi_log-msgv2
                           ls_badi_log-msgv3
                           ls_badi_log-msgv4.
          else.
            message id     ls_badi_log-msgid
                    type   'W'
                    number ls_badi_log-msgno
                    with   ls_badi_log-msgv1
                           ls_badi_log-msgv2
                           ls_badi_log-msgv3
                           ls_badi_log-msgv4.
          endif.
        when others.
          message id     ls_badi_log-msgid
                  type   ls_badi_log-msgty
                  number ls_badi_log-msgno
                  with   ls_badi_log-msgv1
                         ls_badi_log-msgv2
                         ls_badi_log-msgv3
                         ls_badi_log-msgv4.
      endcase.
    endloop.
  endif.

endform.                    " call_badi_save_doc_prep