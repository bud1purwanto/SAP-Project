*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNG_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Die Kontierung wird geprüft.                                  *
*---------------------------------------------------------------------*
FORM kontierung_pruefen.

  DATA: l_flag TYPE c.

  data: l_xmacc type XMACC.

  BREAK-POINT ID mb_kontierung_pruefen.

* begin --------------------------------------------------- "MAA2
  DATA : lv_dm07m_xhistma_save         TYPE  xhistma,
         lv_cobl_meins_save            TYPE  meins,
         lv_flag_break_point           TYPE  abap_bool.
* end ----------------------------------------------------- "MAA2
* MAA EhP4
  if NOT dm07m-xhistma  IS INITIAL.
    CALL FUNCTION 'MB_MAA_ACC_CHECK_GET'
      IMPORTING
        E_XMACC = l_xmacc.

    IF  mseg-maa_urzei IS INITIAL.                          "MAA2
      if l_xmacc is initial.
        return.
      ENDIF.
    ENDIF.                                                  "MAA2
  endif.
* MAA EhP4

* begin --------------------------------------------------- "MAA2
*  IF  lv_flag_maa_new = abap_true.
**   restore the content of this field
*    MOVE : lv_dm07m_xhistma_save       TO  dm07m-xhistma.
*  ENDIF.
* end ----------------------------------------------------- "MAA2

  CLEAR mseg-kdein.
  CLEAR cobl.
  cobl-bldat = mkpf-bldat.
  cobl-blart = mkpf-blart.
  cobl-budat = mkpf-budat.
* COBL-BZDAT = MKPF-BUDAT.                "Variante im FI-AA seit 4.0A
  cobl-xblnr = mkpf-xblnr.
  MOVE-CORRESPONDING mseg  TO cobl.
  IF NOT mseg-matbf IS INITIAL.
    cobl-matnr = mseg-matbf.
  ENDIF.
  MOVE-CORRESPONDING dm07m TO cobl.
  MOVE-CORRESPONDING vm07m TO cobl.
* transfer consumption postings between two companies should be  "964452
* possible                                                       "964452
  IF NOT dm07m-kzuml IS INITIAL OR                          "964452
     ( dm07m-umkzvbr = 'V' OR dm07m-umkzvbr = 'A' ).        "964452
    cobl-monat = dm07m-ummon.
    cobl-gjahr = dm07m-umgja.
  ENDIF.
* Analog Stelle Send_pai
  IF dm07m-fausw+11(1) = minus.
* deleted note 354804 (in case MB_CREATE... no field selection check!)
*   clear: cobl-ps_psp_pnr.                                 "note328378
* Feldauswahl ausgeschaltet und KDAUF bezieht sich nicht auf
* Umlagerzeile, dann Projekt zurücksetzten
    IF mseg-umsok IS INITIAL.
      CLEAR mseg-ps_psp_pnr.
    ENDIF.
  ENDIF.
  IF dm07m-fausw+12(1) = minus.
* Feldauswahl ausgeschaltet und KDAUF bezieht sich nicht auf
* Umlagerzeile, dann Kundenauftrag zurücksetzten
    IF mseg-umsok IS INITIAL.
      CLEAR: mseg-kdauf, mseg-kdpos.
    ENDIF.
  ENDIF.
  IF mseg-matnr IS INITIAL.
    cobl-menge = mseg-erfmg.
    cobl-meins = mseg-erfme.
  ENDIF.
  IF NOT mseg-anln1 IS INITIAL AND NOT vm07m-kzwes = s AND
     NOT mseg-bustw IS INITIAL.
    cobl-koart = a.
  ENDIF.
  CLEAR cobl-kokrs.
  kdauf = mseg-kdauf.
  kdpos = mseg-kdpos.
  kdein = mseg-kdein.
  pspnr = mseg-ps_psp_pnr.
  kzbws = dm07m-umkzbws.
  IF mseg-sobkz = e OR mseg-umsok = e. "wonder if this is correct
    "because we use mseg-kdauf, that belongs to mseg-umsok ??
    IF t158-vgart = vgart_wf OR t158-vgart = vgart_ws
        OR t158-vgart = vgart_wr.
      IF mseg-sobkz = e .
        PERFORM kundenauftragspruefung USING mseg-kdauf
                                             mseg-kdpos
                                             mseg-kdein
                                                  space
                                             mseg-matnr
                                                 mseg-sobkz
                                   CHANGING dm07m-umkzbws
                                            dm07m-ucuob
                                            dm07m-umkzvbr.
      ELSEIF mseg-umsok = e.
        PERFORM kundenauftragspruefung USING mseg-kdauf
                                               mseg-kdpos
                                               mseg-kdein
                                                    space
                                               mseg-matnr
                                               mseg-umsok
                                     CHANGING dm07m-umkzbws
                                              dm07m-ucuob
                                              dm07m-umkzvbr.
      ENDIF.
    ENDIF.
    IF t158-vgart = vgart_wf OR t158-vgart = vgart_ws
       OR t158-vgart = vgart_wr
       OR dm07m-fausw+12(1) = minus.
      CLEAR: cobl-kzvbr, cobl-kdauf, cobl-kdpos, cobl-kdein.
      IF mseg-kzvbr = p.
        CLEAR: cobl-ps_psp_pnr.
      ENDIF.
    ENDIF.
  ENDIF.
  IF ( mseg-sobkz = q OR mseg-umsok = q ) AND
     ( t158-vgart = vgart_wf OR t158-vgart = vgart_ws
       OR t158-vgart = vgart_wr
       OR dm07m-fausw+11(1) = minus ) .
    CLEAR: cobl-ps_psp_pnr.
    CLEAR: cobl-kzvbr.
  ENDIF.

ENHANCEMENT-POINT EHP604_KONTIERUNG_PRUEFEN_01 SPOTS ES_SAPMM07M. "DT071126

* valuated special stock and delivery refering to cross company
* transfer order => KDAUF, KDPOS and PS_PSP_PNR shouldn't be filled
  IF mseg-sobkz = e OR mseg-sobkz = q OR mseg-sobkz = t.
    IF mseg-kzbws = m OR mseg-kzbws = a.
      IF im_process = l.
        PERFORM purchase_order_check(saplkaip) USING mseg-ebeln
                                                     mseg-ebelp
                                            CHANGING l_flag.
        IF mseg-umsok = T.                                "SIT
          CLEAR l_flag.
        ENDIF.
        IF l_flag = 'X'.
          CLEAR: cobl-kdauf,
                 cobl-kdpos,
                 cobl-ps_psp_pnr.
        ENDIF.
        CLEAR: l_flag.
      ENDIF.
    ENDIF.
  ENDIF.
* As first take the partner business area of MSEG as business are
* for CO (= business area of cost center f.e.): PARGB
* If the business area for CO is still initial, take the business
* area of the receiving material master: UMGSB
* If the business area for CO is still initial, take the business
* area of the material master: GSBER
* Note 365071 makes an attempt to improve the situation.
* Cannot be implemented in this support package. See internal memo.
  cobl-gsber = mseg-pargb.
  IF cobl-gsber IS INITIAL.
    cobl-gsber = dm07m-umgsb.
    IF cobl-gsber IS INITIAL.
      cobl-gsber = mseg-gsber.
    ENDIF.
  ENDIF.
* Same logic for profit center as before in case of business areas.
  cobl-prctr = mseg-pprctr.
  IF cobl-prctr IS INITIAL.
    cobl-prctr = dm07m-umprc.
    IF cobl-prctr IS INITIAL.
      cobl-prctr = mseg-prctr.
    ENDIF.
  ENDIF.
* PartnerPC and PartnerBA should be set with values of material master.
* Because these are the partners for CO.
* This was requested by CO. See note 167853.
  cobl-pargb  = mseg-gsber.
  cobl-pprctr = mseg-prctr.
  cobl-bukrs = mseg-parbu.
  IF NOT dm07m-parwk IS INITIAL.                            "789672
    cobl-werks = dm07m-parwk.                               "789672
    IF tcurm-bwkrs_cus = 1.                                 "789672
      cobl-bwkey = cobl-werks.                              "789672
    ENDIF.                                                  "789672
  ENDIF.                                                    "789672
  IF NOT dm07m-kzuml IS INITIAL.
    cobl-werks = mseg-umwrk.
  ENDIF.
  cobl-hkont = dm07m-konto.
  cobl-vorgn = rw_vorgang.
  cobl-awtyp = rw_awtyp.                                    "1125184
  IF vm07m-xstor = '2'.                                     "700472
    cobl-stflg = 'X'.                                       "700472
  ENDIF.                                                    "700472
* New check request by FI-AA :                                  "1270744
* If there is no accounting line as a result of the good        "1270744
* receipt postings, set new flag XNOGL to 'X'.                  "1270744
* So far, good receipt posting to non-valudated block           "1270744
* stock (103 and 104)is known.                                  "1270744
  if not cobl-anln1 is initial.                             "1270744
    if ( T156-KZWES = S AND mseg-bustw is INITIAL ) OR      "1270744
       ( mseg-menge = 0 AND NOT mseg-elikz IS INITIAL ).    "1604096
      cobl-xnogl = X.                                       "1270744
    endif.                                                  "1270744
  endif.                                                    "1270744


** Retrieve Funded Program if MEASURE is active. - Note 1597730
  IF NOT CL_FM_FUNDED_PROG_UTIL_APPL=>IS_MEASURE_ACTIVE( )  IS INITIAL.
    DATA: l_measure TYPE fm_measure,
          xteskl    TYPE TABLE OF eskl,
          xeskn     TYPE eskn,
          xessr     TYPE essr,
          xeskl     TYPE eskl.
    FIELD-SYMBOLS <measure> TYPE fm_measure.

    CLEAR l_measure.
** Services
    If MSEG-LFBNR is NOT INITIAL.
      CALL FUNCTION 'MS_READ_ENTRY_SHEET'
        EXPORTING
          i_lblni            = mseg-lfbnr
          i_from_online      = 'X'
          I_WITH_ESKL        = 'X'
        IMPORTING
          e_essr             = xessr
        TABLES
*         t_eskn             = xeskn
*         t_esll             = xesll
          t_eskl             = xteskl
        EXCEPTIONS
          sheet_not_found    = 01
          account_not_found  = 02
          sheet_not_buffered = 03
          OTHERS             = 04.

      IF sy-subrc = 0.
        READ TABLE xteskl INTO xeskl INDEX 1.

        If sy-subrc = 0.
          CALL FUNCTION 'MS_ACCOUNT_GET_MEASURE'
            EXPORTING
              i_packno  = xeskl-hpackno
              i_zekkn   = xeskl-zekkn
            IMPORTING
              E_MEASURE = l_measure.
          ASSIGN COMPONENT 'MEASURE' OF STRUCTURE cobl TO <measure>.
          IF  <measure> IS ASSIGNED
          AND l_measure IS NOT INITIAL..
            MOVE l_measure TO <measure>.
          ENDIF.
        ENDIF.
      ENDIF.
** Not services
    ELSE.
      IF mseg-zekkn IS NOT INITIAL.
        l_measure = CL_FM_FUNDED_PROG_UTIL_APPL=>GET_MEASURE_FROM_PO(
                                                                        IV_REFBN = mseg-ebeln
                                                                        IV_RFPOS = mseg-ebelp
                                                                        IV_RFKNT = mseg-zekkn
                                                                       ).
      ELSE.
        l_measure = CL_FM_FUNDED_PROG_UTIL_APPL=>GET_MEASURE_FROM_PO(
                                                          IV_REFBN = mseg-ebeln
                                                          IV_RFPOS = mseg-ebelp
                                                         ).
      ENDIF.
*          ENDIF.
      ASSIGN COMPONENT 'MEASURE' OF STRUCTURE cobl TO <measure>.
      IF  <measure> IS ASSIGNED
      AND l_measure IS NOT INITIAL..
        MOVE l_measure TO <measure>.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'RWIN_CHECK'
    EXPORTING
      gjahr   = cobl-gjahr
      process = 'BELEGPOS'
      event   = 'PRUEFEN '
    TABLES
      tkomp   = tkomp
    EXCEPTIONS
      OTHERS  = 0.
  DATA: gsber LIKE mseg-gsber,
        prctr LIKE mseg-prctr.
  gsber = mseg-gsber.
  prctr = mseg-prctr.

* OLC EhP5e Ensure that for the Order type the activity values (APLZL/AUFPL) are cleared when necessary.
* For Production Orders the values of AUFPL and APLZL can contain values for header costed orders.
* OLC sees this as an error scenario. The values need to be cleared prior to the accounting check.
  IF cl_erp_co_olc_tools=>is_not_olc_relevant( mseg-aufnr ) EQ abap_true.
    DATA lv_aplzl TYPE cim_count.
    lv_aplzl = mseg-aplzl.
    CLEAR cobl-aplzl.
  ENDIF.

* begin --------------------------------------------------- "MAA2
*   it could be possibe that packed quantity field on AA level
*   is zero although there is a very small quantity for amount
*   based distribution in a float field and there could be a
*   value, so this account assignment has to be checked without
*   quantity and quantity unit
  IF  cobl-menge IS INITIAL.
*     clear the quantitity unit, too; avoid error AAPO181
    MOVE  cobl-meins                 to  lv_cobl_meins_save.
    CLEAR                            cobl-meins.
  ENDIF.
* end ----------------------------------------------------- "MAA2

  LOOP AT tkomp.
    CALL FUNCTION tkomp-function
      EXPORTING
        i_cobl = cobl
      IMPORTING
        e_cobl = cobl.

* - begin ------------------------------------------------- "MAA2
    IF NOT lv_cobl_meins_save IS INITIAL.
*     restore the content of the field quantity unit
      MOVE  lv_cobl_meins_save         TO  cobl-meins.
    ENDIF.

* If no cost element in COBL, do not derive Company Code
    IF cobl-hkont IS INITIAL AND NOT cobl-kzbws IS INITIAL. "935865
      IF NOT cobl-bukrs = mseg-parbu.                       "1562553
        cobl-bukrs = mseg-parbu.                            "1562553
      ENDIF.                                                "935865
    ENDIF.                                                  "935865
    MOVE-CORRESPONDING mseg    TO cobl_mb.
    MOVE-CORRESPONDING dm07m   TO cobl_mb.
    MOVE-CORRESPONDING vm07m   TO cobl_mb.
    MOVE-CORRESPONDING cobl    TO mseg.
    MOVE-CORRESPONDING cobl    TO dm07m.
    MOVE-CORRESPONDING cobl    TO vm07m.
    MOVE-CORRESPONDING cobl_mb TO mseg.
    MOVE-CORRESPONDING cobl_mb TO dm07m.
    MOVE-CORRESPONDING cobl_mb TO vm07m.
    IF NOT mseg-parbu = cobl-bukrs.
      mseg-parbu = cobl-bukrs.
      PERFORM buchungskreis_pruefen(sapfm07m) USING mseg-parbu
                                                   dm07m-umkpl
                                                   dm07m-umper
                                                   dm07m-umwae
                                                    mkpf-budat
                                                   dm07m-umgja
                                                   dm07m-ummon.
    ENDIF.
    mseg-pargb = cobl-gsber.
    mseg-pprctr = cobl-prctr.
    mseg-gsber = gsber.
    mseg-prctr = prctr.
    IF NOT cobl-hkont IS INITIAL.
      dm07m-konto = cobl-hkont.
    ENDIF.
    IF NOT cobl-objnr_real IS INITIAL.
      vm07m-objnr = cobl-objnr_real.
    ENDIF.
    IF cobl-autyp = sa_autyp AND t158-vgart NE vgart_ws     "582677
      AND ( xmigo <> space OR xbapi <> space )              "753240
      and xmbwl <> space and mseg-kzbew <> B                "720308
      and vm07m-pstyp <> 3.                                 "1366639
      MESSAGE e162 WITH cobl-aufnr.                         "582677
    ENDIF.                                                  "582677
  ENDLOOP.

* OLC EhP5e
* Now repopulate the MSEG and COBL values.
  IF cl_erp_co_olc_tools=>is_not_olc_relevant( mseg-aufnr ) EQ abap_true.
    mseg-aplzl = lv_aplzl.
    cobl-aplzl = lv_aplzl.
  ENDIF.

  IF ( mseg-sobkz = e OR mseg-umsok = e ) AND
     ( t158-vgart = vgart_wf OR t158-vgart = vgart_ws
       OR t158-vgart = vgart_wr
       OR dm07m-fausw+12(1) = minus ).
    mseg-kdauf = kdauf.
    mseg-kdpos = kdpos.
    mseg-kdein = kdein.
  ENDIF.
  IF NOT xmbwl IS INITIAL AND NOT mseg-kdauf IS INITIAL
     AND ( t158-vgart = vgart_wr OR t158-vgart = vgart_ws ).
    CALL FUNCTION 'ENQUEUE_EVVBAKE'
      EXPORTING
        vbeln          = mseg-kdauf
      EXCEPTIONS
        foreign_lock   = 2
        system_failure = 3.
    CASE sy-subrc.
      WHEN 2.
        MESSAGE e042(v1) WITH mseg-kdauf
            RAISING document_blocked.
      WHEN 3.
        MESSAGE a043(v1).
    ENDCASE.
  ENDIF.
  IF ( mseg-sobkz = q OR mseg-umsok = q ) AND
     ( t158-vgart = vgart_wf OR t158-vgart = vgart_ws
       OR t158-vgart = vgart_wr
       OR dm07m-fausw+11(1) = minus ) .
    mseg-ps_psp_pnr = pspnr.
  ENDIF.
  PERFORM qm_kontierung.

* check company code                                             "531078
* IF ( xmigo = x OR xbapi = x ) AND NOT mseg-matnr IS INITIAL    "531078
  IF xmbwl = x AND NOT mseg-matnr IS INITIAL                "949106
    AND  NOT mseg-bukrs IS INITIAL AND NOT mseg-parbu IS INITIAL
    AND  mseg-umwrk IS INITIAL AND mseg-bukrs <> mseg-parbu.
    PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '517'
                      mseg-parbu mseg-bukrs mseg-werks space.
  ENDIF.


* MAA EhP4
* Reset Flag XMAA
  CALL FUNCTION 'MB_MAA_ACC_CHECK_SET'
    EXPORTING
      i_xmacc = space.

ENDFORM.                    "kontierung_pruefen