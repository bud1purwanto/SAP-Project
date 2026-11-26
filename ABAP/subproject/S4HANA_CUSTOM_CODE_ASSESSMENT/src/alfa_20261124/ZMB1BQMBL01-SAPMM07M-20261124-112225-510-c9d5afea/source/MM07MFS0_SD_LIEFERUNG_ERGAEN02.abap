*----------------------------------------------------------------------*
*      Form  SD_LIEFERUNG_ERGAENZEN
*----------------------------------------------------------------------*
* Füllen der Übergabedaten zur Erzeugung einer Lieferung
*----------------------------------------------------------------------*
form sd_lieferung_ergaenzen changing l_xlk03 like komdlgn.

* The EHP604 condition variable has no effect for the core code
* conditions, it's value changes only in the switched code. This
* usage makes possible to avoid enh. sections.
DATA: EHP604_SD_LIEFERUNG_ERGAENZ_03 VALUE space,              "DT071219
      ls_ekpo_sit TYPE ekpo.

*........ Allgemein gültige Felder füllen...............................
  l_xlk03-mandt = xmseg-mandt.
  l_xlk03-meins = xmseg-meins.
  l_xlk03-lfimg = xmseg-erfmg.
  l_xlk03-vrkme = xmseg-erfme.
ENHANCEMENT-POINT SD_LIEFERUNG_ERGAENZEN_02 SPOTS ES_SAPMM07M.
  l_xlk03-bwart = xmseg-bwart.
* in case of different conversion factors in PO / material master,
* necessary to give the conversion factors to GN_DELIVERY_CREATE "374499
  if xmseg-meins <> xmseg-erfme.                                 "480232
    l_xlk03-umvkz = zdm07m-umrez.                                "374499
    l_xlk03-umvkn = zdm07m-umren.                                "374499
  endif.                                                         "480232


*........Daten aus XVM07M..............................................*
  l_xlk03-kunwe = xvm07m-kunwe.
  l_xlk03-lifnr = xvm07m-lvs_lifnr.
  l_xlk03-etens = xvm07m-etens.          "353043
  l_xlk03-lfart = xvm07m-lfart.
ENHANCEMENT-POINT EHP603_SD_LIEFERUNG_ERGAENZ_01 SPOTS ES_SAPMM07M.

  l_xlk03-vkorg = xvm07m-vkorg.
  l_xlk03-vstel = xvm07m-vstel.
  l_xlk03-vtweg = xvm07m-vtweg.
  l_xlk03-spart = xvm07m-spart.
  l_xlk03-qplos = xvm07m-qplos.

*... Advanced Returns Management II (EhP 6)
*... Indicator for LFE document (Valuation posting)
    IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
      move: XVM07M-msr_valuation TO l_XLK03-msr_valuation.
      IF xvm07m-msr_id IS NOT INITIAL.
* Set indicator for MSR process
        l_xlk03-msr_active = abap_true.
      ENDIF.
    endif.

  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.

   if xvm07m-msr_insp_guid is not initial.                         "n_1269580
     CALL FUNCTION 'GUID_CONVERT'
       EXPORTING
          IV_GUID_X16                  = xvm07m-msr_insp_guid
       IMPORTING
          EV_GUID_C32                  = l_xlk03-spe_inspout_guid
       EXCEPTIONS
          NO_UNICODE_SUPPORT_YET       = 1
          PARAMETERS_ERROR             = 2
          OTHERS                       = 3.

*     IF sy-subrc <> 0.                                            "v_del_1269580
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.                "^_del_1269580
     ENDIF.
    ENDIF.

*........Daten aus ZDM07M..............................................*
  l_xlk03-rblvs = zdm07m-rblvs.

*........Kontierungsfelder in die Lieferung übernehmen.................*
  l_xlk03-kostl      = xmseg-kostl.
  l_xlk03-gsber      = xmseg-gsber.
  l_xlk03-ps_psp_pnr = xmseg-ps_psp_pnr.
  l_xlk03-paobjnr    = xmseg-paobjnr.
  l_xlk03-fipos      = xmseg-fipos.
  l_xlk03-fistl      = xmseg-fistl.
  l_xlk03-geber      = xmseg-geber.
  l_xlk03-grant_nbr  = xmseg-grant_nbr.
  l_xlk03-fkber      = xmseg-fkber.
  l_xlk03-aufnr      = xmseg-aufnr.
  l_xlk03-kdauf      = xmseg-kdauf.
  l_xlk03-kdpos      = xmseg-kdpos.
  IF cl_ops_switch_check=>ops_sfws_bud_per( ) IS NOT INITIAL.
    l_xlk03-budget_pd = zdm07m-budget_pd.
  ENDIF.

*........Sonstige Daten................................................*
  l_xlk03-lfdat     = sy-datlo.
  l_xlk03-wadat     = sy-datlo.
  l_xlk03-wadat_ist = mkpf-budat.

ENHANCEMENT-POINT SD_LIEFERUNG_ERGAENZEN_01 SPOTS ES_SAPMM07M.
*........Allgemeine Daten II (HUM).....................................*
  l_xlk03-lifex     = mkpf-xblnr.
  l_xlk03-xabln     = mkpf-xabln.
* if xblnr_avis has been populated -> take it over as external delivery
* note number in likp
  if not xmbwl is initial and not xvm07m-xblnr_avis is initial.
    l_xlk03-lifex     = xvm07m-xblnr_avis.
  endif.
  l_xlk03-bolnr     = mkpf-frbnr.
  l_xlk03-bldat     = mkpf-bldat.
  l_xlk03-wadat_ist = mkpf-budat.

  l_xlk03-kzear     = xmseg-kzear.
  l_xlk03-lgpla     = xmseg-lgpla.
  l_xlk03-lgtyp     = xmseg-lgtyp.
  l_xlk03-kunwe     = xmseg-wempf.
  l_xlk03-ablad     = xmseg-ablad.
* l_xlk03-kztlf     = xmseg-elikz.
  IF NOT DM07M-ELIKZ_INPUT IS INITIAL.                       "v_n_965214
*   ELIKZ was changed manually
    IF NOT XMSEG-ELIKZ IS INITIAL.
      L_XLK03-KZTLF = 'X'.
    ELSE.
      L_XLK03-KZTLF = 'Y'.   "Dummy to know about manual change to space
    ENDIF.
  ELSE.
*   ELIKZ was not changed, but should stay as before
    IF NOT XVM07M-ELIKZ_OLD IS INITIAL AND
       NOT XMSEG-ELIKZ IS INITIAL.
      L_XLK03-KZTLF = 'X'.
    ENDIF.
  ENDIF.                                                     "^_n_965214
  l_xlk03-grund     = xmseg-grund.
  l_xlk03-lfpos     = xmseg-lfpos.
  l_xlk03-lfbnr     = xmseg-lfbnr.
  l_xlk03-lfgja     = xmseg-lfbja.
  l_xlk03-bwtar     = xmseg-bwtar.
  l_xlk03-kzbew     = xmseg-kzbew.
  l_xlk03-insmk     = xmseg-insmk.
  l_xlk03-kzvbr     = xmseg-kzvbr.
  l_xlk03-kokrs     = xmseg-kokrs.
  l_xlk03-prctr     = xmseg-prctr.
  l_xlk03-bpmng     = xmseg-bpmng.
  l_xlk03-exvkw     = xmseg-exvkw.
  l_xlk03-exbwr     = xmseg-exbwr.
  l_xlk03-rsnum     = xmseg-rsnum.                               "427936
  l_xlk03-rspos     = xmseg-rspos.                               "427936
  L_XLK03-EMATN     = XMSEG-EMATN.                             "n_732435
  IF NOT XMSEG-RSNUM IS INITIAL.                             "v_n_790375
*   lines of note 790375 deleted                               "n_828895
    L_XLK03-RSART   = XMSEG-RSART.
  ENDIF.                                                     "^_n_790375

  IF zdm07m-xkman <> space.                                 "v_n_1069460
* The G/L account needs only to be copied to the delivery if it has
* been entered manually
    l_xlk03-konto     = zdm07m-konto.
  ENDIF.                                                    "^_n_1069460
  l_xlk03-vfdat     = zdm07m-vfdat_input.
  l_xlk03-hsdat     = zdm07m-hsdat_input.
  l_xlk03-kzuml     = zdm07m-kzuml.
  l_xlk03-cuobj     = zdm07m-cuobj.
  IF cl_ewm_switch_check=>le_sfws_sc_ewm_man( ) = abap_true."v_n_1370175
* Production supply area is needed for consumption posting
    l_xlk03-prvbe = zdm07m-prvbe.
  ENDIF.                                                    "^_n_1370175

  l_xlk03-lichn     = xvm07m-licha.

*........Auswertung des Bewegungskennzeichen...........................*
  case xmseg-kzbew.
    when b.
      l_xlk03-vgbel = xmseg-ebeln.
      l_xlk03-vgpos = xmseg-ebelp.
      l_xlk03-vgtyp = v.
*     SIT: Valuation of Special Stock for deliveries to return items
      IF  t156-bustr = '169'                                    "1557257
      AND cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
        IF cl_mm_im_sit_info=>get_sit_info_item(
               iv_ebeln = xmseg-ebeln
               iv_ebelp = xmseg-ebelp ) IS NOT INITIAL.
          CLEAR ls_ekpo_sit.
          CALL FUNCTION 'ME_EKPO_SINGLE_READ'
            EXPORTING
              pi_ebeln         = xmseg-ebeln
              pi_ebelp         = xmseg-ebelp
            IMPORTING
              po_ekpo          = ls_ekpo_sit
            EXCEPTIONS
              no_records_found = 1
              OTHERS           = 2.
          IF sy-subrc = 0 AND ls_ekpo_sit-retpo IS NOT INITIAL.
            l_xlk03-kzbws = ls_ekpo_sit-kzbws.
          ENDIF.
        ENDIF.
      ENDIF.
*     WE-bezogene rechnungsprüfung
      l_xlk03-lfgja = xmseg-lfbja.
      l_xlk03-lfbnr = xmseg-lfbnr.
      l_xlk03-lfpos = xmseg-lfpos.
    when f.
      l_xlk03-aufnr    = xmseg-aufnr.
      l_xlk03-posnr_pp = xmseg-aufps.
  endcase.

ENHANCEMENT-POINT EHP604_SD_LIEFERUNG_ERGAENZ_03 SPOTS ES_SAPMM07M .

* Umlagerbestellung (T156-KZBWA = '01')
  if xvm07m-kzbwa = '01' OR
     EHP604_SD_LIEFERUNG_ERGAENZ_03 IS NOT INITIAL.            "DT071219
    l_xlk03-vgbel = xmseg-ebeln.
    l_xlk03-vgpos = xmseg-ebelp.
    l_xlk03-vgtyp = v.
*     we-bezogene rechnungsprüfung
    l_xlk03-lfgja = xmseg-lfbja.
    l_xlk03-lfbnr = xmseg-lfbnr.
    l_xlk03-lfpos = xmseg-lfpos.
  endif.

* Textposition für materiallose Rücklieferung                 "v_849409
  if xmseg-matnr is initial.
    l_xlk03-posar = 'B'.
    L_XLK03-ARKTX = ZDM07M-MAKTX.                            "n_1015987
  endif.                                                      "^_849409

endform.