*---------------------------------------------------------------------*
*       FORM FCODE_MALL                                               *
*---------------------------------------------------------------------*
*       'Alle markieren' für Wertkontraktabruf auf Kopierdynpro       *
*---------------------------------------------------------------------*
FORM FCODE_MALL.
  RV45A-VBAP_SELKZ = SELEKTIERT.
  REFRESH IVBAP.
  PERFORM IVBAP_AUFBAUEN_WK_ABRUF_NEUE(SAPFV45P) USING RV45A-POSNR.
  CLEAR RV45A-VBAP_SELKZ.
ENDFORM.