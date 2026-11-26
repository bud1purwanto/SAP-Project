*&---------------------------------------------------------------------*
*&  Include           MV45AFFE_FELDAUSWAHL_MSR
*&---------------------------------------------------------------------*

FORM feldauswahl_msr CHANGING cs_screen TYPE screen.

* Advanced Returns Management II (EhP 6)
  IF gs_ops_switch_check-ops_sfws_sc_advret2 eq charx.
    IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_sdf AND
       tvak-msr_active IS NOT INITIAL.
      IF cs_screen-name EQ 'VBAP-ZIEME' OR
         cs_screen-name EQ 'VBAP-ZMENG'.
        cs_screen-input = 0.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF cs_screen-group4 NE 'MSR'.
    RETURN.
  ENDIF.

* if field is part of a non-msr-overview
  IF t185v-panel EQ 'UMSR' OR
     t185v-panel EQ 'PMSR'.
    cs_screen-input = 1.
    cs_screen-invisible = 0.

* Advanced Returns Management II (EhP 6)
    IF gs_ops_switch_check-ops_sfws_sc_advret2 eq charx.
      IF cs_screen-group1 IS NOT INITIAL.
        CASE sy-dynnr.
*************************************************************************************
*****  Important for using transaction SFAC *****
* Fields of structure GS_MSR_SALES_ITEM with Type of screen element: CHECK (checkbox)
* have to got the sign "_" on tabs "Element list" -> "Texts/ I/O templates" in
* column "Text or I/O field", otherwise this fields will not displayed in SFAC
*************************************************************************************
          WHEN '4448'. "item detail screen
            CALL FUNCTION 'FIELD_SELECTION_MODIFY_SINGLE'
              EXPORTING
                modulpool    = sy-repid
                dynprogruppe = 'ARM2'
                mode         = 'A'.

          WHEN '4900'. "table control
            CALL FUNCTION 'FIELD_SELECTION_MODIFY_SINGLE'
              EXPORTING
                modulpool    = sy-repid
                dynprogruppe = 'LIST'
                mode         = 'A'.
        ENDCASE.
      ENDIF.
    ENDIF.

  ELSE.
    cs_screen-input = 0.
    cs_screen-invisible = 1.
    RETURN.
  ENDIF.

* Hide text fields in the table control
  IF sy-dynnr EQ '4900'.
    IF cs_screen-name EQ 'MSR_S_SALES_ITEM-VENDOR_NAME' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-VENDOR_DIFF_ADR' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-INSPECTION_COMMENT' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-INSP_SHORT_TEXT' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-NEXT_PLANT_NAME' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-CUST_INSP_COMM' OR
       cs_screen-name EQ 'MSR_S_SALES_ITEM-CUST_INSP_CODE'.
      cs_screen-input = 0.
      cs_screen-invisible = 1.
      RETURN.
    ENDIF.
  ENDIF.

  IF cs_screen-group2 EQ 'LOO' AND
     sy-stepl GT 0.
*   Hide text fields in the table control
    IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-VENDOR_NAME' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-DIFF_VENDOR_ADR' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-INSPECTION_COMMENT' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-INSP_SHORT_TEXT' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-NEXT_PLANT_NAME' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-CUST_INSP_COMM' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-CUST_INSP_CODE'.
      cs_screen-input = 0.
      cs_screen-invisible = 1.
      RETURN.
    ENDIF.
*   RMA required and Vendor address are no Input fields in Table Control
    IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-VENDOR_ADRNR' OR
       cs_screen-name EQ 'GS_MSR_SALES_ITEM-RMA_VENDOR_REQ'.
      cs_screen-input = 0.
      RETURN.
    ENDIF.
  ENDIF.

* Icon
  IF cs_screen-name EQ 'GV_NEXT_PLANTS_ICON'.
    cs_screen-input = 1.
    IF t180-trtyp EQ chara.
      cs_screen-input = 0.
    ENDIF.
    IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr.
      cs_screen-input = 0.
    ENDIF.
    IF NOT gs_msr_sales_item-next_plant IS INITIAL.
      cs_screen-input = 1.
    ENDIF.
    RETURN.
  ENDIF.
  IF cs_screen-name EQ 'GV_VENDOR_ADDRESS_ICON'.
    cs_screen-input = 1.
    IF t180-trtyp EQ chara.
      cs_screen-input = 0.
    ENDIF.
    IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr.
      cs_screen-input = 0.
    ENDIF.
    IF NOT gs_msr_sales_item-lifnr IS INITIAL AND
       NOT gs_msr_sales_item-vendor_diff_adr IS INITIAL.
      cs_screen-input = 1.
    ENDIF.
    RETURN.
  ENDIF.
  IF cs_screen-name  EQ 'GV_INSPECTION_TEXT_ICON' OR
     cs_screen-name  EQ 'GV_CUST_INSP_TEXT_ICON'.
    cs_screen-input = 1.
    RETURN.
  ENDIF.

* Push Button
  IF cs_screen-name EQ 'PB_TRACKING'.
    cs_screen-input = 1.
    IF vbapd-updkz EQ chari OR
       svbap-tabix EQ 0.
      cs_screen-input = 0.
    ENDIF.
    RETURN.
  ENDIF.
  IF cs_screen-name EQ 'PB_GET_NUMBER'.
    cs_screen-input = 1.
    IF NOT vbak-vbeln IS INITIAL.
      cs_screen-input = 0.
    ENDIF.
    IF tvak-msr_next_number IS INITIAL.
      cs_screen-input = 0.
      cs_screen-invisible = 1.
    ENDIF.
    RETURN.
  ENDIF.
  IF cs_screen-name EQ 'PB_ITEM_DEFAULTS'.
    cs_screen-input = 1.
    IF t180-trtyp EQ chara OR
       tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr OR
       tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_sdf.
      cs_screen-input = 0.
    ENDIF.
    RETURN.
  ENDIF.

* Label
  IF cs_screen-name EQ 'MSR_S_SALES_ITEM-RMA_CUSTOMER'.
    IF tvak-msr_next_number IS INITIAL.
      cs_screen-invisible = 1.
    ELSE.
      cs_screen-invisible = 0.
    ENDIF.
    RETURN.
  ENDIF.

* if msr is not active
  IF NOT gr_msr_sales IS BOUND.
    cs_screen-input = 0.
    cs_screen-invisible = 1.
    RETURN.
  ENDIF.

**************************
* screen-independent logic
**************************

* if msr is not active
  IF NOT gr_msr_sales IS BOUND.
    cs_screen-input = 0.
    cs_screen-invisible = 1.
    RETURN.
  ENDIF.

* if document category not credit memo request, not SDF or
* not returns order, then make it invisible.
  IF tvak-vbtyp NE if_msr_trc_c=>gc_doc_cat_ro  AND
     tvak-vbtyp NE if_msr_trc_c=>gc_doc_cat_cmr AND
   ( tvak-vbtyp NE if_msr_trc_c=>gc_doc_cat_sdf AND
     gs_ops_switch_check-ops_sfws_sc_advret2 eq charx ).
    cs_screen-input = 0.
    cs_screen-invisible = 1.
    RETURN.
  ENDIF.

  IF t180-trtyp EQ chara.
    cs_screen-input = 0.
  ELSE.
    cs_screen-input = 1.
  ENDIF.

* Advanced Returns Management II (EhP 6)
  IF gs_ops_switch_check-ops_sfws_sc_advret2 eq charx.

    IF cs_screen-name EQ 'VBAP-CHARG'.
      IF tvak-msr_active IS NOT INITIAL AND
         vbap-posnr      IS NOT INITIAL AND
         vbap-xchpf      IS INITIAL AND
         vbapd-pvpos     IS INITIAL AND
         ( sy-dynnr      EQ '4448' OR
           sy-dynnr      EQ '4900' ). " VA01/02/03 Returns Tab
        cs_screen-active    = 1.
        cs_screen-invisible = 0.
        IF vbap-matnr IS NOT INITIAL.
          cs_screen-input     = 0.
        ELSE.
          cs_screen-input     = 1.
        ENDIF.
      ENDIF.
    ENDIF.

* field manipulation via TA: SFAW/SFAC
    IF cs_screen-group1 IS NOT INITIAL.
      CASE sy-dynnr.
        WHEN '4448'. "item detail screen
          CALL FUNCTION 'FIELD_SELECTION_MODIFY_SINGLE'
            EXPORTING
              modulpool    = sy-repid
              dynprogruppe = 'ARM2'
              mode         = 'A'.

        WHEN '4900'. "table control
          CALL FUNCTION 'FIELD_SELECTION_MODIFY_SINGLE'
            EXPORTING
              modulpool    = sy-repid
              dynprogruppe = 'LIST'
              mode         = 'A'.
      ENDCASE.
    ENDIF.

    IF cs_screen-name EQ 'VBAP-CHARG'AND
      tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_sdf AND
      tvak-msr_active IS NOT INITIAL.
      cs_screen-active = 0.
    ENDIF.

    IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-REP_AVAIL_QTY'.
      cs_screen-input = 0.
    ENDIF.

    IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_sdf AND
       tvak-msr_active IS NOT INITIAL.
      cs_screen-input = 0.
      IF cs_screen-name CS '_SALES_ITEM-REPLACE_MATNR'    OR
         cs_screen-name CS '_SALES_ITEM-REPLACE_QTY'      OR
         cs_screen-name CS '_SALES_ITEM-REPLACE_UNIT'     OR
         cs_screen-name CS '_SALES_ITEM-REPLACE_MATNRTXT' OR
         cs_screen-name CS '_SALES_ITEM-PAYING_PLANT'     OR
         cs_screen-name CS '_SALES_ITEM-REP_AVAIL_QTY'    OR
         cs_screen-name EQ 'PB_ATP_OVERVIEW'              OR
         cs_screen-name EQ 'PB_ATP_CHECK'.
        cs_screen-invisible = 1.
        RETURN.
      ENDIF.
    ELSE.
      IF cs_screen-name CS '_SALES_ITEM-REPLACED_MATNR'    OR
         cs_screen-name CS '_SALES_ITEM-REPLACED_QTY'      OR
         cs_screen-name CS '_SALES_ITEM-REPLACED_UNIT'     OR
         cs_screen-name CS '_SALES_ITEM-REPLACED_MATNRTXT'.
        cs_screen-input = 0.
        cs_screen-invisible = 1.
        RETURN.
      ENDIF.
    ENDIF.
    IF cs_screen-name EQ 'PB_RETURNS_DETAILS' OR
       cs_screen-name EQ 'PB_RETURNS_DETAILS2'.
      IF t185v-panel EQ fcode_msr_item_overview.
        cs_screen-input = 1.
        cs_screen-invisible = 0.
      ELSEIF t185v-panel EQ fcode_msr_item_detail.
        cs_screen-input = 0.
        cs_screen-invisible = 1.
      ENDIF.
      IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr.
        IF cs_screen-name EQ 'PB_RETURNS_DETAILS'.
          cs_screen-input = 0.
          cs_screen-invisible = 1.
        ENDIF.
      ELSE.
        IF cs_screen-name EQ 'PB_RETURNS_DETAILS2'.
          cs_screen-input = 0.
          cs_screen-invisible = 1.
        ENDIF.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF. " End switch

  IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr AND
    cs_screen-name NE 'VBAP-MSR_REFUND_CODE'.
    cs_screen-input = 0.
  ENDIF.

  IF gs_msr_sales_item-display_only = abap_true.
    IF cs_screen-name NE 'VBAP-MSR_APPROV_BLOCK' OR
       vbap-msr_approv_block IS INITIAL.
      cs_screen-input = 0.
    ENDIF.
  ENDIF.

  IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-RMA_VENDOR_REQ'.
    cs_screen-input = 0.
    RETURN.
  ENDIF.

  IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-RMA_CUSTOMER'.
    cs_screen-input = 0.
    cs_screen-invisible = 0.
    IF tvak-msr_next_number IS INITIAL.
      cs_screen-invisible = 1.
    ENDIF.
    RETURN.
  ENDIF.

  IF cs_screen-name EQ 'GS_MSR_SALES_ITEM-NEXT_PLANT' OR
     cs_screen-name EQ 'GS_MSR_SALES_ITEM-TRANSSHIPMENT'.
    IF NOT gs_msr_sales_item-multiple_plants IS INITIAL.
      cs_screen-input = 0.
    ENDIF.
  ENDIF.

ENDFORM.                    "feldauswahl_msr