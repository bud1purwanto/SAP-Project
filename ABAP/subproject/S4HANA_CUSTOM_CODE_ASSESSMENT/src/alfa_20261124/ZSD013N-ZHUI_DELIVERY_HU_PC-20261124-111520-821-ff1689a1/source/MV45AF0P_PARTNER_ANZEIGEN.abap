***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung alphabetisch sortiert:         *
*  ----------------------------------------------------------         *
*  Buchstabe P:                                                       *
***********************************************************************
*----------------------------------------------------------------------*
*          FORM PARTNER_ANZEIGEN                                       *
*----------------------------------------------------------------------*
* Die Stammdaten zum Partner sollen angezeigt werden.                  *
* Dazu werden Parameter gesetzt.                                       *
*----------------------------------------------------------------------*
FORM PARTNER_ANZEIGEN USING US_PARVW
                            US_AUSWAHL.
  LOCAL: TVTA, XVBAP.

  IF SY-DYNGR = 'LIST'.
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
    IF SY-SUBRC = 4.
      PERFORM XVBAP_MARKIEREN(SAPFV45P).
      PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
    ENDIF.
    IF SY-SUBRC > 0.
      CLEAR VBAP.
    ELSE.
      VBAP = XVBAP.
      PERFORM IVBAP-SELKZ_RESET(SAPFV45P) USING VBAP-POSNR.
    ENDIF.
  ENDIF.
* Kopfpartner anzeigen
  IF SY-DYNGR = 'KOPF' OR
     SY-DYNGR = 'LIST' AND VBAP-POSNR IS INITIAL.
    PERFORM XVBPA_LESEN(SAPFV45K) USING US_PARVW
                                        POSNR_LOW
                                        SY-TABIX.
    PERFORM TVTA_SELECT USING VBAK-VKORG
                              VBAK-VTWEG
                              VBAK-SPART.

    SET PARAMETER ID 'KUN' FIELD XVBPA-KUNNR.
    SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
    SET PARAMETER ID 'VTW' FIELD TVTA-VTWKU.
    SET PARAMETER ID 'SPA' FIELD TVTA-SPAKU.
    SET PARAMETER ID 'DDY' FIELD US_AUSWAHL.
  ENDIF.
* Positionspartner anzeigen
  IF SY-DYNGR = 'POSI' OR
     SY-DYNGR = 'LIST' AND NOT VBAP-POSNR IS INITIAL.
    PERFORM XVBPA_LESEN(SAPFV45K) USING US_PARVW
                                        VBAP-POSNR
                                        SY-TABIX.
    PERFORM TVTA_SELECT USING VBAK-VKORG
                              VBAK-VTWEG
                              VBAP-SPART.

    SET PARAMETER ID 'KUN' FIELD XVBPA-KUNNR.
    SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
    SET PARAMETER ID 'VTW' FIELD TVTA-VTWKU.
    SET PARAMETER ID 'SPA' FIELD TVTA-SPAKU.
    SET PARAMETER ID 'DDY' FIELD US_AUSWAHL.
  ENDIF.

ENDFORM.