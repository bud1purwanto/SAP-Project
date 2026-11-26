***INCLUDE MV50AF0F_FELDA_STAT_LVS .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_STAT_LVS                                     *
*---------------------------------------------------------------------*
*       In Abhängigkeit vom Vorhandensein des LVS werden bestimmte    *
*       Felder ausgeblendet (nicht unbedingt im neuen Dialog)         *
*---------------------------------------------------------------------*
form feldauswahl_stat_lvs changing cf_exit_flag.

  if screen-name = 'LIPS-LGNUM' or
     screen-name = 'LIPS-LGTYP' or
     screen-name = 'LIPS-LGPLA' or
     screen-name = 'LIPS-LGBZO' or
     screen-name = 'T300T-LNUMT'.
    if lips-komkz ca ' A'.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'VBUP-LVSTA' or
     screen-name = 'VBSTT-LVSTA_BEZ'.
    if lips-komkz ca ' A'.
      if t180-bldgr eq gc_new_dialog_outb
         or t180-bldgr eq gc_new_dialog_inb.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      else.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

  if screen-name = 'LIPS-LGNUM' and likp-vbtyp ca vbtyp_liav
                                and lips-lgnum ne space.
    screen-active = 1.
  endif.
  if screen-name = 'LIPS-LGPBE' and
     lips-komkz ca 'BCD12'.
    screen-active = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPSD-PIKMG'.
    if lips-komkz ca 'C12 '.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
*   Lean-WM und Relevant für WM ?
    elseif lips-komkz =  'D' and
           vbup-lvsta ca 'AB'.
*  Im Lean-WM wird die Pickmenge nach erfolgter Quittierung wieder
* geöffnet
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name eq 'LIPS-LGBZO' and
     screen-active eq 1.
    if lips-lgnum is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Storage location and plant is not changeable
* if HU managed and item is packed
  if screen-name = 'LIPS-LGORT' or                                 "HUM
     screen-name = 'LIPS-WERKS'.
    if not lips-hupos is initial and
           vbup-pksta ca 'BC'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                    "FELDAUSWAHL_STAT_LVS