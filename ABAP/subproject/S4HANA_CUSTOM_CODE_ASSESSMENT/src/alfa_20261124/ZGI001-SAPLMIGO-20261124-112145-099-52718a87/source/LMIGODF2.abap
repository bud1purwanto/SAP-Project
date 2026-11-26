*----------------------------------------------------------------------*
*   INCLUDE LMIGODF2                                                   *
*   Detail tabstrip freight implementation                             *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_freight IMPLEMENTATION.
***********************************************************************
* Constructor                                                         *
***********************************************************************
  METHOD constructor.
    DATA: lt_okcodes   TYPE lif_migo_frame=>ty_t_okcodes,
          lt_receiving TYPE lif_migo_frame=>ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_DETAIL_FREIGHT'.
    APPEND 'MIGO_SCROLL'          TO lt_receiving.
    APPEND 'KERNEL_RESET'         TO lt_receiving.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_receiving  = lt_receiving.
  ENDMETHOD.

***********************************************************************
* Message_handling                                                    *
***********************************************************************
  METHOD lif_migo_frame~message_handler.
    CASE i_message_id.
      WHEN 'MIGO_SCROLL'.
        CHECK is_message-data1 = 'FREIGHT'.
        CASE is_message-data2.
          WHEN 'P--'.
            tv_gofreight-top_line = 1.
          WHEN 'P- '.
            tv_gofreight-top_line =
            tv_gofreight-top_line - p_displayed_lines.
          WHEN 'P++'.
            tv_gofreight-top_line = tv_gofreight-lines.
          WHEN 'P+ '.
            tv_gofreight-top_line =
            tv_gofreight-top_line + p_displayed_lines.
            IF tv_gofreight-top_line > tv_gofreight-lines.
              tv_gofreight-top_line = tv_gofreight-lines.
            ENDIF.
        ENDCASE.
        CALL METHOD lcl_migo_cursor=>cursor_set
             EXPORTING i_oref_screenobject = me
                       i_field             = 'GOFREIGHT-VENDORNAME'
                       i_stepl             = 1.
      WHEN 'KERNEL_RESET'.
        tv_gofreight-top_line = 1.
    ENDCASE.
  ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.

***********************************************************************
*          pbo outside loop                                           *
***********************************************************************
  METHOD pbo.
    CALL METHOD super->pbo.
    CALL METHOD column_hide.
    DESCRIBE TABLE oref_detail->t_gofreight LINES p_lines.
    tv_gofreight-lines = p_lines.
  ENDMETHOD.

************************************************************************
* PBO module within LOOP: Get data from detail and transfer them to
* the screen.
************************************************************************
  METHOD pbo_loop.
*    If CANCEL or DISPLAY, no fields ready for input
    LOOP AT SCREEN.
      CHECK screen-name = 'GOFREIGHT-VENDORNAME'.
      IF lcl_migo_globals=>kernel->s_action-cancel  = abap_true
      OR lcl_migo_globals=>kernel->s_action-display = abap_true.
        screen-input = c_mod_off.
      ELSE.
        screen-input = c_mod_on.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
*    Display freight vendors on screen
    READ TABLE oref_detail->t_gofreight INTO gofreight
                       INDEX tv_gofreight-current_line.
    IF sy-subrc = 0.
      p_displayed_lines = sy-loopc.
    ELSE.
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDMETHOD.

***********************************************************************
*          pai outside loop                                           *
***********************************************************************
  METHOD pai.
    CALL METHOD super->pai.
    CALL METHOD cursor_set.
  ENDMETHOD.

************************************************************************
* PAI module within LOOP: Transfer data back to the kernel
************************************************************************
    METHOD pai_loop.
      DATA: ls_gofreight TYPE gofreight.

      READ TABLE oref_detail->t_gofreight INTO ls_gofreight
                            INDEX tv_gofreight-current_line.
      CHECK sy-subrc = 0.
      IF gofreight-vendorname <> ls_gofreight-vendorname.
        ls_gofreight-vendorname = gofreight-vendorname.
        ls_gofreight-lifnr      = gofreight-lifnr.
        MODIFY oref_detail->t_gofreight FROM ls_gofreight
                          INDEX tv_gofreight-current_line.
      ENDIF.
    ENDMETHOD.

***********************************************************************
* Hide columns: ebeln, ebelp and freight_line(global_counter for
*               tv_gofreight)
***********************************************************************
    METHOD column_hide.
      DATA: ls_column TYPE lcl_migo_screenmodification=>ty_s_column.
* gofreight-ebeln invisible
      READ TABLE tv_gofreight-cols INTO ls_column
           WITH KEY screen-name = 'GOFREIGHT-EBELN'.
      ls_column-invisible = 1.
      MODIFY tv_gofreight-cols FROM ls_column INDEX ls_column-index.
* gofreight-ebelp invisible
      READ TABLE tv_gofreight-cols INTO ls_column
        WITH KEY screen-name = 'GOFREIGHT-EBELP'.
      ls_column-invisible = 1.
      MODIFY tv_gofreight-cols FROM ls_column INDEX ls_column-index.
* gofreight-freight_line invisible
      READ TABLE tv_gofreight-cols INTO ls_column
        WITH KEY screen-name = 'GOFREIGHT-FREIGHT_LINE'.
      ls_column-invisible = 1.
      MODIFY tv_gofreight-cols FROM ls_column INDEX ls_column-index.
    ENDMETHOD.

************************************************************************
* Resolution of freight number line
************************************************************************
    METHOD cursor_position_resolve.
      e_name            = 'FREIGHT'.
      e_tabix           = oref_detail->current_line.
      e_secondary_tabix = tv_gofreight-top_line +
                          lcl_migo_cursor=>stepl - 1.
    ENDMETHOD.

***********************************************************************
* Find right cursor position.                                         *
***********************************************************************
    METHOD cursor_set.
      DATA: l_lines LIKE sy-tabix.
      DATA: l_stepl LIKE sy-loopc.
      DATA: l_cursorline LIKE sy-stepl.

      CHECK lcl_migo_cursor=>oref_screenobject = me.

      DESCRIBE TABLE oref_detail->t_gofreight LINES l_lines.
*   positioning in empty table control
      IF lcl_migo_cursor=>stepl > l_lines.
        tv_gofreight-top_line = 1.
        EXIT.
      ENDIF.

      CHECK l_lines > 0.
      CHECK okcode = 'OK_GO'.

      l_cursorline = tv_gofreight-top_line
                     + lcl_migo_cursor=>stepl - 1.
*   positioning after ENTER
      IF p_displayed_lines = lcl_migo_cursor=>stepl.
        tv_gofreight-top_line =
        tv_gofreight-top_line + p_displayed_lines - 1.
        CALL METHOD lcl_migo_cursor=>cursor_set
             EXPORTING i_oref_screenobject = me
                       i_field             = 'GOFREIGHT-VENDORNAME'
                       i_stepl             = 2.
      ELSEIF NOT lcl_migo_cursor=>value IS INITIAL
                 AND p_lines <> l_cursorline.
*     do not change cursor position when position
*     on space or last position
        l_lines = lcl_migo_cursor=>stepl + 1.
        CALL METHOD lcl_migo_cursor=>cursor_set
             EXPORTING i_oref_screenobject = me
                       i_field             = 'GOFREIGHT-VENDORNAME'
                       i_stepl             = l_lines.
      ENDIF.
    ENDMETHOD.

  ENDCLASS.