*&---------------------------------------------------------------------*
*&      Form  CUA_SETZEN_SORTIMENT
*&---------------------------------------------------------------------*
*       CUA-Parameter übergeben, nahezu alle FCodes ausblenden
*----------------------------------------------------------------------*
FORM CUA_SETZEN_SORTIMENT.

  DATA: STR_LEN(4) TYPE N VALUE '1',
        DA_TEXTFOLGE(2) VALUE 'DN'.    "für den Titelaufbau

  FIELD-SYMBOLS: <TFS>.

  REFRESH CUA_EXCLUDE.

  CUA_EXCLUDE-FUNCTION = 'MARK'.
  APPEND CUA_EXCLUDE.

* Positionieren nach Positionsnummer macht keinen Sinn
  CUA_EXCLUDE-FUNCTION = 'POPO'.
  APPEND CUA_EXCLUDE.

* Direktes Übernehmen aus Sortiment oder Materialeingabe nicht erlaubt
  CUA_EXCLUDE-FUNCTION = 'RUEB'.
  APPEND CUA_EXCLUDE.

* Status setzen
  SET PF-STATUS T185V-STATUS EXCLUDING CUA_EXCLUDE
                             OF PROGRAM MODUL-POOL.

  REFRESH CUA_EXCLUDE.

* Temporär <<< Titelparameter aufbauen >>>
* Gleichzeitig erfolgt die Textmontage des Parameters je nach Sprache
* in anderer Reihenfolge (Beispiel: Terminauftrag ändern und
* Change Sales Order)
  IF DA_TEXTFOLGE CS SY-LANGU.
* Bezeichnung der Belegart holen
    CUA_TEXT = TVAKT-BEZEI.
    STR_LEN = STRLEN( CUA_TEXT ) + 1.
    IF STR_LEN > 1.
* Belegnummer hintendranhängen
      WRITE VBAK-VBELN TO CUA_TEXT+STR_LEN.
      STR_LEN = STRLEN( CUA_TEXT ) + 1.
    ENDIF.
* Bearbeitungsart hintendranhängen
    WRITE RV45A-TXT_TITCUA TO CUA_TEXT+STR_LEN.
    STR_LEN = STRLEN( CUA_TEXT ).
    IF STR_LEN > 0.
      ASSIGN CUA_TEXT+0(STR_LEN) TO <TFS>.
    ENDIF.
  ELSE.
* Bearbeitungsart holen
    CUA_TEXT = RV45A-TXT_TITCUA.
    STR_LEN = STRLEN( CUA_TEXT ) + 1.
* Belegart hintendranhängen
    WRITE TVAKT-BEZEI TO CUA_TEXT+STR_LEN.
    STR_LEN = STRLEN( CUA_TEXT ).
    IF STR_LEN > 1.
* Belegnummer hintendranhängen
      WRITE VBAK-VBELN TO CUA_TEXT+STR_LEN.
      STR_LEN = STRLEN( CUA_TEXT ) + 1.
    ENDIF.
    IF STR_LEN > 0.
      ASSIGN CUA_TEXT+0(STR_LEN) TO <TFS>.
    ENDIF.
  ENDIF.
  MOVE <TFS> TO RV02P-TITLE.

  SET TITLEBAR T185V-CTITEL OF PROGRAM MODUL-POOL WITH <TFS>.

ENDFORM.                               " CUA_SETZEN_SORTIMENT