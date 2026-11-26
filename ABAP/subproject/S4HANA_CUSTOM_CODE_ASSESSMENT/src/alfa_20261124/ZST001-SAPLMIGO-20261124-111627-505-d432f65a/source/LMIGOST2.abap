*----------------------------------------------------------------------*
*   INCLUDE LMIGOST2                                                   *
*   GUI status
*----------------------------------------------------------------------*

CLASS lcl_migo_status IMPLEMENTATION.

************************************************************************
* Register for all OK-codes processed by the GUI status
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes,
          lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids,
          lt_sending     TYPE lif_migo_frame=>ty_t_message_ids.
    lif_migo_frame~class_id = 'MIGO_STATUS'.
* OK-code standard menu functions
    APPEND 'OK_POST'  TO lt_okcodes.
    APPEND 'OK_POST1' TO lt_okcodes.
    APPEND 'OK_CHECK' TO lt_okcodes.
    APPEND 'OK_TREE'  TO lt_okcodes.
    APPEND 'OK_HELP'  TO lt_okcodes.
* Function codes that have to be remapped because they are usually
* triggered by dynpro buttons (with OK-code MIGO_OK...)
    APPEND 'OK_GO'      TO lt_okcodes.
    APPEND 'OK_SORT_UP' TO lt_okcodes.
    APPEND 'OK_SORT_D'  TO lt_okcodes.
    APPEND 'OK_SEARCH'  TO lt_okcodes.
    APPEND 'OK_SEARCHN' TO lt_okcodes.
    APPEND 'OK_NOT_OK'  TO lt_okcodes.
    APPEND 'OK_TAKE_VA' TO lt_okcodes.
    APPEND 'OK_SPLIT_Q' TO lt_okcodes.
    APPEND 'OK_CONT'    TO lt_okcodes.
    APPEND 'OK_NOT_ORD' TO lt_okcodes.
    APPEND 'OK_NEW_IT'  TO lt_okcodes.                      "409735
    APPEND 'OK_PREV_IT' TO lt_okcodes.
    APPEND 'OK_NEXT_IT' TO lt_okcodes.
* OK-codes for EXIT-functions
    APPEND 'OK_REFRESH' TO lt_okcodes.
    APPEND 'OK_END'     TO lt_okcodes.
    APPEND 'OK_EXIT'    TO lt_okcodes.
    APPEND 'P++'        TO lt_okcodes.
    APPEND 'P+ '        TO lt_okcodes.
    APPEND 'P--'        TO lt_okcodes.
    APPEND 'P- '        TO lt_okcodes.
* Messages
    APPEND 'MIGO_TREE_STATUS'           TO lt_receiving.
    APPEND 'KERNEL_STATUS_CHANGED'      TO lt_receiving.
    APPEND 'KERNEL_MODE_CHANGED'        TO lt_receiving.
    APPEND 'MIGO_DETAIL_TOGGLER_STATUS' TO lt_receiving.
    APPEND 'ITEMDETAIL_CURRENTLINE'     TO lt_receiving.
    APPEND 'MIGO_TV_TOGGLER_STATUS'     TO lt_receiving.
    APPEND 'NEW_DOCUMENT'               TO lt_receiving.

    APPEND 'MIGO_TREE_OPEN'        TO lt_sending.
    APPEND 'MIGO_TREE_CLOSE'       TO lt_sending.
    APPEND 'MIGO_HTML_HELP_SHOW'   TO lt_sending.
    APPEND 'MIGO_SCROLL'           TO lt_sending.
    APPEND 'TRANSACTION_LEAVE'     TO lt_sending.

    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_receiving  = lt_receiving
        it_sending    = lt_sending.
  ENDMETHOD.                    "constructor

************************************************************************
* Message handler
************************************************************************
  METHOD lif_migo_frame~message_handler.
    CASE i_message_id.
      WHEN 'MIGO_TREE_STATUS'.
        IF is_message-data1 = 'VISIBILITY'.
          p_tree_visible = is_message-data2.
        ENDIF.
      WHEN 'MIGO_DETAIL_TOGGLER_STATUS'.
        p_detail_visible = is_message-data2.
      WHEN 'ITEMDETAIL_CURRENTLINE'.
        p_detail_line    = is_message-data1.
    ENDCASE.
* Update the status for all incoming messages (KERNEL_MODE_CHANGED...)
    CALL METHOD status_set.
  ENDMETHOD.                    "lif_migo_frame~message_handler

************************************************************************
* Ok-code handler
* OK-codes in GUI stati are limited in length (10 characters).
* The Ok-codes in the dynpros are sometimes longers, especially
* as they have to carry the prefix "MIGO_". Therefore, a mapping
* is necessary to offer the same functions in the status.
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    DATA: l_new_okcode TYPE lif_migo_frame=>ty_okcode,
          l_name       TYPE lcl_migo_screenobject=>ty_name,
          l_ok         TYPE abap_bool.
    CLEAR ok_check.                                             "1102164
    CASE i_okcode.
*   Remapping
      WHEN 'OK_GO'.      l_new_okcode = 'MIGO_OK_GO'.
      WHEN 'OK_NOT_OK'.  l_new_okcode = 'MIGO_OK_NOT_OK'.
      WHEN 'OK_TAKE_VA'. l_new_okcode = 'MIGO_OK_TAKE_VALUE'.
      WHEN 'OK_SPLIT_Q'. l_new_okcode = 'MIGO_OK_SPLIT_QUAN'.
      WHEN 'OK_CONT'.    l_new_okcode = 'MIGO_OK_CONTAINER'.
      WHEN 'OK_NOT_ORD'. l_new_okcode = 'MIGO_OK_NOT_ORDERED'.
      WHEN 'OK_NEW_IT'.  l_new_okcode = 'MIGO_OK_NEW_ITEMS'."409735
      WHEN 'OK_PREV_IT'. l_new_okcode = 'MIGO_OK_PREV_IT'.
      WHEN 'OK_NEXT_IT'. l_new_okcode = 'MIGO_OK_NEXT_IT'.
      WHEN 'OK_SORT_UP'. l_new_okcode = 'MIGO_OK_SORT_UP'.
      WHEN 'OK_SORT_D'.  l_new_okcode = 'MIGO_OK_SORT_DOWN'.
      WHEN 'OK_SEARCH'.  l_new_okcode = 'MIGO_OK_SEARCH_STRG'.
      WHEN 'OK_SEARCHN'. l_new_okcode = 'MIGO_OK_SEARCH_NEXT'.
*   Executable functions
      WHEN 'OK_POST' OR 'OK_POST1'.
*       Check if there are any error messages that have been     ERP2005
*       added to the log via MB_MIGO_ITEM_BADI.
*       In case of errors - switch into simulation mode to
*       prevent posting while showing badi and mb_create-
*       messages together
        IF NOT lcl_migo_globals=>if_badi_item IS INITIAL AND
           oref_badi_log->message_exist_all( i_error_only = abap_true ) = abap_true.
          CALL METHOD lcl_migo_globals=>kernel->document_check.
        ELSE.
          CALL METHOD lcl_migo_globals=>kernel->document_post.
        ENDIF.
      WHEN 'OK_CHECK'.
ENHANCEMENT-SECTION     LMIGOST2_01 SPOTS ES_SAPLMIGO.
        ok_check = x.                                           "1102164
        CALL METHOD lcl_migo_globals=>kernel->document_check
          IMPORTING
            e_ok = l_ok.
        IF l_ok = abap_true.
          MESSAGE s026.                "document is o.k.
        ENDIF.
END-ENHANCEMENT-SECTION.
      WHEN 'OK_REFRESH' OR 'OK_EXIT'.
        CHECK popup_to_confirm( text-007 ) = abap_true.
        CALL METHOD lcl_migo_globals=>kernel->reset.
        CALL METHOD lcl_migo_enqueue=>restore( 'TRANSACTION_START' ).
        LEAVE TO SCREEN 0001.
      WHEN 'OK_END'.
        CHECK popup_to_confirm( text-001 ) = abap_true.
*       Restore of enqueue state only necessary if MIGO has
*       been called externally. Otherwise, the roll area is
*       destroyed and the locks are removed by the system.
        IF lcl_migo_globals=>external_call_active = abap_true."377195
          CALL METHOD lcl_migo_enqueue=>restore( 'TRANSACTION_START' ).
        ENDIF.                                              "377195
        def_sms 'TRANSACTION_LEAVE' space space.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'OK_TREE'.
        IF p_tree_visible = abap_true.
          def_sms 'MIGO_TREE_CLOSE' space space.
        ELSE.
          def_sms 'MIGO_TREE_OPEN'  space space.
        ENDIF.
      WHEN 'OK_HELP'.
        def_sms 'MIGO_HTML_HELP_SHOW' space space.
      WHEN 'P++' OR 'P+ ' OR 'P--' OR 'P- '.
*       Can only be executed if the cursor can be found in the
*       MIGO screens. Does not work for cursor in controls, foreign
*       subscreens etc.
        IF NOT lcl_migo_cursor=>oref_screenobject IS INITIAL."366534
          CALL METHOD
            lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
            IMPORTING
              e_name = l_name.
*         Default: Scroll in tableview tv_goitem. If cursor is in
*         different tableview (serialnumbers, freight,...),
*         then scroll in this tv
          IF l_name <> 'SERIALNUMBERS' AND l_name <> 'FREIGHT'.
            l_name = 'TABLEVIEW'.
          ENDIF.
          def_sms 'MIGO_SCROLL' l_name i_okcode.
        ENDIF.                                              "366534
    ENDCASE.
* In case of remapping, send the new OK-code
    IF l_new_okcode <> space.
      CALL METHOD lcl_migo_frame=>okcode_dispatch( l_new_okcode ).
    ENDIF.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

************************************************************************
* Set the status according to the kernel state
************************************************************************
  METHOD status_set.
    DATA: l_status TYPE migo_fs_status,
          l_j1b_subcontr TYPE abap_bool.            " Brazil Note 327205
    CLEAR pt_excluding.
* No posting and checking possible in DISPLAY-mode
    IF lcl_migo_globals=>kernel->s_action-display = abap_true.
      APPEND 'OK_POST'    TO pt_excluding.
      APPEND 'OK_POST1'   TO pt_excluding.
      APPEND 'OK_CHECK'   TO pt_excluding.
    ENDIF.
* Recovery of saved entries possible only if no positions in table
    IF lcl_migo_globals=>kernel->s_status-lines = 0.
      APPEND 'OK_POST'   TO pt_excluding.
      APPEND 'OK_POST1'  TO pt_excluding.
      APPEND 'OK_CHECK'  TO pt_excluding.
      APPEND 'OK_J1BA'   TO pt_excluding.
    ELSE.
      APPEND 'OK_PRE_SEL' TO pt_excluding.
    ENDIF.
* 1.Foreign trade: no OK_PREDOC possible as external ftrade memory
*   Necessary because import data is copied from PO, which is not
*   possible after parking a document.
* 2.BAdI MB_MIGO_BADI: parameter s_status-no_predoc can be set in order
*   to disable the 'Hold Data'-function.
    IF lcl_migo_globals=>kernel->s_status-ximport = abap_true OR
       lcl_migo_globals=>kernel->s_status-no_predoc = abap_true.
      APPEND 'OK_PREDOC'  TO pt_excluding.
    ENDIF.
* Text for the tree-button
    IF p_tree_visible = abap_false.
      g_tree_button_text = 'Tree on'(117).
    ELSE.
      g_tree_button_text = 'Tree off'(108).
    ENDIF.
* If MIGO has been called and is requested not to permit
* anything leaving the current document: Disable nearly everything.
    IF lcl_migo_globals=>external_call_deadend = abap_true.
      APPEND 'OK_TREE'    TO pt_excluding.
      APPEND 'OK_REFRESH' TO pt_excluding.
      APPEND 'OK_PREDOC'  TO pt_excluding.
      APPEND 'OK_DEFVALS' TO pt_excluding.
    ENDIF.
*   Derive activity for OK-codes which correcpond to buttons on the
*   screen. This can be done using the fieldselection information.
    DEFINE def_exclude.
      call method lcl_migo_screenmodification=>get
        exporting
          i_field          = &2
          i_global_counter = 0
        receiving
          r_status         = l_status.
      if l_status < lcl_migo_screenmodification=>c_input.
        append &1 to pt_excluding.
      endif.
    END-OF-DEFINITION.
    def_exclude 'OK_NOT_ORD' 'OK_NOT_ORDERED'.
    def_exclude 'OK_CONT'    'OK_CONTAINER'.
    def_exclude 'OK_NEW_IT'  'OK_NEW_ITEMS'.                "409735
    def_exclude 'OK_SPLIT_Q' 'OK_SPLIT_QUANTITY'.
    def_exclude 'OK_NOT_OK'  'OK_NOT_OK'.
    def_exclude 'OK_TAKE_VA' 'OK_TAKE_VALUE'.
*   Set status
    IF lcl_migo_globals=>kernel->s_status-xtaxes = abap_false.
      SET PF-STATUS 'MIGO_STATUS' EXCLUDING pt_excluding.
    ELSE.
*   Note 381582
*     CALL METHOD oref_nota_fiscal->j_1b_get_subcontr       "Note 327205
*       RECEIVING r_subcontr = l_j1b_subcontr.              "Note 327205
*     IF l_j1b_subcontr = abap_true.                        "Note 327205
      IF oref_nota_fiscal->j_1b_nf_button_disabled( ) = abap_true.
        SET PF-STATUS 'MIGO_STATUS' EXCLUDING pt_excluding.  "Note 327205
      ELSE.                                                 "Note 327205
        SET PF-STATUS 'MIGO_STATUS_BRAZIL' EXCLUDING pt_excluding.
      ENDIF.                                                "Note 327205
    ENDIF.
  ENDMETHOD.                    "status_set
************************************************************************
* Check whether refreshing or leaving the transaction is
* dangerous. Send a popup to offer a possibility to save, junk
* or cancel. If saving was not successful, return to the transaction
* without success.
************************************************************************
  METHOD popup_to_confirm.
    DATA: l_answer TYPE char1,
          l_posted TYPE abap_bool.
    ENHANCEMENT-POINT SAPLMIGO_10 SPOTS ES_SAPLMIGO STATIC.
    IF lcl_migo_globals=>kernel->s_status-lines = 0 OR
       lcl_migo_globals=>kernel->s_control-action = 'A04'.
      e_success = abap_true.
      EXIT.
    ENDIF.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption  = 'J'
        textline1      = text-003
        titel          = i_title
        cancel_display = 'X'
      IMPORTING
        answer         = l_answer.
    CASE l_answer.
      WHEN a.
        e_success = abap_false.
      WHEN n.
        e_success = abap_true.
      WHEN j.
        ENHANCEMENT-POINT SAPLMIGO_11 SPOTS ES_SAPLMIGO.

        CALL METHOD lcl_migo_globals=>kernel->document_post
          IMPORTING
            e_ok = l_posted.
        CASE l_posted.
          WHEN abap_true.  e_success = abap_true.
          WHEN abap_false. e_success = abap_false.
        ENDCASE.
    ENDCASE.
  ENDMETHOD.                    "popup_to_confirm

ENDCLASS.                    "lcl_migo_status IMPLEMENTATION