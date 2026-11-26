*---------------------------------------------------------------------*
*       FORM FCODE_STAT_U0                                            *
*---------------------------------------------------------------------*
* Overview of order status                                            *
*---------------------------------------------------------------------*
FORM FCODE_STAT_U0  USING US_T185F
                          US_T185
                          US_T185V.

  DATA: SELPOS LIKE SY-TFILL.          "Counter

  PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  IF SY-SUBRC = 4.
    IF TC_SELLINE NE 0.
      PERFORM XVBAP_MARKIEREN(SAPFV45P).
    ENDIF.
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  ENDIF.
  IF SY-SUBRC = 0.
    VBAP = XVBAP.
    CLEAR SELPOS.
    LOOP AT IVBAP WHERE SELKZ EQ SELEKTIERT.
      ADD 1 TO SELPOS.
    ENDLOOP.
    IF SELPOS > 1.
      CLEAR VBAP-POSNR.
    ENDIF.

    PERFORM FCODE_STAT_POSITION USING US_T185F
                                      US_T185
                                      US_T185V.
  ELSE.
    PERFORM FCODE_STAT_KOPO USING US_T185F
                                  US_T185
                                  US_T185V.
  ENDIF.

ENDFORM.