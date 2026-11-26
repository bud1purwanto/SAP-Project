*---------------------------------------------------------------------*
*       MODULE KOMV_PRUEFEN                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE KOMV_PRUEFEN_FIRST.

* nicht nach Änderung der AUART wegen V1206
  CHECK VBAK-AUART EQ *VBAK-AUART.

  PERFORM VBAP_LOESCHEN_SETZEN(SAPFV45P).
  PERFORM KOMV_PRUEFEN_FIRST(SAPFV45P).
  PERFORM KOMV_PRUEFEN(SAPFV45P) USING CHARX
                                CHANGING SY-SUBRC.

ENDMODULE.












