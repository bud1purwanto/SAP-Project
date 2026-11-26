*&---------------------------------------------------------------------*
*&  Include           MV50A_TM_HANDLER_CLASS
*&---------------------------------------------------------------------*

CLASS cl_tm_event_handler DEFINITION.
  PUBLIC SECTION.

    METHODS:

      handle_header_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object,

      handle_item_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object,

      handle_header_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm,

      handle_item_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm.


ENDCLASS.                    "cl_tm_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_tm_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_tm_event_handler IMPLEMENTATION.

  METHOD  handle_header_toolbar.

    DATA:
      ls_toolbar        TYPE stb_button.

*....................................................................
* E_OBJECT of event TOOLBAR is of type REF TO CL_ALV_EVENT_TOOLBAR_SET.
* This class has got one attribute, namly MT_TOOLBAR, which
* is a table of type TTB_BUTTON. One line of this table is
* defined by the Structure STB_BUTTON (see data deklaration above).
*....................................................................

    LOOP AT e_object->mt_toolbar INTO ls_toolbar.
      IF ls_toolbar-function EQ '&DETAIL'
      OR ls_toolbar-function EQ '&PRINT_BACK'
      OR ls_toolbar-function EQ '&MB_VIEW'
      OR ls_toolbar-function EQ '&MB_EXPORT'
      OR ls_toolbar-function EQ '&MB_VARIANT'
      OR ls_toolbar-function EQ '&INFO'.
      ELSE.
        IF ls_toolbar-function NP '&&SEP*'.
          DELETE e_object->mt_toolbar INDEX sy-tabix.
        ENDIF.
      ENDIF.
    ENDLOOP.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon to display document flow of selected items
    CLEAR ls_toolbar.
    MOVE 'DSP_DOCFLOW' TO ls_toolbar-function.
    ls_toolbar-quickinfo = text-tm1.
    ls_toolbar-text      = text-tm2.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "lcl_event_handler

  METHOD handle_item_toolbar.

    DATA:
      ls_toolbar        TYPE stb_button.

*....................................................................
* E_OBJECT of event TOOLBAR is of type REF TO CL_ALV_EVENT_TOOLBAR_SET.
* This class has got one attribute, namly MT_TOOLBAR, which
* is a table of type TTB_BUTTON. One line of this table is
* defined by the Structure STB_BUTTON (see data deklaration above).
*....................................................................

    READ TABLE e_object->mt_toolbar
      TRANSPORTING NO FIELDS
      WITH KEY function = '&MB_SUBTOT'.
    IF sy-subrc = 0.
      DELETE e_object->mt_toolbar INDEX sy-tabix.
    ENDIF.
    READ TABLE e_object->mt_toolbar
      TRANSPORTING NO FIELDS
      WITH KEY function = '&GRAPH'.
    IF sy-subrc = 0.
      DELETE e_object->mt_toolbar INDEX sy-tabix.
    ENDIF.
    READ TABLE e_object->mt_toolbar
      TRANSPORTING NO FIELDS
      WITH KEY function = '&MB_SUM'.
    IF sy-subrc = 0.
      DELETE e_object->mt_toolbar INDEX sy-tabix.
    ENDIF.

* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* append an icon to display document flow of selected items
    CLEAR ls_toolbar.
    MOVE 'DSP_DOCFLOW' TO ls_toolbar-function.
    ls_toolbar-quickinfo = text-tm1.
    ls_toolbar-text      = text-tm2.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_item_toolbar

  METHOD handle_header_user_command.
    DATA:
      lv_doc_type       TYPE tms_doc_type,
      lv_doc_nr         TYPE tms_doc_nr,
      ls_message        TYPE bapiret2,
      lt_messages       TYPE bapirettab.

    FIELD-SYMBOLS:
      <fs_sts>          TYPE tms_s_doc_status_scr.

    CASE e_ucomm.
      WHEN 'DSP_DOCFLOW'.
        READ TABLE gt_tm_item_sts
          ASSIGNING <fs_sts>
          INDEX 1.
        IF sy-subrc IS INITIAL.
          lv_doc_type = <fs_sts>-doc_type.
          lv_doc_nr   = <fs_sts>-vbeln_dlv.
        ENDIF.

        gr_tm_docflow->display_docflow(
           EXPORTING
            iv_doc_type = lv_doc_type
            iv_doc_nr   = lv_doc_nr
            IMPORTING
            et_messages = lt_messages ).
        READ TABLE lt_messages INTO ls_message INDEX 1.
        IF sy-subrc IS INITIAL.
          MESSAGE
            ID     ls_message-id
            TYPE   ls_message-type
            NUMBER ls_message-number
            WITH   ls_message-message.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_header_user_command

  METHOD handle_item_user_command.

    DATA:
      lt_rows           TYPE lvc_t_row,
      lv_doc_type       TYPE tms_doc_type,
      lv_doc_item       TYPE tms_doc_item,
      lv_doc_nr         TYPE tms_doc_nr,
      ls_message       TYPE bapiret2,
      lt_messages       TYPE bapirettab.

    FIELD-SYMBOLS:
      <fs_row>          TYPE lvc_s_row,
      <fs_sts>          TYPE tms_s_doc_status_scr.

    CASE e_ucomm.

      WHEN 'DSP_DOCFLOW'.
        gr_tm_table_item->get_selected_rows(
          IMPORTING
            et_index_rows = lt_rows ).

        IF lt_rows IS INITIAL.
          IF gt_tm_item_sts IS INITIAL.
            MESSAGE s350(int_tm_erp) WITH vbak-vbeln.
          ELSE.
            MESSAGE s353(int_tm_erp).
          ENDIF.
        ELSE.
          READ TABLE lt_rows
            ASSIGNING <fs_row>
            INDEX 1.
          IF sy-subrc IS INITIAL.
            READ TABLE gt_tm_item_sts
              ASSIGNING <fs_sts>
              INDEX <fs_row>-index.
          ELSE.
            READ TABLE gt_tm_item_sts
              ASSIGNING <fs_sts>
              INDEX 1.
          ENDIF.

          lv_doc_item = <fs_sts>-posnr_dlv.
          lv_doc_nr   = <fs_sts>-vbeln_dlv.
          lv_doc_type = <fs_sts>-doc_type.

          gr_tm_docflow->display_docflow(
             EXPORTING
              iv_doc_type = lv_doc_type
              iv_doc_nr   = lv_doc_nr
              iv_doc_item = lv_doc_item
             IMPORTING
              et_messages = lt_messages ).
          READ TABLE lt_messages INTO ls_message INDEX 1.
          IF sy-subrc IS INITIAL.
            MESSAGE
              ID     ls_message-id
              TYPE   ls_message-type
              NUMBER ls_message-number
              WITH   ls_message-message.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "handle_header_user_command


ENDCLASS.                    "cl_tm_event_handler IMPLEMENTATION