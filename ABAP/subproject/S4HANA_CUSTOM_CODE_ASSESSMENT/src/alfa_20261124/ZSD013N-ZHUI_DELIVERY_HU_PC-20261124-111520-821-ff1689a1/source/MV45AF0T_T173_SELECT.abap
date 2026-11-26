*&---------------------------------------------------------------------*
*&  Include           MV45AF0T_T173_SELECT
*&---------------------------------------------------------------------*
form t173_select using us_vsart
                       us_error
                       ch_subrc.

  ch_subrc = 0.
  check: us_vsart ne t173-vsart.

  if us_vsart = space.
    clear: t173, t173t.
    exit.
  endif.

  select single * from t173 where vsart = us_vsart.
  if sy-subrc ne 0.
    clear: t173, t173t.
    if us_error ne space.
      message e173(v2) with us_vsart.
    else.
      ch_subrc = 4.
      exit.
    endif.
  endif.

endform.                    "t173_select