*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBEP_WMENG_PRUEFEN_A                              *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE VBEP-WMENG_PRUEFEN_A                                   *
*---------------------------------------------------------------------*
*       Gesplitteter Modul VBEP-WMENG_PRUEFEN (Erster Teil)           *
*---------------------------------------------------------------------*
MODULE VBEP-WMENG_PRUEFEN_A.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

* Allgemeine Prüfungen im Zusammenhang mit VBEP-WMENG
  DATA: DA_VARA VALUE CHARA.
  PERFORM VBEP-WMENG_PRUEFEN_HANDLER(SAPFV45E) CHANGING DA_VARA.

ENDMODULE.