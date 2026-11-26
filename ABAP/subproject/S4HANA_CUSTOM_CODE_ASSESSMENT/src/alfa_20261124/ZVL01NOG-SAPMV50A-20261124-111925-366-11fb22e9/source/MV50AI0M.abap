************************************************************************
*                                                                      *
* PAI Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "M" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE MATERIAL_STATUS                                        *
*---------------------------------------------------------------------*
*       Pruefen des Material-Status                                   *
*---------------------------------------------------------------------*
MODULE MATERIAL_STATUS.

  CHECK FCODE(4) NE FCODE_ABBRECHEN              AND      "46A BEY
        FCODE(4) NE FCODE_BACK                   AND
        FCODE(4) NE 'POS+'                       AND
        FCODE(4) NE FCODE_XLIPS_LOESCHEN         AND
        FCODE(4) NE FCODE_XLIPS_LOESCHEN_EINZELN AND
        FCODE(4) NE FCODE_ENDE.

  CHECK NOT LIPS-MATNR IS INITIAL.
  CHECK MAAPV-VMSTA NE SPACE OR MAAPV-MSTAV NE SPACE.

  PERFORM MATERIAL_PRODUKT_STATUS(SAPFV50P) USING SY-SUBRC.

ENDMODULE.
*eject


*---------------------------------------------------------------------*
*       MODULE MSEG-ERFMG_PRUEFEN.                                    *
*---------------------------------------------------------------------*
*       Prüfen Eingabemenge                                           *
*---------------------------------------------------------------------*
MODULE MSEG-ERFMG_PRUEFEN.

  PERFORM MSEG-ERFMG_PRUEFEN.

ENDMODULE.
*eject


*---------------------------------------------------------------------*
*       MODULE MSEG_FUELLEN                                           *
*---------------------------------------------------------------------*
*       Übernehmen Daten in XMSEG                                     *
*---------------------------------------------------------------------*
MODULE MSEG_FUELLEN.

  PERFORM MSEG_FUELLEN.

ENDMODULE.
*eject


*---------------------------------------------------------------------*
*       MODULE MSEG-MATNR_PRUEFEN.                                    *
*---------------------------------------------------------------------*
*       Prüfen lagerort bei Eingabe                                   *
*---------------------------------------------------------------------*
MODULE MSEG-MATNR_PRUEFEN.

  PERFORM MSEG-MATNR_PRUEFEN.

ENDMODULE.
*eject


*---------------------------------------------------------------------*
*       MODULE MSEG_UNTERLEGEN                                        *
*---------------------------------------------------------------------*
*       Für VL07 wird ausser der Lieferposition die parallele         *
*       Tabelle MSEG gelesen                                          *
*---------------------------------------------------------------------*
MODULE MSEG_UNTERLEGEN.

  READ TABLE SLIPS INDEX SY-STEPL.
  READ TABLE XMSEG INDEX SLIPS-TABIX.
  IF SY-SUBRC NE 0.
    MESSAGE A322 WITH 'XMSEG'.
  ENDIF.
  MSEG = XMSEG.

ENDMODULE.
*eject