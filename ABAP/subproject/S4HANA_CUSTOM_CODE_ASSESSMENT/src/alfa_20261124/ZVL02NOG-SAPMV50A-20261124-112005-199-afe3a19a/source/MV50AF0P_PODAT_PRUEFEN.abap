*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PODAT_PRUEFEN                                     *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PODAT_PRUEFEN
*&---------------------------------------------------------------------*
*       POD Datum nach Eingabe prüfen
*----------------------------------------------------------------------*
FORM PODAT_PRUEFEN.
  IF LIKP-PODAT IS INITIAL.
    MESSAGE E681.
  ENDIF.
  IF LIKP-WADAT_IST LT LIKP-PODAT.
    MESSAGE E682.
  ENDIF.
ENDFORM.                               " PODAT_PRUEFEN