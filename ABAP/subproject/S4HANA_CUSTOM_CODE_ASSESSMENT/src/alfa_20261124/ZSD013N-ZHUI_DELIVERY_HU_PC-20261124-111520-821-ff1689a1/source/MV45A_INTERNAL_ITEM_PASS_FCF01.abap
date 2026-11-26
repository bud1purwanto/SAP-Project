*----------------------------------------------------------------------*
***INCLUDE MV45A_INTERNAL_ITEM_PASS_FCF01 .
*----------------------------------------------------------------------*
FORM internal_item_pass_fcode .

  IF gs_screenbadi_int_i-handler IS BOUND.
    CALL METHOD gs_screenbadi_int_i-handler->pass_fcode_to_subscreen
      EXPORTING
        is_int_item_tab    = gs_screenbadi_int_i
        iv_fcode_same_page = fcode_gleiche_seite
        iv_fcode           = fcode.
  ENDIF.

ENDFORM.                    " INTERNAL_ITEM_PASS_FCODE