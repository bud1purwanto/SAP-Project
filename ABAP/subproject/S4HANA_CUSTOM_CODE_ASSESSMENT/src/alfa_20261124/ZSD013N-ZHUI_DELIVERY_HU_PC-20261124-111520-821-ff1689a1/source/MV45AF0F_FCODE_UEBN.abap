*&---------------------------------------------------------------------*
*&      Form  FCODE_UEBN
*&---------------------------------------------------------------------*
*       Übernahme von Materialien aus Wertkontrakt, Sortiment zum      *
*       Wertkontrakt oder eingegebenen Materialien zum Wertkontrakt    *
*       in einen Abrufauftrag.                                         *
*----------------------------------------------------------------------*
FORM FCODE_UEBN.

* In der XVBAP dürfen nur die Positionen stehen bleiben, die selektiert
* wurden
  LOOP AT IVBAP.
    IF IVBAP-SELKZ NE SELEKTIERT.
      READ TABLE XVBAP INDEX IVBAP-TABIX.
      IF SY-SUBRC = 0.
        XVBAP-UPDKZ = UPDKZ_DELETE.
        MODIFY XVBAP INDEX IVBAP-TABIX.
        DELETE IVBAP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR RV45A-VBAP_SELKZ.
  PERFORM IVBAP_AUFBAUEN_ALTE(SAPFV45P).
  IVBAP_TABIX_ZEILE_1 = 1.

ENDFORM.