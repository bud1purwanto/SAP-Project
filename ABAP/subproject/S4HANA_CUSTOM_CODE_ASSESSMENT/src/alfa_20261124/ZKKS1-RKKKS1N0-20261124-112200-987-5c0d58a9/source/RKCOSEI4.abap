*----------------------------------------------------------------------*
*   INCLUDE RKCOSEI4                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SENDER_SELECTION
*&---------------------------------------------------------------------*
*       Sender-spezifische Selektionsparameter in Tab. P_SELPA
*       aufnehmen
*       Aufruf aus RKO74001
*----------------------------------------------------------------------*
*      <--p_selpa   Tabelle der Selektionsparameter (ohne Variante)    *
*                   Selektion ueber Funktionsgr. KASS                  *
*      <--p_tcode   Name der zugehörigen Online-Sammel-AbrTransaktion  *
*      <--p_selart  Erweiterte Selektionsart
*                   Siehe Report RKASSELA und Funktionsgr. KASS
*      <--p_variant Selektionsvariante                                 *
*                   Selektion ueber Funktionsgr. KASS                  *
*----------------------------------------------------------------------*
form sender_selection tables    pt_selpa    structure cosel2
                      changing  p_selart   type kass_selart
                                p_variant  like rsvar-variant
                                p_one.
  data:
     ld_kokrs like lko74-kokrs.
  call function 'K_KOKRS_SET'
       importing
            e_kokrs = ld_kokrs.

  p_one = ' '.
  clear pt_selpa.
  pt_selpa-low(10) = 'KOKRS     '.
  pt_selpa-low+10  = ld_kokrs.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  loop at werks.
    pt_selpa-low(10) = 'WERKS     '.
    pt_selpa-low+10  = werks-low.
    pt_selpa-high    = werks-high.
    pt_selpa-option  = werks-option.
    pt_selpa-sign    = werks-sign.
    append pt_selpa.
  endloop.

  loop at auart.
    pt_selpa-low(10) = 'AUART     '.
    pt_selpa-low+10  = auart-low.
    pt_selpa-high    = auart-high.
    pt_selpa-option  = auart-option.
    pt_selpa-sign    = auart-sign.
    append pt_selpa.
  endloop.

  loop at matnr.
    pt_selpa-low(10) = 'MATNR     '.
    pt_selpa-low+10  = matnr-low.
    pt_selpa-high    = matnr-high.
    pt_selpa-option  = matnr-option.
    pt_selpa-sign    = matnr-sign.
    append pt_selpa.
  endloop.

  loop at aufnr.
    pt_selpa-low(10) = 'AUFNR     '.
    pt_selpa-low+10  = aufnr-low.
    pt_selpa-high    = aufnr-high.
    pt_selpa-option  = aufnr-option.
    pt_selpa-sign    = aufnr-sign.
    append pt_selpa.
  endloop.

  clear pt_selpa.
  pt_selpa-low(10) = 'AUFGR     '.
  pt_selpa-low+10  = aufgr.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_FAUF '.
  pt_selpa-low+10  = in_fauf.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.
ENHANCEMENT-POINT RKCOSEI4_01 SPOTS ES_RKCOSEI4 INCLUDE BOUND.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_PKOSA'.
  pt_selpa-low+10  = in_pkosa.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_PIAUF'.
  pt_selpa-low+10  = in_piauf.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_QMAUF'.
  pt_selpa-low+10  = in_qmauf.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_PROJ '.
  pt_selpa-low+10  = in_proj.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  clear pt_selpa.
  pt_selpa-low(10) = 'INCL_KSTRG'.
  pt_selpa-low+10  = in_kstrg.
  pt_selpa-option  = 'EQ'.
  pt_selpa-sign    = 'I'.
  append pt_selpa.

  p_selart = con_selart-or3.
endform.                               " SENDER_SELECTION

*&---------------------------------------------------------------------*
*&      Form  SENDER_INITIALIZATION
*&---------------------------------------------------------------------*
*       Aufruf aus RKO74001
*----------------------------------------------------------------------*
form sender_initialization.
  statics:
     ld_1st_time type xflag value 'X'.

  check not ld_1st_time is initial.
  clear ld_1st_time.
  if sy-batch is initial
     and werks is initial.
    get parameter id 'WRK' field werks.
  endif.
* PERFORM WERKS_TEXT_GET
*    USING
*       WERKS
*       ' '
*    CHANGING
*       TXTW.
  if sy-repid <> 'RKO7CO88' and
     sy-repid(5) <> 'RKWTP'.
    loop at screen.
      if screen-group1 = 'AGR'.
        screen-active = '0'.
        modify screen.
      endif.
    endloop.
  endif.
  perform select_options_restrict.
  perform kass_fw_event_register using:
       kass_fw_event-selection_screen_output
       'SENDER_SELSCREEN_OUTPUT'
       kass_fw_priority-default
       kass_fw_default_reg_options ,
       kass_fw_event-selection_screen
       'SENDER_SELSCREEN'
       kass_fw_priority-default
       kass_fw_default_reg_options .
endform.                               " SENDER_INITIALIZATION


*---------------------------------------------------------------------*
*       FORM sender_selscreen_output                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form sender_selscreen_output.
  statics:
     sd_1st_time  type xflag value 'X',
     sd_in_fauf   like in_fauf,
     sd_in_pkosa  like in_pkosa,
     sd_in_piauf  like in_piauf,
     sd_in_qmauf  like in_qmauf,
     sd_in_proj   like in_proj,
     sd_in_kstrg  like in_kstrg,
     sd_auart     like auart[],
     sd_matnr     like matnr[].

  data:
     ld_vrgng type tj01-vrgng.

  if not sd_1st_time is initial.
    clear sd_1st_time.
    sd_auart    = auart[].
    sd_matnr    = matnr[].
    sd_in_fauf  = in_fauf.
    sd_in_pkosa = in_pkosa.
    sd_in_piauf = in_piauf.
    sd_in_qmauf = in_qmauf.
    sd_in_proj  = in_proj.
    sd_in_kstrg = in_kstrg.
  endif.

  perform kass_fw_activity_get
     changing ld_vrgng.

  if selexp is initial.
    auart[]  = sd_auart.
    matnr[]  = sd_matnr.
    in_fauf  = sd_in_fauf.
    in_pkosa = sd_in_pkosa.
    in_piauf = sd_in_piauf.
    in_qmauf = sd_in_qmauf.
    in_proj  = sd_in_proj.
    in_kstrg = sd_in_kstrg.

    subscexp = '@3S@'.
    call function 'ICON_CREATE'
         exporting
              name   = 'ICON_DATA_AREA_EXPAND'
         importing
              result = subscexp.
    loop at screen.
      if screen-group1 = 'EXP'.
        screen-active = '0'.
        modify screen.
      endif.
    endloop.
  else.
    subscexp = '@3T@'.
    call function 'ICON_CREATE'
         exporting
              name   = 'ICON_DATA_AREA_COLLAPSE'
         importing
              result = subscexp.
    loop at screen.
      if screen-group1 = 'IMP'
*        OR screen-name CS 'AUFNR'
         or screen-name cs 'MATNR'.
        screen-active = '0'.
        modify screen.
      endif.
    endloop.
  endif.
  case ld_vrgng.
    when 'KVAR'.                       "Variances
      loop at screen.
        if    screen-name cs 'IN_QMAUF'
           or screen-name cs 'IN_PROJ'
           or screen-name cs 'IN_KSTRG'.
          screen-active = '0'.
          modify screen.
        endif.
      endloop.
      clear: in_qmauf, in_proj, in_kstrg.
  endcase.
endform.

*---------------------------------------------------------------------*
*       FORM sender_selscreen                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form sender_selscreen.
  data:
     ld_no_of_plants type i,
     ld_kokrs        type tka01-kokrs,
     ld_kokrs_sav    type tka01-kokrs,
     ld_werks_sav    type aufk-werks.

  if sy-ucomm = 'SUBSCEXP'.
    if selexp is initial.
      selexp = 'X'.
    else.
      clear selexp.
    endif.
  endif.
  perform kokrs_adjust using werks[].
endform.


*&---------------------------------------------------------------------*
*&      Form  WERKS_TEXT_GET
*&---------------------------------------------------------------------*
*       Text des Werks ermitteln
*----------------------------------------------------------------------*
*  -->  p_WERKS   Werk
*  <--  p_TEXT    Text des Werks
*----------------------------------------------------------------------*
form werks_text_get using     p_werks  like lko74-werks
                              p_chk_input type c
                    changing  p_text.
  tables: t001w.
  clear txtw.
* Werk angegeben
  if not p_werks is initial.
*   Werkstab. lesen
    select single * from t001w where werks = p_werks.
    if sy-subrc is initial.
      p_text = t001w-name1.
    else.
      if not p_chk_input is initial.
        message id 'KD' type 'E' number '600'.
      else.
        clear p_text.
      endif.
    endif.

* Werk initial -> alle Werke des KOKRS
  else.
*    WRITE text-001 TO p_text.
  endif.

endform.                               " WERKS_TEXT_GET


*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_WERKS
*&---------------------------------------------------------------------*
*       F4-Hilfe für Feld Werk
*----------------------------------------------------------------------*
form value_request_werks.

  data:
     it_f4_fields type help_value occurs 0 with header line,
     it_f4_values(60) type c occurs 3 with header line,
     ld_kokrs like tka01-kokrs,
     lt_t001w like t001w occurs 0 with header line.

  refresh it_f4_fields.
  refresh it_f4_values.

* Anzeige-Spalten beschreiben
  if it_f4_fields[] is initial.
    it_f4_fields-tabname = 'LKO74'.
    it_f4_fields-fieldname = 'WERKS'.
    it_f4_fields-selectflag = 'X'.
    append it_f4_fields.
    it_f4_fields-tabname = 'DD07V'.
    it_f4_fields-fieldname = 'DDTEXT'.
    it_f4_fields-selectflag = ' '.
    append it_f4_fields.
  endif.

  select * from t001w into table lt_t001w.
  loop at lt_t001w.
    append lt_t001w-werks to it_f4_values.
    append lt_t001w-name1 to it_f4_values.
  endloop.

* F4-Werte anzeigen
  call function 'HELP_VALUES_GET_WITH_TABLE'
       exporting
            fieldname    = 'WERKS'
            tabname      = 'LKO74'
       importing
            select_value = werks
       tables
            fields       = it_f4_fields
            valuetab     = it_f4_values.

endform.                               "value_request_werks.

*---------------------------------------------------------------------*
*       FORM KOKRS_ADJUST                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_WERKS                                                       *
*---------------------------------------------------------------------*
form kokrs_adjust
   using
      p_werksel like werks[].

  data:
     ld_in_rfc       type xflag,
     ld_popup        type xflag,
     ld_werksel      like line of p_werksel,
     ld_no_of_plants type i,
     ld_kokrs        type tka01-kokrs,
     ld_kokrs_sav    type tka01-kokrs,
     ld_werks_sav    type aufk-werks.

  check not p_werksel is initial.


  call function 'SPTA_RFC_CONTEXT_DETECT'
       importing
            rfc_context = ld_in_rfc.
  if  sy-batch is initial
      and ld_in_rfc is initial
      and sy-slset is initial.         "Variant of Report
    ld_popup = 'X'.
  else.
    ld_popup = '0'.
  endif.

  read table p_werksel index 1 into ld_werksel.
  call function 'RM_KOKRS_TO_PLANT_FIND'
       exporting
            werks           = ld_werksel-low
       importing
            e_kokrs         = ld_kokrs_sav
       exceptions
            bukrs_not_found = 01
            kokrs_not_found = 02.
  if sy-subrc <> 0.
    message id 'KO' type 'E' number '133' with ld_werksel-low.
    exit.
  endif.
  call function 'K_KOKRS_SET'
       exporting
            display   = 'X'
            i_kokrs   = ld_kokrs_sav
            popup     = ld_popup
       exceptions
            not_found = 1
            others    = 2.
  ld_werks_sav = ld_werksel-low.

  describe table p_werksel lines ld_no_of_plants.
  if ld_no_of_plants > 1.
* Check, if all plants entered belong to the same KoKrs
    loop at p_werksel into ld_werksel.
      call function 'RM_KOKRS_TO_PLANT_FIND'
           exporting
                werks           = ld_werksel-low
           importing
                e_kokrs         = ld_kokrs
           exceptions
                bukrs_not_found = 01
                kokrs_not_found = 02.
      if sy-subrc <> 0.
        message id 'KO' type 'E' number '133' with ld_werksel-low .
        exit.
      endif.
      if ld_kokrs_sav <> ld_kokrs.
        message id '61' type 'E' number '824'
                with ld_werks_sav ld_werksel-low.
        exit.
      endif.
    endloop.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM select_options_restrict                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form select_options_restrict.
  type-pools: sscr.
  data:
     ld_sscr_restrict type sscr_restrict,
     ld_ass like line of ld_sscr_restrict-ass_tab,
     ld_opt_list like line of ld_sscr_restrict-opt_list_tab.
  statics: first_time type c value 'X'.
  check not first_time is initial.
  clear first_time.

  ld_opt_list-name = 'OPTLIST_EQ'.
  ld_opt_list-options-eq = 'X'.
  insert ld_opt_list into table ld_sscr_restrict-opt_list_tab.
  ld_ass-kind = 'S'.
  ld_ass-name = 'WERKS'.
  ld_ass-sg_main = 'I'.
  ld_ass-op_main = 'OPTLIST_EQ'.
  ld_ass-op_addy = 'OPTLIST_EQ'.
  insert ld_ass into table ld_sscr_restrict-ass_tab.
  call function 'SELECT_OPTIONS_RESTRICT'
       exporting
*           PROGRAM                =
            restriction            = ld_sscr_restrict.
*           DB                     = ' '
endform.