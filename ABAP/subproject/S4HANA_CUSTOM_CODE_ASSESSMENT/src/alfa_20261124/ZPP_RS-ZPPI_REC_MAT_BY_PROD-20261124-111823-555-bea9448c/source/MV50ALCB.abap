*----------------------------------------------------------------------*
*   INCLUDE MV50ALCB                                                   *
*----------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Form  UC_PF_STATUS_SET
*&---------------------------------------------------------------------*
*       Called from Listviewer Uncompleteness Processing
*----------------------------------------------------------------------*
*      -->P_CUA_EXCLUDE  text                                        *
*----------------------------------------------------------------------*
form uc_pf_status_set using it_cua_exclude type slis_t_extab.

  data: lt_cua_exclude_save type shp_cua_exclude_t.

  append lines of cua_exclude to lt_cua_exclude_save.

  refresh cua_exclude.
  sort it_cua_exclude by fcode.
  delete adjacent duplicates from it_cua_exclude comparing fcode.
  insert lines of it_cua_exclude into table cua_exclude.

  perform cua_setzen.

  refresh cua_exclude.
  append lines of lt_cua_exclude_save to cua_exclude.

endform.                    " UC_PF_STATUS_SET



*&---------------------------------------------------------------------*
*&      Form  uc_USER_COMMAND
*&---------------------------------------------------------------------*
*       Called from Listviewer
*----------------------------------------------------------------------*
*      -->P_PS_FCODE  text                                             *
*      -->P_PS_SELFIELD  text                                          *
*----------------------------------------------------------------------*
form uc_lv_user_command using    p_fcode like sy-ucomm
                              p_selfield type slis_selfield.

  case p_fcode.
    when 'UCDO'.
*---------leave list_viewer setting return_code:
      p_selfield-exit = 'X'.
    when '&ELP'.
*---------F1 for the ddtxt field ?
      check p_selfield-sel_tab_field eq 'PVBUV-DDTEXT'.
      clear p_fcode.       "get control !!!
      perform listfield_docu(sapfv50u) using p_selfield.
    when 'UCRF'.
*---------complete new recalc of uncompleteness data:
      perform uc_complete_recalc(sapfv50u).
      p_selfield-refresh = 'X'.
      p_selfield-col_stable = 'X'.
  endcase.

endform.                    " uc_lv_USER_COMMAND