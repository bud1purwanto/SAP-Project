*---------------------------------------------------------------------*
*       FORM FPLAN_AKTUALISIEREN_CALL                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  US_FLG_XVEDA                                                  *
*---------------------------------------------------------------------*
FORM FPLAN_AKTUALISIEREN_CALL
  USING  US_FLG_CREATE_DATES
         US_NOMSG.
  LOCAL: TVAP-FPART,
         XVBEP.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_FPLNR    LIKE VBKD-FPLNR.
  DATA: DA_KFPLNR   LIKE VBKD-FPLNR.
  DATA: DA_KFPLAN   LIKE RV60F-KFPLAN.
  DATA: DA_ABSAGEN(1) TYPE C.
*
  PERFORM T459K_LESEN.
  PERFORM PREISFINDUNG_VORBEREITEN IN PROGRAM SAPFV45P USING 'P'.
  IF VBAP-FKREL EQ CON_FKREL_FPLAN OR
   ( VBAP-FKREL IS INITIAL AND         "oder Angebote
     NOT TVAP-FPART IS INITIAL ).
*   Gibt es einen Kopffakturierungsplan ?
    PERFORM XVBKD_LESEN(SAPFV45K) USING POSNR_LOW.
    IF XVBKD-POSNR EQ POSNR_LOW AND
       NOT XVBKD-FPLNR IS INITIAL.
      MOVE XVBKD-FPLNR TO DA_KFPLNR.
    ENDIF.
*   Ermitteln, ob Positionsfakturierungsplan auf Kopffakturierungsplan
*   zeigt
    PERFORM FPLANART_ERMITTELN_KOPF CHANGING TVAK-FPART.
    PERFORM XVBKD_LESEN(SAPFV45K) USING VBAP-POSNR.
    PERFORM FPLANART_ERMITTELN CHANGING TVAP-FPART.
    PERFORM FPLAN_POS_KOPFRELEVANT USING    VBAP-POSNR
                                            TVAP-FPART TVAK-FPART
                                   CHANGING SY-SUBRC.
    IF SY-SUBRC EQ 0.
      MOVE CHARB TO DA_KFPLAN.
    ENDIF.
    PERFORM VBKD_BEARBEITEN_VORBEREITEN(SAPFV45K).
*
*   VEDA lesen
    IF NOT TVAK-VTERL IS INITIAL.      "AND US_FLG_XVEDA NE CHARX.
*     Vertragsdaten vorhanden
      DATA: DA_POSNR_LOW LIKE VEDA-VPOSN.
      MOVE VBAK-VBELN TO XVEDA-VBELN.
      MOVE VBAP-POSNR TO XVEDA-VPOSN.
      CALL FUNCTION 'SD_VEDA_SELECT'
           EXPORTING
                I_DOCUMENT_NUMBER = XVEDA-VBELN
                I_ITEM_NUMBER     = XVEDA-VPOSN
                I_TRTYP           = T180-TRTYP
           IMPORTING
                E_VEDAVB          = XVEDA.
      CALL FUNCTION 'SD_VEDA_SELECT'
           EXPORTING
                I_DOCUMENT_NUMBER = XVEDA-VBELN
                I_ITEM_NUMBER     = DA_POSNR_LOW
                I_TRTYP           = T180-TRTYP
           IMPORTING
                E_VEDAVB          = VEDAVB.
    ENDIF.


*   Netzpläne
    IF T459K-MNTGA EQ MOFAUF.
      DATA: BEGIN OF TFPLTNP OCCURS 1.
              INCLUDE STRUCTURE FPLTNP.
      DATA: END   OF TFPLTNP.
      PERFORM NETZPLAN_ERMITTELN(SAPFV45P)
                                 TABLES TFPLTNP
                                 USING  VBAK-VBELN
                                        VBAP-POSNR.
    ENDIF.
*   entweder Netzplan oder PSP-Element kann zu Meilensteinen führen
    DESCRIBE TABLE TFPLTNP LINES SY-TABIX.
    IF SY-TABIX EQ 0.
      IF NOT VBAP-PS_PSP_PNR  IS INITIAL OR
         NOT *VBAP-PS_PSP_PNR IS INITIAL.
        MOVE VBAP-PS_PSP_PNR TO TFPLTNP-PSPEL_NEU.
        MOVE *VBAP-PS_PSP_PNR TO TFPLTNP-PSPEL_ALT.
        APPEND TFPLTNP.
      ENDIF.
    ENDIF.
*   Bereitstellen der fakturierten Termine
    DATA: BEGIN OF TFPLTS OCCURS 10.
            INCLUDE STRUCTURE FPLTS.
    DATA: END   OF TFPLTS.
    READ TABLE XVBFA WITH KEY MANDT = SY-MANDT
                              VBELV = VBAK-VBELN
                              POSNV = VBAP-POSNR BINARY SEARCH.
    IF SY-SUBRC EQ 0.
      LOOP AT XVBFA FROM SY-TABIX.
        IF XVBFA-VBELV NE VBAK-VBELN OR
           XVBFA-POSNV NE VBAP-POSNR.
          EXIT.
        ENDIF.
        IF XVBFA-FPLNR EQ VBKD-FPLNR.
          MOVE-CORRESPONDING XVBFA TO TFPLTS.
          APPEND TFPLTS.
* Anzahlungen / Fakturierungsplan und aufwandsbezogene Faktura
        ELSEIF NOT VBKD-FFPRF IS INITIAL.
          INCLUDE BADI_SD_DPBP_FILL_TFPLTS_1.
        ENDIF.
      ENDLOOP.
    ENDIF.

*   Fuellen Anwendungsdaten
    MOVE-CORRESPONDING VBAK TO FPLAA.
    MOVE-CORRESPONDING VBAP TO FPLAA.
    MOVE VBAK-WAERK         TO FPLAA-WAERK.
    MOVE VBAP-KWMENG        TO FPLAA-MENGE.
    IF FPLAA-MENGE IS INITIAL.
      MOVE VBAP-ZMENG       TO FPLAA-MENGE.
    ENDIF.
    MOVE VBKD-KURRF TO FPLAA-KURRF.
*   Füllen Kommunikationsstruktur mit Preisfeldern aus VBAP
    MOVE-CORRESPONDING VBAP TO KOMPAX.
*   Fakturierungsplannummer initialisieren, wenn eine Pos-VBKD noch
*   nicht existiert, da sonst Änderungsmodus unterstellt wird
    MOVE VBKD-FPLNR TO DA_FPLNR.
    IF VBKD-POSNR EQ POSNR_LOW AND
       NOT VBKD-FPLNR IS INITIAL.
      CLEAR DA_FPLNR.
    ENDIF.
*   Wenn ein Absagegrund eingegeben wurde, der fakturarelevant
*   ist, dann muß der Fakturierungsplan angepasst werden.
    CLEAR DA_ABSAGEN.
ENHANCEMENT-SECTION     FPLAN_AKTUALISIEREN_CALL_01 SPOTS ES_MV45ATOP.
    IF NOT VBAP-ABGRU IS INITIAL.
      PERFORM TVAG_SELECT USING VBAP-ABGRU
                                TVAG-DRAGR
                                SPACE
                                SY-SUBRC.
      PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                      CHANGING DA_ABSAGEN.
    ENDIF.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-SECTION     FPLAN_AKTUALISIEREN_CALL_02 SPOTS ES_SAPMV45A.
*   Aufruf Generieren ohne Dialog
    CALL FUNCTION 'BILLING_SCHEDULE_GENERATE'
         EXPORTING
              I_FKDAT        = VBKD-FKDAT
              I_FPLNR        = DA_FPLNR
              I_WAERS        = VBAK-WAERK
              I_FPART        = TVAP-FPART
              I_VEDA         = XVEDA
              I_VEDA_KOPF    = VEDAVB
              I_UPD_FPLA     = UPD_FPLA
              I_UPD_FPLT     = UPD_FPLT
              I_KOMK         = TKOMK
              I_KOMP         = TKOMP
              I_KOMPAX       = KOMPAX
              I_FKREL        = VBAP-FKREL
              I_CREATE_DATES = US_FLG_CREATE_DATES
              I_KFPLAN       = DA_KFPLAN
              I_KFPLNR       = DA_KFPLNR
              I_NOMSG        = US_NOMSG
              I_ABSAGEN      = DA_ABSAGEN
              I_FPLAA        = FPLAA
         IMPORTING
              E_FPLNR        = XVBKD-FPLNR
              E_DATALOSS     = DA_DATALOSS
              E_UPD_FPLA     = UPD_FPLA
              E_UPD_FPLT     = UPD_FPLT
              E_KOMPAX       = KOMPAX
         TABLES
              FPLA_NEW       = XFPLA
              FPLA_OLD       = YFPLA
              FPLT_NEW       = XFPLT
              FPLT_OLD       = YFPLT
              I_FPLTS        = TFPLTS
              I_FPLTNP       = TFPLTNP
              I_KOMV         = XKOMV
              I_TKOMK        = TKOMK
              I_SVBAP        = UVBAP.
END-ENHANCEMENT-SECTION.

    MOVE-CORRESPONDING KOMPAX TO VBAP.
*
    IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
      R185D-DATALOSS = DA_DATALOSS.
    ENDIF.

    REFRESH TFPLTS. CLEAR TFPLTS.
    REFRESH TFPLTNP. CLEAR TFPLTNP.

    IF XVBKD-FPLNR NE VBKD-FPLNR.
      IF VBKD-POSNR EQ POSNR_LOW.
        SVBKD-TABIX = 0.
        MOVE VBAP-POSNR TO VBKD-POSNR.
      ENDIF.
      MOVE XVBKD-FPLNR TO VBKD-FPLNR.
      IF SVBKD-TABIX = 0.
        PERFORM VBKD_BEARBEITEN(SAPFV45K) USING VBKD-POSNR.
      ELSE.
        PERFORM XVBKD_AENDERN(SAPFV45K).
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.