*----------------------------------------------------------------------*
*   INCLUDE MV45AISN_VBSN_BEARBEITEN_ENDE                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  VBSN_BEARBEITEN_ENDE  INPUT
*&---------------------------------------------------------------------*
*       Endebearbeitung VBSN
*----------------------------------------------------------------------*
MODULE VBSN_BEARBEITEN_ENDE INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBSN_BEARBEITEN_ENDE(SAPFV45L).

ENDMODULE.                             " VBSN_BEARBEITEN_ENDE  INPUT