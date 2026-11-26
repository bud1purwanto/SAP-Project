*----------------------------------------------------------------------*
*   INCLUDE LMIGOSM2                                                   *
*   Screenmanager
*----------------------------------------------------------------------*

CLASS lcl_migo_screenmanager IMPLEMENTATION.

METHOD constructor.
  DATA: lt_message_ids TYPE lif_migo_frame=>ty_t_message_ids.
  APPEND 'MIGO_HEADER_TOGGLER_STATUS' TO lt_message_ids.
  APPEND 'MIGO_TV_TOGGLER_STATUS'     TO lt_message_ids.
  APPEND 'MIGO_DETAIL_TOGGLER_STATUS' TO lt_message_ids.
  APPEND 'MIGO_DETAIL_CARRIER_CHANGE' TO lt_message_ids.
  lif_migo_frame~class_id = 'MIGO_SCREENMANAGER'.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer  = me
      it_receiving   = lt_message_ids.
ENDMETHOD.

METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.

METHOD lif_migo_frame~message_handler.
* Set the correct bit in the status data
* Mapping: <status> = 'ABC' with A = Header, B = Table, C = Item
  CASE i_message_id.
    WHEN 'MIGO_HEADER_TOGGLER_STATUS'. p_status+0(1) = is_message-data2.
    WHEN 'MIGO_DETAIL_TOGGLER_STATUS'. p_status+2(1) = is_message-data2.
    WHEN 'MIGO_DETAIL_CARRIER_CHANGE'. "new carrier screen with 'old'
                                       "p_status
  ENDCASE.
  p_status+1(1) = x.                               "Table always visible
* Choose the appropriate subscreen
  IF lcl_migo_globals=>kernel->s_action-migo_mode = 'GT'.
*   Transfer posting
    g_detail_subscreen   = '0305'.
    CASE p_status.
      WHEN 'XX '. g_screenmanager_dynnr = '0006'.
      WHEN 'XXX'. g_screenmanager_dynnr = '0007'.
      WHEN ' X '. g_screenmanager_dynnr = '0008'.
      WHEN ' XX'. g_screenmanager_dynnr = '0009'.
    ENDCASE.
  ELSE.
*   Normal posting (mode: GI/GR/GS/GO)
    g_detail_subscreen   = '0300'.
    CASE p_status.
      WHEN 'XX '. g_screenmanager_dynnr = '0002'.
      WHEN 'XXX'. g_screenmanager_dynnr = '0003'.
      WHEN ' X '. g_screenmanager_dynnr = '0004'.
      WHEN ' XX'. g_screenmanager_dynnr = '0005'.
    ENDCASE.
  endif.

ENDMETHOD.




ENDCLASS.