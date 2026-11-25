REPORT ztrain_alv_c.
* Latihan ALV C - CL_GUI_ALV_GRID (OO, editable)
* Butuh screen 0100 (custom control CC_ALV) dan PF-STATUS S100
TABLES: ekko.

TYPES: BEGIN OF ty_po,
         ebeln TYPE ekko-ebeln,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netwr TYPE ekpo-netwr,
       END OF ty_po.

DATA: gt_po   TYPE STANDARD TABLE OF ty_po,
      go_cont TYPE REF TO cl_gui_custom_container,
      go_grid TYPE REF TO cl_gui_alv_grid,
      gt_lvc  TYPE lvc_t_fcat,
      gs_lvc  TYPE lvc_s_fcat,
      gs_lay  TYPE lvc_s_layo,
      ok_code TYPE sy-ucomm.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln.

CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_data_changed.
    DATA: ls_mod TYPE lvc_s_modi,
          lv_qty TYPE ekpo-menge.
    LOOP AT er_data_changed->mt_good_cells INTO ls_mod
         WHERE fieldname = 'MENGE'.
      lv_qty = ls_mod-value.
      IF lv_qty <= 0.
        CALL METHOD er_data_changed->add_protocol_entry
          EXPORTING
            i_msgid     = '00'
            i_msgty     = 'E'
            i_msgno     = '001'
            i_msgv1     = 'Qty harus > 0'
            i_fieldname = ls_mod-fieldname
            i_row_id    = ls_mod-row_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

DATA: go_handler TYPE REF TO lcl_handler.

START-OF-SELECTION.
  SELECT ebeln ebelp matnr txz01 menge meins netwr FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE gt_po
    WHERE ebeln IN s_ebeln AND loekz = space
      AND bstyp = 'F'.            "hanya PO (bukan RFQ/kontrak)
  CALL SCREEN 100.

FORM build_lvc_fcat.
  PERFORM add_lvc USING 'EBELN' 'PO Number' ' '.
  PERFORM add_lvc USING 'EBELP' 'Item'      ' '.
  PERFORM add_lvc USING 'MATNR' 'Material'  ' '.
  PERFORM add_lvc USING 'TXZ01' 'Description' ' '.
  PERFORM add_lvc USING 'MENGE' 'Qty'       'X'.
  PERFORM add_lvc USING 'MEINS' 'UoM'       ' '.
  PERFORM add_lvc USING 'NETWR' 'Net Value' ' '.
ENDFORM.

FORM add_lvc USING p_field p_text p_edit.
  CLEAR gs_lvc.
  gs_lvc-fieldname = p_field.
  gs_lvc-coltext   = p_text.
  gs_lvc-edit      = p_edit.
  IF p_field = 'MENGE'.
    gs_lvc-ref_table = 'EKPO'.
    gs_lvc-ref_field = 'MENGE'.
  ENDIF.
  APPEND gs_lvc TO gt_lvc.
ENDFORM.

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  IF go_grid IS INITIAL.
    CREATE OBJECT go_cont
      EXPORTING
        container_name = 'CC_ALV'.
    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_cont.
    PERFORM build_lvc_fcat.
    gs_lay-zebra      = 'X'.
    gs_lay-cwidth_opt = 'X'.
    CREATE OBJECT go_handler.
    SET HANDLER go_handler->on_data_changed FOR go_grid.
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_lay
      CHANGING
        it_outtab       = gt_po
        it_fieldcatalog = gt_lvc.
  ELSE.
    CALL METHOD go_grid->refresh_table_display.
  ENDIF.
ENDMODULE.

MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
