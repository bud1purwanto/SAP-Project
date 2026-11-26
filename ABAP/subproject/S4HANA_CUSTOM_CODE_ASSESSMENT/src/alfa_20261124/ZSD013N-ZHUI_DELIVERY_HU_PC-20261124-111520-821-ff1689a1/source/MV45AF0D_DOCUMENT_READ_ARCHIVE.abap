*----------------------------------------------------------------------*
***INCLUDE MV45AF0D_DOCUMENT_READ_ARCHIVE .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DOCUMENT_READ_ARCHIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form document_read_archive
     tables xkomv
     changing data_read_from_archive.

  data: xkonv like konv occurs 0 with header line,
        i_xvbup like vbup occurs 0 with header line,
        xjest like jest occurs 0 with header line,
        xjsto like jsto occurs 0 with header line,
        da_xvbep like vbep occurs 0 with header line,
        da_xvbap like vbap occurs 0 with header line,
        da_xvbak like vbak occurs 0 with header line,
        da_xvbpa like vbpa occurs 0 with header line,
        lvs_vbpa   type   vbpa,
        no_master_adress type xflag.
  data: i_xvbpa type vbpavb occurs 0 with header line.
  data: i_xvbadr type sadrvb occurs 0.
  data: l_vbpa type vbpavb occurs 0 with header line.
  data: da_actvt(2),
        bl_error.
  data: sd_swu_active type c.
  data: only_extern type xfeld.
  data: l_sd_sales_exit   type ref to if_ex_badi_sd_sales,
          active type xfeld.
  data: stxb like stxb occurs 0,
        stxh like stxh occurs 0,
        stxl like stxl occurs 0.
  data: da_addr1_val type addr1_val occurs 0 with header line.

  data: lt_s073 type standard table of s073.

  data: lv_read_archive      type boole.
  data: lv_quotation_archive type boole.
  data: lv_contract_archive  type boole.
  data: lv_sched_agr_archive type boole.

* not found on db - search in archive          "archive
  data: i_borident like borident.
  i_borident = vbak-vbeln.

  if not gv_vbak_special_archiving is initial.
* Range of Date for archive search
    write gv_erdat_sel to i_borident+10.
  endif.

* Payment Service Provider
  data: lt_paysphl type tdt_paysp_hl,
        lt_lpaysp_arch type tdt_paysp_hl.

* Decide if data shall be read from archive
  if t180-trtyp = 'A'.          " Read data from archive in DISPLAY transaction type

    lv_read_archive = charx.

  elseif t180-trtyp = 'H'.      " Specific case in ADD transaction type

    if cl_ops_switch_check=>ops_sfws_sc_advret1( ) is not initial.
      " Read data from archive in ADD transaction type and
      " if switch cl_ops_switch_check=>ops_sfws_sc_advret1 is set

      lv_read_archive = charx.

    endif.

  endif.


* make sure that archive is read for display-purposes only
*  IF t180-trtyp = 'A'.
  if lv_read_archive is not initial.
    data_read_from_archive_handle = 999.
* now the data are read from archive
    call function 'ASH_SD_VBAK_READ'
      exporting
        i_borident             = i_borident
      tables
        et_vbak                = da_xvbak
        et_vbfa                = xvbfa
        et_vbap                = da_xvbap
        et_vbuk                = xvbuk
        et_konv                = xkonv
        et_vbep                = da_xvbep
        et_vbkd                = xvbkd
        et_veda                = xveda
        et_vbpa                = xvbpa
        et_vbup                = xvbup
        et_nast                = xnast
        et_jest                = xjest
        et_jsto                = xjsto
        et_fpla                = xfpla
        et_fplt                = xfplt
        et_addr1_val           = da_addr1_val
        et_paysp_hl            = lt_paysphl
        et_xvblb               = xvblb
        et_xvbeh               = xvbeh
        et_xvbsn               = xvbsn
        et_vbkfz               = xvbkfz
        et_xs073               = lt_s073
      changing
        c_handle               = data_read_from_archive_handle
      exceptions
        not_in_infostructure   = 1
        not_in_archive         = 2
        no_instructure_defined = 3
        others                 = 4.


* not found in archive -> error message
    if sy-subrc <> 0.
      clear data_read_from_archive_handle.
      message e302 with vbak-vbeln.
    endif.

* Begin of processing
    read table da_xvbak index 1.
    move da_xvbak to vbak.
     *vbak = vbak.
    yvbak = vbak.

    svbak-tabix = 1.
    xvbak_updkz = updkz_old.

    if vbak-vbtyp                          eq vbtyp_ange and
       cl_ops_switch_check=>sd_sfws_sc3( ) eq abap_true.
      lv_quotation_archive = abap_true.
    endif.

    if ( vbak-vbtyp                        eq vbtyp_kont  or
         vbak-vbtyp                        eq vbtyp_gruko    ) and
       cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
      lv_contract_archive = abap_true.
    endif.

    if vbak-vbtyp                          ca vbtyp_lp  and
       cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true.
      lv_sched_agr_archive = abap_true.
    endif.

* Only archived sales documents (VA03, VA23, VA33, VA43)
    if vbak-vbtyp           ne vbtyp_auftr and
       vbak-vbtyp           ne vbtyp_reto and
       vbak-vbtyp           ne vbtyp_ganf and
       vbak-vbtyp           ne vbtyp_lanf and
       vbak-vbtyp           ne vbtyp_kl   and
       lv_quotation_archive ne abap_true  and
       lv_contract_archive  ne abap_true  and
       lv_sched_agr_archive ne abap_true.
      message e302 with vbak-vbeln.
    endif.

* checking authorizations (exclusive copying)
    if tvcpa-auarv eq space and tvcpa-auarn eq space.
      perform berechtigung_pruefen using    da_actvt
                                              vbak-auart
                                              space
                                     changing sy-subrc.

    endif.

* Steuerungstabellen zum Belegkopf lesen.
    perform tvak_select using   vbak-auart
                                bl_error
                                sy-subrc.


    perform tvakt_select using  vbak-auart
                                 bl_error
                                 sy-subrc.

* Paßt Transaktion zur Auftragsart ?
    perform tvak-trvog_pruefen using vbak-trvog
                                     t180-trvog.
    perform vbak-vbeln_set_parameter(sapfv45k).


* Steuerungstabellen zum Belegkopf lesen.
* Verkaufsorganisation lesen
    perform tvko_select using vbak-vkorg
                              bl_error
                              sy-subrc.
* Vertriebsweg lesen
    perform tvtw_select using  vbak-vtweg
                                bl_error
                                sy-subrc.
* Sparte lesen
    perform tspa_select using   vbak-spart
                                bl_error
                                sy-subrc.
* Verkaufsbüro lesen
    perform tvbur_select using  vbak-vkbur
                                bl_error
                                sy-subrc.
* Verkäufergruppe lesen
    perform tvkgr_select using  vbak-vkgrp
                                bl_error
                                sy-subrc.
* Vertriebsbereich lesen
    perform tvta_select using  vbak-vkorg
                               vbak-vtweg
                               vbak-spart.

* CO-Status
    call function 'STATUS_BUFFER_FILL_EXT'
      tables
        jest_imp = xjest[]
        jsto_imp = xjsto[].

* Default-Umfang setzen
    perform uebersicht_ansteuern(sapfv45p).

* preparation xvbap
    loop at da_xvbap.
      move da_xvbap to vbap.
      perform xvbap_aufbauen(sapfv45p).
    endloop.

    perform uvbap_aufbauen(sapfv45s).
    clear: *vbep, vbap.
    xvbep_anzahl = 0.
    loop at da_xvbep.
      move da_xvbep to vbep.
      if vbap-posnr <> vbep-posnr.
        if not vbap-posnr is initial and
         xvbep-posnr = vbap-posnr.
          perform xvbap_aendern(sapfv45p).
        endif.
        xvbep_anzahl = 0.
        perform xvbap_lesen_allgemein(sapfv45p) using vbep-posnr
                                                      space
                                                      svbap-tabix.

        perform vbap_bearbeiten_vorbereiten(sapfv45p).
      endif.
      if svbap-tabix = 0.
        message a427.
      else.
        perform xvbep_aufbauen(sapfv45e).
      endif.
    endloop.
    if not vbap-posnr is initial and
      da_xvbep-posnr = vbap-posnr.
      perform xvbap_aendern(sapfv45p).
    endif.
    free da_xvbep.

* Partner
    data: cnt_aa like vbpa2-cntpa.
    data: cnt_aw like vbpa2-cntpa.
    data: ind_aw like sy-index.
    data: ind_aa like sy-index.
    data: tabix like sy-tabix.

    loop at xvbpa.
      append xvbpa to l_vbpa.
    endloop.

    loop at l_vbpa into vbpa.

      clear i_xvbpa.
      move-corresponding vbpa to i_xvbpa.
      vtcom-parvw = vbpa-parvw.
      vtcom-kunnr = vbpa-kunnr.
      vtcom-lifnr = vbpa-lifnr.
      vtcom-parnr = vbpa-parnr.
      vtcom-pernr = vbpa-pernr.
      vtcom-adrnr = vbpa-adrnr.
      vtcom-adrnp = vbpa-adrnp.
      vtcom-adrda = vbpa-adrda.
      vtcom-ablad = vbpa-ablad.
      clear kupav.
      vtcom-msgkz = 'U'.
      call function 'VIEW_KUPAV'
        exporting
          comwa   = vtcom
        importing
          pawa    = kupav
          tpar_wa = tpar.
      vtcom-msgkz = ' '.
      i_xvbpa-name1 = kupav-name_list.     "P30K132589/31H
      i_xvbpa-lzone = kupav-lzone.
      i_xvbpa-fehgr = tpar-fehgr.
      i_xvbpa-nrart = tpar-nrart.
      l_vbpa-nrart  = tpar-nrart.
      i_xvbpa-spras = kupav-spras.
      i_xvbpa-telfx = kupav-telfx.
      i_xvbpa-teltx = kupav-teltx.
      i_xvbpa-telx1 = kupav-telx1.
      if i_xvbpa-land1 is initial and
         i_xvbpa-adrda co ' ADG'.
        i_xvbpa-land1 = kupav-land1.
      endif.

* if CAM is activated and there is a partner (but not an employee)
      if not zav_flag        is   initial        and
             i_xvbpa-adrnr   is   initial.
*   complete VBPA record with address data
        move-corresponding i_xvbpa to lvs_vbpa.
        call function 'SD_VBPA_RECORD_COMPLETE'
          changing
            frs_vbpa = lvs_vbpa.
        move-corresponding lvs_vbpa to i_xvbpa.
      endif.
* if CAM is activated and there is a partner (but not an employee)
      if not zav_flag        is   initial        and
             i_xvbpa-adrnr   is   initial.
*   complete VBPA record with address data
        move-corresponding i_xvbpa to lvs_vbpa.
        call function 'SD_VBPA_RECORD_COMPLETE'
          changing
            frs_vbpa = lvs_vbpa.
        move-corresponding lvs_vbpa to i_xvbpa.
      endif.

      read table xvbpa with key posnr = i_xvbpa-posnr
                                parvw = i_xvbpa-parvw.
      if sy-subrc = 0.
        move-corresponding i_xvbpa to xvbpa.
        modify xvbpa index sy-tabix.
      endif.

    endloop. "bezieht sich auf loop at l_vbpa.

* End of partner-processing -> routine of its own ?

* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
    call function 'SD_OBJECT_TYPE_DETERMINE'
      exporting
        i_document_type        = vbak-vbtyp
        i_tvak                 = tvak
      importing
        e_business_object      = businessobjekt
        e_business_object_item = businessobjekt_pos
      exceptions
        others                 = 0.
    if not call_function = 'X' and
       fcode ne 'IFLU' and
       not businessobjekt is initial.
      get parameter id 'SD_SWU_ACTIVE' field sd_swu_active.
      if not sd_swu_active is initial.
        call function 'SWU_OBJECT_PUBLISH'
          exporting
            objtype           = businessobjekt
            objkey            = vbak-vbeln
          exceptions
            objtype_not_found = 1
            others            = 2.
      endif.
    endif.

    if gwa_twpa is initial.
      select single * from twpa
            client specified
            into gwa_twpa
            where  mandt       = sy-mandt.
    endif.

* Ermitteln Verkaufshilfsmittel zu einem Beleg
    if not gwa_twpa-addis is initial.
      call function 'WTAD_ADDIS_IN_SO_READ_FROM_DB'
        exporting
          fi_vbak = vbak.
    endif.

* alle Partner zum Beleg lesen -> neue Routine ?
* Auftraggeber lesen
    loop at xvbpa.

      perform kuagv_select_xvbpa.
      perform t683v_select(sapmv45a) using tvak-kalvg
                                           kuagv-kalks
                                           space
                                           sy-subrc.
* Warenempfänger lesen
      perform kuwe2_select_xvbpa.
* Regulierer lesen
      perform kurgv_select_xvbpa.
      check fcode ne 'IFLU'.

    endloop.

* manual address
    data: da_sd_address_handle type adrnr,
          da_address_data type addr1_data,
          da_address_handle like szad_field-handle.
    data: da_vbadr type vbadr.
    loop at da_addr1_val.
      call function 'SD_ADDRESS_HANDLE_GET'
        importing
          fef_adrnr           = da_sd_address_handle
        exceptions
          no_handle_available = 1
          others              = 2.
      if sy-subrc = 0.
        da_address_handle = da_sd_address_handle.
        move-corresponding da_addr1_val to da_address_data.
        call function 'ADDR_INSERT'
          exporting
            address_data    = da_address_data
            address_group   = 'SD01'
            address_handle  = da_address_handle
          exceptions
            address_exists  = 1
            parameter_error = 2
            internal_error  = 3
            others          = 4.
        if sy-subrc <> 0.
        else.
          loop at xvbpa where adrnr = da_addr1_val-addrnumber.
            xvbpa-adrnr = da_address_handle.
            modify xvbpa.
            loop at xvbadr where adrnr = da_addr1_val-addrnumber.
              xvbadr-adrnr = da_address_handle.
              modify xvbadr.
            endloop.
*           Fill XVBADR for AG and WE for screen SAPMV45A4701
            if sy-subrc <> 0.
*             Entry already exists with HANDLE?
              loop at xvbadr where adrnr = da_address_handle.
              endloop.
              if sy-subrc <> 0 and
                 ( xvbpa-parvw = 'AG' or
                   xvbpa-parvw = 'WE' ).
                call function 'SD_ADDRESS_GET'
                  exporting
*                   FIF_ADDRESS_NUMBER      =
*                   FIF_PERSONAL_NUMBER     =
                    fif_address_handle      = da_address_handle
*                   FIF_ADDRESS_TYPE        =
                    fif_address_indicator   = xvbpa-adrda
*                   FIF_READ_SADR_ONLY      = ' '
                    fif_reload_entry        = 'X'
*                   FIF_LANGU               = SY-LANGU
                  importing
                    fes_address             = da_vbadr
*                   FES_SDPARTNER_ADDRESS   =
                  exceptions
                    address_not_found       = 1
                    address_type_not_exists = 2
                    no_person_number        = 3
                    others                  = 4.
                if sy-subrc <> 0.
                else.
                  move-corresponding da_vbadr to xvbadr.
                  xvbadr-adrnr = da_address_handle.
                  append xvbadr.
                endif.
              endif.
            endif.
          endloop.
        endif.
      endif.
    endloop.

* Prepare Conditions
    perform preisfindung_vorbereiten(sapfv45p) using 'K'.
    call function 'RV_KONV_SELECT'
      exporting
        comm_head_i           = tkomk
        read_condition_record = 'X'
      importing
        comm_head_e           = tkomk
      tables
        tkomv                 = xkomv.
    modify tkomk index tkomk-ix_komk.
    konv_gelesen = charx.

    perform material_vorstep_aenderung(sapfv45p).

* TVAK an SAPLV45W übergeben (z.B. für Feldauswahl)
    call function 'SD_VEDA_SET_DATA'
      exporting
        i_tvak = tvak.
* Transfer of contract data from archive into (SAPLV45W)XVEDA
    if not tvak-vterl is initial.
      move vbak-vbeln to vedavb-vbeln.
      clear vedavb-vposn.
      call function 'SD_XVEDA_REFRESH'.
      call function 'SD_VEDA_PUT_DATA'
        exporting
          i_document_number = vedavb-vbeln
          i_position_number = vedavb-vposn
          i_vbak            = vbak
          i_tvak            = tvak
        tables
          it_xveda          = xveda[].
    endif.

    ivbap_tabix_zeile_1 = 1.

* Belegstatus zum Auftrag lesen

    vbukkey-mandt = vbak-mandt.
    vbukkey-vbeln = vbak-vbeln.
    read table xvbup with key vbukkey.

*   Push VBAK to V45I
    call function 'SD_PUSH_ITEM'
      exporting
        i_vbak = vbak.

*   Push VBLB, VBEH, S073 to SAPLV45L
    call function 'SD_PUSH_AGR'
      exporting
        iv_vbeln  = vbak-vbeln
      tables
        it_xvblb  = xvblb
        it_xvbeh  = xvbeh
        it_xvbkfz = xvbkfz
        it_xs073  = lt_s073.

*   Push VBSN to SAPFV45L for index table creation
    if not xvbsn[] is initial.
      perform create_ivbsn_archive
              in program sapfv45l
              tables xvbsn.
    endif.

* kumulierten Belegfluß aufbauen
    call function 'RV_XVBAPF_CREATE'
      exporting
        vbeln   = vbak-vbeln
        i_vbak  = vbak
      tables
        fxvbfa  = xvbfa
        fxvbapf = xvbapf.

    if modification_flag-no_output_control is initial.
* Fuellen Key fuer Nachrichtenstatus
      move vbak-vbeln to xobjky.
      move vbak-vbeln to xobjky_to.
      move '999999'   to xobjky_to+10.
* Nachrichten lesen
      call function 'RV_MESSAGES_READ'
        exporting
          msg_kappl    = tvak-kappl
          msg_objky    = xobjky
          msg_objky_to = xobjky_to.
    endif.

* Gelesene Tabellen bereits in Funktionsgruppe V45I puffern
    call function 'SD_PUSH_ITEM'
      tables
        i_xvbap = xvbap[]
        i_xvbup = xvbup[]
        i_xvbep = xvbep[]
        i_xvbkd = xvbkd[].

* Restliche Tabelleneinträge mitgeben fürs Dynpro
    append lines of xkonv to xkomv.

    message s302 with vbak-vbeln.

  else.
    message e302 with vbak-vbeln.
  endif.

* Payment service provider
  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true
    and lt_paysphl is not initial.
* Get reference to class
    if not gr_paysp is bound.
      gr_paysp = cl_sls_paysp_integration=>get_instance( ).
    endif.
* Trigger archived PSP data into buffer
    call method gr_paysp->get_arch_data
      exporting
        iv_document_id = vbak-vbeln
        it_paysp_hl    = lt_paysphl.
  endif.

endform.                    " DOCUMENT_READ_ARCHIVE