*---------------------------------------------------------------------*
*       FORM UMLAGERMAT_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Das Umlagermaterial wird gelesen.                             *
*---------------------------------------------------------------------*
FORM umlagermat_pruefen USING u-matnr LIKE mseg-matnr
                              u-werks LIKE mseg-werks
                              u-lgort LIKE mseg-lgort
                              u-charg LIKE mseg-charg
                              u-bwtar LIKE mseg-bwtar
                              u-kdauf LIKE mseg-kdauf
                              u-kdpos LIKE mseg-kdpos
                              u-pspnr LIKE mseg-ps_psp_pnr
                              u-umsok LIKE mseg-umsok
                              u-xenqu TYPE c   .

  DATA: lifnr LIKE mseg-lifnr,
        kunnr LIKE mseg-kunnr,
        kdauf LIKE mseg-kdauf,
        pspnr LIKE mseg-ps_psp_pnr,
        kdpos LIKE mseg-kdpos,
        plpla LIKE mseg-plpla,
        l_lgort LIKE mseg-lgort,                                "586336
        l_kzbws TYPE kzbws,                                     " 560226
        l_xkzbws_change TYPE c.                                  "627312

 DATA: ls_isu_pipeline_preis_ermittel TYPE isu_pipeline_preis_ermitteln. "IS2ERP

ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_03 SPOTS ES_SAPMM07M STATIC.
  DATA: l_156m_smarc TYPE t156m-smarc. "needed for E048 check
  DATA: ls_isu_material_lesen TYPE isu_material_lesen. "IS2ERP
  DATA: LS_ISU_SONDERBESTAND_PRUEFEN TYPE ISU_SONDERBESTAND_PRUEFEN. "IS2ERP

ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_04 SPOTS ES_SAPMM07M.
  PERFORM sonderbestand_pruefen(sapfm07m) USING u-umsok
                                                mseg-lifnr
                                                mseg-kunnr
                                                   u-kdauf
                                                   u-kdpos
                                                mseg-plpla
                                                   u-pspnr
                                                     lifnr
                                                     kunnr
                                                     kdauf
                                                     kdpos
                                                     plpla
                                                     pspnr
                                                LS_ISU_SONDERBESTAND_PRUEFEN. "IS2ERP     .

ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_05 SPOTS ES_SAPMM07M.
  vw = s.
  IF mseg-shkzg = s.
    vw = h.
  ENDIF.
  DATA xbwtarneu TYPE c. CLEAR xbwtarneu.
* if mseg-mengu is initial and not mseg-wertu is initial.
*   perform menge_umrechnen(sapfm07m) using u-matnr.
* endif.
  l_kzbws = dm07m-umkzbws.                                      " 560226
* Avoid that batch is created automatically in case of remove    "586336
* from storage location and receiving storage location <> space  "586336
  IF t156-bustr = '303'.                                         "586336
    l_lgort = u-lgort.                                           "586336
    CLEAR u-lgort.                                               "586336
  ENDIF.                                                         "586336
ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_06 SPOTS ES_SAPMM07M.
  PERFORM material_lesen(sapfm07m) USING    u-matnr
                                        dm07m-umbwk
                                            u-bwtar
                                            u-werks
                                            u-lgort
                                            u-charg
                                              vw
                                         t158-trtyp
                                            u-umsok
                                        dm07m-umsof
                                        dm07m-umsol
                                        dm07m-umsov
                                              lifnr
                                              kunnr
                                              kdauf
                                              kdpos
                                              plpla
                                              xbwtarneu
                                        dm07m-umlfg
                                        dm07m-umlfm
                                              x
                                            u-xenqu
                                        dm07m-umxrm
                                        dm07m-umxvk
                                        dm07m-umxbn
                                        dm07m-umxln
                                        dm07m-umxsm
                                        dm07m-umxsv
                                        dm07m-umxsk
                                        dm07m-umxso
                                        dm07m-umxsw
                                        dm07m-umxse
                                        dm07m-umxsq
                                        dm07m-umxstau
                                              pspnr
                                        dm07m-umkzbws
                                        dm07m-umxlaut
                                        dm07m-umberid            "454320
                                        ls_isu_material_lesen "IS2ERP
                                CHANGING    l_xkzbws_change.     "627312

ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_07 SPOTS ES_SAPMM07M.
  IF l_lgort <> SPACE.                                           "586336
    u-lgort = l_lgort.                                           "586336
    CLEAR l_lgort.                                               "586336
  ENDIF.                                                         "586336
  CHECK NOT u-xenqu IS INITIAL.
* Source and target KZBWS must be equal in case of new segment  "1308429
  IF mseg-kzbws <> dm07m-umkzbws AND mseg-kzbew IS INITIAL AND  "1308429
     ( ( mtcor-rmssa = x AND mseg-umsok = 'E' AND               "1368870
         mseg-sobkz = 'E' AND  mseg-kdauf IS INITIAL AND        "1368870
         NOT mseg-mat_kdauf IS INITIAL ) OR                     "1368870
       ( mtcor-rmssa = x AND mseg-umsok = 'T' AND               "SIT
         mseg-sobkz = 'T' AND  mseg-kdauf IS INITIAL AND        "SIT
         NOT mseg-mat_kdauf IS INITIAL ) OR                     "SIT
       ( mtcor-rmssq = x AND mseg-umsok = 'Q' AND               "1368870
         mseg-sobkz = 'Q' AND mseg-ps_psp_pnr IS INITIAL AND    "1368870
         NOT mseg-mat_pspnr IS INITIAL ) ).                     "1368870
       mseg-kzbws = l_kzbws.                                    "1308429
       MESSAGE e242.                                            "1308429
  ELSEIF l_kzbws <> dm07m-umkzbws.                              " 560226
    IF mseg-kzbew = b OR mseg-kzbew = f.                        " 560226
      mseg-kzbws = kzbws.                                       " 560226
      MESSAGE e242.                                             " 560226
*   condition, when KZBWS has to be changed because a non-valuated
*   material must not be valuated when it belongs to project stock
*   note 607325: logic for MSSQ extended to MSSA
*   note 627312: make check easier - was it done intentionally?
    ELSEIF NOT l_xkzbws_change = x.                             " 627312
      CALL FUNCTION 'ME_CHECK_T160M'                            " 560226
           EXPORTING                                            " 560226
                i_arbgb = 'M7'                                  " 560226
                i_msgnr = '242'                                 " 560226
                i_msgvs = msgvs                                 " 560226
           EXCEPTIONS                                           " 560226
                nothing = 00                                    " 560226
                warning = 01                                    " 560226
                error   = 02.                                   " 560226
      CASE sy-subrc.                                            " 560226
        WHEN 0.                                                 " 560226
          mseg-kzbws = kzbws.                                   " 560226
          MESSAGE e242.                                         " 560226
        WHEN 1.                                                 " 560226
          MESSAGE w242.                                         " 560226
        WHEN 2.                                                 " 560226
          mseg-kzbws = kzbws.                                   " 560226
          MESSAGE e242.                                         " 560226
      ENDCASE.                                                  " 560226
*   Bewertungssteuerung im Materialstamm und Sonderbestand weichen ab
    ENDIF.                                                      " 560226
  ENDIF.                                                        " 560226
* Material is split valuated. User entered a receiving valuation
* type (u-bwtar) but MATERIAL_READ has exported none (MBEFU-BWTAR)
* => it means the entered valuation type does not exist (E077)
  IF NOT mbefu-bwtty IS INITIAL AND
     mbefu-bwtar IS INITIAL AND
     NOT u-bwtar IS INITIAL.
      MESSAGE e077 WITH u-matnr dm07m-umbwk u-bwtar.
  ENDIF.
* There is no valuation for a single batch and there is no      "559040
* entry in the valuation table                                  "559040
* If valuation record does not exist in MBEW, valuated special
* stock entry must not be created -> note 957980
  IF mbefu-kzbaa <> X AND mbefu-bwtty <> SPACE.           "957980_start
    IF mtcor-rmbew = X.
      MESSAGE e077 WITH u-matnr dm07m-umbwk u-bwtar.
    ELSEIF mtcor-rebew = X OR mtcor-rqbew = X.
      SELECT SINGLE * FROM mbew WHERE
                      matnr = u-matnr AND
                      bwkey = dm07m-umbwk AND
                      bwtar = u-bwtar.
      IF sy-subrc IS NOT INITIAL.
        MESSAGE e077 WITH u-matnr dm07m-umbwk u-bwtar.
      ENDIF.
    ENDIF.                                                 "957980_end
  ENDIF.                                                        "559040
* Customizeable message if batch and valuation type are not     "559525
* equal in case of single batch valuation                       "559525
  IF u-bwtar NE u-charg                                         "559525
    AND u-bwtar <> space AND u-charg <> space.                  "559525
    if mbefu-XCHPF is initial.                                  "801097
*     for split valuated materials without batches charg <> bwtar
*     can lead to wrong MCHA entries and even to MBEW inconsistencies.
*     note 801097
      MESSAGE e426 with u-charg u-bwtar u-matnr u-werks.
*   otherwise message 426 for single batch valuation only       "937018
    elseif mbefu-kzbaa = X.                                     "937018
      PERFORM NACO_ERMITTELN_V4(SAPFM07M) USING 'M7' '426'
              u-charg u-bwtar u-matnr u-werks.
    endif.
  ENDIF.                                                        "559525
* All movements to stock in transfer (MARC-UMLMC) are forbidden
* for split valuated materials because UMLMC is neutral (no
* connection to a valuation type). No 303 - 305 movement.
  IF NOT mbefu-bwtty IS INITIAL AND mbefu-bwtar IS INITIAL.
    MESSAGE e048.
  ENDIF.
* Above coding does not work if receiving storage location set as
* input in T156B (for 303). So additional check necessary.
* In table T156M a posting to stock in transfer has T156M-SMARC = WU1.
* 305 is checked in MENGE_PRUEFEN with VM07M-SMARC.
  IF NOT mbefu-bwtty IS INITIAL.
    SELECT smarc FROM t156m INTO l_156m_smarc
                 WHERE bustm = mseg-bustm.
      IF l_156m_smarc = 'WU1'.
        MESSAGE e048.
      ENDIF.
    ENDSELECT.
  ENDIF.
* 801097_v
  if not dm07m-umbar_po is initial and not u-bwtar is initial and
     dm07m-umbar_po <> u-bwtar.
    MESSAGE e426 with u-charg u-bwtar u-matnr u-werks.
  endif.
* 801097_^
* Transfer posting material to material (BWART 309) is not allowed for generic articles
  IF mbefu-attyp = attyp-sam AND mseg-matnr <> mseg-ummat
    AND NOT mseg-ummat IS INITIAL.
    MESSAGE e316(M7).
  ENDIF.
  IF mbefu-mengu IS INITIAL AND
     NOT    u-umsok = e AND NOT    u-umsok = q AND
     ( dm07m-umxvk IS INITIAL OR mbefu-wertu IS INITIAL ).
    MESSAGE e097.
  ENDIF.
ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_01 SPOTS ES_SAPMM07M.
  IF mbefu-mengu IS INITIAL AND NOT mbefu-wertu IS INITIAL.
    IF NOT    u-umsok IS INITIAL.
      MESSAGE e311.
    ENDIF.
  ELSE.
    IF mseg-mengu IS INITIAL.
      mseg-meins = mbefu-meins.
    ENDIF.
    IF NOT mseg-meins = mbefu-meins.
ENHANCEMENT-SECTION EHP606_UMLAGERMAT_PRUEFEN_01 SPOTS ES_SAPMM07M .
      MESSAGE e105 WITH mseg-meins mbefu-meins.
END-ENHANCEMENT-SECTION.
    ENDIF.
*   Background posting of cross-system movement. As there is not
*   status for "in transit", this posting is done without serial
*   numbers. The check has to be removed because the issuing profile
*   is unknown.
    IF NOT dm07m-sernp = mbefu-sernp AND
       cl_mmim_cross_system=>gf_mode <> r.                       "sdp462
      MESSAGE e174 WITH mseg-werks mbefu-werks.
    ENDIF.
   IF t158-trtyp = h AND inventur IS INITIAL AND NOT u-charg IS INITIAL.
      PERFORM chargendaten_mat_umlagerung USING u-matnr
                                                u-werks
                                                u-charg.
      PERFORM chargendaten_pruefen(sapfm07m) USING u-matnr
                                                   u-werks
                                                   u-charg
                                                   u-lgort
                                                   x.
    ENDIF.
  ENDIF.
  PERFORM segmentdaten_mat_umlagerung(sapfm07m).
  mseg-ummat = u-matnr.
  mseg-umwrk = u-werks.
* PPF: begin Rel. 4.6
  PERFORM ermittle_inv_belege(sapfm07m)  USING mseg-ummab   " 367065
                                               u-lgort
                                               u-charg
                                               u-umsok
                                           dm07m-umlfg
                                               u-werks
                                               u-kdauf
                                               u-kdpos
                                            mseg-lifnr
                                            mseg-kunnr
                                           mbefu-mengu
                                           mbefu-wertu
                                           dm07m-umibpoi
                                           u-xenqu.
* PPF: end Rel. 4.6
  CALL FUNCTION 'MB_FILL_MARC_ENQUEUE_TABLE'
       EXPORTING
            mbefu  = mbefu
            rmarc  = xmtcor-rmarc
            rmarch = xmtper-rmarch
            mclfm  = xmtper-mclfm
            mcgja  = xmtper-mcgja
            lfgja  = dm07m-umlfg
            lfmon  = dm07m-umlfm
       TABLES
            xmarc  = xmarc.
ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_02 SPOTS ES_SAPMM07M.
  IF NOT u-lgort IS INITIAL AND NOT    u-umsok = e AND
     NOT    u-umsok = o AND NOT    u-umsok = v AND NOT    u-umsok = w.
    CALL FUNCTION 'MB_FILL_MARD_ENQUEUE_TABLE'
         EXPORTING
              mbefu  = mbefu
              rmard  = xmtcor-rmard
              rmardh = xmtper-rmardh
              mdlfm  = xmtper-mdlfm
              mdgja  = xmtper-mdgja
              lfgja  = dm07m-umlfg
              lfmon  = dm07m-umlfm
         TABLES
              xmard  = xmard.
    IF NOT u-charg IS INITIAL.
      CALL FUNCTION 'MB_FILL_MCHB_ENQUEUE_TABLE'
           EXPORTING
                mbefu  = mbefu
                rmchb  = xmtcor-rmchb
                rmchbh = xmtper-rmchbh
                chlfm  = xmtper-chlfm
                chgja  = xmtper-chgja
                lfgja  = dm07m-umlfg
                lfmon  = dm07m-umlfm
           TABLES
                xmchb  = xmchb.
    ENDIF.
  ENDIF.
  IF NOT u-charg IS INITIAL.
* note 601357: up to now, field XBWTARNEU was used to set the flag XDBUP
* in XMCHA. As the field is only used in MATERIAL_LESEN when the
* material is split valuated and handled nowhere else, it could never be
* filled for materials with batches but no split valuation. If the batch
* level is not set on material/ plant (that means KZDCH = 0) the flag is
* set again later in SPERRTABELLEN_RECHNUNG_MCHA (LMBMVFS0).
* Before the correction, function MB_FILL_MCHA_ENQUEUE_TABLE was always
* called with parameter rmcha = xbwtarneu.
* New logic: If the entry MCHA has to be created (MTCOR-RMCHA = X), for
* a material with batch management, the update flag is set from this
* field, otherwise it will be set as before.
* Note 1136739: Even if the MCHA exists already, we have to update MCHA
*               if it does not yet have a BWTAR for material with split
*               valuation (XBWTARNEU = X).
*               Furthermore added MCH1_ENQUEUE (forgotten by 601357?)
    IF NOT mbefu-xchpf IS INITIAL AND xbwtarneu IS INITIAL.     "1136739
      CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'
           EXPORTING
                mbefu = mbefu
                rmcha = xmtcor-rmcha
                xdbup = xmtcor-rmcha
                kzdch = kzdch
           TABLES
                xmcha = xmcha.
      CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'
           EXPORTING
                mbefu = mbefu
                rmch1 = xmtcor-rmch1
                kzdch = kzdch
           TABLES
                xmch1 = xmch1.
    ELSEIF mbefu-xchpf IS INITIAL AND mbefu-xchar = x.          "1471714
*   split valuation only                                        "1471714
      CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'                "1471714
           EXPORTING                                            "1471714
                mbefu = mbefu                                   "1471714
                rmcha = xmtcor-rmcha                            "1471714
                xdbup = xbwtarneu                               "1471714
                kzdch = kzdch                                   "1471714
           TABLES                                               "1471714
                xmcha = xmcha.                                  "1471714
    ELSE.                                                        "601357
      CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'
           EXPORTING
                mbefu = mbefu
                rmcha = xmtcor-rmcha
                xdbup = xbwtarneu
                kzdch = kzdch
           TABLES
                xmcha = xmcha.
      CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'                "1136739
           EXPORTING                                            "1136739
                mbefu = mbefu                                   "1136739
                rmch1 = xmtcor-rmch1                            "1136739
                kzdch = kzdch                                   "1136739
           TABLES                                               "1136739
                xmch1 = xmch1.                                  "1136739
    ENDIF.
    IF u-lgort IS INITIAL AND u-charg IS NOT INITIAL.
      CALL FUNCTION 'MB_FILL_MSTB_ENQUEUE_TABLE'                "SIT
        EXPORTING
          MBEFU         = mbefu
          RMSTB         = xmtcor-rmstb
          LFGJA         = dm07m-umlfg
          LFMON         = dm07m-umlfm
          RMSTBH        = xmtper-rmstbh
          TBLFM         = xmtper-tblfm
          TBGJA         = xmtper-tbgja
          sobkz         = u-umsok
        TABLES
          XMSTB         = xmstb.
    ENDIF.
  ENDIF.
* PPF Rel.4.6: begin
  READ TABLE xtiseg INDEX 1.
  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'MB_FILL_ISEG_ENQUEUE_TABLE'
     EXPORTING
          ibpoi   = dm07m-umibpoi
     TABLES
          xxiseg  = xxiseg
          ziseg   = xtiseg.
   ENDIF.
* PPF Rel. 4.6: end

*  PERFORM umlagerung_string_pruefen.                        "note331195
  CALL FUNCTION 'MB_TRANSFER_STRING_CHECK'                   "note331195
       EXPORTING                                             "note331195
          I_BUSTM           = S156S-BUSTM                    "note331195
          IS_MSEG           = MSEG                           "note331195
          IS_DM07M          = DM07M                          "note331195
          I_KZDCH           = KZDCH                          "note331195
          I_ATTYP           = MBEFU-ATTYP                    "note331195
       TABLES                                                "note331195
          CT_T156M          = X156M                          "note331195
       CHANGING                                              "note331195
          CS_T156M          = T156M                          "note331195
       EXCEPTIONS                                            "note331195
          INTERNAL_ERROR    = 1                              "note331195
          OTHERS            = 2.                             "note331195

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO        "note331195
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.         "note331195
  ENDIF.                                                     "note331195


  CASE    u-umsok.
    WHEN space.
      EXIT.
    WHEN b.
ENHANCEMENT-POINT UMLAGERMAT_PRUEFEN_08 SPOTS ES_SAPMM07M.
    WHEN e.
      IF NOT kdauf IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSKA_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmska  = xmtcor-rmska
                  rmskah = xmtper-rmskah
                  kalfm  = xmtper-kalfm
                  kagja  = xmtper-kagja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kdauf  = kdauf
                  kdpos  = kdpos
                  sobkz  = u-umsok
             TABLES
                  xmska  = xmska.
        IF u-charg IS NOT INITIAL AND u-lgort IS INITIAL.      "SIT
          CALL FUNCTION 'MB_FILL_MSTE_ENQUEUE_TABLE'
                EXPORTING
                    mbefu  = mbefu
                    rmste  = xmtcor-rmste
                    rmsteh = xmtper-rmsteh
                    tegja  = xmtper-tegja
                    telfm  = xmtper-telfm
                    lfgja  = dm07m-umlfg
                    lfmon  = dm07m-umlfm
                    kdauf  = kdauf
                    kdpos  = kdpos
                    sobkz  = u-umsok
                TABLES
                    xmste  = xmste.
        ENDIF.

        CALL FUNCTION 'MB_FILL_MSSA_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmssa  = xmtcor-rmssa
                  rmssah = xmtper-rmssah
                  salfm  = xmtper-salfm
                  sagja  = xmtper-sagja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kdauf  = kdauf
                  kdpos  = kdpos
                  sobkz  = u-umsok
             TABLES
                  xmssa  = xmssa.
      ENDIF.
      IF mseg-sobkz =    u-umsok AND mseg-kdauf IS INITIAL
    AND ( ( NOT xmtcor-rmssa IS INITIAL AND NOT mseg-kzbws IS INITIAL )
              OR NOT xmtcor-rebew IS INITIAL ).
        dm07m-umkzbws = mseg-kzbws.
      ENDIF.
      mseg-kdauf = kdauf.
      mseg-kdpos = kdpos.
    WHEN k.
      IF NOT lifnr IS INITIAL.
        IF NOT tcurm-konsi IS INITIAL. "4.0konsi
          data: p_netwr_before type vm07m-netwr.    "EP 2.0 konsi
          p_netwr_before = vm07m-netwr.             "EP 2.0 konsi
ENHANCEMENT-POINT MM07MFU0_UMLAGERMAT_PRUEFEN_09 SPOTS ES_MM07MTOP.

          PERFORM pipeline_preis_ermitteln(sapfm07m) USING    u-umsok
                                                           mseg-ummat
                                                           mseg-umwrk
                                                           lifnr
                                                           ls_isu_pipeline_preis_ermittel. "IS2ERP
ENHANCEMENT-POINT MM07MFU0_UMLAGERMAT_PRUEFEN_10 SPOTS ES_MM07MTOP.

          if p_netwr_before <> vm07m-netwr.         "EP 2.0 konsi
*           receiver's price is different to sender's price
            message e395.                           "EP 2.0 konsi
          endif.                                    "EP 2.0 konsi
        ENDIF.                         "4.0konsi
        CALL FUNCTION 'MB_FILL_MKOL_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmkol  = xmtcor-rmkol
                  rmkolh = xmtper-rmkolh
                  kllfm  = xmtper-kllfm
                  klgja  = xmtper-klgja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  lifnr  = lifnr
                  sobkz  = u-umsok
             TABLES
                  xmkol  = xmkol.
      ENDIF.
    WHEN m.
      IF NOT lifnr IS INITIAL.
        CALL FUNCTION 'MB_FILL_MKOL_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmkol  = xmtcor-rmkol
                  rmkolh = xmtper-rmkolh
                  kllfm  = xmtper-kllfm
                  klgja  = xmtper-klgja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  lifnr  = lifnr
                  sobkz  = u-umsok
             TABLES
                  xmkol  = xmkol.
      ENDIF.
    WHEN l.
    WHEN o.
* OM EhP 604
    IF gv_mm_om1_sfws_sc_active = abap_true.
      IF t156-bustr EQ bustr_64A.
        MOVE xbbefu-emlif TO lifnr.
      ENDIF.
    ENDIF.
*/ OM EhP 604
      IF NOT lifnr IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSLB_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmslb  = xmtcor-rmslb
                  rmslbh = xmtper-rmslbh
                  lblfm  = xmtper-lblfm
                  lbgja  = xmtper-lbgja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  lifnr  = lifnr
                  sobkz  = u-umsok
             TABLES
                  xmslb  = xmslb.
        CALL FUNCTION 'MB_FILL_MSSL_ENQUEUE_TABLE'
             EXPORTING
                  mbefu = mbefu
                  rmssl = xmtcor-rmssl
                  lfgja = dm07m-umlfg
                  lfmon = dm07m-umlfm
                  lifnr = lifnr
                  sobkz = u-umsok
             TABLES
                  xmssl = xmssl.
      ENDIF.
    WHEN q.
      IF NOT pspnr IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSPR_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmspr  = xmtcor-rmspr
                  rmsprh = xmtper-rmsprh
                  prlfm  = xmtper-prlfm
                  prgja  = xmtper-prgja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  pspnr  = pspnr
                  sobkz  = u-umsok
             TABLES
                  xmspr  = xmspr.
        IF u-lgort IS INITIAL AND u-charg IS NOT INITIAL.    "SIT
          CALL FUNCTION 'MB_FILL_MSTQ_ENQUEUE_TABLE'
            EXPORTING
              LFGJA         = dm07m-umlfg
              LFMON         = dm07m-umlfm
              MBEFU         = mbefu
              PSPNR         = u-pspnr
              RMSTQ         = xmtcor-rmstq
              SOBKZ         = u-umsok
              RMSTQH        = xmtper-rmstqh
              TQLFM         = xmtper-tqlfm
              TQGJA         = xmtper-tqgja
            TABLES
              XMSTQ         = xmstq.
        ENDIF.
        CALL FUNCTION 'MB_FILL_MSSQ_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmssq  = xmtcor-rmssq
                  rmssqh = xmtper-rmssqh
                  sqlfm  = xmtper-sqlfm
                  sqgja  = xmtper-sqgja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  pspnr  = pspnr
                  sobkz  = u-umsok
             TABLES
                  xmssq  = xmssq.
      ENDIF.
* note 560226: We have to clear KZBWS when a material is non-valuated,
* but WERTU depends on the plant. Therefore KZBWS might be different for
* both lines because of that and we have to consider SETKZBWS as well.
      IF mseg-sobkz = u-umsok AND mseg-ps_psp_pnr IS INITIAL
         AND ( ( xmtcor-rmssq = 'X' AND NOT mseg-kzbws IS INITIAL )
            OR xmtcor-rqbew = 'X' )
         AND dm07m-setkzbws = ' '.                              " 560226
        dm07m-umkzbws = mseg-kzbws.
      ENDIF.
      mseg-ps_psp_pnr = pspnr.
* begin of SIT
    WHEN t.
      IF NOT kdauf IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSKA_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmska  = xmtcor-rmska
                  rmskah = xmtper-rmskah
                  kalfm  = xmtper-kalfm
                  kagja  = xmtper-kagja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kdauf  = kdauf
                  kdpos  = kdpos
                  sobkz  = u-umsok
             TABLES
                  xmska  = xmska.
        CALL FUNCTION 'MB_FILL_MSSA_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmssa  = xmtcor-rmssa
                  rmssah = xmtper-rmssah
                  salfm  = xmtper-salfm
                  sagja  = xmtper-sagja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kdauf  = kdauf
                  kdpos  = kdpos
                  sobkz  = u-umsok
             TABLES
                  xmssa  = xmssa.
      ENDIF.
      IF mseg-sobkz =    u-umsok AND mseg-kdauf IS INITIAL
    AND ( ( NOT xmtcor-rmssa IS INITIAL AND NOT mseg-kzbws IS INITIAL )
              OR NOT xmtcor-rebew IS INITIAL ).
        dm07m-umkzbws = mseg-kzbws.
      ENDIF.
      mseg-kdauf = kdauf.
      mseg-kdpos = kdpos.
* end SIT
    WHEN v.
      IF NOT kunnr IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSKU_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmsku  = xmtcor-rmsku
                  rmskuh = xmtper-rmskuh
                  kulfm  = xmtper-kulfm
                  kugja  = xmtper-kugja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kunnr  = kunnr
                  sobkz  = u-umsok
             TABLES
                  xmsku  = xmsku.
      ENDIF.
    WHEN w.
      IF NOT kunnr IS INITIAL.
        CALL FUNCTION 'MB_FILL_MSKU_ENQUEUE_TABLE'
             EXPORTING
                  mbefu  = mbefu
                  rmsku  = xmtcor-rmsku
                  rmskuh = xmtper-rmskuh
                  kulfm  = xmtper-kulfm
                  kugja  = xmtper-kugja
                  lfgja  = dm07m-umlfg
                  lfmon  = dm07m-umlfm
                  kunnr  = kunnr
                  sobkz  = u-umsok
             TABLES
                  xmsku  = xmsku.
      ENDIF.
    WHEN z.
    WHEN OTHERS.
ENHANCEMENT-SECTION     UMLAGERMAT_PRUEFEN_09 SPOTS ES_SAPMM07M.
      MESSAGE e009 WITH    u-umsok.
END-ENHANCEMENT-SECTION.
  ENDCASE.

ENDFORM.