*---------------------------------------------------------------------*
*       MODULE INCOMPLOG_SET_CURSOR OUTPUT                            *
*---------------------------------------------------------------------*
*       Cursorpositionierung auf das zu vervollständigende Feld       *
*       während Abarbeitung des Unvollständigkeitsprotokolls          *
*---------------------------------------------------------------------*
MODULE INCOMPLOG_SET_CURSOR OUTPUT.

  IF FEHLER = 'X'.
    SET CURSOR FIELD FEHLERFELD.
  ENDIF.

ENDMODULE.