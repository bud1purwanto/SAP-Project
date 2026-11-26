*eject
*---------------------------------------------------------------------*
*       FORM ABBRECHEN                                                *
*---------------------------------------------------------------------*
*       Wenn die zweite Call-Stufe mit EXIT-Code verlassen wurde,     *
*       wird das darunterliegende PopUp nochmal gesendet.             *
*---------------------------------------------------------------------*
FORM ABBRECHEN.
  IF NOT ABBRECHEN IS INITIAL.
    CLEAR T063C.
    CLEAR ABBRECHEN.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.