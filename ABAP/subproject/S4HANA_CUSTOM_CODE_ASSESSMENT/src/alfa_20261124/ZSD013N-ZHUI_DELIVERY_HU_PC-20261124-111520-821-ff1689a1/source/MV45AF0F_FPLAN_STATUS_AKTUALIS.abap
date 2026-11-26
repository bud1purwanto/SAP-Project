*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FPLAN_STATUS_AKTUALIS                             *
*----------------------------------------------------------------------*
FORM FPLAN_STATUS_AKTUALISIEREN.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_ABSAGEN(1) TYPE C.
* Setzen Status Termin, falls Fakturierungsplan
  CHECK VBAP-FKREL EQ CON_FKREL_FPLAN.
* Bereitstellen der fakturierten Termine
  DATA: BEGIN OF DA_TFPLTS OCCURS 10.
          INCLUDE STRUCTURE FPLTS.
  DATA: END   OF DA_TFPLTS.
  READ TABLE XVBFA WITH KEY MANDT = SY-MANDT
                            VBELV = VBAP-VBELN
                            POSNV = VBAP-POSNR BINARY SEARCH.
  IF SY-SUBRC EQ 0.
    LOOP AT XVBFA FROM SY-TABIX.
      IF XVBFA-VBELV NE VBAP-VBELN OR
         XVBFA-POSNV NE VBAP-POSNR.
        EXIT.
      ENDIF.
      IF XVBFA-FPLNR EQ VBKD-FPLNR.
        MOVE-CORRESPONDING XVBFA TO DA_TFPLTS.
        APPEND DA_TFPLTS.
* Anzahlungen / Fakturierungsplan und aufwandsbezogene Faktura
      ELSEIF NOT VBKD-FFPRF IS INITIAL.
       INCLUDE BADI_SD_DPBP_FILL_TFPLTS_2.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Wenn ein Absagegrund eingegeben wurde, der fakturarelevant
* ist, muß die Statusermittlung des Fakt.plans dies wissen
  CLEAR DA_ABSAGEN.
  IF NOT VBAP-ABGRU IS INITIAL.
    PERFORM TVAG_SELECT USING VBAP-ABGRU
                              TVAG-DRAGR
                              SPACE
                              SY-SUBRC.
    PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                    CHANGING DA_ABSAGEN.
  ENDIF.

  CALL FUNCTION 'BILLING_SCHEDULE_STATUS'
       EXPORTING
            I_FPLNR   = VBKD-FPLNR
            I_ABSAGEN = DA_ABSAGEN
       IMPORTING
            E_DATALOSS  = DA_DATALOSS
       TABLES
            FPLA_OLD  = YFPLA
            FPLA_NEW  = XFPLA
            FPLT_OLD  = YFPLT
            FPLT_NEW  = XFPLT
            I_FPLTS   = DA_TFPLTS.

  IF DA_DATALOSS NE SPACE.
    R185D-DATALOSS = DA_DATALOSS.
    UPD_FPLA = CHARX.
    UPD_FPLT = CHARX.
  ENDIF.

ENDFORM.