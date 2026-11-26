*eject
*---------------------------------------------------------------------*
*       FORM UMLAGERUNG_PRUEFEN                                       *
*---------------------------------------------------------------------*
*       Die Daten der Umlagerung werden geprueft.                     *
*---------------------------------------------------------------------*
FORM umlagerung_pruefen.

  DATA: lo_badi_batch_data_change_int TYPE REF TO badi_batch_data_change_int.
  DATA: ls_mcha  TYPE mcha,
        ls_bncom TYPE bncom,
        lv_umcha TYPE charg_d.

  CHECK NOT dm07m-kzuml IS INITIAL AND NOT fcausw-xneup IS INITIAL.

  lv_umcha = mseg-umcha.

* Feld empfangene Charge soll nur initialisiert werden bei       "745250
* Eingabe einer neuen Chargennummer                              "745250
  IF xmbwl = space.                                         "745250
    IF mbefu-xchar <> space.                                "745250
* Ab zweiter Position soll empfangene Charge ebenfalls           "764623
* manuel eingegeben werden können                                "764623
      STATICS: merker LIKE mseg-zeile.                      "764623
      IF mseg-zeile > merker.                               "764523
        CLEAR: cl_mch1-charg, cl_mcha-charg.                "764523
        merker = mseg-zeile.                                "764523
      ENDIF.                                                "764523
      IF cl_mch1-charg = space.                             "745250
        CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'             "745250
         EXPORTING                                          "745250
           matnr                        = mbefu-matnr       "745250
           charg                        = mbefu-charg       "745250
         IMPORTING                                          "745250
           mch1_buffer                  = cl_mch1.          "745250
      ENDIF.                                                "745250
                                                            "745250
      IF cl_mcha-charg = space.                             "745250
        CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'             "745250
         EXPORTING                                          "745250
           matnr                        = mbefu-matnr       "745250
           charg                        = mbefu-charg       "745250
         IMPORTING                                          "745250
           mcha_buffer                  = cl_mcha.          "745250
      ENDIF.                                                "745250
                                                            "745250
      IF cl_mch1-charg <> space.                            "745250
        IF mseg-umcha NE space AND mseg-charg <> cl_mch1-charg AND "745250
           cl_mch1-charg <> space.                          "745250
          CLEAR: mseg-umcha.                                "745250
        ENDIF.                                              "745250
      ENDIF.                                                "745250
      IF cl_mcha-charg <> space.                            "745250
        IF mseg-umcha NE space AND mseg-charg <> cl_mcha-charg AND "745250
           cl_mcha-charg <> space.                          "745250
          CLEAR: mseg-umcha.                                "745250
        ENDIF.                                              "745250
      ENDIF.                                                "745250
    ENDIF.                                                  "745250
  ENDIF.                                                    "745250

* note 1373378
*** internal BADI
  TRY.
      GET BADI lo_badi_batch_data_change_int.
      MOVE-CORRESPONDING mseg TO ls_bncom.
      IF ls_bncom-umcha IS INITIAL.
        ls_bncom-umcha = lv_umcha.
      ENDIF.
      CALL BADI lo_badi_batch_data_change_int->change_batch_data
        EXPORTING
          is_bncom = ls_bncom
        CHANGING
          cs_mcha  = ls_mcha.

      mseg-umcha = ls_mcha-charg.
      mseg-umzst = ls_mcha-zustd.

    CATCH cx_badi_not_implemented.
  ENDTRY.

* Aufruf das Customer Function Call zur Vorbelegung der Charge
  IF mseg-umcha IS INITIAL AND t158-trtyp = h.
    PERFORM umcharge_vorschlagen USING mseg-umcha.
  ENDIF.

* The old fieldselection (T156B) is not valid for a transfer posting
* from MIGO
  IF NOT vm07m-xstor = zwei AND xmigo <> x.
    IF dm07m-fausw+55(1) = minus.
      CLEAR mseg-ummat.
    ENDIF.
    IF dm07m-fausw+56(1) = minus.
      CLEAR mseg-umwrk.
    ENDIF.
    IF dm07m-fausw+57(1) = minus.
      CLEAR mseg-umlgo.
    ENDIF.
    IF dm07m-fausw+64(1) = minus.
      CLEAR mseg-umcha.
    ENDIF.
    IF NOT vm07m-kzbwa = kzbwa-01 AND
       NOT vm07m-kzbwa = kzbwa-05 AND
       NOT vm07m-kzbwa = kzbwa-07.
      CLEAR: mseg-umbar.
    ENDIF.
    IF mseg-umsok = 'T' AND mseg-umbar IS INITIAL.          "SIT
      mseg-umbar = mseg-bwtar.                              "SIT
    ENDIF.                                                  "SIT
    IF dm07m-fausw+60(1) = minus.
      CLEAR: mseg-kdauf, mseg-kdpos.
    ENDIF.
    IF dm07m-fausw+62(1) = minus.
      CLEAR mseg-ps_psp_pnr.
    ENDIF.
  ENDIF.
  DATA: ummat LIKE mseg-ummat,
        umwrk LIKE mseg-umwrk,
        umlgo LIKE mseg-umlgo,
        umcha LIKE mseg-umcha,
        umbar LIKE mseg-umbar,
        umkda LIKE mseg-kdauf,
        umkdp LIKE mseg-kdpos,
        umpsp LIKE mseg-ps_psp_pnr.

ENHANCEMENT-POINT EHP604_MM07MFU0_UMLAGERUNG_P01 SPOTS ES_MM07MFB1_BELEG_LESEN STATIC .

ENHANCEMENT-POINT EHP604_MM07MFU0_UMLAGERUNG_P02 SPOTS ES_MM07MFB1_BELEG_LESEN .

  ummat = mseg-ummat.
  umwrk = mseg-umwrk.
  umlgo = mseg-umlgo.
  umcha = mseg-umcha.
  umbar = mseg-umbar.
  umkda = mseg-kdauf.
  umkdp = mseg-kdpos.
  umpsp = mseg-ps_psp_pnr.
  IF ummat IS INITIAL.
    ummat = mseg-matnr.
  ENDIF.
  IF umwrk IS INITIAL.
    umwrk = mseg-werks.
  ENDIF.
ENHANCEMENT-SECTION     UMLAGERUNG_PRUEFEN_04 SPOTS ES_SAPMM07M.
  IF ( umkda IS INITIAL AND mseg-umsok = e ) OR
    ( umkda IS INITIAL AND mseg-umsok = t ).                     "SIT
    umkda = mseg-mat_kdauf.
    umkdp = mseg-mat_kdpos.
    IF dm07m-setkzbws IS INITIAL.
      dm07m-umkzbws = mseg-kzbws.
    ENDIF.
  ENDIF.
  IF umpsp IS INITIAL AND mseg-umsok = q.
    umpsp = mseg-mat_pspnr.
    IF dm07m-setkzbws IS INITIAL.
      dm07m-umkzbws = mseg-kzbws.
    ENDIF.
  ENDIF.

END-ENHANCEMENT-SECTION.
*** begin note 429136
  IF     vm07m-xstor  = zwei    AND
     NOT vm07m-xvkbw IS INITIAL.
*   when we cancel a transfer to a value-based article we gotta keep
*   in mind its original vkwrt (needed in verkaufswert_ermitteln)
    dm07m-umvkw = fuss-umvkw.
  ENDIF.
*** end   note 429136

* moved by IS2ERP
  DATA: u_umlgo LIKE mseg-umlgo,
        u_umcha LIKE mseg-umcha,
        u_umbar LIKE mseg-umbar,
        u_umkda LIKE mseg-kdauf,
        u_umkdp LIKE mseg-kdpos,
        u_umpsp LIKE mseg-ps_psp_pnr,
        u_umsok LIKE mseg-umsok.

ENHANCEMENT-SECTION     UMLAGERUNG_PRUEFEN_05 SPOTS ES_SAPMM07M.

  IF NOT dm07m-umard IS INITIAL OR NOT dm07m-umchb IS INITIAL OR
     NOT dm07m-umbpr IS INITIAL OR NOT dm07m-umlib IS INITIAL OR
     NOT dm07m-umkol IS INITIAL OR NOT dm07m-umeik IS INITIAL OR
     NOT dm07m-umklk IS INITIAL OR NOT dm07m-umkub IS INITIAL OR
     NOT dm07m-umsku IS INITIAL OR NOT dm07m-umslb IS INITIAL OR
     NOT dm07m-umska IS INITIAL OR NOT dm07m-umspr IS INITIAL OR
     dm07m-umarc = 'WU5' OR NOT dm07m-umstb IS INITIAL OR
     NOT dm07m-umste IS INITIAL OR NOT dm07m-umstq IS INITIAL.
*break hegewald.
    PERFORM umlagerwerk_pruefen USING umwrk x.
    IF umlgo IS INITIAL.
      IF mseg-umsok <> 'T'.                                     "SIT
        umlgo = mseg-lgort.
      ENDIF.
    ENDIF.
    IF umcha IS INITIAL AND NOT mseg-charg IS INITIAL.

      CLEAR: u_umlgo, u_umcha, u_umbar,
             u_umkda, u_umkdp, u_umpsp, u_umsok.
      PERFORM umlagermat_pruefen USING ummat
                                       umwrk
                                     u_umlgo
                                     u_umcha
                                     u_umbar
                                     u_umkda
                                     u_umkdp
                                     u_umpsp
                                     u_umsok
                                       space.
      IF NOT mbefu-xchar IS INITIAL AND mbefu-xchpf = vm07m-xchpf.
        umcha = mseg-charg.
*       After copying batch to transfer batch above:
*       -> read customizing for M7 199 (see note 43334)
*       -> check batch level (see note 406255)
        IF NOT mbefu-xchpf IS INITIAL AND mseg-kzbew IS INITIAL
*        no entry of UMCHA when changing the batch status        "970485
           AND NOT t156-bustr = bwart_341                   "970485
*        no change of UMCHA is case of QA11                     "1281383
           AND qss_aufruf IS INITIAL                        "1281383
*        no change of UMCHA in case of QA07                     "1312843
           AND NOT sy-cprog = 'RQAAAS10'                       "1317302
*        no change of UMCHA in case of /ISDFPS/CHANGE_SLOC
           AND NOT sy-cprog = '/ISDFPS/CHANGE_SLOC'.             "1397667
          CALL FUNCTION 'MB_CHECK_T160M'
            EXPORTING
              i_arbgb  = 'M7'
              i_msgnr  = '199'
              i_nolog  = x
              i_output = space
            IMPORTING
              rc       = rc.
          CASE rc.
            WHEN 0.
              IF t156-chneu CA ' ABC' AND
                 ummat NE mseg-matnr  AND
                 kzdch EQ charge_auf_mand.
                CLEAR umcha.
              ELSEIF mseg-shkzg EQ s.
                MESSAGE s199 WITH text-uab mseg-charg.
              ELSE.
                MESSAGE s199 WITH text-uem mseg-charg.
              ENDIF.
            WHEN 1.
              IF t156-chneu CA ' ABC' AND
                 ummat NE mseg-matnr  AND
                 kzdch EQ charge_auf_mand.
                CLEAR umcha.
              ELSEIF mseg-shkzg EQ s.
                mseg-umcha = umcha.
                MESSAGE w199 WITH text-uab mseg-charg.
                PERFORM naco_log(sapfm07m) USING 'W' 'M7' '199'
                                 text-uab mseg-charg space space.
              ELSE.
                mseg-umcha = umcha.
                MESSAGE w199 WITH text-uem mseg-charg.
                PERFORM naco_log(sapfm07m) USING 'W' 'M7' '199'
                                 text-uem mseg-charg space space.
              ENDIF.
            WHEN 2.
*             (E) clear UMCHA if automatic batch creation is allowed
              IF t156-chneu CA ' ABC'.
                CLEAR umcha.
              ELSE.
                mseg-umcha = umcha.
                IF mseg-shkzg EQ s.
                  MESSAGE w199 WITH text-uab mseg-charg.
                ELSE.
                  MESSAGE w199 WITH text-uem mseg-charg.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF mseg-umsok = v OR mseg-umsok = w OR mseg-umsok = o.
    PERFORM umlagerwerk_pruefen USING umwrk x.
  ELSE.
    PERFORM umlagerwerk_pruefen USING umwrk space.
  ENDIF.
  IF mseg-matnr = ummat AND mseg-werks = umwrk AND
     mseg-lgort = umlgo AND mseg-charg = umcha AND
     mseg-mat_kdauf = umkda AND mseg-mat_kdpos = umkdp AND
     mseg-mat_pspnr = umpsp AND
     mseg-sobkz = mseg-umsok AND vm07m-smarc = dm07m-umarc AND
     vm07m-smard = dm07m-umard AND vm07m-smchb = dm07m-umchb AND
     vm07m-smbpr = dm07m-umbpr AND vm07m-smlib = dm07m-umlib AND
     vm07m-smkol = dm07m-umkol AND vm07m-smeik = dm07m-umeik AND
     vm07m-smklk = dm07m-umklk AND vm07m-smkub = dm07m-umkub AND
     vm07m-smsku = dm07m-umsku AND vm07m-smslb = dm07m-umslb AND
     vm07m-smska = dm07m-umska AND vm07m-smspr = dm07m-umspr AND
     vm07m-smsca = dm07m-umsca AND vm07m-smscp = dm07m-umscp.
    PERFORM nachrichtencode_ermitteln(sapfm07m) USING 'M7' '104'. "ok
  ENDIF.
  IF mseg-umsok = v OR mseg-umsok = w OR mseg-umsok = o
    OR mseg-umsok = t OR t156-bustr = '68C' OR t156-bustr = '69C'. "SIT
    CLEAR umlgo.
  ELSE.
    IF NOT umlgo IS INITIAL.
      IF umlgo CA stern.
        SET CURSOR FIELD 'MSEG-UMLGO'.
        MESSAGE e116.
      ENDIF.
      CLEAR ut001l.
      ut001l-werks = umwrk.
      ut001l-lgort = umlgo.
      ut001l-xlong = dm07m-umxln.
      PERFORM umlagerort_pruefen USING ut001l
                                       mseg-bwart.
      dm07m-umxln   = ut001l-xlong.
      dm07m-umvkorg = ut001l-vkorg.                                 "HUM
      dm07m-umvtweg = ut001l-vtweg.                                 "HUM
      dm07m-umvstel = ut001l-vstel.                                 "HUM
      dm07m-umspart = ut001l-spart.                                 "HUM
      dm07m-umxhupf = ut001l-xhupf.                                 "HUM
      dm07m-umsdkun = ut001l-kunnr.                                 "HUM
      dm07m-umsdlif = ut001l-lifnr.                                 "HUM
    ENDIF.
  ENDIF.
END-ENHANCEMENT-SECTION.
  IF umcha CA stern.
    SET CURSOR FIELD 'MSEG-UMCHA'.
    MESSAGE e116.
  ENDIF.
  PERFORM umlagermat_pruefen USING ummat
                                   umwrk
                                   umlgo
                                   umcha
                                   umbar
                                   umkda
                                   umkdp
                                   umpsp
                                   mseg-umsok
                                   u    .
  IF kzdws EQ eins.                                         "ALRK115218
    DATA: loc_umwso LIKE dm07m-kzwso.                       "ALRK115218
    PERFORM read_kzwso(sapfm07m) CHANGING dm07m-kzwso       "ALRK115218
                                          loc_umwso.        "ALRK115218
    IF loc_umwso EQ b AND NOT mseg-umcha IS INITIAL.        "899218
      IF dm07m-umcla IS INITIAL.                            "ALRK115218
        PERFORM mengen_bewertung USING mseg.                "ALRK115218
      ENDIF.                                                "ALRK115218
    ENDIF. " loc_umwso eq b and not mseg-umcha is initial   "899218
  ENDIF.                                                    "ALRK115218

  IF gv_mm_om1_sfws_sc_active = abap_true.
* In this special case the subcontractor has to be filled using the vendor-number.
    IF t156-bustr = '30C'.
      mseg-emlif = mseg-lifnr.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT UMLAGERUNG_PRUEFEN_01 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT UMLAGERUNG_PRUEFEN_02 SPOTS ES_SAPMM07M.

* In case of active SCC the transfer postings could cause    "n1391236
* inconsistencies between MBEW and OBEW (note 1384307)       "n1391236
  IF mseg-sobkz = 'O' AND mseg-umsok = 'O' AND              "n1391236
     mseg-bustm = 'MOOF'.                                   "n1391236
      data: lv_sccact_rec type flag.                         "n1391236
      data: lv_sccact_iss type flag.                         "n1391236
      data: ls_ummssl type smssl.                            "n1418132
*    check wheter the stock unit is relevant for SCC (XOBEW) "n1418132
*    301 O is not supported by SCC -> check MSSL-XOBEW       "n1418132
     CLEAR: lv_sccact_rec, lv_sccact_iss, ls_ummssl.         "n1418132
        READ TABLE xmssl                                     "n1418132
             WITH KEY matnr = mseg-matnr                     "n1418132
                      werks = mseg-werks                     "n1418132
                      sobkz = mseg-sobkz                     "n1418132
                      lifnr = mseg-lifnr                     "n1418132
             into ls_ummssl.                                 "n1418132
        IF sy-subrc = 0.                                     "n1418132
         lv_sccact_rec = ls_ummssl-xobew.                    "n1418132
        ENDIF.                                               "n1418132
        READ TABLE xmssl                                     "n1418132
             WITH KEY matnr = mseg-ummat                     "n1418132
                      werks = mseg-umwrk                     "n1418132
                      sobkz = mseg-umsok                     "n1418132
                      lifnr = mseg-emlif                     "n1418132
             into ls_ummssl.                                 "n1418132
        IF sy-subrc = 0.                                     "n1418132
         lv_sccact_iss = ls_ummssl-xobew.                    "n1418132
        ENDIF.                                               "n1418132
        IF lv_sccact_rec <> lv_sccact_iss.                   "n1418132
          message e019(M7) with mseg-bwart mseg-sobkz.       "n1418132
        ENDIF.                                               "n1418132
      ENDIF.                                                 "n1391236
      CLEAR: lv_sccact_rec, lv_sccact_iss, ls_ummssl.        "n1418132


ENDFORM.                    "umlagerung_pruefen