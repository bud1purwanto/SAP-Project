*eject
*---------------------------------------------------------------------*
*       FORM F-SEGMENTE_GENERIEREN                                    *
*---------------------------------------------------------------------*
*       Die Segmente des Buchhaltungsbelegs werden generiert.         *
*       Dabei werden zunächst die Belegzeilen zu einer Material-      *
*       bewegung erzeugt. Anschliessend werden die Belegzeilen        *
*       für die Bezugsnebenkosten erstellt.                           *
*       Entsprechend dem Wertestring ermittelt das Programm SAPLMBGB  *
*       die Buchungsbetraege und stellt sie in die Tabelle XZCXCM,    *
*       bzw. für Bezugsnebenkosten in die Tabelle XZCXCB.             *
*---------------------------------------------------------------------*

* MAA2 : error M7 330 when creating an outbound delivery for a "n1626562
* return delivery of a MAA GR item with amount based           "n1626562
* distribution                                                 "n1626562

FORM f-segmente_generieren
                    CHANGING cs_enhancement TYPE isc_f_segmente_generieren. "#EC *

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_11 SPOTS ES_SAPMM07M STATIC.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_12 SPOTS ES_SAPMM07M.

  DATA: c_kzuml LIKE dm07m-kzuml,                           "495236
        lv_append_done,                                     "N980402
        lv_memorise_index TYPE sytabix.                     "N980402

* MAA_DEV
  DATA : lv_flag_maa_set_shkzg         TYPE  abap_bool.     "MAA2
  DATA : lv_flag_restore               TYPE  abap_bool.

* for saving the input tables for the value calculation
  DATA : lt_save_yekbnk                TYPE  me_ekbnk,      "MAA2
         lt_save_yekbnk_cr             TYPE  cl_mmim_maa_2=>tt_yekbnk_cr, "MAA2
         lt_save_yebefu_cr             TYPE  ebefu_cr_t.    "MAA2

  DATA: ls_xekws     TYPE sekws,
        ls_xekbn     TYPE sekbn,
        ls_xekws_old         LIKE LINE OF xekws_old,        "n1391053
        ls_xekbn_old         LIKE LINE OF xekbn_old,        "n1391053
        ls_ekbz      TYPE ekbz,
        ls_xacc_dc   TYPE accounting,
        ls_ekbecr    TYPE cki_ekbecr.

  DATA: lf_maa_urzei TYPE maa_urzei.


  CALL FUNCTION 'J_1B_IM_TX_YMSEG'                        "note 870572
       TABLES                                             "note 870572
            i_ymseg = ymseg.                              "note 870572

  CLEAR: rm07m-summe_s,
         rm07m-summe_h,
         rm07m-saldo.
  CLEAR mtcom.
*----------------------------------------------------------------------*
* process all items of the MM document
*----------------------------------------------------------------------*

* MAA2 Begin
* if business function multi account assignment is active
  IF cl_ops_switch_check=>mm_sfws_maa( ) IS NOT INITIAL.
    go_mmim_maa_2->gv_rounding_diff_values_tabix = 1.
  ENDIF.
* MAA2 End

  LOOP AT zmseg.
ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_02 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_14 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     F-SEGMENTE_GENERIEREN_01 SPOTS ES_SAPMM07M.
    CHECK NOT zmseg-bustw IS INITIAL.
    READ TABLE zdm07m INDEX zmseg-zeile.
END-ENHANCEMENT-SECTION.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZDM07M' zmseg-zeile.
    ENDIF.

*   valuated GR postings for PO item with multi account     "n1465935
*   assignment which will update valuated special stocks    "n1465935
*   are not possible                                        "n1465935
*   incorrect message M7 447 when last item has MAA       "n1494883
    IF NOT zdm07m-xhistma IS INITIAL.                       "n1494883
                                                            "n1465935
*     the Posting string for values has to be "WE06" and    "n1465935
*     the flag Valuation of Special Stock has to be initial "n1465935
      IF NOT ( zmseg-bustw =  bustw_we06  AND               "n1465935
               zmseg-kzbws IS INITIAL ).                    "n1465935
*       GR for &1 &2 not possible due valuated special st.. "n1465935
        MESSAGE  e447        WITH  zmseg-ebeln zmseg-ebelp. "n1465935
      ENDIF.                                                "n1465935
    ENDIF.                                                  "n1465935

ENHANCEMENT-POINT F_SEGMENTE_GENERIEREN_03 SPOTS ES_SAPMM07M.

    READ TABLE zvm07m INDEX zmseg-zeile.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'ZVM07M' zmseg-zeile.
    ENDIF.
    dm07m = zdm07m.
    vm07m = zvm07m.
    mseg = zmseg.
* Begin note 663537 - Fashion
    DATA: l_konsi_check_c TYPE c VALUE space.
    PERFORM call_badi_consi_checkstructart USING    mseg
                                                    vm07m
                                           CHANGING l_konsi_check_c.
* End note 663537 - Fashion
    IF NOT zvm07m-xstor = zwei AND NOT zmseg-bustw IS INITIAL AND
* begin 111546
*                                  NOT ZMSEG-BUSTW = BUSTW_WE06.
                                   NOT zmseg-bustw = bustw_we06 AND
* begin note 409343
*                                  NOT zmseg-bustw = bustw_mb07.
                                   NOT zmseg-bustw = bustw_mb07 AND
* Begin note 663537 - Fashion
*\                                   NOT ZMSEG-BUSTW = BUSTW_TXBR.
                                   NOT zmseg-bustw = bustw_txbr AND
                                   NOT l_konsi_check_c IS INITIAL.
* End note 663537 - Fashion
* end note 409343
* end 111546
      IF vm07m-kzbwa = kzbwa-sz OR NOT vm07m-xhead IS INITIAL
                                OR NOT dm07m-umxhead IS INITIAL.
        LOOP AT xpxvaf WHERE zeile = mseg-zeile.
          EXIT.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'XPXVAF' mseg-zeile.
        ENDIF.
        IF vm07m-kzbwa = kzbwa-sz.                          "P45K019000
          IF xpxvaf-xwrob IS INITIAL.                       "P45K019000
            mseg-exbwr = xpxvaf-exwrt.
          ELSE.                                             "P45K019000
            mseg-exbwr = xpxvaf-wrbtr.                      "P45K019000
          ENDIF.                                            "P45K019000
        ENDIF.
* vsa struct. article
* transfer of struct. article and and bom is exploded both at sender's
* and at receiver's -> get value of head (647) at sender's from xpxvaf
        IF NOT xpxvaf-ergze IS INITIAL  AND  vm07m-kzbwa = kzbwa-05.
          mseg-exbwr = xpxvaf-exwrt.
        ENDIF.
* vsa struct. article
        IF NOT ( mseg-mengu IS INITIAL AND NOT mseg-wertu IS INITIAL ).
          mseg-vkwrt = xpxvaf-vkwrt.
          mseg-vkwra = xpxvaf-vkwra.
        ENDIF.
        IF NOT ( dm07m-ummen IS INITIAL AND NOT dm07m-umwer IS INITIAL )
                      AND NOT dm07m-kzuml IS INITIAL.
          dm07m-umvkw = xpxvaf-umvkw.
          dm07m-umvka = xpxvaf-umvka.
        ENDIF.
      ELSEIF ( NOT vm07m-xvkbw IS INITIAL AND vm07m-xhead IS INITIAL )
         OR ( NOT dm07m-umxvk IS INITIAL AND dm07m-umxhead IS INITIAL ).
        LOOP AT ypxvaf WHERE zeile = mseg-zeile.
          EXIT.
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'YPXVAF' mseg-zeile.
        ENDIF.
        IF NOT ( mseg-mengu IS INITIAL AND NOT mseg-wertu IS INITIAL ).
          mseg-vkwrt = ypxvaf-vkwrt.
          mseg-vkwra = ypxvaf-vkwra.
        ENDIF.
        IF NOT ( dm07m-ummen IS INITIAL AND NOT dm07m-umwer IS INITIAL )
                       AND NOT dm07m-kzuml IS INITIAL.
          dm07m-umvkw = ypxvaf-umvkw.
          dm07m-umvka = ypxvaf-umvka.
        ENDIF.
      ENDIF.
    ENDIF.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_03 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     F_SEGMENTE_GENERIEREN_02 SPOTS ES_SAPMM07M.

* MAA2 Begin
    IF mseg-bustw = bustw_we06 AND NOT dm07m-xhistma IS INITIAL
                                   AND vm07m-pstyp NE '9'.
*                                   and gv_flag_round = abap_true. test to May18th
      IF mseg-maa_urzei NE lf_maa_urzei.
        CALL METHOD go_mmim_maa_2->calc_rounding_diff_values
          EXPORTING
            is_mseg        = mseg
*           is_dm07m       = zdm07m
            is_vm07m       = vm07m
            it_mseg        = zmseg[]
            it_dm07m       = zdm07m[]
            it_ekws        = xekws[]
            it_ekbn        = xekbn[]
          CHANGING
            cv_flag_error  = gv_flag_error
            ct_message_log = gt_message_log.
        IF gv_flag_error = abap_true.
          PERFORM              send_maa_error_message.
        ENDIF.

        lf_maa_urzei = mseg-maa_urzei.
      ENDIF.
    ENDIF.
* MAA2 End

    IF NOT dm07m-xhistma  IS INITIAL AND " this is a MAA item
       NOT xdeliv         = 'X'.         " create no delivery "n1626562
*     save the origininal tables with the values
      MOVE : yekbnk[]          TO  lt_save_yekbnk[],
             yekbnk_cr[]       TO  lt_save_yekbnk_cr[],
             yebefu_cr[]       TO  lt_save_yebefu_cr[],
             abap_true         TO  lv_flag_restore.

*     save ordered quantities
      MOVE : dm07m-bpbmg               TO  gs_dm07m_save-bpbmg,
             dm07m-bpbmg_abd           TO  gs_dm07m_save-bpbmg_abd,
             dm07m-bsmng               TO  gs_dm07m_save-bsmng,
             dm07m-bsmng_abd           TO  gs_dm07m_save-bsmng,
             abap_true                 TO  gv_flag_dm07m_saved.

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
    ENDIF.                                                  "MAA2
* --- end   ----------------------------------------------- MAA2

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

    CALL FUNCTION 'MB_CALCULATE_VALUES'
      EXPORTING
        dm07m      = dm07m
        vm07m      = vm07m
        mkpf       = mkpf
        mseg       = mseg
        mbequ      = tcurm-mbequ
        glvor      = rw_vorgang
        kurst      = t003-kurst
        brazil     = brazil
        xmbwl      = xmbwl
        xcheck     = space
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
        xebew      = xebew
        xmbew      = xmbew
        xqbew      = xqbew
        xobew      = xobew                             "kaz
        xeklb      = zeklb
        xekls      = xekls
        xfaws      = xfaws
        xfawv      = xfawv
        x156w      = x156w
        xzcxcb     = xzcxcb
        xzcxcm     = xzcxcm
        yekbnk     = yekbnk
        yekbnk_cr  = yekbnk_cr
        yebefu_cr  = yebefu_cr
        yfbefu_cr  = yfbefu_cr
        zekbe_cr   = zekbe_cr
        zaufbe_cr  = zaufbe_cr
        xekbnk_kdm = yekbnk_kdm.                 "N1027899 + 1520698
END-ENHANCEMENT-SECTION.


ENHANCEMENT-POINT MM07MFF9_F_SEGMENTE_GENERIE_01 SPOTS ES_SAPMM07M.
    IF   vm07m-pstyp = drei   OR
         NOT xmbwl IS INITIAL OR
       NOT tcurm-mbequ IS INITIAL.
ENHANCEMENT-SECTION EHP604_MM07MFF9_F_SEGMENTE_G01 SPOTS ES_SAPMM07M .
      CALL FUNCTION 'MB_SIMULATE_VALUES'
        EXPORTING
          dm07m  = dm07m
          vm07m  = vm07m
          mseg   = mseg
          mbequ  = tcurm-mbequ
          xmbwl  = xmbwl
          xmigo  = xmigo                                    "595089
        IMPORTING
          dm07m  = dm07m
          vkwrt  = mseg-vkwrt                               " 116725
          vkwra  = mseg-vkwra                               " 116725
        TABLES
          x156w  = x156w
          xmbew  = xmbew
          xebew  = xebew
          xqbew  = xqbew
          xobew  = xobew                              "kaz
          xzcxcb = xzcxcb
          xzcxcm = xzcxcm.
END-ENHANCEMENT-SECTION.
    ENDIF.

    IF shfwdif = s.
      rm07m-summe_s = rm07m-summe_s + fwdif.
      rm07m-saldo   = rm07m-saldo   + fwdif.
    ELSE.
      rm07m-summe_h = rm07m-summe_h + fwdif.
      rm07m-saldo   = rm07m-saldo   - fwdif.
    ENDIF.
    CLEAR vw.

ENHANCEMENT-SECTION EHP604_MM07MFF9_F_SEGMENTE_G02 SPOTS ES_SAPMM07M .
    CALL FUNCTION 'MB_UPDATE_VALUE_ENQUEUE_TABLE'
      EXPORTING
        dm07m     = dm07m
        vm07m     = vm07m
        mkpf      = mkpf
        mseg      = mseg
        aktyp     = space
      IMPORTING
        upd_um03b = vw
        dm07m     = dm07m
        vkwrt     = mseg-vkwrt                              " 203679
        vkwra     = mseg-vkwra                              " 203679
      TABLES
        xekbn     = xekbn
        xekbv     = xekbv
        xekws     = xekws
        xekwv     = xekwv
        xeklb     = zeklb
        xekls     = xekls
        xfaws     = xfaws
        xfawv     = xfawv
        x156w     = x156w
        xmbew     = xmbew
        xebew     = xebew
        xqbew     = xqbew
        xobew     = xobew                             "kaz
        xzcxcb    = xzcxcb
        xzcxcm    = xzcxcm
        yekbnk    = yekbnk
        yekbnk_cr = yekbnk_cr
        yebefu_cr = yebefu_cr
        yfbefu_cr = yfbefu_cr.
END-ENHANCEMENT-SECTION.

*   restore ordered quantities of structur DM07M            "MAA2
    IF gv_flag_dm07m_saved = abap_true.                     "MAA2
      MOVE : gs_dm07m_save-bpbmg       TO  dm07m-bpbmg,
             gs_dm07m_save-bpbmg_abd   TO  dm07m-bpbmg_abd,
             gs_dm07m_save-bsmng       TO  dm07m-bsmng,
             gs_dm07m_save-bsmng_abd   TO  dm07m-bsmng.
      CLEAR : gs_dm07m_save,           gv_flag_dm07m_saved.
    ENDIF.                                                  "MAA2

    IF  lv_flag_restore = abap_true.                        "MAA2
*     restore the original values into the tables after the "MAA2
*     value calculation of this MAA item                    "MAA2
      MOVE : lt_save_yekbnk[]          TO  yekbnk[],        "MAA2
             lt_save_yekbnk_cr[]       TO  yekbnk_cr[],     "MAA2
             lt_save_yebefu_cr[]       TO  yebefu_cr[].     "MAA2
    ENDIF.                                                  "MAA2

    IF upd_um03b IS INITIAL.
      upd_um03b = vw.
    ENDIF.
    dm07m-vmeng = mseg-menge.
    dm07m-vermg = mseg-erfmg.
    dm07m-vbpmg = mseg-bpmng.
    dm07m-vbsmg = mseg-bstmg.
    dm07m-vvkwr = mseg-vkwrt.                               " 203679
ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_04 SPOTS ES_SAPMM07M.


    zdm07m = dm07m.
    MODIFY zdm07m INDEX dm07m-zeild.
    ymbuz_key-zeilz = dm07m-zeild.
    CLEAR ymbuz_key-xauto.
ENHANCEMENT-SECTION     F-SEGMENTE_GENERIEREN_05 SPOTS ES_SAPMM07M.
    READ TABLE ymbuz WITH KEY ymbuz_key BINARY SEARCH.
END-ENHANCEMENT-SECTION.


    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH 'YMBUZ' ymbuz_key-zeilz ymbuz_key-xauto.
    ENDIF.
    mseg-zeile = sy-tabix.
* begin of the note 916298
* save the jurisdiction code in the internal table 'xmseg' because of
* possible error FF 793
    IF NOT brazil IS INITIAL AND NOT xbapi IS INITIAL AND
       NOT mseg-txjcd IS INITIAL.
      READ TABLE xmseg WITH KEY zeile   = mseg-zeile
                                line_id = mseg-line_id.
      IF sy-subrc IS INITIAL.
        xmseg-txjcd = mseg-txjcd.
        MODIFY xmseg INDEX sy-tabix.
        IF NOT zdm07m-kzuml IS INITIAL.
          LOOP AT xmseg WHERE parent_id EQ mseg-line_id
                        AND   xauto     NE space.
            xmseg-txjcd = mseg-txjcd.
            MODIFY xmseg.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
* end of the note 916298

    CLEAR: c_kzuml.                                         "495236
    PERFORM f-segmente_erstellen USING mseg-bustw
                                            space
                                 CHANGING c_kzuml.          "495236
ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_06 SPOTS ES_SAPMM07M.

* MAA EhP4 begin -------------------------------------------"MAA EhP4
* in the case field SHKZG was modified in table XZCXCM for KDM lines
* the statistic indicator has to be reset for these KDM lines in table
* XACCIT

* MAA EhP4 end ---------------------------------------------"MAA EhP4

    LOOP AT zekbe_cr.
      yekbe_cr = zekbe_cr.
      yekbe_cr-ebeln = mseg-ebeln.
      yekbe_cr-ebelp = mseg-ebelp.
      yekbe_cr-buzei = zmseg-zeile.
      APPEND yekbe_cr.
    ENDLOOP.
    LOOP AT zaufbe_cr.
      yaufbe_cr = zaufbe_cr.
      yaufbe_cr-aufnr = mseg-aufnr.
      yaufbe_cr-posnr = mseg-aufps.
      yaufbe_cr-buzei = zmseg-zeile.
      APPEND yaufbe_cr.
    ENDLOOP.

*-- begin ------------------------------------------------- "MAA2
*   it could be possible that table XZCXCB for the delivery
*   costs does not contain useful data caused by very small
*   quantities for a MAA GR item. If there is a quantity in
*   field zdm07m-erfmg_abd -> create an XEKBZ entry
    IF NOT zmseg-xmacc      IS INITIAL   AND
           zdm07m-erfmg_abd > 0          AND
           sy-subrc         > 0.
      CLEAR                  sy-subrc.
      MOVE  abap_true        TO  lv_flag_maa_set_shkzg.
    ELSE.
      MOVE  abap_false       TO  lv_flag_maa_set_shkzg.
    ENDIF.
*-- end --------------------------------------------------- "MAA2

    LOOP AT xzcxcb WHERE curtp = curtp10
                   AND NOT shkzg = space.
      EXIT.
    ENDLOOP.

    IF sy-subrc IS INITIAL.
      LOOP AT yekbnk WHERE ebeln = mseg-ebeln
                       AND ebelp = mseg-ebelp.
* FR1 and KDM lines in xaccit will be created here, KDM has
* always bustw = BNKR, if xeink = X then bustw = BNKG and
* only FR1 line will be created but not any KDM line
        LOOP AT xzcxcb WHERE stunr = yekbnk-stunr           "N1306508
                       AND   zaehk = yekbnk-zaehk           "N1306508
                       AND   vorsl = vorsl_kdm              "N1306508
                       AND NOT shkzg IS INITIAL.            "N1306508
          EXIT.                                             "N1306508
        ENDLOOP.                                            "N1306508


* no any updates in RWIN when multi account and planned costs
* and the po item is GR non valuated
        IF dm07m-mulko IS INITIAL OR zmseg-weunb IS INITIAL. "MAA2
          PERFORM f-segmente_erstellen USING xzcxcb-bustw
                                                        x
                                       CHANGING   c_kzuml.  "495236
        ENDIF.                                              "MAA2

        DATA ml00. CLEAR ml00.
        DATA ml10. CLEAR ml10.
        CLEAR: xekbz, xekbz_cr, lv_append_done.             "N980402
        LOOP AT xzcxcb WHERE stunr = yekbnk-stunr
                       AND   zaehk = yekbnk-zaehk
                       AND   xauto = x.
          IF xzcxcb-curtp NE xekbz_cr-curtp.                "N1509501
            CLEAR lv_append_done.                           "N1509501
          ENDIF.                                            "N1509501

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_07 SPOTS ES_SAPMM07M.


          IF xzcxcb-curtp = curtp00 AND
             xzcxcb-vorsl NE vorsl_kdm.                     "N980402
            xekbz-wrbtr = xzcxcb-dmbtr.
            xekbz-waers = xzcxcb-waers.
            ml00 = x.
          ELSEIF xzcxcb-curtp = curtp10 AND
                 xzcxcb-vorsl NE vorsl_kdm.                 "N980402
            xekbz-stunr = xzcxcb-stunr.
            xekbz-zaehk = xzcxcb-zaehk.
            xekbz-dmbtr = xzcxcb-dmbtr.

*---------- begin ----------------------------------------- "MAA2
            IF  lv_flag_maa_set_shkzg = abap_true  AND      "MAA2
                xzcxcb-shkzg          IS INITIAL.           "MAA2
*             the debit/credit indicator is missing for     "MAA2
*             this MAA GR item -> take the contrary of      "MAA2
*             field ZMSEG-SHKZG                             "MAA2
              IF  zmseg-shkzg  = s.                         "MAA2
                MOVE : h               TO  xekbz-shkzg,     "MAA2
                       h               TO  xekbz-shkko.     "MAA2
              ELSE.                                         "MAA2
                MOVE : s               TO  xekbz-shkzg,     "MAA2
                       s               TO  xekbz-shkko.     "MAA2
              ENDIF.                                        "MAA2
            ELSE.                                           "MAA2
              xekbz-shkzg = xzcxcb-shkzg.
              xekbz-shkko = xzcxcb-shkzg.                   "484722
            ENDIF.                                          "MAA2
*---------- end ------------------------------------------- "MAA2

            xekbz-hswae = xzcxcb-waers.
            xekbz-lifnr = xzcxcb-lifnr.
            xekbz-bewtp = xzcxcb-bewtp.
            xekbz-kschl = xzcxcb-kschl.
            xekbz-budat = mkpf-budat.
            xekbz-cpudt = mkpf-cpudt.
            xekbz-cputm = mkpf-cputm.
            xekbz-ernam = mkpf-usnam.
            xekbz-ebeln = zmseg-ebeln.
            xekbz-ebelp = zmseg-ebelp.
* note 583853: for stock transfer (ZDM07M-KZUML = X), the valuation type
* has to be taken from the line for the receiving plant
* comparison: logic for EKBE is more complicated due to historical
* reasons, but result is the same
* take UMBAR when: ( XMSEG-KZBEW IS INITIAL OR XMSEG-KZBEW = L )
* AND NOT XMSEG-KZZUG IS INITIAL [BESTELLENTWICKLUNG_GENERIEREN]
            IF zdm07m-kzuml = x.                            " 583853
              xekbz-bwtar = zmseg-umbar.                    " 583853
            ELSE.                                           " 583853
              xekbz-bwtar = zmseg-bwtar.
            ENDIF.                                          " 583853
            xekbz-vgabe = eins.
            xekbz-menge = zmseg-bstmg.
            xekbz-bpmng = zmseg-bpmng.
            xekbz-buzei = zmseg-zeile.
            IF NOT mkpf-xblnr IS INITIAL.
              xekbz-xblnr = mkpf-xblnr.
            ELSE.
              xekbz-xblnr = zvm07m-xblnr_avis.
            ENDIF.

*           Goods receipt inbound delivery                     "867249
            IF xmbwl = 'X' AND im_process = 'L'             "867249
              AND t158-vgart = 'WE'.                        "867249
              IF NOT zvm07m-xblnr_avis IS INITIAL.          "867249
                xekbz-xblnr = zvm07m-xblnr_avis.            "867249
              ENDIF.                                        "867249
            ENDIF.                                          "867249

            IF NOT mkpf-frbnr IS INITIAL.
              xekbz-frbnr = mkpf-frbnr.
            ELSE.
              xekbz-frbnr = zvm07m-frbnr_avis.
            ENDIF.

            IF xekbz-shkzg = zmseg-shkzg AND zmseg-umwrk IS INITIAL.
              IF zmseg-shkzg = h.
                xekbz-shkzg = s.
              ELSE.
                xekbz-shkzg = h.
              ENDIF.
*             if zmseg-umwrk is initial.
*               xekbz-dmbtr = 0 - xekbz-dmbtr.
*               xekbz-wrbtr = 0 - xekbz-wrbtr.
*             endif.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_08 SPOTS ES_SAPMM07M.
            ENDIF.
*          if not zmseg-umwrk is initial and not zmseg-kzzug is initial.
*             xekbz-waers = zmseg-waers.
*           endif.
            ml10 = x.

* Begin N980402
          ELSEIF xzcxcb-curtp = curtp10 AND
                 xzcxcb-vorsl = vorsl_kdm.
            IF xzcxcb-shkzg = zmseg-shkzg.
              xekbz-kudif = xzcxcb-dmbtr.
            ELSE.
              xekbz-kudif = 0 - xzcxcb-dmbtr.
            ENDIF.
* In case of stock transfer (valuated or with account
* assigned) change sign because zmseg-shkzg is reversed.
            IF zdm07m-kzuml = 'X' OR NOT zmseg-umwrk IS INITIAL.
              xekbz-kudif = 0 - xekbz-kudif.
            ENDIF.
* End 980402
          ENDIF.

* MAA-DEV
          IF NOT dm07m-xhistma IS INITIAL.                  "N1423825
            READ TABLE yekbe_cr INTO ls_ekbecr
               WITH KEY ebeln = mseg-ebeln
                        ebelp = mseg-ebelp
                        buzei = mseg-zeile
                        curtp = xzcxcb-curtp.
            IF sy-subrc = 0.
              IF ls_ekbecr-curtp = curtp10.
                xekbz-wkurs = ls_ekbecr-wkurs.
                IF xekbz-waers = ls_ekbecr-waers.
                  xekbz-wkurs = '100000'.
                ENDIF.
              ENDIF.
              xekbz_cr-wkurs = ls_ekbecr-wkurs.
              IF xekbz-waers = ls_ekbecr-waers.
                xekbz_cr-wkurs = '100000'.
              ENDIF.
            ENDIF.
          ENDIF.                                            "N1423825
* MAA-DEV DC WKURS

* Here, we check if we have material ledger active. In case of
* stock transfer (zdm07m-kzuml = 'X'), we check the material
* of the receiving plant (zdm07m-ummlm) instead of the material of
* the issuing plant (zvm07m-mlmaa). If the material is not valuated
* (zdm07m-umwer is initial), we cannot use these fields zdm07m-ummlm
* or zvm07m-mlmaa, so we use t001k-mlbwa. => note 0439945
          DATA: help_ekbz_cr TYPE c.                        "0439945
          IF NOT zdm07m-kzuml IS INITIAL.                   "0439945
            IF NOT zdm07m-umwer IS INITIAL.  " val. mat.    "0439945
              IF NOT zdm07m-ummlm IS INITIAL.               "0439945
                help_ekbz_cr = 'X'.                         "0439945
              ENDIF.                                        "0439945
            ELSEIF zdm07m-umwer IS INITIAL.  "not val. mat. "0439945
              IF zmseg-umwrk = t001w-werks                  "0439945
              AND t001w-bwkey = t001k-bwkey                 "0439945
              AND NOT t001k-mlbwa IS INITIAL.  "ml active   "0439945
                help_ekbz_cr = 'X'.                         "0439945
              ENDIF.                                        "0439945
* if there are different PO-items with different plants,    "507109
* T001K maybe filled with the wrong plant, so we have to    "507109
* make a new select on T001K , but we first check if        "507109
* T001W is still filled with the correct datas:             "507109
              IF NOT zmseg-umwrk = t001w-werks.             "507109
                SELECT SINGLE * FROM t001w WHERE            "507109
                       werks = zmseg-umwrk .                "507109
                IF NOT sy-subrc IS INITIAL.                 "507109
                  MESSAGE e001(m7) WITH 'T001W' zmseg-umwrk. "507109
                ENDIF.                                      "507109
                SELECT SINGLE * FROM t001k WHERE            "507109
                       bwkey = t001w-bwkey.                 "507109
                IF NOT sy-subrc IS INITIAL.                 "507109
                  MESSAGE e001(m7) WITH 'T001K'  t001w-bwkey. "507109
                ENDIF.                                      "507109
                IF NOT t001k-mlbwa IS INITIAL.  "ml active  "507109
                  help_ekbz_cr = 'X'.                       "507109
                ENDIF.                                      "507109
              ENDIF.                                        "507109

            ENDIF.                                          "0439945
          ELSEIF zdm07m-kzuml IS INITIAL.                   "0439945
            IF NOT zvm07m-mlmaa IS INITIAL                  "0439945
*           da bei kontierten Bestellungen, das mlmaa nicht sitzt:
               OR ( zvm07m-mlmaa IS INITIAL                 "0439945
                    AND NOT zmseg-kzvbr IS INITIAL ).       "0439945
              help_ekbz_cr = 'X'.                           "0439945
            ENDIF.                                          "0439945
          ENDIF.                                            "0439945
          IF NOT help_ekbz_cr IS INITIAL.                   "0439945
            IF xzcxcb-vorsl NE vorsl_kdm.                   "N980402
              xekbz_cr-ebeln = zmseg-ebeln.
              xekbz_cr-ebelp = zmseg-ebelp.
              xekbz_cr-stunr = xzcxcb-stunr.
              xekbz_cr-zaehk = xzcxcb-zaehk.
              xekbz_cr-vgabe = eins.
              xekbz_cr-buzei = zmseg-zeile.
              xekbz_cr-curtp = xzcxcb-curtp.
              xekbz_cr-waers = xzcxcb-waers.
              xekbz_cr-shkzg = xzcxcb-shkzg.
              xekbz_cr-wrbtr = xzcxcb-dmbtr.

* Begin N980402
              lv_append_done = x.

              IF zmseg-maa_urzei IS INITIAL.                "MAA2
                APPEND xekbz_cr.
              ELSE.                                         "MAA2
                CALL METHOD go_mmim_maa_2->xekbz_cr_aggregate
                  EXPORTING
                    is_zmseg       = zmseg
                  CHANGING
                    cs_xekbz_cr    = xekbz_cr
                    cv_flag_error  = gv_flag_error
                    ct_message_log = gt_message_log.

                IF gv_flag_error = abap_true.
                  PERFORM            send_maa_error_message.
                ENDIF.

                IF zmseg-xmacc CA 'LU'.
                  APPEND xekbz_cr.
                ENDIF.

              ENDIF.                                        "MAA2

              lv_memorise_index = sy-tabix.
            ELSEIF xzcxcb-vorsl = vorsl_kdm.
              IF xzcxcb-shkzg = zmseg-shkzg.
                xekbz_cr-kudif = xzcxcb-dmbtr.
              ELSE.
                xekbz_cr-kudif = 0 - xzcxcb-dmbtr.
              ENDIF.
              IF zdm07m-kzuml = 'X' OR NOT zmseg-umwrk IS INITIAL.
                xekbz_cr-kudif = 0 - xekbz_cr-kudif.
              ENDIF.
              IF lv_append_done = x.
                MODIFY xekbz_cr INDEX  lv_memorise_index
                                TRANSPORTING kudif.
              ENDIF.
              CONTINUE.
            ENDIF.
* End N980402

          ENDIF.
          CLEAR help_ekbz_cr.                               "0439945
        ENDLOOP.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'XZCXCB' space yekbnk-stunr yekbnk-zaehk.
        ELSEIF ml00 IS INITIAL.
          MESSAGE e001 WITH 'XZCXCB' '00' yekbnk-stunr yekbnk-zaehk.
        ELSEIF ml10 IS INITIAL.
          MESSAGE e001 WITH 'XZCXCB' '10' yekbnk-stunr yekbnk-zaehk.
        ENDIF.

        IF zmseg-maa_urzei IS INITIAL.                      "MAA2
          APPEND xekbz.
        ELSE.                                               "MAA2
          CALL METHOD go_mmim_maa_2->xekbz_aggregate
            EXPORTING
              is_zmseg       = zmseg
            CHANGING
              cs_xekbz       = xekbz
              cv_flag_error  = gv_flag_error
              ct_message_log = gt_message_log.

          IF gv_flag_error = abap_true.
            PERFORM            send_maa_error_message.
          ENDIF.

          IF zmseg-xmacc CA 'LU'.
            xekbz-xmacc = zdm07m-xhistma.   " B or X
            APPEND xekbz.
          ENDIF.

          CALL METHOD go_mmim_maa_2->maa_ekbz_ma_creator
            EXPORTING
              is_zmseg       = zmseg
              is_zdm07m      = zdm07m
            CHANGING
              ct_xekbz_ma    = xekbz_ma[]
              cv_flag_error  = gv_flag_error
              ct_message_log = gt_message_log.

          IF gv_flag_error = abap_true.
            PERFORM        send_maa_error_message.
          ENDIF.
        ENDIF.                                              "MAA2

        LOOP AT xzcxcb WHERE stunr = yekbnk-stunr
                       AND   zaehk = yekbnk-zaehk
                       AND   xauto = space
                       AND   curtp = curtp10.
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          PERFORM f-segmente_erstellen USING xzcxcb-bustw
                                                    y
                                       CHANGING   c_kzuml.  "495236

        ENDIF.
      ENDLOOP.
    ENDIF.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_09 SPOTS ES_SAPMM07M.

  ENDLOOP.

* init table with components of finished product            "note 870572
  DATA: BEGIN OF lt_ymseg OCCURS 0.                         "note 870572
          INCLUDE STRUCTURE mseg.                           "note 870572
  DATA: END OF lt_ymseg.                                    "note 870572
  CALL FUNCTION 'J_1B_IM_TX_YMSEG'                          "note 870572
       TABLES                                               "note 870572
            i_ymseg = lt_ymseg.                             "note 870572
  IF NOT rm07m-saldo = 0.
    MESSAGE e050 WITH rm07m-saldo rm07m-summe_s rm07m-summe_h.
  ENDIF.

* OLC EhP5e
* If OLC is on, and the Order is header costed ensure that APLZL/AUFPL are clear.
* These values are needed in MSEG, but should not be posted to BSEG.
  IF cl_erp_co_olc_sw_check=>erp_co_olc( ) IS NOT INITIAL.
    FIELD-SYMBOLS <xaccit> LIKE LINE OF xaccit[].
    LOOP AT xaccit[] ASSIGNING <xaccit> WHERE aufnr IS NOT INITIAL.
      IF cl_erp_co_olc_tools=>is_not_olc_relevant( <xaccit>-aufnr ) EQ abap_true.
        CLEAR: <xaccit>-aplzl, <xaccit>-aufpl.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_10 SPOTS ES_SAPMM07M.

ENHANCEMENT-POINT F-SEGMENTE_GENERIEREN_13 SPOTS ES_SAPMM07M.

ENDFORM.                    "F-SEGMENTE_GENERIEREN

*----------------------------------------------------------------------*
*    do_additional_checks
*----------------------------------------------------------------------*

* this is a dummy FORM routine. It is called prom function group MBWL
* at process time "LOAD-OF-PROGRAM" to make sure that function group
* MBWL and program pool SAPMM07 work with the same common data areas

FORM do_additional_checks
  USING     uv_string        TYPE  symsgv
  CHANGING  cv_flag_check    TYPE  abap_bool.

*----------------------------------------------------------------------*
  DATA : lv_dontpanic        TYPE  symsgv,
         lv_string           TYPE  symsgv.
*----------------------------------------------------------------------*

  MOVE  abap_false           TO  cv_flag_check.

  GET PARAMETER ID 'DONTPANIC' FIELD  lv_dontpanic.

  IF sy-subrc IS INITIAL.
    MOVE  uv_string          TO  lv_string.
    TRANSLATE : lv_string    TO  UPPER CASE,             "#EC TRANSLANG
                lv_dontpanic TO  UPPER CASE.             "#EC TRANSLANG

*   special user parameter for analysis is available
    FIND FIRST OCCURRENCE OF lv_string  IN  lv_dontpanic.

    IF  sy-subrc IS INITIAL.
      MOVE  abap_true        TO  cv_flag_check.
    ENDIF.
  ENDIF.

ENDFORM.                    " do_additional_checks

*----------------------------------------------------------------------*
* send_maa_error_message.
*----------------------------------------------------------------------*

FORM send_maa_error_message.

*----------------------------------------------------------------------*

* define local working fields
  DATA : ls_message_log      LIKE LINE OF gt_message_log.

*----------------------------------------------------------------------*

* send the message
  LOOP AT gt_message_log     INTO  ls_message_log.
    MESSAGE ID               ls_message_log-id
            TYPE             ls_message_log-type
            NUMBER           ls_message_log-number
            WITH             ls_message_log-message_v1
                             ls_message_log-message_v2
                             ls_message_log-message_v3
                             ls_message_log-message_v4.
  ENDLOOP.

ENDFORM.                    " send_maa_error_messag

*----------------------------------------------------------------------*