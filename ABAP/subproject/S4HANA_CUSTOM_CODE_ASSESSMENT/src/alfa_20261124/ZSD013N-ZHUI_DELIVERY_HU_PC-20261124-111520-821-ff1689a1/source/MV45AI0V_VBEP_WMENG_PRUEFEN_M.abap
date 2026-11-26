*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBEP_WMENG_PRUEFEN_M                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE VBEP-WMENG_PRUEFEN_M                                   *
*---------------------------------------------------------------------*
*       Gesplitteter Modul VBEP-WMENG_PRUEFEN (Zweiter Teil)          *
*---------------------------------------------------------------------*
MODULE VBEP-WMENG_PRUEFEN_M.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* Mengenprüfungen (Schrittmenge, Mindestauftragsmenge etc.)
  DATA: DA_VARM VALUE CHARM.
  PERFORM VBEP-WMENG_PRUEFEN_HANDLER(SAPFV45E) CHANGING DA_VARM.

ENDMODULE.