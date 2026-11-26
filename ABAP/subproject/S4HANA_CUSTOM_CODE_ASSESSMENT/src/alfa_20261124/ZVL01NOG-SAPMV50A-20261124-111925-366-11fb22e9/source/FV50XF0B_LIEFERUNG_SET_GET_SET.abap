***INCLUDE FV50XF0B_LIEFERUNG_SET_GET_SET .
*---------------------------------------------------------------------*
*       FORM LIEFERUNG_SET_GET_SETZEN                                 *
*---------------------------------------------------------------------*
form lieferung_set_get_setzen.

  data: vbeln_von    like likp-vbeln,
        vbeln_bis    like likp-vbeln.

  case xlikp-vbtyp.                                         "HP_352369
    when vbtyp_liav.
      set parameter id 'VLM' field xlikp-vbeln.
    when vbtyp_grwe.
      set parameter id 'VLG' field xlikp-vbeln.
    when others.
      set parameter id 'VL ' field xlikp-vbeln.
  endcase.
* bei Grob-WE wird auch empfangendes Werk gesetzt
  if xlikp-vbtyp eq vbtyp_grwe.                             "HP_352369
    set parameter id 'WRK' field rv50a-werks.
  endif.

  if vbuk-vbeln ne xlikp-vbeln.
    perform xvbuk_lesen(sapfv50k) using xlikp-vbeln.
  endif.
  if vbuk-fkstk ca 'AB' or vbuk-fkivk ca 'AB'.
    set parameter id 'VFR' field xlikp-vbeln.
  endif.

  if sy-binpt eq charx.
    if ylikp_updkz = updkz_delete.
      message s310 with tvlkt-vtext xlikp-vbeln.
    else.
      if ( kz_lieferavis eq charx or t180-tcode = 'VL31N' ) and
         not vbeln_bis is initial.
        message s139 with tvlkt-vtext vbeln_von vbeln_bis.
      else.
        message s311 with tvlkt-vtext xlikp-vbeln.
      endif.
    endif.
  endif.

endform.