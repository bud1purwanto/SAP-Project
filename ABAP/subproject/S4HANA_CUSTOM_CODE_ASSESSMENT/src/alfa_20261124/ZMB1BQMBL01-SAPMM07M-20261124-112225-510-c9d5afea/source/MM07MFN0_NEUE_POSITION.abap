*---------------------------------------------------------------------*
*       FORM NEUE_POSITION                                            *
*---------------------------------------------------------------------*
*       Über F-Taste bzw. PopUp wurden Daten für eine neue            *
*       Position eingegeben.                                          *
*---------------------------------------------------------------------*
FORM NEUE_POSITION.

  IF NOT BCODE-BWART IS INITIAL AND BCODE-BWART NE T156-BWART AND
     ( NOT FCAUSW-XNEUP IS INITIAL OR NOT FCAUSW-XSELP IS INITIAL ).
    PERFORM BEWEGUNGSART_PRUEFEN(SAPFM07M) USING BCODE-BWART
                                                 SPACE.
  ENDIF.
  IF T158-KZBEW IS INITIAL.
    IF FCODE_NEXT = FCOD-KL(20) OR FCODE_NEXT = FCOD-KP(20).
      DESCRIBE TABLE YMSEG LINES INDEX_K.
      CLEAR VW.
      IF NOT BCODE-BWART IS INITIAL AND INDEX_K IS INITIAL.
        VW = X.
      ENDIF.
      IF NOT T156-KZBWA IS INITIAL.
        IF BCODE-BWART IS INITIAL AND INDEX_K IS INITIAL.
          BCODE-BWART = T156-BWART.
          VW = X.
        ENDIF.
        IF NOT BCODE-BWART IS INITIAL AND NOT INDEX_K IS INITIAL.
          CLEAR VW.
          CLEAR: BCODE-BWART, BCODE-SOBKZ.
        ENDIF.
      ENDIF.
      IF VW = X.
        IF FCAUSW-XLIST IS INITIAL.
          FCODE = FCODE_NEXT = FCOD-NP(20).
        ELSE.
          FCODE = FCODE_NEXT = FCOD-NL(20).
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR VW.
  ENDIF.
  IF ( FCODE_NEXT = FCOD-NL(20) OR FCODE_NEXT = FCOD-NP(20) ).
    IF NOT BCODE-BWART IS INITIAL.
      CLEAR VW.
      CLEAR: MSEG-KZZUG, MSEG-KZVBR.
      PERFORM SONDERBESTKZ_PRUEFEN(SAPFM07M) USING BCODE-SOBKZ
                                                   VM07M-SOBFI
                                                   VM07M-SOBLO
                                                   VM07M-SOBVO.
      PERFORM BILDAUSWAHL_PRUEFEN(SAPFM07M) USING BCODE-BWART
                                                  BCODE-SOBKZ.
      PERFORM BEWEGUNGSTEXT_LESEN(SAPFM07M) USING BCODE-BWART
                                                  BCODE-SOBKZ
                                                   MSEG-KZBEW
                                                   MSEG-KZZUG
                                                   MSEG-KZVBR
                                                  DM07M-BTEXT.
      RM07M-BWART = BCODE-BWART.
      RM07M-SOBKZ = BCODE-SOBKZ.
      CLEAR BCODE.
      NEXT_BTEXT = DM07M-BTEXT.
      NEXT_SOBFI = VM07M-SOBFI.
      NEXT_SOBLO = VM07M-SOBLO.
      NEXT_SOBVO = VM07M-SOBVO.
      NEXT_UMSOF = DM07M-UMSOF.
      NEXT_UMSOL = DM07M-UMSOL.
      NEXT_UMSOV = DM07M-UMSOV.
      NEXT_FAUSW = DM07M-FAUSW.
      NEXT_KZGRU = DM07M-KZGRU.
      NEXT_UMSOK = MSEG-UMSOK.
    ELSE.
      IF NEXT_BTEXT IS INITIAL.
        DESCRIBE TABLE YDM07M LINES INDEX_K.
        IF NOT INDEX_K IS INITIAL.
          READ TABLE YDM07M INDEX INDEX_K.
          IF NOT SY-SUBRC IS INITIAL.
            MESSAGE E001 WITH 'YDM07M' INDEX_K.
          ENDIF.
          NEXT_BTEXT = YDM07M-BTEXT.
          NEXT_UMSOF = YDM07M-UMSOF.
          NEXT_UMSOL = YDM07M-UMSOL.
          NEXT_UMSOV = YDM07M-UMSOV.
          NEXT_FAUSW = YDM07M-FAUSW.
          NEXT_KZGRU = YDM07M-KZGRU.
          READ TABLE YVM07M INDEX INDEX_K.
          IF NOT SY-SUBRC IS INITIAL.
            MESSAGE E001 WITH 'YVM07M' INDEX_K.
          ENDIF.
          NEXT_SOBFI = YVM07M-SOBFI.
          NEXT_SOBLO = YVM07M-SOBLO.
          NEXT_SOBVO = YVM07M-SOBVO.
          READ TABLE YMSEG INDEX INDEX_K.
          IF NOT SY-SUBRC IS INITIAL.
            MESSAGE E001 WITH 'YMSEG' INDEX_K.
          ENDIF.
          NEXT_UMSOK = YMSEG-UMSOK.
          CLEAR INDEX_K.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF DM07M-FAUSW IS INITIAL.
    IF RM07M-KZBEW IS INITIAL OR RM07M-KZBEW = B.  "204573
      DM07M-FAUSW = OLD_FAUSW.
      DM07M-BTEXT = OLD_BTEXT.
      DM07M-KZGRU = OLD_KZGRU.
      VM07M-SOBFI = OLD_SOBFI.
      VM07M-SOBLO = OLD_SOBLO.
      VM07M-SOBVO = OLD_SOBVO.
      DM07M-UMSOF = OLD_UMSOF.
      DM07M-UMSOL = OLD_UMSOL.
      DM07M-UMSOV = OLD_UMSOV.
      MSEG-UMSOK  = OLD_UMSOK.
      CLEAR: OLD_FAUSW,
             OLD_BTEXT,
             OLD_KZGRU,
             OLD_UMSOK,
             OLD_SOBFI, OLD_UMSOF,
             OLD_SOBLO, OLD_UMSOL,
             OLD_SOBVO, OLD_UMSOV.
    ENDIF.
  ENDIF.

ENDFORM.