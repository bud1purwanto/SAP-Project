*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAP_WAERK_SETZEN                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VBAP-WAERK_SETZEN  INPUT
*&---------------------------------------------------------------------*
MODULE VBAP-WAERK_SETZEN INPUT.

  VBAP-WAERK = VBAK-WAERK.

  IF *VBAP-WAERK IS INITIAL.
    *VBAP-WAERK = VBAP-WAERK.
  ENDIF.

ENDMODULE.                 " VBAP-WAERK_SETZEN  INPUT