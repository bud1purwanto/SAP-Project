*----------------------------------------------------------------------*
*   INCLUDE LMIGODS4                                                   *
*   Detail tabstrip serial numbers implementation                      *
*   pbo-, pai- methods                                                 *
*----------------------------------------------------------------------*

***********************************************************************
* PBO outside loop                                                    *
***********************************************************************
  METHOD pbo.
    CALL METHOD super->pbo.
    CALL METHOD tableview_serial_mod_button.
    CALL METHOD tableview_serial_size.
  ENDMETHOD.

***********************************************************************
* PBO module within LOOP: Get data from detail and transfer them to   *
* the screen.                                                         *
***********************************************************************
  METHOD pbo_loop.
    IF tv_goserial-current_line > p_lines.
      EXIT FROM STEP-LOOP.
    ENDIF.
    CALL METHOD tableview_serial_line_get.
    CALL METHOD tableview_serial_modify.
    p_loopc = sy-loopc.
  ENDMETHOD.

***********************************************************************
* PBO module: display serialnumbers (dynpro 362)                "637093
***********************************************************************
  METHOD pbo_show_inv.                                          "637093
    CALL METHOD serial_show_inv.                                "637093
  ENDMETHOD.                                                    "637093

***********************************************************************
* PAI module within LOOP: Transfer data back to the kernel            *
***********************************************************************
  METHOD pai_loop.
    CALL METHOD tableview_serial_line_set.
  ENDMETHOD.

***********************************************************************
* PAI after loop                                                      *
***********************************************************************
  METHOD pai_after_loop.
    CALL METHOD tableview_serial_table_prepare.
    CALL METHOD tableview_serial_cursor.
  ENDMETHOD.