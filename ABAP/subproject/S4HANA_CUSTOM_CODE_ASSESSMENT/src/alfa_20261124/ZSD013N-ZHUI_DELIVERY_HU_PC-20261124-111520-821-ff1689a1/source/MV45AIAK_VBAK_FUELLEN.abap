*---------------------------------------------------------------------*
*       MODULE VBAK_FUELLEN                                           *
*---------------------------------------------------------------------*
*       VBAK mit Vorschlagswerten aus den Stammdaten beim             *
*       Anlegen füllen                                                *
*---------------------------------------------------------------------*
MODULE VBAK_FUELLEN.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ENDE_OHNE_PRUEFUNG USING SPACE
                             CHANGING LEAVE_WITHOUT_CHECK.
  CHECK LEAVE_WITHOUT_CHECK IS INITIAL.

ENHANCEMENT-POINT VBAK_FUELLEN_10 SPOTS ES_SAPMV45A.
  PERFORM VBAK_FUELLEN(SAPFV45K).

ENDMODULE.