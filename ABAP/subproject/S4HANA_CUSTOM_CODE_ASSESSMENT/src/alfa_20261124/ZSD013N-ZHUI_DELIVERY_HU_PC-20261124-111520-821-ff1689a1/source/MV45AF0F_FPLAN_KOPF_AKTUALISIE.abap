*---------------------------------------------------------------------*
*       FORM FPLAN_KOPF_AKTUALISIEREN_CALL                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  US_FLG_CREATE_DATES                                           *
*---------------------------------------------------------------------*
FORM FPLAN_KOPF_AKTUALISIEREN_CALL
  USING  US_FLG_CREATE_DATES.
  LOCAL: TVAK-FPART.
  LOCAL: VBAP, VBAPD.
  LOCAL: VBKD.
  LOCAL: *VBKD.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
* Da es sich hier um den Kopffakturierungsplan handelt, muß die
* Feldleiste VBAP und VBAPD leer sein, damit im PREISFINDUNG_VORBEREITEN
* die TKOMK nicht durch Positionsdaten beinflußt wird.
* (wichtig für möglichen Terminsplitt auf dem Kopffakturierungsplan)
  CLEAR: VBAP, VBAPD.
  PERFORM PREISFINDUNG_VORBEREITEN IN PROGRAM SAPFV45P USING 'K'.
  IF NOT TVAK-FPART IS INITIAL.
    PERFORM FPLAN_SUMMEN_ERMITTELN CHANGING KOMPAX.
    PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                               SVBKD-TABIX.
    PERFORM VBKD_BEARBEITEN_VORBEREITEN(SAPFV45K).
*
*   VEDA lesen
    IF NOT TVAK-VTERL IS INITIAL.
*     Vertragsdaten vorhanden
      DATA: DA_POSNR_LOW LIKE VEDA-VPOSN.
      MOVE VBAK-VBELN TO XVEDA-VBELN.
      MOVE POSNR_LOW  TO XVEDA-VPOSN.
      CALL FUNCTION 'SD_VEDA_SELECT'
           EXPORTING
                I_DOCUMENT_NUMBER = XVEDA-VBELN
                I_ITEM_NUMBER     = POSNR_LOW
                I_TRTYP           = T180-TRTYP
           IMPORTING
                E_VEDAVB          = VEDAVB.
    ENDIF.
*   entweder Netzplan oder PSP-Element kann zu Meilensteinen führen
    DATA: BEGIN OF TFPLTNP OCCURS 1.
            INCLUDE STRUCTURE FPLTNP.
    DATA: END   OF TFPLTNP.
    DESCRIBE TABLE TFPLTNP LINES SY-TABIX.
    IF SY-TABIX EQ 0.
      IF NOT VBAK-PS_PSP_PNR  IS INITIAL OR
         NOT *VBAK-PS_PSP_PNR IS INITIAL.
        MOVE VBAK-PS_PSP_PNR TO TFPLTNP-PSPEL_NEU.
        MOVE *VBAK-PS_PSP_PNR TO TFPLTNP-PSPEL_ALT.
        APPEND TFPLTNP.
      ENDIF.
    ENDIF.

    PERFORM FPLANART_ERMITTELN_KOPF CHANGING TVAK-FPART.
*   Aufruf Generieren ohne Dialog
    CALL FUNCTION 'BILLING_SCHEDULE_GENERATE'
         EXPORTING
              I_FKDAT        = VBKD-FKDAT
              I_FPLNR        = VBKD-FPLNR
              I_WAERS        = VBAK-WAERK
              I_FPART        = TVAK-FPART
              I_VEDA_KOPF    = VEDAVB
              I_UPD_FPLA     = UPD_FPLA
              I_UPD_FPLT     = UPD_FPLT
              I_KOMK         = TKOMK
              I_KOMPAX       = KOMPAX
              I_CREATE_DATES = US_FLG_CREATE_DATES
              I_KFPLAN       = CHARA
              I_NOMSG        = CHARX
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
              I_FPLTNP       = TFPLTNP
              I_TKOMK        = TKOMK.
*
    IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
      R185D-DATALOSS = DA_DATALOSS.
    ENDIF.

    REFRESH TFPLTNP. CLEAR TFPLTNP.

    IF XVBKD-FPLNR NE VBKD-FPLNR.
      MOVE XVBKD-FPLNR TO VBKD-FPLNR.
      IF SVBKD-TABIX = 0.
        PERFORM VBKD_BEARBEITEN(SAPFV45K) USING VBKD-POSNR.
      ELSE.
*       Aufruf wegen Unvollständigkeit
        PERFORM XVBKD_AENDERN(SAPFV45K).
        PERFORM VBKD_PRUEFEN_VOLLST(SAPFV45K) USING VBKD-POSNR
                                                     SPACE.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.