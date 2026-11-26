*---------------------------------------------------------------------*
*       FORM FCODE_BACK                                               *
*---------------------------------------------------------------------*
*       Die Transaktion VA02 kann aus einer Listanzeige aufgerufen    *
*       werden.                                                       *
*       Beim Funktionscode "BACK" auf den Ort U0 wird durch diese     *
*       Form der Rücksprung in die Liste erreicht.                    *
*       Ansonsten wird vor dem Verlassen der Erfassungsmaske der      *
*       Beleg initialisiert.                                          *
*---------------------------------------------------------------------*
FORM FCODE_BACK.

  DATA: DA_SUBRC LIKE SY-SUBRC.
  FIELD-SYMBOLS: <check>.

* Aufruf z.B. aus VC01, IW51
  IF  CALL_DIALOG NE SPACE
  AND OLD_FCODE   NE FCODE_ENDE
  AND OLD_FCODE   NE FCODE_ABBRECHEN1
* Im Anzeigemodus nie Unvollständigkeit prüfen
  AND T180-TRTYP  NE CHARA.
    PERFORM INCOMPL_LAST_DIALOG USING DA_SUBRC.
    CHECK DA_SUBRC EQ 0.
    PERFORM CALL_DIALOG_EXPORT.
  ELSE.
* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.
  ENDIF.

* initialization in call transaction mode
  IF sy-calld <> SPACE.
*   configuration
    ASSIGN ('(SAPFV45S)sy-subrc') TO <check>.
    IF sy-subrc = 0.
      IF CALL_ACTIVITY NE ACTIVITY_SERVICE_ORDER AND
         CALL_ACTIVITY NE ACTIVITY_SERVICE_REQUEST.
        CALL FUNCTION 'CONFIGURATION_INITIALIZER'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.
*   technical objects / serial numbers
    ASSIGN ('(SAPLIWOL)sy-subrc') TO <check>.
    IF sy-subrc = 0.
      IF CALL_ACTIVITY NE ACTIVITY_SERVICE_ORDER AND
         CALL_ACTIVITY NE ACTIVITY_SERVICE_REQUEST.
        CALL FUNCTION 'IWOL_REFRESH_ALL'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.
  ENDIF.

* Object List
  ASSIGN ('(SAPLIOPOL)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'PMSDO_RESET'.
    CALL FUNCTION 'IOPOL_BUFFER_REFRESH'.
  ENDIF.
  UNASSIGN <check>.

  LEAVE.
  PERFORM BELEG_INITIALISIEREN.

ENDFORM.