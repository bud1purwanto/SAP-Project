*&---------------------------------------------------------------------*
*&      Module  ABHOLFENSTER_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       Für MAIS-Aufträge wird das Abholfenster geprüft
*----------------------------------------------------------------------*
MODULE ABHOLFENSTER_PRUEFEN INPUT.

  PERFORM ABHOLFENSTER_PRUEFEN USING CHARX
                                     VBAK-ABHOD
                                     VBAK-ABHOV
                                     VBAK-ABHOB
                                     VBAK-VBELN.

ENDMODULE.                             " ABHOLFENSTER_PRUEFEN  INPUT