*---------------------------------------------------------------------*
*       FORM FCODE_PTEX_SUB                                           *
*---------------------------------------------------------------------*
*       Übergang zum Positionstextbild mit XVBAP_DETAIL - Aufruf      *
*       FCODE_PTEX gibt es noch wegen Abwärtskompatibilität           *
*---------------------------------------------------------------------*
form fcode_ptex_sub.
  data: lv_screen_group like t185-bldgr.
  if fehler eq charx.
    perform xvbap_lesen_direkt(sapfv45p) using xvbuv-posnr
                                         changing svbap-tabix.
  else.
    call function 'LOCATION_EXTRACT'
      importing
        bildgruppe = lv_screen_group.
    if lv_screen_group = 'U0'.
      perform xvbap_detail(sapfv45p).
    endif.
  endif.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform vbap_fuellen_tvcom(sapfv45p).

endform.

form fcode_ptex.

  if fehler eq charx.
    perform xvbap_lesen_direkt(sapfv45p) using xvbuv-posnr
                                         changing svbap-tabix.
  else.
    perform xvbap_detail(sapfv45p).
  endif.
  perform tvap_select using xvbap-pstyv
                            space
                            sy-subrc.
  perform xthead_uebersicht_p_ansteuern(sapfv45t)
                                       using tvap-txtgr
                                             chara
                                             vbak-vbeln
                                             xvbap-posnr.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform vbap_fuellen_tvcom(sapfv45p).

endform.