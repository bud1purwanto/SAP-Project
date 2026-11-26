***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe E:                                                       *
*                                                                     *
***********************************************************************


*---------------------------------------------------------------------*
*       FORM EINGABE_GEWICHT_PRUEFEN                                  *
*---------------------------------------------------------------------*
*       Prüfung :  Nettogewicht kleiner als Bruttogewicht             *
*                  Gewichtseinheit muss vorhanden sein und            *
*                  zulässige Dimension haben                          *
*---------------------------------------------------------------------*
form eingabe_gewicht_pruefen using eg_btgew like likp-btgew
                                   eg_ntgew like likp-ntgew
                                   eg_gewei like likp-gewei.

  if eg_btgew lt eg_ntgew.
    message e056.
  endif.

  if eg_gewei eq space     and
     ( eg_btgew ne space   or
       eg_ntgew ne space ).
    message e057.
  endif.
  if eg_gewei ne space.
    call function 'DIMENSIONCHECK_MASS'
      exporting
        gewei               = eg_gewei
      exceptions
        dimension_not_mass  = 01
        t006d_entry_missing = 02
        t006_entry_missing  = 03.
    if sy-subrc ne 0.
      message e077 with eg_gewei.
    endif.
  endif.
  r185d-dataloss = charx.

endform.                    "eingabe_gewicht_pruefen
*eject


*---------------------------------------------------------------------*
*       FORM EINGABE_VOLUMEN_PRUEFEN                                  *
*---------------------------------------------------------------------*
*       Prüfung :  Nettogewicht kleiner als Bruttogewicht             *
*                  Gewichtseinheit muss vorhanden sein und            *
*                  zulässige Dimension haben                          *
*---------------------------------------------------------------------*
form eingabe_volumen_pruefen using ev_volum like likp-volum
                                   ev_voleh like likp-voleh.

  if ev_voleh eq space
     and ev_volum ne space.
    message e079.
  endif.
  if ev_voleh ne space.
    call function 'DIMENSIONCHECK_VOLUME'
      exporting
        voleh                = ev_voleh
      exceptions
        dimension_not_volume = 01
        t006d_entry_missing  = 02
        t006_entry_missing   = 03.
    if sy-subrc ne 0.
      message e078 with ev_voleh.
    endif.
  endif.
  r185d-dataloss = charx.
endform.                    "eingabe_volumen_pruefen
*eject


*---------------------------------------------------------------------*
*       FORM ERROR_LOG_COPY                                           *
*---------------------------------------------------------------------*
*       Schreiben Fehlerprotokoll beim Kopieren                       *
*---------------------------------------------------------------------*
form error_log_copy.
endform.                    "error_log_copy
*eject


*---------------------------------------------------------------------*
*       FORM EXCLUDE_FUNCTION_TRTYP.                                  *
*---------------------------------------------------------------------*
*       Bei Anzeigen sind gewisse FCODE nicht zulässig                *
*---------------------------------------------------------------------*
form exclude_function_trtyp.

  data: lf_fcode       type fcode,
        lf_subrc       type sysubrc,
        ls_cua_exclude type shp_cua_exclude.

  if    t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    if t180-tcode cs 'VLPOD'.
      case t180-trtyp.
        when chara.
          do 99 times varying lf_fcode from cua_exclu_vlpoda_nd-f01
                                       next cua_exclu_vlpoda_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
        when charv.
          do 99 times varying lf_fcode from cua_exclu_vlpodc_nd-f01
                                       next cua_exclu_vlpodc_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
      endcase.
    elseif t180-tcode = 'VLODAR' or t180-tcode = 'VLIDAR'.
            do 99 times varying lf_fcode from cua_exclu_anzeige_ARCH_nd-f01
                                         next cua_exclu_anzeige_ARCH_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
    else.
      case t180-trtyp.
        when chara.
          do 99 times varying lf_fcode from cua_exclu_anzeige_nd-f01
                                       next cua_exclu_anzeige_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
        when charh.
          do 99 times varying lf_fcode from cua_exclu_anlegen_nd-f01
                                       next cua_exclu_anlegen_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
        when charv.
          do 99 times varying lf_fcode from cua_exclu_aendern_nd-f01
                                       next cua_exclu_aendern_nd-f02.
            if lf_fcode(4) = '9999'.
              exit.
            endif.
            ls_cua_exclude-function = lf_fcode.
            insert ls_cua_exclude into table cua_exclude.
          enddo.
      endcase.
    endif.
  else.                                "old dialog
    case t180-trtyp.
      when chara.
        do 99 times varying lf_fcode from cua_exclu_anzeige-f01
                                     next cua_exclu_anzeige-f02.
          if lf_fcode(4) = '9999'.
            exit.
          endif.
          ls_cua_exclude-function = lf_fcode.
          insert ls_cua_exclude into table cua_exclude.
        enddo.
      when charh.
        do 99 times varying lf_fcode from cua_exclu_anlegen-f01
                                     next cua_exclu_anlegen-f02.
          if lf_fcode(4) = '9999'.
            exit.
          endif.
          ls_cua_exclude-function = lf_fcode.
          insert ls_cua_exclude into table cua_exclude.
        enddo.
      when charv.
        do 99 times varying lf_fcode from cua_exclu_aendern-f01
                                     next cua_exclu_aendern-f02.
          if lf_fcode(4) = '9999'.
            exit.
          endif.
          ls_cua_exclude-function = lf_fcode.
          insert ls_cua_exclude into table cua_exclude.
        enddo.
    endcase.
  endif.

* default: do not display dynamical available fcodes
* 'process next/previsous incompleteness'
* 'terminate incompleteness processing'
  perform cua_fcode_allow using 'UCNX' no.
  perform cua_fcode_allow using 'UCBK' no.
  perform cua_fcode_allow using 'UCCL' no.

endform.                    "exclude_function_trtyp
*eject


*---------------------------------------------------------------------*
*       FORM EXT_NUMMER_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Die externe Belegnummer wird auf Gültigkeit geprüft.          *
*---------------------------------------------------------------------*
form ext_nummer_pruefen.

  data: enp_returncode.

  data: lf_tabix type sytabix,
        ls_nriv like nriv,
        lf_numki like tvlk-numki,
        lf_flag_internal type c,
        lf_vbeln(19) type c,
        ls_docnum_publish type shp_docnum_publish,
        lt_docnum_publish type shp_docnum_publish_t.

  ranges: lt_r_check for likp-vbeln.

  check likp-vbeln ne space.

* It is assumed at first that the given number is intended to fill holes
* in the internal number range.
  lf_numki = tvlk-numki.
  perform userexit_number_range using lf_numki.
  if lf_numki ne space.
    call function 'NUMBER_GET_INFO'
      exporting
        nr_range_nr        = lf_numki
        object             = 'RV_BELEG'
      importing
        interval           = ls_nriv
      exceptions
        interval_not_found = 1
        object_not_found   = 2
        others             = 3.
    if sy-subrc ne 0.
      message id sy-msgid type 'E' number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    lt_r_check-sign   = 'I'.
    lt_r_check-option = 'BT'.
    write ls_nriv-fromnumber to lt_r_check-low  right-justified.
    write ls_nriv-nrlevel    to lt_r_check-high right-justified.
    append lt_r_check.
    if likp-vbeln in lt_r_check.
      select single * from vbuk
                      where vbeln eq likp-vbeln.
      if sy-subrc eq 0.
        write likp-vbeln to lf_vbeln no-zero.
        message e346 with lf_vbeln.
      endif.
      lf_flag_internal = charx.
    endif.
  endif.

  if tvlk-numke eq space and lf_flag_internal eq space.
    message e007 with likp-lfart.
  endif.

  perform lieferung_sperren using likp-vbeln.

  if lf_flag_internal eq space.
    call function 'NUMBER_CHECK'
      exporting
        number      = likp-vbeln
        nr_range_nr = tvlk-numke
        object      = 'RV_BELEG'
      importing
        returncode  = enp_returncode.

    if enp_returncode ne space.
      perform lieferung_entsperren using likp-vbeln.
      message e020.
    endif.
  endif.

* Probelesen auf Vertriebsbelegkopf
  perform vbuk_select_probe using likp-mandt likp-vbeln.

* Setzen der akzeptierten Nummer in alle Tabellen
  read table xlikp index 1.
  if sy-subrc eq 0.
    xlikp-vbeln = likp-vbeln.
    modify xlikp index sy-tabix.
  endif.

  xlikp-mandt = likp-mandt.
  xlikp-vbeln = likp-vbeln.
  perform b_abhaengige_tabellen_updaten using space.

* Bei VL01 mit Chargenfindung ist die ilips zu einer
* nicht sortierten xlips aufgebaut.
* Nach sort im rename müssen Indizes in ilips neu ermittelt werden
  refresh slips.
  loop at ilips.

    call function 'SHP_XLIPS_LESEN_DIREKT'
      exporting
        if_vbeln      = likp-vbeln
        if_posnr      = ilips-posnr
        if_omit_ilips = charx
      importing
        cf_tabix      = lf_tabix
      tables
        ct_lips       = xlips
      exceptions
        others        = 1.
    if sy-subrc = 0.
      slips-tabix =
      ilips-tabix = lf_tabix.
      append slips.
      modify ilips.
    endif.
  endloop.


* Texte
  call function 'SD_EXTERNAL_NUMBER'
    exporting
      fi_vbeln = xlikp-vbeln
    tables
      xthead   = xthead.

* korrigieren der internen Tabellen fue Bedarfsuebergabe
  data atp_type type les_atp_type.
  call function 'LE_ATP_GET_VERSION'
    importing
      atp_type = atp_type.

  if atp_type eq charo.
    call function 'RV_REQUIREMENT_CORRECT'
      exporting
        belegnummer = likp-vbeln
      tables
        avbbd       = avbbd.
  else.
    call function 'LE_ATP_RV_REQUIREMENT_CORRECT'
      exporting
        belegnummer = likp-vbeln.
  endif.

* Renumber conditions
  tkomv-knumv = likp-knump .
  if not tkomv-knumv is initial.
    modify tkomv from tkomv
                 transporting knumv
                 where knumv eq space.
  endif.

* Highest batch item number in delivery
  gt_batch_item_num-vbeln = likp-vbeln.
  modify gt_batch_item_num from gt_batch_item_num
                           transporting vbeln
                           where vbeln eq space.
  sort gt_batch_item_num by vbeln.

  perform partner_initialize_callback.

  ls_docnum_publish-vbeln_old = space.
  ls_docnum_publish-vbeln_new = likp-vbeln.
  append ls_docnum_publish to lt_docnum_publish.

  if not gi_badi_delivery is initial.              "n_530754/n_637289
  call method gi_badi_delivery->document_number_publish
    exporting
      it_docnum_publish = lt_docnum_publish
      is_v50agl         = v50agl
      if_trtyp          = t180-trtyp
      if_tcode          = t180-tcode
    changing
      cs_v50agl_cust    = v50agl_cust.
  endif.                                                    "n_530754

* update XVBAPF                                             "v_n_766135
  perform rename_cumulated_flow(sapmv50a) tables xvbapf
                               using  space
                                      likp-vbeln.           "^_n_766135

* Update serial numbers                                     "v_n_601776
  perform serialnumber_rename(sapmv50a) using space
                                              likp-vbeln.   "^_n_601776

endform.                    "ext_nummer_pruefen
*eject
*##ngr-anf
*&---------------------------------------------------------------------*
*&      Form  ERMITTELN_BELEG_MC
*&---------------------------------------------------------------------*
*       Ermitteln Belegnummer Lieferavis/Grob-WE per Matchcode         *
*----------------------------------------------------------------------*
form ermitteln_grobwe_mc.

  check not rv50a-verur_gw is initial.

  call function 'SD_GET_DELIVERY_BY_MC'
    exporting
      i_verur = rv50a-verur_gw
    importing
      e_vbeln = likp-vbeln.

  if likp-vbeln is initial.
    message e668.
*    Keinen Eintrag zur Auswahl gefunden
  endif.

endform.                               " ERMITTELN_BELEG_MC
*##ngr-end
*---------------------------------------------------------------------*
*       FORM EINGABE_GEWICHT_PRUEFEN_NEU                              *
*---------------------------------------------------------------------*
*       Prüfung :  Nettogewicht kleiner als Bruttogewicht?            *
*                  Gewichtseinheit muss vorhanden sein und            *
*                  zulässige Dimension haben                          *
*                  Umrechung des Nettogewichts in neue Einheit,       *
*                  falls Einheit manuell geändert wurde               *
*---------------------------------------------------------------------*
form eingabe_gewicht_pruefen_neu using     if_btgew like likp-btgew
                                           if_gewei_old like likp-gewei
                                           if_gewei_new like likp-gewei
                                 changing  cf_ntgew like likp-ntgew.

  data: lf_ntgew like likp-ntgew,
        lf_check_gewei like likp-gewei.


  if if_gewei_new eq space  and
     ( if_btgew ne space   or
       cf_ntgew ne space ).
    message e057.
  endif.

  if if_gewei_new ne space.
    call function 'DIMENSIONCHECK_MASS'
      exporting
        gewei               = if_gewei_new
      exceptions
        dimension_not_mass  = 01
        t006d_entry_missing = 02
        t006_entry_missing  = 03.
    if sy-subrc ne 0.
      message e077 with if_gewei_new.
    endif.
  endif.

* On detail screens where both net weight and gross weight can be
* maintained no weight conversion is performed
  if   sy-dynnr eq '0300'
    or sy-dynnr eq '0370'
    or sy-dynnr eq '0380'
    or sy-dynnr gt '2000'.
    if if_btgew lt cf_ntgew.
      message e056.
    else.
*     Store last value of weight unit for return to overview screen
      gf_save_gewei = if_gewei_new.
    endif.
    r185d-dataloss = charx.
    exit.
  endif.

* Check whether weight unit has been changed for the second time
  if gf_save_gewei ne space.
    lf_check_gewei = gf_save_gewei.
  else.
    lf_check_gewei = if_gewei_old.
  endif.

  if     lf_check_gewei ne if_gewei_new
     and lf_check_gewei ne space.
    call function 'UNIT_CONVERSION_SIMPLE'
      exporting
        input                = cf_ntgew
        unit_in              = lf_check_gewei
        unit_out             = if_gewei_new
      importing
        output               = lf_ntgew
      exceptions
        conversion_not_found = 1
        division_by_zero     = 2
        input_invalid        = 3
        output_invalid       = 4
        overflow             = 5
        type_invalid         = 6
        units_missing        = 7
        unit_in_not_found    = 8
        unit_out_not_found   = 9
        others               = 10.
    if sy-subrc ne 0.
      message e058 with lf_check_gewei if_gewei_new.
    else.
      cf_ntgew = lf_ntgew.
    endif.
  endif.

* Store last value of weight unit
  gf_save_gewei = if_gewei_new.

* Send warning message if weight is changed the first time in creation
* mode (LO): user should check net weight on detail screen
* It does not make sense to send message VL056 here
  if     t180-trtyp eq charh
     and if_gewei_old eq space
     and gf_save_gewei eq space.
    message s249.
  elseif if_btgew lt cf_ntgew.
    message e056.
  endif.

  r185d-dataloss = charx.

endform.                    "eingabe_gewicht_pruefen_neu
*&---------------------------------------------------------------------*
*&      Form  export_data_redetermine   "HP_320996
*&---------------------------------------------------------------------*
*       Redetermine export data of the complete delivery in case of
*       changes of the ship-to address
*----------------------------------------------------------------------*
form export_data_redetermine.

  data: ls_save_lips   like lips,
        ls_save_mtcom  like mtcom,
        ls_save_*mtcom like mtcom,
        ls_save_maepv  like maepv,
        ls_save_mt06e  like mt06e,
        ls_save_mchar  like mchar,
        ls_save_t001w  like t001w,
        lf_subrc       like sy-subrc.

  field-symbols: <ls_xlips> like line of xlips.

  perform likp_export_bestimmen(sapfv50k).

  check not likp-expkz is initial.

* Save current item work areas since update routine may be called during
* item processing
  ls_save_lips   = lips.
  ls_save_t001w  = t001w.

  perform material_work_area_save(sapfv50p) changing ls_save_mtcom
                                                     ls_save_*mtcom
                                                     ls_save_maepv
                                                     ls_save_mt06e
                                                     ls_save_mchar.

  loop at xlips assigning <ls_xlips>
                where updkz ne updkz_delete.
    move-corresponding <ls_xlips> to lips.
    perform t001w_select(sapmv50a) using lips-werks
                                         charx
                                         lf_subrc.
    if not lips-matnr is initial.
      perform maepv_select(sapfv50p) using lips-matnr
                                           lips-werks
                                           lips-lgort
                                           lips-berid         "n_987304
                                           charx
                                           space
                                           lf_subrc.
      if not lips-charg is initial
         and lips-sobkz na 'OVW'.       "not for special stocks
        perform mchar_select(sapfv50p) using lips-matnr
                                             lips-werks
                                             lips-lgort
                                             lips-charg
                                             lips-sobkz
                                             lips-eprio
                                             lips-rules
                                             lips-kzbef
                                             lf_subrc.
      endif.
    endif.
    perform lips_referenz_lesen(sapfv50p).
    perform lips_fuellen_export(sapfv50p).
  endloop.

* Restore current work areas
  lips   = ls_save_lips.
  t001w  = ls_save_t001w.

  perform material_work_area_restore(sapfv50p) using ls_save_mtcom
                                                     ls_save_*mtcom
                                                     ls_save_maepv
                                                     ls_save_mt06e
                                                     ls_save_mchar.

endform.                    " export_data_redetermine
*&---------------------------------------------------------------------*
*&      Form  exit_from_batch_input (n_606793)
*&---------------------------------------------------------------------*
form exit_from_batch_input.

  check sy-binpt ne space.
* Show error messages in the log as information messages in the log of
* the BI session
  loop at cvbfs.
    message id     cvbfs-msgid
            type   'I'
            number cvbfs-msgno
            with   cvbfs-msgv1
                   cvbfs-msgv2
                   cvbfs-msgv3
                   cvbfs-msgv4.
  endloop.
* Terminate with error message
  message e461.

endform.                    " exit_from_batch_input