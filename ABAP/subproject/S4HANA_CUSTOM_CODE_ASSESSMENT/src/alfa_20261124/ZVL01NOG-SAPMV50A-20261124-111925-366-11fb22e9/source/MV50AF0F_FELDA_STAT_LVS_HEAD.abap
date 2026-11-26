*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDA_STAT_LVS_HEAD                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_STAT_LVS_HEAD
*&---------------------------------------------------------------------*
form feldauswahl_stat_lvs_head changing cf_exit_flag type c.

  check screen-input eq 1.

  if screen-name eq 'LIKP-LGTOR' or
     screen-name eq 'LIKP-LGBZO'.
    if likp-lgnum is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                               " FELDAUSWAHL_STAT_LVS_HEAD