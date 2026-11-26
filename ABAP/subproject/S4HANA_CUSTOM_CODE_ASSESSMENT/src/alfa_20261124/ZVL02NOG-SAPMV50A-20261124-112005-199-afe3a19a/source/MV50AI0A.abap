************************************************************************
*                                                                      *
* PAI Module Lieferabwicklung                                          *
*     Module alphabetisch geordnet; hier mit "A" beginnend             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE ANLIEFERTERMIN_TEST                                    *
*---------------------------------------------------------------------*
*       Prüfen des Liefertermins bzw. der Zeitangaben der Anlieferung *
*---------------------------------------------------------------------*
MODULE ANLIEFERTERMIN_TEST INPUT.

  PERFORM ANLIEFERTERMIN_PRUEFEN.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE AUFTRAG_REFERIEREN                                     *
*---------------------------------------------------------------------*
*       Auftrag referieren                                            *
*---------------------------------------------------------------------*
MODULE AUFTRAG_REFERIEREN INPUT.

* In case of errors during delivery creation the internal tables have
* to be reset before a new attempt
  IF GF_ERROR_ON_DOCUMENT_READ EQ CHARX.                    "v_n_585842
    GF_SAVE_VSTEL = LIKP-VSTEL.
    GF_SAVE_LFART = LIKP-LFART.
    GF_SAVE_DATBI = LV50C-DATBI.
    GF_SAVE_ABPOS = LV50C-ABPOS.
    GF_SAVE_BIPOS = LV50C-BIPOS.
    GF_SAVE_VBELN = LV50C-VBELN.
    PERFORM BELEG_DATEN_INIT.
    LIKP-VSTEL = GF_SAVE_VSTEL.
    LIKP-LFART = GF_SAVE_LFART.
    LV50C-DATBI = GF_SAVE_DATBI.
    LV50C-ABPOS = GF_SAVE_ABPOS.
    LV50C-BIPOS = GF_SAVE_BIPOS.
    LV50C-VBELN = GF_SAVE_VBELN.
  ELSE.
    GF_ERROR_ON_DOCUMENT_READ = CHARX.
  ENDIF.                                                    "^_n_585842
  PERFORM AUFTRAG_REFERIEREN.

ENDMODULE.
*eject

*---------------------------------------------------------------------*
*       MODULE AUFTRAG_NEXT_REFERIEREN                                *
*---------------------------------------------------------------------*
*       Auftrag referieren                                            *
*---------------------------------------------------------------------*
MODULE AUFTRAG_NEXT_REF INPUT.

  PERFORM AUFTRAG_NEXT_REFERIEREN.

ENDMODULE.
*eject