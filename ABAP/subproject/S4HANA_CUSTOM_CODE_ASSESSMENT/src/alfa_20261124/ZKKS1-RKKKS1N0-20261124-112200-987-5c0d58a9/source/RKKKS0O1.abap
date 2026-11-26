*---------------------------------------------------------------------*
* INITIALIZATION
*---------------------------------------------------------------------*
initialization.
  perform limit_process using sy-repid.

  perform kass_fw_init
     using
        'KVAR'
        kass_fw_default_init_options.

  perform kass_fw_event_register
     using
        kass_fw_event-start_of_selection
        'START_OF_SELECTION_MAIN'
        kass_fw_priority-main
        kass_fw_default_reg_options.

  perform kass_fw_event_register using
     kass_fw_event-selection_screen_output
     'ICON_CHANGE'
     kass_fw_priority-main
     kass_fw_default_reg_options.

  perform kass_fw_event_register using:
     kass_fw_event-selection_screen
     'JUST_DO_IT'
     kass_fw_priority-main
     kass_fw_default_reg_options.

* Set function code...
  PA_OKCOD = 'AUSF'.
* Set report name...
  PA_REPID = SY-REPID.
  READ TEXTPOOL PA_REPID INTO TA_TXTPL.
* Set flag collective processing...
  PA_SAMML = CON_X.
* Set transaction code...
  pa_tcode = pa_repid+2(5).
* Set transaction code...
  perform transaktion_setzen in program sapmkks0
    using    pa_tcode '2000'
    changing pa_tcode pa_dynnr.


*---------------------------------------------------------------------*
* ICON_CHANGE                                                         *
*---------------------------------------------------------------------*
form icon_change.

  IF SY-BATCH IS INITIAL.
*   Set Kokrs...
    GET PARAMETER ID 'CAC' FIELD PA_KOKRS.
*   Set period...
    IF NOT pa_KOKRS IS INITIAL.
      IF pa_GJAHR IS INITIAL.
        GET PARAMETER ID 'GJR' FIELD pa_GJAHR.
      ENDIF.
      IF pa_POPER IS INITIAL.
        GET PARAMETER ID 'VPE' FIELD pa_POPER.
      ENDIF.
      IF  pa_GJAHR IS INITIAL
       OR pa_POPER IS INITIAL.
        CALL FUNCTION 'K_PERIODS_GET'
          EXPORTING
            PAR_IGJAHR    = pa_GJAHR
            PAR_IPOPER    = pa_POPER
            PAR_KOKRS     = pa_KOKRS
            PAR_PREVP     = CON_X
            PAR_SPEOK     = CON_CHAR
          IMPORTING
            PAR_EGJAHR    = pa_GJAHR
            PAR_EPOPER    = pa_POPER.
      ENDIF.
    ENDIF.
*   Get target versions...
    if not pa_awvse is initial.
      flg_awvse = con_x.
    else.
      flg_awvse = con_char.
    endif.
    PERFORM SOLLVERSIONEN_BESORGEN in program sapmkks0
      tables   ta_kv20a ta_kv20b
*     using    pa_samml pa_inclf pa_incli pa_inclp
      using    pa_samml con_x    con_x    con_x
               pa_objkt pa_awvrs pa_kokrs pa_tcode
               pa_okcod con_awoba-or con_x
      changing pa_anzvs pa_awvse pa_awval pa_vssel
               pa_vsall pa_initi.
*   Set comments...
    LOOP AT TA_TXTPL
      WHERE ID = 'I'.
      CASE TA_TXTPL-KEY.
        WHEN 'ALL'.
          SA_AWVAL = TA_TXTPL-ENTRY.
        WHEN 'VSE'.
          SA_AWVSE = TA_TXTPL-ENTRY.
        WHEN 'LIS'.
          SA_LISTF = TA_TXTPL-ENTRY.
      ENDCASE.
    ENDLOOP.
*   Set icons...
    if not p_kks00c is initial.
      hlp_listf = con_x.
    else.
      clear hlp_listf.
    endif.
    if not pa_vssel is initial.
      hlp_awvse = con_x.
    else.
      clear hlp_awvse.
    endif.

*   Set correct icons on pushbuttons...
    if hlp_listf = con_x.
      write: icon_display_more to pb_listf as icon.
      write: text-I01 to pb_listf+4.
    else.
      write: icon_enter_more to pb_listf as icon.
      write: text-I01 to pb_listf+4.
    endif.
    if hlp_awvse = con_x.
      write: icon_display_more to pb_awvse as icon.
      write: text-I02 to pb_awvse+4.
    else.
      write: icon_enter_more to pb_awvse as icon.
      write: text-I02 to pb_awvse+4.
    endif.

*   refresh dynpro fields...
    sa_vsall = pa_vsall.
    sa_vssel = pa_vssel.

    loop at screen.
      if screen-name = 'PB_LISTF'
       and pa_listf is initial.
        screen-active = 0.
        modify screen.
      elseif screen-name ='PB_AWVSE'
       and flg_awvse is initial
       and pa_awvse is initial.
        screen-active = 0.
        modify screen.
      endif.
    endloop.
  endif.

endform.

*---------------------------------------------------------------------*
* JUST_DO_IT                                                          *
*---------------------------------------------------------------------*
form just_do_it.

  case sscrfields-ucomm.
    when 'LIST'.
*     Set list parameters...
      if pa_listf is initial.
        message e244(kd).
      else.
        CALL FUNCTION 'K_VARIANCES_BATCH_CONFIG_46A'
          EXPORTING
            I_USER            = 'B'
          CHANGING
            C_LIST_PARAM      = P_KKS00C.

        if not p_kks00c is initial.
          hlp_listf = con_x.
        endif.
      endif.

    when 'AVER'.
*     Set target versions...
*     if pa_awvse is initial.
*       message e244(kd).
*     else.
        REFRESH TA_KV20A.
        CALL FUNCTION 'K_VARIANCE_VERSION_SELECT'
          EXPORTING
            PAR_SPRAS           = SY-LANGU
            PAR_AWOBA           = CON_AWOBA-OR
            PAR_AWVKZ           = CON_X
            PAR_VINDX           = CON_X
            PAR_KOKRS           = PA_KOKRS
            PAR_TCODE           = PA_TCODE
         TABLES
            TAB_KV20A1          = TA_KV20A
            TAB_KV20B1          = TA_KV20B.

*       Get target versions...
        pa_initi = con_x.
        PERFORM SOLLVERSIONEN_BESORGEN in program sapmkks0
          tables   ta_kv20a ta_kv20b
*         using    pa_samml pa_inclf pa_incli pa_inclp
          using    pa_samml con_x    con_x    con_x
                   pa_objkt pa_awvrs pa_kokrs pa_tcode
                   pa_okcod con_awoba-or con_x
          changing pa_anzvs pa_awvse pa_awval pa_vssel
                   pa_vsall pa_initi.
*     endif.

    when 'LIOK'.
*     Detail list...

    when 'VSOK'.
*     Versions...
      if not pa_awvse is initial
       and pa_vssel is initial.
        message s018.
      endif.

    when 'TEST'.
*     Test mode...
      CALL FUNCTION 'K_TEST_MODE_SET'
        IMPORTING
          PAR_TSTKZ = PA_TSTKZ
          PAR_FORTS = PA_FORTS
          PAR_VERWS = PA_VERWS
          PAR_KKS04 = PA_KKS04.

    when 'KKRS'.
*     Set controlling aread...
      perform kokrs_setzen(sapmkks0).

    WHEN 'SDEL'.
*     Delete set target versions...
      PERFORM INDX_SOLLVERSIONEN_KEY_SETZEN(SAPMKKS0)
        USING PA_TCODE PA_KOKRS SPACE.
      PERFORM INDX_SOLLVERSIONEN_LOESCHEN(SAPMKKS0)
        USING PA_TCODE.
  endcase.

endform.
*&---------------------------------------------------------------------*
*&      Form  limit_process
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM limit_process  USING  id_repid type syrepid.

* check if transaction is allowed
  data: ld_subrc type sysubrc.

  call function 'FB0C_LIMIT_PROCESS'
    EXPORTING
      ID_REPID           = id_repid
      ID_NO_DIALOG       = space
    IMPORTING
      ED_SUBRC           = ld_subrc.
  if not ld_subrc is initial.
    leave program.
  endif.

ENDFORM.                    " limit_process