*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDA_STAT_VERTEILT                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_STAT_VERTEILT
*&---------------------------------------------------------------------*
*       Field selection for distributed deliveries
*----------------------------------------------------------------------*
form feldauswahl_stat_verteilt tables it_dlfld structure dlfld
                               using if_cmact type xfeld      "n_921209
                               changing cf_exit_flag type c.
* replaced                                                   v_n_921209
  check screen-input eq 1.

  if if_cmact is initial.
    perform feldauswahl_stat_vert tables it_dlfld
                                  changing cf_exit_flag.
  else.
    perform feldauswahl_stat_vert_cm tables it_dlfld
                                     changing cf_exit_flag.
  endif.
*                                                            ^_n_921209

endform.                               " FELDAUSWAHL_STAT_VERTEILT

*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_STAT_VERT                            n_671468
*&---------------------------------------------------------------------*
*       DISTRIBUTED, CHANGE MANAGEMENT INACTIVE
*----------------------------------------------------------------------*
form feldauswahl_stat_vert tables it_dlfld structure dlfld
                           changing cf_exit_flag type c.
  data:
    lf_tabname like dlfld-tabname,
    lf_fieldname like dlfld-fieldname.

* change management inactive -> change mode in decentral system only
  check not likp-verursys is initial.

* Some fields are generally not changeable
* Commented fields are open or can be controlled dynamically (DLFLD)
* Dynamically controlled fields: LV50SFWM gn_set_field_control_default
* Item fields
  if screen-name = 'LIPS-LGORT'.
*   Check for generated packing items (LGORT can be maintained)
    if lips-lgort is initial and
       lips-posar eq charc.
      exit.
    else.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.


* lines deleted                                                n_779150

  if screen-name = 'LIPS-PSTYV' or     "currently not supported
     screen-name = 'LIPS-POSNR' or     "never changeable
     screen-name = 'LIPS-MATNR' or     "never changeable
     screen-name = 'LIPS-SERNR' or     "currently not supported
*    screen-name = 'LIPS-AESKD' OR     "DLFLD
*    screen-name = 'LIPS-ARKTX' OR     "DLFLD
     screen-name = 'LIPS-WERKS' or     "never changeable
     screen-name = 'LIPS-UEBTO' or     "currently not supported
     screen-name = 'LIPS-UNTTO' or     "currently not supported
     screen-name = 'LIPS-KZTLF' or     "currently not supported
     screen-name = 'LIPS-UEBTK' or     "currently not supported
*    SCREEN-NAME = 'LIPS-CHARG' OR     "changeable only by WM TOs
*    screen-name = 'LIPS-BRGEW' OR
*    screen-name = 'LIPS-NTGEW' OR
*    screen-name = 'LIPS-GEWEI' OR
*    screen-name = 'LIPS-VOLUM' OR
*    screen-name = 'LIPS-VOLEH' OR
*    screen-name = 'LIPSD-G_LFIMG' OR
*    screen-name = 'LIPS-LFIMG' OR
*    screen-name = 'LIPS-LGMNG' OR
*    screen-name = 'LIPSD-PIKMG' OR
     screen-name = 'LIPS-VRKME' or     "never changeable
*    screen-name = 'RV50A-VRKM1' OR
*    screen-name = 'LIPS-MEINS' OR
*    screen-name = 'LIPS-UMVKN' OR
*    screen-name = 'LIPS-UMVKZ' OR
*    screen-name = 'LIPS-EMPST' OR      "DLFLD
*    screen-name = 'LIPS-MBDAT' OR
     screen-name = 'LIPS-UEPOS'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

*  New items can not be created
  if lips-matnr is initial.
*  if screen-name = 'LIPS-LFIMG' or                           "n_632959
    if screen-name = 'LIPS-VRKME' or
       screen-name = 'LIPS-BRGEW' or
       screen-name = 'LIPS-NTGEW' or
       screen-name = 'LIPS-GEWEI' or
       screen-name = 'LIPS-VOLUM' or
       screen-name = 'LIPS-VGBEL' or
       screen-name = 'LIPS-VGPOS' or
       screen-name = 'LIPS-VOLEH' or
       screen-name = 'LIPS-ARKTX' or
*    screen-name = 'LIPS-CHARG' or                           "n_632959
       screen-name = 'LIPS-KZTLF' or
       screen-name = 'LIPS-UEBTK' or
       screen-name = 'LIPS-UEBTO' or
       screen-name = 'LIPS-PROFL' or
       screen-name = 'LIPS-MBDAT' or
       screen-name = 'LIPS-MBUHR' or
*    screen-name = 'LIPS-BWTAR' or                           "n_632959
       screen-name = 'LIPSD-G_LFIMG' or
       screen-name = 'LIPSD-PIKMG' or
       screen-name = 'LIPSD-VRKMP' or
       screen-name = 'LIPSD-CHMULT' or
       screen-name = 'RV50A-LFPMG' or
       screen-name = 'RV50A-VRKM1' or
       screen-name = 'VBUP-KOSTA' or
       screen-name = 'VBUP-LVSTA' or
       screen-name = 'LIPSD-DOCUBATCH_CHARG'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

*Einschränkung auf Anlieferung                              "v_n_632959
*  Neue Positionen nur auf Chargensplitbild + Anlieferung
  if lips-matnr is initial         and
     ( v50agl-chargensplitbild = ' ' or likp-vbtyp <> '7' ). "n_1059871
     if screen-name = 'LIPS-BWTAR' or
        screen-name = 'LIPS-CHARG' or
        screen-name = 'LIPS-LFIMG'.
        screen-input = 0.
        exit.
     endif.
  endif.                                                   "^_n_632959

*  Header fields
  if screen-name = 'LIKP-LFART' or
     screen-name = 'LIKP-AUTLF' or
     screen-name = 'LIKP-KUNNR' or
     screen-name = 'LIKP-VERUR' or
*    screen-name = 'RV50A-VERUR_LA' or    "DLFLD
*    screen-name = 'RV50A-KDMAT_LA' OR    "DLFLD
*    screen-name = 'LIKP-LIFSK' OR        "must be changeable
*    screen-name = 'LIKP-LPRIO' OR        "DLFLD
*    screen-name = 'LIKP-VSBED' OR        "DLFLD
*    screen-name = 'LIKP-LSTEL' OR        "DLFLD
*    screen-name = 'LIKP-LIFEX' OR        "DLFLD
*    screen-name = 'LIKP-ABLAD' OR        "DLFLD
*    screen-name = 'LIKP-ROUTE' OR        "DLFLD
*    screen-name = 'LIKP-BEROT' OR        "DLFLD
*    screen-name = 'LIKP-TRATY' OR        "DLFLD
*    screen-name = 'LIKP-TRAID' OR        "DLFLD
*    screen-name = 'LIKP-BOLNR' OR        "DLFLD
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
*    screen-name = 'LIKP-INCO1' OR        "DLFLD
*    screen-name = 'LIKP-INCO2' OR        "DLFLD
*    screen-name = 'LIKP-PROLI' OR
*    screen-name = 'LIKP-LGTOR' OR
*    screen-name = 'LIKP-LGBZO' OR
*    screen-name = 'LIKP-AULWE' OR        "DLFLD
*    screen-name = 'LIKP-XABLN' OR
     screen-name = 'LIKP-VSTEL'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

*  Check for changeable fields not processed above
  split screen-name at '-' into lf_tabname lf_fieldname.

*  Access for header fields with empty item handle
  if    lf_tabname eq 'LIKP'
     or lf_tabname eq 'VBUK'
     or lf_tabname eq 'VBPA'.
    read table it_dlfld with key handle_det = space
                                 tabname    = lf_tabname
                                 fieldname  = lf_fieldname.
    if sy-subrc eq 0 and it_dlfld-flag_change ne space.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  else.
    read table it_dlfld with key handle_det = lips-handle
                                 tabname    = lf_tabname
                                 fieldname  = lf_fieldname.
    if sy-subrc eq 0 and it_dlfld-flag_change ne space.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
endform.                               " FELDAUSWAHL_STAT_VERT

*&---------------------------------------------------------------------*
*&      Form  FELDAUSWAHL_STAT_VERT_CM                         n_671468
*&---------------------------------------------------------------------*
*       DISTRIBUTED, CHANGE MANAGEMENT ACTIVE
*----------------------------------------------------------------------*
form feldauswahl_stat_vert_cm tables it_dlfld structure dlfld
                              changing cf_exit_flag type c.

  if screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-WERKS' or
     screen-name = 'LIPS-LGORT'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

  if screen-name = 'LIPS-UMVKN' or
     screen-name = 'LIPS-UMVKZ' or
     screen-name = 'LIPS-VRKME'.
    if likp-verursys is initial or
       lips-kzfme ca KZFME_WS.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

endform.                               " FELDAUSWAHL_STAT_VERT_CM