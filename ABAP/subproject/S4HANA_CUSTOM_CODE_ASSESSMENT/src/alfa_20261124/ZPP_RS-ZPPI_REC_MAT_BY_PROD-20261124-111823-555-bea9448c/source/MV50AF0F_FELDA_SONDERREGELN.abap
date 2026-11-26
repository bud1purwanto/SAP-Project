***INCLUDE MV50AF0F_FELDA_SONDERREGELN .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_SONDERREGELN                                 *
*---------------------------------------------------------------------*
*       Feste Sonderregeln der Feldauswahl                            *
*---------------------------------------------------------------------*
form feldauswahl_sonderregeln changing cf_exit_flag type c.

  constants: lc_loop(3) type c value 'LOO'.

  data: cols_wa like line of <tc>-cols,"table control work-area
        kz_strtyp like tmgw2-strtp,
        ls_mpnprf like tmppf.

  field-symbols: <feld>.
  field-symbols: <ls_ilips> like ilips.                       "n_558685
  field-symbols: <ls_xlips> like xlips.                       "n_558685

  statics: l_ekpo_sls like ekpo.
  data:    h_ebelp    like ekpo-ebelp.
ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_04 SPOTS ES_SAPMV50A STATIC .

  assign table field (screen-name) to <feld>. "tut nicht ( mehr )


* Check properties of fields assigned to screen groups
ENHANCEMENT-SECTION     FELDAUSWAHL_SONDERREGELN_01 SPOTS ES_SAPMV50A.
  case screen-group3.

* auf Listbildern im Loop ist das Selektionskennzeichen
* nur für bereits existente Positionen eingabebereit
    when 'SEL'.
      if screen-group2 eq 'LOO'  and
         sy-dyngr      eq 'LIST' and
         lips-posnr    eq 0.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.

* nur eingabebereit, wenn initial
    when '001'.
      if <feld> is initial.
      else.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.

* nicht eingabebereit, wenn initial
    when '002'.
      if <feld> is initial.
        screen-input = 0.
      endif.

* (Numerisches) Feld ausblenden, wenn initial
    when '007'.
      if <feld> is initial.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.

*   Laenderspezifische Feldselektion ('J' + Landeskennzeichen)
    when others.
      if screen-group3(1) = 'J'.
        call function 'J_1B_SD_SCREEN_CONTROL'
          exporting
            i_fieldgroup_3 = screen-group3
            i_vstel        = likp-vstel
            i_aktyp        = t180-trtyp
          importing
            e_input        = screen-input
            e_output       = screen-output
            e_invisible    = screen-invisible
            e_active       = screen-active.

        if screen-active    = 0 or
           screen-invisible = 1 or
           screen-input     = 0.
          cf_exit_flag = charx.
          exit.
        endif.
      endif.
  endcase.
END-ENHANCEMENT-SECTION.

  case screen-group1.
    when 'EHS'.
      call function 'EHS002_CHECK_EHS_ACTIVE'
        exceptions
          ehs_not_exist = 1
          others        = 2.

      if sy-subrc ne 0.
*       don't show the fields likp-cont_dg and likp-proli if EH&S is not
*       installed
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
  endcase.

* Aussenhandel: TabStrip ausgeblendet falls Inlandslieferung
* Risikomanagement / Finanzdokumente
* Felder sind nur bei Lieferungen mit Auftragsbezug pflegbar
  case screen-group2.
    when 'EXP'.
      if ( likp-expkz is initial ) or
         ( likp-exnum is initial ) .
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    when 'LOC'.
      if tvlk-aufer eq charx.          " LF mit Auftragsbezug
        perform field_sel_fin_doc.
      else.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    when others.
*------- Nada
  endcase.

*---------------------------------------------------------------------*
* Check for potential inactive fields with priority

* SP Changeability of returns deliveries. Only the
* fields mentioned in the list below are ready for input
  if likp-vbtyp eq vbtyp_lire and
     likp-spe_le_scenario eq charr.

     if t180-trtyp          ca 'HV'  and
         vbup-wbsta          ca 'A '  and
         vbup-kosta          ca 'A '  and
         vbup-lvsta          ca 'A '  and
         vbup-fksta          ca 'A '  and
         vbup-fkivp          ca 'A '  and
         likp-vlstk          ca 'AD '.
        if screen-name eq 'LIPS-LGORT'  or
           screen-name eq 'RV50A-SELKZ'.
          screen-input = 1.
        else.
          screen-input = 0.
        endif.
        if sy-stepl ne 0 and
           lips-posnr is initial.
          screen-input = 0.
        endif.
        cf_exit_flag = charx.
        return.
      endif.
   endif.

* Lines deleted n_990782

* Batch split screen in inbound deliveries
  if screen-name = 'KUWEV-KUNNR' or
     screen-name = 'KUWEV-NAME1' or
     screen-name = 'KUWEV-ORT01'.
    if v50agl-chargensplitbild = 'X'
       and ( sy-dynnr    eq gc_dyn_batchsplit or
             t185v-panel eq gc_panel_chsp )
       and likp-vbtyp = vbtyp_liav.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Do not show picking date and time in case of inbound deliveries
  if screen-name = 'RV50A-MBDAT' or
     screen-name = 'RV50A-MBUHR'.
    if t185v-panel eq gc_panel_chsp and
       likp-vbtyp  eq vbtyp_liav.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Vendors batch is not visible in outbound deliveries
  if screen-name = 'LIPS-LICHN' or
     screen-name = '*LIPS-LICHN'.
    if ( sy-dynnr    eq gc_dyn_batchsplit or
         t185v-panel eq gc_panel_chsp )
       and likp-vbtyp ne vbtyp_liav.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-UNTTO_PROZ' or
     screen-name = 'LIPS-UEBTO_PROZ'.
    if lips-posnr eq 0.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* MPN Herstellerteilenummer, nur auf Detailbild sichtbar & änderbar
  if screen-name = 'LIPS-EMATN'.
    if mt06a-mprof is initial.                               "n_1304489
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    else.
      if ls_mpnprf-mprof ne mt06a-mprof.                     "n_1304489
        call function 'MB_READ_TMPPF'
          exporting
            profile        = mt06a-mprof                     "n_1304489
          importing
            mpn_parameters = ls_mpnprf
          exceptions
            others         = 1.
      endif.
      if not ls_mpnprf-mpnch is initial.
        screen-input = '1'.
      else.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

  if screen-name = 'MSEG-MENGE' or
     screen-name = 'MSEG-MEINS'.
    if mseg-meins = mseg-erfme.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Show purchase order only if likp-verursys is initial
  if screen-name = 'LIPS-VGBEL' or
     screen-name = 'LIPS-VGPOS' or
     screen-name = 'EKPO-EBELN' or
     screen-name = 'EKPO-EBELP'.
    if not likp-verursys is initial.
      screen-active = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Do not show document status 'Checked' on overview screen
  if screen-name eq 'RV50A-CHST_TXT'.
    if taxi_screen_group(1) eq 'W' and                      "v_n_574894
       xvbuk-bestk eq space        and
       v50agl-display_from_archive eq space.
      screen-invisible = 1.
      cf_exit_flag = charx.
      exit.
    elseif v50agl-display_from_archive ne space.
      screen-intensified = 1.
      cf_exit_flag = charx.
      exit.
    endif.                                                  "^_n_574894
  endif.

  if screen-name = 'LIKP-XBLNR'.
    clear fin1_param.
    fin1_param-appli = 'W'.
    fin1_param-aktyp = t180-aktyp.
    fin1_param-blgar = likp-lfart.
    call function 'OFF_NUMBER_GLOBAL_SCREEN'
      exporting
        i_fin1_param     = fin1_param
        i_likp           = likp
        i_input          = screen-input
        i_output         = screen-output
        i_invisible      = screen-invisible
      importing
        o_input          = screen-input
        o_output         = screen-output
        o_invisible      = screen-invisible
      exceptions
        input_incomplete = 1
        country_unknown  = 2
        others           = 3.
    cf_exit_flag = charx.
    exit.
  endif.

* Close LIFEX field for input in special scenarios
  if screen-name eq 'LIKP-LIFEX' or
     SCREEN-NAME EQ 'LIPS-LIFEXPOS' OR                      "n_1411807
     screen-name eq 'RV50A-VERUR_LA'.
    if likp-spe_lifex_type eq gc_lifex_type-returns       or
*       likp-spe_lifex_type eq gc_lifex_type-vendor_asn    or
       LIKP-SPE_LIFEX_TYPE EQ GC_LIFEX_TYPE-STOCKTRANSFER OR
       LIKP-SPE_LIFEX_TYPE EQ GC_LIFEX_TYPE-NOSTOTRANSFER.    "n_1364822
      screen-input = 0.
      cf_exit_flag = charx.
      return.
    endif.
  endif.

* New dialog: Avoid invisible fields whenever possible
* ('not relevant' might also be a useful information!)
  if t180-bldgr ne gc_new_dialog_outb
     and t180-bldgr ne gc_new_dialog_inb.

    if screen-name = 'VBUP-KOQUA' or
       screen-name = 'VBSTT-KOQUA_BEZ'.
      if vbup-koqua = space.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.

*   Show flag 'Split according to warehouse number' only if not initial
    if screen-name = 'LIKP-LISPL'.
      if likp-lispl is initial.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.

*   Show distribution status only if relevant
    if screen-name = 'LIKP-VLSTK'.
      if likp-vlstk is initial.
        screen-active = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.

  endif.

* Batch split screen is active
  if sy-dyngr eq 'CHSP'.
    if v50agl-chargensplitbild eq charx.
      perform feldauswahl_charge_bwtar_chsp changing cf_exit_flag.
      check cf_exit_flag eq space.
    else.                            "dummy screen active
      if screen-group2 eq lc_loop.
        screen-active = 0.
      else.
        screen-input = 0.
      endif.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if lips-posnr ne 0.
    perform feldauswahl_stat_lvs changing cf_exit_flag.
    check cf_exit_flag eq space.
  endif.

*---------------------------------------------------------------------*
* Please add no checks that influence SCREEN-ACTIVE below this line!
* It is only allowed to change SCREEN-INPUT to 0

* If field is already closed for input no further checks necessary
  if screen-input     = 0 or
     screen-active    = 0 or
     screen-invisible = 1.
    cf_exit_flag = charx.
    exit.
  endif.

  case t180-trtyp.
    when chara.
*     Display mode: no input possible at all
ENHANCEMENT-SECTION     MV50AF0F_FELDA_SONDERREGELN_02 SPOTS ES_SAPMV50A.
      if screen-group3 ne 'SEL'.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
END-ENHANCEMENT-SECTION.
    when charh.
*     No external document number maintenance allowed
      if screen-name = 'LIKP-VBELN'.
        if tvlk-numke = space.
          screen-input = 0.
          cf_exit_flag = charx.
          exit.
        endif.
      endif.
  endcase.

  if status_transport ne 0.
    perform feldauswahl_stat_transport changing cf_exit_flag.
    check cf_exit_flag eq space.
  endif.

*---------------------------------------------------------------------*
* Special checks
  if screen-name eq 'LIKP-WADAT_IST'     or
     screen-name eq 'RV50A-WADAT_IST_LA'.
ENHANCEMENT-SECTION     MV50AF0F_FELDA_SONDERREGELN_01 SPOTS ES_SAPMV50A.
    if xvbuk-wbstk ne charc and
       t180-trtyp  ne chara and
       ( likp-vlstk ca ' AD' or
         ( likp-vlstk eq 'B' and v50agl-dlv_change ne space ) ).
      screen-input = 1.
      cf_exit_flag = charx.
      exit.
    endif.
END-ENHANCEMENT-SECTION.
  endif.


* Goods issue date is obligatory for deliveries without reference
  if screen-name eq 'LIKP-WADAT' or
     screen-name eq 'KUWEV-KUNNR'.
    if ( ( screen-name eq 'LIKP-WADAT' and likp-lfdat is initial )  or
          screen-name eq 'KUWEV-KUNNR' ) and
       lieferung_or eq charx and
       likp-verursys is initial.
      screen-required = 1.
    endif.
  endif.


  if screen-name = 'KUWEV-KUNNR'.
    if not kuwev-kunnr is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-VRKME' or
     screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-POSNR'.
    if lips-posar = charc.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.



* falls Prüflos existiert ist Matnr nicht änderbar
  if screen-name = 'LIPS-MATNR'.
    if not lips-qplos is initial or
       not lips-qtlos is initial.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.


  if screen-name = 'LIPS-WERKS'    or
     screen-name = 'LIPS-LGORT'.
    if v50agl-chargensplitbild = ' '       and
          lips-uecha is initial            and
          sy-dynnr    ne gc_dyn_batchsplit and
          t185v-panel ne gc_panel_chsp     and
          lips-kcmeng gt 0                 and
          lips-xchar = charx.
      IF NOT LIKP-VBTYP EQ VBTYP_LIAV.                        "n_1587144
*       Storage location opened for input of IBD main item
        SCREEN-INPUT = 0.
        CF_EXIT_FLAG = CHARX.
        EXIT.
      ENDIF.                                                  "n_1587144
    endif.
  endif.

  if screen-name = 'LIPS-LGMNG'    or
     screen-name = 'LIPSD-G_LFIMG' or
     screen-name = 'LIPS-VRKME'    or
     screen-name = 'LIPS-MATNR'    or
     screen-name = 'LIPS-CHARG'.
    if v50agl-chargensplitbild = ' '      and
      not lips-uecha is initial           and
      sy-dynnr       ne gc_dyn_batchsplit and
      t185v-panel    ne gc_panel_chsp.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* batch split and corr. -> no quantity related input on pick detail
  IF screen-name = 'LIPS-LFIMG'    OR                       "v_n_558685
     screen-name = 'LIPS-UMVKN'    OR
     screen-name = 'LIPS-UMVKZ'.
    IF v50agl-chargensplitbild = ' '      and
      not lips-uecha is initial           and
      sy-dynnr       ne gc_dyn_batchsplit and
      t185v-panel    ne gc_panel_chsp.
      READ TABLE ilips ASSIGNING <ls_ilips>
                       WITH KEY posnr = lips-uecha.
      READ TABLE xlips INDEX <ls_ilips>-tabix
                       ASSIGNING <ls_xlips>.
      IF NOT <ls_xlips>-grkor IS INITIAL AND
             <ls_xlips>-uepos IS INITIAL.                     "n_745428
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      ENDIF.
    ENDIF.
  ENDIF.                                                    "^_n_558685

  if screen-name = 'LIPS-LGMNG'.
    if sy-dynnr ne gc_dyn_batchsplit and
       t185v-panel ne gc_panel_chsp.
      screen-name = 'LIPS-LGMNG'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-CHARG'.
    if lips-kzfme ca kzfme_ws.
      if lips-kcmengvme > 0.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    else.
      if lips-kcmeng > 0.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

* lines deleted                                               "n_671468

  if xvbup-lvsta = charb.
    if screen-name = 'LIPS-LGORT' or
       screen-name = 'LIPS-LFIMG' or
       screen-name = 'LIPS-VRKME' or
       screen-name = 'LIPS-CHARG' or
       screen-name = 'LIPS-BWART'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

  if xvbup-lvsta ca 'BC' and                                 "v_n_895666
     xvbup-kosta ca 'BC'.
    if screen-name = 'LIPS-BWART' or
       screen-name = 'LIPS-INSMK' or
       screen-name = 'LIPS-BESTQ'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.                                                     "^_n_895666

ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_02 SPOTS ES_SAPMV50A.
* If open WM transfer orders are assigned to the main item of a batch
* split the batch split items must not be changed.
  if screen-name = 'LIPS-LGORT' or
     screen-name = 'LIPS-LFIMG' or
     screen-name = 'LIPS-LICHN' or
     screen-name = 'LIPS-UMVKZ' or
     screen-name = 'LIPS-UMVKN' or
     screen-name = 'LIPS-VRKME' or
     screen-name = 'LIPS-CHARG' or
     screen-name = 'LIPS-BWTAR'.
    if ( not lips-uecha is initial or                       "HP_310651
       v50agl-chargensplitbild eq charx ) and
       gs_vbup_uecha-lvsta eq charb.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.


*   Deaktivierung Coding von Hinweis 321000, Inkonsistenzen
*   zwischen vepo und lips werden durch Hinweis 365414
*   toleriert, der Chargensplit ist somit wieder möglich
  if 1 = 2.
* batch split items are packed must not be changed
    if ( not lips-uecha is initial or                         "50A
       v50agl-chargensplitbild eq charx ) and
       gs_vbup_uecha-pksta is initial and
       xvbup-pksta ca 'BC'.
      if screen-name = 'LIPS-LGORT' or
         screen-name = 'LIPS-LFIMG' or
         screen-name = 'LIPS-LICHN' or
         screen-name = 'LIPS-UMVKZ' or
         screen-name = 'LIPS-UMVKN' or
         screen-name = 'LIPS-VRKME' or
         screen-name = 'LIPS-CHARG' or
         screen-name = 'LIPS-BWTAR'.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.

  if screen-name = 'LIKP-TRSPG'.
    if xvbuk-trsta = charb or
       xvbuk-trsta = charc.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.

* Feldsteuerung für Leergutgruppen: bei Vorgängerbeleg Bestellung können
* als Stücklistentyp nur Leergutstücklisten vorkommen !
  if screen-name = 'RV50A-MENGE_GW' or
     screen-name = 'RV50A-MEINS_GW' or
     screen-name = 'LIPSD-G_LFIMG' or                         "n_1021971
     screen-name = 'LIPS-LFIMG' or
     screen-name = 'LIPS-VRKME' or
     screen-name = 'RV50A-LIPS_SELKZ'.
    if lips-vgtyp = vbtyp_bestell.
      if not lips-uepos is initial.
* für Leergutpositionen
*       values for quantities possible in case of SLS
        if ( lips-vgbel ne l_ekpo_sls-ebeln
          or lips-vgpos ne l_ekpo_sls-ebelp )
        and not ( screen-name      eq 'RV50A-MEINS_GW'
               or screen-name      eq 'LIPS-VRKME'     ).

*          note: EKPO should be buffered at this place
*                already or will be red later via
*                buffer
          move lips-vgpos to h_ebelp.
          call function 'ME_EKPO_SINGLE_READ'
            exporting
              pi_ebeln         = lips-vgbel
              pi_ebelp         = h_ebelp
            importing
              po_ekpo          = l_ekpo_sls
            exceptions
              no_records_found = 1
              others           = 99.

          if sy-subrc <> 0.
            clear l_ekpo_sls-uptyp.
            move lips-vgbel to l_ekpo_sls-ebeln.
            move lips-vgpos to l_ekpo_sls-ebelp.
          endif.
        endif.                         "EKPO-read necessary?

        if l_ekpo_sls-uptyp ne '9'     "i.e. SLS-subitem
        or screen-name      eq 'RV50A-MEINS_GW'
        or screen-name      eq 'LIPS-VRKME'.
          screen-input = 0.
          cf_exit_flag = charx.
          exit.
        endif.
      elseif not lips-grkor is initial.
* bei der Vollgutposition keine Änderung der Mengeneinheit erlaubt, da
* dies neue Stücklistenauflösung bedeuten würde
        if screen-name = 'LIPS-VRKME' or
           screen-name = 'RV50A-MEINS_GW'.
          screen-input = 0.
          cf_exit_flag = charx.
          exit.
        endif.
      endif.
    ELSEif lips-vgtyp ca 'CI' and screen-name = 'LIPS-VRKME'."SP_654782
      if xvbap-vbeln ne lips-vgbel or xvbap-posnr ne lips-vgpos.
        read table xvbap with key vbeln = lips-vgbel
                                  posnr = lips-vgpos
                                  binary search.
      endif.
      IF NOT xvbap-stkey IS INITIAL.
* auch bei Auftragsbezug und Stücklisten keine Änderung der Mengen-
* einheit, da sonst Stücklistenauflösung notwendig
        PERFORM pruefen_structart_sl CHANGING kz_strtyp
                                            xvbap-stkey.      "SP_668592
        IF kz_strtyp = charp AND
           NOT lips-grkor IS INITIAL.
          screen-input = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  endif.

* Anteils-/variable Mengeneinheit
ENHANCEMENT-SECTION     FELDAUSWAHL_SONDERREGELN_05 SPOTS ES_SAPMV50A.
  if lips-kzfme ca kzfme_ws.
* Zähler/Nenner nicht änderbar
    if screen-name = 'LIPS-UMVKZ' or
       screen-name = 'LIPS-UMVKN'.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
* Vorgängerbeleg vorhanden
    if not lips-vgbel is initial  or
       not lips-vgtyp is initial.
* --> VRKME nicht änderbar
      if screen-name = 'LIPS-VRKME'.
        screen-input = 0.
      endif.
    endif.
* Chargensplitpositionen vorhanden
    if screen-name = 'LIPS-VRKME'.
      if lips-kcmeng > 0 and lips-prosa is initial.
* --> VRKME nicht änderbar
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
      if not lips-uecha is initial.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.
END-ENHANCEMENT-SECTION.

* Anteils-/variable ME auf HPPOS u. abw. ME auf Chargensplitposition
  if screen-name = 'LIPS-LFIMG'.
    if clips-kzfme ca kzfme_ws and not lips-uecha is initial
       and lips-vrkme ne clips-vrkme and lips-lfimg le 0.
*--> LFIMG nicht änderbar
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
* Anteils-/variable ME auf Chargensplitposition u. abw. ME auf HPPOS
    if lips-kzfme ca kzfme_ws and not lips-uecha is initial
       and lips-vrkme ne clips-vrkme and lips-lfimg le 0.
      screen-input = 0.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.


* Shipment Info
* If LIKP-TRMTYP is filled, do not allow LIKP-TRATY to be changed
  if not ( likp-trmtyp is initial ) and
     screen-name eq 'LIKP-TRATY'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.

* Batch split screen: no change if inspection lot + HU exist "v_n_799348
  if v50agl-chargensplitbild = 'X'
     and ( sy-dynnr    eq gc_dyn_batchsplit or
           t185v-panel eq gc_panel_chsp )
     and likp-vbtyp = vbtyp_liav.
    if screen-name eq 'LIPS-LFIMG' or
       screen-name eq 'LIPS-VRKME'.
      CALL FUNCTION 'QAAT_SD_CHECK_HU_LOT'
        EXPORTING
          i_prueflos              = lips-qplos
       EXCEPTIONS
          STATUS_HUM_ACTIVE       = 1
          OTHERS                  = 2
                .
      if sy-subrc eq 1.
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
      endif.
    endif.
  endif.                                                     "^_n_799348

* partial goods receipt: change delivery quantity (Teil-WE)  "v_n_796053
  if screen-name = 'LIPSD-G_LFIMG' or screen-name = 'LIPS-LFIMG'.
* lines of notes 1107255 and 1237396 deleted                   "v_n_1265060
    if xvbuk-wbstk = 'B' and likp-vbtyp = vbtyp_liav and
       ( ( xvbup-wbsta CA 'BC' and likp-vlstk is initial ) or
         ( xvbup-wbsta = 'B' and not likp-verursys is initial    "n_1312397
                             and not likp-vlstk is initial ) )."^_n_1265060
      screen-input = '1'.
      cf_exit_flag = charx.
      exit.
    endif.
  endif.                                                     "^_n_796053


ENHANCEMENT-POINT FELDAUSWAHL_SONDERREGELN_03 SPOTS ES_SAPMV50A.


endform.                    "feldauswahl_sonderregeln