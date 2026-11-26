*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CALL_BADI_READ_DELIVE                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  call_badi_read_delivery
*&---------------------------------------------------------------------*
form call_badi_read_delivery.

  data: lf_force_status_update type c.

  field-symbols: <ls_xlikp> like line of xlikp.              "n_1071429

  check not gi_badi_delivery is initial.           "n_530754/n_637289

  call method gi_badi_delivery->read_delivery
    exporting
      it_xvbuk               = xvbuk[]
      it_yvbuk               = yvbuk[]
      it_xvbup               = xvbup[]
      it_yvbup               = yvbup[]
      is_v50agl              = v50agl
      if_trtyp               = t180-trtyp
      if_tcode               = t180-tcode
    changing
      cs_likp                = likp
      cs_likpd               = likpd
      ct_ylikp               = ylikp[]
      ct_xlips               = xlips[]
      ct_ylips               = ylips[]
      ct_xvbpa               = xvbpa[]
      ct_yvbpa               = yvbpa[]
      ct_xvbfa               = xvbfa[]
      ct_yvbfa               = yvbfa[]
      ct_xvbadr              = xvbadr[]
      cf_force_status_update = lf_force_status_update
      cs_v50agl_cust         = v50agl_cust.

* Synchronize xlikp and likp/likpd                         "v_n_1071429
  if not xlikp[] is initial.
    read table xlikp assigning <ls_xlikp> with key vbeln = likp-vbeln.
    if sy-subrc eq 0.
      move-corresponding likp to <ls_xlikp>.
      move-corresponding likpd to <ls_xlikp>.
    endif.
  endif.                                                   "^_n_1071429


* If status relevant changes are performed in user exit a status update
* can be triggered
  if lf_force_status_update ne space.

    if xlikp[] is initial.                                 "v_n_1071429

      call function 'RV_XVBAPF_CREATE'
        exporting
          vbeln   = likp-vbeln
        tables
          fxvbapf = xvbapf
          fxvbfa  = xvbfa.

      perform warenempfaenger_bereitstellen(sapmv50a).

      loop at xlips where vbeln eq likp-vbeln
                      and updkz ne updkz_delete.

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
            fxvbfa   = xvbfa.
      endloop.

    else.                                                  "^_n_1071429

    loop at xlikp where updkz ne updkz_delete.
      move-corresponding xlikp to likp.

      call function 'RV_XVBAPF_CREATE'
        exporting
          vbeln   = xlikp-vbeln
        tables
          fxvbapf = xvbapf
          fxvbfa  = xvbfa.

      perform warenempfaenger_bereitstellen(sapmv50a).

      loop at xlips where vbeln eq xlikp-vbeln
                      and updkz ne updkz_delete.

        call function 'LIPS_STATUS_MAINTAIN'
          exporting
            f_likp   = likp
              f_posnr  = xlips-posnr                         "n_1071429
            land1_we = kuwev-land1
          tables
            fxlips   = xlips
            fxvbapf  = xvbapf
            fxvbup   = xvbup
            fyvbup   = yvbup
            fxvbfa   = xvbfa.                                   "XAN-SPE

      endloop.
    endloop.

    endif.                                                   "n_1071429

*   Update header status of all processed deliveries
    perform xvbuk_pflegen(sapfv50k).

  endif.


endform.                    " call_badi_read_delivery