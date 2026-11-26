*---------------------------------------------------------------------*
*       FORM SEGMENT_HINZUFUEGEN                                      *
*---------------------------------------------------------------------*
*       Das Segment mit den verprobten Daten wird hinzugefuegt.       *
*---------------------------------------------------------------------*

* MAA2 : error M7 330 when creating an outbound delivery for a "n1626562
* return delivery of a MAA GR item with amount based           "n1626562
* distribution                                                 "n1626562

* error during processing of serial numbers                 "n584955

FORM segment_hinzufuegen.

* Outsourced Manufacturing                                     "1624277
  DATA: ls_dm07m_tmp TYPE dm07m,                               "1624277
        lv_om_active TYPE xfeld.                               "1624277

*-----------------------------------------------------------"MAA2
* define local working areas
  DATA : lv_flag_restore     TYPE  abap_bool.

* for saving the input tables for the value calculation
  DATA : lt_save_yekbnk      TYPE  me_ekbnk,
         lt_save_yekbnk_cr   TYPE  cl_mmim_maa_2=>tt_yekbnk_cr,
         lt_save_yebefu_cr   TYPE  ebefu_cr_t.
*-----------------------------------------------------------"MAA2

  CHECK xpaus IS INITIAL.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_11 SPOTS ES_SAPMM07M.

* trigger optional serial number handling (aktyp = k) and display of
* serial numbers (MB03 -> aktyp = a / MB02 -> aktyp = V).
  IF aktyp <> h AND xmbwl IS INITIAL.                       "note388608
    IF t158-trtyp = h.                                      "note388608
      PERFORM serialnummern_pruefen.                        "note388608
    ELSE.                                                   "note388608
      IF NOT dm07m-sernp IS INITIAL.                        "note388608
        CHECK ccode EQ ccod-nser.                           "note388608
        PERFORM serialnummern_pflegen.                      "note388608
      ENDIF.                                                "note388608
    ENDIF.                                                  "note388608
  ENDIF.                                                    "note388608

  CHECK aktyp = h.

* Get new line id. If called from MB_CREATE, the LINE_ID may come
* from outside. Therefore, fill only if empty. This is handled by
* the method.
  CALL METHOD cl_mmim_line_id_manager=>line_id_get
    CHANGING
      c_line_id = mseg-line_id.
* Kontrolle, ob 'Mischlieferung' (= HU-pflichtige und Nicht-HU-pflicht.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_01 SPOTS ES_SAPMM07M.
* Positionen in einem Beleg) erlaubt ist.
  DATA: wa_ymseg LIKE ymseg.                                "484376
  IF NOT dm07m-mekor     IS INITIAL AND "tied empty             "484376
          mseg-parent_id IS INITIAL AND                     "484376
     NOT  mseg-ebeln     IS INITIAL AND "refering p.o.          "484376
     NOT  mseg-ebelp     IS INITIAL.                        "484376
*   within movements without reference to a p.o. parent_id got filled
*   in upos_stueli (MM07MFU0)                                   "484376

* Note 805560 - Begin

*     READ TABLE ymseg INTO wa_ymseg WITH KEY ebeln = mseg-ebeln"484376
*                                         ebelp = dm07m-uebpo.  "484376
* relating the correct full product to the empties in case of a reversal
* movement 102 w.r.t po
    DATA: item_position LIKE mseg-urzei.
    IF NOT mseg-lfbnr IS INITIAL AND NOT mseg-lfbja IS INITIAL.
      PERFORM read_item_position USING mseg-lfbja
                                       mseg-lfbnr
                                       mseg-lfpos
                                       t158-trtyp
                                 CHANGING item_position.

* get the correct parent line from ymseg corresponding to the tied empty
* in the mseg
      READ TABLE ymseg INTO wa_ymseg WITH KEY ebeln = mseg-ebeln
                                              ebelp = dm07m-uebpo
                                              lfbnr = mseg-lfbnr
                                              lfpos = item_position.


    ELSE.
      READ TABLE ymseg INTO wa_ymseg WITH KEY ebeln =  mseg-ebeln
                                              ebelp = dm07m-uebpo
                                              urzei = mseg-urzei. "1386553
    ENDIF.

*   setting the line depth of the tied empty - always one more than the
*   full product
    mseg-line_depth = wa_ymseg-line_depth + 1.

* Note 805560 - End

*   get full product of the tied empty to set parent_id         "484376
    mseg-parent_id = wa_ymseg-line_id.                      "484376

    FIELD-SYMBOLS <wa_yvm07m> TYPE vm07m.                   "544663
    READ TABLE yvm07m ASSIGNING <wa_yvm07m>                 "544663
      WITH KEY zeilv = wa_ymseg-zeile.                      "544663
    ADD 1 TO <wa_yvm07m>-line_count.                        "544663
*   identified as a child of this full product                  "544663

  ENDIF.                                                    "484376

* begin Outsourced Manufacturing EhP 4
  IF gv_mm_om1_sfws_sc_active = abap_true.
    IF mseg-ebeln IS NOT INITIAL AND mseg-sobkz = o.
      PERFORM sc_components_check.
    ENDIF.
  ENDIF.
* end Outsourced Manufacturing EhP 4

  PERFORM sd_positions_kontrolle.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_10 SPOTS ES_SAPMM07M.
  DATA zeile_old LIKE mseg-zeile. zeile_old = mseg-zeile.
  IF mseg-kzbew = o.
    mseg-zeile = o_zeile + 1.
  ELSE.
    mseg-zeile = m_zeile + 1.
  ENDIF.
  IF NOT dm07m-kzuml IS INITIAL AND NOT dm07m-xowst IS INITIAL
     AND mseg-xobew IS INITIAL                                      "kaz
     AND mseg-bwtar = mseg-umbar AND mseg-matnr = mseg-ummat
     AND vm07m-bwkey = dm07m-umbwk AND mseg-kzbws = dm07m-umkzbws
     AND mseg-mat_kdauf = mseg-kdauf AND mseg-mat_kdpos = mseg-kdpos
     AND mseg-mat_pspnr = mseg-ps_psp_pnr
     AND ( mseg-sobkz = mseg-umsok OR
       mseg-sobkz IS INITIAL AND ( mseg-umsok = o OR mseg-umsok = v OR
                                   mseg-umsok = w ) OR
       mseg-umsok IS INITIAL AND ( mseg-sobkz = o OR mseg-sobkz = v OR
                                   mseg-sobkz = w ) )
     AND mseg-gsber = dm07m-umgsb AND mseg-prctr = dm07m-umprc
     AND vm07m-xhead IS INITIAL AND dm07m-umxhead IS INITIAL.
    LOOP AT yekbnk WHERE ebeln = mseg-ebeln
                     AND ebelp = mseg-ebelp.
      EXIT.
    ENDLOOP.
ENHANCEMENT-SECTION     SEGMENT_HINZUFUEGEN_02 SPOTS ES_SAPMM07M.
*begin of retrofit SDP Bw 20050208
*    IF NOT sy-subrc IS INITIAL.
    IF NOT sy-subrc IS INITIAL AND
       cl_mmim_cross_system=>kzdir_get( mseg-bwart ) <> r.
*end of retrofit SDP Bw 20050208
      CLEAR mseg-bustw.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ENDIF.
  IF NOT xmbwl IS INITIAL AND NOT tcurm-mbequ IS INITIAL AND
        mbval      IS INITIAL AND
        xlock_allp IS INITIAL AND
     NOT mseg-bustw IS INITIAL AND NOT mseg-bustw = bustw_we06 AND
     ( NOT mseg-wertu IS INITIAL OR
     ( NOT dm07m-kzuml IS INITIAL AND NOT dm07m-umwer IS INITIAL ) ).
*   REFRESH: prefetch04, prefetch21, prefetch22.                    "kaz
    REFRESH: prefetch04, prefetch21, prefetch22, prefetch29.        "kaz
    DATA: lt_dummy LIKE enqueues_exception_s OCCURS 0.      "396879
    PERFORM buchen_mat_prefetch
             TABLES  lt_dummy                               "396879
             USING dm07m
                   vm07m
                   mseg.
    CALL FUNCTION 'MB_PREREAD_MATERIAL_VALUES'
      EXPORTING
        mbequ = tcurm-mbequ
        xonly = eins
      TABLES
        pre04 = prefetch04
        pre21 = prefetch21
*       pre22 = prefetch22.                                   "kaz
        pre22 = prefetch22                                    "kaz
        pre29 = prefetch29.                                   "kaz
  ENDIF.
  DATA: werte_rechnen. CLEAR werte_rechnen.


ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_09 SPOTS ES_SAPMM07M.
****** Localization Brazil
  DATA j_1b_tf_gi_rel(1) TYPE c.
  PERFORM j_1b_im_tf_gi_processing USING    brazil
                                            mseg-bwart
                                   CHANGING vm07m
                                            mseg
                                            j_1b_tf_gi_rel.

ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_03 SPOTS ES_SAPMM07M.
* Same behaviour like MB_CREATE_GOODS_MOVEMENT:                 "563950
* KZVBR has to be equal v in case of mvt. 333, XKOKO = X and    "563950
* external G/L account                                          "563950
  IF ( ( NOT mseg-kzbew = b AND im_process = l )            "563950
    OR NOT t156-xkoko IS INITIAL )                          "563950
    AND t156-xkoko = x                                      "597873
    AND vm07m-xstor IS INITIAL.                             "563950
    IF ( NOT mseg-kostl IS INITIAL OR                       "563950
      NOT mseg-ps_psp_pnr IS INITIAL OR                     "563950
      NOT mseg-aufnr IS INITIAL OR                          "563950
      NOT mseg-paobjnr IS INITIAL ) AND                     "563950
      mseg-kzvbr IS INITIAL AND                             "563950
      mseg-sobkz NE e AND mseg-sobkz NE q .                 "563950
      mseg-kzvbr = v.                                       "563950
    ENDIF.                                                  "563950
  ENDIF.                                                    "563950

* save NBM-Code from PO into the internal table NF_DIS
  PERFORM j_1b_tx_nbm_code_save.                            "886530

  IF ( ( NOT vm07m-pstyp = drei OR NOT mseg-kzbew = b ) AND
     NOT mseg-ebeln = auto_best AND
     ( xmbwl IS INITIAL OR NOT xsimu IS INITIAL ) AND
     tcurm-mbequ IS INITIAL ) OR
   (  ( NOT brazil IS INITIAL AND NOT vm07m-j_1bnfrel IS INITIAL )
        AND  ( xmbwl IS INITIAL OR NOT xsimu IS INITIAL ) )
****Localization Brazil -----TF with TO and NF*****
    OR ( NOT j_1b_tf_gi_rel IS INITIAL ).
*
    werte_rechnen = x.
    PERFORM j_1b_tx_calculate_init.

* MAA2 Begin
    IF NOT dm07m-xhistma   IS INITIAL    AND  " this is a MAA item
       NOT xdeliv          =  'X'        AND  " create no delivery "n1626562
           mseg-bustw      =  bustw_we06.    " this GR is valuated
*     save the origininal tables with the values
      MOVE : yekbnk[]          TO  lt_save_yekbnk[],
             yekbnk_cr[]       TO  lt_save_yekbnk_cr[],
             yebefu_cr[]       TO  lt_save_yebefu_cr[],
             abap_true         TO  lv_flag_restore.

*     select the matching lines and copy the MAA quantities and values
      CALL METHOD go_mmim_maa_2->copy_maa_data_for_calc
        EXPORTING
          is_mseg          = mseg
          it_yekbnk        = lt_save_yekbnk
          it_yekbnk_cr     = lt_save_yekbnk_cr
          it_yebefu_cr     = lt_save_yebefu_cr
        CHANGING
          cs_dm07m         = dm07m
          cs_vm07m         = vm07m
          ct_yekbnk_maa    = yekbnk[]
          ct_yekbnk_cr_maa = yekbnk_cr[]
          ct_yebefu_cr_maa = yebefu_cr[]
          cv_flag_error    = gv_flag_error
          ct_message_log   = gt_message_log.

      IF gv_flag_error = abap_true.
        PERFORM              send_maa_error_message.
      ENDIF.
    ENDIF.
* MAA2 End

* begin -------------------------------------------------------"n1626562
    IF NOT dm07m-xhistma IS INITIAL AND  " MAA item
           xdeliv        = 'X'      AND  " create outbound delivery
           dm07m-mulko   = gc_mulko_3.   " amount based distribution
*     copy the ordered, received, and invoiced quantities on
*     GR item level into the float format, because they are needed
*     in MB_CALCULATE_VALUES
      dm07m-bsmng_abd        = dm07m-bsmng / 1000.
      dm07m-bpbmg_abd        = dm07m-bpbmg / 1000.
      dm07m-wwmng_abd        = dm07m-wwmng / 1000.
      dm07m-bpwwm_abd        = dm07m-bpwwm / 1000.
      dm07m-remng_abd        = dm07m-remng / 1000.
      dm07m-bprem_abd        = dm07m-bprem / 1000.
    ENDIF.
* end ---------------------------------------------------------"n1626562

ENHANCEMENT-SECTION     SEGMENT_HINZUFUEGEN_07 SPOTS ES_SAPMM07M.

    CALL FUNCTION 'MB_CALCULATE_VALUES'
      EXPORTING
        dm07m      = dm07m
        vm07m      = vm07m
        mkpf       = mkpf
        mseg       = mseg
        glvor      = rw_vorgang
        kurst      = t003-kurst
        brazil     = brazil
        xmbwl      = xmbwl
        xcheck     = x
      IMPORTING
        dm07m      = dm07m
        vm07m      = vm07m
        mseg       = mseg
        x_fwdif    = fwdif
        x_shfwdif  = shfwdif
      TABLES
        xekbn      = xekbn
        xekbv      = xekbv
        xekws      = xekws
        xekwv      = xekwv
        xeklb      = xeklb
        xekls      = xekls
        xfaws      = xfaws
        xfawv      = xfawv
        xebew      = xebew
        xmbew      = xmbew
        xqbew      = xqbew
        xobew      = xobew                                     "kaz
        x156w      = x156w
        xzcxcb     = xzcxcb
        xzcxcm     = xzcxcm
        yekbnk     = yekbnk
        yekbnk_cr  = yekbnk_cr
        yebefu_cr  = yebefu_cr
        yfbefu_cr  = yfbefu_cr
        zekbe_cr   = zekbe_cr
        zaufbe_cr  = zaufbe_cr
        xekbnk_kdm = yekbnk_kdm.               "N1027899 + 1520698
END-ENHANCEMENT-SECTION.

    CALL FUNCTION 'MB_SIMULATE_VALUES'
      EXPORTING
        dm07m  = dm07m
        vm07m  = vm07m
        mseg   = mseg
        mbequ  = tcurm-mbequ
        xmbwl  = xmbwl
        xmigo  = xmigo                                      "595089
      IMPORTING
        dm07m  = dm07m
        vkwrt  = mseg-vkwrt                                 " 116725
        vkwra  = mseg-vkwra                                 " 116725
      TABLES
        x156w  = x156w
        xmbew  = xmbew
        xebew  = xebew
        xqbew  = xqbew
        xobew  = xobew                                        "kaz
        xzcxcb = xzcxcb
        xzcxcm = xzcxcm.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_04 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_05 SPOTS ES_SAPMM07M.

  ENDIF.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_12 SPOTS ES_SAPMM07M.
  IF xmigo IS INITIAL.                                      "647353
    CLEAR vm07m-global_counter.                             "647353
  ENDIF.                                                    "647353

* Begin of Note 1624277                                       "v_1624277
* Outsoruced Manufacturing via deliveries & HU/WM
  CLEAR lv_om_active.

  IF gv_mm_om1_sfws_sc_active EQ 'X' AND dm07m-co_order EQ 'X'
    AND mseg-kzbew = L AND mseg-aufnr IS NOT INITIAL
    AND mseg-line_id IS NOT INITIAL AND mseg-parent_id IS NOT INITIAL
    AND vm07m-xstor NE '2'.

    lv_om_active = 'X'.
    ls_dm07m_tmp = dm07m.
    dm07m-imseg_original = mseg-line_id. "original pos in delivery
  ENDIF.
* End of Note 1624277                                         "^_1624277

  CALL FUNCTION 'LVS_COMMUNICATION_MB'
    EXPORTING
      i_mseg       = mseg
      i_xmbwl      = xmbwl
      i_dm07m      = dm07m
      i_vm07m      = vm07m
      i_rm07m      = rm07m
      i_st156s     = s156s
      i_mkpf       = mkpf
      i_xdeliv     = xdeliv
      i_qss_aufruf = qss_aufruf
      i_im_process = im_process
      i_t158       = t158
    IMPORTING
      e_mseg       = mseg
      e_dm07m      = dm07m
      e_vm07m      = vm07m
      e_tafkz      = lvs_tafkz
      e_mailk      = lvs_mailk
      e_mkpf       = mkpf.

* Begin of Note 1624277                                       "v_1624277
  IF lv_om_active = 'X'.
    CLEAR lv_om_active.
    dm07m-imseg_original = ls_dm07m_tmp-imseg_original.
  ENDIF.
* End of Note 1624277                                         "^_1624277
*                                           start of note 1075444
* For Delivery creation check existing deliveries for reservation
  DATA: lt_vrsli LIKE TABLE OF vrsli,
        ls_vrsli LIKE vrsli,
        lv_rfmng LIKE vrsli-rfmng,
        lv_offen LIKE rbefu-offen,
        lv_rsnum(10) TYPE c,
        lv_shkzg LIKE t156-shkzg.
* Decentral warehouse only (HU case in FM07MEM0_MENGE_PRUEFEN)
  IF mkpf-bfwms = 1 AND NOT mseg-rsnum IS INITIAL
                AND mseg-shkzg = xmres-rshkz.
    SELECT * FROM vrsli INTO TABLE lt_vrsli
      WHERE rsnum = mseg-rsnum
        AND rspos = mseg-rspos.
    LOOP AT lt_vrsli INTO ls_vrsli.
      IF NOT ls_vrsli-bwart EQ mseg-bwart.
        SELECT SINGLE shkzg INTO lv_shkzg FROM t156
          WHERE bwart = ls_vrsli-bwart.
        IF NOT lv_shkzg EQ mseg-shkzg.
          SUBTRACT ls_vrsli-rfmng FROM lv_rfmng.
        ELSE.
          ADD ls_vrsli-rfmng TO lv_rfmng.
        ENDIF.
      ELSE.
        ADD ls_vrsli-rfmng TO lv_rfmng.
      ENDIF.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      lv_offen = xmres-bdmng - xmres-enmng - lv_rfmng.
      IF lv_offen LT mseg-menge.
        MOVE mseg-rsnum TO lv_rsnum.
        SHIFT lv_rsnum LEFT DELETING LEADING '0'.
        PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '466'
          lv_rsnum lv_rfmng mseg-meins ls_vrsli-delnr.
      ENDIF.
    ENDIF.
  ENDIF.
*                                             end of note 1075444
* Serial number handling (for MBxx transactions only) has moved to
* SEGMENT_HINZUFUEGEN, because it must not be performed before it is
* sure that the current item is error free and will be adopted
* It has moved here within the form to make sure that the stock tables
* will not be updated if the input of the serial numbers is cancelled
* (notes 388608, 437805)
  IF xmbwl IS INITIAL.                                      "note437805
    IF t158-trtyp = h.                                      "note437805
      PERFORM serialnummern_pruefen.                        "note437805
    ELSE.                                                   "note437805
      IF NOT dm07m-sernp IS INITIAL.                        "note437805
        CHECK ccode EQ ccod-nser.                           "note437805
        PERFORM serialnummern_pflegen.                      "note437805
      ENDIF.                                                "note437805
    ENDIF.                                                  "note437805
  ENDIF.                                                    "note437805

  IF NOT werte_rechnen IS INITIAL.
    PERFORM anlagenwert_pruefen.
  ENDIF.
  IF NOT mseg-xblvs IS INITIAL OR
     NOT dm07m-umxbl IS INITIAL.
    CALL FUNCTION 'L_IM_RELEASE_BUFFER'
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.
  PERFORM qpl1_update_memory.
  CALL CUSTOMER-FUNCTION '001'
       EXPORTING
            i_mseg  = mseg
            i_vm07m = vm07m
            i_dm07m = dm07m
            i_mkpf  = mkpf
       IMPORTING
            e_sgtxt = mseg-sgtxt.

  IF NOT if_mb_check_line_badi IS INITIAL.
    CALL METHOD if_mb_check_line_badi->check_line
      EXPORTING
        is_mkpf  = mkpf
        is_mseg  = mseg
        is_dm07m = dm07m
        is_vm07m = vm07m.
  ENDIF.

* begin 307676
  LOOP AT xxiseg WHERE ibpoi = vm07m-ibpoi.
* Sperren des Inventurbelegs
    CALL FUNCTION 'ENQUEUE_EMIKPF'
      EXPORTING
        iblnr          = xxiseg-iblnr
        gjahr          = xxiseg-gjahr
      EXCEPTIONS
        foreign_lock   = 2
        system_failure = 3.
    CASE sy-subrc.
      WHEN 2.
        MESSAGE e113 WITH sy-msgv1
                          xxiseg-iblnr
                          xxiseg-gjahr.
      WHEN 3.
        MESSAGE e110.
    ENDCASE.
  ENDLOOP.
  IF NOT dm07m-kzuml IS INITIAL.
    LOOP AT xxiseg WHERE ibpoi = dm07m-umibpoi.
* Sperren des Inventurbelegs
      CALL FUNCTION 'ENQUEUE_EMIKPF'
        EXPORTING
          iblnr          = xxiseg-iblnr
          gjahr          = xxiseg-gjahr
        EXCEPTIONS
          foreign_lock   = 2
          system_failure = 3.
      CASE sy-subrc.
        WHEN 2.
          MESSAGE e113 WITH sy-msgv1
                            xxiseg-iblnr
                            xxiseg-gjahr.
        WHEN 3.
          MESSAGE e110.
      ENDCASE.
    ENDLOOP.
  ENDIF.
* end 307676

  IF NOT werte_rechnen IS INITIAL.
    CALL FUNCTION 'MB_UPDATE_VALUE_ENQUEUE_TABLE'
      EXPORTING
        dm07m     = dm07m
        vm07m     = vm07m
        mkpf      = mkpf
        mseg      = mseg
        aktyp     = aktyp
      IMPORTING
        upd_um03b = upd_um03b
        dm07m     = dm07m
      TABLES
        xekbn     = xekbn
        xekbv     = xekbv
        xekws     = xekws
        xekwv     = xekwv
        xeklb     = xeklb
        xekls     = xekls
        xfaws     = xfaws
        xfawv     = xfawv
        x156w     = x156w
        xmbew     = xmbew
        xzcxcb    = xzcxcb
        xzcxcm    = xzcxcm
        yekbnk    = yekbnk
        yekbnk_cr = yekbnk_cr
        yebefu_cr = yebefu_cr
        yfbefu_cr = yfbefu_cr
        xebew     = xebew
*       xqbew     = xqbew.                                    "kaz
        xqbew     = xqbew                                     "kaz
        xobew     = xobew.                                    "kaz

    IF  lv_flag_restore = abap_true.                        "MAA2
*     restore the original values into the tables after the "MAA2
*     value calculation of this MAA item                    "MAA2
      MOVE : lt_save_yekbnk[]          TO  yekbnk[],        "MAA2
             lt_save_yekbnk_cr[]       TO  yekbnk_cr[],     "MAA2
             lt_save_yebefu_cr[]       TO  yebefu_cr[].     "MAA2
    ENDIF.                                                  "MAA2
  ENDIF.

ENHANCEMENT-SECTION     SEGMENT_HINZUFUEGEN_08 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'MB_UPDATE_MATERIAL_ENQUEUE_TAB'
    EXPORTING
      budat  = mkpf-budat
      dm07m  = dm07m
      mseg   = mseg
      vm07m  = vm07m
      kzdch  = kzdch
    TABLES
      xekpo  = xekpo
      xekpk  = xekpk
      xekla  = xekla
      xfaup  = xfaup
      xmarc  = xmarc
      xmard  = xmard
      xmcha  = xmcha
      xmch1  = xmch1
      xmchb  = xmchb
      xmkol  = xmkol
      xmsku  = xmsku
      xmslb  = xmslb
      xmssl  = xmssl
      xmska  = xmska
      xmssa  = xmssa
      xmres  = xmres
      xmspr  = xmspr
      xmssq  = xmssq
      xxiseg = xxiseg            " PPF Rel. 4.6
      xmstb  = xmstb                                  "SIT
      xmste  = xmste                                  "SIT
      xmstq  = xmstq.                                 "SIT
END-ENHANCEMENT-SECTION.
*begin note 367783
  IF dm07m-kzuml = 'X'.
*only for stock transfers
    LOOP AT xmarc.
      IF ( xmarc-glgmg <> xmarc-glgmg_old ) AND
        tcurm-leerg_abw <> 'X'.
*field marc-glgmg can only be used in case of empties!
        MESSAGE a019(m7) WITH mseg-bwart.
      ENDIF.
    ENDLOOP.
  ENDIF.
*end note 367783
  IF auth04_wrk IS INITIAL AND auth04_bwa IS INITIAL
                           AND NOT auth04 IS INITIAL.
    auth04_bwa = mseg-bwart.
    auth04_wrk = mseg-werks.
    CLEAR rm07m-ldest.
  ENDIF.
  mseg-mjahr = mkpf-mjahr.
  vm07m-zeilv = mseg-zeile.
  dm07m-zeild = mseg-zeile.
  dm07m-urvermg = dm07m-urerfmg.
  dm07m-vmeng = mseg-menge.
  dm07m-vermg = mseg-erfmg.
  dm07m-vbpmg = mseg-bpmng.
  dm07m-vbsmg = mseg-bstmg.
  dm07m-vvkwr = mseg-vkwrt.
  dm07m-vexvk = mseg-exvkw.
  dm07m-vumvkw = dm07m-umvkw.
ENHANCEMENT-POINT EHP604_SEGMENT_HINZUFUEGEN_01 SPOTS ES_SAPMM07M .

* error during processing of serial numbers :               "n584955
* insert movement type group for serial number profile into "n584955
* internal working table YDM07M                             "n584955
  MOVE  s156s-snbwg          TO  dm07m-snbwg.               "n584955

  IF mseg-urzei IS INITIAL.
    mseg-urzei = mseg-zeile.
  ENDIF.
* vsa struct. article
  IF NOT dm07m-oruml IS INITIAL.
    PERFORM struc_article_pointer.
  ENDIF.

* MAA2 Begin
  IF NOT xmbwl IS INITIAL AND NOT fuss-xhistma IS INITIAL AND
    NOT xdeliv = 'X'.
*   look for MAA processing here not for MB* transactions
*   copy the relevant MAA data into the structures MSEG, DM07M,
*   and VM07M
    CALL METHOD go_mmim_maa_2->copy_maa_data_3
      EXPORTING
        is_fuss           = fuss
        is_xebefu         = xebefu
        it_xaccounting    = xaccounting[]
        it_xaccounting_cr = xaccounting_cr[]
      CHANGING
        cs_mseg           = mseg
        cs_dm07m          = dm07m
        cs_vm07m          = vm07m
        ct_message_log    = gt_message_log
        cv_flag_error     = gv_flag_error.

    IF gv_flag_error = abap_true.
      PERFORM              send_maa_error_message.
    ENDIF.

  ENDIF.
* MAA2 End

* vsa struct. article
  IF NOT mseg-kzbew = o.
    m_zeile = m_zeile + 1.
    ymseg = mseg.
    yvm07m = vm07m.
    ydm07m = dm07m.
    APPEND ymseg.
    APPEND yvm07m.
    APPEND ydm07m.
  ENDIF.
  IF ( mseg-urzei IS INITIAL OR mseg-zeile = mseg-urzei ) AND
     ( NOT t158-kzbew = o OR mseg-kzbew = o ).
    omseg = mseg.
    ovm07m = vm07m.
    odm07m = dm07m.
    IF mseg-kzbew = o.
      o_zeile = o_zeile + 1.
      APPEND omseg.
      APPEND ovm07m.
      APPEND odm07m.
    ENDIF.
  ELSE.
    CLEAR: omseg, ovm07m, odm07m.
  ENDIF.
ENHANCEMENT-POINT SEGMENT_HINZUFUEGEN_06 SPOTS ES_SAPMM07M.

ENDFORM.                    "segment_hinzufuegen