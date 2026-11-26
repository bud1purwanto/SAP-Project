***INCLUDE MV50AF0F_FCODE_TEAN .
*---------------------------------------------------------------------*
*       FORM FCODE_TEAN                                               *
*---------------------------------------------------------------------*
*       Sichern Textanalyse                                           *
*---------------------------------------------------------------------*
FORM FCODE_TEAN.
* Is something to do for the SD-monitor-protocol ? To decide this get
* the parameter-ids.
  IF XSDCTRLFLAG IS INITIAL.
    CALL FUNCTION 'SD_MONITOR_CONTROL_FLAGS_GET'
         IMPORTING
              FSDCTRLFLAG = XSDCTRLFLAG
         EXCEPTIONS
              OTHERS      = 1.
  ENDIF.

* if transaction is called by SD-monitor, so only the protocol is to be
* posted (regardless the flag XSDCTRLFLAG-PROTSAV) because MONICALL
* means simulation of some FCODES (and only in change-mode)
  IF XSDCTRLFLAG-MONICALL = YES AND T180-AKTYP = AKTYP-CHANGE.
*    to avoid unwished updates ...
    ROLLBACK WORK.
*    ... now save the protocol
    CALL FUNCTION 'SD_MONITOR_PROTOCOL_EXPORT'
         EXPORTING
              FPAPPL = PROTOCOLCALLER-SDL
              FVBELN = LIKP-VBELN
         EXCEPTIONS
              OTHERS = 1.
    COMMIT WORK.
  ENDIF.
  LEAVE PROGRAM.
ENDFORM.