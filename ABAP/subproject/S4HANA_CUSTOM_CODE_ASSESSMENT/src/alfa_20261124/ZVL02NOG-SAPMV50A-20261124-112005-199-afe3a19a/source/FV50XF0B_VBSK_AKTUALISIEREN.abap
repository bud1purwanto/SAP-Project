***INCLUDE FV50XF0B_VBSK_AKTUALISIEREN .
*---------------------------------------------------------------------*
*       FORM VBSK_AKTUALISIEREN                                       *
*---------------------------------------------------------------------*
*  -->  IF_TEMP_VBELN                                                 *
*---------------------------------------------------------------------*
form vbsk_aktualisieren using if_temp_vbeln like likp-vbeln.

  data: bs_strat(1)  value ' ',        "Summen in großer Einheit
        bs_summe     like likp-btgew.
  field-symbols: <ls_cvbfs> type vbfs.

  vbsk-vbnum = vbsk-vbnum + 1.

  if vbsk-gewei eq space.
    vbsk-gewei = xlikp-gewei.
  endif.
  bs_summe = vbsk-brgew.
  perform likp_werte_umrechnen(sapfv50k)
          using xlikp-btgew   xlikp-gewei
                bs_summe      vbsk-gewei
                bs_strat     char_plus.
*        Abfangen Überlauf
  if bs_summe > 9999999999.
    vbsk-brgew = 9999999999.
  else.
    vbsk-brgew = bs_summe.
  endif.

  if vbsk-voleh eq space.
    vbsk-voleh = xlikp-voleh.
  endif.
  bs_summe = vbsk-volum.
  perform likp_werte_umrechnen(sapfv50k)
          using xlikp-volum   xlikp-voleh
                bs_summe      vbsk-voleh
                bs_strat     char_plus.
*        Abfangen Überlauf
  if bs_summe > 9999999999.
    vbsk-volum = 9999999999.
  else.
    vbsk-volum = bs_summe.
  endif.

* Tabelle VBSS fortgeschrieben
  cvbss-mandt      = xlikp-mandt.
  cvbss-sammg      = vbsk-sammg.
  cvbss-vbeln      = xlikp-vbeln.
  append cvbss.

  loop at cvbfs assigning <ls_cvbfs>
                where   msgv1 eq if_temp_vbeln
                  and   msgid eq 'VL'
                  and ( msgno eq '196' or msgno eq '256' ).
    replace if_temp_vbeln with xlikp-vbeln into <ls_cvbfs>-msgv1.
    clear <ls_cvbfs>-vbeln.
  endloop.

endform.                    "VBSK_AKTUALISIEREN