*----------------------------------------------------------------------*
***INCLUDE MV45AI_MSR .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MSR_INIT  INPUT
*&---------------------------------------------------------------------*
MODULE msr_init INPUT.
  PERFORM msr_init.
ENDMODULE.                 " MSR_INIT  INPUT
**&---------------------------------------------------------------------*
**&      Module  MSR_CHECK_NEXT_PLANT  INPUT
**&---------------------------------------------------------------------*
*MODULE msr_check_next_plant INPUT.
*  PERFORM msr_check_next_plant USING chare.
*ENDMODULE.                 " MSR_CHECK_NEXT_PLANT  INPUT
**&---------------------------------------------------------------------*
**&      Module  MSR_BUFFER_DATA  INPUT
**&---------------------------------------------------------------------*
*MODULE msr_buffer_data INPUT.
*  IF gr_msr_sales IS NOT BOUND.
*    RETURN.
*  ENDIF.
*  gr_msr_sales->update_data_to_buffer(
*    EXPORTING
*      is_msr_sales_item = gs_msr_sales_item
*      is_vbap           = vbap
*      is_vbak           = vbak ).
*ENDMODULE.                 " MSR_BUFFER_DATA  INPUT
**&---------------------------------------------------------------------*
**&      Module  MSR_CHECK_SCREEN  INPUT
**&---------------------------------------------------------------------*
*MODULE msr_check_screen INPUT.
*  PERFORM msr_check_screen USING charx.
*ENDMODULE.                 " MSR_CHECK_SCREEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_PROCESS_ITEM  INPUT
*&---------------------------------------------------------------------*
*MODULE msr_process_item INPUT.
*  PERFORM msr_process_item.
*ENDMODULE.                 " MSR_PROCESS_ITEM  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FCODE  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fcode INPUT.
  PERFORM msr_fcode.
ENDMODULE.                 " MSR_FCODE  INPUT
**&---------------------------------------------------------------------*
**&      Module  MSR_CHECK_APPROVAL  INPUT
**&---------------------------------------------------------------------*
*MODULE msr_check_approval INPUT.
*  IF gr_msr_sales IS NOT BOUND.
*    RETURN.
*  ENDIF.
*  gr_msr_sales->check_approval(
*    EXPORTING
*      is_vbak  = vbak
*      it_xvbap = xvbap[]
*      is_rv45a = rv45a
*    CHANGING
*      cs_vbup  = vbup
*      cs_vbap  = vbap ).
*ENDMODULE.                 " MSR_CHECK_APPROVAL  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_CHECK_VENDOR  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_check_vendor INPUT.
  PERFORM msr_fastchange_check_vendor.
ENDMODULE.                 " MSR_FASTCHANGE_CHECK_VENDOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_CHECK_ADRNR  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_check_adrnr INPUT.
  PERFORM msr_fastchange_check_adrnr.
ENDMODULE.                 " MSR_FASTCHANGE_CHECK_ADRNR  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_CHECK_NEXTPLANT  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_check_nextplant INPUT.
  PERFORM msr_fastchange_check_nextplant.
ENDMODULE.                 " MSR_FASTCHANGE_CHECK_NEXTPLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_CHECK_CLEARFLAG  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_check_clearflag INPUT.
  IF gs_msr_sales_fastchange-ret_reason_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-ret_reason.
  ENDIF.
  IF gs_msr_sales_fastchange-fu_code_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-fu_code.
  ENDIF.
  IF gs_msr_sales_fastchange-refund_control_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-refund_control.
  ENDIF.
  IF gs_msr_sales_fastchange-refund_code_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-refund_code.
  ENDIF.
  IF gs_msr_sales_fastchange-rma_vendor_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-rma_vendor.
  ENDIF.
  IF gs_msr_sales_fastchange-inspection_code_x EQ abap_true.
    CLEAR gs_msr_sales_fastchange-inspection_code.
  ENDIF.
ENDMODULE.                 " MSR_FASTCHANGE_CHECK_CLEARFLAG  INPUT


*----------------------------------------------------------------------*
*  MODULE msr_fastchange_check_update INPUT
*----------------------------------------------------------------------*
MODULE msr_fastchange_check_update INPUT.

  IF fcode NE fcode_abbrechen AND
     fcode NE 'SUEB'.
    PERFORM msr_fastchange_update_check.
  ENDIF.

ENDMODULE.                    "msr_fastchange_check_update INPUT


*&---------------------------------------------------------------------*
*&      Module  TEST_RRC_SHORTENED  INPUT
*&---------------------------------------------------------------------*
MODULE confirm_rrc_change INPUT.
  PERFORM confirm_rrc_change.
ENDMODULE.                 " TEST_RRC_SHORTENED  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_FCODE_NPLANT  INPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_fcode_nplant INPUT.
* Maintenance of Nextplants in fastchange is removed as this function requires
* information about the item scenario like plant, FU-Code, Material received, which
* is not available for fastchange of several items
*  PERFORM msr_fastchange_fcode_nplant.
ENDMODULE.                 " MSR_FASTCHANGE_FCODE_NPLANT  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_CHECK_BATCH  INPUT
*&---------------------------------------------------------------------*
*MODULE msr_check_batch INPUT.
*  PERFORM msr_check_batch.
*ENDMODULE.                 " MSR_CHECK_BATCH  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_CHG_FCODE  INPUT
*&---------------------------------------------------------------------*
MODULE msr_chg_fcode INPUT.
  PERFORM msr_chg_fcode.
ENDMODULE.                 " MSR_CHG_FCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_MAP_FIELDS_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE msr_map_fields_pai INPUT.
  PERFORM msr_map_fields_pai.
ENDMODULE.                 " MSR_MAP_FIELDS_PAI  INPUT