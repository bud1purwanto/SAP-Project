*----------------------------------------------------------------------*
*   INCLUDE LMIGODB2                                                   *
*   Detail tabstrip batch implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_batch IMPLEMENTATION.

  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

* screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    APPEND 'MIGO_OK_BATCH_CLASS' TO lt_okcodes.
    lif_migo_frame~class_id = 'MIGO_DETAIL_BATCH'.
ENHANCEMENT-POINT LCL_MIGO_DETAIL_BATCH_01 SPOTS ES_SAPLMIGO.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes.
  ENDMETHOD.                    "constructor


  METHOD lif_migo_frame~okcode_handler.
ENHANCEMENT-SECTION     LMIGODB2_01 SPOTS ES_SAPLMIGO.
    CASE i_okcode.
      WHEN 'MIGO_OK_BATCH_CLASS'.
        CALL METHOD lcl_migo_globals=>kernel->batch_maintain
          EXPORTING
            i_line = oref_detail->current_line.
      WHEN OTHERS.
    ENDCASE.
END-ENHANCEMENT-SECTION.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler

ENDCLASS.                    "lcl_migo_detail_batch IMPLEMENTATION