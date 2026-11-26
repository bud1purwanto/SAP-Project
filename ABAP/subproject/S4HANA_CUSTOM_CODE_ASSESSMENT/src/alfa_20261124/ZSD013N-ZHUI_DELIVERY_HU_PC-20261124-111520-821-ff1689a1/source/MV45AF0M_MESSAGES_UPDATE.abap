*&---------------------------------------------------------------------*
*&      Form  MESSAGES_UPDATE
*&---------------------------------------------------------------------*
*       Nachrichtensteuerung                                          *
*----------------------------------------------------------------------*
FORM MESSAGES_UPDATE.

  IF CALL_FUNCTION IS INITIAL.
    CALL FUNCTION 'RV_MESSAGES_UPDATE'
         EXPORTING
              MSG_KAPPL = TVAK-KAPPL
              MSG_OBJKY = XOBJKY.
  ELSE.
    CALL FUNCTION 'RV_MESSAGES_UPDATE'
         EXPORTING
              MSG_KAPPL            = TVAK-KAPPL
              MSG_OBJKY            = XOBJKY
              MSG_REPLACEMENT_DONE = CHARX.
  ENDIF.

* Nachrichten initialisieren
  CALL FUNCTION 'RV_MESSAGES_REFRESH'
       EXPORTING
            MSG_KAPPL = TVAK-KAPPL.
  CLEAR: PROPOS,
         XOBJKY.

ENDFORM.