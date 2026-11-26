*---------------------------------------------------------------------*
*       FORM AUFTRAGGEBER_HOLEN                                       *
*---------------------------------------------------------------------*
*       Beim Kopieren von Musteraufträgen in Aufträge mit Kunden-     *
*       bezug vom Anforderungsbild aus muss zunächst der Kunde        *
*       eingegeben werden.                                            *
*---------------------------------------------------------------------*
FORM AUFTRAGGEBER_HOLEN USING US_FCODE.

  LOCAL: KOPIEREN.

  IF NOT KUAGV-KUNNR CO ' 0?' OR
     FCODE = FCODE_ABBRECHEN.
    EXIT.
  ENDIF.
  KOPIEREN = CHARX.

  CALL SCREEN 304 STARTING AT 21 14
                  ENDING   AT 62 18.

  IF FCODE = FCODE_ABBRECHEN.
    PERFORM BELEG_INITIALISIEREN.
    US_FCODE = FCODE_ABBRECHEN.
  ENDIF.

ENDFORM.