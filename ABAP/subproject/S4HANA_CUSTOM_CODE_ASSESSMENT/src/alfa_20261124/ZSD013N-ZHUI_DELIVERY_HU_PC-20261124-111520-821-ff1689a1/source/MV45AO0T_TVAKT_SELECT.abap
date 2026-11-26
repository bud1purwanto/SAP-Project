*---------------------------------------------------------------------*
*       MODULE TVAKT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Auftragsartentext                                       *
*---------------------------------------------------------------------*
MODULE TVAKT_SELECT OUTPUT.

* Auftragsart
  PERFORM TVAKT_SELECT USING VBAK-AUART
                             SPACE
                             SY-SUBRC.

ENDMODULE.