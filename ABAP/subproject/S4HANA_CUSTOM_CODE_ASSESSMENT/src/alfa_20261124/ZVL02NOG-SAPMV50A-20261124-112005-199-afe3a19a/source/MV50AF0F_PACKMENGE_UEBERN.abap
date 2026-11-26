*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_PACKMENGE_UEBERN                                  *
*----------------------------------------------------------------------*
* wirkstoff ist noch nicht berücksichtigt und vbfa wird für WM nicht
* reduziert, da es mehrere Flußsätze geben kann.
form fcode_pamu.
  data: ls_vbfa type vbfa,
        ls_xvbup like line of xvbup.                         "n_1044726
  data: lf_diff type vbfa-rfmng, lf_diff_flt type vbfa-rfmng_flt,
        lf_diff_flo type vbfa-rfmng_flo, lf_tabix type sytabix,
        lf_packmenge type vbapf-xmenge,
        lf_not_picked type xflag,
        lf_unconf_pick type xflag,                           "n_1047902
        lf_packmengev type vbapf-xmengev.
  data: lf_vbapf_tabix type sytabix,
        lf_rfmng_new type rfmng.

  data: lf_save_diff like lips-lfimg.                          "n_600177
  data: lf_msgty like sy-msgty,                             "v_n_1653885
        lf_rcode like sy-subrc,
        lf_msgno like sy-msgno.                             "^_n_1653885

  field-symbols: <lips> type lipsvb, <vbapf> type vbapf,
                 <vbfa> type vbfavb.

  if xvbuk-wbstk = 'C'.                                     "v_n_1239342
    message e602.
    exit.
  endif.                                                    "^_n_1239342

* Check if picking is allowed                               "v_n_1653885
* first packed qty will be copied to picked qty
  call function 'SD_DELIVERY_SUBSEQUENT_ALLOWED'
       exporting
            blikp   = likp
            bvbuk   = xvbuk
            fofun   = fofun_kommi
       exceptions
            error   = 1
            warning = 2
            others  = 3.
  case sy-subrc.
    when 1 or 3.
      lf_msgty = chare.
    when 2.
      lf_msgty = charw.
    when others.
      lf_msgty = space.
  endcase.
  if lf_msgty ne space.
     lf_msgno = sy-msgno.
     perform message_handling_variabel(sapmv50a)
                using lips-posnr
                      lf_msgno
                      lf_msgty
                      sy-msgid
                      sy-msgv1
                      sy-msgv2
                      sy-msgv3
                      sy-msgv4
                      gs_mhpar
                      v50agl-msgvs
            changing  lf_msgty
                      lf_rcode.
  endif.                                                    "^_n_1653885

  loop at xlips assigning <lips> where vbeln = xlikp-vbeln and
                                       updkz ne updkz_delete.
    check <lips>-komkz ne space.               "not relevant for picking
    check <lips>-pckpf ne 'B'.                  "not packable
    check <lips>-posar ne 'C'.                  "no generated packitems
    read table xvbapf assigning <vbapf> with key vbeln = <lips>-vbeln
                                                 posnr = <lips>-posnr
                                        binary search.
    check sy-subrc is initial.
    lf_vbapf_tabix = sy-tabix.
    if <vbapf>-xmenge is initial
       and v50agl-no_lfimg_check_mng0p is initial.
      perform tvlp_select(sapmv50a) using <lips>-pstyv sy-subrc.
      if sy-subrc is initial and tvlp-mng0p eq charb.
        message s870 with <lips>-posnr <lips>-pstyv.
        continue.
      endif.
    endif.
    lf_packmenge  = <vbapf>-xmenge.
    lf_packmengev = <vbapf>-xmengev.
    if <lips>-komkz cn ' A'.
      check <vbapf>-xmenge < <vbapf>-qmenge.
    else.
      check <vbapf>-xmenge <> <vbapf>-qmenge.
    endif.
    lf_diff_flt = <vbapf>-qmenge - <vbapf>-xmenge.
    lf_diff = lf_diff_flt.
    lf_save_diff = lf_diff.                                    "n_600177
    lf_diff_flo = <vbapf>-qmengev - <vbapf>-xmengev.
    clear: lf_not_picked, ls_vbfa.
    if  <vbapf>-qmenge = 0. "not picked yet
      lf_diff_flt = - lf_diff_flt.
      lf_diff =  lf_diff_flt.
      lf_diff_flo = - lf_diff_flo.
      lf_not_picked = 'X'.
    endif.
    loop at xvbfa transporting no fields where vbelv = <lips>-vbeln and
                                               posnv = <lips>-posnr and
                                               vbtyp_n = 'Q' and
                                               rfmng > 0 and
                                               plmin ca ' +'.
      lf_tabix = sy-tabix.
      exit.
    endloop.
    if not sy-subrc is initial.
      if <lips>-komkz is initial.                "Item not pickrelevant
        <vbapf>-qmenge = <vbapf>-xmenge.
        <vbapf>-qmengev = <vbapf>-xmengev.
        continue.
      else.
        read table xvbfa assigning <vbfa> with key vbelv = <lips>-vbeln
                                                   posnv = <lips>-posnr
                                                   vbtyp_n = 'X'.
        check sy-subrc is initial.
        ls_vbfa-mandt = <vbfa>-mandt.
        ls_vbfa-vbelv = <lips>-vbeln.
        ls_vbfa-posnv = <lips>-posnr.
        ls_vbfa-vbeln = <vbfa>-vbeln.
        ls_vbfa-posnn = <vbfa>-posnn.
        ls_vbfa-meins = <vbfa>-meins.
        ls_vbfa-plmin = space.                               "n_1680911
        ls_vbfa-vbtyp_v = <vbfa>-vbtyp_v.                    "n_1680911
        lf_diff = - lf_diff.
        lf_diff_flt = - lf_diff_flt.
        lf_diff_flo = - lf_diff_flo.
        ls_vbfa-vbtyp_n = 'Q'.
        include incl_v50a_pakmg.
      endif.
    else.
      clear lf_unconf_pick.                                  "n_1047902
      loop at xvbfa transporting no fields                   "SP_561868
                    where vbelv = <lips>-vbeln and
                          posnv = <lips>-posnr and
                          vbtyp_n = 'Q'        and
                          not plmin = '-'      and
                          rfmng > 0            and
                          taqui is initial.
        read table xvbup into ls_xvbup                     "v_n_1044726
                         with key vbeln = <lips>-vbeln
                                  posnr = <lips>-posnr.
        check ls_xvbup-koqua eq 'B' or                     "^_n_1044726
              ls_xvbup-lvsta eq 'B'.                         "n_1047902
        write <lips>-posnr to sy-msgv1 using edit mask '==ALPHA'.
        message w644 with sy-msgv1.
        lf_unconf_pick = 'X'.                                "n_1047902
        exit.
      endloop.
      if not lf_unconf_pick is initial.                      "n_1047902
        continue.
      endif.
      loop at xvbfa into ls_vbfa from lf_tabix.
        if not ls_vbfa-vbelv = <lips>-vbeln or
           not ls_vbfa-posnv = <lips>-posnr or
           not ls_vbfa-vbtyp_n = 'Q'.
          exit.
        endif.
        check not ls_vbfa-plmin = '-'.
        check ls_vbfa-rfmng > 0.
        include incl_v50a_pakmg.
        if lf_diff is initial.
          continue.
        else.
          read table xvbapf assigning <vbapf> index lf_vbapf_tabix.
        endif.
      endloop.
    endif.
    if lf_packmengev is initial.
      <lips>-pikmg = lf_packmenge * <lips>-umvkz / <lips>-umvkn.
    else.
      <lips>-pikmg = lf_packmengev.
    endif.

ENHANCEMENT-POINT MV50AF0F_PACKMENGE_UEBERN_01 SPOTS ES_SAPMV50A.

    perform uc_upd_request(sapfv50u) using space              "n_617069
                                           <lips>-posnr
                                           <lips>-uecha
                                           <lips>-uepos.
*    if not lf_not_picked is initial.                        "v_n_600177
     if not lf_not_picked is initial or lf_save_diff <> 0.   "^_n_600177
* wenn noch nicht kommissioniert wurde, muss auch der Status
* gesetzt werden, bevor die Pickmenge als Liefermenge übernommen wird
      call function 'LIPS_STATUS_MAINTAIN'
        exporting
          f_likp  = likp
          f_posnr = <lips>-posnr
        tables
          fxlips  = xlips
          fxvbapf = xvbapf
          fxvbup  = xvbup
          fyvbup  = yvbup
          fxvbfa  = xvbfa.                                      "XAN-SPE
    endif.
  endloop.


  perform fcode_komu.
endform.                    "FCODE_PAMU