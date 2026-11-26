*---------------------------------------------------------------------*
*       FORM CUA_SETZEN                                               *
*---------------------------------------------------------------------*
*       CUA-Parameter an CUA-Routine uebergeben                       *
*       Aufbau:                                                       *
*              Stelle 1-4 : fest aus Tabelle 185V                     *
*              Stelle 5-8 : variabel                                  *
*---------------------------------------------------------------------*
FORM cua_setzen.

  LOCAL: xvbap.
  DATA: da_dfies_tab     LIKE dfies,
        da_tbnam         LIKE dfies-tabname,
        da_fdnam         LIKE dfies-fieldname,
        da_feldbeschr    LIKE dfies-scrtext_l,
        da_anzahl        TYPE i,
        da_severity      LIKE sy-msgty,
        da_subrc         LIKE sy-subrc,
        da_subrc_auth    LIKE sy-subrc,
        da_subrc_pefz LIKE sy-subrc,
        da_subrc_xvbuv LIKE sy-subrc VALUE 4,
        da_vbmue_eintrag.
  DATA: str_len(4) TYPE n VALUE '1',
        da_textfolge(2) VALUE 'DN'.    "für den Titelaufbau
  DATA: da_call_rfc   TYPE char1.
  DATA: i_dnact LIKE rdgdnact.
  DATA: tabname(30) TYPE c VALUE 'NDISYSTEMS'.
  DATA: BEGIN OF wa_ndisyst,
          logsys(10) TYPE c,
          type(10)   TYPE c,
          ndirel(4)  TYPE c,
        END OF wa_ndisyst.
  DATA: lv_display_text_for_archive   TYPE boole.
  DATA: lv_contract_archive TYPE boole.
  DATA: lv_sched_agr_archive TYPE boole.

  STATICS fcode_alt LIKE t185f-fcode.
  FIELD-SYMBOLS: <tfs>.

  DATA: l_sd_sales_basic_exit TYPE REF TO if_ex_badi_sd_sales_basic,
            active TYPE xfeld.

  PERFORM dummy(sapfv45l).

* Buttonleiste in Übersichtsbilder bestimmen
  PERFORM cua_setzen_buttons.

* Cursorpositionierung während Abarbeitung des Unvollständigkeits-
* protokolls (für 4.0-Bilder muß zusätzlich jeweils ein Aufruf des
* Moduls INCOMPLOG_SET_CURSOR direkt aus den Tabstrip-Karten-Subscreens
* erfolgen)
  IF fehler = 'X'.
    IF fcode NE fcode_gleiche_seite.
      fcode_alt = fcode.
    ENDIF.
    IF fcode_alt = fcode_kopf_texte.
      t185v-status = 'FSBL'.
    ELSE.
      t185v-status = 'FS  '.
    ENDIF.
* Status Unvollständigkeit Partner-Subscreen setzen
    IF fehler_kpar_sub EQ charx.
      t185v-status = status_fs_kpar_sub.
    ELSEIF fehler_ppar_sub EQ charx.
      t185v-status = status_fs_ppar_sub.
    ENDIF.

    SET CURSOR FIELD fehlerfeld.       " 3.1 und früher

    IF fehlerfeld CA '-'.
      da_tbnam  = fehlerfeld(sy-fdpos).
      sy-fdpos  = sy-fdpos + 1.
      da_fdnam  = fehlerfeld+sy-fdpos.
      CALL FUNCTION 'RV_FIELD_READ'
        EXPORTING
          fdr_field       = da_fdnam
          fdr_langu       = sy-langu
          fdr_table       = da_tbnam
        IMPORTING
          fdr_dfies       = da_dfies_tab
        EXCEPTIONS
          field_not_found = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        CLEAR da_dfies_tab-scrtext_l.
      ENDIF.
    ENDIF.

    da_feldbeschr = fehlerfeld.
    IF da_dfies_tab-scrtext_l CN ' '.
      da_feldbeschr = da_dfies_tab-scrtext_l.
    ENDIF.

    IF NOT fehlerexit IS INITIAL.
      MESSAGE s019(vu) WITH da_feldbeschr.
    ENDIF.

  ENDIF.

* GUI-Redesign 4.0: Vor Ermittlung des neuen Ortes den alten
* Ort sichern, um sowohl Bildgruppenwechsel als auch Panelwechsel
* erkennen zu können
   *taxi_screen_group = taxi_screen_group.
   *taxi_panel        = taxi_panel.

  CALL FUNCTION 'LOCATION_EXTRACT'
       IMPORTING
            bild       = t185v-panel
*           GUI-Redesign 4.0: aktuelle Bildgruppe und Funktionscode
*           ermitteln zur Weiterverarbeitung in der FORM
*           taxi_initialize_carrierscreen
            bildgruppe = taxi_screen_group
            funktion   = taxi_fcode
*           Das Arbeitsgebiet wird benötigt, um cua_modifizieren für
*           auf Tabstrip-Karten umgestellte Bilder zu unterbinden.
            programm   = t185v-agidv.

  taxi_panel = t185v-panel.

  CHECK t185v-status NE space.

* GUI-Redesign 4.0: Tabelle der ausgeblendeten Reiter löschen
  REFRESH taxi_inactive_fcodes.

* loop at cua_exclude where function(2) = 'S\'.
*   perform taxi_deactivate_tab using cua_exclude-function.
* endloop.

* Alle im letzten Aufruf von cua_setzen deaktivierten Fcodes
* wieder aktivieren.
* Die in transaktion_init deaktivierten Fcodes sind hiervon nicht
* betroffen. Die Einträge stehen am Anfang von cua_exclude, die
* Unterscheidung fixer und variabler Einträge erfolgt anhand der
* globalen Variablen cua_excl_fix_tabix (Index des ersten variablen
* Eintrags).
  IF cua_excl_fix_tabix NE 0.
    DELETE cua_exclude FROM cua_excl_fix_tabix.
  ENDIF.

* Fcode für aktuellen Panel inaktiv setzen
  cua_exclude-function = t185v-panel.
  APPEND cua_exclude.

* Unerwünschte Fcodes bei CALL DIALOG inaktiv setzen
  IF NOT call_dialog IS INITIAL.
    PERFORM exclude_function_dialog.
  ENDIF.

* deactivate document flow for archived documents
  IF data_read_from_archive = 'X'.
    cua_exclude-function = 'IFLU'.
    APPEND cua_exclude.

* deactivate change documents
    cua_exclude-function = 'IAEN'.
    APPEND cua_exclude.

* deactivate messages for archived documents
    cua_exclude-function = 'KDOK'.
    APPEND cua_exclude.
    cua_exclude-function = 'DDOK'.
    APPEND cua_exclude.
    cua_exclude-function = 'PDOK'.
    APPEND cua_exclude.
    cua_exclude-function = 'DDOK_I'.
    APPEND cua_exclude.

* deactivate create/change mode for archived documents
    cua_exclude-function = 'ANLE'.
    APPEND cua_exclude.
    cua_exclude-function = 'AEND'.
    APPEND cua_exclude.
    cua_exclude-function = 'FAU1'.
    APPEND cua_exclude.

* deactivate delivery/invoicing for archived documents
    cua_exclude-function = 'FLI1'.
    APPEND cua_exclude.
    cua_exclude-function = 'FFA1'.
    APPEND cua_exclude.

* deactivate incompleteness log for archived documents
    cua_exclude-function = 'FEAZ'.
    APPEND cua_exclude.

* deactivate status overview for archived documents
    cua_exclude-function = 'STAT'.
    APPEND cua_exclude.

* deactivate costing for archived documents
    cua_exclude-function = 'PKAL'.
    APPEND cua_exclude.

    lv_display_text_for_archive = abap_false.
    IF cl_ops_switch_check=>sd_sfws_sc3( ) EQ abap_true.
      lv_display_text_for_archive = abap_true.
    ENDIF.

    IF lv_display_text_for_archive EQ abap_false.
* deactivate tab-strip for texts

      cua_exclude-function = 'KTEX_SUB'.
      APPEND cua_exclude.
      cua_exclude-function = 'PTEX_SUB'.
      APPEND cua_exclude.
    ENDIF.

*   Check whether to display archived contracts via VA43/Sales UI
    IF ( vbak-vbtyp                        EQ vbtyp_kont  OR        "contracts
         vbak-vbtyp                        EQ vbtyp_gruko    ) AND  "master contracts
       cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
      lv_contract_archive = abap_true.
    ENDIF.

*   Check whether to display archived scheduling agreements via VA33
    IF vbak-vbtyp                          CA vbtyp_lp  AND
       cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
      lv_sched_agr_archive = abap_true.
    ENDIF.

    IF lv_contract_archive  EQ abap_true OR
       lv_sched_agr_archive EQ abap_true.
* Transportation Info -> Itinerary: Graph
      cua_exclude-function = fcode_transportinfo_weg.
      APPEND cua_exclude.
* Transportation Info -> Transportation network: Graphic
      cua_exclude-function = fcode_transportinfo_netz.
      APPEND cua_exclude.
* Transportation Info -> Itinerary: List
      cua_exclude-function = fcode_transportinfo_weg_liste.
      APPEND cua_exclude.
* Transportation Info -> Transportation network: List
      cua_exclude-function = fcode_transportinfo_netz_liste.
      APPEND cua_exclude.
* Transportation Info -> Delivery Tracking
      cua_exclude-function = fcode_tracking.
      APPEND cua_exclude.
    ENDIF.

  ENDIF.
* Unerwünschte Fcodes bei RFC inaktiv setzen
  GET PARAMETER ID 'CALL_RFC' FIELD  da_call_rfc.
  IF NOT da_call_rfc IS INITIAL.
    PERFORM exclude_function_rfc.
  ENDIF.

* Ist einer Verkaufsbelegart kein Textschema zugeordnet,
* so wird der Reiter für die Texte ausgeblendet.
  IF tvak-txtgr IS INITIAL AND NOT vbak-auart IS INITIAL.
    cua_exclude-function = fcode_kopf_texte_neu.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING fcode_kopf_texte_neu.
  ENDIF.

* Ist einem Positionstyp kein Textschema zugeordnet,
* so wird der Reiter für die Texte ausgeblendet.
  IF tvap-txtgr IS INITIAL AND
    taxi_screen_group CS 'P'.
    cua_exclude-function = fcode_position_texte_neu.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING fcode_position_texte_neu.
  ENDIF.

* Im Anzeigemodus die Funktionen GVFP und BVFS (der BVFP macht)
* deaktivieren
  IF t180-trtyp = chara.
    cua_exclude-function = fcode_gruppen_verfuegbarkeit.
    APPEND cua_exclude.
    cua_exclude-function = fcode_beleg_verfuegbarkeit_sw.
    APPEND cua_exclude.
  ENDIF.

* Den nicht aktuellen der beiden Reiter 'Verkauf' ausblenden
  PERFORM text_control_tabstrip_umsetzen.
ENHANCEMENT-POINT CUA_SETZEN_14 SPOTS ES_SAPMV45A STATIC .

ENHANCEMENT-POINT CUA_SETZEN_10 SPOTS ES_SAPMV45A.
* Auftraggeber anlegen

  CALL FUNCTION 'SD_FIELD_INPUT_CHECK'
    EXPORTING
      tabname        = 'KUAGV'
      fieldname      = 'KUNNR'
    IMPORTING
      display_status = da_subrc.
  IF da_subrc NE 0 OR t180-trtyp = chara.
    cua_exclude-function = fcode_auftraggeber_anlegen.
    APPEND cua_exclude.
  ENDIF.

* Fcode für Einteilungen eventuell deaktivieren
  IF tvak-vbtyp CA vbtyp_ohne_eint_mit_g.
    cua_exclude-function = fcode_einteilung.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_einteilung.
  ENDIF.

* Reiter für Unvollständigkeit Auslieferungsauftrag ausblenden
  IF NOT ( vbak-vbklt EQ vbklt_ausl_auft AND
           taxi_panel EQ 'UMAI' ).
    cua_exclude-function = fcode_unvollst_ausl_auft.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_unvollst_ausl_auft.
  ENDIF.

* Reiter Positionsdetailbild Auslieferungsauftrag ausblenden
  IF vbak-vbklt EQ vbklt_ausl_auft.
    cua_exclude-function = 'UER3'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UER3'.
  ENDIF.

* Fcode für Fakturierungsplan eventuell deaktivieren
  IF tvak-fpart IS INITIAL.
    cua_exclude-function = fcode_fplan_kopf.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_fplan_kopf.
  ENDIF.
* Fcode für Merkmalsanzeige ausblenden
  PERFORM vbmue_hat_eintrag CHANGING da_vbmue_eintrag.
  IF da_vbmue_eintrag EQ charn.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_uebersicht_konfiguration.
  ENDIF.
* Fcode für Fakturierungsplan (nur Reiter ausblenden nicht Menü)
  IF tvap-fpart IS INITIAL.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_fplan_pos.
  ENDIF.
ENHANCEMENT-POINT CUA_SETZEN_05 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT CUA_SETZEN_03 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT CUA_SETZEN_06 SPOTS ES_SAPMV45A.

* Fcode für Ratenplan (Zahlkungskarten) eventuell deaktivieren
  IF tvak-rpart IS INITIAL OR
    ( t180-trtyp EQ chara AND vbak-rplnr IS INITIAL ).
    cua_exclude-function = fcode_rplan.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_rplan.
  ENDIF.

* externe Kreditversicherung
  IF tvak-babss IS INITIAL.
    cua_exclude-function = fcode_wkv.
    APPEND cua_exclude.
  ELSE.
*   Ermitteln, ob Absicherungstyp WKV aktiv
    CALL FUNCTION 'SD_ORDER_RISK_CHECK'
      EXPORTING
        i_abstp             = '1'"'1' oder '2'
        i_abssc             = vbkd-abssc
      EXCEPTIONS
        security_not_active = 3
        OTHERS              = 4.
    IF sy-subrc EQ 3.
      cua_exclude-function = fcode_wkv.
      APPEND cua_exclude.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT CUA_SETZEN_11 SPOTS ES_SAPMV45A.
* bei fehlender Transaktionscodeberechtigung Listen + Kundenstammblatt
* inaktiv schalten
  PERFORM berechtigung_pruefen USING space
                                     space
                                     charx
                                CHANGING da_subrc_auth.
  IF authority_liste_anfrage IS INITIAL.
    cua_exclude-function = fcode_liste_anfrage.
    APPEND cua_exclude.
  ENDIF.
  IF authority_liste_angebot IS INITIAL.
    cua_exclude-function = fcode_liste_angebot.
    APPEND cua_exclude.
  ENDIF.
  IF authority_liste_auftrag IS INITIAL.
    cua_exclude-function = fcode_liste_auftrag.
    APPEND cua_exclude.
  ENDIF.
  IF authority_liste_kontrakt IS INITIAL.
    cua_exclude-function = fcode_liste_kontrakt.
    APPEND cua_exclude.
  ENDIF.
  IF authority_liste_lieferplan IS INITIAL.
    cua_exclude-function = fcode_liste_lieferplan.
    APPEND cua_exclude.
  ENDIF.
  IF authority_liste_posvorschlag IS INITIAL.
    cua_exclude-function = fcode_liste_posvorschlag.
    APPEND cua_exclude.
  ENDIF.
  IF authority_kundenstammblatt IS INITIAL.
    cua_exclude-function = fcode_kundenstammblatt.
    APPEND cua_exclude.
  ENDIF.

*** FCode-Deaktivierung für Positionsbilder
  IF sy-dyngr = 'POSI' OR
     taxi_screen_group CS 'P'.
*   Auf Positionsebene keine Verfügbarkeitsprüfung für den Gesamtbeleg
    cua_exclude-function = fcode_beleg_verfuegbarkeit.
    APPEND cua_exclude.
    PERFORM tvap_select USING xvbap-pstyv
                              space
                              sy-subrc.
*   Einteilungsfcode/-Reiter, nur wenn Einteilungen erlaubt
    IF tvap-eterl = space AND
       sy-subrc = 0 AND
       xvbap-pstyv NE space.
      cua_exclude-function = fcode_einteilung.
      APPEND cua_exclude.
*     GUI-Redesign 4.0: entsprechenden Reiter ausblenden
      PERFORM taxi_deactivate_tab USING fcode_einteilung.
    ENDIF.
ENHANCEMENT-POINT CUA_SETZEN_01 SPOTS ES_SAPMV45A.
  ENDIF.
*** Ende FCode-Deaktivierung für Positionsbilder

* NO ATP CHECK ON DYNPRO 4422
  IF t185v-panel = 'POST'.           " display item structure
    cua_exclude-function = 'PORE'.
    APPEND cua_exclude.
  ENDIF.

* alten Reiter generell ausblenden
  cua_exclude-function = fcode_kpar.
  APPEND cua_exclude.
  PERFORM taxi_deactivate_tab USING fcode_kpar.
  cua_exclude-function = fcode_ppar.
  APPEND cua_exclude.
  PERFORM taxi_deactivate_tab USING fcode_ppar.

  PERFORM tpaer_select USING tvak-pargr
                             'AG'
                             space
                             sy-subrc.
  IF tpaer-papfl IS INITIAL.
    cua_exclude-function = fcode_kpar_sub.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_kpar_sub.
    cua_exclude-function = fcode_ppar_sub.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_ppar_sub.
  ENDIF.

*********************************************************************
* Lieferpläne mit Abrufen
*********************************************************************
  IF NOT tvak-abdis IS INITIAL.        " Zulieferung
*   Bei Lieferplänen mit Abrufen keine Taste 'Nächstes Bild', da dies
*   für Probleme sorgen würde (z.B. Springen auf normales Einteilungs-
*   bild vom Kontierungsbild aus'.
*   Abfrage auf Bild (früher auf sy-dynnr) - AKK070897
    IF t185v-panel = 'PFEI' OR         "Liefer-/Feinabruf
       t185v-panel = 'PAED' OR         "Änderungsstand Datum
       t185v-panel = 'PAEF' OR         "Änderungsstand FZ
       t185v-panel = 'PLEI' OR         "Lieferabrufe
       t185v-panel = 'PPEI'.           "Planabrufe
      cua_exclude-function = fcode_naechstes_bild.
      APPEND cua_exclude.
      cua_exclude-function = fcode_naechste_position.
      APPEND cua_exclude.
      cua_exclude-function = fcode_vorige_position.
      APPEND cua_exclude.
      cua_exclude-function = fcode_erste_position.
      APPEND cua_exclude.
      cua_exclude-function = fcode_letzte_position.
      APPEND cua_exclude.
      IF NOT vbap-abgru IS INITIAL.
        cua_exclude-function = fcode_abruf_ohne_vor.
        APPEND cua_exclude.
        cua_exclude-function = fcode_abruf_mit_vor.
        APPEND cua_exclude.
        cua_exclude-function = fcode_abruf_generieren.
        APPEND cua_exclude.
        cua_exclude-function = 'LSKO'.
        APPEND cua_exclude.
      ENDIF.
    ENDIF.

    IF t185v-panel = 'PKNB' OR
       t185v-panel = 'PKNT'.           "Kontierung
      cua_exclude-function = fcode_naechstes_bild.
      APPEND cua_exclude.
    ENDIF.

    cua_exclude-function = fcode_einteilung.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_einteilung.
    cua_exclude-function = 'ULFG'.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING 'ULFG'.
    IF sy-dyngr EQ 'POSI'.
* Keine Planabrufpflege ohne Planabrufvorschrift
      IF vbap-plavo IS INITIAL.
        cua_exclude-function = fcode_planabruf.
        APPEND cua_exclude.
        PERFORM taxi_deactivate_tab USING fcode_planabruf.
      ENDIF.
* Kein neuer Abruf (außer Planabruf) beim Hinzufügen
      IF t180-trtyp EQ charh AND vblb-abart NE abart_pab.
        cua_exclude-function = fcode_abruf_ohne_vor.
        APPEND cua_exclude.
      ENDIF.
    ELSE.
* Kurzanzeige nur auf Positionsbildern, da nur dort VBLB gefüllt ist
      cua_exclude-function = fcode_kurzanzeige.
      APPEND cua_exclude.
    ENDIF.
* Kein Feinabruf bei ABDIS 'E' (Kein Feinabruf) oder ' ' (1. Bild VA31)
    IF vbak-abdis EQ chare OR
       vbak-abdis IS INITIAL.
      cua_exclude-function = fcode_feinabruf.
      APPEND cua_exclude.
*     GUI-Redesign 4.0: entsprechenden Reiter ausblenden
      PERFORM taxi_deactivate_tab USING fcode_feinabruf.
    ENDIF.
* bei MAIS-Lieferplan nur Folgefunktion 'Auftrag' möglich
    IF tvak-vbtyp EQ vbtyp_lp_norm AND
       tvak-vbklt EQ vbklt_lp_ausl_auft.
      cua_exclude-function = fcode_folgef_lief1.
      APPEND cua_exclude.
      cua_exclude-function = fcode_folgef_fak1.
      APPEND cua_exclude.
* kein Verpackungsvorschlag
*     CUA_EXCLUDE-FUNCTION = FCODE_VERPACKEN.
*     APPEND CUA_EXCLUDE.
    ENDIF.

* keine Änderungsstände
    IF t180-trtyp EQ chara.            " Anzeigemodus
*       Gibt es Änderungsständen?
*       - es gibt mindestens eine Position mit Änderungsständen
*         Menü Springen -> Position -> Änderungsstände anbieten
*       - Reiter in der Position nur, wenn zur Psition Änderungsstände
*         vorhanden
*       Are there any engineering change statuses?
*       - There is at least one item with eng.change statuses
*         Menu Goto -> Item -> Eng.change statuses has to be available
*       - Tapstrip only for items with eng.change statuses
      IF xvbsn[] IS INITIAL.
*         Es sind keine Änderungsstände vorhanden.
*         There arn't any eng.change statuses
        cua_exclude-function = fcode_aenderung.
        APPEND cua_exclude.
      ENDIF.
*         GUI-Redesign 4.0: entsprechenden Reiter ausblenden
*         GUI-Redesign 4.0: grey out tapstrip
      LOOP AT xvbsn WHERE posnr EQ vbap-posnr
                    AND   updkz NE updkz_delete.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
        PERFORM taxi_deactivate_tab USING fcode_aenderung.
      ENDIF.
    ENDIF.                             " Ende Änderungsstände

*   GUI-Redesign 4.0: Bei Zulieferung in Positionsdetailbildern
*                     Reiter 'Struktur' ausblenden
    PERFORM taxi_deactivate_tab USING 'POST'. "Struktur

* Fcode Vorschlag Eingangsfortschrittszahl
    IF t185v-panel = 'PLEI' OR
       t185v-panel = 'PFEI' OR
       t185v-panel = 'PPEI'.
      IF t185v-panel = 'PPEI' OR
         t180-trtyp EQ chara.
        cua_exclude-function = fcode_vorschlag_efz.
        APPEND cua_exclude.
      ELSE.
        PERFORM cua_setzen_pefz(sapfv45l) CHANGING da_subrc_pefz.
        IF da_subrc_pefz NE 0.
          cua_exclude-function = fcode_vorschlag_efz.
          APPEND cua_exclude.
        ENDIF.
      ENDIF.
    ENDIF.

*   CMDS - Collaborative Management of Delivery Schedules
    IF NOT item_cmds_active IS INITIAL.
      cua_exclude-function = fcode_vorschlag_efz.
      APPEND cua_exclude.
      cua_exclude-function = fcode_abruf_ohne_vor.
      APPEND cua_exclude.
      cua_exclude-function = fcode_abruf_mit_vor.
      APPEND cua_exclude.
      cua_exclude-function = fcode_idoc_abruf.
      APPEND cua_exclude.
      cua_exclude-function = fcode_abruf_generieren.
      APPEND cua_exclude.
      PERFORM xvblb_lesen(sapfv45l) USING vbak-vbeln
                                          vbap-posnr
                                          abart_pab.
      IF xvblb-posnr IS INITIAL.
        PERFORM taxi_deactivate_tab USING fcode_planabruf.
        cua_exclude-function = fcode_planabruf.
        APPEND cua_exclude.
      ENDIF.
      cua_exclude-function = fcode_xvbep_anlegen.
      APPEND cua_exclude.
      cua_exclude-function = fcode_xvbep_loeschen.
      APPEND cua_exclude.
      cua_exclude-function = fcode_xvbep_loeschen_einzeln.
      APPEND cua_exclude.
      IF t180-trtyp <> 'A'.
        cua_exclude-function = 'IVFP'.
        APPEND cua_exclude.
      ENDIF.
    ENDIF.
*****************************************************************
* Lieferpläne mit Abrufen ENDE
*****************************************************************

  ELSE.                                " keine Zulieferung
* bei MAIS-Auftrag nur Folgefunktion 'Lieferung' möglich
    IF tvak-abdis IS INITIAL AND
       tvak-vbklt EQ vbklt_ausl_auft.
      cua_exclude-function = fcode_folgef_auf1.
      APPEND cua_exclude.
      cua_exclude-function = fcode_folgef_fak1.
      APPEND cua_exclude.
      IF t180-trtyp NE charh.
* Position Löschen nicht möglich (außer beim Anlegen)
        cua_exclude-function = fcode_xlips_loeschen.
        APPEND cua_exclude.
        cua_exclude-function = fcode_xlips_loeschen_einzeln.
        APPEND cua_exclude.
      ENDIF.
    ENDIF.
    cua_exclude-function = fcode_lieferabruf.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_lieferabruf.
    cua_exclude-function = fcode_feinabruf.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_feinabruf.
    cua_exclude-function = fcode_planabruf.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_planabruf.
    cua_exclude-function = fcode_aenderung.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_aenderung.
    cua_exclude-function = fcode_kurzanzeige.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_kurzanzeige.
    IF tvak-vbtyp CN vbtyp_auft.
      cua_exclude-function = 'VERP'.
      APPEND cua_exclude.
    ENDIF.
*   GUI-Redesign 4.0: Wenn keine Zulieferung, bei Positionsdetailbildern
*                     Reiter 'Abrufsteuerung' ausblenden
    PERFORM taxi_deactivate_tab USING 'PAST'. "Abrufsteuerung
  ENDIF.

* Wenn noch keine Lieferung vorhanden Transportinfo ausschalten
  IF vbuk-lfstk <> charb AND vbuk-lfstk <> charc.
    cua_exclude-function = fcode_transportinfo_netz.
    APPEND cua_exclude.
    cua_exclude-function = fcode_transportinfo_weg.
    APPEND cua_exclude.
    cua_exclude-function = fcode_transportinfo_netz_liste.
    APPEND cua_exclude.
    cua_exclude-function = fcode_transportinfo_weg_liste.
    APPEND cua_exclude.
    cua_exclude-function = fcode_tracking.
    APPEND cua_exclude.
  ENDIF.

* Vertragsdaten ********************************************************
  IF tvak-vterl IS INITIAL.
    cua_exclude-function = 'PVER'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'PVER'.
    cua_exclude-function = 'KVER'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KVER'.
    cua_exclude-function = 'KKSE'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KKSE'.
    cua_exclude-function = 'PKSE'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'PKSE'.
  ENDIF.
* Ende Vertragsdaten ***************************************************

* Reparaturabwicklung **************************************************
  IF tvak-vbklt NA 'FG' OR
     tvak-vbtyp NA vbtyp_auftr.
*   Reparatur nur im Reparaturauftrag erlaubt (Und nur auf HP)
    cua_exclude-function = fcode_reparatur.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING fcode_reparatur.
  ENDIF.
  IF tvak-vbklt CA 'FG'.
*     Struktur nicht erlaubt
    cua_exclude-function = fcode_umfang_struktur.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING fcode_umfang_struktur.
*     Reparaturreiter nur für die Reparaturanforderung aktiv
    IF sy-dyngr = 'POSI' AND
       tvap-scheme_rma IS INITIAL.
      cua_exclude-function = fcode_reparatur.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING fcode_reparatur.
    ENDIF.
  ENDIF.
* Ende Reparaturabwicklung *********************************************

* Keine Servicedaten pflegbar, wenn Bedarfsklasse dies nicht erlaubt
  IF t459k-mntga NE mofauf.
    cua_exclude-function = 'EID6'.
    APPEND cua_exclude.
  ELSE.
    PERFORM t003o_select(sapmv45a) USING t459k-auart
                                         charx
                                         sy-subrc.
    IF t003o-autyp NE service.
      cua_exclude-function = 'EID6'.
      APPEND cua_exclude.
    ENDIF.
  ENDIF.

* Korrekturlieferungen (Zulieferer)
  IF   tvak-korli IS INITIAL OR
     ( NOT tvak-abdis IS INITIAL AND   "MAIS-Lieferplan
       tvak-vbklt EQ vbklt_lp_ausl_auft ).
    cua_exclude-function = 'LSKO'.
    APPEND cua_exclude.
  ENDIF.

* FCODE für Objektstatus setzen
  IF vbak-objnr EQ space.
    cua_exclude-function = fcode_objektstatus_kopf.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_objektstatus_kopf.
  ENDIF.
  IF vbap-objnr EQ space.
    cua_exclude-function = fcode_objektstatus_position.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_objektstatus_position.
  ENDIF.

* Kostenbericht nicht im Anlegenmodus aktivieren
  IF t180-trtyp = charh.
    cua_exclude-function = 'KOST'.
    APPEND cua_exclude.
  ENDIF.

* Alle Menüeinträge ausblenden, die nicht vertragsrelevant sind
* Übersicht Beschaffung bleibt aktiv, da die Bedarfsart die Kontierung
* bestimmt
  IF tvak-vbtyp CA vbtyp_ohne_eint_mit_g.
    cua_exclude-function = 'UVER'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UVER'.
    cua_exclude-function = 'ULFG'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'ULFG'.
  ENDIF.
* Bei Rechnungskorrektur ist nur 'Anlegen mit Bezug auf Faktura'
* erlaubt
  IF tvak-vbklt EQ vbklt_rech_korr.
    cua_exclude-function = fcode_kopieren_anfrage.
    APPEND cua_exclude.
    cua_exclude-function = fcode_kopieren_angebot.
    APPEND cua_exclude.
    cua_exclude-function = fcode_kopieren_auftrag.
    APPEND cua_exclude.
    cua_exclude-function = fcode_kopieren_kontrakt.
    APPEND cua_exclude.
    cua_exclude-function = fcode_kopieren_lieferplan.
    APPEND cua_exclude.
  ENDIF.
* Wenn es keine Rechnungskorrektur ist, dann Button
* 'unveränd.Pos.löschen' nicht erlaubt.
  IF tvak-vbklt NE vbklt_rech_korr.
    cua_exclude-function = fcode_prkl.
    APPEND cua_exclude.
  ENDIF.
* Bei Produktselektion/NatRab ist das Löschen von Einteilungen
* nicht erlaubt
  IF NOT vbap-uepvw IS INITIAL.
    cua_exclude-function = 'EILO'.
    APPEND cua_exclude.
    cua_exclude-function = 'EILE'.
    APPEND cua_exclude.
  ENDIF.

* Gruppenkontrakt ******************************************************
  IF tvak-vbtyp EQ vbtyp_gruko.
*   Auf Übersichtebene alles bis auf Reiter Übersicht ausblenden
    cua_exclude-function = 'POS+'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'POS+'.

    cua_exclude-function = 'UER2'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UER2'.

    cua_exclude-function = 'UER3'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UER3'.

    cua_exclude-function = 'UBST'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UBST'.

    cua_exclude-function = 'UBSF'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UBSF'.

    cua_exclude-function = 'UVER'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UVER'.

    cua_exclude-function = 'UERL'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UERL'.

    cua_exclude-function = 'UECO'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UECO'.

*   Auf Kopfebene 'Konditionen' 'Kontierung' 'Zahlkarte'ausblenden
    cua_exclude-function = 'KKON'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KKON'.

    cua_exclude-function = 'KKO1'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KKO1'.

    cua_exclude-function = 'KKNT'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KKNT'.

    cua_exclude-function = 'KRPL'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KRPL'.

    cua_exclude-function = 'KKSE'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'KKSE'.

*   Im Anlegemodus kein verzweigen in Unterkontrakt
    IF t180-trtyp EQ charh.
      cua_exclude-function = 'GRKO'.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING 'GRKO'.
    ENDIF.
  ENDIF.
* Ende Gruppenkontrakt *************************************************

* Wertkontrakt mit (WK) oder ohne (WK1) Sortiment **********************
  IF tvak-kopgr = 'WK' OR
     tvak-kopgr = 'WK1'.
*   Auf Übersichtebene Beschaffungs- und Versandbild ausblenden
    cua_exclude-function = 'UBSF'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UBSF'.

    cua_exclude-function = 'UVER'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'UVER'.

*   Auf Positionsebene Einteilungsbild ausblenden
    IF sy-dyngr = 'POSI'.
      cua_exclude-function = 'PEIN'.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING 'PEIN'.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT CUA_SETZEN_02 SPOTS ES_SAPMV45A.
* Sortimentsbausteinanzeige nur im Wertkontrakt mit Sortimentsbaustein
  IF tvak-kopgr NE 'WK'.
    cua_exclude-function = 'SHSB'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'SHSB'.
  ENDIF.
* Fcode für Fakturierungsplan auf Posebene eventuell deaktivieren
  IF sy-dyngr = 'POSI'.
    IF tvap-fpart IS INITIAL.
      cua_exclude-function = fcode_fplan_pos.
      APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
      PERFORM taxi_deactivate_tab USING fcode_fplan_pos.
    ENDIF.
  ENDIF.
* Fcode für Cross-Selling ausblenden
  IF tcsp-crspl IS INITIAL.
    cua_exclude-function = fcode_cross_selling.
    APPEND cua_exclude.
  ENDIF.

* Protokoll für Listung/Ausschluß
  CASE protokoll_ma.
    WHEN 'X'.
* Trace eingeschaltet
      cua_exclude-function = 'MFON'.
      APPEND cua_exclude.
    WHEN ' '.
* Trace ausgeschaltet
      cua_exclude-function = 'MFOF'.
      APPEND cua_exclude.
  ENDCASE.
* Protokoll für Materialfindung
  CASE protokoll_la.
    WHEN 'X'.
* Trace eingeschaltet
      cua_exclude-function = 'LAON'.
      APPEND cua_exclude.
    WHEN ' '.
* Trace ausgeschaltet
      cua_exclude-function = 'LAOF'.
      APPEND cua_exclude.
  ENDCASE.
* Naturalrabatt
  CASE protokoll_na.
    WHEN 'X'.
* Trace eingeschaltet
      cua_exclude-function = 'NAON'.
      APPEND cua_exclude.
    WHEN ' '.
* Trace ausgeschaltet
      cua_exclude-function = 'NAOF'.
      APPEND cua_exclude.
  ENDCASE.
* Cross-Selling
  CASE protokoll_cs.
    WHEN 'X'.
* Trace eingeschaltet
      cua_exclude-function = 'CSON'.
      APPEND cua_exclude.
    WHEN ' '.
* Trace ausgeschaltet
      cua_exclude-function = 'CSOF'.
      APPEND cua_exclude.
  ENDCASE.

* Gesetzliche Kontrolle
* Neuermittlung nur im Aendern-Modus
  IF t180-trtyp NE charv.
    cua_exclude-function = 'PEXN'.
    APPEND cua_exclude.
  ENDIF.
* Lieferplaene: keine Gesetzliche Kontrolle moeglich
  IF ( tvak-vbtyp CO vbtyp_lp ) .
    cua_exclude-function = 'PEXA'.
    APPEND cua_exclude.
    cua_exclude-function = 'PEXI'.
    APPEND cua_exclude.
    cua_exclude-function = 'PEXN'.
    APPEND cua_exclude.
  ENDIF.

* Absprung in Finanzdokumentpflege nur von Fakturabildern aus möglich
* Finanzdokumente: im Anzeigemodus nur Anzeigen des FD möglich
* Finanzdokumente: Protokoll nur auf Fakturabildern    möglich
  IF NOT ( t185v-panel EQ 'KDE3' ) AND
     NOT ( t185v-panel EQ 'PDE3' ).
    cua_exclude-function = 'IFDH'.
    APPEND cua_exclude.
    cua_exclude-function = 'IFDV'.
    APPEND cua_exclude.
    cua_exclude-function = 'IFDA'.
    APPEND cua_exclude.
    cua_exclude-function = 'IFDP'.
    APPEND cua_exclude.
  ELSE.
    IF t180-trtyp EQ chara.
      cua_exclude-function = 'IFDH'.
      APPEND cua_exclude.
      cua_exclude-function = 'IFDV'.
      APPEND cua_exclude.
      cua_exclude-function = 'IFDP'.
      APPEND cua_exclude.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'J_1BSA_SCREEN_COMPONENT_ACTIVE'
    EXPORTING
      bukrs                = tvko-bukrs
      component            = '**'
      progname             = 'SAPMV45A'
      dynpronr             = '4470'
    EXCEPTIONS
      component_not_active = 01
      no_active_fields     = 02
      OTHERS               = 03.
  IF sy-subrc > 0.
    cua_exclude-function = 'PLND'.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING 'PLND'.
  ENDIF.
* IDOC-Anzeige nur bei Lieferplänen mit Abrufen möglich
  IF vbak-abdis IS INITIAL OR
     t180-trtyp EQ charh.
    cua_exclude-function = fcode_idoc_abruf.
    APPEND cua_exclude.
  ENDIF.

* Kopffakturierungsplan nur wenn TVAK-FPART gesetzt
  IF tvak-fpart IS INITIAL.
    cua_exclude-function = 'KFPL'.
    APPEND cua_exclude.
*   GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING 'KFPL'.
  ENDIF.

***** DSEG *****
  IF gwa_twpa IS INITIAL.
    SELECT SINGLE * FROM twpa
          CLIENT SPECIFIED
          INTO gwa_twpa
          WHERE  mandt       = sy-mandt.
  ENDIF.

  IF NOT gwa_twpa-addis IS INITIAL.
***** DSEG *****
* Verkaufshilfsmittelreiter nur, wenn zentraler Schalter gesetzt ist
    CALL FUNCTION 'WTAD_ADDIS_IN_SO_DISPLAY_CHK'
      EXPORTING
        fi_vbtyp         = vbak-vbtyp
      EXCEPTIONS
        addis_not_active = 1
        OTHERS           = 2.
***** DSEG *****
  ENDIF.
  IF sy-subrc <> 0 OR gwa_twpa-addis IS INITIAL.
***** DSEG *****
    cua_exclude-function = fcode_verkaufshilfsmittel.
    APPEND cua_exclude.
* GUI-Redesign 4.0: entsprechenden Reiter ausblenden
    PERFORM taxi_deactivate_tab USING fcode_verkaufshilfsmittel.
  ENDIF.

* Anzeige Lieferungen über Funktionsbaustein 'SD_HELP_DELIVERY' nur
* bei Lieferplänen mit Abrufen auf Positionsbildern
  IF NOT vbak-abdis IS INITIAL AND
     sy-dyngr NE 'POSI'.
    cua_exclude-function = fcode_liefersit_pos.
    APPEND cua_exclude.
  ENDIF.

* Schnelländerung Fakturasperre inaktiv wenn voll fakturiert
  IF ( xvbuk-fkstk EQ charc AND
       xvbuk-fksak EQ charc OR
       xvbuk-fkstk EQ space AND
       xvbuk-fksak EQ charc OR
       xvbuk-fkstk EQ charc AND
       xvbuk-fksak EQ space ) AND
     rv45a-s_faksk IS INITIAL.
    cua_exclude-function = fcode_schnellaend_fak_sperre.
    APPEND cua_exclude.
  ENDIF.

* Reiter "Konditionen" für Textpositionen ausblenden
  IF sy-dyngr = 'POSI' AND vbap-posar = charb.
    cua_exclude-function = fcode_kondition_position.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING fcode_kondition_position.
  ENDIF.

* Set Advanced Returns Functions
  IF gr_msr_sales IS BOUND.
    CALL METHOD gr_msr_sales->maintain_cua
      EXPORTING
        is_t180            = t180
        is_t185v           = t185v
        is_tvak            = tvak
        is_vbak            = vbak
      CHANGING
        ct_inactive_fcodes = taxi_inactive_fcodes[]
        ct_cua_exclude     = cua_exclude[].
  ELSE.
*   Deactivate Advanced Returns tabstrip
    PERFORM taxi_deactivate_tab USING fcode_msr_item_detail.
    PERFORM taxi_deactivate_tab USING fcode_msr_item_overview.
*   Exclude function from menu
    cua_exclude-function = fcode_msr_item_detail.
    APPEND cua_exclude.
    cua_exclude-function = fcode_msr_item_overview.
    APPEND cua_exclude.
    cua_exclude-function = fcode_msr_fastchg_item.
    APPEND cua_exclude.
    cua_exclude-function = fcode_msr_fastchg_approv.
    APPEND cua_exclude.
    cua_exclude-function = fcode_msr_tracking_all.
    APPEND cua_exclude.
    cua_exclude-function = fcode_msr_tracking_item.
    APPEND cua_exclude.
  ENDIF.

* TM ERP Integration II - UI Extension
  IF gr_tm_sales IS NOT BOUND.
    PERFORM taxi_deactivate_tab USING fcode_tm_status_overview.
    cua_exclude-function = fcode_tm_status_overview.
    APPEND cua_exclude.
  ENDIF.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      handle = l_sd_sales_basic_exit
      active = active.

  IF active = charx.
    CALL METHOD l_sd_sales_basic_exit->maintain_cua
      EXPORTING
        fvbak             = vbak
        ft180             = t180
        fxvbap            = xvbap[]
        fxvbpa            = xvbpa[]
        posnr             = vbap-posnr "This parameter is only for FI-CA
        f_call_dialog     = call_dialog
        ft185v            = t185v
      CHANGING
        f_inactive_fcodes = taxi_inactive_fcodes[]
        f_cua_exclude     = cua_exclude[].
  ENDIF.

  PERFORM is_foap_cd_active
    TABLES
      cua_exclude[]
    USING
      vbak.

* EH&S: Gefahrgutabwicklung und Stoffberichte
  CALL FUNCTION 'SD_EHS_CHECK_ACTIVE'
    EXPORTING
      i_vbtyp    = vbak-vbtyp
      i_vkorg    = vbak-vkorg
      i_auart    = vbak-auart
    CHANGING
      c_vggp     = rv45a_uv-vggp
    EXCEPTIONS
      ehs_active = 1
      OTHERS     = 2.

  CALL FUNCTION 'SD_EHS_GET_STATUS'
    EXCEPTIONS
      ehs_nicht_aktiv  = 1
      ehs_vbepdg_aktiv = 2
      ehs_alles_aktiv  = 3
      OTHERS           = 4.

  IF sy-subrc = 1.
*   Kein Button "Gefahrgutprüfungen" und Kein Button "Gefahrgut"
*   einblenden sowie Reiter "Gefahrgut" ausblenden
    cua_exclude-function = fcode_gefahrgut.
    APPEND cua_exclude.
    cua_exclude-function = fcode_gefahrgut_zusatzdaten.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING  fcode_gefahrgut_zusatzdaten.

  ELSEIF sy-subrc = 2.
*   Kein Button "Gefahrgutprüfungen" aber Button "Gefahrgut" und
*   Reiter "Gefahrgut" einblenden
*   Ausnahme: Kein Button "Gefahrgut" und kein Reiter "Gefahrgut"
*   einblenden wenn es sich um ein Material ohne
*   Gefahrgutkennzeichenprofil handelt

*   Überprüfung ob Gefahrgutkennzeichenprofil gefahrgutrelevant
    CALL FUNCTION 'SD_PROFL_CHECK'
      EXPORTING
        profl  = xvbap-profl
      EXCEPTIONS
        no_dg  = 1
        OTHERS = 2.

    IF ( sy-dyngr = 'POSI' AND sy-subrc <> 0 ) AND
       ( xvbap-posnr = vbap-posnr ).
      cua_exclude-function = fcode_gefahrgut_zusatzdaten.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING  fcode_gefahrgut_zusatzdaten.
    ENDIF.

    cua_exclude-function = fcode_gefahrgut.
    APPEND cua_exclude.

  ELSEIF sy-subrc = 3.
*   Button "Gefahrgutprüfungen" und Button "Gefahrgut" einblenden
*   Ausnahme: Kein Button "Gefahrgut" und kein Reiter "Gefahrgut"
*   einblenden wenn es sich um ein Material ohne
*   Gefahrgutkennzeichenprofil handelt

*   Überprüfung ob Gefahrgutkennzeichenprofil gefahrgutrelevant
    CALL FUNCTION 'SD_PROFL_CHECK'
      EXPORTING
        profl  = xvbap-profl
      EXCEPTIONS
        no_dg  = 1
        OTHERS = 2.

    IF ( sy-dyngr = 'POSI' AND sy-subrc <> 0 ) AND
       ( xvbap-posnr = vbap-posnr ).
      cua_exclude-function = fcode_gefahrgut_zusatzdaten.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING  fcode_gefahrgut_zusatzdaten.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'EHS002_CHECK_EHS_ACTIVE'
    EXCEPTIONS
      ehs_not_exist = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
*   Kein Menüabsprung "Stoffberichte" wenn EH&S nicht installiert
    cua_exclude-function = fcode_stoffberichte.
    APPEND cua_exclude.
  ENDIF.
* ENDE Gefahrgutprüfungen und Stoffberichte

* Gefahrgut: Template-Materialabwicklung
  MOVE-CORRESPONDING vbak TO i_dnact.
  CALL FUNCTION 'EHS003_CHECK_TPPR_ACTIVE'
    EXPORTING
      i_dnact     = i_dnact
      i_vbtyp     = vbak-vbtyp
    EXCEPTIONS
      tppr_active = 1
      OTHERS      = 2.

  IF sy-subrc <> 1.
* Reiter "Gefahrgut" ausblenden wenn Abwicklung nicht durchgeführt
* werden soll
    cua_exclude-function = fcode_template_abwicklung.
    APPEND cua_exclude.
    PERFORM taxi_deactivate_tab USING  fcode_template_abwicklung.
  ELSE.
* Abwicklung ist aktiv; Überprüfung, ob relevantes Material im Beleg
    CALL FUNCTION 'EHS003_TPMAT_CHECK'
      EXPORTING
        i_vbtyp        = vbak-vbtyp
        i_vbeln        = vbak-vbeln
      TABLES
        i_xvbap_tab    = xvbap
      EXCEPTIONS
        tpmat_exist    = 1
        no_tpmat_exist = 2
        wrong_param    = 3
        no_profl_found = 4
        others_        = 5.

    IF sy-subrc <> 1.
* Reiter "Gefahrgut" ausblenden wenn keine relevanten Materialien im
* Beleg
      cua_exclude-function = fcode_template_abwicklung.
      APPEND cua_exclude.
      PERFORM taxi_deactivate_tab USING  fcode_template_abwicklung.
    ENDIF.
  ENDIF.
* ENDE Gefahrgut: Template-Materialabwicklung
ENHANCEMENT-POINT CUA_SETZEN_15 SPOTS ES_SAPMV45A.
*Screen extensions (BAdIs)
  PERFORM cust_activate_tab(sapmv45a).

* New Internal and Customer BAdI screens
  PERFORM deactivate_screen_badi_tab.
***

* Buttons für Produktvorschlag ggfs. ausblenden
  IF dpp_active IS INITIAL.
    cua_exclude-function = fcode_umfang_produktvorschlag.
    APPEND cua_exclude.
    cua_exclude-function = fcode_uebernehmen_menge_pv.
    APPEND cua_exclude.
  ELSE.
* es kann keine Menge aus dem Produktvorschlag übernommen werden
    LOOP AT xvbpv WHERE
         NOT pvmng01 IS INITIAL.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0.
      da_subrc = sy-subrc.
    ELSE.
      LOOP AT xvbap WHERE updkz <> updkz_delete
                    AND pvpos   <> space
                    AND pvmng01 <> 0
                    AND kwmeng  =  0.
        EXIT.
      ENDLOOP.
    ENDIF.
    IF sy-subrc NE 0 OR
       da_subrc NE 0.
      cua_exclude-function = fcode_uebernehmen_menge_pv.
      APPEND cua_exclude.
    ENDIF.
ENHANCEMENT-POINT CUA_SETZEN_04 SPOTS ES_SAPMV45A.
  ENDIF.

* Fand CALL DIALOG schon statt ?
  IF call_dialog_folge = 'X'.
    cua_exclude-function = fcode_ende.
    APPEND cua_exclude.
    cua_exclude-function = fcode_abbrechen1.
    APPEND cua_exclude.
  ENDIF.

* Wurden Nachrichten gesammelt?
  IF sy-dyngr NE 'ANFO'.
    CALL FUNCTION 'SD_CHECK_MSGTAB'
      IMPORTING
        anz      = da_anzahl
        severity = da_severity.
    IF da_anzahl = 0.
      cua_exclude-function = fcode_protokoll.
      APPEND cua_exclude.
    ELSE.
      IF da_severity CA 'AE' AND
        hinweis_protokoll_show NE space.
        MESSAGE s111(v2).
* Nach neu eingegangenen Meldungen die Nachricht nur 1x anzeigen
        CLEAR hinweis_protokoll_show.
      ELSEIF hinweis_protokoll_show NA ' AE'.
        MESSAGE s112(v2).
* Nach neu eingegangenen Meldungen die Nachricht nur 1x anzeigen
        CLEAR hinweis_protokoll_show.
      ENDIF.
    ENDIF.
  ENDIF.

* Falls kein PlugIn aktiv ist und kein APO-System mit Release >= 31
* angeschlossen ist, sollte die Buttonanzeige für die
* Liefergruppenkorrelation (Versand) nicht möglich sein
  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
    EXCEPTIONS
      exits_not_active = 1
      OTHERS           = 2.
  IF NOT sy-subrc IS INITIAL.
    cua_exclude-function = fcode_crlt.
    APPEND cua_exclude.
  ELSE.
* Prüfen, ob mindestens 1 APO-System mit Release >= 31
* angeschlossen ist.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = tabname
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      SELECT SINGLE * INTO wa_ndisyst FROM (tabname)
             WHERE type   = 'SAP_APO   ' AND
             ndirel      >= '31'.
      IF sy-subrc > 0.
        cua_exclude-function = fcode_crlt.
        APPEND cua_exclude.
      ENDIF.
    ELSE.
      cua_exclude-function = fcode_crlt.
      APPEND cua_exclude.
    ENDIF.
  ENDIF.

* Bei CALL TRANSACTION weitere Funktionen ausblenden
  IF sy-calld <> space.
    PERFORM cua_call_exclude.
  ENDIF.
* in case of active SAP Creditmanagement
  DATA: l_flag TYPE flag.
  CALL FUNCTION 'UKM_IS_ACTIVE'
    IMPORTING
      e_active = l_flag.

  IF NOT l_flag IS INITIAL.
    APPEND 'IKRL' TO cua_exclude.
    APPEND 'KLIM' TO cua_exclude.
*     APPEND 'IKRL' to CUA_EXCLUDE.
  ENDIF.

  IF NOT cl_ops_switch_check=>sd_sfws_sc2( ) IS INITIAL.
* VA03 diplay from archive search with date / START
* ANZA should only be displayed in normal VA03
    IF t180-trtyp NE chara OR   "Display
       t180-trvog NE char0 OR   "Order
       gv_asuc EQ 'X' OR        "Search with date
       gv_vbak_special_archiving IS INITIAL.
      cua_exclude-function = 'ANZA'.
      APPEND cua_exclude.
    ENDIF.
* IF VA03 and 'search with date' then 'EDIT', 'CREATE'
* and 'Display document flow' should not be diplayed, but 'SHOW' should be active
    IF t180-trtyp EQ chara AND   "Display
       t180-trvog EQ char0 AND   "Order
       gv_asuc EQ 'X' AND        "Search with date
       NOT gv_vbak_special_archiving IS INITIAL.
      cua_exclude-function = 'AEND'.
      APPEND cua_exclude.
      cua_exclude-function = 'ANLE'.
      APPEND cua_exclude.
      DELETE cua_exclude WHERE function EQ 'ANZE'.
      cua_exclude-function = 'IFLU'.
      APPEND cua_exclude.
      cua_exclude-function = 'STAT'.
      APPEND cua_exclude.
    ENDIF.
* VA03 diplay from archive search with date / END
  ENDIF.

** Enhancements Counter Sales
  DATA: ls_basic_cfg    TYPE wsdt_basic_cfg.
  DATA: ls_mv_cfg       TYPE wsdt_mv_cfg.
  DATA: l_cua_exclude TYPE cua_exclude.

* check if material search is active in Sales order
  ls_basic_cfg = cl_wsd_config=>read_mat_basic_config(
                    cl_wsd_constants=>co_appl_sales_order ).
  IF ls_basic_cfg-so_active IS INITIAL.
    cua_exclude-function = 'MATS'.
    APPEND cua_exclude.
  ELSE.
    IF NOT (     (    sy-tcode EQ 'VA01' OR sy-tcode EQ 'VA02'
                   OR sy-tcode EQ 'VA11' OR sy-tcode EQ 'VA12'
                   OR sy-tcode EQ 'VA21' OR sy-tcode EQ 'VA22' )
           " and ( tvak-vbtyp = 'C' )
             ).
      cua_exclude-function = 'MATS'.
      APPEND cua_exclude.
    ENDIF.
  ENDIF.

* check if material view is active in Sales order
  ls_mv_cfg = cl_wsd_config=>read_mat_view_config(
          cl_wsd_constants=>co_appl_sales_order ).

  IF ls_mv_cfg-mv_active IS INITIAL.
    cua_exclude-function = 'MATV'.
    APPEND cua_exclude.
  ELSE.

    " if not ( tvak-vbtyp = 'C' ).
    " cua_exclude-function = 'MATV'.
    " append cua_exclude.
    " endif.

  ENDIF.

  IF /cbad/cl_switch_check=>/cbad/sd_sfws_sc1( ) EQ abap_true.
*   Enhancements Contracts and Billing
    IF tvak-extcont IS INITIAL.
      cua_exclude-function = 'DKON'.
      APPEND cua_exclude.
      IF tvak-kschl_budget IS INITIAL AND tvak-kschl_caps IS INITIAL.
        cua_exclude-function = 'BLOG'.
        APPEND cua_exclude.
      ENDIF.
    ELSE.
      cua_exclude-function = 'BLOG'.
      APPEND cua_exclude.
*   Allways hide button in create and change mode
      IF t180-trtyp EQ charh OR t180-trtyp EQ charv.
        cua_exclude-function = 'DKON'.
        APPEND cua_exclude.
      ENDIF.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT CUA_SETZEN_12 SPOTS ES_SAPMV45A.
  PERFORM cua_modifizieren USING t185v-status.

ENHANCEMENT-POINT CUA_SETZEN_13 SPOTS ES_SAPMV45A.

  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    PERFORM cua_exclude_paysp.
  ENDIF.

* Status setzen
  SET PF-STATUS t185v-status EXCLUDING cua_exclude
                             OF PROGRAM modul-pool.

*-Kein CUA-Titel vorgegeben: alter Wert bleibt -----------------------*
  CHECK t185v-ctitel NE space.

* Temporär <<< Titelparameter aufbauen >>>
* Gleichzeitig erfolgt die Textmontage des Parameters je nach Sprache
* in anderer Reihenfolge (Beispiel: Terminauftrag ändern und
* Change Sales Order)
  IF da_textfolge CS sy-langu.
* Bezeichnung der Belegart holen
    cua_text = tvakt-bezei.
    str_len = strlen( cua_text ) + 1.
    IF str_len > 1.
* Belegnummer hintendranhängen
      WRITE vbak-vbeln TO cua_text+str_len.
      str_len = strlen( cua_text ) + 1.
    ENDIF.
** Bei Archivbelegen: 'Aus Archiv' dranhängen

    IF data_read_from_archive = 'X'.
      rv45a-txt_titcua = text-301.
    ENDIF.

* Bearbeitungsart hintendranhängen
    WRITE rv45a-txt_titcua TO cua_text+str_len.
    str_len = strlen( cua_text ).
    IF str_len > 0.
      ASSIGN cua_text+0(str_len) TO <tfs>.
    ENDIF.
  ELSE.
* Bearbeitungsart holen
    IF data_read_from_archive = 'X'.
      rv45a-txt_titcua = text-301.
    ENDIF.
    cua_text = rv45a-txt_titcua.
    str_len = strlen( cua_text ) + 1.
* Belegart hintendranhängen
    WRITE tvakt-bezei TO cua_text+str_len.
    str_len = strlen( cua_text ) + 1.
    IF str_len > 1.
* Belegnummer hintendranhängen
      WRITE vbak-vbeln TO cua_text+str_len.
      str_len = strlen( cua_text ) + 1.
    ENDIF.
    IF str_len > 0.
      ASSIGN cua_text+0(str_len) TO <tfs>.
    ENDIF.
  ENDIF.
  MOVE <tfs> TO rv02p-title.

  SET TITLEBAR t185v-ctitel OF PROGRAM modul-pool
                            WITH <tfs>.


ENDFORM.                    "CUA_SETZEN

*&---------------------------------------------------------------------*
*&      Form  is_foap_cd_active
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_CUA_EXCLUDE  text
*      -->I_FVBAK         text
*----------------------------------------------------------------------*
FORM is_foap_cd_active
  TABLES
    it_cua_exclude TYPE cua_exclude_t
  USING
    i_fvbak        TYPE vbak.

  DATA:
    ls_cua_exclude TYPE cua_exclude,
    l_activ        TYPE boolean.

  CALL FUNCTION 'FOAP_FI_CDA_IS_ACTIV'
    IMPORTING
      ex_is_activ = l_activ.

  IF l_activ IS INITIAL.
    ls_cua_exclude-function = '+DMC'.
    COLLECT ls_cua_exclude INTO it_cua_exclude.
    RETURN.
  ENDIF.

  IF i_fvbak-vbtyp NE 'K'.
    ls_cua_exclude-function = '+DMC'.
    COLLECT ls_cua_exclude INTO it_cua_exclude.
  ENDIF.

ENDFORM.                    "is_foap_cd_active