*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_MENGE_SETZEN                                 *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_MENGE_SETZEN                                         *
*---------------------------------------------------------------------*
*       verändern der Liefermenge einer Position aufgrund der         *
*       Korrelation                                                   *
*---------------------------------------------------------------------*
FORM korr_menge_setzen USING km_tabix LIKE sy-tabix
                             km_lfimg TYPE numeric.

  DATA: da_lfimg LIKE lips-lfimg.

  da_lfimg    = km_lfimg.
  slips-tabix = km_tabix.
  ilips-tabix = km_tabix.

  PERFORM lips_bearbeiten_vorbereiten(sapfv50p).

* Rundung für Stücklisten-Unterpositionen mit ganzzahliger Mengeneinheit
* einer Teilstückliste, die nicht das minimale Korrelationsverhältnis
* bestimmt hat und aufgrund ungünstiger Stücklistenverhältnisse durch
* das Mitkorrelieren nichtganzzalig wird.
  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input         = da_lfimg
      no_type_check = charx
      round_sign    = tvlp-rndsg
      unit_in       = lips-vrkme
      unit_out      = lips-vrkme
    IMPORTING
      output        = da_lfimg
    EXCEPTIONS
      OTHERS        = 99.

  lips-lfimg = da_lfimg.
ENHANCEMENT-POINT KORR_MENGE_SETZEN_01 SPOTS ES_SAPMV50A.
  PERFORM lips_quan_set(sapfv50p) USING 'A' space.
  PERFORM lips-matnr_pruefen(sapfv50p) USING sy-subrc.
  PERFORM lips_bearbeiten(sapfv50p).

ENDFORM.                    "KORR_MENGE_SETZEN
*eject