*eject
*---------------------------------------------------------------------*
*       FORM EXCLUDE_FUNCTION_TRTYP.                                  *
*---------------------------------------------------------------------*
*       Bei Anzeigen sind gewisse FCODE nicht zulässig                *
*---------------------------------------------------------------------*
* In diesem Unterprogramm werden abhängig vom Transaktionstyp
* (Hinzufügen, Verändern, Anzeigen) bestimmte Fcodes für die gesamte
* Dauer der Transaktion deaktiviert. Dies geschieht durch Eintrag des
* Fcodes in die Tabelle cua_exclude.
* Daneben werden innerhalb von cua_setzen weitere Fcodes deaktiviert.
* Diese Deaktivierungen gelten aber nur bis zum nächsten Aufruf von
* cua_setzen (normalerweise beim nächsten Dynpro).
* Diese variablen Deaktivierungen werden ebenfalls durch Einträge in
* cua_exclude realisiert. Um zwischen fixen und variablen Einträgen
* unterscheiden zu können, wird der Index des ersten variablen Eintrags
* in der globalen Variablen cua_excl_fix_tabix gespeichert.

FORM EXCLUDE_FUNCTION_TRTYP.

  DATA: DA_FCODE LIKE T185-FCODE.
  CASE T180-TRTYP.
    WHEN CHARA.
      DO 99 TIMES VARYING DA_FCODE FROM CUA_EXCLU_ANZEIGE-F01
                                   NEXT CUA_EXCLU_ANZEIGE-F02.
        IF DA_FCODE = '9999'.
          EXIT.
        ENDIF.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDDO.
      IF CUA_EXCL_FIX_TABIX IS INITIAL.
        CUA_EXCL_FIX_TABIX = SY-TABIX + 1.
      ENDIF.
    WHEN CHARH.
      DO 99 TIMES VARYING DA_FCODE FROM CUA_EXCLU_ANLEGEN-F01
                                   NEXT CUA_EXCLU_ANLEGEN-F02.
        IF DA_FCODE = '9999'.
          EXIT.
        ENDIF.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDDO.
      IF CUA_EXCL_FIX_TABIX IS INITIAL.
        CUA_EXCL_FIX_TABIX = SY-TABIX + 1.
      ENDIF.
    WHEN CHARV.
      DO 99 TIMES VARYING DA_FCODE FROM CUA_EXCLU_AENDERN-F01
                                   NEXT CUA_EXCLU_AENDERN-F02.
        IF DA_FCODE = '9999'.
          EXIT.
        ENDIF.
        CUA_EXCLUDE-FUNCTION = DA_FCODE.
        APPEND CUA_EXCLUDE.
      ENDDO.
      IF CUA_EXCL_FIX_TABIX IS INITIAL.
        CUA_EXCL_FIX_TABIX = SY-TABIX + 1.
      ENDIF.
  ENDCASE.

ENDFORM.