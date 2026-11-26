*-----------------------------------------------------------------------
*        Datenbanktabelle VBAP
*-----------------------------------------------------------------------

TYPE-POOLS: vabap, ibxx, mdr1p.

TABLES: vbap, *vbap,
        vbapd, *vbapd,
        vbpv,                          " Produktvorschlag
        cabn,                          " Merkmale
        cabnt,                         " Merkmalsbezeichnung
        cepct,                         " Profitcenter-Text
        *cobl, cobl,                   " Kontierungsblock
        drad,                          " Dokumente
        komkh, komph,                  " Chargenfindung
        komkg, kompg,                  " Listung, Ausschluß
        komkd, kompd, kondd, tvsu,     " Substitution
        menge,                         " EAN-Daten aus der MARM
        moaf,                         " Montageauftrag aus Konfiguration
        tvag,
        tvagt,
        tvap, *tvap,
        tvapt,
        tvfst,
        tprio, tprit,
        tstl,                          " Steuertypen pro Land
        tskm,                          " Steuerindikatoren Material
        tvm1,                          " materialgruppe
        tvm2,                          " materialgruppe
        tvm3,                          " materialgruppe
        tvm4,                          " materialgruppe
        tvm5,                          " materialgruppe
        tvrl,                          " Vertriebsrelevanz
        tvsut,                         " Substitutionstexte
        tvrmas,                        " Reparaturschema
        tvvfs,
        tvvfz,
        t001k,
        t163k,                         " Kontierung
        t178,
        t178t,
        t179,
        t179t,
        tmfg,                          " Material-Frachtgruppen
        tmfgt,                         " Material-Frachtgruppen Texte
        j_1bagt,                       " Texte zum Beweg'schl.  (Bras.)
        j_1btxsdct,                    " Texte zum SD-Steuerkz. (Bras.)
        j_1batl1t,                     " Texte zu Steuer ICMS   (Bras.)
        j_1batl2t,                     " Texte zu Steuer IPI    (Bras.)
        j_1batl3t,                     " Texte zu Steuer ISS    (Bras.)
        j_1batl4t,                     " Texte zu Steuer COFINS (Bras.)
        j_1batl5t,                     " Texte zu Steuer PIS    (Bras.)
        e1curef,                       " Dynpro
        msr_s_sales_item.              " Dynpro 4448

DATA:   BEGIN OF COMMON PART vbapcom.

* Allgemeine Deklarationen für den Kontierungsblock

DATA: co_dynnr   LIKE tcobl-dynnr,     "Dynpronummer des Subscreens
      co_progn   LIKE sy-cprog,        "Name des Kontierungsblockmodul
      process LIKE cobl-process,       "RWIN-Prozeß
      event   LIKE cobl-event.         "RWIN-Zeitpunkt

* Interne Tabelle der Felder eines Subscreens im Kontierungsblock

DATA BEGIN OF int_coblf OCCURS 10.
        INCLUDE STRUCTURE coblf.
DATA END OF int_coblf.

* Dokumente

DATA BEGIN OF xdrad OCCURS 10.
        INCLUDE STRUCTURE drad.
DATA END OF xdrad.

* gelöschte Positionen, die ein Dokument
DATA BEGIN OF ydrad OCCURS 10.
        INCLUDE STRUCTURE drad.
DATA END OF ydrad.

DATA: drad_refresh TYPE c.

* Alter Tabellenstand beim Ändern

DATA:   BEGIN OF yvbap OCCURS 2.
        INCLUDE STRUCTURE vbapvb.
DATA:   END OF yvbap.

* Aktueller Tabellenstand

DATA:   BEGIN OF xvbap OCCURS 125.
        INCLUDE STRUCTURE vbapvb.
DATA:   END OF xvbap.

* Positionen der Vorlage

DATA:   BEGIN OF vvbap OCCURS 10.
        INCLUDE STRUCTURE vbapvb.
DATA:   END OF vvbap.

* VBAP-Key

DATA: BEGIN OF vbapkey,
        mandt LIKE vbap-mandt,
        vbeln LIKE vbap-vbeln,
        posnr LIKE vbap-posnr,
      END OF vbapkey.

* Verdichtete Flusstabelle

DATA: BEGIN OF xvbapf OCCURS 10.
        INCLUDE STRUCTURE vbapf.
DATA: END OF xvbapf.

* beim Update des Auftrages beim Rechnungseingang entsteht
* eine veränderte REMNG im verdichteten Fluß
DATA: BEGIN OF yvbapf OCCURS 10.
        INCLUDE STRUCTURE vbapf.
DATA: END OF yvbapf.

* Materialfindung

DATA: BEGIN OF konddp_tab OCCURS 10.
        INCLUDE STRUCTURE konddp.
DATA: END OF konddp_tab.
DATA: product_selection_rekursiv   TYPE c.
* Verfügbarkeitsprüfung bei Produktselektion
DATA: prod_sel_revfp TYPE c VALUE '1'.

* Naturalrabatt

DATA: BEGIN OF kondn_mat_tab OCCURS 10.
        INCLUDE STRUCTURE kondn_mat.
DATA: END OF kondn_mat_tab.
DATA: natrab_rekursiv   TYPE c.

* Cross-Selling

DATA: BEGIN OF cross_sell_tab OCCURS 10.
        INCLUDE STRUCTURE mats_cs_ov.
DATA: END OF cross_sell_tab.
DATA: BEGIN OF cs_mats_tab OCCURS 10.
        INCLUDE STRUCTURE cross_sell_materials.
DATA: END OF cs_mats_tab.
DATA: cross_selling_rekursiv   TYPE c.

* Sourcing
DATA:
  xvbapsou LIKE vbapsou OCCURS 0 WITH HEADER LINE,
  sourcing_cancel_active,
  sourcing_transfer_active,
  sourcing_transfer_indicator,
  sourcing_price_mainitem,
  sourcing_transfer_starter.

* Reparaturabwicklung  - anzulegende Unterpositionen

DATA: BEGIN OF xvbaprep OCCURS 10.
        INCLUDE STRUCTURE v46r_itemkom.
DATA: END OF xvbaprep.
DATA: BEGIN OF xvbaprep_ser OCCURS 10.
        INCLUDE STRUCTURE v46r_serikom.
DATA: END OF xvbaprep_ser.
DATA: repair_rekursiv   TYPE c.

* Produktvorschlag

DATA: BEGIN OF xvbpv OCCURS 10.
        INCLUDE STRUCTURE vbpvd.
DATA: END OF xvbpv.


* Hauptposition

DATA: BEGIN OF hvbap.
        INCLUDE STRUCTURE vbapvb.
DATA: END OF hvbap.
DATA: BEGIN OF *hvbap.
        INCLUDE STRUCTURE vbapvb.
DATA: END OF *hvbap.

* Positionen sortiert nach übergeordneten Positionen
* UVBAP ist sortiert !
DATA: BEGIN OF uvbap OCCURS 10.
        INCLUDE STRUCTURE vbapu.
DATA: END OF uvbap.

* external UVBAP
DATA: BEGIN OF gt_uvbap_ext OCCURS 10.
        INCLUDE STRUCTURE vbapu.
DATA: END OF gt_uvbap_ext.

* Positionen sortiert nach Korrelationsgruppen

DATA: BEGIN OF gvbap_key,
        grkor LIKE vbap-grkor,
        posnr LIKE vbap-posnr,
      END OF gvbap_key.

DATA: BEGIN OF gvbap OCCURS 10.
        INCLUDE STRUCTURE gvbap_key.
DATA:   lfgfa TYPE f,
        noapo TYPE c,
        matnr LIKE vbap-matnr,
        werks LIKE vbap-werks,
        grdat LIKE vbep-edatu,
        gruhr LIKE vbep-ezeit,
        stlnr LIKE vbap-stlnr,
        stlhp TYPE c,          "Stücklistenhauptposition
        grart TYPE c,          "Korrelationsart
      END OF gvbap.

* Lieferdatum und -Uhrzeit auf Einteilungsebene
DATA: BEGIN OF gr_ldat OCCURS 0,
        posnr LIKE vbap-posnr,
        edatu LIKE vbep-edatu,
        ezeit LIKE vbep-ezeit,
      END OF gr_ldat.

* Liefergruppen, bei denen nach Gruppenprüfung eine Nachkorrelation
* erforderlich ist
DATA: BEGIN OF gr_chk OCCURS 0,
        grkor LIKE vbap-grkor,
      END OF gr_chk.

* Indextabelle für die Anzeige am Schirm

DATA: BEGIN OF ivbap OCCURS 150,
        posnr LIKE vbap-posnr,
        tabix LIKE sy-tabix,           " Index für Tabelle XVBAP
        selkz,
      END OF ivbap.

* Sortierung bei aktivem Produktvorschlag
DATA: BEGIN OF ivbap_pv OCCURS 150,
        pvsrt LIKE vbapd-pvsrt,      " Sortierung gemäß Produktvorschlag
        posnr LIKE vbap-posnr,
        tabix LIKE sy-tabix,           " Index für Tabelle XVBAP
        selkz,
      END OF ivbap_pv.

* XVBAP-TABIX zur Step-Loop-Zeile

DATA: BEGIN OF svbap OCCURS 12,
        tabix LIKE sy-tabix,
      END OF svbap.

* Konfigurationsdaten

DATA: BEGIN OF dbcuobj OCCURS 10.
        INCLUDE STRUCTURE confnr.
DATA: END OF dbcuobj.

DATA: BEGIN OF sdwa OCCURS 3.
        INCLUDE STRUCTURE cltable.
DATA: END OF sdwa.

DATA: BEGIN OF sdwa_chg OCCURS 3.
        INCLUDE STRUCTURE cltable.
DATA: END OF sdwa_chg.

DATA: xvcsdpos LIKE vcsdpos OCCURS 10 WITH HEADER LINE,
      *vcsdpos LIKE vcsdpos.

DATA: BEGIN OF xmerkmal OCCURS 10,
        index LIKE sy-index.
        INCLUDE STRUCTURE char_va_sel.
DATA:   atinn LIKE cabn-atinn,
        atein LIKE cabn-atein,
        atinp LIKE cabn-atinp.
ENHANCEMENT-POINT VBAPDATA_04 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND .
DATA: END OF xmerkmal.

* ERP: Lean Order (LORD)
TYPES:
      BEGIN OF tgs_characteristic,
        posnr TYPE posnr,
        index TYPE sy-index,
        atnam TYPE atnam,
        atbez TYPE atbez,
        cleng TYPE cleng,
        atinn TYPE atinn,
        atein TYPE atein,
        atinp TYPE atinp,
        atvie TYPE atvie,
        aterf TYPE aterf,
        attab TYPE attab,
        atfel TYPE atfel,
        atsch TYPE atsch,
        atfor TYPE atfor,
        atint TYPE atint,
      END OF tgs_characteristic.
DATA: gs_characteristic TYPE tgs_characteristic.
DATA: gt_characteristic TYPE STANDARD TABLE OF tgs_characteristic.
DATA: gs_char_request TYPE api_val_i.
DATA: gt_char_request TYPE STANDARD TABLE OF api_val_i.

* Advanced Returns Management
DATA: gr_msr_sales TYPE REF TO cl_msr_sales.
DATA: gs_msr_sales_item TYPE msr_s_sales_item.
DATA: gs_msr_sales_item_old TYPE msr_s_sales_item.
DATA: gv_msr_defaults TYPE flag,
      gv_msr_fastchange TYPE flag.
DATA: gv_msr_copy_split_id TYPE msr_split_id.
DATA: gv_msr_crd_copy TYPE char1.
DATA: gv_msr_error TYPE char1.
DATA: gv_msr_like_error TYPE char1.
DATA: BEGIN OF gs_msr_sales_descr,
        returns_reason_t TYPE msr_ret_reason_text,
        fu_code_t TYPE msr_fu_code_text,
        refund_code_t TYPE msr_refund_code_text,
        refund_control_t TYPE msr_refund_control_text,
        inspection_code_t TYPE qtxt_code,
        approv_block_t TYPE ddtext,
        nfu_code_t TYPE msr_fu_code_text,
      END OF gs_msr_sales_descr.

* TM ERP Integration II - UI Extension
DATA: gr_tm_sales         TYPE REF TO cl_tm_sales.
DATA: gv_tm_ctrl_key      TYPE tm_ctrl_key.
DATA: gv_tm_ctrl_key_desc TYPE tm_ctrl_key_desc.
DATA: gr_tm_docflow       TYPE REF TO if_tms_docflow.
DATA: gt_tm_head_sts      TYPE tms_t_doc_status_scr.
DATA: gt_tm_item_sts      TYPE tms_t_doc_status_scr.
DATA: g_tm_cont_head      TYPE REF TO cl_gui_custom_container.
DATA: g_tm_cont_item      TYPE REF TO cl_gui_custom_container.
DATA: gr_tm_table_item    TYPE REF TO cl_gui_alv_grid.
DATA: gr_tm_table_head    TYPE REF TO cl_gui_alv_grid.
DATA: gv_tm_doc_type      TYPE tms_doc_type.
DATA: gv_tm_doc_nr        TYPE tms_doc_nr.

ENHANCEMENT-POINT VBAPDATA_03 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND .
DATA: xmerkmal_save LIKE xmerkmal OCCURS 0.

DATA: BEGIN OF xmwert OCCURS 10,
        posnr  LIKE vbap-posnr,
        mwert01 LIKE rv45a-mwert01,
        mwert02 LIKE rv45a-mwert02,
        mwert03 LIKE rv45a-mwert03,
        mwert04 LIKE rv45a-mwert04,
        mwert05 LIKE rv45a-mwert05,
        mwert06 LIKE rv45a-mwert06,
        mwert07 LIKE rv45a-mwert07,
        mwert08 LIKE rv45a-mwert08,
        mwert09 LIKE rv45a-mwert09,
        mwert10 LIKE rv45a-mwert10,
      END OF xmwert.
* Spaltenanzahl für Übersichtsbild Konfiguration
DATA: ueco_col_count(2) TYPE n VALUE 10.

DATA: type_matching,
      delete_item_active,
      configuration_update_document.

DATA: BEGIN OF cfg_subitm_data OCCURS 0,
        config_id LIKE e1cucfg-config_id,
        inst_id   LIKE e1cuins-inst_id,
        posnr     LIKE vbap-posnr,
        posguid   LIKE vbapkom-posguid,
      END OF cfg_subitm_data.

DATA: crm_subsched_data,
      ext_subitem_sched.

DATA: BEGIN OF crm_bom_data_del OCCURS 0,
        posnr     LIKE vbap-posnr,
        matnr     LIKE vbap-matnr,
        uepos     LIKE vbap-uepos,
      END OF crm_bom_data_del.

* Effectivitydaten
DATA: dbtechs LIKE techsnr OCCURS 10 WITH HEADER LINE.

* Angebote bzw. Kontrakte bei Hinweis

DATA: BEGIN OF hnw_vbap OCCURS 100.
        INCLUDE STRUCTURE listvbap.
DATA: END OF hnw_vbap.

DATA: BEGIN OF hnw_vbak OCCURS 100.
        INCLUDE STRUCTURE vakpa.
DATA: END OF hnw_vbak.

* Tabellen für ALE-Positionen,

DATA: BEGIN OF vb_key OCCURS 50.
        INCLUDE STRUCTURE vbkey.
DATA: END OF vb_key.

* Tabelle mit Vertriebsbelegen zur Ermittlung des Fakturastatus

DATA: BEGIN OF fvbapkom1 OCCURS 50.
        INCLUDE STRUCTURE vbapkom1.
DATA: END OF fvbapkom1.

* Globalisieren der Übergabestruktur US_VBAPKOM
DATA: BEGIN OF us_vbapkom.
        INCLUDE STRUCTURE vbapkom.
DATA: END OF us_vbapkom.
* Dazu Feldleiste
DATA: BEGIN OF us_vbapkomx.
        INCLUDE STRUCTURE vbapkomx.
DATA: END OF us_vbapkomx.

* Vorgängerbeleg bei Anlegen aus Meldung für die Positionen, die
* per Call-Dialog erfasst werden.
DATA: dia_vbap_vgbel LIKE vbap-vgbel,
      dia_vbap_vgpos LIKE vbap-vgpos,
      dia_vbap_vgtyp LIKE vbap-vgtyp.

* Hilfstabellen Zuliefermatchcode
DATA BEGIN OF da_m_vlpma OCCURS 50.
        INCLUDE STRUCTURE m_vlpma.
DATA END OF da_m_vlpma.
RANGES r_kdmat FOR m_vlpma-kdmat.


* Hilfsfelder für Blättern

DATA: ivbap_tabix_zeile_1_post LIKE sy-tabix, "Tabix der ersten Zeile
      ivbap_tabix_zeile_1 LIKE sy-tabix,   "Tabix der ersten Zeile
      ivbap_tabix_aktuell LIKE sy-tabix,   "laufender Tabix der Seite
      ivbap_loopc         LIKE sy-tabix,   "Anzahl LOOP-Zeilen
      gv_cursor           TYPE i,
      ivbap_del_ind       LIKE sy-tabix.   "aufsetzen nach Löschen

DATA: t184_vwpos(4)       TYPE c,      "Positionsverwendung
      xvbap_high_posnr    LIKE vbap-posnr, "Höchste Positionsnummer
      xvbap_posnr_config  LIKE vbap-posnr, "POSNR bereits vergeben
      xvbap_loeschen,                  "Löschen der Position
      xvbap_loop_fcode LIKE t185-fcode,"Fcode vor Löschen im Loop
      xvbap_loeschen_bei_anlegen.      "Löschen beim Anlegen


*---------------------------------------------------------------------*
*     Umfang und zugehörige Direktwerte                               *
*---------------------------------------------------------------------*
DATA: xvbap_umfang(1)     TYPE c,      "Umfang der Liste
      xvbap_umfang_uall   TYPE c VALUE 'A', "alle Positionen
      xvbap_umfang_uhau   TYPE c VALUE 'B', "übergeordnete Positionen
      xvbap_umfang_umar   TYPE c VALUE 'C', "markierte Positionen
      xvbap_umfang_vbkd   TYPE c VALUE 'D', "sep. VBKD auf Position
      xvbap_umfang_post   TYPE c VALUE 'E'. "Struktur zur Position

ENHANCEMENT-POINT VBAPDATA_01 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND .
DATA: xvbap_umfang_opv.

* INCLUDE für Objektart
INCLUDE rbonrart.

* Änderungskennzeichen für Ende-Bearbeitung

DATA: vbap_ende_verfuegbarkeit,
      vbap_ende_bearbeitung,
      vbap_ende_steuer_neu,
      vbap_kopfsummen_neu,
      redetermine_bedae,               " Redetermine rqmt type
      assembly_order_not_changeable,   " Montage nicht mehr änderbar
      fcode_config_and_qty_change,
      beschaffung_erfolgt,             " wegen BESTAND_BEDARF_ABGLEICHEN
      configuration_changed,           " Konfiguration geändert
      effectivity_changed,             " Effectivitybewertung geändert
      config_material_exchanged,      " Tausch Std.produkt --> Lagertype
      config_build_structure,
      strukturpflege_konfiguration,    " während der STL-Auflösung
      struktur_angelegt,
      status_warnung_erfolgt,          " Materialstatus Vertrieb
      preise_angelegt,
      vbap_pruefen,                    " für Unvollständigkeitex
      vbap_kzvbr_e,                    " Position mit Einzelfertigung da
      vbap_korli,
      function_new_pricing,            " Neue Preisfindung über FB
      no_structure,                    " Keine Strukturaufl. bei BAPI
      natrab_new,                      " NatRab neu ermitteln
      upd_vbap,                        " Für Änderungsbelege
      wk_abruf_exist,                  " Wertkontraktabruf existiert
      dpp_active,                      " Dynam. Produktvorschlag aktiv
      dpp_quantity,                    " Dynam. Produktvorschlagsmenge
      plant_change_mto.                " Werksänderung make to order

* Kennzeichen für erfolgten Hinweis auf Löschvormerkung
DATA: vbap_matnr_loe LIKE vbap-matnr,
      vbap_werks_loe LIKE vbap-werks.

* Kennzeichen: Versandstelle und Route für alle Positionen neu ermitteln
DATA: vstel_ermitteln_alle.

* Kennzeichen für Gewicht/Volumen Übernahme im CALL_FUNCTION           *
DATA: no_gv.                           " keine G/V Ermittlung

* Hilfsfeld zum Prüfen der VRKME: Geprüfte Vrkme. Zieme analog.
DATA: prf_vrkme LIKE vbap-vrkme,
      prf_zieme LIKE vbap-zieme.
DATA: vrkme_changed.

* Hilfsfeld zum Prüfen, ob das Werk geändert wurde
DATA: werks_changed.

DATA: gv_pstyv_determ TYPE pstyv.

* serialnummern geändert
DATA: gf_serial_changed.
DATA: gt_serial_changed TYPE STANDARD TABLE OF posnr.

* Hilfsfeld, um Verfügbarkeitsprüfung für Strecke zu erlauben
DATA: pore_third_party TYPE c VALUE 'X'.

DATA: msg_lgort TYPE c VALUE ' '.

* Hilfsfeld zum Prüfen, ob das Material geändert wurde
DATA: matnr_changed.

* Auxiliary Field when ME_REQUISITION_EXT Exits with Error
DATA: error_in_req.

* Steuerflag für Textbearbeitung
DATA: BEGIN OF no_text_copy,
        header,
        item,
        check,
      END OF no_text_copy.

* Kennzeichen: Wunschdatum wurde geändert
DATA: etdat_changed.

* Flag: form MAT_AUF_HINWEIS_PRUFEN ist schon mal gelaufen
DATA: mat_auf_hinweis_geprueft TYPE c,
      mat_auf_hinweis_copy TYPE c.

ENHANCEMENT-POINT VBAPDATA_02 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND.
* Flags für Analyse Listung/Ausschluss, Materialfindung, Naturalrabatt
DATA: protokoll_la, protokoll_ma, protokoll_na, protokoll_cs.

* Businessobjekt auf Positionsebene
DATA: businessobjekt_pos LIKE nast-objtype.

* Hilfsfelder Zulieferabwicklung
DATA select_new_m_vlpma(1).

* Kennzeichen für Gesamtnetzterminierung
DATA: vbap_gesamtnetzterminierung TYPE c VALUE ' '.

* Hilfsfelder für Aufteilungsregeln
DATA: abr_vor_gabja LIKE cobrb-gabja,
      abr_vor_gabpe LIKE cobrb-gabpe.

* Teilbestaetigte Produktselektion
DATA: prodsel_dispo TYPE c.

* Gruppenaufruf Verfuegbarkeitspruefung
DATA: atp_ergebnis_abholen TYPE c,
      atp_gruppenaufruf TYPE c VALUE ' '.  " Ein='X', AUS= ' '

* form BESTAND_BEDARF_ABGLEICHEN is calling
DATA: atp_check_active TYPE c.

* FORM LIEFERDATUM_BESTIMMEN is calling
DATA: correlation_active TYPE xfeld.

* Hilfsfeld zum Merken der Benutzereingaben
* z.B. Änderungen bei der Ausgabe von W/E - Meldungen
* Gültigkeit bis FV45PFAP_VBAP_BEARBEITEN_ENDE
DATA: vbapin LIKE vbap.

* HELL - DUNKEL  - Verarbeitung
CONSTANTS: verarb_hell   VALUE 'H',
           verarb_dunkel VALUE 'D',
           verarb_immer  VALUE 'I',
           verarb_neut   VALUE 'N'.

* Constants and data to check if correlation or scheduling is
* necessary.
CONSTANTS:
  gc_caller_apo_bop TYPE c VALUE 'A', "system is APO, application is BOP
  gc_caller_apo_vmi TYPE c VALUE 'V', "system is APO, application is VMI
  gc_caller_crm     TYPE c VALUE 'C'. "system is CRM

DATA:
  gf_calling_application  TYPE c,
  bop_flag                TYPE c.

* item is now processed in BAPI mode (SD_SALES_ITEM_MAINTAIN)
DATA: gv_item_in_process.

* VBAP-MATNR gefüllt
DATA: gv_vbap_matnr_gefuellt.

* RV45A-MABNR gefüllt
DATA: gv_rv45a_mabnr_gefuellt.

DATA: pos_geaendert.

* Auftragsstückliste Prüfung.
DATA: kdst_read.

* Kundenauftragsbestand Prüfung.
DATA: mska_read.
* material was substituted
DATA: matnr_subst.

* quantity was changed due to configuration
DATA: wmeng_upd_conf.

* item texts were read from memory in BAPI mode
DATA: item_texts_from_memory.

* batch selection criteria need to be updated manually
DATA: upd_batch_sel.

* quantity was changed due to umvkn/umvkz
DATA: wmeng_upd_umvk.

* action BDCU is allowed
DATA: bdcu_allowed.

* flag to recognize new items for scrolling
* for example in RBA case
DATA: new_item_to_scroll.

* CMDS - Collaborative Management of Delivery Schedules
DATA item_cmds_active TYPE char1.

* ERGEBNIS_AN_VERFUEGBARKEIT called twice
DATA: gv_eav_called.

* EDI FOREGROUND FROM ERROR: no suitable contract item
DATA: gv_edi_no_contract_item.

* RRICB mode
DATA: rricb_flag.

ENHANCEMENT-POINT VBAPDATA_10 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND .
DATA: END OF COMMON PART.

* Haushaltsmanagement
TYPE-POOLS: fmco.

DATA: BEGIN OF hhm_vbap,
        fistl   LIKE cobl-fistl,
        fipos   LIKE cobl-fipos,
        fonds   LIKE cobl-geber,
        budget_pd LIKE cobl-budget_pd,
        btn_hhm(1)             ,
      END   OF hhm_vbap.

* Hilfsfeld zum Prüfen, ob V4 231 angezeigt wurde
DATA: v4231_shown.

*eject


***** DSEG *****
DATA: gwa_twpa LIKE twpa.
***** DSEG *****
ENHANCEMENT-POINT VBAPDATA_05 SPOTS ES_VBAPDATA STATIC INCLUDE BOUND .


* VBAPVB with location data, needed for data transfer to Service fill monitor
DATA:   BEGIN OF xvbap_loc OCCURS 125.
        INCLUDE STRUCTURE vbapvb_loc.
DATA:   END OF xvbap_loc.