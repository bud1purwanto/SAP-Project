*---------------------------------------------------------------------*
*       FORM FCODE_PKON                                               *
*---------------------------------------------------------------------*
*       Übergang zum Positionspreisbild via Dialogbaustein            *
*---------------------------------------------------------------------*
FORM FCODE_PKON USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.
  DATA: DA_ABSAGEN(1) TYPE C.
  DATA: DA_RESTMENGE  LIKE KOMP-MGLME,
        DA_RESTMENGEV LIKE KOMP-MGAME.

  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
  IF VBAP-POSAR = CHARB.
    H185F-FCODE = FCODE_ZURUECK.
    EXIT.
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
  BILDTEXT    = TVAKT-BEZEI.
  CONDENSE BILDTEXT.
  EXPORT FEHLER TO MEMORY ID 'PKON'.
* Baustein auskommentiert, da es zu 4.6A den Konditionssubscreen gibt
* CALL FUNCTION 'PRICING_DIALOG'
*      EXPORTING
*           COMM_HEAD_I   = TKOMK
*           COMM_ITEM_I   = TKOMP
*           COMM_TEXT     = BILDTEXT
*           MATERIAL_TEXT = VBAP-ARKTX
*           T185_I        = T185
*           T185F_I       = T185F
*           T185V_I       = T185V
*           DISPLAY_ONLY  = DISPLAY_MODE
*      IMPORTING
*           COMM_HEAD_E   = TKOMK
*           COMM_ITEM_E   = TKOMP
*           T185_E        = T185
*           T185F_E       = T185F
*      TABLES
*           TKOMV         = XKOMV
*           SVBAP         = UVBAP.


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
             INCLUDE BADI_SD_DPBP_PKON.
            ENDIF.
          ENDLOOP.
        ENDIF.
*       MOVE-CORRESPONDING TKOMP TO KOMPAX.
*       Wenn ein Absagegrund eingegeben wurde, der fakturarelevant
*       ist, muß dies dem Fakturierungsplan mitgegeben werden
        CLEAR DA_ABSAGEN.
        IF NOT VBAP-ABGRU IS INITIAL.
          PERFORM TVAG_SELECT USING VBAP-ABGRU
                                    TVAG-DRAGR
                                    SPACE
                                    SY-SUBRC.
          PERFORM FPLAN_ABSAGEN_ERMITTELN USING    TVAG
                                          CHANGING DA_ABSAGEN.
        ENDIF.
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
    MOVE-CORRESPONDING KOMPAX TO VBAP.
    PERFORM VBKD_BEARBEITEN_ZTERM(SAPFV45K)
            USING TKOMP-ZTERM TKOMP-VALDT TKOMP-VALTG.
    PERFORM VBAP_BEARBEITEN(SAPFV45P).
    PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
  ENDIF.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.
  FCODE = T185F-FCODE.

ENDFORM.