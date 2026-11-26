*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WA_PRUEFEN                                    *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktion Warenbewegung/-ausgabe    *
*        wird geprueft.                                               *
*---------------------------------------------------------------------*
FORM fusszeile_wa_pruefen USING f-dbest TYPE c
                                IS_ENHANCEMENT TYPE ISU_FUSSZEILE_WA_PRUEFEN. "#EC *

  DATA: l_xkzbws_change TYPE c.                                " 627312
  DATA: LS_ISU_MATERIAL_PRUEFEN TYPE ISU_MATERIAL_PRUEFEN.  "IS2ERP
  DATA: l_mseg_lgort LIKE mseg-lgort.                          "1493020

ENHANCEMENT-POINT FUSSZEILE_WA_PRUEFEN_01 SPOTS ES_SAPMM07M.

  mseg-kzbew = rm07m-kzbew.
  PERFORM fusszeile_bew_pruefen.
  IF mseg-werks IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'MSEG' 'WERKS'.
  ENDIF.
  PERFORM werk_pruefen(sapfm07m) USING    x
                                       mseg-werks
                                      vm07m-bwkey
                                      dm07m-bwmod
                                      dm07m-xeink
                                      dm07m-xbkng
                                      vm07m-xvkbw
                                       mseg-bukrs
                                      dm07m-ktopl
                                      dm07m-periv
                                       mseg-waers
                                       mkpf-budat
                                       mseg-gjahr
                                      vm07m-monat
                                       mseg-xruem
                                       mseg-xruej
                                      vm07m-lfgja
                                      vm07m-lfmon
                                      dm07m-fabkl
                                      dm07m-kzxab.
  dm07m-xewrx = t001k-xewrx.
  dm07m-x2fdo = t001k-x2fdo.
  vm07m-vgart = t159l-vgart.
  dm07m-xwmhd = t159l-xwmhd.
  dm07m-xefre = t001k-xefre.
  dm07m-efrej = t001k-efrej.
  dm07m-xelik = t159l-xelik.
  dm07m-xlaut = t159l-xlaut.
  IF mseg-parbu IS INITIAL.
    mseg-parbu = mseg-bukrs.
  ENDIF.
  IF NOT mseg-matnr IS INITIAL.
*-- Buchungskreisprüfung ----------------------------------------------*
*    IF NOT mseg-kzbew IS INITIAL                                "373926
    IF mseg-parbu NE mseg-bukrs.                                 "373926
      DATA: gjahr LIKE mseg-gjahr,
            monat LIKE vm07m-monat.
      PERFORM buchungskreis_pruefen(sapfm07m) USING mseg-bukrs
                                                    t001-ktopl
                                                    t001-periv
                                                    t001-waers
                                                    mkpf-budat
                                                         gjahr
                                                         monat.
      IF NOT fcausw-xneup IS INITIAL AND fcausw-xlist IS INITIAL
         AND xmbwl IS INITIAL AND mseg-umwrk IS INITIAL
         AND not mseg-parbu is initial.                         "373926
*        AND mseg-kzbew = b.                                    "373926
        PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '517'
                        mseg-parbu mseg-bukrs mseg-werks space.
      ENDIF.
    ENDIF.
*-- Buchungskreisprüfung ----------------------------------------------*
*   In the receiving part of a cross-system movement, the storage
*   location of the issuing side is not known in the receiving system.
    IF mseg-lgort NA stern AND NOT mseg-lgort IS INITIAL
       AND cl_mmim_cross_system=>kzdir_get( mseg-bwart ) <> r.   "sdp462
      CLEAR xt001l.
      xt001l-werks = mseg-werks.
      xt001l-lgort = mseg-lgort.
      xt001l-xlong = dm07m-xlong.
      PERFORM lagerort_pruefen(sapfm07m) USING xt001l
                                               mseg-bwart.
      dm07m-xlong = xt001l-xlong.
    ENDIF.
    bild-lgort = mseg-lgort.
    bild-charg = mseg-charg.
*   Also the mateiral master of MSEG-MATNR is not present, therefore
*   all coding parts which seem to be related to reading the materal
*   are disabled.
    IF cl_mmim_cross_system=>kzdir_get( mseg-bwart ) <> r.       "sdp462
      DATA: lifnr LIKE mseg-lifnr,
            kunnr LIKE mseg-kunnr,
            kdauf LIKE mseg-kdauf,
            kdpos LIKE mseg-kdpos,
            plpla LIKE mseg-plpla,
            pspnr LIKE mseg-ps_psp_pnr,
            kzbws LIKE mseg-kzbws.
      kzbws = mseg-kzbws.
      CLEAR: lifnr, kunnr, kdauf, kdpos, plpla, pspnr.
      DATA: sobkz LIKE mseg-sobkz.
      MOVE mseg-sobkz TO sobkz.
      IF ( mseg-sobkz = e OR mseg-sobkz = t ) AND         "SIT
         NOT mseg-kzbws IS INITIAL.
        kdauf = mseg-mat_kdauf.
        kdpos = mseg-mat_kdpos.
      ENDIF.
      IF mseg-sobkz = q AND NOT mseg-kzbws IS INITIAL.
        pspnr = mseg-mat_pspnr.
      ENDIF.
ENHANCEMENT-POINT FUSSZEILE_WA_PRUEFEN_02 SPOTS ES_SAPMM07M.

* OMA EHP4                                                 "1493020
* LGORT was not passed to material_pruefen before EHP4     "1493020
      IF gv_mm_om1_sfws_sc_active EQ abap_true             "1493020
         AND t156-bustr EQ bustr_64a.                      "1493020
*       if this is needed for OMA, we pass it when active  "1493020
        l_mseg_lgort = mseg-lgort.                         "1493020
      ELSE.                                                "1493020
*       standard case                                      "1493020
        l_mseg_lgort = space.                              "1493020
      ENDIF.                                               "1493020
* OMA EHP4                                                 "1493020

      PERFORM material_pruefen(sapfm07m) USING mseg-matnr
                                              vm07m-bwkey
                                               mseg-bwtar
                                               mseg-werks
                                             l_mseg_lgort  "1493020
                                                    space
                                               mseg-shkzg
                                                    space
                                                    space
                                                    space
                                                    space
                                                    lifnr
                                                    kunnr
                                                    kdauf
                                                    kdpos
                                                    plpla
                                              vm07m-lfgja
                                              vm07m-lfmon
                                                  f-dbest
                                                    space
                                               mseg-xruem
                                              vm07m-xvkbw
                                              dm07m-xbkng
                                              dm07m-xlong
                                              dm07m-xsmng
                                              dm07m-xsvng
                                              dm07m-xskng
                                              dm07m-xsong
                                              dm07m-xswng
                                              dm07m-xseng
                                              dm07m-xsqng
                                              vm07m-xstau
                                                    pspnr
                                                    kzbws
                                            dm07m-xlaut
                                            dm07m-berid         " 454320
                                            LS_ISU_MATERIAL_PRUEFEN     "IS2ERP
                                    CHANGING    l_xkzbws_change." 627312
ENHANCEMENT-POINT FUSSZEILE_WA_PRUEFEN_03 SPOTS ES_SAPMM07M.
      mseg-kzbws = kzbws.
* MB_Create_goods_movement: Split valuated material (without batch)
*                        -> only BWART necessary for input not CHARG
      IF NOT mbefu-bwtty IS INITIAL AND NOT mbefu-bwtar IS INITIAL
         AND mbefu-charg IS INITIAL AND mbefu-xchpf IS INITIAL
         AND NOT xmbwl IS INITIAL.
        bild-charg  = mbefu-bwtar.
      ENDIF.

      IF NOT xt437e_check IS INITIAL AND mseg-sobkz IS INITIAL.
        PERFORM entnahmeprio_pruefen(sapfm07m) USING mseg-matnr
                                                     mseg-werks
                                                     mbefu-eprio
                                                     mkpf-budat
                                                     mseg-sobkz.
      ENDIF.
      IF mseg-sobkz NE sobkz.
        PERFORM fusszeile_bew_pruefen.
      ENDIF.
      mseg-lgort = bild-lgort.
      mseg-charg = bild-charg.
      IF mbefu-xchar IS INITIAL AND NOT mseg-charg IS INITIAL.
        PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '047'
                                 mseg-matnr mseg-werks space space.
        CLEAR: mseg-charg, bild-charg.
      ENDIF.
    ENDIF.                                                       "sdp462
    CALL FUNCTION 'MB_KZVBR_SICHERN'
         EXPORTING
              kzvbr      = mseg-kzvbr
              mseg_zeile = mseg-zeile
              umkzvbr    = dm07m-umkzvbr
         IMPORTING
              umkzvbr    = dm07m-umkzvbr.
    PERFORM mengenstring_finden(sapfm07m) USING mseg-bwart
                                                mseg-wertu
                                                mseg-mengu
                                                mseg-sobkz
                                                mseg-kzbew
                                                mseg-kzzug
                                                mseg-kzvbr
                                                mseg-matnr
                                                mseg-kzbws.
    PERFORM segmentdaten_t156s_setzen(sapfm07m).
  ENDIF.
  PERFORM bewegungstext_lesen(sapfm07m) USING mseg-bwart
                                              mseg-sobkz
                                              mseg-kzbew
                                              mseg-kzzug
                                              mseg-kzvbr
                                             dm07m-btext.
  IF NOT msegk-konto IS INITIAL
     AND NOT fcausw-xlist IS INITIAL AND NOT fcausw-xneup IS INITIAL.
    IF dm07m-konto IS INITIAL.
      dm07m-konto = msegk-konto.
    ENDIF.
  ENDIF.
  IF NOT dm07m-konto IS INITIAL.
    dm07m-xkman = x.
  ENDIF.
ENDFORM.