*---------------------------------------------------------------------*
*       FORM BESTELLENTWICKLUNG_GENERIEREN                            *
*---------------------------------------------------------------------*
*       Die Bestellentwicklung wird generiert.                        *
*---------------------------------------------------------------------*
* form bestellentwicklung_generieren.
  FORM bestellentwicklung_generieren USING segindex LIKE sy-tabix.

* nicht für Sammelartikel-Zeilen
    CHECK NOT xvm07m-attyp = attyp-sam.
    CLEAR xekbe.
    MOVE-CORRESPONDING xvm07m TO xekbe.
    MOVE-CORRESPONDING xmkpf TO xekbe.
    MOVE-CORRESPONDING xmseg TO xekbe.
    CASE t156-bustr.
      WHEN '107'.
        xekbe-weora = zdm07m-weora.
        IF ( vm07m-xstor = zwei
          OR ( vm07m-retpo IS INITIAL AND xmseg-shkzg = h )
          OR ( vm07m-retpo = x AND xmseg-shkzg = s ) )
          AND NOT vm07m-webre IS INITIAL.
          xekbe-weora = zdm07m-weora_ekbe.
        ENDIF.
      WHEN '109'.
        IF vm07m-webre IS INITIAL.
          xekbe-weora = zdm07m-weora.
        ELSE.
          xekbe-weora = zdm07m-weora_ekbe.
        ENDIF.
    ENDCASE.
    if_secon.
    IF NOT mbval IS INITIAL.
      xacchd-cpudt = mw_cpudt.
      xacchd-cputm = mw_cputm.
    ENDIF.
    end_secon.
    IF NOT xower IS INITIAL.
      xekbe-xwoff = x.
    ENDIF.
    IF xmseg-sobkz = m OR xmseg-sobkz = k.
      CLEAR xekbe-bwtar.
    ELSEIF ( xmseg-kzbew IS INITIAL OR xmseg-kzbew = l )
      AND NOT xmseg-kzzug IS INITIAL
      AND NOT xmseg-sobkz = 'T' AND NOT t156-bustr = '107'. "SIT
      xekbe-bwtar = xmseg-umbar.
    ENDIF.
    IF xvm07m-elikz_old NE xmseg-elikz.
      xekbe-elikz = 1.
      IF xvm07m-elikz_old = x.
        xekbe-elikz = 0.
      ENDIF.
    ELSE.                                                   "1327321
      READ TABLE xekbe WITH KEY ebeln = xekbe-ebeln         "1327321
                                ebelp = xekbe-ebelp         "1327321
           TRANSPORTING NO FIELDS.                          "1327321
      IF sy-subrc = 0.                                      "1327321
        IF xmseg-elikz = x.                                 "1327321
          xekbe-elikz = 1.                                  "1327321
        ELSE.                                               "1327321
          xekbe-elikz = 0.                                  "1327321
        ENDIF.                                              "1327321
      ENDIF.                                                "1327321
    ENDIF.
    xekbe-lfgja = xmseg-lfbja.
    xekbe-gjahr = xmseg-mjahr.

*   In case of MAA and Cancellation do not fill xebke-belnr. This field has to be
*   empty  for ME_STATISTICS_EKBE_RKO
    IF xvm07m-xstor  <> 2 AND zdm07m-xhistma = abap_false.  "MAA DEV
      xekbe-belnr = xmseg-mblnr.
    ENDIF.                                                  "MAA DEV
    xekbe-buzei = xmseg-zeile.
    xekbe-ernam = xmkpf-usnam.
    xekbe-menge = xmseg-bstmg.
    xekbe-dmbtr = xvm07m-awewr.
*   zdm07m-kudif can only filled if exchange rate        "N980402
*   difference handling in OMRW is active                "N980402
    xekbe-kudif = zdm07m-kudif.                             "N980402
    xekbe-hswae = xmseg-waers.
    xekbe-wrbtr = xvm07m-aweww.
    xekbe-waers = xvm07m-bwaer.
    IF xmseg-bwart EQ bwart_141 OR xmseg-bwart EQ bwart_142.
      CLEAR xekbe-bamng.
      xekbe-lfgja = xvm07m-lfbja_internal.
      xekbe-lfbnr = xvm07m-lfbnr_internal.
      xekbe-lfpos = xvm07m-lfpos_internal.
    ELSE.
      xekbe-bamng = xmseg-menge.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_06 SPOTS ES_SAPMM07M.
    ENDIF.
    IF NOT xmkpf-xblnr IS INITIAL.
      xekbe-xblnr = xmkpf-xblnr.
    ELSE.
      xekbe-xblnr = xvm07m-xblnr_avis.
    ENDIF.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_01 SPOTS ES_SAPMM07M.

    IF NOT xmbwl IS INITIAL                                "note 137056
      AND NOT xmkpf-msr_active = 'X'
      AND NOT xvm07m-xblnr_avis IS INITIAL.                "note 137056
      xekbe-xblnr = xvm07m-xblnr_avis.                     "note 137056
    ENDIF.                                                 "note 137056

* Temporary correct KZBEW unnecessary here           "204573
    CASE xmseg-kzbew.
*-- WA zur Umlagerungsbestellung und WA zur LB-Bestellung ------------*
      WHEN space OR l.                                      "204573
        IF xmseg-kzzug IS INITIAL.
*       Subcontracting components
          IF xvm07m-pstyp = drei.                           "204573
            xekbe-vgabe = sieben.
            xekbe-bewtp = o.
*       read table ymbuz index xmseg-zeile.
            READ TABLE ymbuz INDEX segindex.
            IF NOT sy-subrc IS INITIAL.
*         message e001 with 'YMBUZ' xmseg-zeile.
              MESSAGE e001 WITH 'YMBUZ' segindex.
            ENDIF.
            if_secon.
*         loop at zeklb where zeile = ymbuz-zeile
            LOOP AT zeklb WHERE zeile = ymbuz-zeilz
                          AND   curtp = curtp10.
              EXIT.
            ENDLOOP.
            end_secon.
            IF NOT sy-subrc IS INITIAL.
              MESSAGE e001 WITH 'ZEKLB' tabix.
            ENDIF.
            IF zeklb-wrbtr < 0.
              xekbe-wrbtr = 0 - zeklb-wrbtr.
            ELSE.
              xekbe-wrbtr = zeklb-wrbtr.
            ENDIF.
            xekbe-waers = zeklb-umwae.
            IF zeklb-dmbtr < 0.
              xekbe-dmbtr = 0 - zeklb-dmbtr.
            ELSE.
              xekbe-dmbtr = zeklb-dmbtr.
            ENDIF.
            xekbe-hswae = zeklb-waers.
          ENDIF.     "vm07m-pstyp=3 subcontracting  204573
        ELSEIF xmseg-xauto = x.                                       "SIT
          xekbe-vgabe = eins.
          xekbe-bewtp = e.
*         store delivery information for stock transfer in ekbe"1657162
          xekbe-vbeln_st = xvm07m-vbeln.                       "1657162
          xekbe-vbelp_st = xvm07m-vbelp.                       "1657162
* Posting into receiving SIT
          IF mseg-lgort IS INITIAL.
            xekbe-wesbb = xekbe-menge.
            IF xbbefu-bstme = xbbefu-bprme.
              xekbe-bpweb = xekbe-menge.
            ELSE.
              CALL FUNCTION 'MB_UNIT_CONVERSION'
                EXPORTING
                  menge                = xekbe-bpmng
                  meins                = xbbefu-bprme
                  erfmg                = xekbe-menge
                  erfme                = xbbefu-bstme
                  umrez                = xbbefu-bpumz
                  umren                = xbbefu-bpumn
                IMPORTING
                  o_menge              = xekbe-bpweb
                EXCEPTIONS
                  conversion_not_found = 4.
              IF NOT sy-subrc IS INITIAL.
                MESSAGE e026 WITH mseg-bprme mseg-erfme.
              ENDIF.
            ENDIF.
            xekbe-menge = 0.
            xekbe-bpmng = 0.
ENHANCEMENT-POINT EHP605_BESTELLENTWICKLUNG_G_01 SPOTS ES_SAPMM07M .
          ENDIF.
        ELSE.
*         GI for transfer PO (351/641)
          xekbe-vgabe = sechs.
          xekbe-bewtp = u.
*         store delivery information for stock transfer in ekbe"1657162
          xekbe-vbeln_st = xvm07m-vbeln.                       "1657162
          xekbe-vbelp_st = xvm07m-vbelp.                       "1657162
*         HSWAE is always the local currency of the plant posting
*         the goods issue, DMBTR is always the amount of the
*         goods movment. Do ***not*** use XVM07M-AWEWR here, because
*         it is not filled always correctly (e.g. receiving part
*         of cross-system movements).
          xekbe-dmbtr = xmseg-dmbtr.
          xekbe-hswae = xmseg-waers.
*         WAERS is the document currency, WRBTR the corresponding
*         amount.
*         This concept of document
*         currency only makes sense for cross-company PO's. Only
*         there it is possible to specify a different PO currency,
*         and WRBTR/WAERS should reflect the GI-amount in that other
*         currency.
*         Remark: The fields WRBTR/WAERS do not seem to be used
*         anywhere. Even the PO history display, when switching to
*         "document currency", only shows their contents for goods
*         receipts.
*         The case of initial BWAER can occur for accounted
*         UB-POs within the same CC (???).
*         However, the strategy should be: If I dont know, use DMBTR.
          IF xvm07m-bwaer <> xmseg-waers
             AND NOT xvm07m-bwaer IS INITIAL.
*           Different document currency. This can only occur in the
*           case of cross-company PO. Only in this case AWEWW is filled
*           with a useful value (from BESTELLWERT_UPDATE in WA01).
            xekbe-wrbtr = xvm07m-aweww.
            xekbe-waers = xvm07m-bwaer.
          ELSE.
*           UB-logic PO. There is no different PO-currency, WRBTR
*           must be equal to HSWAE.
*           Caution: AWEWW and AWEWR might be filled (from
*           WA04_ZUGANGSWERT in WA04), but sometimes in the
*           wrong way (depending on the local currency of the
*           ***receiver***). Irrelevant for the PO history!!!
            xekbe-wrbtr = xmseg-dmbtr.
            xekbe-waers = xmseg-waers.
          ENDIF.
*         Fallback solution for receiving part of cross-system
*         movements. No valuation of the issuing part. DMBTR is
*         filled externally via IDoc and therefore present, but WRBTR
*         is completely missing.
*         I will fill it with the local currency of the issuer
*         (although now WAERS differ between issuing and receiving
*         lines. At lease WRBTR matches WAERS and contains some
*         useful value).
          IF cl_mmim_cross_system=>gf_mode = r.             "sdp462
            xekbe-wrbtr = xmseg-dmbtr.                      "sdp462
            xekbe-waers = xmseg-waers.                      "sdp462
          ENDIF.                                            "sdp462
          IF xmseg-umsok = 'T'.     "case 681        "SIT
*         681 gets quantity and value to avoid double delivery
*         creation in the static quantity check field XEKPO-WAMNG
          ELSEIF xmseg-sobkz = 'T'. "case 685        "SIT
            xekbe-menge = 0.                         "SIT
            xekbe-bpmng = 0.                         "SIT
            xekbe-wrbtr = 0.                         "SIT
            xekbe-dmbtr = 0.                         "SIT
          ENDIF.                                     "SIT
        ENDIF.
*-- 'Normaler' Wareneingang ------------------------------------------*
      WHEN b.
        xekbe-vgabe = eins.
        xekbe-bewtp = e.
*       store delivery information for stock transfer in ekbe "1657162
        IF NOT zdm07m-reswk IS INITIAL.                       "1657162
          IF NOT xvm07m-vbeln IS INITIAL.                     "1657162
            xekbe-vbeln_st = xvm07m-vbeln.                    "1657162
            xekbe-vbelp_st = xvm07m-vbelp.                    "1657162
          ELSE.  " i.e. via MIGO                              "1657162
            xekbe-vbeln_st = zdm07m-vbeln_vl.                 "1657162
            xekbe-vbelp_st = zdm07m-vbelp_vl.                 "1657162
          ENDIF.                                              "1657162
        ENDIF.                                                "1657162
        CASE xvm07m-kzwes.
          WHEN s.
            IF xvm07m-sekpo = 'E12' OR xvm07m-sekpo = 'E23'. "1096899
              xekbe-wesbb = xekbe-menge.
              xekbe-bpweb = xekbe-bpmng.
* SIT 167/169 and 109E/Q
            ELSEIF xvm07m-sekpo = 'E44' OR xvm07m-sekpo = 'E45' OR "SIT
                   xvm07m-sekpo = 'E32'.                           "SIT
              xekbe-wesbb = xekbe-menge.                           "SIT
              xekbe-bpweb = xekbe-bpmng.                           "SIT
            ELSE.
              xekbe-wesbs = xekbe-menge.
              xekbe-bpwes = xekbe-bpmng.
            ENDIF.
            xekbe-menge = 0.
            xekbe-bpmng = 0.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_07 SPOTS ES_SAPMM07M.
          WHEN x.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_08 SPOTS ES_SAPMM07M.
            IF xvm07m-sekpo = 'E12' OR xvm07m-sekpo = 'E23'. "1096899
              xekbe-wesbb = 0 - xekbe-menge.
              xekbe-bpweb = 0 - xekbe-bpmng.
* SIT 167/169 and 109E/Q
            ELSEIF xvm07m-sekpo = 'E44' OR xvm07m-sekpo = 'E45' OR "SIT
                   xvm07m-sekpo = 'E32'.                           "SIT
              xekbe-wesbb = 0 - xekbe-menge.                      "SIT
              xekbe-bpweb = 0 - xekbe-bpmng.                      "SIT
            ELSE.
              xekbe-wesbs = 0 - xekbe-menge.
              xekbe-bpwes = 0 - xekbe-bpmng.
            ENDIF.

        ENDCASE.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_02 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_03 SPOTS ES_SAPMM07M.

*-    'WHEN L' now included in 'WHEN SPACE' -> no dead coding     381812
*-- Lieferschein zur Umlagerungsbestellung ---------------------------*
*     WHEN L.                                                     381812
*-- Localization BRA - TF BRA ---------------------------------------*
*   coding for Brazil not necessary here!!
*       DATA J_1B_TF_CAN_GI(1) TYPE C.                            381812
*       PERFORM J_1B_TF_CANCEL_GI_CHECK USING    XMSEG-BWART      381812
*                                                BRAZIL           381812
*                                       CHANGING J_1B_TF_CAN_GI.  381812
*       IF  ( NOT XMSEG-KZZUG IS INITIAL )                        381812
*        OR ( NOT J_1B_TF_CAN_GI IS INITIAL ).   "TF Brazil       381812
*         XEKBE-VGABE = SECHS.                                    381812
*         XEKBE-BEWTP = U.                                        381812
*         XEKBE-DMBTR = XMSEG-DMBTR.                              381812
*       ENDIF.                                                    381812
    ENDCASE.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_04 SPOTS ES_SAPMM07M.

*-- MAA-DEV
    DATA: l_curtp     TYPE curtp,
          l_acc_menge TYPE ekbe_ma-menge.

    IF NOT zdm07m-xhistma IS INITIAL.                       "MAA2

*     create the PO history entries on AA line level and
*     replace the values on item level EKBE
* --- begin ----------------------------------------------- MAA2
      CALL METHOD go_mmim_maa_2->maa_ekbe_ma_creator
        EXPORTING
          is_xvm07m      = xvm07m
          is_mseg        = xmseg
          is_zdm07m      = zdm07m
          it_yekbe_cr    = yekbe_cr[]
        CHANGING
          cs_xekbe       = xekbe
          ct_xekbe_ma_s  = xekbe_ma[]
          cv_flag_error  = gv_flag_error
          ct_message_log = gt_message_log.

      IF gv_flag_error = abap_true.
        PERFORM            send_maa_error_message.
      ENDIF.

      CALL METHOD go_mmim_maa_2->xekbe_aggregate
        EXPORTING
          is_mseg        = xmseg
        CHANGING
          cs_xekbe       = xekbe
          cv_flag_error  = gv_flag_error
          ct_message_log = gt_message_log.

      IF gv_flag_error = abap_true.
        PERFORM            send_maa_error_message.
      ENDIF.
* --- end   ----------------------------------------------- MAA2

*------ Save current Exchange rate
      DATA: ls_ekbe_cr TYPE cki_ekbecr.
      READ TABLE yekbe_cr INTO ls_ekbe_cr
                          WITH KEY buzei = zdm07m-zeild
                                   curtp = curtp10.
      IF sy-subrc = 0.
        xekbe-wkurs = ls_ekbe_cr-wkurs.
        IF xekbe-waers = ls_ekbe_cr-waers.
          xekbe-wkurs = '100000'.
        ENDIF.
      ENDIF.
    ENDIF.
*-- MAA-DEV


    IF ( xmseg-xmacc = cl_mmim_maa_2=>gc_xhistma_badi  OR  "MAA2
         xmseg-xmacc = cl_mmim_maa_2=>gc_xhistma_std ).    "MAA2
      "don't update EKBE and EKBE_CR                       "MAA2
    ELSE.                                                  "MAA2
      IF xvm07m-kzbwa = kzbwa-05 AND NOT zdm07m-xstbw IS INITIAL.
        wekbe = xekbe.
        APPEND wekbe.
      ELSE.
        APPEND xekbe.
      ENDIF.

      LOOP AT yekbe_cr WHERE buzei = zdm07m-zeild.
        IF yekbe_cr-ebeln NE xmseg-ebeln OR yekbe_cr-ebelp NE xmseg-ebelp.
          MESSAGE e001 WITH 'YEKBE_CR' zdm07m-zeild xmseg-ebeln xmseg-ebelp.
        ENDIF.
        xekbe_cr = yekbe_cr.
        xekbe_cr-vgabe = xekbe-vgabe.
        xekbe_cr-gjahr = xekbe-gjahr.
        xekbe_cr-belnr = xekbe-belnr.
        xekbe_cr-buzei = xekbe-buzei.
        IF zdm07m-xhistma IS INITIAL.    "MAA-DEV
          xekbe_cr-zekkn = xekbe-zekkn.                        "note 123430
        ENDIF.
*---- MAA-DEV
        IF xekbe_cr-waers = xekbe-waers.
          xekbe_cr-wkurs = '100000'.
        ENDIF.
*---- MAA-DEV
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_09 SPOTS ES_SAPMM07M .
        IF xvm07m-kzbwa = kzbwa-05 AND NOT zdm07m-xstbw IS INITIAL.
          wekbe_cr = xekbe_cr.
          APPEND wekbe_cr.
        ELSE.
          APPEND xekbe_cr.
        ENDIF.
      ENDLOOP.
    ENDIF.                                                 "MAA2

*...evtl. Struktur fuer Fremdvorgang fortschreiben
    IF NOT zdm07m-aufpl_ord IS INITIAL AND
       NOT zdm07m-aplzl_ord IS INITIAL.
      MOVE-CORRESPONDING xekbe TO xexop.
      MOVE-CORRESPONDING zdm07m TO xexop.
      xexop-aufnr = xmseg-aufnr.
      APPEND xexop.
    ENDIF.
*    IF NOT ( ZDM07M-XVASH IS INITIAL  OR  VAS_SWITCH IS INITIAL ).
    IF NOT zdm07m-xvash IS INITIAL.                        " P9CK166739
* create po history entries for subitems
      PERFORM vas_bestellentwicklung_upos.
    ENDIF.
ENHANCEMENT-POINT BESTELLENTWICKLUNG_GENERIER_05 SPOTS ES_SAPMM07M.
  ENDFORM.                    "BESTELLENTWICKLUNG_GENERIEREN

*----------------------------------------------------------------------*