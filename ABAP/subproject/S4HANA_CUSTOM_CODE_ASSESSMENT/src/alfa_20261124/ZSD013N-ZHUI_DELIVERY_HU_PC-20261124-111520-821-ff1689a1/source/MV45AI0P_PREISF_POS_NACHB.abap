*----------------------------------------------------------------------*
*   INCLUDE MV45AI0P_PREISF_POS_NACHB                                  *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PREISFINDUNG_NACHBEREITEN_POS   INPUT
*&---------------------------------------------------------------------*
*       PAI des Konditionssubscreens wird durchgeführt
*----------------------------------------------------------------------*
MODULE PREISFINDUNG_NACHBEREITEN_POS INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM PREISFINDUNG_NACHBEREITEN_POS(SAPFV45P) USING T185F
                                                        T185
                                                        T185V.

ENDMODULE.                 " PREISFINDUNG_NACHBEREITEN_POS   INPUT