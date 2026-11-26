*eject
*---------------------------------------------------------------------*
*       FORM SEGMENT_SCHREIBEN                                        *
*---------------------------------------------------------------------*
*       Das geaenderte Segment wird zurueckgeschrieben.               *
*---------------------------------------------------------------------*
FORM segment_schreiben.

* MAA2 : error M7 330 when creating an outbound delivery for a "n1626562
* return delivery of a MAA GR item with amount based           "n1626562
* distribution                                                 "n1626562

*-----------------------------------------------------------"MAA2
* define local working areas
  DATA : lv_flag_restore     TYPE  abap_bool.

* for saving the input tables for the value calculation
  DATA : lt_save_yekbnk      TYPE  me_ekbnk,
         lt_save_yekbnk_cr   TYPE  cl_mmim_maa_2=>tt_yekbnk_cr,
         lt_save_yebefu_cr   TYPE  ebefu_cr_t.
*-----------------------------------------------------------"MAA2

  CHECK aktyp = k OR aktyp = v.
  DATA xchange TYPE c. CLEAR xchange.
  IF aktyp = k.
    IF NOT ymseg-zeile = mseg-zeile.
      a_zeile = mseg-zeile.
      PERFORM segment_lesen USING space.
    ENDIF.
    CALL FUNCTION 'LVS_COMMUNICATION_MB_CHANGE'
      EXPORTING
        i_ymseg  = ymseg
        i_ydm07m = ydm07m
        i_yvm07m = yvm07m
        i_mseg   = mseg
        i_xmbwl  = xmbwl
        i_dm07m  = dm07m
        i_vm07m  = vm07m
        i_rm07m  = rm07m
        i_st156s = s156s
        i_mkpf   = mkpf
      IMPORTING
        e_mseg   = mseg
        e_dm07m  = dm07m
        e_vm07m  = vm07m
        e_tafkz  = lvs_tafkz
        e_mailk  = lvs_mailk
        e_mkpf   = mkpf.
    DATA: werte_rechnen. CLEAR werte_rechnen.
ENHANCEMENT-POINT SEGMENT_SCHREIBEN_04 SPOTS ES_SAPMM07M.
    IF ( ( NOT vm07m-pstyp = drei OR NOT mseg-kzbew = b ) AND
       NOT mseg-ebeln = auto_best AND
       tcurm-mbequ IS INITIAL ) OR
       ( NOT brazil IS INITIAL AND NOT vm07m-j_1bnfrel IS INITIAL ).
      werte_rechnen = x.

* MAA2 Begin
      IF NOT dm07m-xhistma  IS INITIAL     AND  " this is a MAA item
         NOT xdeliv         =  'X'         AND  " create no delivery "n1626562
             mseg-bustw     =  bustw_we06.      " this GR is valuated

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
*       copy the ordered, received, and invoiced quantities on
*       GR item level into the float format, because they are needed
*       in MB_CALCULATE_VALUES
        dm07m-bsmng_abd      = dm07m-bsmng / 1000.
        dm07m-bpbmg_abd      = dm07m-bpbmg / 1000.
        dm07m-wwmng_abd      = dm07m-wwmng / 1000.
        dm07m-bpwwm_abd      = dm07m-bpwwm / 1000.
        dm07m-remng_abd      = dm07m-remng / 1000.
        dm07m-bprem_abd      = dm07m-bprem / 1000.
      ENDIF.
* end ---------------------------------------------------------"n1626562

ENHANCEMENT-SECTION     SEGMENT_SCHREIBEN_01 SPOTS ES_SAPMM07M.
      CALL FUNCTION 'MB_CALCULATE_VALUES'
        EXPORTING
          dm07m      = dm07m
          vm07m      = vm07m
          mkpf       = mkpf
          mseg       = mseg
          glvor      = rw_vorgang
          kurst      = t003-kurst
          brazil     = brazil
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
          xmbew      = xmbew
          x156w      = x156w
          xzcxcb     = xzcxcb
          xzcxcm     = xzcxcm
          yekbnk     = yekbnk
          xebew      = xebew
          xqbew      = xqbew
          xobew      = xobew                                   "kaz
          yekbnk_cr  = yekbnk_cr
          yebefu_cr  = yebefu_cr
          yfbefu_cr  = yfbefu_cr
          xekbnk_kdm = yekbnk_kdm.                 "N1027899 + 1520698
END-ENHANCEMENT-SECTION.



ENHANCEMENT-SECTION EHP604_SEGMENT_SCHREIBEN_01 SPOTS ES_SAPMM07M .
      CALL FUNCTION 'MB_SIMULATE_VALUES'
        EXPORTING
          dm07m  = dm07m
          vm07m  = vm07m
          mseg   = mseg
          mbequ  = tcurm-mbequ
        IMPORTING
          dm07m  = dm07m
          vkwrt  = mseg-vkwrt                               " 116725
          vkwra  = mseg-vkwra                               " 116725
        TABLES
          x156w  = x156w
          xmbew  = xmbew
          xebew  = xebew
          xqbew  = xqbew
          xobew  = xobew                                      "kaz
          xzcxcb = xzcxcb
          xzcxcm = xzcxcm.
END-ENHANCEMENT-SECTION.
    ENDIF.
    IF NOT werte_rechnen IS INITIAL.
      PERFORM anlagenwert_pruefen.
    ENDIF.
    CALL FUNCTION 'LVS_DEQUEUE_OLD'
      EXPORTING
        i_ymseg  = ymseg
        i_ydm07m = ydm07m
        i_yvm07m = yvm07m.
    PERFORM qpl1_update_memory.
    IF t158-trtyp = h.
      CALL CUSTOMER-FUNCTION '001'
           EXPORTING
                i_mseg  = mseg
                i_vm07m = vm07m
                i_dm07m = dm07m
                i_mkpf  = mkpf
           IMPORTING
                e_sgtxt = mseg-sgtxt.
    ENDIF.

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
*         xqbew     = xqbew.                                  "kaz
          xqbew     = xqbew                                   "kaz
          xobew     = xobew.                                  "kaz
*                xxiseg    = xxiseg.

      IF  lv_flag_restore = abap_true.                      "MAA2
*       restore the original values into the tables after   "MAA2
*       the value calculation of this MAA item              "MAA2
        MOVE : lt_save_yekbnk[]          TO  yekbnk[],      "MAA2
               lt_save_yekbnk_cr[]       TO  yekbnk_cr[],   "MAA2
               lt_save_yebefu_cr[]       TO  yebefu_cr[].   "MAA2
      ENDIF.                                                "MAA2
    ENDIF.

ENHANCEMENT-POINT SEGMENT_SCHREIBEN_05 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     SEGMENT_SCHREIBEN_02 SPOTS ES_SAPMM07M.
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
        xxiseg = xxiseg                             " PPF Rel.4.6
        xmstb  = xmstb                              "SIT
        xmste  = xmste                              "SIT
        xmstq  = xmstq.                             "SIT
END-ENHANCEMENT-SECTION.
    CALL FUNCTION 'MB_MODIFY_STOCK_ENQUEUE_ENTRY'
      EXPORTING
        xneup = fcausw-xneup
        xaenp = fcausw-xaenp
        mbequ = tcurm-mbequ
        basmg = mseg-menge
        baswr = mseg-vkwrt
        mseg  = mseg
        vm07m = vm07m
      TABLES
        x156m = x156m
        x156w = x156w
        xmchb = xmchb
      CHANGING
        dm07m = dm07m.
    IF NOT dm07m-vermg = mseg-erfmg.
      xchange = x.
    ENDIF.
    dm07m-urvermg = dm07m-urerfmg.
    dm07m-vmeng = mseg-menge.
    dm07m-vermg = mseg-erfmg.
    dm07m-vbpmg = mseg-bpmng.
    dm07m-vbsmg = mseg-bstmg.
    dm07m-vvkwr = mseg-vkwrt.
    dm07m-vexvk = mseg-exvkw.
    dm07m-vumvkw = dm07m-umvkw.
ENHANCEMENT-POINT MM07MFS9_SEGMENT_SCHREIBEN_03 SPOTS ES_SAPMM07M.
  ENDIF.
  ymseg = mseg.
  yvm07m = vm07m.
  ydm07m = dm07m.
  CLEAR ydm07m-xexit.
  MODIFY ymseg INDEX mseg-zeile.
  MODIFY yvm07m INDEX vm07m-zeilv.
  MODIFY ydm07m INDEX dm07m-zeild.
  IF aktyp = k AND NOT xchange IS INITIAL.
    IF ( mseg-urzei IS INITIAL OR mseg-zeile = mseg-urzei ) AND
       ( NOT t158-kzbew = o OR mseg-kzbew = o ).
      omseg = mseg.
      ovm07m = vm07m.
      odm07m = dm07m.
    ELSE.
      CLEAR: omseg, ovm07m, odm07m.
    ENDIF.
    IF mseg-kzbew = b AND vm07m-pstyp = drei AND mseg-erfmg = 0
       AND xmbwl IS INITIAL.
      LOOP AT ymseg WHERE urzei = mseg-zeile
                    AND   NOT erfmg = 0.
        READ TABLE yvm07m INDEX ymseg-zeile.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'YVM07M' ymseg-zeile.
        ENDIF.
        READ TABLE ydm07m INDEX ymseg-zeile.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'YDM07M' ymseg-zeile.
        ENDIF.
        CLEAR fuss.
        MOVE-CORRESPONDING ydm07m TO fuss.
        MOVE-CORRESPONDING yvm07m TO fuss.
        MOVE-CORRESPONDING ymseg TO fuss.
        IF fuss-xauto IS INITIAL AND mseg-xauto = d.
          fuss-xauto = d.
        ENDIF.
        fuss-erfmg = 0.
        fuss-menge = 0.
        fuss-bpmng = 0.
        fuss-bstmg = 0.
        fuss-elikz = fuss-elikz_old.
        fuss-xselk = x.
        fuss-xselp = x.
        fuss-xprue = x.
        fuss-fcode = fcod-kp.
        APPEND fuss.
        IF fcode_next = fcod-kp.
          fcode_next = fcod-ab.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF xmbwl IS INITIAL.
      DATA ftabix LIKE fuss-tabix. CLEAR ftabix.
      DATA fazeil LIKE fuss-azeil. CLEAR fazeil.
      PERFORM strukt_material USING k
                                    ftabix
                                    fazeil.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT MM07MFS9_SEGMENT_SCHREIBEN_04 SPOTS ES_SAPMM07M.
ENDFORM.