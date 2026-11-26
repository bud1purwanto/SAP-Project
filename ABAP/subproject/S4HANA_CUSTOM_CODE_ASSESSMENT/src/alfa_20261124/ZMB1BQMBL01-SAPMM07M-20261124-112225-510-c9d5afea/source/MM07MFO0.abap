*---------------------------------------------------------------------*
*       FORM OK-CODE_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Der OK-Code wird geprueft und ausgewertet.                    *
*---------------------------------------------------------------------*
FORM OK-CODE_PRUEFEN.
ENHANCEMENT-POINT OK-CODE_PRUEFEN_01 SPOTS ES_SAPMM07M.
  IF XKZBEW IS INITIAL.
    OLD_FCODE  = FCODE.
  ENDIF.
  OLD_XKZBEW  = XKZBEW.
  IF NOT XKZBEW IS INITIAL.
    NEXT_XKZBEW = XKZBEW.
  ENDIF.
  IF T063C-CCODE = CCOD-NEBE AND OK-CODE = 'OK'.
    FCODE_NEXT = FCOD-NL.
  ENDIF.
  IF NOT ANF_BILD IS INITIAL.
    CLEAR: BCODE-BWART,
           BCODE-SOBKZ.
  ENDIF.
ENHANCEMENT-POINT MM07MFO0_01 SPOTS ES_SAPMM07M.
  CHECK NOT OK-CODE IS INITIAL.
  SELECT SINGLE * FROM T063O WHERE OK_CODE = OK-CODE.
  IF NOT SY-SUBRC IS INITIAL.
    DATA: OKCODE LIKE OK-CODE.
    OKCODE = OK-CODE.
    CLEAR OK-CODE.
    MESSAGE E002 WITH OKCODE.
  ENDIF.
  IF NOT T063O-SICHT IS INITIAL.
    IF T063O-SICHT = '00'.
      CLEAR T063O-SICHT.
    ENDIF.
    SET PARAMETER ID 'SIC' FIELD T063O-SICHT.
  ENDIF.
  CCODE = T063O-CCODE.
  IF NOT ANF_BILD IS INITIAL AND T063O-CCODE = CCOD-NFBL
     AND T063C-CCODE = CCOD-NEBE.
    CLEAR: CCODE, T063O.
  ENDIF.
  PCODE_NEXT  = T063O-PCODE.
*  IF NOT T063O-BWART IS INITIAL AND SY-BINPT IS INITIAL.   "note 316370
  IF NOT T063O-BWART IS INITIAL.                            "note 316370
    BCODE-BWART = T063O-BWART.
    BCODE-SOBKZ = T063O-SOBKZ.
  ENDIF.
  IF T063O-CCODE IS INITIAL AND NOT T063O-TCODE IS INITIAL AND
     NOT ANF_BILD IS INITIAL AND T063O-FCODE NE FCOD-EN.
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        TCODE   = t063o-tcode
      EXCEPTIONS
        OK        = 0
        NOT_OK    = 1
        OTHERS    = 2.
    IF SY-SUBRC = 0.
      CALL TRANSACTION T063O-TCODE.
    else.
      message s172(00) with t063o-tcode.
    endif.
    IF SY-CALLD IS INITIAL.
      LEAVE TO TRANSACTION TCODE.
    ELSE.
      LEAVE.
    ENDIF.
  ENDIF.
  IF NOT T063O-FCODE IS INITIAL.
    SELECT SINGLE * FROM T063F WHERE FCODE EQ T063O-FCODE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH '063F' T063O-FCODE.
    ENDIF.
    IF NOT T063F-XNEUP IS INITIAL AND NOT RM07M-BWART IS INITIAL
       AND T063O-OK_CODE NE 'NLWE'
       AND T063O-OK_CODE NE 'NLWS'.
      CLEAR: CCODE, T063O-CCODE.
      CLEAR: PCODE_NEXT.
    ENDIF.
*   IF T063O-OK_CODE = 'NLWE' OR T063O-OK_CODE = 'NLWS'.
*     CLEAR RM07M-KZBEW.
*     XKZBEW = X.
*   ENDIF.
    IF T158-TRTYP = H.
      READ TABLE YMSEG INDEX 1.
      IF SY-SUBRC IS INITIAL.
        XCONFIRM = X.
      ELSE.
        IF FCODE = FCOD-AB.
          CLEAR XCONFIRM.
        ENDIF.
      ENDIF.
      IF T063F-XLIST IS INITIAL AND NOT T063F-XSELP IS INITIAL.
        XSELE = X.
      ENDIF.
    ENDIF.
    IF NOT T063F-XENDE IS INITIAL OR NOT T063O-XBACK IS INITIAL.
      PERFORM TRANSAKTION_VERLASSEN_PRUEFEN.
    ELSE.
      IF NOT T063O-FCODE IS INITIAL.
        FCODE_NEXT = T063O-FCODE.
      ELSE.
        FCODE_NEXT = FCODE.
      ENDIF.
    ENDIF.
    IF NOT FCAUSW-XSELP IS INITIAL AND FCODE_NEXT = FCOD-KL AND
       NOT T063O-CCODE IS INITIAL.
      FCODE_NEXT = FCOD-SL.
    ENDIF.
    IF NOT FCAUSW-XLIST IS INITIAL AND
       ( FCODE_NEXT = FCOD-SP  OR FCODE_NEXT = FCOD-SS  OR
         FCODE_NEXT = FCOD-SUU OR
         FCODE_NEXT = FCOD-SSF OR FCODE_NEXT = FCOD-SSR ).
      CLEAR INDEX_L.
      LOOP AT FUSS WHERE XSELK NE SPACE.
        INDEX_L = INDEX_L + 1.
      ENDLOOP.
      IF INDEX_L IS INITIAL AND ANF_BILD IS INITIAL.
        FCODE_NEXT = FCOD-AB.
      ENDIF.
    ENDIF.
    IF FCODE = FCOD-AB AND T063O-OK_CODE = FCOD-KLA.
      FCODE_NEXT = FCOD-AB.
    ENDIF.
    IF ( FCODE_NEXT = FCOD-AB OR FCODE_NEXT = FCOD-KL ) AND
       T063O-XBACK IS INITIAL.
      AUFSETZEN_1 = 1.
    ENDIF.
    CLEAR L_ZEILE.
  ENDIF.
  IF NOT T063O-AUSWA IS INITIAL.
    PERFORM OK-CODE_PRUEFEN_AUSWAHL.
  ENDIF.
  IF NOT T063O-CCODE IS INITIAL OR NOT T063O-TCODE IS INITIAL
     AND NOT T063O-TCODE = TCOD-MB00.
    XPF02 = X.
    IF NOT T063O-XCURS IS INITIAL.
      PERFORM OK-CODE_PRUEFEN_AUFRUF.
    ELSE.
      IF NOT T063O-TCODE IS INITIAL AND T063O-OK_CODE = CCOD-FB03.
        PERFORM TRANSAKTION_AUFRUFEN.
        CLEAR XPF02.
      ELSE.
        INDEX_L = INDEX_Z = MSEG-ZEILE.
      ENDIF.
    ENDIF.
    IF T063O-CCODE EQ CCOD-VKU3.                                  " PPF
       PERFORM VKBELEG_ANZEIGEN.                                  " PPF
    ENDIF.                                                        " PPF
  ENDIF.
  IF T063O-BWART NE SPACE.
    PERFORM BEWEGUNGSART_LESEN(SAPFM07M) USING BCODE-BWART.
    IF T158-KZBEW IS INITIAL OR XKZBEW = 1.
      RM07M-BWARTWA = RM07M-BWART = BCODE-BWART.
      SET PARAMETER ID 'BWA' FIELD RM07M-BWARTWA.
      RM07M-SOBKZ = BCODE-SOBKZ.
    ELSE.
      RM07M-BWARTWE = RM07M-BWART = BCODE-BWART.
      SET PARAMETER ID 'BWE' FIELD RM07M-BWARTWE.
    ENDIF.
  ENDIF.
  IF CCODE NE SPACE AND T063O-TCODE IS INITIAL.
    SELECT SINGLE * FROM T063C WHERE CCODE EQ CCODE.
    IF SY-SUBRC IS INITIAL.
      XPF02 = T063C-XPF02.
      IF T063C-AUFRUF IS INITIAL.
        IF T063C-XPF02 IS INITIAL.
          WHILE CCODE NE SPACE AND T063C-XMODA = SPACE.
            PERFORM DYNPRO_CALL.
          ENDWHILE.
        ENDIF.
        IF NOT ABBRECHEN IS INITIAL AND NOT ANF_BILD IS INITIAL.
          CLEAR: ABBRECHEN, T063O, T063C.
          SET SCREEN SY-DYNNR.
          LEAVE SCREEN.
        ENDIF.
        CLEAR: T063C, T063O.
      ENDIF.
    ELSE.
      CLEAR: T063C, T063O.
    ENDIF.
    EXIT.
  ENDIF.
*--- Mehrstufige POP-UP's:                                           -*
*--- in einem Pop-Up wird bei                                        -*
*--- einem CCODE ungleich Space ein weiteres POP-UP-Window aufgerufen-*
* IF CCODE NE SPACE AND OK-CODE NE FCOD-EC AND CCODE NE X.
  IF NOT CCODE IS INITIAL AND CCODE NE X.
    SELECT SINGLE * FROM T063C WHERE CCODE EQ CCODE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH '063C' CCODE.
    ENDIF.
    WHILE CCODE NE SPACE AND T063C-XMODA IS INITIAL.
      PERFORM DYNPRO_CALL.
    ENDWHILE.
    CLEAR CCODE.
  ENDIF.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM OK-CODE_PRUEFEN_AUFRUF                                   *
*---------------------------------------------------------------------*
*       Bearbeitung, wenn OK-Code eine Transaktion bzw. Dialogfenster *
*       aufruft.                                                      *
*---------------------------------------------------------------------*
FORM OK-CODE_PRUEFEN_AUFRUF.
  IF FCAUSW-XLIST IS INITIAL.
    INDEX_L = INDEX_Z = MSEG-ZEILE.
  ELSE.
    GET CURSOR FIELD VW LINE INDEX_L.
ENHANCEMENT-POINT MM07MFO0_02 SPOTS ES_SAPMM07M.

    IF INDEX_L IS INITIAL.
      PERFORM UNGUELTIGE_ZEILE.
    ELSE.
      INDEX_L = INDEX_L + AUFSETZEN_1 - 1.
      INDEX_Z = AUFSETZEN_1.
    ENDIF.
  ENDIF.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM OK-CODE_PRUEFEN_AUSWAHL                                  *
*---------------------------------------------------------------------*
*       Bearbeitung, wenn OK-Code eine Auswahl bewirkt.               *
*---------------------------------------------------------------------*
FORM OK-CODE_PRUEFEN_AUSWAHL.
  CASE T063O-AUSWA.
    WHEN P.
      GET CURSOR FIELD VW LINE INDEX_L.
      INDEX_L = INDEX_L + AUFSETZEN_1 - 1.
      IF INDEX_L IS INITIAL.
        PERFORM UNGUELTIGE_ZEILE.
      ELSE.
        RM07M-ZEILE = INDEX_L.
      ENDIF.
    WHEN S.
      KREUZ = X.
    WHEN T.
      KREUZ = SPACE.
    WHEN OTHERS.
      KREUZ = X.
      IF T063O-AUSWA = X.
        KREUZ = X.
      ELSE.
        KREUZ = SPACE.
      ENDIF.
      LOOP AT FUSS.
        FUSS-XSELK = KREUZ.
        MODIFY FUSS INDEX SY-TABIX.
      ENDLOOP.
  ENDCASE.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM OK-CODE_POP_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Der OK-Code auf dem PopUp wird ausgewertet.                   *
*---------------------------------------------------------------------*
FORM OK-CODE_POP_PRUEFEN.
  SELECT SINGLE * FROM T063O WHERE OK_CODE = OK-CODE.
  IF SY-SUBRC NE 0.
    MESSAGE E001 WITH '063O' OK-CODE.
  ENDIF.
  IF NOT T063O-FCODE IS INITIAL.
    SELECT SINGLE * FROM T063F WHERE FCODE EQ T063O-FCODE.
    IF SY-SUBRC NE 0.
      MESSAGE E001 WITH '063F' T063O-FCODE.
    ENDIF.
    FCODE_NEXT = T063O-FCODE.
    IF FCODE_NEXT = FCOD-SP OR FCODE_NEXT = FCOD-SS OR
       FCODE_NEXT = FCOD-SUU OR
       FCODE_NEXT = FCOD-SSF OR FCODE_NEXT = FCOD-SSR.
      FCODE = FCODE_NEXT.
      PERFORM FCODE_LESEN USING FCODE.
      IF T063F-XLIST IS INITIAL.
        XSELE = X.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*eject