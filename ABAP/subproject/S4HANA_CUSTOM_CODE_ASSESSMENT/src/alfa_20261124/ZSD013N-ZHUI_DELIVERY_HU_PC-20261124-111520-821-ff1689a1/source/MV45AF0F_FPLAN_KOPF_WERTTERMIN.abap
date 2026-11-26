*---------------------------------------------------------------------*
*       FORM FPLAN_KOPF_WERTTERMINE_ERM                               *
*---------------------------------------------------------------------*
*       Wertmäßiger Termin im Kopf.fakt.plan suchen                   *
*---------------------------------------------------------------------*
FORM FPLAN_KOPF_WERTTERMINE_ERM CHANGING CH_WERT.

  CHECK NOT TVAK-FPART IS INITIAL.
* nur wenn Kopffakturierungsplan zugelassen
  CLEAR CH_WERT.
* Lesen der VBKD
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                             SVBKD-TABIX.

  IF NOT XVBKD-FPLNR IS INITIAL.
    READ TABLE XFPLT WITH KEY FPLNR = XVBKD-FPLNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT XFPLT FROM SY-TABIX.
        IF XFPLT-FPLNR NE XVBKD-FPLNR.
          EXIT.
        ENDIF.
        IF XFPLT-FAREG CA CON_FAREG_WERT.
*          wertmäßiger Termin gefunden
           MOVE CHARX TO CH_WERT.
           EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.