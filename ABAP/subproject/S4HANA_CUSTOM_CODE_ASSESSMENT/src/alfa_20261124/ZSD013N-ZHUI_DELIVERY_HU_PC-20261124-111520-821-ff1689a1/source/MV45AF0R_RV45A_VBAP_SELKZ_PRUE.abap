*&---------------------------------------------------------------------*
*&      Form  RV45A-VBAP_SELKZ_PRUEFEN                                 *
*&---------------------------------------------------------------------*
*       Selektionskennzeichen bei gesetztem Absagegrund zurücksetzen   *
*       Wird auf dem Kopierbild verwendet                              *
*----------------------------------------------------------------------*
FORM RV45A-VBAP_SELKZ_PRUEFEN.

  DATA: DA_SUBRC LIKE SY-SUBRC.

  IF RV45A-VBAP_SELKZ EQ SELEKTIERT.
    PERFORM XVBAP_MARKIERBAR_PRUEFEN(SAPFV45P) USING DA_SUBRC.
    IF DA_SUBRC > 0.
      MESSAGE I709 WITH VBAP-POSNR.
      CLEAR RV45A-VBAP_SELKZ.
    ENDIF.
  ENDIF.

ENDFORM.                    " RV45A-VBAP_SELKZ_PRUEFEN