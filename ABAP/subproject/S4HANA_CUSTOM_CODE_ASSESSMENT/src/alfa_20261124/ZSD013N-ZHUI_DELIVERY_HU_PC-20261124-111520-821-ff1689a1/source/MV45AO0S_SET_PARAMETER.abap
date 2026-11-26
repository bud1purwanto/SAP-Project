*eject
*---------------------------------------------------------------------*
*       MODULE SET_PARAMETER                                          *
*---------------------------------------------------------------------*
*       Parameter müssen abweichend vom Tabellenfeld gesetzt werden   *
*---------------------------------------------------------------------*
MODULE SET_PARAMETER OUTPUT.

* Für Retouren zum Reparaturauftrag
  GET PARAMETER ID 'ALT' FIELD TVAK-LFARV.

ENDMODULE.