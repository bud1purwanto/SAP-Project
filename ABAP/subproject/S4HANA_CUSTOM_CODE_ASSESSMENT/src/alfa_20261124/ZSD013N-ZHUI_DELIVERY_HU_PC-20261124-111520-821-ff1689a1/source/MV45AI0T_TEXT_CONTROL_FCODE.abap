*----------------------------------------------------------------------*
*   INCLUDE MV45AI0T_TEXT_CONTROL_FCODE                                *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Dieser Modul ruft für TEC Ereignisse den Dispatcher auf            *
*----------------------------------------------------------------------*
MODULE TEXT_CONTROL_FCODE.

  IF FCODE(1) EQ '%'.
    call method c_textedit_control=>dispatch
         EXPORTING FCODE = FCODE.
  ENDIF.

ENDMODULE.