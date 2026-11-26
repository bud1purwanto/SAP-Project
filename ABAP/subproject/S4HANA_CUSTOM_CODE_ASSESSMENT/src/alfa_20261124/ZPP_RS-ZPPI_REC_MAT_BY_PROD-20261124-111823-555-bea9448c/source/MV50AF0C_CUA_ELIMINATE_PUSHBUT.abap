*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_ELIMINATE_PUSHBUT                             *
*----------------------------------------------------------------------*
form cua_eliminate_pushbutton.

  data: lf_prefix(5) type c,
        lf_fcode type fcode.

  check screen-name cs 'BT_'.

  split screen-name at '_' into lf_prefix lf_fcode.
  read table cua_exclude with table key function = lf_fcode
                         transporting no fields.
  if sy-subrc eq 0.
    screen-invisible = 0.
  endif.

endform.                    "cua_eliminate_pushbutton