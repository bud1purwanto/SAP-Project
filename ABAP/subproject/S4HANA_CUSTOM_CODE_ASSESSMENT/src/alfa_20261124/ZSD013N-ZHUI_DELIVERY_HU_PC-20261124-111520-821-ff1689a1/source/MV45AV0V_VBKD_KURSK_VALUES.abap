*---------------------------------------------------------------------*
*       MODULE VBKD_kursk_VALUES.                                     *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld VBKD-kursk                               *
*---------------------------------------------------------------------*
MODULE VBKD_kursk_VALUES.

  CLEAR DA_DISPLAY.
  da_dynpprog = sy-repid.
  da_dynpnr   = sy-dynnr.
  loop at screen.
    if screen-name = 'VBKD-KURSK'.
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
  da_kursdatum = vbkd-kursk_dat.
  if da_kursdatum is initial.
    da_kursdatum = vbkd-prsdt.
  endif.

  CALL FUNCTION 'F4_EXCHANGE_RATE'
       EXPORTING
            TYPE_OF_RATE       = da_kurstyp
            DATE               = da_kursdatum
            FOREIGN_CURRENCY   = vbak-waerk
            LOCAL_CURRENCY     = t001-waers
            FIELDNAME          = 'VBKD-KURSK'
            DYNAME             = da_dynpprog
            DYNUMB             = da_dynpnr
            DISPLAY_ONLY       = da_display
       CHANGING
            KURS               = vbkd-kursk
       EXCEPTIONS
            INSUFFICIENT_INPUT = 1
            OTHERS             = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



* if DA_DISPLAY IS INITIAL AND         " Ändern-Modus
*    NOT DA_VALUE IS INITIAL.          " User hat Wert eingegeben
*   PERFORM DYNP_VALUES_UPDATE USING SY-REPID
*                                    SY-DYNNR
*                                    'VBKD-ZTERM'
*                                    DA_VALUE
*                           CHANGING SY-SUBRC.
* ENDIF.

ENDMODULE.