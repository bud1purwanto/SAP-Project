*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_ERMITTELN_ZEILENNR
*&---------------------------------------------------------------------*
*       text: ermitteln der Zeilennummer fuer die neue FUSS-Zeile
*----------------------------------------------------------------------*
FORM LGORT_CD_ERMITTELN_ZEILENNR CHANGING MAX_ZEILE.

  LOOP AT FUSS.
    IF FUSS-ZEILE > MAX_ZEILE.
      MAX_ZEILE = FUSS-ZEILE.
    ENDIF.
  ENDLOOP.
  MAX_ZEILE = MAX_ZEILE + 1.

ENDFORM.                               " LGORT_CD_ERMITTELN_ZEILENNR