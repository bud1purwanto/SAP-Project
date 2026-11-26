*----------------------------------------------------------------------*
*   INCLUDE LMIGODP6
*   Detail tabstrip PO components implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_po_sc IMPLEMENTATION.

  METHOD pbo.

    DATA: lt_ekbe_sc TYPE me_ekbe_sc.
    DATA: ls_comp_tv TYPE gocomp_tv.
    FIELD-SYMBOLS <ekbe_sc> TYPE ekbe_sc.

    DATA:      ls_goitem_tmp  TYPE goitem.
    DATA:      lv_lines           TYPE sytabix.

* Hide Fields
    DATA: ls_fieldname TYPE migo_fieldname,
          ls_tctrl_col TYPE cxtab_column,
          lv_tabix     TYPE sy-tabix,
          lv_tab       TYPE dd02d-tabname,
          lv_field     TYPE dd03d-fieldname.


    CLEAR lv_lines.
    CLEAR pt_comp_tv.

    CALL METHOD super->pbo.

    IF goitem-ebeln IS INITIAL.
*       get EBELN/ EBELP from parent item for subcontracting component
      lcl_migo_globals=>kernel->get_parent_item(
        EXPORTING
          i_global_counter = goitem-parent
        IMPORTING
          e_goitem         = ls_goitem_tmp ).
    ELSE.
* At the time of early Component consumption (before GR), no parent exists.
      ls_goitem_tmp-ebeln = goitem-ebeln.
      ls_goitem_tmp-ebelp = goitem-ebelp.
    ENDIF.

    TRY.
        cl_mmpur_mepo_db_utility=>get_ekbe_sc(
          EXPORTING iv_ebeln   = ls_goitem_tmp-ebeln
                    iv_ebelp   = ls_goitem_tmp-ebelp
          IMPORTING et_ekbe_sc = lt_ekbe_sc ).
      CATCH cx_mmpur_not_found.
        CLEAR lt_ekbe_sc.
    ENDTRY.

* Assignment between Component and Component Consumption is only possible on MATNR.
    LOOP AT lt_ekbe_sc ASSIGNING <ekbe_sc> WHERE matnr = goitem-matnr.
      MOVE-CORRESPONDING <ekbe_sc> TO ls_comp_tv.
      APPEND ls_comp_tv TO pt_comp_tv.
    ENDLOOP.

    DESCRIBE TABLE pt_comp_tv LINES lv_lines.
    tv_gocomp-lines = lv_lines.


* Hide Table fields.

    LOOP AT tv_gocomp-cols INTO ls_tctrl_col.

      lv_tabix = sy-tabix.

      SPLIT ls_tctrl_col-screen-name AT '-' INTO lv_tab lv_field.

      IF lv_field = 'EBELN' OR
         lv_field = 'EBELP' OR
         lv_field = 'MATNR'.

        ls_tctrl_col-invisible = c_mod_on.
        MODIFY tv_gocomp-cols FROM ls_tctrl_col
                   INDEX lv_tabix.
      ENDIF.
ENHANCEMENT-POINT EHP606_LMIGODP6_01 SPOTS ES_SAPLMIGO .
    ENDLOOP.

  ENDMETHOD.                    "pbo

  METHOD pbo_loop.

    READ TABLE pt_comp_tv INTO gocomp_tv INDEX tv_gocomp-current_line.
    IF sy-subrc NE 0.
      EXIT FROM STEP-LOOP.
    ELSE.
*      ekbe_sc_tv = ls_ekbe_sc_tv.
    ENDIF.

  ENDMETHOD.                    "pbo_loop

ENDCLASS.                    "lcl_migo_detail_po_sc IMPLEMENTATION