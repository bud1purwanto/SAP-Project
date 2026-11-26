*eject
*---------------------------------------------------------------------*
*       FORM   POPUP_VERLASSEN                                        *
*---------------------------------------------------------------------*
*       Verarbeitung bei EXIT-COMMAND auf POPUP                       *
*---------------------------------------------------------------------*
FORM POPUP_VERLASSEN.

  CASE RM07M-KZBEW.
    WHEN B.
      REFRESH: XMSEG, XMKPF, XRKPF, XEKSEL,
               XEBEFU, XEKBNK, XEBEFU_CR, XEKBNK_CR.
      CLEAR  : XEBEFU, XMSEG, XMKPF, XEKSEL, KBEFU,
               XEBEFU, XEKBNK, XEBEFU_CR, XEKBNK_CR.
      CLEAR  : RM07M-EBELN, RM07M-EBELP.
      CLEAR  : RM07M-MBLNR, RM07M-MJAHR.
    WHEN F.
      REFRESH: XFBEFU, XMSEG, XMKPF.
      CLEAR  : XFBEFU, XMSEG, XMKPF.
      CLEAR  : RM07M-AUFNR, RM07M-AUFPS.
      CLEAR  : RM07M-MBLNR, RM07M-MJAHR.
    WHEN OTHERS.
      REFRESH: XRBEFU, XMSEG, XMKPF, XRKPF, XSTPOX.
      CLEAR  : XRBEFU, XMSEG, XMKPF, XRKPF, XSTPOX.
      CLEAR  : RM07M-RSNUM, RM07M-RSPOS.
      CLEAR  : RM07M-CAPID, RM07M-STLAL, RM07M-SMENG.
      CLEAR  : RM07M-MBLNR, RM07M-MJAHR.
      PERFORM SUCHFELDER_INIT.
  ENDCASE.
  IF NOT ANF_BILD IS INITIAL.
    READ TABLE FUSS INDEX 1.
    IF NOT SY-SUBRC IS INITIAL.
      IF NOT SY-CALLD IS INITIAL.
        LEAVE TO TRANSACTION SY-TCODE.
      ENDIF.
      CLEAR: BCODE-BWART, BCODE-SOBKZ.
      ABBRECHEN = X.
      CLEAR XSELE.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
  IF NOT OLD_FCODE IS INITIAL.
    FCODE_NEXT = OLD_FCODE.
  ENDIF.
  XKZBEW = NEXT_XKZBEW = OLD_XKZBEW.
  IF OLD_FCODE = FCOD-NP.
    if index_z = 0 and sy-dynnr = 1501.                        "689905
      FCODE_NEXT = FCOD-NP.                                    "689905
    else.                                                      "689905
      FCODE_NEXT = FCOD-KP.                                    "689905
    endif.                                                     "689905
  ELSEIF FCODE = FCOD-NL AND XKZBEW = 3.
    FCODE_NEXT = FCOD-NG.
  ELSEIF XKZBEW = 1.
    IF FCODE = FCOD-NL.
      FCODE_NEXT = FCOD-KL.
    ELSEIF FCODE = FCOD-SL.
      FCODE_NEXT = FCOD-KL.
      READ TABLE FUSS INDEX 1.
      IF SY-SUBRC IS INITIAL.
        FCODE_NEXT = FCOD-SL.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR FUSS.
  IF FCODE_NEXT NE FCODE AND XPF02 IS INITIAL.
    PERFORM FCODE_PRUEFEN.
    IF NOT FCAUSW-XSELP IS INITIAL.
      READ TABLE FUSS INDEX 1.
      IF NOT SY-SUBRC IS INITIAL.
        FCODE_NEXT = FCOD-AB.
        PERFORM FCODE_PRUEFEN.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT AUFSETZEN IS INITIAL.
    RM07M-ZEILE = AUFSETZEN.
  ENDIF.
  CLEAR VW.
  IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
    IF NOT OLD_BWARTWA IS INITIAL.
      RM07M-BWARTWA = RM07M-BWART = OLD_BWARTWA.
      RM07M-SOBKZ   = OLD_SOBKZ.
      VW = X.
    ENDIF.
  ELSE.
    IF NOT OLD_BWARTWE IS INITIAL.
      RM07M-BWARTWE = RM07M-BWART = OLD_BWARTWE.
      VW = X.
    ENDIF.
  ENDIF.
  IF VW = X.
    RM07M-WERKS = OLD_WERKS. CLEAR OLD_WERKS.
    RM07M-LGORT = OLD_LGORT. CLEAR OLD_LGORT.
    IF NOT XBCODE IS INITIAL.
*--   für Umlagerungsbestellung, damit kein Fehler bei 351/352 wenn   -*
*--   Dialogfenster abgebrochen wird                                  -*
      BCODE-BWART = OLD_BWARTWA.
      BCODE-SOBKZ = OLD_SOBKZ.
      CLEAR: OLD_BWARTWA, OLD_SOBKZ, XBCODE.
    ENDIF.
  ENDIF.
  CLEAR VW.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.