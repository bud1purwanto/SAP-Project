***INCLUDE MV50AF0F_FCODE_CHCR .
FORM FCODE_CHCR.

  LOOP AT ILIPS WHERE SELKZ = CHARX.

*...Kopfstatus der Lieferung aktualisieren
    PERFORM XVBUK_PFLEGEN(SAPFV50K).

*...  Positionsstatus der Lieferung lesen
    PERFORM XVBUP_LESEN(SAPFV50P) USING XLIPS-VBELN
                                        ILIPS-POSNR.

*...   WA schon gebucht?
    IF XVBUP-WBSTA = 'C'.
      MESSAGE S602.
      EXIT.
    ENDIF.


*...  Faktura erfolgt?
    IF XVBUK-FKSTK CA 'BC'.
      MESSAGE S186.
      EXIT.
    ENDIF.

*...  LVS aktiv?
    IF XVBUP-LVSTA = 'B'.
      MESSAGE S235.
      EXIT.
    ENDIF.

*...  LVS fertig?
    IF XVBUP-LVSTA = 'C'.
      MESSAGE S236.
      EXIT.
    ENDIF.

*...  gibt es offene Kommiaufträge ?
    IF XVBUP-KOQUA = 'B' AND XVBUP-LVSTA = SPACE.
      MESSAGE S237.
      EXIT.
    ENDIF.

*...  Kommissionierung quittiert ?
    IF XVBUP-KOQUA = 'C' AND XVBUP-LVSTA = SPACE.
      MESSAGE S238.
      EXIT.
    ENDIF.

  ENDLOOP.

  PERFORM NEW_BATCH_CREATE_PREPARE_1(SAPFV50D).

ENDFORM.