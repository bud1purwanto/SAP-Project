*---------------------------------------------------------------------*
*       FORM FCODE_AUFL                                               *
*---------------------------------------------------------------------*
*       Auflösen eines Sortiments bei der Übernahme aus Wertkontrakt  *
*---------------------------------------------------------------------*
FORM FCODE_AUFL.

* Übergabetabelle für Materialien aus Sortiment
  DATA: BEGIN OF DA_WSOP_READ OCCURS 20.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_READ.
* Übergabestruktur zur Definition des auszulesenden Sortiments
  DATA: BEGIN OF DA_WSOP_INPUT.
          INCLUDE STRUCTURE WSOP.
  DATA: END OF DA_WSOP_INPUT.
  DATA: DA_POSNR_HIGH LIKE VBAP-POSNR,
        DA_PSTYN LIKE TVCPA-PSTYN,
        DA_WKKOP LIKE TVCPA-WKKOP,
        DA_TVAK LIKE TVAK.

* Wurde eine Position selektiert?
  PERFORM XVBAP_DETAIL(SAPFV45P).

  IF FCODE EQ FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S678.
    LEAVE SCREEN.
  ENDIF.

* Darf ein Material außer dem Wertkontraktmaterial kopiert werden?
  PERFORM WERTKONTRAKT_KOPIEREN_PRUEFEN USING DA_WKKOP
                                              TVCPA-AUARN
                                              TVCPA-AUARV
                                              TVCPA-FKARV
                                              SPACE
                                              VBAP-PSTYV
                                              DA_PSTYN.

  IF DA_WKKOP EQ CHARB.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S678.
    LEAVE SCREEN.
  ENDIF.

* Ist der Zielwert bereits erreicht?
  PERFORM WK_ABRUF_PRUEFEN_KOPIEREN USING SY-SUBRC
                                          VBAP.
  IF SY-SUBRC > 0.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    LEAVE SCREEN.
  ENDIF.

* Ist ein Sortimentsbaustein vorhanden?
  IF VBAP-SKOPF IS INITIAL.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S649.
    LEAVE SCREEN.
  ENDIF.

* Die verwendeten Felder der Struktur RV45A müssen gefüllt werden:
  RV45A-SKOPF      = VBAP-SKOPF.
  RV45A-POSNR      = VBAP-POSNR.
  RV45A-PSTYV      = VBAP-PSTYV.
  RV45A-WAERS      = VBAP-WAERK.       "Währung des Wertkontrakts
  RV45A-ZWERT      = VBAP-ZWERT.
  RV45A-CUA_LONG   = TEXT-260.
  RV45A-SPART      = VBAP-SPART.
  RV45A-PS_PSP_PNR = VBAP-PS_PSP_PNR.
  DA_WSOP_INPUT-MANDT = SY-MANDT.
  DA_WSOP_INPUT-SKOPF = VBAP-SKOPF.

* Zielpositionstyp zur Bestimmung von KZFME in VBAP_UMRECHNUNGSFAKTOREN
  SELECT SINGLE * FROM TVAP WHERE PSTYV = DA_PSTYN.

* Höchste Positionsnummer besorgen
  CLEAR DA_POSNR_HIGH.
  LOOP AT XVBAP.
    IF XVBAP-POSNR > DA_POSNR_HIGH.
      DA_POSNR_HIGH = XVBAP-POSNR.
    ENDIF.
  ENDLOOP.

* Sortiment auslesen
  CALL FUNCTION 'WSOP_READ_WSOP'
       EXPORTING
            WSOP          = DA_WSOP_INPUT
            DATUM         = SY-DATLO
            ALL_POS       = CHARX
       TABLES
            WSOP_INPUT    = DA_WSOP_READ
       EXCEPTIONS
            NO_REC_FOUND  = 1
            NO_REC_ACTIVE = 2.

* Auftragsartencustomizing besorgen
  SELECT SINGLE * FROM TVAK INTO DA_TVAK WHERE AUART = TVCPA-AUARN.

ENHANCEMENT-POINT FCODE_AUFL_01 SPOTS ES_SAPMV45A STATIC.
ENHANCEMENT-POINT FCODE_AUFL_02 SPOTS ES_SAPMV45A.
* XVBAP mit Materialnummern und zwingend notwendigen Feldern versorgen
  LOOP AT DA_WSOP_READ.

* Beim erneuten Aufruf die bereits selektierten Materialien auslassen
* und schon Selektionskennzeichen setzen
    READ TABLE XVBAP WITH KEY MATNR    = DA_WSOP_READ-SPOSI
                              VGPOS_WK = RV45A-POSNR
                              UPDKZ    = UPDKZ_NEW.
    IF SY-SUBRC = 0.
      VBAP = XVBAP.
      RV45A-VBAP_SELKZ = SELEKTIERT.
      PERFORM IVBAP_ANLEGEN(SAPFV45P) USING SY-TABIX.
      CLEAR RV45A-VBAP_SELKZ.
      CONTINUE.
    ENDIF.

    CLEAR: VBAP, VBAPD.
    DA_POSNR_HIGH = DA_POSNR_HIGH + 1.
* Entsprechende Felder der XVBAP füllen
    VBAP-POSNR      = DA_POSNR_HIGH.
    VBAP-MATNR      = DA_WSOP_READ-SPOSI.
    VBAP-MATWA      = DA_WSOP_READ-SPOSI.
    VBAP-WAERK      = RV45A-WAERS.
    VBAPD-VGPOS_WK  = RV45A-POSNR.
    VBAP-PSTYV      = RV45A-PSTYV.     "Wird benötigt für Kopierroutine
    VBAP-PS_PSP_PNR = RV45A-PS_PSP_PNR.
    VBAPD-UPDKZ     = UPDKZ_NEW.
    VBAP-MANDT      = SY-MANDT.
    VBAP-VBELN      = VBAK-VBELN.

ENHANCEMENT-SECTION     FCODE_AUFL_03 SPOTS ES_SAPMV45A.
* Prüfung auf Existenz des Materials im Vertiebsbereich und Lesen
* des Artikelkurztextes
    PERFORM MAAPV_SELECT(SAPFV45P) USING VBAP-MATNR
                                   VBAK-VKORG
                                   VBAK-VTWEG
                                   SPACE
                                   SY-SUBRC.
END-ENHANCEMENT-SECTION.



* Nur übernehmen, wenn Material für Vertriebsbereich vorgesehen ist
* und lesen Materialstamm erfolgreich war.
    IF SY-SUBRC = 0 AND
       NOT MAAPV-MATNR IS INITIAL.
      PERFORM VBAP_FUELLEN_MAAPV(SAPFV45P).
* Hat Sparte aus Kopf Vorrang?
      VBAP-SPART = VBAK-SPART.
      IF DA_TVAK-SPAPO NE SPACE AND
         MAAPV-SPART NE SPACE.
        VBAP-SPART = MAAPV-SPART.
      ENDIF.
* Artikelkurztext wird nicht mehr in VBAP_FUELLEN_MAAPV gefüllt
      VBAP-ARKTX = MAAPV-ARKTX.
* Umrechnungsfaktoren in Lagermengeneinheit müssen gefüllt werden
      PERFORM VBAP_UMRECHNUNGSFAKTOREN(SAPFV45P) USING SY-SUBRC.
      IF ( TVAP-ETERL = SPACE AND
           ( SY-SUBRC = 0 OR
             SY-SUBRC = 1 ) ) OR
         ( TVAP-ETERL = CHARX AND
           ( SY-SUBRC = 0 OR
             SY-SUBRC = 3 ) ).
* Wenn im Materialstamm keine Sparte definiert ist
* --> Sparte aus Wertkontraktposition übernehmen
        IF VBAP-SPART IS INITIAL.
          VBAP-SPART = RV45A-SPART.
        ENDIF.
        MOVE-CORRESPONDING VBAP TO XVBAP.
        MOVE-CORRESPONDING VBAPD TO XVBAP.
        APPEND XVBAP.
      ENDIF.

    ENDIF.
  ENDLOOP.
ENHANCEMENT-POINT FCODE_AUFL_04 SPOTS ES_SAPMV45A.

* Die Positionen des Vorgängerbelegs sollen nicht angezeigt werden,
* daher nur neue Positionen in IVBAP stellen
  PERFORM IVBAP_AUFBAUEN_WK_ABRUF_NEUE(SAPFV45P) USING RV45A-POSNR.
  IVBAP_TABIX_ZEILE_1 = 1.

ENDFORM.