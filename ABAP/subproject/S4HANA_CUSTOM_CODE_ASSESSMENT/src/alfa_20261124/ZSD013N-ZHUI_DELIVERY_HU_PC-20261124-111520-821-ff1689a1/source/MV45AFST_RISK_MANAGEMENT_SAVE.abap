FORM RISK_MANAGEMENT_SAVE.
* Wenn Belegabsicherungsschema sitzt, Sichern der externen Tabellen
  IF NOT TVAK-BABSS IS INITIAL.
    CALL FUNCTION 'SD_RISK_EXTERNAL_ORDER_SAVE'
         EXPORTING
              I_VBAK       = VBAK
              I_VBAK_UPDKZ = XVBAK_UPDKZ
         TABLES
              I_XVBAP      = XVBAP
              I_XVBKD      = XVBKD
         EXCEPTIONS
              OTHERS       = 0.
  ENDIF.
ENDFORM.