*----------------------------------------------------------------------*
***INCLUDE MV45AF0T_TEXT_CONTROL_EINGABEB .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_EINGABEBEREIT
*&---------------------------------------------------------------------*
*       Die Eingabeberitschaft des Text Control wird gesetzt
*----------------------------------------------------------------------*

* ITF scanner
include rstxscad.

FORM TEXT_CONTROL_EINGABEBEREIT.

  TABLES: TTXS.

  DATA: L_TOKEN TYPE ITF_TOKEN.

* Default: Text eingabebereit
  TEXT_CONTROL_READY_FOR_INPUT = CHARX.

* DO klammert Prüfungen auf Eingabebereitschaft
  DO 1 TIMES.

* 1. Anzeigemodus?
    IF T180-TRTYP EQ CHARA.
      CLEAR TEXT_CONTROL_READY_FOR_INPUT.
      EXIT.
    ENDIF.

* 2. Ist zur Zeit eine Referenz in der XTHEAD?
    IF NOT XTHEAD-TDREFID   IS INITIAL OR
       NOT XTHEAD-TDREFOBJ  IS INITIAL OR
       NOT XTHEAD-TDREFNAME IS INITIAL.
      TEXT_CONTROL_REFERIERT = CHARX.
      CLEAR TEXT_CONTROL_READY_FOR_INPUT.
      EXIT.
    ELSE.
      CLEAR TEXT_CONTROL_REFERIERT.
    ENDIF.

* 3. Vor dem VBAK_FUELLEN_TEXTE: Ist eine Zugriffsfolge hinterlegt?
    IF SVBAK-TABIX = 0.
      SELECT SINGLE * FROM TTXS WHERE TDOBJECT = 'VBBK'
                                  AND TXTGR    = TVAK-TXTGR
                                  AND TDID     = TVAK-TDID.
      IF SY-SUBRC EQ 0.
        IF NOT TTXS-TXZUF IS INITIAL.
          TEXT_CONTROL_REFERIERT = CHARX.
          CLEAR TEXT_CONTROL_READY_FOR_INPUT.
          EXIT.
        ELSE.
          CLEAR TEXT_CONTROL_REFERIERT.
        ENDIF.
      ELSE.
* Text & zum Schema & nicht vorhanden
        CLEAR TEXT_CONTROL_AVAILABLE.
        MESSAGE I248(VC) WITH TVAK-TDID TVAK-TXTGR.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

* nur weitermachen, wenn Text vorhanden
  CHECK NOT TEXT_CONTROL_AVAILABLE IS INITIAL.

* Eingabebereitschaft setzen
  IF TEXT_CONTROL_READY_FOR_INPUT IS INITIAL.
* Anzeigemodus in VA03 und bei referierten Texten
    CALL METHOD TEXT_EDITOR->SET_READONLY_MODE
           EXPORTING READONLY_MODE = TEXT_EDITOR->TRUE
           EXCEPTIONS
             OTHERS = 1.
  ELSE.
*   Sonst änderbar
*   anderbar jedoch nur, wenn der Text keine Formatierungen besitzt
*   --> Text mit Formatierungen --> nur Anzeigemodus
    PERFORM INIT_ITF_SCANNER(RSTXSCAN) USING C_WITHOUT_COMMAND_SCAN
                                             C_FORM_TEXT.
    LOOP AT TLINETAB.
      IF GV_FORMATIERUNG = CHARX.
        EXIT.
      ENDIF.
      PERFORM SET_ITF_TEXT(RSTXSCAN) USING TLINETAB[].
      IF TLINETAB-TDFORMAT NE '*'.
        GV_FORMATIERUNG = CHARX.
        EXIT.
      ENDIF.
      DO.
        PERFORM READ_NEXT_ITF_TOKEN(RSTXSCAN) USING L_TOKEN.
          IF L_TOKEN-CODE <> C_TOKEN_ELEMENT_BEGIN AND
             L_TOKEN-CODE <> C_TOKEN_ELEMENT_END AND
             L_TOKEN-CODE <> C_TOKEN_PARAGRAPH_BEGIN AND
             L_TOKEN-CODE <> C_TOKEN_PARAGRAPH_END AND
             L_TOKEN-CODE <> C_TOKEN_LINE_BEGIN AND
             L_TOKEN-CODE <> C_TOKEN_LINE_END AND
             L_TOKEN-CODE <> C_TOKEN_STRING.
               " text besitzt formatierung
               " c_token_tab
               " c_token_ltag_begin
               " c_token_ctag_begin
               " c_token_url_begin
               " c_token_symbol_begin
               " c_token_symbol
               " c_token_prefix_begin
               " c_token_option
               " c_token_suffix_begin
               " c_token_sap_char
               " c_token_template_string
               " c_token_command_begin
               " c_token_command
               " c_token_comment
               IF L_TOKEN-CODE = C_TOKEN_TEXT_END.
                 EXIT.
               ELSE.
                 GV_FORMATIERUNG = CHARX.
                 EXIT.
               ENDIF.
          ENDIF.
      ENDDO.
    ENDLOOP.
    IF NOT GV_FORMATIERUNG IS INITIAL.
*     Text besitzt Formatierungen
*     --> Text nur im Anzeigemodus
    CALL METHOD TEXT_EDITOR->SET_READONLY_MODE
           EXPORTING READONLY_MODE = TEXT_EDITOR->TRUE
         EXCEPTIONS
           OTHERS = 1.
  ELSE.
    CALL METHOD TEXT_EDITOR->SET_READONLY_MODE
           EXPORTING READONLY_MODE = TEXT_EDITOR->FALSE
         EXCEPTIONS
           OTHERS = 1.
    ENDIF.
  ENDIF.

ENDFORM.                               " TEXT_CONTROL_EINGABEBEREIT