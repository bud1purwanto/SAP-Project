*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_ITEM_PASS_FCF01 .
*----------------------------------------------------------------------*
FORM customer_item_pass_fcode .

  IF go_screenbadi_cus_i IS BOUND.
    CALL BADI go_screenbadi_cus_i->pass_fcode_to_subscreen
      EXPORTING
        is_cus_item_tab = gs_screenbadi_cus_i
        iv_fcode_same_page = fcode_gleiche_seite
        iv_fcode           = fcode.
  ENDIF.

ENDFORM.                    " CUSTOMER_ITEM_PASS_FCODE