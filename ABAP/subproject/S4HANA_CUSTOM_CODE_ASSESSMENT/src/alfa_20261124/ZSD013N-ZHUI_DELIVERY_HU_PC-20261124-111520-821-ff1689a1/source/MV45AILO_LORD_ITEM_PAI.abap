*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_ITEM_PAI
*&---------------------------------------------------------------------*

form vbap_unterlegen using uv_tabix.

  xvbap_loop_fcode = fcode.

  clear rv45a-vbap_selkz.
  clear rv45a-mabnr.

  read table svbap index uv_tabix.
  if sy-subrc ne 0 or
     svbap-tabix = 0.
*   create item
    svbap-tabix = 0.
  else.
*   change item
    read table xvbap index svbap-tabix.
    if sy-subrc ne 0.
      message a322(v1) with 'SVBAP'.
    endif.
    read table ivbap
         with key posnr = xvbap-posnr
                  binary search.
    if not ivbap-selkz is initial.
      rv45a-vbap_selkz = charx.
    endif.
  endif.

* prepare item workarea
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

endform.                    "vbap_unterlegen


*&---------------------------------------------------------------------*
*&      Form  vbsn_unterlegen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*----------------------------------------------------------------------*
form vbsn_unterlegen using uv_tabix.

  if fcode eq fcode_xvbap_loeschen.
* Weiter falls die aktuelle Zeile nicht zum Löschen selektiert wurde
    check rv45a-vbap_selkz ne selektiert.
  endif.
  if fcode eq fcode_xvbsn_loeschen.
* Weiter falls die aktuelle Zeile nicht zum Löschen selektiert wurde
    check rv45a-vbsn_selkz ne selektiert.
  endif.

  read table svbsn index uv_tabix.
  if sy-subrc ne 0 or
     svbsn-tabix = 0.
* Anlegen
    svbsn-tabix = 0.
  else.
* Ändern
    read table xvbsn index svbsn-tabix.
    if sy-subrc ne 0.
      message a322(v1) with 'SVBSN'.
    endif.
    if xvbsn-updkz eq updkz_delete.
      svbsn-tabix = 0.
    endif.
  endif.
* alle Daten bereitstellen
  perform vbsn_bearbeiten_vorbereiten(sapfv45l).

endform.                    "vbsn_unterlegen


*&---------------------------------------------------------------------*
*&      Form  VBAP-WAERK_SETZEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbap-waerk_setzen.

  vbap-waerk = vbak-waerk.

  if *vbap-waerk is initial.
     *vbap-waerk = vbap-waerk.
  endif.

endform.                    "vbap-waerk_setzen


*&---------------------------------------------------------------------*
*&      Form  vbap-posnr_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbap-posnr_pruefen.

  perform vbap-posnr_pruefen(sapfv45p) using space.

endform.                    " vbap-posnr_pruefen


*&---------------------------------------------------------------------*
*&      Form  rv45a_mabnr_filled
*&---------------------------------------------------------------------*
form rv45a_mabnr_filled.

  gv_rv45a_mabnr_gefuellt = charx.

endform.                    " rv45a_mabnr_filled


*&---------------------------------------------------------------------*
*&      Form  vbap_matnr_filled
*&---------------------------------------------------------------------*
form vbap_matnr_filled.

  gv_vbap_matnr_gefuellt = charx.

endform.                    " vbap_matnr_filled


*&---------------------------------------------------------------------*
*&      Form  vbap-matnr_pruefen
*&---------------------------------------------------------------------*
form vbap-matnr_pruefen.

  data: lv_matwa type matwa.

  perform vbap_matnr_matwa_fuellen(sapfv45p).

  if vbap-matnr ne *vbap-matnr.
    matnr_changed = charx.
  endif.

  perform vbap-matnr_pruefen(sapfv45p) using charx
                                             sy-subrc.
  perform vbap-spart_pruefen_fe(sapfv45p).

  lv_matwa = vbap-matwa.
  vbap-matwa = *vbap-matwa.
  if vbap = *vbap.
    clear matnr_changed.
  endif.
  vbap-matwa = lv_matwa.

  if vbap-matnr ne *vbap-matnr or
     not matnr_changed is initial or
     svbap-tabix = 0.
    if vbap-pstyv = *vbap-pstyv.
      clear vbap-pstyv.
    else.
      if not vbap-pstyv is initial and
         not matnr_changed is initial and
         not gv_pstyv_determ is initial.
        if vbap-pstyv eq gv_pstyv_determ.
          clear vbap-pstyv.
          clear gv_pstyv_determ.
        endif.
      endif.
    endif.
    clear vbap-arktx.
    clear vbap-sumbd.
    clear vbap-vpmat.
    clear: prf_vrkme,
           vbapd-wklnd.
  endif.

endform.                    " vbap-matnr_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-werks_pruefen
*&---------------------------------------------------------------------*
form vbap-werks_pruefen.

  perform vbap-werks_pruefen(sapfv45p) using vbap-posnr
                                             vbap-werks
                                             space
                                             space
                                             charx
                                    changing sy-subrc
                                             vbap-lgort.

endform.                    "vbap-werks_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-lgort_pruefen
*&---------------------------------------------------------------------*
form vbap-lgort_pruefen.

  perform vbap-lgort_pruefen(sapfv45p) using charx.

endform.                    "vbap-lgort_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap_fuellen
*&---------------------------------------------------------------------*
form vbap_fuellen.

  if vbapin-vrkme is initial.
    vbapin-vrkme = vbap-vrkme.
  endif.

  perform vbap_fuellen(sapfv45p).

endform.                    "vbap_fuellen


*&---------------------------------------------------------------------*
*&      Form  vbap-charg_pruefen
*&---------------------------------------------------------------------*
form vbap-charg_pruefen.

  check: vbap-charg ne *vbap-charg.

  perform vbap-charg_pruefen(sapfv45p).

endform.                    "vbap-charg_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbep-wmeng_setzen
*&---------------------------------------------------------------------*
form vbep-wmeng_setzen.

  if vbapin-kwmeng is initial.
    vbapin-kwmeng = rv45a-kwmeng.
  endif.

  perform vbep-wmeng_setzen(sapfv45e).

endform.                    "vbep-wmeng_setzen


*&---------------------------------------------------------------------*
*&      Form  vbap-vrkme_pruefen
*&---------------------------------------------------------------------*
form vbap-vrkme_pruefen.

  perform vbap-vrkme_pruefen(sapfv45p) using charx
                        changing sy-subrc sy-msgid sy-msgty sy-msgno
                                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

endform.                    "vbap-vrkme_pruefen


*&---------------------------------------------------------------------*
*&      Form  rv45a_etdat_in_check
*&---------------------------------------------------------------------*
form rv45a_etdat_in_check.

  data: da_etdat like vbep-edatu,
        da_prgbz like vbep-prgrs.

  if not rv45a-etdat is initial and
     not rv45a-prgbz is initial.
    call function 'PERIOD_AND_DATE_CONVERT_INPUT'
      exporting
        dialog_date_is_in_the_past = space
        external_date              = rv45a-etdat
        external_period            = rv45a-prgbz
      importing
        internal_date              = da_etdat
        internal_period            = da_prgbz
      exceptions
        no_data                    = 1
        period_invalid             = 2
        date_invalid               = 3.
    case sy-subrc.
      when 1.
*        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e394(v1).
      when 2.
*        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e346(v1) with rv45a-prgbz.
      when 3.
*        set cursor field 'RV45A-PRGBZ' line sy-stepl.
        message e345(v1) with rv45a-etdat rv45a-prgbz.
    endcase.
  endif.

endform.                    " rv45a_etdat_in_check


*&---------------------------------------------------------------------*
*&      Form  vbkd-waktion_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd-waktion_pruefen.

  perform vbkd-waktion_pruefen(sapfv45k) changing vbkd-waktion
                                                  sy-subrc.

endform.                    "vbkd-waktion_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap_abgrs_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbap_abgrs_pruefen.

  perform vbap_abgrs_pruefen(sapfv45p).

endform.                    "vbap_abgrs_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-pmatn_pruefen
*&---------------------------------------------------------------------*
form vbap-pmatn_pruefen.

  perform vbap-pmatn_pruefen(sapfv45p).

endform.                    "vbap-pmatn_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap_abgru_pruefen
*&---------------------------------------------------------------------*
form vbap_abgru_pruefen.

  perform vbap-abgru_pruefen(sapfv45p) using charx
                                             sy-subrc.

endform.                    "vbap_abgru_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-sernr_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbap-sernr_pruefen.

  perform vbap-sernr_pruefen(sapfv45p) using vbap-sernr.

endform.                    "vbap-sernr_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd_bsark_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd_bsark_pruefen.

  perform vbkd_bsark_pruefen(sapfv45k).

endform.                    "vbkd_bsark_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd_bsark_e_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd_bsark_e_pruefen.

  perform vbkd_bsark_e_pruefen(sapfv45k).

endform.                    "vbkd_bsark_e_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-vstel_pruefen
*&---------------------------------------------------------------------*
form vbap-vstel_pruefen.

  if vbapin-vstel is initial.
    vbapin-vstel = vbap-vstel.
  endif.

  perform vbap-vstel_pruefen(sapfv45p) using vbap-vstel
                                             charx
                                             sy-subrc.

endform.                    "vbap-vstel_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbap-route_pruefen
*&---------------------------------------------------------------------*
form vbap-route_pruefen.

  if vbapin-route is initial.
    vbapin-route = vbap-route.
  endif.
  if not vbap-route is initial.
    perform vbap-route_pruefen(sapfv45p) using vbap-route
                                               charx
                                               sy-subrc.
  endif.
  perform route_vsart_check using vbap-route
                                  charx
                                  sy-subrc.

endform.                    "vbap-route_pruefen


*&---------------------------------------------------------------------*
*&      Form  rv45a_etdat_m_change
*&---------------------------------------------------------------------*
form rv45a_etdat_m_change.

* RV45A-ETDAT changed manually
  etdat_manual = 'X'.

endform.                    "rv45a_etdat_m_change


*&---------------------------------------------------------------------*
*&      Form  vbap_bearbeiten
*&---------------------------------------------------------------------*
form vbap_bearbeiten.

  perform vbap_gewicht_volumen_setzen(sapfv45p).

  data: da_new_line_item.
  if svbap-tabix = 0.
    da_new_line_item = charx.
  else.
    da_new_line_item = space.
  endif.

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    perform msr_check_item using gv_msr_error space.
    clear gv_msr_error.
  endif.

  perform vbap_bearbeiten(sapfv45p).

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    clear gv_msr_error.
  endif.

  if da_new_line_item = charx.
    if call_activity eq gc_activity_lord.
      if svbap-tabix > 0.
        append svbap.
      endif.
    endif.
    item_detail_tabix = svbap-tabix.
  endif.

endform.                    "vbap_bearbeiten


*&---------------------------------------------------------------------*
*&      Form  vbep-wmeng_pruefen_a
*&---------------------------------------------------------------------*
form vbep-wmeng_pruefen_a.

  data: da_vara value chara.
  perform vbep-wmeng_pruefen_handler(sapfv45e) changing da_vara.

endform.                    " vbep-wmeng_pruefen_a


*&---------------------------------------------------------------------*
*&      Form  vbep-wmeng_pruefen_m
*&---------------------------------------------------------------------*
form vbep-wmeng_pruefen_m.

  data: da_varm value charm.
  perform vbep-wmeng_pruefen_handler(sapfv45e) changing da_varm.

endform.                    " vbep-wmeng_pruefen_m


*&---------------------------------------------------------------------*
*&      Form  vbap_bearbeiten_ende
*&---------------------------------------------------------------------*
form vbap_bearbeiten_ende.

  if svbap-tabix eq 0 and
     fcode = fcode_xvbap_loeschen.
    fcode = xvbap_loop_fcode.
  endif.

  check: svbap-tabix > 0,
         t180-trtyp ne chara.

  perform vbap_loeschen_setzen(sapfv45p).
  if xvbap_loeschen_bei_anlegen ne space and
    svbap-tabix > 0.
    perform xvbap_loeschen(sapfv45p) using vbap-posnr.
    fcode = xvbap_loop_fcode.
    exit.
  endif.

  check xvbap_loeschen eq space.

  perform vbap_bearbeiten_ende(sapfv45p).

endform.                    " vbap_bearbeiten_ende


*&---------------------------------------------------------------------*
*&      Form  vbap-zieme_pruefen
*&---------------------------------------------------------------------*
form vbap-zieme_pruefen.

  perform vbap-zieme_pruefen(sapfv45p) using charx
                        changing sy-subrc sy-msgid sy-msgty sy-msgno
                                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

endform.                    "vbap-zieme_pruefen


*&---------------------------------------------------------------------*
*&      Form  shipment_vsart_check_mod
*&---------------------------------------------------------------------*
form shipment_vsart_check_mod.

  perform shipment_vsart_check using vbkd-vsart
                                     vbap-route
                                     sy-subrc.

endform.                    "shipment_vsart_check_mod


*&---------------------------------------------------------------------*
*&      Form  vbkd_valdt_pruefen
*&---------------------------------------------------------------------*
form vbkd_valdt_pruefen.

  perform datum_in_vergangenheit_pruefen using vbkd-valdt.

endform.                    "vbkd_valdt_pruefen


*&---------------------------------------------------------------------*
*&      Form  item_delete_by_key
*&---------------------------------------------------------------------*
form item_delete_by_key using uv_posnr.

  data: lv_tabix type sy-tabix.

  perform xvbap_lesen_allgemein in program sapfv45p
                                using uv_posnr space
                                changing svbap-tabix.
  if svbap-tabix = 0.
*   item does not exist
  else.
    perform vbap_bearbeiten_vorbereiten in program sapfv45p.
    perform xvbap_loeschen_gruppe_pruefen in program sapfv45p
                                          using uv_posnr
                                                sy-subrc.
    if sy-subrc = 0.
      perform xvbap_loeschen_gruppe in program sapfv45p
                                    using uv_posnr.
    endif.
  endif.

endform.                    "item_delete_by_key


*&---------------------------------------------------------------------*
*&      Form  item_atp_sapgui
*&---------------------------------------------------------------------*
form item_atp_sapgui using uv_posnr.

  local: tvta,
         call_function.

  clear call_function.
  clear tvta-revfp.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform fcode_pore.

  if atp_gruppenaufruf eq charx.
    perform verfuegbarkeit_pruefen_gruppen(sapfv45p) using verarb_hell.
  endif.

  perform fcode_lgko.

endform.                    "item_atp_sapgui


*&---------------------------------------------------------------------*
*&      Form  item_config_sapgui
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_config_sapgui using uv_posnr
                              uv_fcode.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  perform configuration_fcode_change(sapfv45s).

  call function 'DIALOG_SET_NO_DIALOG'.

  clear uv_fcode.
  if fcode eq 'SICH'.
    uv_fcode = 'SAVE'.
  endif.

endform.                    "item_config_sapgui


*&---------------------------------------------------------------------*
*&      Form  item_atpcheck_by_key
*&---------------------------------------------------------------------*
*      -->UV_POSNR   text
*      -->UV_REVFP   text
*----------------------------------------------------------------------*
form item_atpcheck_by_key using uv_posnr
                                uv_revfp.

  local: tvta.

  case uv_revfp.
    when chara. tvta-revfp = chard.
    when charb. tvta-revfp = space.
    when charc. tvta-revfp = chare.
  endcase.

  perform xvbap_lesen_allgemein in program sapfv45p
                                using uv_posnr space
                                changing svbap-tabix.
  if svbap-tabix = 0.
*   item does not exist
  else.
    perform vbap_bearbeiten_vorbereiten in program sapfv45p.
    perform fcode_pore(sapmv45a).
    perform fcode_lgko(sapmv45a).
  endif.

endform.                    "item_atpcheck_by_key


*&---------------------------------------------------------------------*
*&      Form  item_pricing_by_key
*&---------------------------------------------------------------------*
*      -->UV_POSNR         text
*      -->UV_PRICING_TYPE  text
*----------------------------------------------------------------------*
form item_pricing_by_key using uv_posnr
                               uv_pricing_type.

  data: lv_posnr type posnr.
  data: lv_message type string.

  perform xvbap_lesen_allgemein in program sapfv45p
                                using uv_posnr space
                                changing svbap-tabix.
  if svbap-tabix = 0.
*   item does not exist
  else.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    perform preisfindung(sapfv45p) using uv_pricing_type.
    write vbap-posnr to lv_posnr no-zero.
    message i022(sls_lord) with lv_posnr into lv_message.
    message_collect_lord.
    perform vbap_bearbeiten(sapfv45p).
    perform vbap_bearbeiten_ende(sapfv45p).
  endif.

endform.                    "item_pricing_by_key


*&---------------------------------------------------------------------*
*&      Form  item_bustrans_by_key
*&---------------------------------------------------------------------*
*      -->UV_POSNR   text
*      -->UV_VRGNG   text
*----------------------------------------------------------------------*
form item_bustrans_by_key using uv_posnr
                                uv_vrgng.

  data:
    lt_msg_tab    type tsmesg,

    ls_msg        type balmi,

    lv_vrgng      type j_vorgang,
    lv_msg        type string,
    lv_msg_active type boole_d,
    lf_change     type c.

  lv_vrgng  = uv_vrgng.

  perform xvbap_lesen_allgemein in program sapfv45p
                                using uv_posnr space
                                changing svbap-tabix.
  if svbap-tabix = 0.
*   item does not exist
  else.
    perform vbap_bearbeiten_vorbereiten in program sapfv45p.

*   Prepare status msg log
    call function 'SD_MESSAGES_PREPARE'
      importing
        ev_msg_active = lv_msg_active
        et_msg_tab    = lt_msg_tab.

    call function 'SD_ITEM_CHANGE_STATUS'
      exporting
        i_vrgng          = lv_vrgng
        i_vbap           = vbap
        i_vbak           = vbak
      tables
        fxvbfa           = xvbfa
        fxvbapf          = xvbapf
        fxvbup           = xvbup
        fxvbep           = xvbep
      exceptions
        no_status_object = 1
        missing_data     = 2
        not_allowed      = 3
        others           = 4.
    if sy-subrc <> 0.
      message id sy-msgid type charw number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into lv_msg.
      message_collect_lord.
    endif.

    call function 'STATUS_GET_CHANGE_FLAG'
      importing
        flg_change = lf_change.
    if lf_change ne space.
      r185d-dataloss = charx.
    endif.

*   Reset current state of status msg log
    call function 'SD_MESSAGES_RESTORE'
      exporting
        iv_msg_active = lv_msg_active
        it_msg_tab    = lt_msg_tab.

  endif.

endform.                    "item_bustrans_by_key

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_objstat
*&---------------------------------------------------------------------*
*       Adapted copy of form STATUS_MAINTAIN_VBAP
*       (FV45PFST_STATUS_MAINTAIN_VBAP)
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_objstat using uv_posnr.

  data: da_display.
  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

  if not vbap-objnr is initial.
    if t180-trtyp = chara.
      da_display = charx.
    endif.

    call function 'STATUS_MAINTAIN'
      exporting
        display_only = da_display
        objnr        = vbap-objnr.

*   Flag has to be set in any case, as FM does not return info
    r185d-dataloss = charx.
  else.
  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_objstat

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_output
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_PDOK (MV45AF0F_FCODE_PDOK)
*----------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung auf
*       Positionsebene aus LORD-Klasse
*
*       call dialog module of output processing on item level from
*       LORD class
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_output using uv_posnr.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

* Wenn das Flag sitzt, muß Sicherheitsabfrage durchgeführt werden
* if flag is set, safety check has to be carried out
  if sy-datar ne space.
    r185d-dataloss = sy-datar.
  endif.

  data: l_cua_text(80) type c,        " local CUA-Text
        ls_t185f       type t185f.
***********************
  data: bildtext like dv70a-btext.
  data: da_updat.
  data: ls_tvap like tvap.
  data: ls_vbap like vbap.
  data: da_posnr like vbap-posnr.

  da_posnr = vbap-posnr.                          " save vbap-posnr
* Objektkey aufbauen
* build up  object key
  move  vbak-vbeln to xobjky_pos.
  write vbap-posnr to xobjky_pos+10.
* Bildtext für Dialogbaustein aufbauen
* build up screen text
  bildtext    = rv45a-txt_vbeln.
  bildtext+21 = vbak-vbeln.
  write text-063 to bildtext+40(20).
  write vbap-posnr to bildtext+61(06).
* buid up local CUA text
  write vbak-vbeln to l_cua_text.
  concatenate tvakt-bezei l_cua_text
            into l_cua_text separated by space.
* Nachrichtenfindung durchführen
* carry out output determination
  if t185f-trtyp ne 'A'.
* Kommunikationsblock Kopf neu aufbauen
* build up new header communication block
    read table xvbkd index 1.
    na_vbkd = xvbkd.
    ls_vbap = vbap.
    ls_tvap = tvap.
    perform xvbuk_uebersicht_vorbereiten(sapfv45k).
    call function 'COMMUNICATION_AREA_KOMKBV1'
      exporting
        msg_vbak  = vbak
        msg_vbkd  = na_vbkd
        msg_vbuk  = vbuk
        msg_trtyp = t180-trtyp
      tables
        tab_vbpa  = xvbpa
        tab_vbap  = xvbap
        tab_part  = part.
* Kommunikationsblock Position aufbauen
* build up item communication block
    vbap = ls_vbap.
    tvap = ls_tvap.
    perform xvbup_lesen(sapfv45p) using vbak-vbeln vbap-posnr.
    perform xvbkd_lesen(sapfv45k) using vbap-posnr.
    vbup = xvbup.
    call function 'COMMUNICATION_AREA_KOMPBV1'
         exporting
              msg_vbap = vbap
              msg_vbkd = vbkd
              msg_vbup = vbup
* EHS environment
              msg_vbak = vbak
         tables
              tab_vbpa = xvbpa
              tab_part = part.
    if t185f-trtyp = charv.
      loop at xvbap where posnr = da_posnr.  " looking for correct xvbap
        exit.
      endloop.
      if xvbap-updkz = charu.
* Kommunikationsblock alt aufbauen
* build up old header communication block
        perform yvbap_lesen(sapfv45p) using da_posnr sy-tabix.
        vbap = yvbap.
        perform yvbkd_lesen(sapfv45k) using vbap-posnr sy-tabix ' '.
        if sy-subrc = 0.
          vbkd = yvbkd.
        else.
          vbkd-posnr = 0.
          perform yvbkd_lesen(sapfv45k) using vbkd-posnr sy-tabix ' '.
          if sy-subrc = 0.
            vbkd = yvbkd.
          else.
            read table xvbkd index 1.
            vbkd = xvbkd.
          endif.
        endif.
        yvbup-mandt = vbak-mandt.
        yvbup-vbeln = vbak-vbeln.
        yvbup-posnr = vbap-posnr.
        read table yvbup.
        if sy-subrc = 0.
          vbup = yvbup.
        endif.
      endif.
    endif.
    call function 'COMMUNICATION_AREA_KOMPBV1'
      exporting
        msg_old  = 'X'
        msg_vbap = vbap
        msg_vbkd = vbkd
        msg_vbup = vbup
      tables
        tab_vbpa = xvbpa
        tab_part = part.
* Nachrichtenfindung durchführen
* carry out output determination
    call function 'MESSAGING'
      exporting
        applikation = tvak-kappl
        msg_objky   = xobjky_pos
        schema      = tvap-kalsm
        pi_item     = charx
      tables
        msg_part    = part.
  endif.

* build up small T185F
  ls_t185f-fcode = 'ENT1'.
  if t180-trtyp = chara.
    ls_t185f-trtyp = 'A'.
  else.
    ls_t185f-trtyp = 'V'.
  endif.

* Dialogbaustein zur Nachrichtenbearbeitung aufrufen.
* call dialog module of output determination
*  T185F = H185F.
*  T185  = H185.
*  T185V = H185V.
  call function 'RV_MESSAGES_MAINTENANCE'
    exporting
*     min_t185     = t185
      min_t185f    = ls_t185f
*     min_t185v    = t185v
      min_objky    = xobjky_pos
      min_kappl    = tvak-kappl
      min_kalsm    = tvap-kalsm
      min_btext    = bildtext
      min_cua_text = l_cua_text
      pi_objtype   = businessobjekt_pos
    importing
      mex_fcode    = fcode
*     mex_t185f    = t185f
*     mex_t185v    = t185v
      mex_updat    = da_updat
    tables
      mtb_part     = part.
  if da_updat ne space.
    r185d-dataloss = charx.
  endif.
*  H185F = T185F.
*  H185V = T185V.
***********************

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_output

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_preview
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_LIST_CURRENT_I
*       (MV45AF0F_FCODE_LIST_CURRENT_I)
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_preview using uv_posnr.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

* Wenn das Flag sitzt, muß Sicherheitsabfrage durchgeführt werden
* if flag is set, safety check has to be carried out
  if sy-datar ne space.
    r185d-dataloss = sy-datar.
  endif.

***********************
  data: da_xnast like vnast occurs 0 with header line,
        da_ynast like nast occurs 0 with header line,
        da_xvbfa like vbfa occurs 0 with header line,
        da_preview_processed(1) type c.

* Objektkey aufbauen
  move  vbak-vbeln to xobjky_pos.
  write vbap-posnr to xobjky_pos+10.
* Nachrichtenfindung durchführen
  if t185f-trtyp ne 'A' or
     xvbak_updkz eq updkz_new.
* Kommunikationsblock Kopf neu aufbauen
    read table xvbkd index 1.
    na_vbkd = xvbkd.
    perform xvbuk_uebersicht_vorbereiten(sapfv45k).
    call function 'COMMUNICATION_AREA_KOMKBV1'
      exporting
        msg_vbak  = vbak
        msg_vbkd  = na_vbkd
        msg_vbuk  = vbuk
        msg_trtyp = t180-trtyp
      tables
        tab_vbpa  = xvbpa
        tab_vbap  = xvbap
        tab_part  = part.
* Kommunikationsblock Position aufbauen
    perform xvbup_lesen(sapfv45p) using vbak-vbeln vbap-posnr.
    vbup = xvbup.
    call function 'COMMUNICATION_AREA_KOMPBV1'
         exporting
              msg_vbap = vbap
              msg_vbkd = vbkd
              msg_vbup = vbup
* EHS environment
              msg_vbak = vbak
         tables
              tab_vbpa = xvbpa
              tab_part = part.
    if t185f-trtyp = charv.
      if xvbap-updkz = charu.
* Kommunikationsblock alt aufbauen
        perform yvbap_lesen(sapfv45p) using vbap-posnr sy-tabix.
        vbap = yvbap.
        perform yvbkd_lesen(sapfv45k) using vbap-posnr sy-tabix ' '.
        if sy-subrc = 0.
          vbkd = yvbkd.
        else.
          vbkd-posnr = 0.
          perform yvbkd_lesen(sapfv45k) using vbkd-posnr sy-tabix ' '.
          if sy-subrc = 0.
            vbkd = yvbkd.
          else.
            read table xvbkd index 1.
            vbkd = xvbkd.
          endif.
        endif.
        yvbup-mandt = vbak-mandt.
        yvbup-vbeln = vbak-vbeln.
        yvbup-posnr = vbap-posnr.
        read table yvbup.
        if sy-subrc = 0.
          vbup = yvbup.
        endif.
      endif.
    endif.
    call function 'COMMUNICATION_AREA_KOMPBV1'
      exporting
        msg_old  = 'X'
        msg_vbap = vbap
        msg_vbkd = vbkd
        msg_vbup = vbup
      tables
        tab_vbpa = xvbpa
        tab_part = part.
* Nachrichtenfindung durchführen
    call function 'MESSAGING'
      exporting
        applikation = tvak-kappl
        msg_objky   = xobjky_pos
        schema      = tvap-kalsm
        pi_item     = charx
      tables
        msg_part    = part.
  endif.

  call function 'RV_MESSAGES_GET'
    exporting
      msg_kappl      = tvak-kappl
      msg_objky_from = xobjky_pos
    tables
      tab_xnast      = da_xnast
      tab_ynast      = da_ynast.

* prüfen, ob überhaupt relevante Nachrichten zur Druckanzeige da sind
  loop at da_xnast where nacha eq char1 or
                         nacha eq char2.
    exit.
  endloop.
  if sy-subrc eq 0.
* XVBFA in Struktur VBFA an SD_PUSH_ITEM übergeben
    loop at xvbfa.
      move-corresponding xvbfa to da_xvbfa.
      append da_xvbfa.
    endloop.
* aktuelle Daten an FUGR V45I übergeben
    call function 'SD_PUSH_ITEM'
      exporting
        i_vbak  = vbak
      tables
        i_xvbap = xvbap
        i_xvbep = xvbep
        i_xvbfa = da_xvbfa
        i_xvbkd = xvbkd
        i_xvbpa = xvbpa
        i_xvbup = xvbup.

    call function 'RV_PRICE_PRINT_GET_BUFFER'
      exporting
        i_init              = space
        i_vbeln             = vbak-vbeln
        i_print_from_buffer = space
      tables
        t_komv              = xkomv.

* Ausgabe aufrufen
    call function 'RV_MESSAGE_DIALOG'
      exporting
        pi_kappl              = tvak-kappl
        pi_objky              = xobjky_pos
        pi_kschl              = tvak-kschl
        pi_data_from_buffer   = charx
        pi_quick_preview      = space
        pi_quick_preview_opt  = charx
        pi_faxoutput          = charx
      importing
        preview_processed     = da_preview_processed
      exceptions
        cancel                = 1
        no_message            = 2
        message_not_printable = 2
        print_error           = 3
        others                = 4.

    case sy-subrc.
      when 0.
        if da_preview_processed eq charx.
          message s103.
        endif.
      when 1.
      when 2.
        message s102.
      when 3.
        message s104.
      when others.
        message s104.
    endcase.
  else.
    message s102.
  endif.

***********************

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_preview


*&---------------------------------------------------------------------*
*&      Form  item_sapgui_badet
*&---------------------------------------------------------------------*
*       Adapted call of form FCODE_CHFD (FV45SF0F_FCODE_CHFD)
*----------------------------------------------------------------------*
*       Aufruf der Chargenfindung auf Positionsebene
*
*       Call batch dertermination of item leval
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_badet using uv_posnr.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

  perform fcode_chfd(sapfv45s).
*  if t180-trtyp = chara.
*    perform fcode_chaz(sapfv45s).
*  else.
*    perform fcode_chfd(sapfv45s).
*  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_badet

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_badis
*&---------------------------------------------------------------------*
*       Ergebnisaufruf der Chargenfindung auf Positionsebene
*
*       Call result of batch dertermination of item leval
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_badis using uv_posnr.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

  perform fcode_chaz(sapfv45s).
*  if t180-trtyp = chara.
*    perform fcode_chaz(sapfv45s).
*  else.
*    perform fcode_chfd(sapfv45s).
*  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_badis

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_batch
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*      -->UV_VRGNG   text
*----------------------------------------------------------------------*
form item_sapgui_batch using uv_posnr
                             uv_vrgng.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbap_lesen_direkt(sapfv45p) using uv_posnr
                                             svbap-tabix.
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

  if uv_vrgng = 'DISPLAY'.
    perform fcode_chaz(sapfv45s).
  else.
    perform fcode_chfd(sapfv45s).
  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_batch

*&---------------------------------------------------------------------*
*&      Form  item_sapgui_techobj
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_POTO (MV45AF0F_FCODE_POTO)
*----------------------------------------------------------------------*
*       Pflege der Serialnummern auf Positionsebene
*
*       maintain serial numbers on item leval
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*----------------------------------------------------------------------*
form item_sapgui_techobj using uv_posnr.

  data: xanzsn       like risa0-anzahl,
        da_xanzsn    like risa0-anzahl,
        xtrtyp       like t180-trtyp,
        da_vrgng     like tj01-vrgng,
        da_j_vorgang like tj01-vrgng,
        da_cuobj     like vbap-cuobj,
        da_stdpd     like maepv-stdpd,
        da_dataloss  like r185d-dataloss,
        da_material_only,
        da_vbeln     like vbap-vbeln.
  data: begin of xser02 occurs 5.
          include structure rserxx.
  data: end of xser02.
  data: da_riwol  like riwol  occurs 1 with header line.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  if call_dialog = charx.
    message id 'V2' type 'I' number '156'.
    exit.
  endif.

* Basismenge auf Dezimalen prüfen
* check decimals of basic quantity
  xanzsn = vbap-kwmeng mod 1000.
  if xanzsn <> 0.
    message i535.
    clear xanzsn.
    exit.
  endif.

  perform serial_tobj_entscheid(sapfv45p)
    using    vbap tvap
    changing sy-subrc.
  if sy-subrc eq 0.
    da_vrgng = vrgng_sdau.             " Auftrag
    da_j_vorgang = vrgng_pms2.
  else.
    da_vrgng = vrgng_sdw1.             " Kontrakt
    da_j_vorgang = vrgng_pms4.
  endif.

  if da_vrgng = vrgng_sdau and
     vbak-vbtyp na vbtyp_auft and
     tvap-eterl = space.
*   Anlegen Serialnummern nur für 'Auftragsartige' erlaubt
*   creating of serial numbers is only allowed for sales oder likes
    message s285.
    exit.
  endif.

* Serialnummern koennen nur bei vorhandenem Werk angelegt werden
* plant is needed for the creation of serial numbers
  if vbap-werks is initial and
     da_vrgng <> vrgng_sdw1.
    message i191.
    exit.
  endif.

  if vbap-serail is initial and
     da_vrgng <> vrgng_sdw1.
*   Zum ausgewaehlten Material gibt es kein Serialnummernprofil
*   there isn't any serial number profile for the material
    message i192 with vbap-matnr vbap-werks.
    exit.
  endif.

* Serialnummer darf nicht bei Vertragspositionen übergeben werden
* no serial number for agreement item
  if da_vrgng = vrgng_sdw1.
    da_cuobj = space.
  else.
*   Kofigurationsnummer übergeben
*   hand over configuration number
    da_cuobj = xvbap-cuobj.

*   ... und Standardproduktnummer lesen und übergeben
*   ... read and hand over standard product number
    perform maepv_select(sapfv45p) using vbap-matnr
                                         vbap-werks
                                         vbap-berid
                                         vbap-lgort
                                         charx
                                         space
                                         sy-subrc.

    da_stdpd = maepv-stdpd.
  endif.

* Menge fuer die Anzahl der Serialnummern bestimmen
* determine quantity of needed serial numbers
  xanzsn = vbap-kwmeng * vbap-umvkz / vbap-umvkn / 1000.

  xtrtyp = t180-trtyp.
* Referenzstatus pruefen
* check reference status
  if vbup-wbsta = charc.
    xtrtyp = chara.
  endif.

* Workareas initialisieren
* initialize workareas
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

* Material lesen, um zu prüfen, ob konfigurierbares Material vorliegt
* read material and verify if it is configurable
  perform maapv_select(sapfv45p) using xvbap-matnr
                                       vbak-vkorg
                                       vbak-vtweg
                                       charx
                                       sy-subrc.

* Konfigurationskennzeichen, Bewertungsart und Charge
* machen nur bei auftragsartigen Belegen Sinn
* configuration flag, valuation type and batch
* makes onls sense for sales order like documents
  if da_vrgng = vrgng_sdau.

    select single * from t134 where mtart = maapv-mtart.
    if t134-kzkfg = charx and
       xvbap-cuobj is initial.
      message i529.
    endif.

* wenn STDPD nicht sitzt muss das Feld aus Matnr gefuellt werden
* if STDPD initial take it from MATNR
    if da_stdpd is initial and
       not ( da_cuobj is initial ).
      da_stdpd = xvbap-matnr.
    endif.

* Serialnummer und Bewertungstyp prüfen
* check serial number and valuation type
    if not vbap-xchar is initial.
      if vbap-charg is initial and
            vbap-bwtar is initial.
        message i626.
        exit.
      endif.
    endif.

* Serialnummer und Charge pruefen
* check serial number and batch
    if maepv-xchpf <> space and
       vbap-charg is initial.
      message i608.
      exit.
    endif.
  endif.

* Kundennummer des Warenempfängers ermitteln
* get KUNNR of ship-to
  perform xvbpa_lesen(sapfv45k) using 'WE'
                                      xvbap-posnr
                                      xvbpa_aktind.

* Falls Anzahl Serialnummern > Menge, Zahl der Serialnummern übergeben
* in case the number of serial numbers > quantity, hand over the number
  if xvbap-anzsn > xanzsn.
    da_xanzsn = xvbap-anzsn.
  else.
    da_xanzsn = xanzsn.
  endif.

* Falls noch keine Belegnummer vergeben wurde, immer mit '$' arbeiten
* if there is no doc number jet, take '$'
  if xvbap-vbeln is initial.
    if da_vrgng = vrgng_sdau.
      da_vbeln = char$.
    else.
      clear da_vbeln.
    endif.
  else.
    da_vbeln = xvbap-vbeln.
  endif.

  if da_vrgng eq vrgng_sdau.
    call function 'SERIALPROFILE_CHECK'
      exporting
        operation     = da_vrgng
        activity      = xtrtyp
        document      = da_vbeln
        item          = xvbap-posnr
        kmatnr        = da_stdpd
        material      = xvbap-matnr
        profile       = xvbap-serail
        quantity      = da_xanzsn
        j_vorgang     = da_j_vorgang
        debitor       = xvbpa-kunnr
        cuobj         = da_cuobj
        m_charge      = vbap-charg
        vbtyp         = vbak-vbtyp
        sd_auart      = vbak-auart
        sd_postyp     = xvbap-pstyv
      importing
        anzsn         = vbap-anzsn
        serial_commit = da_dataloss.

    if not da_dataloss is initial.
*   If serial number was changed save info to sernr_chg.
      sernr_chg-vbeln      = vbap-vbeln.
      sernr_chg-posnr      = vbap-posnr.
      sernr_chg-anzsn_old  = *vbap-anzsn.
      sernr_chg-anzsn_new  = vbap-anzsn.
      sernr_chg-nr_changed = charx.
      append sernr_chg.
      serial_dataloss = da_dataloss.
    endif.
  else.
    if vbap-vkgru eq vkgru_rep_reparaturanfo or
       vbap-vkgru eq vkgru_rep_reparatur.
*     nur Objekte mit Materialbezug (keine technischen Plätze)
*     only for object with reference to material (no functional location)
      da_material_only = charx.
    endif.
    call function 'IWOL_WV_LIST'
      exporting
        i_sdaufnr       = da_vbeln
        i_sdposnr       = xvbap-posnr
        i_aktyp         = xtrtyp
        i_kunde         = xvbpa-kunnr
        i_vbtyp         = vbak-vbtyp
        i_sd_auart      = vbak-auart
        i_postyp        = xvbap-pstyv
        i_only_material = da_material_only
      importing
        e_change        = da_dataloss
      tables
        t_ser02         = xser02
        t_riwol         = da_riwol
      exceptions
        no_object_list  = 1.
    clear vbap-anzsn.
    if sy-subrc eq 0.
      if ( vbap-vkgru eq vkgru_rep_reparaturanfo and
           tvak-vbklt eq charg )                 or
         vbap-vkgru eq vkgru_rep_reparatur.
        vbap-anzsn = vbapd-menge_g.
        do.
          read table da_riwol index sy-index.
          if sy-subrc ne 0. exit. endif.
          if da_riwol-dbknz ne chard.
            vbapd-matnr_g = da_riwol-matnr.
            exit.
          endif.
        enddo.
        vbap_pruefen   = charx.
      else.
        loop at xser02 where sdaufnr = da_vbeln and
                             posnr   = xvbap-posnr.
          add xser02-anzsn to vbap-anzsn.
        endloop.
      endif.
    endif.
  endif.

  if r185d-dataloss is initial.
    r185d-dataloss = da_dataloss.
  endif.

  perform vbap_bearbeiten(sapfv45p).
  perform vbap_pruefen_ende(sapfv45p).
  perform vbap_bearbeiten_ende(sapfv45p).


* anything changed , then make a DEQUEUE
  if not da_dataloss is initial.
    gesperrt = charx.
  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "item_sapgui_techobj


*&---------------------------------------------------------------------*
*&      Form  komv_pruefen
*&---------------------------------------------------------------------*
form komv_pruefen.

  read table ivbap with key posnr = vbap-posnr
                   binary search transporting no fields.
  check sy-subrc eq 0.

  perform komv_pruefen(sapfv45p) using charx
                                 changing sy-subrc.

endform.                    "komv_pruefen

*&---------------------------------------------------------------------*
*&      Form  vbap_kalsm_zschl_pruefen
*&---------------------------------------------------------------------*
form vbap_kalsm_zschl_pruefen.

  data:
    lv_subrc type subrc.

  perform vbap-kalsm_zschl_pruefen
          in program sapfv45p
          using charx
                lv_subrc.

endform.                    "vbap_kalsm_zschl_pruefen

*&---------------------------------------------------------------------*
*&      Form  VBAP_CHECK_EAN11 (as of 6.03)
*&---------------------------------------------------------------------*
form vbap_check_ean11.

  data:
    lt_mean  type mean_tab,
    lt_mean2 type mean_tab,

    ls_mean  type mean,

    lv_lines type i.

* Treat EAN/UPC in combination with material and unit

  if rv45a-mabnr is initial and
     vbap-vrkme  is initial and
     vbap-ean11  is initial.
*   No current data to be enriched or checked
    return.
  endif.

  if gv_rv45a_mabnr_gefuellt is initial     and
     vbap-vrkme              eq *vbap-vrkme and
     vbap-ean11              eq *vbap-ean11.
*   No current data change to be enriched or checked
    return.
  endif.

  if vbap-ean11 is initial.
*   EAN is initial: Check whether it has been initialized despite
*   unchanged combination of material and unit
    if not *vbap-ean11             is initial     and
           gv_rv45a_mabnr_gefuellt is initial     and
           vbap-vrkme              eq *vbap-vrkme.
      message i085(sls_lord) with vbap-ean11 rv45a-mabnr vbap-vrkme.
      vbap-ean11 = *vbap-ean11.
      return.
    endif.
  else.
*   EAN is populated: Get data for given EAN/UPV
    call function 'SD_GET_MAT_UOM_FOR_EAN'
      exporting
        is_vbak  = vbak
        iv_actvt = gc_activity_lord
        iv_ean   = vbap-ean11
      importing
        et_mean  = lt_mean.
    if lines( lt_mean ) eq 0.
*     No hit for given EAN
      message e080(sls_lord) with vbap-ean11.
      return.
    endif.

    if rv45a-mabnr is initial or
       vbap-vrkme  is initial.
*     The EAN - if possible - determines material and/or unit
      if not rv45a-mabnr is initial.
*       Reduce set of hits if material is given
        delete lt_mean where matnr ne rv45a-mabnr.
      endif.
      if not vbap-vrkme is initial.
*       Reduce set of hits if unit is given
        delete lt_mean where meinh ne vbap-vrkme.
      endif.
      lv_lines = lines( lt_mean ).
      if lv_lines ge 2.
*       Multi hits for given EAN. Check whether all hits point to the
*       same of material
        lt_mean2 = lt_mean.
        sort lt_mean2 by matnr.
        delete adjacent duplicates from lt_mean2 comparing matnr.
        if lines( lt_mean2 ) ge 2.
*         EAN is not unique with respect to MATNR
          message e081(sls_lord) with vbap-ean11.
          return.
        else.
*         All hits point to the same MATNR: search for main EAN
          delete lt_mean where hpean is initial.
          if lt_mean          is initial or
             lines( lt_mean ) ge 2.
*           No or several main EAN do exist for the given MATNR
            message e082(sls_lord) with vbap-ean11 rv45a-mabnr.
            return.
          endif.
        endif.
      elseif lv_lines eq 0.
*       After potential reduction, no EAN hit remains
        if not rv45a-mabnr is initial.
*         EAN and given material do not match
          message e086(sls_lord) with vbap-ean11 rv45a-mabnr.
          return.
        endif.
        if not vbap-vrkme is initial.
*         EAN and given unit do not match
          message e087(sls_lord) with vbap-ean11 vbap-vrkme.
          return.
        endif.
      endif.
*     Now, we have detected one file that deals as source of material and unit
      read table lt_mean
           into ls_mean
           index 1.
      if not sy-subrc      is initial or
             ls_mean-matnr is initial or
             ls_mean-meinh is initial.
*       MEAN file is odd
        message e083(sls_lord) with vbap-ean11.
        return.
      else.
*       Set MATNR and VRKME for EAN
        gv_rv45a_mabnr_gefuellt = charx.
        rv45a-mabnr             = ls_mean-matnr.
        vbap-vrkme              = ls_mean-meinh.
        return.
      endif.
    elseif gv_rv45a_mabnr_gefuellt eq charx       or
           vbap-vrkme              ne *vbap-vrkme or
           vbap-ean11              ne *vbap-ean11.
*     Material and/or unit and/or EAN did change: Check EAN against new data
      read table lt_mean
           transporting no fields
           with key matnr = rv45a-mabnr
                    meinh = vbap-vrkme.
      if not sy-subrc is initial.
*       EAN/UPC does not fit to the new combination of material and unit
        if vbap-ean11 eq *vbap-ean11.
*         EAN was not change: Delete it for new re-determination on demand
          clear vbap-ean11.
          return.
        else.
*         EAN was changed, too: Process error
          message e084(sls_lord) with vbap-ean11 rv45a-mabnr vbap-vrkme.
          return.
        endif.
      endif.
    endif.
  endif.

endform.                    "vbap_check_ean11


*&---------------------------------------------------------------------*
*&      Form  check_item_copy_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->US_TVCPA   text
*      -->US_XVBAP   text
*      -->US_XVBUP   text
*      -->UV_SUBRC   text
*----------------------------------------------------------------------*
form check_item_copy using us_tvcpa type tvcpa
                           us_xvbap type vbapvb
                           us_xvbup type vbupvb
                           uv_subrc type sy-subrc.

  local: tvcpa.

  data: ls_vbap type vbap,
        ls_vbup type vbup,
        ls_vbrp type vbrp.

  uv_subrc = 0.

  tvcpa = us_tvcpa.
  check: tvcpa-auarn ne space.
  perform tvcpa_select(sapmv45a) using tvcpa-auarn
                                       tvcpa-auarv
                                       space
                                       us_xvbap-pstyv
                                       space
                                       space
                                       sy-subrc.
  check sy-subrc = 0.

  if tvcpa-grbed > 0.
    ls_vbap = us_xvbap.
    ls_vbup = us_xvbup.
    call function 'RV_DOCUMENT_COPY_ITEM_CHECK'
      exporting
        fvcpa          = tvcpa
        fvbap          = ls_vbap
        fvbrp          = ls_vbrp
        fvbup          = ls_vbup
      exceptions
        nicht_kopieren = 1.
    if sy-subrc ne 0.
      uv_subrc = 2.
    endif.
  endif.

endform.                    "check_item_copy_single


*&---------------------------------------------------------------------*
*&      Form  item_create_with_ref
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form item_create_with_ref.

  data: lv_vbeln_ref type vbeln,
        lt_posnr_ref type tdt_posnr,
        ls_posnr_swap type tds_posnr_swap,
        lt_posnr_swap type tdt_posnr_swap.

  check: mat_auf_hinweis_geprueft is initial.

  if gv_vbtyp_ref_ext eq vbtyp_opportunity.
    gv_vbeln_ref_ext = gv_message_vbeln_ref.
    clear gv_message_vbeln_ref.
    gv_posnr_ref_ext = gv_message_posnr_ref.
    clear gv_message_posnr_ref.
  else.
    return.
    lv_vbeln_ref = gv_message_vbeln_ref.
    append gv_message_posnr_ref to lt_posnr_ref.

    clear gv_message_vbeln_ref.
    clear gv_message_posnr_ref.

    if cl_lord=>gv_v45a is initial.
      call function 'SLS_LORD_COPY_DOC'
        exporting
          iv_vbeln_ref  = lv_vbeln_ref
          it_posnr_ref  = lt_posnr_ref
        importing
          et_posnr_swap = lt_posnr_swap
        exceptions
          error_message = 1.
    else.
      call function 'SLS_LORD_COPY_DOC_V45A'
        exporting
          iv_vbeln_ref  = lv_vbeln_ref
          it_posnr_ref  = lt_posnr_ref
        importing
          et_posnr_swap = lt_posnr_swap
        exceptions
          error_message = 1.
    endif.
    if sy-subrc <> 0.
      perform beleg_entsperren using lv_vbeln_ref.
*      ls_message-msgid = sy-msgid.
*      ls_message-msgty = 'E'.
*      ls_message-msgno = sy-msgno.
*      ls_message-msgv1 = sy-msgv1.
*      ls_message-msgv2 = sy-msgv2.
*      ls_message-msgv3 = sy-msgv3.
*      ls_message-msgv4 = sy-msgv4.
*      cl_lord_object=>collect_message( ls_message ).
    else.
      read table lt_posnr_swap into ls_posnr_swap index 1.
      perform xvbap_lesen_direkt(sapfv45p) using ls_posnr_swap-posnr_new
                                                 svbap-tabix.
      perform vbap_bearbeiten_vorbereiten(sapfv45p).
      perform xvbep_lesen_erste(sapfv45e) using space.
      perform vbep_bearbeiten_vorbereiten(sapfv45e).
    endif.
  endif.

endform.                    "item_create_with_ref

*&---------------------------------------------------------------------*
*&      Form  vbap-iuid_pruefen
*&---------------------------------------------------------------------*
form vbap-iuid_pruefen.

  perform vbap_iuid_pruefen(sapfv45p) using vbap-matnr
                                            vbap-werks
                                            vbap-iuid_relevant
                                   changing sy-subrc.

endform.                    "vbap-iuid_pruefen


*&---------------------------------------------------------------------*
*&      Form  set_msr_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_msr_error.

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    gv_msr_error = charx.
    r185d-dataloss = charx.
  endif.

endform.                    "set_msr_error


*&---------------------------------------------------------------------*
*&      Form  lord_atp_check_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_atp_check_group.

  perform verfuegbarkeit_pruefen_gruppen(sapfv45p) using verarb_dunkel.

endform.                    "lord_atp_check_group

*&---------------------------------------------------------------------*
*&      Form  lord_set_vbap_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_POSNR   text
*      -->UV_FIELD   text
*      -->UV_VALUE   text
*----------------------------------------------------------------------*
form lord_set_vbap_field using    uv_posnr
                                  uv_field
                                  uv_value
                         changing cv_error.

  field-symbols: <lv_field> type any.
  clear: cv_error.

  assign component uv_field of structure vbap to <lv_field>.
  if sy-subrc <> 0.
    cv_error = abap_true.
    return.
  endif.

  perform xvbap_lesen_allgemein in program sapfv45p
                                using uv_posnr space
                                changing svbap-tabix.
  if svbap-tabix = 0.
*   item does not exist
    cv_error = abap_true.
    return.
  else.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    <lv_field> = uv_value.
    perform vbap_bearbeiten(sapfv45p).
    perform vbap_bearbeiten_ende(sapfv45p).
  endif.

endform.                    "lord_set_vbap_field
*&---------------------------------------------------------------------*
*&      Form  vbap_pstyv_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbap_pstyv_pruefen.

  data: lv_pstyv type pstyv.

  lv_pstyv = vbap-pstyv.

  perform vbap-pstyv_pruefen(sapfv45p).

  if vbap-pstyv ne lv_pstyv.
    gv_pstyv_determ = vbap-pstyv.
  endif.

endform.                    "vbap_pstyv_pruefen