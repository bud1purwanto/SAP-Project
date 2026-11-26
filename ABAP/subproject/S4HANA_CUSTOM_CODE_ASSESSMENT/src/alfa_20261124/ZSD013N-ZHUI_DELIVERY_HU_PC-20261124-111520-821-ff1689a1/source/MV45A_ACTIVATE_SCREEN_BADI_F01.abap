*----------------------------------------------------------------------*
***INCLUDE MV45A_ACTIVATE_SCREEN_BADI_F01 .
*----------------------------------------------------------------------*
FORM deactivate_screen_badi_tab.

  DATA: lv_fcode           TYPE fcode,
        lv_fcode_counter   TYPE i,
        lv_fcode_counter_s TYPE string.

*   screen extension header detail
  IF sy-dyngr = 'KOPF'.
*   Check and deactivate not implemented Internal BAdI tabs
    CLEAR gt_screenbadi_int_h.
    TRY.
        GET BADI go_screenbadi_int_h.
        IF go_screenbadi_int_h IS BOUND.
          CALL BADI go_screenbadi_int_h->activate_tab_page
            EXPORTING
              is_vbak         = vbak
            CHANGING
              ct_head_scr_int = gt_screenbadi_int_h.
        ENDIF.
      CATCH cx_badi.
    ENDTRY.
    CLEAR: lv_fcode_counter, lv_fcode_counter_s.
    lv_fcode_counter = cv_badi_max_tabs_int + 1.
    DELETE gt_screenbadi_int_h WHERE program IS INITIAL
                                  OR dynpro IS INITIAL.
    DELETE gt_screenbadi_int_h FROM lv_fcode_counter.
    DO cv_badi_max_tabs_int TIMES.
      READ TABLE gt_screenbadi_int_h INDEX sy-index TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        lv_fcode_counter_s = sy-index.
        CONCATENATE 'K_INT_BADI_' lv_fcode_counter_s INTO lv_fcode.
        PERFORM taxi_deactivate_tab USING lv_fcode.
      ENDIF.
    ENDDO.
*   Check and Deactivate not implemented Customer BAdI tabs
    CLEAR gt_screenbadi_cus_h.
    TRY.
        GET BADI go_screenbadi_cus_h.
        IF go_screenbadi_cus_h IS BOUND.
          CALL BADI go_screenbadi_cus_h->activate_tab_page
            EXPORTING
              is_vbak         = vbak
            CHANGING
              ct_cus_head_tab = gt_screenbadi_cus_h.
        ENDIF.
      CATCH cx_badi.
    ENDTRY.
    CLEAR: lv_fcode_counter, lv_fcode_counter_s.
    lv_fcode_counter = cv_badi_max_tabs_cus + 1.
    DELETE gt_screenbadi_cus_h WHERE head_program IS INITIAL
                                  OR head_dynpro IS INITIAL.
    DELETE gt_screenbadi_cus_h FROM lv_fcode_counter.
    DO cv_badi_max_tabs_cus TIMES.
      READ TABLE gt_screenbadi_cus_h INDEX sy-index TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        lv_fcode_counter_s = sy-index.
        CONCATENATE 'K_CUS_BADI_' lv_fcode_counter_s INTO lv_fcode.
        PERFORM taxi_deactivate_tab USING lv_fcode.
      ENDIF.
    ENDDO.
  ELSEIF sy-dyngr = 'POSI'.
*   Check and deactivate not implemented Internal BAdI tabs
    CLEAR gt_screenbadi_int_i.
    TRY.
        GET BADI go_screenbadi_int_i.
        IF go_screenbadi_int_i IS BOUND.
          CALL BADI go_screenbadi_int_i->activate_tab_page
            EXPORTING
              is_vbap         = vbap
              is_vbak         = vbak
            CHANGING
              ct_item_scr_int = gt_screenbadi_int_i.
        ENDIF.
      CATCH cx_badi.
    ENDTRY.
    CLEAR: lv_fcode_counter, lv_fcode_counter_s.
    lv_fcode_counter = cv_badi_max_tabs_int + 1.
    DELETE gt_screenbadi_int_i WHERE program IS INITIAL
                                  OR dynpro IS INITIAL.
    DELETE gt_screenbadi_int_i FROM lv_fcode_counter.
    DO cv_badi_max_tabs_int TIMES.
      READ TABLE gt_screenbadi_int_i INDEX sy-index TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        lv_fcode_counter_s = sy-index.
        CONCATENATE 'P_INT_BADI_' lv_fcode_counter_s INTO lv_fcode.
        PERFORM taxi_deactivate_tab USING lv_fcode.
      ENDIF.
    ENDDO.
*   Check and Deactivate not implemented Customer BAdI tabs
    CLEAR gt_screenbadi_cus_i.
    TRY.
        GET BADI go_screenbadi_cus_i.
        IF go_screenbadi_cus_i IS BOUND.
          CALL BADI go_screenbadi_cus_i->activate_tab_page
            EXPORTING
              is_vbak         = vbak
              is_vbap         = vbap
            CHANGING
              ct_cus_item_tab = gt_screenbadi_cus_i.
        ENDIF.
      CATCH cx_badi.
    ENDTRY.
    CLEAR: lv_fcode_counter, lv_fcode_counter_s.
    lv_fcode_counter = cv_badi_max_tabs_cus + 1.
    DELETE gt_screenbadi_cus_i WHERE item_program IS INITIAL
                                  OR item_dynpro IS INITIAL.
    DELETE gt_screenbadi_cus_i FROM lv_fcode_counter.
    DO cv_badi_max_tabs_cus TIMES.
      READ TABLE gt_screenbadi_cus_i INDEX sy-index TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        lv_fcode_counter_s = sy-index.
        CONCATENATE 'P_CUS_BADI_' lv_fcode_counter_s INTO lv_fcode.
        PERFORM taxi_deactivate_tab USING lv_fcode.
      ENDIF.
    ENDDO.
  ELSE.
*     Deactivate all the tabs
    DO cv_badi_max_tabs_int TIMES.
      lv_fcode_counter_s = sy-index.
      CONCATENATE 'K_INT_BADI_' lv_fcode_counter_s INTO lv_fcode.
      PERFORM taxi_deactivate_tab USING lv_fcode.
      CONCATENATE 'P_INT_BADI_' lv_fcode_counter_s INTO lv_fcode.
      PERFORM taxi_deactivate_tab USING lv_fcode.
    ENDDO.
    DO cv_badi_max_tabs_cus TIMES.
      lv_fcode_counter_s = sy-index.
      CONCATENATE 'K_CUS_BADI_' lv_fcode_counter_s INTO lv_fcode.
      PERFORM taxi_deactivate_tab USING lv_fcode.
      CONCATENATE 'P_CUS_BADI_' lv_fcode_counter_s INTO lv_fcode.
      PERFORM taxi_deactivate_tab USING lv_fcode.
    ENDDO.
  ENDIF.

ENDFORM.                    " DEACTIVATE_SCREEN_BADI_TAB