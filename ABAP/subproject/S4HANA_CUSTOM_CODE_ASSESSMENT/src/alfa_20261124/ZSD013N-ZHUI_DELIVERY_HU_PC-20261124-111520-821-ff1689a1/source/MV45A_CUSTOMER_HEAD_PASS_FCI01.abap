*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_HEAD_PASS_FCI01 .
*----------------------------------------------------------------------*
MODULE customer_head_pass_fcode INPUT.

  IF go_screenbadi_cus_h IS BOUND.
    CALL BADI go_screenbadi_cus_h->pass_fcode_to_subscreen
      EXPORTING
        is_cus_head_tab = gs_screenbadi_cus_h
        iv_fcode_same_page = fcode_gleiche_seite
        iv_fcode           = fcode.
  ENDIF.

ENDMODULE.                 " CUSTOMER_HEAD_PASS_FCODE  INPUT