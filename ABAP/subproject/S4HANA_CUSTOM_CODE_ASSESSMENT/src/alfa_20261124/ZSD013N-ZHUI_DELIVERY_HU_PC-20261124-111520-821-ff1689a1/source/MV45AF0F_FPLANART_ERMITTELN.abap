*---------------------------------------------------------------------*
*       FORM FPLANART_ERMITTELN                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CH_FPART                                                      *
*---------------------------------------------------------------------*
FORM FPLANART_ERMITTELN CHANGING CH_FPART.
* aus VBAK, VBAP, VBKD soll über customer function call eine
* Fakturierungsplanart ermittelt werden.

  IF VBKD-POSNR NE POSNR_LOW AND
     NOT VBKD-FPLNR IS INITIAL.
*   Positionsfakturierungsplanart nachlesen, da Fakt.plan vorhanden
    READ TABLE XFPLA WITH KEY FPLNR = VBKD-FPLNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE XFPLA-FPART TO CH_FPART.
    ENDIF.
  ELSE.
ENHANCEMENT-POINT SAPMV45A_11 SPOTS ES_SAPMV45A.
*   nur beim Anlegen
    CALL FUNCTION 'EXIT_SAPMV45A_001'
         EXPORTING
              IVBAK           = VBAK
              IVBAP           = VBAP
              IVBKD           = VBKD
              ITVAK           = TVAK
              ITVAP           = TVAP
         CHANGING
              BILLINGPLANTYPE = CH_FPART.
  ENDIF.
ENDFORM.