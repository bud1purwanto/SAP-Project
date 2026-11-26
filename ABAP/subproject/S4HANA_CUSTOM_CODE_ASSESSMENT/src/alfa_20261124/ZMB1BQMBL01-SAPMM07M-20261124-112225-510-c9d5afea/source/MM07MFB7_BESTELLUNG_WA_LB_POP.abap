*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_WA_LB_POP.                                    *
*---------------------------------------------------------------------*
*       Die Bestellung wird für den Warenausgang zur Lohnbearbeiter-  *
*       bestellung wird gelesen.                                      *
*---------------------------------------------------------------------*
  FORM BESTELLUNG_WA_LB_POP.
    PERFORM BESTELLUNG_WA_LB_PRUEFEN USING RM07M-EBELN
                                           RM07M-EBELP.
    CLEAR FUSS.
    REFRESH: PREFETCH01,
             PREFETCH02,
             PREFETCH03.
    LOOP AT XMDGI WHERE NOT MATNR IS INITIAL.
      MOVE-CORRESPONDING XMDGI TO PREFETCH02.
      COLLECT PREFETCH02.
      MOVE-CORRESPONDING XMDGI TO PREFETCH03.
      COLLECT PREFETCH03.
    ENDLOOP.
    PERFORM PREFETCH_AUSFUEHREN USING X
                                      SPACE.
    LOOP AT XMDGI.
ENHANCEMENT-SECTION BESTELLUNG_WA_LB_POP_03 SPOTS ES_SAPMM07M .
      CHECK ( T156-SHKZG = XMDGI-SHKZG AND T156-XSTBW IS INITIAL ) OR
        ( NOT T156-SHKZG = XMDGI-SHKZG AND NOT T156-XSTBW IS INITIAL ).
END-ENHANCEMENT-SECTION.
      CLEAR: DM07M,
             VM07M,
             MSEG.
      MOVE-CORRESPONDING XMDGI TO MSEG.
      MOVE-CORRESPONDING XMDGI TO DM07M.
      MOVE-CORRESPONDING XMDGI TO VM07M.
ENHANCEMENT-POINT EHP604_BESTELLUNG_WA_LB_POP_01 SPOTS ES_SAPMM07M.
      IF T156B-FAUSW+16(1) NE MINUS.
        MSEG-EBELN = RM07M-EBELN.
ENHANCEMENT-POINT BESTELLUNG_WA_LB_POP_01 SPOTS ES_SAPMM07M.
      ENDIF.
ENHANCEMENT-SECTION     BESTELLUNG_WA_LB_POP_02 SPOTS ES_SAPMM07M.
      MSEG-BWART = RM07M-BWART.
END-ENHANCEMENT-SECTION.
      if mseg-lgort is initial.        " SC-batch
        MSEG-LGORT = RM07M-LGORT.
      endif.                           " SC-batch
      PERFORM FUSSZEILE_BEW_PRUEFEN.
      PERFORM FUSS_ERGAENZEN.
      CLEAR FUSS-XPRUE.
      FUSS-FCODE = FCOD-NP.
      FUSS-XSELP = FCAUSW-XSELP.
      FUSS-XSELK = T158-XSELE.
      PERFORM FUSS_NACH_YFUSS.
    ENDLOOP.
    PERFORM FUSS_AUS_YFUSS.
    FREE XMDGI.
    IF XAKTIV IS INITIAL.
      XAKTIV = X.
    ENDIF.
  ENDFORM.