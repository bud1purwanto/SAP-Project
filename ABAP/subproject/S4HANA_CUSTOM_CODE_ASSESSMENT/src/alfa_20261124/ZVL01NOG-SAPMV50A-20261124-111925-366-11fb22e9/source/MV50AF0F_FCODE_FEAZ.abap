***INCLUDE MV50AF0F_FCODE_FEAZ .
*---------------------------------------------------------------------*
*       FORM FCODE_FEAZ                                               *
*---------------------------------------------------------------------*
*       Aufruf der Problemliste                                       *
*----------------------------------------------------------------------*
form fcode_feaz.

  data: xa_lines           type p,
        dynnr              like sy-dynnr,
        ls_appl_log_head   type bal_s_log,
        ls_bal_fcat        type bal_s_fcat,
        ls_display_profile type bal_s_prof.

  field-symbols: <ls_bal_fcat> type bal_s_fcat.

*---- Fehlerprotokoll aufbereiten -------------------------------------
  describe table cvbfs lines xa_lines.
  if xa_lines eq 0.
    message s017.
    fcode = fcode_gleiche_seite.
    exit.
  endif.

*---- Fehlerprotokoll ausgeben ----------------------------------------

  dynnr = sy-dynnr.

  leave to list-processing and return to screen dynnr.

  set pf-status 'FE  ' excluding cua_exclude.
  set titlebar 'F01 '.
  loop at cvbfs where msgno = '033'
                  and msgid = 'VL'.
    loop at gt_splitprot into gs_splitprot
          where vbeln = cvbfs-vbeln
          and   posnr = cvbfs-posnr.
      cvbfs-msgv1 = cvbfs-posnr.
      cvbfs-msgv2 = gs_splitprot-feld.
      cvbfs-msgv3 = gs_splitprot-feldwert1.
      cvbfs-msgv4 = gs_splitprot-feldwert2.
      exit.
    endloop.
    modify cvbfs from cvbfs.
  endloop.

* Old tree error log replaced 470
*  CALL FUNCTION 'VBFS_TREE_LIST_DISPLAY'
**      EXPORTING
**           I_VBFS_S_CB_PROGRAM      =
**           I_VBFS_CB_PROGRAM        =
**           I_VBFS_S_CB_USER_COMMAND =
**           I_VBFS_CB_USER_COMMAND   =
**           I_VBFS_S_CB_GUI_STATUS   =
**           I_VBFS_CB_GUI_STATUS     =
**           I_VBFS_CALLED_BY         = ' '
*       TABLES
*            I_VBFS                       = CVBFS.
*

  call function 'BAL_DSP_PROFILE_NO_TREE_GET'
    importing
      e_s_display_profile = ls_display_profile.

  clear ls_bal_fcat.
  ls_bal_fcat-ref_table = 'LESHP_LOG_VBFS_CONTEXT'.
  ls_bal_fcat-ref_field = 'VBELN'.
  ls_bal_fcat-col_pos = 2.
  append ls_bal_fcat to ls_display_profile-mess_fcat.
  clear ls_bal_fcat.
  ls_bal_fcat-ref_table = 'LESHP_LOG_VBFS_CONTEXT'.
  ls_bal_fcat-ref_field = 'POSNR'.
  ls_bal_fcat-col_pos = 3.
  append ls_bal_fcat to ls_display_profile-mess_fcat.

  loop at ls_display_profile-mess_fcat assigning <ls_bal_fcat>.
    case <ls_bal_fcat>-ref_field.
      when 'VBELN'.
        <ls_bal_fcat>-col_pos  = 2.
        <ls_bal_fcat>-hotspot  = charx.                        "n_693545
      when 'POSNR'.
        <ls_bal_fcat>-col_pos  = 3.
      when 'T_MSG'.
        <ls_bal_fcat>-col_pos  = 4.
    endcase.
  endloop.

* Use grid for displaying messages; optimize column width
  ls_display_profile-use_grid = charx.
  ls_display_profile-cwidth_opt = charx.

* Parameters for layout administration
  ls_display_profile-disvariant-report    = 'SAPMV50A'.
  ls_display_profile-disvariant-handle    = 'ELOG'.
  ls_display_profile-disvariant-log_group = '6'.
  ls_display_profile-disvariant-username  = sy-uname.

* define callback to react on hotspot - as for pushbutton    "v_n_693545
  ls_display_profile-clbk_ucom-userexitt     = ' '.
  ls_display_profile-clbk_ucom-userexitp     = 'SAPMV50A'.
  ls_display_profile-clbk_ucom-userexitf     = 'CALL_BACK_FOR_HOTSPOT'.
                                                             "^_n_693545

  call function 'LE_SHP_VBFS2BAL_DISPLAY'
    exporting
      is_appl_log_head      = ls_appl_log_head
      it_vbfs               = cvbfs[]
      is_display_profile    = ls_display_profile
    exceptions
      no_log_needed         = 0
      profile_inconsistent  = 0
      internal_error        = 0
      no_data_available     = 0
      no_authority          = 0
      error_in_subfunctions = 0
      others                = 0.

* If VL01N is called by CALL TRANSACTION and no items could be created:
* Leave transaction and return to caller here.
  if sy-dynnr eq '4001' and sy-calld eq charx.
    leave.
  endif.

* Transaktionsvarianten prüfen                              "v_n_902128
  if sy-dynnr eq '4001'.
    data: lf_subrc like sy-subrc,
          lf_xclientind TYPE c.

    CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'
         IMPORTING
              TCVARIANT                     = gf_tcvariant
              FLAG_CLIENT_INDEPENDENT       = lf_xclientind
              RC                            = lf_subrc.
    if lf_subrc eq 2.
*     Transaktionsvariante aktiv
      CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'
             EXPORTING
                  TCODE                           = sy-tcode
                  VARIANT                         = gf_tcvariant
                  I_FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                  CALL_MODE                       = space.
    endif.
  endif.
* Ende Transaktionsvarianten prüfen                         "^_n_902128

  fcode = fcode_gleiche_seite.

endform.                    "FCODE_FEAZ

                                                            "v_n_693545
*---------------------------------------------------------------------*
*       FORM CALL_BACK_FOR_HOTSPOT                                    *
*---------------------------------------------------------------------*
form call_back_for_hotspot changing cs_ucomm_data TYPE bal_s_cbuc.

  data: ls_cvbfs like line of cvbfs.

  check cs_ucomm_data-list_hotsp eq charx.                     "n_791294

  read table cvbfs into ls_cvbfs
                   index cs_ucomm_data-LIST_MSGH-MSGNUMBER.
  if tvlk-aufer = 'B'.                                       "v_n_861142
    CALL FUNCTION 'RV_CALL_DISPLAY_TRANSACTION'
      EXPORTING
        vbeln          = ls_cvbfs-vbeln
        vbtyp          = 'V'.
  else.
    CALL FUNCTION 'RV_CALL_DISPLAY_TRANSACTION'
      EXPORTING
        vbeln          = ls_cvbfs-vbeln.
  endif.                                                     "^_n_861142
endform.                                                     "^_n_693545