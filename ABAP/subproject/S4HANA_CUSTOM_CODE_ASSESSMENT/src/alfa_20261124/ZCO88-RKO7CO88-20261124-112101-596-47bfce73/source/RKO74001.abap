*eport rko74001.
* CO-Abrechnung ueber Report - abrechn. spezif. Teil


*---------------------------------------------------------------------*
* Data definition
*---------------------------------------------------------------------*
*N740800 Clean up for Selection Screens
include rko74top.


*---------------------------------------------------------------------*
* Selektion-Screen
*---------------------------------------------------------------------*
* controlling area
* parameters: kokrs like auak-kokrs no-display.  (now in framework)
* Parameter
selection-screen begin of block parameter
            with frame title text-101.
parameters: perio    like auak-perio memory id 74p obligatory,
            gjahr    like auak-gjahr memory id gjr obligatory,
            vaart    like lko74-vaart obligatory.
selection-screen comment 50(30) txtvaart for field vaart.
selection-screen end of block parameter.
* Reversal ?
selection-screen begin of block function
            with frame title text-200.
selection-screen begin of line.
parameters: ausf default 'X' radiobutton group fkt.
*selection-screen comment 4(40) text-a01.                       "N740800
selection-screen comment 4(40) text-a01 for field ausf.         "N740800
selection-screen end of line.
selection-screen begin of line.
parameters: stor radiobutton group fkt.
*selection-screen comment 4(40) text-a02.                       "N740800
selection-screen comment 4(40) text-a02 for field stor.         "N740800
selection-screen end of line.
selection-screen end of block function.
* Testrun, list ...?
selection-screen begin of block ablauf
            with frame title text-102.
parameters: testlauf like lko74-testlauf default 'X'.   "Testlauf
include rkrfcgroupinc_params.
parameters: tdcheck  like lko74-tdcheck. "trans.data check
selection-screen end of block ablauf.
* listvariants  ...?
selection-screen begin of block list
            with frame title text-103.
parameters: grndlist like lko74-grnd_liste default 'X' no-display.
parameters: list     like lko74-list.  "Auflisten J/N
selection-screen pushbutton 33(30) pu_list user-command list.
selection-screen end of block list.

* additional parameters
selection-screen begin of block wsdat
            with frame title text-104.
parameters: buperio  like auak-buperio memory id 74b,
            budat    like auak-budat,  "posting date
            bzdat    like auak-bzdat,  "Bezugsdatum
            wsdat    like lko74-wsdat. "Wertstellungsdatum
selection-screen end of block wsdat.

* Pushbutton for technical settings
selection-screen pushbutton 1(30) pu_tech user-command tech.


* technical fields -> no output because on pushbuttons
selection-screen begin of block felder with frame.
parameters: count like lko74-count_com "Anzahl Sender pro COMMIT
                     default '10' no-display.
parameters: errgr    like lko74-aufgr no-display.
parameters: rfc_no like lko74-rfc_no no-display.
parameters: var_cos like lko74-variant_cos no-display,
            var_wip like lko74-variant_wip no-display.
selection-screen end of block felder.

* Events for Parallel processing
include rkrfcgroupinc_events.

*---------------------------------------------------------------------*
* INITIALIZATION   (with registration of events)
*---------------------------------------------------------------------*
initialization.
  perform initialization.


*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
start-of-selection.
  perform start_of_selection.


*---------------------------------------------------------------------*
* VALUE-REQUEST
*---------------------------------------------------------------------*
at selection-screen on value-request for vaart.
  perform value_request_vaart.


*---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*---------------------------------------------------------------------*
at selection-screen on block wsdat.
  perform check_wsdat.

at selection-screen on block parameter.
  perform check_parameter.

at selection-screen on count.
  if not ( count > 0 and count <= 999 ).
    message id 'KD' type 'E' number '601'.
  endif.

at selection-screen on vaart.
  perform check_vaart.

*---------------------------------------------------------------------*
* forms for registered events
*---------------------------------------------------------------------*
form at_selscreen.
  perform pushbottons.
endform.

*---------------------------------------------------------------------*
*       FORM at_selscreen_output                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form at_selscreen_output.
  perform modify_fields.
  perform change_icons.
  perform check_vaart.                                       "HW904079
endform.



*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_VAART
*&---------------------------------------------------------------------*
*       F4-Hilfe : Verarbeitungsart
*----------------------------------------------------------------------*
form value_request_vaart.
  data: ld_ddtext like dd07v-ddtext.
  call function 'K_SETTLEMENT_VAART_F4'
       exporting
            i_exclude = gd_vaart_excl
       importing
            e_vaart   = vaart
            e_text    = ld_ddtext.
  txtvaart = ld_ddtext.

endform.                               " VALUE_REQUEST_VAART

*&---------------------------------------------------------------------*
*&      Form  START_OF_SELECTION
*&---------------------------------------------------------------------*
*       Selektionsparameter einsammeln und Abrechnung starten
*----------------------------------------------------------------------*
form start_of_selection.

  data: ld_repid like sy-repid,
        ls_wf_witem like scma_witem.

* database commit to free lock on joblog
  call function 'DB_COMMIT'.

* if not sy-batch is initial.           (now in framework)
*   call function 'K_KOKRS_SET'
*        exporting
*             i_kokrs = kokrs.
* endif.

* sender selection
  perform sender_selection tables    it_sender
                           changing  hlp_selart
                                     hlp_variant
                                     hlp_one.
* Abrechnung
* KOKRS wird z.B. für die Werksverprobung gebraucht und
* dort ggfs geaendert !
* call function 'K_KOKRS_SET'              (now in framework)
*      importing
*           e_kokrs = kokrs.

  perform append_selpa tables it_selpa.

  if ausf = 'X'.
    sy-ucomm = 'AUSF'.
  elseif stor = 'X'.
    sy-ucomm = 'STOR'.
  endif.

* Abrechnung starten
  ld_repid = sy-repid.
  ls_wf_witem-wf_witem = wf_witem.
  ls_wf_witem-wf_wlist = wf_wlist.
  call function 'K_SETTLEMENT_EXTERN_START'
       exporting
            i_wrttp     = wrttp_ist
            i_tcode     = gd_tcode
            i_repid     = ld_repid
            i_ucomm     = sy-ucomm
            i_selart    = hlp_selart
            i_variant   = hlp_variant
            i_oneobject = hlp_one
            i_wf_okey   = wf_okey
            i_wf_witem  = ls_wf_witem
       tables
            t_general   = it_selpa
            t_sender    = it_sender
            t_trace     = it_trace.
endform.                               " START_OF_SELECTION

*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form initialization.
  data: begin of ld,
        perio like auak-perio,
        buperio like auak-buperio,
        vaart_txt like dd07v-ddtext,
        end of ld.

* register events for KASS-Framework
  perform kass_fw_init
     using 'KOAO' kass_fw_default_init_options.

  perform kass_fw_event_register using
     kass_fw_event-selection_screen_output
     'AT_SELSCREEN_OUTPUT'
     kass_fw_priority-main
     kass_fw_default_reg_options.

  perform kass_fw_event_register using:
     kass_fw_event-selection_screen
     'AT_SELSCREEN'
     kass_fw_priority-main
     kass_fw_default_reg_options.

* Kostenrechnungskreis    (now in framework)
* if sy-batch is initial.
*   if kokrs is initial.
*     call function 'K_KOKRS_SET'
*          importing
*               e_kokrs = kokrs.
*   endif.
* endif.

* Sender
  perform sender_initialization.

* Initialization for online processing !!! (kokrs not filled)
  if sy-batch is initial.
*   SPA der Buchungsperiode ggfs fuer Abrechnungsperiode uebernehmen
    get parameter id '74P' field ld-perio.
    if ld-perio is initial.
      get parameter id 'VPE' field ld-buperio.
      if not ld-buperio is initial.
        set parameter id '74P' field ld-buperio.
      endif.
    endif.

*   Verarbeitungsart: Auszuschließende Werte ermitteln
    perform vaart_excl_get in program saplko71
            using    kokrs
                     gd_tcode
            changing gd_vaart_excl
                     gd_vaart_dtel_zusatz.
  endif.

* Verarbeitungsart: Vorschlagswert + Prueftext
  perform vaart_text_get in program saplko71
           using     wrttp_ist
                     gd_tcode
                     gd_vaart_excl
           changing  vaart
                     ld-vaart_txt.
  txtvaart = ld-vaart_txt.

endform.                               " INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  HELP_REQUEST_VAART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form help_request_vaart.
  data: begin of ld,
        object1 like dokil-object,
        object2 like dokhl-object,
        end of ld.
  call function 'DOCU_OBJECT_NAME_CONCATENATE'
       exporting
            docu_id  = 'DZ'
            element  = 'CO_VAART'
            addition = gd_vaart_dtel_zusatz
       importing
            object   = ld-object1
       exceptions
            others   = 1.
  check sy-subrc is initial.
  ld-object2 = ld-object1.
  call function 'DOCU_CALL'
       exporting
            displ      = 'X'
            displ_mode = '2'
            id         = 'DZ'
            langu      = sy-langu
            object     = ld-object2
            typ        = 'E'
       exceptions
            others     = 0.

endform.                               " HELP_REQUEST_VAART
*&---------------------------------------------------------------------*
*&      Form  check_wsdat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form check_wsdat.

  data: ld_perio like auak-perio.

* posting period <= settlement period
  if buperio < perio and not buperio is initial.
    message e293(kd).
  endif.

* posting period valid
  if not buperio is initial.
    call function 'K_PERIOD_CHECK_IN_KOKRS'
         exporting
              i_perio = buperio                          "#EC DOM_EQUAL
              i_gjahr = gjahr
              i_kokrs = kokrs.
  endif.

* check posting date
  if not budat is initial.
    if not buperio is initial.
      ld_perio = buperio.
    else.
      ld_perio = perio.
    endif.
    call function 'K_POSTING_DATE_CHECK'
         exporting
              id_kokrs       = kokrs
              id_gjahr       = gjahr
              id_period_from = ld_perio
              id_period_to   = ld_perio
              id_budat       = budat
         exceptions
              no_budat       = 0.
  endif.

endform.                               " check_wsdat
*&---------------------------------------------------------------------*
*&      Form  check_parameter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form check_parameter.

  call function 'K_PERIOD_CHECK_IN_KOKRS'
       exporting
            i_perio = perio
            i_gjahr = gjahr
            i_kokrs = kokrs.

endform.                               " check_parameter
*&---------------------------------------------------------------------*
*&      Form  change_icons
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form change_icons.

* clear icons if box was cleared
  if list is initial and gb_list_changed = 'X'.
    clear:  gb_list_changed, var_cos, var_wip.
  endif.

* set correct icons on pushbuttons
  if gb_list_changed = 'X'.
    write: icon_display_more to pu_list as icon.
    write: text-pu1 to pu_list+4.
  else.
    write: icon_enter_more to pu_list as icon.
    write: text-pu1 to pu_list+4.
  endif.
  if gb_tech_changed = 'X'.
    write: icon_display_more to pu_tech as icon.
    write: text-pu2 to pu_tech+4.
  else.
    write: icon_enter_more to pu_tech as icon.
    write: text-pu2 to pu_tech+4.
  endif.


endform.                               " change_icons
*&---------------------------------------------------------------------*
*&      Form  pushbottons
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form pushbottons.

  case sscrfields-ucomm.
    when 'LIST'.
      if list is initial.
        message e244(kd).
      endif.
      call function 'K_SETTLEMENT_LISTVARIANTS_GET'
           exporting
                incl_variant_wip = 'X'
                id_variant_cos   = var_cos
                id_variant_wip   = var_wip
           importing
                ed_variant_cos   = var_cos
                ed_variant_wip   = var_wip.
      if not var_cos is initial or not var_wip is initial.
        gb_list_changed = 'X'.
      endif.
    when 'TECH'.
      if sy-repid <> 'RKO7CO88' and sy-repid <> 'RKO7KO8G'.
        gb_aufgr = space.
      else.
        gb_aufgr = 'X'.
      endif.
      call function 'K_SETTLEMENT_TECHINFO_GET'
           exporting
                incl_aufgr       = gb_aufgr
                incl_count_com   = 'X'
                incl_trace_objnr = 'X'
                id_aufgr         = errgr
                id_count_com     = count
                id_trace_objnr   = it_trace-objnr
                id_rfc_no        = rfc_no
           importing
                ed_aufgr         = errgr
                ed_count_com     = count
                ed_trace_objnr   = it_trace-objnr
                ed_rfc_no        = rfc_no.
      if count is initial.
        count = '10'.
      endif.
      if not errgr is initial or not it_trace-objnr is initial
         or count <> 10.
        gb_tech_changed = 'X'.
      endif.
      if not rfc_no is initial.
*      gb_tech_changed = 'X'.
      endif.
      refresh it_trace.
      if not it_trace-objnr is initial.
        append it_trace.
      endif.
  endcase.

endform.                               " pushbottons
*&---------------------------------------------------------------------*
*&      Form  check_vaart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form check_vaart.

  clear txtvaart.
  if gd_vaart_excl is initial.
    perform vaart_excl_get in program saplko71
            using    kokrs
                     gd_tcode
            changing gd_vaart_excl
                     gd_vaart_dtel_zusatz.
  endif.
  perform vaart_text_get in program saplko71
          using     wrttp_ist
                    gd_tcode
                    gd_vaart_excl
          changing  vaart
                    gd_txtvaart.
  txtvaart = gd_txtvaart.

endform.                               " check_vaart
*&---------------------------------------------------------------------*
*&      Form  modify_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form modify_fields.

  loop at screen.
    if sy-repid = 'RKO7CO88' or
       sy-repid = 'RKO7VA88' or
       sy-repid = 'RKO7FO3C' or
       sy-repid = 'RKO7CO8A' or
       sy-repid = 'RKO7COWLCO88' or
       sy-repid = 'RKO7COWLVA88' or
       sy-repid = 'RKO7COWLCO8A'.
      if screen-name = 'BZDAT' or
         screen-name = '%_BZDAT_%_APP_%-TEXT'.
        screen-active = '0'.
        modify screen.
      endif.
    endif.
  endloop.

endform.                               " modify_fields
*&---------------------------------------------------------------------*
*&      Form  append_selpa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form append_selpa tables it_selpa structure kaba00.

  clear it_selpa.
  it_selpa-field  = 'LKO74-KOKRS'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = kokrs.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-PERIO'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = perio.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-BUPERIO'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = buperio.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-GJAHR'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = gjahr.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-BUDAT'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = budat.
  append it_selpa.
  clear it_selpa.
  it_selpa-field  = 'LKO74-BZDAT'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = bzdat.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-VAART'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = vaart.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-TESTLAUF'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = testlauf.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-GRND_LISTE'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = grndlist.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-LIST'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = list.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-TDCHECK'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = tdcheck.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-WSDAT'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = wsdat.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-COUNT_COM'.
  it_selpa-option = 'EQ'.
  lko74-count_com = count.
  it_selpa-low    = lko74-count_com.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-RFC_GRP'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = rfcgroup.
  append it_selpa.

  if not errgr is initial.
    clear it_selpa.
    it_selpa-field  = 'GD0-ERRGR'.
    it_selpa-option = 'EQ'.
    it_selpa-low    = errgr.
    append it_selpa.
  endif.

  clear it_selpa.
  it_selpa-field  = 'LKO74-VARIANT_COS'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = var_cos.
  append it_selpa.

  clear it_selpa.
  it_selpa-field  = 'LKO74-VARIANT_WIP'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = var_wip.
  append it_selpa.
  clear it_selpa.
  it_selpa-field  = 'LKO74-RFC_NO'.
  it_selpa-option = 'EQ'.
  it_selpa-low    = rfc_no.
  append it_selpa.

endform.                               " append_selpa