*&---------------------------------------------------------------------*
*&  Include           MV45AF1T_J_1BATL4T_SELECT                        *
*&---------------------------------------------------------------------*

form j_1batl4t_select using us_j_1btaxlw4 type j_1btaxlw4
                            ch_subrc      like sy-subrc.

  clear: ch_subrc.

  if us_j_1btaxlw4 is initial.
    clear: j_1batl4t.
    exit.
  endif.

  select single * from j_1batl4t where langu    eq sy-langu
                                 and   taxlaw   eq us_j_1btaxlw4.

  if not ( sy-subrc is initial ).
    clear: j_1batl4t.
    ch_subrc = 4.
  endif.

endform.                               " J_1BATL4T_SELECT