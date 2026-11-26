***INCLUDE MV50AF0F_FCODE_PKON .
*---------------------------------------------------------------------*
*       FORM FCODE_PKON                                               *
*---------------------------------------------------------------------*
*       Übergang zum Positionspreisbild via Dialogbaustein            *
*---------------------------------------------------------------------*
form fcode_pkon using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

  data: lf_display_mode type c,
        ls_xvbuk        like line of xvbuk,
        lf_bildtext(40) type c.

  t185  = h185.
  t185f = h185f.
  t185v = h185v.

  perform p_komk_komp_fuellen(sapfv50p) using 'P'.
  if not tkomp-prsfd is initial.

    lf_display_mode = ' '.
    read table xvbuk into ls_xvbuk
                     with key vbeln = likp-vbeln
                     binary search.
    if ls_xvbuk-fkstk ca 'BC'.
      lf_display_mode = 'X'.
    endif.

* userexit for screen input at pricing screen                  "n_693000
  perform userexit_pricing_screen_input in program sapmv50a
                                        changing lf_display_mode.
*   Bildtext für Dialogbaustein aufbauen
    lf_bildtext    = tvlkt-vtext.
    condense lf_bildtext.
    export fehler to memory id 'PKON'.
    call function 'PRICING_SCREEN'
      exporting
        comm_head_i   = tkomk
        comm_item_i   = tkomp
        comm_text     = lf_bildtext
        material_text = xlips-arktx
        trtyp_i       = t185f-trtyp
        display_only  = lf_display_mode
      importing
        comm_head_e   = tkomk
        comm_item_e   = tkomp
      tables
        tkomv         = tkomv.

    if tkomp-fxmsg ne space.
      perform kompax_fill_from_komp(saplv61a)
          using    tkomp
                   0
          changing kompax.
      move-corresponding kompax to lips.
      likp-netwr = likp-netwr + lips-netwr - *lips-netwr.
      perform xlips_aendern(sapfv50p).
    endif.
  else.
    t185f-fcode = 'BACK'.
  endif.
  h185  = t185.
  h185f = t185f.
  h185v = t185v.
  fcode = t185f-fcode.

endform.                    "FCODE_PKON