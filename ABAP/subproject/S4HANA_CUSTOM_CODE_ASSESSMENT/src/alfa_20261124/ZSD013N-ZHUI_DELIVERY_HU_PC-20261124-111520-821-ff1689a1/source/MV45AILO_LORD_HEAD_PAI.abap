*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_HEAD_PAI
*&---------------------------------------------------------------------*


form ext_nummer_pruefen.

  perform vbak-vbeln_pruefen(sapfv45k).
  perform vbeln_uebernehmen.

endform.                    "ext_nummer_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbak_partner_aendern
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak_partner_aendern.

  perform vbak_partner_aendern(sapfv45k) using space.

endform.                    " vbak_partner_aendern


*&---------------------------------------------------------------------*
*&      Form  vbak_bearbeiten
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak_bearbeiten.

  if vbakin-vsbed is initial.
    vbakin-vsbed = vbak-vsbed.
  endif.

  perform vbak_bearbeiten(sapfv45k).

  call function 'J_1BSA_COMPONENT_ACTIVE'
    exporting
      bukrs                = t001-bukrs
      component            = 'BR'
    exceptions
      component_not_active = 02.
  if sy-subrc = 0.
    perform j_1b_0303_check(j_1bv45a) using vbak *vbak.
  endif.

endform.                    " vbak_bearbeiten


*&---------------------------------------------------------------------*
*&      Form  vbak-guebg_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak-guebg_pruefen.

  perform einteilung_vor_datum_pruefen(sapfv45e) using vbak-guebg.
  perform datum_in_vergangenheit_pruefen(sapmv45a) using vbak-guebg.

endform.                    " vbak-guebg_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbak-gueen_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak-gueen_pruefen.

  perform einteilung_vor_datum_pruefen(sapfv45e) using vbak-gueen.
  perform datum_in_vergangenheit_pruefen(sapmv45a) using vbak-gueen.

endform.                    " vbak-gueen_pruefen


*&---------------------------------------------------------------------*
*&      Form  gueltig_von_bis_pr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form gueltig_von_bis_pr.

  perform datum_von_bis_pruefen(sapmv45a) using vbak-guebg
                                                vbak-gueen.

endform.                    " gueltig_von_bis_pr


*&---------------------------------------------------------------------*
*&      Form  angebot_von_bis_pr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form angebot_von_bis_pr.

  perform datum_von_bis_pruefen(sapmv45a) using vbak-angdt
                                                vbak-bnddt.

endform.                    " angebot_von_bis_pr


*&---------------------------------------------------------------------*
*&      Form  vbak-waerk_neuermitteln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak-waerk_neuermitteln.

  if fcode = 'WNEU'.
    perform vbak-waerk_ermitteln(sapfv45k).
    perform vbkd-kursk_ermitteln(sapfv45k).
    perform vbkd-stcur_ermitteln(sapfv45k).
  else.
*   Do not transport the currency in case of exp. currency
    if not checked_currency is initial and
           checked_currency ne xvbak-waerk.
      vbak-waerk = xvbak-waerk.
    endif.
  endif.

endform.                    " vbak-waerk_neuermitteln


*&---------------------------------------------------------------------*
*&      Form  rv45a-kedatu_eingabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form rv45a-kedatu_eingabe.

  perform vbak-vdatu_pruefen(sapfv45k) using rv45a-ketdat
                                             rv45a-kprgbz.

endform.                    " rv45a-kedatu_eingabe


*&---------------------------------------------------------------------*
*&      Form  rv45a-dwerk_pruefen_mod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form rv45a-dwerk_pruefen_mod.

  perform rv45a-dwerk_pruefen using rv45a-dwerk
                                    charx
                                    sy-subrc.

  if xvbap_high_posnr > 0 and t180-trtyp eq charh.
    message w107(v1).
  endif.

endform.                    " rv45a-dwerk_pruefen_mod


*&---------------------------------------------------------------------*
*&      Form  rv45a_kedatu_pruefen_fk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form rv45a_kedatu_pruefen_fk.

  data da_subrc_dat_werk like sy-subrc.

  if not vbak-vbklt eq vbklt_ausl_auft and
     not vbak-vbklt eq vbklt_ausl_auft_korr.
    perform datum_pruefen_werk_fk(sapmv45a) using rv45a-dwerk
                                                  vbak-vdatu
                                                  charx
                                                  space
                                         changing da_subrc_dat_werk.
  endif.

endform.                    "rv45a_kedatu_pruefen_fk


*&---------------------------------------------------------------------*
*&      Form  vbak-audat_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak-audat_pruefen.

  perform datum_in_vergangenheit_pruefen(sapmv45a) using vbak-audat.

endform.                    " vbak-audat_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbak-waerk_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak-waerk_pruefen.

  perform vbak-waerk_pruefen(sapfv45k).
  perform vbak_waerk_expiration(sapfv45k).

endform.                    " vbak-waerk_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-kursk_fixiert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd-kursk_fixiert.

  perform vbkd-kursk_fixiert(sapfv45k) using vbkd-kursk.

endform.                    " vbkd-kursk_fixiert


*&---------------------------------------------------------------------*
*&      Form  vbkd-kursk_ermitteln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd-kursk_ermitteln.

  perform vbkd-kursk_ermitteln(sapfv45k).
  perform vbkd-stcur_ermitteln(sapfv45k).
  perform vbkd-wkkur_ermitteln(sapfv45k).

endform.                    " vbkd-kursk_ermitteln


*&---------------------------------------------------------------------*
*&      Form  vbkd-zterm_pruefen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbkd-zterm_pruefen.

  perform vbkd-zterm_pruefen(sapfv45k) using vbkd-zterm
                                             charx
                                             sy-subrc.

endform.                    " vbkd-zterm_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbak_set_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbak_set_data.

  if xvbak-agupda = charx.
    vbak-autlf = xvbak-autlf.
    vbak-vkbur = xvbak-vkbur.
    vbak-vkgrp = xvbak-vkgrp.
    vbak-waerk = xvbak-waerk.
    vbak-vsbed = xvbak-vsbed.
    vbak-kvgr1 = xvbak-kvgr1.
    vbak-kvgr2 = xvbak-kvgr2.
    vbak-kvgr3 = xvbak-kvgr3.
    vbak-kvgr4 = xvbak-kvgr4.
    vbak-kvgr5 = xvbak-kvgr5.
  endif.

  if vkgrp_clear = charx.
    clear vbak-vkgrp.
  endif.

endform.                    "vbak_set_data


*&---------------------------------------------------------------------*
*&      Form  veda_set_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form veda_set_data.

  check not tvak-vterl is initial.

  call function 'SD_VEDA_SET_DATA'
    exporting
      i_tvak  = tvak
    tables
      t_xvbuv = xvbuv
      t_hvbuv = hvbuv.

* Kopfvertragsdaten für späteren Vergleich merken
  perform xveda_lesen(sapfv45p) using *veda_k
                                vbak-vbeln
                                posnr_low
                                t180-trtyp.

endform.                    "veda_set_data


*&---------------------------------------------------------------------*
*&      Form  veda_completeness_h
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form veda_completeness_h.

  check not tvak-vterl is initial.

* Prüfen ob sich Kopfvertragsdaten geändert haben
  perform xveda_lesen(sapfv45p) using veda
                                vbak-vbeln
                                posnr_low
                                t180-trtyp.
  check veda ne *veda_k.

  call function 'SD_VEDA_CREATE'
    exporting
      i_trtyp             = t180-trtyp
      i_profile           = tvak-vprof
      i_vbeln             = vbak-vbeln
      i_vposn             = posnr_low
      i_uepos             = posnr_low
      i_fehgr             = tvak-fehgr
      i_dialog_incomplete = charx
      i_tvak              = tvak
    tables
      t_hvbuv             = hvbuv
      t_xvbuv             = xvbuv.

  perform veda_check_item_completeness.

endform.                    "veda_completeness_h


*&---------------------------------------------------------------------*
*&      Form  vbak_vdatu_on_changed
*&---------------------------------------------------------------------*
form vbak_vdatu_on_changed.

  data: lv_ketdat type ketdat,
        lv_kprgbz type kprgbz.

  vbak-vprgr = char1.

  call function 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    exporting
      internal_date   = vbak-vdatu
      internal_period = vbak-vprgr
    importing
      external_date   = lv_ketdat
      external_period = lv_kprgbz.

  perform vbak-vdatu_pruefen(sapfv45k) using lv_ketdat
                                             lv_kprgbz.

  rv45a-ketdat = lv_ketdat.
  rv45a-kprgbz = lv_kprgbz.

endform.                    "vbak_vdatu_on_changed


*&---------------------------------------------------------------------*
*&      Form  vbkd-bzirk_pruefen
*&---------------------------------------------------------------------*
form vbkd-bzirk_pruefen.

  perform vbkd-bzirk_pruefen(sapfv45k) using vbkd-bzirk
                                             charx
                                             sy-subrc.

endform.                    "vbkd-bzirk_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-vsart_pruefen
*&---------------------------------------------------------------------*
form vbkd-vsart_pruefen.

  perform t173_select using vbkd-vsart
                            charx
                            sy-subrc.

endform.                    "vbkd-vsart_pruefen


*&---------------------------------------------------------------------*
*&      Form  shipment_info_check
*&---------------------------------------------------------------------*
form shipment_info_check.

  call function 'SD_SHIPMENT_MOT_TYPE_CHECK'
    exporting
      i_trmtyp                  = vbkd-trmtyp
    changing
      c_traty                   = vbkd-traty
    exceptions
      mot_type_inconsistent
      transp_type_not_maintained.

  case sy-subrc.
    when 1.
      message id 'VW' type 'E' number '812' with vbkd-trmtyp.
    when 2.
      if vbkd-trmtyp is initial.
        message id 'VW' type 'E' number '813' with vbkd-traty.
      else.
        message id 'VW' type 'E' number '814'
          with vbkd-traty vbkd-trmtyp.
      endif.
  endcase.

endform.                    "shipment_info_check


*&---------------------------------------------------------------------*
*&      Form  tvak_empfi_pruefen
*&---------------------------------------------------------------------*
form tvak_empfi_pruefen.

  perform tvak-empfi_pruefen using tvak-empfi
                                   vbkd-abtnr
                                   vbkd-empst.

endform.                    "tvak_empfi_pruefen


*&---------------------------------------------------------------------*
*&      Form  kuwev_ablad_pruefen
*&---------------------------------------------------------------------*
form kuwev_ablad_pruefen.

  perform kuwev_knfak_setzen using kuwev-ablad
                                   kuwev-kunnr.

  perform kuwev-ablad_pruefen using kuwev-ablad
                                    vbak-vbeln
                                    vbap-posnr.

endform.                    "kuwev_ablad_pruefen


*&---------------------------------------------------------------------*
*&      Form  set_vtber
*&---------------------------------------------------------------------*
form set_vtber.

  if t180-trtyp eq charh.
    gs_vtber_ext-vkorg = vbak-vkorg.
    gs_vtber_ext-vtweg = vbak-vtweg.
    gs_vtber_ext-spart = vbak-spart.
    vbak-vkorg = *vbak-vkorg.
    vbak-vtweg = *vbak-vtweg.
    vbak-spart = *vbak-spart.
  endif.

endform.                    "set_vtber


*&---------------------------------------------------------------------*
*&      Form  zahlungskarten_datumi
*&---------------------------------------------------------------------*
form zahlungskarten_datumi.

* Determine payment card valid-to date
  ccdata-datbi = cl_lord_services=>convert_ccard_datbi( iv_ccins     = ccdata-ccins
                                                        iv_ccins_old = *ccdata-ccins
                                                        iv_datbi     = ccdate-exdatbi ).

endform.                    "zahlungskarten_datumi


*&---------------------------------------------------------------------*
*&      Form  check_paymentcards
*&---------------------------------------------------------------------*
form check_paymentcards.

  r185d-dataloss = charx.
  perform zahlungskarten_pruefen.
  check ccdata-datbi ne *ccdata-datbi.
  perform zahlungskarten_datum_pruefen.

endform.                    "check_paymentcards


*&---------------------------------------------------------------------*
*&      Form  vbkd-kdkg1_pruefen
*&---------------------------------------------------------------------*
form vbkd-kdkg1_pruefen.

  perform vbkd_kdkgx_pruefen(sapfv45k) using '1'.

endform.                    "vbkd-kdkg1_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-kdkg2_pruefen
*&---------------------------------------------------------------------*
form vbkd-kdkg2_pruefen.

  perform vbkd_kdkgx_pruefen(sapfv45k) using '2'.

endform.                    "vbkd-kdkg2_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-kdkg3_pruefen
*&---------------------------------------------------------------------*
form vbkd-kdkg3_pruefen.

  perform vbkd_kdkgx_pruefen(sapfv45k) using '3'.

endform.                    "vbkd-kdkg3_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-kdkg4_pruefen
*&---------------------------------------------------------------------*
form vbkd-kdkg4_pruefen.

  perform vbkd_kdkgx_pruefen(sapfv45k) using '4'.

endform.                    "vbkd-kdkg4_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbkd-kdkg5_pruefen
*&---------------------------------------------------------------------*
form vbkd-kdkg5_pruefen.

  perform vbkd_kdkgx_pruefen(sapfv45k) using '5'.

endform.                    "vbkd-kdkg5_pruefen


*&---------------------------------------------------------------------*
*&      Form  lieferdatum_setzen
*&---------------------------------------------------------------------*
form lieferdatum_setzen.

  perform liefergruppendatum_setzen(sapfv45v) using verarb_immer.

endform.                    "lieferdatum_setzen


*&---------------------------------------------------------------------*
*&      Form  head_pricing
*&---------------------------------------------------------------------*
*      -->IV_PRICING_TYPE  text
*----------------------------------------------------------------------*
form head_pricing using iv_pricing_type.

  data: lv_message type string.

  if iv_pricing_type is initial.
*   Do overall pricing with fallback pricing type
    perform fcode_konb
            in program sapmv45a.
  else.
*   Do overall pricing according to given pricing type
    perform preisfindung_gesamt
            in program sapmv45a
            using iv_pricing_type.
  endif.
* Add message
  message i019(sls_lord) into lv_message.
  message_collect_lord.

endform.                    "head_pricing


**&---------------------------------------------------------------------*
**&      Form  head_sapgui_custcrea
**&---------------------------------------------------------------------*
**       Adapted copy of form FCODE_IAAN (MV45AF0F_FCODE_IAAN)
**----------------------------------------------------------------------*
* Is called from CL_LORD-CALL_SAPGUI_CUSTCREA
form head_sapgui_custcrea using iv_kunnr
                                ev_kunnr.

  constants: da_tcode like sy-tcode value 'VD01'.
  data: da_ktokd like rf02d-ktokd,
        da_authority_subrc like sy-subrc,
        da_kunnr like kuagv-kunnr.
  data: bdcdata type table of bdcdata.
  data: da_opt like ctu_params.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.
***************
  if vbak-kunnr ne iv_kunnr.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = iv_kunnr
      importing
        output = da_kunnr.
  else.
    da_kunnr = iv_kunnr.
  endif.

* Redetermine TVTA in case it was initialized
  if tvta is initial.
    if not vbak-vkorg is initial and
       not vbak-vtweg is initial and
       not vbak-spart is initial.

      perform tvta_select using vbak-vkorg
                                vbak-vtweg
                                vbak-spart.
    endif.
  endif.

* set parameter id 'KUN' field kuagv-kunnr.
  set parameter id 'KUN' field da_kunnr.
  set parameter id 'VKO' field tvta-vkorg.
  set parameter id 'VTW' field tvta-vtwku.
  set parameter id 'SPA' field tvta-spaku.
  get parameter id 'KGD' field da_ktokd.
  if da_ktokd is initial.
    set parameter id 'KGD' field '0001'.
  endif.

* Berechtigung pruefen
* check authority
  perform check_authority_trans using da_tcode
                             changing da_authority_subrc.

  if da_authority_subrc eq 0.
* Transaktionsaufruf nicht über Folgebildsteuerung, da:
* - Rückgabe der Kundennummer nicht möglich
* - Dateneingabe bei Exit-Fcode verloren gehen
* no use of screen sequence control, because
* - retrun of customer ID not possible
* - data lost of EXIT fcode
    da_opt-dismode = 'A'.
    da_opt-updmode = 'S'.
    da_opt-nobinpt = 'X'.
    call transaction da_tcode using bdcdata options from da_opt.

    call function 'KNVV_REFRESH_BUFFER'.

    get parameter id 'KUN' field da_kunnr.
    if not da_kunnr is initial and
       da_kunnr ne 'INTERN'.
      ev_kunnr = da_kunnr.

    endif.
  else.
    message i001(v10) with da_tcode.
  endif.

***************
  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "head_sapgui_custcrea

*&---------------------------------------------------------------------*
*&      Form  head_sapgui_custdis
*&---------------------------------------------------------------------*
*
*       Anzeige Auftraggeber/ Display sold-to party
*----------------------------------------------------------------------*
form head_sapgui_custdis.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  perform xvbpa_lesen(sapfv45k) using 'AG'
                                      posnr_low
                                      sy-tabix.
  perform tvta_select using vbak-vkorg
                            vbak-vtweg
                            vbak-spart.

  set parameter id 'KUN' field xvbpa-kunnr.
  set parameter id 'VKO' field vbak-vkorg.
  set parameter id 'VTW' field tvta-vtwku.
  set parameter id 'SPA' field tvta-spaku.
  set parameter id 'DDY' field '110310'.

  call transaction 'VD03' and skip first screen.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "head_sapgui_custdis


*&---------------------------------------------------------------------*
*&      Form  head_sapgui_custfs
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_KUST
*       (MV45AF0F_FCODE_KUST)
*
*       Übergang zum Kundenstammblatt/ Display sales summary
*----------------------------------------------------------------------*
form head_sapgui_custfs.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

  if not vbak-kunnr is initial.
    submit rvkusta1 and return
      with vkorg = vbak-vkorg
      with vtweg = vbak-vtweg
      with spart = vbak-spart
      with kunnr = vbak-kunnr.
  endif.

  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "head_sapgui_custfs

*&---------------------------------------------------------------------*
*&      Form  head_sapgui_objstat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form head_sapgui_objstat.

  data: da_display.
  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.


  if not vbak-objnr is initial.
    if t180-trtyp = chara.
      da_display = charx.
    endif.

    call function 'STATUS_MAINTAIN'
      exporting
        display_only = da_display
        objnr        = vbak-objnr.

*   Flag has to be set in any case, as FM does not return info
    r185d-dataloss = charx.
  endif.

  call function 'DIALOG_SET_NO_DIALOG'.


endform.                    "head_sapgui_objstat

*&---------------------------------------------------------------------*
*&      Form  head_sapgui_output
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_KDOK (MV45AF0F_FCODE_KDOK)
*----------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung auf
*       Kopfebene aus LORD-Klasse
*
*       call dialog module of output processing on header level from
*       LORD class
*----------------------------------------------------------------------*
form head_sapgui_output.

  data: l_cua_text(80) type c,        " local CUA-Text
        ls_t185f       type t185f.
  data: bildtext like dv70a-btext.
  data: da_updat.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.
* Wenn das Flag sitzt, muß Sicherheitsabfrage durchgeführt werden
* if flag is set, safety check has to be carried out
  if sy-datar ne space.
    r185d-dataloss = sy-datar.
  endif.

***************
* Bildtext für Dialogbaustein aufbauen
* build up screen text
  bildtext    = rv45a-txt_vbeln.
  bildtext+21 = vbak-vbeln.
* buid up local CUA text
  write vbak-vbeln to l_cua_text.
  concatenate tvakt-bezei l_cua_text
            into l_cua_text separated by space.
* Nachrichtenfindung durchführen
* carry out output determination
  data: begin of vbkd_key,
          mandt like vbkd-mandt,
          vbeln like vbkd-vbeln,
          posnr like vbkd-posnr,
        end   of vbkd_key.

  if t185f-trtyp ne 'A'.
    vbkd_key-mandt = sy-mandt.
    vbkd_key-vbeln = vbak-vbeln.
    vbkd_key-posnr = 0.
    read table xvbkd with key vbkd_key.
    na_vbkd = xvbkd.
* Kopfstatus ermitteln
* determine header status
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

    call function 'MESSAGING'
      exporting
        applikation = tvak-kappl
        msg_objky   = xobjky
        schema      = tvak-kalsm
        pi_objtype  = businessobjekt
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
  call function 'RV_MESSAGES_MAINTENANCE'
       exporting
*            min_t185     = t185
            min_t185f    = ls_t185f
*            min_t185v    = t185v
            min_objky    = xobjky
            min_kappl    = tvak-kappl
            min_kalsm    = tvak-kalsm
            min_btext    = bildtext
            min_cua_text = l_cua_text
            pi_objtype   = businessobjekt
       importing
            mex_fcode    = fcode
*            mex_t185f    = t185f
*            mex_t185v    = t185v
            mex_updat    = da_updat
       tables
            mtb_part     = part.
  if da_updat ne space.
    r185d-dataloss = charx.
  endif.

***************
  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "head_sapgui_output

*&---------------------------------------------------------------------*
*&      Form  head_sapgui_preview
*&---------------------------------------------------------------------*
*       Adapted copy of form FCODE_LIST_CURRENT
*       (MV45AF0F_FCODE_LIST_CURRENT_I)
*----------------------------------------------------------------------*
form head_sapgui_preview.

  data: da_xnast like vnast occurs 0 with header line,
        da_ynast like nast occurs 0 with header line,
        da_xvbfa like vbfa occurs 0 with header line,
        da_preview_processed(1) type c.

  local: call_function.

  clear call_function.
  call function 'DIALOG_SET_WITH_DIALOG'.

* Wenn das Flag sitzt, muß Sicherheitsabfrage durchgeführt werden
* if flag is set, safety check has to be carried out
  if sy-datar ne space.
    r185d-dataloss = sy-datar.
  endif.

***************

* Get data of objectkey for output
  move vbak-vbeln to xobjky.

* Nachrichtenfindung durchführen
  data: begin of vbkd_key,
          mandt like vbkd-mandt,
          vbeln like vbkd-vbeln,
          posnr like vbkd-posnr,
        end   of vbkd_key.

  if t185f-trtyp ne 'A' or
     xvbak_updkz eq updkz_new.
    vbkd_key-mandt = sy-mandt.
    vbkd_key-vbeln = vbak-vbeln.
    vbkd_key-posnr = 0.
    read table xvbkd with key vbkd_key.
    na_vbkd = xvbkd.
* Kopfstatus ermitteln
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

    call function 'MESSAGING'
      exporting
        applikation = tvak-kappl
        msg_objky   = xobjky
        schema      = tvak-kalsm
        pi_objtype  = businessobjekt
      tables
        msg_part    = part.
  endif.

  call function 'RV_MESSAGES_GET'
    exporting
      msg_kappl      = tvak-kappl
      msg_objky_from = xobjky
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
        pi_objky              = xobjky
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

  call function 'RV_PRICE_PRINT_GET_BUFFER'
    exporting
      i_init              = charx
      i_print_from_buffer = space.

***************
  call function 'DIALOG_SET_NO_DIALOG'.

endform.                    "head_sapgui_preview