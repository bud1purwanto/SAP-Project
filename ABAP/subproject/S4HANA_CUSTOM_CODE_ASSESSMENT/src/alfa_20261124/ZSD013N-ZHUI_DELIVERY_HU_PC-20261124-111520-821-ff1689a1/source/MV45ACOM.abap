*---------------------------------------------------
*        Allgemeine Felder der Kundenauftragsbearbeitung
*---------------------------------------------------
TABLES:  rv61a,                        " Konditionsfelder
         rv45a,
         rv45a_uv,
         v46r_uv,
         rv45s,
         rv45z,
         rv46g_doc,
         r185d,                        " Folgebild Dialogsteuerung
         vbepdg,
         indx.

* New data for handling predefined pricing elements
INCLUDE vappedata.

enhancement-point mv45acom_02 spots es_mv45acom static include bound.
DATA:    BEGIN OF COMMON PART mv45acom.

* Laufzeitinformation (Hell, Dunkel, Batch, Call Modus)
DATA: bi_info LIKE bdcrun.
* Catt aktiv
DATA: cattaktiv.
* Globaler Schalter zum Ausschalten der Sonderlogik
* für Hintergrundverarbeitung
DATA: background_debug(1) TYPE c.

DATA: berechtigung_block.              " Berechtigung block/unblock
DATA: berechtigung_unblock.            " Berechtigung unblock
DATA: berechtigung_ccard.              " Berechtigung Zahlungskarten
DATA: authority_check_cua_exclude,     " Ber.prüf. durchgeführt CUA_EX
      authority_liste_auftrag,         " Berechtigung Trans. VA05
      authority_liste_anfrage,         " Berechtigung Trans. VA15
      authority_liste_angebot,         " Berechtigung Trans. VA25
      authority_liste_lieferplan,      " Berechtigung Trans. VA35
      authority_liste_kontrakt,        " Berechtigung Trans. VA45
      authority_liste_posvorschlag.    " Berechtigung Trans. VA55
DATA: authority_kundenstammblatt.      " Berechtigung Kundenstammblatt
DATA: zaehler_vbfs LIKE vbfs-zaehl.
* temporäre Entwicklungsfelder ENDE

* Globaler Schalter, ob Preisfindung fE Gesamtbeleg notwendig
DATA: prsgr LIKE komp-prsgr.

* Globales Flag, daß Gesamtpreisfindung gelaufen ist.
DATA: g_pricing_complete TYPE c.

* Globaler Schalter fE FB STATUS_BUFFER_REFRESH
DATA: status_buff_init TYPE c VALUE 'X'.

* Globaler Schalter für Initialisierung Datenbereiche Konfiguration
DATA: g_no_init_config_data TYPE c.

*Global switch to turn of 'Dequeue_all' in 'Beleg_Iinitialisieren'
DATA: g_no_dequeue_sd_sales TYPE c.

* Global switch to dequeue the document in case of no changes
DATA: g_no_document_changes TYPE c.

* global flag to dequeue BANF AUFK PLAF
DATA: g_dequeue_bap TYPE c.

* global switch to turn off 'ITOB_BUF_CLEANUP' in 'BELEG_SICHERN'
DATA: g_no_itob_buf_cleanup TYPE c.

* Globaler Schalter fE BANFe initialisieren, bearbeiten, sichern
* requisition_buff_init eq space --> keine BANF-Bearbeitung
DATA: requisition_buff_init TYPE c VALUE 'X'.

DATA: alternativpos_da,                " Tuning Alternativpos
      positionsvorschlag,              " Kennzeichen Positionsvorschl.
                                       " X = Auswahlliste zum Vorschl.
      prodsel_aktiv,                   " Beleg mit Produktselektion
      kopieren,                        " Kopieren, auch Pos.vorschlag
      abruf_pruefen,                   " Abruf bei Back prEen
      call_function,                   " Auftragsbearbeitung per
                                       "            Call Function
      modification_flag LIKE sado_mod_flagstring, "Process modification
      bufferread_flag   LIKE sado_buf_flagstring, "Process buffer read
      call_activity(4),                " Aktiver Aufrufer bei Call
                                       "   (z.B. Funktionsgruppe)
      call_bapi,                       " Call from BAPI (Sales Order)
      call_bapi_simulation_mode,       " Call from BAPI (Simulation)
      call_from_crm,                   " Call from CRM
      dialog_bapi,                     " Call from dialogue BAPI
      call_bapi_save,                  " Call SD_SALES_DOCUMENT_SAVE
                                       " from BAPI
      no_messages,                     " Keine Nachrichtenausgabe
      no_authority_check,              " keine BerechtigungsprEung
      call_dialog,                     " Auftragsbearbeitung per
                                       "            Call Dialog
      backorder_result,                " ErgebnisEernahme der
                                       " REkstandsauflösung (n.sperr.
      config_fcode_change,             " Modus während FCODE POCO
      costing_to_save,                 " zu sichernde Kalkulationsart
      third_party_status,              " Fakturastatus bei Strecke
      suppress_av_dialog,              " Steuerung VerfEbarkeits-Dialog
      display_text_popup,              " Steuerung Text-Popup
      display_message_popup,           " Steuerung Hinweis auf Angebote
                                       " oder Kontrakte
      fcode(20),
      old_fcode(20).
DATA: kopieren_euro_waerk LIKE vbak-waerk.

DATA: credit_check_ccard_simul_mode.   " Simulationsmodus für Kredit-
" check in Zahlungskartenanw.

DATA: fehler(1) TYPE c.                " blank: keine Fehlerbearbeitung

* Unvollständigkeit Partner-Subscreen
DATA: fehler_kpar_sub(1) TYPE c,
      fehler_ppar_sub(1) TYPE c.

DATA: yvbuv_lines LIKE sy-tabix.       " Anzahl Zeilen in YVBUV
DATA: fehlerfeld TYPE tbfdnam_vb.      " Name des fehlerhaften Feldes
DATA: active_screen LIKE sy-dynnr.     " Akt. Dynpro bei Scr.varianten
enhancement-point mv45acom_03 spots es_mv45acom static include bound.

* Felder zur Pflege von Konditionen auf Positionsbildern
* Kennzeichen, ob Konditionen gelesen wurden
DATA: konv_gelesen,
      skomv_subrc LIKE sy-subrc,
      skomv_tabix LIKE sy-tabix.
DATA: kbetr_filled(1) TYPE c.
DATA: BEGIN OF xkonvc OCCURS 50.
        INCLUDE STRUCTURE ukonvc.
DATA: END OF xkonvc.
DATA: BEGIN OF ykonvc OCCURS 50.
        INCLUDE STRUCTURE ukonvc.
DATA: END OF ykonvc.
DATA: BEGIN OF vtcomag.
        INCLUDE STRUCTURE vtcom.
DATA: END OF vtcomag.
DATA: BEGIN OF vtcomwe.
        INCLUDE STRUCTURE vtcom.
DATA: END OF vtcomwe.
DATA: BEGIN OF vtcomrg.
        INCLUDE STRUCTURE vtcom.
DATA: END OF vtcomrg.

* Internal Table for Change of Serial Number
DATA: BEGIN OF sernr_chg OCCURS 50.
        INCLUDE STRUCTURE sernr_chnge.
DATA: END OF sernr_chg.

* PrEung Anliefertermin
DATA:  checked_kunnr LIKE kuwev-kunnr,
       checked_knfak LIKE kuwev-knfak, "Zuletzt gepüfter Kalender
       checked_date LIKE vbep-edatu,   "Zuletzt geprEter Anlieferdatum
       checked_zeit LIKE vbep-ezeit.   "Zuletzt geprEter Anlieferzeit
DATA   checked_vdatu LIKE vbak-vdatu
                     VALUE '00000000'. "geprEtes Wunschlieferdatum

* Kennzeichen fE ALE, Bestätigungsstatus setze
DATA: mm_flag,           "Auftrag vom MM bestätigt oder geänder
      ale_flag,                        "ALE-Relevanz
      ale_change_flag.   "Änderungsrelevanz Auftrag fE ALE

enhancement-point mv45acom_01 spots es_mv45acom static include bound.
* Steuerung Entsperren mit Dequeue_all
* Kennzeichen, daß irgendetwas gesperrt wurde
DATA: gesperrt.

* Kennzeichen, daß Schnelländerung läuft
DATA schnellaenderung.

* SÜW (Systemübergreifender Warenfluss)
* Document has/had Item Relevant for Cross-System Flow of Goods
DATA: csfg_xvbap_logsys,
      csfg_yvbap_logsys.

* Performance Userexit COOM0003 (MV45AFZZ - USEREXIT_MOVE_FIELD_TO_VBAK)
DATA: coom0003_in_use(1) TYPE c.

* table for unmarked lines in fast change
DATA: BEGIN OF xunmark OCCURS 0,
        posnr TYPE posnr_va.
DATA: END OF xunmark.

* table for changed fields in dynamic tables
DATA: gt_dynchg TYPE STANDARD TABLE OF bapifldchg.

* PlugIn installed
DATA: pi_installed TYPE char10.
* Erster Aufruf für die Ermittlung der Abladestelle
DATA first_call_unlpoint TYPE boolean VALUE 'X'.

* Cursorposition auf Tablecontrol
DATA: tc_selline LIKE sy-stepl.

DATA  global_pricing_type LIKE t683-knprs_v.
* Sonderbehandlung EURO bei teilfakturierten Aufträgen
DATA: euro_waers LIKE tcurc-waers.
DATA: euro_active(1) TYPE c.

DATA: atp_workmode LIKE bapisdls-atp_wrkmod.
DATA: atp_basic_setting LIKE t000atp.

* RV45A-ETDAT changed manually on Dynpro
DATA: etdat_manual TYPE c.

* sold-to party changed manually on Dynpro
DATA: kunnr_upd_check TYPE c.

* sales group cleared at partner determnination
DATA: vkgrp_clear TYPE c.

* Message V1360 issued due to missing quantity
DATA: BEGIN OF ls_posnr,
        posnr TYPE vbap-posnr,
      END OF ls_posnr.
DATA: gt_v1360 LIKE TABLE OF ls_posnr WITH HEADER LINE.

* Tabstrip-Controls  EnjoySAP
DATA: uebor LIKE sy-tcode.             "Tabscrip-controls
DATA: item_detail_counter TYPE p.
DATA: header_detail_counter TYPE p.
DATA: indxkey LIKE indx-srtfd.
DATA: item_detail_screen LIKE sy-dynnr VALUE '4800'.
DATA: header_detail_screen LIKE sy-dynnr VALUE '4800'.
DATA: detail_screen LIKE sy-dynnr.
DATA: item_detail_tabix LIKE sy-tabix.

* Partner-Subscreen - Dataloss
DATA: mv45a_dataloss_par_sub LIKE r185d-dataloss.

* ZAV Memory ID
DATA: cam_memory_id TYPE i.
* CRM Lock Mode
DATA: crm_lock_mode(1) TYPE c.
* Status Flags Container Import
DATA  dialog_processed TYPE c.
DATA  dialog_check(3) TYPE c.
DATA  keep_posnr TYPE posnr.
DATA: data_read_from_archive TYPE c.
DATA: data_read_from_archive_handle LIKE sy-tabix.

* Switch-check
types:
      begin of tgs_ops_switch_check,
        ops_sfws_sc_advret1 type xfeld,
        ops_sfws_sc_advret2 type xfeld,
      end of tgs_ops_switch_check.

data: gs_ops_switch_check type tgs_ops_switch_check.

* ERP LORD
types:
      begin of tgs_text_v45a,
        object type tdobject,
        name type tdname,
        id type tdid,
        spras type spras,
        id_t type tdtext,
        spras_iso type laiso,
        spras_t type sptxt,
        type type tdtexttype,
        tabix type sytabix,
        selkz type selkz,
        multiple_lines type flag,
        handle type guid_32,
        first_tline type string,
        text_string type string,
        text_xstring type xstring,
        formatted type flag,
      end of tgs_text_v45a,
      tgt_text_v45a type table of tgs_text_v45a.
data: gv_tdname_v45a type tdname,
      gs_text_v45a type tgs_text_v45a,
      gt_text_v45a type tgt_text_v45a.
data: gf_text_display_only type flag,
      gf_xtext_display_only type flag.
data: gv_text_deflangu     type spras,
      gv_text_deflangu_iso type laiso,
      gv_text_deflangu_t   type sptxt.

DATA: gv_lord_callid TYPE char10,
      BEGIN OF gs_vtber_ext,
        kunnr TYPE kunnr,
        vkorg TYPE vkorg,
        vtweg TYPE vtweg,
        spart TYPE spart,
      END OF gs_vtber_ext.
DATA: gv_vbeln_ref_ext TYPE vbak-vbeln,
      gv_posnr_ref_ext TYPE vbap-posnr,
      gv_vbtyp_ref_ext TYPE vbak-vbtyp.
DATA: gs_cpd_address TYPE tds_cpd_address.
DATA: gf_no_messages_doc TYPE flag,
      gv_message_vbeln_ref TYPE vbeln,
      gv_message_posnr_ref TYPE posnr.
DATA: gs_screen TYPE screen.
DATA: gf_saving_abort TYPE flag.
DATA: gf_no_commit TYPE flag.
data: gf_no_init type flag.
DATA: gf_synchron TYPE flag.
DATA: gf_sapgui_mode TYPE flag.
DATA: gf_item_ref TYPE flag.
DATA: gv_besta TYPE besta,
      gv_besta_t TYPE bezei20,
      gv_posar_t TYPE val_text.
DATA: gv_edatu_last TYPE edatu,
      gv_mbdat_last TYPE mbdat,
      gv_bmeng_last TYPE bmeng.
DATA: gv_lord_scenario_id TYPE tdd_scenario_id.
DATA: gv_lord_caller_id TYPE tdd_caller_id.
DATA: BEGIN OF gs_lord_vbup_cum,
      vbeln TYPE vbeln_va,
      posnr TYPE posnr,
      wbsta TYPE wbsta,
      fksta TYPE fksta,
      END OF gs_lord_vbup_cum.
DATA: BEGIN OF gs_lord_vbup_cum_bez,
      vbeln TYPE vbeln_va,
      posnr TYPE posnr,
      wbsta_bez TYPE wbsta_bez,
      fksta_bez TYPE fksta_bez,
      END OF gs_lord_vbup_cum_bez.
DATA: BEGIN OF gs_lord_vbuk_cum,
      vbeln TYPE vbeln_va,
      wbstk TYPE wbstk,
      fkstk TYPE fkstk,
END OF gs_lord_vbuk_cum.
DATA: BEGIN OF gs_lord_vbuk_cum_bez,
      vbeln TYPE vbeln_va,
      wbstk_bez TYPE bezei20,
      fkstk_bez TYPE bezei20,
      END OF gs_lord_vbuk_cum_bez.
data: gt_posnr_swap type tdt_posnr_swap.

* LOGIC
data: gr_logic_vbak type ref to cl_logic_access.
data: gr_logic_vbap type ref to cl_logic_access.

* Data Reference
data: gr_sls_data_ref type ref to cl_sls_data_ref.

* Payment Service Provider
DATA: BEGIN OF gs_lpaysp_data,
        ps_provider      TYPE tds_lpaysp_comv-ps_provider,
        transaction_id_r TYPE tds_lpaysp_comr-transaction_id_r,
        reference_id_r   TYPE tds_lpaysp_comr-reference_id_r,
        psp_txn_id_r     TYPE tds_lpaysp_comr-psp_txn_id_r,
        txn_profile_r    TYPE tds_lpaysp_comr-txn_profile_r,
        txn_status_r     TYPE tds_lpaysp_comr-txn_status_r,
        amount_req_r     TYPE tds_lpaysp_comr-amount_req_r,
        currency_req_r   TYPE tds_lpaysp_comr-currency_req_r,
      END OF gs_lpaysp_data.
DATA: BEGIN OF gs_lpaysp_descr,
        sppaym_t         TYPE val_text,
        ps_provider_t    TYPE tds_lpaysp_comr-ps_provider_t,
        txn_profile_t    TYPE tds_lpaysp_comr-txn_profile_t ,
        txn_status_t     TYPE tds_lpaysp_comr-txn_status_t ,
      END OF gs_lpaysp_descr.
* SAP Credit Management (FIN-FSCM-CR)
DATA: gv_ukm_active,
      gv_ukm_erp2005.   "BADI ERP2005

* revenue recognition currency change
DATA: gvf_waerk_disp(1) TYPE c.

* flag texts for DP90
DATA  dp90_text.

enhancement-point mv45acom_10 spots es_mv45acom static include bound.

DATA:   END OF COMMON PART.
enhancement-point mv45acom_11 spots es_mv45acom static include bound.