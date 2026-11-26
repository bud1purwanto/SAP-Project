*eject.
*----------------------------------------------------------------------*
*                 Frachtlieferant übernehmen                           *
*----------------------------------------------------------------------*
FORM f_lieferant_uebernehmen.

  SORT flindex.
  READ TABLE flindex INDEX sy-stepl.
  SORT yekbnk.
  CLEAR yekbnk.
  IF sy-subrc IS INITIAL.
    READ TABLE yekbnk INDEX flindex-zeile.
    IF yekbnk-lifnr NE ekbnk-lifnr.                         "HUM
      upd_fralief = x.                                      "HUM
    ENDIF.                                                  "HUM
    yekbnk-lifnr = ekbnk-lifnr.
    MODIFY yekbnk INDEX flindex-zeile.
  ENDIF.

ENDFORM.