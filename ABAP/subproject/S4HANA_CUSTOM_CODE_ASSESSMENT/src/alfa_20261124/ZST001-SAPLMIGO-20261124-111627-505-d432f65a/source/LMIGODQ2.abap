*----------------------------------------------------------------------*
*   INCLUDE LMIGODQ2                                                   *
*   Detail tabstrip quantity implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_quantity IMPLEMENTATION.

************************************************************************
* Constructor
************************************************************************
method constructor.
  data: lt_okcodes type lif_migo_frame~ty_t_okcodes,
        lt_sending type lif_migo_frame~ty_t_message_ids.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_DETAIL_QUANTITY'.
  append 'MIGO_OK_DET_ITEM' to lt_okcodes.
  append 'DETERMINE_SINGLE'    to lt_sending.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes
      it_sending    = lt_sending.
endmethod.

************************************************************************
* Handler for the button
************************************************************************
method lif_migo_frame~okcode_handler.
  case i_okcode.
    when 'MIGO_OK_DET_ITEM'.
      def_sms 'DETERMINE_SINGLE' oref_detail->current_line space.
  endcase.
endmethod.

method lif_migo_frame~message_handler.
endmethod.

ENHANCEMENT-POINT LMIGODQ2_01 SPOTS ES_SAPLMIGO STATIC.







ENDCLASS.