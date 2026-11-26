*----------------------------------------------------------------------*
***INCLUDE MV45AO0C_CHAR_VA_SEL_DISPLAY .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CHAR_VA_SEL_DISPLAYLIST  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE char_va_sel_displaylist OUTPUT.

  DATA: ma_tabix LIKE sy-tabix.

  IF sy-stepl > ueco_col_count.
    EXIT FROM STEP-LOOP.
  ENDIF.

  ma_tabix = sy-stepl + tctrl_char_va_sel_lin1 - 1.
  READ TABLE xmerkmal WITH KEY INDEX = ma_tabix.
  IF sy-subrc eq 0.
    MOVE-CORRESPONDING xmerkmal TO char_va_sel.
  ELSE.
    CLEAR char_va_sel.
  ENDIF.

ENDMODULE.                             " CHAR_VA_SEL_DISPLAYLIST  OUTPUT







