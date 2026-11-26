*eject
*---------------------------------------------------------------------*
*       FORM AUSNAHME_BEARBEITEN                                      *
*---------------------------------------------------------------------*
*       Nach erfolgloser Selektion kommt es zur Behandlung der Aus-   *
*       nahme.                                                        *
*---------------------------------------------------------------------*
FORM AUSNAHME_BEARBEITEN.
  SELECT SINGLE * FROM T063C WHERE CCODE = CCOD-NEBE.
  IF SY-SUBRC IS INITIAL AND T158-KZBEW = B
     AND NOT T156-XNEBE IS INITIAL.
    CCODE = T063C-CCODE.
    XPF02 = X.
    PERFORM DYNPRO_CALL.
    CLEAR XPF02.
    IF ABBRECHEN IS INITIAL.
      IF FCODE_NEXT NE FCOD-NL.
        IF ANF_BILD IS INITIAL OR SY-TCODE NE 'MB0A'.
          SELECT SINGLE * FROM T063C WHERE CCODE = CCOD-NFBL.
          IF SY-SUBRC IS INITIAL.
            CCODE = CCOD-NFBL.
            PERFORM DYNPRO_CALL.
          ENDIF.
        ELSE.
          LEAVE TO TRANSACTION SY-TCODE.
        ENDIF.
      ELSE.
        IF ANF_BILD IS INITIAL AND
           ( DM07M-BTEXT IS INITIAL OR RM07M-BWART NE T156T-BWART ).
          PERFORM BEWEGUNGSTEXT_LESEN(SAPFM07M) USING RM07M-BWART
                                                      RM07M-SOBKZ
                                                      RM07M-KZBEW
                                                       MSEG-KZZUG
                                                       MSEG-KZVBR
                                                      DM07M-BTEXT.
        ENDIF.
      ENDIF.
    ELSE.
      IF NOT ANF_BILD IS INITIAL.
       LEAVE TO TRANSACTION SY-TCODE.
      ENDIF.
      IF NOT OLD_FCODE IS INITIAL.
        FCODE_NEXT = OLD_FCODE.
      ENDIF.
      CLEAR ABBRECHEN.
      CLEAR XKZBEW.
    ENDIF.
    EXIT.
  ELSE.
    MESSAGE E083.
  ENDIF.
ENDFORM.