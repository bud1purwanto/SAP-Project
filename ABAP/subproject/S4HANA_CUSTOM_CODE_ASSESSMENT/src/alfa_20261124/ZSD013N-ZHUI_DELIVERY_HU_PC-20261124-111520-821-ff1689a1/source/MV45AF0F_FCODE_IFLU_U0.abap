*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß vom Übersichtsbild aus                      *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_U0 USING US_T185F
                         US_T185
                         US_T185V.

  PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  IF SY-SUBRC = 4.
    IF TC_SELLINE NE 0.
      PERFORM XVBAP_MARKIEREN(SAPFV45P).
    ENDIF.
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  ENDIF.
  IF SY-SUBRC = 0.
    IF XVBAP-UPDKZ EQ UPDKZ_NEW.
      MESSAGE I141(VR) WITH XVBAP-POSNR.
    ELSE.
      VBAP = XVBAP.
        PERFORM IVBAP-SELKZ_RESET(SAPFV45P) USING VBAP-POSNR.

        PERFORM FCODE_IFLU_POSITION USING US_T185F
                                          US_T185
                                          US_T185V.
    ENDIF.
  ELSE.
    PERFORM FCODE_IFLU_KOPF USING US_T185F
                                  US_T185
                                  US_T185V.
  ENDIF.

ENDFORM.