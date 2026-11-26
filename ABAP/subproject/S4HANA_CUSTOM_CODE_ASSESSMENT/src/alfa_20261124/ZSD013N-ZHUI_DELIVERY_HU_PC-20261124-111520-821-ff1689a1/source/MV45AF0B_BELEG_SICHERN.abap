*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN                                            *
*---------------------------------------------------------------------*
*       Beleg an Protokolldatei übergeben                             *
*       Anschliessend wird der Beleg initialisiert                    *
*       CH_SUBRC = 0: alles ok                                        *
*       CH_SUBRC = 4: Es wurde nicht gesichert, sondern ins Fehlerpr. *
*                     verzweigt oder auf dem Popup Abbrechen gedrückt *
*---------------------------------------------------------------------*
form beleg_sichern using us_syncron
                         ch_subrc.

  data:
    da_vbeln       like vbak-vbeln,
    da_yvbeln      like vbak-vbeln,
    da_pab_inc     type c,
    da_vbeln_save  like vbak-vbeln,
    da_vbeln_ext   like vbak-vbeln,
    da_subrc       like sy-subrc,
    da_subrc_lf    like sy-subrc,
*---------------------------------------------------------------------*
* Definition Returncode SUBRC_LF (Sofortlieferung = Immediate Delivery)
*  0 = OK
*  1 = Kundenauftrag schon beliefert = Sales order already delivered
*  4 = Löschen Beleg / Kein Sofortauftrag / Lieferunvollständigkeit
*    = Delete document / No rush order / Incomplete concerning delivery
* 12 = Keine Lieferposition erzeugt = No delivery item created
* 16 = Lieferung erzeugt, aber nicht für alle relevanten Positionen
*    = Delivery created, but not for all relevant items
* 90 = Korrekturlieferung - WA-Buchen = Correction delivery - Post GI
* 91 = Auslieferungsauftrag-Korrektur = Delivery order correction
* 98 = Anlegen OK - Mehr als eine Lieferung gesichert
*    = Create OK - More than one delivery saved
* 99 = Anlegen OK - Sichern gescheitert = Create OK - Save failed
*---------------------------------------------------------------------*
    lt_xvbap_modify_requirements like xvbap occurs 0 with header line,
    lt_yvbap_modify_requirements like yvbap occurs 0 with header line,
    da_text_vbeln   type lv70t_ty_appl_table,
    da_edi_stop(1)  type c,
    da_numki        like tvak-numki,
    da_fmbdat       like vbak-fmbdat,
    xobjart         like tvak-objart_hin,
    xobjid          like sapb-sapobjid,
    da_objkey       like sweinstcou-objkey,
    da_container    like swcont occurs 0 with header line.

* start Revenue Recognition Project
  data: lvf_subrc like sy-subrc.
  data: lvs_komk like komk.
  data: lvs_yvbuk like vbukvb.
  data: lvf_rev_rec_active type xfeld,
        lvt_xvbup type vbupvb occurs 0 with header line,
        lvf_vbuk_changed type xfeld.
* end   Revenue Recognition Project

* VPRS Update process
  data: lo_vprs_update_process type ref to cl_vprs_update_process.

* Hilfstabellen Auftragseingang Zulieferer
  data: da_xvbep like xvbep occurs 0 with header line,
        da_yvbep like yvbep occurs 0 with header line,
        da_ivbep like ivbep occurs 0 with header line.

enhancement-point beleg_sichern_10 spots es_sapmv45a static.
* Hilfstabellen für Funktionsbausteinaufrufe mit Tabelle XQTVB
* ohne POSTGUID
  data: lt_xqtvb like qtvbd occurs 0.

  data: l_sd_sales_exit   type ref to if_ex_badi_sd_sales,
            active type xfeld.

* SÜW (Systemübergreifender Warenfluss)
* Local tables for Batch Determination in Cross-System Flow of Goods
  data: lt_allocations     type bapi3060_allocations,
        lt_valuations_char type bapi3060_valuations_char,
        lt_valuations_curr type bapi3060_valuations_curr,
        lt_valuations_num  type bapi3060_valuations_num.
* Local CSFG info structure
  data: ls_csfg_info type csfgt_info_dyn.
  data: da_no_dialog type c.

  data: lv_abort_save type xfeld.
  data: ls_message type bapiret2,
        lt_message type bapirettab,
        lv_message type string.

enhancement-point beleg_sichern_04 spots es_sapmv45a static.
* damit beim Unvollständigkeitsdialog die VBLB-Daten erhalten bleiben
* und nicht vom unten folgenden CLEAR VBLB gelöscht werden - CLEAR
* wurde eingebaut wegen Verbuchungsabbrüchen bei Anlegen Abruf und
* Liefersperre in der Position
  local: vblb,
         svblb_subrc,
         svblb_tabix.
  local: gv_msr_error.

  if vbak-abdis ne space.
    call function 'SD_XVBLB_YVBLB_GET_FOR_UPDATE'
      tables
        fxvblb = xvblb
        fyvblb = yvblb
      exceptions
        others = 0.

* Wenn es sich um einen EDL-Lieferplan mit Feinabrufen handelt, muß
* der Feinabrufhorizont hier geprüft werden, da er zwar als Mußfeld
* definiert, auf dem Einteilungsbild aber nicht vorhanden ist und
* deswegen ungefüllt sein kann.
    if vbak-abdis ne chare and
       ( vbak-vbtyp eq vbtyp_lp_edl or
         vbak-vbklt eq vbklt_lp_edl   ).
      loop at xvblb where abart eq abart_fab    and
                          abrli eq abrli_low    and
                          updkz ne updkz_old    and
                          updkz ne updkz_delete and
                          abhor is initial.
        message i328(v4) with xvblb-posnr.
      endloop.
      if sy-subrc eq 0.
*     Lieferplan nicht sichern, bei Feinabrufen ohne Feinabrufhorizont
        fcode = fcode_gleiche_seite.
        perform fcode_bearbeiten.
        ch_subrc = 4.
        exit.
      endif.
    endif.
* Planabruf prozessieren
* Planing delivery schedule processing
    loop at xvbap where updkz ne updkz_delete.
      svbap-tabix = sy-tabix.
      perform planabruf_pruefen(sapfv45l) using da_pab_inc.
    endloop.
    if da_pab_inc eq charx.
*   Lieferplan nicht sichern, bei unvollständigem Planabrufen
*   planing del.schedule incomplete, no saving of schedule agreement
      fcode = fcode_gleiche_seite.
      perform fcode_bearbeiten.
      ch_subrc = 4.
      exit.
    endif.

  endif.

* Sicherheitsabfrage, da Aufruf auch aus VA03, Folgefunktion->Lieferung
  check t180-trtyp ne chara.

* SD Save in Process (will be cleared in BELEG_INITIALISIEREN)
  if vbak-vbeln is initial.
    da_vbeln = 'XXXXXXXXXX'.
  else.
    da_vbeln = vbak-vbeln.
  endif.
  export da_vbeln to memory id 'SD_SAVE_IN_PROCESS'.

* Damit "Save in Process" im Fehlerfall auch wieder ausgeschaltet wird.
  do 1 times.

    fehler = space.
* Unvollständigkeit Partner-Subscreen - Fehlerflags initialisieren
    clear: fehler_kpar_sub,
           fehler_ppar_sub.


enhancement-point beleg_sichern_02 spots es_sapmv45a.
    if not vbak-abdis is initial.
* bei Lieferplänen für Zulieferer wird XVBEP und YVBEP
* zwischengespeichert, da diese für den Auftragseingang im Original-
* zustand benötigt werden und der nachfolgende XVBEP_ZUORDNEN die
* Tabellen verändert (der muß aber für die Ermittlung des Änderungs-
* datums trotzdem laufen, da er die wirklich geänderten Einteilungen
* ermittelt
      da_xvbep[] = xvbep[].
      da_yvbep[] = yvbep[].
      da_ivbep[] = ivbep[].
* Einteilungen zuordnen
      perform xvbep_zuordnen(sapfv45e).
* ggf. Änderungsdatum setzen
      perform aedat_setzen_abruf(sapfv45l).
* zwischengespeicherte Tabellen zurückholen
      xvbep[] = da_xvbep[].
      yvbep[] = da_yvbep[].
      ivbep[] = da_ivbep[].
    else.
      perform xvbep_zuordnen(sapfv45e).
    endif.

    perform ivbep1_anlegen_alle(sapfv45e).

* Gefahrgut: Ermitteln von Gefahrgutstammsätzen für Template-Material
*            Abwicklung
    perform dgmsd_determine changing da_subrc.
    if da_subrc >= 2.
      if call_function is initial.
        fcode = fcode_gleiche_seite.
        perform fcode_bearbeiten.
        ch_subrc = 4.
        exit.
      else.
        message id sy-msgid type 'E' number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

* Gefahrgutprüfung
    perform gg_sichern_pruefen changing da_subrc.
    if da_subrc >= 5.
      if call_function is initial.
        fcode = fcode_gleiche_seite.
        perform fcode_bearbeiten.
        ch_subrc = 4.
        exit.
      else.
        if call_activity eq gc_activity_lord.
          message id sy-msgid type 'W' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          message_collect_lord.
          message w033(sls_lord).
          message_collect_lord.
          ch_subrc = 4.
          exit.
        else.
          message id sy-msgid type 'E' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endif.
    endif.
    clear da_subrc.

* Payment Service Provider
    if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
      if ( vbak-sppaym eq cv_sppaym01 or yvbak-sppaym eq cv_sppaym01 ) and
         gr_paysp is bound.
* Document consistency checked
        call method gr_paysp->save_consistency_check
          exporting
            is_vbak          = vbak
          exceptions
            save_not_allowed = 1.
        if sy-subrc eq 1.
          if call_function is initial.
            message id sy-msgid type 'W' number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            fcode = fcode_gleiche_seite.
            perform fcode_bearbeiten.
            ch_subrc = 4.
            exit.
          else.
            if call_activity eq gc_activity_lord.
              message id sy-msgid type 'W' number sy-msgno
                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              message_collect_lord.
              message w033(sls_lord).
              message_collect_lord.
              ch_subrc = 4.
              exit.
            else.
              message id sy-msgid type 'E' number sy-msgno
                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
          endif.
        endif.
      endif.
    endif.

    describe table yvbep.
    if call_activity = activity_atp_area   and    " Neuterminierung
       sy-tfill = 0.
      loop at xvbep.
        if not xvbep-updkz is initial.
          exit.
        endif.
      endloop.
      if xvbep-updkz is initial.
        clear r185d-dataloss.
      endif.
    endif.

enhancement-point beleg_sichern_40 spots es_sapmv45a.

*   check if LOGIC-objects have been changed.
    if r185d-dataloss is initial.
      if not cl_logic_access=>gv_changed_global is initial.
        r185d-dataloss = charx.
      endif.
    endif.

*   Update item data only if something has changed. But save the
*   item always if forced by rescheduling             " note 644789
    if r185d-dataloss = space     and
       force_update   = space     and
       upd_vbuk is initial and
       upd_vbup is initial.

*   Für den Workflow Gruppenkontrakt im Hintergrundschritt muß das
*   beendende Ereigniss auch ohne Sichern ausgelöst werden, wenn
*   keine Änderung im Unterkontrakt vorgenommen werden mußte
      if call_activity eq activity_gruko_pushdata.
        da_objkey = vbak-vbeln.
        call function 'SWE_EVENT_CREATE_FOR_UPD_TASK'
          exporting
            objtype           = businessobjekt
            objkey            = da_objkey
            event             = 'CHANGED'
          tables
            event_container   = da_container
          exceptions
            objtype_not_found = 1.
      endif.

*   Keine Datenänderung
      message s041.
      if call_activity eq gc_activity_lord.
        message w041.
        message_collect_lord.
      endif.
*   Push message to BAPI return table
      if call_bapi eq charx.
        perform message_vbfs_aufbauen(sapfv45l) using 'V1'
                                                      '041'
                                                      'S'
                                                      space
                                                      space
                                                      space
                                                      space.
      endif.
*   BAPI: In this case the locks must be released
      g_no_document_changes = charx.

* EDI Lieferplaene: Bei Vordergrundverarbeitung wird Sichern nicht
* zugelassen
* Sched. Agr.:In Foreground processing SAVING isn't allowed
      if idoc_number ne space and
         sy-binpt eq charx and
         cattaktiv is initial and
         not vbak-abdis is initial.
        da_edi_stop = charx.
        if bi_info-ctu_amodus eq chara or
           bi_info-ctu_amodus eq chare .
          message i044(v4) with idoc_number vbak-vbeln.
          fcode = fcode_ende.
          perform fcode_bearbeiten.
          ch_subrc = 4.
          exit.
        endif.
      endif.

*... CRM call in ARM II (EhP6)
      if cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true and
         tvak-msr_active = 'X'.
*    CRM Perform Removed will be processed at a later point within this routine
      else.
*---NO deltadownload to CRM, BUT backanswer to CRM must be sent
        perform bapidaten_ermitteln using charx.
      endif.

    else.
      clear vblb.
      clear force_update.
*   Wenn eine Aktivität für den Vertrag gesetzt wurde, dann muss im
*   Falle für den Folgekontrakt bzw. Folgeangebot auf eine vorhandene
*   Erledigungsregel geprüft werden
      if modification_flag-no_contract_data is initial.
        perform veda-vaktsch_pruefen(sapfv45p) using da_subrc.
        if da_subrc = 9.
          ch_subrc = 4.
          exit.
        endif.
      endif.
enhancement-point beleg_sichern_05 spots es_sapmv45a.

      call function 'SD_EVENT_DETERMINE'
        exporting
          i_vbak_updkz = xvbak_updkz
        importing
          e_event      = ereignis.

enhancement-point beleg_sichern_11 spots es_sapmv45a.

enhancement-point beleg_sichern_12 spots es_sapmv45a.

enhancement-point beleg_sichern_28 spots es_sapmv45a.

      if gr_msr_sales is bound.
        call method gr_msr_sales->save_prepare
          exporting
            is_vbak       = vbak
            is_tvak       = tvak
          importing
            ev_abort_save = lv_abort_save
            et_message    = lt_message
          changing
            ct_xvbap      = xvbap[]
            ct_yvbap      = yvbap[]
            ct_xvbep      = xvbep[]
            ct_yvbep      = yvbep[]
            ct_xvbuv      = xvbuv[].
        if lv_abort_save is not initial.
          if call_activity eq gc_activity_lord.
            sy-msgty = chare.
            message_collect_lord.
          else.
            fcode = fcode_gleiche_seite.
            perform fcode_bearbeiten.
          endif.
          ch_subrc = 4.
          return.
        else.
          if call_activity eq gc_activity_lord.
            loop at lt_message into ls_message.
              message id ls_message-id
                      type 'S'
                      number ls_message-number
                      with ls_message-message_v1
                           ls_message-message_v2
                           ls_message-message_v3
                           ls_message-message_v4
                      into lv_message.
              message_collect_lord.
            endloop.
          endif.
        endif.
      endif.

*     LORD callback: save prepare
      if call_activity eq gc_activity_lord.
        perform lord_doc_save_prepare.
        if not gf_saving_abort is initial.
          clear gf_saving_abort.
          ch_subrc = 4.
          return.
        endif.
      endif.


* Call SD Sales BAdI
      call function 'GET_HANDLE_SD_SALES'
        importing
          handle = l_sd_sales_exit
          active = active.

      if active = charx.
        call method l_sd_sales_exit->save_document_prepare
          exporting
            ft180   = t180
          changing
            f_subrc = da_subrc
            fvbak   = vbak
            fxvbap  = xvbap[]
            fxkomv  = xkomv[]
            fxvbapf = xvbapf[]
            fxvbfa  = xvbfa[]
            fxvbep  = xvbep[]
            fxvbkd  = xvbkd[]
            fxvbpa  = xvbpa[]
            fxvbuk  = xvbuk[]
            fxvbup  = xvbup[]
            fxfpla  = xfpla[]
            fxfplt  = xfplt[]
            fyvbak  = yvbak
            fyvbap  = yvbap[]
            fyvbapf = yvbapf[]
            fyvbfa  = yvbfa[]
            fyvbep  = yvbep[]
            fyvbkd  = yvbkd[]
            fyvbpa  = yvbpa[]
            fyvbuk  = yvbuk[]
            fyvbup  = yvbup[]
            fyfpla  = yfpla[]
            fyfplt  = yfplt[]
            fxvbadr = xvbadr[]
            fyvbadr = yvbadr[]
            fxvblb  = xvblb[]
            fyvblb  = yvblb[]
            fxvbuv  = xvbuv[]
            fyvbuv  = yvbuv[].
        if da_subrc > 0 .
          fcode = fcode_gleiche_seite.
          perform fcode_bearbeiten.
          ch_subrc = 4.
          exit.
        endif.
      endif.

* Userexit
      perform userexit_save_document_prepare.
      INCLUDE MV45AF0B_INTTAB_ANALYZE_4.

enhancement-point beleg_sichern_13 spots es_sapmv45a.
* Abschlussrunde, letzte Ergänzungen und Prüfungen
      clear gf_saving_abort.
      perform beleg_bearbeiten_ende using da_subrc.
      if da_subrc > 0.     " for case error, user interrupt save proc.
        ch_subrc = 4.
        exit.
      endif.

* Prüfung bei Wertkontraktabruf auf Überschreiten des Zielwertes
      perform wk_abruf_pruefen_sichern using da_subrc.
      if da_subrc > 0.
        ch_subrc = 4.
        if call_activity eq gc_activity_lord.
          message w033(sls_lord).
          message_collect_lord.
        endif.
        exit.
      endif.

enhancement-point beleg_sichern_41 spots es_sapmv45a.
* Unvollständigkeitsdialog
      perform incompl_last_dialog using da_subrc.
      if da_subrc > 0.
        ch_subrc = 4.
        exit.
      endif.

* MSR Locking
      if gr_msr_sales is bound.
        gr_msr_sales->lock_msr(
          exporting
            is_vbak           = vbak
            it_xvbap          = xvbap[]
          exceptions
            lock_not_possible = 1
            internal_error    = 2
            others            = 3  ).
        if sy-subrc <> 0.
          if call_activity eq gc_activity_lord.
            message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            message_collect_lord.
          else.
            message id sy-msgid type 'I' number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endif.
          fcode = fcode_gleiche_seite.
          perform fcode_bearbeiten.
          ch_subrc = 4.
          exit.
        endif.
      endif.

* Einzelpostenfakturierung
      if call_dialog = charx.
        ch_subrc = 0.
* Export to memory muss laufen
        perform call_dialog_export.
        exit.
      endif.

      call function 'DIALOG_GET_STATUS'
        importing
          dialog_status = da_no_dialog.

      if call_function is initial or
        ( ( sy-tcode(3) eq 'DP9' or sy-tcode(3) eq 'DP8' ) and
          da_no_dialog is initial ).
* Ermitteln der Objektart
        perform t681z_select using tvak-kappl sy-subrc.
* Aufruf spätes Erfassen
        if t180-trtyp eq charv.
          xobjid = vbak-vbeln.
        endif.
        if t180-trtyp eq charh.
          xobjart = tvak-objart_hin.
        else.
          xobjart = tvak-objart_ver.
        endif.
        if xobjart ne space and
           ( sy-binpt is initial or cattaktiv = charx ).
          call function 'ARCHIV_POPUP_BARCODE'
            exporting
              dokumentart = xobjart
              object      = t681z-oj_name
              object_id   = xobjid
            exceptions
              others      = 1.
        endif.
      endif.

      if vbak-vbeln is initial.

        da_numki = tvak-numki.

* Userexit
        perform userexit_number_range using da_numki.
        INCLUDE MV45AF0B_INTTAB_ANALYZE_5.
* interne Nummernvergabe
        data: da_rc like inri-returncode.
        call function 'NUMBER_GET_NEXT'
          exporting
            nr_range_nr = da_numki
            object      = 'RV_BELEG'
          importing
            returncode  = da_rc
            number      = vbak-vbeln.
        case da_rc.
          when '1'.
            message i532 with da_numki 'RV_BELEG'.
          when '2'.
            message i533 with da_numki 'RV_BELEG'.
        endcase.

      endif.
ENHANCEMENT-POINT BELEG_SICHERN_25 SPOTS ES_MV45ATOP .

*   Belegnummer in externe Bestellnummer übernehmen
      if not tvak-extnr_rma is initial.
        perform xvbkd_lesen_direkt(sapfv45k) using posnr_low
                                                   svbkd-tabix.
        if xvbkd-bstkd is initial and
           not svbkd-tabix is initial.
          perform vbkd_bearbeiten_vorbereiten(sapfv45k).
          write vbak-vbeln to da_vbeln_ext.
          move da_vbeln_ext to vbkd-bstkd.
          vbkd-bstkd_m = vbkd-bstkd.
          set locale language tvko_sadr-spras.
          translate vbkd-bstkd_m to upper case.
          set locale language space.
          perform xvbkd_aendern(sapfv45k).
          move vbkd-bstkd to vbak-bstnk.
          if xvbak_updkz = updkz_old.
            xvbak_updkz = updkz_update.
            vbak-aedat = sy-datum.
          endif.
*         Incompletion - Header
          if not vbkd-bstkd is initial.
            perform xvbuv_loesch_vor_pruef_feld(sapfv45f)
                                        using posnr_low
                                              etenr_low
                                              'VBKD      '
                                              'BSTKD'.
          endif.
*         und die Positionen auch
          loop at xvbkd where updkz ne updkz_delete.
            svbkd-tabix = sy-tabix.
            check xvbkd-posnr gt posnr_null and
                  xvbkd-bstkd is initial.
            perform vbkd_bearbeiten_vorbereiten(sapfv45k).
            move vbak-bstnk to vbkd-bstkd.
            perform xvbkd_aendern(sapfv45k).
*           Incompletion - Item
            if not vbkd-bstdk is initial.
              perform xvbuv_loesch_vor_pruef_feld(sapfv45f)
                                           using xvbkd-posnr
                                                 etenr_low
                                                 'VBKD      '
                                                 'BSTKD'.
            endif.
          endloop.
        endif.
      endif.

      perform vbak-vbeln_set_parameter(sapfv45k).

      if not vbak-abdis is initial.
        call function 'SD_XVBLB_RENAME'
          exporting
            document_number = vbak-vbeln.

* Übergabe der Belegnummer an XS073, da im Falle einer
* Korrekturlieferung beim Anlegen eines Lieferplans für Zulieferer
* die fehlende Belgnummer z.B. beim Ermitteln der offenen Liefermenge
* im VIS Probleme verursacht
        call function 'SD_XS073_RENAME'
          exporting
            i_vbak  = vbak
            i_trtyp = t180-trtyp.

        call function 'SD_XVBKFZ_RENAME'
          exporting
            document_number = vbak-vbeln.
      endif.

      veda-vbeln = vbak-vbeln.
      call function 'SD_XVEDA_RENUMBER'
        exporting
          i_document_number = veda-vbeln.

      data: lf_new_number like vekp-vpobjkey.
      lf_new_number = vbak-vbeln.
      call function 'V51P_PACKING_RENAME'
        exporting
          if_object          = '02'
          if_document_nr_new = lf_new_number.

* Aufruf der Verbuchungsvorbereitung für Ausfuhrkontrolldaten VBEX
* Einfuegen der korrekten Belegnummer VBELN in der Tabelle VBEX,
* auch im Fall der expliziten 'Neuermittlung'
* Anmerkung: Die Ausgabe der Liste erfolgt in der Routine EXPORT_AUSFUHR
*            als Teil der Routine BELEG_BEARBEITEN_ENDE schon frueher
      if modification_flag-no_export_control is initial.
        if not ( tvak-excok is initial ).
          perform export_ausfuhr_update_prepare.
        endif.
      endif.

* Update dynamischer Posten (löst Einzelposten Update dann ab)
      perform dli_update.

* rename the SD-monitor-protocol, but only if protocol is to be saved
* and not in CHANGE-mode because then the document number is known
      if t180-aktyp = 'H'.
        if xsdctrlflag is initial.
          call function 'SD_MONITOR_CONTROL_FLAGS_GET'
            importing
              fsdctrlflag = xsdctrlflag
            exceptions
              others      = 1.
        endif.
        if xsdctrlflag-protsave = 'X'.
          call function 'SD_MONITOR_PROTOCOL_RENAME'
            exporting
              fpappl = protocolcaller-sda
              fvbeln = vbak-vbeln
            exceptions
              others = 1.
          call function 'SD_MONITOR_PROTOCOL_EXPORT'
            exporting
              fpappl = protocolcaller-sda
              fvbeln = vbak-vbeln
            exceptions
              others = 1.
        endif.
      endif.

* Nummernvergabe fuer Konditionssaetze
      if vbak-knumv is initial.
        call function 'NUMBER_GET_NEXT'
          exporting
            nr_range_nr = '01'
            object      = 'KONV'
          importing
            number      = vbak-knumv.
      endif.

* Nummernvergabe fuer Fakturierungspläne
* und RevRev Aktivitätskennzeichen ermitteln.
      loop at xvbkd.
        svbkd-tabix = sy-tabix.
* Start Revenue Recognition Project(enhancement)
        if lvf_rev_rec_active is initial.
          if not xvbkd-rrrel is initial.
            lvf_rev_rec_active = charx.
          endif.
        endif.
* End Revenue Recognition Project(enhancement)
        check xvbkd-updkz ne updkz_delete.
        check xvbkd-fplnr(1) eq '$'.
        perform vbkd_bearbeiten_vorbereiten(sapfv45k).
        call function 'BILLING_SCHEDULE_GET_NUMBER'
          exporting
            i_fplnr  = vbkd-fplnr
            i_vbeln  = vbak-vbeln
          importing
            e_fplnr  = vbkd-fplnr
          tables
            fpla_new = xfpla
            fplt_new = xfplt.
        perform xvbkd_aendern(sapfv45k).
      endloop.
* Nummernvergabe fuer Ratenplan
      if vbak-rplnr(1) eq '$'.
        call function 'BILLING_SCHEDULE_GET_NUMBER'
          exporting
            i_fplnr  = vbak-rplnr
            i_vbeln  = vbak-vbeln
          importing
            e_fplnr  = vbak-rplnr
          tables
            fpla_new = xfpla
            fplt_new = xfplt.
* VBAK_AENDERN darf hier nicht mehr laufen, da zu viel abläuft.
* z.B. wird vbup gelesen, hat aber noch keine Belegnummer
*     perform vbak_aendern(sapfv45k).
        if xvbak_updkz = updkz_old.
          xvbak_updkz = updkz_update.
          vbak-aedat = sy-datum.
        endif.
      endif.

* Rename für separate externe Belegtabellen Absicherungsmanagement
      if t180-aktyp = 'H'.
        perform risk_management_rename.
      endif.

* Haushaltsmanagements-Zuordnung abspeichern
      data: l_t_fmco_post_sd type fmco_t_post_sd with header line.
      data: da_no_refresh like fmdy-xfeld.

      loop at xvbap where updkz ne updkz_delete
                      and pvpos is initial.
        l_t_fmco_post_sd-posnr_old = xvbap-posnr.
        l_t_fmco_post_sd-posnr_new = xvbap-posnr.
        l_t_fmco_post_sd-vbeln_new = vbak-vbeln.
        append l_t_fmco_post_sd.
      endloop.

* Bei Sofortlieferung darf keine Initialisierung des HHM stattfinden.
* If SO creates a purch. requisition, then refresh will happen after
* second call of SD-FM interface.
      if not tvak-lisof  is initial or
         not rv45a-banfn is initial or
         not rv45a-bnfpo is initial .
        da_no_refresh = charx.
      endif.

* Kontierungszuordnung funds management speichern
      call function 'FM_CO_ASS_INPUT_POST_SD'
        exporting
          no_refresh     = da_no_refresh
        tables
          t_fmco_post_sd = l_t_fmco_post_sd.


* Alle Tabellen sortieren etc.
      perform beleg_sichern_vorbereiten.

* EDI Lieferplaene, Pruefung Neueintrag XVBLB , andernfalls IDOC nicht
* bis Ende eingebucht. Bei Vordergrundverarbeitung wird Sichern nicht
* zugelassen
* Sched. Agr., Check if new entry in XVBLB, otherwise IDOC not
* completely posted. In Foreground processing SAVING isn't allowed
      clear da_edi_stop.
      if idoc_number ne space and
         sy-binpt eq charx and
         cattaktiv is initial and
         not vbak-abdis is initial.
        read table xvblb transporting no fields with key
                                       updkz = updkz_new.
        if sy-subrc ne 0.
          da_edi_stop = charx.
          if  bi_info-ctu_amodus eq chara or
              bi_info-ctu_amodus eq chare .
            message i044(v4) with idoc_number vbak-vbeln.
            fcode = fcode_ende.
            perform fcode_bearbeiten.
            ch_subrc = 4.
            exit.
          endif.
        endif.
      endif.

* Payment Service Provider
      if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true and
        ( vbak-sppaym eq cv_sppaym01 or yvbak-sppaym eq cv_sppaym01 ) and
        gr_paysp is bound.
* Document number has to be exchanged in PSP data
        call method gr_paysp->rename
          exporting
            iv_document_id_to = vbak-vbeln.
        call method gr_paysp->save
          importing
            et_paysp_hl     = gt_paysp_hl
            et_paysp_hl_old = gt_paysp_hl_old.
      endif.

*     LOGIC: rename parent key (vbeln)
      perform beleg_rename_logic.

* start Revenue Recognition Project
* Rev.Rec. neads communication header from form Preisfindung_vorbereiten
      lvs_komk = tkomk.
* end   Revenue Recognition Project

* Ergebnisobjekt mit aktueller Belegnummer versorgen
      perform ergebnisobjekt_versorgen.

* CO_Objekte bei Einzelfertigung gegebenenfalls löschen
      perform co_objekt_loeschen(sapfv45p).

* CO_Objekte für Einzelfertigung anlegen
      perform co_objekt_anlegen(sapfv45p).

* Effectivity speichern (TECHS)
      perform effectivity_save(sapfv45s).

* Interne Objektnummer für konfigurierte Positionen (CUOBJ)
      perform konfiguration_anlegen(sapfv45p).

***** DSEG *****
      if gwa_twpa is initial.
        select single * from twpa
              client specified
              into gwa_twpa
              where  mandt       = sy-mandt.
      endif.

      if not gwa_twpa-addis is initial.
***** DSEG *****

* Verkaufshilfsmittel speichern
        call function 'WTAD_ADDIS_IN_SO_DISPLAY_CHK'
          exporting
            fi_vbtyp         = vbak-vbtyp
          exceptions
            addis_not_active = 1
            others           = 2.
        if sy-subrc = 0.
          perform additionals_sichern(sapfv45p).
        endif.

***** DSEG *****
      endif.
***** DSEG *****

* Texte zur Verbuchung umbenennen (nur im Anlegen nötig)
      if t180-trtyp eq charh.
        call function 'RV_TEXT_RENAME'
          exporting
            fi_tdobject   = 'VBB*'
            fi_tdname_neu = vbak-vbeln.
      endif.
enhancement-point beleg_sichern_16 spots es_mv45atop.

* BANF/Fertigugs-/Planauftrag verbuchen und
* Nummer in VBEP übernehmen
      perform beschaffung_sichern(sapfv45e).

* BADI_SD_TO_FM, give the new ordernumber to FM
      include badi_sd_to_fm_item_number_pr.

* Packen muß vor Lieferung erzeugen gesichert werden
      if modification_flag-no_packing is initial.
        call function 'HU_PACKING_UPDATE'
          exporting
            if_synchron = us_syncron.
      endif.

enhancement-point beleg_sichern_14 spots es_sapmv45a.
* Texte sichern
      append vbak-vbeln to da_text_vbeln.
      call function 'SD_COMMIT_TEXT'
        exporting
          fi_caller = gc_text_appl_id-sales_document
          fit_vbeln = da_text_vbeln[]
          fi_keep   = 'X'
        exceptions
          others    = 1.

* Sofortlieferung  (ACHTUNG: wegen der Objektnummer darf dieser
* Schritt auch erst nach CO_OBJEKT_ANLEGEN laufen)
      perform lieferung_erzeugen
           tables   lt_xvbap_modify_requirements
                    lt_yvbap_modify_requirements
           changing da_subrc_lf.
      if not vbak-abdis is initial and
             da_subrc_lf eq 12.
        perform korrekturlieferung_reset(sapfv45l).
      endif.

* Auslieferungsauftrag-Korrektur - DA_SUBRC_LF entsprechend setzen
      perform auslieferungsauftrag_korrektur changing da_subrc_lf.

* Bedarfssätze auslesen, separiert wegen Sofortlieferung
      perform bedarf_fuellen
           tables lt_xvbap_modify_requirements
                  lt_yvbap_modify_requirements.

      call function 'ND_EXITS_ACTIVE_CHECK'
        exceptions
          exits_not_active = 1
          others           = 2.

      if sy-subrc eq 0.

        perform catalogue_build_ref(sapfv45v).

        data: fn like  rs38l-name   value 'CAVE_SL_DOC_VBBE_MAP'.

        perform apo_update_without_requ(sapfv45v).

        call function 'FUNCTION_EXISTS'
          exporting
            funcname           = fn
          exceptions
            function_not_exist = 1.
        if sy-subrc = 0.
          call function fn
            tables
              apo_req = xvbbe.
        endif.

      endif.

* Updatekennzeichen in XVBEP und YVBEP neu setzen
*   PERFORM xvbep_zuordnen(sapfv45e).

* Kalkulation sichern
* muß nach CO_OBJEKT_ANLEGEN laufen !
* muß nach Nummernvergabe CUOBJ (Konfiguration) laufen !
      perform kalkulation_sichern(sapfv45p).

* Erzeugen der Selektionen für merkmalsbasierte ATP
      call function 'VBXD_GENERATE_CRITERIA'
        exporting
          i_vbak = vbak
        tables
          t_vbap = xvbap.

* Verify Classification
      call function 'V01F_BDSEL_OBJECTS_VERIFY'
        exporting
          i_vbeln_va = vbak-vbeln
        tables
          t_vbap     = xvbap.

* update batch selection critera (temporary cuobj_ch)
* in field catalog for transfer to SCM
      loop at xvbap
        where cuobj_ch is not initial
          and updkz <> updkz_delete.
        read table x_sdfields
             with key delnr = xvbap-vbeln
                      delps = xvbap-posnr
                      kfdna = 'APO_SD_CUOBJ_CH'.
        if sy-subrc is initial and
           x_sdfields-value gt '999999999999990000'.
          x_sdfields-value = xvbap-cuobj_ch.
          modify x_sdfields index sy-tabix from x_sdfields
                 transporting value.
        endif.
      endloop.

* Aufteilungsregel für Einzelfertigung sichern
      perform aufteilungsregel_sichern(sapfv45p).

* Übergabe ALEKZ
      alekz  = ale_flag.
      mmflag = mm_flag.
* Konsistenzprüfungen
      perform beleg_pruefen.

* Preisvereinbarungen sichern und neue KNUMVs in XKONV übernehmen
      perform preisvereinbarungen_sichern.


* Lord Reparaturauftrag, Referenz zur Servicemeldung
      if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
        if call_activity eq gc_activity_lord and
          vbak-qmnum is not initial and
          t180-trtyp = charh and
          tvak-vbtyp = vbtyp_auftr.
          perform lord_repair_objreference_write
            using vbak-vbeln
                  vbak-qmnum.
        endif.
      endif.

* Objektreferenz erzeugen
      perform objectreference_write tables i_attr_tab
                                    using  vbak
                                           i_vbakkom_ref.
*     Copy requirements on item level
      call customer-function '003'
          exporting
            xvbak   = vbak
            xvbuk   = vbuk
            xkomk   = lvs_komk
          importing
            lvf_subrc = lvf_subrc
          tables
            xvbkd = xvbkd
            xvbfa = xvbfa
            xvbap = xvbap
            xvbup = xvbup.

      if lvf_subrc eq 0.
*       Start Revenue Recognition Project
*       Revenue-Recognition-Update
        if t180-trtyp ne chara and lvf_rev_rec_active is initial.
          read table yvbuk into lvs_yvbuk with key vbeln = vbak-vbeln.
        endif.

        if ( not vbuk-rrsta         is initial or
             not lvs_yvbuk-rrsta    is initial or
             not lvf_rev_rec_active is initial )    and
                 t180-trtyp    ne chara             and
                 vbak-vbtyp    na vbtyp_agan        and
                 call_activity ne activity_purchase and
           ( not ( not modification_flag-no_pricing is initial ) or
                   ( call_function ne space and
                     call_activity eq activity_atp_area ) ).

          if t001-bukrs ne vbak-bukrs_vf and
             not vbak-bukrs_vf is initial.
            perform t001_select using vbak-bukrs_vf
                                      charx
                                      sy-subrc.
          endif.

          refresh lvt_xvbup[].
          lvt_xvbup   = xvbup.
          lvt_xvbup[] = xvbup[].

          call function 'SD_REV_REC_SALES'
            exporting
              fif_vorgang        = t180-trtyp
              fis_xvbak          = vbak
              fis_yvbak          = yvbak
              fif_xvbak_updkz    = xvbak_updkz
              fif_yvbak_updkz    = yvbak_updkz
              fis_t001           = t001
              fis_komk           = lvs_komk
              fif_konv_geaendert = konv_geaendert
              fis_xvbuk          = xvbuk
              fis_tvak           = tvak
              fif_euro_active    = euro_active
            tables
              fit_xvbap          = xvbap
              fit_yvbap          = yvbap
              fit_xkomv          = xkomv
              fit_xvbkd          = xvbkd
              fit_yvbkd          = yvbkd
              fit_xfpla          = xfpla
              fit_xfplt          = xfplt
              fit_yfplt          = yfplt
              fit_xkomp          = tkomp
              fit_xvbup          = lvt_xvbup
              fit_xvbpa          = xvbpa
              fit_xvbep          = xvbep
              fit_xvbuv          = xvbuv
              fit_xvbfa          = xvbfa
            exceptions
              no_revenue_lines   = 1
              others             = 2.

          if sy-subrc <> 0.
*            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          else.
*Adjust Status
            call function 'SD_SET_REVREC_STATUS'
              exporting
                fif_vorgang      = t180-trtyp
                fis_vbeln        = vbuk-vbeln
              importing
                fef_vbuk_changed = lvf_vbuk_changed
              tables
                fit_xvbuk        = xvbuk
                fit_xvbup        = xvbup
                fit_yvbup        = yvbup
                fit_yvbuk        = yvbuk
                fit_rev_xvbup    = lvt_xvbup.
            if lvf_vbuk_changed = charx.
              vbuk-rrsta = xvbuk-rrsta.
            endif.
          endif.
        endif.
      endif.
*     End Revenue Recognition Project


enhancement-point sapmv45a_21 spots es_sapmv45a.




enhancement-point beleg_sichern_15 spots es_sapmv45a.
      if gr_msr_sales is bound.
        call method gr_msr_sales->save
          exporting
            it_xvbap = xvbap[]
            it_xvbep = xvbep[]
            it_xvbuv = xvbuv[]
            it_xvbuk = xvbuk[]
            it_yvbuk = yvbuk[]
            it_yvbap = yvbap[]
          changing
            cs_yvbak = yvbak
            cs_vbak  = vbak.
      else.
        if not vbak-msr_id is initial and
           t180-trtyp eq charv.
          perform msr_verify_save_change.
        endif.
      endif.

*     save data of changed LOGIC objects
      cl_logic_access=>save_execute( ).

*     LORD callback: save prepare (part 2)
      if call_activity eq gc_activity_lord.
        perform lord_doc_save_prepare_2.
      endif.

* Call SD Sales BAdI
      if active = charx.
        call method l_sd_sales_exit->save_document_prepare_part2
          exporting
            ft180   = t180
          changing
            fvbak   = vbak
            fxvbap  = xvbap[]
            fxkomv  = xkomv[]
            fxvbapf = xvbapf[]
            fxvbfa  = xvbfa[]
            fxvbep  = xvbep[]
            fxvbkd  = xvbkd[]
            fxvbpa  = xvbpa[]
            fxvbuk  = xvbuk[]
            fxvbup  = xvbup[]
            fxfpla  = xfpla[]
            fxfplt  = xfplt[]
            fyvbak  = yvbak
            fyvbap  = yvbap[]
            fyvbapf = yvbapf[]
            fyvbfa  = yvbfa[]
            fyvbep  = yvbep[]
            fyvbkd  = yvbkd[]
            fyvbpa  = yvbpa[]
            fyvbuk  = yvbuk[]
            fyvbup  = yvbup[]
            fyfpla  = yfpla[]
            fyfplt  = yfplt[]
            fxvbadr = xvbadr[]
            fyvbadr = yvbadr[]
            fxvblb  = xvblb[]
            fyvblb  = yvblb[].
      endif.

      if vbak-vbtyp na vbtyp_agan.
* Call VPRS-Update process if it is activated
        lo_vprs_update_process =
           cl_vprs_update_process=>get_vprs_update_process( ).
        lo_vprs_update_process->handle_vprs_update_process(
                      exporting iv_caller = cl_rr_constants=>gc_caller_s
                                is_vbak   = vbak
                                it_vbap   = xvbap[]
                                it_vbkd   = xvbkd[]
                                it_vbep   = xvbep[]
                                it_vbuk   = xvbuk[]
                                it_vbup   = xvbup[]
                                it_vbfa   = xvbfa[]
                                iv_bukrs  = t001-bukrs
                                iv_manek  = vbuk-manek ).
      endif.

* SÜW (Systemübergreifender Warenfluss)
* Filling of CSFG info structure (SÜW)
      clear ls_csfg_info.
      if csfg_xvbap_logsys eq charx.
        ls_csfg_info-x_logsys_flag = charx.
      endif.
      if csfg_yvbap_logsys eq charx.
        ls_csfg_info-y_logsys_flag = charx.
      endif.

* Batch Determination in Cross-System Flow of Goods
      if ls_csfg_info-x_logsys_flag eq charx.
        perform read_classification changing lt_allocations
                                             lt_valuations_char
                                             lt_valuations_curr
                                             lt_valuations_num.
      endif.

* Übergabe des Belegs an die Protokolldatei

      if t180-trtyp eq charh.
        if sy-dbsys <> 'ORACLE'.
          perform beleg_sperren using vbak-vbeln space.
        endif.

* Ermitteln kleinstes Materialbereitstellungsdatum für rückständige
* Aufträge
        call function 'SD_MBDAT_DETERMINE'
          exporting
            fvbak  = vbak
          importing
            fmbdat = da_fmbdat
          tables
            fxvbep = xvbep.

        vbak-fmbdat = da_fmbdat.

* Hilfstabelle für Funktionsbaustein füllen
        lt_xqtvb[] = xqtvb[].




* Verbuchung
enhancement-section     beleg_sichern_30 spots es_sapmv45a.
        call function 'RV_SALES_DOCUMENT_ADD' in update task
          exporting
            fvbak              = vbak
            fkonv_geaendert    = konv_geaendert
            falekz             = alekz
            it_allocations     = lt_allocations
            it_valuations_char = lt_valuations_char
            it_valuations_curr = lt_valuations_curr
            it_valuations_num  = lt_valuations_num
            is_csfg_info       = ls_csfg_info
          tables
            fxkomv             = xkomv
            fxvbap             = xvbap
            fxvbapf            = xvbapf
            fxvbbe             = xvbbe
            fxvbbs             = xvbbs
            fxvbsn             = xvbsn
            fxvbep             = xvbep
            fxvbkd             = xvbkd
            fxvbfa             = xvbfa
            fxvbpa             = xvbpa
            fxvbpa2            = xvbpa2
            fxvbup             = xvbup
            fxvbuk             = xvbuk
            fxqtch             = xqtch
            fxqtvb             = lt_xqtvb
            fxapoi             = x_sdfields
            fyvbbe             = yvbbe
            fyvbbs             = yvbbs
            fyvbup             = yvbup
            fyvbuk             = yvbuk
            fxvbuv             = xvbuv
            fxsadr             = xvbadr
            fxfpla             = xfpla
            fyfpla             = yfpla
            fxfplt             = xfplt
            fyfplt             = yfplt
            fyqtvb             = yqtvb
            fvbkey             = vb_key
            fxvblb             = xvblb
            fyvblb             = yvblb
            fxvbkfz            = xvbkfz                         " CMDS
            fyvbkfz            = yvbkfz.                        " CMDS
end-enhancement-section.

* Nachrichten umbenennen
        if no_messages eq space.
          data: objky_old like nast-objky,
                objky_new like nast-objky.

          objky_old = space.
          objky_new = vbak-vbeln.
          call function 'RV_MESSAGES_RENAME'
            exporting
              msg_kappl     = tvak-kappl
              msg_objky_old = objky_old
              msg_objky_new = objky_new
              msg_leng      = 10.
        endif.

*     Objektliste der Serialnummern mit Belegnummer ergaenzen
        data: vbeln_old like vbap-vbeln.

        vbeln_old = char$.

* 2 Aufrufe für Serialnummern --> ohne Einteilungen und mit Einteilungen
        if not serial_dataloss is initial.
          call function 'SERIALPROFILE_CHECK'
            exporting
              operation = vrgng_sdr3
              doc_old   = vbeln_old
              doc_new   = vbak-vbeln.

          clear vbeln_old.
        endif.

        call function 'IWOL_WV_SWITCH_NUMBER'
          exporting
            old_sdaufnr    = vbeln_old
            new_sdaufnr    = vbak-vbeln
          exceptions
            no_object_list = 1.

      else.

* Hilfstabelle für Funktionsbaustein füllen
        lt_xqtvb[] = xqtvb[].

        if cl_ops_switch_check=>sd_sfws_sc2( ) eq abap_true.
*         Set/adopt timestamp if at least one change in the sales document applies
          get time stamp field vbak-upd_tmstmp.
        endif.

* Verändern
* Verbuchung
enhancement-section     beleg_sichern_29 spots es_sapmv45a.
        call function 'RV_SALES_DOCUMENT_UPDATE' in update task
          exporting
            fvbak              = vbak
            fyvbak             = yvbak
            fyvbak_updkz       = yvbak_updkz
            fkonv_geaendert    = konv_geaendert
            falekz             = alekz
            fmm_flag           = mmflag
            it_allocations     = lt_allocations
            it_valuations_char = lt_valuations_char
            it_valuations_curr = lt_valuations_curr
            it_valuations_num  = lt_valuations_num
            is_csfg_info       = ls_csfg_info
          tables
            fxkomv             = xkomv
            fxvbap             = xvbap
            fxvbapf            = xvbapf
            fxvbbe             = xvbbe
            fxvbbs             = xvbbs
            fxvbep             = xvbep
            fxvbeh             = xvbeh
            fxvbkd             = xvbkd
            fxvbfa             = xvbfa
            fxvbpa             = xvbpa
            fxvbpa2            = xvbpa2
            fxvbsn             = xvbsn
            fxvbup             = xvbup
            fxvbuk             = xvbuk
            fyvbap             = yvbap
            fxqtch             = xqtch
            fxqtvb             = lt_xqtvb
            fxapoi             = x_sdfields
            fyvbbe             = yvbbe
            fyvbbs             = yvbbs
            fyvbep             = yvbep
            fyvbfa             = yvbfa
            fyvbkd             = yvbkd
            fyvbpa             = yvbpa
            fyvbpa2            = yvbpa2
            fyvbsn             = yvbsn
            fyvbup             = yvbup
            fyvbuk             = yvbuk
            fxvbuv             = xvbuv
            fyvbuv             = yvbuv
            fxsadr             = xvbadr
            fysadr             = yvbadr
            fxfpla             = xfpla
            fyfpla             = yfpla
            fxfplt             = xfplt
            fyfplt             = yfplt
            fyqtvb             = yqtvb
            fvbkey             = vb_key
            fxvblb             = xvblb
            fyvblb             = yvblb
            fxvbkfz            = xvbkfz                         " CMDS
            fyvbkfz            = yvbkfz.                        " CMDS
end-enhancement-section.
      endif.
* Gemeinsam: Anlegen oder Ändern

* Update Dynamischer Produktvorschlag
      if not tvak-pvbsm  is initial and  " Belegschema
         not kuagv-pvksm is initial.     " Kundenschema
        call function 'SD_INT_DPP_UPDATE' in update task
          exporting
            i_vbak  = vbak
            i_yvbak = yvbak.
      endif.

* Löschen Dynamischer Produktvorschlag, wenn Auftrag gelöscht wird
      if xvbak_updkz = updkz_delete and
         not tvak-pvbsm is initial. "PV Belegschema
        call function 'SD_INT_DPP_DELETE' in update task
          exporting
            i_vbak = vbak.
      endif.
enhancement-point beleg_sichern_17 spots es_sapmv45a.

enhancement-point beleg_sichern_18 spots es_sapmv45a.

enhancement-point beleg_sichern_19 spots es_sapmv45a.

enhancement-point beleg_sichern_20 spots es_sapmv45a.

* Verbuchung der Gefahrgut-Anhangstabellen
      call function 'SD_EHS_SAVE'
        exporting
          i_vbak_tab  = vbak
        tables
          i_xvbap_tab = xvbap
          i_xvbep_tab = xvbep.

* Gefahrgut: Verbuchung der Gefahrgutbelegtabelle (Template-Material-
*            Abwicklung
      call function 'EHS003_DGMSD_UPDATE'
        exporting
          i_vbeln    = vbak-vbeln
          i_synchron = ''
          i_vbtyp    = vbak-vbtyp
        exceptions
          others_    = 1.

* Verbuchung der Ausfuhrkontrolldaten im Auftrag
      if not ( tvak-excok is initial ).
        call function 'RV_EXPORT_VBEX_UPDATE_PREPARE'
          tables
            i_xvbex = xvbex
            i_yvbex = yvbex
            i_xembk = xembk.
      endif.

      call function 'FT_SLS_PARTNER_FTRADE_PREPARE'
        exporting
          i_base_document              = '2VA'
          i_document_number            = vbak-vbeln
        tables
          i_t_vbapvb_ord_line_item_new = xvbap
          i_t_vbpavb_partner_new       = xvbpa
          i_t_vbpavb_partner_old       = yvbpa
          i_t_sadrvb_address_new       = xvbadr
          i_t_sadrvb_address_old       = yvbadr.

      perform sll_document_transfer using 'V'.

* Präferenzdaten mit Objektnummer für konfigurierte Positionen und
* Vertriebsbelegnummer ergänzen und sichern.
      perform praeferenz_sichern(sapfv45p).

* Referenz zum Workflow herstellen
      data: begin of da_wfas2 occurs 1.
              include structure wfas2.
      data: end of da_wfas2.
      refresh da_wfas2.
      clear da_wfas2.
      if call_function is initial.
* Ermitteln der Objektart
        perform t681z_select using tvak-kappl sy-subrc.
* Aufruf Workflow
        da_wfas2-asgtp = t681z-oj_name.
        da_wfas2-asgky = vbak-vbeln.
        append da_wfas2.
        call function 'WF_COMMIT'
          tables
            assignments = da_wfas2.
      endif.

      if modification_flag-no_output_control is initial.
* Barcode für spätes Erfassen sichern
        xobjid = vbak-vbeln.
* Ermitteln der Objektart
        perform t681z_select using tvak-kappl sy-subrc.
        call function 'ARCHIV_BARCODE_INSERT_BATCH'
          exporting
            object_id  = xobjid
            sap_object = t681z-oj_name
          exceptions
            others     = 1.
* Nachrichten verbuchen
        if no_messages eq space.
          xobjky = vbak-vbeln.
          if not call_function is initial.
            call function 'RV_MESSAGES_MAIL_REPLACE'
              exporting
                msg_kappl             = tvak-kappl
              exceptions
                no_mail_message_found = 01.
          endif.
* Zur Vermeidung eines NESTED_PERFORM_ON_COMMIT darf die Routine nur
* dann ON COMMIT aufgerufen werden, wenn sich der BELEG_SICHERN nicht
* bereits in einem ON COMMIT befindet. Der BELEG_SICHERN wird z.B. ON
* COMMIT aufgerufen, wenn ein Strukturplan geändert wird.
          if sy-oncom eq charp.
            perform messages_update.
          else.
            perform messages_update on commit.
          endif.
        endif.
      endif.
* Vertragsdaten verbuchen.
      if modification_flag-no_contract_data is initial.
        call function 'SD_VEDA_SAVE'.
      endif.

*   Serialnummern verbuchen --> 2 Aufrufe
*   ohne Einteilungen und mit Einteilungen
      if modification_flag-no_change_status is initial.
enhancement-point beleg_sichern_06 spots es_sapmv45a static.
enhancement-point beleg_sichern_07 spots es_sapmv45a.
        if not serial_dataloss is initial.
          call function 'SERIALPROFILE_CHECK'
            exporting
              operation = vrgng_sdap
            tables
              tab_cuobj = dbcuobj.
        endif.

        call function 'IWOL_WV_POST_OBJECT_LIST'
          exporting
            i_sdaufnr      = vbak-vbeln
          exceptions
            no_object_list = 1.
      endif.

***** DSEG *****
      if gwa_twpa is initial.
        select single * from twpa
              client specified
              into gwa_twpa
              where  mandt       = sy-mandt.
      endif.

      if not gwa_twpa-addis is initial.
***** DSEG *****

* Verkaufshilfsmittel verbuchen
        call function 'WTAD_ADDIS_IN_SO_DISPLAY_CHK'
          exporting
            fi_vbtyp         = vbak-vbtyp
          exceptions
            addis_not_active = 1
            others           = 2.
        if sy-subrc = 0.
          call function 'WTAD_ADDIS_IN_SO_POST'
            exporting
              fi_vbak  = vbak
            tables
              fit_vbap = xvbap
              fit_vbep = xvbep
              fit_vbkd = xvbkd.
        endif.
***** DSEG ******
      endif.
***** DSEG ******

* Sofortlieferung sichern, wenn alles OK (0) oder einzelne Positionen
* erzeugt (16), oder Korrekturlieferung (90).
      if da_subrc_lf = 0  or
         da_subrc_lf = 16 or
         da_subrc_lf = 90.
        da_yvbeln = da_vbeln.
        perform lieferung_sichern changing da_vbeln
                                           da_subrc.
        case da_subrc.
          when 0.                        " Eine Lieferung gesichert (OK)
            export da_yvbeln to memory id 'SofortauftragBeiNeuterm'.
          when 1.                        " Keine Lieferung gesichert
            da_subrc_lf = 99.
          when 2.                        " Mehrere Lieferungen gesichert
            da_subrc_lf = 98.
            export da_yvbeln to memory id 'SofortauftragBeiNeuterm'.
        endcase.
      endif.

* Ereignis 'CREATED', 'CHANGED' oder 'DELETED' für Workflow auslösen
      if not businessobjekt is initial.
* Check if we need additional event parameters
        if businessobjekt = bus_2095 and
           ereignis = event_changed.
          call function 'SD_GROUPCONTRACT_GETDATA_WF'
            tables
              t_gruko     = gruko
              t_container = da_container.
        endif.
        da_objkey = vbak-vbeln.
        call function 'SWE_EVENT_CREATE_FOR_UPD_TASK'
          exporting
            objtype           = businessobjekt
            objkey            = da_objkey
            event             = ereignis
          tables
            event_container   = da_container
          exceptions
            objtype_not_found = 1.

enhancement-point beleg_sichern_24 spots es_sapmv45a.

      endif.

* start Revenue Recognition Project
      if ( not vbuk-rrsta         is initial or
           not lvs_yvbuk-rrsta    is initial or
           not lvf_rev_rec_active is initial ).
*       Update revenue recognition database VBREVx
        call function 'SD_REV_REC_POSTING'.
        call function 'SD_REV_REC_COLLECT_POST' in update task
          exporting
            fif_vbeln = vbak-vbeln.
      endif.
* end Revenue Recognition Project

* Switch CPE Formula Document to final KNUMV
      constants lc_knumv_blank type knumv value '          '.

      if xvbak_updkz = 'I'.
        call function 'CPE_ERP_KNUMV_CHANGE'
          exporting
            iv_knumv_new        = vbak-knumv
            iv_knumv_old        = lc_knumv_blank
          exceptions
            cpe_not_active      = 0
            old_knumv_not_found = 0.
      endif.

** Save CPE Formula Document
*      CALL FUNCTION 'CPE_ERP_FORMULA_SAVE'
*        EXPORTING
*          iv_knumv          = vbak-knumv
*        EXCEPTIONS
*          cpe_not_active    = 0
*          formula_not_found = 0.

enhancement-point beleg_sichern_09 spots es_sapmv45a.

enhancement-point beleg_sichern_03 spots es_sapmv45a.

enhancement-point beleg_sichern_08 spots es_sapmv45a.

*     LORD callback: save
      if call_activity eq gc_activity_lord.
        perform lord_doc_save.
      endif.

* Call SD Sales BAdI
      if active = charx.
        call method l_sd_sales_exit->save_document
          exporting
            ft180   = t180
            f_updkz = xvbak_updkz
          changing
            fvbak   = vbak
            fxvbap  = xvbap[]
            fxkomv  = xkomv[]
            fxvbapf = xvbapf[]
            fxvbfa  = xvbfa[]
            fxvbep  = xvbep[]
            fxvbkd  = xvbkd[]
            fxvbpa  = xvbpa[]
            fxvbuk  = xvbuk[]
            fxvbup  = xvbup[]
            fxfpla  = xfpla[]
            fxfplt  = xfplt[]
            fyvbak  = yvbak
            fyvbap  = yvbap[]
            fyvbapf = yvbapf[]
            fyvbfa  = yvbfa[]
            fyvbep  = yvbep[]
            fyvbkd  = yvbkd[]
            fyvbpa  = yvbpa[]
            fyvbuk  = yvbuk[]
            fyvbup  = yvbup[]
            fyfpla  = yfpla[]
            fyfplt  = yfplt[]
            fxvbadr = xvbadr[]
            fyvbadr = yvbadr[]
            fxvblb  = xvblb[]
            fyvblb  = yvblb[].
      endif.

enhancement-point beleg_sichern_42 spots es_sapmv45a.
* Userexit
      perform userexit_save_document.
      INCLUDE MV45AF0B_INTTAB_ANALYZE_3.

enhancement-point beleg_sichern_01 spots es_sapmv45a.
* Statistik-Fortschreibung
      perform statistik_update.

* Save CPE Formula Document
      call function 'CPE_ERP_FORMULA_SAVE'
        exporting
          iv_knumv          = vbak-knumv
        exceptions
          cpe_not_active    = 0
          formula_not_found = 0.

*   T_KANZ kann nicht von der Kalkulation gelöscht werden, da sie beim
*   Statistikaufbau verwendet wird
      call function 'CK_F_KANZ_RESET'.

* Sichern der separaten externen Belegtabellen Absicherungsmanagement
      perform risk_management_save.

* Disporechnung nach der Verbuchung starten
      if yvbak_updkz ne updkz_delete.
        perform disposition_aufrufen.
      endif.

*-----Deltadownload SFA
      perform bapidaten_ermitteln using space.

* Posting + Deltadownload Conditions
      if t180-trtyp ne chara and not tvak-vterl is initial.
        call function 'RV_CONDITION_POST'.
      endif.

      if yvbak_updkz = updkz_delete.
        message s008 with tvakt-bezei vbak-vbeln.
        message_collect_lord.
      else.
        if tvak-lisof eq space and vbap_korli eq space or
           da_subrc_lf = 1.
          if message_type = chari.
            message i311 with tvakt-bezei vbak-vbeln.
          else.
            message s311 with tvakt-bezei vbak-vbeln.
          endif.
          message_collect_lord.
        else.
          if message_type = chari.
            case da_subrc_lf.
              when 0 or 90.
                message i260 with tvakt-bezei vbak-vbeln da_vbeln.
                message_collect_lord.
              when 16.
                message i609 with tvakt-bezei vbak-vbeln da_vbeln.
                message_collect_lord.
              when 98.
                message i856 with tvakt-bezei vbak-vbeln.
                message_collect_lord.
              when others.
                message i261 with tvakt-bezei vbak-vbeln.
                message_collect_lord.
            endcase.
          else.
            case da_subrc_lf.
              when 0 or 90.
                message s260 with tvakt-bezei vbak-vbeln da_vbeln.
                message_collect_lord.
              when 16.
                message s609 with tvakt-bezei vbak-vbeln da_vbeln.
                message_collect_lord.
              when 98.
                message s856 with tvakt-bezei vbak-vbeln.
                message_collect_lord.
              when others.
                message s261 with tvakt-bezei vbak-vbeln.
                message_collect_lord.
            endcase.
          endif.
        endif.
*   Push message to BAPI return table
        if call_bapi = charx.
          perform vbap_init.
          perform message_vbfs_aufbauen(sapfv45l) using sy-msgid
                                                        sy-msgno
                                                        'S'
                                                        sy-msgv1
                                                        sy-msgv2
                                                        sy-msgv3
                                                        space.
        endif.
      endif.
      if not ( call_activity eq gc_activity_lord and
               gf_no_commit  eq charx                ).
*       Do not revoke the indicator GESPERRT if the LORD-API
*       saves w/o COMMIT (and the enqueues are hence not
*       revoked via below triggered update LUW)
        gesperrt = space.
      endif.
* Belegnummer exportieren, wird in sd_sales_docu_maintain_dialog
* importiert
      da_vbeln_save = vbak-vbeln.
      export da_vbeln_save
             to memory id container_sales_doc.

*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* In dieser Routine werden die X-Tabellen teilweise gelöscht !
      perform change_document_create.
    endif.

* In dieser Routine wird im EDI-Fall der Status 53 geschrieben
* In this routine the status record is fill with the value 53
    if idoc_number ne space and
       sy-binpt eq charx and
       cattaktiv is initial.
      perform idoc_status_fill using da_edi_stop.
    endif.
enhancement-point es_mv45af0b spots es_sapmv45a.

enhancement-section     beleg_sichern_21 spots es_sapmv45a.
    if ( call_function = space or
         ( us_syncron = charx and
           call_activity ne gc_activity_lord ) ) or
       ( call_activity eq gc_activity_lord and
         gf_no_commit is initial ).
      if us_syncron = space.
        commit work.
      else.
        commit work and wait.
      endif.
    else.
      if call_activity ne gc_activity_lord.
*       Do not set these indicators if the LORD-API
*       saves w/o COMMIT
        g_no_init_config_data = charx.
        g_no_dequeue_sd_sales = charx.
      endif.
    endif.
end-enhancement-section.
enhancement-point beleg_sichern_22 spots es_sapmv45a.

ENHANCEMENT-SECTION     BELEG_SICHERN_23 SPOTS ES_SAPMV45A.
    if not ( call_activity eq gc_activity_lord and
             gf_no_commit eq charx ).
      if call_function = charx.
        g_no_itob_buf_cleanup = charx.
        perform beleg_initialisieren.
        clear g_no_itob_buf_cleanup.
      else.
        perform beleg_initialisieren.
      endif.
    endif.
END-ENHANCEMENT-SECTION.
    ch_subrc = 0.

* Damit "Save in Process" im Fehlerfall auch wieder ausgeschaltet wird.
  enddo.

  if ch_subrc > 0.
    clear da_vbeln.
    export da_vbeln to memory id 'SD_SAVE_IN_PROCESS'.
  endif.

endform.                    "BELEG_SICHERN


*&---------------------------------------------------------------------*
*&      Form  remove_save_in_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form remove_save_in_process.

  data: da_vbeln like vbak-vbeln.

  clear da_vbeln.
  export da_vbeln to memory id 'SD_SAVE_IN_PROCESS'.

endform.                    "remove_save_in_process