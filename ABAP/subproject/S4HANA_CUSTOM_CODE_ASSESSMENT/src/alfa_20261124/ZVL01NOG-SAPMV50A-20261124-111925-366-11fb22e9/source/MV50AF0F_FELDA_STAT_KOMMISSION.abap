***INCLUDE MV50AF0F_FELDA_STAT_KOMMISSION
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_STAT_KOMMISSION                              *
*---------------------------------------------------------------------*
*       In Abhängigkeit von bereits erfolgten Aktivitäten des         *
*       LVS wird die Änderbarkeit der Lieferung                       *
*       eingeschränkt:                                                *
*---------------------------------------------------------------------*
form feldauswahl_stat_kommission changing cf_exit_flag type c.

  check: screen-input = 1.

* Positionsfelder
  if screen-name = 'LIPS-POSNR' or
     screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-MBDAT' or
     screen-name = 'LIPS-MBUHR'.
    if xvbup-kosta ca 'BC' or
       xvbup-lvsta eq charb.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
  if screen-name = 'LIPS-LFIMG' or                          "v_n_817541
     screen-name = 'LIPSD-G_LFIMG' or                         "n_853202
     screen-name = 'LIPS-LGMNG'.
    if xvbup-lvsta eq charb and likp-vbtyp <> vbtyp_liav.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
  if xvbup-lvsta = charb.
    if screen-name = 'LIPS-CHARG' or                        "^_n_817541
       screen-name = 'LIPS-BWTAR' or
       screen-name = 'LIPS-CHARG' or
       screen-name = 'LIPS-LGMNG' or
       screen-name = 'LIPS-VRKME' or
       screen-name = 'RV50A-VRKM1' or
       screen-name = 'LIPS-UMVKN' or
       screen-name = 'LIPS-UMVKZ' or
       screen-name = 'LIPS-MEINS'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
  if screen-name = 'LIPS-CHARG' or
     screen-name = 'LIPS-BWTAR'.
    if xvbup-lvsta = charc.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-VRKME'.
    if xvbup-kosta ca 'BC'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-WERKS' or
     screen-name = 'LIPS-LGORT'.
    if xvbup-kosta ca 'BC'.
      if ( screen-name = 'LIPS-WERKS' and lips-werks ne space ) or
         ( screen-name = 'LIPS-LGORT' and lips-lgort ne space ).
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

* Kopffelder
  if screen-name = 'LIKP-BEROT' or
     screen-name = 'LIKP-KODAT' or
     screen-name = 'LIKP-KOUHR'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                    "feldauswahl_stat_kommission