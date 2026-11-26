***INCLUDE FV50XF0B_BELEG_DATEN_INIT .
*---------------------------------------------------------------------*
*       FORM BELEG_DATEN_INIT                                         *
*---------------------------------------------------------------------*
*       Zurücksetzen aller Datenbereiche                              *
*                                                                     *
*       Im Falle des Lieferavis erfolgt der Aufruf per CALL DIALOG    *
*       dabei werden folgende Tabellen bereits gefüllt übergeben:     *
*         XLIKP
*         XLIPS
*         XVBFA
*         XVBPA
*         XVBUK
*         XVBUP
*         YVBUK
*         YVBUP
*         CVBLS
*         CVBFS
*---------------------------------------------------------------------*

form beleg_daten_init.

* allgemeine Felder, EATABs etc
  clear:   rv50a,
           rv02p,
           lv50c,
           posnr_umsetzung.
  refresh: posnr_umsetzung.
ENHANCEMENT-POINT EHP_BELEG_DATEN_INIT_01 SPOTS ES_FV50XF0B_BELEG_DATEN_INIT INCLUDE BOUND .
  clear: kuagv,
         kuwev, kunnr_old,
         kurgv,
         likp, slikp-tabix,
         xlips_high_posnr,
         ilips_tabix_zeile_1,
         r185d-dataloss,
         rv50a-lips_selkz,
         ilips-selkz,
         status_transport.

  clear: save_287_menge.                                    "n_615643

* Konditionstabelle
  call function 'PRICING_REFRESH'                           "50A
       tables
            tkomk = tkomk
            tkomv = tkomv.
  refresh: gt_pricing_type_save.                             "470

* Kopf der Lieferung
  clear:   likp,
           xlikp,
           ylikp,
           ylikp_updkz,                                    "note 145944
           slikp-tabix.
* Clear number administration for batch items
  clear: posnr_last.
  refresh: gt_batch_item_num.
  if kz_lieferavis eq space.
    refresh: xlikp,
             ylikp.
  else.
    refresh: ylikp.
  endif.
  if kz_lieferavis eq space and v50agl-kommirueckmeldung = space
     and no_dequeue = space.
    call function 'DEQUEUE_ALL'
      exporting
        _synchron = 'X'
      exceptions
        others    = 0.
  endif.
  refresh likp_dat.

* Positionen der Lieferung
  clear:   lips,
           xlips, wat_prot,
           ylips,
           hlips,
           ilips,
           slips,
           xlips_high_posnr.
enhancement-point beleg_daten_init_01 spots es_fv50xf0b_beleg_daten_init include bound.
  if kz_lieferavis eq space.

    call function 'SD_DELIVERY_CUMULATIVE_REFRESH'
      exceptions
        others = 1.

    refresh: xlips, xvbuv, yvbuv, wat_prot,
             xlips_ref,                                            "AIP
             ylips,
             hlips,
             ilips,
             slips.
  else.
    refresh: ylips,
             hlips,
             ilips,
             slips.
  endif.

enhancement-point beleg_daten_init_02 spots es_fv50xf0b_beleg_daten_init include bound.
* Kopf des Auftrags
  clear:   cvbak,
           yvbak,
           svbak-tabix.

* Positionen der Auftrags
  clear:   xvbap,
           yvbap,
           xvbapf,
           hvbap,
           uvbap,
           gvbap,
           ivbap,
           svbap.
  refresh: xvbap,
           yvbap,
           xvbapf,
           uvbap,
           gvbap,
           ivbap,
           svbap.

* Einteilungen
  clear:   xvbep,
           yvbep,
           ivbep,
           svbep.
  refresh: xvbep,
           yvbep,
           ivbep,
           svbep.

* Kopf-Stati
  clear:   cvbuk,
           yvbuk,
           xvbuk,
           svbuk_tabix.
  if kz_lieferavis eq space.
    refresh: xvbuk,
             yvbuk.
  endif.

* Positions-Stati
  clear:   xvbup,
           yvbup.
  if kz_lieferavis eq space.
    refresh: xvbup,
             yvbup.
  endif.

* Belegfluß
  clear:   xvbfa,
           yvbfa.
  if kz_lieferavis eq space.
    refresh: xvbfa,
             yvbfa.
  else.
    refresh: yvbfa.
  endif.
  clear:   xvtfa,
           yvtfa.
  refresh: xvtfa,
           yvtfa.

* Partner
  clear:   xvbpa,
           yvbpa,
           svbpa,
           kuwev.
  if kz_lieferavis eq space.
    refresh: xvbpa,
             yvbpa,
             svbpa,
             xvbadr.
  else.
    refresh: yvbpa,
             svbpa.
  endif.


  call function 'RV_PARTNER_REFRESH'.

  call function 'RV_TEXT_COPY_REFRESH'.
* Do not remove unsaved addresses in case of immediate deliveries
  data: lf_not_clear_addr type c.                           "v_n_773387
  import lf_not_clear_addr from memory id 'LE_NO_ADDR_CLEAR'.
  if v50agl-sofauftrag eq space and
     lf_not_clear_addr is initial.                          "^_n_773387
    call function 'ADDR_MEMORY_CLEAR'
      exporting
        force              = 'X'
      exceptions
        unsaved_data_exist = 0
        internal_error     = 0
        others             = 0.
  else.
    call function 'ADDR_MEMORY_CLEAR'
      exporting
        force              = space
      exceptions
        unsaved_data_exist = 0
        internal_error     = 0
        others             = 0.
  endif.


  refresh xthead.

* Findungsprotokoll
  if lepad_pakti-uname = sy-uname and
     lepad_pakti-kzakt ca 'L'.
    call function 'LE_PAD_REFRESH'.
  endif .

* Nachrichten
  clear:   nat,
           no_messages_update.                              "n_731003
  refresh: nat.

enhancement-section     fv50xf0b_beleg_daten_init_01 spots es_fv50xf0b_beleg_daten_init include bound .
  if sy-oncom ne 'P' and                                    "v_n_946479
    ( v50agl-no_commit = 'X' or v50agl-sofauftrag = 'X' ).
    perform messages_refresh on commit level level_msg_init."^_n_946479
  else.
    perform messages_refresh.
  endif.
end-enhancement-section.

* Serialnummern
* no refresh serialnumbers for production orders            "v_n_667847
* if transactions CO01, CO40, CO08 in use
  if v50agl-kommirueckmeldung is initial.
    case call_activity.
      when activity_assembly.
      when activity_assembly_co40.
      when activity_assembly_co08.
      when activity_assembly_co02.                          "n_810497
      when activity_assembly_co07.                          "n_810497
      when activity_assembly_co10.                          "n_810497
      WHEN activity_assembly_co05.                          "N_1084189
      WHEN activity_assembly_co41.                          "N_1084189
      WHEN activity_assembly_cohv.                          "N_1084189
      WHEN activity_assembly_pk12.                          "n_1255510
      WHEN activity_assembly_pk13.                          "n_1255510
      WHEN activity_assembly_pk21.                          "n_1255510
      WHEN activity_assembly_pk22.                          "n_1255510
      WHEN activity_assembly_pkrf.                          "n_1255510
      when others.
        perform serialnumber_refresh.
    endcase.                                                "^_n_667847
  endif.
* Versandtermine
  if aufrufer ne chart and v50agl-sammelgang = space
     AND v50agl-sofauftrag EQ space                           "n_1519960
     AND call_activity NE activity_assembly
     and call_activity ne activity_service_order
     and call_activity ne act_rueck_service_order                   "470
     and v50agl-pp_delivery eq space.
    call function 'SD_DEADLINE_REFRESH'.
  endif.
* LIPS-Referenzdaten
  perform lr_reference_data_refresh.
* Nicht änderbare Felder
  perform dlfld_refresh.
* Gefahrgutzusatzdaten
  perform gg_lipsdg_refresh.
* Gefahrgut: Template-Material-Abwicklung
  call function 'EHS003_DGMSD_REFRESH'
    exporting
      i_vbtyp = 'J'                                           "n_1137766
    exceptions
      others_ = 1.

* Bedarfe
  data atp_type type les_atp_type.
  call function 'LE_ATP_GET_VERSION'
    importing
      atp_type = atp_type.

  if atp_type eq charo.
    clear:   xvbbe,
             yvbbe,
             avbbd,
             avbbd_yvbbd_merker,                            "HW 562105
             xvbbs,
             yvbbs.
    refresh: xvbbe,
             yvbbe,
             avbbd,
             avbbd_yvbbd_merker,
             xvbbs,
             yvbbs.

    call function 'RV_REQUIREMENT_REFRESH'.
  else.
    clear:   xvbbe,
             yvbbe,
             xvbbs,
             yvbbs.
    refresh: xvbbe,
             yvbbe,
             xvbbs,
             yvbbs.

    call function 'LE_ATP_REFRESH'
      exporting
        if_kz_avbbd = charx
        if_kz_lv03v = charx.
  endif.

* WA-Schnittstelle
enhancement-point beleg_daten_init_10 spots es_fv50xf0b_beleg_daten_init static include bound.

enhancement-section     beleg_daten_init_03 spots es_fv50xf0b_beleg_daten_init include bound.
  if v50agl-sammelgang = space and no_imseg_refresh = space.
    perform ximseg_refresh(sapfv50w).
  endif.
end-enhancement-section.

* POD / LEB Data refresh                                    "46A
  clear:   gt_tvpod, gt_ytvpod, gt_check_pod, gs_error_pod.
  refresh: gt_tvpod, gt_ytvpod, gt_check_pod.
  data: gf_step like sy-tabix.
  clear gf_step.
  export gf_step to memory id 'GF_STEP'.
  clear:   gf_anz_pod, gf_lines_pod, gf_error_pod.

* Incompleteness data
  if kz_lieferavis eq space.                                "46A
    perform uc_refresh(sapfv50u).
  endif.
* reset subscreen for incompletion log (611 = empty)
  bottom_subscreen = '611'.                                 "n_859822

* Kennzeichen
  clear: r185d-dataloss,
         kz_wareneingang,
         packdaten_verbuchen.
* Sammelgang: Kopiertabellen, da aus Übergabe gefüllt
*           : Gruppe
*           : Protokollinfo
* IF V50AGL-SAMMELGANG = CHARX. "note 138960

  clear:   cvbap,
           cvbep,
           cvbfa,
           cvbkd,
           cvbpa,
           cvbup.
  refresh: cvbap,
           cvbep,
           cvbfa,
           cvbkd,
           cvbpa,
           cvbup.

  clear:   kclips.                                          "n_986131
  refresh: kclips.                                          "n_986131
  clear:   cvbss.
  refresh: cvbss.

  if v50agl-sammelgang = charx.
    clear:   cvbfs,
             cvbls.
    refresh: cvbfs,
             cvbls.

    call function 'SD_CREDIT_REFRESH'.

  endif.

* Aussenhandel: Exportdaten
  call function 'EXPIMP_TABLES_REFRESH'.

* Aussenhandel: Dokumentengeschaeft: Initialisierungsroutinen
  call function 'RV_LOC_INIT_PREPARE'.

* Aussenhandel: Dokumentengeschaeft: Initialisieren Protokoll
*  CALL FUNCTION 'RV_FOR_TRADE_PROTOCOL_INIT'
*       EXCEPTIONS
*            OTHERS  = 1.

* Aussenhandel: Gesetzliche Kontrolle: Initialisieren SLS-Daten
  call function 'FT_SLS_PARTNER_ADDR_MEM_INIT'
    exporting
      i_base_document = '2LI'.

* Packdaten
  if v50agl-kommirueckmeldung is initial.
    call function 'HU_PACKING_REFRESH'.
  endif.

* QM-Daten
  call function 'QAAT_SD_INITIALIZE'
    exporting
      status_buff_init = status_buffer_init.
  call function 'QMHU_INITIALIZE'.                          "SP_557245

* purchaseorder data:
  clear: xeket, xekpo, xmseg.
  refresh: xeket, xekpo, xmseg.

enhancement-section     beleg_daten_init_11 spots es_fv50xf0b_beleg_daten_init include bound.
  clear: aufrufer.
end-enhancement-section.

enhancement-point beleg_daten_init_21 spots es_fv50xf0b_beleg_daten_init include bound .

  clear v50agl-deadline_init.
  clear v50agl-splitprot_requested.
  clear: v50agl-dlv_change, v50agl-dlv_change_off.
  clear v50agl-display_from_archive.                        "n_574894
  refresh gt_splitprot.
  refresh gt_finchdel.                                      "n_786148

  if not gi_badi_delivery is initial.              "n_530754/n_637289
    call method gi_badi_delivery->initialize_delivery
      exporting
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      changing
        cs_v50agl_cust = v50agl_cust.
  endif.                                                    "n_530754

* Brasilianische Felder in brasilianischer                  "v_n_645951
* Funktionsgruppe initialis.
  call function 'J_1B_SD_SH_INIT_LOCAL'.                    "^_n_645951

* Reset buffered scenario flag
  call method /spe/cl_ctrl=>reset_scenario_flag.            "n_990782

* Payment Service Provider
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    cl_sls_paysp_integration=>refresh( ).
  ENDIF.

* Userexit zum intialisieren
  perform userexit_refresh_document(sapmv50a).

  refresh gt_serno_change.                                  "470

* Initialize docubatch data                                 "n_1405579
  CALL FUNCTION 'VBDBDM_INIT'.

* Initialize SIT data                                       "n_1571231
  CLEAR: gv_sit_flag, gv_sit_cancel_flag, gv_xsit, gv_sit_doc_num,
         gv_sit_retpo, gt_sitbw[].

ENDFORM.                    "BELEG_DATEN_INIT



*&---------------------------------------------------------------------*
*&      Form  MESSAGES_REFRESH
*&---------------------------------------------------------------------*
* Wenn der Aufrufer den Comit setzt, dürfen die Nachrichten erst so
* spät wie möglich inititalisiert werden, da sonst evtl. Nachrichten
* verloren gehen.
* messages_update ist on commit, damit er als letztes läuft.
*&---------------------------------------------------------------------*
form messages_refresh.

  DATA: ls_header51 TYPE header51.

  if kz_lieferavis is initial and
     kz_grobwe is initial.
    call function 'RV_MESSAGES_REFRESH'
      exporting
        msg_kappl = 'V2'.
  endif.
  if not kz_lieferavis is initial.
    call function 'RV_MESSAGES_REFRESH'
      exporting
        msg_kappl = 'E1'.
  endif.
  if not kz_grobwe is initial.
    call function 'RV_MESSAGES_REFRESH'
      exporting
        msg_kappl = 'M1'.
  endif.
  if aufrufer ne chart.
    call function 'RV_MESSAGES_REFRESH'
      exporting
        msg_kappl = 'V4'.
    CALL FUNCTION 'V51P_GET_HEADER_DATA'
     IMPORTING
       ES_HEADER51       = ls_header51.
*   When update of delivery items for packaging material    "v_n_1473828
*   is triggered from transport, do not refresh the messages.
    IF ls_header51-object = '04' AND ls_header51-no_refresh = 'X'.
      EXIT.
    ENDIF.                                                  "^_n_1473828

    call function 'RV_MESSAGES_REFRESH'
      exporting
        msg_kappl = 'V6'.
  endif.

endform.                               " MESSAGES_REFRESH