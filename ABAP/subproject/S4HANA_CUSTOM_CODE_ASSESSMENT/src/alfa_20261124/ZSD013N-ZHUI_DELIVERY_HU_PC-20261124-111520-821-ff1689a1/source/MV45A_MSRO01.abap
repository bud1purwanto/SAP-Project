*----------------------------------------------------------------------*
***INCLUDE MV45AO_MSR .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  MSR_SET_ICONS  OUTPUT
*&---------------------------------------------------------------------*
MODULE msr_set_icons OUTPUT.
  PERFORM msr_set_icons.
ENDMODULE.                 " MSR_SET_ICONS  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_INIT_ITEM  OUTPUT
*&---------------------------------------------------------------------*
MODULE msr_init_fastchg_item_screen OUTPUT.
  CLEAR fcode.
  IF gs_msr_sales_fastchange-next_plant IS INITIAL.
    CLEAR gs_msr_sales_fastchange-next_plant_name.
  ENDIF.
  IF gs_msr_sales_fastchange-lifnr IS INITIAL.
    CLEAR gs_msr_sales_fastchange-vendor_name.
  ENDIF.
  IF gs_msr_sales_fastchange-vendor_diff_adr IS INITIAL.
    CLEAR gs_msr_sales_fastchange-vendor_adrnr_name.
  ENDIF.
ENDMODULE.                 " MSR_FASTCHANGE_INIT_ITEM  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_SET_ICONS  OUTPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_set_icons OUTPUT.
  PERFORM msr_fastchange_set_icons.
ENDMODULE.                 " MSR_FASTCHANGE_SET_ICONS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_FASTCHANGE_FIELDSEL OUTPUT
*&---------------------------------------------------------------------*
MODULE msr_fastchange_fieldsel OUTPUT.

  LOOP AT SCREEN.

* Maintenance of Nextplants in fastchange is removed as this function requires
* information about the item scenario like plant, FU-Code, Material received, which
* is not available for fastchange of several items
    IF screen-name EQ 'GV_NEXT_PLANTS_ICON'.
      screen-invisible = 1.
      screen-active    = 0.
      screen-input     = 0.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

* Maintenance of most fields in fastchange is not possible for
* credit memo requests
* Compare program MV45AFFE_FELDAUSWAHL_MSR
    IF tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr AND
       screen-name NE 'GS_MSR_SALES_FASTCHANGE-REFUND_CODE' AND
       screen-name NE 'GS_MSR_SALES_FASTCHANGE-REFUND_CODE_X'.
      screen-input = 0.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDMODULE.                 " MSR_FASTCHANGE_FIELDSEL  OUTPUT

*---------------------------------------------------------------------*
*       MODULE MSR_INCOMPLOG_SET_CURSOR OUTPUT                        *
*---------------------------------------------------------------------*
*       Cursorpositionierung auf das zu vervollständigende Feld       *
*       während Abarbeitung des Unvollständigkeitsprotokolls          *
*---------------------------------------------------------------------*
MODULE msr_incomplog_set_cursor OUTPUT.
  IF gr_msr_sales IS NOT BOUND.
    RETURN.
  ENDIF.

  IF fehler = charx.
    gr_msr_sales->change_incomplog_field( CHANGING cv_fehlerfeld = fehlerfeld   ).
    SET CURSOR FIELD fehlerfeld.
  ENDIF.
ENDMODULE.                    "MSR_INCOMPLOG_SET_CURSOR OUTPUT


*&---------------------------------------------------------------------*
*&      Module  MSR_XVBAP_DETAIL  OUTPUT
*&---------------------------------------------------------------------*
MODULE msr_xvbap_detail OUTPUT.

  CASE t185v-panel.
    WHEN fcode_msr_item_overview.
      PERFORM xvbap_item_detail.
    WHEN fcode_msr_item_detail.
      IF svbap-tabix > 0.
        READ TABLE xvbap INDEX svbap-tabix.
        IF sy-subrc NE 0.
          MESSAGE a325 WITH svbap-tabix.
        ELSE.
          item_detail_tabix = tc_selline = sy-tabix.
        ENDIF.
      ENDIF.
      PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).
  ENDCASE.

* replacement material
  IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
*   PERFORM msr_get_matnr_txt.
    PERFORM msr_get_werks_txt.
  ENDIF.

ENDMODULE.                 " MSR_XVBAP_DETAIL  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  MSR_VBAP_UNTERLEGEN_DETAI  INPUT
*&---------------------------------------------------------------------*
MODULE msr_vbap_unterlegen_detai INPUT.

  CASE t185v-panel.
    WHEN fcode_msr_item_overview.
      xvbap_loop_fcode = fcode.
      PERFORM vbap_unterlegen_detai(sapfv45p).
    WHEN fcode_msr_item_detail.
*     In case of item detail do not have to execute the logic
  ENDCASE.

ENDMODULE.                 " MSR_VBAP_UNTERLEGEN_DETAI  INPUT
*&---------------------------------------------------------------------*
*&      Module  MSR_MAP_FIELDS_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE msr_map_fields_pbo OUTPUT.
  PERFORM msr_map_fields_pbo.
ENDMODULE.                 " MSR_MAP_FIELDS_PBO  OUTPUT