***INCLUDE MV50AF0F_FELDA_LGORT_CHSP .
*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_LGORT_CHSP
*&---------------------------------------------------------------------*
*       Feld Lagerort im Splitbild                                     *
*----------------------------------------------------------------------*
form feldauswahl_lgort_chsp changing cf_exit_flag type c.

  if screen-name = 'LIPS-LGORT'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                               " FELDAUSWAHL_LGORT_CHSP