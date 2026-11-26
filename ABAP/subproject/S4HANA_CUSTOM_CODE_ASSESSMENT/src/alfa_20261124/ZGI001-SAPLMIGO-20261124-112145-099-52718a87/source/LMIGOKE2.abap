*----------------------------------------------------------------------*
*   INCLUDE LMIGOKE2                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_kernel IMPLEMENTATION.

************************************************************************
* Constructor
* The kernel is not allowed to register for any OK-codes or
* receiving messages.
************************************************************************
  METHOD constructor.
    DATA: lt_sending TYPE lif_migo_frame~ty_t_message_ids.
    lif_migo_frame~class_id = 'MIGO_KERNEL'.
    APPEND 'KERNEL_RESET'           TO lt_sending.
    APPEND 'KERNEL_MODE_CHANGED'    TO lt_sending.
    APPEND 'KERNEL_STATUS_CHANGED'  TO lt_sending.
    APPEND 'NEW_DOCUMENT'           TO lt_sending.
    APPEND 'MODEL_CHANGE_BEGIN'     TO lt_sending.
    APPEND 'MODEL_CHANGE_COMPLETE'  TO lt_sending.
    APPEND 'KERNEL_DOC_LOGLEVEL'    TO lt_sending.
    APPEND 'HEADER_OPEN'            TO lt_sending.
    APPEND 'ALLOWED_DOCS_CHANGED'   TO lt_sending.
    APPEND 'MIGO_TIP_REQUEST'       TO lt_sending.
    APPEND 'MIGO_DETAIL_CARRIER_CHANGE' TO lt_sending.

    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_sending    = lt_sending.
ENHANCEMENT-POINT LMIGOKE2_02 SPOTS ES_SAPLMIGO.
  ENDMETHOD.                    "constructor

************************************************************************
* Includes with methods
************************************************************************
  INCLUDE lmigoka1.                       "Authority checks
  INCLUDE lmigoka2.                       "Availability check
  INCLUDE LMIGOKA3.                       "Availability check
  INCLUDE lmigokb1.                       "Batch maintain
  INCLUDE lmigokb2.                       "Documentary batch
  INCLUDE lmigokc1.                       "Confirmations
  INCLUDE lmigokc2.                       "Change all items
  INCLUDE lmigokcd.                       "Cross Docking
  INCLUDE lmigokd1.                       "Document operations
  INCLUDE lmigokd2.                       "Delivery note
  INCLUDE lmigokd3.                       "Defaults operation
  INCLUDE lmigokd4.                       "Document loading
  INCLUDE lmigokf1.                       "Foreign trade
  INCLUDE lmigokfe.                       "tied empties handling
  INCLUDE lmigokg1.                       "Goods movement preparation
  INCLUDE lmigokg2.                       "Goods movement error handling
  INCLUDE lmigokga.                       "Process generic articles
  INCLUDE lmigokge.                       "Goods mvmt prepar.tied empties<LG>
  INCLUDE lmigokh1.                       "Header operations
  INCLUDE lmigoki1.                       "Inbound delivery
  INCLUDE lmigokj2.                       "Official number
  INCLUDE lmigokl1.                       "Line operations
  INCLUDE lmigokl2.                       "Line operations subitems
  INCLUDE lmigokl3.                       "Line operations for BAdI
  INCLUDE lmigokl4.                       "Line checks
  INCLUDE lmigokl5.                       "Line checks transfer fields
  INCLUDE lmigokm1.                       "Material document
  INCLUDE lmigokm2.                       "Material master
  INCLUDE lmigokm3.                       "Movement type determination
  INCLUDE lmigokn1.                       "Names
  INCLUDE lmigokn2.                       "New positions from WUEB
  INCLUDE lmigoko1.                       "Outbound delivery
  INCLUDE lmigoko2.                       "Output determination
  INCLUDE lmigoko4.                       "Order read data
  INCLUDE lmigoko5.                       "Order: read dependent reservation
  INCLUDE lmigokp1.                       "Purchase order read data
  INCLUDE lmigokp2.                       "Purchase order fill data
  INCLUDE lmigokp3.                       "Predocument save/load
  INCLUDE lmigokp4.                       "pipeline methods
  INCLUDE lmigokp5.                       "Purchase order fill data for
                                          "stock transfer
  INCLUDE lmigokp6.                       "Purchase order fill goitem,
                                          "material document, freight
  INCLUDE lmigokp7.                       "Purchase order tied empties
  INCLUDE lmigokr1.                       "Reset
  INCLUDE lmigokr2.                       "Reservation
ENHANCEMENT-POINT LMIGOKE2_01 SPOTS ES_SAPLMIGO STATIC.
  INCLUDE lmigoks1.                       "Status changes
  INCLUDE lmigoks2.                       "Shipping elements
  INCLUDE lmigoks3.                       "Serial numbers
  INCLUDE lmigoks4.                       "Screen modification
  INCLUDE lmigoks5.                       "Special Stock (Transfer)
  INCLUDE lmigoks6.                       "Screen modification(Transfer)
  INCLUDE lmigokst.                       "Process structured articles
  INCLUDE lmigokt1.                       "Table operations
  INCLUDE lmigokt2.                       "Transport
  INCLUDE lmigokt3.                       "Transportidentification
  INCLUDE lmigokt4.                       "Transfer data
  INCLUDE lmigoku1.                       "Unit conversion
  INCLUDE lmigoku2.                       "for prod. unit
  INCLUDE lmigoku3.                       "for um-fields
  INCLUDE lmigokv1.                       "Valuation type
  INCLUDE lmigokvs.                       "Value added Services
  INCLUDE lmigokw1.                       "WM - Warehouse management
************************************************************************
* Handlers for the framework
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler

ENDCLASS.                    "lcl_migo_kernel IMPLEMENTATION