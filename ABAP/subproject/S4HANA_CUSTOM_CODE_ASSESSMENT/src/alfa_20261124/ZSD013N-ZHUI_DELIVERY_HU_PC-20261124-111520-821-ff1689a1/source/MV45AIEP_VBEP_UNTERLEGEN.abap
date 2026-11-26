*eject
*---------------------------------------------------------------------*
*       MODULE VBEP_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       Die alte Einteilung wird unter die Eingabedaten gelegt        *
*---------------------------------------------------------------------*
MODULE VBEP_UNTERLEGEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

  PERFORM VBEP_UNTERLEGEN(SAPFV45E).

ENHANCEMENT-POINT VBEP_UNTERLEGEN_10 SPOTS ES_SAPMV45A.
ENDMODULE.