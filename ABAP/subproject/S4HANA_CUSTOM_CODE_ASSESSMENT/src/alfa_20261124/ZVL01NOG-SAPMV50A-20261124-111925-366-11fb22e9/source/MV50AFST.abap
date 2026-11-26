***INCLUDE MV50AFST .
*&---------------------------------------------------------------------*
*&      Form  FILL_ALV_STATUS_DISPLAY
*&---------------------------------------------------------------------*
FORM fill_alv_status_display TABLES it_vbup  STRUCTURE vbup
                                    it_lips  STRUCTURE lips
                                    it_vbuk  STRUCTURE vbuk
                                    it_ilips STRUCTURE shp_ilips
                             USING  is_likp STRUCTURE likpvb
                                    if_xlips_umfang TYPE c.

* help WA for delivery item line
  DATA: ls_outtab_item LIKE gs_outtab_item.
* help table index
  DATA: lf_tabix LIKE sy-tabix.
* BORGR_WBSTK_FROM_EKES removed with n_1072933

* indicator for subitems
  CLEAR gf_subitems.

* insert header status data from LIKP
  MOVE-CORRESPONDING is_likp TO gt_outtab_header.
* insert header status data from VBUK
  IF it_vbuk-vbeln NE is_likp-vbeln.
    READ TABLE it_vbuk WITH KEY vbeln = is_likp-vbeln.
  ENDIF.
  MOVE-CORRESPONDING it_vbuk TO gt_outtab_header.
* BORGR_WBSTK_FROM_EKES removed with n_1072933
  APPEND gt_outtab_header.

* insert item status data
  LOOP AT it_vbup WHERE vbeln = is_likp-vbeln.
    CLEAR ls_outtab_item.
    READ TABLE it_lips WITH KEY mandt = sy-mandt
                                vbeln = is_likp-vbeln
                                posnr = it_vbup-posnr.
*   show only items matching the current display extent
    IF if_xlips_umfang NE xlips_umfang_ucha.                "46B
      READ TABLE it_ilips WITH KEY posnr = it_vbup-posnr
                          BINARY SEARCH
                          TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        READ TABLE it_ilips WITH KEY posnr = it_lips-uecha
                            BINARY SEARCH
                            TRANSPORTING NO FIELDS.
        CHECK sy-subrc EQ 0.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING it_vbup TO ls_outtab_item.
*   BORGR_WBSTK_FROM_EKES removed with n_1072933

    MOVE-CORRESPONDING it_lips TO ls_outtab_item.
    IF it_lips-uecha IS INITIAL.
      ls_outtab_item-gf_itemsort = it_lips-posnr.
    ELSE.
      ls_outtab_item-gf_itemsort = it_lips-uecha.
*     subitems exist, enable subitem display button
      gf_subitems = charx.
    ENDIF.
    APPEND ls_outtab_item TO gt_outtab_item.
  ENDLOOP.

  SORT gt_outtab_item BY gf_itemsort posnr.

ENDFORM.                               " FILL_ALV_STATUS_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  header_status_display
*&---------------------------------------------------------------------*
FORM header_status_display.

  IF g_custom_container_01 IS INITIAL.
*   container for ALV GRID delivery header does not exist

    CLEAR gs_variant_header.

*   create object alv event receiver
    CREATE OBJECT evt_rcv_head_stat_disp.

*   create container for delivery header status
    CREATE OBJECT g_custom_container_01
        EXPORTING container_name = grid_header_status.
    CREATE OBJECT grid1
         EXPORTING
         i_parent = g_custom_container_01.

    SET HANDLER evt_rcv_head_stat_disp->handle_double_click FOR grid1.
    SET HANDLER evt_rcv_head_stat_disp->handle_toolbar FOR grid1.
    SET HANDLER evt_rcv_head_stat_disp->handle_user_command FOR grid1.
  ENDIF.

*   title for status display delivery header
  gs_layout_header-grid_title = text-017.

*   look for a user specific variant
  MOVE sy-repid TO gs_variant_header-report.

  IF t180-bldgr EQ gc_new_dialog_inb.
    MOVE gc_header_loggrp_inb TO gs_variant_header-log_group.
  ELSE.
    MOVE gc_header_loggrp_outb TO gs_variant_header-log_group.
  ENDIF.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save        = gc_var_maint_user_specific
    CHANGING
      cs_variant    = gs_variant_header
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.

  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      i_default            = gc_enable_set_default          "hp_332790
      i_save               = gc_var_maint_user_specific
      is_variant           = gs_variant_header
      is_print             = gs_print
      is_layout            = gs_layout_header
      it_toolbar_excluding = gt_toolbar_excluding
    CHANGING
      it_fieldcatalog      = gt_fieldcat_lvc_header[]
      it_outtab            = gt_outtab_header[].

ENDFORM.                               " header_status_display
*&---------------------------------------------------------------------*
*&      Form  item_status_display
*&---------------------------------------------------------------------*
FORM item_status_display.

  STATICS: sf_xlips_umfang TYPE c.

  IF g_custom_container_02 IS INITIAL.
*   container for ALV GRID delivery header does not exist

    DATA: lt_filter TYPE lvc_t_filt.
    DATA: ls_filter TYPE lvc_s_filt.
    CLEAR gs_variant_item.

*   create object alv event receiver
    CREATE OBJECT evt_rcv_item_stat_disp.

    CREATE OBJECT g_custom_container_02
        EXPORTING container_name = grid_item_status.
    CREATE OBJECT grid2
         EXPORTING
         i_parent = g_custom_container_02.

    SET HANDLER evt_rcv_item_stat_disp->handle_double_click FOR grid2.
    SET HANDLER evt_rcv_item_stat_disp->handle_toolbar FOR grid2.
    SET HANDLER evt_rcv_item_stat_disp->handle_user_command FOR grid2.

    IF xlips_umfang NE xlips_umfang_uhau.
      gs_layout_item-grid_title = text-018.
    ELSE.
      gs_layout_item-grid_title = text-019.
    ENDIF.

* multi line selection
    gs_layout_item-sel_mode = 'C'.
    MOVE sy-repid TO gs_variant_item-report.


    IF t180-bldgr EQ gc_new_dialog_inb.
      MOVE gc_item_loggrp_inb TO gs_variant_item-log_group.
    ELSE.
      MOVE gc_item_loggrp_outb TO gs_variant_item-log_group.
    ENDIF.

    CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save        = gc_var_maint_user_specific
      CHANGING
        cs_variant    = gs_variant_item
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.

    IF gf_subitems EQ charx.
* subitems exist, filter subitems for first display

      CALL METHOD grid2->get_filter_criteria
        IMPORTING
          et_filter = lt_filter.

      READ TABLE lt_filter INTO ls_filter
                           WITH KEY fieldname = 'POSNR'
                                    low       = gc_subitem_low.
      IF sy-subrc EQ 0.
        DELETE lt_filter INDEX sy-tabix.
      ELSE.
        ls_filter-fieldname = 'POSNR'.
        ls_filter-low    = gc_subitem_low.
        ls_filter-high   = space.
        ls_filter-option = 'LT'.
        ls_filter-sign   = 'I'.
        APPEND ls_filter TO lt_filter.
      ENDIF.
    ENDIF.

    CALL METHOD grid2->set_table_for_first_display
      EXPORTING
        i_default            = gc_enable_set_default        "hp_332790
        i_save               = gc_var_maint_user_specific
        is_variant           = gs_variant_item
        is_print             = gs_print
        is_layout            = gs_layout_item
        it_toolbar_excluding = gt_toolbar_excluding
      CHANGING
        it_fieldcatalog      = gt_fieldcat_lvc_item[]
        it_outtab            = gt_outtab_item[]
        it_filter            = lt_filter[].

* § 4.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD grid2->set_toolbar_interactive.

  ELSE.
    DATA: ls_stable TYPE lvc_s_stbl.
    ls_stable-row = charx.
    ls_stable-col = charx.
    CALL METHOD grid2->refresh_table_display
      EXPORTING
        is_stable = ls_stable.
*   Refresh title if display extent has been changed
    IF sf_xlips_umfang NE xlips_umfang.                     "46B
      sf_xlips_umfang = xlips_umfang.
      IF xlips_umfang NE xlips_umfang_uhau.
        gs_layout_item-grid_title = text-018.
      ELSE.
        gs_layout_item-grid_title = text-019.
      ENDIF.
      CALL METHOD grid2->set_frontend_layout
        EXPORTING
          is_layout = gs_layout_item.
    ENDIF.

  ENDIF.

  CALL METHOD grid2->set_selected_rows
    EXPORTING
      it_index_rows = gt_index_rows[].

ENDFORM.                               " item_status_display
*&---------------------------------------------------------------------*
*&      Form  INIT_ALV_STATUS_DISPLAY
*&---------------------------------------------------------------------*
FORM init_alv_status_display.

* init data structure
*   delivery header data display structure
  CLEAR gt_outtab_header.
  REFRESH gt_outtab_header.
*   delivery item data display structure
  CLEAR gt_outtab_item.
  REFRESH gt_outtab_item.

* table for marked item lines
  CLEAR gt_index_rows.
  REFRESH gt_index_rows.

ENDFORM.                               " INIT_ALV_STATUS_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  SET_DISPLAY_CHARACTER
*&---------------------------------------------------------------------*
FORM set_display_character.

  DATA: lf_fname LIKE gt_color-fname.
  FIELD-SYMBOLS <fs_status>.

* delete Menubutton EXPORT, Button SUM, Button SUM_TOT
  APPEND cl_gui_alv_grid=>mc_mb_export    TO gt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_sum       TO gt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_subtot    TO gt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_detail    TO gt_toolbar_excluding.

* activate coloring
  gs_layout_header-ctab_fname = 'COLINFO'.
  gs_layout_item-ctab_fname = 'COLINFO'.
* optimize column width
  gs_layout_header-cwidth_opt = ' '.                        "46B
  gs_layout_item-cwidth_opt = ' '.
* send small title
  gs_layout_header-smalltitle = 'X'.                        "46B
  gs_layout_item-smalltitle = 'X'.

* check for initial state
  IF g_custom_container_01 IS INITIAL.

*   merge field catalog for delivery header
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'LEDLVSTATDISPHEAD'
      CHANGING
        ct_fieldcat      = gt_fieldcat_lvc_header[].

    LOOP AT gt_fieldcat_lvc_header.
      gt_fieldcat_lvc_header-no_out = 'X'.
      IF gt_fieldcat_lvc_header-dd_outlen EQ 1.
        gt_fieldcat_lvc_header-outputlen = 6.
        gt_fieldcat_lvc_header-just = 'CENTER'.
      ENDIF.
ENHANCEMENT-SECTION     MV50AFST_04 SPOTS ES_SAPMV50A.
      IF gt_fieldcat_lvc_header-fieldname = 'VBELN'.
        gt_fieldcat_lvc_header-col_pos = 1.
        gt_fieldcat_lvc_header-outputlen = 12.
        gt_fieldcat_lvc_header-key = charx.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'KOSTK'.
        gt_fieldcat_lvc_header-col_pos = 2.
        IF t180-bldgr EQ gc_new_dialog_inb.
          gt_fieldcat_lvc_header-scrtext_s = text-041.
          gt_fieldcat_lvc_header-scrtext_m = text-040.
          gt_fieldcat_lvc_header-scrtext_l = text-039.
          gt_fieldcat_lvc_header-tooltip   = text-039.
        ENDIF.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'PKSTK'.
        gt_fieldcat_lvc_header-col_pos = 3.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'LVSTK'.
        gt_fieldcat_lvc_header-col_pos = 4.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'KOQUK'.
        gt_fieldcat_lvc_header-col_pos = 5.
        IF t180-bldgr EQ gc_new_dialog_inb.
          gt_fieldcat_lvc_header-scrtext_s = text-044.
          gt_fieldcat_lvc_header-scrtext_m = text-043.
          gt_fieldcat_lvc_header-scrtext_l = text-042.
        ENDIF.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'WBSTK'.
        gt_fieldcat_lvc_header-col_pos = 6.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'FKSTK'.
        gt_fieldcat_lvc_header-col_pos = 7.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'FKIVK'.
        gt_fieldcat_lvc_header-col_pos = 8.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'TRSTA'.
        gt_fieldcat_lvc_header-col_pos = 9.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'CMGST'.
        gt_fieldcat_lvc_header-col_pos = 10.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'PDSTK'.
        gt_fieldcat_lvc_header-col_pos = 11.
        CLEAR gt_fieldcat_lvc_header-no_out.
      ELSEIF gt_fieldcat_lvc_header-fieldname = 'DUMMY'.
        gt_fieldcat_lvc_header-tech = charx.
      ENDIF.
END-ENHANCEMENT-SECTION.

      MODIFY gt_fieldcat_lvc_header.
    ENDLOOP.
  ENDIF.

* check for initial state
  IF g_custom_container_02 IS INITIAL.

* merge field catalog for delivery item
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'LEDLVSTATDISPITEM'
      CHANGING
        ct_fieldcat      = gt_fieldcat_lvc_item[].

    LOOP AT gt_fieldcat_lvc_item.
      gt_fieldcat_lvc_item-no_out  = 'X'.
      IF gt_fieldcat_lvc_item-dd_outlen EQ 1.
        gt_fieldcat_lvc_item-outputlen = 6.
        gt_fieldcat_lvc_item-just = 'CENTER'.
      ENDIF.
ENHANCEMENT-SECTION     SET_DISPLAY_CHARACTER_01 SPOTS ES_SAPMV50A.
      IF gt_fieldcat_lvc_item-fieldname EQ 'POSNR'.
        gt_fieldcat_lvc_item-col_pos = 1.
        gt_fieldcat_lvc_item-outputlen = 4.
        gt_fieldcat_lvc_item-key = charx.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'MATNR'.
        gt_fieldcat_lvc_item-col_pos = 2.
        gt_fieldcat_lvc_item-outputlen = 7.
        gt_fieldcat_lvc_item-key = charx.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'KOSTA'.
        gt_fieldcat_lvc_item-col_pos = 3.
        IF t180-bldgr EQ gc_new_dialog_inb.
          gt_fieldcat_lvc_item-scrtext_s = text-037.
          gt_fieldcat_lvc_item-scrtext_m = text-036.
          gt_fieldcat_lvc_item-scrtext_l = text-038.
        ENDIF.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'PKSTA'.
        gt_fieldcat_lvc_item-col_pos = 4.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'LVSTA'.
        gt_fieldcat_lvc_item-col_pos = 5.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'KOQUA'.
        gt_fieldcat_lvc_item-col_pos = 6.
        IF t180-bldgr EQ gc_new_dialog_inb.
          gt_fieldcat_lvc_item-scrtext_s = text-046.
          gt_fieldcat_lvc_item-scrtext_m = text-045.
          gt_fieldcat_lvc_item-scrtext_l = text-045.
        ENDIF.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'WBSTA'.
        gt_fieldcat_lvc_item-col_pos = 7.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'FKSTA'.
        gt_fieldcat_lvc_item-col_pos = 8.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'FKIVP'.     "46B
        gt_fieldcat_lvc_item-col_pos = 9.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'PDSTA'.
        gt_fieldcat_lvc_item-col_pos = 10.
        CLEAR gt_fieldcat_lvc_item-no_out.
      ELSEIF gt_fieldcat_lvc_item-fieldname EQ 'DUMMY'.
        gt_fieldcat_lvc_item-tech = charx.
      ENDIF.
END-ENHANCEMENT-SECTION.

      MODIFY gt_fieldcat_lvc_item.
    ENDLOOP.
  ENDIF.

* coloring header
  LOOP AT gt_outtab_header.
    REFRESH gt_color.
    CLEAR   gt_color.
    CLEAR   lf_fname.

    LOOP AT gt_fieldcat_lvc_header WHERE dd_outlen EQ 1.
    CONCATENATE 'GT_OUTTAB_HEADER' '-' gt_fieldcat_lvc_header-fieldname
                                                          INTO lf_fname.
      ASSIGN (lf_fname) TO <fs_status>.
      CHECK sy-subrc EQ 0.
      PERFORM maintain_color USING <fs_status>
                                    gt_fieldcat_lvc_header-fieldname.
ENHANCEMENT-POINT MV50AFST_05 SPOTS ES_SAPMV50A.
    ENDLOOP.

    gt_outtab_header-colinfo[] = gt_color[].
    MODIFY gt_outtab_header.
  ENDLOOP.

* coloring delivery item
  LOOP AT gt_outtab_item.
    REFRESH gt_color.
    CLEAR   gt_color.
    CLEAR   lf_fname.

*   colour special fields
    LOOP AT gt_fieldcat_lvc_item WHERE dd_outlen EQ 1.
      CONCATENATE 'GT_OUTTAB_ITEM' '-' gt_fieldcat_lvc_item-fieldname
                   INTO lf_fname.
      ASSIGN (lf_fname) TO <fs_status>.
      CHECK sy-subrc EQ 0.
      PERFORM maintain_color USING <fs_status>
                                   gt_fieldcat_lvc_item-fieldname.
    ENDLOOP.
    gt_outtab_item-colinfo[] = gt_color[].
    MODIFY gt_outtab_item.
  ENDLOOP.

* mark the item lines on ALV GRID
  LOOP AT ilips WHERE selkz = charx.
    READ TABLE gt_outtab_item WITH KEY posnr = ilips-posnr.
    IF sy-subrc EQ 0.
      gt_index_rows-index = sy-tabix.
      APPEND gt_index_rows.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " SET_DISPLAY_CHARACTER
*&---------------------------------------------------------------------*
*&      Form  MAINTAIN_COLOR
*&---------------------------------------------------------------------*
FORM maintain_color USING    if_status TYPE c
                             if_fname  LIKE lvc_s_fcat-fieldname.

  CHECK NOT if_status IS INITIAL.

  IF if_status = 'A'.
    gt_color-fname = if_fname.
    gt_color-color-col = 6.
    gt_color-color-int = 0.
    APPEND gt_color.
  ELSEIF if_status = 'B'.
    gt_color-fname = if_fname.
    gt_color-color-col = 3.
    gt_color-color-int = 0.
    APPEND gt_color.
  ELSEIF if_status = 'C'.
    gt_color-fname = if_fname.
    gt_color-color-col = 5.
    gt_color-color-int = 0.
    APPEND gt_color.
  ENDIF.
ENDFORM.                               " MAINTAIN_COLOR
*&---------------------------------------------------------------------*
*&      Form  GET_MARKED_ROWS
*&---------------------------------------------------------------------*
FORM get_marked_rows.

  DATA:    BEGIN OF lf_ilips OCCURS 15,
             posnr LIKE lips-posnr,
           END OF lf_ilips.

  CALL METHOD grid2->get_selected_rows
    IMPORTING
      et_index_rows = gt_index_rows[].

  LOOP AT gt_index_rows.
    READ TABLE gt_outtab_item INDEX gt_index_rows-index.
    IF sy-subrc EQ 0.
      lf_ilips-posnr = gt_outtab_item-posnr.
      APPEND lf_ilips.
    ENDIF.
  ENDLOOP.

  LOOP AT ilips.
    READ TABLE lf_ilips WITH KEY posnr = ilips-posnr.
    IF sy-subrc EQ 0.
* item is marked
      ilips-selkz = charx.
    ELSE.
* item is not marked
      CLEAR ilips-selkz.
    ENDIF.
    MODIFY ilips.
  ENDLOOP.

ENDFORM.                               " GET_MARKED_ROWS
*&---------------------------------------------------------------------*
*&      Form  TOGGLE_SUBITEM_DISPLAY
*&---------------------------------------------------------------------*
FORM toggle_subitem_display.
  DATA: ls_stable TYPE lvc_s_stbl.
  DATA: lt_filter TYPE lvc_t_filt.
  DATA: ls_filter TYPE lvc_s_filt.

  CHECK gf_subitems EQ charx.
* subitems exist, filter subitems for first display

  CALL METHOD grid2->get_filter_criteria
    IMPORTING
      et_filter = lt_filter.

  READ TABLE lt_filter INTO ls_filter
                       WITH KEY fieldname = 'POSNR'
                                low       = gc_subitem_low.
  IF sy-subrc EQ 0.
    DELETE lt_filter INDEX sy-tabix.
  ELSE.
    ls_filter-fieldname = 'POSNR'.
    ls_filter-low    = gc_subitem_low.
    ls_filter-high   = space.
    ls_filter-option = 'LT'.
    ls_filter-sign   = 'I'.
    APPEND ls_filter TO lt_filter.
  ENDIF.

  CALL METHOD grid2->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  ls_stable-row = charx.
  ls_stable-col = charx.
  CALL METHOD grid2->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.                               "TOGGLE_SUBITEM_DISPLAY
*---------------------------------------------------------------------*
*       CLASS CL_EVENT_RECV_HEAD_STATUS_DISP IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS cl_event_recv_head_status_disp IMPLEMENTATION.
  METHOD handle_double_click.

   READ TABLE gt_outtab_header INDEX e_row-index TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      CASE e_column.
        WHEN 'KOSTK'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HPIC_T'.
        WHEN 'PKSTK'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HPIC_T'.
        WHEN 'LVSTK'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HPIC_T'.
        WHEN 'KOQUK'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HPIC_T'.
        WHEN 'FKSTK'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HFIN_T'.
        WHEN 'TRSTA'.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HTRA_T'.
        WHEN OTHERS.
          CALL METHOD cl_gui_cfw=>set_new_ok_code
            EXPORTING
              new_code = 'HABW_T'.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "cl_event_recv_head_status_disp

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.
    DATA: lt_filter TYPE lvc_t_filt.
    DATA: ls_filter TYPE lvc_s_filt.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon to show legend
    CLEAR ls_toolbar.
    MOVE 'SLEG' TO ls_toolbar-function.
    MOVE 1 TO gs_toolbar-butn_type.
    MOVE space TO ls_toolbar-disabled.
    MOVE text-071 TO ls_toolbar-quickinfo.
    MOVE icon_icon_list TO ls_toolbar-icon.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "cl_event_recv_head_status_disp


  METHOD handle_user_command.
    DATA: ls_stable TYPE lvc_s_stbl.

    IF e_ucomm = 'SLEG'.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = 'SLEG_T'.
      CLEAR e_ucomm.
    ENDIF.
  ENDMETHOD.                    "cl_event_recv_head_status_disp

ENDCLASS.                    "cl_event_recv_head_status_disp
*---------------------------------------------------------------------*
*       CLASS CL_EVENT_RECV_ITEM_STATUS_DISP IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS cl_event_recv_item_status_disp IMPLEMENTATION.
  METHOD handle_double_click.
    DATA: ls_outtab_item LIKE gs_outtab_item.
    DATA: ls_ilips LIKE ilips.
    DATA: ls_xlips LIKE lips.

    READ TABLE gt_outtab_item INTO ls_outtab_item INDEX e_row-index.
    CHECK sy-subrc EQ 0.

* adjust ilips if necessary
    READ TABLE ilips INTO ls_ilips
                     WITH KEY posnr = ls_outtab_item-posnr.
    IF sy-subrc NE 0.
*    selected item is not in index
      READ TABLE xlips INTO ls_xlips
                       WITH KEY posnr = ls_outtab_item-posnr.
      IF sy-subrc EQ 0.
        IF ls_xlips-uecha IS INITIAL.
*          build ilips with main items.
          PERFORM ilips_aufbauen_alle IN PROGRAM sapfv50p.
          xlips_umfang = xlips_umfang_uall.
        ELSE.
*          build ilips with batch item.
          PERFORM ilips_aufbauen_struktur_chsp IN PROGRAM sapfv50p
                                                  USING ls_xlips-uecha.
          xlips_umfang = xlips_umfang_ucha.
        ENDIF.
      ENDIF.
    ENDIF.

    CASE e_column.
      WHEN 'MATNR'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'IMAT_T'.
      WHEN 'KOSTA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'IPIC_T'.
      WHEN 'PKSTA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'ILOA_T'.
      WHEN 'LVSTA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'IPIC_T'.
      WHEN 'KOQUA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'IPIC_T'.
      WHEN 'PDSTA'.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'LEBA_T'.
      WHEN OTHERS.
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'IABW_T'.
    ENDCASE.
  ENDMETHOD.                    "cl_event_recv_item_status_disp

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.
    DATA: lt_filter TYPE lvc_t_filt.
    DATA: ls_filter TYPE lvc_s_filt.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon to show legend
    CLEAR ls_toolbar.
    MOVE 'SLEG' TO ls_toolbar-function.
    MOVE 1 TO gs_toolbar-butn_type.
    MOVE space TO ls_toolbar-disabled.
    MOVE text-071 TO ls_toolbar-quickinfo.
    MOVE icon_icon_list TO ls_toolbar-icon.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    IF gf_subitems EQ charx.

* append a separator to normal toolbar
      CLEAR ls_toolbar.
      MOVE 3 TO ls_toolbar-butn_type.
      APPEND ls_toolbar TO e_object->mt_toolbar.

* additional button for subitem display
      CLEAR ls_toolbar.
      MOVE 'UPOS' TO ls_toolbar-function.
      MOVE 1 TO gs_toolbar-butn_type.
      MOVE space TO ls_toolbar-disabled.

      CALL METHOD grid2->get_filter_criteria
        IMPORTING
          et_filter = lt_filter.

      READ TABLE lt_filter INTO ls_filter
                           WITH KEY fieldname = 'POSNR'
                                    low       = gc_subitem_low.
      IF sy-subrc EQ 0.
        MOVE text-034 TO ls_toolbar-quickinfo.
        MOVE icon_expand TO ls_toolbar-icon.
      ELSE.
        MOVE text-035 TO ls_toolbar-quickinfo.
        MOVE icon_collapse TO ls_toolbar-icon.

      ENDIF.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.                             " subitems exist
  ENDMETHOD.                    "cl_event_recv_item_status_disp


  METHOD handle_user_command.
    DATA: ls_stable TYPE lvc_s_stbl.

    IF e_ucomm = 'UPOS'.
      PERFORM toggle_subitem_display.
      CLEAR e_ucomm.
    ENDIF.

    IF e_ucomm = 'SLEG'.
      CALL METHOD cl_gui_cfw=>set_new_ok_code
        EXPORTING
          new_code = 'SLEG_T'.
      CLEAR e_ucomm.
    ENDIF.
  ENDMETHOD.                           "handle_user_command
ENDCLASS.                    "cl_event_recv_item_status_disp