***INCLUDE MV45AF0L_LEAVE_SCREEN .

*--------------------------------------------------------------------*
*      module leave_screen                                           *
*--------------------------------------------------------------------*
*      es wird geprüft, ob ein leave_screen durchgeführt werden muß  *
*--------------------------------------------------------------------*
MODULE LEAVE_SCREEN.

  IF FLAG_LEAVE_SCREEN NE SPACE.
    CLEAR FLAG_LEAVE_SCREEN.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.