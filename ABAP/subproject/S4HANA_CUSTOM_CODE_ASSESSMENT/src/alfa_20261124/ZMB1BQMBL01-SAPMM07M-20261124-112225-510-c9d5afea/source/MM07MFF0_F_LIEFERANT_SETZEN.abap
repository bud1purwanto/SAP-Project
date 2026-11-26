*eject.
*----------------------------------------------------------------------*
*                 Frachtlieferant setzen.                              *
*----------------------------------------------------------------------*
FORM f_lieferant_setzen.

  CLEAR dekbnk.
  READ TABLE dekbnk INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    EXIT FROM STEP-LOOP.
  ENDIF.
  ekbnk-lifnr = dekbnk-lifnr.
  ekbnk-kschl = dekbnk-kschl.
  ekbnk-vtext = dekbnk-vtext.
  flindex-zeile = dekbnk-zeile.
  flindex-stepl = sy-stepl.
  APPEND flindex.
  DELETE dekbnk INDEX 1.

ENDFORM.