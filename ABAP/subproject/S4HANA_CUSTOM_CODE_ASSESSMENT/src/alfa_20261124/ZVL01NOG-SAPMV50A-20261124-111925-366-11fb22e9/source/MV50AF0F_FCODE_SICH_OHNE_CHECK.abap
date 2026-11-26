***INCLUDE MV50AF0F_FCODE_SICH_OHNE_CHECK .
*---------------------------------------------------------------------*
*       FORM FCODE_SICH_OHNE_CHECK                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM FCODE_SICH_OHNE_CHECK.

* Sicherung
  PERFORM BELEG_SICHERN USING SPACE.

* rename the SD-monitor-protocol, but only if protocol is to be saved
* and not in CHANGE-mode because then the document number is known
  IF T180-AKTYP = AKTYP-CREATE.
    IF XSDCTRLFLAG IS INITIAL.
      CALL FUNCTION 'SD_MONITOR_CONTROL_FLAGS_GET'
           IMPORTING
                FSDCTRLFLAG = XSDCTRLFLAG
           EXCEPTIONS
                OTHERS      = 1.
    ENDIF.
    IF XSDCTRLFLAG-PROTSAVE = YES.
      CALL FUNCTION 'SD_MONITOR_PROTOCOL_RENAME'
           EXPORTING
                FPAPPL = PROTOCOLCALLER-SDL
                FVBELN = LIKP-VBELN
           EXCEPTIONS
                OTHERS = 1.
      CALL FUNCTION 'SD_MONITOR_PROTOCOL_EXPORT'
           EXPORTING
                FPAPPL = PROTOCOLCALLER-SDL
                FVBELN = LIKP-VBELN
           EXCEPTIONS
                OTHERS = 1.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT FCODE_SICH_OHNE_CHECK_01 SPOTS ES_SAPMV50A.
* Sichern im Verändern springt zum ersten Bild der jeweiligen Tr.
  IF T180-TRTYP EQ CHARV.
    FCODE+3(1) = CHAR1.
    PERFORM FCODE_BEARBEITEN.
  ENDIF.

ENDFORM.