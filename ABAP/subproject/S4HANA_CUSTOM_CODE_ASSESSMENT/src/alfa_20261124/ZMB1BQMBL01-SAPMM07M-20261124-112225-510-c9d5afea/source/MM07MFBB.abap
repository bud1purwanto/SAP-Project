*---------------------------------------------------------------------*
*       FORM BLAETTERN                                                *
*       ueber PF21, PF22, PF23, PF24 in einer Tabelle blaettern.      *
*---------------------------------------------------------------------*
*       A_ZEILE   = aktuelle Buchungszeile                            *
*       L_ZEILE   = letzte Buchungszeile auf aktueller Seite          *
*       <FELD1>   = bisher erzeugte maximale Buchungszeile            *
*       MAX_ANZPO = maximal moegliche Anzahl Buchungszeile pro Seite  *
*                   Das Feld MAX_ANZPO wird in der FORM-Routine       *
*                   POSITION_SETZEN (MM07MFP0) aus SY-LOOPC gesetzt.  *
*---------------------------------------------------------------------*
FORM BLAETTERN.

  CHECK FCAUSW-XNEUP IS INITIAL.
  CLEAR: XKONT.
  IF FCAUSW-XSELP IS INITIAL.
    DESCRIBE TABLE YMSEG LINES ENDE.
  ELSE.
    DESCRIBE TABLE FUSS  LINES ENDE.
  ENDIF.
  IF ENDE IS INITIAL.
    CLEAR: PCODE, PCODE_NEXT.
    A_ZEILE = 1.
    EXIT.
  ENDIF.
  CASE PCODE.
    WHEN PCOD-PPLU.
      A_ZEILE = AUFSETZEN + 1.
      IF A_ZEILE > <F>.
        A_ZEILE = <F>.
        MESSAGE W750.
      ENDIF.
    WHEN PCOD-PMIN.
      A_ZEILE = AUFSETZEN - 1.
      IF A_ZEILE < 1.
        A_ZEILE = 1.
        MESSAGE W751.
      ENDIF.
    WHEN OTHERS.
      IF ( T158-KZBEW IS INITIAL OR XKZBEW = 1 )
         AND ( NOT FCAUSW-XSELP IS INITIAL OR
         NOT FCAUSW-XAENP IS INITIAL ).
        CASE PCODE.
          WHEN PCOD-ANFA.
            A_ZEILE = 1.
          WHEN PCOD-PLUS.
            A_ZEILE = L_ZEILE + 1.
            IF A_ZEILE > <F>.
              A_ZEILE = 1.
            ENDIF.
          WHEN PCOD-MINU.
            INDEX_L = AUFSETZEN_1 - 1.
            PERFORM BLAETTERN_K.
          WHEN PCOD-ENDE.
            INDEX_L = ENDE.
            PERFORM BLAETTERN_K.
            IF A_ZEILE > <F> AND NOT <F> IS INITIAL.
              A_ZEILE = <F>.
            ENDIF.
        ENDCASE.
      ELSE.
        START = AUFSETZEN_1.
        ANZAHL = MAX_ANZPO.
        IF NOT FCAUSW-XSELP IS INITIAL.
          DESCRIBE TABLE FUSS LINES ENDE.
        ENDIF.
        CALL FUNCTION 'SCROLLING_IN_TABLE'
             EXPORTING
                  ENTRY_ACT = START
                  ENTRY_TO  = ENDE
                  LOOPS     = ANZAHL
                  OK_CODE   = PCODE
             IMPORTING
                  ENTRY_NEW = INDEX_Z.
        A_ZEILE = INDEX_Z.
      ENDIF.
  ENDCASE.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM BLAETTERN_K.                                             *
*---------------------------------------------------------------------*
*       Bei Vorgängen die über das Dynpro 421 abgewickelt werden,     *
*       z. B. korrigieren in Listform, selektieren aus Auswahlliste   *
*       muss anders geblättert werden. Die Kontierung muss beim Blät- *
*       tern immer mit berücksichtigt werden.                         *
*---------------------------------------------------------------------*
FORM BLAETTERN_K.
  DATA: BEGIN OF V_MSEGK.
          INCLUDE STRUCTURE MSEGK.
  DATA: END OF V_MSEGK.
  DATA: BEGIN OF O_MSEGK.
          INCLUDE STRUCTURE MSEGK.
  DATA: END OF O_MSEGK.
  CLEAR: RC, SY-SUBRC, O_MSEGK, V_MSEGK, INDEX_Z.
  IF INDEX_L IS INITIAL.
    INDEX_L = 1.
  ENDIF.
  WHILE RC IS INITIAL AND SY-SUBRC IS INITIAL.
    IF FCAUSW-XSELP IS INITIAL.
      READ TABLE YMSEG INDEX INDEX_L.
      MOVE-CORRESPONDING YMSEG TO O_MSEGK.
      READ TABLE YDM07M INDEX INDEX_L.
      IF NOT YDM07M-XKMAN IS INITIAL.
        O_MSEGK-KONTO = YDM07M-KONTO.
      ENDIF.
    ELSE.
      READ TABLE FUSS INDEX INDEX_L.
      MOVE-CORRESPONDING FUSS TO O_MSEGK.
      IF NOT FUSS-XKMAN IS INITIAL.
        O_MSEGK-KONTO = FUSS-KONTO.
      ENDIF.
    ENDIF.
    IF NOT VM07M-XSTOR = ZWEI.
      IF YDM07M-FAUSW+55(1) = MINUS.
        CLEAR: O_MSEGK-UMMAT, V_MSEGK-UMMAT.
      ENDIF.
      IF YDM07M-FAUSW+56(1) = MINUS.
        CLEAR: O_MSEGK-UMWRK, V_MSEGK-UMWRK.
      ENDIF.
      IF YDM07M-FAUSW+57(1) = MINUS.
        CLEAR: O_MSEGK-UMLGO, V_MSEGK-UMLGO.
      ENDIF.
    ENDIF.
    INDEX_Z = INDEX_Z + 1.
    IF INDEX_Z = 1.
      V_MSEGK = O_MSEGK.
    ENDIF.
    IF V_MSEGK NE O_MSEGK OR INDEX_Z > MAX_ANZPO.
      A_ZEILE = INDEX_L + 1.
      RC = 4.
    ENDIF.
    INDEX_L = INDEX_L - 1.
    IF NOT SY-SUBRC IS INITIAL.
      A_ZEILE = 1.
    ENDIF.
  ENDWHILE.
ENDFORM.
*eject