*&---------------------------------------------------------------------*
*&      Form  GRUKO_BEARBEITEN
*&---------------------------------------------------------------------*
*       Auslösen von Bearbeitungsschritten aus dem Loop des
*       Tablecontrol im Übersichtsbild des Gruppenkontrakts
*----------------------------------------------------------------------*
FORM GRUKO_BEARBEITEN.

  LOCAL: GRUKO.

  IF RV46G_DOC-SELKZ IS INITIAL.
*   Nicht mehr benötigte Selektionen löschen
    IF NOT GRUKO-SELKZ IS INITIAL.
      CLEAR GRUKO-SELKZ.
      MODIFY GRUKO TRANSPORTING SELKZ WHERE SELKZ = 'X'.
    ENDIF.
    EXIT.
  ELSE.
*   Beleg zum Anzeigen vormerken
    READ TABLE GRUKO WITH KEY VBELN = RV46G_DOC-VBELN.
    IF SY-SUBRC EQ 0.
      GRUKO-SELKZ = RV46G_DOC-SELKZ.
      MODIFY GRUKO INDEX SY-TABIX.
    ENDIF.

*   Wegen gemeinsamer Nutzung von Status mit anderen Belegarten wird
*   bei Doppelklick auf einen Listzeile der FCode 'ITEM' geliefert.
*   Dieser muss in 'GRKO' zur Ausnahmebehandlung für den Gruppenkontrakt
*   übersetzt werden. (AKK)
    IF FCODE = 'ITEM'.
      FCODE = 'GRKO'.
    ENDIF.
  ENDIF.

ENDFORM.                               " GRUKO_BEARBEITEN