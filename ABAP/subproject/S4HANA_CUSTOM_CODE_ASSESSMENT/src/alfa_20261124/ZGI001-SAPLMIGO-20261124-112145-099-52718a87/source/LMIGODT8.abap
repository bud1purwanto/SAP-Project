*&---------------------------------------------------------------------*
*&  Include           LMIGODT8                                         *
*&---------------------------------------------------------------------*
CLASS lcl_migo_detail_trans IMPLEMENTATION.

************************************************************************
* Method constructor
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame~ty_t_okcodes,
          lt_sending TYPE lif_migo_frame~ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_DETAIL_TRANS'.
    APPEND 'MIGO_OK_DET_LEFT'       TO lt_okcodes.
    APPEND 'MIGO_OK_DET_RIGHT'      TO lt_okcodes.
    APPEND 'DETERMINE_SINGLE'       TO lt_sending.
    APPEND 'DETERMINE_SINGLE_RIGHT' TO lt_sending.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_sending    = lt_sending.
  ENDMETHOD.                    "constructor

************************************************************************
* Handler for the button
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'MIGO_OK_DET_LEFT'.
        def_sms 'DETERMINE_SINGLE' oref_detail->current_line space.
      WHEN 'MIGO_OK_DET_RIGHT'.
        def_sms 'DETERMINE_SINGLE_RIGHT'
           oref_detail->current_line space.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler
************************************************************************
* Method PBO_FRAME_TEXT_SET:
* This method sets the text for the two frames on the item detail
* tabstrip TRANSFER:
* - SHKZG = S:  FROM / TO
* - SHKZG = H:  TO / FROM
************************************************************************
  METHOD pbo_frame_text_set.
    DATA: l_shkzg TYPE goitem-shkzg.
*   PT_GOITEM initial -> Take SHKZG from default movement type
    IF goitem-shkzg IS INITIAL.
      SELECT SINGLE shkzg INTO l_shkzg FROM t156
         WHERE bwart = lcl_migo_globals=>kernel->s_defaults-bwart.
    ELSE.
      l_shkzg = goitem-shkzg.
    ENDIF.
*   Set frame-text on item detail tabstrip TRASFER
    IF l_shkzg = s.
*     Reversal transfer movement type (302, 312, ...)
      godynpro-left_transfer_frame  = text-220.
      godynpro-right_transfer_frame = text-210.
    ELSE.
*     Normal transfer movement type (301, 311, ...)
      godynpro-left_transfer_frame  = text-210.
      godynpro-right_transfer_frame = text-220.
    ENDIF.
  ENDMETHOD.                      " pbo_frame_text_set

************************************************************************
* METHOD pbo_stock_identifier_set
************************************************************************
  METHOD pbo_stock_identifier_set.

*   Get special stock indicator for right subscreen
    CALL METHOD lcl_migo_globals=>kernel->umsok_get
                  CHANGING c_sobkz   = godynpro-sobkz
                           cs_goitem = goitem.

*   Text for special stock indicators
    CLEAR: goitem-sotxt,
           goitem-umsotxt.
    IF NOT godynpro-sobkz IS INITIAL.
      SELECT SINGLE sotxt FROM t148t INTO goitem-sotxt
                            WHERE spras = sy-langu
                              AND sobkz = godynpro-sobkz.
    ENDIF.
    IF NOT goitem-umsok IS INITIAL.
      SELECT SINGLE sotxt FROM t148t INTO goitem-umsotxt
                            WHERE spras = sy-langu
                              AND sobkz = goitem-umsok.
    ENDIF.

*   Left special stock subscreen for transfer detail.
    CASE goitem-sobkz.
      WHEN 'Q'.    g_sub_transfer_left = '0391'.
      WHEN 'K' OR 'O' OR 'P' OR 'M'.    g_sub_transfer_left = '0392'.
      WHEN 'W' OR 'V'.                  g_sub_transfer_left = '0393'.
      WHEN 'E'.    g_sub_transfer_left = '0394'.
      WHEN OTHERS. g_sub_transfer_left = '0399'.
    ENDCASE.
*   Right special stock subscreen for transfer detail.
    CASE goitem-umsok.
      WHEN 'Q'.    g_sub_transfer_right = '0395'.
      WHEN 'K' OR 'O' OR 'P' OR 'M'.    g_sub_transfer_right = '0396'.
      WHEN 'W' OR 'V'.                  g_sub_transfer_right = '0397'.
      WHEN 'E'.                         g_sub_transfer_right = '0398'.
      WHEN 'T'.                         g_sub_transfer_right = '0500'.
      WHEN OTHERS. g_sub_transfer_right = '0399'.
    ENDCASE.

ENHANCEMENT-POINT EHP604_PBO_STOCK_IDENT_SET_01 SPOTS ES_SAPLMIGO .

  ENDMETHOD.                    "pbo_stock_identifier_set

ENDCLASS.                    "lcl_migo_detail_trans IMPLEMENTATION