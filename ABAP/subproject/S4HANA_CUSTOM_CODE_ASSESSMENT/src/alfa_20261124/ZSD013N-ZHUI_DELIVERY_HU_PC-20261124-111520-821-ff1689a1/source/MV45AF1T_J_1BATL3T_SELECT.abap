*&---------------------------------------------------------------------*
*&  Include           MV45AF1T_J_1BATL3T_SELECT                        *
*&---------------------------------------------------------------------*

form j_1batl3t_select using us_j_1btaxlw3 type J_1BTAXLW3
                            ch_subrc      like sy-subrc.

  clear: ch_subrc.

  if us_j_1btaxlw3 is initial.
    clear: j_1batl3t.
    exit.
  endif.

  select single * from j_1batl3t where langu    eq sy-langu
                                 and   taxlaw   eq us_j_1btaxlw3.

  if not ( sy-subrc is initial ).
    clear: j_1batl3t.
    ch_subrc = 4.
  endif.

endform.                               " J_1BATL3T_SELECT