*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_HEAD_SET_DATF01 .
*----------------------------------------------------------------------*
FORM customer_head_set_data .

  IF go_screenbadi_cus_h IS BOUND.
    CALL BADI go_screenbadi_cus_h->transfer_data_to_subscreen
      EXPORTING
        is_cus_head_tab = gs_screenbadi_cus_h
        is_vbak     = vbak
        is_vbkd     = vbkd
        is_t180     = t180
        is_rv45a    = rv45a.
  ENDIF.

ENDFORM.                    " CUSTOMER_HEAD_SET_DATA