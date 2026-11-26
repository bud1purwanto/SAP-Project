***INCLUDE MV50AF0F_FELDA_STAT_TRANSPORT .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_STAT_TRANSPORT                               *
*---------------------------------------------------------------------*
*       In Abhängigkeit vom Status von Transporten, in denen          *
*       eine Lieferung ist, wird die Änderbarkeit der Lieferung       *
*       eingeschränkt:                                                *
*---------------------------------------------------------------------*
form feldauswahl_stat_transport changing cf_exit_flag type c.

  check: screen-input = 1.

* Positionsfelder
  if screen-name = 'LIPS-PSTYV' or
     screen-name = 'LIPS-POSNR' or
     screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-SERNR' or
     screen-name = 'LIPS-AESKD' or
     screen-name = 'LIPS-ARKTX' or
     screen-name = 'LIPS-WERKS' or
     screen-name = 'LIPS-LGORT' or
     screen-name = 'LIPS-CHARG' or
     screen-name = 'LIPS-BRGEW' or
     screen-name = 'LIPS-NTGEW' or
     screen-name = 'LIPS-GEWEI' or
     screen-name = 'LIPS-VOLUM' or
     screen-name = 'LIPS-VOLEH' or
     screen-name = 'LIPSD-G_LFIMG' or
     screen-name = 'LIPS-LFIMG' or
     screen-name = 'LIPS-LGMNG' or
     screen-name = 'LIPSD-PIKMG' or
     screen-name = 'LIPS-VRKME' or
     screen-name = 'RV50A-VRKM1' or
     screen-name = 'LIPS-VRKM1' or
     screen-name = 'LIPS-MEINS' or
     screen-name = 'LIPS-UMVKN' or
     screen-name = 'LIPS-UMVKZ' or
     screen-name = 'LIPS-UEPOS' or
     screen-name = 'LIPS-EMPST' or
     screen-name = 'LIPS-MFRGR' or                          "470
     screen-name = 'LIPS-MBDAT' or
     screen-name = 'LIPS-MBUHR'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

* Kopffelder
  if screen-name = 'LIKP-LFART' or
     screen-name = 'LIKP-AUTLF' or
     screen-name = 'LIKP-TPMID' or
     screen-name = 'LIKP-KUNNR' or
     screen-name = 'LIKP-LIFSK' or
     screen-name = 'LIKP-LPRIO' or
     screen-name = 'LIKP-VSBED' or
     screen-name = 'LIKP-VSTEL' or
     screen-name = 'LIKP-LSTEL' or
     screen-name = 'LIKP-LIFEX' or
     screen-name = 'LIKP-ABLAD' or
     screen-name = 'LIKP-ROUTE' or
     screen-name = 'LIKP-BEROT' or
     screen-name = 'LIKP-KODAT' or
     screen-name = 'LIKP-KOUHR' or
     screen-name = 'LIKP-LDDAT' or
     screen-name = 'LIKP-LDUHR' or
     screen-name = 'LIKP-TDDAT' or
     screen-name = 'LIKP-TDUHR' or
     screen-name = 'LIKP-WADAT' or
     screen-name = 'LIKP-WAUHR' or
     screen-name = 'LIKP-LFDAT' or
     screen-name = 'LIKP-LFUHR' or
     screen-name = 'LIKP-ANZPK' or
     screen-name = 'LIKP-BTGEW' or
     screen-name = 'LIKP-NTGEW' or
     screen-name = 'LIKP-GEWEI' or
     screen-name = 'LIKP-VOLUM' or
     screen-name = 'LIKP-VOLEH' or
     screen-name = 'LIKP-WAQUI' or
     screen-name = 'LIKP-INCO1' or
     screen-name = 'LIKP-INCO2' or
     screen-name = 'LIKP-PROLI' or
     screen-name = 'LIKP-XABLN'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                    "FELDAUSWAHL_STAT_TRANSPORT