*---------------------------------------------------------------------*
*       FORM FCODE_ILIF_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Lieferungen vom Übersichtsbild aus                    *
*---------------------------------------------------------------------*
FORM FCODE_ILIF_U0 USING US_T185F
                         US_T185
                         US_T185V.

  PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  IF SY-SUBRC = 4.
    PERFORM XVBAP_MARKIEREN(SAPFV45P).
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
  ENDIF.
  IF SY-SUBRC = 0.
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
    VBAP = XVBAP.
    PERFORM IVBAP-SELKZ_RESET(SAPFV45P) USING VBAP-POSNR.

    PERFORM XVBUP_LESEN(SAPFV45P) USING VBAK-VBELN
                                        VBAP-POSNR.
    PERFORM FCODE_ILIF USING US_T185F
                             US_T185
                             US_T185V.
  ENDIF.

ENDFORM.