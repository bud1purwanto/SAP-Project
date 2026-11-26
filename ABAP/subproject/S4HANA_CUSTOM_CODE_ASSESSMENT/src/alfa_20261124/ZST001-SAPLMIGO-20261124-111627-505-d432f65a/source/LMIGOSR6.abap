*----------------------------------------------------------------------*
*   INCLUDE LMIGOSR6                                                   *
*   Search for production orders during goods receipt.
*----------------------------------------------------------------------*

************************************************************************
* Send the popup
************************************************************************
METHOD order_search_popup.
  CALL SCREEN 3010 STARTING AT 5 1.
  IF sy-ucomm = 'OK_START'.
    CALL METHOD order_search.
  ENDIF.
ENDMETHOD.

************************************************************************
* Execute the search
************************************************************************
METHOD order_search.

* Communication structure with PPCOWE00.
* All changes need to be done in parallel.
  TYPES: BEGIN OF ty_ord_tab.
           INCLUDE TYPE afpo.
    TYPES: autyp TYPE caufv-autyp,
           gamng TYPE caufv-gamng,
           gmein TYPE caufv-gmein,
           kopf_objnr TYPE caufv-objnr,
           sttxt TYPE caufvd-sttxt,
         END OF ty_ord_tab.

  DATA: ls_got156  TYPE got156,
        ls_ord_tab TYPE ty_ord_tab,
        lt_ord_tab TYPE TABLE OF ty_ord_tab,
        ls_list    TYPE ty_s_order,
        lt_list    TYPE ty_t_order,
        ls_message TYPE lif_migo_frame~ty_s_message.

* Get SHKZG of the current default movement type
  CALL METHOD lcl_migo_buffer=>move_type_get
    EXPORTING
      i_move   = lcl_migo_globals=>kernel->s_defaults-bwart
    IMPORTING
      e_got156     = ls_got156
    EXCEPTIONS
      OTHERS = 1.
*   Call the report
    EXPORT fueb-nrcfd = x TO MEMORY ID 'WE_AUFTRAG'.
    EXPORT no_dialog  = x TO MEMORY ID 'PPCOWE00_CONTROL'.
    IF NOT gosearch_ord-matnr IS INITIAL OR
       NOT gosearch_ord-werks IS INITIAL.
      SUBMIT ppcowe00 AND RETURN WITH p_matnr = gosearch_ord-matnr
                                 WITH p_werks = gosearch_ord-werks
                                 WITH p_shkzg = ls_got156-shkzg.
    ENDIF.
    IMPORT ord_tab_export = lt_ord_tab
           FROM MEMORY ID 'PPCOWE00_RESULT'.

*   Prepare the MIGO searchresult table
    LOOP AT lt_ord_tab INTO ls_ord_tab.
      MOVE-CORRESPONDING ls_ord_tab TO ls_list.
      APPEND ls_list TO lt_list.
    ENDLOOP.

* Send the searchresult (may be empty)
  ls_message-data1 = 'R08'.
  GET REFERENCE OF lt_list INTO ls_message-dref.
  CALL METHOD lcl_migo_frame=>message_send
    EXPORTING
      i_iref_sender = me
      i_message_id  = 'NEW_SEARCHRESULT'
      is_message    = ls_message.

ENDMETHOD.