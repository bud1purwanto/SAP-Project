*---------------------------------------------------------------------*
*       CLASS lcl_migo_tableview IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_migo_tableview IMPLEMENTATION.

  INCLUDE lmigotv3.                    "Tableview buttons
  INCLUDE lmigotv4.                    "Field modification, PBO

************************************************************************
* Constructor
************************************************************************
  METHOD constructor.
    DATA: lt_receiving TYPE lif_migo_frame=>ty_t_message_ids,
          lt_sending   TYPE lif_migo_frame=>ty_t_message_ids,
          lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes.
*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_TABLEVIEW'.
* Messages
    APPEND 'ITEMDETAIL_CURRENTLINE'      TO lt_receiving.
    APPEND 'MIGO_DETAIL_TOGGLER_STATUS'  TO lt_receiving.
    APPEND 'MIGO_TV_TOGGLER_STATUS'      TO lt_receiving.
    APPEND 'MIGO_SCROLL'                 TO lt_receiving.
    APPEND 'TABLEVIEW_LINE_SET'          TO lt_receiving.
    APPEND 'ITEMDETAIL_LINE_SET'         TO lt_sending.
    APPEND 'ITEMDETAIL_OPEN'             TO lt_sending.
    APPEND 'GA_OPEN'                     TO lt_sending.
    APPEND 'SPLIT_QUANTITY'              TO lt_sending.
    APPEND 'MIGO_TIP_REQUEST'            TO lt_sending.
    APPEND 'DETERMINE_SINGLE'            TO lt_sending.
    APPEND 'DETERMINE_ALL'               TO lt_sending.
* Okcodes
    APPEND 'MIGO_OK_SEARCH_STRG'    TO lt_okcodes.
    APPEND 'MIGO_OK_SEARCH_NEXT'    TO lt_okcodes.
    APPEND 'MIGO_OK_SORT_DOWN'      TO lt_okcodes.
    APPEND 'MIGO_OK_SORT_UP'        TO lt_okcodes.
    APPEND 'MIGO_OK_LINE_CLICK'     TO lt_okcodes.
    APPEND 'MIGO_OK_LOGLEVEL'       TO lt_okcodes.
    APPEND 'MIGO_OK_NOT_OK'         TO lt_okcodes.
    APPEND 'MIGO_OK_SPLIT_QUAN'     TO lt_okcodes.
    APPEND 'MIGO_OK_NOT_ORDERED'    TO lt_okcodes.
    APPEND 'MIGO_OK_CONTAINER'      TO lt_okcodes.
    APPEND 'MIGO_OK_NEW_ITEMS'      TO lt_okcodes.
    APPEND 'MIGO_OK_TAKE_VALUE'     TO lt_okcodes.
    APPEND 'MIGO_OK_EXPAND'         TO lt_okcodes.
    APPEND 'MIGO_OK_EXPAND_BOM'     TO lt_okcodes.
    APPEND 'MIGO_OK_DET_LINE'       TO lt_okcodes.
    APPEND 'MIGO_OK_DET_ALL'        TO lt_okcodes.
ENHANCEMENT-POINT LCL_MIGO_TABLEVIEW_01 SPOTS ES_SAPLMIGO.
    APPEND 'MIGO_OK_DOC_BATCH_DT'   TO lt_okcodes.
ENHANCEMENT-POINT LMIGOTV2_02 SPOTS ES_SAPLMIGO.
    "$$
    "$$
    "$$
ENHANCEMENT-POINT LCL_MIGO_TABLEVIEW_02 SPOTS ES_SAPLMIGO.
    APPEND 'MIGO_OK_GA_VARIANTS'    TO lt_okcodes.
    APPEND 'MIGO_OK_ADD_VARIANT'    TO lt_okcodes.

    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_receiving  = lt_receiving
        it_sending    = lt_sending
        it_okcodes    = lt_okcodes.
  ENDMETHOD.                    "constructor

************************************************************************
* OK-code handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    DATA: l_line        TYPE sytabix,
          l_search_next TYPE abap_bool,
          l_sort_up     TYPE abap_bool,
          l_name        TYPE lcl_migo_screenobject=>ty_name,
          ls_control    TYPE lcl_migo_kernel=>ty_s_control,
          ls_message    TYPE lif_migo_frame=>ty_s_message.
ENHANCEMENT-POINT LMIGOTV2_07 SPOTS ES_SAPLMIGO STATIC.

    CASE i_okcode.
      WHEN 'MIGO_OK_LINE_CLICK'.
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_tabix = l_line
              e_name  = l_name.
          CHECK l_name = 'TABLEVIEW'.
          def_sms 'ITEMDETAIL_LINE_SET' l_line space.
          def_sms 'ITEMDETAIL_OPEN'     space  space.
        ENDIF.
      WHEN 'MIGO_OK_LOGLEVEL'.
*       Display log for an item
        CALL METHOD log_display.
      WHEN 'MIGO_OK_EXPAND'.
*       f.e. for subcontract order
        CALL METHOD line_expand_collapse.
      WHEN 'MIGO_OK_SORT_UP'.
        l_sort_up = abap_true.
        CALL METHOD tableview_sort( l_sort_up ).
      WHEN 'MIGO_OK_SORT_DOWN'.
        l_sort_up  = abap_false.
        CALL METHOD tableview_sort( l_sort_up ).
      WHEN 'MIGO_OK_SEARCH_STRG'.
        l_search_next = abap_false.
        CALL METHOD tableview_search( l_search_next ).
      WHEN 'MIGO_OK_SEARCH_NEXT'.
        l_search_next = abap_true.
        CALL METHOD tableview_search( l_search_next ).
      WHEN 'MIGO_OK_NOT_OK'.
*       Delete all lines with take_it = space
        CALL METHOD tableview_delete_not_ok.
      WHEN 'MIGO_OK_SPLIT_QUAN'.
*       Call popup for to split the quantity in serveral lines
        IF p_itemdetail_visible = abap_true.
          def_sms 'SPLIT_QUANTITY' p_itemdetail_line space.
        ELSE.
          IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
            CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
              IMPORTING
                e_tabix = l_line
                e_name  = l_name.
          ENDIF.
          IF l_name = 'TABLEVIEW' AND l_line <> 0.
            def_sms 'SPLIT_QUANTITY' l_line space.
          ELSE.
            MESSAGE s031.
          ENDIF.
        ENDIF.
      WHEN 'MIGO_OK_DET_LINE'.
*       Batch/stock determination for a single line item in the TC
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_tabix = l_line
              e_name  = l_name.
          IF l_name = 'TABLEVIEW' AND l_line <> 0.
            def_sms 'DETERMINE_SINGLE' l_line space.
          ENDIF.
        ENDIF.
      WHEN 'MIGO_OK_DET_ALL'.
*       Batch/stock determination for all lines
        def_sms 'DETERMINE_ALL' space space.
      WHEN 'MIGO_OK_EXPAND_BOM'.
*       Expand the bill of material
        IF p_itemdetail_visible = abap_true.
          CALL METHOD lcl_migo_globals=>kernel->line_expand_collapse
            EXPORTING
              i_line   = p_itemdetail_line
              i_okcode = i_okcode.
        ELSE.
          IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
            CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
              IMPORTING
                e_tabix = l_line
                e_name  = l_name.
          ENDIF.
          IF l_name = 'TABLEVIEW' AND l_line <> 0.
            CALL METHOD lcl_migo_globals=>kernel->line_expand_collapse
              EXPORTING
                i_line   = l_line
                i_okcode = i_okcode.
          ELSE.
            MESSAGE s036.
          ENDIF.
        ENDIF.
      WHEN 'MIGO_OK_NOT_ORDERED'.
*       Switch to NEW_POSITION
        ls_control = lcl_migo_globals=>kernel->mode_get( ).
        ls_control-new_line_mode = p.
        CALL METHOD lcl_migo_globals=>kernel->mode_set
          EXPORTING
            is_control = ls_control.
      WHEN 'MIGO_OK_CONTAINER'.
*       Switch to CONTAINER
        ls_control = lcl_migo_globals=>kernel->mode_get( ).
        ls_control-new_line_mode = c.
        CALL METHOD lcl_migo_globals=>kernel->mode_set
          EXPORTING
            is_control = ls_control.
      WHEN 'MIGO_OK_NEW_ITEMS'.
*       Switch to NEW_POSITION (for GI-mode)
        ls_control = lcl_migo_globals=>kernel->mode_get( ).
        ls_control-new_line_mode = x.
        CALL METHOD lcl_migo_globals=>kernel->mode_set
          EXPORTING
            is_control = ls_control.
      WHEN 'MIGO_OK_TAKE_VALUE'.
        CALL METHOD valuecopy.
      WHEN 'MIGO_OK_DOC_BATCH_DT'.
*       Switch to detail screen documentary batch
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
          CLEAR ls_message.
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_tabix = l_line
              e_name  = l_name.
          CHECK l_name = 'TABLEVIEW'.
          def_sms 'ITEMDETAIL_LINE_SET' l_line space.
          def_sms 'ITEMDETAIL_OPEN'     space  space.
          ls_message-data1 = l_line.
          ls_message-data2 = 'GOITEM-DOCUBATCH_CHARG'.
          CALL METHOD lcl_migo_frame=>message_send
            EXPORTING
              i_message_id     = 'SET_CURSOR_POSITION'
              is_message       = ls_message
              i_system_message = abap_true.
        ENDIF.
* Retail: generic articles, edit existing variants
      WHEN 'MIGO_OK_GA_VARIANTS'.
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_tabix = l_line
              e_name  = l_name.
          IF l_name = 'FIRSTLINE' AND l_line = 0.
            l_line = 1.
          ENDIF.
          def_sms 'ITEMDETAIL_LINE_SET' l_line space.
          def_sms 'GA_OPEN' space space.
          CALL METHOD lcl_migo_globals=>kernel->ga_variants_edit
            EXPORTING
              i_line = l_line.
        ENDIF.
* Retail: generic articles, create new variants by matrix
      WHEN 'MIGO_OK_ADD_VARIANT'.
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL.
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_tabix = l_line
              e_name  = l_name.
          IF l_name = 'FIRSTLINE' AND l_line = 0.
            l_line = 1.
          ENDIF.
          def_sms 'ITEMDETAIL_LINE_SET' l_line space.
          CALL METHOD lcl_migo_globals=>kernel->ga_variants_edit
            EXPORTING
              i_line        = l_line
              i_new_variant = 'NV'.
          def_sms 'GA_OPEN' space space.
        ENDIF.
* IS2ERP, IS OK-codes are handled in 'WHEN OTHERS'
      WHEN OTHERS.
ENHANCEMENT-POINT LMIGOTV2_01 SPOTS ES_SAPLMIGO.

    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

************************************************************************
* Message handler
************************************************************************
  METHOD lif_migo_frame~message_handler.
ENHANCEMENT-SECTION     LMIGOTV2_04 SPOTS ES_SAPLMIGO.
    "$$
    CASE i_message_id.
      WHEN 'ITEMDETAIL_CURRENTLINE'.
        p_itemdetail_line = is_message-data1.
        CALL METHOD tableview_line_show( p_itemdetail_line ).
      WHEN 'MIGO_DETAIL_TOGGLER_STATUS'.
        IF is_message-data1 = 'VISIBILITY'.
          p_itemdetail_visible = is_message-data2.
        ENDIF.
      WHEN 'MIGO_TV_TOGGLER_STATUS'.
        IF is_message-data1 = 'VISIBILITY'.
          p_ga_visible = is_message-data2.
        ENDIF.
      WHEN 'MIGO_SCROLL'.
        CHECK is_message-data1 = 'TABLEVIEW'.
        CASE is_message-data2.
          WHEN 'P--'.
            tv_goitem-top_line = 1.
          WHEN 'P- '.
            tv_goitem-top_line = tv_goitem-top_line - p_displayed_lines.
          WHEN 'P++'.
            tv_goitem-top_line = tv_goitem-lines.
          WHEN 'P+ '.
            tv_goitem-top_line = tv_goitem-top_line + p_displayed_lines.
            IF tv_goitem-top_line > tv_goitem-lines.
              tv_goitem-top_line = tv_goitem-lines.
            ENDIF.
        ENDCASE.
      WHEN 'TABLEVIEW_LINE_SET'.
        tv_goitem-top_line = is_message-data1.
    ENDCASE.
END-ENHANCEMENT-SECTION.
    "$$
  ENDMETHOD.                    "lif_migo_frame~message_handler

************************************************************************
* PAI module before loop
************************************************************************
  METHOD pai.
    CALL METHOD super->pai.
  ENDMETHOD.                    "pai

************************************************************************
* PAI module within LOOP: Transfer data back to the kernel
************************************************************************
  METHOD pai_loop.
    DATA: ls_goitem TYPE goitem.
* Nothing to change if this is the line where the itemdetail is
ENHANCEMENT-SECTION     LMIGOTV2_05 SPOTS ES_SAPLMIGO.
    "$$
    IF ( p_itemdetail_visible = abap_true AND
         p_itemdetail_line    = tv_goitem-current_line ).
      EXIT.
    ENDIF.
* get data from TV using a filter goitem_tv (contains all fields on
* screen 0200/ in TV)
    MOVE-CORRESPONDING goitem TO goitem_tv.
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING
        i_line    = tv_goitem-current_line
      IMPORTING
        es_goitem = ls_goitem.
    MOVE-CORRESPONDING goitem_tv TO ls_goitem.
    MOVE goitem-umhsdat TO ls_goitem-umhsdat.                   "1111534
    MOVE goitem-umvfdat TO ls_goitem-umvfdat.                   "1111534
    CALL METHOD lcl_migo_globals=>kernel->line_modify
      EXPORTING
        i_line            = tv_goitem-current_line
        i_authority_check = abap_false
      CHANGING
        cs_goitem         = ls_goitem.
END-ENHANCEMENT-SECTION.
    "$$
  ENDMETHOD.                    "pai_loop

************************************************************************
* Display application log for an item
************************************************************************
  METHOD log_display.
    DATA: l_line TYPE sy-tabix,
          l_global_counter TYPE migo_global_counter.
    CALL METHOD cursor_position_resolve
      IMPORTING
        e_tabix = l_line.
    CALL METHOD lcl_migo_globals=>kernel->line_mapping
      EXPORTING
        i_line           = l_line
      IMPORTING
        e_global_counter = l_global_counter.
    CALL METHOD oref_log->display
      EXPORTING
        i_item           = abap_true
        i_global_counter = l_global_counter.
  ENDMETHOD.                    "log_display

************************************************************************
* Button to expand/collapse a line
************************************************************************
  METHOD line_expand_collapse.
    DATA: l_line TYPE sy-tabix.
    CALL METHOD cursor_position_resolve
      IMPORTING
        e_tabix = l_line.
    def_sms 'ITEMDETAIL_LINE_SET' l_line space.
    CALL METHOD lcl_migo_globals=>kernel->line_expand_collapse
      EXPORTING
        i_line = l_line.
  ENDMETHOD.                    "line_expand_collapse


ENDCLASS.                    "lcl_migo_tableview IMPLEMENTATION


*---------------------------------------------------------------------*
*       CLASS lcl_migo_tableview_buttons IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_migo_tableview_buttons IMPLEMENTATION.
ENDCLASS.                    "lcl_migo_tableview_buttons IMPLEMENTATION