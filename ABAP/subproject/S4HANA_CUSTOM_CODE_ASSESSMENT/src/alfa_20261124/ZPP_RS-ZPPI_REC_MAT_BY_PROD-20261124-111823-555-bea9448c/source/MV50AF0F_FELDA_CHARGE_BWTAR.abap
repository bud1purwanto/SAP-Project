***INCLUDE MV50AF0F_FELDA_CHARGE_BWTAR .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_CHARGE_BWTAR                                 *
*---------------------------------------------------------------------*
*       Feste Feldmodifikation zur Eingabebereitschaft von            *
*       Chargen und Bewertungsarten                                   *
*---------------------------------------------------------------------*
form feldauswahl_charge_bwtar changing cf_exit_flag type c.

  if screen-name = 'LIPS-CHARG' and
     ( lips-xchpf eq space or
       lipsd-chmult ne space ) .                            "46A BEY
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-CHARG'.
    if not lips-xchar is initial and
       lips-anzsn ne 0.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
*   Decentral WMS: Once the batch is assigned it must not be changed
    if not lips-charg is initial and
       not lips-uepos is initial.                           "n_674567
      if ( likp-vlstk eq 'B' and likp-verursys eq space ) or
         ( likp-vlstk eq 'A' and likp-verursys ne space ).
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
*   inspection lot + HU + batch assigned                     "v_n_799348
    if not lips-charg is initial and
       not lips-qplos is initial .
      CALL FUNCTION 'QAAT_SD_CHECK_HU_LOT'
        EXPORTING
          i_prueflos              = lips-qplos
       EXCEPTIONS
          STATUS_HUM_ACTIVE       = 1
          OTHERS                  = 2
                .
      IF sy-subrc eq 1.
        screen-input = 0.
      ENDIF.
      exit.
    endif.                                                   "^_n_799348
  endif.
  if screen-name = 'MSEG-CHARG' and
     mseg-sobkz eq space.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-BWTAR' and
     ( lips-xchar eq space      or
       lips-xchpf eq charx      or
       LIPSD-CHMULT NE SPACE    OR
       LIPS-ANZSN   NE 0 ) .                                  "n_1536130
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-BRGEW' and
     ( lipsd-chmult ne space    and
       taxi_screen_group(1) ne 'I' ) .
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-NTGEW' and
     ( lipsd-chmult ne space    and
       taxi_screen_group(1) ne 'I' ) .
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-GEWEI' and
     ( lipsd-chmult ne space    and
       taxi_screen_group(1) ne 'I' ) .
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-VOLUM' and
     ( lipsd-chmult ne space    and
       taxi_screen_group(1) ne 'I' ) .
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
  if screen-name = 'LIPS-VOLEH' and
     ( lipsd-chmult ne space    and
       taxi_screen_group(1) ne 'I' ) .
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

endform.                    "FELDAUSWAHL_CHARGE_BWTAR