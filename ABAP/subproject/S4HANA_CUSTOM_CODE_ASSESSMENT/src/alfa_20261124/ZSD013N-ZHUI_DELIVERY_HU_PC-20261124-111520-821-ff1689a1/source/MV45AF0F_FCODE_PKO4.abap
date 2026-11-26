*eject
*&---------------------------------------------------------------------*
*&      Form  FCODE_PKO4
*&---------------------------------------------------------------------*
*       Kopie von FCODE_PKON mit TAXI-Navigation
*----------------------------------------------------------------------*
FORM FCODE_PKO4 USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.
DATA: DA_ABSAGEN(1) TYPE C.
DATA: DA_RESTMENGE  LIKE KOMP-MGLME,
      DA_RESTMENGEV LIKE KOMP-MGAME.

* Die folgenden Aufrufe sind nötig für den direkten Aufruf. Sie werden
* normalerweise im PBO ausgeführt. Es wird der Bildgruppenwechsel
* (falls erfolgt) festgestellt, die Reiterleiste aufgebaut, der FCode
* gespeichert, der zu diesem Bild geführt hat und der aktive Reiter
* nach vorne geholt.
  PERFORM CUA_SETZEN.
ENHANCEMENT-POINT FCODE_PKO4_01 SPOTS ES_SAPMV45A.
  PERFORM TAXI_INITIALIZE_CARRIERSCREEN.

  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
  IF VBAP-POSAR = CHARB.
    H185F-FCODE = C_TAXI_DEFAULT_ITEM_FCODE.
    exit.
  ENDIF.
  PERFORM PREISFINDUNG_VORBEREITEN(SAPFV45P) USING 'P'.
  DATA: DISPLAY_MODE.
  IF TKOMP-KAEND_TYP(1) = '*'.
    DISPLAY_MODE = 'X'.
  ENDIF.
* Rechnungskorrektur (bei Gut- oder Lastschrift dürfen die Konditionen
* der automatisch erzeugten Gut-/Last Position nicht eingabebereit sein)
  IF VBAK-VBKLT = VBKLT_RECH_KORR.
    IF ( VBAK-VBTYP = VBTYP_GANF AND VBAP-SHKZG = CHARX  AND
         NOT VBAP-VGPOS IS INITIAL                           ) OR
       ( VBAK-VBTYP = VBTYP_LANF AND VBAP-SHKZG = CHARX  AND
         NOT VBAP-VGPOS IS INITIAL                           ).
      DISPLAY_MODE = 'X'.
    ENDIF.
  ENDIF.
* Bildtext für Dialogbaustein aufbauen
  DATA: BILDTEXT(40) TYPE C.
*  bildtext    = tvakt-bezei.

  BILDTEXT = RV02P-TITLE.
  CONDENSE BILDTEXT.
  EXPORT FEHLER TO MEMORY ID 'PKON'.

  TAXI_PROGRAM                 = T185V-CPROG.
  TAXI_HEADER_SUBSCREEN        = T185V-DYBS1.
  TAXI_GUI_PROGRAM             = T185V-AGIDV.
  TAXI_GUI_STATUS              = T185V-STATUS.
  IF FEHLER = CHARX.
    TAXI_GUI_STATUS = 'FS_EXT'.
  ENDIF.
  TAXI_GUI_TITLE               = T185V-CTITEL.
* Wegen Rollbereichswechsel bei Call Dialog müssen zunächst die
* Felder des HeaderSubscreens zur späteren Rückübernahme in
* ABAP-Memory geschrieben werden.
  PERFORM TAXI_SET_ITEM_HEADER.

  CALL FUNCTION 'PRICING_DIALOG_TABSTRIPS'
       EXPORTING
            COMM_HEAD_I   = TKOMK
            COMM_ITEM_I   = TKOMP
            COMM_TEXT     = BILDTEXT
            MATERIAL_TEXT = VBAP-ARKTX
            T185_I        = T185
            T185F_I       = T185F
            T185V_I       = T185V
            DISPLAY_ONLY  = DISPLAY_MODE
            TAXI_TABSTRIP_CAPTIONS_I = TAXI_TABSTRIP_CAPTIONS
            TAXI_PROGRAM_I           = TAXI_PROGRAM
            TAXI_HEADER_SUBSCREEN_I  = TAXI_HEADER_SUBSCREEN
            TAXI_GUI_PROGRAM_I       = TAXI_GUI_PROGRAM
            TAXI_GUI_STATUS_I        = TAXI_GUI_STATUS
            TAXI_GUI_TITLE_I         = TAXI_GUI_TITLE
       IMPORTING
            COMM_HEAD_E   = TKOMK
            COMM_ITEM_E   = TKOMP
            T185_E        = T185
            T185F_E       = T185F
       TABLES
            TKOMV         = XKOMV
            SVBAP         = UVBAP
       CHANGING
            TAXI_TABSTRIP_C = TAXI_TABSTRIP_ITEM.

  CALL FUNCTION 'TAXI_CONVERT_FCODE'
     EXPORTING
          FCODE_IN        = T185F-FCODE
     IMPORTING
          FCODE_OUT       = T185F-FCODE
     EXCEPTIONS
          FCODE_NOT_FOUND = 1
          OTHERS          = 2.

  IF T185F-TRTYP NE CHARA.
*   nicht im Anzeigemodus
    IF TKOMP-PRSGR = CHARX.
      PRSGR = TKOMP-PRSGR.
    ENDIF.

    MODIFY TKOMK INDEX TKOMP-IX_KOMK.
    PERFORM KOMPAX_FILL_FROM_KOMP(SAPLV61A)
      USING    TKOMP
             VBAP-CMPRE_FLT
      CHANGING KOMPAX.
    IF TKOMP-FXMSG NE SPACE.
      R185D-DATALOSS = CHARX.
      KONV_GEAENDERT = CHARX.
    ENDIF.
    IF TKOMP-FXMSG NE SPACE.
      IF VBAP-FKREL EQ CON_FKREL_FPLAN OR
       ( VBAP-FKREL IS INITIAL AND       "oder Angebote
         NOT TVAP-FPART IS INITIAL ).
*     Aufruf Aktualisieren Fakturawerte
        PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING VBAP-POSNR
                                                   SVBKD-TABIX.
        IF NOT XVBKD-FPLNR IS INITIAL.
* Bereitstellen der fakturierten Termine
  DATA: BEGIN OF TFPLTS OCCURS 10.
          INCLUDE STRUCTURE FPLTS.
  DATA: END   OF TFPLTS.
          READ TABLE XVBFA WITH KEY MANDT = SY-MANDT
                                    VBELV = VBAP-VBELN
                                    POSNV = VBAP-POSNR BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            LOOP AT XVBFA FROM SY-TABIX.
              IF XVBFA-VBELV NE VBAP-VBELN OR
                 XVBFA-POSNV NE VBAP-POSNR.
                EXIT.
              ENDIF.
              IF XVBFA-FPLNR EQ XVBKD-FPLNR.
                MOVE-CORRESPONDING XVBFA TO TFPLTS.
                APPEND TFPLTS.
* Anzahlungen / Fakturierungsplan und aufwandsbezogene Faktura
              ELSEIF NOT XVBKD-FFPRF IS INITIAL.
               INCLUDE BADI_SD_DPBP_PKO4.
              ENDIF.
            ENDLOOP.
          ENDIF.
*       Wenn ein Absagegrund eingegeben wurde, der fakturarelevant
*       ist, muß dies dem Fakturierungsplan mitgegeben werden
          CLEAR DA_ABSAGEN.
ENHANCEMENT-SECTION     FCODE_PKO4_02 SPOTS ES_MV45ATOP.
          IF NOT VBAP-ABGRU IS INITIAL.
            PERFORM TVAG_SELECT USING VBAP-ABGRU
                                      TVAG-DRAGR
                                      SPACE
                                      SY-SUBRC.
            PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                            CHANGING DA_ABSAGEN.
          ENDIF.
END-ENHANCEMENT-SECTION.
*       Fuellen Anwendungsdaten
          MOVE-CORRESPONDING VBAK TO FPLAA.
          MOVE-CORRESPONDING VBAP TO FPLAA.
          MOVE VBAP-WAERK         TO FPLAA-WAERK.
          MOVE *VBAP-WAERK        TO FPLAA-WAERK_ALT.
          MOVE EURO_WAERS         TO FPLAA-EURO.
          MOVE VBAP-KWMENG        TO FPLAA-MENGE.
          IF FPLAA-MENGE IS INITIAL.
            MOVE VBAP-ZMENG       TO FPLAA-MENGE.
          ENDIF.
*       MOVE-CORRESPONDING TKOMP TO KOMPAX.
          CALL FUNCTION 'BILLING_SCHEDULE_INVOICE_VALUE'
               EXPORTING
                    I_FPLNR    = XVBKD-FPLNR
                    I_WAERS    = VBAP-WAERK
                    I_UPD_FPLA = UPD_FPLA
                    I_UPD_FPLT = UPD_FPLT
                    I_KOMK     = TKOMK
                    I_KOMP     = TKOMP
                    I_KOMPAX   = KOMPAX
                    I_ABSAGEN  = DA_ABSAGEN
                    I_FPLAA    = FPLAA
               IMPORTING
                    E_UPD_FPLA = UPD_FPLA
                    E_UPD_FPLT = UPD_FPLT
                    E_KOMPAX   = KOMPAX
               TABLES
                    FPLA_NEW   = XFPLA
                    FPLA_OLD   = YFPLA
                    FPLT_NEW   = XFPLT
                    FPLT_OLD   = YFPLT
                    I_KOMV     = XKOMV
                    I_TKOMK    = TKOMK
                    I_FPLTS    = TFPLTS
                    I_SVBAP    = UVBAP.
          MOVE-CORRESPONDING KOMPAX TO TKOMP.
        ENDIF.
      ENDIF.
* Für Wertkontraktpositionen muß der Zielwert aktualisiert werden
      IF VBAP-ERLRE EQ CON_ERLRE_WERTKONTRAKT.
        PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING VBAP-POSNR
                                                   SVBKD-TABIX.
        PERFORM XKOMV_LESEN(SAPFV45P).
      ENDIF.
      MOVE-CORRESPONDING KOMPAX TO VBAP.
      PERFORM VBKD_BEARBEITEN_ZTERM(SAPFV45K)
              USING TKOMP-ZTERM TKOMP-VALDT TKOMP-VALTG.
      PERFORM VBAP_BEARBEITEN(SAPFV45P).
      PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
    ENDIF.
    IF prsgr = CHARX.
       Perform preisfindung_gesamt USING CHARA.
       CLEAR prsgr.
    ENDIF.
  ENDIF.

  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.                    " FCODE_PKO4