*---------------------------------------------------------------------*
*       FORM BELEG_INITIALISIEREN                                     *
*---------------------------------------------------------------------*
*       Nach Sichern werden die belegrelevanten Daten initialisiert.  *
*       Die Vorschlagswerte des Anforderungsbildes werden in den Kopf *
*       übernommen.                                                   *
*---------------------------------------------------------------------*
FORM beleg_initialisieren.

  FIELD-SYMBOLS: <check>.
  DATA:
    da_vbeln LIKE vbak-vbeln VALUE IS INITIAL,
    da_banfn LIKE vbep-banfn,
    da_bnfpo LIKE vbep-bnfpo,
    da_posnr LIKE vbep-posnr,
    da_mbdat LIKE vbep-mbdat,
    da_flag VALUE chari,
    da_no_init_configuration_data,
    da_text_vbeln TYPE lv70t_ty_appl_table,
    da_fcode LIKE t185-fcode,
    i_dnact LIKE rdgdnact,
    lv_sync TYPE ddenqsync.

  if not gf_no_init is initial.
    return.
  endif.

* Reset the flag 'Save in Process'
  EXPORT da_vbeln TO MEMORY ID 'SD_SAVE_IN_PROCESS'.

  APPEND vbak-vbeln TO da_text_vbeln.

* Fcode zurücksetzen
  CLEAR sy-ucomm.
  da_no_init_configuration_data = g_no_init_config_data.
  CLEAR g_no_init_config_data.

* Kopf für Ausgabe beim Funtionsbaustein merken
  ovbak = vbak.
   *vbak = vbak.

ENHANCEMENT-POINT BELEG_INITIALISIEREN_10 SPOTS ES_SAPMV45A.
* Fall DP95
* Für BAPI auch FCODE initialisieren
  IF NOT call_function IS INITIAL.
    CLEAR default_vkbur.
    CLEAR default_vkgrp.
    CLEAR fcode.
  ENDIF.

  CLEAR: kuagv, vtcomag, tvcpa,
         kuwev, vtcomwe, save,
         kurgv, vtcomrg,
         alternativpos_da,
         bop_flag,
         prodsel_aktiv,
         rtext-sprvo,
         rv45a-koein,
         rv45a-endbp,
         rv45a-endbk,
         rv45a-mwsbk,
         rv45a-btgew,
         rv45a-ntgew,
         rv45a-gewei,
         rv45a-volum,
         rv45a-voleh,
         rv45a-vbap_selkz,
         rv45a-vbep_selkz,
         rv45a-vbsn_selkz,
         rv45a-ewert,
         rv45a-banfn,
         rv45a-bnfpo,
         rv45a-aufno,
         rv45a-plano,
         rv45a-dwerk,
         rv45a-kedatu,
         rv45a-s_ezeit,
         rv45a-ketdat,
         rv45a-etdat,
         rv45a-rb_auart,
         rv45a-rb_aauart1,
         rv45a-rb_aauart2,
         rv45a-waktion,
         rv45a-mabnr,
         rv45a-bedae,
         rv45a-ccode,
         rv45a-ccode_head,
         rv45a-prgbz,
         RV46G_DOC-KTEXT,
         rv45s,
         rv45z-abhor,
         rv45z-akffz,
         rv45z-aklfz,
         rv45z-akmfz,
         rv45z-abfnk,
         rv45z-ablnk,
         rv45z-abmnk,
         rv45z-fzdif,
         rv45z-uwmen,
         rv45z-lfmkd,
         rv45z-lfnkd,
         rv45z-abrfz,
         rv45z-liffz,
         rv45z-liffz_vorj,
         rv45z-edlfz,
         rv45z-edlfz_vorj,
         rv45z-edlfz_lf,
         rv45z-wagfz,
         rv45z-vsdmg,
         rv45z-vorrck,
         rv45z-edl_uwmen,
         rv45z-ffeint,
         rv45z-mfeint,
         rv45z-mafz,
         rv45z-mafz_vorj ,
         rv45z-ma_fzdif,
         rv45z-mafz_pu,
         rv45z-mais_uwmen,
         rv45z-mlfmng,
         rv45z-kom_ok,
         rv45z-verp_ok,
         rv45z-wab_ok,
         rv45z-lifex,
         rv45z-cust_planned_abefz,
         rv45z-edlue,
         tvgrt,
         tvkbt,
         vbak, svbak-tabix, svbap-tabix, yvbak_updkz, xvbak_updkz,
         vbkd, svbkd-tabix, kvbkd, *kvbkd,
         vbap, vbpa, xvbpa, xvbadr,
         vbapd,
         xvbap_high_posnr,
         xvbap_loeschen,
         xvbep_alle_gelesen,
         xvbsn_alle_gelesen,
         ivbap_tabix_zeile_1,
         r185d-dataloss,
         ivbap-selkz,
         ivbep-selkz,
         ivbsn-selkz,
         konv_gelesen,
         konv_geaendert,
         skomv_tabix,
         skomv_subrc,
         vbap_kopfsummen_neu,
         vbap_kzvbr_e,
         wk_abruf_exist,
         checked_date,
         checked_zeit,
         checked_kunnr,
         checked_knfak,
         kz_art_vbsn,
         upd_vbak, upd_vbuk,
         incompletion_active,
         upd_vbap, upd_vbup,
         upd_vbep,
         upd_vbsn,
         upd_vbkd,
         upd_vblb,
         material_vorstep_gelaufen,
         no_authority_check,
         no_text_copy,
**       call_activity,
         backorder_result,
         costing_to_save,
         mm_flag,
         ale_flag,
         dbcuobj,
         select_new_m_vlpma,
         gruko,
         hinweis_grp_show,
         xdcvbep,
         ydcvbep,
         prsgr,
         be_aendern,
         enthaelt_beschaffung,
         atp_workmode,
         serial_dataloss,
         tds_kunag_search_term-term,
         gv_search_term_old,
         matnr_subst.

  if cl_mmpur_switch_check=>get_serial01_switch_state( ) eq charx.
    clear gf_serial_changed.
    clear gt_serial_changed.
  endif.

* LORD-API: Init global CPD data
  IF call_activity EQ gc_activity_lord.
    CLEAR gs_cpd_address.
  ENDIF.

* dyn. Produktvorschlag deaktivieren und
* Überschrift des Table-Controls neu ermitteln.
  CLEAR: dpp_active,
         xvbap_umfang_opv,
         rv45a-cua_long.
  CASE xvbap_umfang.
    WHEN xvbap_umfang_uall. da_fcode = fcode_umfang_positionen.
    WHEN xvbap_umfang_uhau. da_fcode = fcode_umfang_hauptpositionen.
    WHEN xvbap_umfang_umar. da_fcode = fcode_umfang_markierte.
    WHEN xvbap_umfang_vbkd. da_fcode = fcode_umfang_vbkd_position.
    WHEN xvbap_umfang_post. da_fcode = fcode_umfang_struktur.
  ENDCASE.
  PERFORM d301t_select(sapmv45a) USING da_fcode.

  rv45a_uv-vggp = charx.

*                                      Dokumentenverw. initialisieren .
  IF call_function IS INITIAL.

    ASSIGN ('(SAPLCVOB)sy-subrc') TO <check>.
    IF sy-subrc = 0 .
      CALL FUNCTION 'DOCUMENT_ASSIGNMENT_REFRESH'.
    ELSE.
      ASSIGN ('(SAPLCV140)sy-subrc') TO <check>.
      IF sy-subrc = 0 .
        CALL FUNCTION 'DOCUMENT_ASSIGNMENT_REFRESH'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.
  ENDIF.

ENHANCEMENT-POINT BELEG_INITIALISIEREN_11 SPOTS ES_SAPMV45A.

  IF t180-trtyp = charh AND
     call_function = space.
    vbak-auart = *vbak-auart.
*    VTBer wird ab 4.0 stets neu via AG bzw. WE bestimmt
*    vbak-vkorg = *vbak-vkorg.
*    vbak-vtweg = *vbak-vtweg.
*    vbak-spart = *vbak-spart.
  ENDIF.

* Merkfelder für Auftraggeber und Warenempfänger zurücksetzen
  CLEAR: prf_ag, prf_we.

* Partner-Call-Back initialisieren
  PERFORM partner_call_back_in USING *vbak-vbeln
                                     *vbak-vbtyp
                                     tvak.
* Haushaltmgm. initialisieren
  CALL FUNCTION 'FM_CO_ASS_INPUT_INIT'
    EXPORTING
      i_obart = objektart_vb.

  ASSIGN ('(SAPLFYTX_TAXM)sy-subrc') TO <check>.
  IF sy-subrc = 0 .
* Externe Steuern initialisieren
    CALL FUNCTION 'EXTERNAL_TAX_DOC_REFRESH'
      EXPORTING
        i_belnr = *vbak-vbeln.
  ENDIF.
  UNASSIGN <check>.


***** DSEG ******
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
    EXPORTING
      bukrs                = *vbak-bukrs_vf
      component            = 'BR'
    EXCEPTIONS
      component_not_active = 02.
  IF sy-subrc = 0.
* Brasilien: Felder in Funktionsgruppe Auftrag Brasilien initialisieren
    CALL FUNCTION 'J_1B_SD_SA_INIT_LOCAL'
      EXPORTING
        i_vbak = *vbak.
  ENDIF.
***** DSEG *****

  CLEAR: *vbak.
  CLEAR: *vbap.

* Initialization of internal tables for output processing
  IF call_function IS INITIAL OR
     NOT call_bapi_simulation_mode IS INITIAL.
    CALL FUNCTION 'RV_MESSAGES_REFRESH'
      EXPORTING
        msg_kappl = tvak-kappl.
    CLEAR: propos.
    CLEAR xobjky.
  ELSEIF NOT call_function IS INITIAL.
    CLEAR xobjky.
  ENDIF.
* Serialnummern
  IF requisition_buff_init NE space AND
     call_activity NE activity_service_request AND
     call_activity NE activity_good_movement.
    ASSIGN ('(SAPLIPW1)sy-subrc') TO <check>.
    IF sy-subrc = 0 .
      CALL FUNCTION 'SERIAL_INTTAB_REFRESH'.
      IF cl_ops_switch_check=>mm_sfws_serno( ) EQ cl_mmpur_constants=>yes.
        CALL FUNCTION 'MMPUR_MESEN_INITIALIZE'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.
* also the buffer
    IF g_no_itob_buf_cleanup IS INITIAL.
      ASSIGN ('(SAPLITO1)sy-subrc') TO <check>.
      IF sy-subrc = 0 .
        CALL FUNCTION 'ITOB_BUF_CLEANUP'
          EXPORTING
            i_read_buffer  = charx
            i_write_buffer = charx
            i_reset_lock   = charx
          EXCEPTIONS
            not_successful = 1
            no_handle      = 2.
      ENDIF.
      UNASSIGN <check>.
    ENDIF.
  ENDIF.

  ASSIGN ('(SAPLIWOL)sy-subrc') TO <check>.
  IF sy-subrc = 0 .
    CALL FUNCTION 'IWOL_REFRESH_ALL'.
  ENDIF.
  UNASSIGN <check>.

  CLEAR:   sernr_chg.
  REFRESH: sernr_chg.

* Preisfindung initialisieren


ENHANCEMENT-SECTION     BELEG_INITIALISIEREN_14 SPOTS ES_SAPMV45A.
  CALL FUNCTION 'PRICING_REFRESH'
    TABLES
      tkomk = tkomk
      tkomv = xkomv.
END-ENHANCEMENT-SECTION.

  clear tkomp.
  refresh tkomp.

  CLEAR pos_geaendert.

* Zurücksetzen Konditionssätze für Preisvereinbarungen
  ASSIGN ('(SAPLV14A)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'RV_CONDITION_RESET'
      EXPORTING
        free_memory = charx.
* clear last_context in V14A
    CALL FUNCTION 'SD_DELETE_V14A_LAST_CONTEXT'.
  ENDIF.
  UNASSIGN <check>.

* Partnerbearbeitung initialisieren
  CALL FUNCTION 'RV_PARTNER_REFRESH'.

* Erster Aufruf für die Ermittlung der Abladestelle
  first_call_unlpoint = charx.

* Nicht bei Rückkehr aus Positionsauswahlbildern,
* da transaktionsweiter Memoryzugriff
  IF rv45a-amode NE charc AND
     positionsvorschlag EQ space.
* Textkopiererei initialisieren
    CALL FUNCTION 'RV_TEXT_COPY_REFRESH'.

* Texte aus Verbuchungsmemory löschen
    CALL FUNCTION 'SD_DELETE_TEXT_FROM_CATALOG'
      EXPORTING
        fi_caller = gc_text_appl_id-sales_document
        fit_vbeln = da_text_vbeln[]
      EXCEPTIONS
        OTHERS    = 0.

  ENDIF.

* Initialisieren Textpflege
  CALL FUNCTION 'SD_WORD_PROCESSING_INIT'.

* Eingabebereitschaft des Text Control
  text_control_ready_for_input = charx.
  CLEAR text_control_referiert.

* Banferei initialisieren
  IF requisition_buff_init NE space AND
     call_activity NE activity_service_request.

    ASSIGN ('(SAPLEBNE)sy-subrc') TO <check>.
    IF sy-subrc = 0.
      CALL FUNCTION 'ME_REFRESH_REQUISITION_EXT'.
    ELSE.
      ASSIGN ('(SAPLMMDA)sy-subrc') TO <check>.
      IF sy-subrc = 0.
        CALL FUNCTION 'ME_REFRESH_REQUISITION_EXT'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.
  ENDIF.

* Bestellbestätigung löschen
  PERFORM bestellbestaetigung(sapfv45e) USING da_banfn
                                              da_bnfpo
                                              da_posnr
                                              chard
                                     CHANGING da_mbdat.

* Statische Variable in VERIFY_FINAL_CHECK initialisieren
  PERFORM verify_final_check(sapfv45e) CHANGING da_flag.

* Fakturierungsplan initialisieren
  CLEAR: fpla, *fpla, tfpla, fplaa.
  CLEAR: fplad, *fplad.
  CLEAR xfpla. REFRESH xfpla.
  CLEAR yfpla. REFRESH yfpla.
  CLEAR upd_fpla.
  CLEAR: fplt, *fplt, tfplt.
  CLEAR xfplt.
  CLEAR: fpltd, *fpltd.
  CLEAR: upd_fplt.
  REFRESH open_values.
* Funktionsgruppe V60F initialisieren
  ASSIGN ('(SAPLV60F)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'SD_V60F_REFRESH'.
  ENDIF.
  UNASSIGN <check>.

* Kundenmaterialinformationen initialisieren
  CLEAR knmt.

* Cross-Selling initialisieren
  PERFORM cross_sell_loeschen(sapfv45p) USING posnr_low.

* Empfangsstellenfindungstabelle initialisieren
  ASSIGN ('(SAPLW45A)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'RETAIL_DOCUMENT_REFRESH'.
  ELSE.
    FREE MEMORY ID 'SD_CONFIG_COMPONENTS'.
  ENDIF.
  UNASSIGN <check>.


* Strukturinformationen initialisieren
  PERFORM struktur_xstb_refresh(sapfv45s).

* Konfiguration initialisieren / wird beim ersten Aufruf Konfig. gemacht
  rv45a-konfig_init = charx.

  CLEAR crm_subsched_data.

* Schnittstelle zu Konfig initialisieren
  CALL FUNCTION 'V45CU_INIT'
    EXPORTING
      no_init_cu = da_no_init_configuration_data.

* Initialize classification data
  IF call_function IS INITIAL AND
     call_activity NE activity_service_request AND
     call_activity NE activity_assembly.
    call function 'CLO0_DDB_INIT'.
  ENDIF.

* Montage und Kalkulation initialisieren (innerhalb VA01, VA02)
* Das Flag status_buff_init ist normalerweise immer gesetzt. Wird
* ein Auftrag über FBs angelegt, dann kann das Flag zurückgesetzt
* werden, um zu vermeiden, daß die Tabellen des rufenden Programms
* initialisiert werden.

  IF status_buff_init NE space.
    PERFORM montage_init.
* Kalkulation
    ASSIGN ('(SAPLKKE3)sy-subrc') TO <check>.
    IF sy-subrc = 0.
      CALL FUNCTION 'K_UNITCOSTING_REFRESH'.
    ELSE.
      ASSIGN ('(SAPLKKE2)sy-subrc') TO <check>.
      IF sy-subrc = 0.
        CALL FUNCTION 'K_UNITCOSTING_REFRESH'.
      ENDIF.
    ENDIF.
    UNASSIGN <check>.

    CALL FUNCTION 'CK_F_PRODUCTCOSTING_REFRESH'.

* Aufteilungsregel
    ASSIGN ('(SAPLKOBS)sy-subrc') TO <check>.
    IF sy-subrc = 0.
      CALL FUNCTION 'K_SETTLEMENT_RULE_REFRESH'
        EXPORTING
          all_refresh = charx.
    ENDIF.
    UNASSIGN <check>.

  ENDIF.

* Bedarfsübergabe initialisieren, wenn notwendig
  IF bedarf_trennen NE space.
    CALL FUNCTION 'RV_REQUIREMENT_REFRESH'.
    bedarf_trennen = space.
  ENDIF.

* Verfügbarkeit und Liefergruppen
  PERFORM mverf_init(sapfv45v).
  PERFORM mverf_init_group(sapfv45v).

* Lokale ATP
  CALL METHOD cl_latp_tool=>latp_init_pers_enq_raise_event.

* Lieferabrufdaten
  CALL FUNCTION 'SD_XVBLB_REFRESH'.

* Verpackung / Handling Units
  IF call_activity NE activity_good_movement.               "n_1254034
    CALL FUNCTION 'HU_PACKING_REFRESH'.
  ENDIF.

* Vertragsdaten
  CALL FUNCTION 'SD_XVEDA_REFRESH'.
* VEDA in SAPMV45A(change log)
  REFRESH: xveda,
           yveda.

* Refresh table: GVT_COND_SAK
  CALL FUNCTION 'SD_BILLING_SCHED_COND_REFRESH'.

* Funktionsgruppe V45I initialisieren
  IF call_bapi IS INITIAL OR
     call_bapi_simulation_mode = 'X'.
    CALL FUNCTION 'SD_V45I_REFRESH'
      EXPORTING
        i_vbeln         = ovbak-vbeln
        i_initial_vbeln = charx.
  ENDIF.

* Lieferung bei Sofortauftrag
* nicht wenn Aufruf über MB11
  IF  call_activity NE activity_good_movement AND
      call_activity NE activity_credit_recreate AND
      call_activity NE activity_service_request AND
      call_activity NE activity_service_order   AND
      call_activity NE 'CRRC'                   AND
      no_rv_delivery_init EQ space AND
      ( tvak-lisof NE space OR
        vbap_korli NE space ) .
    CALL FUNCTION 'RV_DELIVERY_INIT'
      EXPORTING
        status_buff_init = space
        i_call_activity  = call_activity
        if_no_deque      = g_no_dequeue_sd_sales.
    CLEAR vbap_korli.
  ENDIF.

* BAPI: Dequeue banf aufk plaf if no data have been changed
  IF gesperrt              = charx AND
     g_no_dequeue_sd_sales = charx AND
     g_no_document_changes = charx AND
     g_dequeue_bap         = charx.
    PERFORM dequeue_bap.
  ENDIF.

  IF call_activity NE activity_good_movement.
* BAPI: Dequeue if no data have been changed
    IF gesperrt              = charx AND
       g_no_dequeue_sd_sales = charx AND
       g_no_document_changes = charx.
      LOOP AT xvbap WHERE NOT vgbel IS INITIAL.
        PERFORM beleg_entsperren      USING xvbap-vgbel.
        PERFORM beleg_entsperren_btch USING xvbap-vgbel.
      ENDLOOP.
    ENDIF.
  ENDIF.


ENHANCEMENT-POINT BELEG_INITIALISIEREN_12 SPOTS ES_SAPMV45A.
  REFRESH: xvbeh,
           xkomv, xkonvc, ykonvc,
           xthead, ithead, reftext,
           xvbap, vvbap, uvbap, gvbap, ivbap, ivbap_pv,
           xvbepek,
           xvbpv,
           vvbrp,
           matkey,
           xvbapf,
           yvbapf,
           avbbd,
           xvbbe, yvbbe,
           xvbbs, yvbbs,
           xvbsn,
           xvbep, ivbep, ivbep1, vvbep,
           xvbsn, ivbsn, ivbsn1,
           xvbfa,
           xvbkd,
           xvbpa, xvbpa2,
           xvbup, yvbup,
           xvbuk, yvbuk,
           xvbuv, hvbuv, dvbuv,
           xvbadr,
           xfpla, xfplt,
           apo_bop_xvbep,
           dbcuobj,
           gruko,
           xdcvbep,
           ydcvbep,
           vb_key,
           purchase_data.

  REFRESH: yvbap,
           yvbsn,
           yvbep,
           yvbsn,
           yvbkd,
           yvbfa,
           yvbpa, yvbpa2,
           yvbadr, yfpla, yfplt.

  IF CALL_ACTIVITY EQ GC_ACTIVITY_LORD.
    refresh: svbep, svbap.
    clear: yvbak.
  ENDIF.

  CLEAR: xvbuk, yvbuk,
         xvbup, yvbup,
         xvbep, ivbep1, vbep.
* Status initialisieren
  CLEAR: vbuk, vbup.

* Revenue Recognition VBREVR initialize buffers.
  ASSIGN ('(SAPLVFRF)SY-SUBRC') TO <check>.
  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'SD_FIND_VBREVR_INIT'.
  ENDIF.            .
  UNASSIGN <check>.

* revenue recognition currency change
  CLEAR gvf_waerk_disp.

* im SD_XVBLB_REFRESH werden nur die in der
* Funktionsgruppe V45L liegenden XVBLB und YVBLB
* initialisiert, VBLB und *VBLB bleiben gefüllt mit
* den alten Werten. Auch XVBLB und YVBLB in SAPMV45A
* bleiben von SD_XVBLB_REFRESH unberührt. Deshalb der
* folgende CLEAR und REFRESH.
  CLEAR: vblb, *vblb, xvblb, yvblb.
  REFRESH: xvblb, yvblb.
  CLEAR: m_v4143_lab, m_v4143_fab.
* zurücksetzen globales Flag für Prüfung doppelte Lieferplanpositionen
  CLEAR select_new_m_vlpma.
* zurücksetzen globale Einteilungstabelle für Mengenprüfung MAIS
  CLEAR mais_quan_check_xvbep.
  REFRESH mais_quan_check_xvbep.

* Refresh Kreditmanagement
  CALL FUNCTION 'SD_CREDIT_REFRESH'.

* Refresh FSCM Kreditstammdaten wenn Aufruf von LORD
  if call_activity eq gc_activity_lord.
    call function 'SD_FSCM_CREDIT_REFRESH_LORD'.
  endif.

  PERFORM kredit_refresh_document(sapfv45k).

* Payment Service Provider Data
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    cl_sls_paysp_integration=>refresh( ).
    CLEAR: gr_paysp, gt_paysp_hl, gt_paysp_hl_old.
  ENDIF.

* Funktionsgruppe V45C initialisieren
  ASSIGN ('(SAPLV45C)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    PERFORM refresh_v45c(saplv45c).
  ENDIF.
  UNASSIGN <check>.

* Refresh Gruppenkontrakt
  ASSIGN ('(SAPLV46G)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'SD_GROUPCONTRACT_REFRESHDATA'.
  ENDIF.
  UNASSIGN <check>.

* Refresh Reparaturabwicklung
  ASSIGN ('(SAPLV46R)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'SD_REPAIRORDER_REFRESHDATA'
      EXPORTING
        refresh_all = charx.
  ENDIF.
  UNASSIGN <check>.

* Gefahrgutmodul prüfen und initialisieren
  ASSIGN ('(SAPLVEHS)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'SD_EHS_CHECK_ACTIVE'
      EXPORTING
        i_vbtyp    = ovbak-vbtyp
        i_vkorg    = ovbak-vkorg
        i_auart    = ovbak-auart
      CHANGING
        c_vggp     = rv45a_uv-vggp
      EXCEPTIONS
        ehs_active = 1
        OTHERS     = 2.
  ENDIF.
  UNASSIGN <check>.


* Gefahrgut: Template-Materialabwicklung prüfen und initialisieren
  MOVE-CORRESPONDING ovbak TO i_dnact.
  CALL FUNCTION 'EHS003_CHECK_TPPR_ACTIVE'
    EXPORTING
      i_dnact     = i_dnact
      i_vbtyp     = ovbak-vbtyp
    EXCEPTIONS
      tppr_active = 1
      OTHERS      = 2.

* Refresh: Ausfuhrkontrolldaten
  REFRESH: xvbex,
           yvbex.
  CLEAR:   ausfuhr_neu.

* Sofortauftrag: Lieferdaten
  IF  call_activity NE activity_good_movement AND
      call_activity NE activity_credit_recreate AND
      call_activity NE activity_service_request AND
      call_activity NE activity_service_order   AND
      call_activity NE 'CRRC'                   AND
      no_rv_delivery_init EQ space AND
      tvak-lisof NE space.
    CALL FUNCTION 'RV_DELIVERY_INIT'
      EXPORTING
        status_buff_init = status_buff_init
        i_call_activity  = call_activity
        if_no_deque      = g_no_dequeue_sd_sales.
  ENDIF.

  CLEAR no_rv_delivery_init.

* Materialstammpufferung:
  maxtz_maapv = maxtz_norm.

* Übernahme aus Konfiguration
  REFRESH xvcsdpos.
  CLEAR:  xvcsdpos, *vcsdpos.

ENHANCEMENT-POINT BELEG_INITIALISIEREN_13 SPOTS ES_SAPMV45A.
  REFRESH xvckey.
  CLEAR xvckey.

* init V1360 error tab
  REFRESH gt_v1360.
  CLEAR gt_v1360.

* Refresh für VC01
  CLEAR: call_dialog_folge.

* Initialisieren IDOC-Tabellen und Felder
  CLEAR: idoc_edidc,
         idoc_control,
         idoc_status,
         return_variables,
         serialization_info,
         idoc_number,
         text_error.

  REFRESH: idoc_control,
           idoc_status,
           return_variables,
           serialization_info,
           text_error,
           xposguid.

* Initialisieren registrierter Anwendungen
  IF NOT tuuid IS INITIAL.
    CALL FUNCTION 'INIT_EVENT_RAISE'
      EXPORTING
        tuuid  = tuuid
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

* Businessobjekt depublizieren und initialisieren
  IF NOT businessobjekt IS INITIAL.
    IF NOT ovbak-vbeln IS INITIAL.
      ASSIGN ('(SAPLSWUG)sy-subrc') TO <check>.
      IF sy-subrc = 0.
        CALL METHOD cl_gui_cfw=>flush.
        CALL FUNCTION 'SWU_OBJECT_RESTORE'
          EXPORTING
            objtype = businessobjekt
            objkey  = ovbak-vbeln.
      ENDIF.
      UNASSIGN <check>.
    ENDIF.
    CLEAR businessobjekt.
  ENDIF.
  CLEAR checked_vdatu.


* Gefahrgutprüfung
  ASSIGN ('(SAPLVEHS)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'SD_VBEPDG_REFRESH'.
  ENDIF.
  UNASSIGN <check>.

* Gefahrgut: Template-Materialabwicklung
  ASSIGN ('(SAPLVMSS)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'EHS003_DGMSD_REFRESH'
      EXPORTING
        i_vbtyp = ovbak-vbtyp
      EXCEPTIONS
        others_ = 1.

* Nachrichtensammler
    CALL FUNCTION 'SD_INIT_MESSAGES'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.
  UNASSIGN <check>.

  ASSIGN ('(SAPLVBAK)g_no_dequeue_sd_sales') TO <check>.
  IF sy-subrc = 0 AND <check> = charx.
    g_no_dequeue_sd_sales = <check>.
  ENDIF.
  UNASSIGN <check>.

  IF call_activity NE activity_good_movement.
    IF ( gesperrt = charx AND g_no_dequeue_sd_sales IS INITIAL ) OR
       ( call_bapi = charx AND call_activity = activity_atp_simulate ).

      IF call_activity EQ gc_activity_lord.
        lv_sync = 'X'.
      ENDIF.
      CALL FUNCTION 'DEQUEUE_ALL'
        EXPORTING
          _synchron = lv_sync.
* APO-Deltas abbauen
      CALL FUNCTION 'EXTERNAL_DELTA_HANDLING'
        EXPORTING
*         IM_TRGUID   =
*         IM_LOGSYS   =
          im_deltafct = charr
        EXCEPTIONS
          OTHERS      = 1.
      CLEAR: gesperrt.
    ENDIF.

* BAPI: Dequeue if no data have been changed
    IF gesperrt = charx AND
       g_no_dequeue_sd_sales = charx AND
       g_no_document_changes = charx.
      PERFORM beleg_entsperren USING ovbak-vbeln.
      PERFORM beleg_entsperren_btch USING ovbak-vbeln.
    ENDIF.
    CLEAR g_no_document_changes.
  ENDIF.

* Anwendungstrace
*  CALL FUNCTION 'PF_ASTAT_END'
*    EXCEPTIONS
*      OTHERS = 1.
*  CALL FUNCTION 'PF_ASTAT_INIT'
*    EXPORTING
*      initkey = process_salesorder
*    EXCEPTIONS
*      OTHERS  = 1.

* Aussenhandel: Dokumentengeschaeft: Initialisierungsroutinen
  ASSIGN ('(SAPLV86E)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'RV_LOC_INIT_PREPARE'.
  ENDIF.
  UNASSIGN <check>.


* Aussenhandel: Dokumentengeschaeft: Initialisieren Protokoll
*  CALL FUNCTION 'RV_FOR_TRADE_PROTOCOL_INIT'
*       EXCEPTIONS
*            OTHERS = 1.

* Aussenhandel: Gesetzliche Kontrolle: Initialisieren SLS-Daten
  ASSIGN ('(SAPLVFSP)sy-subrc') TO <check>.
  IF sy-subrc = 0.
    CALL FUNCTION 'FT_SLS_PARTNER_ADDR_MEM_INIT'
      EXPORTING
        i_base_document = '2VA'.
  ENDIF.
  UNASSIGN <check>.



* Meldung beim Kopieren von Lieferplanpositionen mit Änderungsstände in
* Einzelaufträge -> globales Flag initialisieren
  CLEAR m_v1894.

* Feldauswahl VA90/DP90 Folgebeleg
  gsv_screen_input = 2.

* Nachrichtentabelle XNAST initialisieren (wird benötigt zur Anzeige
* der Nachrichten vorm Sichern im Beleg
  CLEAR: xnast,
         ynast.
  REFRESH: xnast,
           ynast.

* Sonderbehandlung EURO bei teilfakturierten Aufträgen
  CLEAR euro_waers.
  CLEAR euro_active.
* check expired currency ?
  CLEAR check_expired_currency.
  CLEAR checked_currency.
* ZAV
  CLEAR cam_memory_id.

* Auftragsstückliste Prüfung.
  CLEAR: kdst_read.

* KUNDENAUFTRAGSBESTAND Prüfung.
  CLEAR: mska_read.
ENHANCEMENT-POINT BELEG_INITIALISIEREN_02 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT BELEG_INITIALISIEREN_01 SPOTS ES_SAPMV45A.
* refresh KNVV buffer
  CALL FUNCTION 'KNVV_REFRESH_BUFFER'.
* refresh KNVI buffer
  CALL FUNCTION 'KNVI_REFRESH_BUFFER'.

ENHANCEMENT-POINT SAPMV45A_30 SPOTS ES_SAPMV45A.

* Close Archive
  IF     data_read_from_archive        =  charx   AND
     NOT data_read_from_archive_handle IS INITIAL.
    CALL FUNCTION 'ARCHIVE_CLOSE_FILE'
      EXPORTING
        archive_handle = data_read_from_archive_handle.
    IF call_activity EQ gc_activity_lord.
*     Lean Order: After having closed the archive file, we have to
*     invalidate the global archive variables, accordingly
      CLEAR:
        data_read_from_archive,
        data_read_from_archive_handle.
    ENDIF.
  ENDIF.

* Refresh data in function group INTTAB_ANALYZE
  INCLUDE MV45AF0B_REFRESH_XYTAB.                     " INTTAB_ANALYZE
* Read table TPARAMS_SD
* Set variable GV_INTTAB_ANALYZE in function group INTTAB_ANALYZE
  INCLUDE MV45AF0B_READ_TPARAMS_SD.                   " INTTAB_ANALYZE

* SÜW (Systemübergreifender Warenfluss)
* Cross-System Flow of Goods
  CLEAR: csfg_xvbap_logsys,
         csfg_yvbap_logsys.

* Clear dynamic change table
  REFRESH gt_dynchg.

* Clear Plug In Installed
  CLEAR pi_installed.

* begin note 763656
  CALL FUNCTION 'WTAD_ADDIS_IN_SO_INIT'.
* end note 763656

* Init CPE Formula Documents
  CALL FUNCTION 'CPE_ERP_FORMULA_INIT'
    EXCEPTIONS
      cpe_not_active          = 0
      formula_init_terminated = 0
      OTHERS                  = 0.

  if /CBAD/CL_SWITCH_CHECK=>/CBAD/SD_SFWS_SC1( ) eq abap_true.
*   Contract and Billing
    CALL METHOD /CBAD/CL_MESSAGE_LOG=>REFRESH_LOG.
  endif.

* LOGIC
  perform beleg_init_logic.

* Call SD Sales BAdI
  DATA: l_sd_sales_exit   TYPE REF TO if_ex_badi_sd_sales,
        active TYPE xfeld.
  CALL FUNCTION 'GET_HANDLE_SD_SALES'
    IMPORTING
      handle = l_sd_sales_exit
      active = active.
  IF active = charx.
    CALL METHOD l_sd_sales_exit->document_init
      EXPORTING
        ft180 = t180
      CHANGING
        fvbak = ovbak.
  ENDIF.

* refresh structure for conditions which have entered / changed
* manually or via BAPI
  FIELD-SYMBOLS <komv> TYPE komv.
  ASSIGN ('(SAPFV45P)komv') TO <komv>.
  IF sy-subrc = 0.
    CLEAR <komv>.
    UNASSIGN <komv>.
  ENDIF.

* Funktionsgruppe V45K initialisieren
  CALL FUNCTION 'SD_V45K_REFRESH'.

ENHANCEMENT-POINT BELEG_INITIALISIEREN_20 SPOTS ES_SAPMV45A.

* ERP: lean Order
  CLEAR gv_vbeln_ref_ext.
  CLEAR gv_vbtyp_ref_ext.

* Advanced Returns
  CLEAR gt_msr_sales_fastchange.
  CLEAR gs_msr_sales_fastchange.
  CLEAR gs_msr_sales_item.
  CLEAR gs_item_default.
  CLEAR gr_msr_sales.
  IF fcode = fcode_sichern AND t180-trtyp = 'H'.
    PERFORM msr_init.
  ENDIF.

* Userexit zum intialisieren
  PERFORM userexit_refresh_document.

ENHANCEMENT-POINT EHP_BELEG_INITIALISIEREN_01 SPOTS ES_SAPMV45A.

ENDFORM.                    "BELEG_INITIALISIEREN