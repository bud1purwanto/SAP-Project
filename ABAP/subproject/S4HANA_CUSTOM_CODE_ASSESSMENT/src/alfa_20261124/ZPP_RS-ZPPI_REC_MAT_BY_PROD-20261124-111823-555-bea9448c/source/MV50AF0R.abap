***********************************************************************
*                                                                      *
*  Unterroutinen RV-Versand alphabetisch sortiert:                     *
*  -----------------------------------------------                     *
*  Buchstabe R:                                                        *
*                                                                      *
************************************************************************

*----------------------------------------------------------------------*
* SQL-Returncode zuruecksetzen bei erfolgreichem Zugriff               *
*----------------------------------------------------------------------*
form returncode_setzen.

  sqlrc = 0.

endform.                    "returncode_setzen
*eject

form return_from_chsp.

  data: r_fcode like fcode value 'UALL'.

* Mengenkorrelation durchführen, wenn die
* - Liefermenge aller Split-Positionen größer ist als die Liefermenge
*   der Hauptposition und
* - die Chargenhauptposition gleichtzeitig Hauptposition einer
*   Liefergruppe ist.
  data: da_menge_uebersicht like lips-kcmeng.
  data: da_menge_splitbild  like lips-kcmeng.
  data: da_tabix like sy-tabix.

  perform transform_fcode changing r_fcode.

  if not clips-kzfme ca kzfme_ws.
    da_menge_uebersicht = save_clips-kcmeng_flo + save_clips-lgmng_flo.
    da_menge_splitbild  =      clips-kcmeng_flo +      clips-lgmng_flo.
  else.
    da_menge_uebersicht = save_clips-kcmengvmef + save_clips-lfimg_flo."
    da_menge_splitbild  =      clips-kcmengvmef + clips-lfimg_flo. "#&rm
  endif.

  if ( da_menge_splitbild >  da_menge_uebersicht and
       clips-uepos        is initial             and
       not clips-grkor    is initial             ).
    perform xlips_lesen_direkt(sapfv50p) using clips-posnr da_tabix.
    perform korr_mengen_aendern(sapmv50a) using clips-posnr.
  endif.


*   Positionierung des rufenden Bildes züruckholen
  ilips_tabix_aktuell = ilips_tabix_aktuell_calldynpro.
  ilips_tabix_zeile_1 = ilips_tabix_zeile_1_calldynpro.
  ilips_tabix_zeile_1_set = charx.

  perform xlips_umfang_setzen(sapfv50p) using r_fcode.
  perform ilips_aufbauen_alle(sapfv50p).
  v50agl-chargensplitbild = ' '.

  refresh cua_exclude.
  cua_exclude[] = save_cua_exclude[].
  refresh save_cua_exclude.

endform.                    "return_from_chsp
*&---------------------------------------------------------------------*
*&      Form  RV_TEXT_COPY_SIMUL
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form rv_text_copy_simul.
  data: lt_xthead like xthead occurs 0 with header line.

  lt_xthead[] = xthead[]. "die xthead wird auch im simul mode refreshed
  call function 'RV_TEXT_COPY'
    exporting
      ftvcom     = tvcom
      no_popup   = yes
      fpappl     = protocolcaller-sdl
      simul_mode = yes
    tables
      fxthead    = lt_xthead
      fxvbpa     = xvbpa
      fxvbuv     = xvbuv.

  call function 'SD_MONITOR_PROTOCOL_GET'
    exporting
      fpappl   = protocolcaller-sdl
      fprottyp = protocoltype-text
    tables
      fprot    = xprot
    exceptions
      others   = 1.

* call protocol display; the protocol decides on it´s own if it is
* really in display mode or in SD-monitor-call-mode
  call function 'SD_TEXT_PROTOCOL_DISPLAY'
    exporting
      ftvcom = tvcom
    tables
      fprot  = xprot
    exceptions
      others = 1.
endform.                               " RV_TEXT_COPY_SIMUL

*&---------------------------------------------------------------------*
*&      Form  REFERENCE_OUTB_PROCESS
*&---------------------------------------------------------------------*
form reference_outb_process.

  data: lf_changed like r185d-dataloss.

  call function 'SHP_LIPSRF_MAINTAIN_PROC'
    changing
      cf_changed = lf_changed.

  if lf_changed ne space.
    r185d-dataloss = lf_changed.
  endif.

endform.                               " REFERENCE_OUTB_PROCESS

*&---------------------------------------------------------------------*
*&      Form  REFERENCE_INB_PROCESS
*&---------------------------------------------------------------------*
form reference_inb_process.

  data: lf_changed like r185d-dataloss.

  call function 'SHP_LIPSPO_MAINTAIN_PROC'
    changing
      cf_changed = lf_changed.

  if lf_changed ne space.
    r185d-dataloss = lf_changed.
  endif.

endform.                               " REFERENCE_INB_PROCESS
*eject

*&---------------------------------------------------------------------*
*&      Form  RESCHEDULE_EXECUTE
*&---------------------------------------------------------------------*
*       If rescheduling is planned during delivery processing, it is
*       performed directly
*----------------------------------------------------------------------*
form reschedule_execute.

  data: lf_subrc like sy-subrc,
        ls_save_vbeln like lips-vbeln,
        ls_save_posnr like lips-posnr,
        ls_xlips_work like xlips,
        ls_save_ilips like ilips,
        ls_save_slips like slips.

  check tvlk-neute ca gc_auto_rescheduling.
  check not neuterminierung[] is initial.

  read table neuterminierung with key vbeln = likp-vbeln.
  check sy-subrc eq 0.

  delete neuterminierung index sy-tabix.

  check not neuterminierung-neute is initial .

  ls_save_vbeln = lips-vbeln.
  ls_save_posnr = lips-posnr.
  ls_save_ilips = ilips.
  ls_save_slips = slips.

  perform likp_bearbeiten_vorbereiten(sapfv50k).

  perform likp_termine_bestimmen_neu(sapfv50k)
                     using charx
                           charx       "I_VERSANDTERMINE
                           likp        "LIKP Input
                           likp        "LIKP Output
                           xlikp-vstrm
                           xlikp-trtrm
                           lf_subrc.   "Returncode

  if *likp ne likp.
    message i469.
  endif.

  perform likp_bearbeiten(sapfv50k).

* Restore current work areas
  loop at xlips where vbeln eq ls_save_vbeln
                  and posnr eq ls_save_posnr
                  and updkz ne updkz_delete.
    exit.
  endloop.

  move-corresponding xlips to lips.
  move-corresponding xlips to lipsd.

  ilips = ls_save_ilips.
  slips = ls_save_slips.

endform.                               " RESCHEDULE_EXECUTE
*&---------------------------------------------------------------------*
*&      Form  reason_code_check
*&---------------------------------------------------------------------*
form reason_code_check using    value(if_grund) like lips-grund
                                value(if_bwart) like lips-bwart
                                value(if_error) type c
                       changing cf_subrc        like sy-subrc.

  data: ls_t157d like t157d.

  check not if_grund is initial.
  check not if_bwart is initial.

  select single * from t157d
                  into ls_t157d
                  where bwart eq if_bwart
                    and grund eq if_grund.
  if sy-subrc ne 0.
    if if_error eq space.
      cf_subrc = sy-subrc.
    else.
      message e457 with if_grund if_bwart.
    endif.
  endif.

endform.                               " reason_code_check
*&---------------------------------------------------------------------*
*&      Form  read_delivery_from_archive (n_574894)
*&---------------------------------------------------------------------*
form read_delivery_from_archive
     using    value(if_vbeln)     like likp-vbeln
              value(if_erdat)     like likp-erdat
     changing cf_subrc            like sy-subrc.

  data: ls_borident   type borident,
        lf_msgtxt     type c,
        lf_subrc      like sy-subrc,
        lt_likp       type standard table of likp,
        lt_lips       type standard table of lips,
        lt_lipsrf     type standard table of lipsrf,        "v_n_840264
        ls_lipsrf     type lipsrf,
        ls_xlips_ref  type leshp_delivery_refdata,
        ls_lipsrf_key type v50b_lipsrf_key_s,
        lt_lipsrf_key type v50b_lipsrf_key_t,               "^_n_840264
        lt_vbpa       type standard table of vbpa,
        lt_vbfa       type standard table of vbfa,
        lt_vbuk       type standard table of vbuk,
        lt_vbup       type standard table of vbup,
        lt_vbuv       type standard table of vbuv,
        lt_vbpa3      type standard table of vbpa3,
        lt_konv       type standard table of konv,
        lt_sadr       type standard table of sadr,
        lt_eikp       type standard table of eikp,
        lt_eipo       type standard table of eipo,
        lt_xeikp      type standard table of eikpvb,
        lt_xeipo      type standard table of eipovb,
        lt_addr1_val  type standard table of addr1_val,
        lt_cd_docflow type standard table of /spe/cd_docflow,
        ls_addr1_val  type addr1_val,
        ls_addr1_data type addr1_data,
        ls_cd_docflow type /spe/cd_docflow,
        ls_vbpa3      type vbpa3,
        ls_vbuk       type vbuk,
        ls_vbup       type vbup,
        ls_vbuv       type vbuv,
        ls_konv       type konv,
        ls_sadr       type sadr,
        ls_tpar       type tpar,
        ls_eikp       type eikp,
        ls_eipo       type eipo,
        ls_xeikp      type eikpvb,
        ls_xeipo      type eipovb,
        lt_tpar       type sorted table of tpar with unique key parvw,
        lf_parvw      type parvw_4,
        lf_adrnr      type adrnr,
        lf_objectkey  type swo_typeid,
        lf_vbeln_txt(10)  type c,
        lf_address_handle like szad_field-handle.

  field-symbols: <ls_vbpa>  type vbpa,
                 <ls_lips>  type lips,
                 <ls_vbfa>  type vbfa,
                 <ls_xvbpa> type vbpavb.

* No access to archive without document number
  if if_vbeln is initial.
    message e045(v1) into lf_msgtxt.
    cf_subrc = 8.
    exit.
  endif.

  write if_vbeln to lf_vbeln_txt no-zero.
  condense lf_vbeln_txt.


*...Pre-read to detect if more that one delivery exits in the archive
PERFORM pre_read_delivery_from_archive
            USING
                if_vbeln
                if_erdat
            CHANGING
               ls_borident
               cf_subrc.

*...Error occurred, exit processing
if cf_subrc = 8.
  exit.
endif.


* Read delivery from archive
if  ls_borident-objkey is initial.
 ls_borident-objkey = if_vbeln.
endif.

  call function 'ASH_RV_LIKP_READ'
    exporting
      i_borident             = ls_borident
    tables
      et_likp                = lt_likp
      et_lips                = lt_lips
      et_lipsrf              = lt_lipsrf                    "n_840264
      et_vbfa                = lt_vbfa
      et_vbpa                = lt_vbpa
      et_vbuk                = lt_vbuk
      et_vbup                = lt_vbup
      et_vbpa3               = lt_vbpa3
      et_vbuv                = lt_vbuv
      et_konv                = lt_konv
      et_sadr                = lt_sadr
      et_eikp                = lt_eikp
      et_eipo                = lt_eipo
      et_addr1_val           = lt_addr1_val
      et_cd_docflow          = lt_cd_docflow
    exceptions
      not_in_infostructure   = 1
      not_in_archive         = 2
      no_instructure_defined = 3
      others                 = 4.
  if sy-subrc ne 0.
    if sy-msgid eq 'VB'.
      message e559 with lf_vbeln_txt
                   into lf_msgtxt.
      cf_subrc = 8.
      exit.
    else.
*     Enable that ADK messages appear on the screen
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
  endif.

* Nothing found?
  if lt_likp[] is initial.
    message e559 with lf_vbeln_txt into lf_msgtxt.
    cf_subrc = 8.
    exit.
  endif.

* Reload was successful
  cf_subrc = 0.
  v50agl-display_from_archive = charx.

* Switch to display mode in any case
  if t180-trtyp ne chara.
*   Dataloss flag not necessary in display mode.
    clear r185d-dataloss.
*   Set new internal transaction code
    if t180-tcode = 'VL32N'.
      t180-tcode = 'VL33N'.
    elseif t180-tcode = 'VL02N'.
      t180-tcode = 'VL03N'.
    endif.
    call function 'DEQUEUE_ALL'.
*   Initialization for the 'new' Transaction code
    select single * from t180 where tcode = t180-tcode.
    if sy-subrc ne 0.
      message e015 with t180-tcode into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
*   Set second parameter for the title
    rv50a-txt_titcua = text-005.
    refresh cua_exclude.
    perform exclude_function_trtyp.
  endif.

  sort lt_vbpa  by mandt vbeln posnr parvw.
  sort lt_vbpa3 by mandt vbeln posnr parvw.

* Now fill common part structures...
  read table lt_likp into likp index 1.
  read table lt_cd_docflow into ls_cd_docflow index 1.
  if sy-subrc eq 0.
    likpd-spe_cd_process = ls_cd_docflow-cd_process.
  endif.
   *likp  = likp.
   *likpd = likpd.
  slikp-tabix = 1.
  move-corresponding likp  to xlikp.
  move-corresponding likpd to xlikp.
  move-corresponding likp  to ylikp.
  move-corresponding likpd to ylikp.
  xlikp_updkz = updkz_old.

* Check authorization
  if likp-vbtyp na vbtyp_mmli.
    perform berechtigung_pruefen using '03' lf_subrc.
    if lf_subrc ne 0.
      perform lieferung_entsperren using likp-vbeln.
      message e087 with likp-vstel into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
  endif.

* Read delivery type
  perform tvlk_select using likp-lfart
                            space
                            lf_subrc.
  if lf_subrc ne 0.
    message e309 with likp-lfart into lf_msgtxt.
    cf_subrc = 8.
    exit.
  endif.

* Check for valid combination of transaction and delivery type
  if likp-vbtyp ca vbtyp_liav and t180-trvog ne chard or
     likp-vbtyp ca vbtyp_grwe and t180-trvog ne charg or
     likp-vbtyp ca vbtyp_lief and t180-trvog ne char6.
    message e143 into lf_msgtxt.
    cf_subrc = 8.
    exit.
  endif.

* Read shipping point
  if not likp-vstel is initial.
    perform tvst_select using likp-vstel
                              space
                              lf_subrc.
    if lf_subrc ne 0.
      message e100 with likp-vstel into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
  endif.

* Process partner table
  loop at lt_vbpa assigning <ls_vbpa>.

    call function 'SD_VBPA_RECORD_COMPLETE'
      changing
        frs_vbpa = <ls_vbpa>.

    clear xvbpa.
    move-corresponding <ls_vbpa> to xvbpa.

*   Add partner type
    read table lt_tpar into ls_tpar
                       with table key parvw = xvbpa-parvw.
    if sy-subrc ne 0.
      select single * from tpar
                      into ls_tpar
                      where parvw eq xvbpa-parvw.
      if sy-subrc eq 0.
        insert ls_tpar into table lt_tpar.
      else.
        clear ls_tpar.
      endif.
    endif.
    xvbpa-nrart = ls_tpar-nrart.
    xvbpa-fehgr = ls_tpar-fehgr.

*   Tax numbers for CPD customers
    read table lt_vbpa3 into ls_vbpa3
                        with key vbeln = xvbpa-vbeln
                                 posnr = xvbpa-posnr
                                 parvw = xvbpa-parvw
                        binary search.
    if sy-subrc eq 0.
      xvbpa-stcd1 = ls_vbpa3-stcd1.
      xvbpa-stcd2 = ls_vbpa3-stcd2.
      xvbpa-stcd3 = ls_vbpa3-stcd3.
      xvbpa-stcd4 = ls_vbpa3-stcd4.
      xvbpa-stkzn = ls_vbpa3-stkzn.
      xvbpa-stcdt = ls_vbpa3-stcdt.
      xvbpa-j_1kfrepre = ls_vbpa3-j_1kfrepre.
      xvbpa-j_1kftbus  = ls_vbpa3-j_1kftbus.
      xvbpa-j_1kftind  = ls_vbpa3-j_1kftind.
    endif.

    append xvbpa.

  endloop.

  loop at lt_sadr into ls_sadr.                             "v_n_645989
    call function 'ADDR_CONVERT_SADR_TO_ADDR1_VAL'
      exporting
        sadr      = ls_sadr
      importing
        addr1_val = ls_addr1_val.
    append ls_addr1_val to lt_addr1_val.
  endloop.                                                  "^_n_645989

* Push manual addresses to CAM memory
  sort lt_addr1_val by addrnumber.
  loop at xvbpa assigning <ls_xvbpa>
                where not adrnr is initial.
*   Check for manual addresses from archive
    read table lt_addr1_val into ls_addr1_val
                            with key addrnumber = <ls_xvbpa>-adrnr
                            binary search.
    check sy-subrc eq 0.

    lf_parvw = <ls_xvbpa>-parvw.
    call function 'SD_ADDRESS_HANDLE_GET'
      exporting
        fif_parvw           = lf_parvw
        fif_posnr           = posnr_low
      importing
        fef_adrnr           = lf_adrnr
      exceptions
        no_handle_available = 1
        others              = 2.

    if sy-subrc ne 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
    lf_address_handle = lf_adrnr.

    clear ls_addr1_data.
    move-corresponding ls_addr1_val to ls_addr1_data.
    call function 'ADDR_INSERT'
      exporting
        address_data        = ls_addr1_data
        address_group       = 'SD01'
        address_handle      = lf_address_handle
        check_empty_address = ' '
        check_address       = 'X'
      exceptions
        address_exists      = 1
        parameter_error     = 2
        internal_error      = 3
        others              = 4.
    if sy-subrc ne 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.

*   Link "new" address to entry in partner table
    <ls_xvbpa>-adrnr = lf_address_handle.
*   Convert adress indicator for deliveries created         "v_n_645989
*   before 4.5A
    case <ls_xvbpa>-adrda.
      when 'B'.
        <ls_xvbpa>-adrda = 'E'.
      when 'C'.
        <ls_xvbpa>-adrda = 'F'.
    endcase.                                                "^_n_645989

*   Internal table XVBADR must be updated as well
    call function 'ADDR_CONVERT_ADDR1_VAL_TO_SADR'
      exporting
        addr1_val = ls_addr1_val
      importing
        sadr      = ls_sadr.

    clear xvbadr.
    move-corresponding ls_sadr to xvbadr.
    xvbadr-adrnr = <ls_xvbpa>-adrnr.
    xvbadr-updkz = updkz_new.
    append xvbadr.

  endloop.
  check cf_subrc eq 0.
  sort xvbadr by adrnr.

* Finally: Move partner data to partner memory
  lf_objectkey = likp-vbeln.
  call function 'SD_PARTNER_DATA_PUT'
    exporting
      fic_objecttype              = 'LIKP'
      fic_objectkey               = lf_objectkey
    tables
      frt_xvbpa                   = xvbpa
      frt_xvbadr                  = xvbadr
    exceptions
      no_object_specified         = 1
      no_object_creation_possible = 2
      others                      = 3.
  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            into lf_msgtxt.
    cf_subrc = 8.
    exit.
  endif.

* Build document flow and cumulated flow
  loop at lt_vbfa assigning <ls_vbfa>.
    clear xvbfa.
    move-corresponding <ls_vbfa> to xvbfa.
    append xvbfa.
  endloop.

  sort xvbfa by vbelv posnv vbeln posnn vbtyp_n.

  call function 'RV_XVBAPF_CREATE'
    exporting
      vbeln   = likp-vbeln
    tables
      fxvbapf = xvbapf
      fxvbfa  = xvbfa.

* Status information
  loop at lt_vbuk into ls_vbuk.
    clear xvbuk.
    move-corresponding ls_vbuk to xvbuk.
    append xvbuk.
  endloop.

  loop at lt_vbup into ls_vbup.
    clear xvbup.
    move-corresponding ls_vbup to xvbup.
    append xvbup.
  endloop.

  sort xvbuk by mandt vbeln.
  sort xvbup by mandt vbeln posnr.

* LIPS reference data (related to CRM sales orders)         "v_n_840264
  loop at lt_lipsrf into ls_lipsrf.
    move-corresponding ls_lipsrf to ls_xlips_ref.
    insert ls_xlips_ref into table xlips_ref.
  endloop.
  if sy-subrc ne 0.
*   Fallback: Get LIPSRF from database if available
    loop at lt_lips transporting no fields
                    where vgbel ne space
                      and vgsys ne space.
      exit.
    endloop.
    if sy-subrc eq 0.
      ls_lipsrf_key-handle_obj = likp-handle.
      append ls_lipsrf_key to lt_lipsrf_key.
      call function 'SHP_LIPSRF_GET_LIST'
        exporting
          it_lipsrf_key = lt_lipsrf_key
        tables
          ct_lipsrf     = lt_lipsrf.
      loop at lt_lipsrf into ls_lipsrf.
        move-corresponding ls_lipsrf to ls_xlips_ref.
        insert ls_xlips_ref into table xlips_ref.
      endloop.
    endif.
  endif.                                                    "^_n_840264
* Process delivery items
  loop at lt_lips assigning <ls_lips>.
    clear xlips.
    move-corresponding <ls_lips> to xlips.
    if sy-tabix eq 1.
      rv50a-vtweg = xlips-vtweg.
      rv50a-spart = xlips-spart.
    endif.
    append xlips.
  endloop.

* For outbound deliveries: Read ship-to party information
  if likp-vbtyp ca 'JT'.
    perform warenempfaenger_bereitstellen.
    if not likp-ablad is initial.
      kuwev-ablad = likp-ablad.
    endif.
  else.
    perform lieferavis_eatab_fuellen.
  endif.

* Fill dynamic part of XLIPS with values
  loop at xlips.
    clear: lips, lipsd.
    move-corresponding xlips to lips.
    perform lips_x_aufbauen using sy-tabix.
  endloop.

* Incompleteness data
  loop at lt_vbuv into ls_vbuv.
    clear xvbuv.
    move-corresponding ls_vbuv to xvbuv.
    append xvbuv.
  endloop.
  sort xvbuv by mandt vbeln posnr etenr parvw tdid tbnam fdnam.

* Conditions
  loop at lt_konv into ls_konv.
    clear tkomv.
    move-corresponding ls_konv to tkomv.
    append tkomv.
  endloop.
  sort tkomv by mandt knumv kposn stunr zaehk.

* Foreign trade data
  loop at lt_eikp into ls_eikp.
    move-corresponding ls_eikp to ls_xeikp.
    append ls_xeikp to lt_xeikp.
  endloop.
  loop at lt_eipo into ls_eipo.
    move-corresponding ls_eipo to ls_xeipo.
    append ls_xeipo to lt_xeipo.
  endloop.
  if not lt_xeikp[] is initial.
    sort lt_xeikp by exnum.
    sort lt_xeipo by exnum expos.
    export xeikp = lt_xeikp to memory id 'EXPORT_KOPF'.
    export xeipo = lt_xeipo to memory id 'EXPORT_POSI'.
    call function 'EXPIMP_TABLES_IMPORT'.
  endif.

* Read sales organisation and distribution area
  if likp-vbtyp na vbtyp_mmli.
    perform tvko_select using likp-vkorg
                              space
                              lf_subrc.
    if lf_subrc ne 0.
      message e313 with likp-vkorg into lf_msgtxt.
      cf_subrc = 8.
      exit.
    endif.
    if not rv50a-vtweg is initial and
       not rv50a-spart is initial.
      perform tvta_select using likp-vkorg
                                rv50a-vtweg
                                rv50a-spart.
    endif.
  endif.

  message s558 display like 'W' with lf_vbeln_txt.

endform.                               " read_delivery_from_archive

*&---------------------------------------------------------------------*
*&      Form  pre_read_delivery_from_archive
*&---------------------------------------------------------------------*
form pre_read_delivery_from_archive using
                                       value(if_vbeln)     type likp-vbeln
                                       value(if_erdat)     type likp-erdat
                                    changing  cs_borident  type borident
                                              cf_subrc     type sy-subrc.


data: fc type slis_fieldcat_alv occurs 0 with header line,
      ls_selection type slis_selfield,
      ls_borident type borident,
      ls_ash_rv_likp type ASH_RV_LIKP_S,
      lt_ash_rv_likp type ASH_RV_LIKP_t,
      lf_vbeln_txt(10)  type c,
       lf_msgtxt     type c.

clear: fc,
       lt_ash_rv_likp,
       ls_ash_rv_likp,
       ls_borident,
       cf_subrc.

*...Set delivery number to be read from archive
ls_borident-OBJKEY = if_vbeln.


*... Single delivery object selected
if not if_erdat is initial.
     concatenate if_vbeln
      'I'
      'EQ'
      if_erdat
      if_erdat
      into cs_borident-objkey.
    exit.
endif.


*...Select all available deliveries from archive
CALL FUNCTION 'RV_ASH_LIKP_PRE_READ'
 EXPORTING
   IS_BORIDENT                  = ls_borident
 IMPORTING
   ET_ASH_RV_LIKP               = lt_ash_rv_likp
 EXCEPTIONS
   NOT_IN_INFOSTRUCTURE         = 1
   NOT_IN_ARCHIVE               = 2
   NO_INSTRUCTURE_DEFINED       = 3
   OTHERS                       = 4.

*...Error: Delivery does not exist in the database or in the archive
IF sy-subrc <> 0.
    write if_vbeln to lf_vbeln_txt no-zero.
    condense lf_vbeln_txt.
    message ID 'VL'
    type       'E'
    number     '559'
    with lf_vbeln_txt into lf_msgtxt.
    cf_subrc = 8.
    exit.
ENDIF.

*...Single or multiple deliveries with the same number read from archive?
read table lt_ash_rv_likp index 2 transporting no fields.
if sy-subrc <> 0.
  cf_subrc = 0.
  cs_borident = ls_borident.
  exit.
endif.


*...Proceed only if more that one delivery exists with the same number
fc-fieldname     = 'VBELN'.
fc-ref_tabname   = 'LIKP'.
fc-ref_fieldname = 'VBELN'.
fc-key           = 'X'.
append fc.

fc-fieldname     = 'ERDAT'.
fc-ref_tabname   = 'LIKP'.
fc-ref_fieldname = 'ERDAT'.
fc-key           = 'X'.
append fc.

*...Send Popup to select a single delivery from the list of deliveries with the same number
 CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
   EXPORTING
    I_TITLE                       = text-088
    I_SELECTION                   = 'X'
*   I_ALLOW_NO_SELECTION          =
    I_ZEBRA                       = 'X'
    I_SCREEN_START_COLUMN         = 8
    I_SCREEN_START_LINE           = 0
    I_SCREEN_END_COLUMN           = 0
    I_SCREEN_END_LINE             = 0
*   I_CHECKBOX_FIELDNAME          = 'XFELD'
*   I_LINEMARK_FIELDNAME          =
    I_SCROLL_TO_SEL_LINE          = 'X'
    I_tabname                     = 'LT_ASH_RV_LIKP'
*   I_STRUCTURE_NAME              =
    IT_FIELDCAT                   = fc[]
*   IT_EXCLUDING                  =
*   I_CALLBACK_PROGRAM            =
*   I_CALLBACK_USER_COMMAND       =
*   IS_PRIVATE                    =
  IMPORTING
    ES_SELFIELD                   = ls_selection
*   E_EXIT                        =
   TABLES
     t_outtab                     = lt_ash_rv_likp
  EXCEPTIONS
    PROGRAM_ERROR                 = 1
    OTHERS                        = 2.

IF sy-subrc <> 0.
   clear: cs_borident.
*...Error: Systemerror: Popup to select a delivery could not be processed without error
   message id     'VB'
           type   'E'
           number '646'
           with   lf_vbeln_txt into lf_msgtxt.
   cf_subrc = 8.
   exit.
else.
   read table lt_ash_rv_likp index ls_selection-tabindex into ls_ash_rv_likp.
   if sy-subrc = 0.
      concatenate ls_ash_rv_likp-vbeln
      'I'
      'EQ'
      ls_ash_rv_likp-erdat
      ls_ash_rv_likp-erdat
      into cs_borident-OBJKEY.
   else.
      clear: cs_borident.
      write if_vbeln to lf_vbeln_txt no-zero.
      condense lf_vbeln_txt.
*...Error: Please select at least a delivery from the list
      message id     'VB'
              type   'E'
              number '645'
              with   lf_vbeln_txt into lf_msgtxt.
      cf_subrc = 8.
      exit.
   endif.
ENDIF.
endform.