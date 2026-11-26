***INCLUDE MV50AF0F_FELDA_STAT_FAKTURA .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_STAT_FAKTURA                                 *
*---------------------------------------------------------------------*
*       In Abhängigkeit von bereits erfolgten Fakturen auf            *
*       eine  Lieferung wird die Änderbarkeit der Lieferung           *
*       eingeschränkt.                                                *
*---------------------------------------------------------------------*
form feldauswahl_stat_faktura changing cf_exit_flag type c.

  check: screen-input = 1.

* Item fields
ENHANCEMENT-SECTION     FELDAUSWAHL_STAT_FAKTURA_01 SPOTS ES_SAPMV50A.
  if screen-name = 'LIPS-PSTYV' or
     screen-name = 'LIPS-POSNR' or
     screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-BRGEW' or
     screen-name = 'LIPS-NTGEW' or
     screen-name = 'LIPS-GEWEI' or
     screen-name = 'LIPS-VOLUM' or
     screen-name = 'LIPS-VOLEH' or
     screen-name = 'LIPSD-G_LFIMG' or
     screen-name = 'LIPS-LFIMG' or
     screen-name = 'LIPS-LGMNG' or
     screen-name = 'LIPS-VRKME' or
     screen-name = 'RV50A-VRKM1' or
     screen-name = 'LIPS-MEINS' or
     screen-name = 'LIPS-UMVKN' or
     screen-name = 'LIPS-UMVKZ'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
END-ENHANCEMENT-SECTION.
  if screen-name eq 'LIPS-FAKSP'.
    if xvbup-fkivp ne chara.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Header fields
  if screen-name = 'LIKP-LFART' or
     screen-name = 'LIKP-KUNNR' or
     screen-name = 'LIKP-FKARV' or
     screen-name = 'LIKP-FKDAT' or
     screen-name = 'LIKP-VSBED' or
     screen-name = 'LIKP-VSTEL' or
     screen-name = 'LIKP-ANZPK' or
     screen-name = 'LIKP-BTGEW' or
     screen-name = 'LIKP-NTGEW' or
     screen-name = 'LIKP-GEWEI' or
     screen-name = 'LIKP-VOLUM' or
     screen-name = 'LIKP-VOLEH' or
     screen-name = 'LIKP-WAQUI' or
     screen-name = 'LIKP-INCO1' or
     screen-name = 'LIKP-INCO2'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name eq 'LIKP-FAKSK'.
    if xvbuk-fkivk ne chara.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                    "feldauswahl_stat_faktura