*----------------------------------------------------------------------*
*   INCLUDE LMIGOKD4                                                   *
*   Centralized document loader
*----------------------------------------------------------------------*

METHOD ref_document_read.
  DATA: l_lines         TYPE i,
        l_document      TYPE char50,
        l_firstline_log TYPE migo_loglevel,
        es_highest_msg  TYPE bal_s_msg,
        ls_message      TYPE lif_migo_frame~ty_s_message,
        l_mjahr         TYPE mjahr,
        ls_key          TYPE ty_s_refdockey.

* Save current number of lines (to compare later on) and
* refresh the document log and set the context (initial).
  l_lines = s_status-lines.
  CALL METHOD oref_doc_log->refresh.
  CALL METHOD oref_doc_log->context_set.
* According to the REFDOC, start the proper reading routine
  CASE i_refdoc.
    WHEN 'R01'.
      l_document = is_key-po_number.
      CALL METHOD purchase_order_read
        EXPORTING
          i_po_number = is_key-po_number
          i_po_item   = is_key-po_item
          i_po_werks  = is_key-po_werks.
    WHEN 'R02'.
      l_document = is_key-mat_doc.
      l_mjahr    = is_key-doc_year.
      CALL METHOD materialdocument_read
        EXPORTING
          i_mat_doc  = is_key-mat_doc
        CHANGING
          c_doc_year = l_mjahr.
    WHEN 'R03'.
      l_document = is_key-delivery_note.
      CALL METHOD delivery_note_read
        EXPORTING
          i_delivery_note = is_key-delivery_note.
    WHEN 'R04'.
      l_document = is_key-inbound_delivery.
      CALL METHOD inbound_delivery_read
        EXPORTING
          i_inbound_delivery = is_key-inbound_delivery
          i_shipping_unit    = is_key-shipping_unit.
    WHEN 'R05'.
      l_document = is_key-outbound_delivery.
      CALL METHOD outbound_delivery_read
        EXPORTING
          i_outbound_delivery = is_key-outbound_delivery
          i_shipping_unit     = is_key-shipping_unit.
    WHEN 'R06'.
      l_document = is_key-transport.
      CALL METHOD transport_read
        EXPORTING
          i_transport = is_key-transport.
    WHEN 'R07'.
      l_document = is_key-transportident.
      CALL METHOD transportident_read
        EXPORTING
          i_transportident  = is_key-transportident
          i_transport_means = is_key-transport_means.
    WHEN 'R08'.
      l_document = is_key-order_number.
* GI for order is treated as a GI for reservation
      IF s_action-migo_mode = 'GI'.
        CALL METHOD order_reservation_read
           EXPORTING
             i_order_number    = is_key-order_number
             i_order_operation = is_key-order_operation.
      ELSE.
        CALL METHOD order_read
           EXPORTING
             i_order_number   = is_key-order_number
             i_order_item     = is_key-order_item.
      ENDIF.
    WHEN 'R09'.
      l_document = is_key-reservation_number.
      CALL METHOD reservation_read
         EXPORTING
           i_res_number = is_key-reservation_number
           i_res_item   = is_key-reservation_item
           i_res_type   = is_key-reservation_type.
    ENDCASE.
* Evaluate the result.
* The document has been at least partially inserted if the number of
* lines before and after differ or, if with reference to a material
* document (delivery note --> material document), there are
* any lines in (mat doc reading executes a reset).
  IF s_status-lines <> l_lines OR
     ( ( s_control-refdoc = 'R02' OR s_control-refdoc = 'R03' )  AND
         s_status-lines > 0 ).
    e_nothing_found = abap_false.
    ls_key = is_key.
    ls_key-doc_year = l_mjahr.
    CALL METHOD new_document
      EXPORTING
        i_refdoc = i_refdoc
        is_key   = ls_key.
  ELSE.
*   Nothing found. Default message 064 (no positions) if no other
*   message in the log.
    e_nothing_found = abap_true.
    IF oref_doc_log->message_exist_all( ) = abap_false.
      CALL METHOD oref_doc_log->message_add
        EXPORTING
          i_msgty = w
          i_msgid = 'M7'
          i_msgno = '064'
          i_msgv1 = l_document.
    ENDIF.
  ENDIF.
* Set the status icon in the first line
  IF oref_doc_log->message_exist_all( ) = abap_true.
    CALL METHOD oref_doc_log->message_exist_single
      IMPORTING e_loglevel       = l_firstline_log
                es_msg           = es_highest_msg.
*   Write the highest message into the status line
    IF es_highest_msg-msgty <> space.
      MESSAGE ID     es_highest_msg-msgid
              TYPE   s
              NUMBER es_highest_msg-msgno
              WITH   es_highest_msg-msgv1
                     es_highest_msg-msgv2
                     es_highest_msg-msgv3
                     es_highest_msg-msgv4.
    ENDIF.
  ENDIF.
* Send message to the first line with the loglevel and the message
  GET REFERENCE OF l_firstline_log INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'KERNEL_DOC_LOGLEVEL'
      is_message    = ls_message.
ENDMETHOD.


************************************************************************
* Send a message that a new document has been inserted
************************************************************************
METHOD new_document.
  DATA: ls_message  TYPE lif_migo_frame~ty_s_message,
        ls_key      TYPE ty_s_refdockey,
        l_id        TYPE es_object_id,
        l_typ       TYPE oj_name,
        BEGIN OF ls_matdoc,
          mblnr TYPE mblnr,
          mjahr TYPE mjahr,
        END OF ls_matdoc.

* Send around a message with the goods news
  ls_message-data1 = i_refdoc.
  IF i_from_posting = abap_true.
    ls_message-data2 = 'POSTED'.
  ENDIF.
  GET REFERENCE OF is_key INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'NEW_DOCUMENT'
      is_message    = ls_message.
* Append this document to the user objects.
  CASE i_refdoc.
    WHEN 'R01'.
      l_id = is_key-po_number.
      l_typ = 'BUS2012'.
    WHEN 'R08'.
      l_id = is_key-order_number.
      l_typ = 'BUS2048'.
    WHEN 'R09'.
      l_id = is_key-reservation_number.
      l_typ = 'BUS2093'.
    WHEN 'R02'.
      ls_matdoc-mblnr = is_key-mat_doc.
      ls_matdoc-mjahr = is_key-doc_year.
      l_id = ls_matdoc.
      l_typ = 'BUS2017'.
  ENDCASE.
  IF NOT l_typ IS INITIAL.
    CALL FUNCTION 'ES_APPEND_USER_OBJECTS'
      EXPORTING
        iobject_typ  = l_typ
        iobject_id   = l_id
        isave        = x
        i_no_refresh = space.  "Read fresh from database upon next
  ENDIF.                       "ES_READ_USER_OBJECTS
ENDMETHOD.