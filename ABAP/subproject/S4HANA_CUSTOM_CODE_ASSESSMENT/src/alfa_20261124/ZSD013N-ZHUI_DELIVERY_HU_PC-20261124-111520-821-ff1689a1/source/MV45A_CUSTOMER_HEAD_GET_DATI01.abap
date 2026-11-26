*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_HEAD_GET_DATI01 .
*----------------------------------------------------------------------*
MODULE customer_head_get_data INPUT.

  DATA: lv_dataloss TYPE dialog.

  IF go_screenbadi_cus_h IS BOUND.
    CALL BADI go_screenbadi_cus_h->transfer_data_from_subscreen
      EXPORTING
        is_t180     = t180
        is_cus_head_tab = gs_screenbadi_cus_h
      IMPORTING
        ev_dataloss = lv_dataloss
      CHANGING
        cs_vbkd     = vbkd
        cs_rv45a    = rv45a
        cs_vbak     = vbak
        cv_fcode    = fcode.
  ENDIF.

  IF r185d-dataloss IS INITIAL.
    r185d-dataloss = lv_dataloss.
  ENDIF.

  PERFORM vbak_bearbeiten(sapfv45k).

ENDMODULE.                 " CUSTOMER_HEAD_GET_DATA  INPUT