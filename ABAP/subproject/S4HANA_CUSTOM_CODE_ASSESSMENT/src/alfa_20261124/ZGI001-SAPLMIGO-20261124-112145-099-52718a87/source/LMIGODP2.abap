*----------------------------------------------------------------------*
*   INCLUDE LMIGODP2                                                   *
*   Detail tabstrip purchase order implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_po IMPLEMENTATION.

  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    APPEND 'MIGO_OK_SHIP_CONS' TO lt_okcodes.
    lif_migo_frame~class_id = 'MIGO_DETAIL_PO'.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes.
  ENDMETHOD.
  METHOD pbo.
    CALL METHOD super->pbo.

* Set subscreen for QM certificate depending on goitem-xqm_cert
    IF goitem-xqm_cert = abap_true.
      g_qm_prog     = 'SAPLQBCK'.
      g_sub_qm_cert = '1000'.
    ELSE.
*   Not relevant: Dummy-Subscreen SAPLMIGO 2099
      g_qm_prog     = c_repid.
      g_sub_qm_cert = '2099'.
    ENDIF.

* Send current line to QM (data has been filled in line_check)
    CALL FUNCTION 'QBCK_MIGO_LINE_SET'
         EXPORTING
              i_global_counter = goitem-global_counter.
  ENDMETHOD.

  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'MIGO_OK_SHIP_CONS'.
        CALL METHOD
             lcl_migo_globals=>kernel->shipping_construction_maintain
             EXPORTING i_line = oref_detail->current_line.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.

ENDCLASS.