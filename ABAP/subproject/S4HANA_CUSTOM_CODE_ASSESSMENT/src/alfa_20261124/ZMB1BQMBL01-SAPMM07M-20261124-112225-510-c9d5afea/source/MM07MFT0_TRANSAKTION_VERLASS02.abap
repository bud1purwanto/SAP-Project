*eject
*---------------------------------------------------------------------*
*       FORM   TRANSAKTION_VERLASSEN                                  *
*---------------------------------------------------------------------*
*       Laufende Transaktion wird verlassen.                          *
*---------------------------------------------------------------------*
FORM TRANSAKTION_VERLASSEN.
  IF T158-TRTYP = H AND FCAUSW-XSELP IS INITIAL.
    DESCRIBE TABLE YMSEG LINES INDEX_L.
    IF INDEX_L IS INITIAL.
      IF FCODE = FCOD-AB.
        CLEAR XCONFIRM.
      ENDIF.
      IF SY-DATAR IS INITIAL AND XCONFIRM IS INITIAL.
        PERFORM TRANSAKTION_VERLASSEN_OHNE.
      ENDIF.
    ELSE.
      CLEAR INDEX_L.
    ENDIF.
  ENDIF.
  IF T158-TRTYP = A.
    PERFORM TRANSAKTION_VERLASSEN_OHNE.
  ENDIF.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            TITEL     = TEXT-A01
            TEXTLINE1 = TEXT-A02
            TEXTLINE2 = TEXT-A03
       IMPORTING
            ANSWER    = CONFIRM.
  CASE CONFIRM.
    WHEN J.
      FCODE_NEXT = FCOD-BU.
      CLEAR OK-CODE.
    WHEN A.
      FCODE_NEXT = FCODE.
      IF NOT XSELE IS INITIAL.
        FCODE_NEXT = FCOD-AB.
      ELSE.
        IF FCODE_NEXT = FCOD-NP.
          FCODE_NEXT = FCOD-KP.
        ENDIF.
      ENDIF.
      CLEAR OK-CODE.
    WHEN N.
      PERFORM TRANSAKTION_VERLASSEN_OHNE.
  ENDCASE.
ENDFORM.