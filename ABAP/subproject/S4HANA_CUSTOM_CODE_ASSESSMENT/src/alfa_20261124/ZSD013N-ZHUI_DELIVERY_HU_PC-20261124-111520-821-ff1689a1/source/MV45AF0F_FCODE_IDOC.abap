*&---------------------------------------------------------------------*
*&      Form  FCODE_IDOC
*&---------------------------------------------------------------------*
*       Meldung, falls kein IDOC zum aktuellen Abruf vorhanden ist     *
*       und Rücksprung.                                                *
*       Der Aufruf der IDOC-Anzeige erfolgt über die Form              *
*       DELIVERY_SCHEDULE_IDOC aus der Bildfolgesteuerung.             *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_IDOC.

  IF VBLB-DOCNUM IS INITIAL.
    PERFORM MESSAGE_IDOC_DISPLAY.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ENDIF.

ENDFORM.