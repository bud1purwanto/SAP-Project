*---------------------------------------------------------------------*
*       FORM FCODE_KRPL_40                                            *
*---------------------------------------------------------------------*
*       Übergang zum Kopffakturierungsplan                            *
*---------------------------------------------------------------------*
form fcode_krpl_40 using h185f structure t185f h185  structure t185
                                               h185v structure t185v.
* !!!! A C H T U N G: redundantes Coding im FCODE_KRPL
  local: tvak-fpart.
  data: da_vbap_tabix like svbap-tabix,
        da_tvcaa like tvcaa,
        da_actvt like tact-actvt.
  data: lf_available type flag.

  t185  = h185.
  t185f = h185f.
  t185v = h185v.

* Die folgenden Aufrufe sind nötig für den direkten Aufruf. Sie werden
* normalerweise im PBO ausgeführt. Es wird der Bildgruppenwechsel
* (falls erfolgt) festgestellt, die Reiterleiste aufgebaut, der FCode
* gespeichert, der zu diesem Bild geführt hat und der aktive Reiter
* nach vorne geholt.
  perform cua_setzen.
  perform taxi_initialize_carrierscreen.

* Authority-Check
  case t180-trtyp.
    when charh.                        "Anlegen
      da_actvt = 'C1'.                 "Pflegen
    when charv.                        "Ändern
      da_actvt = 'C1'.                 "Pflegen
    when chara.                        "Anzeigen
      da_actvt = 'C2'.                 "Anzeigen
  endcase.

* This authority check is not necessary in case of encrypted credit
* card numbers
  data: secure_ccard_active type xfeld.

  call function 'CCARDEC_DO_ENVELOPE'
    exporting
      im_ccins  = ' '
    importing
      ex_result = secure_ccard_active.
  if secure_ccard_active is initial.
    call function 'SD_CCARD_SALES_AUTHORITY_CHECK'
      exporting
        i_auart      = vbak-auart
        i_actvt      = da_actvt
      exceptions
        no_authority = 4.
    if sy-subrc ne 0.
      message id sy-msgid type 'I' number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      h185f-fcode = c_taxi_default_head_fcode.
      exit.
    endif.
  endif.

  perform ccard_check_available using lf_available charx.
  if lf_available is initial.
    h185f-fcode = c_taxi_default_head_fcode.
    exit.
  endif.

  data: da_dataloss like r185d-dataloss.
*
  if not tvak-rpart is initial.
*
* Prüfgruppe lesen
    call function 'SD_CCARD_TVCAA_SELECT'
      exporting
        i_tvak    = tvak
      importing
        e_tvcaa   = da_tvcaa
      exceptions
        not_found = 1.
    if sy-subrc ne 0.
      message id sy-msgid type 'I' number sy-msgno with sy-msgv1.
      h185f-fcode = fcode_zurueck.
      exit.
    endif.

* Liefergruppekorrelation berücksichtigen
    credit_check_ccard_simul_mode = charx.    " lgko runs in simul. mode
    perform fcode_lgko.
    credit_check_ccard_simul_mode = space.

* Kondition ermitteln
    perform preisfindung_gesamt using chara.

*   Vorbereitung Aufruf Dialog
    clear fplaa.
    move-corresponding vbak to fplaa.
    move-corresponding vbak to kompax.
    move vbak-waerk         to fplaa-waerk.
    move kurgv-kunnr        to fplaa-kunrg.
    move tvak-ccpgr         to fplaa-ccpga.

* Steuerbetrag ermitteln
    clear fplaa-mwsbk.
    loop at xvbap where kowrr is initial    " in Kopfsummen übernehmen
                    and updkz ne updkz_delete.
      add xvbap-mwsbp to fplaa-mwsbk.       " use field xvbap-mwsbp
    endloop.


* Get the sum of what should be authorized
* Read static info
    perform xvbuk_lesen(sapfv45k) using vbak-vbeln.

*  XVBUK fuellen, wenn die Tabelle XVBUK doch gebraucht wird
*                 und vorher noch nicht gefuellt werden kann.
    if not svbuk_subrc is initial.
      perform xvbuk_uebersicht_vorbereiten(sapfv45k).
    endif.

    read table xfpla
         with key fplnr = vbak-rplnr
         binary search.
    if sy-subrc ne 0.
      clear xfpla.
    endif.


    if t180-trtyp ne chara.                 " if not in display modus
*  Re-run the availibility check
      perform credit_redo_availability.
    endif.
* Get open values - all items, DA_VBAP_TABIX = 0
    perform offene_werte_ermitteln tables open_values
                                   using charx da_vbap_tabix.
* User exit in order to decide which items will be invoiced together
    perform authorization_value_split tables open_values .
* Get open delivery values
    if t180-trtyp ne chara.                 " if not in display modus
      call function 'SD_CCARD_GET_OPEN_DELIVERIES'
        exporting
          i_vbak_vbeln = vbak-vbeln
        tables
          i_s132       = open_values
          fxvbap       = xvbap
          fxvbfa       = xvbfa.
* Get open invoice values
      call function 'SD_CCARD_GET_OPEN_BILLINGS'
        exporting
          i_vbeln = vbak-vbeln
        tables
          i_s132  = open_values
          fxvbuk  = xvbuk
          fxvbfa  = xvbfa.
    endif.
* We have to read payment plan header again, maybe we've lost it
    read table xfpla
         with key fplnr = vbak-rplnr
         binary search.
    if sy-subrc ne 0.
      clear xfpla.
    endif.
* Set Factor - Communication with Credit Management
    call function 'SD_CCARD_SET_FACTOR'
      exporting
        i_source  = '1'          "Sales Order
        i_vbak    = vbak
        i_xfpla   = xfpla
      tables
        t_xfplt   = xfplt
        t_bezs132 = open_values.
* Offene Belegwerte ermitteln
    call function 'SD_CCARD_GET_NEXT_COST'
      exporting
        i_source  = '1'          "Sales Order
        i_vbtyp   = vbak-vbtyp
      importing
        e_bezs132 = open_values
        e_cost    = fplaa-leiwr
      tables
        t_bezs132 = open_values
      exceptions
        no_costs  = 4.
    if sy-subrc = 0.
      fplaa-cmngv = open_values-sptag.
      if fplaa-cmngv is initial.
        fplaa-cmngv = sy-datlo.
      endif.
    else.
      clear fplaa-leiwr.
      clear fplaa-cmngv.
    endif.

*  we get the value again, for case we have lost it.
    move vbak-netwr to kompax-netwr.

    taxi_program                 = t185v-cprog.
    taxi_header_subscreen        = t185v-dybs1.
    taxi_gui_program             = t185v-agidv.
    taxi_gui_status              = t185v-status.
    taxi_gui_title               = t185v-ctitel.
*
    call function 'BILLING_SCHEDULE_DIALOG'
      exporting
        i_t185                   = t185
        i_t185f                  = t185f
        i_t185v                  = t185v
        i_bezei                  = rv02p-title
        i_fplnr                  = vbak-rplnr
        i_waers                  = vbak-waerk
        i_fpart                  = tvak-rpart
*       I_VEDA_KOPF              = VEDAVB
        i_fplaa                  = fplaa
*       I_FKDAT                  = VBKD-FKDAT
        i_upd_fpla               = upd_fpla
        i_upd_fplt               = upd_fplt
        i_kompax                 = kompax
*       I_KFPLAN                 = CHARA
        i_taxi_tabstrip_captions = taxi_tabstrip_captions
        i_taxi_program           = taxi_program
        i_taxi_header_subscreen  = taxi_header_subscreen
        i_taxi_gui_program       = taxi_gui_program
        i_taxi_gui_status        = taxi_gui_status
        i_taxi_gui_title         = taxi_gui_title
      importing
        e_t185                   = t185
        e_t185f                  = t185f
        e_t185v                  = t185v
        e_fplnr                  = vbak-rplnr
        e_dataloss               = da_dataloss
        e_upd_fpla               = upd_fpla
        e_upd_fplt               = upd_fplt
*       E_KOMPAX                 = KOMPAX
      tables
        fpla_new                 = xfpla
        fpla_old                 = yfpla
        fplt_new                 = xfplt
        fplt_old                 = yfplt
      changing
        c_taxi_tabstrip          = taxi_tabstrip_head.

    call function 'TAXI_CONVERT_FCODE'
      exporting
        fcode_in        = t185f-fcode
      importing
        fcode_out       = fcode
      exceptions
        fcode_not_found = 1
        others          = 2.
    move fcode to t185f-fcode.
*
    if da_dataloss ne space and r185d-dataloss eq space.
      r185d-dataloss = da_dataloss.
    endif.

    perform vbak_aendern(sapfv45k).
*   löschen offenen Wert, um einen neuen Aufbau zu ermöglichen
    refresh open_values.
*   automatische Kreditprüfung, wenn sich absicherungsrelevante Felder
*   ändern
    if da_dataloss ne space.
      if ( tvak-klimp     eq chard or
           not tvak-babss is initial  ) and
         vbuk_recheck  is initial and
         call_function is initial.
*     Keine Prüfung auf Kopfebene wenn im VKMx-Recheck oder
*     eine andere Call-Function läuft (dunkel) oder Batch
        perform creditcheck(sapmv45a)
          using    space space
          changing kvbuk.
      endif.
    endif.
  else.
    h185f-fcode = fcode_kaufmann_kopf.
    exit.
  endif.
*
  h185  = t185.
  h185f = t185f.
  h185v = t185v.
  fcode = t185f-fcode.

endform.                    "FCODE_KRPL_40