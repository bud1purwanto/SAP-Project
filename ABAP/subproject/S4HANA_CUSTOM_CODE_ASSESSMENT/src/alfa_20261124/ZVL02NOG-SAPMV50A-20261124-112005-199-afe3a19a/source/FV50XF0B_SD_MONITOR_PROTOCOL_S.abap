***INCLUDE FV50XF0B_SD_MONITOR_PROTOCOL_S .
*&---------------------------------------------------------------------*
*&      Form  SD_MONITOR_PROTOCOL_SAVE
*&---------------------------------------------------------------------*
*       muss moeglichst knapp vor dem commit ausgefuehrt werden  *
*----------------------------------------------------------------------*
FORM SD_MONITOR_PROTOCOL_SAVE.

  IF XSDCTRLFLAG-PROTSAVE = YES.
    CALL FUNCTION 'SD_MONITOR_PROTOCOL_EXPORT'
         EXPORTING
              FPAPPL = PROTOCOLCALLER-SDL
              FVBELN = LIKP-VBELN
         EXCEPTIONS
              OTHERS = 1.
  ENDIF.

ENDFORM.                               " SD_MONITOR_PROTOCOL_SAVE