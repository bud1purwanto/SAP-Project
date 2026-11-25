REPORT ztrain_badi_mock.
* Mock class lokal untuk syntax check method BAdI latihan
* (field ZZTRN_REMARK diganti ZLINE karena append latihan belum dibuat)
CLASS lcl_trn_so_item_tab DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_ex_sls_item_scr_cus.
ENDCLASS.

CLASS lcl_trn_so_item_tab IMPLEMENTATION.
  METHOD if_ex_sls_item_scr_cus~activate_tab_page.
    DATA: ls_tab TYPE LINE OF sales_cust_tab_page_t.
    ls_tab-item_caption = 'Latihan BAdI'.
    ls_tab-item_program = 'SAPLZTRN_SO_TAB'.
    ls_tab-item_dynpro  = '9001'.
    APPEND ls_tab TO ct_cus_item_tab.
  ENDMETHOD.

  METHOD if_ex_sls_item_scr_cus~transfer_data_to_subscreen.
    DATA: lv_display TYPE c.
    IF sy-tcode = 'VA03'.
      lv_display = 'X'.
    ENDIF.
    CALL FUNCTION 'Z_TRN_SO_TAB_SET'
      EXPORTING
        iv_remark  = is_vbap-zline
        iv_display = lv_display.
  ENDMETHOD.

  METHOD if_ex_sls_item_scr_cus~transfer_data_from_subscreen.
    CALL FUNCTION 'Z_TRN_SO_TAB_GET'
      IMPORTING
        ev_remark = cs_vbap-zline.
  ENDMETHOD.

  METHOD if_ex_sls_item_scr_cus~pass_fcode_to_subscreen.
  ENDMETHOD.
ENDCLASS.
