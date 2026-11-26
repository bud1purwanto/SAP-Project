*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR3                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Register for the messages that trigger the search.
************************************************************************
METHOD constructor.
  DATA: lt_receiving TYPE lif_migo_frame~ty_t_message_ids,
        lt_sending   TYPE lif_migo_frame~ty_t_message_ids.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_SEARCH'.
  APPEND 'MIGO_START_SEARCH_PO'  TO lt_receiving.
  APPEND 'MIGO_START_SEARCH_MD'  TO lt_receiving.
  APPEND 'MIGO_START_SEARCH_ORD' TO lt_receiving.
  APPEND 'MIGO_START_SEARCH_RES' TO lt_receiving.
  APPEND 'SEARCH_HAS_NEW_MATDOC' TO lt_sending.
  APPEND 'NEW_SEARCHRESULT'      TO lt_sending.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_receiving  = lt_receiving
      it_sending    = lt_sending.
ENDMETHOD.

************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.

************************************************************************
* Message handler
************************************************************************
METHOD lif_migo_frame~message_handler.
  CASE i_message_id.
    WHEN 'MIGO_START_SEARCH_MD'.
      CALL METHOD materialdocument_search.
    WHEN 'MIGO_START_SEARCH_PO'.
      CALL METHOD purchase_order_search_popup.
    WHEN 'MIGO_START_SEARCH_ORD'.
*     Search for production orders can be two absolutely
*     different things:
*     - Search for MB31-mode (goods receipt)
*     - Search for MB11-mode (goods issue --> reservation)
      CASE lcl_migo_globals=>kernel->s_control-action.
        WHEN 'A01'.
          CALL METHOD order_search_popup.
        WHEN 'A07'.
          CALL METHOD reservation_search_popup.
      ENDCASE.
    WHEN 'MIGO_START_SEARCH_RES'.
      CALL METHOD reservation_search_popup.

  ENDCASE.
ENDMETHOD.

************************************************************************
* PBO of search popup for purchase orders
************************************************************************
METHOD pbo.
  CALL METHOD super->pbo.
  SET PF-STATUS 'SEARCH_POPUP'.
  CASE lcl_migo_globals=>kernel->s_control-refdoc.
    WHEN 'R09'.
      IF NOT gosearch_res-no_acc IS INITIAL.
        LOOP AT SCREEN.
          CHECK screen-group2 = 1.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDMETHOD.

************************************************************************
* PAI of search popup for purchase orders
************************************************************************
METHOD pai.
  CALL METHOD super->pai.
  IF sy-ucomm = 'OK_START'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDMETHOD.

************************************************************************
* PAI at exit-command
************************************************************************
METHOD pai_exit.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMETHOD.