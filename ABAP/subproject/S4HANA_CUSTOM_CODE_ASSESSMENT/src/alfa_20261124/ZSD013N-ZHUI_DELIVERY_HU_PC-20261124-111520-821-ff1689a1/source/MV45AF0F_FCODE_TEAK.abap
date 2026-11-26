*---------------------------------------------------------------------*
*       FORM FCODE_TEAK                                               *
*---------------------------------------------------------------------*
* Analysis of textprocessing  -  Header                               *
*---------------------------------------------------------------------*
FORM FCODE_TEAK.

* to analyse the textprocessing the communication-WA has to be filled
  PERFORM TVCOM_FILL_SIMULMODE USING 'VBAK'.

  CALL FUNCTION 'RV_TEXT_COPY'
       EXPORTING
            FTVCOM     = TVCOM
            NO_POPUP   = 'X'
            FPAPPL     = PROTOCOLCALLER-SDA
            SIMUL_MODE = 'X'
       TABLES
            FXTHEAD    = XTHEAD
            FXVBPA     = XVBPA
            FXVBUV     = XVBUV.

  CALL FUNCTION 'SD_MONITOR_PROTOCOL_GET'
       EXPORTING
            FPAPPL   = PROTOCOLCALLER-SDA
            FPROTTYP = PROTOCOLTYPE-TEXT
       TABLES
            FPROT    = XPROT
       EXCEPTIONS
            OTHERS   = 1.

* call protocol display; the protocol decides on it´s own if it is
* really in display mode or in SD-monitor-call-mode
  CALL FUNCTION 'SD_TEXT_PROTOCOL_DISPLAY'
       EXPORTING
            FTVCOM = TVCOM
       TABLES
            FPROT  = XPROT
       EXCEPTIONS
            OTHERS = 1.
ENDFORM.