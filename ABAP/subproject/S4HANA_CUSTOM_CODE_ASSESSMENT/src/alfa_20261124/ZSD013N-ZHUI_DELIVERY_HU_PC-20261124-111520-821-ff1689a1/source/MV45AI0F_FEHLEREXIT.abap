*---------------------------------------------------------------------*
*       MODULE FEHLEREXIT INPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE FEHLEREXIT INPUT.

  IF FEHLEREXIT = 'X'.
    PERFORM FCODE_BEARBEITEN.
    FEHLEREXIT = ' '.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.