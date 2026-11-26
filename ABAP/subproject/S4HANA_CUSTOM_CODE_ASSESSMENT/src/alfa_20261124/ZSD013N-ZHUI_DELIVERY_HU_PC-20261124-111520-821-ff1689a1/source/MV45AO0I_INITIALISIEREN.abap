*---------------------------------------------------------------------*
*       MODULE INITIALISIEREN OUTPUT                                  *
*---------------------------------------------------------------------*
*       Setzen eines neuen Status --> Action-Bar und der Ueberschrift *
*---------------------------------------------------------------------*
MODULE INITIALISIEREN OUTPUT.

* perform tcvariant_set.
  PERFORM SCHLUESSELWORTE_SETZEN USING TVAK-TRVOG.
  PERFORM CUA_SETZEN.
  PERFORM XVBAK_INITIALISIEREN(SAPFV45K).

ENHANCEMENT-POINT INITIALISIEREN_10 SPOTS ES_SAPMV45A.
ENDMODULE.