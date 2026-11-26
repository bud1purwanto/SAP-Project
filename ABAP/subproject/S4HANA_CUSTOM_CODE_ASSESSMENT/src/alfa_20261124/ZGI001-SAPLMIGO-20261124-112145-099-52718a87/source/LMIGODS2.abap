*----------------------------------------------------------------------*
*   INCLUDE LMIGODS2                                                   *
*   Detail tabstrip serial numbers implementation                      *
*   constuctor, message-handling, okcode-handling                      *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_serial_numbers IMPLEMENTATION.

  INCLUDE lmigods3.                         "tableview_serial methods
  INCLUDE lmigods4.                         "pbo-, pai- methods

***********************************************************************
* Constructor                                                         *
***********************************************************************
  METHOD constructor.
    DATA: lt_okcodes   TYPE lif_migo_frame=>ty_t_okcodes,
          lt_receiving TYPE lif_migo_frame=>ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_DETAIL_SERIAL_NUMBERS'.
    APPEND 'MIGO_OK_SER_SELALL'     TO lt_okcodes.
    APPEND 'MIGO_OK_SER_DESELALL'   TO lt_okcodes.
    APPEND 'MIGO_OK_SER_DELETE'     TO lt_okcodes.
    APPEND 'MIGO_OK_SER_SEARCH'     TO lt_okcodes.          "400986
    APPEND 'MIGO_OK_SER_REF'        TO lt_okcodes.          "688602
    APPEND 'MIGO_SCROLL'            TO lt_receiving.
    APPEND 'KERNEL_RESET'           TO lt_receiving.
    APPEND 'ITEMDETAIL_CURRENTLINE' TO lt_receiving.             "383260
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_receiving  = lt_receiving.
  ENDMETHOD.

***********************************************************************
* Okcode-handling                                                     *
***********************************************************************
  METHOD lif_migo_frame~okcode_handler.
    DATA: lt_goserial TYPE lcl_migo_kernel=>ty_t_goserial.  "400986
    CASE i_okcode.
      WHEN 'MIGO_OK_SER_SELALL'.
       CALL METHOD lcl_migo_globals=>kernel->serialnumbers_select_all
              EXPORTING i_line = oref_detail->current_line.
      WHEN 'MIGO_OK_SER_DESELALL'.
       CALL METHOD lcl_migo_globals=>kernel->serialnumbers_deselect_all
              EXPORTING i_line = oref_detail->current_line.
      WHEN 'MIGO_OK_SER_DELETE'.
       CALL METHOD lcl_migo_globals=>kernel->serialnumbers_delete_sel
              EXPORTING i_line = oref_detail->current_line.
      WHEN 'MIGO_OK_SER_SEARCH'.                            "400986
        CALL METHOD serial_search.                          "400986
      WHEN 'MIGO_OK_SER_REF'.                               "688602
        CALL METHOD serial_ref.                             "688602
    ENDCASE.
  ENDMETHOD.

***********************************************************************
* Message_handling                                                    *
***********************************************************************
  METHOD lif_migo_frame~message_handler.
    CASE i_message_id.
      WHEN 'MIGO_SCROLL'.
        CHECK is_message-data1 = 'SERIALNUMBERS'.
        CASE is_message-data2.
          WHEN 'P--'.
            tv_goserial-top_line = 1.
          WHEN 'P- '.
            tv_goserial-top_line = tv_goserial-top_line - p_loopc.
          WHEN 'P++'.
            tv_goserial-top_line = tv_goserial-lines.
          WHEN 'P+ '.
            tv_goserial-top_line = tv_goserial-top_line + p_loopc.
            IF tv_goserial-top_line > tv_goserial-lines.
              tv_goserial-top_line = tv_goserial-lines.
            ENDIF.
        ENDCASE.
        CALL METHOD lcl_migo_cursor=>cursor_set
             EXPORTING i_oref_screenobject = me
                       i_field             = 'GOSERIAL-SERIALNO'
                       i_stepl             = 1.
      WHEN 'KERNEL_RESET'           OR                           "383260
           'ITEMDETAIL_CURRENTLINE'.                             "383260
*       Scroll table-control back to top position.
        tv_goserial-top_line = 1.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.