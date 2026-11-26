*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_TABSTRIP                             *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Diese Routine wählt von den beiden Reitern 'Verkauf' den jeweils   *
*   aktuellen aus und blendet den anderen aus                          *
*   Aufruf aus CUA_EXCLUDE                                             *
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_TABSTRIP_UMSETZEN.
* Text Control verfügbar und gemäß Customizing eingestellt?
  IF NOT TVAK-TDID IS INITIAL AND
     NOT TEXT_CONTROL_AVAILABLE IS INITIAL AND
     ( SYSTEMTYP IS INITIAL OR
       SYSTEMTYP EQ 'WN32' ).
* Führt die Kopfgruppe in der einzeiligen Übersicht auf ERF1 oder ERFA?
    READ TABLE KGTAB WITH KEY TVAK-KOPGR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
*   GUI-Redesign 4.0: Reiter ohne Text Control ausblenden
      PERFORM TAXI_DEACTIVATE_TAB USING FCODE_UEBERSICHT_EINZEILIG.
      EXIT.
    ENDIF.
  ENDIF.
*   GUI-Redesign 4.0: Reiter mit Text Control ausblenden
  PERFORM TAXI_DEACTIVATE_TAB USING FCODE_UEBERSICHT_MIT_TEC.
ENDFORM.