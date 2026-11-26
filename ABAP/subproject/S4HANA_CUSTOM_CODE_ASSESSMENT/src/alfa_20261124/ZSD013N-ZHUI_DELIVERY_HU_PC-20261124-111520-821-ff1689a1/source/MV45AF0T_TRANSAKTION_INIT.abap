*---------------------------------------------------------------------*
*       FORM TRANSAKTION_INIT                                         *
*---------------------------------------------------------------------*
*       Startwerte der Transaktion auf dem Anforderungsbild setzen.   *
*---------------------------------------------------------------------*
form transaktion_init using us_tcode.

ENHANCEMENT-POINT TRANSAKTION_INIT_10 SPOTS ES_SAPMV45A.
  data: ti_error.
  data: da_text_vbeln type lv70t_ty_appl_table.
  data: tabname(30) type c value 'NDISYSTEMS'.
  data: begin of wa_ndisyst,
          logsys(10) type c,
          type(10)   type c,
          ndirel(4)  type c,
        end of wa_ndisyst.
  data: l_sd_sales_exit   type ref to if_ex_badi_sd_sales,
        active type xfeld.
ENHANCEMENT-POINT TRANSAKTION_INIT_01 SPOTS ES_SAPMV45A.
* Programme laden, weil sonst die Tabellendaten bei Modulaufrufen
* aus dem Modul Fcode nicht bekannt sind.
  perform dummy(sapfv45c).
  perform dummy(sapfv45k).
  perform programm_laden(sapfv45e).
  perform programm_laden(sapfv45p).
  perform programm_laden(sapfv45s).
* Key für Initialisierung
ENHANCEMENT-POINT TRANSAKTION_INIT_02 SPOTS ES_SAPMV45A.
  clear tuuid.
  if call_function is initial.
    call function 'INIT_EVENT_MASTER_TUUID_GET'
      importing
        tuuid  = tuuid
      exceptions
        others = 2.
  endif.

* Catt aktiv ?
  import cattaktiv from memory id 'CATT'.
  if sy-subrc > 0.
    clear cattaktiv.
  endif.

* Clear double click fcode
  clear gl_fcode.

* Bei allen Datenbankzugriffen wird mit den Feldern VBAK-MANDT
* und VBAK-VBELN gearbeitet.
  vbak-mandt = sy-mandt.

* Laufzeitinformation (Hell, Dunkel, Batch, Call Modus)
  call function 'BDC_RUNNING'
    importing
      bi_info = bi_info          " A=Hell, E=Fehler, N=Dunkel
    exceptions
      others  = 1.

* Sonderlogik für Hintergrundverarbeitung global abschalten
  get parameter id 'SD_BACKGROUND_DEBUG' field background_debug.

* Gruppenverfügbarkeitsprüfung (APO-Liefergruppenkorrelation)?
  select single * from t000atp into atp_basic_setting.
  do 1 times.
    IF CALL_FUNCTION EQ CHARX AND
       CALL_ACTIVITY NE GC_ACTIVITY_LORD.
      check atp_basic_setting-grp_call_fun eq charx.
    endif.
    if bi_info-bdc_amodus eq charn
    or bi_info-ctu_amodus eq charn
    or bi_info-cdu_amodus eq charn.
      check atp_basic_setting-grp_bdc_back eq charx.
    endif.
* Prüfen, ob PlugIn aktiv ist
    call function 'ND_EXITS_ACTIVE_CHECK'
      exceptions
        exits_not_active = 1
        others           = 2.
    check sy-subrc eq 0.
* Prüfen, ob ein APO-System mit Release >= 31 angeschlossen ist
    call function 'DDIF_NAMETAB_GET'
      exporting
        tabname   = tabname
      exceptions
        not_found = 1
        others    = 2.
    check sy-subrc eq 0.
    select single * into wa_ndisyst from (tabname)
           where type eq 'SAP_APO   ' and ndirel ge '31  '.
    check sy-subrc eq 0.
    atp_gruppenaufruf = charx.
  enddo.

* Anwendungszeitmessung initialisieren
  call function 'PF_ASTAT_INIT'
    exporting
      initkey = process_salesorder
    exceptions
      others  = 1.

* Defaultwerte aus T180 lesen und interpretieren
  perform t180_interpretieren using us_tcode.

* Container für Auftragsanlage aus Container einlesen
  perform container_import.

* Je nach Transaktionstyp gewisse Fcodes deaktivieren: Tabelle füllen
  if call_function = space.
    perform exclude_function_trtyp.
  endif.

* GUI-Redesign 4.0: Tabelle der Bildgruppen initialisieren
  perform taxi_screen_groups_init.

* Dynamisch Schlüsselwörter und Texte setzen
  perform schluesselworte_setzen using t180-trvog.

* IDOC und Batch-Input, Initialisieren hier, da nach COMMIT WORK
* BELEG_SICHERN die Routine BELEG_INITIALISIEREN nicht mehr laeuft
* und somit Daten des global Memory stehen blieben
  if ( sy-binpt ne space
       or call_activity eq 'CRRE'
       or call_activity eq 'CRRC' ) and
     call_activity ne activity_purchase and
     call_activity ne activity_assembly.


* Montage und Kalkulation initialisieren
* Das Flag status_buff_init ist normalerweise immer gesetzt. Wird
    if status_buff_init ne space.
      perform montage_init.
* Kalkulation
      call function 'K_UNITCOSTING_REFRESH'.
      call function 'CK_F_PRODUCTCOSTING_REFRESH'.
* Aufteilungsregel
      call function 'K_SETTLEMENT_RULE_REFRESH'
        exporting
          all_refresh = charx.
    endif.

* Delete texts from the last document in call transaction mode.
    data: da_vbeln_save like vbak-vbeln.
    import da_vbeln_save
           from memory id container_sales_doc.
    if not da_vbeln_save is initial.
      append da_vbeln_save to da_text_vbeln.
    endif.

  endif.

* Unter PBO stehen die GPA-Werte noch nicht zur Verfuegung
* Beim Anlegen werden die Parameter aus dem Memory geholt.
* Nur wenn die Werte nicht initial sind, sonst werden im Funktionsbau-
* steinmode die Eingaben überschrieben.
  if call_function = space.
    if t180-trtyp = charh.
      if vbak-auart is initial.
        perform vbak-auart_get_parameter(sapfv45k).
      endif.
      if t180-trvog ne charb and
         call_dialog is initial.
        if vbak-vkorg is initial.
          get parameter id 'VKO' field vbak-vkorg.
        endif.
        if vbak-vtweg is initial.
          get parameter id 'VTW' field vbak-vtweg.
        endif.
        if vbak-spart is initial.
          get parameter id 'SPA' field vbak-spart.
        endif.
        if vbak-vkbur is initial.
          get parameter id 'VKB' field vbak-vkbur.
        endif.
        if vbak-vkgrp is initial.
          get parameter id 'VKG' field vbak-vkgrp.
        endif.
      endif.
* Default Tabelle TVAK lesen
      if vbak-auart ne space.
        perform tvakt_select using vbak-auart
                                     ti_error
                                     sy-subrc.
      endif.

* Default Text zur Verkaufsorganisation lesen
      if vbak-vkorg ne space.
        perform tvko_select using vbak-vkorg
                                    ti_error
                                    sy-subrc.
        perform tvkot_select using vbak-vkorg
                                     ti_error
                                     sy-subrc.
      endif.

* Default Text zum Vertriebsweg lesen
      if vbak-vtweg ne space.
        perform tvtwt_select using vbak-vtweg
                                     ti_error
                                     sy-subrc.
      endif.

* Default Text zur Sparte lesen
      if vbak-spart ne space.
        perform tspat_select using vbak-spart
                                     ti_error
                                     sy-subrc.
      endif.

* Default Text zur Verkäufersgruppe lesen
      if vbak-vkbur ne space.
        perform tvkbt_select using vbak-vkbur
                                     ti_error
                                     sy-subrc.
      endif.

* Default Text zur Verkäufersgruppe lesen
      if vbak-vkgrp ne space.
        perform tvgrt_select using vbak-vkgrp
                                     ti_error
                                     sy-subrc.
      endif.
    elseif call_dialog = space.
* Ansonsten wird die Belegnummer vorgeschlagen
* Bei Call Dialog soll es aber nicht passieren
* (Anzeige über Call Dialog)
      perform vbak-vbeln_get_parameter(sapfv45k).
    endif.

* Definition des Standardfunktionscodes: ENT2: auf Dynpro bleiben
    fcode = fcode_anforderung.
  endif.

* Aussenhandel: Dokumentengeschaeft: Initialisierungsroutinen
  call function 'RV_LOC_INIT_PREPARE'.

* Aussenhandel: Dokumentengeschaeft: Initialisieren Protokoll
*  CALL FUNCTION 'RV_FOR_TRADE_PROTOCOL_INIT'
*       EXCEPTIONS
*            OTHERS = 1.

ENHANCEMENT-POINT TRANSAKTION_INIT_11 SPOTS ES_SAPMV45A.
* Aussenhandel: Gesetzliche Kontrolle: Initialisieren SLS-Daten
  call function 'FT_SLS_PARTNER_ADDR_MEM_INIT'
    exporting
      i_base_document = '2VA'.

* Ab Release 99A: Text Control ist für alle Systemtypen verfügbar
  perform text_control_tr_init.

* ZAV Memory IMPORT
  if cam_memory_id > 0.
    call function 'ADDR_MEMORY_NEW_ROLL_AREA'
      exporting
        memory_stack_top = cam_memory_id.
    call function 'ADDR_MEMORY_RESTORE'
      exceptions
        memory_stack_empty = 1
        internal_error     = 2
        others             = 3.
    if sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.
  endif.

* Initialisieren Textmemory and Pricing Agreements
  if call_activity <> activity_invoice_request and
     call_activity <> activity_service_request and
     call_activity <> activity_service_order   and
     call_activity <> activity_rebate_set      and
     call_activity <> activity_bapi_copy       and
     call_activity <> activity_assembly.

    import catalog from memory id 'SAPLSTXD'.
    if sy-subrc = 0.
      append vbak-vbeln to da_text_vbeln.

      call function 'SD_DELETE_TEXT_FROM_CATALOG'
        exporting
          fi_caller = gc_text_appl_id-sales_document
          fit_vbeln = da_text_vbeln[]
        exceptions
          others    = 0.

      call function 'RV_CONDITION_RESET'
        exporting
          free_memory = charx.

    endif.
  endif.

* globale Flags für Berechtigungsprüfungen im CUA_EXCLUDE initialisieren
  perform cua_exclude_auth_check_init.

* Initialize batch data & batch selection criteria
  if call_function is initial and
     call_activity is initial.
    call function 'VB_INIT'
      exporting
        init_reset = charx.
  endif.
  call function 'VB_INIT'.

* init configuration
  if call_activity ne activity_assembly and
     call_activity ne activity_purchase and
     call_activity ne activity_service_order and
     call_activity ne activity_global_trade.
    call function 'CUCB_INITIALIZER'.
  endif.

* refresh parameter effectivity
  call function 'TECHS_DATA_RESET'.

* clear temp. adrnr
  if data_read_from_archive = charx.
    data: da_address_handle like szad_field-handle.
    loop at xvbpa where adrnr(1) = '$'.
      da_address_handle = xvbpa-adrnr.
      call function 'ADDR_SINGLE_RESET'
        exporting
          address_handle   = da_address_handle
        exceptions
          number_not_found = 1
          handle_not_found = 2
          parameter_error  = 3
          internal_error   = 4
          others           = 5.
    endloop.
  endif.

* revenue recognition currency change
  clear gvf_waerk_disp.

* VA03 für archivierte Belege
  clear data_read_from_archive.

* Refresh data in function group INTTAB_ANALYZE
  INCLUDE MV45AF0T_REFRESH_XYTAB.                     " INTTAB_ANALYZE
* Read table TPARAMS_SD
* Set variable GV_INTTAB_ANALYZE in function group INTTAB_ANALYZE
  INCLUDE MV45AF0T_READ_TPARAMS_SD.                   " INTTAB_ANALYZE

* check if sd_sfws_sc2 is switched on and special archiving is active
  if not cl_ops_switch_check=>sd_sfws_sc2( ) is initial.
    clear gv_vbak_special_archiving.
    call function 'SD_VBAK_SPECIAL_ARCHIVING'
      importing
        ev_special_archiving = gv_vbak_special_archiving.
  endif.

  if /CBAD/CL_SWITCH_CHECK=>/CBAD/SD_SFWS_SC1( ) eq abap_true.
*   Contract and Billing
    CALL METHOD /CBAD/CL_MESSAGE_LOG=>REFRESH_LOG.
    CALL METHOD /CBAD/CL_MESSAGE_LOG=>CREATE_LOG.
  endif.

* switches
  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    gs_ops_switch_check-ops_sfws_sc_advret1 = charx.
  endif.
  if cl_ops_switch_check=>ops_sfws_sc_advret2( ) eq charx.
    gs_ops_switch_check-ops_sfws_sc_advret2 = charx.
  endif.

* Call SD Sales BAdI

  call function 'GET_HANDLE_SD_SALES'
    importing
      handle = l_sd_sales_exit
      active = active.
  if active = charx.
    call method l_sd_sales_exit->transaction_init
      exporting
        ft180     = t180
        factivity = call_activity
      changing
        fvbak     = vbak.
  endif.

  gr_sls_data_ref = cl_sls_data_ref=>create_instance( ).
  if not gr_sls_data_ref is initial.
    call method gr_sls_data_ref->set_data_ref
      exporting
        is_t180  = t180
        is_vbak  = vbak
        is_vbap  = vbap
        is_xvbap = xvbap
        it_xvbap = xvbap[]
        is_vbkd  = vbkd
        is_xvbkd = xvbkd
        it_xvbkd = xvbkd[]
        it_xvbpa = xvbpa[]
        is_tvak  = tvak
        is_tvap  = tvap
        is_vbuk  = vbuk
        is_vbup  = vbup
        is_xvbup = xvbup
        it_xvbup = xvbup[]
        is_xvbep = xvbep
        it_xvbep = xvbep[]
        it_ivbep1 = ivbep1[].
  endif.

endform.                    "TRANSAKTION_INIT