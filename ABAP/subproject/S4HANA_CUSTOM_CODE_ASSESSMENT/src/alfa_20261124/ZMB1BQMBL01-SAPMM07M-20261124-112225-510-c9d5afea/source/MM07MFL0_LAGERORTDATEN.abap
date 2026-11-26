*---------------------------------------------------------------------*
*       FORM LAGERORTDATEN                                            *
*---------------------------------------------------------------------*
*       Die Daten auf Lagerort- und Chargenebene des Materials        *
*       werden geprueft und ins Segment uebernommnen.                 *
*---------------------------------------------------------------------*
FORM lagerortdaten USING is_enhancement TYPE isu_lagerortdaten. "#EC *

  DATA: ls_isu_menge_umrechnen  TYPE isu_menge_umrechnen,   "IS2ERP
        ls_isu_material_pruefen TYPE isu_material_pruefen,  "IS2ERP
        ls_isu_lagerortauswahl  TYPE isu_lagerortauswahl.   "IS2ERP

  DATA: lr_insmk_wip_change TYPE REF TO mb_insmk_wip_change,  " OM EhP 604
        lv_insmk_wip_change TYPE abap_bool.                   " OM EhP 604


ENHANCEMENT-POINT lagerortdaten_04 SPOTS es_sapmm07m.

ENHANCEMENT-POINT lagerortdaten_01 SPOTS es_sapmm07m.


  DATA: w_mcha TYPE mcha,                                   "735938
        w_mch1 TYPE mch1.                                   "735938

* nicht, wenn Position ausgelassen werden soll,
* und nur, wenn eine neue Position hinzugefügt werden soll
  CHECK ( xpaus IS INITIAL AND NOT fcausw-xneup IS INITIAL ).
* XLAUS = X: functionality storage location/batch - '*' is evaluated.
*            flag set during this routine, make sure it is empty at
*            the beginning (exit with error message last time)
  CLEAR: xlaus.                                             "note 326203

* e_atpcsx should be empty if no or the mm batch determination   "648152
* are taking place
  IF ( mseg-charg CA stern AND NOT dm07m-chsmm IS INITIAL
                           AND NOT vm07m-xchpf IS INITIAL )
*      = batch determination via new vb_batch_determination
*        will be taking place
     OR
     ( NOT mseg-charg IS INITIAL AND NOT dm07m-kzchf IS INITIAL
                                 AND NOT dm07m-chsmm IS INITIAL
                                 AND NOT vm07m-xchpf IS INITIAL ).
*      = batch determination via new vb_batch_determination
*        has taken place
  ELSE.
*   = no or mm batch determination
    CLEAR:   e_atpcsx.
    REFRESH: e_atpcsx.
  ENDIF.                                                    "648152

  DATA: sobkz LIKE mseg-sobkz,
        lifnr LIKE mseg-lifnr,
        kunnr LIKE mseg-kunnr,
        kdauf LIKE mseg-kdauf,
        kdpos LIKE mseg-kdpos,
        plpla LIKE mseg-plpla,
        pspnr LIKE mseg-ps_psp_pnr.
ENHANCEMENT-POINT mm07mfl0_lagerortdaten_01 SPOTS es_sapmm07m STATIC.
  DATA: h_zustd LIKE t156m-zustd,
        l_xkzbws_change TYPE c.                             " 627312

  STATICS: zeile_old LIKE mseg-zeile,                       "note 610068
           lgort_old LIKE mseg-lgort,                       "note 610068
           xblvs_old LIKE mseg-xblvs,                       "note 610068
           xhupf_old LIKE xt001l-xhupf.                     "note 610068

  DATA:    xblvs_new LIKE mseg-xblvs.                       "note 610068
  DATA: ls_isu_sonderbestand_pruefen TYPE isu_sonderbestand_pruefen. "IS2ERP

* @vsa_cd
  DATA: cd_vorgang TYPE c.             " soll die Pos. ueber cd gehen
* @vsa_cd
* DM07M-XLORT wird zunächst - zusammen mit DM07M-XCHAR - z.B. beim
* Übernehmen der Bestellung gesetzt, falls MSEG-MATNR nicht blank;
* später wird der Eintrag aber durch T156S-XLORT (Lagerort erforderlich)
* überschrieben
  IF NOT dm07m-xlort IS INITIAL AND
     vm07m-xstor NE zwei.

    IF xmbwl IS INITIAL AND
    ( mseg-sobkz IS INITIAL
      OR mseg-sobkz =  k ).
*     Customer Function, um Lagerort zu setzen. Ggf. auf '*', damit
*     Bestandsfindung läuft, nur für Dialogfunktionen MBxx
      DATA: loc_lgort LIKE mseg-lgort.
      CALL CUSTOMER-FUNCTION '009'                          "300466
           EXPORTING
                i_mseg       = mseg
                i_dm07m      = dm07m
                i_vm07m      = vm07m
                i_mkpf       = mkpf
           IMPORTING
                e_lgort      = loc_lgort.
*          EXCEPTIONS                                       "428953
*               error_message.
      IF NOT loc_lgort IS INITIAL.
        mseg-lgort = loc_lgort.
      ENDIF.

    ENDIF.

*   BAdI to replace storage location, also in MB_Create-case
*   GTS-functionality only !                                "ERP2005
    IF xmigo IS INITIAL AND
       NOT if_mb_stor_loc_badi_gts IS INITIAL.
      CALL METHOD if_mb_stor_loc_badi_gts->change_stor_loc_gts
        EXPORTING
          mkpf  = mkpf
          mseg  = mseg
          dm07m = dm07m
          vm07m = vm07m
        IMPORTING
          lgort = loc_lgort.

      IF NOT loc_lgort IS INITIAL.
        mseg-lgort = loc_lgort.
      ENDIF.

    ENDIF.

  ENDIF.   "IF NOT dm07m-xlort IS INITIAL AND vm07m-xstor NE zwei.


  IF NOT dm07m-xvash IS INITIAL  AND  xmbwl IS INITIAL.
    PERFORM vas_mengen_verteilung(sapfm07m).  "note 202841
  ENDIF.
  IF NOT vm07m-xchpf IS INITIAL.
*   begin of note 359935
*   set relevant batch determination fields of T156B as T156B is only
*   filled in case of movement types >= 201.
*   T156B is read for field selection in bildauswahl_pruefen. Here
*   we read only batch determination fields.
*   Do not read T156B fields in case of XMBWL as we do not want
*   a batch determination in case of an external call.
*   Former times the fields have been read via
*   bildauswahlpruefen (segmentdaten_t156B_setzen), but only
*   for kzbew initial and kzbew = l (which never has been true).
    IF xmbwl IS INITIAL  OR ( xmbwl = 'X' AND xmigo = 'X' ). "853805
      SELECT SINGLE chsmm umchs kzchp FROM t156b
                      INTO (dm07m-chsmm, dm07m-umchs, dm07m-kzchp)
                      WHERE bwart = mseg-bwart
                        AND sobkz = mseg-sobkz.
      IF sy-subrc <> 0.
*      if entry with special stock indicator not found    > reread
*      without special stock indicator. This is necessary for mvt.
*      < 201 as we have no entry with sobkz in standard, but they
*      might be added some day (or by the customer).
        SELECT SINGLE chsmm umchs kzchp FROM t156b
                       INTO (dm07m-chsmm, dm07m-umchs, dm07m-kzchp)
                       WHERE bwart = mseg-bwart
                         AND sobkz = space.
      ENDIF.
    ENDIF.
*   end of note 359935

*-- Aufruf das Customer Function Call zur Vorbelegung der Charge/
*   der Umlagercharge
    IF mseg-charg IS INITIAL AND t158-trtyp = h.
      PERFORM charge_vorschlagen USING mseg-charg.
    ENDIF.
    IF mseg-umcha IS INITIAL AND t158-trtyp = h.
      PERFORM umcharge_vorschlagen USING mseg-umcha.
    ENDIF.
*-- Prüfung, ob Charge aus Fertigungsauftrag gekommen sein muß (nur WA)
    IF mseg-shkzg = h AND                                   "802312
       ( dm07m-kzech EQ '1' OR
         dm07m-kzech EQ '2' OR
         dm07m-kzech EQ '3' ).
      MESSAGE e119(lp).
    ELSEIF dm07m-kzech EQ stern.       " AND MSEG-KZBEW = F.
      IF dm07m-xstbw IS INITIAL.
        IF NOT mseg-charg IS INITIAL.
*---------> MESSAGE, daß Charge zurückgenommen wird
        ELSE.
          mseg-charg = stern.
        ENDIF.
      ELSE.
        CLEAR dm07m-kzech.
      ENDIF.
    ELSEIF dm07m-kzech NE plus AND dm07m-kzech NE minus.
      CLEAR dm07m-kzech.
    ENDIF.
*-- Prüfung der manuell eingegebenen Charge
    IF NOT dm07m-kzchp IS INITIAL AND NOT mseg-charg  CA stern
                                  AND NOT mseg-charg  IS INITIAL
                                  AND dm07m-kzchf     IS INITIAL
                                  AND NOT dm07m-chsmm IS INITIAL.
      PERFORM chargenfindung USING p.
    ENDIF.
  ENDIF.

* Begin of changes for OM EhP 604
* In cases of WiP-Batches and certain movement types (T156-XWIPB) posting from blocked stock will be
* allowed using the BAdI below.
  IF gv_mm_om1_sfws_sc_active = abap_true.
    IF  t156-xwipb = abap_true AND mseg-charg IS NOT INITIAL AND vm07m-xstor <> 2.
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
         EXPORTING
           matnr                        = mseg-matnr
           charg                        = mseg-charg
           werks                        = mseg-werks
*          READ_FROM_BUFFER             = X
         IMPORTING
           batch_buffer                 = w_mcha
           mch1_buffer                  = w_mch1
        EXCEPTIONS
           OTHERS                       = 5.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      TRY.
          GET BADI lr_insmk_wip_change.
          CALL BADI lr_insmk_wip_change->change_wip_insmk_to_blocked
            EXPORTING
              is_mseg                        = mseg
              is_vm07m                       = vm07m
              is_mcha                        = w_mcha
              is_mch1                        = w_mch1
            CHANGING
              cv_change_wip_insmk_to_blocked = lv_insmk_wip_change.
        CATCH cx_badi_not_implemented.
          lv_insmk_wip_change = abap_false.
      ENDTRY.
      IF lv_insmk_wip_change = abap_true AND
         ( w_mch1-batch_type = 1 OR w_mcha-batch_type = 1 ).
*     Finally change the stock type
        IF mseg-insmk IS INITIAL.   "if not initial: keep insmk
          mseg-insmk = 3.  "blocked stock
        ENDIF.
*     If stock type has been changed issue customizable message M7 470
        perform nachrichtencode_ermitteln(sapfm07m) using 'M7' '470'.
*     this is necessary because if the batch has not been entered immediately on the first
*     screen in MBxx, the wrong INSMK will be used.
        clear dm07m-insmk_original.
      ENDIF.
      CLEAR: w_mcha, w_mch1.
    ENDIF.
  ENDIF.

*-Klassifikation im Dunklen und Vorbelegen von Werten bei Para.Eingabe
  IF kzdws EQ '1'.
    DATA: l_umwso LIKE dm07m-kzwso.
    PERFORM read_kzwso(sapfm07m) CHANGING dm07m-kzwso
                                          l_umwso.
    DATA: l_kzuml LIKE dm07m-kzuml.
    PERFORM menge_parallel_read_kzuml(sapfm07m) CHANGING l_kzuml.
    IF ( ( dm07m-kzwso EQ b AND l_kzuml IS INITIAL ) OR
         ( l_umwso     EQ b AND NOT l_kzuml IS INITIAL ) ).
      PERFORM mengen_bewertung USING mseg.
    ENDIF.
  ENDIF.                               "ALRK014884 SW End

* PERFORM MENGE_UMRECHNEN(SAPFM07M) USING MSEG-MATNR.
  PERFORM menge_umrechnen(sapfm07m) USING mseg-matbf
                                    ls_isu_menge_umrechnen. "IS2ERP

  IF ( dm07m-xlort IS INITIAL OR mseg-kzbew = o )
       AND ( NOT t156-bustr = '107' AND                           "SIT
             NOT t156-bustr = '167' AND                           "SIT
             NOT t156-bustr = '68E' AND                           "SIT
             NOT t156-bustr = '559' AND                           "SIT
             NOT mseg-sobkz = 'T' ).                              "SIT

* Change for note 735938 starts.
* Fill up the field vm07m-licha from the batch master if it is
* initial.
    IF ( NOT mseg-charg IS INITIAL AND vm07m-licha IS INITIAL
         AND mseg-kzbew NE o ) .
      IF kzdch = 0.
        SELECT SINGLE * INTO w_mcha FROM mcha
        WHERE  matnr = mseg-matnr
        AND    werks = mseg-werks
        AND    charg = mseg-charg.
        vm07m-licha = w_mcha-licha.
      ELSE.
        SELECT SINGLE * INTO w_mch1 FROM mch1
        WHERE  matnr = mseg-matnr
        AND    charg = mseg-charg.
        vm07m-licha = w_mch1-licha.
      ENDIF.
    ENDIF.
* Change for note 735938 ends.
*   LGORT needs to be cleared before QM call - note 316750
    CLEAR mseg-lgort.                         "note 316750
    IF dm07m-xlort IS INITIAL AND NOT mseg-kzbew = o
       AND cl_mmim_cross_system=>kzdir_get( mseg-bwart ) <> r. "sdp46
*     Always use original INSMK [before QM-check].
*     Except KZBEW=B/F, because you can change INSMK on screen
      IF dm07m-insmk_original+1(1) IS INITIAL.
        dm07m-insmk_original(1)   = mseg-insmk.
        dm07m-insmk_original+1(1) = x.
      ENDIF.
      IF mseg-kzbew NA 'FB'.
        mseg-insmk = dm07m-insmk_original(1).
      ENDIF.
      PERFORM qss_testen USING mseg-insmk.
    ENDIF.
    IF NOT vm07m-xchpf IS INITIAL AND                       "412562
       NOT vm07m-kzwes = s AND NOT vm07m-xstor = zwei AND
       mseg-kzbew <> o.
      IF mseg-charg IS INITIAL.                             "412562
        IF mseg-kzbew = b OR mseg-kzbew = f.
          IF mseg-shkzg = s.
            SELECT SINGLE * FROM t159l WHERE werks = mseg-werks.
            IF NOT t159l-xcaut IS INITIAL.
*             auto-create batch for GR with account assignment
              PERFORM chargennummernvergabe(sapfm07m)
                                 USING mseg
                                                            mseg-shkzg
                                                            mseg-matnr
                                                            mseg-werks
                                                   CHANGING mseg-charg.
              PERFORM charge_initialzustand(sapfm07m)           "1442176
                                 USING mseg-matnr               "1442176
                                       vm07m-mtart              "1442176
                                       mseg-charg               "1442176
                                       mseg-werks               "1442176
                              CHANGING mbefu-zustd              "1442176
                                       mbefu-zusch.             "1442176
              mseg-zustd = mbefu-zustd.                         "1442176
              mseg-zusch = mbefu-zusch.                         "1442176
              IF mseg-zustd = x.                                "1442176
                PERFORM naco_ermitteln_v1(sapfm07m)             "1442176
                        USING 'M7' '670' mseg-charg.            "1442176
              ENDIF.                                            "1442176
            ENDIF.
          ENDIF.
        ENDIF.
        IF mseg-charg IS INITIAL AND NOT mseg-xmacc CA 'XLBU'.  "MAA2
          IF sy-stepl IS INITIAL.
            SET CURSOR FIELD 'MSEG-CHARG'.
          ELSE.
            SET CURSOR FIELD 'MSEG-CHARG' LINE sy-stepl.
          ENDIF.
          PERFORM nachrichtencode_ermitteln(sapfm07m) USING 'M7' '191'.
        ENDIF.
      ELSE.                                                 "412562
*       Check externally entered batch number for consistency.
*       To decide whether the batch already exists, we must read
*       the material master as this has not been done properly before.
        DATA:                                               "412562
          ls_mtcor TYPE mtcor,                              "412562
          ls_mtcom TYPE mtcom.                              "412562
        ls_mtcom-kenng = 'MBEFU'.                           "412562
        ls_mtcom-matnr = mseg-matnr.                        "412562
        ls_mtcom-werks = mseg-werks.                        "412562
        ls_mtcom-charg = mseg-charg.                        "412562
        CALL FUNCTION 'MATERIAL_READ'                       "412562
          EXPORTING                                         "412562
            schluessel                 = ls_mtcom           "412562
          IMPORTING                                         "412562
            return                     = ls_mtcor           "412562
          EXCEPTIONS                                        "412562
            OTHERS                     = 1.                 "412562
        IF   "new batch
           ( kzdch  = null AND NOT ls_mtcor-rmcha IS INITIAL )   "412562
           OR                                               "412562
           ( kzdch <> null AND NOT ls_mtcor-rmch1 IS INITIAL ). "412562
          PERFORM charge_number_check(sapfm07m)             "412562
                                      USING mseg-matnr      "412562
                                            mseg-werks      "412562
                                            mseg-lgort      "412562
                                            mseg-charg.     "412562
          IF  mseg-kzbew = b AND NOT mseg-kzvbr IS INITIAL.     "1442176
*         Initialzustand für neue Charge                        "1057725
*         bei WE zu kontierter Bestellung in MB oder BAPI       "1057725
*         bei WE zu kontierter Bestellung in MIGO nach Prüfen   "1442176
            PERFORM charge_initialzustand(sapfm07m)         "1057725
                               USING mseg-matnr             "1057725
                                     vm07m-mtart            "1057725
                                     mseg-charg             "1057725
                                     mseg-werks             "1057725
                            CHANGING mbefu-zustd            "1057725
                                     mbefu-zusch.           "1057725
            mseg-zustd = mbefu-zustd.                       "1057725
            mseg-zusch = mbefu-zusch.                       "1057725
            IF NOT mseg-zustd IS INITIAL.                       "1442176
              PERFORM naco_ermitteln_v1(sapfm07m)               "1442176
                      USING 'M7' '670' mseg-charg.              "1442176
            ENDIF.                                              "1442176
          ENDIF.                                            "1057725
        ENDIF.                                              "412562
      ENDIF.                                                "412562
    ENDIF.
  ELSE.
    IF NOT mseg-matnr IS INITIAL.
      mseg-bwtar = dm07m-bwtor.
      IF NOT xmbwl IS INITIAL AND
         NOT dm07m-bwtar_xmbwl IS INITIAL AND
         mseg-bwtar IS INITIAL.
*       behaviour changed by note 331096: check if valuation type
*       is already determined by enqueue table
        PERFORM bewertungsart_holen(sapfm07m) USING mseg-bwtar
                                                    vm07m-webre.
        IF mseg-sobkz = 'K' AND NOT mseg-bwtar IS INITIAL.  "949367
          CLEAR mseg-bwtar.                                 "949367
        ENDIF.                                              "949367
        IF mseg-bwtar <> dm07m-bwtar_xmbwl AND
           NOT mseg-bwtar IS INITIAL.
          MESSAGE e043 WITH mseg-bwtar dm07m-bwtar_xmbwl.
        ELSE.
          mseg-bwtar = dm07m-bwtar_xmbwl.
        ENDIF.
      ENDIF.
      IF NOT inventur IS INITIAL.
*       Use always original INSMK [before QM-check]
*       Except KZBEW=B/F, because you can change INSMK on screen
        IF dm07m-insmk_original+1(1) IS INITIAL.
          dm07m-insmk_original(1)   = mseg-insmk.
          dm07m-insmk_original+1(1) = x.
        ENDIF.
        IF mseg-kzbew NA 'FB'.
          mseg-insmk = dm07m-insmk_original(1).
        ENDIF.
        insmk = mseg-insmk.
        PERFORM qss_testen USING insmk.
      ENDIF.
      IF NOT mseg-kzbew = o AND inventur IS INITIAL.
*       Use always original INSMK [before QM-check]
*       Except KZBEW=B/F, because you can change INSMK on screen
        IF dm07m-insmk_original+1(1) IS INITIAL.
          dm07m-insmk_original(1)   = mseg-insmk.
          dm07m-insmk_original+1(1) = x.
        ENDIF.
        IF mseg-kzbew NA 'FB'.
          mseg-insmk = dm07m-insmk_original(1).
        ENDIF.
        insmk = mseg-insmk.
        IF NOT vm07m-soblo IS INITIAL and xebefu-LBLKZ = 'X'   "n1263739
           AND mseg-kzbew = 'B' AND xebefu-pstyp = 0.          "n1263739
          CLEAR mseg-lgort.                                    "n1263739
        ENDIF.                                                 "n1263739
        PERFORM qss_testen USING insmk.
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
* vsa_lg anfang
        IF mseg-xauto = l.
          PERFORM leergut_xauto_kontrollieren.
        ENDIF.
* vsa_lg ende
        IF mseg-xauto = l.
          h_zustd = l.
* vsa_lg anfang
        ELSEIF mseg-xauto = m.
          h_zustd = mseg-zustd = m.
        ELSEIF mseg-xauto = w.
          h_zustd = mseg-zustd = w.
* vsa_lg ende
        ELSE.
          CLEAR h_zustd.
        ENDIF.
        IF NOT s156s-bustm IS INITIAL.
          SELECT * FROM t156m WHERE bustm = s156s-bustm
                               AND  zustd = h_zustd.
            EXIT.
          ENDSELECT.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH '156M' s156s-bustm h_zustd.
          ENDIF.
        ELSE.
          CLEAR t156m.
        ENDIF.
        IF NOT insmk IS INITIAL.
          IF NOT mseg-kzbew = b AND NOT mseg-kzbew = f AND
             NOT mseg-insmk = insmk.
*           The following statement has been changed by note 492625.
*           The problem which is mentionned in that note is that
*           the former statement has always been true in
*           case of INSMK = F. To ask for LBBSA = '02' and INSMK = F
*           seems to make no sense as LBBSA = '02' is for quality
*           stock. Therefore QM has changed INSMK to unrestricted and
*           we should issue a message in that case. In case time shows
*           the intention of the former statement, please comment
*           on if you do additional changes.
            IF ( NOT t156m-lbbsa = '01' AND insmk = f ) OR
               ( NOT t156m-lbbsa = '02' AND insmk = q ) OR
*              ( NOT t156m-lbbsa = '02' AND insmk = f ) OR
               ( NOT t156m-lbbsa = '07' AND insmk = s ).
              DATA: bstar LIKE t064b-bstar.
              CASE insmk.
                WHEN f.
                  bstar = eins.
                WHEN q.
                  bstar = zwei.
                WHEN s.
                  bstar = vier.
                WHEN OTHERS.
                  MESSAGE e157 WITH insmk.
              ENDCASE.
              SELECT SINGLE * FROM  t064b
                     WHERE  spras       = sy-langu
                     AND    bstar       = bstar .
              IF NOT sy-subrc IS INITIAL.
                MESSAGE e001 WITH 'T064B' t064b-bstar.
              ENDIF.
              PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '156'
                      mseg-matnr t064b-btext space space.
            ENDIF.
          ENDIF.
          mseg-insmk = insmk.
        ENDIF.
      ENDIF.
* @vsa_cd anfang
* pruefen cross-docking relevante Position
      PERFORM lgort_cd_vorgang_pruefen CHANGING cd_vorgang.
      IF NOT xmigo IS INITIAL AND cd_mseg_eingemischt IS INITIAL.
        IMPORT cd_mseg_eingemischt TO cd_mseg_eingemischt
          FROM MEMORY ID 'CD_MSEG_EINGEMISCHT'.
        IF sy-subrc = 0 AND NOT cd_mseg_eingemischt[] IS INITIAL.
          cd_vorgang_aktiv = 'X'.
        ENDIF.
        FREE MEMORY ID 'CD_MSEG_EINGEMISCHT'.
      ENDIF.
      IF NOT cd_vorgang IS INITIAL.
        IF mseg-lgort NA stern.
          PERFORM lgort_cd_einmischen_lagerorte.
        ELSE.
          PERFORM lgort_cd_warnung_meth_ignor.
        ENDIF.
* Note 806863 - Begin
*      ELSEIF fuss-xvash = x.
      ENDIF.
      IF fuss-xvash = x.
* Note 806863 - End
        PERFORM vas_simulate_aufrufen.
      ENDIF.
* @vsa_cd ende
      IF mseg-charg CA stern OR mseg-lgort CA stern.
* Charge/Lagerort * bei Stücklisten (Leihgut,..) und value added service
* nicht erlaubt
        IF NOT dm07m-upvor IS INITIAL OR
           ( NOT dm07m-uebpo IS INITIAL AND dm07m-uptyp CA '234' ) OR
           NOT dm07m-xvash IS INITIAL.
          MESSAGE e116.
        ELSE.                                             "NOTE 180691
          PERFORM retail_article_split_check.            "NOTE 180691
        ENDIF.
ENHANCEMENT-SECTION     mm07mfl0_lagerortdaten_02 SPOTS es_sapmm07m.
        IF mseg-charg CA stern.
          IF dm07m-kzech IS INITIAL.
            IF NOT ( mseg-sobkz EQ space OR
                     mseg-sobkz EQ o     OR
                     mseg-sobkz EQ v     OR
                     mseg-sobkz EQ w     OR
                     mseg-sobkz EQ e     OR
                     mseg-sobkz EQ q     OR
                     mseg-sobkz EQ k ).
              MESSAGE e116.
            ENDIF.
            IF dm07m-chsmm IS INITIAL AND NOT mseg-sobkz IS INITIAL
               AND dm07m-rules IS INITIAL.
              MESSAGE e116.
            ENDIF.
          ENDIF.
        ELSEIF NOT ( mseg-sobkz EQ space OR
                     mseg-sobkz EQ k     OR
                     mseg-sobkz EQ e     OR
                     mseg-sobkz EQ q        ).
          MESSAGE e116.
        ENDIF.
END-ENHANCEMENT-SECTION.
        xlaus = x.
        DATA x_lgort LIKE mseg-lgort.
        x_lgort = mseg-lgort.
        IF x_lgort CA stern.
          CLEAR mseg-lgort.
        ENDIF.
        IF NOT dm07m-eprio IS INITIAL AND dm07m-fausw+13(1) = minus.
          dm07m-fausw+13(1) = punkt.
        ENDIF.
*------ Chargenfindung über L_IM_BATCH_DETERMINATION_INT
        IF mseg-charg CA stern AND dm07m-kzech EQ stern
                               AND NOT vm07m-xchpf IS INITIAL.
          PERFORM chargenbestimmung_wm_pp.
*------ Chargenfindung über VB_BATCH_DETERMINATION
        ELSEIF mseg-charg CA stern AND NOT dm07m-chsmm IS INITIAL
                                   AND NOT vm07m-xchpf IS INITIAL.
          PERFORM chargenfindung USING f.
*------ Bestandsfindung über BF_STOCK_DETERMINATION
        ELSEIF NOT dm07m-eprio IS INITIAL AND
               NOT dm07m-rules IS INITIAL AND
               mseg-shkzg = h AND
               ( x_lgort CA stern OR ( mseg-charg CA stern AND
               ( NOT dm07m-xchar IS INITIAL OR mseg-sobkz = o ) ) ).
          PERFORM bestandsfindung.
        ELSE.
*-------- Storage location selection: No special stock allowed
          IF mseg-sobkz <> space.
            MESSAGE e116.
          ENDIF.
*------   alte Chargenfindung
          MOVE-CORRESPONDING dm07m TO mbefu.
          MOVE-CORRESPONDING vm07m TO mbefu.
          MOVE-CORRESPONDING mseg TO mbefu.
          PERFORM lagerortauswahl(sapfm07m) USING mseg-matnr
                                                  mseg-werks
                                                  mseg-sobkz
                                                  mseg-lgort
                                                  mseg-shkzg
                                                  mseg-wertu
                                                  mseg-mengu
                                                  fuss-xnepo
                                                  ls_isu_lagerortauswahl. "IS2ERP

          CASE confirm.
            WHEN n.
              xpaus = x.
              EXIT.
            WHEN m.
              IF x_lgort CA stern.
                CLEAR x_lgort.
                CLEAR xlaus.
                MESSAGE e039.
              ENDIF.
          ENDCASE.
        ENDIF.
        IF mseg-lgort IS INITIAL.
          mseg-lgort = x_lgort.
        ENDIF.
        CLEAR: ylgort, index_z.
        LOOP AT ylgort WHERE NOT xselp IS INITIAL.
          index_z = index_z + 1.
          IF index_z = 1.
            lifnr = mseg-lifnr.
            sobkz = mseg-sobkz.
            MOVE-CORRESPONDING ylgort TO dm07m.
            MOVE-CORRESPONDING ylgort TO vm07m.
            MOVE-CORRESPONDING ylgort TO mseg.
            IF mseg-lifnr IS INITIAL.
              mseg-lifnr = lifnr.
            ENDIF.
            IF mseg-sobkz IS INITIAL.
              mseg-sobkz = sobkz.
            ENDIF.
            PERFORM menge_umrechnen(sapfm07m) USING mseg-matnr
                                      ls_isu_menge_umrechnen. "IS2ERP

            DELETE ylgort.
          ENDIF.
        ENDLOOP.
        CLEAR:  lifnr, sobkz.
        IF index_z IS INITIAL.
*         CLEAR MSEG-CHARG.                                  "note309091
          CLEAR xlaus.
          MESSAGE e046 WITH mseg-matnr mseg-werks mseg-lgort.
        ELSE.
          DATA: h_fuss LIKE fuss.
          DATA: fuss2 LIKE fuss OCCURS 0
                           WITH HEADER LINE.
          h_fuss = fuss.
          LOOP AT fuss.
            fuss-zeile = fuss-zeile + index_z.
            MODIFY fuss.
          ENDLOOP.
          fuss2[] = fuss[].
          REFRESH fuss.
          fuss = h_fuss.
          PERFORM fuss_ergaenzen.
*         No append: MB_CREATE would post two MSEG's for one item
*         (DM07M-KZECH was set in IMSEG for item w/o batch)
          IF xmbwl IS INITIAL OR '*+' NA dm07m-kzech.       "note 383640
            f_zeile = f_zeile + 1.
*           The line appended here is used in DYNPRO_VORBEREITEN
*           as basis for the remaining lines in YLGORT. It does not
*           get a LINE_ID here, because this line is only a template.
*           The LINE_ID will be assigned in SEGMENT_HINZUFUEGEN.
*           See the internal memo in note 339202.
            CLEAR fuss-line_id.                             "339202
            APPEND fuss.
          ENDIF.                                            "note 210297
*         sort fuss by zeile.
          LOOP AT fuss2.
            fuss = fuss2.
            APPEND fuss.
          ENDLOOP.
          CLEAR xlaus.
          xconfirm = x.
        ENDIF.
      ENDIF.
      IF NOT vm07m-soblo IS INITIAL OR mseg-sobkz = p       "389484
                                    OR mseg-bustm = 'MTRA'  "389484
                                    OR mseg-bustm = 'MTRE'  "389484
                                    OR mseg-bustm = 'MTRQ'  "389484
                                    OR t156-bustr = '107'   "SIT
                                    OR t156-bustr = '167'   "1639088
                                    OR mseg-sobkz = 'T'.    "SIT
* OMA EHP4
        IF NOT ( gv_mm_om1_sfws_sc_active EQ abap_true
           AND t156-bustr EQ bustr_64a ).
          CLEAR mseg-lgort.
        ENDIF.
      ELSE.
*/OMA EHP4

* tied empties don't necessarily need a storage loc;
        IF mseg-lgort IS INITIAL  AND
           NOT ( mseg-xauto = l  OR  mseg-xauto = f  OR
                 mseg-xauto = m  OR  mseg-xauto = w ) AND
           NOT ( t156-bustr = '107' OR mseg-sobkz = 'T' OR      "SIT
                 t156-bustr = '68E' OR t156-bustr = '69E' OR    "SIT
                 t156-bustr = '167' OR t156-bustr = '559' ).    "SIT

* Umbewertung Chargen: Lagerort nicht erforderlich
ENHANCEMENT-SECTION     mm07mfl0_lagerortdaten_08 SPOTS es_sapmm07m.
          IF NOT t156-kzbwa EQ kzbwa-07.
            PERFORM no_input(sapfm07m) USING 'MSEG' 'LGORT'.
          ENDIF.

END-ENHANCEMENT-SECTION.
          "$$
        ENDIF.
        IF NOT mseg-lgort IS INITIAL.
          CLEAR xt001l.
          xt001l-werks = mseg-werks.
          xt001l-lgort = mseg-lgort.
          xt001l-xlong = dm07m-xlong.
          PERFORM lagerort_pruefen(sapfm07m) USING xt001l
                                                   mseg-bwart.
          dm07m-xlong = xt001l-xlong.
          vm07m-vkorg = xt001l-vkorg.                       "HUM
          vm07m-vtweg = xt001l-vtweg.                       "HUM
          vm07m-vstel = xt001l-vstel.                       "HUM
*         vm07m-spart is always filled by material data and "373620
*         cannot be replaced by t001l-spart. Old_spart is   "373620
*         used as dummy for gn_delivery_create.
          old_spart   = xt001l-spart.                       "HUM
          vm07m-xhupf = xt001l-xhupf.                       "HUM
          vm07m-sdkun = xt001l-kunnr.                       "HUM
          vm07m-sdlif = xt001l-lifnr.                       "HUM
        ELSEIF mseg-xauto = l  OR  mseg-xauto = f  OR
               mseg-xauto = m  OR  mseg-xauto = w.
* no storage loc for a tied empty -> xlong-Flag is taken from the
* full product
          dm07m-xlong = t001l-xlong.
        ENDIF.

*                                                 begin of note 610068
* in case the form is:
* - not being called via mb_create
* - and the storage location has been changed
*   (e.g. for a posting using MB1A related to a production order):
*
* -> check whether it has been changed from either:
*    - a HU-managed only -> WM-managed only location
*    - or from a HU- and WM-managed -> WM-managed only location

* -> if yes, throw an error message, as in the old transactions such a
*    change can lead to the creation of an mm-movement without
*    triggering the necessary WM-transportation request.

        IF mseg-zeile <> zeile_old AND
           xmbwl IS INITIAL.           " no call via mb_create

*         store WM- and HU-related info in case the line has changed
*         and transaction is not being called via mb_create
          zeile_old = mseg-zeile.
          lgort_old = mseg-lgort.
          xhupf_old = xt001l-xhupf.

*         determine, whether storage location is WM-managed
*         (mseg-xblvs has not yet been filled, it will only
*          be filled by lvs_communication_mb later on)
          CALL FUNCTION 'T320_SINGLE_READ'
            EXPORTING
              t320_werks       = mseg-werks
              t320_lgort       = mseg-lgort
*             OBEST_FLAG       = ' '
*             KZRFB            = ' '
*            IMPORTING
*              WT320           =
            EXCEPTIONS
              not_found        = 1
              OTHERS           = 2
                    .
          IF sy-subrc = 0.
            xblvs_old = x.
          ELSE.
            CLEAR xblvs_old.
          ENDIF.

        ELSEIF mseg-zeile = zeile_old  AND
               mseg-lgort <> lgort_old AND
               xmbwl IS INITIAL.

*         determine, whether storage location is WM-managed
*         (mseg-xblvs has not yet been filled, as it will only
*          be filled by lvs_communication_mb later on)
          CALL FUNCTION 'T320_SINGLE_READ'
            EXPORTING
              t320_werks       = mseg-werks
              t320_lgort       = mseg-lgort
*             OBEST_FLAG       = ' '
*             KZRFB            = ' '
*            IMPORTING
*              WT320           =
            EXCEPTIONS
              not_found        = 1
              OTHERS           = 2
                    .
          IF sy-subrc = 0.
            xblvs_new = x.
          ELSE.
            CLEAR xblvs_new.
          ENDIF.

*         xdeliv flag is still set, as if a delivery would have
*         to be created (must not be reset here, as the field has to be
*         set globally, as soon as there is one position for
*         which a delivery has to be created)
          IF NOT xdeliv IS INITIAL

*            changed storage location is WM-managed only
             AND ( NOT xblvs_new IS INITIAL AND
                   xt001l-xhupf IS INITIAL      )

*            original storage location was either HU-managed only...
             AND ( ( xblvs_old IS INITIAL AND
                     NOT xhupf_old IS INITIAL )

*                  ...or HU- and WM-managed
                   OR  ( NOT xblvs_old IS INITIAL AND
                         NOT xhupf_old IS INITIAL    )
                 ).

            MESSAGE e440 WITH lgort_old mseg-lgort sy-tcode.

          ENDIF. "if not xdeliv is initial

        ENDIF. "mseg-zeile <> zeile_old
*                                                     end of note 610068
      ENDIF.
      IF mseg-sobkz = p.
        CLEAR: bqpex, bqpim.
        IF mseg-lifnr IS INITIAL.
          PERFORM pipeline_lief_ermitteln(sapfm07m).
        ELSE.
          bqpex-flief = mseg-lifnr.
          bqpex-infnr = dm07m-infnr.
          bqpim-werks = mseg-werks.
          bqpim-matnr = mseg-matnr.
        ENDIF.
      ENDIF.
      IF NOT ( mseg-kzbew = b AND mseg-sobkz = o ).
        mseg-emlif = mseg-lifnr.
      ENDIF.
ENHANCEMENT-POINT MM07MFL0_LAGERORTDATEN_10 SPOTS ES_MM07MTOP STATIC .

ENHANCEMENT-SECTION     mm07mfl0_lagerortdaten_03 SPOTS es_sapmm07m.
      PERFORM sonderbestand_pruefen(sapfm07m) USING mseg-sobkz
                                                    mseg-emlif
                                                    mseg-kunnr
                                                    mseg-mat_kdauf
                                                    mseg-mat_kdpos
                                                    mseg-plpla
                                                    mseg-mat_pspnr
                                                         lifnr
                                                         kunnr
                                                         kdauf
                                                         kdpos
                                                         plpla
                                                         pspnr
                                                    ls_isu_sonderbestand_pruefen. "IS2ERP     .
END-ENHANCEMENT-SECTION.
      IF NOT fuss-werks IS INITIAL
         AND fuss-werks NE mseg-werks.
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
      ENDIF.
      CLEAR maktx.
      IF NOT fuss-maktx IS INITIAL AND fuss-matnr = mseg-matnr.
        maktx = fuss-maktx.
      ENDIF.
      DATA: bwtar LIKE mseg-bwtar.
      DATA: kzbws LIKE mseg-kzbws. CLEAR kzbws.
      bwtar = mseg-bwtar.
ENHANCEMENT-SECTION     mm07mfl0_lagerortdaten_04 SPOTS es_sapmm07m.
      IF mseg-sobkz = e OR mseg-sobkz = q OR mseg-sobkz = t.       "SIT
        kzbws = mseg-kzbws.
      ELSE.
        CLEAR mseg-kzbws.
      ENDIF.
END-ENHANCEMENT-SECTION.
* Goods receipt for a purchase order (e.g. with movement 102)    "860197
* for split valuated materials which have no batch management    "860197
* requirement indicator should be possible                       "860197
* start of correction for Note 715479:
* process: a goods-receipt with reference to a purchase order is posted
* with transaction MIGO. The relevant item is a return item and the
* material is split valuated. If the valuation type has not been entered
* in the purchase order but in transaction MIGO, the valuation-type
* (MSEG-BWTAR) must be handed over to the field "batch" (MSEG-CHARG).
* Otherwise error M7 347 is generated in subroutine MATERIAL_LESEN.
* With this correction transaction MIGO behaves like transaction MB01.
* ADDITION BY NOTE 799313.
* The note 799313 modifies this correction to allow movement in case of
* Return delivery of a Material document too.
      IF xmigo = 'X'.
        IF NOT dm07m-bwtty IS INITIAL AND
               dm07m-xchar = 'X'      AND
               vm07m-xchpf IS INITIAL AND
               ( vm07m-retpo = 'X' OR
                 vm07m-xstor = ' ' OR                       "860197
                 vm07m-xstor = '1' )  AND    "Added for Note 799313
               mseg-kzbew  = 'B'      AND
               mseg-charg IS INITIAL.
          mseg-charg = mseg-bwtar.
          CLEAR mseg-bwtar.
        ENDIF.
      ENDIF.
* end of correction for Note 715479
ENHANCEMENT-POINT EHP604_LAGERORTDATEN_01 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT mm07mfl0_lagerortdaten_05 SPOTS es_sapmm07m.
      PERFORM material_pruefen(sapfm07m) USING mseg-matnr
                                              vm07m-bwkey
                                               mseg-bwtar
                                               mseg-werks
                                               mseg-lgort
                                               mseg-charg
                                               mseg-shkzg
                                               mseg-sobkz
                                              vm07m-sobfi
                                              vm07m-soblo
                                              vm07m-sobvo
                                                    lifnr
                                                    kunnr
                                                    kdauf
                                                    kdpos
                                                    plpla
                                              vm07m-lfgja
                                              vm07m-lfmon
                                                    space
                                                    s
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
                                               mseg-kzbws
                                              dm07m-xlaut
                                              dm07m-berid   "454320
                                  ls_isu_material_pruefen   "IS2ERP
                                      CHANGING   l_xkzbws_change. "627312
ENHANCEMENT-POINT mm07mfl0_lagerortdaten_06 SPOTS es_sapmm07m.
* vsa_lg anfang
      IF NOT mbefu-mlgut IS INITIAL AND  xmbwl IS INITIAL.
* keep in mind the full product
        PERFORM leergut_fuellen_vgmseg.
      ENDIF.
* vsa_lg ende
      IF vm07m-soblo IS INITIAL AND NOT mseg-sobkz = p AND  "389484
         mseg-lgort IS INITIAL  AND NOT ( mseg-bustm = 'MTRA' OR "389484
                                          mseg-bustm = 'MTRE' OR "389484
                                          mseg-bustm = 'MTRQ' ). "389484
* bei geb. Leergut kein Lagerort erforderlich, Buchung auf MARC
        IF NOT ( mseg-xauto = l  OR  mseg-xauto = f  OR
                 mseg-xauto = m  OR  mseg-xauto = w ) AND
           NOT ( t156-bustr = '107' OR mseg-sobkz = 'T' OR      "SIT
                 t156-bustr = '68E' OR t156-bustr = '69E' OR    "SIT
                 t156-bustr = '167' OR t156-bustr = '559' ).    "SIT
* Umbewertung Chargen: Lagerort nicht erforderlich
ENHANCEMENT-SECTION     mm07mfl0_lagerortdaten_07 SPOTS es_sapmm07m.
          IF NOT t156-kzbwa EQ kzbwa-07.
              PERFORM no_input(sapfm07m) USING 'MSEG' 'LGORT'.
          ENDIF.
END-ENHANCEMENT-SECTION.
          "$$
        ENDIF.
      ENDIF.
*     We must not post a document with a KZBWS that differs from special
*     stock entries (MSSQ, MSSA) that are already in the system (first
*     condition).
*     but: MSEG-KZBWS is changed intentionally within MATERIAL_LESEN in
*     special cases and then, it is not consistent with the field KZBWS
*     that was used to keep the value from MSEG within this form routine
*     during MATERIAL_PRUEFEN (calls MATERIAL_LESEN)
*     Check for customizing: If there is already a wrong entry or if
*     there were customizing changes in the meantime, we have to use
*     KZBWS as it is already in MSSQ or to refuse the posting
*     If sending an error message, we reset MSEG-KZBWS to the value
*     protected in KZBWS, otherwise we post with KZBWS from MSSQ.
      IF ( NOT mseg-kzbws = kzbws ) AND ( inventur IS INITIAL ).
        IF mseg-kzbew = b OR mseg-kzbew = f.                " 560226
          mseg-kzbws = kzbws.                               " 560226
          MESSAGE e242.                                     " 560226
*       condition, when KZBWS has to be changed because a non-valuated
*       material must not be valuated when it belongs to project stock
*       note 607325: logic for MSSQ extended to MSSA
*       note 627312: make check easier - was it done intentionally?
        ELSEIF NOT l_xkzbws_change = x.                     " 627312
          CALL FUNCTION 'ME_CHECK_T160M'
            EXPORTING
              i_arbgb = 'M7'
              i_msgnr = '242'
              i_msgvs = msgvs
            EXCEPTIONS
              nothing = 00
              warning = 01
              error   = 02.
          CASE sy-subrc.
            WHEN 0.
              mseg-kzbws = kzbws.                           " 560226
              MESSAGE e242.
            WHEN 1.
              IF xmigo = x.                                 " 607325
                CALL FUNCTION 'MICK_MESSAGE_ADD'            " 607325
                  EXPORTING                                 " 607325
                    i_msgty          = w                    " 607325
                    i_msgid          = 'M7'                 " 607325
                    i_msgno          = '242'.               " 612451
              ELSE.                                         " 607325
                MESSAGE w242.
              ENDIF.                                        " 607325
            WHEN 2.
              mseg-kzbws = kzbws.                           " 560226
              MESSAGE e242.
          ENDCASE.
*    Bewertungssteuerung im Materialstamm und Sonderbestand weichen ab
        ENDIF.                                              " 560226
      ENDIF.
*     if t158-kzbew = f and
      IF mseg-kzbew = f AND
         ( ( mseg-bwtar NE bwtar AND NOT xkont IS INITIAL ) OR
           dm07m-konto IS INITIAL OR
         ( NOT mseg-kzbws = a AND NOT mseg-kzbws IS INITIAL ) ).
        PERFORM kontierung_lesen USING  mseg-parbu
                                       dm07m-parwk
                                       dm07m-umkpl
                                       dm07m-umper
                                       dm07m-umwae
                                        mkpf-budat
                                       dm07m-umgja
                                       dm07m-ummon
                                       dm07m-konto
                                        mseg-anln1.
        PERFORM kontierung_pruefen.
      ENDIF.
      CLEAR bwtar.
      IF NOT fuss-maktx IS INITIAL AND fuss-matnr = mseg-matnr.
        dm07m-maktx = maktx.
      ENDIF.
      IF NOT kzdzv = eins OR vm07m-xchpf IS INITIAL.
ENHANCEMENT-POINT lagerortdaten_02 SPOTS es_sapmm07m.

        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'MB_CHECK_MATERIAL_STRING'
    TABLES
      x156m = x156m
      x156w = x156w
    CHANGING
      dm07m = dm07m
      vm07m = vm07m
      mseg  = mseg.
* Bei Kontierten Bestellungen mchb segment anlegen.
  IF ( mseg-kzbew = b AND NOT mseg-kzvbr IS INITIAL ) OR
     ( mseg-kzbew = f AND ( mseg-kzbws = a OR mseg-kzbws IS INITIAL ) ).
    IF NOT mseg-charg IS INITIAL AND NOT vm07m-xchpf IS INITIAL.
      DATA: flag1, char1.
*     Check if valuation type of batch matches to the valuation type
*     received by the purchase order
*     Check valuation type only if order / purchase order       "505102
*     is accounted                                              "505102
      IF ( mseg-kzbew = b AND NOT mseg-kzvbr IS INITIAL ) OR "505102
         ( mseg-kzbew = f AND NOT mseg-kzvbr IS INITIAL ).  "505102
        DATA: l_bwtar LIKE mcha-bwtar.                     "note 450913
        IF NOT mseg-bwtar IS INITIAL.                      "note 450913
          SELECT SINGLE bwtar FROM mcha                    "note 450913
                              INTO l_bwtar                 "note 450913
                              WHERE matnr = mseg-matnr     "note 450913
                                AND werks = mseg-werks     "note 450913
                                AND charg = mseg-charg.    "note 450913
          IF sy-subrc = 0 AND l_bwtar <> mseg-bwtar        "note 450913
            AND NOT l_bwtar IS INITIAL.                     "532985
            MESSAGE e424(m7) WITH mseg-bwtar.              "note 450913
          ENDIF.                                           "note 450913
          CLEAR l_bwtar.                                   "note 450913
        ENDIF.                                             "note 450913
      ENDIF.                                                "505102
      PERFORM charge_character_check(sapfm07m) USING mseg-charg
                                            CHANGING flag1
                                                     char1.
      IF NOT flag1 IS INITIAL.
        SET CURSOR FIELD 'MSEG-CHARG'.
        MESSAGE e567(m3) WITH char1.
      ENDIF.
      mtcom-matnr = mseg-matnr.                             "note391090
      mtcom-werks = mseg-werks.                             "note391090
      mtcom-charg = mseg-charg.
      CLEAR ls_mtcom.                                       "657671
      MOVE-CORRESPONDING mtcom TO ls_mtcom.                 "657671
      ls_mtcom-kenng = 'MBEFU'.                             "657671
      DATA: charg_mtcor LIKE mtcor.
      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel = ls_mtcom                             "657671
        IMPORTING
          return     = charg_mtcor.
      mbefu-charg = mseg-charg.
      mbefu-matnr = mseg-matnr.
      mbefu-werks = mseg-werks.
      PERFORM chargendaten_mat_setzen(sapfm07m) USING mseg-matnr
                                                      mseg-werks
                                                      mseg-charg.
      xmtcor-rmcha = charg_mtcor-rmcha.
      xmtcor-rmch1 = charg_mtcor-rmch1.

* Cancellation goods receipt XLORT = ' '
      IF xmbwl = 'X' AND dm07m-xlort = ' '                  "865115
       AND vm07m-xstor = 2.                                 "865115
        PERFORM chargendaten_pruefen(sapfm07m) USING mseg-matnr "865115
                                                     mseg-werks "865115
                                                     mseg-charg "865115
                                                     space  "865115
                                                     space. "865115
      ENDIF.                                                "865115

* Goods receipt for purchase order assigned to an account should "923611
* not overwrite VFDAT HSDAT in the batch master                  "923611
      IF dm07m-xlort = ' ' AND dm07m-xchar = 'X'            "923611
       AND dm07m-xwmhd = 'X' AND dm07m-kzmhd = ' '.         "923611
        PERFORM chargendaten_pruefen(sapfm07m) USING mseg-matnr "923611
                                                     mseg-werks "923611
                                                     mseg-charg "923611
                                                     space  "923611
                                                     space. "923611
      ENDIF.                                                "923611

* Goods Receipt for Purchase Order assigned to a cost center     "1069088
* should not overwrite VFDAT HSDAT in the batch master when the  "1069088
* shelf life expiration check is NOT active for the plant        "1069088
      IF dm07m-xlort = ' ' AND dm07m-xchar = 'X'            "1069088
       AND dm07m-xwmhd = ' '.                               "1069088
        PERFORM chargendaten_pruefen(sapfm07m) USING mseg-matnr "1069088
                                                     mseg-werks "1069088
                                                     mseg-charg "1069088
                                                     space  "1069088
                                                     space. "1069088
      ENDIF.                                                "1069088

* Third-Party according to note 372184
      IF vm07m-pstyp = '5'.                                 "683619
        PERFORM chargendaten_pruefen(sapfm07m) USING mseg-matnr
                                                     mseg-werks
                                                     mseg-charg
                                                     space
                                                     space.
      ENDIF.                                                "683619
      PERFORM chargendaten_mat_cfc.
      CALL FUNCTION 'MB_FILL_MCHA_ENQUEUE_TABLE'
        EXPORTING
          mbefu = mbefu
          rmcha = charg_mtcor-rmcha
          kzdch = kzdch
        TABLES
          xmcha = xmcha.
      CALL FUNCTION 'MB_FILL_MCH1_ENQUEUE_TABLE'
        EXPORTING
          mbefu = mbefu
          rmch1 = charg_mtcor-rmch1
          kzdch = kzdch
        TABLES
          xmch1 = xmch1.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT lagerortdaten_03 SPOTS es_sapmm07m.

ENDFORM.                    "lagerortdaten