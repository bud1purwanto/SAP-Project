*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_COND_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  lord_cond_pai_multi
*&---------------------------------------------------------------------*
form lord_cond_pai_multi.

  perform kot_ende(saplv69a).

  if pricing_header is initial.
    check vbap-posar ne charb.
  endif.

  call function 'PRICING_SUBSCREEN_GET_DATA'
    importing
      comm_head_e      = tkomk
      comm_item_e      = tkomp
      calculation_type = global_pricing_type
    tables
      tkomv            = xkomv
      tkomp            = tkomp
    exceptions
      error            = 1
      others           = 2.

  if pricing_header is initial.
    t185f-trtyp = t180-trtyp.
    perform preisfindung_nachbereiten_pos(sapfv45p) using t185f
                                                          t185
                                                          t185v.
  else.
    if tkomp-fxmsg ne space.
      r185d-dataloss = charx.
      konv_geaendert = charx.
    endif.
    if not global_pricing_type is initial.
      perform preisfindung_gesamt using global_pricing_type.
    endif.
    if global_pricing_type ne chare.
      perform preisfindung_gesamt using chare.
    endif.
    modify tkomk index tkomp-ix_komk.
  endif.

endform.                    "lord_cond_pai_multi