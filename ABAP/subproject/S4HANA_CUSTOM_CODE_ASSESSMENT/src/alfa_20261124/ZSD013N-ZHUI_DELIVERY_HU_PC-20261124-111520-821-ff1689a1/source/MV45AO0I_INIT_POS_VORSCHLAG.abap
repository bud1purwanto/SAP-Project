*---------------------------------------------------------------------*
*    MODULE INIT_POS_VORSCHLAG OUTPUT                                 *
*---------------------------------------------------------------------*
*    Initialisieren Flag zum Verlassen des Dynpros ohne Verarbeitung  *
*    für den Positionsvorschlag                                       *
*---------------------------------------------------------------------*

MODULE INIT_POS_VORSCHLAG OUTPUT.

  IF TVAK-TRVOG EQ CHAR5.
    CLEAR LEAVE_WITHOUT_CHECK.
  ENDIF.

ENDMODULE.                 " INIT_POS_VORSCHLAG  OUTPUT