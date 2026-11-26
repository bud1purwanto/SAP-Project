*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_SONDERREGELN                                 *
*---------------------------------------------------------------------*
*       Feste Sonderregeln der Feldauswahl                            *
*       falls screen-group3 ne space.                                 *
* Das Coding wurde zu 4.5A überarbeitet:                              *
* 1. Regeln entfernen                                                 *
* 2. Im Dynpro screen-group3 entfernt                                 *
* 3. Coding im mv45affe_feldauswahl_status eingebaut                  *
*---------------------------------------------------------------------*
FORM feldauswahl_sonderregeln.

  FIELD-SYMBOLS: <feld>.
  DATA: da_lfdnr LIKE tstl-lfdnr,
        da_olfmng LIKE vbepd-olfmng,
        da_counter LIKE sy-tabix.

ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_10 SPOTS ES_SAPMV45A STATIC.

  CASE screen-group3.

* Bei nicht kopierbaren Positionen ist das SELKZ nicht eingabebereit
* Bei Vollreferenz kann das Selektionskennzeichen nicht geändert
* werden, außer bei Alternativpostionen und deren Grundposition
    WHEN 'SEL'.

      PERFORM xvbap_markierbar_pruefen(sapfv45p) USING sy-subrc.
      IF sy-subrc > 0.
        screen-input = 0.
      ENDIF.

* nur eingabebereit, wenn initial
    WHEN '001'.
      ASSIGN (screen-name) TO <feld>.
      IF NOT <feld> IS INITIAL.
        screen-input = 0.
      ENDIF.

* Ausblenden Positionsdaten auf Einteilungsloop-Folgezeilen
    WHEN '003'.
*   Modul VBAP_AUSBLENDEN wird von XVBEP_LESEN aus aufgerufen

* da zu 4.6A die VBAP-MATNR im TC nach hinten gerutscht ist, muß sie
* - außer für Batch-Input - ausgeblendet werden (nur Spaltenüberschrift
* ausblenden genügt nicht)
      IF screen-name EQ 'VBAP-MATNR' AND tvak-ermat NE chara
        AND sy-binpt EQ space.
        screen-active = 0.
      ENDIF.

* Auf Positionsbildern sind Einteilungsdaten nicht eingabebereit,
* wenn mehr als eine Einteilung da ist.
    WHEN '004'.
      IF vbap-kwmeng > vbep-cmeng.
        screen-input = 0.
      ENDIF.
* Auf Positionsbildern sind Einteilungsdaten nicht aktiv,
* wenn zur Position keine Einteilungen erlaubt sind.
      IF tvap-eterl  = space AND
         vbapd-pvpos = space AND
         NOT tvap-pstyv IS INITIAL OR
         tvap-pstyv IS INITIAL AND
         vbak-vbtyp CA vbtyp_ohne_einteilung.
        screen-active = 0.
      ENDIF.
* Desgleichen bei Zuliefererlieferplänen
      IF vbak-abdis NE space.
        screen-active = 0.
        CASE screen-name.
          WHEN 'RV45A-KWMENG'.
            screen-active = 1.
            screen-input  = 0.
          WHEN 'VBAP-VRKME'.
            screen-active = 1.
            screen-input  = 1.
        ENDCASE.
      ENDIF.
* Keine Änderung der Menge beim Sammelartikel
      IF vbapd-attyp EQ sam_typ.
        screen-input = 0.
      ENDIF.
* Keine Änderung bei Strecke und Fakturamenge gemäß Wareneingangsmenge,
* wenn Fakturastatus erledigt
      IF VBAP-FKREL EQ 'B'.
        read table xvbup with key vbeln = vbap-vbeln
                                  posnr = vbap-posnr.
        IF XVBUP-FKSAA EQ 'C'.
          read table xvbapf with key vbeln = vbap-vbeln
                                     posnr = vbap-posnr.
          IF XVBAPF-WEMNG      EQ XVBAPF-ERLMENGE_F AND
             XVBAPF-ERLMENGE_F GT VBAP-KWMENG.
            screen-input = 0.
          ENDIF.
        ENDIF.
      ENDIF.

* Keine kaufmännischen Daten auf der Position erlaubt
    WHEN '005'.
      IF tvap-kderl EQ space AND vbkd-posnr = posnr_low.   "Hnweis
        screen-input = 0.
      ENDIF.

* Nicht eingabebereit, wenn initial oder kaufmännische Daten nicht er-
* laubt sind.
    WHEN '006'.
      ASSIGN (screen-name) TO <feld>.
      IF <feld> IS INITIAL OR ( tvap-kderl EQ space AND
                                vbkd-posnr = posnr_low ).
        screen-input = 0.
      ENDIF.

* Feld ausblenden, wenn initial (Nullenunterdrückung)
    WHEN '007'.
      ASSIGN (screen-name) TO <feld>.
      IF <feld> IS INITIAL.
        screen-active = 0.
      ENDIF.

* Fußzeile (Materialnummer, Charge, Werk) nur änderbar,
* wenn keine Unterpositionen da sind und keine Referenz vorliegt.
* Änderungen der Fusszeile haben Auswirkung auf alle Einteilungen (Typ)
    WHEN '008'.

* da zu 4.6A die VBAP-MATNR im TC nach hinten gerutscht ist, muß sie
* - außer für Batch-Input - ausgeblendet werden (nur Spaltenüberschrift
* ausblenden genügt nicht)
      IF screen-name EQ 'VBAP-MATNR' AND tvak-ermat NE chara
        AND sy-binpt EQ space.
        screen-active = 0.
      ENDIF.

* Hat die Position Unterpositionen ?
      IF screen-name NE 'VBAP-CHARG'.  " nicht bei Chargen
        READ TABLE uvbap WITH KEY uepos = vbap-posnr BINARY SEARCH.
        IF sy-subrc = 0.
          screen-input = 0.
        ENDIF.
      ENDIF.

* Ist die Position eine relevante Folgeposition ?
      ASSIGN (screen-name) TO <feld>.
      IF NOT vbap-vgpos IS INITIAL AND
         vbap-upflu NE space AND
         screen-name NE 'VBAP-CHARG' AND
         NOT <feld> IS INITIAL.
        screen-input = 0.
      ENDIF.

* Teilgeliferte Chargen-Positionen dürfen nicht geändert werden
      IF screen-name  EQ 'VBAP-CHARG' AND
         screen-input NE 0.            " nicht schon sowiso zu
        READ TABLE xvbup WITH KEY vbeln = vbap-vbeln
                                  posnr = vbap-posnr.
        IF xvbup-lfsta EQ charb OR
           xvbup-lfsta EQ charc OR
           xvbup-lfgsa EQ charb OR
           xvbup-lfgsa EQ charc.
          screen-input = 0.
        ENDIF.
      ENDIF.

* Ausblenden Liefergruppe und Gruppenlieferdatum auf LFGruppenübersicht
    WHEN '010'.
* Form LIEFERGRUPPE_AUSBLENDEN(SAPFV45V) wird aufgerufen aus
* XVBEP_LESEN_ERSTE_BMENG

* Kunde ausblenden, wenn Beleg ohne Kundenbezug
    WHEN '011'.
      PERFORM tpaer_select USING tvak-pargr
                                 'AG'
                                 space
                                 sy-subrc.
      IF tpaer-papfl IS INITIAL.
        screen-active = 0.
      ENDIF.

* Einteilungsdatum ohne Wunschmenge läßt sich bei Verfp. nicht ändern
* Falls Rundung erlaubt ist, ist die gerundete Menge eingabebereit
    WHEN '012'.
      IF screen-name EQ 'VBEP-CMENG' AND
         ( NOT vbap-kzfme  IS INITIAL OR
           NOT vbak-abdis  IS INITIAL OR
           NOT kuagv-rdoff IS INITIAL OR
           NOT vbap-cuobj  IS INITIAL OR
           tvap-rderl      IS INITIAL OR
           tvap-strum CA config_tvap  OR
           vbap-uepvw EQ natrab_drein OR
           vbap-uepvw EQ natrab_drauf ).
        screen-input = 0.
      ENDIF.
      IF vbep-wmeng EQ 0     AND
         vbep-verfp NE space AND
       ( vbep-bmeng NE 0 OR
         vbep-roms1 NE 0 ).
        screen-input = 0.
      ENDIF.
* Einteilungstyp nicht eingabebereit bei Lieferplänen für Zulieferer
      IF screen-name EQ 'VBEP-ETTYP' AND NOT
         vbak-abdis IS INITIAL.
        screen-input = 0.
      ENDIF.

* Keine Änderung der Menge beim Sammelartikel
      IF screen-name EQ 'VBEP-WMENG' AND
         vbapd-attyp EQ sam_typ.
        screen-input = 0.
      ENDIF.

* Feld bei TextPositionen ausblenden
    WHEN '014'.
      IF vbap-posar CA posar_text AND
         vbap-posnr > 0.
        screen-active = 0.
      ENDIF.

* Feld bei vbkd zu Textpositionen ausblenden (Positionsbild)
    WHEN '015'.
      IF vbap-posar CA posar_text AND
         vbap-posnr > 0.
        screen-active = 0.
      ENDIF.
      IF tvap-kderl EQ space AND vbkd-posnr = posnr_low.
        screen-input = 0.
      ENDIF.

*   Vertragsbeginn und -ende in Positionen mit Einteilungen ausblenden
    WHEN '024'.
      IF tvap-eterl <> space.
        screen-active = 0.
      ENDIF.
* Steuerindikatoren länderspezifisch auf Kopfebene ausblenden
    WHEN '025'.
      da_lfdnr = screen-name+9.
      IF VBAK-LANDTX IS INITIAL.
        PERFORM tstl_select USING t001-land1
                                da_lfdnr
                                space
                                sy-subrc.
      ELSE.
        PERFORM tstl_select USING VBAK-LANDTX   "note 486144
                                da_lfdnr
                                space
                                sy-subrc.
      ENDIF.

      IF sy-subrc > 0 OR
         t001-land1 = space.
        screen-active = 0.
      ENDIF.

* Auf Positionsbildern wird die Zielmenge ausgeblendet,
* wenn Einteilungen erlaubt sind.
    WHEN '026'.
      IF tvap-eterl = charx.
        screen-active = 0.
      ENDIF.

* aktuelle FertigungsfreigabeFz zu, falls es einen Freigabehorizont
* gibt oder falls der Abruf neu ist und kein EDI-Eingang
    WHEN '027'.
      IF NOT vblb-abfde IS INITIAL OR
         ( neuer_abruf_lab EQ chary AND rv45z-docnum IS INITIAL ).
        screen-input = 0.
      ENDIF.

* aktuelle MaterialfreigabeFz zu, falls es einen Freigabehorizont
* gibt oder falls der Abruf neu ist und kein EDI-Eingang
    WHEN '028'.
      IF NOT vblb-abmde IS INITIAL OR
         ( neuer_abruf_lab EQ chary AND rv45z-docnum IS INITIAL ).
        screen-input = 0.
      ENDIF.

* Freigabe-Ab-Datum und Freigabe-Bis-Datum nicht eingabebereit,
* wenn Freigabeperiode gepflegt ist
    WHEN '029'.
      CASE screen-name.
        WHEN 'VBLB-ABFDE'.
          IF NOT vblb-fflauf IS INITIAL AND
             NOT vblb-ffein IS INITIAL.
            screen-input = 0.
          ENDIF.
        WHEN 'VBLB-ABMDE'.
          IF NOT vblb-mflauf IS INITIAL AND
             NOT vblb-mfein IS INITIAL.
            screen-input = 0.
          ENDIF.
      ENDCASE.

*   Aktionsnummern bei Nicht-Vertriebsschienen ausblenden
    WHEN '030'.
      IF NOT tvta-afind = charx.
        screen-active = 0.
      ENDIF.

*   Absicherungsschema nicht eingabebereit, wenn Belegschema initial
*                                           oder Beleg freigegeben
    WHEN '031'.
      IF tvak-babss IS INITIAL.                             "OR
*        VBUK-CMGST EQ CHARD.
        screen-input  = 0.
      ENDIF.

    WHEN '032'.
      IF tvak-vbklt EQ vbklt_lp_ausl_auft.
        IF screen-name EQ '*VBEPD-OLFMNG'.
* offene Liefermenge ausblenden bei Lieferplänen mit
* Auslieferungsauftrag - nur Überschriftsfeld ausblenden, da Loop-Feld
* sowieso über die Feldauswahl ausgeblendet wird, wenn es leer ist
* (in Lieferplänen mit Auslieferungsaufträgen sollte es immer leer sein)
          LOOP AT xvbep WHERE vbeln EQ vbap-vbeln AND
                              posnr EQ vbap-posnr AND
                              updkz NE updkz_delete AND
                              lfrel EQ charx.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            screen-active = 0.
          ENDIF.
        ENDIF.
      ENDIF.

* Wenn es keine Rechnungskorrektur ist, dann VGBEL und VGPOS ausblenden
    WHEN '033'.
      IF tvak-vbklt NE vbklt_rech_korr.
        screen-active = 0.
      ELSE.
* Nur Ausgabe, wenn es sich um eine Rechnungskorrektur handelt
        screen-input  = 0.
      ENDIF.

* bei Auslieferungsauftrag Liefertoleranzen nicht eingabebereit
    WHEN '034'.
      IF tvak-vbklt EQ vbklt_ausl_auft OR
         tvak-vbklt EQ vbklt_lp_ausl_auft.
        screen-input = 0.
      ENDIF.

* Bei Kopieren aus Wertkontrakt Sortimentsbaustein und Produkthierarchie
* nur anzeigen, wenn vorhanden
    WHEN '035'.
      IF vbap-erlre NE con_erlre_wertkontrakt.
        screen-active = 0.
      ELSE.
        ASSIGN (screen-name) TO <feld>.
        IF <feld> IS INITIAL.
          screen-active = 0.
        ENDIF.
      ENDIF.

* Kennzeichen für dahinterstehende Materialien beim Kopieren aus
* Wertkontrakt nur setzen, wenn nötig
    WHEN '036'.
      READ TABLE xvbap WITH KEY vgpos_wk = vbap-posnr
                                updkz    = updkz_new.
      IF sy-subrc <> 0 OR
         vbap-erlre NE con_erlre_wertkontrakt.
        screen-active = 0.
      ENDIF.

* Zahlungskarten, nur, wenn Ratenplanart vorhanden/Berechtigt
    WHEN '037'.                        "CCARD
      DATA: BEGIN OF ccard_use_tab OCCURS 5.
              INCLUDE STRUCTURE ccard_use.
      DATA: END OF ccard_use_tab.
      DATA xfplt_temp LIKE fpltvb.
      DATA ccount TYPE i.

      IF tvak-rpart IS INITIAL OR
         berechtigung_ccard = space.
        screen-active = 0.
      ELSE.
*       IF SCREEN-NAME      EQ 'CCDATA-CCINS' AND
*          NOT CCDATA-CCINS IS INITIAL.
*         SCREEN-INPUT = 0.
*       ENDIF.
        IF NOT vbak-rplnr IS INITIAL.
          READ TABLE xfplt WITH KEY fplnr = vbak-rplnr
                                    uelnr = '         '
                                    ueltr = 0         BINARY SEARCH.
          CHECK sy-subrc = 0.
          MOVE xfplt TO xfplt_temp.
* Keine Eingabe, falls:
* 1. Karten bereits fakturiert
          IF NOT vbak-vbeln IS INITIAL.
            CALL FUNCTION 'SD_CCARD_USAGE_SELECT'
              EXPORTING
                vbeln_i     = vbak-vbeln
                fplnr_i     = xfplt_temp-fplnr
                fpltr_i     = xfplt_temp-fpltr
              TABLES
                ccard_use_t = ccard_use_tab.
            DESCRIBE TABLE ccard_use_tab LINES sy-tabix.
            IF sy-tabix > 0.
              screen-input = 0.
            ENDIF.
          ENDIF.
* 2. Karte bereits authorisiert
          LOOP AT xfplt WHERE uelnr EQ xfplt_temp-fplnr
                          AND ueltr EQ xfplt_temp-fpltr.
            screen-input = 0.
            EXIT.
          ENDLOOP.
* 3. Mehrere Karten vorhanden
          CLEAR ccount.
          LOOP AT xfplt WHERE fplnr = vbak-rplnr
                          AND ueltr IS INITIAL.
            ADD 1 TO ccount.
            IF ccount = 2.
              screen-input = 0.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

* Lieferzeiten: Nur in Angeboten, Kontrakten und Aufträgen
    WHEN '039'.
      IF tvak-vbtyp NA vbtyp_ange AND  "nicht Angebot
         tvak-vbtyp NA vbtyp_kont AND  "nicht Kontrakt
         tvak-vbtyp NA vbtyp_auftr.    "nicht Auftrag
        screen-active = 0.
      ENDIF.

* Zusagedaten: Nur in Vertriebsbelegen mit TVAK-DELCF='X' sichtbar
    WHEN '040'.
      IF tvak-delcf IS INITIAL.
        screen-active = 0.             "nicht sichtbar
      ELSE.
        screen-input = 0.              "nie eingabebereit
      ENDIF.

*041----------------------------------------------------------------
*   Feldern zur Zielmenge
    WHEN '041'.
*        Regel1: Wenn Einteilungen erlaubt sind
*                 und es der Verkaufsbeleg nicht vom Typ Lieferplan ist,
*                oder wenn es eine Wertkontraktposition ist
*                werden die Felder ausgeblendet.
      IF  ( tvap-eterl = 'X'
            AND vbak-vbtyp CN vbtyp_lp )
           OR vbap-erlre EQ con_erlre_wertkontrakt
           OR tvap-pstyv IS INITIAL
           AND vbak-vbtyp CN vbtyp_ohne_einteilung.
* Die Überschrift Substitutionsgrund wurde bisher immer unnötig
* ausgeblendet.
        IF screen-name NE '*VBAP-SUGRD'.
           screen-active = 0.
        ENDIF.
      ENDIF.


*042----------------------------------------------------------------
*   Wie Gruppe 41, nur das für Mengenumrechnungsfelder Regel2 nötig
    WHEN '042'.
*        Regel1: Wenn Einteilungen erlaubt sind
*                 und es der Verkaufsbeleg nicht vom Typ Lieferplan ist,
*                werden die Felder ausgeblendet.
      IF  ( tvap-eterl = 'X'
            AND vbak-vbtyp CN vbtyp_lp )
           OR vbap-erlre EQ con_erlre_wertkontrakt
           OR tvap-pstyv IS INITIAL
           AND vbak-vbtyp CN vbtyp_ohne_einteilung.
        screen-active = 0.
      ENDIF.

*        Regel2: Die Felder (bestätigte Menge) sind bei maschineller
*                Verfügbarkeitsprüfung zu.
      IF vbep-verfp NE space.
        screen-input = 0.
      ENDIF.

*043----------------------------------------------------------------
*   Zu den Feldern gehören Auftragsmenge, 1.Lieferdatum usw.
    WHEN '043'.
*        Regel1: Wenn keine Einteilungen erlaubt sind,
*                werden die Felder ausgeblendet.
      IF tvap-eterl = ' ' AND
         NOT tvap-pstyv IS INITIAL OR
         tvap-pstyv IS INITIAL AND
         vbak-vbtyp CA vbtyp_ohne_einteilung.
        screen-active = 0.
      ENDIF.
      IF vbak-abdis NE space.
        screen-active = 0.
        Case screen-name.
          WHEN 'RV45A-KWMENG'   OR
               'RV45A-VRKME1'   OR
               'VBAP_ZIEME_UMR' OR
               'VBEP-MEINS'.
            screen-active = 1.
            screen-input  = 0.
        ENDCASE.
      ENDIF.

*044----------------------------------------------------------------
*   Wie Gruppe 43, nur für Mengenumrechnungsfelder umvkz, umvkn
    WHEN '044'.
*        Regel1: Wenn keine Einteilungen erlaubt sind,
*                werden die Felder ausgeblendet.
      IF tvap-eterl = ' ' AND
         NOT tvap-pstyv IS INITIAL OR
         tvap-pstyv IS INITIAL AND
         vbak-vbtyp CA vbtyp_ohne_einteilung.
        screen-active = 0.
      ENDIF.
      IF vbak-abdis NE space.
        screen-active = 0.
        Case screen-name.
          WHEN 'VBAP-UMVKN'   OR
               'VBAP-UMVKZ'.
            screen-active = 1.
            screen-input  = 1.
        ENDCASE.
      ENDIF.
      IF vbap-meins = vbap-vrkme.
        screen-input = 0.
      ENDIF.

* Felder ausblenden, wenn es eine Wertkontraktposition ist
    WHEN '046'.
      IF vbap-erlre EQ con_erlre_wertkontrakt.
        screen-active = 0.
      ENDIF.

* bei Auslieferungsauftrag Sequenz-Nummer aktiv, sonst nicht
* bei Auslieferungsauftrag Datum AFZ aktiv, sonst nicht
    WHEN '047'.
      IF tvak-vbklt NE vbklt_ausl_auft AND
         tvak-vbklt NE vbklt_ausl_auft_korr.
        screen-active = 0.
      ENDIF.

*   Feld ausblenden, wenn es keine Wertkontraktposition ist
    WHEN '048'.
      IF vbap-erlre NE con_erlre_wertkontrakt.
        screen-active = 0.
      ENDIF.

*   Feld ausblenden, wenn keine Wertkontraktposition existiert
    WHEN '049'.
      LOOP AT xvbap WHERE updkz NE updkz_delete AND
                          erlre EQ con_erlre_wertkontrakt.
        EXIT.
      ENDLOOP.
      IF sy-subrc > 0.
        screen-active = 0.
      ENDIF.

*   Feld ausblenden, wenn kein CO-Objekt (Pos)
    WHEN '050'.
      IF vbap-objnr IS INITIAL.
        screen-active = 0.
      ENDIF.

*   Feld ausblenden, wenn kein CO-Objekt (Kopf)
    WHEN '051'.
      IF vbak-objnr IS INITIAL.
        screen-active = 0.
      ENDIF.

*   Felder (Buttons) ausblenden, wenn Planabruf
    WHEN '052'.
      IF vblb-abart EQ abart_pab.
        screen-active = 0.
      ENDIF.

*   Felder (Buttons) ausblenden, wenn kein Planabruf
    WHEN '053'.
      IF vblb-abart NE abart_pab.
        screen-active = 0.
      ENDIF.

* Ausblenden, wenn keine Bestellanforderung
    WHEN '054'.
      IF tvep-bsart IS INITIAL.
        screen-active = 0.
      ENDIF.

* Ausblenden, wenn keine Beschaffung
    WHEN '05B'.
      screen-active = 0.
      READ TABLE ivbep1 WITH KEY posnr = vbap-posnr
                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        LOOP AT ivbep1 FROM sy-tabix.
          IF ivbep1-posnr NE vbap-posnr.
            EXIT.
          ENDIF.
          READ TABLE xvbep INDEX ivbep1-tabix.
          IF NOT xvbep-aufnr IS INITIAL OR
             NOT xvbep-plnum IS INITIAL OR
             NOT xvbep-bnfpo IS INITIAL.
            screen-active = 1.
          ENDIF.
        ENDLOOP.
      ENDIF.

* Änderungsstand und Seriennummer wird nur in Einzelaufträgen auf dem
* EInteilungsbild und Positionsdetailbild angezeigt
    WHEN '055'.
      IF NOT tvak-abdis IS INITIAL.
        screen-active = 0.
      ELSE.
        IF NOT tvak-vbtyp CA vbtyp_auft AND
           NOT tvak-vbtyp CA vbtyp_agan.
          screen-active = 0.
        ENDIF.
        IF NOT screen-active EQ 0 AND
           ( screen-name EQ 'VBSN-AESKD' OR
             screen-name EQ 'VBAP-SERNR' ) AND
             t185v-panel EQ 'PEIN'.
* Ausblenden, wenn es keinen aktiven Änderungsstand gibt
          LOOP AT xvbsn WHERE vbeln EQ vbak-vbeln AND
                              posnr EQ vbap-posnr AND
                              aktkz EQ charx AND NOT
                              updkz EQ updkz_delete.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            screen-active = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN '056'.
* Feld Liefersperre auf Übersicht Versand ist nicht eingabebereit, wenn
* es mehr als eine Einteilung gibt
      IF vbap-kbmeng = 0.
        screen-input = 0.
      ELSE.
        LOOP AT xvbep WHERE vbeln EQ vbak-vbeln AND
                            posnr EQ vbap-posnr AND
                            updkz NE updkz_delete.
          da_counter = da_counter + 1.
          IF xvbep-wmeng NE xvbep-bmeng AND
             xvbep-bmeng NE 0.
            da_counter = 2.
          ENDIF.
          IF da_counter GT 1.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF da_counter GT 1.
          screen-input = 0.
        ENDIF.
      ENDIF.
* Feld Liefersteuerung auf Übersicht Versand nicht eingabebereit, falls
* weder Naturalrabatt noch Cross-Selling vorliegt
    WHEN '057'.
      IF vbap-uepvw NE cross_selling AND
         vbap-uepvw NA naturalrabatt.
        screen-input = 0.
      ENDIF.
* Feld Materialbestellnummer nicht sichtbar, falls nicht mit
* Materialbestellnummer gearbeitet werden soll
    WHEN '058'.
      IF screen-name = 'RV45A-MABNR'.
        IF tvak-ermat NE chara.
*         es wird nicht mit Materialbestellnummer gearbeitet
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'TEXT_RV45A_MABNR'.
        IF tvak-ermat NE chara.
*         es wird nicht mit Materialbestellnummer gearbeitet
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'VBAP-MATNR'.
        IF tvak-ermat EQ chara.
*         Material auf nicht eingabebereit setzen
          screen-input = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'VBKD-WMINR'.
        IF tvak-ermat IS INITIAL.
*         es wird nur mit Materialnummer gearbeitet
*         keine Produktkatalogfindung
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'WWMIT-WMITX'.
        IF tvak-ermat IS INITIAL.
*         es wird nur mit Materialnummer gearbeitet
*         keine Produktkatalogfindung
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'RV45A-CCODE_HEAD'.
        IF tvak-ermat IS INITIAL.
*         es wird nur mit Materialnummer gearbeitet
*         keine Produktkatalogfindung
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-name = 'RV45A-CCODE'.
        IF tvak-ermat IS INITIAL.
*         es wird nur mit Materialnummer gearbeitet
*         keine Produktkatalogfindung
          screen-active = 0.
        ENDIF.
      ENDIF.
* Hat die Position Unterpositionen ?
      IF screen-name = 'RV45A-MABNR' or
         screen-name = 'VBAP-MATNR'.
        READ TABLE uvbap WITH KEY uepos = vbap-posnr BINARY SEARCH.
        IF sy-subrc = 0.
          screen-input = 0.
        ENDIF.
      ENDIF.

* da zu 4.6A die VBAP-MATNR im TC nach hinten gerutscht ist, muß sie
* - außer für Batch-Input - ausgeblendet werden (nur Spaltenüberschrift
* ausblenden genügt nicht)
    WHEN '059'.
      IF tvak-ermat NE chara AND sy-binpt EQ space.
*       es wird ohne Materialbestellnummer gearbeitet
        screen-active = 0.
      ENDIF.

* Indizierungsfelder: Preisindizierung ueberhaupt aktiv? (Argent./Bras.)
    WHEN 'NDX'.
      IF T001-INFMT IS INITIAL.     "indexing not used
        SCREEN-INPUT = '0'.
        SCREEN-OUTPUT = '0'.
        SCREEN-INVISIBLE = '1'.
        SCREEN-ACTIVE = 0.
      ELSE.

      CALL FUNCTION 'J_1B_INDX_SCREEN_CONTROL'
        EXPORTING
          i_t001      = t001
          i_aktyp     = t180-trtyp
        IMPORTING
          e_invisible = screen-invisible
          e_active    = screen-active.

      ENDIF.
*   Länderspezifische Feldselektion ('J' + Landeskennzeichen)
    WHEN OTHERS.
      IF screen-group3(1) = 'J'.
        CALL FUNCTION 'J_1B_SD_SCREEN_CONTROL'
          EXPORTING
            i_fieldgroup_3 = screen-group3
            i_bukrs        = t001-bukrs
            i_aktyp        = t180-trtyp
          IMPORTING
            e_invisible    = screen-invisible
            e_active       = screen-active.

        IF NOT vbak-vbtyp = 'E'.            "<<< INSERT Note 509208

        IF SCREEN-NAME = 'VBAP-J_1BTXSDC' AND NOT VBAP-VBELN IS INITIAL.
            SELECT SINGLE * FROM VBUP WHERE VBELN = VBAP-VBELN
                                       AND  POSNR = VBAP-POSNR.
            IF SY-SUBRC = 0.
              IF ( VBUP-GBSTA = 'A' ) OR ( VBUP-GBSTA IS INITIAL ).
                SCREEN-INPUT     = 1.
              ELSE.
                SCREEN-INPUT     = 0.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_12 SPOTS ES_SAPMV45A STATIC.
      ENDIF.

  ENDCASE.
ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_11 SPOTS ES_SAPMV45A STATIC.

* Konditionsschlüssel in der zweizeiligen Erfassung nicht änderbar
  IF screen-name = 'KOMV-KSCHL'.
    screen-input = 0.
  ENDIF.

ENDFORM.                    "feldauswahl_sonderregeln