*----------------------------------------------------------------------*
*   INCLUDE MV45AI0F_FCODE_ENDE_OHNE_PRUEF                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  FCODE_ENDE_OHNE_PRUEFUNG  INPUT
*&---------------------------------------------------------------------*
*       Fcode ohne Ausführung der nachfolgenden Module ausführen
*       Dieses Modul sollte nur auf dem Trägerdynpro aufgerufen werden
*----------------------------------------------------------------------*
MODULE FCODE_ENDE_OHNE_PRUEFUNG INPUT.

  PERFORM ENDE_OHNE_PRUEFUNG USING CHARX
                             CHANGING LEAVE_WITHOUT_CHECK.

ENDMODULE.                             " FCODE_ENDE_OHNE_PRUEFUNG  INPUT