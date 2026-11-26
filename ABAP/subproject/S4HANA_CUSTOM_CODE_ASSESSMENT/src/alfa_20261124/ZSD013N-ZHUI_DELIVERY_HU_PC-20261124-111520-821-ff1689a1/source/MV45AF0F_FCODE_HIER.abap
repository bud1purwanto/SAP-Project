*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_HIER                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_HIER                                               *
*---------------------------------------------------------------------*
*       Auflösen einer Produkthierarchie: Übernahme aus Wertkontrakt  *
*---------------------------------------------------------------------*
FORM FCODE_HIER.

* Übergabetabelle für Materialien aus Sortiment
  DATA: BEGIN OF DA_PRODH_MATNR OCCURS 20,
          MATNR LIKE VBAP-MATNR.
  DATA: END OF DA_PRODH_MATNR.
  DATA: DA_POSNR_HIGH LIKE VBAP-POSNR,
        DA_PSTYN LIKE TVCPA-PSTYN,
        DA_WKKOP LIKE TVCPA-WKKOP,
        DA_PRODH LIKE VBAP-PRODH,
        DA_TVAK LIKE TVAK,
        DA_VTWEG LIKE VBAK-VTWEG.

  DA_VTWEG = VBAK-VTWEG.
  IF DA_VTWEG   NE SPACE AND
     TVTA-VTWKU NE SPACE.
    DA_VTWEG = TVTA-VTWKU.
  ENDIF.

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

* Ist eine Produkthierarchie vorhanden?
  IF VBAP-PRODH IS INITIAL.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S783.
    LEAVE SCREEN.
  ENDIF.

* Die verwendeten Felder der Struktur RV45A müssen gefüllt werden:
  RV45A-PRODH      = VBAP-PRODH.
  RV45A-POSNR      = VBAP-POSNR.
  RV45A-PSTYV      = VBAP-PSTYV.
  RV45A-WAERS      = VBAP-WAERK.       "Währung des Wertkontrakts
  RV45A-ZWERT      = VBAP-ZWERT.
  RV45A-CUA_LONG   = TEXT-260.
  RV45A-SPART      = VBAP-SPART.
  rv45a-ps_psp_pnr = vbap-ps_psp_pnr.

* Zielpositionstyp zur Bestimmung von KZFME in VBAP_UMRECHNUNGSFAKTOREN
  SELECT SINGLE * FROM TVAP WHERE PSTYV = DA_PSTYN.

* Höchste Positionsnummer besorgen
  CLEAR DA_POSNR_HIGH.
  LOOP AT XVBAP.
    IF XVBAP-POSNR > DA_POSNR_HIGH.
      DA_POSNR_HIGH = XVBAP-POSNR.
    ENDIF.
  ENDLOOP.

* Prüfen, ob generisch gesucht werden soll
  DA_PRODH = RV45A-PRODH.
  SEARCH DA_PRODH FOR '**'.
  CASE SY-SUBRC.
*   Generische Suche
    WHEN 0.
      REPLACE CHAR* WITH CHAR% INTO DA_PRODH.

* Materialien zur Produkthierarchie in entsprechende Tabelle einlesen
* jedes Material darf nur einmal in der Tabelle vorhanden sein
      SELECT MATNR FROM M_MAT1P INTO TABLE DA_PRODH_MATNR
                                WHERE PRODH LIKE DA_PRODH AND
                                      VKORG = VBAK-VKORG  AND
                                      VTWEG = DA_VTWEG.
      SORT DA_PRODH_MATNR ASCENDING.
      DELETE ADJACENT DUPLICATES FROM DA_PRODH_MATNR.

*   Exakte Übereinstimmung
    WHEN 4.
* Materialien zur Produkthierarchie in entsprechende Tabelle einlesen
* jedes Material darf nur einmal in der Tabelle vorhanden sein
      SELECT MATNR FROM M_MAT1P INTO TABLE DA_PRODH_MATNR
                                WHERE PRODH = RV45A-PRODH AND
                                      VKORG = VBAK-VKORG  AND
                                      VTWEG = DA_VTWEG.
      SORT DA_PRODH_MATNR ASCENDING.
      DELETE ADJACENT DUPLICATES FROM DA_PRODH_MATNR.
  ENDCASE.

* Auftragsartencustomizing besorgen
  SELECT SINGLE * FROM TVAK INTO DA_TVAK WHERE AUART = TVCPA-AUARN.

* XVBAP mit Materialnummern und zwingend notwendigen Feldern versorgen
  LOOP AT DA_PRODH_MATNR.

* Beim erneuten Aufruf die bereits selektierten Materialien auslassen
* und schon Selektionskennzeichen setzen
    READ TABLE XVBAP WITH KEY MATNR    = DA_PRODH_MATNR-MATNR
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
    VBAP-MATNR      = DA_PRODH_MATNR-MATNR.
    VBAP-MATWA      = DA_PRODH_MATNR-MATNR.
    VBAP-WAERK      = RV45A-WAERS.
    VBAPD-VGPOS_WK  = RV45A-POSNR.
    VBAP-PSTYV      = RV45A-PSTYV.     "Wird benötigt für Kopierroutine
    VBAPD-UPDKZ     = UPDKZ_NEW.
    VBAP-MANDT      = SY-MANDT.
    VBAP-VBELN      = VBAK-VBELN.
    vbap-ps_psp_pnr = rv45a-ps_psp_pnr.

* Prüfung auf Existenz des Materials im Vertiebsbereich und Lesen
* des Artikelkurztextes
    PERFORM MAAPV_SELECT(SAPFV45P) USING VBAP-MATNR
                                   VBAK-VKORG
                                   VBAK-VTWEG
                                   SPACE
                                   SY-SUBRC.
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

* Die Positionen des Vorgängerbelegs sollen nicht angezeigt werden,
* daher nur neue Positionen in IVBAP stellen
  PERFORM IVBAP_AUFBAUEN_WK_ABRUF_NEUE(SAPFV45P) USING RV45A-POSNR.
  IVBAP_TABIX_ZEILE_1 = 1.

ENDFORM.                    "FCODE_HIER