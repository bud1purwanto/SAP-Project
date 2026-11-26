*---------------------------------------------------------------------*
*       FORM FCODE_KKON                                               *
*---------------------------------------------------------------------*
*       Es wird das Kopf-Preisbild angesteuert                        *
*---------------------------------------------------------------------*
form fcode_kkon using h185f structure t185f h185  structure t185
                                            h185v structure t185v.

  data: lf_display_mode type c,
        ls_xvbuk        like line of xvbuk,
        lf_bildtext(40) type c.

  t185  = h185.
  t185f = h185f.
  t185v = h185v.

  perform preisfindung_gesamt using chara.

  perform p_komk_komp_fuellen(sapfv50p) using 'K'.

  lf_display_mode = ' '.
  if likp-kalsp is initial.
    lf_display_mode = 'X'.
  endif.

  read table xvbuk into ls_xvbuk
                   with key vbeln = likp-vbeln
                   binary search.
  if ls_xvbuk-fkstk ca 'BC'.
    lf_display_mode = 'X'.
  endif.

* userexit for screen input at pricing screen                  "n_693000
  perform userexit_pricing_screen_input in program sapmv50a
                                        changing lf_display_mode.

* Bildtext für Dialogbaustein aufbauen
  lf_bildtext    = tvlkt-vtext.
  condense lf_bildtext.

  call function 'PRICING_SCREEN'
    exporting
      comm_head_i      = tkomk
      comm_item_i      = tkomp
      comm_text        = lf_bildtext
      trtyp_i          = t185f-trtyp
      display_only     = lf_display_mode
    importing
      comm_head_e      = tkomk
      comm_item_e      = tkomp
      calculation_type = global_pricing_type
    tables
      tkomv            = tkomv.

  if tkomp-fxmsg ne space.
    r185d-dataloss = charx.
*   konv_geaendert = charx.
  endif.

  if not global_pricing_type is initial.
    perform preisfindung_gesamt using global_pricing_type.
  endif.
  if global_pricing_type ne chare.
    perform preisfindung_gesamt using chare.
  endif.

  modify tkomk index tkomp-ix_komk.

  h185  = t185.
  h185f = t185f.
  h185v = t185v.
  fcode = t185f-fcode.

endform.                    "FCODE_KKON