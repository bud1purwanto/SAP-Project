***********************************************************************
*                                                                     *
* Bearbeiten Lieferungen : Belege sichern                             *
*                                                                     *
* Verwendung  in  :  SAPMV50A                                         *
*                 :  SAPLV50S                                         *
*                                                                     *
***********************************************************************

* Please add new includes in ALPHABETICAL order! (must be difficult)

* A
INCLUDE fv50xf0b_address_renumber_post.
INCLUDE fv50xf0b_adressen_umschluessel."n
INCLUDE fv50xf0b_apo_build_sdfields.
INCLUDE fv50xf0b_apo_build_sdsourcing.
INCLUDE fv50xf0b_apo_sdfields.
INCLUDE fv50xf0b_apo_sdfields_osta.
INCLUDE FV50XF0B_APO_UPDATE_WITHOUT_RE.
INCLUDE fv50xf0b_appointments_buchen.
* B
INCLUDE fv50xf0b_b_abhaengige_tabellen.
INCLUDE fv50xf0b_bapi_dlv_change_simu.
INCLUDE fv50xf0b_batchsplit_incomplete."_check
INCLUDE fv50xf0b_batchsplit_kcmeng_cor."
INCLUDE fv50xf0b_beleg_daten_init.
INCLUDE fv50xf0b_beleg_daten_init_afte."rwards
INCLUDE fv50xf0b_beleg_kommiliste_anst."ossen
INCLUDE fv50xf0b_beleg_kompl_check. "..._komplettlieferungscheck
INCLUDE fv50xf0b_beleg_kompl_pruef. "..._komplettlieferung_pruefen
INCLUDE fv50xf0b_beleg_nachrichten_v2.
INCLUDE fv50xf0b_beleg_neuterminieren.
INCLUDE fv50xf0b_beleg_lagernummer_set."zen
INCLUDE fv50xf0b_beleg_sichern.
INCLUDE fv50xf0b_beleg_sichern_vorbere."iten
INCLUDE fv50xf0b_beleg_verteilung_prue."fen
INCLUDE fv50xf0b_bestellmenge_lesen.
INCLUDE fv50xf0b_bestellung_aktualisie."ren
INCLUDE fv50xf0b_billing_check.
INCLUDE fv50xf0b_bte_00501015_call.
ENHANCEMENT-POINT fv50xf0b_01 SPOTS es_fv50xf0b STATIC INCLUDE BOUND.
INCLUDE fv50xf0b_buffer_refresh_delive."ry
* C
INCLUDE fv50xf0b_call_badi_save_doc_pr."ep
INCLUDE FV50XF0B_CHECK_APO_UPDTRIGGER.
INCLUDE fv50xf0b_check_change_manageme."nt
INCLUDE fv50xf0b_create_inspection_lot.                "Prüflos für HUM
* D
INCLUDE fv50xf0b_decentral_picking_che."ck
INCLUDE fv50xf0b_del_final_check_lgnum.
INCLUDE fv50xf0b_delivery_final_determ."inations
INCLUDE fv50xf0b_delivery_publish.
INCLUDE fv50xf0b_dialog_protocol.                           "n_704387
INCLUDE fv50xf0b_dlv_maint_permission.
* F
INCLUDE fv50xf0b_fill_lt_text_vbeln.
* I
INCLUDE fv50xf0b_ibdlv_obdlv_docflow.                  "Worklfow HUM
INCLUDE fv50xf0b_inb_deliv_rec_point_c."heck
INCLUDE fv50xf0b_inspection_lot_renumb.                      "50A
* L
INCLUDE fv50xf0b_lieferung_rename.
INCLUDE fv50xf0b_lieferung_set_get_set."zen
INCLUDE fv50xf0b_lieferung_statistiken."_buchen
INCLUDE fv50xf0b_lieferungen_buchen.
INCLUDE fv50xf0b_lieferungstab_sortier. "...tabellen_sortieren
* M
INCLUDE fv50xf0b_maintain_aedat.
INCLUDE fv50xf0b_mot_capacity_check.
* N
INCLUDE fv50xf0b_nachrichten_buchen.
INCLUDE fv50xf0b_nachrichten_vse_buche."n
INCLUDE fv50xf0b_not_supported_scenari."o_check
INCLUDE fv50xf0b_nummernvergabe_kondit."ionen
INCLUDE fv50xf0b_nummernvergabe_liefer."ung
INCLUDE fv50xf0b_nummernvergabe_xblnr.
* P
INCLUDE fv50xf0b_packing_consistency_c."check
* S
INCLUDE fv50xf0b_safe_keeping. "GTS Safe Keeping
INCLUDE fv50xf0b_sammelgangsprotoll_sc."hreiben
* Line deleted n_533730/551329
INCLUDE fv50xf0b_sd_mob_client_update.
INCLUDE fv50xf0b_sd_monitor_protocol_s."ave
INCLUDE fv50xf0b_ship_info_to_atpfield.
INCLUDE fv50xf0b_sll_document_transfer.
* T
INCLUDE fv50xf0b_text_determination_co."mplete              "n_610917
INCLUDE fv50xf0b_text_memory_init.
* V
INCLUDE fv50xf0b_vbbed_apo_fuellen.   "APO Intergration
INCLUDE fv50xf0b_vbsk_aktualisieren.
INCLUDE fv50xf0b_versandtermine_buchen.
* W
INCLUDE fv50xf0b_wf_ibdlv_from_obdlv.                              "HUM
INCLUDE fv50xf0b_wm_update_packing.                                "HUM
* X
INCLUDE fv50xf0b_xlikp_aus_likp_fuelle."n
INCLUDE fv50xf0b_xsi_get_carrier_data.
* Y
INCLUDE fv50xf0b_yvbbe_apo_rework.

* Billing of Replenishment Deliveries
INCLUDE /spe/sto_deliv_f03. "/spe/condition_number_get

* additional ROC filter criteria
INCLUDE /spe/sto_roc_f01. "/spe/add_filter_criteria

*SPE OUTB additional fields for APO requirement update
INCLUDE /spe/v50sf08 IF FOUND.     "spe_add_field_for_requirement
INCLUDE /spe/v50sf0  IF FOUND.     "spe_ship_data_to_atpfield

*SPE OUTB additional field for APO key completion
INCLUDE /spe/lsse_erpf01. "/spe/sse_scrap_ind

* additional filter criteria for DIRDLV delivery
INCLUDE /spe/dirdlv_roc_f01.