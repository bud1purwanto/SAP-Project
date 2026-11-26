*eject
*---------------------------------------------------------------------*
*       FORM M-BELEGNUMMER_VERGEBEN                                   *
*---------------------------------------------------------------------*
*       Bei interner Nummernvergabe wird der Nummernkreis gelesen     *
*       und die naechste Belegnummer erhoeht. (Materialbeleg)         *
*---------------------------------------------------------------------*
FORM m-belegnummer_vergeben.

  DATA: rc_number LIKE inri-returncode.

  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
            nr_range_nr   = numkr
            object        = 'MATBELEG'
            toyear        = xmkpf-mjahr
       IMPORTING
            returncode    = rc_number
            number        = xmkpf-mblnr
       EXCEPTIONS
            error_message = 2.
  CASE rc_number.
    WHEN 1.
      MESSAGE w560.
    WHEN 2.
      MESSAGE w561.
  ENDCASE.
  IF xmkpf-mblnr IS INITIAL.
    MESSAGE e559.
  ENDIF.

ENDFORM.