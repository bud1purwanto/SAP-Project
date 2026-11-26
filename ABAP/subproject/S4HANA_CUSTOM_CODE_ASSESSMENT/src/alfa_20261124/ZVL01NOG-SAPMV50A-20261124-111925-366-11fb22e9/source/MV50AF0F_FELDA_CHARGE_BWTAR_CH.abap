***INCLUDE MV50AF0F_FELDA_CHARGE_BWTAR_CH .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_CHARGE_BWTAR_CHSP                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form feldauswahl_charge_bwtar_chsp changing cf_exit_flag type c.

  if screen-name = 'LIPS-CHARG' and
     clips-xchpf eq space.
    screen-active = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-BWTAR' and
     ( clips-xchar eq space      or
       clips-xchpf eq charx ).
    screen-active = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                    "FELDAUSWAHL_CHARGE_BWTAR_CHSP