***INCLUDE FV50XF0B_BELEG_VERTEILUNG_PRUE .
*----------------------------------------------------------------------*
*       FORM BELEG_VERTEILUNG_PRUEFEN                                  *
*----------------------------------------------------------------------*
*       Falls im Lieferkopf eine Lagernummer sitzt, wird die Relevanz  *
*       für die Verteilung überprüft. Das Ergebnis wird im Feld VLSTK  *
*       übergeben.                                                     *
*----------------------------------------------------------------------*
FORM beleg_verteilung_pruefen USING if_likp-lgnum LIKE likp-lgnum
                                    if_likp-verursys LIKE likp-verursys
                                    if_tvlk_distrb_mode LIKE tvlk-dbtch
* SPE MP 14.01.2005 Control distribution of returns deliveries
                 if_likp-vbtyp            LIKE likp-vbtyp
                 if_likp-spe_acc_app_sts  LIKE likp-spe_acc_app_sts
                 if_likp-spe_shp_inf_sts  LIKE likp-spe_shp_inf_sts
                           CHANGING cf_likp-vlstk LIKE likp-vlstk.

  DATA: li_modify_distrib_status TYPE REF TO le_shp_modify_distrib_status,
        lf_vlstk TYPE vlstk.

  TABLES: t340d.

  CHECK cf_likp-vlstk CA ' AD'.

  IF if_likp-verursys IS INITIAL.
*   central system (ERP)

    IF if_likp-lgnum IS INITIAL.
      CLEAR cf_likp-vlstk.
    ELSE.
      IF t340d-lgnum NE if_likp-lgnum.
        SELECT SINGLE * FROM t340d WHERE lgnum = if_likp-lgnum.
        IF sy-subrc NE 0.
          CLEAR t340d.
        ENDIF.
      ENDIF.

      IF t340d-decsy IS INITIAL.
        CLEAR cf_likp-vlstk.
      ELSE.
*         warehouse number is decentral
        IF if_tvlk_distrb_mode = char1.
*          distribution in batch mode
          cf_likp-vlstk = chard.
        ELSEIF if_tvlk_distrb_mode = char2.
*          distribution immediatly at delivery save
          cf_likp-vlstk = chara.
        ELSEIF if_tvlk_distrb_mode IS INITIAL.
*          distribution controled on warehouse number
          IF t340d-t340d_dbtch IS INITIAL.
*             distribution immediatly at delivery save
            cf_likp-vlstk = chara.
          ELSE.
*             distribution in batch mode
            cf_likp-vlstk = chard.
          ENDIF.
        ELSE.
*          no valid delivery type distribution mode
          CLEAR cf_likp-vlstk.
        ENDIF.
* SPE100 MP 14.01.2005 Control distribution of returns deliveries
* Do not distribute returns deliveries if still messages from the
* dealer and carrier portal are expected. However, advanced
* distribution should be possible in any case with transaction VL06D
        IF cf_likp-vlstk EQ chara AND
           if_likp-vbtyp EQ vbtyp_lire.
          IF  if_likp-spe_acc_app_sts EQ gc_spe_ret-acc_app_expected OR
              if_likp-spe_acc_app_sts EQ gc_spe_ret-acc_app_expected_edi OR
              if_likp-spe_acc_app_sts EQ gc_spe_ret-acc_app_ich_err_expected OR
              if_likp-spe_acc_app_sts EQ gc_spe_ret-acc_app_edi_err_expected OR
              if_likp-spe_shp_inf_sts EQ gc_spe_ret-shp_inf_expected. "v_n_1109714
            cf_likp-vlstk = chard.
          ENDIF.
        ENDIF.
*

      ENDIF.
    ENDIF.

  ELSE.
*   decentral system (LVS)
    cf_likp-vlstk = chara.
  ENDIF.

ENHANCEMENT-POINT EHP603_BELEG_VERTLG_PRUEFEN_01 SPOTS ES_FV50XF0B_BEL_VERT_PRUEF INCLUDE BOUND .

* Direct outbound delivery for production staging: Set   "v_n_1247419
* status to 'distributed' during delivery creation
  IF likp-spe_le_scenario = /spe/if_ewm_man_const=>scenario-supply AND
     cl_ewm_switch_check=>le_sfws_sc_ewm_man( )  = gc_true AND
     /spe/cl_ewm_man_services=>is_ewm_replica( ) = gc_true AND
     cf_likp-vlstk CA 'AD' AND
     t180-trtyp    =  charh.
    cf_likp-vlstk = charb.
  ENDIF.                                                 "^_n_1247419

*--- Additional item scenario, reject the distribution of inbound delivery to EWM

  IF likp-spe_le_scenario = gc_le_scenario-additm AND
    likp-vbtyp = '7'.
    cf_likp-vlstk = charb.
  ENDIF.

* BAdI for influencing the distribution status  (EhP 2)
* Note: This BAdI is dedicated for replacement article determination only!
  TRY.
      GET BADI li_modify_distrib_status.
    CATCH cx_badi_not_implemented.
  ENDTRY.

  IF li_modify_distrib_status IS BOUND.
    lf_vlstk = cf_likp-vlstk.
    CALL BADI li_modify_distrib_status->modify_distribution_status
      EXPORTING
        is_likp   = likp
        is_likpd  = likpd
        it_xvbuk  = xvbuk[]
        it_yvbuk  = yvbuk[]
        it_xvbup  = xvbup[]
        it_yvbup  = yvbup[]
        it_xlikp  = xlikp[]
        it_ylikp  = ylikp[]
        it_xlips  = xlips[]
        it_ylips  = ylips[]
        it_xvbpa  = xvbpa[]
        it_yvbpa  = yvbpa[]
        is_v50agl = v50agl
        if_trtyp  = t180-trtyp
        if_tcode  = t180-tcode
      CHANGING
        cf_vlstk  = lf_vlstk.
*   Ensure that only valid distribution status are used
    IF lf_vlstk CA ' AD'.
      cf_likp-vlstk = lf_vlstk.
    ENDIF.
  ENDIF.

ENDFORM.                    "BELEG_VERTEILUNG_PRUEFEN