*---------------------------------------------------------------------*
*       FORM F-BELEG_ERGAENZEN                                        *
*---------------------------------------------------------------------*
*       Der Buchhaltungsbeleg wird ergaenzt.                          *
*---------------------------------------------------------------------*
FORM f-beleg_ergaenzen.

  def_break 'F-BELEG_ERGAENZEN'.                            "#EC *
  BREAK-POINT ID mb_f_beleg_ergaenzen.

* do not call accounting interface, if LOG-FIN decoupling is active
* temporarily deactivated!
* Obsolete
* The coding within this switch check is not in use
  CHECK  cl_log_dcfl_switch_check=>log_dcfl_swfs_01_rs( ) = abap_false.

  SORT bukrs.
  DATA: bukrx LIKE bukrs-bukrs,
        xumbw LIKE bukrs-xumbw.
  CLEAR: bukrx, xumbw.
  LOOP AT bukrs.
    IF NOT bukrs-saldo = 0.
      IF NOT bukrs-xumbw IS INITIAL.
        MESSAGE e052 WITH bukrs-bukrs bukrs-saldo.          "#EC *
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-subrc IS INITIAL.
    MOVE-CORRESPONDING mkpf TO xacchd.
    MOVE mkpf-tcode2 TO xacchd-tcode.
    xacchd-awtyp = rw_awtyp.
    xacchd-glvor = rw_vorgang.

    if_secon.
    IF NOT mbval IS INITIAL.
      xacchd-cpudt = mw_cpudt.
      xacchd-cputm = mw_cputm.
    ENDIF.
    end_secon.
    APPEND xacchd.
ENHANCEMENT-POINT F-BELEG_ERGAENZEN_01 SPOTS ES_SAPMM07M.
    DATA component LIKE trwpr-component. CLEAR component.
    CALL FUNCTION 'MIMB_VM07M_EXPORT'                       "898769
      EXPORTING
      i_vm07m  = vm07m.                                     "898769
    CALL FUNCTION 'CKMV_AC_DOCUMENT_CREATE'
      EXPORTING
        i_comp             = component
      TABLES
        t_acchd            = xacchd
        t_accit            = xaccit
        t_acccr            = xacccr
        t_accit_ext        = gt_accit_ext
      CHANGING
        needs_smbew_update = vw.
    upd_rw = x.
    CALL FUNCTION 'MIMB_VM07M_REFRESH'.                     "898769
    IF NOT vw IS INITIAL.
      CALL FUNCTION 'CKML_F_XMBEW_UPDATE'
        TABLES
          xmbew = xmbew
          xebew = xebew
*         xqbew = xqbew.                                      "kaz
          xqbew = xqbew                               "kaz
          xobew = xobew.                              "kaz
    ENDIF.
  ELSE.
ENHANCEMENT-SECTION     MM07MFF9_F_BELEG_ERGAENZEN_01 SPOTS ES_SAPMM07M.
* Bei unbewerteten Wareneingang
    CALL FUNCTION 'BP_CHECK_FUNDS_LAST'
      .
*- Check AVC if found
    PERFORM gmavc_check_fund_last(rgmledger_addon)
                IF FOUND.
END-ENHANCEMENT-SECTION.
  ENDIF.

PERFORM period_shift_check.                                   "1636844

ENDFORM.                    "F-BELEG_ERGAENZEN