*eject
*---------------------------------------------------------------------*
*       FORM AUSWAHL_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Wenn keine Auswahl in der Selektionsliste getroffen wurde,    *
*       wird ein Kontroll-Pop-Up gesendet.                            *
*---------------------------------------------------------------------*
FORM AUSWAHL_PRUEFEN.
  CLEAR: RC,
         VW,
         CONFIRM.

  LOOP AT FUSS                                              "0438401
          TRANSPORTING NO FIELDS
          WHERE XSELK NE SPACE.
    VW = X.
    EXIT.
  ENDLOOP.
  CLEAR FUSS.
  IF VW = X.
    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
      EXPORTING
        DEFAULTOPTION = N
        DIAGNOSETEXT1 = TEXT-B02
        DIAGNOSETEXT2 = TEXT-B03
        TEXTLINE1     = TEXT-B04
        TITEL         = TEXT-B01
      IMPORTING
        ANSWER        = CONFIRM.
    CASE CONFIRM.
      WHEN J.
        CLEAR F_ZEILE.
        REFRESH: FUSS, VAR_FUSS.
      WHEN OTHERS.
        RC = 4.
        IF NOT OLD_FCAUSW-FCODE IS INITIAL.
          FCODE = FCODE_NEXT = OLD_FCAUSW-FCODE.
        ELSE.
          FCODE = FCODE_NEXT.
        ENDIF.
        PERFORM FCODE_LESEN USING FCODE.
        CLEAR: T063C, T063O, CCODE.
    ENDCASE.
  ELSE.
    CLEAR F_ZEILE.
    REFRESH: FUSS, VAR_FUSS.
  ENDIF.
  CLEAR FUSS.
ENDFORM.                    "AUSWAHL_PRUEFEN