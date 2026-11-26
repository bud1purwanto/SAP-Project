*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50ADIA_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /spe/ret_select_screen
*&---------------------------------------------------------------------*
FORM /spe/ret_select_screen .

  IF likp-vbtyp EQ vbtyp_lire.
    gf_returns_subscreen = '1120'.
  ELSE.
    gf_returns_subscreen = '1124'.
  ENDIF.

ENDFORM.                    " /spe/ret_select_screen