*----------------------------------------------------------------------*
***INCLUDE MV45A_TM_PBO_4798 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_4798  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_4798 OUTPUT.
  PERFORM display_alv_head.
  PERFORM display_alv_item.
ENDMODULE.                 " PBO_4798  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_HEAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv_head .

  DATA:
    ls_status           TYPE tms_s_doc_status_scr,
    ls_layout           TYPE lvc_s_layo,
    ls_variant          TYPE disvariant,
    lt_head_fcat        TYPE lvc_t_fcat,
    ls_message          TYPE bapiret2,
    lt_messages         TYPE bapirettab,
    lo_event_handler    TYPE REF TO cl_tm_event_handler.

  FIELD-SYMBOLS:
     <ls_fcat>          TYPE lvc_s_fcat.

  CALL METHOD gr_tm_docflow->get_doument_status
    EXPORTING
      iv_doc_type   = gv_tm_doc_type
      iv_doc_nr     = gv_tm_doc_nr
    IMPORTING
      es_status_hdr = ls_status
      et_messages   = lt_messages.
  READ TABLE lt_messages INTO ls_message INDEX 1.
  IF sy-subrc IS INITIAL.
    MESSAGE
      ID     ls_message-id
      TYPE   ls_message-type
      NUMBER ls_message-number
      WITH   ls_message-message.
  ENDIF.

  CLEAR gt_tm_head_sts.

  ls_status-tm_ctrl_key = gv_tm_ctrl_key.
  ls_status-tm_ctrl_key_desc = gv_tm_ctrl_key_desc.
  APPEND ls_status TO gt_tm_head_sts.


* ---------------------- Build ALV Grid for Header status --------------------------

  IF g_tm_cont_head IS NOT BOUND.

    CREATE OBJECT g_tm_cont_head
      EXPORTING
        container_name = 'G_CONTAINER_HEAD'.

    lt_head_fcat = gr_tm_docflow->get_head_fcat( ).

    CLEAR ls_layout.
    ls_layout-cwidth_opt = abap_true.
    ls_layout-sel_mode = 'A'.
    ls_layout-grid_title = 'Header Status'.
    ls_layout-smalltitle = abap_true.

    CLEAR ls_variant.
    ls_variant-report = sy-repid.

    CREATE OBJECT gr_tm_table_head
      EXPORTING
        i_parent = g_tm_cont_head.

    gr_tm_table_head->set_table_for_first_display(
      EXPORTING
        is_layout        = ls_layout
        i_default        = 'X'
        i_save           = 'A'
        is_variant       = ls_variant
      CHANGING
        it_outtab        = gt_tm_head_sts
        it_fieldcatalog  = lt_head_fcat ).

* ------------------ handle events --------------------
    CREATE OBJECT lo_event_handler.
    SET HANDLER lo_event_handler->handle_header_user_command FOR gr_tm_table_head.
    SET HANDLER lo_event_handler->handle_header_toolbar      FOR gr_tm_table_head.

    gr_tm_table_head->set_toolbar_interactive( ).

  ENDIF.

ENDFORM.                    " DISPLAY_ALV_HEAD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv_item.
  DATA:
    ls_layout           TYPE lvc_s_layo,
    ls_variant          TYPE disvariant,
    lt_item_fcat        TYPE lvc_t_fcat,
    lo_event_handler    TYPE REF TO cl_tm_event_handler.

  FIELD-SYMBOLS:
    <ls_fcat>           TYPE lvc_s_fcat.

  CLEAR gt_tm_item_sts.

  gr_tm_docflow->get_doument_status(
    EXPORTING
      iv_doc_type    = gv_tm_doc_type
      iv_doc_nr      = gv_tm_doc_nr
    IMPORTING
      et_status_item = gt_tm_item_sts ).


* ---------------------- Build ALV Grid for Item status --------------------------
  IF g_tm_cont_item IS NOT BOUND.

    CREATE OBJECT g_tm_cont_item
      EXPORTING
        container_name = 'G_CONTAINER_ITEM'.

    lt_item_fcat = gr_tm_docflow->get_item_fcat( ).

    CLEAR ls_layout.
    ls_layout-cwidth_opt = abap_true.
    ls_layout-sel_mode = ' '.
    ls_layout-grid_title = 'Item Status'.
    ls_layout-smalltitle = abap_true.

    CLEAR ls_variant.
    ls_variant-report = sy-repid.

    CREATE OBJECT gr_tm_table_item
      EXPORTING
        i_parent = g_tm_cont_item.

    gr_tm_table_item->set_table_for_first_display(
      EXPORTING
        is_layout        = ls_layout
        i_default        = 'X'
        i_save           = 'A'
        is_variant       = ls_variant
      CHANGING
        it_outtab        = gt_tm_item_sts
        it_fieldcatalog  = lt_item_fcat ).

* ------------------ handle events --------------------
    CREATE OBJECT lo_event_handler.
    SET HANDLER lo_event_handler->handle_item_user_command FOR gr_tm_table_item.
    SET HANDLER lo_event_handler->handle_item_toolbar      FOR gr_tm_table_item.

    gr_tm_table_item->set_toolbar_interactive( ).

  ENDIF.

ENDFORM.                    " DISPLAY_ALV_ITEM