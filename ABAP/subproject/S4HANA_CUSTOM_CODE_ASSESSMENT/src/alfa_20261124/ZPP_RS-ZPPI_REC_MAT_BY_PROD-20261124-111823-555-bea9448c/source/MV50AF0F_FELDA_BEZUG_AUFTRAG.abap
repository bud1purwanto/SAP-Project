***INCLUDE MV50AF0F_FELDA_BEZUG_AUFTRAG .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_BEZUG_AUFTRAG                                *
*---------------------------------------------------------------------*
*       Feste Feldmodifikation gemäß Bezug zum Auftrag                *
*       liegt einer Lieferung ein Auftrag zugrunde, dürfen einige     *
*       Angaben in der Lieferung nicht eigenständig geändert werden   *
*---------------------------------------------------------------------*
form feldauswahl_bezug_auftrag changing cf_exit_flag type c.

  data: ls_xvbup like line of xvbup,
        lf_subrc like sy-subrc,
        lf_order_reference type c,
        lf_msgty like sy-msgty value 'E'.

  check: screen-input = 1.

* Positionsfelder
  if screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-KZTLF' or
     screen-name = 'LIPS-WERKS'.
    if lips-vgbel ne space  or         "alle mit Vorgaenger
       lips-rsnum ne space  or
       lips-vgtyp ne space.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
  if screen-name = 'LIPS-PSTYV' or
     screen-name = 'LIPS-UNTTO' or
     screen-name = 'LIPS-UEBTO' or
     screen-name = 'LIPS-UEBTK'.
    if lips-vgbel ne space  and
       lips-vgtyp ne charv  or         "Aufträge
       lips-vgtyp ne space  and
       lips-vgtyp ne charv.            "Aufträge
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.
  if screen-name = 'LIPS-PSTYV'.
    if not lips-matnr is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Kopffelder
  if screen-name = 'LIKP-VSBED' or
     screen-name = 'LIKP-VSTEL'.
    if tvlk-aufer eq charx.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
*   Decentralized warehouse management system
    if likp-verursys ne space.
      call function 'SHP_LIPSRF_EXISTENCE_CHECK'
        exporting
          if_handle_obj     = likp-handle
        importing
          ef_existence_flag = lf_order_reference.
      if lf_order_reference ne space.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

* The mainitem of a product selection is only a sort of header, so it
* it useless to change it
  if lips-prosa ca 'AC'.
    if screen-name = 'LIPS-LFIMG' or
       screen-name = 'LIPS-VRKME' or
       screen-name = 'LIPS-LGMNG' or
       screen-name = 'LIPS-UMVKZ' or
       screen-name = 'LIPS-UMVKN' or
       screen-name = 'LIPS-BRGEW' or
       screen-name = 'LIPS-NTGEW' or
       screen-name = 'LIPS-GEWEI' or
       screen-name = 'LIPS-VOLUM' or
       screen-name = 'LIPS-VOLEH' or
       screen-name = 'LIPS-LGORT' or
       screen-name = 'LIPS-CHARG' or
       screen-name = 'LIPS-BWTAR' or
       screen-name = 'LIPSD-PIKMG' or
       screen-name = 'LIPS-MBDAT' or
       screen-name = 'LIPS-MBUHR' or
       screen-name = 'RV50A-VRKM1' or
       screen-name = 'LIPSD-G_LFIMG' or
       screen-name = 'LIPS-SERNR'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

ENHANCEMENT-POINT FELD_BEZUG_AUFTRAG_01 SPOTS ES_SAPMV50A.
  if screen-name = 'LIPS-LFIMG'    or
     screen-name = 'LIPSD-G_LFIMG' or
     screen-name = 'LIPS-VRKME'    or
     screen-name = 'LIPS-UMVKZ'    or
     screen-name = 'LIPS-UMVKN'.
    if lips-vgbel ne space and
       lips-vgtyp ca vbtyp_auft.
      perform tvap_select using lips-pstyv
                                lf_subrc.
      if tvap-fkrel eq 'G'.
        read table xvbup into ls_xvbup
                         with key mandt = sy-mandt
                                  vbeln = lips-vgbel
                                  posnr = lips-vgpos
                         binary search.
        if ls_xvbup-fksaa ca 'BC'.
          perform message_steuerung using  gs_mhpar
                                           v50agl-msgvs
                                           'VL'
                                           '444'
                                  changing lf_msgty
                                           lf_subrc.
          if lf_msgty eq 'E'.
            screen-input = 0.
            cf_exit_flag = charx.
            exit.
          endif.
        endif.
      endif.
    endif.
  endif.

endform.                    "FELDAUSWAHL_BEZUG_AUFTRAG