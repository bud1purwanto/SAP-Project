*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_DEACTIVATE_PUSHBU                             *
*----------------------------------------------------------------------*
form cua_deactivate_pushbutton changing cf_exit_flag type c.

  data: lf_prefix(5) type c,
        lf_fcode type fcode.

  check screen-name cs 'BT_'.

  split screen-name at '_' into lf_prefix lf_fcode.
  read table cua_exclude with table key function = lf_fcode
                         transporting no fields.
  if sy-subrc eq 0.
    screen-input = 0.
*   Suppress button for batch creation completely if        "v_n_616979
*   inactive (save horizontal space on small windows)
    if screen-name eq 'BT_CHCR_T'.
      screen-active = 0.
    endif.                                                  "^_n_616979
    cf_exit_flag = charx.
    exit.
  endif.

endform.                    "CUA_DEACTIVATE_PUSHBUTTON