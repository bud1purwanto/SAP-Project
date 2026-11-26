*----------------------------------------------------------------------*
*   INCLUDE LMIGOKT2                                                   *
*   Transport
*----------------------------------------------------------------------*

METHOD transport_read.
  DATA: r_transport TYPE RANGE OF tknum,
        s_transport LIKE LINE OF r_transport,
        r_vlief     TYPE RANGE OF vbeln_vl,
        s_vlief     LIKE LINE OF r_vlief.

  s_transport-sign = 'I'.
  s_transport-option = 'EQ'.
  s_transport-low = i_transport.
  APPEND s_transport TO r_transport.

  CALL FUNCTION 'SD_SHINOTIF_FOR_SHIPMENT'
    TABLES
      shipment_i          = r_transport
      shinotif_o          = r_vlief
    EXCEPTIONS
      shipment_i_empty    = 1
      no_entries_found    = 2
      not_found           = 3
      no_inbound_shipment = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
  LOOP AT r_vlief INTO s_vlief.
    CALL METHOD confirmation_get
      EXPORTING i_vbeln = s_vlief-low.
  ENDLOOP.
ENDMETHOD.