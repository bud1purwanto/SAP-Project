***INCLUDE MV50AF0F_FELDA_VRKME_KZFME_CHS .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_VRKME_KZFME_CHSP                             *
*---------------------------------------------------------------------*
*       Eingabesteuerung VRKME auf Splitbild                          *
*---------------------------------------------------------------------*
form feldauswahl_vrkme_kzfme_chsp changing cf_exit_flag type c.

* Anteils-/variable Mengeneinheit auf der übergeordneten Position
  if clips-kzfme ca kzfme_ws.
    if screen-name = 'LIPS-VRKME'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                    "FELDAUSWAHL_VRKME_KZFME_CHSP