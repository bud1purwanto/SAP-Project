*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_ITEM_GET_DATF01 .
*----------------------------------------------------------------------*
FORM customer_item_get_data .

  DATA: lv_dataloss TYPE dialog.

  IF go_screenbadi_cus_i IS BOUND.
    CALL BADI go_screenbadi_cus_i->transfer_data_from_subscreen
      EXPORTING
        is_t180     = t180
        is_cus_item_tab = gs_screenbadi_cus_i
      IMPORTING
        ev_dataloss = lv_dataloss
      CHANGING
        cv_fcode    = fcode
        cs_vbkd     = vbkd
        cs_vbap     = vbap
        cs_rv45a    = rv45a.
  ENDIF.

  IF r185d-dataloss IS INITIAL.
    r185d-dataloss = lv_dataloss.
  ENDIF.

ENDFORM.                    " CUSTOMER_ITEM_GET_DATA