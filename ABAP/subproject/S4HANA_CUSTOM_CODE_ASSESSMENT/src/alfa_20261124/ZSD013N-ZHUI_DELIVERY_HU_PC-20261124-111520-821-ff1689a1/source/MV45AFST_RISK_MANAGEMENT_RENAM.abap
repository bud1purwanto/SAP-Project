FORM RISK_MANAGEMENT_RENAME.
* Wenn Belegabsicherungsschema sitzt, RENAME der externen Tabellen
  IF NOT TVAK-BABSS IS INITIAL.
    CALL FUNCTION 'SD_RISK_EXTERNAL_RENAME'
         EXPORTING
              I_DOCUMENT_OLD = SPACE
              I_DOCUMENT_NEW = VBAK-VBELN
         EXCEPTIONS
              OTHERS         = 0.
  ENDIF.
ENDFORM.