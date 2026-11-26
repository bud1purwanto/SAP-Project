*---------------------------------------------------------------------*
*       MODULE VBAP-EXART_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Eingabepruefung: Geschaeftsart                                *
*       Fremdschluessel: Land der Versandstelle                       *
*---------------------------------------------------------------------*
MODULE VBAP-EXART_PRUEFEN.

  PERFORM VBAP-EXART_PRUEFEN(SAPFV45P) USING VBAP-WERKS
                                             XVBAP-WKLND
                                             VBAP-EXART.

ENDMODULE.