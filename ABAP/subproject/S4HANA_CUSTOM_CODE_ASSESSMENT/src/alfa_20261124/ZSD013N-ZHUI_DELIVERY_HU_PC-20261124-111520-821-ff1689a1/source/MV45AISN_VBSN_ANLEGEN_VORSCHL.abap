*---------------------------------------------------------------------*
*       MODULE VBSN_ANLEGEN_VORSCHL                                   *
*---------------------------------------------------------------------*
*       Fcode VBSN_ANLEGEN wird vorgeschlagen, wenn in die letzte     *
*       Zeile eine Position eingegeben und kein Fcode eingegeben wurde*
*---------------------------------------------------------------------*
MODULE VBSN_ANLEGEN_VORSCHL.

  IF  VBSN-AENNR  > 0
  AND SVBSN-TABIX = 0
  AND SY-LOOPC    = SY-STEPL
  AND FCODE = FCODE_GLEICHE_SEITE.
    FCODE = FCODE_XVBSN_ANLEGEN.
  ENDIF.

ENDMODULE.