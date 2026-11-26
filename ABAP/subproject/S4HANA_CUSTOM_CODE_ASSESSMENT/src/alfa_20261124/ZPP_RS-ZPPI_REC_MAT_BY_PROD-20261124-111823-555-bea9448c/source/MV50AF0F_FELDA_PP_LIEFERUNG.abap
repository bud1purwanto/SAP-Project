*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDA_PP_LIEFERUNG                                *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_PP_LIEFERUNG (HUM)
*&---------------------------------------------------------------------*
*       Feldauswahl für Lieferungen aus PP-Schnittstelle
*----------------------------------------------------------------------*
form feldauswahl_pp_lieferung changing cf_exit_flag type c.

  check screen-input eq 1.

  if screen-name = 'LIPS-PSTYV' or     "currently not supported
     screen-name = 'LIPS-POSNR' or     "never changeable
     screen-name = 'LIPS-MATNR' or     "never changeable
*    screen-name = 'LIPS-SERNR' OR
*    screen-name = 'LIPS-AESKD' OR
*    screen-name = 'LIPS-ARKTX' OR
     screen-name = 'LIPS-WERKS' or     "never changeable
     screen-name = 'LIPS-LGORT' or     "never changeable
*    screen-name = 'LIPS-UEBTO' OR
*    screen-name = 'LIPS-UNTTO' OR
*    screen-name = 'LIPS-KZTLF' OR
*    screen-name = 'LIPS-UEBTK' OR
     screen-name = 'LIPS-CHARG' or     "changeable only by WM TOs
*    screen-name = 'LIPS-BRGEW' OR
*    screen-name = 'LIPS-NTGEW' OR
*    screen-name = 'LIPS-GEWEI' OR
*    screen-name = 'LIPS-VOLUM' OR
*    screen-name = 'LIPS-VOLEH' OR
     screen-name = 'LIPSD-G_LFIMG' or  "never changeable
     screen-name = 'LIPS-LFIMG' or     "never changeable
     screen-name = 'LIPS-LGMNG' or     "never changeable
*    screen-name = 'LIPSD-PIKMG' OR
     screen-name = 'LIPS-VRKME' or     "never changeable
     screen-name = 'RV50A-VRKM1' or    "never changeable
     screen-name = 'LIPS-MEINS' or     "never changeable
     screen-name = 'LIPS-UMVKN' or     "never changeable
     screen-name = 'LIPS-UMVKZ' or     "never changeable
*    screen-name = 'LIPS-EMPST' OR
*    screen-name = 'LIPS-MBDAT' OR
     screen-name = 'LIPS-UEPOS'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

* New items can not be created
  if lips-matnr is initial.
    if screen-name = 'LIPS-LFIMG' or
       screen-name = 'LIPS-VRKME' or
       screen-name = 'LIPS-BRGEW' or
       screen-name = 'LIPS-NTGEW' or
       screen-name = 'LIPS-GEWEI' or
       screen-name = 'LIPS-VOLUM' or
       screen-name = 'LIPS-VGBEL' or
       screen-name = 'LIPS-VGPOS' or
       screen-name = 'LIPS-VOLEH' or
       screen-name = 'LIPS-ARKTX' or
       screen-name = 'LIPS-CHARG' or
       screen-name = 'LIPS-KZTLF' or
       screen-name = 'LIPS-UEBTK' or
       screen-name = 'LIPS-UEBTO' or
       screen-name = 'LIPS-PROFL' or
       screen-name = 'LIPS-MBDAT' or
       screen-name = 'LIPS-MBUHR' or
       screen-name = 'LIPS-BWTAR' or
       screen-name = 'LIPSD-G_LFIMG' or
       screen-name = 'LIPSD-PIKMG' or
       screen-name = 'LIPSD-VRKMP' or
       screen-name = 'LIPSD-CHMULT' or
       screen-name = 'RV50A-LFPMG' or
       screen-name = 'RV50A-VRKM1' or
       screen-name = 'VBUP-KOSTA' or
       screen-name = 'VBUP-LVSTA'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Header fields
  if screen-name = 'LIKP-LFART' or
     screen-name = 'LIKP-AUTLF' or
     screen-name = 'LIKP-KUNNR' or
     screen-name = 'LIKP-VERUR' or
     screen-name = 'RV50A-VERUR_LA' or
*    screen-name = 'RV50A-KDMAT_LA' OR
*    screen-name = 'LIKP-LIFSK' OR
*    screen-name = 'LIKP-LPRIO' OR
*    screen-name = 'LIKP-VSBED' OR
*    screen-name = 'LIKP-LSTEL' OR
*    screen-name = 'LIKP-LIFEX' OR
*    screen-name = 'LIKP-ABLAD' OR
*    screen-name = 'LIKP-ROUTE' OR
*    screen-name = 'LIKP-BEROT' OR
*    screen-name = 'LIKP-TRATY' OR
*    screen-name = 'LIKP-TRAID' OR
*    screen-name = 'LIKP-BOLNR' OR
*    screen-name = 'LIKP-KODAT' OR
*    screen-name = 'LIKP-KOUHR' OR
*    screen-name = 'LIKP-LDDAT' OR
*    screen-name = 'LIKP-LDUHR' OR
*    screen-name = 'LIKP-TDDAT' OR
*    screen-name = 'LIKP-TDUHR' OR
*    screen-name = 'LIKP-WADAT' OR
*    screen-name = 'LIKP-WAUHR' OR
*    screen-name = 'LIKP-WADAT_IST' OR
*    screen-name = 'LIKP-LFDAT' OR
*    screen-name = 'LIKP-LFUHR' OR
*    screen-name = 'LIKP-ANZPK' OR
*    screen-name = 'LIKP-BTGEW' OR
*    screen-name = 'LIKP-NTGEW' OR
*    screen-name = 'LIKP-GEWEI' OR
*    screen-name = 'LIKP-VOLUM' OR
*    screen-name = 'LIKP-VOLEH' OR
*    screen-name = 'LIKP-INCO1' OR
*    screen-name = 'LIKP-INCO2' OR
*    screen-name = 'LIKP-PROLI' OR
*    screen-name = 'LIKP-LGTOR' OR
*    screen-name = 'LIKP-LGBZO' OR
*    screen-name = 'LIKP-AULWE' OR
*    screen-name = 'LIKP-XABLN' OR
     screen-name = 'LIKP-VSTEL'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                               " FELDAUSWAHL_PP_LIEFERUNG