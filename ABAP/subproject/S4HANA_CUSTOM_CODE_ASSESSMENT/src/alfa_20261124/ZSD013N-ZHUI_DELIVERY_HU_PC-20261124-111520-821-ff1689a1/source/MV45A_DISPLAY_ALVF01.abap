*----------------------------------------------------------------------*
***INCLUDE MV45A_DISPLAY_ALVF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Form display_alv prepares the search query, prepares the ALV
*       GRID, perfomes the search, builds the ALV GRID and displays
*       the result.
*----------------------------------------------------------------------*

FORM display_alv .

  DATA:
      event_receiver_cs     TYPE REF TO cl_event_receiver_cs,

* Tables
      lt_object_type_key    TYPE com_search_tt_object_type_key,
      lt_query              TYPE trext_query_entries,
      lt_req_attribute      TYPE trext_attributes,
      lt_result_item        TYPE com_search_tt_result_item,
      lt_sort_attribute     TYPE trext_sort_attributes,
      lt_fieldcatalog       TYPE lvc_t_fcat,
      lt_toolbar_excluding  TYPE ui_functions,
      lt_index_list         TYPE com_search_tt_index_list_objty,
      lt_object_types       TYPE com_search_tt_object_type_key,
      lt_result             TYPE tdt_search_customer,
      lt_messages           TYPE cl_lo_oif_services=>tct_messages,

* Structured workareas
      ls_query              TYPE LINE OF trext_query_entries,
      ls_req_attribute      TYPE LINE OF trext_attributes,
      ls_sort_attribute     TYPE LINE OF trext_sort_attributes,
      ls_object_type_key    TYPE com_search_ts_object_type_key,
      ls_result_attributes  TYPE trexs_doc_attributes,
      ls_result_item        TYPE LINE OF com_search_tt_result_item,
      ls_fieldcatalog       TYPE lvc_s_fcat,
      ls_toolbar_excluding  TYPE ui_func,
      ls_msg                TYPE tds_error,
      ls_object_types       LIKE LINE OF lt_object_types,
      ls_index_list         LIKE LINE OF lt_index_list,
      ls_result             LIKE LINE OF lt_result,
      ls_messages           TYPE tds_error,
      ls_sales_area         TYPE tds_lo_oif_salesarea,

* Variables
      lv_no_of_hits         TYPE i,
      lv_string_convert     TYPE string,
      lv_search_string      TYPE string,
      lv_vkorg              LIKE vbak-vkorg,
      lv_vtweg              LIKE vbak-vtweg,
      lv_spart              LIKE vbak-spart,
      lv_term_action        TYPE trexd_term_action. "linguistic

* Constants
  CONSTANTS:
       lc_msgty_s           TYPE sy-msgty VALUE 'S',
       lc_msgty_i           TYPE sy-msgty VALUE 'I',
       lc_msgty_w           TYPE sy-msgty VALUE 'W',
       lc_msgty_e           TYPE sy-msgty VALUE 'E',
       lc_maxrecords        TYPE i VALUE 500.


  SET PF-STATUS 'CS01'.

* check if index for business object KNA1 exists
  ls_object_types-object_type = '1'.
  ls_object_types-busobj = 'KNA1'.

  APPEND ls_object_types TO lt_object_types.
  CALL METHOD cl_com_se_custom_read=>get_index_list_for_obj_types
    EXPORTING
      it_object_types            = lt_object_types
      iv_only_active_indexes     = 'X'
*    iv_query_language          =
*    iv_favorite_result_langu   =
*    iv_index_type              = ''
    IMPORTING
      et_index_list_for_objty    = lt_index_list
*    et_indexes                 =
    EXCEPTIONS
      busobj_not_defined         = 1
      favorite_langu_not_defined = 2
      OTHERS                     = 3
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE lc_msgty_s  NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    leave_without_check = abap_true.
    LEAVE TO SCREEN 0.
  ENDIF.

  LOOP AT lt_index_list INTO ls_index_list.
    IF ls_index_list-entry_found = abap_false.
      MESSAGE s445(v2).
      leave_without_check = abap_true.
      LEAVE TO SCREEN 0.
    ENDIF.
    IF ls_index_list-index_active = abap_false.
      MESSAGE s447(v2).
      leave_without_check = abap_true.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDLOOP.



*START SEARCH

  ls_sales_area-vkorg = xvbak-vkorg.
  ls_sales_area-vtweg = xvbak-vtweg.
  ls_sales_area-spart = xvbak-spart.

  lv_search_string = tds_kunag_search_term-term.

*set search mode (exact, fuzzy, liguistic)
  CASE search_mode.
    WHEN 1.
      lv_term_action = cl_lo_oif_services=>gc_term_action_e.
    WHEN 2.
      lv_term_action = cl_lo_oif_services=>gc_term_action_f.
    WHEN 3.
      lv_term_action = cl_lo_oif_services=>gc_term_action_l.
  ENDCASE.

*call search routine
  CALL METHOD cl_lo_oif_services=>search_customer
    EXPORTING
      iv_search_term = lv_search_string
      iv_term_action = lv_term_action
      is_sarea       = ls_sales_area
*      iv_hold_data   = SPACE
    IMPORTING
      et_customer    = lt_result
      et_message     = lt_messages.


* Process first error message
  LOOP AT lt_messages
       INTO ls_messages
       WHERE msgty EQ lc_msgty_e.
    MESSAGE ID ls_messages-msgid
            TYPE lc_msgty_s
            NUMBER ls_messages-msgno
            WITH ls_messages-msgv1
                 ls_messages-msgv2
                 ls_messages-msgv3
                 ls_messages-msgv4.
    leave_without_check = abap_true.
    LEAVE TO SCREEN 0.
  ENDLOOP.
*  Process warning message
    LOOP AT lt_messages
         INTO ls_messages
         WHERE msgty EQ lc_msgty_w.
      MESSAGE ID ls_messages-msgid
              TYPE lc_msgty_s
              NUMBER ls_messages-msgno
              WITH ls_messages-msgv1
                   ls_messages-msgv2
                   ls_messages-msgv3
                   ls_messages-msgv4.
    leave_without_check = abap_true.
    LEAVE TO SCREEN 0.
    ENDLOOP.

*  Process status and information messages
    LOOP AT lt_messages
         INTO ls_messages.
      MESSAGE ID ls_messages-msgid
              TYPE lc_msgty_s
              NUMBER ls_messages-msgno
              WITH ls_messages-msgv1
                   ls_messages-msgv2
                   ls_messages-msgv3
                   ls_messages-msgv4.
    ENDLOOP.


  lv_no_of_hits = LINES( lt_result ).

  IF lv_no_of_hits = 0.
*no search result
    leave_without_check = abap_true.
    LEAVE TO SCREEN 0.
  ENDIF.


  CLEAR gt_sold_to_party.
  LOOP AT lt_result INTO ls_result.
    MOVE-CORRESPONDING ls_result TO gs_sold_to_party.
    APPEND gs_sold_to_party TO gt_sold_to_party.
  ENDLOOP.


  IF lv_no_of_hits = 1.
*only one search result -> no selection popup necessary
    READ TABLE lt_result INDEX 1 INTO ls_result.
    gv_kunnr_from_search = ls_result-kunnr.
    gv_set_kunnr = abap_true.
    MESSAGE s446(v2) WITH tds_kunag_search_term-term.
*   Eindeutiges Ergebnis zu '&1' wurde übernommen.
    LEAVE TO SCREEN 0.
  ENDIF.



  lv_string_convert = lv_no_of_hits.
  CONCATENATE text-s01 ': (' lv_string_convert text-s02 ') ' INTO g_layout1-grid_title .
  g_layout1-no_toolbar = abap_true.


* prepare ALV GRID

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'TDS_SEARCH_CUSTOMER'
    CHANGING
      ct_fieldcat      = lt_fieldcatalog.

  LOOP AT lt_fieldcatalog INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
      WHEN 'KUNNR'.
        ls_fieldcatalog-outputlen = 10.
      WHEN 'NAME'.
        ls_fieldcatalog-outputlen = 15.
      WHEN 'NAME_2'.
        ls_fieldcatalog-outputlen = 15.
      WHEN 'POSTL_COD1'.
        ls_fieldcatalog-outputlen = 6.
      WHEN 'CITY'.
        ls_fieldcatalog-outputlen = 9.
      WHEN 'STREET'.
        ls_fieldcatalog-outputlen = 8.
      WHEN 'HOUSE_NO'.
        ls_fieldcatalog-outputlen = 3.
    ENDCASE.
    MODIFY lt_fieldcatalog FROM ls_fieldcatalog
     TRANSPORTING outputlen.
  ENDLOOP.

  ls_toolbar_excluding = cl_gui_alv_grid=>mc_fc_excl_all.
  APPEND ls_toolbar_excluding TO lt_toolbar_excluding.
  ls_toolbar_excluding = cl_gui_alv_grid=>mc_fc_col_optimize.
  APPEND ls_toolbar_excluding TO lt_toolbar_excluding.
  ls_toolbar_excluding = cl_gui_alv_grid=>mc_fc_unfix_columns.
  APPEND ls_toolbar_excluding TO lt_toolbar_excluding.

  IF g_custom_container IS INITIAL.
* first display of ALV

    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.
    CREATE OBJECT grid1
      EXPORTING
        i_parent      = g_custom_container
        i_appl_events = abap_true.
    CREATE OBJECT event_receiver_cs.

    CALL METHOD grid1->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

*     handler for ALV grid
    SET HANDLER event_receiver_cs->handle_double_click FOR grid1.

* display result
    CALL METHOD grid1->set_table_for_first_display
      EXPORTING
        is_layout                     = g_layout1
        it_toolbar_excluding          = lt_toolbar_excluding
      CHANGING
        it_outtab                     = gt_sold_to_party
        it_fieldcatalog               = lt_fieldcatalog
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.
* ALV had been displayed at least once

    IF NOT gv_right_click = abap_true.
* display result
      CALL METHOD grid1->set_table_for_first_display
        EXPORTING
          is_layout                     = g_layout1
          it_toolbar_excluding          = lt_toolbar_excluding
        CHANGING
          it_outtab                     = gt_sold_to_party
          it_fieldcatalog               = lt_fieldcatalog
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " DISPLAY_ALV