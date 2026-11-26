* eject
************************************************************************
*              FORM FCODE_PSAV                                         *
************************************************************************
* Routine handles Fcode PSAV, this means save SD-Protocol in MONICALL  *
************************************************************************
FORM FCODE_PSAV.

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
  IF XSDCTRLFLAG-MONICALL = 'X' AND T180-AKTYP = 'V'.
*    to avoid unwished updates ...
    ROLLBACK WORK.
*    ... now save the protocol
    CALL FUNCTION 'SD_MONITOR_PROTOCOL_EXPORT'
         EXPORTING
              FPAPPL = PROTOCOLCALLER-SDA
              FVBELN = VBAK-VBELN
         EXCEPTIONS
              OTHERS = 1.
    COMMIT WORK.
  ENDIF.
  LEAVE PROGRAM.
ENDFORM.