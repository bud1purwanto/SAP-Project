*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BELEG_DATEN_INIT_AFTE                             *
*----------------------------------------------------------------------*

form beleg_daten_init_afterwards.

* dequeue all
  if kz_lieferavis eq space and v50agl-kommirueckmeldung = space
     and no_dequeue = space.
    call function 'DEQUEUE_ALL'
      exporting
        _synchron = 'X'
      exceptions
        others    = 0.
  endif.

endform.                    "beleg_daten_init_afterwards