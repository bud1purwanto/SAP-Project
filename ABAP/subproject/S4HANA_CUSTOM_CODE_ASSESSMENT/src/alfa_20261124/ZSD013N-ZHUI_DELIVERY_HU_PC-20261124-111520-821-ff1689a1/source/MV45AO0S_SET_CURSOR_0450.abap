*---------------------------------------------------------------------*
*       MODULE SET_CURSOR_0450                                        *
*---------------------------------------------------------------------*
*       Der Cursor wird ergonomisch auf die Menge gesetzt             *
*---------------------------------------------------------------------*
MODULE SET_CURSOR_0450 OUTPUT.

  IF VBAPD-EPMEH = SPACE AND
     FEHLER IS INITIAL.
    SET CURSOR FIELD 'RV45A-KWMENG' LINE SY-STEPL.
  ENDIF.

ENDMODULE.