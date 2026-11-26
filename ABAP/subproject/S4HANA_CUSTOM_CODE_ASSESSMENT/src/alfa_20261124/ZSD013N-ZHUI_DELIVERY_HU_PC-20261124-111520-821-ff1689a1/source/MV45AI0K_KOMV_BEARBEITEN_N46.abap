*----------------------------------------------------------------------*
***INCLUDE MV45AI0K_KOMV_BEARBEITEN_N46 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  KOMV_BEARBEITEN_N46  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE KOMV_BEARBEITEN_N46 INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  CHECK VBAP-POSNR NE '000000'.
  PERFORM KOMV_BEARBEITEN_N46(SAPFV45P).

ENDMODULE.                             " KOMV_BEARBEITEN_N46  INPUT