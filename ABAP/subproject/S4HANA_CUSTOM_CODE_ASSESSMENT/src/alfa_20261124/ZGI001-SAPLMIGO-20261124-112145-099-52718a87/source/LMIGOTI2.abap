*----------------------------------------------------------------------*
*   INCLUDE LMIGOTI2                                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_titlebar IMPLEMENTATION.
************************************************************************
* Constructor
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame=>ty_t_message_ids.
  APPEND 'KERNEL_MODE_CHANGED' TO lt_receiving.
  APPEND 'NEW_DOCUMENT'        TO lt_receiving.
  APPEND 'KERNEL_RESET'        TO lt_receiving.
  lif_migo_frame~class_id = 'MIGO_TITLEBAR'.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer  = me
      it_receiving   = lt_receiving.
* Read complete user name
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
              EXPORTING i_usnam = sy-uname
              IMPORTING e_exnam = p_username.
ENDMETHOD.

METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.
************************************************************************
* Set the title according to the incoming messages
************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: ls_data    TYPE dd07v,
        l_value    TYPE domvalue_l.
  FIELD-SYMBOLS: <ls_key> TYPE lcl_migo_kernel=>ty_s_refdockey.
  CASE i_message_id.
    WHEN 'KERNEL_MODE_CHANGED'.
*     New ACTION
      l_value = lcl_migo_globals=>kernel->s_control-action.
      CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
        EXPORTING
          name          = 'GOACTION'
          value         = l_value
          texts_only    = x
        IMPORTING
          dd07v_wa      = ls_data
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
      p_action_text = ls_data-ddtext.
*     New REFDOC
      l_value = lcl_migo_globals=>kernel->s_control-refdoc.
      CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
        EXPORTING
          name          = 'REFDOC'
          value         = l_value
          texts_only    = x
        IMPORTING
          dd07v_wa      = ls_data
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
      p_refdoc_text = ls_data-ddtext.
    WHEN 'NEW_DOCUMENT'.
      CHECK is_message-data2 <> 'POSTED'.     "Posted document not shown
      ASSIGN is_message-dref->* TO <ls_key>.
      CASE is_message-data1.
        WHEN 'R01'. WRITE <ls_key>-po_number         TO p_document.
        WHEN 'R02'. WRITE <ls_key>-mat_doc           TO p_document.
        WHEN 'R03'. WRITE <ls_key>-delivery_note     TO p_document.
        WHEN 'R04'. WRITE <ls_key>-inbound_delivery  TO p_document.
        WHEN 'R05'. WRITE <ls_key>-outbound_delivery TO p_document.
        WHEN 'R06'. WRITE <ls_key>-transport         TO p_document.
        WHEN 'R07'. WRITE <ls_key>-transportident    TO p_document.
        WHEN 'R08'. WRITE <ls_key>-order_number      TO p_document.
      ENDCASE.
    WHEN 'KERNEL_RESET'.
      CLEAR p_document.
  ENDCASE.
  CONCATENATE p_action_text p_refdoc_text p_document '-'
              p_username
              INTO p_title SEPARATED BY space.
  CONDENSE p_title.
* Send title only if allowed (problem when called).
  SET TITLEBAR 'MIGO_TITLEBAR' WITH p_title.
ENDMETHOD.
ENDCLASS.