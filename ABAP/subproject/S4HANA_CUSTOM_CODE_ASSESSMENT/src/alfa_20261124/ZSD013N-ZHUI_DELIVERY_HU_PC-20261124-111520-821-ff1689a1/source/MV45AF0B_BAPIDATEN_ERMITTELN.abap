*&---------------------------------------------------------------------*
*&      Form  BAPIDATEN_ERMITTELN                                      *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
form bapidaten_ermitteln using us_check_proxy type C.

  type-pools v45i.

  data: func_name   type rs38l_fnam     value 'CRS_READ_CRMPAROLTP',
        lc_infofunc like tfdir-funcname value 'CRS_SALES_GET_INFO'.
  constants:
        fm_name_isu type rs38l_fnam value 'FKK_CONVERT_ACC_INTO_GUID'.

  data: lv_parval1          type char255,
        lv_tabix            type sy-tabix,
        lv_release_crm(3)   type c,
        lv_crm_connected    type c,
        lv_ndi_exits_active type c,
        lv_scenario_a       type c,
        lv_scenario_y       type c,
        lt_fmtab            like fmrfc    occurs 0 with header line.

  data: da_sales_view     like order_view,
        da_vbak_keytab    like sales_key  occurs 0 with header line.

  data: da_vbak       like vbak           occurs 0 with header line,
        da_vbak_old   like vbak           occurs 0 with header line,
        da_vbadr      like sadrvb         occurs 0 with header line,
        da_konh       like konh           occurs 0 with header line,
        da_konp       like konp           occurs 0 with header line,
        da_konm       like konm           occurs 0 with header line,
        da_konw       like konw           occurs 0 with header line,
        da_veda       like vedavb         occurs 0 with header line,
        da_thead      like theadvb        occurs 0 with header line,
        da_tline      like bapitextli     occurs 0 with header line,
        da_vbfa       type v45i_vbfa_tabl          with header line,
        da_vbfa_old   type v45i_vbfa_tabl          with header line,
        da_curef      like bapicurefm     occurs 0 with header line,
        da_cucfg      like bapicucfgm     occurs 0 with header line,
        da_cuins      like bapicuinsm     occurs 0 with header line,
        da_cuprt      like bapicuprtm     occurs 0 with header line,
        da_cuval      like bapicuvalm     occurs 0 with header line,
        da_cublb      like bapicublbm     occurs 0 with header line,
        da_cuvk       like bapicuvkm      occurs 0 with header line,
        da_fpla       like fplavb         occurs 0 with header line,
        da_fplt       like fpltvb         occurs 0 with header line,
        da_xvbap      like vbapvb         occurs 0 with header line,
        da_xvbap_main like vbapvb         occurs 0 with header line,
        da_xvbap_sub  like vbapvb         occurs 0 with header line,
        da_xvbep      like vbepvb         occurs 0 with header line,
        da_xvbpa      like vbpavb         occurs 0 with header line,
        da_xvbpa2     like vbpavb         occurs 0 with header line,
        da_xvbkd      like vbkdvb         occurs 0 with header line,
        da_xvbuk      like vbukvb         occurs 0 with header line,
        da_xvbup      like vbupvb         occurs 0 with header line,
        da_yvbuk      like vbukvb         occurs 0 with header line,
        da_yvbup      like vbupvb         occurs 0 with header line,
        da_xvbfa      like vbfa           occurs 0 with header line,
        da_xvbuv      like vbuvvb         occurs 0 with header line,
        da_xkomv      like komv           occurs 0 with header line,
        lt_ykonv      like konv           occurs 0 with header line,
        da_csltok     type table of bapicsltok     with header line,
        da_fldchg     type table of bapifldchg     with header line.

  data: ls_vbak       like vbak,
        ls_csltok     type bapicsltok,
        ls_xvbkd      like vbkdvb.

*-------Event 501014 aktiviert
  data: da_download_active(1) type c.

*-------Anzahl Einträge in VBFA
  data: lv_tabix_vbfa         like sy-tabix.

*-------CRM Beleg wird zum ersten Mal im R/3 geändert
  data: lv_first(1)           type c,
        lv_par1(255)          type c.
*-------Daten sollen zurück ins CRM gesendet werden
  data: lv_data_send(1)       type c,
        lv_authorization(1)   type c.

*-------Kennzeichen, dass Vorgängerbeleg ein Kontrakt ist
  data: lv_kontrakt(1)        type c.

*-------Flag, that we are coming from the PROXY-BAPI
  data: lv_proxy              type c,
        lv_infofunc_exist     type c.

*-------Sicherung VBKLA
  data: lv_vbkla              like vbak-vbkla.

*-------Dynamische Daten ermitteln
  data: lv_det_dyndat         type char1.

*-------Help table for XVBAP
  data: lt_xvbap_help like vbapvb occurs 0 with header line.

*-------Rettung Adressdaten
  data: lv_address            type sdpartner_address.
  field-symbols: <fs_vbadr> like sadrvb.

*-------Hilfszeiger für loop über da_xvbap
  field-symbols: <fs_vbap> like vbapvb.
*------Hilfszeiger für loop über xvbpa
  field-symbols: <fs_xvbpa> like vbpavb.

*-------Ist ein CRM angeschlossen ?
  data: da_crmrfcpar like crmrfcpar.

*-------Verschlüsselung Kreditkarten
  data: lv_secure_ccard_bin type ccardec_s_bin,
        lv_ccnum            type ccnum.

*-------VWPOS determination
  data: lt_xhvbap     type sorted table of vbapvb
                           with non-unique key vbeln uepos,
        ls_xvbap      type vbapvb,
        ls_xhvbap     type vbapvb,
        ls_vbap       type vbap,
        ls_hvbap      type vbap,
        lv_vwpos      type vwpos.

  if call_activity eq gc_activity_lord and
     not gf_no_init is initial.
    return.
  endif.

*-Prüfen, ob wir aus dem Proxy kommen
  call function 'FUNCTION_EXISTS'
         exporting
            funcname           = lc_infofunc
         exceptions
            function_not_exist = 1
            others             = 2.
  if sy-subrc = 0.
    lv_infofunc_exist = charx.
      call function lc_infofunc    "#EC EXISTS
           importing
              e_send_together = lv_proxy.
  endif.

* If there are no changes in R/3:
* backanswer-BDOCs to CRM will be sent, but no download to CRM.
  if us_check_proxy = charx.
    if lv_infofunc_exist is initial.
      exit.
    else.
      if lv_proxy is initial.
        exit.
      endif.
    endif.
  endif.

*-Ermitteln ob Daten aus dem Kundenauftrag an eine Applikation
* versendet werden sollen
  call function 'BF_FUNCTIONS_FIND'
       exporting
            i_event       = '00501014'
       tables
            t_fmrfc       = lt_fmtab
       exceptions
            nothing_found = 1
            others        = 2.
  if sy-subrc = 0.
    da_download_active = charx.
  endif.

*-Verarbeitung wenn Download aktiv oder bei Ausführung eines BAPIs
  check: not da_download_active is initial or
         not call_bapi          is initial.

*-Füllen der Funktionsgruppe V60F mit den aktuellen Daten
  call function 'BILLING_SCHEDULE_PUSH_DATA'
       tables
            i_xfpla = xfpla
            i_xfplt = xfplt.

*-Ermitteln Anzahl Einträge VBFA
  describe table xvbfa lines lv_tabix_vbfa.

*-Daten aus globalen Tabellen übernehmen
  da_xvbap[] = xvbap[].
  da_xvbep[] = xvbep[].
  da_xvbuk[] = xvbuk[].
  da_xvbup[] = xvbup[].
  da_xvbpa[] = xvbpa[].
  da_xvbkd[] = xvbkd[].
  if lv_tabix_vbfa < 1000.
*---Bei mehr als 1000 Belegflussätzen, werden diese nicht in die
*   Puffer übernommen. Die da_Xvbfa wird gepuffert (für BAPIs), die
*   da_vbfa wird über den Prefetch gelesen und ans CRM übertragen.
    da_xvbfa[] = xvbfa[].
  endif.
  da_xkomv[] = xkomv[].
  da_xvbuv[] = xvbuv[].
*-Adressen werden direkt ans CRM übergeben und nicht über den
* Prefetch gelesen
  da_vbadr[] = xvbadr[].
*-Hausnummer und Strasse geradeziehen
  loop at xvbpa where adrda ca 'BCEF' and
                     updkz  ca 'IU'.
    read table da_vbadr assigning <fs_vbadr>
               with key xvbpa-adrnr.
    if sy-subrc = 0.
       CALL FUNCTION 'SD_ADDRESS_GET'
        EXPORTING
          FIF_ADDRESS_NUMBER            = <fs_vbadr>-adrnr
        IMPORTING
          FES_SDPARTNER_ADDRESS         = lv_address
        EXCEPTIONS
          ADDRESS_NOT_FOUND             = 1
          ADDRESS_TYPE_NOT_EXISTS       = 2
          NO_PERSON_NUMBER              = 3
          OTHERS                        = 4
                 .
       IF SY-SUBRC = 0.
          <fs_vbadr>-stras = lv_address-street.
          <fs_vbadr>-hausn = lv_address-house_num1.
          <fs_vbadr>-strs2 = lv_address-house_num1.
       ENDIF.
    endif.
  endloop.

*-Füllen Auftragskopf in Übergabetabelle nach hinten verlagert, da
* VBAK-VBKLA evtl. noch verändert wird
* ...
*-Füllen Belegfluss YVBFA, falls weniger als 1000 Sätze
  if not yvbfa[]   is initial and
     lv_tabix_vbfa <  1000.
    loop at yvbfa.
      move-corresponding yvbfa to da_vbfa_old.
      da_vbfa_old-origin_vbeln = vbak-vbeln.
      append da_vbfa_old.
    endloop.
  endif.
*-Feldänderungen übernehmen
  da_fldchg[] = gt_dynchg.

*-Und bei Neuanlage mit der Belegnummer füllen, da die BAPIs die
* Tabellen mit Belegnummer benötigen
  if xvbak_updkz = chari.
    loop at da_xvbap where vbeln eq ''.
      da_xvbap-vbeln = vbak-vbeln.
      modify da_xvbap.
    endloop.
    loop at da_xvbep where vbeln eq ''.
      da_xvbep-vbeln = vbak-vbeln.
      modify da_xvbep.
    endloop.
    loop at da_xvbpa where vbeln eq ''.
      da_xvbpa-vbeln = vbak-vbeln.
      modify da_xvbpa.
    endloop.
    loop at da_xvbkd where vbeln eq ''.
      da_xvbkd-vbeln = vbak-vbeln.
      modify da_xvbkd.
    endloop.
    loop at da_xvbuk where vbeln eq ''.
      da_xvbuk-vbeln = vbak-vbeln.
      modify da_xvbuk.
    endloop.
    loop at da_xvbup where vbeln eq ''.
      da_xvbup-vbeln = vbak-vbeln.
      modify da_xvbup.
    endloop.
    loop at da_xkomv where knumv eq ''.
      da_xkomv-knumv = vbak-knumv.
      modify da_xkomv.
    endloop.
    loop at da_xvbuv where vbeln eq ''.
      da_xvbuv-vbeln = vbak-vbeln.
      modify da_xvbuv.
    endloop.
    loop at da_fldchg where doc_number eq ''.
      da_fldchg-doc_number = vbak-vbeln.
      modify da_fldchg.
    endloop.
  endif.
*-Füllen der Funktionsgruppe V45I mit den aktuellen Daten
  call function 'SD_PUSH_ITEM'
       exporting
            i_vbak           = vbak
            i_buffer_refresh = charx
       tables
            i_xvbap          = da_xvbap
            i_xvbup          = da_xvbup
            i_xvbep          = da_xvbep
            i_xvbkd          = da_xvbkd
            i_xvbpa          = da_xvbpa
            i_xvbuk          = da_xvbuk
            i_xvbfa          = da_xvbfa
            i_xvbuv          = da_xvbuv.

*-Ab hier nur weiter, falls CRM angebunden ist. Dies kann nur über den
* Event 501014 abgefragt werden. Der Baustein ND_EXITS_ACTIVE_CHECK
* liefert auch TRUE zurück, falls ein PI-A aktiviert ist, welches
* nicht notwendigerweise die CRM Bausteine enthält. Weiterhin ist die
* weitere Ausführung der Form unnötig, falls kein CRM am R/3 hängt.
  check: not da_download_active is initial.

*-Folgenden Sonderfall prüfen: Kunde hat Event 00501014 aktiviert
* (eigene Funktion eingehängt), CRM ist allerdings nicht im Einsatz
  call function 'FUNCTION_EXISTS'
       exporting
            funcname           = func_name
       exceptions
            function_not_exist = 1
            others             = 2.
  check: sy-subrc = 0.

*-Szenario lesen
  call function 'CRM_GET_SCENARIO'
       exporting
           is_vbak        = vbak
           iv_updkz       = xvbak_updkz
       importing
           ev_scenario_a = lv_scenario_a
           ev_scenario_y = lv_scenario_y.

*-Beim Anlegen eines CRM Belegs im R/3 kann das Szenario Y gesetzt
* werden, mit welchem R/3 Daten zurück ins CRM gesendet werden
* können.
  if xvbak_updkz     =  updkz_new  and
     vbak-vbkla+3(1) >= '3'        and
     not call_bapi   is initial.
*---Scenario prüfen
    if lv_scenario_y = 'Y'.
      if vbak-vbkla+2(1) <> 'Z'.
*-------Szenario setzen
        vbak-vbkla+2(1) = lv_scenario_y.
      endif.
    elseif lv_scenario_y is initial.
*-----Szenario initial, nix machen
    else.
*-----Nicht unterstützt, Abbruch
      message a301(v3).
    endif.
  endif.

*-Szenario A prüfen
  if lv_scenario_a   = 'A'.
    vbak-vbkla+2(1) = lv_scenario_a.
  endif.

*-ermitteln CRM-Release
  call function func_name
        exporting
            i_paraname = 'CRM_RELEASE'
        importing
            e_parval1  = lv_parval1.
  lv_release_crm = lv_parval1+0(3).

* If lv_release_crm empty => X-message (correct download not possible)
  if da_download_active = charx.
    CALL FUNCTION 'CRM_CONNECTED'
     IMPORTING
       CRM_CONNECTED       = lv_crm_connected
     EXCEPTIONS
       NO_CRMRFCPAR        = 1
       OTHERS              = 2
              .
    IF sy-subrc = 0 and lv_release_crm = space and
       lv_crm_connected = charx.
        message x302(v3).
    ENDIF.
   endif.

*-Füllen der View für das Ermitteln der Auftragstabellen
  da_sales_view-partner    = charx.
  da_sales_view-sdcond     = charx.
  da_sales_view-sdcond_add = charx.
  da_sales_view-contract   = charx.
  da_sales_view-text       = charx.
*-bei mehr als 1000 Belegflusssätzen werden Daten nicht ermittelt
  if lv_tabix_vbfa < 1000.
    da_sales_view-flow     = charx.
  endif.
  da_sales_view-billplan   = charx.
  da_sales_view-configure  = charx.
  da_sales_view-credcard   = charx.

*-Im Standardszenario soll eine manuelle Änderung eines CRM Belegs
* (ab CRM Release 30A) nicht zurück ins CRM gesendet werden. Das
* gleiche gilt für maschinelle Änderungen (z.B. Neuterminierung)
*-Daten von 20B und 20C CRM Belegen müssen zurück übertragen werden
  if vbak-vbkla+3(1) = '2' and
    lv_release_crm(1) < '3'.
    lv_data_send = 'X'.
  endif.
  if not lv_proxy is initial.
    lv_data_send = 'X'.
  endif.
*-Szenario X wird in BELEG_LESEN gesetzt, falls CRM Beleg im R/3
* geändert werden soll. In diesem Fall findet eine Rückübertragung
* der R/3 Daten statt. Rückübertragung ebenso bei Y und Z.
  if vbak-vbkla+2(1) = 'X'  or
     vbak-vbkla+2(1) = 'Y'  or
     vbak-vbkla+2(1) = 'Z'  or
     vbak-vbkla+2(1) = 'S'  or
     vbak-vbkla+2(1) = 'A'.
    lv_data_send = 'X'.
  endif.
*-R/3 ATP aus CRM (neues Szenario im CRM 40) soll die Daten einer
* Neuterminierung aus dem R/3 ins CRM übertragen
  if vbak-vbkla+0(2) =  'CR'               and
     vbak-vbkla+3(1) >= '4'                and
     vbak-vbkla+6(1) =  'B'                and
     call_activity   =  activity_atp_area.
    lv_data_send = 'X'.
  endif.

*-Beleg wurde im R/3 angelegt ==> Daten senden
  if vbak-vbkla+2(1) = ' '.
    lv_data_send = 'X'.
  endif.

*-Re-Authorisierung überträgt bei einem CRM 50 System die Daten
* zurück ins CRM, auch wenn Szenario A nicht aktiviert ist
  if vbak-vbkla+0(2) =  'CR'               and
     vbak-vbkla+3(1) >= '5'                and
     lv_data_send    <> 'X'                and
     call_activity   =  activity_credit_authori.
    lv_authorization = 'X'.
    lv_data_send     = 'X'.
*---Nicht alle Daten müssen zurückübertragen werden
    clear: da_sales_view-partner,
           da_sales_view-sdcond,
           da_sales_view-sdcond_add,
           da_sales_view-contract,
           da_sales_view-text,
           da_sales_view-flow,
           da_sales_view-configure.
    refresh: da_xvbpa,
             da_xvbfa,
             da_xkomv,
             da_xvbuv,
             da_vbadr.
*---Info fürs CRM
    da_fldchg-doc_number = vbak-vbeln.
    da_fldchg-itm_number = '000000'.
    da_fldchg-bapi_struc = 'FLAG'.
    da_fldchg-bapi_field = 'AUTHORIZATION'.
    da_fldchg-control    = chara.
    append da_fldchg.
  endif.

*-Prüfen, ob Rückübertragung stattfinden soll
  check: lv_data_send = 'X'.

*-Füllen Auftragsnummer in Schlüsseltabelle des PREFETCH
  da_vbak_keytab-vbeln = vbak-vbeln.
  append da_vbak_keytab.

*-Für die Rückantwort in das CRM werden nicht alle Daten benötigt
* wenn der Ursprungsbeleg im CRM ab 30A angelegt wurde. Daten werden
* allerdings für Szenario X und Y noch benötigt.
*-Daten sollen auch bei Beleg, der im R/3 angelegt wurde versendet
* werden (VBKLA initial)
  if vbak-vbkla+2(1) = ' '  or
     vbak-vbkla+3(1) = '2'  or
     vbak-vbkla+2(1) = 'X'  or
     vbak-vbkla+2(1) = 'Y'  or
     vbak-vbkla+2(1) = 'Z'  or
     vbak-vbkla+2(1) = 'S'  or
     vbak-vbkla+2(1) = 'A'.

*---Bei Neuterminierung ist Ermittlung und Lesen von Konditionen,
*   Adressen usw. nicht notwendig
    if konv_geaendert =  space             and
       call_activity  =  activity_atp_area and
       call_function  <> space.
      clear da_sales_view-sdcond_add.
      clear da_sales_view-partner.
      clear da_sales_view-address.
      clear da_sales_view-text.
      clear da_sales_view-configure.
      clear da_sales_view-credcard.
* Bruttowert muss ermittelt werden, weil er sonst im
* CRM verloren geht
      da_sales_view-item = charx.
      lt_xvbap_help[] = da_xvbap[].
      lv_det_dyndat = charx.
    endif.

*---Userexit aufrufen, um zu ermittelnde Daten reduzieren zu können
    call function 'OPEN_FI_PERFORM_00511074_P'
         exporting
              iv_event      = 'FILTER_ORDER'
              iv_scenario   = vbak-vbkla+2(1)
              iv_updkz      = xvbak_updkz
              is_vbak       = vbak
         changing
              cs_sales_view = da_sales_view
         exceptions
              others        = 1.
*---Download only when salesview is filled.
    check: not da_sales_view is initial.

*---Ermittlen der Auftragsdaten
    lv_vbkla = vbak-vbkla.
    if vbak-vbtyp = 'G'.
       da_xvbpa2[] = da_xvbpa[].
    endif.
    call function 'SD_SALES_DOCUMENT_PREFETCH'
        exporting
             i_sales_view   = da_sales_view
             i_memory_read  = charb
             i_det_dyndat   = lv_det_dyndat
             i_download_crm = charx
        tables
             i_vbak_keytab = da_vbak_keytab
             fxvbap        = lt_xvbap_help
             fxvbpa        = da_xvbpa
*            fxsadr        = da_vbadr
             fxkomv        = da_xkomv
             fxkonh        = da_konh
             fxkonp        = da_konp
             fxkonm        = da_konm
             fxkonw        = da_konw
             fxveda        = da_veda
             fxthead       = da_thead
             fxtline       = da_tline
             fxvbfa        = da_vbfa
             fcuref        = da_curef
             fcucfg        = da_cucfg
             fcuins        = da_cuins
             fcuprt        = da_cuprt
             fcuval        = da_cuval
             fcublb        = da_cublb
             fcuvk         = da_cuvk
             fxfpla        = da_fpla
             fxfplt        = da_fplt.
    vbak-vbkla = lv_vbkla.
    if vbak-vbtyp = 'G'.
       da_xvbpa[] = da_xvbpa2[].
    endif.
    if da_sales_view-item = charx.
* in case of rescheduling update gross value
      loop at lt_xvbap_help into lt_xvbap_help
                            where not brtwr is initial.
        read table da_xvbap with key posnr = lt_xvbap_help-posnr
                                     transporting no fields.
        modify da_xvbap index sy-tabix from lt_xvbap_help
                                       transporting brtwr.
      endloop.
    endif.

  endif.

*-Nicht benötigte Daten bei Neuterminierung (R/3-ATP) löschen
  if vbak-vbkla+0(2) =  'CR'               and
     vbak-vbkla+3(1) >= '4'                and
     vbak-vbkla+6(1) =  'B'                and
     call_activity   =  activity_atp_area.
    refresh: da_xvbpa,
             da_xvbkd,
             da_xvbfa,
             da_xkomv,
             da_xvbuv,
             da_vbadr.
  endif.


*-Bei Sofortauftrag Daten aus SAPMV50A (über FuGr VAC1) holen
  call function 'SD_CRM_RUSHORDER_DATA_READ'
       tables
            da_xvbuk    = da_xvbuk
            yvbuk       = da_yvbuk
            da_xvbup    = da_xvbup
            yvbup       = da_yvbup
            da_vbfa     = da_vbfa
            da_vbfa_old = da_vbfa_old.
* Falls der Sofortauftrag nicht geänderte Belegflussdaten zu
* Vorgängerbelegen zurückliefert, diese hier löschen
  loop at da_vbfa where origin_vbeln <> vbak-vbeln.
    read table xvbfa with key vbelv = da_vbfa-vbelv
                              posnv = da_vbfa-posnv
                              vbeln = da_vbfa-vbeln
                              posnn = da_vbfa-posnn.
    if sy-subrc    = 0    and
       xvbfa-updkz = updkz_old.
      delete da_vbfa.
    endif.
  endloop.

  if vbak-vbkla+2(1) =  'X' and
     vbak-vbkla+3(1) >= '3'.
*---CRM Beleg im R/3 geändert
    if vbak-vbkla+2(1)  = 'X' and
       yvbak-vbkla+2(1) = 'M'.
*-----Kennzeichen setzen, dass "erste" Rückübertragung
      lv_first = charx.
*-----beim Löschen sind die Objektreferenenzen bereits gelöscht
*-----und damit kann die Belegguid nicht mehr ermittelt werden
*-----um den Status TRANSFERRING im CRM zu setzen
      if XVBAK_UPDKZ ne UPDKZ_DELETE.
*-----RFC ins CRM um Kopf-Status "transferring" zu setzen. Falls
*     dieser nicht gesetzt werden kann, kommt Abbruchmeldung.
       call function 'CRM_SET_STATUS_TRANSFER'
           exporting
               iv_vbeln  = vbak-vbeln
               iv_vbtyp  = vbak-vbtyp
           exceptions
               error     = 1.
       if sy-subrc <> 0.
        message a300(v3).
       endif.
      endif.
    endif.
  endif.

*-Szenario A prüfen: bei ersten Ändern eines CRM Belegs im R/3 alles
* senden - analog X
  if vbak-vbkla+2(1)  =  'A' and
     vbak-vbkla+3(1)  >= '4' and
     yvbak-vbkla+2(1) =  'M'.
    lv_first = 'X'.
  endif.

*-Füllen Auftragskopf in Übergabetabelle
  da_vbak = vbak.
  append da_vbak.
*-Füllen YVBAK in Übergabetabelle
  da_vbak_old = yvbak.
  append da_vbak_old.

*-Kopftext ID hinzufügen, um Aufrufversion des Events zu kennzeichen
  clear da_thead.
  da_thead-tdobject   = 'VBBK'.
  da_thead-tdname     = vbak-vbeln.
  da_thead-tdid       = 'ZYZY'.
  da_thead-tdform     = 'SYSTEM'.
  da_thead-tdlinesize = '002'.
  append da_thead.
*-XVBAP für Bapi anpassen
  loop at da_xvbap.
*---Position mit Lösch-Kennzeichen
    if da_xvbap-updkz = updkz_delete.
      read table yvbap with key vbeln = da_xvbap-vbeln
                                posnr = da_xvbap-posnr.
      if sy-subrc <> 0.
*-------Position wurde angelegt und wieder gelöscht ==> nix machen
        delete da_xvbap.
      else.
*-------Position war schon auf DB vorhanden
        if yvbap-updkz = updkz_delete.
          read table xvbap with key vbeln = da_xvbap-vbeln
                                    posnr = da_xvbap-posnr
                                    updkz = updkz_new
                           transporting no fields.
          if sy-subrc = 0.
*-----------Position wieder angelegt: Löschung nicht übertragen
            delete da_xvbap.
          endif.
        endif.
      endif.
    endif.
*---Position mit Insert-Kennzeichen
    if da_xvbap-updkz = updkz_new.
*-----Zuvor gelöschte Position wieder angelegt ==> Update
      read table yvbap with key vbeln = da_xvbap-vbeln
                                posnr = da_xvbap-posnr.
      if sy-subrc = 0.
        da_xvbap-updkz = updkz_update.
        modify da_xvbap.
      endif.
    endif.
  endloop.
*-XVBEP für Bapi anpassen (MW kommt mit D und I UPDKZ auf einer Position
* nicht zurecht.
  loop at da_xvbep.
*---Einteilung mit Lösch-Kennzeichen
    if da_xvbep-updkz = updkz_delete.
      read table yvbep with key vbeln = da_xvbep-vbeln
                                posnr = da_xvbep-posnr
                                etenr = da_xvbep-etenr.
      if sy-subrc <> 0.
*-------Einteilung wurde angelegt und wieder gelöscht ==> nix machen
        delete da_xvbep.
      else.
*-------Einteilung war schon auf DB vorhanden
        if yvbep-updkz = updkz_delete.
          read table xvbep with key vbeln = da_xvbep-vbeln
                                    posnr = da_xvbep-posnr
                                    etenr = da_xvbep-etenr
                                    updkz = updkz_new
                           transporting no fields.
          if sy-subrc = 0.
*-----------Einteilung wieder angelegt: Löschung nicht übertragen
            delete da_xvbep.
          endif.
        endif.
      endif.
    endif.
*---Einteilung mit Insert-Kennzeichen
    if da_xvbep-updkz = updkz_new.
*-----Zuvor gelöschte Einteilung wieder angelegt ==> Update
      read table yvbep with key vbeln = da_xvbep-vbeln
                                posnr = da_xvbep-posnr
                                etenr = da_xvbep-etenr.
      if sy-subrc = 0.
        da_xvbep-updkz = updkz_update.
        modify da_xvbep.
      endif.
    endif.
  endloop.

* changed item-XVBKD requires corresponding XVBAP.
  loop at da_xvbkd where updkz ne updkz_delete.
   read table da_xvbap with key vbeln = da_xvbkd-vbeln
                                posnr = da_xvbkd-posnr
                                updkz = updkz_old.
   if sy-subrc = 0.
    da_xvbap-updkz = updkz_update.
    modify da_xvbap index sy-tabix.
   endif.
  endloop.

  loop at da_xvbap assigning <fs_vbap>
                       where updkz = updkz_old and
                         not faksp is initial.
    <fs_vbap>-updkz = updkz_update.
  endloop.

  if lv_first is initial.
*For structured items send the whole structure if a node was updated.
*Get main-items.
    loop at da_xvbap where updkz ne updkz_old.
      ls_xvbap = da_xvbap.
      while not ls_xvbap-uepos is initial.
      read table da_xvbap into ls_xvbap with key posnr = ls_xvbap-uepos.
      endwhile.
      if ls_xvbap-updkz = updkz_old.
        ls_xvbap-updkz = updkz_update.
        modify da_xvbap from ls_xvbap index sy-tabix transporting updkz.
      endif.
      move-corresponding ls_xvbap to da_xvbap_main.
      append da_xvbap_main.
    endloop.
*Update sub-items.
    loop at da_xvbap_main.
      loop at uvbap where uepos = da_xvbap_main-posnr.
        read table da_xvbap with key posnr = uvbap-posnr.
        if da_xvbap-updkz = updkz_old.
          da_xvbap-updkz = updkz_update.
          modify da_xvbap index sy-tabix transporting updkz.
        endif.
      endloop.
    endloop.
  endif.

* special case bom explosion in R/3 and CRM
  loop at crm_bom_data_del.
    lv_tabix = sy-tabix.
    read table da_xvbap with key posnr = crm_bom_data_del-posnr
                                 updkz = updkz_new
                                 transporting no fields.
    if sy-subrc ne 0.
      da_xvbap-posnr = crm_bom_data_del-posnr.
      da_xvbap-matnr = crm_bom_data_del-matnr.
      da_xvbap-uepos = crm_bom_data_del-uepos.
      da_xvbap-updkz = updkz_delete.
      insert da_xvbap into table da_xvbap.
    endif.
    delete crm_bom_data_del index lv_tabix.
  endloop.

* special case rushorder: xvbap not changed but status was updated
  loop at da_xvbap where updkz eq updkz_old.
    read table da_xvbup with key posnr = da_xvbap-posnr
                                 updkz = updkz_update.
    if sy-subrc = 0.
      da_xvbap-updkz = updkz_update.
      modify da_xvbap transporting updkz.
    endif.
  endloop.

* Items should not be deleted, if they are rejected and if they
* are sent from CRM; otherwise they keep status 'to be distributed'
  loop at da_xvbap where updkz eq updkz_old.
    if not da_xvbap-abgru is initial and
       vbak-vbkla(2) = 'CR' and
       not call_bapi is initial.
      da_xvbap-updkz = updkz_update.
      modify da_xvbap transporting updkz.
    endif.
  endloop.

*-Einträge mit UPDKZ=SPACE löschen, da MW dies als INSERT interpretiert.
* Falls geänderter CRM Beleg (ab 30A) zum ersten Mal zurück übertragen
* wird, alle Positionen und Einteilungen übertragen
  if lv_first is initial.
    delete da_xvbap where updkz = updkz_old.
  endif.

*-Handling CRM
  if lv_release_crm+0(1) < '3'.
*---CRM Release 20B und 20C: Nur geänderte Einteilungen übertragen
    delete da_xvbep where updkz = updkz_old.
  else.
*---ab CRM Release 30 alle Einteilungen senden
    loop at da_xvbep where updkz = updkz_old.
      read table da_xvbap with key vbeln = da_xvbep-vbeln
                                   posnr = da_xvbep-posnr
                 transporting no fields.
      if sy-subrc <> 0.
        delete da_xvbep.
      endif.
    endloop.
  endif.


  do 1 times.

*---Nachfolgende Daten (Aufbereitung) nicht bei V_V2 (R3-ATP) benötigt
    if vbak-vbkla+0(2) =  'CR'               and
       vbak-vbkla+3(1) >= '4'                and
       vbak-vbkla+6(1) =  'B'                and
       call_activity   =  activity_atp_area.
      exit.
    endif.

*---Delete Adress Data, if they are Masta Data
    IF lv_release_crm+0(1) GE '3'.
      LOOP AT da_xvbpa WHERE adrda CA 'ADG'.
        DELETE da_vbadr WHERE adrnr = da_xvbpa-adrnr.
      ENDLOOP.
    ENDIF.

*---Check , if IS-U is active ?
    call function 'FUNCTION_EXISTS'
        exporting
          funcname           = fm_name_isu
        exceptions
          function_not_exist = 1
          others             = 2.
    if sy-subrc = 0.
*--- IS-U is active
       delete da_xvbpa where updkz = updkz_old and
                             parvw ne parvw_rg.

*--- If there's a payer already with updkz = U
*--- then delete the extra payer.
       read table da_xvbpa with key updkz = updkz_update
                                 parvw = parvw_rg.
       if sy-subrc = 0.
*--- Partner found delete old partner
         delete da_xvbpa where updkz = updkz_old and
                               parvw = parvw_rg.
       endif.

*--- If there's a payer already with updkz = I
*--- then delete the extra payer.
      read table da_xvbpa with key updkz = updkz_new
                                parvw = parvw_rg.
      if sy-subrc = 0.
*--- Partner found delete old partner
        delete da_xvbpa where updkz = updkz_old and
                              parvw = parvw_rg.
      endif.


       loop at da_xvbpa where updkz = updkz_old and
                              parvw = parvw_rg.
            da_xvbpa-updkz =  updkz_update.
            modify da_xvbpa.
       endloop.
    else.
*--- IS-U is not active
       delete da_xvbpa where updkz = updkz_old.
    endif.

*---Nicht geänderte Daten aus VBPA, VBKD und FPLA löschen. FPLA nicht
*   löschen, da unlimitierte Karte benötigt (ab CRM 5.0)
    if lv_release_crm+0(1) <= '4'.
      delete da_fpla  where updkz = updkz_old.
    endif.

*---manually changed adress in follow-up/copied document
 loop at xvbpa assigning <fs_xvbpa> where adrda ca 'BCEF' "manual adress
                                   and updkz ca 'I'. "partner inserted
   loop at da_vbadr assigning <fs_vbadr> where adrnr = <fs_xvbpa>-adrnr.
        <fs_vbadr>-updkz = updkz_update.
      endloop.
    endloop.
    delete da_vbadr where updkz = updkz_old.

*---Falls eine Position hinzugefügt wurde, den Kopf-VBKD-Satz
*   übertragen, auch falls keine Änderung stattgefunden hat
    read table da_xvbap with key vbeln = vbak-vbeln
                                 updkz = updkz_new.
    if sy-subrc = 0.
      delete da_xvbkd where updkz = updkz_old and
                            not posnr is initial.
    else.
*---Wenn sich ABRVW (CRM: USAGE_TYPE) geändert hat, muss Kopf-VBKD
*   geschickt werden
     if da_vbak-abrvw ne da_vbak_old-abrvw or
        da_vbak-kvgr1 ne da_vbak_old-kvgr1 or
        da_vbak-kvgr2 ne da_vbak_old-kvgr2 or
        da_vbak-kvgr3 ne da_vbak_old-kvgr3 or
        da_vbak-kvgr4 ne da_vbak_old-kvgr4 or
         da_vbak-kvgr5 ne da_vbak_old-kvgr5 or
         xvbak_updkz = charu.
      delete da_xvbkd where updkz = updkz_old and
                            not posnr is initial.
     else.
      delete da_xvbkd where updkz = updkz_old.
     endif.

    endif.

*---Gelöschte Partner sind leider nur in Y-Tab vorhanden, für MW noch in
*   X-Tab aufnehmen, ansonsten werden die Sätze nicht in CDB gelöscht
*---Nach Änderung des AG sind alle vorherigen Partner mit D in Y-Tab und
*   die neuen Partner mit I in X-Tab
    loop at yvbpa where updkz = updkz_delete.
      read table da_xvbpa with key vbeln = yvbpa-vbeln
                                   posnr = yvbpa-posnr
                                   kunnr = yvbpa-kunnr
                                   pernr = yvbpa-pernr
                                   parnr = yvbpa-parnr
                                   parvw = yvbpa-parvw.
      if sy-subrc <> 0.
        append yvbpa to da_xvbpa.
      endif.
    endloop.

*---Gelöschte Kreditkarten sind nur in Y-Tab vorhanden (nur ab CRM 5.0
*   relevant)
    if lv_release_crm+0(1) >= '5'.
      loop at yfplt where updkz = updkz_delete.
        read table da_fplt with key fplnr = yfplt-fplnr
                                    fpltr = yfplt-fpltr.
        if sy-subrc <> 0.
          append yfplt to da_fplt.
        endif.
      endloop.
    endif.

*---Bei kopierten Belegen ist der Vorgängerbeleg zusätzlich in der VBUK
*   und VBUP. VBAK und VBAP zu diesen Belegen nachlesen und mitübertrage
*   Ansonsten wird Status der referenzierten Belegen nicht aktualisiert.
*---Für Abrufe auf Kontrakte den Vorgängerbeleg bei CRM Release >= 30
*   den Kontrakt nicht mitübertragen
*---Ab CRM Release 40 keine Vorgänger übertragen
    if lv_release_crm+0(1) <= '3'.
      loop at da_xvbuk where vbeln <> vbak-vbeln and
                             updkz <> updkz_delete.
        call function 'SD_VBAK_SELECT'
          exporting
            i_document_number   = da_xvbuk-vbeln
          importing
            e_vbak              = ls_vbak
          exceptions
            document_not_found  = 1
            others              = 2.
        if sy-subrc <> 0.
          delete da_xvbuk.
        else.
          if ls_vbak-vbtyp       ca vbtyp_kont and
             lv_release_crm+0(1) >= '3'.
            lv_kontrakt = charx.
            delete da_xvbuk.
          else.
            append ls_vbak to da_vbak.
*-----------Falls Beleg gelöscht wird, die Vorgängerbelege kennzeichnen,
*           damit diese später nicht auch gelöscht werden.
*           UVGEK unused in SE11.
            if xvbak_updkz = updkz_delete.
              da_xvbuk-uvgek = 'X'.
              modify da_xvbuk.
            endif.
          endif.
        endif.
      endloop.
      loop at da_xvbup where vbeln <> vbak-vbeln and
                             updkz <> updkz_delete.
        read table vvbap with key vbeln = da_xvbup-vbeln
                                  posnr = da_xvbup-posnr
                         binary search.
        if sy-subrc    <> 0     or
           lv_kontrakt =  charx.
          delete da_xvbup.
        else.
          clear da_xvbap.
          da_xvbap = vvbap.
          da_xvbap-updkz = updkz_old.
          append da_xvbap.
        endif.
      endloop.
    else.
*-----Ab CRM Release 40: keine Vorgänger
      delete da_xvbuk where vbeln <> vbak-vbeln.
      delete da_xvbup where vbeln <> vbak-vbeln.
    endif.
*---Falls Sofortauftrag mit Referenz zu Beleg angelegt wird, zu dem
*   schon Folgebelege existieren, ist dieser Fluss in VBFA. Diesen hier
*   löschen ansonsten gibt es Probleme in MW (nur für 20B und 20C)
    if lv_release_crm+0(1) < '3'.
      delete da_vbfa  where vbeln <> vbak-vbeln.
    endif.

*---Da gelöschte Konditionen direkt aus der X-TAB gelöscht werden und
*   keine Y-TAB existiert, müssen die gelöschten Konditionen durch
*   Vergleich mit der DB wieder hergestellt werden. Die MW kommt in
*   Release 20C nicht mit dieser Logik zurecht.
    if not konv_geaendert      is initial and
       not t180-trtyp          =  'H'     and
       not lv_release_crm(1)   >= '3'.
*-----Zur Sicherheit nochmal sortieren
      sort da_xkomv.
*-----Konditionen des Belegs von DB lesen
      select * from  konv into table lt_ykonv
               where knumv = vbak-knumv.
*-----Alle "alten" Konditionen abarbeiten
      loop at lt_ykonv.
        read table da_xkomv with key knumv = lt_ykonv-knumv
                                     kposn = lt_ykonv-kposn
                                     stunr = lt_ykonv-stunr
                                     zaehk = lt_ykonv-zaehk
                            binary search.
        if sy-subrc <> 0.
*---------Kondition auf DB vorhanden, allerdings nicht mehr im Beleg
*         --> Löschsatz hinzufügen
          clear da_xkomv.
          da_xkomv = lt_ykonv.
          da_xkomv-updkz = updkz_delete.
          append da_xkomv.
        endif.
      endloop.
    endif.

  enddo.

*-Szenario A aktiv
  if lv_scenario_a = 'A'.

*---Ermitteln der CSL-Sperranforderung
    call function 'SD_CSLTOK_READ_FROM_BUFFER'
      tables
        it_vbak_keytab     = da_vbak_keytab
        et_csltok          = da_csltok
      exceptions
        csltok_not_found  = 1
        others            = 2.

*---Bei KMATs prüfen, ob KWMENG oder WERKS geändert
    loop at da_xvbap where updkz = updkz_update   and
                           uepos is initial       and
                           not cuobj is initial.
      read table yvbap with key posnr = da_xvbap-posnr.
      if sy-subrc = 0.
        if da_xvbap-kwmeng <> yvbap-kwmeng.
          clear da_fldchg.
          da_fldchg-doc_number = da_xvbap-vbeln.
          da_fldchg-itm_number = da_xvbap-posnr.
          da_fldchg-bapi_struc = 'VBAP'.
          da_fldchg-bapi_field = 'KWMENG'.
          da_fldchg-control    = chara.
          append da_fldchg.
        endif.
        if da_xvbap-werks <> yvbap-werks.
          clear da_fldchg.
          da_fldchg-doc_number = da_xvbap-vbeln.
          da_fldchg-itm_number = da_xvbap-posnr.
          da_fldchg-bapi_struc = 'VBAP'.
          da_fldchg-bapi_field = 'WERKS'.
          da_fldchg-control    = chara.
          append da_fldchg.
        endif.
      endif.
    endloop.

  endif.

*-Prüfen, ob Liefersperre auf Kopf gelöscht wurde
  if vbak-lifsk  =  space and
     yvbak-lifsk <> space.
    clear da_fldchg.
    da_fldchg-doc_number = vbak-vbeln.
    da_fldchg-itm_number = '000000'.
    da_fldchg-bapi_struc = 'VBAK'.
    da_fldchg-bapi_field = 'LIFSK'.
    da_fldchg-control    = chara.
    append da_fldchg.
*---Liefersperren auf ET-Ebene prüfen und Info ans CRM senden
    loop at xvbap where updkz <> updkz_delete.
      loop at xvbep where posnr =  xvbap-posnr and
                          updkz <> updkz_delete.
        if not xvbep-lifsp is initial.
          da_fldchg-doc_number = vbak-vbeln.
          da_fldchg-itm_number = xvbap-posnr.
          da_fldchg-bapi_struc = 'VBAP'.
          da_fldchg-bapi_field = 'LIFSP'.
          da_fldchg-control    = chara.
          append da_fldchg.
          exit.
        endif.
      endloop.
    endloop.
  endif.

* check if billing block was deleted on header
  if vbak-faksk  =  space and
     yvbak-faksk <> space.
    clear da_fldchg.
    da_fldchg-doc_number = vbak-vbeln.
    da_fldchg-itm_number = '000000'.
    da_fldchg-bapi_struc = 'VBAK'.
    da_fldchg-bapi_field = 'FAKSK'.
    da_fldchg-control    = chara.
    append da_fldchg.
  endif.

* Pricing date on header changed
* send all vbkd data that have different pricing date
  loop at da_fldchg
          where bapi_struc = 'VBAK' and
                bapi_field = 'PRSDT'.
    read table xvbkd into ls_xvbkd
                     with key vbeln = vbak-vbeln
                              posnr = '000000'.
    if sy-subrc is initial.
      loop at xvbkd where vbeln = vbak-vbeln and
                          not posnr is initial.
        if xvbkd-prsdt <> ls_xvbkd-prsdt.
          append da_xvbkd.
        endif.
      endloop.
      delete adjacent duplicates from da_xvbkd.
    endif.
  endloop.

*-Info fürs CRM, falls Änderung mittels VA02
  if call_activity is initial.
    da_fldchg-doc_number = vbak-vbeln.
    da_fldchg-itm_number = '000000'.
    da_fldchg-bapi_struc = 'FLAG'.
    da_fldchg-bapi_field = 'ONLINE_CHANGE'.
    da_fldchg-control    = chara.
    append da_fldchg.
  endif.

*-Kreditkartennummer entschlüsseln
  if lv_release_crm+0(1) >= '5'.
    loop at da_fplt where not ccard_guid is initial.
      call function 'CCARDEC_READ'
        exporting
          im_ccard_guid   = da_fplt-ccard_guid
        importing
          ex_ccard_bin    = lv_secure_ccard_bin
        exceptions
          entry_not_found = 1
          others          = 2.
      if sy-subrc <> 0.
        message x008(ccardec) with da_fplt-ccins.
      endif.
      call function 'CCARD_DEVELOPE'
        exporting
          im_ccard_bin    = lv_secure_ccard_bin
        importing
          ex_ccnum        = lv_ccnum
        exceptions
          develope_failed = 1
          others          = 2.
      if sy-subrc <> 0.
        message x008(ccardec) with da_fplt-ccins.
      endif.
*     Entschlüsselung in MAP_FPLTVB_TO_BAPICCARDM verhindern
      clear da_fplt-ccard_guid.
      da_fplt-ccnum = lv_ccnum.
      modify da_fplt transporting ccnum ccard_guid.
    endloop.
  endif.

* fill VWPOS in case the document was copied
  lt_xhvbap[] = da_xvbap[].
  loop at da_xvbap into ls_xvbap where not vgbel is initial.
*   Read main item
    if ls_xvbap-uepos is initial.
      clear ls_hvbap.
    else.
      read table lt_xhvbap into ls_xhvbap
                 with key vbeln = ls_xvbap-vbeln
                          posnr = ls_xvbap-uepos.
      if sy-subrc = 0.
        move-corresponding ls_xhvbap to ls_hvbap.
      endif.
    endif.
*   Call item type usage determination
    move-corresponding ls_xvbap to ls_vbap.
    call function 'SD_VBAP_VWPOS_GET'
      exporting
        vbak     = vbak
        vbap     = ls_vbap
        hvbap    = ls_hvbap
      importing
        p_vwpos  = lv_vwpos.
*   Update item
    if lv_vwpos <> ls_xvbap-vwpos.
      ls_xvbap-vwpos = lv_vwpos.
      modify da_xvbap from ls_xvbap transporting vwpos.
    endif.
  endloop.
* snend the data to CRM for ext. billing scenario in case of
* authorizition by any report or tr. code VCC1.
   if vbak-vbkla+2(1) = 'S' and
     call_activity = activity_credit_authori.
        clear: da_xkomv,
               da_vbadr,
               yvbadr,
               da_xvbap,
               yvbap,
               da_xvbep,
               yvbep,
               da_vbfa,
               da_vbfa_old,
               da_xvbkd,
               yvbkd,
               da_xvbpa,
               yvbpa,
               da_xvbuk,
               yvbuk,
               da_xvbup,
               yvbup,
               da_konh,
               da_konp,
               da_konm,
               da_konw,
               da_veda,
               da_thead,
               da_tline,
               da_curef,
               da_cucfg,
               da_cuins,
               da_cuprt,
               da_cuval,
               da_cublb,
               da_cuvk,
               da_csltok,
               da_fldchg.

    endif.


*-BADI aufrufen

*-Übergabe der Auftragsdaten an den Versendebaustein
  call function 'OPEN_FI_PERFORM_00501014_E'
       exporting
            i_operation = xvbak_updkz
       tables
            t_fmtab     = lt_fmtab
            t_vbak      = da_vbak
            t_vbak_old  = da_vbak_old
            t_komv      = da_xkomv
            t_sadr      = da_vbadr
            t_sadr_old  = yvbadr
            t_vbap      = da_xvbap
            t_vbap_old  = yvbap
            t_vbep      = da_xvbep
            t_vbep_old  = yvbep
            t_vbfa      = da_vbfa
            t_vbfa_old  = da_vbfa_old
            t_vbkd      = da_xvbkd
            t_vbkd_old  = yvbkd
            t_vbpa      = da_xvbpa
            t_vbpa_old  = yvbpa
            t_vbuk      = da_xvbuk
            t_vbuk_old  = yvbuk
            t_vbup      = da_xvbup
            t_vbup_old  = yvbup
            t_fpla      = da_fpla
            t_fpla_old  = yfpla
            t_fplt      = da_fplt
            t_fplt_old  = yfplt
            t_konh      = da_konh
            t_konp      = da_konp
            t_konm      = da_konm
            t_konw      = da_konw
            t_veda      = da_veda
            t_thead     = da_thead
            t_tline     = da_tline
            t_curef     = da_curef
            t_cucfg     = da_cucfg
            t_cuins     = da_cuins
            t_cuprt     = da_cuprt
            t_cuval     = da_cuval
            t_cublb     = da_cublb
            t_cuvk      = da_cuvk
            t_csltok    = da_csltok
            t_fldchg    = da_fldchg.

endform.