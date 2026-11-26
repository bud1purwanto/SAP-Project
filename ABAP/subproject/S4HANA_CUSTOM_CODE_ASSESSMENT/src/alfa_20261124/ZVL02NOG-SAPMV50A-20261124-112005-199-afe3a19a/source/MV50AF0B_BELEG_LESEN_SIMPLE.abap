                                                            "v_n_527241
*&---------------------------------------------------------------------*
*&  Include           MV50AF0B_BELEG_LESEN_SIMPLE                      *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  beleg_lesen_simple
*&---------------------------------------------------------------------*

form beleg_lesen_simple using if_likp_vbeln like likp-vbeln. "n_534514


* Tabellen mit Fehlerhandling lesen
  data: bl_error,
        da_fcode like sy-tcode,
        lf_subrc like sy-subrc,
*       Lines deleted n_523254
        lf_exit_form  like charx,
        lf_wadat_ist  like likp-wadat_ist,
        lf_change_off like v50agl-dlv_change_off,
        ls_dnact      like rdgdnact.

  data: lf_erdat type erdat.

  clear: lf_erdat.
  data: lf_gts_display_mode type boolean.

* EhP 3: Actual goods movement time
  data: ls_wadat      type shp_wadat.

  FIELD-SYMBOLS: <ls_xlips> like line of xlips.               "n_1662007


  bl_error = charx.

  likp-vbeln = if_likp_vbeln.                               "n_534514
  if likp-vbeln is initial.                                 "n_574894
    message e045(v1).
  endif.

enhancement-point beleg_lesen_simple_01 spots es_sapmv50a.
* setzen Parameter
  case t180-trvog.
    when chard.
      set parameter id 'VLM' field likp-vbeln.
    when charg.
      set parameter id 'VLG' field likp-vbeln.
  endcase.

  likp-mandt = sy-mandt.
  perform lieferung_sperren using likp-vbeln.

* Richtigen FCode setzen, wenn nach WABU ENT2 folgen soll
  if sy-ucomm eq space.
    fcode = 'ENT2'.
    perform transform_fcode changing fcode.
  endif.

* Read from Archive
  if t180-tcode = 'VLODAR' or t180-tcode = 'VLIDAR'.
    if ( t180-bldgr eq gc_new_dialog_outb or
         t180-bldgr eq gc_new_dialog_inb ) and
       sy-binpt eq space                   and
       sy-batch eq space                   and
       fcode    ne 'WABU_T'.
*     New dialog: Read delivery from archive and match it into common
*     part if it exists
      perform read_delivery_from_archive using    likp-vbeln
                                                  lf_erdat
                                         changing lf_subrc.
      if lf_subrc eq 0.
*       Delivery could be reloaded successfully
        if fcode eq 'IFLU_T'.
*         Display of document flow is not supported for archived
*         deliveries -> use Document Relationsship Browser instead
          message e576.
        endif.
        exit.
      else.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

* Read from database or archive if necessary
  else.
* Lieferungs-Kopf
  perform likp_select using    likp-mandt
                               likp-vbeln
                      changing lf_subrc.
  endif.

  if lf_subrc ne 0.                                         "v_n_574894
    if ( t180-bldgr eq gc_new_dialog_outb or
         t180-bldgr eq gc_new_dialog_inb ) and
       sy-binpt eq space                   and
       sy-batch eq space                   and
       fcode    ne 'WABU_T'.
*     New dialog: Read delivery from archive and match it into common
*     part if it exists
      perform read_delivery_from_archive using    likp-vbeln
                                                  lf_erdat
                                         changing lf_subrc.
      if lf_subrc eq 0.
*       Delivery could be reloaded successfully
        if fcode eq 'IFLU_T'.
*         Display of document flow is not supported for archived
*         deliveries -> use Document Relationsship Browser instead
          message e576.
        endif.
        exit.
      else.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    else.
*     Old dialog or BI: Show error message that delivery does not exist
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.                                                    "^_n_574894

  if likp-spe_loekz eq charx.                               "v_n_1017222
    message e008(/spe/id_handling) with likp-vbeln.
  endif.                                                    "^_n_1017222

* in case of change management switch to buffered reading
  do 1 times.

    check not likp-lgnum is initial.

    if likp-verursys is initial.
      check likp-vlstk = 'B'.
    else.
      check likp-vlstk = 'A'.
    endif.

    call function 'SHP_CHANGE_ACTIVE'
      exporting
        if_vbtyp         = likp-vbtyp
        if_lgnum         = likp-lgnum
        if_logsys        = likp-verursys
      importing
        ef_active        = v50agl-dlv_change                "n_523254
        ef_emergency_off = v50agl-dlv_change_off.
    if not v50agl-dlv_change is initial.             "v_n_537948/523254
*     Change management for decentralized WMS is active
      if likp-verursys is initial and
         not v50agl-dlv_change_off is initial.
*       Change management is active but temporarily disabled in the
*       ERP system
*       -> Continue with BELEG_LESEN_SIMPLE
        exit.
      else.
*       --> Continue with BELEG_LESEN_BUFFERED
      endif.
    else.
*     Change management for decentralized WMS is not active
*     -> Continue with BELEG_LESEN_SIMPLE
      exit.
    endif.                                                  "^_n_537948

*   change management active => switch to buffered read (use CSL)
    perform lieferung_entsperren using likp-vbeln.

    perform beleg_lesen_buffered using likp-vbeln
                                       charx
                                       space
                                       nicht_sperren.

    lf_exit_form = charx.

    exit.

  enddo.

  check lf_exit_form is initial.

* normal reading - no buffer...

* no buffering => no buffer refresh necessary at the end
  v50agl-no_buffer_refresh = charx.

   *likp = likp.
  ylikp = likp.
  slikp-tabix = 1.
  move-corresponding likp to xlikp.
  xlikp_updkz = updkz_old.

* Move scenario flag to buffer                              "v_n_990782
  if likp-spe_le_scenario ne space.
    call method /spe/cl_ctrl=>buffer_scenario_flag
      exporting
        i_le_scenario = likp-spe_le_scenario.
  endif.                                                    "^_n_990782

* Falls Aufruf aus dem Lieferungsmonitor: WADAT_IST aus Memory holen
  if ( sy-tcode = 'VL02N' or sy-tcode = 'VL32N' )
       and sy-binpt ne space.
ENHANCEMENT-SECTION     EHP_BELEG_LESEN_SIMPLE_02 SPOTS ES_SAPMV50A.
    import wadat_ist to lf_wadat_ist from memory id 'WS_LM'.
    if not lf_wadat_ist is initial.
      likp-wadat_ist = lf_wadat_ist.
      if likp ne *likp.
        xlikp = likp.
        append ylikp.
        xlikp_updkz = updkz_update.
      endif.
    endif.
end-enhancement-section.
  endif.

* Zuliefererabwicklung: Korrekturlieferungen nicht änderbar
  if likp-klief = charx and
     t180-trtyp = charv.
    message e136.
  endif.

* Berechtigung prüfen
* if likp-vbtyp na vbtyp_mmli.                              "n_1438394
  if not likp-vstel is initial.                             "n_1438394
    data: da_actvt like tact-actvt,
          da_subrc like sy-subrc.
    if fcode(4) = 'DRCK' or                                 "46A BEY
       fcode(4) = 'PRNT'.                                   "n_586182
      da_actvt = '04'.
    else.
      da_actvt = '  '.
    endif.
    perform berechtigung_pruefen using da_actvt da_subrc.
    if da_subrc ne 0  and da_actvt = actvt_04.
      perform lieferung_entsperren using likp-vbeln.
      message e087 with likp-vstel.
    endif.
  endif.

* Steuerungstabellen zum Belegkopf lesen.
  perform tvlk_select using likp-lfart
                              bl_error
                              sy-subrc.

* prüfen auf gültige Kombination
* Auslieferungen dürfen nur mit tcode VL01-VL03 bearbeitet werden,
* Anlieferungen nur mit tcode Vl31-VL33 und Grob-WE mit tcode VL41-VL43
  if likp-vbtyp ca vbtyp_liav and t180-trvog ne chard or
     likp-vbtyp ca vbtyp_grwe and t180-trvog ne charg or
     likp-vbtyp ca vbtyp_lief and t180-trvog ne char6.
    message e143.
  endif.

* betroffene Versandstelle lesen
  if likp-vbtyp na vbtyp_mmli.
    perform tvst_select using likp-vstel
                              bl_error
                              sy-subrc.
  endif.


* Partner Lieferungskopf lesen
  perform vbpa_select using likp-mandt
                            likp-vbeln.

* Belegstatus lesen
  perform vbuk_select using likp-mandt
                            likp-vbeln.
  xvbuk = cvbuk.
  append xvbuk.

* Belegstatus der Positionen lesen
  perform vbup_select using likp-mandt
                            likp-vbeln.
*
  cvbak-mandt = likp-mandt.
  cvbak-vbeln = likp-vbeln.
  perform cvbup_uebernehmen(sapfv50c).
  cvbak-vbeln = space.

* Belegfluß lesen
  perform vbfa_select using likp-mandt
                            likp-vbeln.

  perform cvbfa_uebernehmen(sapfv50c) using likp-vbeln.


* Positionen lesen und Default-Umfang in IVBAP einstellen
  perform lips_select using likp-mandt
                            likp-vbeln.

* fill workarea                                              "v_n_539580
  read table xlips index 1.
  if sy-subrc eq 0.
    rv50a-vtweg = xlips-vtweg.
    rv50a-spart = xlips-spart.
  endif.                                                    "^_n_539580

* fill SITKZ
  if cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.    "v_n_1662007
    LOOP at xlips ASSIGNING <ls_xlips>
                  where not bwart is INITIAL.
      if <ls_xlips>-sitkz is INITIAL.
        likpd-sitkz = charn.
      else.
        likpd-sitkz = <ls_xlips>-sitkz.
      endif.
      exit.
    endloop.
    xlikp-sitkz = likpd-sitkz.
  endif.                                                    "v_n_1662007

  ilips_tabix_zeile_1 = 1.

* Warenempfänger lesen                                       "v_n_539580
  if likp-vbtyp na vbtyp_mmli.
    perform warenempfaenger_bereitstellen.
  else.
    perform lieferavis_eatab_fuellen.
  endif.                                                    "^_n_539580

* Fehlerprotokoll lesen
  perform vbuv_select using likp-vbeln.

* Verkaufsorganisation wegen Sprache lesen
  if likp-vbtyp na vbtyp_mmli.
    perform tvko_select using likp-vkorg
                              space
                              sy-subrc.

* TVTA fuer Materialzugriffe lesen
    if not rv50a-vtweg is initial and
       not rv50a-spart is initial.
      perform tvta_select using likp-vkorg
                                rv50a-vtweg
                                rv50a-spart.
    endif.
  endif.

* Konditionen einlesen im Änderungsmodus, falls Kalkulationsschema da
  if t180-trtyp = charv and not likp-kalsp is initial.
    perform konv_select.
  endif.

* Read all messages inbound and outbound
* Performance: Messages for outbound deliveries only
* if no_messages update is set
  if (     likp-vbtyp         ca vbtyp_lief
       and no_messages_update is initial )
  or ( likp-vbtyp ca vbtyp_liav )
  or ( likp-vbtyp ca vbtyp_grwe ).
* Nachrichten lesen
    data: xobjky_to like nast-objky.
* Fuellen Key fuer Nachrichtenstatus
    move likp-vbeln to xobjky.
    move likp-vbeln to xobjky_to.
    move '9999999999'   to xobjky_to+10.
* Nachrichten lesen
    call function 'RV_MESSAGES_READ'
      exporting
        msg_kappl    = tvlk-kappl
        msg_objky    = xobjky
        msg_objky_to = xobjky_to.
  endif.

* Messages read for application V4 (only outbound)
  if (     likp-vbtyp         ca vbtyp_lief
       and no_messages_update is initial ).
    call function 'RV_MESSAGES_READ'
      exporting
        msg_kappl    = 'V4'
        msg_objky    = xobjky
        msg_objky_to = xobjky_to.
  endif.

* Füllt Workarea KOMKBV2 für Nachrichtenfindung V2
* Outbound delivery
  if (     likp-vbtyp         ca vbtyp_lief
       and no_messages_update is initial ).
    call function 'COMMUNICATION_AREA_KOMKBV2'
      exporting
        msg_likp  = likp
        msg_old   = 'X'
        msg_rv50a = rv50a
        msg_vbuk  = vbuk
        msg_trtyp = t180-trtyp
      tables
        tab_part  = part
        tab_lips  = xlips
        tab_vbpa  = xvbpa.
  endif.

* Fill workarea: inbound delivery
  if likp-vbtyp ca vbtyp_liav.
    call function 'COMMUNICATION_AREA_KOMKBE1'
      exporting
        msg_likp  = likp
        msg_old   = 'X'
        msg_rv50a = rv50a
        msg_vbuk  = vbuk
        msg_trtyp = t180-trtyp
      tables
        tab_part  = part
        tab_lips  = xlips
        tab_vbpa  = xvbpa.
  endif.

* Fill workarea: rough goods receipt
  if likp-vbtyp ca vbtyp_grwe.
    call function 'COMMUNICATION_AREA_KOMKBM1'
      exporting
        msg_likp  = likp
        msg_old   = 'X'
        msg_rv50a = rv50a
        msg_vbuk  = vbuk
        msg_trtyp = t180-trtyp
      tables
        tab_part  = part
        tab_lips  = xlips
        tab_vbpa  = xvbpa.
  endif.

*   Aufbau einer Hilfstabelle für Serialnummern in Verbindung mit
*   Chargen
  refresh xlips_ser.
  loop at xlips.
    xlips_ser-posnr = xlips-posnr.
    xlips_ser-uecha = xlips-uecha.
    xlips_ser-anzsn = xlips-anzsn.
    append xlips_ser.
  endloop.
  sort xlips_ser by posnr.

* Gefahrgutzusatzdaten lesen
  perform gg_lipsdg_read using xlips-vbeln.

* Dangerous goods: Template-Material processing
* Check if templatematerial processing should be processed
  move-corresponding likp to ls_dnact.
  call function 'EHS003_CHECK_TPPR_ACTIVE'
    exporting
      i_dnact     = ls_dnact
      i_vbtyp     = likp-vbtyp
    exceptions
      tppr_active = 1
      others      = 2.

  if sy-subrc = 1.
* EH&S functionality is active
    v50agl-tppr_active = charx.
    call function 'EHS003_DGMSD_DLV_READ'
      exporting
        i_likp_tab = likp
      exceptions
        others_    = 1.
  endif.

* Generic system service activation necessary for dialog processing
* only. Call moved to UEBERSICHT_ANSTEUERN (FV50PF0U) n_533596

* Prüfen,ob Gefahrgutprüfung aktiv ist. Kennzeichen in V50AGL übernehmen
  perform gg_check_active_simple changing v50agl-gefahrgut_aktiv.
  if v50agl-gefahrgut_aktiv = gc_gg_inaktiv.
    perform cua_fcode_allow using fcode_gefahrgutpruefung no.
  endif.

* Fill cross-docking process number if available
  call method /spe/cl_cd_docflow=>get_process_number
    exporting
      if_delivery   = likp-vbeln
    receiving
      ef_cd_process = likpd-spe_cd_process.

  move-corresponding likp to xlikp.
  move-corresponding likpd to xlikp.
  move-corresponding vbuk to xvbuk.


* Hinweis bzw. Aenderungseinschraenkung abh. von Status in Transport
  if t180-trtyp ne chara.              "Nicht beim Anzeigen
    if aufrufer ne chart.
      call function 'SD_DELIVERY_SHIPMENT_STATUS'
        exporting
          i_likp                = xlikp
          i_vbuk                = xvbuk
        tables
          i_vbfa                = xvbfa
        exceptions
          shipment_status_info  = 1
          delivery_change_block = 2
          shipping_unit_freight = 3.
      if sy-subrc ne 0.
*       653424: Delivery data must not be edit, if the inbound shipment
*       is completed or the shipment costs are settled. The correction
*       of note 518736 has to be called off. Instead of it, the modifi-
*       cation note 653425 is made, explaining all the risks for the
*       succeeding document to become inconsistent by changes of the
*       delivery data during Goods Receipt.
*       The statement marked with '(n_558147)' is coming with 653424,
*       but a completion of correction note 558147.
        if ( sy-subrc eq 2 or sy-subrc eq 3 ).
*       line deleted                                         n_1361227
*          likp-vbtyp na vbtyp_liav. "n_518736 called off by n_653424
          status_transport = sy-subrc.
        endif.
        if gs_mhpar-glomd eq gc_glomd-dialog.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endif.
    endif.
  endif.

* GTS: Determine whether the delivery is changeable
  if not likp-sakes is initial.
    perform safe_keeping_mode_det changing lf_gts_display_mode.
  endif.
* Switch to display mode in certain situations
  if t180-trtyp ne chara and
     ( ( ( likp-vlstk eq charb or                          "n_1451453
           ( likp-vlstk eq charc and vbuk-wbstk eq charb ) ) and
         v50agl-confirm_central is initial and
         ( v50agl-dlv_change is initial or                  "n_583991
           not v50agl-dlv_change_off is initial )           "n_583991
        ) or
       ( likp-vlstk ca 'EF' and
         likp-verursys is initial and                       "n_547549
         v50agl-confirm_central is initial ) or
         vbuk-bestk eq chara                 or
*        GTS: not changeable if under safe keeping
       ( likp-sakes          eq charb and
         lf_gts_display_mode eq charx )      or
*      SPE OUTB outb. deliveries that are planned for distribution
*      are only changable via CRM or EWM
       ( likp-vlstk = chard      and
         likp-vbtyp = vbtyp_lino and
         likp-spe_le_scenario = charc )      or
       ( likp-stge_loc_change eq gc_stge_loc_change-requested and
         v50agl-dialog ne space )                            "n_1302686
     ).
* SPE MP 25.02.2005 SPE returns can only be changed with reservations
    data: lf_display_mode type c.
    lf_display_mode = charx.
  ELSEIF t180-trtyp EQ chara and                           "v_n_1668425
         ( likp-vlstk eq charb or likp-vlstk eq charc ).
* Button "Display <-> Change" (fcode =  'ANZA_T') should be disabled for
* distributed delivery also in display mode (VL33N), so that user can not
* switch to change mode
    lf_display_mode = charx.                               "^_n_1668425
  endif.
  if lf_display_mode eq space and
     t180-trtyp ne chara      and
     v50agl-dialog ne space   and
     likp-vbtyp eq vbtyp_lire and
     ( likp-spe_le_scenario eq gc_le_scenario-return or
     likp-spe_le_scenario eq gc_le_scenario-tpop ).
    message s105(/spe/ret) display like 'W'.
  endif.

  if lf_display_mode ne space.
* end SPE MP 21.01.2005

*   Dataloss flag not necessary in display mode.
    clear r185d-dataloss.
*   Set new internal transaction code
    if t180-tcode = 'VL32N'.                                "v_n_1374189
      perform t180_interpretieren using 'VL33N'.
    elseif t180-tcode = 'VL02N'.
      perform t180_interpretieren using 'VL03N'.
    elseif t180-tcode = 'VL02'.
      perform t180_interpretieren using 'VL03'.
    elseif t180-tcode = 'VLPOD'.
      perform t180_interpretieren using 'VLPODA'.
    endif.
    call function 'DEQUEUE_ALL'.
    refresh cua_exclude.                                    "^_n_1374189
    perform exclude_function_trtyp.
    perform cua_fcode_allow using 'ANZA_T' no.              "n_617078
    if likp-vlstk eq charb or
       ( likp-vlstk eq charc and vbuk-wbstk eq charb ).      "n_1451453
      if v50agl-dlv_change_off is initial.                  "v_n_583991
        message s239(vl).
      else.
        message s579(vl).
      endif.                                                "^_n_583991
    elseif likp-vlstk eq chare.
      message s477(vl).
    elseif likp-vlstk eq charf.
      message s481(vl).
    elseif vbuk-bestk eq chara.
      message s357(vl).
    elseif likp-vlstk eq chard.
      message s049(/spe/vl).
    elseif likp-sakes eq charb.             "GTS Safe Keeping Status
      message s594(vl).
    endif.
  endif.
enhancement-point mv50af0b_beleg_lesen_simple_01 spots es_sapmv50a static .

enhancement-point mv50af0b_beleg_lesen_simple_02 spots es_sapmv50a.

  if t180-trtyp eq chara and
     likp-stge_loc_change eq gc_stge_loc_change-requested.
    message s757(vl) display like 'W'.                      "n_1302686
  endif.

  if status_transport ne 0.
    do 99 times varying da_fcode from cua_exclu_transport-f01
                                 next cua_exclu_transport-f02.
      if da_fcode(4) = '9999'.
        exit.
      endif.
      perform cua_fcode_allow using da_fcode no.
    enddo.
  endif.

* Tabelle TVPOD einlesen
  if ( not vbuk-pdstk is initial or
     not xvbuk-pdstk is initial ).
    perform pod_tvpod_read.
  endif.

*  TM ERP Integration II - UI Extension
  PERFORM tm_init.

* In case of posting goods issue of an outbound delivery which was
* splitted, lock original delivery  (ULa, 4.6c)
  if        fcode(4)        =  'WABU'
    and     likp-vbtyp      ca vbtyp_lief
    and not tvshp-splitlock is initial.
    perform dsp_vbeln_old_lock using likp-vbeln.
  endif.

  perform xylog_copy_xtabs.                                  "n_1636529

  perform call_badi_read_delivery.

* Userexit
  perform userexit_read_document.

endform.                    " beleg_lesen_simple

*&---------------------------------------------------------------------*
*&      Form  XYLOG_COPY_XTABS
*&---------------------------------------------------------------------*
form XYLOG_COPY_XTABS.                                        "n_1636529

  CALL FUNCTION 'SD_DELIVERY_PUT_XTAB'
    EXPORTING
      IT_XLIPS       = xlips[]
      IT_XVBUP       = xvbup[].

endform.                    " XYLOG_COPY_XTABS                                                            "^_n_527241