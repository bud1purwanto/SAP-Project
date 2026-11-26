*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_FPLA_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LORD_FPLA_HEAD_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form lord_fpla_head_pbo.

  data: begin of tfpltnp occurs 1.
          include structure fpltnp.
  data: end   of tfpltnp.

  local: tvak-fpart.

  clear vbap.
  perform preisfindung_vorbereiten in program sapfv45p using 'K'.

  perform fplan_summen_ermitteln changing kompax.
  perform xvbkd_lesen_direkt(sapfv45k) using posnr_low
                                             svbkd-tabix.
  perform vbkd_bearbeiten_vorbereiten(sapfv45k).

  if not tvak-vterl is initial.
*     Vertragsdaten vorhanden
    data: da_posnr_low like veda-vposn.
*
    move vbak-vbeln to xveda-vbeln.
    call function 'SD_VEDA_SELECT'
      exporting
        i_document_number = xveda-vbeln
        i_item_number     = da_posnr_low
        i_trtyp           = t180-trtyp
      importing
        e_vedavb          = vedavb.
  endif.

  describe table tfpltnp lines sy-tabix.
  if sy-tabix eq 0.
    move vbak-ps_psp_pnr to tfpltnp-pspel_neu.
    move yvbak-ps_psp_pnr to tfpltnp-pspel_alt.
    if not tfpltnp-pspel_neu is initial or
       not tfpltnp-pspel_alt is initial.
      append tfpltnp.
    endif.
  endif.
*   Aufruf Dialog
*   Fuellen Anwendungsdaten für Subscreen
  clear fplaa.
  move-corresponding vbak to fplaa.
  move vbak-waerk         to fplaa-waerk.
  move tvko-bukrs to fplaa-bukrs.
*   Füllen Kommunikationsstruktur mit Preisfeldern aus VBAK
  perform fplanart_ermitteln_kopf changing tvak-fpart.

  call function 'SD_FPLA_DATA_PUT'
    exporting
      iv_trtyp                = t180-trtyp
      iv_fplnr                = vbkd-fplnr
      iv_waers                = vbak-waerk
      iv_fpart                = tvak-fpart
      iv_fkdat                = vbkd-fkdat
      is_fplaa                = fplaa
      iv_upd_fpla             = upd_fpla
      iv_upd_fplt             = upd_fplt
      is_komk                 = tkomk
      is_kompax               = kompax
      iv_fkrel                = ' '
      is_veda_kopf            = vedavb
      iv_kfplan               = chara
      iv_kfplnr               = ' '
      iv_absagen              = ' '
      iv_berechtigung_block   = berechtigung_block
      iv_berechtigung_unblock = berechtigung_unblock
      it_xfpla                = xfpla[]
      it_yfpla                = yfpla[]
      it_xfplt                = xfplt[]
      it_yfplt                = yfplt[]
      it_svbap                = uvbap[]
      if_called_by_lord       = 'X'
    tables
      i_fpltnp                = tfpltnp[].

endform.                    " LORD_FPLA_HEAD_PBO


*&---------------------------------------------------------------------*
*&      Form  LORD_FPLA_ITEM_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form lord_fpla_item_pbo .
* !!!! A C H T U N G: redundantes Coding im FCODE_PFPL

  local: tvap-fpart.

  data: da_dataloss   like r185d-dataloss,
        da_fplnr      like vbkd-fplnr,
        da_kfplan     like rv60f-kfplan,
        da_kfplnr     like vbkd-fplnr,
        da_absagen(1) type c,
        lv_trtyp      like t180-trtyp,
        da_fpart      like tvap-fpart.


*   GIBT ES EINEN KOPFFAKTURIERUNGSPLAN ?
  perform xvbkd_lesen(sapfv45k) using posnr_low.
  perform fplanart_ermitteln_kopf changing tvak-fpart.
  if xvbkd-posnr eq posnr_low and
     not xvbkd-fplnr is initial.
    move xvbkd-fplnr to da_kfplnr.
  endif.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).
*
* Konditionen eingelesen.
  if t180-trtyp = chara.
    perform konv_select(sapfv45p).
  endif.
*
  perform preisfindung_vorbereiten in program sapfv45p using 'P'.
* Ermitteln, ob Positionsfakturierungsplan auf Kopffakturierungsplan
* zeigt
  perform fplanart_ermitteln changing tvap-fpart.
  perform fplan_pos_kopfrelevant using    vbap-posnr
                                          tvap-fpart tvak-fpart
                                 changing sy-subrc.
  if sy-subrc = 0.
    move charb to da_kfplan.
  endif.

*   Es muß sichergestellt werden, daß bei einem wertmäßigen Kopf-
*   fakturierungsplan, der aktuelle Stand der Positionsfakturierungs-
*   pläne gesichert wird, d.h. es müssen nach Prüfung
*   auch eventuelle Differenzen verteilt werden.

  if da_kfplan eq charb.
    perform fplan_pos_wert_verteilen using space.
  endif.

  perform xvbkd_lesen_direkt(sapfv45k) using vbap-posnr
                                             svbkd-tabix.
  perform vbkd_bearbeiten_vorbereiten(sapfv45k).
*
  if not tvak-vterl is initial.
*   Vertragsdaten vorhanden
    data: da_posnr_low like veda-vposn.
*
    move vbak-vbeln to xveda-vbeln.
    move vbap-posnr to xveda-vposn.
    call function 'SD_VEDA_SELECT'
      exporting
        i_document_number = xveda-vbeln
        i_item_number     = xveda-vposn
        i_trtyp           = t180-trtyp
      importing
        e_vedavb          = xveda.
    call function 'SD_VEDA_SELECT'
      exporting
        i_document_number = xveda-vbeln
        i_item_number     = da_posnr_low
        i_trtyp           = t180-trtyp
      importing
        e_vedavb          = vedavb.
  endif.
*
  da_fpart = tvap-fpart.
  perform t459k_lesen.
  tvap-fpart = da_fpart.

  if t459k-mntga eq mofauf.
    perform t003o_select(sapmv45a) using t459k-auart
                                         charx
                                         sy-subrc.
*   Netzpläne vorhanden
    if t003o-autyp = netz.
*
      data: begin of tfpltnp occurs 1.
              include structure fpltnp.
      data: end   of tfpltnp.
      perform netzplan_ermitteln(sapfv45p)
                                 tables tfpltnp
                                 using  vbak-vbeln
                                        vbap-posnr.
    endif.
  endif.
* entweder Netzplan oder PSP-Element kann zu Meilensteinen führen
  describe table tfpltnp lines sy-tabix.
  if sy-tabix eq 0.
    move vbap-ps_psp_pnr to tfpltnp-pspel_neu.
    loop at yvbap where posnr eq vbap-posnr.
      move yvbap-ps_psp_pnr to tfpltnp-pspel_alt.
    endloop.
    if not tfpltnp-pspel_neu is initial or
       not tfpltnp-pspel_alt is initial.
      append tfpltnp.
    endif.
  endif.
* Bereitstellen der fakturierten Termine
  data: begin of tfplts occurs 10.
          include structure fplts.
  data: end   of tfplts.
  read table xvbfa with key mandt = sy-mandt
                            vbelv = vbak-vbeln
                            posnv = vbap-posnr binary search.
  if sy-subrc eq 0.
    loop at xvbfa from sy-tabix.
      if xvbfa-vbelv ne vbak-vbeln or
         xvbfa-posnv ne vbap-posnr.
        exit.
      endif.
      if xvbfa-fplnr eq vbkd-fplnr.
        move-corresponding xvbfa to tfplts.
        append tfplts.
* Anzahlungen / Fakturierungsplan und aufwandsbezogene Faktura
      elseif not vbkd-ffprf is initial.
        include badi_sd_dpbp_pfpl_40.
      endif.
    endloop.
  endif.

* Aufruf Dialog
* Fuellen Anwendungsdaten für Subscreen
  move-corresponding vbak to fplaa.
  move-corresponding vbap to fplaa.
  move vbak-waerk         to fplaa-waerk.
  move vbap-kwmeng        to fplaa-menge.
  if fplaa-menge is initial.
    move vbap-zmeng       to fplaa-menge.
  endif.
  move vbkd-kurrf to fplaa-kurrf.
  move tvko-bukrs to fplaa-bukrs.
* Füllen Kommunikationsstruktur mit Preisfeldern aus VBAP
  move-corresponding vbap to kompax.


* Fakturierungsplannummer initialisieren, wenn eine Pos-VBKD noch
* nicht existiert, da sonst Änderungsmodus unterstellt wird
  move vbkd-fplnr to da_fplnr.
  if vbkd-posnr eq posnr_low and
     not vbkd-fplnr is initial.
    clear da_fplnr.
  endif.
* WENN EIN ABSAGEGRUND EINGEGEBEN WURDE, DER FAKTURARELEVANT
* IST, DANN MUß DER FAKTURIERUNGSPLAN ANGEPASST WERDEN.
  clear da_absagen.
  if not vbap-abgru is initial.
    perform tvag_select using vbap-abgru
                              tvag-dragr
                              space
                              sy-subrc.
    perform fplan_absagen_ermitteln using    tvag
                                    changing da_absagen.
  endif.
* Wenn es sich um eine Rechnungskorrektur handelt darf der Fakt.Plan
* eventuell nur angezeigt werden.

  move t180-trtyp to lv_trtyp.
  if vbak-vbklt = vbklt_rech_korr.
    if ( vbak-vbtyp = vbtyp_ganf and vbap-shkzg = charx ) or
       ( vbak-vbtyp = vbtyp_lanf and vbap-shkzg = charx ).
      move chara to lv_trtyp.
    endif.
  endif.

  call function 'SD_FPLA_DATA_PUT'
    exporting
      iv_trtyp                = lv_trtyp
      iv_fplnr                = da_fplnr
      iv_waers                = vbak-waerk
      iv_fpart                = tvap-fpart
      is_veda                 = xveda
      iv_fkdat                = vbkd-fkdat
      is_fplaa                = fplaa
      iv_upd_fpla             = upd_fpla
      iv_upd_fplt             = upd_fplt
      is_komk                 = tkomk
      is_komp                 = tkomp
      is_kompax               = kompax
      iv_fkrel                = vbap-fkrel
      is_veda_kopf            = vedavb
      iv_kfplan               = da_kfplan
      iv_kfplnr               = da_kfplnr
      iv_absagen              = da_absagen
      iv_berechtigung_block   = berechtigung_block
      iv_berechtigung_unblock = berechtigung_unblock
      it_xfpla                = xfpla[]
      it_yfpla                = yfpla[]
      it_xfplt                = xfplt[]
      it_yfplt                = yfplt[]
      it_komv                 = xkomv[]
      it_svbap                = uvbap[]
      it_fplts                = tfplts[]
      if_called_by_lord       = 'X'
    tables
      i_fpltnp                = tfpltnp[].

endform.                    " LORD_FPLA_ITEM_PBO


*&---------------------------------------------------------------------*
*&      Form  LORD_FPLA_CHECK_AVAILABLE
*&---------------------------------------------------------------------*

form lord_fpla_check_available using    uv_level          type char1
                                        uv_fpla_available type flag.

  clear uv_fpla_available.
  clear vbap.

  data:
  lv_msg    type string.                                    "#EC NEEDED

  if uv_level eq charh.
*   HEAD
    perform xvbkd_lesen(sapfv45k) using posnr_low.
    perform fplanart_ermitteln_kopf changing tvak-fpart.
    if tvak-fpart is initial.
      message w127(sls_lord) with tvak-auart into lv_msg.
      message_collect_lord.
      return.
    endif.
    perform fplan_summen_ermitteln changing kompax.
    perform xvbkd_lesen(sapfv45k) using posnr_low.
    perform vbkd_bearbeiten_vorbereiten(sapfv45k).
    if t180-trtyp eq chara  and
      vbkd-posnr is initial and vbkd-fplnr is initial.
      message i418(v2) into lv_msg.
      message_collect_lord.
      return.
    endif.
  elseif uv_level eq chari.
*   ITEM
    perform xvbkd_lesen(sapfv45k) using posnr_low.
    perform fplanart_ermitteln_kopf changing tvak-fpart.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    if tvap-fpart is initial .
*   Position nicht gemäß Fakturierungsplan zu fakturieren
      message i263 with vbap-posnr into lv_msg.
      message_collect_lord.
      return.
    endif.
    if not ( vbap-fkrel eq con_fkrel_fplan or
             ( vbap-fkrel is initial and
               not tvap-fpart is initial ) ).
      message i263 with vbap-posnr into lv_msg.
      message_collect_lord.
      return.
    endif.

    if t180-trtyp eq chara and
      ( vbkd-posnr is initial or
      ( vbkd-posnr eq vbap-posnr and vbkd-fplnr is initial ) ).
      message i416(v2) into lv_msg.
      message_collect_lord.
      return.
    endif.

    if not vbap-abgru is initial   and
      ( vbkd-posnr is initial or
      ( vbkd-posnr eq vbap-posnr and vbkd-fplnr is initial ) ).
      message i416(v2) into lv_msg.
      message_collect_lord.
      return.
    endif.
  endif.

  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
    if vbak-sppaym eq cv_sppaym01.
      message i020(sls_paysp).
      message_collect_lord.
      return.
    endif.
  endif.

  uv_fpla_available = abap_true.

endform.                    " LORD_FPLA_CHECK_AVAILABLE