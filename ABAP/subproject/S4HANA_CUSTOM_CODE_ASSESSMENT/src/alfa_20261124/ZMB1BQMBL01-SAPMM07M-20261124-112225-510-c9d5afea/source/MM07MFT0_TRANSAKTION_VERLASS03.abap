*eject
*---------------------------------------------------------------------*
*       FORM TRANSAKTION_VERLASSEN_PRUEFEN                            *
*---------------------------------------------------------------------*
*       Es wird geprüft, wie die Transaktion zu verlassen ist.        *
*---------------------------------------------------------------------*
FORM TRANSAKTION_VERLASSEN_PRUEFEN.
  IF NOT T063F-XENDE IS INITIAL.
    IF NOT ANF_BILD IS INITIAL.
      PERFORM TRANSAKTION_VERLASSEN_OHNE.
    ENDIF.
    IF SY-DATAR IS INITIAL AND FCAUSW-XSELP IS INITIAL AND
       XCONFIRM IS INITIAL.
      PERFORM TRANSAKTION_VERLASSEN_OHNE.
    ENDIF.
    IF T158-TRTYP NE A AND NOT XCONFIRM IS INITIAL.
      PERFORM TRANSAKTION_VERLASSEN.
      EXIT.
    ELSE.
      IF NOT FCAUSW-XSELP IS INITIAL OR NOT SY-DATAR IS INITIAL.
        PERFORM TRANSAKTION_VERLASSEN.
        EXIT.
      ELSE.
        PERFORM TRANSAKTION_VERLASSEN_OHNE.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT T063O-XBACK IS INITIAL.
    IF NOT ANF_BILD IS INITIAL.
      SET SCREEN 0.
      LEAVE SCREEN.
    ENDIF.
    IF NOT SY-CALLD IS INITIAL AND T158-TRTYP NE H.
      IF FCODE = CALL_FCODE OR FCODE = FCOD-AB.
        LEAVE.
      ELSE.
        FCODE_NEXT = FCOD-AB.
        AUFSETZEN_1 = 1.
        EXIT.
      ENDIF.
    ENDIF.
    IF SY-DATAR IS INITIAL AND FCAUSW-XSELP IS INITIAL AND
       XCONFIRM IS INITIAL.
      IF T158-TRTYP = H.
        IF SY-CALLD IS INITIAL.
*{   DELETE         TRDK904688                                        1
*\          LEAVE TO TRANSACTION TCODE.
*}   DELETE
*{   INSERT         TRDK904688                                        2
*    bap => pas back dia balik ke current tcode ga ke tcode di program
     TCODE = CL_DYNPRO=>GET_CURRENT_TRANSACTION( ) .
     LEAVE TO TRANSACTION tcode.
*}   INSERT
        ELSE.
          LEAVE.
        ENDIF.
      ELSE.
        IF ( FCODE_NEXT = FCOD-KL OR FCODE_NEXT = FCOD-AB )
           AND ( FCODE = FCOD-KL OR FCODE = FCOD-AB ).
          IF SY-CALLD IS INITIAL.
            LEAVE TO TRANSACTION TCODE.
          ELSE.
            LEAVE.
          ENDIF.
        ELSE.
          FCODE_NEXT = FCOD-AB.
        ENDIF.
      ENDIF.
    ELSE.
      IF FCODE = FCOD-AB AND FCODE_NEXT = FCOD-AB.
        PERFORM TRANSAKTION_VERLASSEN.
        AUFSETZEN_1 = 1.
      ELSE.
        IF SY-DATAR IS INITIAL.
          FCODE_NEXT = FCOD-AB.
          CLEAR RC.
          IF FCAUSW-XLIST IS INITIAL.
            READ TABLE FUSS INDEX 1.
            IF SY-SUBRC IS INITIAL.
              CLEAR XSELE.
              FCODE_NEXT = FCOD-KL.
              IF NOT FUSS-XSELS IS INITIAL.
                FCODE_NEXT = FCOD-SL.
                XBACK = X.
              ENDIF.
              EXIT.
            ELSE.
              IF NOT MSEG-MATNR IS INITIAL.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
          FREE BIWE.
          FREE BILD.
          PERFORM FCODE_PRUEFEN.
          PERFORM DYNPRO_VORBEREITEN.
          PERFORM FCODE_BEARBEITEN.
          CLEAR OK-CODE.
          CLEAR ABBRECHEN.
          LEAVE SCREEN.
        ELSE.
          CASE FCODE.
            WHEN FCOD-NP.
              CLEAR T_INDEX.
              DESCRIBE TABLE FUSS LINES T_INDEX.
              IF NOT T_INDEX IS INITIAL.
                CLEAR XSELE.
                FCODE_NEXT = T158-FCODE.
              ENDIF.
            WHEN FCOD-KP.
              FCODE_NEXT = FCOD-AB.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.