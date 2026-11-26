*---------------------------------------------------------------------*
*       FORM LOHNBEARBEITUNG                                          *
*---------------------------------------------------------------------*
*       Zu einer Lohnbearbeitungsbestellung werden die beim           *
*       Wareneingang auszubuchenden Beistellteile ermittelt.          *
*---------------------------------------------------------------------*
FORM lohnbearbeitung
                  USING is_enhancement TYPE isu_lohnbearbeitung. "IS2ERP

  DATA: lt_xmdvw   TYPE STANDARD TABLE OF ty_s_xmdvw,
        ls_xmdvw   TYPE ty_s_xmdvw,
        lt_mdvw    TYPE STANDARD TABLE OF mdvw,             "381406
        ls_mdvw    TYPE mdvw,                               "381406
        ls_gocomp  TYPE gocomp,
        ls_gocomp_extern TYPE gocomp,                       "969258
        l_global_counter_parent TYPE goitem-global_counter,
        l_no_batch TYPE flag.                                 " SC-batch
  DATA: l_fieldname TYPE migo_fieldname,                    "545344
        lt_migo_cobl_fields TYPE ty_t_fieldname,            "545344
        l_field1     TYPE migo_fieldname,                   "545344
        l_field2     TYPE migo_fieldname.                   "545344
  DATA: ls_isu_fusszeile_wa_pruefen TYPE isu_fusszeile_wa_pruefen. "IS2ERP
  DATA: lt_ekbe_sc   TYPE TABLE OF ekbe_sc,
        ls_ekbe_sc   TYPE ekbe_sc.

* EhP4 retrofit of (IS-) data declaration
* Begin VMS Note 786492 -SRIKANTHS
  DATA: vms_flag_lv   TYPE   xflag.
* The EHP604 condition variable has no effect for the core code
* conditions, it's value changes only in the switched code. This
* usage makes possible to avoid enh. sections.
  DATA: EHP604_MM07MFL0_LOHNBEARBEI_01 VALUE space.         "GA1404019

  DATA : lv_lecomp TYPE c VALUE ' '.                         "1587552

  FIELD-SYMBOLS: <ls_fuss>   LIKE yfuss,
                 <field1>    TYPE any,                      "545344
                 <field2>    TYPE any.                      "545344

ENHANCEMENT-POINT LOHNBEARBEITUNG_03 SPOTS ES_SAPMM07M.
* Return delivery with SD delivery: components should not be given
* to GN_DELIVERY_CREATE. This check already exists in FORM
* AUTOMATISCHE_ZEILEN but is still necessary here because MB_CREATE
* does not perform automatische_zeilen
* Attention:XDELIV =' ' ->System decides that we don't create a delivery
*           XDELIV ='1' ->external caller (MB_CREATE)decides NO delivery
  CHECK xdeliv IS INITIAL OR xdeliv = '1'.
* OMSEG contains the current main item (101 or 121)
* the 101/121 item is also in FUSS
  CHECK aktyp = h AND ovm07m-pstyp = drei.                  "1110140
* in case of mvt 103 no component is posted
* but post components for 107 (valuated GR blocked stock)       "1110140
  CHECK NOT ovm07m-kzwes = s OR ovm07m-sekpo = 'E23'.       "1110140
* but not for 109 (release valuated GR blocked stock)           "1110140
  CHECK NOT ( ovm07m-kzwes = x AND ovm07m-sekpo = 'E12' ).  "1110140

  " EHP5: Batch Traceability
  IF  cl_ops_switch_check=>lo_mm_sd_sfws_dm_sc( ) IS NOT INITIAL.
*--> check the correctnes of finish batch in subsequent adjustment
    IF omseg-kzbew = 'O' AND " subsequent adjustment
       omseg-charg IS NOT INITIAL." batch is entered
      SELECT SINGLE *
             FROM chvw
             WHERE ebeln EQ omseg-ebeln
               AND ebelp EQ omseg-ebelp
               AND matnr EQ omseg-matnr
               AND charg EQ omseg-charg.
      IF sy-subrc <> 0. " the input batch is invalid
        MESSAGE e072(MIGO) WITH omseg-charg. " the inputed batch has not been posted
      ENDIF.
    ENDIF. "kzbew and charg
  ENDIF. " switch

  PERFORM bewegungstext_lesen(sapfm07m) USING omseg-bwart
                                              omseg-sobkz
                                              omseg-kzbew
                                              omseg-kzzug
                                              omseg-kzvbr
                                              rm07m-btext.

  DATA: wemng LIKE xekpo-wemng. CLEAR wemng.
  PERFORM lekpo IN PROGRAM sapfm07m USING       space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                          omseg-ebeln
                                          omseg-ebelp
                                          omseg-lfbja
                                          omseg-lfbnr
                                          omseg-lfpos
                                          omseg-kzzug
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space
                                                space.
  IF rc = 0.
    wemng = xekpo-wemng.
  ELSEIF NOT xmbwl IS INITIAL.
    wemng = odm07m-wemng.
  ENDIF.

* Subsequent adjustment (KZBEW = O): GR-quantity must be > 0.
  IF xmbwl = x AND wemng = 0 AND omseg-kzbew = o.
    MESSAGE e385.
  ENDIF.

* define if 'ME_READ_COMP_GOODS_RECEIPT' is called batch-specific or not
* hint 969258 revises old hint 894818 !!
  IF xmbwl = x.                                             "969258
* we have to determine wether MB_CREATE_GOODS_MOVEMENT   "969258
* is called with or without subcontracting components,   "969258
* both is possible also with BAPI call                   "969258
    READ TABLE gt_gocomp INTO ls_gocomp_extern              "969258
               WITH KEY parent = omseg-line_id.             "969258
    IF sy-subrc <> 0.                                       "969258
      CLEAR l_no_batch.                                     "969258
    ELSE.                                                   "969258
      l_no_batch = 'X'.                                     "969258
    ENDIF.                                                  "969258
  ENDIF.                                                    "969258

* read components in internal table XMDVW
  CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
    EXPORTING
      aktwe         = omseg-bstmg
      ebeln         = omseg-ebeln
      ebelp         = omseg-ebelp
      lfbnr         = omseg-lfbnr
      lfgja         = omseg-lfbja
      lfpos         = omseg-lfpos
      shkzg         = omseg-shkzg
      sumwe         = wemng
      kzbew         = omseg-kzbew
      no_batch      = l_no_batch                        " SC-batch
    IMPORTING
      et_ekbe_sc    = lt_ekbe_sc[]
    TABLES
      t_bbefu       = lt_mdvw                               "38140
    EXCEPTIONS
      not_found_any = 01
      not_found_one = 02
      not_valid_any = 03
      not_valid_one = 04.

  def_break 'ME_READ_COMP_GOODS_RECEIPT'.                   "#EC *
  BREAK-POINT ID mb_me_read_comp_goods_receipt.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'MDVW' sy-subrc. " noch im einzelnen setzen
    CASE sy-subrc.
      WHEN 1.
*       MESSAGE E031 WITH B-EBELN KBEFU-LOEKZ.
      WHEN 2.
*       MESSAGE E030 WITH B-EBELN.
      WHEN 3.
*       MESSAGE E032 WITH B-EBELN.
      WHEN OTHERS.
*       MESSAGE E030 WITH B-EBELN.
    ENDCASE.
  ENDIF.
* Copy data from LT_XMDVW_TMP (table with original structure MDVW)
* the the extended table XMDVW. This is cleaner than using the
* incorrectly typed table in the interface to ME_READ_COMP.
* Additional taks: Enrich MDVW from MM-PUR by BSTME
*                  (see note 509418)
  REFRESH xmdvw.                                            "381406
  LOOP AT lt_mdvw INTO ls_mdvw.                             "381406
    MOVE-CORRESPONDING ls_mdvw TO ls_xmdvw.                 "381406
    ls_xmdvw-bstme = ls_mdvw-erfme.                         "509418
    IF ls_xmdvw-charg IS NOT INITIAL.                         "1356935
      SELECT SINGLE BWTAR FROM MCHA INTO ls_xmdvw-bwtar       "1356935
                         WHERE matnr = ls_xmdvw-matnr AND     "1356935
                               werks = ls_xmdvw-werks AND     "1356935
                               charg = ls_xmdvw-charg.        "1356935
      IF sy-subrc IS NOT INITIAL.                             "1356935
      ENDIF.                                                  "1356935
    ENDIF.                                                    "1356935
    APPEND ls_xmdvw TO xmdvw.                               "381406
  ENDLOOP.                                                  "381406

* Handle external data of components (-> MB_CREATE_GOODS_MOVENT)________
  IF xmbwl = x AND xcanc <> x.
    READ TABLE gt_gocomp INTO ls_gocomp
               WITH KEY parent = omseg-line_id.
    IF sy-subrc <> 0.
*   a) If there is no external information about a component:
*      Use data from ME_READ_COMP_GOODS_RECEIPT (-> XMDVW)
*      (global_counter of end product needed for error messages in MIGO)
      IF xmigo = x.
        LOOP AT xmdvw.
          xmdvw-global_counter = vm07m-global_counter.
          MODIFY xmdvw.
        ENDLOOP.
      ENDIF.
    ELSE.
*     b) If there is any information: Use data of GT_GOCOMP
      PERFORM external_component_get.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT LOHNBEARBEITUNG_05 SPOTS ES_SAPMM07M.

* ______________________________________________________________________
ENHANCEMENT-POINT MM07MFL0_LOHNBEARBEITUNG_01 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT MM07MFL0_LOHNBEARBEITUNG_02 SPOTS ES_SAPMM07M.
  REFRESH: prefetch01,
           prefetch02,
           prefetch03.
  DATA: xlgort TYPE c.
  DATA: bypro  TYPE c.                                        "1356935
  CLEAR xlgort.
* XMDVW: ignore item without matnr as they could be text items in BOM
  LOOP AT xmdvw WHERE NOT matnr IS INITIAL.
ENHANCEMENT-POINT MM07MFL0_LOHNBEARBEITUNG_03 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     MM07MFL0_LOHNBEARBEITUNG_04 SPOTS ES_SAPMM07M.
    IF xmdvw-sobkz IS INITIAL.
      xmdvw-sobkz = o.
      CLEAR xmdvw-lgpro.
      MODIFY xmdvw.
    ELSEIF NOT xmdvw-sobkz = e AND NOT xmdvw-sobkz = q.
      MESSAGE e223 WITH xmdvw-sobkz.
    ELSEIF xmdvw-lgpro IS INITIAL AND ( xmdvw-sobkz EQ q OR
                                       xmdvw-sobkz EQ e ).
      xlgort = x.
    ENDIF.
END-ENHANCEMENT-SECTION.
* begin Outsourced Manufacturing EhP 4
    IF gv_mm_om1_sfws_sc_active = abap_true.
      IF odm07m-co_order IS NOT INITIAL.
        dm07m-co_order = odm07m-co_order.
        LOOP AT lt_ekbe_sc INTO ls_ekbe_sc
           WHERE matnr = xmdvw-matnr
             AND werks = xmdvw-werks
             AND charg = xmdvw-charg.
          IF ls_ekbe_sc-shkzg = h.
            xmdvw-wamng = xmdvw-wamng - ls_ekbe_sc-erfmg.
          ELSE.
            xmdvw-wamng = xmdvw-wamng + ls_ekbe_sc-erfmg.
          ENDIF.
        ENDLOOP.
        IF xmdvw-wamng < 0.
          xmdvw-wamng = xmdvw-wamng * -1.
        ENDIF.
        IF  omseg-kzbew = b.
          xmdvw-erfmg = 0.
ENHANCEMENT-POINT EHP606_LOHNBEARBEITUNG_01 SPOTS ES_SAPMM07M .
        ENDIF.
        MODIFY xmdvw INDEX sy-tabix.
      ENDIF.
    ENDIF.
* end Outsourced Manufacturing EhP 4
    MOVE-CORRESPONDING xmdvw TO prefetch02.
    prefetch02-lgort = xmdvw-lgpro.
    COLLECT prefetch02.
    MOVE-CORRESPONDING xmdvw TO prefetch03.
    COLLECT prefetch03.
  ENDLOOP.
* in case of sobkz E or P on component the quantity is not
* taken from O stock but from E or P stock in a normal storage
* location
  PERFORM lagerort_komponenten USING xlgort.
  PERFORM prefetch_ausfuehren USING x
                                    x.                      "498002
  CLEAR y_zeile.
  REFRESH: yfuss, zfuss.
* remaining main items (101/121) that are still to be processed
* are saved in ZFUSS. At the end of LOHNBEARBEITUNG, FUSS will have
* the following lines in the right order:
* FUSS header line can be ignored as the current item (101) has already
* been processed.
  zfuss[] = fuss[].                                         "0438401
  CLEAR rm07m-kzbew.
  PERFORM fcode_lesen USING fcod-nl.
* No reference document given --> insert lines from XMDVW.
* What about the text positions?
  IF omseg-mblnr IS INITIAL.
    LOOP AT xmdvw.
      CLEAR: dm07m, vm07m, mseg, fuss.
      mseg-zeile = m_zeile + y_zeile + 1.
      IF odm07m-knttp IS INITIAL.
        mseg-lifnr = omseg-lifnr.
        mseg-ebeln = omseg-ebeln.
        mseg-pprctr = omseg-pprctr.
        mseg-parbu = omseg-bukrs.
      ELSE.
        MOVE-CORRESPONDING omseg TO msegk.
        MOVE-CORRESPONDING msegk TO mseg.
*       Note 389931
*       Inheriting rules for KZVBR: the components should read T156X
*       with the same KZVBR as main item. Here however the definitive
*       KZVBR of main item has not been determined yet (changed in
*       LAGERORTDATEN of main item) if we are in MB_CREATE, so it is
*       necessary to give the components the future KZVBR of main item.
*       - KZBWS space: T156X and T156S(Y) will be read with the origina
*                      kzvbr. The kzvbr will not be manipulated, so the
*                      component inherits from omseg.
*                      Rule independent from SOBKZ.
*       - KZBWS M/A:   T156S(Y) and T156X will always be read with KZVBR
*                      space, except if 601 (im_process=L, kzbew <> B)
*                      or 331 from QM (xkoko=X). So in subcontracting,
*                      KZVBR will always be space when valuated stock.
        IF omseg-kzbws IS INITIAL.                          "389931
          mseg-kzvbr = omseg-kzvbr.
        ENDIF.                                              "389931
        IF NOT mseg-kzvbr = a.
          dm07m-konto = odm07m-konto.
        ENDIF.
      ENDIF.
      mseg-ebelp = omseg-ebelp.
      mseg-lfbja = omseg-lfbja.
      mseg-lfbnr = omseg-lfbnr.
      mseg-lfpos = omseg-lfpos.
      mseg-lgort = xmdvw-lgpro.
      vm07m-webre = ovm07m-webre.
      mseg-urzei = omseg-zeile.
      MOVE-CORRESPONDING xmdvw TO dm07m.
      MOVE-CORRESPONDING xmdvw TO vm07m.
      MOVE-CORRESPONDING xmdvw TO mseg.
ENHANCEMENT-POINT LOHNBEARBEITUNG_01 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT LOHNBEARBEITUNG_02 SPOTS ES_SAPMM07M.
      mseg-lgort = xmdvw-lgpro.
*Addition for note 842272 - START
*The value in dm07m-bwtar_xmbwl is later copied to mseg-bwtar. If this
*is not filled here, it throws error M7 044.
      dm07m-bwtar_xmbwl = xmdvw-bwtar.                      "842272
*Addition for note 842272 - END
*     Localization Brazil
      IF brazil = x.
        DATA ls_j_1b_gocomp LIKE gocomp.
        READ TABLE gt_gocomp INTO ls_j_1b_gocomp
                       WITH KEY global_counter = xmdvw-global_counter
                                 matnr          = xmdvw-matnr
                                 werks          = xmdvw-werks.
        mseg-j_1bexbase = ls_j_1b_gocomp-j_1bexbase.
        mseg-mwskz      = ls_j_1b_gocomp-mwskz.
      ENDIF.

      IF mseg-lgort IS INITIAL AND NOT xmdvw-sobkz = o.
        mseg-lgort = rm07m-lgort.
      ENDIF.
*     mseg-bstme = mseg-erfme.                                   "509418
      IF omseg-shkzg = h.
        IF xmdvw-shkzg = h.
          SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbws
                                      AND  bwart = space.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'T156N' fcod-lbws.
          ENDIF.
        ELSE.
          SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbns
                                      AND  bwart = space.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'T156N' fcod-lbns.
          ENDIF.
        ENDIF.
      ELSE.
        IF xmdvw-shkzg = h.
          SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbwa
                                      AND  bwart = space.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'T156N' fcod-lbwa.
          ENDIF.
        ELSE.
          SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbna
                                      AND  bwart = space.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'T156N' fcod-lbna.
          ENDIF.
        ENDIF.
      ENDIF.
      mseg-bwart = t156n-bwart_next.
      mseg-sobkz = xmdvw-sobkz.
      mseg-kzbws = omseg-kzbws.
      dm07m-co_order = odm07m-co_order.                "Outsourced Manufacturing EhP 4
      dm07m-rshkz = xmdvw-shkzg.
      vm07m-pstyp = ovm07m-pstyp.
      dm07m-zeilo = omseg-zeile.
      CLEAR dm07m-vbund.
*     Subsequent adjustment:
*     Get movement type for component and take negative quantity into
*     account (in case of external data for components)
      IF xmbwl = x AND omseg-kzbew = o.
        PERFORM mvt_component_get USING    xmdvw-erfmg
                                           xmdvw-shkzg
                                  CHANGING mseg-bwart
                                           mseg-erfmg.
      ENDIF.
*     The subcontracting component gets the sales order/wbs element from
*     the main material. Subcontracting component with collective
*     requirement are managed via the subcotracting stock (SOBKZ = 'O').
*     For this case MAT_KDAUF and MAT_PSPNR must be cleared.
      IF mseg-sobkz = 'O' AND ( mseg-mat_kdauf IS NOT INITIAL OR"1684680
                                mseg-mat_pspnr IS NOT INITIAL )."1684680
        CLEAR: mseg-mat_kdauf, mseg-mat_kdpos, mseg-mat_pspnr.  "1684680
      ENDIF.                                                    "1684680
      PERFORM fusszeile_wa_pruefen USING space
                                         ls_isu_fusszeile_wa_pruefen. "IS2ERP
      IF NOT xmbwl IS INITIAL.
        vm07m-xchpf = mbefu-xchpf.
        dm07m-xchar = mbefu-xchar.
        dm07m-eprio = mbefu-eprio.
        vm07m-mtvfp = mbefu-mtvfp.
      ENDIF.
*     if migo is used, field pspnr has been determinded already:
      DATA: l_pspnr LIKE grpga-grpnr.
      IF NOT ( xmigo = x AND xcanc <> x ).                  "339452
ENHANCEMENT-POINT EHP604_MM07MFL0_LOHNBEARBEI_01 SPOTS ES_SAPMM07M .
        IF mseg-sobkz = q                             OR
           EHP604_MM07MFL0_LOHNBEARBEI_01 = abap_true.      "GA1404019
ENHANCEMENT-SECTION     MM07MFL0_LOHNBEARBEITUNG_06 SPOTS ES_SAPMM07M.
          IF mseg-kzbws = 'M'.
            CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
              EXPORTING
                i_pspnr              = mseg-ps_psp_pnr
                i_werks              = mseg-werks
                i_matnr              = mseg-matnr
              IMPORTING
                e_grpnr              = l_pspnr
              EXCEPTIONS
                wrong_input          = 1
                no_valid_grpnr_found = 2.
            IF sy-subrc = 0.
              IF mseg-ps_psp_pnr <> l_pspnr AND
                 NOT l_pspnr IS INITIAL.
*             update only changed wbs element
                mseg-ps_psp_pnr = l_pspnr.
              ENDIF.
            ENDIF.
          ENDIF.
END-ENHANCEMENT-SECTION.
          mseg-mat_pspnr = mseg-ps_psp_pnr.
*         Map to variable with structure MDVW.
          CLEAR ls_mdvw.                                    "381406
          MOVE-CORRESPONDING xmdvw TO ls_mdvw.              "381406
          CALL CUSTOMER-FUNCTION '005'
               EXPORTING
                  i_mdvw      = ls_mdvw                     "381406
               CHANGING
                    i_mat_pspnr = mseg-mat_pspnr.
        ELSEIF mseg-sobkz = e.
          mseg-mat_kdauf = mseg-kdauf.
          mseg-mat_kdpos = mseg-kdpos.
        ENDIF.
      ENDIF.                                          "note 339452
      IF NOT mseg-kzvbr IS INITIAL AND NOT mseg-kzvbr = a.
*       Dead coding from note 130404 deleted by note 389931
        LOOP AT x156w WHERE bustw = mseg-bustw
                      AND   vorsl = vorsl_kbs.
          EXIT.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          CLEAR dm07m-konto.
        ENDIF.
      ENDIF.
      fuss-xselp = x.
*     Copy component data into YFUSS !!!
      PERFORM fuss_fuellen USING x.
      LOOP AT xekls WHERE ebeln = mseg-ebeln
                    AND   ebelp = mseg-ebelp
                   AND   lfbja = mseg-lfbja                      " PPF
                   AND   lfbnr = mseg-lfbnr                      " PPF
                   AND   lfpos = mseg-lfpos                      " PPF
                    AND   matnr = mseg-matnr
                    AND   werks = mseg-werks
                    AND   bwtar = mseg-bwtar                  "1356935
                    AND   bypro = xmdvw-bypro.                "1356935
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL                            "note 1043602
         AND xekls-wamng IS INITIAL AND NOT dm07m-wamng IS INITIAL.
        LOOP AT xekls WHERE ebeln = mseg-ebeln          "note 1043602
                    AND   ebelp = mseg-ebelp            "note 1043602
                    AND   lfbja = mseg-lfbja            "note 1043602
                    AND   lfbnr = mseg-lfbnr            "note 1043602
                    AND   lfpos = mseg-lfpos            "note 1043602
                    AND   matnr = mseg-matnr            "note 1043602
                    AND   werks = mseg-werks            "note 1043602
                    AND   bwtar = mseg-bwtar                  "1356935
                    AND   bypro = xmdvw-bypro.                "1356935
          DELETE xekls.                                 "note 1043602
        ENDLOOP.                                        "note 1043602
        xekls-curtp = '10'.                             "note 1043602
        MOVE-CORRESPONDING dm07m TO xekls.              "note 1043602
        MOVE-CORRESPONDING mseg TO xekls.               "note 1043602
        xekls-bypro = xmdvw-bypro.                            "1356935
        APPEND xekls.                                   "note 1043602
      ELSEIF NOT sy-subrc IS INITIAL.                   "note 1043602
        xekls-curtp = '10'.                             "note 1043602
        MOVE-CORRESPONDING dm07m TO xekls.              "note 1043602
        MOVE-CORRESPONDING mseg TO xekls.               "note 1043602
        xekls-bypro = xmdvw-bypro.                            "1356935
        APPEND xekls.                                   "note 1043602
      ENDIF.                                            "note 1043602
      PERFORM lohnb_xekls_extend_cr TABLES xekls        "note 1043602
                                    USING  mseg.        "note 1043602
    ENDLOOP.
  ELSE.
*   Reference document given. Merge data from XMDVW with lines from FUSS
*   Loop at components from material document. ZFUSS contains all data
*   from the read material document: Header lines and components.
    LOOP AT zfuss WHERE ebeln = omseg-ebeln
                  AND   ebelp = omseg-ebelp
                  AND   lfbja = omseg-lfbja
                  AND   lfbnr = omseg-lfbnr
                  AND   lfpos = omseg-lfpos
                  AND   kzbew = space.
      IF xmbwl IS INITIAL.                                 "note 201909
        CHECK zfuss-urzei = omseg-zeile.                   "note 201909
      ELSEIF vm07m-xstor = zwei            AND              "379097
             NOT zfuss-line_id IS INITIAL  AND              "379097
             NOT omseg-line_id IS INITIAL.                  "379097
*   following background: MIGO cancels goods receipt to          "379097
*   subcontract order (original line_ids are filled in           "379097
*   zfuss/omseg); due to qty split in the original GR doc.       "379097
*   -> several main items and subitems in zfuss; they all don't  "379097
*   differ in ebeln, ebelp, lfbja, lfbnr, lfpos => too many      "379097
*   subitems will be selected by loop at zfuss;                  "379097
*   coding of note 201909 above unfortunately doesn't apply in   "379097
*   this case because omseg-zeile already corresponds to the new "379097
*   line number and zfuss-urzei still to the the old (original   "379097
*   GR doc.) line numbers;                                       "379097
*   I prefer working with line_id and parent_id instead of       "379097
*   omseg-smblp, zfuss-urzei... because the logic with line_id   "379097
*   is much clearer, less complex (no calculation with a_zeil,   "379097
*   m_zeil, o_zeil and whatsoever) and thus much more stable;    "379097
        CHECK zfuss-parent_id = omseg-line_id.              "379097
      ENDIF.                                               "note 201909
*     Locate the component in XMDVW
      IF xmbwl = 'X'.                                         "1356935
        SELECT SINGLE xstbw FROM T156 INTO zfuss-xstbw        "1356935
                           WHERE bwart = zfuss-bwart.         "1356935
      ENDIF.                                                  "1356935
      IF ( zfuss-shkzg = 'S' AND zfuss-xstbw = '' OR          "1356935
         zfuss-shkzg = 'H' AND zfuss-xstbw = 'X' ) AND        "1356935
         zfuss-kzbew IS INITIAL.            "only components  "1585602
        bypro = 'X'.                                          "1356935
      ELSE.                                                   "1356935
        bypro = ''.                                           "1356935
      ENDIF.                                                  "1356935
      LOOP AT xmdvw WHERE matnr = zfuss-matnr
                    AND   werks = zfuss-werks
                    AND   bwtar = zfuss-bwtar                 "1356935
                    AND   bypro = bypro.                      "1356935
        EXIT.
      ENDLOOP.
      IF NOT sy-subrc IS INITIAL.                             "1356935
       LOOP AT xmdvw WHERE matnr = zfuss-matnr                "1356935
                     AND   werks = zfuss-werks                "1356935
                     AND   bypro = bypro.                     "1356935
         EXIT.                                                "1356935
       ENDLOOP.                                               "1356935
      ENDIF.                                                  "1356935
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'XMDVW' zfuss-matnr zfuss-werks.
      ENDIF.
      MOVE-CORRESPONDING zfuss TO dm07m.
      MOVE-CORRESPONDING zfuss TO vm07m.
      MOVE-CORRESPONDING zfuss TO mseg.
      vm07m-webre = ovm07m-webre.
      vm07m-pstyp = ovm07m-pstyp.
      mseg-urzei = omseg-zeile.
      dm07m-zeilo = omseg-zeile.
      IF vm07m-xstor <> zwei.                               "373988
*       Working with reference document, but we are not cancellation.
*       It might be sensible to use the quantity proposal of PUR
*       for the components. This is useful if the quantity of the
*       GR-line has been adjusted. We can use this single quantity
*       proposal only if this component consists of only one line
*       and has the same unit as the proposal. Otherwise (e.g.
*       for batch-split of the component) the quantities from the
*       reference document have to be used (we do not want to
*       calculate our own quantity adjustments).
        DATA:                                               "373988
          lf_zfuss_count   TYPE i,                          "373988
          lf_skip_proposal TYPE c.                          "373988
        FIELD-SYMBOLS:                                      "373988
          <ls_zfuss> LIKE zfuss.                            "373988
*       Do not omit these CLEARs because the DATA-statement does not
*       initialize the variables.
        CLEAR lf_zfuss_count.                               "373988
        CLEAR lf_skip_proposal.                             "373988
*       Check how many lines this component has in the reference doc.
        LOOP AT zfuss ASSIGNING <ls_zfuss>                  "373988
          WHERE ebeln = zfuss-ebeln                         "373988
            AND ebelp = zfuss-ebelp                         "373988
            AND lfbja = zfuss-lfbja                         "373988
            AND lfbnr = zfuss-lfbnr                         "373988
            AND lfpos = zfuss-lfpos                         "373988
            AND kzbew = space                               "373988
            AND matnr = zfuss-matnr                         "373988
            AND werks = zfuss-werks                         "373988
            AND urzei = zfuss-urzei.                        "373988
          ADD 1 TO lf_zfuss_count.                          "373988
*         More than one or differing unit --> use data from reference
          IF lf_zfuss_count = 2 OR                          "373988
             <ls_zfuss>-erfme <> xmdvw-erfme.               "373988
            lf_skip_proposal = x.                           "373988
            EXIT.                                           "373988
          ENDIF.                                            "373988
        ENDLOOP.                                            "373988
        IF lf_skip_proposal IS INITIAL.                     "373988
          mseg-erfmg = xmdvw-erfmg.                         "373988
          mseg-erfme = xmdvw-erfme.                         "373988
        ENDIF.                                              "373988
      ENDIF.                                                "373988
      mseg-bstme  = xmdvw-bstme.                            "509418
      dm07m-bdmng = xmdvw-bdmng.
      dm07m-wamng = xmdvw-wamng.
      dm07m-wawrt = xmdvw-wawrt.
      dm07m-rshkz = xmdvw-shkzg.
      CLEAR dm07m-vbund.
      PERFORM fusszeile_wa_pruefen USING space
                                         ls_isu_fusszeile_wa_pruefen. "IS2ERP
      IF NOT xmbwl IS INITIAL.
        vm07m-xchpf = mbefu-xchpf.
        dm07m-xchar = mbefu-xchar.
        dm07m-eprio = mbefu-eprio.
        vm07m-mtvfp = mbefu-mtvfp.
      ENDIF.
      PERFORM kontierung_pruefen.
      IF mseg-kzvbr = a.
        CLEAR dm07m-konto.
      ENDIF.
      MOVE-CORRESPONDING dm07m TO zfuss.
      MOVE-CORRESPONDING vm07m TO zfuss.
      MOVE-CORRESPONDING mseg TO zfuss.
      zfuss-xselk = x.
      zfuss-xselp = x.
      zfuss-xprue = x.
      zfuss-fcode = fcod-np.
      MODIFY zfuss.
      LOOP AT xekls WHERE ebeln = mseg-ebeln
                    AND   ebelp = mseg-ebelp
                   AND   lfbja = mseg-lfbja                      " PPF
                   AND   lfbnr = mseg-lfbnr                      " PPF
                   AND   lfpos = mseg-lfpos                      " PPF
                    AND   matnr = mseg-matnr
                    AND   werks = mseg-werks
                    AND   bwtar = mseg-bwtar                  "1356935
                    AND   bypro = xmdvw-bypro.                "1356935
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL                            "note 1043602
         AND xekls-wamng IS INITIAL AND NOT dm07m-wamng IS INITIAL.
        LOOP AT xekls WHERE ebeln = mseg-ebeln          "note 1043602
                    AND   ebelp = mseg-ebelp            "note 1043602
                    AND   lfbja = mseg-lfbja            "note 1043602
                    AND   lfbnr = mseg-lfbnr            "note 1043602
                    AND   lfpos = mseg-lfpos            "note 1043602
                    AND   matnr = mseg-matnr            "note 1043602
                    AND   werks = mseg-werks            "note 1043602
                    AND   bwtar = mseg-bwtar                  "1356935
                    AND   bypro = xmdvw-bypro.                "1356935
          DELETE xekls.                                 "note 1043602
        ENDLOOP.                                        "note 1043602
        xekls-curtp = '10'.                             "note 1043602
        MOVE-CORRESPONDING dm07m TO xekls.              "note 1043602
        MOVE-CORRESPONDING mseg TO xekls.               "note 1043602
        xekls-bypro = xmdvw-bypro.                            "1356935
        APPEND xekls.                                   "note 1043602
      ELSEIF NOT sy-subrc IS INITIAL.                   "note 1043602
        xekls-curtp = '10'.                             "note 1043602
        MOVE-CORRESPONDING dm07m TO xekls.              "note 1043602
        MOVE-CORRESPONDING mseg TO xekls.               "note 1043602
        xekls-bypro = xmdvw-bypro.                            "1356935
        APPEND xekls.                                   "note 1043602
      ENDIF.                                            "note 1043602
      PERFORM lohnb_xekls_extend_cr TABLES xekls        "note 1043602
                                    USING  mseg.        "note 1043602
    ENDLOOP.
  ENDIF.

* To detect component postings via VL* with Outsourced          "1587552
* Manufacturing active.                                         "1587552
  CLEAR lv_lecomp.                                              "1587552
  IF  gv_mm_om1_sfws_sc_active = abap_true                      "1587552
     AND im_process = l.                                        "1587552
    lv_lecomp = 'X'.                                            "1587552
  ENDIF.                                                        "1587552

* get external-entered COBL-data for components_________________________
  IF NOT xmbwl IS INITIAL AND NOT gt_gocomp[] IS INITIAL
    AND lv_lecomp IS INITIAL.                                   "1587552
    LOOP AT yfuss.
      READ TABLE gt_gocomp INTO ls_gocomp
                  WITH KEY global_counter = yfuss-global_counter.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ls_gocomp-cobl TO yfuss.
*Implement logic from note 545344, only for Profit Center        "985618
        CLEAR: yfuss-pprctr.                                "985618
        CLEAR: lt_migo_cobl_fields.                         "1262574
        MOVE omseg-prctr  TO ls_gocomp-cobl-prctr.          "985618
*get all (also dependent) fields which can be displayed by MIGO  "985618
        CALL METHOD cl_mmim_migo_move_fields=>get_cobl_fields "985618
          EXPORTING i_bwart      = yfuss-bwart              "985618
          IMPORTING et_fields    = lt_migo_cobl_fields.     "985618
*copy PRCTR only if field status set to 'optional' .             "985618
*copy PRCTR to PPRCTR as MM and AC view should be swapped.       "985618
        LOOP AT lt_migo_cobl_fields INTO l_fieldname.       "985618
          IF l_fieldname = 'PRCTR'.                         "985618
            yfuss-pprctr = ls_gocomp-cobl-prctr.            "985618
          ENDIF.                                            "985618
        ENDLOOP.                                            "985618
        yfuss-mat_kdauf = ls_gocomp-mat_kdauf.
        yfuss-mat_kdpos = ls_gocomp-mat_kdpos.
        yfuss-mat_pspnr = ls_gocomp-mat_pspnr.
        yfuss-ablad     = ls_gocomp-ablad.                  "378846
        yfuss-exbwr     = ls_gocomp-exbwr.                  "378846
        yfuss-exvkw     = ls_gocomp-exvkw.                  "378846
        yfuss-grund     = ls_gocomp-grund.                  "378846
        yfuss-konto     = ls_gocomp-konto.                  "378846
        yfuss-sgtxt     = ls_gocomp-sgtxt.                  "378846
        yfuss-weanz     = ls_gocomp-weanz.                  "378846
        yfuss-wempf     = ls_gocomp-wempf.                  "378846
        MODIFY yfuss.
      ENDIF.
    ENDLOOP.
  ENDIF.
*                                                  begin of note 545344
* copy only that CO fields to yfuss which can be displayed by MIGO
IF ( NOT xmbwl IS INITIAL AND gt_gocomp[] IS INITIAL          "1587552
     AND xmigo <> space AND lv_lecomp IS INITIAL ).           "1587552
* begin Outsourced Manufacturing EhP 4
    DELETE yfuss WHERE co_order <> space
                   AND erfmg = 0.
* end Outsourced Manufacturing EhP 4
    LOOP AT yfuss.
*   clear all CO fields of components (YFUSS)
      CLEAR ls_gocomp-cobl.
      MOVE-CORRESPONDING ls_gocomp-cobl TO yfuss.
      CLEAR: yfuss-pprctr, yfuss-pargb.
      CLEAR: lt_migo_cobl_fields.                           "1262574
*   fill all CO fields of main item (101 line) into LS_GOCOMP-COBL
      MOVE-CORRESPONDING omseg  TO ls_gocomp-cobl.
      MOVE-CORRESPONDING odm07m TO ls_gocomp-cobl.
      MOVE-CORRESPONDING ovm07m TO ls_gocomp-cobl.
*   get all (also dependent) fields which can be displayed by MIGO
      CALL METHOD cl_mmim_migo_move_fields=>get_cobl_fields
        EXPORTING
          i_bwart      = yfuss-bwart
          i_with_konto = abap_true
        IMPORTING
          et_fields    = lt_migo_cobl_fields.
*   copy only relevant fields from LS_GOCOMP-COBL to YFUSS
      LOOP AT lt_migo_cobl_fields INTO l_fieldname.
        IF l_fieldname = 'KONTO'.
          yfuss-sakto = odm07m-konto.
        ELSEIF l_fieldname = 'PRCTR'.
          yfuss-pprctr = ls_gocomp-cobl-prctr.
        ELSEIF l_fieldname = 'GSBER'.
          yfuss-pargb = ls_gocomp-cobl-gsber.
        ELSEIF l_fieldname = 'NPLNR'.                       "709779
          yfuss-aufpl = ls_gocomp-cobl-aufpl.               "709779
          yfuss-aplzl = ls_gocomp-cobl-aplzl.               "709779
          yfuss-nplnr = ls_gocomp-cobl-nplnr.               "709779
        ELSE.
          CONCATENATE 'YFUSS-' l_fieldname INTO l_field1.
          CONCATENATE 'LS_GOCOMP-COBL-' l_fieldname INTO l_field2.
          ASSIGN (l_field1) TO <field1>.
*       if field exist in gocomp_cobl, but not in yfuss
          CHECK sy-subrc = 0.                               "646697
          ASSIGN (l_field2) TO <field2>.
          CHECK sy-subrc = 0.                               "646697
          <field1> = <field2>.
        ENDIF.
      ENDLOOP.
      MODIFY yfuss.
    ENDLOOP.
  ENDIF.
*                                                    end of note 545344
* Final preparations of hierarchy-data__________________________________
* Assign new LINE_ID's for positions not filled yet
* Set PARENT_ID from OMSEG
* Set LINE_DEPTH from OMSEG + 1
  LOOP AT yfuss ASSIGNING <ls_fuss>.
    CALL METHOD cl_mmim_line_id_manager=>line_id_get
      CHANGING
        c_line_id = <ls_fuss>-line_id.
    <ls_fuss>-parent_id  = omseg-line_id.
    <ls_fuss>-line_depth = omseg-line_depth + 1.
  ENDLOOP.
*_______________________________________________________________________
  rm07m-kzbew = t158-kzbew.
* MB_CREATE without reference document: YFUSS is filled and
* will be processed by MB_CREATE. Not to be freed here.
  IF NOT xmbwl IS INITIAL.
    CHECK NOT omseg-mblnr IS INITIAL.
  ENDIF.
* Nornal GR or reference
  IF NOT t158-kzbew = o OR NOT omseg-mblnr IS INITIAL.
    REFRESH fuss.
*   With reference document (MBLNR <> initial), YFUSS is empty!
*   Otherwise, the components from XMDVW --> YFUSS are
    fuss[] = yfuss[].                                       "0438401

*   Append lines of ZFUSS (old FUSS before routine-start), which
*   contains also the modified ZFUSS data (e.g. components) by
*   reference document.
    LOOP AT zfuss.
      fuss = zfuss.
      IF NOT fuss-xlaus IS INITIAL.
        LOOP AT ylgort WHERE zeile = zfuss-zeile
                       AND   xselp NE space.
          fuss = zfuss.
          DATA: lifnr LIKE mseg-lifnr.
          lifnr = fuss-lifnr.
          MOVE-CORRESPONDING ylgort TO fuss.
          IF fuss-lifnr IS INITIAL.
            fuss-lifnr = lifnr.
          ENDIF.
          CLEAR lifnr.
          CLEAR fuss-xlaus.
          fuss-fcode = fcod-np.
          fuss-xselk = x.
          f_zeile = f_zeile + 1.
          s_zeile = s_zeile + 1.
          fuss-zeile = f_zeile.
          APPEND fuss.
        ENDLOOP.
      ELSE.
        APPEND fuss.
      ENDIF.
      FREE: ylgort.
    ENDLOOP.
  ELSE.
*   Subsequent adjustment without reference document: Only appending
*   components as the main positions are in OMSEG and will be merged
*   into the mat doc in M_SEGMENTE_...
*   These componentes are appended at the END of all items -->
*   BWART  EBELP
*   121    10
*   121    20
*   544    10
*   544    10
*   544    20
*   544    20
*   therefore no REFRESH FUSS.
    LOOP AT yfuss.
      fuss = yfuss.
      APPEND fuss.
    ENDLOOP.
  ENDIF.
  f_zeile = f_zeile + y_zeile.
  s_zeile = s_zeile + y_zeile.
ENHANCEMENT-POINT MM07MFL0_LOHNBEARBEITUNG_05 SPOTS ES_SAPMM07M.
  FREE: yfuss, zfuss, xmdvw.

ENDFORM.                    "lohnbearbeitung

*&---------------------------------------------------------------------*
*&      Form  lohnb_xekls_extend_cr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_EKLS    text
*      -->I_MSEG     text
*----------------------------------------------------------------------*
FORM lohnb_xekls_extend_cr TABLES it_ekls STRUCTURE sekls  "note 1043602
                           USING i_mseg TYPE mseg.

  DATA: lt_ekls_cr TYPE TABLE OF cki_ekls,
        ls_ekls_cr TYPE cki_ekls,
        lt_bwart   TYPE TABLE OF tbwart,                      "1356935
        ls_bwart   TYPE tbwart,                               "1356935
        lr_bwart   TYPE TABLE OF cki_bwart,                   "1356935
        lw_bwart   TYPE cki_bwart,                            "1356935
        bustr      TYPE T156-BUSTR,                           "1356935
        l_init_done.

  LOOP AT it_ekls WHERE ebeln           = i_mseg-ebeln
                  AND   ebelp           = i_mseg-ebelp
                  AND   lfbnr           = i_mseg-lfbnr
                  AND   lfbja           = i_mseg-lfbja
                  AND   lfpos           = i_mseg-lfpos
                  AND   matnr           = i_mseg-matnr
                  AND   werks           = i_mseg-werks
                  AND   bwtar           = i_mseg-bwtar        "1356935
                  AND   bypro           = xmdvw-bypro.        "1356935
    IF it_ekls-curtp NE '10' AND it_ekls-curtp NE '  '.
      l_init_done = 'X'.
    ENDIF.
  ENDLOOP.
  IF sy-subrc IS INITIAL AND l_init_done IS INITIAL. "
    IF it_ekls-wamng IS INITIAL.
      REFRESH: lt_ekls_cr.
    ELSE.
     SELECT SINGLE bustr FROM T156 INTO bustr                 "1356935
                        WHERE bwart = i_mseg-bwart.           "1356935
     SELECT bwart FROM T156 INTO TABLE lt_bwart               "1356935
                        WHERE bustr = bustr.                  "1356935
     LOOP AT lt_bwart INTO ls_bwart.                          "1356935
        move : ls_bwart-bwart     to  lw_bwart-low,           "1356935
               'I'                to  lw_bwart-sign,          "1356935
               'EQ'               to  lw_bwart-option.        "1356935
        append lw_bwart           to  lr_bwart.               "1356935
     ENDLOOP.                                                 "1356935
      CALL FUNCTION 'CKMW_READ_SC_COMPONENTS'
        EXPORTING
          ebeln     = i_mseg-ebeln
          ebelp     = i_mseg-ebelp
          lfbnr     = i_mseg-lfbnr
          lfgja     = i_mseg-lfbja
          lfpos     = i_mseg-lfpos
          matnr     = i_mseg-matnr
          werks     = i_mseg-werks
          bwtar     = i_mseg-bwtar                            "1356935
        TABLES
          t_ekls_cr = lt_ekls_cr
          t_bwart   = lr_bwart.                               "1356935
    ENDIF.
    LOOP AT it_ekls WHERE ebeln           = i_mseg-ebeln
                    AND   ebelp           = i_mseg-ebelp
                    AND   lfbnr           = i_mseg-lfbnr
                    AND   lfbja           = i_mseg-lfbja
                    AND   lfpos           = i_mseg-lfpos
                    AND   curtp           = space.
      it_ekls-curtp = '10'.
      MODIFY it_ekls.
    ENDLOOP.
    LOOP AT lt_ekls_cr INTO ls_ekls_cr
    WHERE curtp NE '10'
    AND   curtp NE '00'.
      IF it_ekls-wamng IS INITIAL.
        CLEAR: ls_ekls_cr-wamng, ls_ekls_cr-wawrt.
      ELSE.
        ls_ekls_cr-wamng = abs( ls_ekls_cr-wamng ).
        ls_ekls_cr-wawrt = abs( ls_ekls_cr-wawrt ).
      ENDIF.
      MOVE-CORRESPONDING ls_ekls_cr TO it_ekls.
      APPEND it_ekls.
    ENDLOOP.
  ENDIF.
  CLEAR it_ekls.

ENDFORM.                                "note 1043602



*&---------------------------------------------------------------------*
*&      Form  sc_components_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM sc_components_check.
  DATA: lt_ekbe_sc      TYPE TABLE OF ekbe_sc,
        ls_ekbe_sc      TYPE ekbe_sc,
        lt_sc_total     TYPE TABLE OF ekbe_sc,
        ls_sc_total     TYPE ekbe_sc,
        lt_mdvw         TYPE STANDARD TABLE OF mdvw,
        ls_mdvw         TYPE mdvw,
        ls_ekpo         TYPE ekpo,
        ls_ekko         TYPE ekko,
        l_no_batch      TYPE flag,
        i_not_valid     TYPE c,
        l_tabix         TYPE sytabix,
        l_total_batches TYPE erfmg,
        wemng           LIKE xekpo-wemng,
        shkzg           LIKE mseg-shkzg,
        lv_missing_qty  TYPE erfmg.
  CHECK: xmbwl IS NOT INITIAL,                "no MBxx transactions
         mseg-sobkz = o,
         mseg-ebeln IS NOT INITIAL,
         mseg-ebelp IS NOT INITIAL.
  CLEAR: lt_sc_total, xekbe_sc, wemng.
  READ TABLE ymseg INTO omseg
                   WITH KEY ebeln = mseg-ebeln
                            ebelp = mseg-ebelp
                            line_id = mseg-parent_id.
  IF NOT sy-subrc IS INITIAL.
* consumption of components
    CLEAR: odm07m, omseg.
    MOVE-CORRESPONDING mseg TO omseg.
    omseg-kzbew = t158-kzbew.
* Check if subcontracting PO by reading EKPO-PSTYP
    CALL FUNCTION 'ME_EKPO_SINGLE_READ'
      EXPORTING
        pi_ebeln                  = mseg-ebeln
        pi_ebelp                  = mseg-ebelp
      IMPORTING
        PO_EKPO                   = ls_ekpo
      EXCEPTIONS
        NO_RECORDS_FOUND          = 1
        OTHERS                    = 2.
* If subcontracting PO we need to call ME_READ_ITEM_GOODS_RECEIPT
* to fill the reference line OMSEG for form Lohnbearbeitung
    PERFORM bestellung_pruefen(sapmm07m) USING mseg-ebeln
                                               mseg-ebelp
                                               mseg-lfbja
                                               mseg-lfbnr
                                               mseg-lfpos
                                               t156-shkzg
                                               mseg-werks
                                               vm07m-kzwes
                                               space
                                               i_not_valid.
    CHECK xebefu-pstyp = drei.
    CHECK xebefu-co_order IS NOT INITIAL.
* begin of note 1350318
* If no subcontracting PO, stop here, no need to read further.
* Check, if the account assignment category is valid
    CALL FUNCTION 'ME_EKKO_SINGLE_READ'
      EXPORTING
        PI_EBELN                  = mseg-ebeln
      IMPORTING
        PO_EKKO                   = ls_ekko
      EXCEPTIONS
        NO_RECORDS_FOUND          = 1
        OTHERS                    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CALL FUNCTION 'IAOM_OM_RETRIEVE_SCENARIO_DATA'
      EXPORTING
        i_po_order_type = ls_ekko-bsart
      IMPORTING
        e_knttp         = xebefu-knttp
      EXCEPTIONS
        no_knttp        = 1
        OTHERS          = 2.
    IF sy-subrc NE 0.
*   Acct assignment determination is not poss.in the account assgnmnt manager
      MESSAGE e220(IAOM).
    ENDIF.
* end of note 1350318
    rm07m-kzbew = mseg-kzbew.
    IF vm07m-xstor = zwei.
      dm07m-knttp = xebefu-knttp.
      dm07m-wemng = xebefu-wemng.
    ENDIF.
    omseg-lifnr  = kbefu-lifnr.
    odm07m-konto = xebefu-konto.
    omseg-shkzg = mseg-shkzg.
    IF mseg-parent_id IS INITIAL.
      omseg-ebeln = mseg-ebeln.
      omseg-ebelp = mseg-ebelp.
      omseg-bstmg = xebefu-bsmng.
      PERFORM shkzg_drehen IN PROGRAM SAPLMBGB USING omseg-shkzg shkzg.
      omseg-shkzg = shkzg.
    ENDIF.
     wemng = xebefu-bsmng.
  ELSE.
    CHECK xebefu-co_order IS NOT INITIAL.
  ENDIF.      "sy-subrc is initial
* read components in internal table XMDVW
  CALL FUNCTION 'ME_COMPONENTS_REFRESH'.
  CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
    EXPORTING
      aktwe         = xebefu-bsmng
      ebeln         = omseg-ebeln
      ebelp         = omseg-ebelp
      lfbnr         = omseg-lfbnr
      lfgja         = omseg-lfbja
      lfpos         = omseg-lfpos
      shkzg         = omseg-shkzg
      sumwe         = wemng
      kzbew         = omseg-kzbew
      no_batch      = l_no_batch                        " SC-batch
    IMPORTING
      et_ekbe_sc    = lt_ekbe_sc[]
    TABLES
      t_bbefu       = lt_mdvw
    EXCEPTIONS
      not_found_any = 01
      not_found_one = 02
      not_valid_any = 03
      not_valid_one = 04.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'MDVW' sy-subrc. " noch im einzelnen setzen
    CASE sy-subrc.
      WHEN 1.
*     MESSAGE E031 WITH B-EBELN KBEFU-LOEKZ.
      WHEN 2.
*     MESSAGE E030 WITH B-EBELN.
      WHEN 3.
*     MESSAGE E032 WITH B-EBELN.
      WHEN OTHERS.
*     MESSAGE E030 WITH B-EBELN.
    ENDCASE.
  ENDIF.
* Calculate the total consumption posted in the past
  LOOP AT lt_ekbe_sc INTO ls_ekbe_sc
        WHERE ebeln = mseg-ebeln
          AND ebelp = mseg-ebelp
          AND matnr = mseg-matnr.
    CLEAR l_tabix.
    READ TABLE lt_sc_total INTO ls_sc_total
        WITH KEY ebeln = mseg-ebeln
                ebelp = mseg-ebelp
                matnr = mseg-matnr
                charg = ls_ekbe_sc-charg.
    l_tabix = sy-TABIX.
    IF l_tabix = 0.
      APPEND ls_ekbe_sc TO lt_sc_total.
    ELSE.
      IF ls_ekbe_sc-shkzg = H.
*       consumed component
        ls_sc_total-erfmg = ls_sc_total-erfmg + ls_ekbe_sc-erfmg.
      ELSE.  "Reversal of consumption
        ls_sc_total-erfmg = ls_sc_total-erfmg - ls_ekbe_sc-erfmg.
      ENDIF.
      REFRESH xebefu. CLEAR xebefu.
      MODIFY TABLE lt_sc_total FROM ls_sc_total. "INDEX l_tabix.
    ENDIF.
  ENDLOOP.
* Cancellation
  IF vm07m-xstor = zwei.
    READ TABLE lt_ekbe_sc INTO ls_ekbe_sc
       WITH KEY ebeln = mseg-ebeln
                ebelp = mseg-ebelp
                belnr = mseg-smbln
                matnr = mseg-matnr
                charg = mseg-charg.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_ekbe_sc TO xekbe_sc.
      xekbe_sc-shkzg = mseg-shkzg.
    ENDIF.
* Posting e.g. with movement type 544 o, e.g. subsequent adjustment
  ELSEIF lt_ekbe_sc[] IS NOT INITIAL AND mseg-shkzg = s.
    CLEAR: l_total_batches.
    LOOP AT lt_sc_total INTO ls_sc_total
            WHERE ebeln = mseg-ebeln
              AND ebelp = mseg-ebelp
              AND matnr = mseg-matnr.
      l_total_batches = l_total_batches + ls_sc_total-erfmg.
    ENDLOOP.
    MOVE-CORRESPONDING mseg TO xekbe_sc.
    IF l_total_batches < mseg-erfmg.
      lv_missing_qty = mseg-erfmg - l_total_batches.
      lv_missing_qty = ABS( lv_missing_qty ).
* Verbrauch der Lohnbearbeitungskomponente & ist um & & überschritten
      MESSAGE w442(M7) WITH mseg-matnr lv_missing_qty mseg-meins.
      PERFORM naco_log IN PROGRAM sapfm07m USING 'W' 'M7' '442'
              mseg-matnr lv_missing_qty mseg-meins space.
    ENDIF.
ENHANCEMENT-POINT EHP606_LOHNBEARBEITUNG_02 SPOTS ES_SAPMM07M .
  ELSE. "consumption with e.g. movement type 543 o
    CLEAR: l_total_batches.
    LOOP AT lt_sc_total INTO ls_sc_total
            WHERE ebeln = mseg-ebeln
              AND ebelp = mseg-ebelp
              AND matnr = mseg-matnr.
      l_total_batches = l_total_batches + ls_sc_total-erfmg.
    ENDLOOP.
    READ TABLE lt_mdvw INTO ls_mdvw
      WITH KEY matnr = mseg-matnr
               werks = mseg-werks
               charg = mseg-charg.
    IF sy-subrc <> 0.
      READ TABLE lt_mdvw INTO ls_mdvw
        WITH KEY matnr = mseg-matnr
                 werks = mseg-werks.
    ENDIF.
    IF sy-subrc = 0 AND mseg-erfmg <> 0..
      lv_missing_qty = ls_mdvw-bdmng - mseg-erfmg - l_total_batches.
      IF lv_missing_qty < 0.
        lv_missing_qty = ABS( lv_missing_qty ).
*   Verbrauch der Lohnbearbeitungskomponente & ist um & & überschritten
        MESSAGE w442(M7) WITH mseg-matnr lv_missing_qty mseg-meins.
        PERFORM naco_log IN PROGRAM sapfm07m USING 'W' 'M7' '442'
                mseg-matnr lv_missing_qty mseg-meins space.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING mseg TO xekbe_sc.
    xekbe_sc-lagme = ls_mdvw-lagme.
    xekbe_sc-bdmng = ls_mdvw-bdmng.
    xekbe_sc-wamng = ls_mdvw-wamng.
    xekbe_sc-wawrt = ls_mdvw-wawrt.
    xekbe_sc-lgpro = mseg-lgort.
ENHANCEMENT-POINT EHP606_LOHNBEARBEITUNG_03 SPOTS ES_SAPMM07M .
  ENDIF.
  xekbe_sc-buzei = mseg-zeile.
  CLEAR xekbe_sc-belnr.
  APPEND xekbe_sc.
ENDFORM.