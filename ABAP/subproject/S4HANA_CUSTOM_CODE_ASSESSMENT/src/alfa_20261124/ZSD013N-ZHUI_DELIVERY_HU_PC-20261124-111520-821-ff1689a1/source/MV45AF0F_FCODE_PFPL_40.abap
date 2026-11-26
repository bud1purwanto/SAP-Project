*eject
*---------------------------------------------------------------------*
*       FORM FCODE_PFPL_40                                            *
*---------------------------------------------------------------------*
*       Übergang zum Positionsfakturierungsplan                       *
*---------------------------------------------------------------------*
FORM FCODE_PFPL_40 USING       H185F STRUCTURE T185F
                               H185  STRUCTURE T185
                               H185V STRUCTURE T185V.
* !!!! A C H T U N G: redundantes Coding im FCODE_PFPL
  LOCAL: TVAP-FPART.

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

  DATA: DA_FPLNR    LIKE VBKD-FPLNR.
  DATA: DA_KFPLAN   LIKE RV60F-KFPLAN.
  DATA: DA_KFPLNR   LIKE VBKD-FPLNR.
  DATA: DA_ABSAGEN(1)  TYPE C.
  DATA: SAV_TRTYP LIKE T185F-TRTYP.
  DATA: DA_FPART LIKE TVAP-FPART.

*   GIBT ES EINEN KOPFFAKTURIERUNGSPLAN ?
  PERFORM XVBKD_LESEN(SAPFV45K) USING POSNR_LOW.
  PERFORM FPLANART_ERMITTELN_KOPF CHANGING TVAK-FPART.
  IF XVBKD-POSNR EQ POSNR_LOW AND
     NOT XVBKD-FPLNR IS INITIAL.
    MOVE XVBKD-FPLNR TO DA_KFPLNR.
  ENDIF.
*
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
  IF TVAP-FPART IS INITIAL .
*   Position nicht gemäß Fakturierungsplan zu fakturieren
    MESSAGE I263 WITH VBAP-POSNR.
    H185F-FCODE = FCODE_KAUFMANN_POS.
    EXIT.
  ENDIF.

  IF NOT ( VBAP-FKREL EQ CON_FKREL_FPLAN OR
           ( VBAP-FKREL IS INITIAL AND         "oder Angebote
             NOT TVAP-FPART IS INITIAL ) ).
*   Position nicht gemäß Fakturierungsplan zu fakturieren
    MESSAGE I263 WITH VBAP-POSNR.
    H185F-FCODE = FCODE_KAUFMANN_POS.
    EXIT.
  ENDIF.

* Anzeigemodus: Gibt es überhaupt ein Fakturierungsplan auf Position?
  IF T180-TRTYP EQ CHARA AND
    ( VBKD-POSNR IS INITIAL OR
    ( VBKD-POSNR EQ VBAP-POSNR AND VBKD-FPLNR IS INITIAL ) ).
*   Für diese Position existiert kein Fakturierungsplan
    MESSAGE I416(V2).
    H185F-FCODE = FCODE_KAUFMANN_POS.
    EXIT.
  ENDIF.
* Wenn es keinen Fakturierungsplan gibt und die Position ist abgesagt
* darf kein Fakturierungsplan entstehen
  IF NOT VBAP-ABGRU IS INITIAL   AND
    ( VBKD-POSNR IS INITIAL OR
    ( VBKD-POSNR EQ VBAP-POSNR AND VBKD-FPLNR IS INITIAL ) ).
*   Für diese Position existiert kein Fakturierungsplan
    MESSAGE I416(V2).
    H185F-FCODE = FCODE_KAUFMANN_POS.
    EXIT.
  ENDIF.
*
  DATA: DA_DATALOSS LIKE R185D-DATALOSS.
*
* Konditionen eingelesen.
  IF T180-TRTYP = CHARA.
    PERFORM KONV_SELECT(SAPFV45P).
  ENDIF.
*
  PERFORM PREISFINDUNG_VORBEREITEN IN PROGRAM SAPFV45P USING 'P'.
* Ermitteln, ob Positionsfakturierungsplan auf Kopffakturierungsplan
* zeigt
  PERFORM FPLANART_ERMITTELN CHANGING TVAP-FPART.
  PERFORM FPLAN_POS_KOPFRELEVANT USING    VBAP-POSNR
                                          TVAP-FPART TVAK-FPART
                                 CHANGING SY-SUBRC.
  IF SY-SUBRC = 0.
    MOVE CHARB TO DA_KFPLAN.
  ENDIF.

*   Es muß sichergestellt werden, daß bei einem wertmäßigen Kopf-
*   fakturierungsplan, der aktuelle Stand der Positionsfakturierungs-
*   pläne gesichert wird, d.h. es müssen nach Prüfung
*   auch eventuelle Differenzen verteilt werden.

  IF DA_KFPLAN EQ CHARB.
    PERFORM FPLAN_POS_WERT_VERTEILEN USING SPACE.
  ENDIF.

  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING VBAP-POSNR
                                             SVBKD-TABIX.
  PERFORM VBKD_BEARBEITEN_VORBEREITEN(SAPFV45K).
*
  IF NOT TVAK-VTERL IS INITIAL.
*   Vertragsdaten vorhanden
    DATA: DA_POSNR_LOW LIKE VEDA-VPOSN.
*
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
*
    DA_FPART = TVAP-FPART.
    PERFORM T459K_LESEN.
    TVAP-FPART = DA_FPART.

  IF T459K-MNTGA EQ MOFAUF.
    PERFORM T003O_SELECT(SAPMV45A) USING T459K-AUART
                                         CHARX
                                         SY-SUBRC.
*   Netzpläne vorhanden
    IF T003O-AUTYP = NETZ.
*
      DATA: BEGIN OF TFPLTNP OCCURS 1.
              INCLUDE STRUCTURE FPLTNP.
      DATA: END   OF TFPLTNP.
      PERFORM NETZPLAN_ERMITTELN(SAPFV45P)
                                 TABLES TFPLTNP
                                 USING  VBAK-VBELN
                                        VBAP-POSNR.
    ENDIF.
  ENDIF.
* entweder Netzplan oder PSP-Element kann zu Meilensteinen führen
  DESCRIBE TABLE TFPLTNP LINES SY-TABIX.
  IF SY-TABIX EQ 0.
    MOVE VBAP-PS_PSP_PNR TO TFPLTNP-PSPEL_NEU.
    LOOP AT YVBAP WHERE POSNR EQ VBAP-POSNR.
      MOVE YVBAP-PS_PSP_PNR TO TFPLTNP-PSPEL_ALT.
    ENDLOOP.
    IF NOT TFPLTNP-PSPEL_NEU IS INITIAL OR
       NOT TFPLTNP-PSPEL_ALT IS INITIAL.
      APPEND TFPLTNP.
    ENDIF.
  ENDIF.
* Bereitstellen der fakturierten Termine
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
       INCLUDE BADI_SD_DPBP_PFPL_40.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Aufruf Dialog
* Fuellen Anwendungsdaten für Subscreen
  MOVE-CORRESPONDING VBAK TO FPLAA.
  MOVE-CORRESPONDING VBAP TO FPLAA.
  MOVE VBAK-WAERK         TO FPLAA-WAERK.
  MOVE VBAP-KWMENG        TO FPLAA-MENGE.
  IF FPLAA-MENGE IS INITIAL.
    MOVE VBAP-ZMENG       TO FPLAA-MENGE.
  ENDIF.
  MOVE VBKD-KURRF TO FPLAA-KURRF.
  MOVE TVKO-BUKRS TO FPLAA-BUKRS.
* Füllen Kommunikationsstruktur mit Preisfeldern aus VBAP
  MOVE-CORRESPONDING VBAP TO KOMPAX.


* Fakturierungsplannummer initialisieren, wenn eine Pos-VBKD noch
* nicht existiert, da sonst Änderungsmodus unterstellt wird
  MOVE VBKD-FPLNR TO DA_FPLNR.
  IF VBKD-POSNR EQ POSNR_LOW AND
     NOT VBKD-FPLNR IS INITIAL.
    CLEAR DA_FPLNR.
  ENDIF.
* WENN EIN ABSAGEGRUND EINGEGEBEN WURDE, DER FAKTURARELEVANT
* IST, DANN MUß DER FAKTURIERUNGSPLAN ANGEPASST WERDEN.
  CLEAR DA_ABSAGEN.
  IF NOT VBAP-ABGRU IS INITIAL.
    PERFORM TVAG_SELECT USING VBAP-ABGRU
                              TVAG-DRAGR
                              SPACE
                              SY-SUBRC.
    PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                    CHANGING DA_ABSAGEN.
  ENDIF.
* Wenn es sich um eine Rechnungskorrektur handelt darf der Fakt.Plan
* eventuell nur angezeigt werden.
  MOVE T185F-TRTYP TO SAV_TRTYP.
  IF VBAK-VBKLT = VBKLT_RECH_KORR.
    IF ( VBAK-VBTYP = VBTYP_GANF AND VBAP-SHKZG = CHARX ) OR
       ( VBAK-VBTYP = VBTYP_LANF AND VBAP-SHKZG = CHARX ).
      MOVE CHARA TO T185F-TRTYP.       "Anzeige-Modus
    ENDIF.
  ENDIF.

  TAXI_PROGRAM                 = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
  TAXI_GUI_PROGRAM             = T185V-AGIDV.
  TAXI_GUI_STATUS              = T185V-STATUS.
  TAXI_GUI_TITLE               = T185V-CTITEL.

  CALL FUNCTION 'BILLING_SCHEDULE_DIALOG'
       EXPORTING
            I_T185                     = T185
            I_T185F                    = T185F
            I_T185V                    = T185V
            I_BEZEI                    = RV02P-TITLE
            I_FPLNR                    = DA_FPLNR
            I_WAERS                    = VBAK-WAERK
            I_FPART                    = TVAP-FPART
            I_VEDA                     = XVEDA
            I_VEDA_KOPF                = VEDAVB
            I_FPLAA                    = FPLAA
            I_FKDAT                    = VBKD-FKDAT
            I_UPD_FPLA                 = UPD_FPLA
            I_UPD_FPLT                 = UPD_FPLT
            I_KOMK                     = TKOMK
            I_KOMP                     = TKOMP
            I_KOMPAX                   = KOMPAX
            I_FKREL                    = VBAP-FKREL
            I_KFPLAN                   = DA_KFPLAN
            I_KFPLNR                   = DA_KFPLNR
            I_ABSAGEN                  = DA_ABSAGEN
            I_BERECHTIGUNG_BLOCK       = BERECHTIGUNG_BLOCK
            I_BERECHTIGUNG_UNBLOCK     = BERECHTIGUNG_UNBLOCK
            I_TAXI_TABSTRIP_CAPTIONS   = TAXI_TABSTRIP_CAPTIONS
            I_TAXI_PROGRAM             = TAXI_PROGRAM
            I_TAXI_HEADER_SUBSCREEN    = TAXI_HEADER_SUBSCREEN
            I_TAXI_GUI_PROGRAM         = TAXI_GUI_PROGRAM
            I_TAXI_GUI_STATUS          = TAXI_GUI_STATUS
            I_TAXI_GUI_TITLE           = TAXI_GUI_TITLE
       IMPORTING
            E_T185      = T185
            E_T185F     = T185F
            E_T185V     = T185V
            E_FPLNR     = XVBKD-FPLNR
            E_DATALOSS  = DA_DATALOSS
            E_UPD_FPLA  = UPD_FPLA
            E_UPD_FPLT  = UPD_FPLT
            E_KOMPAX    = KOMPAX
       TABLES
            FPLA_NEW    = XFPLA
            FPLA_OLD    = YFPLA
            FPLT_NEW    = XFPLT
            FPLT_OLD    = YFPLT
            I_FPLTS     = TFPLTS
            I_FPLTNP    = TFPLTNP
            I_KOMV      = XKOMV
            I_TKOMK     = TKOMK
            I_SVBAP     = UVBAP
       CHANGING
            C_TAXI_TABSTRIP  = TAXI_TABSTRIP_ITEM.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
     EXPORTING
          FCODE_IN        = T185F-FCODE
     IMPORTING
          FCODE_OUT       = FCODE
     EXCEPTIONS
          FCODE_NOT_FOUND = 1
          OTHERS          = 2.
  MOVE FCODE TO T185F-FCODE.

* Transaktionstyp richtigstellen
  MOVE SAV_TRTYP TO T185F-TRTYP.

  MOVE-CORRESPONDING KOMPAX TO VBAP.

  IF DA_DATALOSS NE SPACE AND R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = DA_DATALOSS.
  ENDIF.
*
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
    R185D-DATALOSS = CHARX.
  ENDIF.
  PERFORM VBAP_BEARBEITEN(SAPFV45P).
  PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
*
  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.