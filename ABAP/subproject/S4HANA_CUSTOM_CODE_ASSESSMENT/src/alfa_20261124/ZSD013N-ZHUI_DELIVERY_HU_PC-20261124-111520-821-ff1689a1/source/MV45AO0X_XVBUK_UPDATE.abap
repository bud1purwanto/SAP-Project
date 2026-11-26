*---------------------------------------------------------------------*
*       MODULE XVBUK_UPDATE                                           *
*---------------------------------------------------------------------*
*       Tabelle XVBUK wird zur Feldauswahl aktualisiert.               *
*---------------------------------------------------------------------*
MODULE XVBUK_UPDATE OUTPUT.
  CHECK T180-TRTYP EQ CHARV OR
        T180-TRTYP EQ CHARH.
  PERFORM XVBUK_UPDATE(SAPFV45K).
ENDMODULE.