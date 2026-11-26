*----------------------------------------------------------------------*
*   INCLUDE LMIGOFR2                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_frame IMPLEMENTATION.
************************************************************************
* The class-constructor. Set the initial queue-mode (just to be sure)
************************************************************************
METHOD class_constructor.
* Start in immedeate processing mode
  p_queue_mode = abap_false.
* Initialize user settings
  CREATE OBJECT poref_settings EXPORTING i_action = 'MIGO_TRACE'.
  CALL METHOD poref_settings->preset( i_element = 'VISIBILITY'
                                      i_active  = abap_false ).
  CALL METHOD poref_settings->preset( i_element = 'TRACE_OKCODES'
                                      i_active  = abap_false ).
  CALL METHOD poref_settings->preset( i_element = 'TRACE_MESSAGES'
                                      i_active  = abap_false ).
  CALL METHOD poref_settings->preset( i_element = 'TRACE_INFOS'
                                      i_active  = abap_false ).
  CALL METHOD poref_settings->preset( i_element = 'TRACE_RECEIVERS'
                                      i_active  = abap_false ).
* Initialize trace
  trace_okcodes   = poref_settings->get( 'TRACE_OKCODES' ).
  trace_messages  = poref_settings->get( 'TRACE_MESSAGES' ).
  trace_infos     = poref_settings->get( 'TRACE_INFOS' ).
  trace_receivers = poref_settings->get( 'TRACE_RECEIVERS' ).
  IF poref_settings->get( 'VISIBILITY' ) = abap_true.
    CALL METHOD trace_visibility_set( i_visibility  = abap_true
                                      i_constructor = abap_true ).
    SET HANDLER toolbar_handler FOR poref_toolbar.
    SET HANDLER close_handler   FOR poref_amodal_window.
  ENDIF.
ENDMETHOD.
************************************************************************
* Append the OKCODES to be registered for this viewer
************************************************************************
METHOD viewer_register.
  DATA: ls_registered_okcode  TYPE pty_s_registered_okcode,
        ls_registered_message TYPE pty_s_registered_message,
        ls_registered_sender  TYPE pty_s_registered_message,
        l_okcode              TYPE lif_migo_frame~ty_okcode,
        l_message_id          TYPE lif_migo_frame~ty_message_id.
* Verify that the viewer has a proper identification and verify
* that there is no double registration
  IF i_iref_viewer->class_id IS INITIAL.
    MESSAGE a899(migo) WITH 'FRAMEWORK_ERROR'
                            'EMPTY_CLASS_ID'
                            space
                            space.
  ENDIF.
  READ TABLE pt_registered_viewers
             WITH TABLE KEY table_line = i_iref_viewer->class_id
             TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    MESSAGE a899(migo) WITH 'FRAMEWORK_ERROR'
                            'DOUBLE_REGISTRATION'
                            i_iref_viewer->class_id
                            space.
  ENDIF.
  INSERT i_iref_viewer->class_id INTO TABLE pt_registered_viewers.
* Register OKCODES
  LOOP AT it_okcodes INTO l_okcode.
*   Catch double registrations
    READ TABLE pt_registered_okcodes
               WITH KEY okcode     = l_okcode
                        component  = i_iref_viewer
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      MESSAGE a899(migo) WITH 'FRAMEWORK_ERROR'
                              'DOUBLE_OKCODE_REGISTRATION'
                              i_iref_viewer->class_id
                              l_okcode.
    ENDIF.
    ls_registered_okcode-okcode    = l_okcode.
    ls_registered_okcode-component = i_iref_viewer.
    INSERT ls_registered_okcode INTO TABLE pt_registered_okcodes.
  ENDLOOP.
* Register receiving MESSAGES
  LOOP AT it_receiving INTO l_message_id.
*   Catch double registrations
    READ TABLE pt_registered_messages
               WITH KEY message_id = l_message_id
                        component  = i_iref_viewer
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      MESSAGE a899(migo) WITH 'FRAMEWORK_ERROR'
                              'DOUBLE_RECEIVER_REGISTRATION'
                              i_iref_viewer->class_id
                              l_message_id.
    ENDIF.
    ls_registered_message-message_id = l_message_id.
    ls_registered_message-component = i_iref_viewer.
    INSERT ls_registered_message INTO TABLE pt_registered_messages.
  ENDLOOP.
* Register sending MESSAGES
  LOOP AT it_sending INTO l_message_id.
*   Catch double registrations
    READ TABLE pt_registered_senders
               WITH TABLE KEY message_id = l_message_id
                              component  = i_iref_viewer
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      MESSAGE a899(migo) WITH 'FRAMEWORK_ERROR'
                              'DOUBLE_SENDER_REGISTRATION'
                              i_iref_viewer->class_id
                              l_message_id.
    ENDIF.
    ls_registered_sender-message_id = l_message_id.
    ls_registered_sender-component  = i_iref_viewer.
    INSERT ls_registered_sender INTO TABLE pt_registered_senders.
  ENDLOOP.

ENDMETHOD.
************************************************************************
* Dispatch an OKCODE to the registered viewers
************************************************************************
METHOD okcode_dispatch.
  DATA: ls_registered_okcode TYPE pty_s_registered_okcode,
        ls_message_queue     TYPE pty_s_message_queue,
        l_okcode             TYPE lif_migo_frame~ty_okcode,
        l_msg_string         TYPE ty_trace_line.
* First of all, we process the messages that have been queued
* (messages from controls have to be processed after the field
*  transport, too).
  LOOP AT pt_message_queue INTO ls_message_queue.
    DELETE pt_message_queue.
    CALL METHOD message_send
      EXPORTING
        i_message_id  = ls_message_queue-message_id
        i_iref_sender = ls_message_queue-sender
        is_message    = ls_message_queue-message.
  ENDLOOP.
* Start processing the OK-code
  IF lcl_migo_globals=>external_call_active = abap_true AND
     i_okcode = 'OK_EXIT'.
    l_okcode = 'OK_END'.
  ELSE.
    l_okcode = i_okcode.
  ENDIF.
* Tace of OKCODES
  IF trace_okcodes = abap_true.
    CLEAR l_msg_string.
    WRITE 'OKCODE' TO l_msg_string(25).
    WRITE ':'              TO l_msg_string+25(1).
    WRITE l_okcode         TO l_msg_string+27(30).
    WRITE ':'              TO l_msg_string+57(1).
    WRITE '|'              TO l_msg_string+84(1).
    CALL METHOD add_line( i_data1 = l_msg_string
                          i_data2 = space ).
  ENDIF.
* Execute the OK-codes
  CLEAR okcode.
  LOOP AT pt_registered_okcodes INTO ls_registered_okcode
                               WHERE ( okcode = l_okcode OR
                                       okcode = '*' ).
*   Trace receivers of okcodes
    IF trace_receivers = abap_true.
      CLEAR l_msg_string.
      WRITE ':'               TO l_msg_string+25(1).
      CONCATENATE 'OK ---->' l_okcode INTO
                 l_msg_string+27(30) SEPARATED BY space.
      WRITE ':'               TO l_msg_string+57(1).
      WRITE ls_registered_okcode-component->class_id
                              TO l_msg_string+59(25).
      WRITE '|'               TO l_msg_string+84(1).
      CALL METHOD add_line( i_data1 = l_msg_string
                            i_data2 = space ).
    ENDIF.
*   Call handler function
    CALL METHOD ls_registered_okcode-component->okcode_handler
      EXPORTING
        i_okcode = l_okcode.
  ENDLOOP.
* OK-codes are dispatched to the GUI-framework for controls
  CALL METHOD cl_gui_cfw=>dispatch.
ENDMETHOD.
************************************************************************
* Send message to the listeners. If these fill in data
* into the answer-structure, forward this data to the sender.
************************************************************************
METHOD message_send.
  DATA: ls_registered_message TYPE pty_s_registered_message,
        ls_message_queue      TYPE pty_s_message_queue,
        l_msg_string          TYPE ty_trace_line,
        ls_answer             TYPE lif_migo_frame~ty_s_message,
        ls_answers            TYPE lif_migo_frame~ty_s_answers.
* Verify that the sender is allowed to send this message
* System messages can be send without registration.
  IF i_system_message = abap_false.
    READ TABLE pt_registered_senders
               WITH TABLE KEY message_id = i_message_id
                              component  = i_iref_sender
               TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      MESSAGE a899 WITH 'FRAMEWORK_ERROR'
                        'MESSAGE_WITHOUT_REGISTRATION'
                        i_iref_sender->class_id
                        i_message_id.
    ENDIF.
  ENDIF.
* If messege queueing active, buffer the message and exit.
  IF p_queue_mode = abap_true OR i_delayed = abap_true.
    ls_message_queue-message_id = i_message_id.
    ls_message_queue-sender     = i_iref_sender.
    ls_message_queue-message    = is_message.
    APPEND ls_message_queue TO pt_message_queue.
    EXIT.
  ENDIF.
* Trace of messages
  IF trace_messages = abap_true.
    CLEAR l_msg_string.
    IF i_iref_sender IS INITIAL.
      WRITE 'SYSTEM' TO l_msg_string(25).
    ELSE.
      WRITE i_iref_sender->class_id TO l_msg_string(25).
    ENDIF.
    WRITE ':'              TO l_msg_string+25(1).
    WRITE i_message_id     TO l_msg_string+27(30).
    WRITE ':'              TO l_msg_string+57(1).
    WRITE is_message-data1 TO l_msg_string+59(25).
    WRITE '|'              TO l_msg_string+84(1).
    WRITE is_message-data2 TO l_msg_string+86(25).
    CALL METHOD add_line( i_data1 = l_msg_string
                          i_data2 = space ).
  ENDIF.
* Deliver messages
  CLEAR et_answers.
  LOOP AT pt_registered_messages INTO ls_registered_message
          WHERE ( message_id = i_message_id OR
                  message_id = '*' ).
*   Trace receivers of messages
    IF trace_receivers = abap_true.
      CLEAR l_msg_string.
      WRITE ':'               TO l_msg_string+25(1).
      CONCATENATE 'MSG --->' i_message_id INTO
                 l_msg_string+27(30) SEPARATED BY space.
      WRITE ':'               TO l_msg_string+57(1).
      WRITE ls_registered_message-component->class_id
                              TO l_msg_string+59(25).
      WRITE '|'               TO l_msg_string+84(1).
      CALL METHOD add_line( i_data1 = l_msg_string
                            i_data2 = space ).
    ENDIF.
*   Call the receiver
    CLEAR ls_answer.
    CALL METHOD ls_registered_message-component->message_handler
      EXPORTING
        i_message_id  = i_message_id
        i_iref_sender = i_iref_sender
        is_message    = is_message
      IMPORTING
        es_answer     = ls_answer.
    IF NOT ls_answer IS INITIAL.
      MOVE-CORRESPONDING ls_answer TO ls_answers.
      ls_answers-recipient = ls_registered_message-component.
      APPEND ls_answers TO et_answers.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Simple message = implicit creation of the work area
************************************************************************
METHOD message_send_simple.
  DATA: ls_message TYPE lif_migo_frame~ty_s_message.
* Implicit cast from ANY to TY_MESSAGE_DATA.
  ls_message-data1 = i_data1.
  ls_message-data2 = i_data2.
  CALL METHOD message_send
    EXPORTING
      i_message_id  = i_message_id
      i_iref_sender = i_iref_sender
      is_message    = ls_message
      i_delayed     = i_delayed.
ENDMETHOD.
************************************************************************
* Dummy implementations of the handlers
************************************************************************
METHOD lif_migo_frame~okcode_handler.
ENDMETHOD.
METHOD lif_migo_frame~message_handler.
ENDMETHOD.
************************************************************************
* Message queues
************************************************************************
METHOD queue_messages.
  p_queue_mode = abap_true.
ENDMETHOD.

METHOD process_messages.
  DATA: ls_message_queue TYPE pty_s_message_queue,
        lt_answers       TYPE lif_migo_frame~ty_t_answers.
  p_queue_mode = abap_false.
  LOOP AT pt_message_queue INTO ls_message_queue.
    DELETE pt_message_queue.
    CALL METHOD message_send
      EXPORTING
        i_message_id  = ls_message_queue-message_id
        i_iref_sender = ls_message_queue-sender
        is_message    = ls_message_queue-message
      IMPORTING
        et_answers    = lt_answers.
*   Buffered messages must not have answers. This ensures that
*   the evaluation of the answer is not lost. The answering concept
*   requires the sender to be online when sending. This is not the
*   case here.
    IF NOT lt_answers IS INITIAL.
      MESSAGE a899 WITH 'FRAMEWORK_ERROR'
                        'BUFFERED_MESSAGE_GETS_ANSWER'
                        ls_message_queue-sender->class_id
                        ls_message_queue-message_id.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
************************************************************************
* Check the existence of a viewer
************************************************************************
METHOD viewer_exist.
  READ TABLE pt_registered_viewers
             WITH TABLE KEY table_line = i_class_id
             TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    r_exists = abap_true.
  ELSE.
    r_exists = abap_false.
  ENDIF.
ENDMETHOD.
************************************************************************
* Crossreference list
************************************************************************
METHOD crossreference_dump.
  DATA: t_list     TYPE STANDARD TABLE OF lif_migo_frame~ty_class_id,
        l_class_id TYPE lif_migo_frame~ty_class_id,
        l_id       TYPE lif_migo_frame~ty_message_id,
        s_msg      TYPE pty_s_registered_message,
        s1_msg     TYPE pty_s_registered_message,
        s_ok       TYPE pty_s_registered_okcode,
        t_id       TYPE STANDARD TABLE OF lif_migo_frame~ty_message_id,
        l_lines    TYPE i.

  DEFINE def_cross.
    call method add_line( i_data1       = &1
                          i_data2       = &2
                          i_late_update = abap_true ).
  END-OF-DEFINITION.

* Header
  def_cross 'Framework-Crossreference' space.                "#EC NOTEXT
  def_cross '========================' space.
  def_cross space space.
* Registered viewers
  CLEAR t_list.
  LOOP AT pt_registered_viewers INTO l_class_id.
    INSERT l_class_id INTO TABLE t_list.
  ENDLOOP.
  SORT t_list.
  def_cross 'Registered viewers' space.                      "#EC NOTEXT
  def_cross '------------------' space.
  LOOP AT t_list INTO l_class_id.
    def_cross l_class_id space.
    def_cross '---- OK-Codes' space.                         "#EC NOTEXT
    LOOP AT pt_registered_okcodes INTO s_ok
        WHERE component->class_id = l_class_id.
      def_cross '--------- ' s_ok-okcode.
    ENDLOOP.

    def_cross '---- Sending' space.                          "#EC NOTEXT
    LOOP AT pt_registered_senders INTO s_msg
        WHERE component->class_id = l_class_id.
      def_cross '--------- ' s_msg-message_id.
    ENDLOOP.

    def_cross '---- Receiving' space.                        "#EC NOTEXT
    LOOP AT pt_registered_messages INTO s_msg
        WHERE component->class_id = l_class_id.
      def_cross '--------- ' s_msg-message_id.
    ENDLOOP.
  ENDLOOP.

* Message flow rereference
  def_cross space space.
  def_cross space space.
  def_cross 'Message flow reference' space.                  "#EC NOTEXT
  def_cross '----------------------' space.
  LOOP AT t_list INTO l_class_id.
    def_cross l_class_id space.
    LOOP AT pt_registered_senders INTO s_msg
          WHERE component->class_id = l_class_id.
      def_cross '---- ' s_msg-message_id.
      LOOP AT pt_registered_messages INTO s1_msg
          WHERE message_id = s_msg-message_id.
        def_cross '--------- ' s1_msg-component->class_id.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
* Update the frontend
  CALL METHOD poref_textedit->set_text_as_r3table
    EXPORTING table = pt_trace.
  DESCRIBE TABLE pt_trace LINES l_lines.
  CALL METHOD poref_textedit->go_to_line
    EXPORTING line = l_lines.
ENDMETHOD.
************************************************************************
* Set the visibility of the trace. If not created, do this first.
************************************************************************
METHOD trace_visibility_set.
  DATA: ls_event  TYPE cntl_simple_event,
        lt_events TYPE cntl_simple_events.


  CASE i_visibility.
    WHEN abap_false.
      IF NOT poref_amodal_window IS INITIAL.
        CALL METHOD poref_amodal_window->set_visible( '0' ).
      ENDIF.
      trace_visible = abap_false.
    WHEN abap_true.
      IF poref_amodal_window IS INITIAL.
*       I had all coding form now on to start and fill the amodal window
*       in a separate method for the sake of good looking code. But
*       BASIS has a problem to see that I am not leaving the scope
*       of the class constructor by calling a method from here. Instead,
*       I received a short dump telling me something about problems
*       in recursive class contructors.
*       ----------------------------------------------------------------
*       Create the amodal window
        CREATE OBJECT poref_amodal_window
          EXPORTING
            width  = 950
            height = 150
            top    = 50
            left   = 700
            repid  = c_repid
            dynnr  = '0001'
            caption = 'MIGO Framework-Trace'.                "#EC NOTEXT
*       Create a splitter container and fix it
        CREATE OBJECT poref_splitter
          EXPORTING
            parent  = poref_amodal_window
            rows    = 2
            columns = 1.
        CALL METHOD poref_splitter->set_row_height
          EXPORTING
            id     = 1
            height = 8.
        CALL METHOD poref_splitter->set_row_sash
          EXPORTING
            id    = 1
            type  = cl_gui_splitter_container=>type_movable
            value = cl_gui_splitter_container=>false.
        poref_top    = poref_splitter->get_container( row    = 1
                                                      column = 1 ).
        poref_bottom = poref_splitter->get_container( row    = 2
                                                      column = 1 ).
*       Create the toolbar and insert the functions
        CREATE OBJECT poref_toolbar
          EXPORTING
            parent = poref_top.
        ls_event-eventid    = cl_gui_toolbar=>m_id_function_selected.
        ls_event-appl_event = space.
        APPEND ls_event TO lt_events.
        CALL METHOD poref_toolbar->set_registered_events
          EXPORTING
            events = lt_events.
*       Same problem as for the entire coding: SET HANDLER dumps here
*       as during construction this would be a second level.
*       Solution: SET HANDLER directly in the constructor.
        IF i_constructor = abap_false.
          SET HANDLER toolbar_handler FOR poref_toolbar.
          SET HANDLER close_handler   FOR poref_amodal_window.   "491163
        ENDIF.
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'TR_CLEAR'
                    butn_type  = cntb_btype_button
                    icon       = '@0Y@'
                    text       = 'Clear'.                    "#EC NOTEXT
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = ''
                    butn_type  = cntb_btype_sep
                    icon       = ''
                    text       = ''.
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'TR_OK'
                    butn_type  = cntb_btype_check
                    is_checked = trace_okcodes
                    icon       = '@LR@'
                    text       = 'OK-Codes'.                 "#EC NOTEXT
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'TR_MSG'
                    butn_type  = cntb_btype_check
                    is_checked = trace_messages
                    icon       = '@1S@'
                    text       = 'Sender'.                   "#EC NOTEXT
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'TR_RCV'
                    butn_type  = cntb_btype_check
                    is_checked = trace_receivers
                    icon       = '@1S@'
                    text       = 'Receiver'.                 "#EC NOTEXT
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'TR_INF'
                    butn_type  = cntb_btype_check
                    is_checked = trace_infos
                    icon       = '@0S@'
                    text       = 'Infos'.                    "#EC NOTEXT
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = ''
                    butn_type  = cntb_btype_sep
                    icon       = ''
                    text       = ''.
        CALL METHOD poref_toolbar->add_button
          EXPORTING fcode = 'CROSS'
                    butn_type  = cntb_btype_button
                    icon       = '@3A@'
                    text       = 'Cross'.                    "#EC NOTEXT
*       Create the textedit control
        CREATE OBJECT poref_textedit
          EXPORTING
            parent            = poref_bottom
            wordwrap_mode     =
                         cl_gui_textedit=>wordwrap_at_fixed_position
            wordwrap_position = 150
            wordwrap_to_linebreak_mode = cl_gui_textedit=>true.
        CALL METHOD poref_textedit->set_readonly_mode.
*       End of initialization code
*       ----------------------------------------------------------------
      ENDIF.
      CALL METHOD poref_amodal_window->set_visible( '1' ).
      trace_visible = abap_true.
  ENDCASE.
  CALL METHOD poref_settings->set( i_element = 'VISIBILITY'
                                   i_active  = trace_visible ).
  CALL METHOD cl_mmim_userdefaults=>flush_all.
ENDMETHOD.
************************************************************************
* Handler for toolbar functions
************************************************************************
METHOD toolbar_handler.
  CASE fcode.
    WHEN 'TR_OK'.  def_boolean_toggle trace_okcodes.
    WHEN 'TR_MSG'. def_boolean_toggle trace_messages.
    WHEN 'TR_RCV'. def_boolean_toggle trace_receivers.
    WHEN 'TR_INF'. def_boolean_toggle trace_infos.
    WHEN 'TR_CLEAR'.
      CLEAR pt_trace.
      CALL METHOD poref_textedit->set_text_as_r3table
        EXPORTING table = pt_trace.
    WHEN 'CROSS'.
      CALL METHOD crossreference_dump.
  ENDCASE.
  CALL METHOD poref_settings->set( i_element = 'TRACE_OKCODES'
                                   i_active  = trace_okcodes ).
  CALL METHOD poref_settings->set( i_element = 'TRACE_MESSAGES'
                                   i_active  = trace_messages ).
  CALL METHOD poref_settings->set( i_element = 'TRACE_INFOS'
                                   i_active  = trace_infos ).
  CALL METHOD poref_settings->set( i_element = 'TRACE_RECEIVERS'
                                   i_active  = trace_receivers ).
  CALL METHOD cl_mmim_userdefaults=>flush_all.

ENDMETHOD.
************************************************************************
* Insert a line into the trace
************************************************************************
METHOD add_line.
  DATA: l_lines TYPE i,
        l_line  TYPE ty_trace_line.
  CHECK NOT poref_textedit IS INITIAL.
  CONCATENATE sy-uzeit ':' INTO l_line.
  CONCATENATE l_line i_data1 i_data2 INTO l_line SEPARATED BY space.
  APPEND l_line TO pt_trace.
  IF i_late_update = abap_false.
    CALL METHOD poref_textedit->set_text_as_r3table
      EXPORTING table = pt_trace.
    DESCRIBE TABLE pt_trace LINES l_lines.
    CALL METHOD poref_textedit->go_to_line
      EXPORTING line = l_lines.
  ENDIF.
ENDMETHOD.
************************************************************************
* Handler for the CLOSE event of the dialog box
************************************************************************
METHOD close_handler.
  CALL METHOD trace_visibility_set
    EXPORTING
      i_visibility = abap_false.
ENDMETHOD.

ENDCLASS.