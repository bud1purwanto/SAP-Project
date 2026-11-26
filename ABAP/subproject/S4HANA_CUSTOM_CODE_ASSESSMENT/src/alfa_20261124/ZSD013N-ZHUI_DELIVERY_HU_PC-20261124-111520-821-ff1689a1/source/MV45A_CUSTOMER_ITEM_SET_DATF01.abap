*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_ITEM_SET_DATF01 .
*----------------------------------------------------------------------*
FORM customer_item_set_data .

  IF go_screenbadi_cus_i IS BOUND.
    CALL BADI go_screenbadi_cus_i->transfer_data_to_subscreen
      EXPORTING
        is_cus_item_tab = gs_screenbadi_cus_i
        iv_tabix = svbap-tabix
        is_t180  = t180
        is_vbak  = vbak
        is_rv45a = rv45a
        is_vbkd  = vbkd
        is_vbap  = vbap.
  ENDIF.

ENDFORM.                    " CUSTOMER_ITEM_SET_DATA