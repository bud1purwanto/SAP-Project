*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_CHECK_CHANGE_MANAGEME                   *
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  check_change_management
*&--------------------------------------------------------------------*
form check_change_management using is_xlikp like likpvb.

  data: lf_cmoff        like t340d-cmoff_foreground,
        ls_t340d        like t340d,
        lf_title(40)    type c,
        lf_button1(20)  type c,
        lf_button2(20)  type c,
        lf_answer       like rsnewleng-fcode,
        lf_subrc        like sy-subrc,                      "n_551608
        lt_user_buttons type standard table of smp_dyntxt
                             with header line,
        lt_parameter    type standard table of spar.

* Special situation: Change management is active in general but has
* either be activated by the emergency flag (table LECMOFF) or the
* partner system can not be reached at the moment
* (COMMUNICATION_FAILURE)
  check v50agl-dlv_change ne space     and
        v50agl-dlv_change_off ne space.

* Central System: Refuse posting of the delivery if CHANGE_OFF flag is
* set
  if is_xlikp-verursys is initial.
    perform finchdel_handling(sapfv50p) using
                        is_xlikp-vbeln '05' 'E' 'VL' '479'
                            space space space space gt_finchdel.
    exit.
  endif.

* The following coding is relevant for the decentral system only

* If the goods movement is posted the change management needs not to be
* deactivated
  if v50agl-warenausgang ne space.
    clear v50agl-dlv_change_off.
  endif.

  check not is_xlikp-lgnum is initial.

* Read customizing settings to decide how to proceed further
  select single * from t340d
                  into ls_t340d
                  where lgnum eq is_xlikp-lgnum.

* Background mode?
  if gs_mhpar-glomd ca gc_glomd-backgr_all.
    lf_cmoff = ls_t340d-cmoff_background.
  else.
    lf_cmoff = ls_t340d-cmoff_foreground.
  endif.

  case lf_cmoff.
    when space.
*     Change of the current document is refused
      clear r185d-dataloss.                                 "n_546918
      perform finchdel_handling(sapfv50p) using
                          is_xlikp-vbeln '05' 'E' 'VL' '479'
                              space space space space gt_finchdel.
      lf_subrc = 4.                                         "n_551608
    when 'A'.
*     Do nothing here; V50AGL-DLV_CHANGE_OFF causes the creation of the
*     IDOC to switch VLSTK to 'F' in both systems
      lf_subrc = 0.                                         "n_551608
    when 'B'.
      lf_button1 = text-085.
      lf_title   = text-087.

      lt_user_buttons-text = lf_button1.
      lt_user_buttons-icon_id = '@2L@'. "ICON_SYSTEM_SAVE
      append lt_user_buttons.

      call function 'POPUP_DISPLAY_TEXT_USER_BUTTON'
        exporting
          language              = sy-langu
          popup_title           = lf_title
          docu_class            = 'DT'
          text_object           = 'LE_SHP_CHANGE_MANAG_DEACTIV'
          display_ok_button     = ' '
          display_cancel_button = 'X'
        importing
          answer                = lf_answer
        tables
          user_buttons          = lt_user_buttons
          parameter             = lt_parameter
        exceptions
          error_in_text         = 1
          text_not_found        = 2
          others                = 3.

      if sy-subrc ne 0.
        lf_answer = 'CANCEL'.
      endif.
      case lf_answer.
        when 'BUTTON1'.
*         Nothing todo here; V50AGL-DLV_CHANGE_OFF will initiate the
*         IDoc that changes VLSTK to 'F'
          lf_subrc = 0.                                     "n_551608
        when 'CANCEL'.
*         Change of the current document is refused
          clear r185d-dataloss.                             "n_546918
          perform finchdel_handling(sapfv50p) using
                              is_xlikp-vbeln '05' 'E' 'VL' '479'
                                  space space space space gt_finchdel.
          lf_subrc = 4.                                     "n_551608
      endcase.

  endcase.

* Saving is only allowed if neither the complete delivery   "v_n_551608
* nor single items are deleted
  if lf_subrc eq 0.
    loop at xlips transporting no fields
                  where updkz eq updkz_delete.
      exit.
    endloop.
    if sy-subrc eq 0.
      clear r185d-dataloss.
      perform finchdel_handling(sapfv50p) using
                          is_xlikp-vbeln '05' 'E' 'VL' '495'
                              space space space space gt_finchdel.
    endif.
  endif.                                                    "^_n_551608

endform.                    "check_change_management