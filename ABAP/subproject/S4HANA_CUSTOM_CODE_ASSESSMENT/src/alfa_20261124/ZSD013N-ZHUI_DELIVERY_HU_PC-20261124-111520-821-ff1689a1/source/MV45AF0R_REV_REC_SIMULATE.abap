*----------------------------------------------------------------------*
*   INCLUDE MV45AF0R_REV_REC_SIMULATE                                    *
*----------------------------------------------------------------------*

form rev_rec_simulate using vbeln.

  data: lvf_subrc like sy-subrc.
  data: lvs_komk like komk.
  data: lvs_xvbuk like vbukvb.
  data: lvs_yvbuk like vbukvb.
  data: lvs_xvbkd like vbkd.
  data: lvf_rrrel_relevant type xfeld.
  data: lvf_vbuk_changed type xfeld,
        lvf_vbup_changed type xfeld,
        lvt_xvbup type vbupvb occurs 0 with header line.

  read table xvbuk into lvs_xvbuk with key vbeln = vbak-vbeln.
  read table yvbuk into lvs_yvbuk with key vbeln = vbak-vbeln.

  read table xvbkd into lvs_xvbkd with key vbeln = vbak-vbeln.
  clear lvf_rrrel_relevant.

  While lvs_xvbkd-vbeln EQ vbak-vbeln.
   read table xvbkd into lvs_xvbkd index sy-tabix.
   If NOT lvs_xvbkd-rrrel is initial.
      lvf_rrrel_relevant = 'X'.
      exit.
   Elseif sy-subrc is initial.
      add 1 to sy-tabix.
      continue.
   Else.
      exit.
   Endif.
  Endwhile.

  If lvf_rrrel_relevant is initial.
   exit.
  Endif.

  if vbak-vbeln = vbeln.
    perform preisfindung_gesamt using 'A'.
    konv_geaendert = 'X'.
    lvs_komk = tkomk.
    refresh lvt_xvbup[].
    lvt_xvbup   = xvbup.
    lvt_xvbup[] = xvbup[].

    call function 'SD_REV_REC_SALES'
      exporting
        fif_vorgang        = t180-trtyp
        fis_xvbak          = vbak
        fis_yvbak          = yvbak
        fif_xvbak_updkz    = xvbak_updkz
        fif_yvbak_updkz    = yvbak_updkz
        fis_t001           = t001
        fis_komk           = lvs_komk
        fif_konv_geaendert = konv_geaendert
        fis_xvbuk          = xvbuk
        fis_tvak           = tvak
        fif_euro_active    = euro_active
      tables
        fit_xvbap          = xvbap
        fit_yvbap          = yvbap
        fit_xkomv          = xkomv
        fit_xvbkd          = xvbkd
        fit_yvbkd          = yvbkd
        fit_xfpla          = xfpla
        fit_xfplt          = xfplt
        fit_yfplt          = yfplt
        fit_xkomp          = tkomp
        fit_xvbup          = lvt_xvbup
        fit_xvbpa          = xvbpa
        fit_xvbep          = xvbep
        fit_xvbuv          = xvbuv
        fit_xvbfa          = xvbfa
      exceptions
        no_revenue_lines   = 1
        others             = 2.
    if sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    else.
*     Determine status
      call function 'SD_SET_REVREC_STATUS'
        exporting
          fif_vorgang      = t180-trtyp
          fis_vbeln        = vbak-vbeln
        importing
          fef_vbuk_changed = lvf_vbuk_changed
          fef_vbup_changed = lvf_vbup_changed
        tables
          fit_xvbuk        = xvbuk
          fit_xvbup        = xvbup
          fit_yvbup        = yvbup
          fit_yvbuk        = yvbuk
          fit_rev_xvbup    = lvt_xvbup.

    endif.

  endif.

endform.                    "REV_REC_UPDATE