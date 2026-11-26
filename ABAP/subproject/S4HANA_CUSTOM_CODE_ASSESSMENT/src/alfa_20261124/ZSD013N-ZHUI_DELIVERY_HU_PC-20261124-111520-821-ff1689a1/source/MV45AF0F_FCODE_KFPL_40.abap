*---------------------------------------------------------------------*
*       FORM FCODE_KFPL_40                                            *
*---------------------------------------------------------------------*
*       Übergang zum Kopffakturierungsplan                            *
*---------------------------------------------------------------------*
FORM FCODE_KFPL_40 USING H185F STRUCTURE T185F H185  STRUCTURE T185
                                            H185V STRUCTURE T185V.
* !!!! A C H T U N G: redundantes Coding im FCODE_KFPL
  LOCAL: TVAK-FPART.
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
  DATA: DA_WERT.
  DATA: DA_UPD_POSFAKT.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* Die folgenden Aufrufe sind nötig für den direkten Aufruf. Sie werden
* normalerweise im PBO ausgeführt. Es wird der Bildgruppenwechsel
* (falls erfolgt) festgestellt, die Reiterleiste aufgebaut, der FCode
* gespeichert, der zu diesem Bild geführt hat und der aktive Reiter
* nach vorne geholt.
  PERFORM CUA_SETZEN.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.
*
  CLEAR VBAP.
  PERFORM PREISFINDUNG_VORBEREITEN IN PROGRAM SAPFV45P USING 'K'.

  IF NOT TVAK-FPART IS INITIAL.
*   Ermitteln Summe der Positionsnettowerte aller Positionen, die auf
*   Kopffakturierungsplan zeigen
    PERFORM FPLAN_SUMMEN_ERMITTELN CHANGING KOMPAX.
    PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING POSNR_LOW
                                               SVBKD-TABIX.
    PERFORM VBKD_BEARBEITEN_VORBEREITEN(SAPFV45K).
*   Anzeigemodus: Gibt es überhaupt ein Kopffakturierungsplan
    IF T180-TRTYP EQ CHARA  AND
       VBKD-POSNR IS INITIAL AND VBKD-FPLNR IS INITIAL.
*     Es existiert kein Kopfffakturierungsplan
      MESSAGE I418(V2).
      H185F-FCODE = FCODE_KAUFMANN_KOPF.
      EXIT.
    ENDIF.
*
    IF NOT TVAK-VTERL IS INITIAL.
*     Vertragsdaten vorhanden
      DATA: DA_POSNR_LOW LIKE VEDA-VPOSN.
*
      MOVE VBAK-VBELN TO XVEDA-VBELN.
      CALL FUNCTION 'SD_VEDA_SELECT'
           EXPORTING
                I_DOCUMENT_NUMBER = XVEDA-VBELN
                I_ITEM_NUMBER     = DA_POSNR_LOW
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
      MOVE VBAK-PS_PSP_PNR TO TFPLTNP-PSPEL_NEU.
      MOVE YVBAK-PS_PSP_PNR TO TFPLTNP-PSPEL_ALT.
      IF NOT TFPLTNP-PSPEL_NEU IS INITIAL OR
         NOT TFPLTNP-PSPEL_ALT IS INITIAL.
        APPEND TFPLTNP.
      ENDIF.
    ENDIF.
*   Aufruf Dialog
*   Fuellen Anwendungsdaten für Subscreen
    CLEAR FPLAA.
    MOVE-CORRESPONDING VBAK TO FPLAA.
    MOVE VBAK-WAERK         TO FPLAA-WAERK.
    MOVE TVKO-BUKRS TO FPLAA-BUKRS.
*   Füllen Kommunikationsstruktur mit Preisfeldern aus VBAK
    PERFORM FPLANART_ERMITTELN_KOPF CHANGING TVAK-FPART.
*
    TAXI_PROGRAM                 = T185V-CPROG.
    TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
    TAXI_GUI_PROGRAM             = T185V-AGIDV.
    TAXI_GUI_STATUS              = T185V-STATUS.
    TAXI_GUI_TITLE               = T185V-CTITEL.
*
    CALL FUNCTION 'BILLING_SCHEDULE_DIALOG'
         EXPORTING
              I_T185                   = T185
              I_T185F                  = T185F
              I_T185V                  = T185V
              I_BEZEI                  = RV02P-TITLE
              I_FPLNR                  = VBKD-FPLNR
              I_WAERS                  = VBAK-WAERK
              I_FPART                  = TVAK-FPART
              I_VEDA_KOPF              = VEDAVB
              I_FPLAA                  = FPLAA
              I_FKDAT                  = VBKD-FKDAT
              I_UPD_FPLA               = UPD_FPLA
              I_UPD_FPLT               = UPD_FPLT
              I_KOMK                   = TKOMK
              I_KOMPAX                 = KOMPAX
              I_KFPLAN                 = CHARA
              I_BERECHTIGUNG_BLOCK     = BERECHTIGUNG_BLOCK
              I_BERECHTIGUNG_UNBLOCK   = BERECHTIGUNG_UNBLOCK
              I_TAXI_TABSTRIP_CAPTIONS = TAXI_TABSTRIP_CAPTIONS
              I_TAXI_PROGRAM           = TAXI_PROGRAM
              I_TAXI_HEADER_SUBSCREEN  = TAXI_HEADER_SUBSCREEN
              I_TAXI_GUI_PROGRAM       = TAXI_GUI_PROGRAM
              I_TAXI_GUI_STATUS        = TAXI_GUI_STATUS
              I_TAXI_GUI_TITLE         = TAXI_GUI_TITLE
         IMPORTING
              E_T185                   = T185
              E_T185F                  = T185F
              E_T185V                  = T185V
              E_FPLNR                  = XVBKD-FPLNR
              E_DATALOSS               = DA_DATALOSS
              E_UPD_FPLA               = UPD_FPLA
              E_UPD_FPLT               = UPD_FPLT
              E_KOMPAX                 = KOMPAX
              E_UPD_POSFAKT            = DA_UPD_POSFAKT
         TABLES
              FPLA_NEW                 = XFPLA
              FPLA_OLD                 = YFPLA
              FPLT_NEW                 = XFPLT
              FPLT_OLD                 = YFPLT
              I_FPLTNP                 = TFPLTNP
              I_TKOMK                  = TKOMK
              I_SVBAP                  = UVBAP
         CHANGING
              C_TAXI_TABSTRIP          = TAXI_TABSTRIP_HEAD.

* Referenz zum Gruppenkontrakt prüfen beim verlassen des Kopfbildes
    PERFORM GRUPPENREFERENZ_PRUEFEN(SAPFV45K).

    CALL FUNCTION 'TAXI_CONVERT_FCODE'
         EXPORTING
              FCODE_IN        = T185F-FCODE
         IMPORTING
              FCODE_OUT       = FCODE
         EXCEPTIONS
              FCODE_NOT_FOUND = 1
              OTHERS          = 2.
    MOVE FCODE TO T185F-FCODE.

    IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
      R185D-DATALOSS = DA_DATALOSS.
    ENDIF.
*
    IF XVBKD-FPLNR NE VBKD-FPLNR.
      MOVE XVBKD-FPLNR TO VBKD-FPLNR.
      IF SVBKD-TABIX = 0.
        PERFORM VBKD_BEARBEITEN(SAPFV45K) USING VBKD-POSNR.
      ELSE.
*       Aufruf wegen Unvollständigkeit
        PERFORM VBKD_PRUEFEN(SAPFV45K) USING VBKD-POSNR.
        PERFORM XVBKD_AENDERN(SAPFV45K).
      ENDIF.
    ENDIF.

* Prüfen, ob es sich um einen wertmäßigen Kopffakturierungsplan handelt
    CALL FUNCTION 'BILL_SCHED_VALUE_BASED_CHECK'
         EXPORTING
              I_KFPLNR       = VBKD-FPLNR
         TABLES
              FPLT_NEW       = XFPLT
         EXCEPTIONS
              VALUE_BASED_OK = 1
              OTHERS         = 2.

    IF SY-SUBRC = 1.
      MOVE CHARX TO DA_WERT.
    ELSE.
      CLEAR DA_WERT.
    ENDIF.

    IF DA_DATALOSS NE SPACE OR
       NOT DA_UPD_POSFAKT IS INITIAL OR
       NOT DA_WERT IS INITIAL.
*   Positionsfakturierungspläne aus Kopf aktualisieren
      PERFORM FPLAN_AKTUALISIEREN(SAPMV45A)
        USING POSNR_FIRST POSNR_HIGH
              SPACE.

      IF NOT DA_WERT IS INITIAL.
*       Möglicherweise müssen noch Differenzen verteilt werden, wenn es
*       sich um einen wertmäßigen Kopffakturierungsplan handelt.
        PERFORM FPLAN_KOPF_WERT_VERTEILEN.
      ENDIF.
    ENDIF.
  ENDIF.
*
  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.