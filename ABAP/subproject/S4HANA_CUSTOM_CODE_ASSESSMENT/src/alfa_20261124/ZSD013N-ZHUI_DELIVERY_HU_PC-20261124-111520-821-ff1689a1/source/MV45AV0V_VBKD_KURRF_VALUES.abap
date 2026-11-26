*---------------------------------------------------------------------*
*       MODULE VBKD_kurrf_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld VBKD-kurrf                               *
*---------------------------------------------------------------------*
MODULE VBKD_kurrf_VALUES.

  CLEAR DA_DISPLAY.
  da_dynpprog = sy-repid.
  da_dynpnr   = sy-dynnr.
  loop at screen.
    if screen-name = 'VBKD-KURRF'.
      if screen-input = 0.
        da_display = 'X'.
      else.
        clear da_display.
      endif.
      exit.
    endif.
  endloop.
  da_kurstyp = vbak-kurst.
  if da_kurstyp is initial.
    da_kurstyp = 'M'.
  endif.
  da_kursdatum = vbkd-kurrf_dat.
  if da_kursdatum is initial.
    da_kursdatum = vbkd-prsdt.
  endif.

  CALL FUNCTION 'F4_EXCHANGE_RATE'
       EXPORTING
            TYPE_OF_RATE       = da_kurstyp
            DATE               = da_kursdatum
            FOREIGN_CURRENCY   = vbak-waerk
            LOCAL_CURRENCY     = t001-waers
            FIELDNAME          = 'VBKD-KURRF'
            DYNAME             = da_dynpprog
            DYNUMB             = da_dynpnr
            DISPLAY_ONLY       = da_display
       CHANGING
            KURS               = vbkd-kurrf
       EXCEPTIONS
            INSUFFICIENT_INPUT = 1
            OTHERS             = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.