*---------------------------------------------------------------------*
*       FORM FPLANART_ERMITTELN_KOPF                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CH_FPART                                                      *
*---------------------------------------------------------------------*
FORM FPLANART_ERMITTELN_KOPF CHANGING CH_FPART.
* aus VBAK, VBKD soll über customer function call eine
* Fakturierungsplanart ermittelt werden.

* nur beim Anlegen
  IF VBKD-FPLNR IS INITIAL.

ENHANCEMENT-POINT SAPMV45A_12 SPOTS ES_SAPMV45A.
    CALL FUNCTION 'EXIT_SAPMV45A_001'
         EXPORTING
              IVBAK           = VBAK
              IVBKD           = VBKD
              ITVAK           = TVAK
         CHANGING
              BILLINGPLANTYPE = CH_FPART.
  ELSE.
*   Kopffakturierungsplanart nachlesen, wenn Fakt.plan vorhanden
    READ TABLE XFPLA WITH KEY FPLNR = VBKD-FPLNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      MOVE XFPLA-FPART TO CH_FPART.
    ENDIF.
  ENDIF.
ENDFORM.