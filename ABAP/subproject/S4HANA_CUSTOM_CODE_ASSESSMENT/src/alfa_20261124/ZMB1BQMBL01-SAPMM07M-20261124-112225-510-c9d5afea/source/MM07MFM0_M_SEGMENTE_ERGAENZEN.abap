*eject
*---------------------------------------------------------------------*
*       FORM M-SEGMENTE_ERGAENZEN                                     *
*---------------------------------------------------------------------*
*       Die Segmente des Materialbelegs werden ergaenzt.              *
*---------------------------------------------------------------------*
FORM m-segmente_ergaenzen.

  DATA: BEGIN OF bezei OCCURS 0,
          tabix LIKE sy-tabix,
          buzei LIKE ekbz-buzei,
        END OF bezei.
  DATA: dindx LIKE sy-index,
        uindx LIKE sy-index,
        dzeil LIKE mseg-zeile,
        aufteiler TYPE c.

  DATA: ls_ftrade TYPE ftkey,
        l_xblnr_first_line TYPE vm07m-xblnr_avis,
        l_frbnr_first_line TYPE vm07m-frbnr_avis.

ENHANCEMENT-POINT m-segmente_ergaenzen_01 SPOTS es_sapmm07m STATIC.
  CLEAR: dindx, uindx, dzeil, aufteiler.
  a_zeile = 0.
* check and correction of XDELIV
  IF rm07m-xdeliv IS INITIAL AND xdeliv = x AND xmbwl IS INITIAL."HUM
    PERFORM sd_check_xdeliv.                                "HUM
  ENDIF.                                                    "HUM
* Lieferung initialisieren (WMS-Komponente +Lieferung aus Warenbewegung)
  IF mkpf-bfwms = 1 OR xdeliv = x.                          "HUM
    PERFORM wms_lieferung_init.
  ENDIF.
  IF NOT xower IS INITIAL AND NOT xmseg_lines IS INITIAL.
    DESCRIBE TABLE xmseg LINES sy-tabix.
    IF sy-tabix NE xmseg_lines.
      MESSAGE e276.
    ENDIF.
  ENDIF.
* clear t156n was added for form SD_FOLGEBEWEGUNGSART_ERMITTELN "501686
  CLEAR t156n.                                              "501686
  DATA l_skip TYPE c.                                       "772903

  LOOP AT xmseg.
    IF mkpf-bfwms = 1 OR xdeliv = x.                     "note 552577
      IF xmseg-bwart = bwart_341 OR xmseg-bwart = bwart_342. "552577
        MESSAGE e462 WITH xmseg-bwart.                   "note 552577
      ENDIF.                                             "note 552577
    ENDIF.                                               "note 552577
    DATA: segindex LIKE sy-tabix.
ENHANCEMENT-POINT m-segmente_ergaenzen_02 SPOTS es_sapmm07m STATIC.
    segindex = sy-tabix.
    if_secon.
    CLEAR xmseg-xwoff.
    end_secon.
    IF NOT xower IS INITIAL.
      CLEAR xmseg-xwoff.
    ENDIF.
    READ TABLE ymbuz INDEX xmseg-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'YMBUZ' xmseg-zeile.
    ENDIF.
    READ TABLE zmbuz INDEX ymbuz-zeilz.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZMBUZ' ymbuz-zeilz.
    ENDIF.
    READ TABLE zdm07m INDEX ymbuz-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZDM07M' ymbuz-zeile.
    ENDIF.
ENHANCEMENT-POINT m-segmente_ergaenzen_03 SPOTS es_sapmm07m.
    READ TABLE xvm07m INDEX xmseg-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'XVM07M' xmseg-zeile.
    ENDIF.
    PERFORM m-segment_zuordnen USING space.
* Lieferung generieren (WMS-Komponente + Lieferung aus Warenbewegung)
    IF mkpf-bfwms = 1 OR xdeliv = x.                        "HUM
*     In repetitive manufacturing MB_CREATE might be called several
*     times before posting. Items which already have been processed
*     by GN_DELIVERY_CREATE must be skipped here.
*     note 772903
      CLEAR l_skip.                                         "772903_v
      IF NOT xmbwl IS INITIAL.
        CALL FUNCTION 'MIMB_BEAKZ_IMPORT'
          EXPORTING
            i_line_id     = xmseg-line_id
          IMPORTING
            e_del_created = l_skip.
      ENDIF.
      IF l_skip IS INITIAL.                                 "772903_^
        PERFORM wms_lips_generieren.
      ENDIF.                                                "772903
      rc = 8.
    ENDIF.
* rc=8: this item will not be posted in material document
* Instead it will be inserted in the delete table ymdel
* and deleted at the end of the routine.
    IF rc = 8.
      if_first.                        " Begin erster Schritt
      ymdel-zeile = xmseg-zeile.
      ymdel-yzeil = ymbuz-zeile.
      IF xmseg-lfbnr IS INITIAL AND NOT xvm07m-webre IS INITIAL AND
         xmseg-kzbew IS INITIAL AND                         "204573
         t158-kzbew = b AND xvm07m-pstyp = drei.
        LOOP AT zeklb WHERE zeile = xmseg-zeile
                      AND   curtp = curtp10.
          ymdel-zeilx = zeklb-zeilx.
          EXIT.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'ZEKLB' xmseg-zeile.
        ENDIF.
      ENDIF.
      APPEND ymdel.
      IF NOT dzeil = ymbuz-zeile.
        dindx = dindx + 1.
        IF NOT zdm07m-kzuml IS INITIAL.
          uindx = uindx + 1.
        ENDIF.
        dzeil = ymbuz-zeile.
      ENDIF.
      CLEAR ymbuz-zeile.
      MODIFY ymbuz INDEX xmseg-zeile.
      end_first.

    ELSE.                                                   "rc <> 8
*   ------------------- items will be created -----------------------
*   rc=0: The item will be inserted to MSEG. Be careful: at this point
*   the item does not have a stable item number. It is going to be
*   renumbered here!! All dependent tables have to be renumbered as well
      READ TABLE xvm07m INDEX xmseg-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'XVM07M' xmseg-zeile.
      ENDIF.
      IF rc = 0.
        xmseg-sakto = ymbuz-sakto.
        xmseg-dmbtr = yfbuz-dmbtr.
        xmseg-bualt = yfbuz-bualt.
        xmseg-bnbtr = yfbuz-bnbtr.
        xvm07m-awewr = yfbuz-awewr.
        xvm07m-aweww = yfbuz-aweww.
        IF xmseg-kzbew = o.                                 "P45
          xmseg-shkzg = yfbuz-shkzg.                        "P45
        ENDIF.                                              "P45
* begin 203679
        IF NOT tcurm-mbequ  IS INITIAL AND
*          NOT ZDM07M-VVKWR IS INITIAL AND
*begin note 378560
*         ( zdm07m-kzuml IS INITIAL OR xmseg-xauto IS INITIAL ) AND
         ( zdm07m-kzuml IS INITIAL OR NOT xmseg-xauto = 'X' ) AND
*consider the other possible values of xauto
*end note 378560
           zdm07m-vvkwr NE xmseg-vkwrt.
          xmseg-vkwra = xmseg-vkwra * zdm07m-vvkwr / xmseg-vkwrt.
          xmseg-vkwrt = zdm07m-vvkwr.
        ENDIF.
        IF NOT tcurm-mbequ  IS INITIAL AND
           NOT zdm07m-kzuml IS INITIAL AND
*begin note 378560
*           NOT xmseg-xauto IS INITIAL  AND
           xmseg-xauto = 'X' AND
* we gotta consider xauto = 'M' or 'W' when doing a transfer posting
*end note 378560
           zdm07m-umvkw NE xmseg-vkwrt.
          xmseg-vkwra = zdm07m-umvka.
          xmseg-vkwrt = zdm07m-umvkw.
        ENDIF.
        IF xmseg-vkwrt < 0.
          xmseg-vkwra = 0 - xmseg-vkwra.
          xmseg-vkwrt = 0 - xmseg-vkwrt.
        ENDIF.
* end 203679
      ELSE.
        CLEAR: xmseg-dmbtr, xmseg-bualt, xmseg-bnbtr.
        yfbuz-monat = xvm07m-monat.
      ENDIF.
*     Item table for foreign trade.
*     MIGO: Ftrade data has been created with expos = global_counter
*     MB01: Ftrade data has been created with expos = (old) mseg-zeile
      ls_ftrade-exnum = mkpf-exnum.
      IF xmseg-kzbew EQ b.
        IF xmigo = x.
          ls_ftrade-expos = xvm07m-global_counter.
        ELSE.
          ls_ftrade-expos = xmseg-zeile.   "this is the old item number
        ENDIF.
      ENDIF.
      INSERT ls_ftrade INTO TABLE gt_ftrade.
*
      IF NOT xvm07m-xlifu IS INITIAL.
        CLEAR xlifo.
        MOVE-CORRESPONDING xmseg TO xlifo.
        xlifo-matnr = xmseg-matbf.
        xlifo-monat = yfbuz-monat.
        xlifo-lbbtr = yfbuz-lbbtr.
        IF xmseg-kzbew = b
        OR xmseg-kzbew = f
        OR xmseg-bustw = bustw_wa04
        OR xmseg-bustw = bustw_wa06.
          xlifo-exwrt = xvm07m-awewr.
        ELSE.
          xlifo-exwrt = xmseg-exbwr.
        ENDIF.
ENHANCEMENT-POINT M-SEGMENTE_ERGAENZEN_11 SPOTS ES_SAPMM07M.
        APPEND xlifo.
        upd_xlifo = x.
      ENDIF.
      IF xmseg-xruem IS INITIAL.
        CLEAR: xmseg-shkum, xmseg-dmbum.
      ELSE.
        PERFORM m-segment_zuordnen USING x.
        IF rc = 0.
          xmseg-shkum = yfbuz-shkzg.
          xmseg-dmbum = yfbuz-dmbtr.
        ELSE.
          CLEAR: xmseg-shkum, xmseg-dmbum.
        ENDIF.
      ENDIF.
      READ TABLE xmkpf INDEX 1.
      IF NOT sy-subrc IS INITIAL.
        xmkpf = mkpf.
        APPEND xmkpf.
      ENDIF.
      xmseg-mandt = xmkpf-mandt.
*     Keep some header information redundantly in MSEG  "n1516684
*     for better performance of material document lists "n1516684
*     MSEG was enhanced by some chosen MKPF fields      "n1516684
      xmseg-budat_mkpf  = xmkpf-budat.                  "n1516684
      xmseg-usnam_mkpf  = xmkpf-usnam.                  "n1516684
      xmseg-xblnr_mkpf  = xmkpf-xblnr.                  "n1516684
      xmseg-vgart_mkpf  = xmkpf-vgart.                  "n1516684
      xmseg-cpudt_mkpf  = xmkpf-cpudt.                  "n1516684
      xmseg-cputm_mkpf  = xmkpf-cputm.                  "n1516684
      xmseg-tcode2_mkpf = xmkpf-tcode2.                 "n1516684
*     counter for items that will be created. Will be mseg-zeile.
      a_zeile = a_zeile + 1.
      xvm07m-zeilv = a_zeile.
      IF xmseg-lfbnr IS INITIAL AND NOT xvm07m-webre IS INITIAL
         AND ( xmseg-kzbew = b OR xvm07m-pstyp = drei ).
        xmseg-lfbja = xmkpf-mjahr.

        IF xmseg-kzbew IS INITIAL.                          "204573
          IF xvm07m-pstyp = drei.
            LOOP AT zeklb WHERE zeile = xmseg-zeile
                          AND   curtp = curtp10.
              LOOP AT ymdel WHERE zeile = zeklb-zeilx.
                EXIT.
              ENDLOOP.
              IF sy-subrc IS INITIAL.
                CLEAR xmseg-lfpos.
              ELSE.
                DESCRIBE TABLE ymdel LINES t_index.
                LOOP AT ymdel WHERE zeilx = zeklb-zeilx.
                  t_index = t_index - 1.
                ENDLOOP.
                xmseg-lfpos = zeklb-zeilx - t_index.
              ENDIF.
              EXIT.
            ENDLOOP.
            IF NOT sy-subrc IS INITIAL.
              MESSAGE e001 WITH 'ZEKLB' xmseg-zeile.
            ENDIF.
          ENDIF.
        ELSE.
          IF xmseg-maa_urzei IS INITIAL.                    "MAA2
            xmseg-lfpos = a_zeile.
          ELSE.                                             "MAA2
            xmseg-lfpos = xmseg-maa_urzei.                  "MAA2
          ENDIF.                                            "MAA2
        ENDIF.
        lfbnr-zeile = a_zeile.
        APPEND lfbnr.
      ENDIF.
      MODIFY xvm07m INDEX xmseg-zeile.
      IF xmseg-bukrs = xmseg-parbu.
        CLEAR xmseg-parbu.
      ENDIF.
      ymbuz-zeile = ymbuz-zeile - dindx.
      MODIFY ymbuz INDEX xmseg-zeile.
      IF ymbuz-xauto IS INITIAL.
        LOOP AT xekbz WHERE ebeln = xmseg-ebeln
                      AND   ebelp = xmseg-ebelp
                      AND   buzei = ymbuz-zeilz.
          bezei-tabix = sy-tabix.
          bezei-buzei = a_zeile.
          APPEND bezei.
        ENDLOOP.
      ENDIF.
      if_first.
*IS2ERP Temporary change to avoid syntax errors
      DATA count_urzei LIKE sy-tabix.
ENHANCEMENT-SECTION     m-segmente_ergaenzen_04 SPOTS es_sapmm07m.
      IF xmseg-xauto IS INITIAL AND
         ( NOT xvm07m-pstyp = drei OR
           NOT xmseg-kzbew IS INITIAL ).                    "204573
        xmseg-urzei = a_zeile.
      ELSE.
*       DATA loc_tabix LIKE sy-tabix. CLEAR loc_tabix.
*        DATA count_urzei LIKE sy-tabix.
*       Note 329696: coding for subitems only.
*       Subitems should receive the URZEI of the main item here.
*       In case of F12, ZMSEG table is already correct and XMSEG also
*       because already corrected in BUCHEN_INITIALISIEREN.
*       Handling of zero lines
*       In case of zero quantity lines, lines are deleted from XMSEG but
*       remain in ZMSEG. So we have to renumber URZEI based on the
*       future XMSEG. This info is in YMBUZ.
*       We first find the ZMBUZ entry of the main item with XMSEG-URZEI
*       (which still has the old URZEI from ZMSEG), then loop at YMBUZ
*       until we find the main item and during that loop set the counter
*       for URZEI. As zero lines are ignored (YMBUZ-ZEILE = 0000), the
*       count_urzei contains the urzei of the main item. Then we set the
*       count_urzei to the current subitem (xmseg-urzei).
        LOOP AT zmbuz WHERE urzey = xmseg-urzei.
          CLEAR count_urzei.
          LOOP AT ymbuz WHERE zeilz LE zmbuz-urzey  "note 329696
                         AND zeile NE '0000'.
            IF NOT ymbuz-zeilz = zmbuz-urzey.        "note 329696
              count_urzei = count_urzei + 1.
            ELSE.
              count_urzei = count_urzei + 1.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF NOT count_urzei IS INITIAL.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF count_urzei IS INITIAL.
          MESSAGE e001 WITH 'ZMBUZ' xmseg-urzei.
        ENDIF.
        xmseg-urzei = count_urzei.
      ENDIF.
END-ENHANCEMENT-SECTION.

      end_first.

* for GR/IR based Invoice Verification: fill xaccit-xref3
* with year and position of original material document, document
* number (stern) will be filled by FI => note 323135
      FIELD-SYMBOLS <fs_xaccit> TYPE accit.
      DATA oref   TYPE REF TO cx_root.
      IF NOT xvm07m-webre IS INITIAL.                      "note 323135
        LOOP AT xaccit ASSIGNING <fs_xaccit>               "note 323135
             WHERE zeile = xmseg-zeile                     "note 323135
               AND ktosl = 'WRX'.                          "note 323135
          IF NOT xmseg-lfbnr IS INITIAL.                   "note 323135
            <fs_xaccit>-xref3       = xmseg-lfbja.         "note 323135
            <fs_xaccit>-xref3+4(10) = xmseg-lfbnr.         "note 323135
* note 394597: in case of services (pstyp 9) do not fill lfpos because
* matdocument and invoice are filled differently, so WRX cannot match
            IF xvm07m-pstyp <> '9'.                         "394597
              <fs_xaccit>-xref3+14(4) = xmseg-lfpos.        "394597
            ELSE.
* Required PSM-FM logic, refer to function module's comments for details
              CALL FUNCTION 'FUNCTION_EXISTS'
                EXPORTING
                  funcname           = 'FM_POPULATE_XREF2'
                EXCEPTIONS
                  function_not_exist = 1
                  OTHERS             = 2.
              IF sy-subrc = 0.
                TRY.
                    CALL FUNCTION 'FM_POPULATE_XREF2'
                      EXPORTING
                        i_bukrs = <fs_xaccit>-bukrs
                        i_lfpos = xmseg-lfpos
                        i_fikrs = <fs_xaccit>-fikrs
                      CHANGING
                        c_xref2 = <fs_xaccit>-xref2.
                  CATCH cx_sy_dyn_call_illegal_func INTO oref.
                ENDTRY.
              ENDIF.
            ENDIF.                                 "end of note 1343517
          ELSE.                                            "note 323135
            <fs_xaccit>-xref3(4)    = xmkpf-mjahr.         "note 323135
            <fs_xaccit>-xref3+4(1)  = stern.               "note 323135
            IF xvm07m-pstyp <> '9'.                         "394597
              <fs_xaccit>-xref3+14(4) = a_zeile.            "394597
            ELSE.
* Required PSM-FM logic, refer to function module's comments for details
              CALL FUNCTION 'FUNCTION_EXISTS'
                EXPORTING
                  funcname           = 'FM_POPULATE_XREF2'
                EXCEPTIONS
                  function_not_exist = 1
                  OTHERS             = 2.
              IF sy-subrc = 0.
                TRY.
                    CALL FUNCTION 'FM_POPULATE_XREF2'
                      EXPORTING
                        i_bukrs = <fs_xaccit>-bukrs
                        i_lfpos = a_zeile
                        i_fikrs = <fs_xaccit>-fikrs
                      CHANGING
                        c_xref2 = <fs_xaccit>-xref2.
                  CATCH cx_sy_dyn_call_illegal_func INTO oref.
                ENDTRY.
              ENDIF.
            ENDIF.                                         "note 323135
          ENDIF.                                           "note 323135
        ENDLOOP.                                           "note 323135
      ENDIF.                                               "note 323135

      IF NOT dindx IS INITIAL OR NOT xmseg-zeile = ymbuz-zeile.
        LOOP AT xaccit WHERE zeile = xmseg-zeile.
          xaccit-zeile = xaccit-zeile - dindx - uindx.
          xaccit-urzeile = xmseg-urzei.
          MODIFY xaccit.
        ENDLOOP.
      ENDIF.
ENHANCEMENT-POINT m-segmente_ergaenzen_05 SPOTS es_sapmm07m.
*     Keep XBLNR_AVIS/FRBNR_AVIS of the first line in mind.
*     If the next lines have a different one, clear it.
*     See explanation below (after endloop).
      IF a_zeile = 1.
        l_xblnr_first_line = xvm07m-xblnr_avis.
        l_frbnr_first_line = xvm07m-frbnr_avis.
      ELSE.
        IF xvm07m-xblnr_avis <> l_xblnr_first_line          "380685
           AND NOT xvm07m-xblnr_avis IS INITIAL.            "380685
          CLEAR l_xblnr_first_line.
        ENDIF.
        IF xvm07m-frbnr_avis <> l_frbnr_first_line          "380685
           AND NOT xvm07m-frbnr_avis IS INITIAL.            "380685

          CLEAR l_frbnr_first_line.
        ENDIF.
      ENDIF.
*
      xmseg-zeile = a_zeile.

*     Merge some data from external system (cross system movment)
      CALL METHOD cl_mmim_cross_system=>merge_xmseg         "sdp462
        CHANGING cs_xmseg = xmseg.                          "sdp462

      MODIFY xmseg.

ENHANCEMENT-POINT m-segmente_ergaenzen_06 SPOTS es_sapmm07m.
* start of note 206672
* make sure mbew is created if mseg is created with quantity 0,
* otherwise no cancelation possible
      IF ( ( xmseg-mengu IS INITIAL AND NOT xmseg-wertu IS INITIAL
            AND xmseg-vkwrt = 0 ) OR
            ( xmseg-erfmg = 0 AND xmseg-menge = 0 AND NOT
          ( xmseg-mengu IS INITIAL AND NOT xmseg-wertu IS INITIAL ) ) )
            AND NOT xmseg-elikz IS INITIAL.
        CALL FUNCTION 'MB_SET_FLAG_VALUE_UPDATE'
          EXPORTING
            i_matbf     = xmseg-matbf
            i_bwkey     = xvm07m-bwkey
            i_bwtar     = xmseg-bwtar
            i_sobkz     = xmseg-sobkz
            i_mat_kdauf = xmseg-mat_kdauf
            i_mat_kdpos = xmseg-mat_kdpos
            i_mat_pspnr = xmseg-mat_pspnr
            i_kzbws     = xmseg-kzbws
            i_xobew     = xmseg-xobew
            i_lifnr     = xmseg-lifnr
            i_ins_oblig = x
          TABLES
            xmbew       = xmbew
            xebew       = xebew
            xqbew       = xqbew
            xobew       = xobew
          EXCEPTIONS
            not_found   = 1
            OTHERS      = 2.
      ENDIF.
* end of note 206672

* Now the dependent tables will be renumbered with new xmseg-zeile
      IF ( NOT xvm07m-abeln IS INITIAL OR NOT xvm07m-aurel IS INITIAL )
         AND xvm07m-retpo IS INITIAL
         AND NOT xvm07m-attyp = attyp-sam.
        CLEAR xauwei.
        MOVE-CORRESPONDING xmkpf TO xauwei.
        MOVE-CORRESPONDING xmseg TO xauwei.
        xauwei-beltp = eins.
        IF NOT xvm07m-abeln IS INITIAL.
          xauwei-exauf = eins.
        ENDIF.
        xauwei-belpo = xmseg-zeile.
        xauwei-menge = xmseg-bstmg.
        IF xmseg-shkzg = s.
          xauwei-sign = plus.
        ELSEIF xmseg-shkzg = h.
          xauwei-sign = minus.
        ENDIF.
        APPEND xauwei.
        aufteiler = x.
      ENDIF.
      IF NOT xmseg-aufnr IS INITIAL.
        PERFORM pps_auftragsentwicklung USING  segindex.
      ENDIF.
*-----Localization Brazil -- TF transfer BRA, cancellation GI--
      DATA j_1b_tf_can_gi.
      PERFORM j_1b_tf_cancel_gi_check USING    xmseg-bwart
                                               brazil
                                      CHANGING j_1b_tf_can_gi.

*
      IF xmseg-kzbew = b OR ( xmseg-kzbew IS INITIAL AND
      ( ( xmseg-kzzug = x AND NOT xmseg-xauto = x ) OR
      xvm07m-pstyp = drei ) ) OR ( xmseg-kzbew = l AND
      ( xmseg-kzzug = x AND NOT xmseg-xauto = x ) )
*-----SIT
      OR ( xmseg-kzzug = x AND xmseg-xauto = x AND xmseg-sobkz <> 'T' AND
           cl_mm_im_sit_info=>get_sit_info_item( iv_ebeln = xmseg-ebeln iv_ebelp = xmseg-ebelp ) = 'X' )
*-----Localization BRA
      OR ( j_1b_tf_can_gi = x AND NOT xmseg-xauto = x ).
        PERFORM bestellentwicklung_generieren USING segindex.
      ENDIF.
      IF NOT xvm07m-xpbed IS INITIAL.
        PERFORM pbed_abbau_generieren.
      ENDIF.
      IF xmseg-sobkz = k OR xmseg-sobkz = p.
        PERFORM konsientwicklung_generieren USING segindex.
      ENDIF.
      IF xmseg-sobkz = o AND NOT xmseg-xobew IS INITIAL.    "kaz
        PERFORM obewentwicklung_generieren.                 "kaz
      ENDIF.                                                "kaz
    ENDIF.
*-- Prüfung Chargenpflicht und Kennzeichung von XMCHA / XMCH1
    IF NOT xmseg-charg IS INITIAL.
      PERFORM lmcha(sapfm07m) USING xmseg-matnr
                                    xmseg-werks
                                    xmseg-charg.
      IF rc IS INITIAL AND xmcha-xchup IS INITIAL.
        xmcha-xchup = x.
        MODIFY xmcha INDEX tabix.
      ENDIF.
      IF NOT xvm07m-xchpf IS INITIAL.
        PERFORM lmch1(sapfm07m) USING xmseg-matnr
                                      xmseg-charg.
        IF rc IS INITIAL AND xmch1-xchup IS INITIAL.
          xmch1-xchup = x.
          MODIFY xmch1 INDEX tabix.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.                             "End of main loop on XMSEG

* reset batches which should not be created
  DATA: lt_mchb LIKE TABLE OF mchb WITH HEADER LINE.
*- only with MIGO and MBxx-transactions batches could have been
*- inserted into CREATE/CHANGE-buffers that should not been posted
*- (mistyping etc.)
*- => ENQUEUE TABLES of Inventory Management are leading
*- 'normal' background postings hopefully don't do that but can fill
*- batches into these buffers for which no goods movement is posted
*- Batch buffers are leading
*- batch buffers are relevant all the time, also when called through BAPI_GOODSMVT_CREATE
  IF kzdch NE charge_auf_werk.
    LOOP AT xmch1 WHERE xchup NE space.
      CLEAR lt_mchb.
      lt_mchb-matnr = xmch1-matnr.
      lt_mchb-charg = xmch1-charg.
      APPEND lt_mchb.
    ENDLOOP.
  ENDIF.
  LOOP AT xmcha WHERE xchup NE space.
    CLEAR lt_mchb.
    lt_mchb-matnr = xmcha-matnr.
    lt_mchb-werks = xmcha-werks.
    lt_mchb-charg = xmcha-charg.
    APPEND lt_mchb.
  ENDLOOP.
  IF NOT xmigo IS INITIAL OR
         xmbwl IS INITIAL.
*- only storage location segments to be created
    LOOP AT xmchb
         WHERE rmchb NE space
           AND xdbup NE space.
*- filter out segments with 0 quantity
      CHECK NOT xmchb-clabs IS INITIAL OR
            NOT xmchb-cumlm IS INITIAL OR
            NOT xmchb-cinsm IS INITIAL OR
            NOT xmchb-ceinm IS INITIAL OR
            NOT xmchb-cspem IS INITIAL OR
            NOT xmchb-cretm IS INITIAL OR
            NOT xmchb-cvmla IS INITIAL OR
            NOT xmchb-cvmum IS INITIAL OR
            NOT xmchb-cvmin IS INITIAL OR
            NOT xmchb-cvmei IS INITIAL OR
            NOT xmchb-cvmsp IS INITIAL OR
            NOT xmchb-cvmre IS INITIAL.
      CLEAR lt_mchb.
      lt_mchb-matnr = xmchb-matnr.
      lt_mchb-werks = xmchb-werks.
      lt_mchb-lgort = xmchb-lgort.
      lt_mchb-charg = xmchb-charg.
      APPEND lt_mchb.
    ENDLOOP.
ENHANCEMENT-POINT m-segmente_ergaenzen_10 SPOTS es_sapmm07m STATIC.

ENHANCEMENT-POINT m-segmente_ergaenzen_09 SPOTS es_sapmm07m.
    IF NOT xdeliv IS INITIAL.

*-Sales Order Stock
      LOOP AT xmska
       WHERE rmska   NE space
       AND   xdbup   NE space.

*-filter out segments with 0 quantity
        CHECK NOT xmska-kalab IS INITIAL OR
              NOT xmska-kains IS INITIAL OR
              NOT xmska-kaein IS INITIAL OR
              NOT xmska-kaspe IS INITIAL OR
              NOT xmska-kavla IS INITIAL OR
              NOT xmska-kavin IS INITIAL OR
              NOT xmska-kavei IS INITIAL OR
              NOT xmska-kavsp IS INITIAL.

        CLEAR lt_mchb.
        lt_mchb-matnr = xmska-matnr.
        lt_mchb-werks = xmska-werks.
        lt_mchb-charg = xmska-charg.
        APPEND lt_mchb.
      ENDLOOP.

*-Special Stocks with Vendor
      LOOP AT xmslb
          WHERE rmslb NE space
          AND   xdbup NE space.

*-filter out segments with 0 quantity
        CHECK  NOT xmslb-lblab IS INITIAL OR
               NOT xmslb-lbins IS INITIAL OR
               NOT xmslb-lbein IS INITIAL OR
               NOT xmslb-lbvla IS INITIAL OR
               NOT xmslb-lbvin IS INITIAL OR
               NOT xmslb-lbvei IS INITIAL.

        CLEAR lt_mchb.
        lt_mchb-matnr = xmslb-matnr.
        lt_mchb-werks = xmslb-werks.
        lt_mchb-charg = xmslb-charg.
        APPEND lt_mchb.
      ENDLOOP.

*-Special Stocks with Customer
      LOOP AT xmsku
       WHERE rmsku NE space
       AND   xdbup NE space.

*-filter out segments with 0 quantity
        CHECK  NOT xmsku-kulab IS INITIAL OR
               NOT xmsku-kuins IS INITIAL OR
               NOT xmsku-kuein IS INITIAL OR
               NOT xmsku-kuvla IS INITIAL OR
               NOT xmsku-kuvin IS INITIAL OR
               NOT xmsku-kuvei IS INITIAL.

        CLEAR lt_mchb.
        lt_mchb-matnr = xmsku-matnr.
        lt_mchb-werks = xmsku-werks.
        lt_mchb-charg = xmsku-charg.
        APPEND lt_mchb.
      ENDLOOP.

*-Special Stocks from Vendor
      LOOP AT xmkol
           WHERE rmkol NE space
           AND   xdbup NE space.

*-filter out segments with 0 quantity
        CHECK  NOT xmkol-slabs IS INITIAL OR
               NOT xmkol-sinsm IS INITIAL OR
               NOT xmkol-seinm IS INITIAL OR
               NOT xmkol-sspem IS INITIAL OR
               NOT xmkol-svmla IS INITIAL OR
               NOT xmkol-svmin IS INITIAL OR
               NOT xmkol-svmei IS INITIAL OR
               NOT xmkol-svmsp IS INITIAL.

        CLEAR lt_mchb.
        lt_mchb-matnr = xmkol-matnr.
        lt_mchb-werks = xmkol-werks.
        lt_mchb-charg = xmkol-charg.
        APPEND lt_mchb.
      ENDLOOP.

*-Project Stock
      LOOP AT xmspr
           WHERE rmspr NE space
           AND   xdbup NE space.


*-filter out segments with 0 quantity
        CHECK  NOT xmspr-prlab IS INITIAL OR
               NOT xmspr-prins IS INITIAL OR
               NOT xmspr-prspe IS INITIAL OR
               NOT xmspr-prein IS INITIAL OR
               NOT xmspr-prvla IS INITIAL OR
               NOT xmspr-prvin IS INITIAL OR
               NOT xmspr-prvei IS INITIAL OR
               NOT xmspr-prvsp IS INITIAL.

        CLEAR lt_mchb.
        lt_mchb-matnr = xmspr-matnr.
        lt_mchb-werks = xmspr-werks.
        lt_mchb-charg = xmspr-charg.
        APPEND lt_mchb.
      ENDLOOP.

    ENDIF.

    CALL FUNCTION 'VB_CHECK_BATCH_FOR_INSERT'
      EXPORTING
        ignore_content_check = 'X'
      TABLES
        new_batches          = lt_mchb.
    CALL FUNCTION 'VB_CHECK_BATCH_FOR_UPDATE'
      EXPORTING
        ignore_content_check = 'X'
      TABLES
        new_batches          = lt_mchb.
  ENDIF.

* XBLNR/FRBNR handling: if the user or MB_CREATE has not entered any
* external document or bill of lading but the items have those external
* numbers derived automatically from e.g. an inbound delivery (WUEB) in
* VM07M-XBLNR_AVIS and VM07M-FRBNR_AVIS, we take the item data in the
* header field MKPF-XBLNR/FRBNR if they are the same for all items.
* L_xblnr_first_line is only filled if all items have the same data.
  IF mkpf-xblnr IS INITIAL AND NOT l_xblnr_first_line IS INITIAL.
    xmkpf-xblnr = mkpf-xblnr = l_xblnr_first_line.
    MODIFY xmkpf INDEX 1.
  ENDIF.
  IF mkpf-frbnr IS INITIAL AND NOT l_frbnr_first_line IS INITIAL.
    xmkpf-frbnr = mkpf-frbnr = l_frbnr_first_line.
    MODIFY xmkpf INDEX 1.
  ENDIF.

* Create SD delivery (WMS-component + create SD delivery from MBRL)
  IF mkpf-bfwms = 1 OR xdeliv = x.                          "HUM
* trigger creation of change documents for batches - note 597322
    LOOP AT lt_mchb.
      CALL FUNCTION 'VB_CHANGE_DOCUMENT_REGISTER'
        EXPORTING
          i_matnr                = lt_mchb-matnr
          i_charg                = lt_mchb-charg
          i_werks                = lt_mchb-werks
          i_no_perform_on_commit = 'X'
        EXCEPTIONS
          OTHERS                 = 0.
    ENDLOOP.
    PERFORM wms_lieferung_erzeugen.
  ENDIF.

  LOOP AT wekbe.
    xekbe = wekbe.
    APPEND xekbe.
  ENDLOOP.
  LOOP AT wekbe_cr.
    xekbe_cr = wekbe_cr.
    APPEND xekbe_cr.
  ENDLOOP.
* @vsa_cd anfang
*  if not aufteiler is initial.
*    call function 'WWEA_INDEX_ALLOCATION'
*         tables
*              im_ex_auwei = xauwei.
*  endif.
* @vsa_cd ende
* Tickets & Additionals
*  call function 'WTAD_CHECK_GOODS_MOVEMENT'
*            exporting
*              mkpf       = xmkpf
*                  IMPORTING
*                       POST_CHECK =
*                       ADDIBELNR  =
*            tables
*              imseg      = xmseg
*            exceptions
*              others     = 0.
* Endgültige XMSEG-ZEILE in EKBZ aus BEZEI schreiben
  DATA: buzei LIKE bezei-buzei.                             "note 123430
  DATA: buzei_old LIKE bezei-buzei.                         "note 158019
  DATA: xekbz_cr_new LIKE xekbz_cr OCCURS 0.                "note 158019
  LOOP AT bezei.
    READ TABLE xekbz INDEX bezei-tabix.
    buzei_old = xekbz-buzei.                                "note 158019
    xekbz-buzei = bezei-buzei.
    buzei = xekbz-buzei.                                    "note 123430
    IF sy-subrc IS INITIAL.
      MODIFY xekbz INDEX bezei-tabix.
      LOOP AT xekbz_cr WHERE ebeln = xekbz-ebeln            "note 123430
                    AND ebelp = xekbz-ebelp                 "note 123430
                    AND stunr = xekbz-stunr                 "note 158019
                    AND zaehk = xekbz-zaehk                 "note 158019
                    AND buzei = buzei_old.                  "note 158019
        xekbz_cr-buzei = buzei.                             "note 123430
        APPEND xekbz_cr TO xekbz_cr_new.                    "note 158019
      ENDLOOP.                                              "note 123430
    ENDIF.
  ENDLOOP.
  IF NOT xekbz_cr_new[] IS INITIAL.                         "note 158019
    xekbz_cr[] = xekbz_cr_new[].                            "note 158019
  ENDIF.                                                    "note 158019
* The following function module may only be called if me_read_item_goods
* receipt was called previously. So we have to make sure there is a PO.
  IF NOT xekbe[] IS INITIAL.

*   Automatic Down Payment Process - adds ekbe entries in case of GRs /
*   GR cancellations                                        ERP 2.0

*   MAA EhP4 fields in PO history table EKBE_MA filled      "n1369731
*   incorrectly, assign internal table ZDM07M, too          "n1369731

    PERFORM downpayment_process                             "n1369731
                             USING     zdm07m[]             "n1369731
                             CHANGING  xekbe[]              "n1369731
                                       xekbe_ma[].          "n1369731


    CALL FUNCTION 'ME_STATISTICS_EKBE_RKO'
      EXPORTING                                             "605754
        i_flg_check_only = 'X'                              "605754
      TABLES
        t_ekbe           = xekbe
        t_ekbz           = xekbz
*       MAA EhP4 - Begin -----------------------------------"MAA EhP4
        t_ekbe_ma        = xekbe_ma                         "MAA EhP4
        t_ekbz_ma        = xekbz_ma.                        "MAA EhP4
*       MAA EhP4 - End -------------------------------------"MAA EhP4
  ENDIF.

  READ TABLE xmkpf INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    IF xmbwl IS INITIAL.
      MESSAGE s061.
ENHANCEMENT-POINT m-segmente_ergaenzen_07 SPOTS es_sapmm07m.
      IF sy-binpt IS INITIAL.
        IF sy-calld IS INITIAL.
          LEAVE TO TRANSACTION tcode.
        ELSE.
          LEAVE.
        ENDIF.
      ELSE.
        LEAVE PROGRAM.
      ENDIF.
    ELSE.
      MESSAGE e061.
    ENDIF.
  ENDIF.
  t_index = 0.
  LOOP AT ymdel.
    tabix = ymdel-zeile - t_index.
    DELETE xvm07m INDEX tabix.
    DELETE xmseg INDEX tabix.
    READ TABLE ymbuz INDEX tabix.
    IF ymbuz-xauto IS INITIAL.
      nast_key-zeile = ymbuz-zeilz.
      msg_objky = nast_key.
      CALL FUNCTION 'RV_MESSAGES_REFRESH'
        EXPORTING
          msg_kappl     = 'ME'
          pi_objky_from = msg_objky.
    ENDIF.
    DELETE ymbuz INDEX tabix.
ENHANCEMENT-POINT m-segmente_ergaenzen_08 SPOTS es_sapmm07m.
    t_index = t_index + 1.
  ENDLOOP.
  IF NOT inventur IS INITIAL.
    LOOP AT ymdel.
      READ TABLE yibuz INDEX ymdel-zeile.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'YIBUZ' ymdel-zeile.
      ENDIF.
      CLEAR yibuz-zeile.
      MODIFY yibuz INDEX ymdel-zeile.
    ENDLOOP.
  ENDIF.
* manuelle Nachrichten aus NAST umbenennen
  LOOP AT ymbuz WHERE xauto IS INITIAL.
    CLEAR nast_key-mjahr.
    nast_key-zeile = ymbuz-zeilz.
    msg_objky = nast_key.
    nast_key-mjahr = mkpf-mjahr.
    nast_key-zeile = sy-tabix.
    msg_objky_new = nast_key.
    CALL FUNCTION 'RV_MESSAGES_RENAME'
      EXPORTING
        msg_kappl     = 'ME'
        msg_objky_new = msg_objky_new
        msg_objky_old = msg_objky.
  ENDLOOP.
* Importdaten: neue Positionsnummer
  FIELD-SYMBOLS: <xtrade> TYPE ftkey,
                 <xmseg>  TYPE mseg.
  LOOP AT gt_ftrade ASSIGNING <xtrade> WHERE exnum NE space
                                       AND   expos NE space.
    IF xmigo = x.
      READ TABLE xvm07m WITH KEY global_counter = <xtrade>-expos.
      IF sy-subrc EQ 0.
        <xtrade>-expos_new = xvm07m-zeilv.
      ENDIF.
    ELSE.
      READ TABLE ymbuz WITH KEY zeilz = <xtrade>-expos.
      IF sy-subrc EQ 0.
        <xtrade>-expos_new = sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "m-segmente_ergaenzen