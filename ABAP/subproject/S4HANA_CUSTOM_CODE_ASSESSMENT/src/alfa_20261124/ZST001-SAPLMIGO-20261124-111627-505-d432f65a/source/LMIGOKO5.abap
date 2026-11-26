*----------------------------------------------------------------------*
*   INCLUDE LMIGOKO5
*----------------------------------------------------------------------*
* method order_reservation_read.                                       *
*----------------------------------------------------------------------*
* This method looks in table afko (order headers) for the dependent    *
* reservation of an order (there can be only one) and hands it over to *
* the method reading reservations.                               *
*----------------------------------------------------------------------*
METHOD order_reservation_read.
  DATA: l_res_number  TYPE rsnum,
        lt_res_items  TYPE TABLE OF rspos,
        l_res_item    TYPE rspos,
        l_rc          LIKE sy-subrc.                        "534257

  CALL FUNCTION 'CO_SF_HEADER_GOODS_ISSUE'                  " 948510
     EXPORTING                                              " 948510
          AUFNR = i_order_number.                           " 948510

  SELECT SINGLE rsnum FROM  afko
                      INTO  l_res_number
                      WHERE aufnr = i_order_number.

  CHECK sy-subrc = 0.

*Begin of Note 534257
* In case of order' check for AFFW entries
* same check for reservations in method reservation_data_fill
* (LMIGOKR2)
  IF NOT s_action-create is INITIAL.
    CALL FUNCTION 'CO_FW_CHECK_AFFW_BY_RSNUM'
      EXPORTING
        I_AUFNR     = i_order_number
      EXCEPTIONS
        INPUT_ERROR = 1
        NOT_FOUND   = 2
        OTHERS      = 3.
* If AFFW entry exits sy-subrc = 0
    IF sy-subrc = 0.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          I_ARBGB = 'M7'
          i_msgnr = '398'
          i_nolog = 'X'
        IMPORTING
          RC      = l_rc.
      CASE l_rc.
        WHEN '01'.
          MESSAGE W398(m7) WITH i_order_number.
          CALL METHOD oref_doc_log->message_add
            EXPORTING
              i_msgty = w
              i_msgid = 'M7'
              i_msgno = '398'
              i_msgv1 = i_order_number.
        WHEN '02'.
          MESSAGE S398(m7) WITH i_order_number.
          CALL METHOD oref_doc_log->message_add
            EXPORTING
              i_msgty = e
              i_msgid = 'M7'
              i_msgno = '398'
              i_msgv1 = i_order_number.
          RETURN.
      ENDCASE.
    ENDIF.
  ENDIF.
*End of Note 534257

  IF i_order_operation IS INITIAL.
    CALL METHOD reservation_read
      EXPORTING
        i_res_number = l_res_number.
  ELSE.
    SELECT rspos INTO TABLE lt_res_items
                 FROM  resb
                 WHERE rsnum = l_res_number AND
                       vornr = i_order_operation AND
                       rsart = space.                       "Note_853319
    LOOP AT lt_res_items INTO l_res_item.
      CALL METHOD reservation_read
        EXPORTING
          i_res_number = l_res_number
          i_res_item   = l_res_item.
    ENDLOOP.
  ENDIF.
ENDMETHOD.