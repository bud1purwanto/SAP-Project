*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_FCODE_DYNAMIC                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CUA_EXCLUDE_DYNAMIC
*&---------------------------------------------------------------------*
*       Suppress fcodes depending on the document status
*       CUA_EXCLUDE is sorted by FCODE! Use CUA_FCODE_ALLOW to
*       activate or deactivate FCODES
*       If FCODE activation is static during the whole delivery
*       processing use form CUA_EXCLUDE_STATIC (called after reading
*       the current document)
*----------------------------------------------------------------------*
form cua_exclude_dynamic.

  data:
    lf_log type c.                                          "n_704387
  field-symbols:
    <ls_xlips> type lipsvb.                                 "n_1557257

ENHANCEMENT-POINT MV50AF0C_CUA_FCODE_DYNAMIC_02 SPOTS ES_SAPMV50A.

  if     not gs_xlips_chsp is initial.                      "v_n_568918
    read table xvbup with key vbeln = gs_xlips_chsp-vbeln
                              posnr = gs_xlips_chsp-posnr
                     binary search.
  elseif not gs_xlips_main is initial.
    read table xvbup with key vbeln = gs_xlips_main-vbeln
                              posnr = gs_xlips_main-posnr
                     binary search.
  endif.                                                    "^_n_568918

* FCODE KGGP, dangerous goods
  if v50agl-gefahrgut_aktiv = gc_gg_unchecked.
    perform gg_check_active_simple changing v50agl-gefahrgut_aktiv.
  endif.
  if v50agl-gefahrgut_aktiv = gc_gg_aktiv.
    perform cua_fcode_allow using fcode_gefahrgutpruefung yes.
  else.
    perform cua_fcode_allow using fcode_gefahrgutpruefung no.
  endif.

* Dangerous goods: Template processing FCODE DGMD_T
  if not v50agl-tppr_active is initial.
*   Template processing is active: check whether document contains
*   relevant materials
    call function 'EHS003_TPMAT_CHECK'
      exporting
        i_vbtyp        = likp-vbtyp
        i_vbeln        = likp-vbeln
      tables
        i_xlips_tab    = xlips
      exceptions
        tpmat_exist    = 1
        no_tpmat_exist = 2
        wrong_param    = 3
        no_profl_found = 4
        others_        = 5.

    if sy-subrc ne 1.
*     Suppress output of dangerous-goods tab if no relevant materials in
*     the current document
      read table taxi_inactive_fcodes
                 with key fcode = fcode_template_processing
                 binary search
                 transporting no fields.
      if sy-subrc ne 0.
*       Tab is active at the moment but should be hided: Force rebuild
*       of the tabs
        v50agl-force_tab_init = charx.
      endif.
      perform cua_taxitab_allow using fcode_template_processing no.
    else.
      read table taxi_inactive_fcodes
                 with key fcode = fcode_template_processing
                 binary search
                 transporting no fields.
      if sy-subrc eq 0.
*       Tab is inactive at the moment but should be displayed: Force
*       rebuild of the tabs
        v50agl-force_tab_init = charx.
      endif.
      perform cua_taxitab_allow using fcode_template_processing yes.
    endif.
  endif.

* FCODE WABU, Wareneingang bei Lieferavis nur im Änderungsmodus
* und wenn erfolgreich zurückgemeldet.
* FCODE WABU, Wareneingang bei Lieferavis - zentral / dezentral
  if ( t180-trtyp eq charh and likp-vbtyp eq vbtyp_liav )
    or ( likp-verursys is initial and
         likp-vbtyp eq vbtyp_liav and not
         likp-vlstk ca ' C'       and not
         likp-kzwab ca ' I'                               )

    or ( not likp-verursys is initial and
             likp-vbtyp eq vbtyp_liav and not
             likp-vlstk ne chara      and not
             likp-kzwab eq chard                          ).

    perform cua_fcode_allow using 'WABU' no.
  endif.
* SIT: No goods issue posting when creating outbound delivery
  if t180-trtyp eq charh and likp-vbtyp eq vbtyp_lino       "v_n_1557257
  and lines( xlips[] ) > 0
  and cl_ops_switch_check=>mm_sfws_sit( ) is not initial.
    loop at xlips assigning <ls_xlips>
                  where sitkz <> space.
      perform cua_fcode_allow using 'WABU' no.
      exit.
    endloop.
  endif.                                                    "^_n_1557257

  if ( t180-bldgr eq gc_new_dialog_outb
       or t180-bldgr eq gc_new_dialog_inb ).
*   If error list is empty protocol button must not be displayed
    if cvbfs[] is initial.
      get parameter id 'LE_SHP_LOG' field lf_log.           "v_n_704387
      if lf_log is initial.
        perform cua_fcode_allow using 'FEAZ_T' no.
      else.
        perform log_get tables cvbfs
                       using likp-vbeln.
        if cvbfs[] is initial.
          perform cua_fcode_allow using 'FEAZ_T' no.
        else.
          perform cua_fcode_allow using 'FEAZ_T' yes.
        endif.
      endif.                                                "^_n_704387
    else.
      perform cua_fcode_allow using 'FEAZ_T' yes.
    endif.
*   If incompleteness dialog is active suppress recursive call of
*   incompleteness protocol
    if bottom_subscreen eq '622'.
      perform cua_fcode_allow using 'UCSH_T' no.
    else.
      perform cua_fcode_allow using 'UCSH_T' yes.
    endif.
  endif.

* Disable FCODES for batch creation in outbound del.
  if likp-vbtyp eq vbtyp_liav.
    perform cua_fcode_allow using 'CHCR' yes.
    if t180-trtyp = chara.
*      not likp-verursys is initial or                     "del_n_653051
*      xvbup-lvsta = charb          or                    "del_n_1534636
*      xvbup-koqua = charb.                               "del_n_1534636
      perform cua_fcode_allow using 'CHCR' no.
    endif.
  else.
    perform cua_fcode_allow using 'CHCR' no.
  endif.

* Disable certain FCODES on the batch split screen
  if v50agl-chargensplitbild = 'X'.
    if likp-vbtyp = vbtyp_liav or not likp-verursys is initial.
      perform cua_fcode_allow using 'CHFD' no.
      perform cua_fcode_allow using 'CHKO' no.
      perform cua_fcode_allow using 'CHAZ' no.
    elseif xvbup-lvsta = charb or xvbup-koqua = charb.
      perform cua_fcode_allow using 'CHSL' no.
      perform cua_fcode_allow using 'CHFD' no.
      perform cua_fcode_allow using 'CHKO' no.
      perform cua_fcode_allow using 'POLO' no.
    else.
      if t180-trtyp ne chara.
        perform cua_fcode_allow using 'CHSL' yes.
        perform cua_fcode_allow using 'CHFD' yes.
        perform cua_fcode_allow using 'CHKO' yes.
        perform cua_fcode_allow using 'POLO' yes.
      endif.
    endif.
  endif.


* externe Kreditversicherung
  if likp-abssc is initial.
    perform cua_fcode_allow using fcode_wkv no.
  else.
*   Ermitteln, ob Absicherungstyp WKV aktiv
    call function 'SD_ORDER_RISK_CHECK'
      exporting
        i_abstp             = '1'"'1' oder '2'
        i_abssc             = likp-abssc
      exceptions
        security_not_active = 3
        others              = 4.
    if sy-subrc eq 3.
      perform cua_fcode_allow using fcode_wkv no.
    else.
      perform cua_fcode_allow using fcode_wkv yes.
    endif.
  endif.


* Finanzdokumente: Nur auf Dynpro 0300 Absprung moeglich und
*                  Lieferung mit Auftragsbezug vorliegt
* New dialog: these functions are available everywhere
* Change functions are disabled by default in display mode (-> MV50ADIA)
  if t180-bldgr ne gc_new_dialog_outb
     and t180-bldgr ne gc_new_dialog_inb.
    if sy-dynnr eq '0300' and tvlk-aufer eq 'X'.
      perform cua_fcode_allow using 'IFDA' yes.
      if t180-trtyp ne chara.
        perform cua_fcode_allow using 'IFDH' yes.
        perform cua_fcode_allow using 'IFDV' yes.
      endif.
    else.
      perform cua_fcode_allow using 'IFDH' no.
      perform cua_fcode_allow using 'IFDV' no.
      perform cua_fcode_allow using 'IFDA' no.
    endif.
  endif.

* Enable rescheduling only in case that the goods issue is not yet
* posted
  if xvbuk-wbstk eq charc.
    perform cua_fcode_allow using 'NEUT_T' no.
  endif.

* Enable Detail view for POD differences only if delivery item is
* relevant for proof of delivery
* Lines deleted n_550881 / n_568918
  if xvbup-pdsta ca 'ABC'.
    perform cua_fcode_allow using 'LEBA_T' yes.
  else.
    perform cua_fcode_allow using 'LEBA_T' no.
  endif.

* Activate simulation button only if document is relevant for
* distribution or WMS change management is active
  if v50agl-dlv_change eq charx or
     ( likp-vlstk ca 'AD' and likp-verursys eq space ).
    perform cua_fcode_allow using 'SIMU_T' yes.
  else.
    perform cua_fcode_allow using 'SIMU_T' no.
  endif.


* Enable or disable FCODES depending on the screen group
  if t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    perform cua_fcode_scrgroup.
  endif.

* Disable 'Deliver order' for delivery types that are not intended to be
* order related
  if tvlk-aufer ne charx
     and not tvlk-lfart is initial.
    perform cua_fcode_allow using 'RAUF' no.
  endif.

* Deactivation of FCODES concerning the WMS
  if likp-verursys is initial.
    perform cua_fcode_allow using fcode_referenz no.
  else.
    if v50agl-dlv_change eq space.
      perform cua_fcode_allow using 'POAN' no. "Positionen anlegen
      if v50agl-chargensplitbild is initial.                "n_821631
        perform cua_fcode_allow using 'POLO' no. "Positionen löschen
      endif.                                                "n_821631
      perform cua_fcode_allow using 'LOES' no. "Löschen
    endif.
    perform cua_fcode_allow using 'RAUF' no. "Auftrag beliefern
  endif.

* Disable 'Deliver order' in Central System for distributed "v_n_1142763
* deliveries in case change management is active
  if likp-verursys is initial   and
     v50agl-dlv_change eq charx and
     likp-vlstk eq charb.
    perform cua_fcode_allow using 'RAUF' no.
  endif.                                                    "^_n_1142763

* Ausblenden der EH&S-Menüeinträge wenn EH&S nicht installiert
  call function 'EHS002_CHECK_EHS_ACTIVE'
    exceptions
      ehs_not_exist = 1
      others        = 2.
  if sy-subrc <> 0.
    perform cua_fcode_allow using 'PGGP' no.
    perform cua_fcode_allow using 'IEHS' no.
  endif.

  if cl_ops_switch_check=>mm_sfws_ci_3( ) = abap_true.
    if likp-vbtyp eq vbtyp_liav or
       likp-werks ne space.
      loop at xlips transporting no fields
                    where updkz ne updkz_delete
                      and vgtyp eq vbtyp_bestell.
        exit.
      endloop.
      if sy-subrc eq 0.
        perform cua_fcode_allow using 'EDOC_T' yes.
      else.
        perform cua_fcode_allow using 'EDOC_T' no.
      endif.
    else.
      perform cua_fcode_allow using 'EDOC_T' no.
    endif.
  else.
    perform cua_fcode_allow using 'EDOC_T' no.
  endif.

ENHANCEMENT-POINT CUA_EXCLUDE_DYNAMIC_01 SPOTS ES_SAPMV50A.
  perform call_badi_change_fcode_attrib.

ENHANCEMENT-POINT MV50AF0C_CUA_FCODE_DYNAMIC_01 SPOTS ES_SAPMV50A.

  perform cua_exclude_badi.                                 "EhP4

endform.                               " CUA_EXCLUDE_DYNAMIC
*eject