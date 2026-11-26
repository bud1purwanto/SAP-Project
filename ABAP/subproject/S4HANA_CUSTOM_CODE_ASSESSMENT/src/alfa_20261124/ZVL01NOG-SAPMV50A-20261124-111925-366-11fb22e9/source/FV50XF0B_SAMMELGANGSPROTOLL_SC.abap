***INCLUDE FV50XF0B_SAMMELGANGSPROTOLL_SC .
*---------------------------------------------------------------------*
*       FORM SAMMELGANGSPROTOKOLL_SCHREIBEN                           *
*---------------------------------------------------------------------*
FORM SAMMELGANGSPROTOKOLL_SCHREIBEN.

* Verbuchen des Fehlerprotokolls, falls Sammelgangsnummer nicht
* initial
  IF NOT VBSK-SAMMG IS INITIAL.
    CALL FUNCTION 'RV_DELIVERY_CC_ERRORLOG_ADD' IN UPDATE TASK
         EXPORTING
              FVBSK = VBSK
         TABLES
              FVBFS = CVBFS
              FVBSS = CVBSS.
  ENDIF.
  PERFORM SD_MONITOR_PROTOCOL_SAVE.

ENDFORM.