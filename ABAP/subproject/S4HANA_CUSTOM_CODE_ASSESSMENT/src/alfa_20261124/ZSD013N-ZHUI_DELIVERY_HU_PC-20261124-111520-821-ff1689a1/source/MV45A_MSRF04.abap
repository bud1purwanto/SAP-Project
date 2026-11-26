*&---------------------------------------------------------------------*
*&  Include           MV45A_MSRF04
*&---------------------------------------------------------------------*
*&  subroutines for fastchange
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_INIT
*&---------------------------------------------------------------------*
FORM msr_fastchange_init.

  LOCAL: vbap.

  DATA: ls_msr_sales_fastchange TYPE msr_s_sales_fastchange.

  PERFORM schnellaenderung_init(sapfv45p).
  READ TABLE ivbap TRANSPORTING NO FIELDS
    WITH KEY selkz = abap_true.
  IF sy-subrc NE 0.
    MESSAGE i323(v1).
    CLEAR sy-ucomm.
    RETURN.
  ENDIF.

  CLEAR gs_msr_sales_fastchange.
  REFRESH gt_msr_sales_fastchange.

  LOOP AT ivbap WHERE selkz EQ abap_true.
    svbap-tabix = ivbap-tabix.
    READ TABLE xvbap INDEX ivbap-tabix.
    MOVE-CORRESPONDING xvbap TO vbap.
    PERFORM msr_read_item.
    IF NOT gs_msr_sales_item IS INITIAL.
      IF gs_msr_sales_item-display_only = abap_true.
        MESSAGE  w020(msr_sd) WITH vbap-posnr.
        CONTINUE.
      ENDIF.
      CLEAR ls_msr_sales_fastchange.
      MOVE-CORRESPONDING gs_msr_sales_item TO ls_msr_sales_fastchange.
      ls_msr_sales_fastchange-msr_id      = vbak-msr_id.
      ls_msr_sales_fastchange-ret_reason  = vbap-msr_ret_reason.
      ls_msr_sales_fastchange-refund_code = vbap-msr_refund_code.
      ls_msr_sales_fastchange-approval_block = vbap-msr_approv_block.
      APPEND ls_msr_sales_fastchange TO gt_msr_sales_fastchange.
    ENDIF.
  ENDLOOP.
  IF gt_msr_sales_fastchange IS INITIAL.
    fcode = fcode_gleiche_seite.
    MESSAGE e021(msr_sd).
  ENDIF.

ENDFORM.                    " MSR_FASTCHANGE_INIT


*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_UPDATE_APPROVAL
*&---------------------------------------------------------------------*
FORM msr_fastchange_update_approval.

  LOCAL: vbap, xvbap, svbap.

  DATA: lv_error TYPE flag VALUE charx,
        lv_info TYPE flag VALUE space,
        lv_changed TYPE flag VALUE space,
        lv_failed TYPE flag VALUE space.

  FIELD-SYMBOLS:
        <ls_msr_sales_fastchange> TYPE msr_s_sales_fastchange.


  LOOP AT gt_msr_sales_fastchange ASSIGNING <ls_msr_sales_fastchange>.
    CHECK gs_msr_sales_fastchange-approval_block NE <ls_msr_sales_fastchange>-approval_block.
    PERFORM xvbap_lesen_allgemein(sapfv45p) USING <ls_msr_sales_fastchange>-posnr
                                                  space
                                         CHANGING svbap-tabix.
    PERFORM vbap_bearbeiten_vorbereiten IN PROGRAM sapfv45p.
    vbap-msr_approv_block = gs_msr_sales_fastchange-approval_block.

*   perform msr_check_item using charx.
    CALL FUNCTION 'SD_CALL_PERFORM'
      EXPORTING
        iv_form       = 'MSR_CHECK_ITEM'
        iv_program    = 'SAPMV45A'
      CHANGING
        cv_using1     = lv_error
        cv_using2     = lv_info
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc = 0.
      PERFORM vbap_bearbeiten IN PROGRAM sapfv45p.
      PERFORM vbap_bearbeiten_ende IN PROGRAM sapfv45p.
      <ls_msr_sales_fastchange>-approval_block = gs_msr_sales_fastchange-approval_block.
      lv_changed = charx.
    ELSE.
      sy-msgty = charw.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      lv_failed = charx.
    ENDIF.
    PERFORM ivbap-selkz_abgearbeitet(sapfv45p) USING <ls_msr_sales_fastchange>-posnr.
  ENDLOOP.
  IF lv_changed IS INITIAL.
    IF NOT lv_failed IS INITIAL.
      MESSAGE i014(msr_sd).
    ENDIF.
  ELSE.
    MESSAGE s008(msr_sd).
  ENDIF.
  PERFORM fcode_set_screen_0(saplv00f).

ENDFORM.                    " MSR_FASTCHANGE_UPDATE_APPROVAL


*&---------------------------------------------------------------------*
*&      Form  msr_fastchange_update
*&---------------------------------------------------------------------*
FORM msr_fastchange_update USING uv_check TYPE flag.

  LOCAL: vbap, xvbap, svbap, gv_msr_fastchange.

  DATA: lv_error TYPE flag VALUE charx,
        lv_info TYPE flag VALUE space,
        lv_changed TYPE flag VALUE space,
        lv_failed TYPE flag VALUE space,
        lv_update TYPE flag VALUE space.

  FIELD-SYMBOLS:
        <ls_msr_sales_fastchange> TYPE msr_s_sales_fastchange.

  gv_msr_fastchange = charx.

  LOOP AT gt_msr_sales_fastchange ASSIGNING <ls_msr_sales_fastchange>.
*   check changed
    PERFORM msr_fastchange_changed USING <ls_msr_sales_fastchange>
                                CHANGING lv_update.
    IF NOT lv_update IS INITIAL.
      PERFORM xvbap_lesen_allgemein(sapfv45p) USING <ls_msr_sales_fastchange>-posnr
                                                    space
                                           CHANGING svbap-tabix.
      PERFORM vbap_bearbeiten_vorbereiten IN PROGRAM sapfv45p.
*     mapping
      PERFORM msr_fastchange_mapping.
*     perform msr_check_item using charx.
      CALL FUNCTION 'SD_CALL_PERFORM'
        EXPORTING
          iv_form       = 'MSR_CHECK_ITEM'
          iv_program    = 'SAPMV45A'
        CHANGING
          cv_using1     = lv_error
          cv_using2     = lv_info
        EXCEPTIONS
          error_message = 1.
      IF sy-subrc = 0.
        IF uv_check IS INITIAL.
          PERFORM vbap_bearbeiten IN PROGRAM sapfv45p.
          PERFORM vbap_bearbeiten_ende IN PROGRAM sapfv45p.
          lv_changed = charx.
        ENDIF.
      ELSE.
        IF NOT uv_check IS INITIAL.
          sy-msgty = chare.
        ELSE.
          sy-msgty = chari.
        ENDIF.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        lv_failed = charx.
      ENDIF.
    ENDIF.
    IF uv_check IS INITIAL.
      PERFORM ivbap-selkz_abgearbeitet(sapfv45p) USING <ls_msr_sales_fastchange>-posnr.
    ENDIF.
  ENDLOOP.
  IF uv_check IS INITIAL.
    IF NOT lv_changed IS INITIAL.
      MESSAGE s007(msr_sd).
    ELSE.
      MESSAGE i014(msr_sd).
    ENDIF.
    PERFORM fcode_set_screen_0(saplv00f).
  ENDIF.

ENDFORM.                    "msr_fastchange_update


*&---------------------------------------------------------------------*
*&      Form  msr_fastchange_update_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_fastchange_update_check.

  PERFORM msr_fastchange_update USING charx.

ENDFORM.                    "msr_fastchange_update_check


*&---------------------------------------------------------------------*
*&      Form  msr_fastchange_update_final
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_fastchange_update_final.

  PERFORM msr_fastchange_update USING space.

ENDFORM.                    "msr_fastchange_update_final


*&---------------------------------------------------------------------*
*&      Form  msr_fastchange_changed
*&---------------------------------------------------------------------*
FORM msr_fastchange_changed USING us_msr_sales_fastchange TYPE msr_s_sales_fastchange
                         CHANGING cv_changed TYPE flag.

  CLEAR cv_changed.

  DO.
*   return reason
    IF NOT gs_msr_sales_fastchange-ret_reason_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-ret_reason IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-ret_reason NE us_msr_sales_fastchange-ret_reason.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   follow-up activity
    IF NOT gs_msr_sales_fastchange-fu_code_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-fu_code IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-fu_code NE us_msr_sales_fastchange-fu_code.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   refund control
    IF NOT gs_msr_sales_fastchange-refund_control_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-refund_control IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-refund_control NE us_msr_sales_fastchange-refund_control.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   refund code
    IF NOT gs_msr_sales_fastchange-refund_code_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-refund_code IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-refund_code NE us_msr_sales_fastchange-refund_code.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   next plant
    IF NOT gs_msr_sales_fastchange-next_plant_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-next_plant IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-next_plant NE us_msr_sales_fastchange-next_plant.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   vendor
    IF NOT gs_msr_sales_fastchange-lifnr_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-lifnr IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-lifnr NE us_msr_sales_fastchange-lifnr.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   Address
    IF NOT gs_msr_sales_fastchange-vendor_adrnr_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-vendor_diff_adr IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-vendor_diff_adr NE us_msr_sales_fastchange-vendor_diff_adr.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   vendor rma number
    IF NOT gs_msr_sales_fastchange-rma_vendor_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-rma_vendor IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-rma_vendor NE us_msr_sales_fastchange-rma_vendor.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   inspection code
    IF NOT gs_msr_sales_fastchange-inspection_code_x IS INITIAL.
      IF NOT us_msr_sales_fastchange-inspection_code IS INITIAL.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ELSE.
      IF gs_msr_sales_fastchange-inspection_code NE us_msr_sales_fastchange-inspection_code.
        cv_changed = charx.
        EXIT.
      ENDIF.
    ENDIF.
*   at customer site
    IF gs_msr_sales_fastchange-at_customer_site NE us_msr_sales_fastchange-at_customer_site.
      cv_changed = charx.
      EXIT.
    ENDIF.
*   material received
    IF gs_msr_sales_fastchange-mat_received NE us_msr_sales_fastchange-mat_received.
      cv_changed = charx.
      EXIT.
    ENDIF.
*   transshipment plant
    IF gs_msr_sales_fastchange-transshipment NE us_msr_sales_fastchange-transshipment.
      cv_changed = charx.
      EXIT.
    ENDIF.
    CLEAR cv_changed.
    EXIT.
  ENDDO.

ENDFORM.                    "msr_fastchange_changed


*&---------------------------------------------------------------------*
*&      Form  msr_fastchange_mapping
*&---------------------------------------------------------------------*
FORM msr_fastchange_mapping.

* return reason
  IF NOT gs_msr_sales_fastchange-ret_reason_x IS INITIAL.
    CLEAR vbap-msr_ret_reason.
  ELSEIF NOT gs_msr_sales_fastchange-ret_reason IS INITIAL.
    vbap-msr_ret_reason = gs_msr_sales_fastchange-ret_reason.
  ENDIF.
* follow-up activity
  IF NOT gs_msr_sales_fastchange-fu_code_x IS INITIAL.
    CLEAR gs_msr_sales_item-fu_code.
  ELSEIF NOT gs_msr_sales_fastchange-fu_code IS INITIAL.
    gs_msr_sales_item-fu_code = gs_msr_sales_fastchange-fu_code.
  ENDIF.
* refund control
  IF NOT gs_msr_sales_fastchange-refund_control_x IS INITIAL.
    CLEAR gs_msr_sales_item-refund_control.
  ELSEIF NOT gs_msr_sales_fastchange-refund_control IS INITIAL.
    gs_msr_sales_item-refund_control = gs_msr_sales_fastchange-refund_control.
  ENDIF.
* refund code
  IF NOT gs_msr_sales_fastchange-refund_code_x IS INITIAL.
    CLEAR vbap-msr_refund_code.
  ELSEIF NOT gs_msr_sales_fastchange-refund_code IS INITIAL.
    vbap-msr_refund_code = gs_msr_sales_fastchange-refund_code.
  ENDIF.
* next plant
  IF NOT gs_msr_sales_fastchange-next_plant_x IS INITIAL.
    CLEAR gs_msr_sales_item-next_plant.
    CLEAR gs_msr_sales_fastchange-next_plants.
  ELSEIF NOT gs_msr_sales_fastchange-next_plant IS INITIAL.
    gs_msr_sales_item-next_plant = gs_msr_sales_fastchange-next_plant.
    gs_msr_sales_fastchange-multiple_plants = abap_true.
  ELSEIF gs_msr_sales_fastchange-next_plant IS INITIAL.
    CLEAR gs_msr_sales_fastchange-next_plants.
  ENDIF.
* vendor
  IF NOT gs_msr_sales_fastchange-lifnr_x IS INITIAL.
    CLEAR gs_msr_sales_item-lifnr.
  ELSEIF NOT gs_msr_sales_fastchange-lifnr IS INITIAL.
    gs_msr_sales_item-lifnr = gs_msr_sales_fastchange-lifnr.
  ENDIF.
* Address
  IF NOT gs_msr_sales_fastchange-vendor_adrnr_x IS INITIAL.
    CLEAR gs_msr_sales_item-vendor_diff_adr.
  ELSEIF NOT gs_msr_sales_fastchange-vendor_diff_adr IS INITIAL.
    gs_msr_sales_item-vendor_diff_adr = gs_msr_sales_fastchange-vendor_diff_adr.
  ENDIF.
* vendor rma number
  IF NOT gs_msr_sales_fastchange-rma_vendor_x IS INITIAL.
    CLEAR gs_msr_sales_item-rma_vendor.
  ELSEIF NOT gs_msr_sales_fastchange-rma_vendor IS INITIAL.
    gs_msr_sales_item-rma_vendor = gs_msr_sales_fastchange-rma_vendor.
  ENDIF.
* material received
  CASE gs_msr_sales_fastchange-mat_received.
    WHEN chary.
      gs_msr_sales_item-mat_received = abap_true.
    WHEN charn.
      gs_msr_sales_item-mat_received = abap_false.
    WHEN OTHERS.
  ENDCASE.
* at customer site
  CASE gs_msr_sales_fastchange-at_customer_site.
    WHEN chary.
      gs_msr_sales_item-at_customer_site = abap_true.
    WHEN charn.
      gs_msr_sales_item-at_customer_site = abap_false.
    WHEN OTHERS.
  ENDCASE.
* transshipment plant
  IF NOT gs_msr_sales_fastchange-transshipment IS INITIAL.
    IF NOT gs_msr_sales_fastchange-next_plant IS INITIAL.
      gs_msr_sales_item-transshipment = gs_msr_sales_fastchange-transshipment.
    ELSE.
      CLEAR gs_msr_sales_fastchange-transshipment.
    ENDIF.
  ENDIF.
* inspection code
  IF NOT gs_msr_sales_fastchange-inspection_code_x IS INITIAL.
    CLEAR gs_msr_sales_item-inspection_code.
  ELSEIF NOT gs_msr_sales_fastchange-inspection_code IS INITIAL.
    gs_msr_sales_item-inspection_code = gs_msr_sales_fastchange-inspection_code.
  ENDIF.

ENDFORM.                    "msr_fastchange_mapping


*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_CHECK_VENDOR
*&---------------------------------------------------------------------*
FORM msr_fastchange_check_vendor .

  DATA:
    ls_lfa1             TYPE lfa1.

  IF gs_msr_sales_fastchange-lifnr_x EQ abap_true.
    CLEAR:
      gs_msr_sales_fastchange-lifnr,
      gs_msr_sales_fastchange-vendor_name.
  ELSEIF gs_msr_sales_fastchange-lifnr IS NOT INITIAL.
*   set vendor name
    CALL FUNCTION 'LFA1_SINGLE_READ'
      EXPORTING
        lfa1_lifnr = gs_msr_sales_fastchange-lifnr
      IMPORTING
        wlfa1      = ls_lfa1
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc IS INITIAL.

* International address version
      CALL METHOD cl_iav_mapping_util=>get_address_as_lfa1
        EXPORTING
          iv_adrnr                 = ls_lfa1-adrnr
          iv_application_component = 'MM_PUR_VENDOR'
        CHANGING
          cs_lfa1                  = ls_lfa1.
      gs_msr_sales_fastchange-vendor_name = ls_lfa1-name1.
    ELSE.
      CLEAR gs_msr_sales_fastchange-vendor_name.
      SET CURSOR FIELD 'GS_MSR_SALES_FASTCHANGE-LIFNR'.
      MESSAGE e753(me) WITH gs_msr_sales_fastchange-lifnr.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.                    " MSR_FASTCHANGE_CHECK_VENDOR

*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_CHECK_ADRNR
*&---------------------------------------------------------------------*
FORM msr_fastchange_check_adrnr.

  DATA:
    ls_addr_sel         TYPE addr1_sel,
    ls_sadr             TYPE sadr.

  IF gs_msr_sales_fastchange-vendor_adrnr_x EQ abap_true.
    CLEAR:
      gs_msr_sales_fastchange-vendor_adrnr_name,
      gs_msr_sales_fastchange-vendor_diff_adr.
  ELSEIF gs_msr_sales_fastchange-vendor_diff_adr IS NOT INITIAL.

    IF gs_msr_sales_fastchange-lifnr IS INITIAL.
      MESSAGE i002(msr_sd).
      CLEAR:
        gs_msr_sales_fastchange-vendor_adrnr_name,
        gs_msr_sales_fastchange-vendor_diff_adr.
      RETURN.
    ENDIF.

    ls_addr_sel-addrnumber = gs_msr_sales_fastchange-vendor_diff_adr.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = ls_addr_sel
      IMPORTING
        sadr              = ls_sadr
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
    IF sy-subrc IS INITIAL.
      gs_msr_sales_fastchange-vendor_adrnr_name = ls_sadr-name1.
    ELSE.
      CLEAR gs_msr_sales_fastchange-vendor_adrnr_name.
      SET CURSOR FIELD 'GS_MSR_SALES_FASTCHANGE-VENDOR_DIFF_ADR'.
      MESSAGE e010(am) WITH gs_msr_sales_fastchange-vendor_diff_adr.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.                    " MSR_FASTCHANGE_CHECK_ADRNR

*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_CHECK_NEXTPLANT
*&---------------------------------------------------------------------*
FORM msr_fastchange_check_nextplant.

  DATA:
    ls_t001w                TYPE t001w,
    ls_msr_sales_fastchange TYPE msr_s_sales_fastchange.

  IF gs_msr_sales_fastchange-next_plant_x EQ abap_true.
    CLEAR:
      gs_msr_sales_fastchange-next_plant,
      gs_msr_sales_fastchange-transshipment,
      gs_msr_sales_fastchange-next_plant_name,
      gs_msr_sales_fastchange-next_plants,
      gs_msr_sales_fastchange-multiple_plants,
      gv_iconname_nplant.
  ELSEIF gs_msr_sales_fastchange-next_plant IS NOT INITIAL.
    CALL FUNCTION 'T001W_READ'
      EXPORTING
        werks    = gs_msr_sales_fastchange-next_plant
      IMPORTING
        struct   = ls_t001w
      EXCEPTIONS
        no_entry = 1
        OTHERS   = 2.
    IF sy-subrc IS INITIAL.
      gs_msr_sales_fastchange-next_plant_name = ls_t001w-name1.
    ELSE.
      CLEAR gs_msr_sales_fastchange-next_plant_name.
      SET CURSOR FIELD 'GS_MSR_SALES_FASTCHANGE-NEXT_PLANT'.
      MESSAGE e726(ct) WITH gs_msr_sales_fastchange-next_plant.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.                    " MSR_FASTCHANGE_CHECK_NEXTPLANT

*&---------------------------------------------------------------------*
*&      Form  F4_FASTCHANGE_MAT_RECEIVED
*&---------------------------------------------------------------------*
FORM f4_fastchange_mat_received.

  TYPES:
    BEGIN OF lty_s_mat_received,
      mat_received      TYPE char1,
      mat_received_text TYPE text60,
    END OF lty_s_mat_received.

  DATA:
    ls_mat_received        TYPE lty_s_mat_received,
    lt_mat_received_values TYPE STANDARD TABLE OF lty_s_mat_received.

  APPEND INITIAL LINE TO lt_mat_received_values.
  ls_mat_received-mat_received      = chary.
  ls_mat_received-mat_received_text = 'Yes'(285).
  APPEND ls_mat_received TO lt_mat_received_values.
  ls_mat_received-mat_received      = charn.
  ls_mat_received-mat_received_text = 'No'(286).
  APPEND ls_mat_received TO lt_mat_received_values.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield  = 'MAT_RECEIVED'
      value_org = chars
    TABLES
      value_tab = lt_mat_received_values
    EXCEPTIONS
      OTHERS    = 0.

ENDFORM.                    " F4_FASTCHANGE_MAT_RECEIVED

*&---------------------------------------------------------------------*
*&      Form  F4_FASTCHANGE_AT_CUST_SITE
*&---------------------------------------------------------------------*
FORM f4_fastchange_at_cust_site.

  TYPES:
    BEGIN OF lty_s_at_cust_site,
      at_customer_site        TYPE char1,
      at_customer_site_values TYPE text60,
    END OF lty_s_at_cust_site.

  DATA:
    ls_at_cust_site        TYPE lty_s_at_cust_site,
    lt_at_cust_site_values TYPE STANDARD TABLE OF lty_s_at_cust_site.

  APPEND INITIAL LINE TO lt_at_cust_site_values.
  ls_at_cust_site-at_customer_site        = chary.
  ls_at_cust_site-at_customer_site_values = 'Yes'(285).
  APPEND ls_at_cust_site TO lt_at_cust_site_values.

  ls_at_cust_site-at_customer_site        = charn.
  ls_at_cust_site-at_customer_site_values = 'No'(286).
  APPEND ls_at_cust_site TO lt_at_cust_site_values.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield  = 'AT_CUSTOMER_SITE'
      value_org = chars
    TABLES
      value_tab = lt_at_cust_site_values
    EXCEPTIONS
      OTHERS    = 0.

ENDFORM.                    " F4_FASTCHANGE_AT_CUST_SITE

*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_SET_ICONS
*&---------------------------------------------------------------------*
FORM msr_fastchange_set_icons.

  DATA:
    lv_text             TYPE string,
    lv_icon             TYPE string.

  IF gr_msr_sales IS NOT BOUND.
    RETURN.
  ENDIF.
* Set icon for next plant
  IF gs_msr_sales_fastchange-multiple_plants IS INITIAL.
    lv_icon = 'ICON_ENTER_MORE'.
*   Set tooltip ...
    CASE t180-trtyp.
      WHEN charh OR charv.
        lv_text = text-p01.
      WHEN chara.
        lv_text = text-p03.
    ENDCASE.
  ELSE.
    lv_icon = 'ICON_DISPLAY_MORE'.
*   Set tooltip
    CASE t180-trtyp.
      WHEN charh OR charv.
        lv_text = text-p02.
      WHEN chara.
        lv_text = text-p03.
    ENDCASE.
  ENDIF.
* Call needed?
  IF gv_iconname_nplant NE lv_icon OR
     gv_iconname_nplant EQ space.
    gv_iconname_nplant = lv_icon.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = lv_icon
        text                  = space
        info                  = lv_text
      IMPORTING
        result                = gv_next_plants_icon
      EXCEPTIONS
        icon_not_found        = 01
        outputfield_too_short = 02
        OTHERS                = 99.
    IF sy-subrc <> 0.
      MOVE space TO gv_next_plants_icon.
    ENDIF.
  ENDIF.

ENDFORM.                    " MSR_FASTCHANGE_SET_ICONS


*&---------------------------------------------------------------------*
*&      Form  MSR_FASTCHANGE_FCODE_NPLANT
*&---------------------------------------------------------------------*
FORM msr_fastchange_fcode_nplant .

  IF fcode NE fcode_msr_next_plants.
    RETURN.
  ENDIF.

  gr_msr_sales->fastchange_next_plants(
    EXPORTING
      is_vbap                 = vbap
      is_vbak                 = vbak
    CHANGING
      cs_msr_sales_fastchange = gs_msr_sales_fastchange ).

  fcode = fcode_gleiche_seite.

  PERFORM msr_fastchange_update USING charx.

ENDFORM.                    " MSR_FASTCHANGE_FCODE_NPLANT