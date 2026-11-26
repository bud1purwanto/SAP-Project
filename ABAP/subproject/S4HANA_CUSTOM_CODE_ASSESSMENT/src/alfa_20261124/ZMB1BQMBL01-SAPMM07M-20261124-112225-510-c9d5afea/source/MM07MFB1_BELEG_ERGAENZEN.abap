*eject
*---------------------------------------------------------------------*
*       FORM BELEG_ERGAENZEN                                          *
*---------------------------------------------------------------------*
*       Die Belegpositionen werden ergänzt und in die Tabelle         *
*       FUSS bzw. MSEG übernommen.                                    *
*---------------------------------------------------------------------*
FORM beleg_ergaenzen.

* Sept 2002 MM                                              "n555246
* log function tax auditor                                  "n555246

* cancellation not possible : data from the original        "n504778
* MM documents were overwritten by data from reservations   "n504778

* separate time depending authorization for tax auditor     "n486477

  DATA: kopf_zeile LIKE mseg-zeile.
  DATA: kopf_ebelp LIKE ekpo-ebelp.                        "559567
  DATA: anz_comp LIKE sy-tabix.
  DATA: xower_old LIKE xower.
  DATA: i_not_valid TYPE c.                                "614370
  DATA: le_or_mm TYPE c.                                   "Note 875529
  DATA: ls_ekko TYPE ekko.                                 "Note 875529
* table to store reservation numbers that have to be locked.
  DATA: BEGIN OF lt_reservation_enqueue OCCURS 0,          "note 205978
          rsnum LIKE resb-rsnum,                           "note 205978
        END OF lt_reservation_enqueue.                     "note 205978
  DATA: BEGIN OF ls_reservation_enqueue,                   "note 205978
          rsnum LIKE resb-rsnum,                           "note 205978
        END OF ls_reservation_enqueue.                     "note 205978
  CLEAR: ls_reservation_enqueue.                           "note 205978
  REFRESH: lt_reservation_enqueue.                         "note 205978
* vsa_lg anfang
*  DATA: KOPF_ZEILE_WERTM TYPE C.
* vsa_lg ende
* note 138602
  DATA: BEGIN OF sxmseg OCCURS 10.     "help table structured article
          INCLUDE STRUCTURE mseg.
  DATA: END OF sxmseg.
* Delivery flow
  DATA:                                                          "358454
    ls_mbvbfa           TYPE mbvbfa,                             "358454
    lt_mbvbfa           TYPE STANDARD TABLE OF mbvbfa.           "358454
  DATA: BEGIN OF ls_likp_info,                               "1657162
          vbeln LIKE likp-vbeln,                             "1657162
          vbtyp LIKE likp-vbtyp,                             "1657162
        END OF ls_likp_info,                                 "1657162
        l_vbeln_im      TYPE c.  "using MSEG-VBELN_IM        "1657162

* definition of the working area for additional fields to   "n504778
* be saved and restored in case of cancellation ( fields    "n504778
* LGORT, CHARG, LIFNR are saved and restored always )       "n504778
  DATA : BEGIN OF l_s_save,                                 "n504778
           werks             LIKE      resb-werks,          "n504778
           prvbe             LIKE      resb-prvbe,          "n504778
           berkz             LIKE      resb-berkz,          "n504778
           sobkz             LIKE      resb-sobkz,          "n504778
           lgnum             LIKE      resb-lgnum,          "n504778
           lgtyp             LIKE      resb-lgtyp,          "n504778
           lgpla             LIKE      resb-lgpla,          "n504778
           kzvbr             like      resb-kzvbr,          "874689
           kdauf             like      mseg-kdauf,          "1057655
           kdpos             like      mseg-kdpos,          "1057655
           kdein             like      mseg-kdein,          "1057655
           ps_psp_pnr        like      mseg-ps_psp_pnr,     "1057655
           bemot             like      mseg-bemot,          "n1066863
        END OF l_s_save.                                    "n504778

DATA: LS_ISU_SONDERBESTAND_PRUEFEN TYPE ISU_SONDERBESTAND_PRUEFEN. "IS2ERP

* begin -------------------------------------------------------"n1626562
DATA : lv_flag_maa_active    TYPE  abap_bool,
       lv_zeile_search       TYPE  mseg-zeile.

* check whether the business function MAA is active
  lv_flag_maa_active = cl_ops_switch_check=>mm_sfws_maa( ).
* end   -------------------------------------------------------"n1626562


* note 138602
  CLEAR: index_l, index_a,
         storno, t156n.
  DESCRIBE TABLE xmseg LINES index_l.
  storno = index_l.
  REFRESH: prefetch01,
           prefetch02,
           prefetch03.
  LOOP AT xmseg.
* Belege mit gemischten Zeilen sind nicht vorgesehen.
    IF NOT xmseg-xwoff IS INITIAL.
      xower_old = xower.
      xower = x.
      IF xower NE xower_old AND sy-tabix > 1.
        MESSAGE e255.
      ENDIF.
    ENDIF.
*   new logic for deliveries                  "1657162\/
    IF xmseg-vbeln_im IS INITIAL OR
       xmseg-vbelp_im IS INITIAL.
      CLEAR l_vbeln_im .  "old logic
    ELSE.
      l_vbeln_im = 'X'.   "new logic
    ENDIF.                                    "1657162/\

*   begin -----------------------------------------------------"n1626562
*   in the case of cancellation a delivery it could be that
*   the items of the reference MM doc do not contain material
*   numbers -> save key for reading the document flow, too

    IF xmseg-matnr IS INITIAL  AND     " no material number
       im_process  =  l        AND     " belongs to a deliverry
       t158-trtyp  =  h        AND     " create MM document
       l_vbeln_im IS INITIAL.                 "1657162
      MOVE-CORRESPONDING  xmseg        TO  ls_mbvbfa.
      APPEND  ls_mbvbfa                TO  lt_mbvbfa.
      CONTINUE.    " take the next entry
    ENDIF.
*   end   -----------------------------------------------------"n1626562

    IF NOT xmseg-matnr IS INITIAL.
      IF t158-trtyp = h.
        MOVE-CORRESPONDING xmseg TO prefetch02.
        COLLECT prefetch02.
*     Prepare prefetch table for document flow.
*     In former times we have had an if-statement at this place in
*     order to prepare table only if we know that this might be
*     a case in which we have to update the document flow ourself
*     (kzbew b, MBST) or if we need to find the delivery number for the
*     document (MB_CANCEL). The check has been only for performance
*     reasons. Necessary due to note 372613
*     if xmseg-kzbew = b.                                        "358454

* > Begin of note 875529

*   Comments: KZZUG is not set for stock transfer orders within the
*             same company code RESWK is set in case of cross company
*             stock transfer orders
       IF l_vbeln_im IS INITIAL.              "1657162
        IF im_process  = 'L' OR
           xmseg-kzbew = 'L'.                                "n_1024978
          MOVE-CORRESPONDING xmseg TO ls_mbvbfa.
          APPEND ls_mbvbfa TO lt_mbvbfa.
        ELSEIF xmseg-kzbew = 'B'.
          IF xmseg-kzzug = 'X'.
            MOVE-CORRESPONDING xmseg TO ls_mbvbfa.
            APPEND ls_mbvbfa TO lt_mbvbfa.
          ELSE.
            IF ls_ekko-ebeln NE xmseg-ebeln.
              CLEAR ls_ekko.
              SELECT SINGLE ebeln reswk FROM ekko
                                        INTO CORRESPONDING
                                             FIELDS OF ls_ekko
                                        WHERE ebeln = xmseg-ebeln.
              IF sy-subrc IS INITIAL AND NOT ls_ekko-reswk IS INITIAL.
                  MOVE-CORRESPONDING xmseg TO ls_mbvbfa.
                  APPEND ls_mbvbfa TO lt_mbvbfa.
              ENDIF.
            ELSEIF NOT ls_ekko-reswk IS INITIAL.
              MOVE-CORRESPONDING xmseg TO ls_mbvbfa.
              APPEND ls_mbvbfa TO lt_mbvbfa.
            ENDIF.
          ENDIF.
        ENDIF.
       ENDIF.                                 "1657162
      ENDIF.
* > End of note 875529
      MOVE-CORRESPONDING xmseg TO prefetch03.
      COLLECT prefetch03.

* note 138602
      IF xmseg-xauto = s.
        READ TABLE xmseg WITH KEY zeile = xmseg-urzei
                                  matnr = xmseg-matnr
                         INTO sxmseg.
        IF sy-subrc IS INITIAL.
          APPEND xmseg TO sxmseg.
        ENDIF.
      ELSEIF xmseg-xauto = u.
        READ TABLE xmseg WITH KEY zeile = xmseg-urzei
                                  ummat = xmseg-matnr
                         INTO sxmseg.
        IF sy-subrc IS INITIAL.
          APPEND xmseg TO sxmseg.
        ENDIF.
      ENDIF.
* note 138602
    ENDIF.
  ENDLOOP.
  IF NOT xower IS INITIAL.
    DESCRIBE TABLE xmseg LINES sy-tabix.
    IF xmbwl IS INITIAL.
      CLEAR xmseg_lines.
    ENDIF.
    xmseg_lines = xmseg_lines + sy-tabix.
  ENDIF.
  PERFORM prefetch_ausfuehren USING x
                                    space.

* > Begin of note 875529
  CLEAR: le_or_mm.
  IF im_process = 'L'.
    le_or_mm = 'X'.
  ENDIF.
* > End of note 875529

* Enrichment of document flow data: find delivery for material doc
  IF NOT lt_mbvbfa IS INITIAL.                                   "358454
    CALL FUNCTION 'MB_READ_DELIVERY_FLOW'                        "358454
      EXPORTING                                                  "358454
        i_xblnr   = xmkpf-xblnr                                  "358454
        i_le_or_mm = le_or_mm                                    "875529
      TABLES                                                     "358454
        ct_mbvbfa = lt_mbvbfa.                                   "358454
*   Sort to allow fast access. SORTED TABLE cannot be used due to the
*   TABLES-parameter of the function module above.
    SORT lt_mbvbfa BY mblnr mjahr zeile.                         "358454
  ENDIF.

  REFRESH yfuss.
  IF NOT t158-trtyp = h.
    REFRESH: ydm07m,
             yvm07m,
             ymseg.
  ENDIF.

  LOOP AT xmseg.
    DATA: kzbew LIKE rm07m-kzbew.
    tabix = sy-tabix.
*   Bei Transaktionstyp H zieht die Berechtigungsprüfung beim
*   Übernehmen der Position. Daher hier überflüssig...
    IF t158-trtyp NE h.
      AUTHORITY-CHECK OBJECT 'M_MSEG_WMB'
                      ID 'ACTVT' FIELD actvt
                      ID 'WERKS' FIELD xmseg-werks.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e120 WITH xmseg-werks.
      ENDIF.
      AUTHORITY-CHECK OBJECT 'M_MSEG_BMB'
                      ID 'ACTVT' FIELD actvt
                      ID 'BWART' FIELD xmseg-bwart.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e121 WITH xmseg-bwart.
      ENDIF.

*     separate time depending authorization for tax auditor "n486477
*     check the authority per item                          "n486477
      DATA : l_f_repid       TYPE progname.                 "n486477
      MOVE  sy-repid         TO  l_f_repid.                 "n486477
                                                            "n486477
      CALL FUNCTION          'MB_CHECK_USER_PG_DATE_PLANT'  "n486477
        EXPORTING                                           "n486477
          i_plant            = xmseg-werks                  "n486477
          i_user             = sy-uname                     "n486477
          i_program          = l_f_repid                    "n486477
          i_budat            = xmkpf-budat                  "n486477
        EXCEPTIONS                                          "n486477
          no_authority_prog  = 1                            "n486477
          no_authority_date  = 2                            "n486477
          OTHERS             = 3.                           "n486477
                                                            "n486477
*     evaluate the result                                   "n486477
      CASE   sy-subrc.                                      "n486477
        WHEN  0.                                            "n486477
*         user has the required authorization               "n486477
        WHEN  1.                                            "n486477
*         You are not authorized to execute program &       "n486477
          MESSAGE  e001(ca_check_date) WITH  l_f_repid.     "n486477
        WHEN  2.                                            "n486477
*         No authorization for displaying data from ...     "n486477
          MESSAGE            e002(ca_check_date).           "n486477
        WHEN  OTHERS.                                       "n486477
*         parameter error                                   "n486477
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno "n486477
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4. "n486477
      ENDCASE.                                              "n486477
    ENDIF.
    IF NOT xmseg-lgort IS INITIAL.                          "162405
      CLEAR xt001l.
      xt001l-werks = xmseg-werks.
      xt001l-lgort = xmseg-lgort.
      xt001l-xlong = dm07m-xlong.
*     The flag tells LAGERORT_PRUEFEN that it has been called by the
*     reader routine. This controls the reaction of the form
*     with respect to deleted storage locations (note 112737) and
*     authority check when reading a reference document.
      f_lagerort_pruefen_trtyp = t158-trtyp.                "162405
      PERFORM lagerort_pruefen(sapfm07m) USING xt001l
                                               xmseg-bwart.
      dm07m-xlong = xt001l-xlong.
    ENDIF.
*   new logic for deliveries                  "1657162\/
    IF xmseg-vbeln_im IS INITIAL OR
       xmseg-vbelp_im IS INITIAL.
      CLEAR l_vbeln_im .  "old logic
    ELSE.
      l_vbeln_im = 'X'.   "new logic
    ENDIF.                                    "1657162/\
    CLEAR: dm07m, vm07m.
    CLEAR rc.
    dm07m-orzeil = xmseg-zeile.        "localization Brazil
    mseg = xmseg.
    IF mseg-sobkz = e AND mseg-mat_kdauf IS INITIAL.        "0176399
      mseg-mat_kdauf = mseg-kdauf.                          "0176399
      mseg-mat_kdpos = mseg-kdpos.                          "0176399
    ENDIF.                                                  "0176399
    IF mseg-sobkz = q AND mseg-mat_pspnr IS INITIAL.        "0176399
      mseg-mat_pspnr = mseg-ps_psp_pnr.                     "0176399
    ENDIF.                                                  "0176399
ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_01 SPOTS ES_SAPMM07M.
    IF t158-trtyp = a.
      mseg-zeile = tabix.
    ELSE.
ENHANCEMENT-SECTION     BELEG_ERGAENZEN_01 SPOTS ES_SAPMM07M.
      IF NOT mseg-zeile = tabix AND xmbwl IS INITIAL.            "406146
        READ TABLE xmseg WITH KEY xmacc = 'V'                 "MAA2
                         TRANSPORTING NO FIELDS.              "MAA2
        IF NOT sy-subrc IS INITIAL.                           "MAA2
          MESSAGE e189 WITH mseg-mblnr.
        ENDIF.                                                "MAA2
      ENDIF.
END-ENHANCEMENT-SECTION.
    ENDIF.
    DATA lifnr LIKE mseg-lifnr.
    IF t158-trtyp = h.
      CHECK mseg-kzzug NE z.
*-  Buchungskreisprüfung mit 2.0 rausnehmen ----- Anfang -------------*
      IF tabix = 1 AND xmbwl IS INITIAL AND NOT mseg-werks IS INITIAL.
        PERFORM werk_pruefen(sapfm07m) USING      space          "702002
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
        IF km07r-waers IS INITIAL.
          km07r-waers = mseg-waers.
          km07r-ktopl = dm07m-ktopl.
          km07r-periv = dm07m-periv.
        ELSE.
        IF NOT km07r-waers = t001-waers OR NOT km07r-ktopl = t001-ktopl
                                        OR NOT km07r-periv = t001-periv.
            MESSAGE e516.
          ENDIF.
        ENDIF.
      ENDIF.
      IF mseg-parbu IS INITIAL.
        mseg-parbu = mseg-bukrs.
      ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen ----- Ende ---------------*
      PERFORM beleg_ergaenzen_init.
      IF mseg-xauto = x.
        storno = storno - 1.
        CHECK a = b.
      ENDIF.
      IF NOT fcausw-xnbwa IS INITIAL.
        IF NOT t156n-fcode = fcausw-fcode OR
           NOT t156n-bwart = mseg-bwart.
          SELECT SINGLE * FROM t156n WHERE fcode = fcausw-fcode
                                      AND  bwart = mseg-bwart.
        ELSE.
          CLEAR sy-subrc.
        ENDIF.
        CHECK sy-subrc IS INITIAL.
        mseg-bwart = t156n-bwart_next.
        vm07m-xstor = t156n-xstor.
        IF NOT t156n-xstor IS INITIAL.
ENHANCEMENT-POINT BELEG_ERGAENZEN_02 SPOTS ES_SAPMM07M.
          IF t156n-xstor = '2'.                                  "702002
          IF rm07m-kzbew = b OR rm07m-kzbew = f                  "934817
           OR rm07m-kzbew = o.                                   "934817
           IF rm07m-kzbew = f.                                   "934817
             AUTHORITY-CHECK OBJECT 'M_MSEG_WWF'                 "934817
                        ID 'ACTVT' FIELD actvt                   "934817
                        ID 'WERKS' FIELD mseg-werks.             "934817
             IF NOT sy-subrc IS INITIAL.                         "934817
               MESSAGE e120 WITH mseg-werks.                     "934817
             ENDIF.                                              "934817
           ELSE.                                                 "934817
              AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'                "934817
                        ID 'ACTVT' FIELD actvt                   "934817
                        ID 'WERKS' FIELD mseg-werks.             "934817
             IF NOT sy-subrc IS INITIAL.                         "934817
               MESSAGE e120 WITH mseg-werks.                     "934817
             ENDIF.                                              "934817
           ENDIF.                                                "934817
          ELSE.                                                  "934817
            AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'                  "702002
                            ID 'ACTVT' FIELD actvt               "702002
                            ID 'WERKS' FIELD mseg-werks.         "702002
            IF NOT sy-subrc IS INITIAL.                          "702002
              MESSAGE e120 WITH mseg-werks.                      "702002
            ENDIF.                                               "702002
          endif.                                                 "934817

          ENDIF.                                                 "702002



          PERFORM belegdaten_storno.
          CHECK rc IS INITIAL.
* note 138602
          IF xmseg-xauto = s  OR  xmseg-xauto = u.
* check whether automatic created position is the header
            READ TABLE sxmseg WITH KEY zeile = xmseg-zeile
                                       matnr = xmseg-matnr.
            IF sy-subrc IS INITIAL.
              vm07m-xhead = x.
            ENDIF.
          ENDIF.
* note 138602
        ENDIF.
      ENDIF.
* Nur bei Belegstorno soll ohne Wert gebucht werden
      IF vm07m-xstor NE zwei.
        CLEAR xower.
      ENDIF.
      IF NOT mseg-xauto IS INITIAL AND NOT t156n-xstor = zwei AND
*begin note 380066
*         NOT mseg-xauto = l.
         NOT mseg-xauto = l AND
         NOT mseg-xauto = m AND NOT mseg-xauto = w AND
         NOT mseg-xauto = f.
* We mustn't forget transfer postings of empties on a value basis!
* Otherwise the tied empties get lost during postings of MBRL or MBSU
* if the sender or receiver manages the stock on a value basis.
********************
* This is the point, where the position gets dropped in case we don't
* have : XAUTO <> space, l, m, w, f   AND   we're NO reversal
********************
*end note 380066
        storno = storno - 1.
        CHECK a = b.
      ENDIF.
*     urzei needs to be cleared in case process is not cancel or return.
*     This is necessary for other processes involving material document
*     as reference document e.g. release blocked stock... as urzei
*     will not correspond to urzei in the following movement as
*     components will be added. A clear would cause a wrong omseg-urzei
*     in the following program flow. See notes 201909 and 322810.
      IF NOT vm07m-xstor = zwei AND NOT vm07m-xstor = eins.   "322810
        CLEAR mseg-urzei.                                     "322810
      ENDIF.                                                  "322810
      IF NOT vm07m-xstor = zwei.
*       CLEAR: MSEG-GRUND, MSEG-URZEI.
        CLEAR mseg-grund.                                  "note 201909
      ENDIF.

      SELECT SINGLE * FROM T156 WHERE BWART = MSEG-BWART.        "649155
      IF NOT rm07m-grund IS INITIAL AND NOT t156-kzgru EQ minus. "649155
        mseg-grund = rm07m-grund.
      ENDIF.
      CLEAR rc.

*     begin -------------------------------------------------"n1626562
*     set the item number depending on MAA item or not
      IF     lv_flag_maa_active =  abap_true AND " MAA is active
         NOT xmseg-maa_urzei    IS INITIAL.      " this is a MAA item
        MOVE  xmseg-maa_urzei          TO  lv_zeile_search.
      ELSE.
        MOVE  xmseg-zeile              TO  lv_zeile_search.
      ENDIF.
*     end   -------------------------------------------------"n1626562

*     Find original delivery number from documentflow index
      READ TABLE lt_mbvbfa INTO ls_mbvbfa                        "358454
                           WITH KEY mblnr = xmseg-mblnr          "358454
                                    mjahr = xmseg-mjahr          "358454
                                    zeile = lv_zeile_search    "n1626562
                           BINARY SEARCH.                        "358454
      IF sy-subrc = 0.                                           "358454
        vm07m-vbeln = ls_mbvbfa-vbelv.                           "358454
        vm07m-vbelp = ls_mbvbfa-posnv.                           "358454
      ELSEIF l_vbeln_im = 'X'.                             "1657162\/
        IF ls_likp_info-vbeln IS INITIAL OR
           ls_likp_info-vbeln NE xmseg-vbeln_im.
          SELECT SINGLE vbeln vbtyp FROM LIKP
                                    INTO ls_likp_info
                                    WHERE vbeln = xmseg-vbeln_im.
        ENDIF.
        IF ls_likp_info-vbtyp = '7'.
         IF t156-bustr = '559'. "else ID is determined by MM-PUR
           dm07m-vbeln_vl = xmseg-vbeln_im.
           dm07m-vbelp_vl = xmseg-vbelp_im.
         ENDIF.
        ELSE.  "vbtyp = J or T
          vm07m-vbeln = xmseg-vbeln_im.
          vm07m-vbelp = xmseg-vbelp_im.
        ENDIF.                                            "1657162/\
      ENDIF.                                                     "358454

*     In case of 'place in storage'-functionality set SOBKZ for
*     subcontractor and customer consignment in-transfer stocks
      IF gv_mm_om1_sfws_sc_active = cl_ops_switch_check=>switch_active_true.
        IF fcausw-fcode = fcod-su
         AND t156-bustr = bustr_30c.
            mseg-sobkz = mseg-umsok.
        ENDIF.
      ENDIF.

*     Temporary correct KZBEW: unnecessary here      note 204573
      CASE mseg-kzbew.                                      "204573
        WHEN space OR l.                                    "204573
          PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                       mseg-xauto.
*         Material document with reservation
          IF NOT mseg-rsnum IS INITIAL AND t158-trtyp = h.
            CLEAR xrbefu.
            REFRESH xrbefu.
            DATA: erfmg LIKE mseg-menge.
            DATA: erfme LIKE mseg-erfme.
            DATA: sobkz LIKE mseg-sobkz.
            DATA: charg LIKE mseg-charg.
            DATA: bwart LIKE mseg-bwart.
            DATA: ps_psp_pnr LIKE mseg-ps_psp_pnr.
            DATA: sgtxt LIKE mseg-sgtxt.
            DATA: l_ablad LIKE mseg-ablad,                 "339567
                  l_wempf LIKE mseg-wempf.                 "339567
            ls_reservation_enqueue-rsnum = mseg-rsnum.     "note 205978
            COLLECT ls_reservation_enqueue INTO            "note 205978
              lt_reservation_enqueue.                      "note 205978
            bwart = mseg-bwart.
            lgort = mseg-lgort.
            menge = mseg-menge.
            erfmg = mseg-erfmg.
            erfme = mseg-erfme.
            sobkz = mseg-sobkz.
            sgtxt = mseg-sgtxt.
            charg = mseg-charg.
            lifnr = mseg-lifnr.
            ps_psp_pnr = mseg-ps_psp_pnr.
            l_ablad = mseg-ablad.                         "339567
            l_wempf = mseg-wempf.                         "339567
            PERFORM bewegungsart_pruefen(sapfm07m) USING bwart
                                                         space.

*           save the data from the old MM document          "n504778
            MOVE-CORRESPONDING  mseg   TO  l_s_save.        "n504778

            shkzg = t156-shkzg.
            CALL FUNCTION 'MB_READ_RESERVATION_POS_WA'
                 EXPORTING
                      rsnum  = mseg-rsnum
                      rspos  = mseg-rspos
                      rsart  = mseg-rsart
                      xrsart = x
                      shkzg  = shkzg
                      bwart  = bwart
                      kzneb  = eins
                      xstor  = vm07m-xstor
                      i_read_for_cancel = read_for_cancel    "note357305
                 TABLES
                      seqtab = xrbefu.
            READ TABLE xrbefu INDEX 1.
            IF NOT sy-subrc IS INITIAL.
              IF shkzg NE xrbefu-shkzg.
                CLEAR: mseg-rsnum, mseg-rspos.
              ELSE.
                index_a = index_a + 1.
              ENDIF.
            ENDIF.
            IF sy-subrc IS INITIAL.
ENHANCEMENT-POINT BELEG_ERGAENZEN_03 SPOTS ES_SAPMM07M.
              CALL FUNCTION 'GRPG_PSPNR_SWITCH_IN_RBEFU'  "<ins 204903
                   CHANGING c_rbefu = xrbefu.             "<ins 204903
ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_02 SPOTS ES_SAPMM07M.
              MOVE-CORRESPONDING xrbefu TO mseg.
ENHANCEMENT-POINT BELEG_ERGAENZEN_10 SPOTS ES_SAPMM07M.

              mseg-bwart = bwart.
              mseg-lgort = lgort.
              mseg-menge = menge.
              mseg-erfmg = erfmg.
              mseg-erfme = erfme.
              mseg-sobkz = sobkz.
              mseg-charg = charg.
              mseg-lifnr = lifnr.
              mseg-ablad = l_ablad.                         "339567
              mseg-wempf = l_wempf.                         "339567
              mseg-kdauf = xrbefu-kdauf.
              mseg-kdpos = xrbefu-kdpos.
              mseg-kdein = xrbefu-kdein.
              IF NOT sgtxt IS INITIAL.
                mseg-sgtxt = sgtxt.
              ENDIF.
              IF xrbefu-ps_psp_pnr IS INITIAL
                AND NOT ps_psp_pnr IS INITIAL.
                mseg-ps_psp_pnr = ps_psp_pnr.
              ENDIF.
*             restore the values from the old MM document      "1057655
*             during cancellation and an automatic             "1057655
*             reservation exists                               "1057655
*             Also applies to cancellation using MBST          "1057655
              if not read_for_cancel is initial OR             "1057655
                 vm07m-xstor = '2'.                            "1057655
*                and xrbefu-bdart        =  'AR'.              "1057655
                move-corresponding  l_s_save   to  mseg.       "1057655
              endif.                                           "1057655
              MOVE-CORRESPONDING xrbefu TO dm07m.
              dm07m-cuobj_refdoc = xrbefu-cuobj.                "630576
              dm07m-kanba = xrbefu-kbnkz.                       "705555
              IF NOT mseg-charg IS INITIAL.
                CLEAR dm07m-kzech.
              ENDIF.
              dm07m-rshkz = xrbefu-shkzg.
              IF vm07m-xstor NE zwei AND NOT xrbefu-ktoma IS INITIAL.
                dm07m-konto = xrbefu-saknr.
              ENDIF.
              vm07m-kzear_old = xrbefu-kzear.
              vm07m-bdter = xrbefu-bdter.
            ENDIF.
            IF NOT mseg-aufnr IS INITIAL OR
               NOT mseg-nplnr IS INITIAL.
              CALL FUNCTION 'CO_SF_MSEG_ACCOUNT_SETTLE'
                   EXPORTING
                        mseg_imp  = mseg
                        rbefu_imp = xrbefu
                   IMPORTING
                        mseg_exp  = mseg.
*              restore the value for BEMOT from the OLD MM   "n1066863
*              document during cancellation. If BEMOT was    "n1066863
*              changed in the order in the meantime, it      "n1066863
*              differs in cancellation from the original doc "n1066863
               IF vm07m-xstor = '2'.                         "n1066863
                 mseg-bemot = l_s_save-bemot.                "n1066863
               ENDIF.                                        "n1066863
            ENDIF.
          ENDIF.
          IF NOT mseg-ebeln IS INITIAL.
            IF mseg-kzzug IS INITIAL.
              IF t158-kzbew = b OR t158-kzbew = o.
                vm07m-pstyp = drei.
                IF mseg-kzvbr = a.
                  CLEAR dm07m-konto.
                ENDIF.
              ENDIF.
              IF t158-kzbew = o.
                DATA: wemng LIKE dm07m-wemng. CLEAR wemng.
*               1. We need to call ME_READ_COMP_GOODS_RECEIPT
*                  that early in order to check if all components are
*                  still available in XMDVW. This is not possible in
*                  form lohnbearbeitung as we are processing GR line
*                  there ??? Is it necessary to fill xekws that early ?
*               2. We call ME_READ_COMP different here as we do
*                  not have all the information we have in form
*                  lohnbearbeitung (see e.g. sumwe = wemng).
*               3. PUR needs the SHKZG from the original document
*                  during this call. As debit/credit indicator
*                  has already been changed in belegdaten_storno, we
*                  need to reverse it here temporarily.
*               see note 376724
*               NEW logic with note 514954:
*               4. Note 3. seems to be wrong as learned with note 514954
*                  we should call ME_READ_COMP always with SHKZG = H for
*                  the main item and KZBEW = O.
                DATA: l_shkzg LIKE mseg-shkzg.                 "376724
                DATA: bypro   TYPE c.                         "1356935
                l_shkzg = h.                                   "376724
                CLEAR: bypro.                                 "1356935
                CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
                     EXPORTING
                          aktwe         = mseg-erfmg
                          ebeln         = mseg-ebeln
                          ebelp         = mseg-ebelp
                          lfbnr         = mseg-lfbnr
                          lfgja         = mseg-lfbja
                          lfpos         = mseg-lfpos
                          shkzg         = l_shkzg              "376724
                          sumwe         = wemng
                          kzbew         = t158-kzbew           "514954
                     TABLES
                          t_bbefu       = xmdvw
                     EXCEPTIONS
                          not_found_any = 01
                          not_found_one = 02
                          not_valid_any = 03
                          not_valid_one = 04.
                IF NOT sy-subrc IS INITIAL.
                  MESSAGE e001 WITH 'MDVW' sy-subrc.
                ENDIF.
                IF ( mseg-shkzg = 'S' AND dm07m-xstbw = '' OR "1356935
                   mseg-shkzg = 'H' AND dm07m-xstbw = 'X' ) AND"1356935
                   mseg-kzbew IS INITIAL.   "only components  "1585602
                  bypro = 'X'.                                "1356935
                ENDIF.                                        "1356935
                LOOP AT xmdvw WHERE matnr = mseg-matnr
                              AND   werks = mseg-werks
                              AND   bwtar = mseg-bwtar        "1356935
                              AND   bypro = bypro.            "1356935
                  dm07m-bdmng = xmdvw-bdmng.
                  dm07m-wamng = xmdvw-wamng.
                  dm07m-wawrt = xmdvw-wawrt.
                  EXIT.
                ENDLOOP.
                IF NOT sy-subrc IS INITIAL.
                  MESSAGE e001 WITH 'XMDVW' mseg-matnr mseg-werks.
                ENDIF.
                LOOP AT xekls WHERE ebeln = mseg-ebeln
                              AND   ebelp = mseg-ebelp
                              AND   lfbja = mseg-lfbja      "PPF
                              AND   lfbnr = mseg-lfbnr      "PPF
                              AND   lfpos = mseg-lfpos      "PPF
                              AND   matnr = mseg-matnr
                              AND   werks = mseg-werks
                              AND   bwtar = mseg-bwtar        "1356935
                              AND   bypro = bypro.            "1356935
                  EXIT.
                ENDLOOP.
                IF NOT sy-subrc IS INITIAL.
                  xekls-curtp = '10'.            "note 1043602
                  MOVE-CORRESPONDING dm07m TO xekls.
                  MOVE-CORRESPONDING mseg TO xekls.
                  xekls-bypro = bypro.                        "1356935
                  APPEND xekls.
                ENDIF.
              ENDIF.
            ELSE.
*           GI for transfer PO (351/641)351: do not read BBEFU here
*           as read in MB_CREATE?
              IF mseg-kzbew <> l.                       "204573/302002
                PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                             mseg-xauto.
                PERFORM bestellung_wa_pruefen USING mseg-ebeln
                                                    mseg-ebelp
                                                    mseg-werks
                                                         space.
                READ TABLE xbbefu INDEX 1.
                IF NOT sy-subrc IS INITIAL.
                  index_a = index_a + 1.
                ENDIF.
                CHECK sy-subrc IS INITIAL.
                CHECK xbbefu-loekz IS INITIAL.
                PERFORM bbefu_check.                      "note 305582
                dm07m-bsmng = xbbefu-erfmg.
                MOVE-CORRESPONDING xbbefu TO dm07m.
                dm07m-umbar_po = xbbefu-umbar.                 "801097
                MOVE-CORRESPONDING xbbefu TO vm07m.
               MOVE kbefu-bwaer TO vm07m-bwaer.            "note 167017
                IF mseg-bstme IS INITIAL.                       "717157
                  mseg-bstmg = mseg-erfmg.                      "717157
                  mseg-bstme = mseg-erfme.                      "717157
                ENDIF.                                          "717157
                PERFORM bezugsnebenkosten_uebernehmen USING mseg-ebeln
                                                            mseg-ebelp
                                                            mseg-weunb
                                                            mseg-kzbew
                                                                 space.
              ENDIF.                   "kzbew <> l            "204573
            ENDIF.
          ENDIF.
          kzbew = rm07m-kzbew.
          CLEAR rm07m-kzbew.
          PERFORM fusszeile_bew_pruefen.
          IF dm07m-maktx IS INITIAL.
            PERFORM kurztext_lesen(sapfm07m) USING mseg-matnr.
            dm07m-maktx = mbefu-maktx.
          ENDIF.
          rm07m-kzbew = kzbew.
*         Not sure it should be called by kzbew=L as well but it seems
*         to have a different handling in case of KZBEW=B or F
          dm07m-mblmg = mseg-menge.                         "note 78657
          dm07m-mbbme = mseg-meins.                         "note 78657
*         in case of return delivery and cancellation check      "533295
*         if kzear will be set on the screen                     "533295
          IF dm07m-rshkz NE mseg-shkzg                          "698463
             AND NOT mseg-kzear IS INITIAL                      "698463
             AND vm07m-kzear_old = mseg-kzear                   "698463
             AND dm07m-kzear_inp IS INITIAL                     "698463
             AND ( aktyp = h OR xmigo = 'X' ).                  "698463
            DATA: meng1 LIKE mseg-menge,                        "698463
                  meng2 LIKE mseg-menge.                        "698463
                  clear meng2.                                  "698463
                  read table XMSEG index 1.                     "698463
                  LOOP at XMSEG.                                "698463
                    IF XMSEG-RSNUM eq MSEG-RSNUM AND            "698463
                       XMSEG-RSPOS eq MSEG-RSPOS.               "698463
                       meng2 = meng2 + XMSEG-menge.             "698463
                    ENDIF.                                      "698463
                  ENDLOOP.                                      "698463
                  meng1 = dm07m-enmng - meng2.                  "698463
            IF meng1 < dm07m-bdmng.                              "533295
*         MIGO cancelation KZEAR setting should not be cleared  "1083162
*         CO13 cancel production order confirmation, KZEAR      "1141370
*         should be cleared                                     "1141370
             IF NOT ( vm07m-xstor = 2 and xmigo = x ).          "1141370
              CLEAR mseg-kzear.                                  "533295
             ENDIF.                                             "1083162
            ENDIF.                                               "533295
          ENDIF.                                                 "533295
        WHEN b.
          IF t156n-xstor IS INITIAL AND mseg-shkzg = s
              AND NOT ( fcode = fcod-sf OR fcode = fcod-sn OR
              old_fcode = fcod-sf ).
            CLEAR: mseg-lfbnr, mseg-lfbja, mseg-lfpos.
          ENDIF.
          PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                       mseg-xauto.
          IF fcode = fcod-sn.
            rm07m-xsbdl = x.
          ENDIF.
          PERFORM bestellung_pruefen USING mseg-ebeln
                                           mseg-ebelp
                                           mseg-lfbja
                                           mseg-lfbnr
                                           mseg-lfpos
                                           mseg-shkzg
                                           mseg-werks
                                          vm07m-kzwes
                                          rm07m-xsbdl
                                          i_not_valid.      "614370
          IF NOT pos_not_valid IS INITIAL.                     "498200
            CLEAR pos_not_valid.                               "498200
            CONTINUE.                                          "498200
          ENDIF.                                               "498200
          READ TABLE xebefu INDEX 1.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'XEBEFU' eins.
          ENDIF.
          IF NOT xebefu-loekz IS INITIAL                    "919757
           and t156n-xstor ca '12'                          "919757
           AND xebefu-pstyp = '3'.                         "1072374
            message E036 with mseg-ebeln mseg-ebelp.        "919757
          endif.                                            "919757
*         In case of VL cancellation it should only be      "n1236124
*         possible to cancel the entire MM document         "n1236124
          IF NOT xebefu-loekz IS INITIAL                    "n1236124
          AND t156n-xstor = 2                               "n1236124
          AND ( im_process = L OR xmseg-kzbew = 'L' ) .     "n1236124
*            Document line & & could not be reversed        "n1236124
             message e345 with mseg-ebeln mseg-ebelp.       "n1236124
          ENDIF.                                            "n1236124
          CHECK xebefu-loekz IS INITIAL.
          IF mseg-anln1 IS INITIAL.
            mseg-anln1 = xebefu-anln1.
          ENDIF.
*         PO order unit has been changed, overwrite order unit
*         of reference document and convert quantity in order unit
          IF NOT xebefu-bstme IS INITIAL    AND            "1024042
             NOT   mseg-bstme IS INITIAL    AND            "1024042
                 xebefu-bstme NE mseg-bstme.               "1024042
            CALL FUNCTION 'MB_UNIT_CONVERSION'             "1024042
               EXPORTING                                   "1024042
                   MEINS                = mseg-meins       "1024042
                   ERFME                = xebefu-bstme     "1024042
                   MENGE                = mseg-menge       "1024042
                   UMREZ                = xebefu-umrez     "1024042
                   UMREN                = xebefu-umren     "1024042
               IMPORTING                                   "1024042
                   O_ERFME              = mseg-bstme       "1024042
                   O_ERFMG              = mseg-bstmg       "1024042
               EXCEPTIONS                                  "1024042
                   OTHERS               = 4.               "1024042
          ENDIF.                                           "1024042
          xebefu-erfmg = mseg-erfmg.
          PERFORM segmentdaten_ek_setzen.
*         begin of note 113766, 412669
          IF vm07m-kzwes = x AND mseg-charg IS INITIAL AND
             vm07m-xstor IS INITIAL.
            mseg-charg = xebefu-charg.
          ENDIF.
*         end of note 113766, 412669
ENHANCEMENT-POINT BELEG_ERGAENZEN_04 SPOTS ES_SAPMM07M.
          IF vm07m-xstor = zwei.
            dm07m-bwtor = mseg-bwtar.
          ELSEIF vm07m-xstor IS INITIAL.
            CLEAR mseg-mblnr.
          ENDIF.
          vm07m-elikz_old = xebefu-elikz.
          PERFORM bezugsnebenkosten_uebernehmen USING mseg-ebeln
                                                      mseg-ebelp
                                                      mseg-weunb
                                                      mseg-kzbew
                                                           space.
          IF mseg-bstme IS INITIAL.                              "480822
            mseg-bstmg = mseg-erfmg.                             "480822
            mseg-bstme = mseg-erfme.                             "480822
          ENDIF.                                                 "480822
          CLEAR vm07m-xnebe.
          IF dm07m-mblbm IS INITIAL.
            dm07m-mblbm = mseg-bpmng.
          ENDIF.
          dm07m-mbbmg = mseg-bstmg.
          dm07m-mbbme = mseg-bstme.
          IF mseg-erfme = mseg-meins.
            dm07m-mblmg = mseg-menge.
            dm07m-mbbme = mseg-meins.
            CLEAR dm07m-mbbmg.
          ENDIF.
        WHEN f.
          PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                       mseg-xauto.
          PERFORM pps_auftrag_pruefen USING mseg-aufnr
                                            mseg-aufps
                                            mkpf-budat.
          READ TABLE xfbefu INDEX 1.
          IF NOT sy-subrc IS INITIAL.
            index_a = index_a + 1.
          ENDIF.
          CHECK sy-subrc IS INITIAL.
          dm07m-maktx = xfbefu-ktext.
          dm07m-bsmng = xfbefu-psmng.
          mseg-bstme = xfbefu-amein.
          MOVE-CORRESPONDING xfbefu TO dm07m.
          dm07m-cuobj_refdoc = xfbefu-cuobj.                    "630576
          MOVE-CORRESPONDING xfbefu TO vm07m.
          dm07m-remng = xfbefu-armng.                     "note 0163340
          dm07m-rewrt = xfbefu-arwrt.                     "note 0163340
*         perform pps_werte.                                "P40K048294
          PERFORM pps_daten_03.
          vm07m-elikz_old = xfbefu-elikz.
* Only overwrite mseg-bstmg if mseg-bstme is not filled  "1581657
           IF mseg-bstme IS INITIAL.                     "1581657
             mseg-bstmg = mseg-erfmg.                    "1581657
             mseg-bstme = mseg-erfme.                    "1581657
           ENDIF.                                        "1581657
          IF vm07m-xstor = zwei.
            dm07m-bwtor = mseg-bwtar.
          ENDIF.
          CLEAR vm07m-xnebe.
          dm07m-mbbmg = mseg-bstmg.
          dm07m-mbbme = mseg-bstme.
          IF mseg-erfme = mseg-meins.
            dm07m-mblmg = mseg-menge.
            dm07m-mbbme = mseg-meins.
            CLEAR dm07m-mbbmg.
          ENDIF.
        WHEN o.
          IF t156n-xstor IS INITIAL AND mseg-shkzg = s
             AND NOT fcode = fcod-sf.
            CLEAR: mseg-lfbnr, mseg-lfbja, mseg-lfpos.
          ENDIF.
          PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                       mseg-xauto.
          PERFORM bestellung_pruefen USING mseg-ebeln
                                           mseg-ebelp
                                           mseg-lfbja
                                           mseg-lfbnr
                                           mseg-lfpos
                                           mseg-shkzg
                                           mseg-werks
                                          vm07m-kzwes
                                           space
                                          i_not_valid.      "614370
          READ TABLE xebefu INDEX 1.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH 'XEBEFU' eins.
          ENDIF.
          CHECK xebefu-loekz IS INITIAL.
          PERFORM segmentdaten_ek_setzen.
          IF vm07m-xstor = zwei.
            dm07m-bwtor = mseg-bwtar.
          ENDIF.
*-      when l now included in space -> no dead coding            381812
*       WHEN l.                                                   284260
*         PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart 381812
*                                                      mseg-xauto.381812
*         kzbew = rm07m-kzbew.                                    381812
*         CLEAR rm07m-kzbew.                                      381812
*         PERFORM fusszeile_bew_pruefen.                          381812
*         IF dm07m-maktx IS INITIAL.                              381812
*           PERFORM kurztext_lesen(sapfm07m) USING mseg-matnr.    381812
*           dm07m-maktx = mbefu-maktx.                            381812
*         ENDIF.                                                  381812
*         rm07m-kzbew = kzbew.                                    381812
      ENDCASE.
* Mengenkorrelation bei Leergut
      IF dm07m-uptyp CA c_mekor.
* vsa_lg anfang
* if its a reversal -> take over xauto from original doc.
        IF vm07m-xstor NE zwei.
          mseg-xauto = l.
        ENDIF.
* vsa_lg ende
        PERFORM leerg_abw_pruefen(sapfm07m).
        dm07m-mekor = x.
*        IF sl_kopf-ebeln = fuss-ebeln AND sl_kopf-ebelp = fuss-uebpo.
*          mseg-urzei = sl_kopf-zeile.
* vsa_lg anfang
*          IF SL_KOPF-WERTMAESSIG = X.
*            CLEAR MSEG-XAUTO.
*          ENDIF.
* vsa_lg ende
*        ENDIF.
        PERFORM leerg_ermittle_urzei USING mseg-ebeln
                                           dm07m-uebpo
                                           mseg-lfbnr
                                  CHANGING mseg-urzei.
      ENDIF.
      IF dm07m-upvor NE space.
        PERFORM kopfzeile_merken USING mseg-lfbnr
                                       mseg-ebeln
                                       mseg-ebelp
                                       mseg-zeile
                                       0.
* vsa_lg anfang
* if mseg-matnr is a full product which is managed on a value-only basis
* the tied empties must be posted to untied stock
*        PERFORM VOLLGUT_WERTMAESSIG_PRUEFEN USING MSEG-MATNR
*                                                  MSEG-MATBF
*                                                  MSEG-MENGU
*                                                  MSEG-WERTU
*                                         CHANGING SL_KOPF-WERTMAESSIG.
* vsa_lg ende
      ENDIF.
      IF mseg-matnr IS INITIAL.
        CLEAR: dm07m-xlort, dm07m-xchar.
      ELSE.
*##ngr220-anf
*       perform kurztext_lesen(sapfm07m) using mseg-matnr.
        PERFORM text_profil_lesen(sapfm07m) USING mseg-matnr mseg-werks.
*##ngr220-end
        dm07m-maktx = mbefu-maktx.
        IF NOT t156-kzwes = s.
          dm07m-xlort = x.
          dm07m-xchar = x.
        ENDIF.
      ENDIF.
      IF vm07m-xstor = drei.
        PERFORM belegdaten_umbuchung.
      ENDIF.
*##ngr220-anf
* Falls es zu dem Artikel eine Leergut-Stückliste gibt, ermitteln der
* Komponenten, abgleichen mit den nachfolgenden Belegspositionen und
* evtl. Verweise in FUSS aufnehmen (UPTYP, URZEI, MEKOR)
* die Lösung ist fehleranfällig; zu 4.0 sollte der Verweis auf die
* Kopfposition (URZEI) und der Unterpositionstyp (UPTYP) in MSEG aufge-
* nommen werden, damit kein Abgleich mit der aktuellen Stückliste lt.
* Stammdaten erforderlich ist
      IF NOT mbefu-mlgut IS INITIAL.
        CLEAR anz_comp.
        PERFORM leerg_stueli_lesen USING mseg-matnr mseg-erfme.
        IF sy-subrc IS INITIAL.
          dm07m-upvor = uptyp_lg.
          kopf_zeile = mseg-zeile.
          kopf_ebelp = mseg-ebelp.                            "559567
* vsa_lg anfang
*          PERFORM VOLLGUT_WERTMAESSIG_PRUEFEN USING MSEG-MATNR
*                                                    MSEG-MATBF
*                                                    MSEG-MENGU
*                                                    MSEG-WERTU
*                                           CHANGING KOPF_ZEILE_WERTM.
* vsa_lg ende
          DESCRIBE TABLE slcomp LINES anz_comp.
          vm07m-line_count = anz_comp.                        "544663
        ENDIF.
      ELSE.
        LOOP AT slcomp WHERE idnrk = mseg-matnr.
          dm07m-uptyp = uptyp_lg.
          IF mseg-urzei IS INITIAL.
            mseg-urzei  = kopf_zeile.
          ENDIF.
          IF dm07m-uebpo IS INITIAL.                          "559567
            dm07m-uebpo = kopf_ebelp.                         "559567
          ENDIF.                                              "559567
          dm07m-mekor = x.
* vsa_lg anfang
*          IF KOPF_ZEILE_WERTM IS INITIAL.
* vsa_lg correction
* if its a reversal -> take over xauto from original doc.
          IF vm07m-xstor NE zwei.
            mseg-xauto = l.
          ENDIF.
* vsa_lg correction
*          ELSE.
*            CLEAR MSEG-XAUTO.
*          ENDIF.
* vsa_lg ende
          PERFORM leerg_abw_pruefen(sapfm07m).
          DELETE slcomp.
          DESCRIBE TABLE slcomp LINES anz_comp.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL AND anz_comp > 0.
          REFRESH slcomp.
        ENDIF.
      ENDIF.
*##ngr220-end
*##ngr-saanf
      vm07m-attyp = mbefu-attyp.
      IF vm07m-attyp = attyp-sam.
        dm07m-upvor = uptyp_var.
        PERFORM get_line_count_old_doc CHANGING vm07m-line_count.
*       note 544663
      ELSEIF mbefu-attyp = attyp-var AND
             NOT mseg-urzei = mseg-zeile AND
             mseg-xauto IS INITIAL.
        dm07m-uptyp = uptyp_var.
      ELSEIF vm07m-attyp = attyp-vks OR vm07m-attyp = attyp-lot OR
             vm07m-attyp = attyp-dis.                           "544663
        PERFORM get_line_count_old_doc CHANGING vm07m-line_count.
*       note 544663
      ENDIF.
*##ngr-saend
      kzbew = rm07m-kzbew.
      rm07m-kzbew = mseg-kzbew.
      PERFORM fuss_ergaenzen.
      PERFORM set_fuss_umvkw_transfer.                          " 429136
      rm07m-kzbew = kzbew.
      CLEAR fuss-xprue.
      fuss-xselp = fcausw-xselp.
      fuss-xsels = fcausw-xselp.
      IF NOT fcausw-xlist IS INITIAL.
        fuss-xselk = xsele_ombi.
        IF mseg-erfmg IS INITIAL AND mseg-vkwrt IS INITIAL
                                 AND NOT t158-kzbew = o.
          CLEAR fuss-xselk.
        ENDIF.
      ENDIF.
      IF NOT fuss-kzbew = t158-kzbew AND fuss-pstyp = drei.
        fuss-konto = mseg-sakto.
        CLEAR fuss-xselk.
      ENDIF.
      PERFORM fuss_nach_yfuss.
    ELSE.
      IF mseg-kzbew = b.
        PERFORM bestellung_pruefen USING mseg-ebeln
                                         mseg-ebelp
                                         mseg-lfbja
                                         mseg-lfbnr
                                         mseg-lfpos
                                              space
                                              space
                                              space
                                              space
                                         i_not_valid.      "614370
        PERFORM segmentdaten_ek_setzen.
        IF NOT mseg-kzvbr IS INITIAL.
          dm07m-knttp = stern.
        ENDIF.
      ENDIF.
      PERFORM bildauswahl_pruefen(sapfm07m) USING mseg-bwart
                                                  mseg-sobkz.
      PERFORM bewegungstext_lesen(sapfm07m) USING mseg-bwart
                                                  mseg-sobkz
                                                  mseg-kzbew
                                                  mseg-kzzug
                                                  mseg-kzvbr
                                                 dm07m-btext.
      PERFORM grund_pruefen.
      IF NOT mseg-matnr IS INITIAL.
        DATA kunnr LIKE mseg-kunnr.
        DATA kdauf LIKE mseg-kdauf.
        DATA kdpos LIKE mseg-kdpos.
        DATA plpla LIKE mseg-plpla.
        DATA pspnr LIKE mseg-ps_psp_pnr.
ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_03 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_04 SPOTS ES_SAPMM07M.
        IF mseg-sobkz = e AND mseg-mat_kdauf IS INITIAL.
          mseg-mat_kdauf = mseg-kdauf.
          mseg-mat_kdpos = mseg-kdpos.
        ELSEIF mseg-sobkz = q AND mseg-mat_pspnr IS INITIAL.
          mseg-mat_pspnr = mseg-ps_psp_pnr.
        ENDIF.                         " wg. Aufwärtskompatibilitaet
ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_05 SPOTS ES_SAPMM07M.
        PERFORM sonderbestand_pruefen(sapfm07m) USING mseg-sobkz
                                                      mseg-lifnr
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
                                                      LS_ISU_SONDERBESTAND_PRUEFEN. "IS2ERP
ENHANCEMENT-POINT MM07MFB1_BELEG_ERGAENZEN_06 SPOTS ES_SAPMM07M.
*       The first line of the receiving part of a cross-system movement
*       refers to a nonexisting plant   > read without plant
*       to get at least the text.
        DATA: l_werks_save TYPE werks_d.                         "sdp462
        l_werks_save = mseg-werks.                               "sdp462
        IF cl_mmim_cross_system=>plant_in_own_system( mseg-werks )"sdp46
             = abap_false.                                       "sdp462
          CLEAR mseg-werks.                                      "sdp462
        ENDIF.                                                   "sdp462
        PERFORM text_profil_lesen(sapfm07m) USING mseg-matnr
                                                  mseg-werks.
        mseg-werks = l_werks_save.                               "sdp462
        dm07m-mhdat = mseg-vfdat.
        dm07m-hsdat_input = mseg-hsdat." Feld neu zu 4.5
        dm07m-vfdat_input = mseg-vfdat." Feld neu zu 4.5
        dm07m-mhdrz = mbefu-mhdrz.
        dm07m-mhdhb = mbefu-mhdhb.
        dm07m-maktx = mbefu-maktx.
        dm07m-sernp = mbefu-sernp.
ENHANCEMENT-POINT BELEG_ERGAENZEN_05 SPOTS ES_SAPMM07M.
      ENDIF.
      IF NOT mseg-lgort IS INITIAL. dm07m-xlort = x. ENDIF.
      IF NOT mseg-charg IS INITIAL. dm07m-xchar = x. ENDIF.
      dm07m-zeild = mseg-zeile.
      vm07m-zeilv = mseg-zeile.
      dm07m-vzbew = minus.
      IF mseg-shkzg = s.
        dm07m-vzbew = plus.
      ENDIF.
      dm07m-konto = mseg-sakto.
      MOVE-CORRESPONDING dm07m TO ydm07m.
      MOVE-CORRESPONDING vm07m TO yvm07m.
      MOVE-CORRESPONDING mseg TO ymseg.
      APPEND ydm07m.
      APPEND yvm07m.
      APPEND ymseg.
      m_zeile = m_zeile + 1.
    ENDIF.
  ENDLOOP.

* in display mode save the number and year of this MM       "n555246
* document in case the user is a tax auditor                "n555246
  IF t158-trtyp NE h.                                       "n555246
*   start this function module with log function            "n555246
    CALL FUNCTION          'MB_CHECK_USER_PG_DATE_PLANT'    "n555246
      EXPORTING                                             "n555246
        i_user             = sy-uname                       "n555246
        i_program          = l_f_repid                      "n555246
        i_write_log        = 'X'                            "n555246
        i_mblnr            = xmkpf-mblnr                    "n555246
        i_mjahr            = xmkpf-mjahr                    "n555246
      EXCEPTIONS                                            "n555246
        OTHERS             = 3.                             "n555246
                                                            "n555246
    IF  sy-subrc <> 0.                                      "n555246
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno     "n555246
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.     "n555246
    ENDIF.                                                  "n555246
  ENDIF.                                                    "n555246
  IF NOT lt_reservation_enqueue[] IS INITIAL.               "205978
    PERFORM reservation_enqueue USING lt_reservation_enqueue[]."205978
  ENDIF.                                                    "205978
  FREE: xebefu, xekbnk, xmdvw, xebefu_cr, xekbnk_cr.
  IF t158-trtyp = h.
    READ TABLE yfuss INDEX 1.
    IF NOT sy-subrc IS INITIAL.
      IF storno IS INITIAL.
        MESSAGE e067 WITH rm07m-mblnr.
      ELSE.
        MESSAGE e064 WITH rm07m-mblnr.
      ENDIF.
    ENDIF.
    IF storno IS INITIAL.
      MESSAGE e067 WITH rm07m-mblnr.
    ENDIF.
  ENDIF.
  PERFORM fuss_aus_yfuss.
  CHECK t158-trtyp = h.
  FREE xmkpf.
ENHANCEMENT-SECTION     BELEG_ERGAENZEN_06 SPOTS ES_SAPMM07M.
  FREE xmseg.
END-ENHANCEMENT-SECTION.
  IF NOT index_a IS INITIAL.
    index_a = index_l - index_a.
    MESSAGE s020 WITH index_a index_l.
  ENDIF.
ENHANCEMENT-POINT BELEG_ERGAENZEN_07 SPOTS ES_SAPMM07M.
  CLEAR index_l.
  IF xaktiv IS INITIAL.
    xaktiv = x.
  ENDIF.
  xconfirm = x.

ENHANCEMENT-POINT BELEG_ERGAENZEN_08 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT BELEG_ERGAENZEN_09 SPOTS ES_SAPMM07M.


ENDFORM.