*----------------------------------------------------------------------*
*   INCLUDE INCL_V50A_PAKMG                                            *
*----------------------------------------------------------------------*
*    LS_VBFA-RFMNG = ls_vbfa-rfmng - lf_diff.                "HP 205734
*    if not ls_vbfa-rfmng > 0.                               "HP 205734
*      lf_diff = lf_diff + ls_vbfa-rfmng.                    "HP 205734
*<<<<   begin of insert HP note 205734 >>>>>>>>>>
    Lf_rfmng_new = ls_vbfa-rfmng - lf_diff.
    if Lf_rfmng_new = 0.
      clear: ls_vbfa-rfmng, ls_vbfa-rfmng_flo, ls_vbfa-rfmng_flt,
             lf_diff, lf_diff_flt, lf_diff_flo.
    endif.
    if Lf_rfmng_new < 0.
      lf_diff     = lf_diff - ls_vbfa-rfmng.
*<<<< end of insert HP note 205734 >>>>>>>>>>>>>>>>>>>>
      lf_diff_flt = lf_diff_flt - ls_vbfa-rfmng_flt.
      lf_diff_flo = lf_diff_flo - ls_vbfa-rfmng_flo.
      clear: ls_vbfa-rfmng, ls_vbfa-rfmng_flo, ls_vbfa-rfmng_flt.
*    else.                                                   "HP 205734
    endif.                                                   "HP 205734
    if Lf_rfmng_new > 0.                                     "HP 205734
      ls_vbfa-rfmng     = ls_vbfa-rfmng     - lf_diff.       "HP 205734
      LS_VBFA-RFMNG_FLT = ls_vbfa-rfmng_flt - lf_diff_flt.
      IF NOT <VBAPF>-QMENGEV IS INITIAL OR <LIPS>-UMVKZ IS INITIAL. "n_v_1668200
        LS_VBFA-RFMNG_FLO = ls_vbfa-rfmng_flo - lf_diff_flo.
      ELSE.
        LS_VBFA-RFMNG_FLO = ls_vbfa-rfmng_flt *
                            <LIPS>-UMVKN / <LIPS>-UMVKZ.     "n_^_1668200
      endif.
      clear: lf_diff, lf_diff_flt, lf_diff_flo.              "HP 205734
    ENDIF.
    if ls_vbfa-rfmng is initial and <lips>-komkz ca 'A'.
      CALL FUNCTION 'RV_XVBFA_MAINTAIN'
               EXPORTING
                    F_VORGANG = CHARL
                    FVBFA     = LS_VBFA
               TABLES
                    FXVBFA    = XVBFA
                    FYVBFA    = YVBFA
                    FXVBAPF   = XVBAPF.
    else.
     CALL FUNCTION 'RV_XVBFA_MAINTAIN'
              EXPORTING
                    F_VORGANG = CHARV
                    FVBFA     = LS_VBFA
               TABLES
                   FXVBFA    = XVBFA
                   FYVBFA    = YVBFA
                    FXVBAPF   = XVBAPF.
    endif.