*&---------------------------------------------------------------------*
*&      Form  CCARD_LAST_DIALOG
*&---------------------------------------------------------------------*
*       If the authorisation is failure, a popup comes over.
*       The user has the choice to save the sales order
*       or cancel it
*----------------------------------------------------------------------*
*      -->P_US_TEXT     Text in display field
*      -->P_US_SICHERN  Flag indicates sales order will be
*                       saved or not.
*----------------------------------------------------------------------*
FORM CCARD_LAST_DIALOG USING    P_US_TEXT
                                P_US_SICHERN.

  DATA: DA_ANSWER(1) TYPE C.

  IF CALL_FUNCTION = SPACE AND
    ( SY-BINPT = SPACE OR
      BI_INFO-CTU_AMODUS CA 'A' OR
      NOT CATTAKTIV IS INITIAL ).
    IF SY-PFKEY NE 'FE  '.
      CALL FUNCTION 'POPUP_TO_DECIDE'
           EXPORTING
                TITEL          = TEXT-280
                TEXTLINE1      = P_US_TEXT
                TEXTLINE3      = TEXT-282
                TEXT_OPTION1   = TEXT-285
                TEXT_OPTION2   = TEXT-286
                CANCEL_DISPLAY = 'X'
                DEFAULTOPTION  = '2'
                START_COLUMN   = 25
                START_ROW      = 6
           IMPORTING
                ANSWER         = DA_ANSWER.
*     Abbrechen
      IF DA_ANSWER = CHARA.
        FCODE = FCODE_GLEICHE_SEITE.
        PERFORM FCODE_BEARBEITEN.
        P_US_SICHERN = 4.
        EXIT.
      ENDIF.
*     Bearbeiten
      IF DA_ANSWER = CHAR2.
        FCODE = 'ENT1'.
        PERFORM FCODE_BEARBEITEN.
        P_US_SICHERN = 4.
        EXIT.
      ENDIF.
*     Sichern.
      P_US_SICHERN = 0.
    ENDIF.
  ENDIF.

  if call_activity eq gc_activity_lord.
    message p_us_text type 'W'.
    message_collect_lord.
    p_us_sichern = 0.
    return.
  endif.

ENDFORM.                               " CCARD_LAST_DIALOG