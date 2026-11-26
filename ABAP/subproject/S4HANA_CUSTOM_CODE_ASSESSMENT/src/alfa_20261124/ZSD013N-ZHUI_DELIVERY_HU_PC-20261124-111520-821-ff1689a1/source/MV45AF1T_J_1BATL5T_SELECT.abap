*&---------------------------------------------------------------------*
*&  Include           MV45AF1T_J_1BATL5T_SELECT                        *
*&---------------------------------------------------------------------*

form j_1batl5t_select using us_j_1btaxlw5 type j_1btaxlw5
                            ch_subrc      like sy-subrc.

  clear: ch_subrc.

  if us_j_1btaxlw5 is initial.
    clear: j_1batl5t.
    exit.
  endif.

  select single * from j_1batl5t where langu    eq sy-langu
                                 and   taxlaw   eq us_j_1btaxlw5.

  if not ( sy-subrc is initial ).
    clear: j_1batl5t.
    ch_subrc = 4.
  endif.

endform.                               " J_1BATL5T_SELECT