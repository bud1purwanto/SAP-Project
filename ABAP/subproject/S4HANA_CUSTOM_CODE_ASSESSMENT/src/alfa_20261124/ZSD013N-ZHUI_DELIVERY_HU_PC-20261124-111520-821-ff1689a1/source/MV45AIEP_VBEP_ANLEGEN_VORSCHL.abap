*---------------------------------------------------------------------*
*       MODULE VBEP_ANLEGEN_VORSCHL                                   *
*---------------------------------------------------------------------*
*       Fcode VBEP_ANLEGEN wird vorgeschlagen, wenn in die letzte     *
*       Zeile eine Position eingegeben und kein Fcode eingegeben wurde*
*---------------------------------------------------------------------*
MODULE VBEP_ANLEGEN_VORSCHL.

  IF VBEP-ETENR > 0 AND
     SVBEP-TABIX = 0 AND
     SY-LOOPC = SY-STEPL AND
     FCODE = FCODE_GLEICHE_SEITE.
    FCODE = FCODE_XVBEP_ANLEGEN.
  ENDIF.

ENDMODULE.