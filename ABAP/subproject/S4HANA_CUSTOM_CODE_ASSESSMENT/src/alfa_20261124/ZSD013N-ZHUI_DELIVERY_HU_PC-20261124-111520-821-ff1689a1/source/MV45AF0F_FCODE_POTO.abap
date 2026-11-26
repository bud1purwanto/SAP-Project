*---------------------------------------------------------------------*
*       FORM FCODE_POTO                                               *
*---------------------------------------------------------------------*
*       Pflege der Serialnummern auf Positionsebene                   *
*---------------------------------------------------------------------*
form fcode_poto using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

  data: xanzsn       like risa0-anzahl,
        da_xanzsn    like risa0-anzahl,
        xtrtyp       like t180-trtyp,
        da_vrgng     like tj01-vrgng,
        da_j_vorgang like tj01-vrgng,
        da_cuobj     like vbap-cuobj,
        da_stdpd     like maepv-stdpd,
        da_dataloss  like r185d-dataloss,
        lf_exit      type flag,
        da_material_only,
        da_vbeln     like vbap-vbeln.
  data: begin of xser02 occurs 5.
          include structure rserxx.
  data: end of xser02.
  data: da_riwol  like riwol  occurs 1 with header line.
  data: da_werks  like vbap-werks.                          "EHP603

  local: gf_serial_changed.

ENHANCEMENT-POINT FCODE_POTO_01 SPOTS ES_SAPMV45A STATIC.
ENHANCEMENT-POINT FCODE_POTO_02 SPOTS ES_SAPMV45A.
  if call_dialog = charx.
    message id 'V2' type 'I' number '156'.
    exit.
  endif.

* Basismenge auf Dezimalen prüfen
  xanzsn = vbap-kwmeng mod 1000.
  if xanzsn <> 0.
    message i535.
    clear xanzsn.
    exit.
  endif.

  perform serial_tobj_entscheid(sapfv45p)
    using    vbap tvap
    changing sy-subrc.
  if sy-subrc eq 0.
    da_vrgng = vrgng_sdau.             " Auftrag
    da_j_vorgang = vrgng_pms2.
ENHANCEMENT-POINT FCODE_POTO_03 SPOTS ES_SAPMV45A.
  else.
    da_vrgng = vrgng_sdw1.             " Kontrakt
    da_j_vorgang = vrgng_pms4.
  endif.

  if da_vrgng = vrgng_sdau and
     vbak-vbtyp na vbtyp_auft and
     tvap-eterl = space.
*   Anlegen Serialnummern nur für 'Auftragsartige' erlaubt
    message s285.
    exit.
  endif.

* Serialnummern koennen nur bei vorhandenem Werk angelegt werden
  if vbap-werks is initial and
     da_vrgng <> vrgng_sdw1.
    message i191.
    exit.
  endif.

  if vbap-serail is initial and
     da_vrgng <> vrgng_sdw1.
*   Zum ausgewaehlten Material gibt es kein Serialnummernprofil
    message i192 with vbap-matnr vbap-werks.
    exit.
  endif.

* Serialnummer darf nicht bei Vertragspositionen übergeben werden
  if da_vrgng = vrgng_sdw1.
    da_cuobj = space.
  else.
*   Kofigurationsnummer übergeben
    da_cuobj = xvbap-cuobj.

*   ... und Standardproduktnummer lesen und übergeben
    perform maepv_select(sapfv45p) using vbap-matnr
                                         vbap-werks
                                         vbap-berid
                                         vbap-lgort
                                         charx
                                         space
                                         sy-subrc.

    da_stdpd = maepv-stdpd.
  endif.

* Menge fuer die Anzahl der Serialnummern bestimmen
  xanzsn = vbap-kwmeng * vbap-umvkz / vbap-umvkn / 1000.

  xtrtyp = t180-trtyp.
* Referenzstatus pruefen
  if vbup-wbsta = charc.
    xtrtyp = chara.
  endif.
ENHANCEMENT-POINT FCODE_POTO_04 SPOTS ES_SAPMV45A.

* Workareas initialisieren
  perform vbap_bearbeiten_vorbereiten(sapfv45p).

* Material lesen, um zu prüfen, ob konfigurierbares Material vorliegt
  perform maapv_select(sapfv45p) using xvbap-matnr
                                       vbak-vkorg
                                       vbak-vtweg
                                       charx
                                       sy-subrc.

* Konfigurationskennzeichen, Bewertungsart und Charge
* machen nur bei auftragsartigen Belegen Sinn
  if da_vrgng = vrgng_sdau.

ENHANCEMENT-SECTION     FCODE_POTO_05 SPOTS ES_SAPMV45A.
    select single * from t134 where mtart = maapv-mtart.
    if t134-kzkfg = charx and
       xvbap-cuobj is initial.
      message i529.
    endif.
END-ENHANCEMENT-SECTION.

* wenn STDPD nicht sitzt muss das Feld aus Matnr gefuellt werden
    if da_stdpd is initial and
       not ( da_cuobj is initial ).
      da_stdpd = xvbap-matnr.
    endif.

* Serialnummer und Bewertungstyp prüfen
    if not vbap-xchar is initial.
      if vbap-charg is initial and
            vbap-bwtar is initial.
        message i626.
        exit.
      endif.
    endif.

* Serialnummer und Charge pruefen
    if maepv-xchpf <> space and
       vbap-charg is initial.
      message i608.
      exit.
    endif.
  endif.

* Kundennummer des Warenempfängers ermitteln
  perform xvbpa_lesen(sapfv45k) using 'WE'
                                      xvbap-posnr
                                      xvbpa_aktind.

* Falls Anzahl Serialnummern > Menge, Zahl der Serialnummern übergeben
  if xvbap-anzsn > xanzsn.
    da_xanzsn = xvbap-anzsn.
  else.
    da_xanzsn = xanzsn.
  endif.

* Falls noch keine Belegnummer vergeben wurde, immer mit '$' arbeiten
  if xvbap-vbeln is initial.
    if da_vrgng = vrgng_sdau.
      da_vbeln = char$.
    else.
      clear da_vbeln.
    endif.
  else.
    da_vbeln = xvbap-vbeln.
  endif.

ENHANCEMENT-POINT FCODE_POTO_06 SPOTS ES_SAPMV45A.
  if da_vrgng eq vrgng_sdau.
ENHANCEMENT-POINT FCODE_POTO_07 SPOTS ES_SAPMV45A STATIC.
ENHANCEMENT-POINT FCODE_POTO_08 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT EHP603_FCODE_POTO_01 SPOTS ES_SAPMV45A.

ENHANCEMENT-SECTION     FCODE_POTO_09 SPOTS ES_SAPMV45A.
    call function 'SERIALPROFILE_CHECK'
      exporting
        operation     = da_vrgng
        activity      = xtrtyp
        document      = da_vbeln
        item          = xvbap-posnr
        kmatnr        = da_stdpd
        material      = xvbap-matnr
        profile       = xvbap-serail
        quantity      = da_xanzsn
        j_vorgang     = da_j_vorgang
        debitor       = xvbpa-kunnr
        cuobj         = da_cuobj
        m_charge      = vbap-charg
        m_werk        = da_werks                            "EHP603
        vbtyp         = vbak-vbtyp
        sd_auart      = vbak-auart
        sd_postyp     = xvbap-pstyv
      importing
        anzsn         = vbap-anzsn
        serial_commit = da_dataloss
        exit_flag     = lf_exit.
END-ENHANCEMENT-SECTION.

    if cl_mmpur_switch_check=>get_serial01_switch_state( ) eq charx.
      if not lf_exit is initial.
        clear da_dataloss.
      endif.
    endif.

    if not da_dataloss is initial.
      if cl_mmpur_switch_check=>get_serial01_switch_state( ) eq charx.
        gf_serial_changed = charx.
      endif.
*     If serial number was changed save info to sernr_chg.
      sernr_chg-vbeln      = vbap-vbeln.
      sernr_chg-posnr      = vbap-posnr.
      sernr_chg-anzsn_old  = *vbap-anzsn.
      sernr_chg-anzsn_new  = vbap-anzsn.
      sernr_chg-nr_changed = charx.
      append sernr_chg.
      serial_dataloss = da_dataloss.
    endif.
  else.
    if vbap-vkgru eq vkgru_rep_reparaturanfo or
       vbap-vkgru eq vkgru_rep_reparatur.
*     nur Objekte mit Materialbezug (keine technischen Plätze)
      da_material_only = charx.
    endif.
    call function 'IWOL_WV_LIST'
      exporting
        i_sdaufnr       = da_vbeln
        i_sdposnr       = xvbap-posnr
        i_aktyp         = xtrtyp
        i_kunde         = xvbpa-kunnr
        i_vbtyp         = vbak-vbtyp
        i_sd_auart      = vbak-auart
        i_postyp        = xvbap-pstyv
        i_only_material = da_material_only
      importing
        e_change        = da_dataloss
      tables
        t_ser02         = xser02
        t_riwol         = da_riwol
      exceptions
        no_object_list  = 1.
    clear vbap-anzsn.
    if sy-subrc eq 0.
      if ( vbap-vkgru eq vkgru_rep_reparaturanfo and
           tvak-vbklt eq charg )                 or
         vbap-vkgru eq vkgru_rep_reparatur.
        vbap-anzsn = vbapd-menge_g.
        do.
          read table da_riwol index sy-index.
          if sy-subrc ne 0. exit. endif.
          if da_riwol-dbknz ne chard.
            vbapd-matnr_g = da_riwol-matnr.
            exit.
          endif.
        enddo.
        vbap_pruefen   = charx.
      else.
        loop at xser02 where sdaufnr = da_vbeln and
                             posnr   = xvbap-posnr.
          add xser02-anzsn to vbap-anzsn.
        endloop.
      endif.
    endif.
  endif.

  if r185d-dataloss is initial.
    r185d-dataloss = da_dataloss.
  endif.

  perform vbap_bearbeiten(sapfv45p).
  perform vbap_pruefen_ende(sapfv45p).
  perform vbap_bearbeiten_ende(sapfv45p).

  h185f-fcode = 'BACK'.

* anything changed , then make a DEQUEUE
  if not da_dataloss is initial.
    gesperrt = charx.
  endif.

endform.                    "FCODE_POTO