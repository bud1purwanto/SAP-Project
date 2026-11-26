*&---------------------------------------------------------------------*
*&  Include           MV45AF0W_WERTKONTRAKT_DATENUEB                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  WERTKONTRAKT_DATENUEBERNAHME
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*

FORM WERTKONTRAKT_DATENUEBERNAHME .

  DATA: WA_XVBAP LIKE LINE OF XVBAP.

  READ TABLE XVBAP INTO WA_XVBAP
      WITH KEY POSNR = XVBAP-VGPOS_WK.
  IF SY-SUBRC EQ 0.
    XVBAP-VBELV = WA_XVBAP-VBELV.
    XVBAP-POSNV = WA_XVBAP-POSNV.
    XVBAP-KZVBR = WA_XVBAP-KZVBR.
    XVBAP-SOBKZ = WA_XVBAP-SOBKZ.
    XVBAP-KZBWS = WA_XVBAP-KZBWS.
    XVBAP-SKOPF = WA_XVBAP-SKOPF.
    MODIFY XVBAP.
  ENDIF.

ENDFORM.                    " WERTKONTRAKT_DATENUEBERNAHME