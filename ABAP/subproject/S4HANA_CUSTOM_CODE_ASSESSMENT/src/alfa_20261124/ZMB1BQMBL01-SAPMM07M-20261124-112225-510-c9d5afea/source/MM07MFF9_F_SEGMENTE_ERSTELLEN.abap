*eject
*---------------------------------------------------------------------*
*       FORM F-SEGMENTE_ERSTELLEN                                     *
*---------------------------------------------------------------------*
*       Die Segmente des Buchhaltungsbelegs werden erstellt.          *
*---------------------------------------------------------------------*
FORM f-segmente_erstellen USING f-bustw LIKE t156w-bustw
                                   f-xbnk  TYPE c
                          CHANGING c_kzuml LIKE dm07m-kzuml. "0495236

  DATA l_shkzg LIKE mseg-shkzg. CLEAR l_shkzg.              "HW578078
  DATA: loc_bwmod LIKE dm07m-parbw.
  DATA: hbnbtr LIKE mseg-bnbtr.                             "830707
  DATA: f_156w_save TYPE t156w.                             "N980402
  t_index  = 1.
  DATA: bklas LIKE dm07m-bklas,                             "981671
        eklas LIKE dm07m-eklas,                             "981671
        qklas LIKE dm07m-qklas.                             "981671
  DATA shkzg LIKE mseg-shkzg. CLEAR shkzg.
*   Funded Program  Note 1576776
  TYPES: BEGIN OF lts_fm_measure,
           measure TYPE fm_measure,
         END OF lts_fm_measure.
ENHANCEMENT-POINT F-SEGMENTE_ERSTELLEN_01 SPOTS ES_SAPMM07M STATIC .
  LOOP AT x156w WHERE bustw = f-bustw.
    CLEAR yfbuz.
    CLEAR: xaccit, xacccr, gs_accit_ext.                    "593240
    CLEAR: f_156w_save.                                     "N1328480
    PERFORM f-segmente_bewerten USING    x156w-cnt02
                                         f-xbnk
                                CHANGING shkzg              "HW578078
                                         l_shkzg.           "HW578078
    xzcxcm-shkzg = shkzg.
ENHANCEMENT-POINT F-SEGMENTE_ERSTELLEN_02 SPOTS ES_SAPMM07M .
    IF NOT xzcxcm-shkzg IS INITIAL OR x156w-buzid = u.
      bukrs-umbuk = dm07m-umbuk.
      IF x156w-buzid = u.
        ymbuz_key-zeilz = zmseg-zeile.
        ymbuz_key-xauto = x.
        READ TABLE ymbuz WITH KEY ymbuz_key BINARY SEARCH.
        tabix = sy-tabix.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'YMBUZ' ymbuz_key-zeilz ymbuz_key-xauto.
        ENDIF.
        READ TABLE xmseg INDEX tabix.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'XMSEG' tabix.
        ENDIF.
        READ TABLE xvm07m INDEX tabix.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'XVM07M' tabix.
        ENDIF.
        xvm07m-awewr = vm07m-awewr.
        xvm07m-aweww = vm07m-aweww.
        bukrs-waers = dm07m-umwae.
        bukrs-gjahr = mseg-gjahr.
        bukrs-monat = vm07m-monat = dm07m-ummon.
        bukrs-ktopl = dm07m-ktopl = dm07m-umkpl.
        bukrs-periv = dm07m-periv = dm07m-umper.
        dm07m-bwmod = dm07m-umbwm.
        dm07m-bklas = dm07m-umbkl.
        vm07m = xvm07m.
        IF NOT mseg-bnbtr IS INITIAL AND xbapi = 'X'.       "830707
          hbnbtr = mseg-bnbtr.                              "830707
          mseg = xmseg.                                     "830707
          mseg-bnbtr = hbnbtr.                              "830707
          CLEAR hbnbtr.                                     "830707
        ELSE.                                               "830707
          mseg = xmseg.
        ENDIF.                                              "830707
ENHANCEMENT-POINT F-SEGMENTE_ERSTELLEN_10 SPOTS ES_SAPMM07M.
        MOVE-CORRESPONDING dm07m TO xaccit.
        MOVE-CORRESPONDING vm07m TO xaccit.
        MOVE-CORRESPONDING mseg TO xaccit.
        MOVE-CORRESPONDING mkpf TO xaccit.
        MOVE-CORRESPONDING dm07m TO gs_accit_ext.           "593240
        MOVE-CORRESPONDING vm07m TO gs_accit_ext.           "593240
        MOVE-CORRESPONDING mseg TO gs_accit_ext.            "593240
* begin of note 362849
* If the calculation number has been generated during this posting,
* the new number (DM07M-UMKAL) has not been know during the generation
* of the m-segment and is still missing in VM07M-KALN1.
        xaccit-kaln1 = dm07m-umkal.                         "note 362849
        bukrs-umbuk = zmseg-bukrs.
        mseg-bualt = dm07m-umbua.
        c_kzuml = x.                                        "0495236
ENHANCEMENT-POINT f-segmente_erstellen_03 SPOTS es_sapmm07m.
      ELSE.
ENHANCEMENT-POINT f-segmente_erstellen_04 SPOTS es_sapmm07m.


        MOVE-CORRESPONDING dm07m TO xaccit.
        MOVE-CORRESPONDING vm07m TO xaccit.
        MOVE-CORRESPONDING mseg TO xaccit.
        MOVE-CORRESPONDING mkpf TO xaccit.
        MOVE-CORRESPONDING dm07m TO gs_accit_ext.           "593240
        MOVE-CORRESPONDING vm07m TO gs_accit_ext.           "593240
        MOVE-CORRESPONDING mseg TO gs_accit_ext.            "593240
        IF NOT cl_psm_core_switch_check=>psm_fm_core_gen( ) IS INITIAL.
**-- Material Reservation and FM integration
**--Setting the completion indicator
          IF NOT mseg-kblnr IS INITIAL AND
             NOT mseg-rsnum IS INITIAL.
            xaccit-erlkz = mseg-kzear.
            gs_accit_ext-elikz = mseg-kzear.
            gs_accit_ext-elikz_old = vm07m-kzear_old.
          ENDIF.
        ENDIF.
** Retrieve Funded Program if MEASURE is active. - Note 1576776
        IF NOT CL_FM_FUNDED_PROG_UTIL_APPL=>IS_MEASURE_ACTIVE( )  IS INITIAL.
          DATA: ls_measure TYPE lts_fm_measure.
          CLEAR ls_measure.

            IF mseg-zekkn IS NOT INITIAL.
              ls_measure-measure = CL_FM_FUNDED_PROG_UTIL_APPL=>GET_MEASURE_FROM_PO(
                                                                              IV_REFBN = mseg-ebeln
                                                                              IV_RFPOS = mseg-ebelp
                                                                              IV_RFKNT = mseg-zekkn
                                                                             ).
            ELSE.
              ls_measure-measure = CL_FM_FUNDED_PROG_UTIL_APPL=>GET_MEASURE_FROM_PO(
                                                                IV_REFBN = mseg-ebeln
                                                                IV_RFPOS = mseg-ebelp
                                                               ).
            ENDIF.
*          ENDIF.
          IF ls_measure-measure IS NOT INITIAL.
            MOVE-CORRESPONDING ls_measure TO xaccit.
          ENDIF.
        ENDIF.

ENHANCEMENT-POINT f-segmente_erstellen_06 SPOTS es_sapmm07m.


*       Fill the partner field for the stock posting.
*       If the receiving side is a materials posting, these
*       fields are taken from the material master. Otherwise,
*       the data which have been copied from MSEG remain.
*       IF NOT dm07m-kzuml IS INITIAL                            "sdp462
*          AND                                                   "sdp462
*          x156w-buzid = m                                       "sdp462
*          AND                                                   "sdp462
*          Receiving side is valuated
*          cl_mmim_cross_system=>valuated_movement_check(        "sdp462
*            i_wertu = dm07m-umwer                               "sdp462
*            i_sobkz = mseg-umsok                                "sdp462
*            i_kzbws = dm07m-umkzbws                             "sdp462
*            i_kzvbr = mseg-kzvbr ) = abap_true.                 "sdp462
*         xaccit-pargb  = dm07m-umgsb.
*         xaccit-pprctr = dm07m-umprc.
*       ENDIF.
        IF NOT dm07m-kzuml IS INITIAL.
          IF ( x156w-buzid = s AND x156w-xbgbb IS INITIAL ) OR "978159
              x156w-buzid = m.                              "978159
            IF cl_mmim_cross_system=>valuated_movement_check( "978159
               i_wertu = dm07m-umwer                        "978159
               i_sobkz = mseg-umsok                         "978159
               i_kzbws = dm07m-umkzbws                      "978159
               i_kzvbr = mseg-kzvbr ) = abap_true.          "978159
                IF NOT dm07m-umgsb is INITIAL.              "1590390
                   xaccit-pargb  = dm07m-umgsb.             "1038490
                ENDIF.                                      "1038490
                IF NOT dm07m-umprc is INITIAL.              "1590390
                   xaccit-pprctr = dm07m-umprc.             "1038490
                ENDIF.                                      "1038490
             ENDIF.                                         "1038490
            IF xaccit-pprctr IS INITIAL.                    "978159
              xaccit-pprctr = dm07m-umprc.                  "978159
            ENDIF.                                          "978159
            IF xaccit-pargb IS INITIAL.                     "978159
              xaccit-pargb  = dm07m-umgsb.                  "978159
            ENDIF.                                          "978159
          ENDIF.                                            "978159

*Begin Note 1038490
*For transfer postings, table xmseg build in program
*MM07MFM0_M_SEGMENTE_GENERIEREN should already contained the correct
*AC's prctr and pprctr. However, if the receiving line is created
*with xmseg-xauto NOT = 'X', this means that the line is created
*with zmseg ( supplying line ). Therefore, the profit center view
*is not correct and MM need to swap it correctly to AC.
*Eg. of movement type 453 with wertu = ' '.
          IF NOT x156w-xbgbb IS INITIAL AND x156w-vorsl = vorsl_gbb
             AND xaccit-xauto IS INITIAL.
            IF NOT xaccit-pprctr is INITIAL.
              xaccit-prctr = xaccit-pprctr.
              xaccit-pprctr = dm07m-umprc.
            ENDIF.
            IF NOT xaccit-pargb is INITIAL.
              xaccit-gsber = xaccit-pargb.
              xaccit-pargb = dm07m-umgsb.
            ENDIF.
          ENDIF.
*End Note 1038490

* Beg H754651
* transfer plant to plant for special stock unvaluated in both plants
* we never have buzid 'M' always buzid 'S'
* we post GBB to GBB

          IF x156w-buzid = s AND x156w-xbgbb IS INITIAL AND xmbwl = x.
            IF mseg-kzbew = 'L'.
              IF cl_mmim_cross_system=>valuated_movement_check(
                i_wertu = dm07m-umwer
                i_sobkz = mseg-umsok
                i_kzbws = dm07m-umkzbws
                i_kzvbr = mseg-kzvbr ) = abap_false.
                xaccit-pprctr = mseg-prctr.
              ENDIF.
            ENDIF.
          ENDIF.

          IF x156w-buzid = s AND x156w-xbgbb IS NOT INITIAL
          AND xmbwl = x.
            IF mseg-kzbew = 'L'.
              IF cl_mmim_cross_system=>valuated_movement_check(
                i_wertu = dm07m-umwer
                i_sobkz = mseg-umsok
                i_kzbws = dm07m-umkzbws
                i_kzvbr = mseg-kzvbr ) = abap_false.
                xaccit-pprctr = mseg-pprctr.
              ENDIF.
            ENDIF.
          ENDIF.
* End H754651
        ENDIF.
*<<<< End Note 649970 >>>>

* Third-Party
        IF vm07m-pstyp = '5' AND NOT x156w-xbgbb IS INITIAL              "note407178
                AND NOT xaccit-kdauf IS INITIAL.            "446713
          xaccit-sdstr = x.                                 "446713
        ENDIF.                                              "446713
        bukrs-waers = mseg-waers.
        bukrs-gjahr = mseg-gjahr.
        bukrs-monat = vm07m-monat.
        bukrs-ktopl = dm07m-ktopl.
        bukrs-periv = dm07m-periv.
*       Logic changed per note 495236.
        IF NOT mseg-bukrs = mseg-parbu.
ENHANCEMENT-SECTION F-SEGMENTE_ERSTELLEN_11 SPOTS ES_SAPMM07M .
          IF ( x156w-xbgbb IS INITIAL AND c_kzuml IS INITIAL )
          OR ( NOT x156w-xbgbb IS INITIAL AND NOT c_kzuml IS INITIAL )
          OR ( x156w-bustw = bustw_bnkr AND mseg-umwrk IS INITIAL )."1374708
*           Offset posting of original stock (WA04) and stock account
*           (as well WA04).
            xaccit-bukrs = mseg-bukrs.
            bukrs-umbuk = mseg-parbu.
          ELSE.
*           All other offset postings GBB/KBS except WA04, e.g. WA01,
*           WE06.
            xaccit-bukrs = mseg-parbu.
            xaccit-gjahr = dm07m-umgja.
            xaccit-monat = dm07m-ummon.
            bukrs-umbuk = mseg-bukrs.
            bukrs-waers = dm07m-umwae.
            bukrs-gjahr = dm07m-umgja.
            bukrs-monat = dm07m-ummon.
            bukrs-ktopl = dm07m-umkpl.
            bukrs-periv = dm07m-umper.
          ENDIF.
END-ENHANCEMENT-SECTION.
        ENDIF.
*       Similar logic for plant in XACCIT
        IF ( x156w-xbgbb IS INITIAL AND c_kzuml IS INITIAL ) OR
           ( NOT x156w-xbgbb IS INITIAL AND NOT c_kzuml IS INITIAL ).
        ELSE.
*         Change plant in this case.
*         This is necessary for both cases (BUKRS = PARBU, BUKRS <>
*         PARBU)
ENHANCEMENT-SECTION     f-segmente_erstellen_07 SPOTS es_sapmm07m.
          IF NOT mseg-umwrk IS INITIAL.
            xaccit-werks = mseg-umwrk.
          ENDIF.
END-ENHANCEMENT-SECTION.
        ENDIF.
      ENDIF.
* To avoid inconsistencies between material ledger and           "597011
* inventory management In case of active ingredient management   "597011
      IF ( mseg-bwart EQ bwart_141 OR mseg-bwart EQ bwart_142 ) "597011
        AND ( NOT t001k-mlbwa IS INITIAL                    "597011
        OR NOT t001k-mlbwv IS INITIAL ).                    "597011
        CLEAR xaccit-menge.                                 "597011
      ENDIF.                                                "597011
      PERFORM kdauf_pspnr_setzen USING xaccit-bustw
                                       x156w-buzid
                                       xaccit-sobkz
                                       xaccit-kdauf
                                       xaccit-kdpos
                                       xaccit-mat_kdauf
                                       xaccit-mat_kdpos
                                       xaccit-ps_psp_pnr
                                       xaccit-mat_pspnr.
      xaccit-urzeile = mseg-urzei.
      xaccit-matnr = mseg-matbf.
      xaccit-vbel2 = vm07m-kdauf_sd.
      xaccit-posn2 = vm07m-kdpos_sd.
      IF NOT vm07m-vbeln IS INITIAL.                            "1629952
        xaccit-posnr_sd = vm07m-vbelp. "Item number of SD doc.  "1612969
      ENDIF.                                                    "1629952

*     Note 1492032 Receiving system has to post a 6B1, mseg-matbf is
*     blank in case of the GBB line, but xaccit-matnr is required for
*     analyses on BSEG-MATNR
      IF dm07m-kzdir = 'R'.                                  "1492032\/
        IF mseg-matbf IS INITIAL AND x156w-vorsl = vorsl_gbb AND
           mseg-matnr = mseg-ummat AND NOT mseg-ummab is initial.
          xaccit-matnr = mseg-ummab.
        ENDIF.
      ENDIF.                                                 "1492032/\
*     Note 327190: in MB0A mkpf-xblnr is filled. In MB_CREATE case
*     (MIGO) mkpf-xblnr is not filled yet if GR for inbound delivery.
*     As it is item information, better to take xblnr from item anyway.
*     Xblnr_avis is filled from imkpf-lifex or from wueb earlier.

      IF t158-vgart NE vgart_wl.                            "701380
        IF NOT vm07m-xblnr_avis IS INITIAL AND NOT xmbwl IS INITIAL. "3271
          xaccit-xblnr = vm07m-xblnr_avis.                  "327190
        ENDIF.                                              "327190
      ENDIF.                                                "701380

      IF mseg-umsok = e AND NOT dm07m-umkzbws IS INITIAL AND
         ( t158-vgart = vgart_wf OR t158-vgart = vgart_ws
           OR t158-vgart = vgart_wr OR dm07m-fausw+12(1) = minus ).
        CLEAR xaccit-kdauf.
        CLEAR xaccit-kdpos.
      ELSEIF mseg-umsok = q AND NOT mseg-kzbws IS INITIAL AND
         ( t158-vgart = vgart_wf OR t158-vgart = vgart_ws
           OR t158-vgart = vgart_wr OR dm07m-fausw+11(1) = minus ).
        CLEAR xaccit-ps_psp_pnr.
      ENDIF.
    ENDIF.
    loc_bwmod = dm07m-bwmod.
    IF mseg-kzbew = f AND NOT x156w-xbgbb IS INITIAL AND
       NOT mseg-werks = dm07m-parwk AND NOT dm07m-parwk IS INITIAL.
      xaccit-werks = dm07m-parwk.
      loc_bwmod = dm07m-parbw.
* --------------------------------- Begin notes 789672 > 862723 > 981671
* Determine valuation class from proper plant
* Consider also split valuation / valuated special stock
      IF tcurm-bwkrs_cus = 1.
        xaccit-bwkey = xaccit-werks.
        SELECT SINGLE bklas eklas qklas
          INTO (bklas, eklas, qklas)
          FROM mbew
          WHERE matnr = xaccit-matnr AND bwkey = xaccit-bwkey
            AND bwtar = xaccit-bwtar.
        IF NOT sy-subrc IS INITIAL.
          SELECT SINGLE bklas eklas qklas
            INTO (bklas, eklas, qklas)
            FROM mbew
            WHERE matnr = xaccit-matnr AND bwkey = xaccit-bwkey.
        ENDIF.
        xaccit-bklas = bklas.
        IF mseg-sobkz = e AND mseg-kzbws = m AND NOT eklas IS INITIAL.
          xaccit-bklas = eklas.
        ELSEIF mseg-sobkz = q AND mseg-kzbws = m
           AND NOT qklas IS INITIAL.
          xaccit-bklas = qklas.
        ENDIF.
      ENDIF.
* ---------------------------------- End notes "789672 > 862723 > 981671
    ENDIF.
*   take over the last GR date from the reference doc          "1310801
    IF vm07m-xstor = '1' OR vm07m-xstor = '2'.                 "1310801
      xaccit-webud = xmkpf-budat.                              "1310801
    ELSEIF xbapi = 'X' AND NOT mseg-anln1 IS INITIAL.          "1342225
      xaccit-webud = xmkpf-budat.                              "1342225
    ENDIF.                                                     "1310801
    IF NOT xzcxcm-shkzg IS INITIAL.
      IF NOT mseg-smbln IS INITIAL AND vm07m-xstor = zwei.
        xaccit-awref_rev = mseg-smbln.
        xaccit-aworg_rev(4) = mseg-sjahr.
      ENDIF.
      IF mseg-matnr IS INITIAL.
        xaccit-menge = mseg-erfmg.
        xaccit-meins = mseg-erfme.
      ENDIF.
      bukrs-bukrs = xaccit-bukrs.
      IF bukrs-bukrs = bukrs-umbuk.
        bukrs-umbuk = zmseg-bukrs.
      ENDIF.
      bukrs-xumbw = x156w-xumbw.
      CLEAR bukrs-xruem.
      IF bukrs-xumbw IS INITIAL.
        bukrs-xruem = mseg-xruem.
      ENDIF.
      xaccit-xnegp = dm07m-xstbw.
      xaccit-xbgbb = x156w-xbgbb.
      xaccit-xumbw = x156w-xumbw.
      IF x156w-xumbw IS INITIAL.
        IF NOT x156w-x2doc IS INITIAL AND NOT mkpf-bla2d IS INITIAL AND
           NOT dm07m-x2fdo IS INITIAL AND
           NOT dm07m-xewrx IS INITIAL AND NOT dm07m-xeink IS INITIAL.
          xaccit-blart = mkpf-bla2d.
        ENDIF.
      ELSE.
        xaccit-blart = mkpf-blaum.
        xaccit-gjahr = bukrs-gjahr = vm07m-lfgja.
        xaccit-monat = bukrs-monat = vm07m-lfmon.
        CALL FUNCTION 'PERIOD_DAY_DETERMINE'
          EXPORTING
            i_gjahr = bukrs-gjahr
            i_monat = bukrs-monat
            i_periv = bukrs-periv
          IMPORTING
            e_fday  = xaccit-budat.
      ENDIF.

* MAA EhP4 begin -------------------------------------------"MAA EhP4
      IF f-xbnk IS NOT INITIAL.
*       for the distribution of delivery cost the infomation is needed
*       to map these lines to xaccounting_dc
        xaccit-stunr = xzcxcb-stunr.
        xaccit-zaehk = xzcxcb-zaehk.
      ENDIF.
* MAA EhP4 end ---------------------------------------------"MAA EhP4

      DATA vorsl LIKE x156w-vorsl. CLEAR vorsl.
      DATA komok LIKE t156x-komok. CLEAR komok.
      DATA kzvbr LIKE mseg-kzvbr. kzvbr = zmseg-kzvbr.
      rc = 2.
      IF f-xbnk IS INITIAL OR x156w-vorsl = vorsl_kdm.      "N980402
        vorsl = x156w-vorsl.
        IF x156w-vorsl = vorsl_kbs AND mseg-kzvbr = a.
          vorsl = vorsl_anl.
        ENDIF.
* Begin N980402
        IF f-xbnk IS INITIAL AND x156w-vorsl = vorsl_kdm.
          f_156w_save = x156w.
          READ TABLE x156w WITH KEY bustw = mseg-bustw
                                    vorsl = vorsl_kdm.
          IF NOT sy-subrc IS INITIAL.
* String is not buffered; only possible for Transfers use WE01
            SELECT * FROM t156w INTO x156w WHERE bustw = 'WE01'
                                            AND vorsl = vorsl_kdm.
              EXIT.
            ENDSELECT.
          ENDIF.
        ENDIF.
* End N980402
ENHANCEMENT-POINT f-segmente_erstellen_08 SPOTS es_sapmm07m.
* Note 389931:
* The following statements can also be found in FM07MFK0 KONTO_PRUEFEN.
* If KZBWS is set, we always read T156X with KZVBR=space except if
* 601 (im_process=l and kzbew <> B) or if QM mvt 331 (xkoko=x)
* where it can space or V. Other movement types (2xx, 5xx)
* have xkoko=y which means kzvbr will be cleared if kzbws is set.
* Not sure why check with kzvbr=E is necessary here as also
* switched in MB_CREATE.
* In case of KZBWS set, we never read T156X with E or P!
        SELECT SINGLE * FROM t156 WHERE bwart = zmseg-bwart. "482317
ENHANCEMENT-SECTION     f_segmente_erstellen_01 SPOTS es_sapmm07m.
        IF zmseg-sobkz = e OR zmseg-sobkz = q.
          IF NOT zmseg-kzbws IS INITIAL.
*     601 or similar movement has two possibilities if KZBWS is set:
*     - original KZVBR is space -> no acct assgnt   (leads to VAX)
*     - original KZVBR is E/V/P -> V - acct assignt (leads to VAY)
            IF NOT zmseg-kzbew = b AND NOT zmseg-kzbew = f  "494584
              AND im_process = l AND dm07m-umkzvbr = e
                AND t156-xkoko <> y.                        "482317
*             no cross company movement (two-step or one-step)
              IF vm07m-kzbwa <> '03' AND vm07m-kzbwa <> '04'. "554768
                dm07m-umkzvbr = v.
              ENDIF.                                        "554768
            ENDIF.
            kzvbr = dm07m-umkzvbr.
          ENDIF.
          IF kzvbr NE v AND NOT zmseg-kzbws IS INITIAL.
            CLEAR kzvbr.
          ELSE.
            IF kzvbr IS INITIAL.
              kzvbr = zmseg-sobkz.
            ENDIF.
          ENDIF.
*       counterpart of 601 with SOBKZ ' ' and KZBVR NOT INITIAL"1660570
*       here it should be 601 T only                           "1660570
        ELSEIF zmseg-sobkz = t AND vm07m-kzbwa IS INITIAL AND  "1660570
               im_process = l.                                 "1660570
          IF zmseg-kzbew = l AND t156-xkoko <> y.              "1660570
*           x_lips from MM07MFK0_LIEFERUNG_PRUEFEN             "1660570
            READ TABLE x_lips WITH KEY vbeln = zmseg-mat_kdauf "1660570
                                       posnr = zmseg-mat_kdpos."1660570
            IF sy-subrc IS INITIAL.                            "1660570
              IF ( x_lips-sobkz = e OR x_lips-sobkz = q ) AND  "1660570
                 NOT dm07m-umkzvbr IS INITIAL.                 "1660570
                kzvbr = dm07m-umkzvbr  = v.                    "1660570
              ELSEIF x_lips-sobkz IS INITIAL.                  "1660570
                kzvbr = dm07m-umkzvbr.                         "1660570
              ELSE.                                            "1660570
                CLEAR kzvbr.                                   "1660570
              ENDIF.                                           "1660570
            ENDIF.                                             "1660570
          ENDIF.                                               "1660570
        ENDIF.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-SECTION     f-segmente_erstellen_09 SPOTS es_sapmm07m.
        SELECT SINGLE * FROM t156x WHERE bwart = zmseg-bwart
                                   AND   wertu = zmseg-wertu
                                   AND   mengu = zmseg-mengu
                                   AND   sobkz = zmseg-sobkz
                                   AND   kzbew = zmseg-kzbew
                                   AND   kzvbr = kzvbr
                                   AND   bustw = x156w-bustw
                                   AND   cnt02 = x156w-cnt02.
END-ENHANCEMENT-SECTION.
        rc = sy-subrc.
        t156x-kzvbr = zmseg-kzvbr.
        IF sy-subrc IS INITIAL.
          xaccit-xpkon = t156x-xpkon.
          komok = t156x-komok.
        ENDIF.
        IF NOT f_156w_save IS INITIAL.                      "N980402
          x156w = f_156w_save.                              "N980402
        ENDIF.                                              "N980402
        IF NOT sy-subrc IS INITIAL OR t156x-xpkon IS INITIAL
                                   AND f-xbnk IS INITIAL.   "N980402
          PERFORM jv_f_seg_erstellen_1.
          MOVE-CORRESPONDING accit_mb TO xaccit.
          PERFORM jv_f_seg_erstellen_2.
          IF ( NOT mseg-kzbew = b )                         "note106582
             OR NOT mseg-kzvbr IS INITIAL.
* Requested from IS-PS: The mentioned fields should not be cleared
* during a goods receipt to PO with account assignement in the WRX line.
            IF NOT x156w-bustw = 'WE06'.
              CLEAR: xaccit-fistl, xaccit-geber, xaccit-fipos,
                     xaccit-grant_nbr, xaccit-fkber, xaccit-budget_pd.
              IF NOT cl_psm_core_switch_check=>psm_fm_core_gen( ) IS INITIAL.
                IF NOT mseg-rsnum IS INITIAL.       " Material Reservation Integration
                  CLEAR: xaccit-kblnr, xaccit-kblpos.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
* Begin N980402
        IF x156w-bustw = bustw_bnkr AND x156w-vorsl = vorsl_kdm.
          IF zmseg-bustw = bustw_we06.
            SELECT SINGLE * FROM t156x WHERE bwart = zmseg-bwart
                                       AND   wertu = zmseg-wertu
                                       AND   mengu = zmseg-mengu
                                       AND   sobkz = zmseg-sobkz
                                       AND   kzbew = zmseg-kzbew
                                       AND   kzvbr = kzvbr
                                       AND   bustw = bustw_we06
                                       AND   cnt02 = '03'.
          ELSEIF zmseg-bustw = bustw_we01.
            SELECT SINGLE * FROM t156x WHERE bwart = zmseg-bwart
                                       AND   wertu = zmseg-wertu
                                       AND   mengu = zmseg-mengu
                                       AND   sobkz = zmseg-sobkz
                                       AND   kzbew = zmseg-kzbew
                                       AND   kzvbr = kzvbr
                                       AND   bustw = bustw_we01
                                       AND   cnt02 = '04'.
          ENDIF.
          komok = t156x-komok.
        ENDIF.
* End N980402
      ELSE.
        vorsl = xzcxcb-vorsl.
        IF vorsl = vorsl_kbs.
          rc = 0.
          xaccit-xpkon = t156x-xpkon = x.
          IF mseg-kzvbr = a.
            vorsl = vorsl_anl.
          ENDIF.
        ELSE.
          MOVE-CORRESPONDING accit_mb TO xaccit.
        ENDIF.
        xaccit-kschl = xzcxcb-kschl.
        xaccit-lifnr = xzcxcb-lifnr.
        CLEAR xaccit-vbund.
* clear customer for neutral accruals                            "746206
* otherwise FI will derive VBUND company from customer master    "746206
        IF yekbnk-bewtp = 'C'.                              "746206
          CLEAR xaccit-kunnr.                               "746206
        ENDIF.                                              "746206
      ENDIF.
      CLEAR bukrs-summe_s.
      CLEAR bukrs-summe_h.
      CLEAR bukrs-saldo.
* clear customer for delivery from consignment stock             "842900
* otherwise FI will derive VBUND from customer master            "842900
      IF mseg-kzbew = l AND                                 "842900
         mseg-sobkz = k AND                                 "842900
         x156w-vorsl = vorsl_kon AND                        "842900
         NOT xaccit-lifnr IS INITIAL.                       "842900
        CLEAR: xaccit-kunnr, xaccit-vbund.                  "842900
      ENDIF.                                                "842900
      IF xzcxcm-shkzg = s OR xzcxcm-shkzg = x.
        PERFORM f-segmente_erzeugen USING s
                                          vorsl
                                          komok
                                          loc_bwmod
                                          f-xbnk
                                          l_shkzg.          "HW578078
      ENDIF.
      IF xzcxcm-shkzg = h OR xzcxcm-shkzg = x.
        PERFORM f-segmente_erzeugen USING h
                                          vorsl
                                          komok
                                          loc_bwmod
                                          f-xbnk
                                          l_shkzg.          "HW578078
      ENDIF.
      APPEND yfbuz.
      COLLECT bukrs.
    ENDIF.
    t_index = t_index + 1.
  ENDLOOP.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'X156W' f-bustw.
  ENDIF.

ENDFORM.                    "f-segmente_erstellen