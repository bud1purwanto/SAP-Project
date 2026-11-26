*&---------------------------------------------------------------------*
*&      Form  DELIVERY_SCHEDULE_IDOC
*&---------------------------------------------------------------------*
*       Anzeige des IDOCs zum aktuellen Abruf, falls vorhanden.        *
*       Aufruf aus der Bildfolgesteuerung.                             *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELIVERY_SCHEDULE_IDOC USING US_T185F
                                  US_T185
                                  US_T185V.

  DATA: DA_ACTION LIKE SY-UCOMM,
        DA_DOCNUM LIKE VBLB-DOCNUM.

  DA_DOCNUM = VBLB-DOCNUM.

  CALL FUNCTION 'EDI_DOCUMENT_STATUS_DISPLAY'
       EXPORTING
            DOCNUM                 = DA_DOCNUM
*         ACTIONS                = '      '
       IMPORTING
            ACTION                 = DA_ACTION
       EXCEPTIONS
            NO_STATUS_RECORD_FOUND = 1
            OTHERS                 = 2.
  IF SY-SUBRC EQ 1.
    PERFORM MESSAGE_IDOC_DISPLAY.
  ENDIF.
ENDFORM.                               " DELIVERY_SCHEDULE_IDOC