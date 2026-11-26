*----------------------------------------------------------------------*
*   INCLUDE LMIGOFR1                                                   *
*----------------------------------------------------------------------*

CLASS lcl_migo_frame DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_migo_frame.
    CLASS-DATA:
      trace_visible   TYPE abap_bool READ-ONLY,
      trace_okcodes   TYPE abap_bool READ-ONLY,
      trace_messages  TYPE abap_bool READ-ONLY,
      trace_receivers TYPE abap_bool READ-ONLY,
      trace_infos     TYPE abap_bool READ-ONLY.
    CLASS-METHODS:
      class_constructor,
*     Register a viewer in the framework and return a pointer to kernel.
      viewer_register
        IMPORTING
          i_iref_viewer  TYPE REF TO lif_migo_frame
          it_okcodes     TYPE lif_migo_frame~ty_t_okcodes     OPTIONAL
          it_receiving   TYPE lif_migo_frame~ty_t_message_ids OPTIONAL
          it_sending     TYPE lif_migo_frame~ty_t_message_ids OPTIONAL,
*     The dispatcher. To be called at the end of the main carrier.
      okcode_dispatch
        IMPORTING
          i_okcode      TYPE lif_migo_frame~ty_okcode,
*     Sending a message.
      message_send
        IMPORTING
          i_message_id     TYPE lif_migo_frame~ty_message_id
          i_iref_sender    TYPE REF TO lif_migo_frame        OPTIONAL
          is_message       TYPE lif_migo_frame~ty_s_message  OPTIONAL
          i_delayed        TYPE abap_bool DEFAULT abap_false
          i_system_message TYPE abap_bool DEFAULT abap_false
        EXPORTING
          et_answers       TYPE lif_migo_frame~ty_t_answers,
      message_send_simple
        IMPORTING
          i_message_id  TYPE lif_migo_frame~ty_message_id
          i_iref_sender TYPE REF TO lif_migo_frame
          i_data1       TYPE any OPTIONAL            "allows simple cast
          i_data2       TYPE any OPTIONAL
          i_delayed     TYPE abap_bool OPTIONAL,
*     Stop processing messages and buffer them internally
      queue_messages,
*     Execute the buffered messages and continue normally
      process_messages,
*     Request whether a given class id is registered
      viewer_exist
        IMPORTING
          i_class_id TYPE lif_migo_frame~ty_class_id
        RETURNING
          value(r_exists) TYPE abap_bool,
*     Tracer functions
      trace_visibility_set
        IMPORTING
          i_visibility  TYPE abap_bool
          i_constructor TYPE abap_bool DEFAULT abap_false,
      add_line
        IMPORTING
          i_data1       TYPE any
          i_data2       TYPE any
          i_late_update TYPE abap_bool DEFAULT abap_false.
  PRIVATE SECTION.
    TYPES:
*     OK-codes
      BEGIN OF pty_s_registered_okcode,
        okcode    TYPE lif_migo_frame~ty_okcode,
        component TYPE REF TO lif_migo_frame,
      END OF pty_s_registered_okcode,
*     Messages
      BEGIN OF pty_s_registered_message,
        message_id TYPE lif_migo_frame~ty_message_id,
        component TYPE REF TO lif_migo_frame,
      END OF pty_s_registered_message,
*     The message queue for deleyed mode
      BEGIN OF pty_s_message_queue,
        message_id TYPE lif_migo_frame~ty_message_id,
        sender     TYPE REF TO lif_migo_frame,
        message    TYPE lif_migo_frame~ty_s_message,
      END OF pty_s_message_queue,
*     Line for the trace window
      ty_trace_line(150) TYPE c.
    CLASS-DATA:
*     Tables with information which viewer wants to see which events.
      pt_registered_okcodes  TYPE SORTED TABLE
                             OF pty_s_registered_okcode
                             WITH NON-UNIQUE KEY okcode,
      pt_registered_messages TYPE SORTED TABLE
                             OF pty_s_registered_message
                             WITH NON-UNIQUE KEY message_id,
      pt_registered_senders  TYPE HASHED TABLE
                             OF pty_s_registered_message
                             WITH UNIQUE KEY message_id component,
      p_queue_mode TYPE abap_bool,
      pt_message_queue TYPE TABLE OF pty_s_message_queue,
      pt_registered_viewers TYPE HASHED TABLE
                            OF lif_migo_frame~ty_class_id
                            WITH UNIQUE DEFAULT KEY,
*     Data for the TRACE-functionality
      poref_settings      TYPE REF TO cl_mmim_userdefaults,
      poref_amodal_window TYPE REF TO cl_gui_dialogbox_container,
      poref_splitter      TYPE REF TO cl_gui_splitter_container,
      poref_top           TYPE REF TO cl_gui_container,
      poref_bottom        TYPE REF TO cl_gui_container,
      poref_toolbar       TYPE REF TO cl_gui_toolbar,
      poref_textedit      TYPE REF TO cl_gui_textedit,
      pt_trace            TYPE STANDARD TABLE OF ty_trace_line.
    CLASS-METHODS:
      toolbar_handler FOR EVENT function_selected OF cl_gui_toolbar
        IMPORTING
          fcode,
      close_handler                                              "491163
        FOR EVENT close OF cl_gui_dialogbox_container,           "491163
      crossreference_dump.
ENDCLASS.

************************************************************************
* Definition to make sending a message easier
************************************************************************
DEFINE def_sms.
  call method lcl_migo_frame=>message_send_simple
    exporting
      i_message_id  = &1
      i_iref_sender = me
      i_data1       = &2
      i_data2       = &3.
END-OF-DEFINITION.

************************************************************************
* Sending an info to the trace
************************************************************************
DEFINE def_info.
  if lcl_migo_frame=>trace_infos = abap_true.
    call method lcl_migo_frame=>add_line( i_data1 = &1
                                          i_data2 = &2 ).
  endif.
END-OF-DEFINITION.