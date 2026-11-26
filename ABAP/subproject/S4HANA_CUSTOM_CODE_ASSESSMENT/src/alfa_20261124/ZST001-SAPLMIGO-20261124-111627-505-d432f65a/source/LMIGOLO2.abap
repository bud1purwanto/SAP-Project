*----------------------------------------------------------------------*
*   INCLUDE LMIGOLO2                                                   *
*----------------------------------------------------------------------*
*   Application log implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_log IMPLEMENTATION.
* Further methods
  INCLUDE lmigolo3.                    "Display, read log
  INCLUDE lmigolo4.              "Communication with MICK and MB_CREATE
*----------------------------------------------------------------------*
*   METHOD CLASS_CONSTRUCTOR
*----------------------------------------------------------------------*
* Gets an authorization for MIGO to prevent refresh from other
* application. The application log can only have one authorization.
*----------------------------------------------------------------------*
  METHOD class_constructor.
    CALL FUNCTION 'BAL_GLB_AUTHORIZATION_GET'
      IMPORTING
        e_authorization            = p_log_auth
      EXCEPTIONS
        authorization_already_done = 0
        OTHERS                     = 0.
* No message if already done as it prevents a global refresh as well
  ENDMETHOD.                           "CLASS_CONSTRUCTOR

*----------------------------------------------------------------------*
*   METHOD CONSTRUCTOR                                                *
*----------------------------------------------------------------------*
* Constructor has nothing to do because log handle is created
* in refresh method (called before posting/check)
* If application log offers one day the possibility to refresh a log
* (delete all messages) without deleting the log, it will be possible
* to create a log handle at constructor time and delete messages before
* MB_CREATE.
*----------------------------------------------------------------------*
* METHOD constructor.
* ENDMETHOD.                           "CONSTRUCTOR

*----------------------------------------------------------------------*
*   METHOD REFRESH
*----------------------------------------------------------------------*
* Close a log with all messages and create a new log handle
* Set MIGOCONTEXT as context table and reset ApplLog defaults
*----------------------------------------------------------------------*
  METHOD refresh.
    DATA: ls_log  TYPE bal_s_log,      "Log header
          ls_mdef_empty TYPE bal_s_mdef.     "Defaults (used to clear)
* Delete the old log handle if already created--------------------------
    IF NOT p_log_handle IS INITIAL.
      CALL FUNCTION 'BAL_LOG_DELETE'
        EXPORTING
          i_log_handle  = p_log_handle
        EXCEPTIONS
          log_not_found = 0
          OTHERS        = 0.
* Reset class context
      CLEAR ps_mdef.
      p_messages_transferred = abap_false.
    ENDIF.

* Now create a new log-------------------------------------------------*
    ls_log-extnumber       = sy-title.
    ls_log-alprog          = c_repid.
    ls_log-context-tabname = 'MIGOCONTEXT'.
* Create log and get handle
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = p_log_handle
      EXCEPTIONS
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Set global data in class memory
    ps_mdef-log_handle      = p_log_handle.
    ps_mdef-context-tabname = 'MIGOCONTEXT'.

* If we are the master(authorization belongs to us), reset defaults
* in Application Log memory as we do not want messages from other
* applications called by us
    IF NOT p_log_auth IS INITIAL.
      CALL FUNCTION 'BAL_GLB_MSG_DEFAULTS_SET'
        EXPORTING
          i_authorization  = p_log_auth
          i_s_msg_defaults = ls_mdef_empty
        EXCEPTIONS
          not_authorized   = 0
          OTHERS           = 0.
    ENDIF.
  ENDMETHOD.                           "REFRESH

*----------------------------------------------------------------------*
*   METHOD MESSAGE_ADD
*----------------------------------------------------------------------*
* Inserts a message to the log
*----------------------------------------------------------------------*
  METHOD message_add.
    DATA: ls_msg   TYPE bal_s_msg,
          l_dummy(72).

    CHECK NOT ps_mdef-log_handle IS INITIAL.

* set message variables in SY-fields to convert in output format
    MESSAGE ID i_msgid TYPE i_msgty NUMBER i_msgno
            WITH i_msgv1 i_msgv2 i_msgv3 i_msgv4
            INTO l_dummy.
    ls_msg-msgty = sy-msgty.
    ls_msg-msgid = sy-msgid.
    ls_msg-msgno = sy-msgno.
    ls_msg-msgv1 = sy-msgv1.
    ls_msg-msgv2 = sy-msgv2.
    ls_msg-msgv3 = sy-msgv3.
    ls_msg-msgv4 = sy-msgv4.
    ls_msg-probclass = '1'.

* set default context and parameters from class context
    ls_msg-context = ps_mdef-context.
    ls_msg-params  = ps_mdef-params.

* add message to log
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
         EXPORTING
              i_log_handle      = p_log_handle
              i_s_msg           = ls_msg
*        IMPORTING
*             E_S_MSG_HANDLE      =
*             E_MSG_WAS_LOGGED    =
*             E_MSG_WAS_DISPLAYED =
         EXCEPTIONS
              log_not_found       = 1
              msg_inconsistent    = 2
              OTHERS              = 3
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.                           "MESSAGE_ADD

*----------------------------------------------------------------------*
* METHOD messages_delete_for_item                                ERP2005
*----------------------------------------------------------------------*
* Delete all messages referring to a given item from the log
* This method has been implemented for the use with the oref_badi_log
*----------------------------------------------------------------------*
  METHOD messages_delete_for_item.

    DATA: lt_logh       TYPE  bal_t_logh,  "Current log
          ls_lfil       TYPE  bal_s_lfil,  "Log handle filter
          lr_logh       TYPE  bal_s_logh,  "Ranges for log handle
          ls_context    TYPE  bal_rfield,  "Context data
          lt_msg_handle TYPE  bal_t_msgh,  "Message handles table
          ls_msg_handle TYPE  balmsghndl,  "Message handle
          lt_cfil       TYPE  bal_t_cfil,  "Context filter table
          ls_cfil       TYPE  bal_s_cfil,  "Context filter
          ls_s_msg      TYPE  bal_s_msg.   "Message data

* This flag is being used to enable the displaying of messages that are being
* added only once via BAdI MB_MIGO_ITEM_BADI during the reading of a
* reference document, i.e. the information that the storage location has been
* changed in the badi out of a certain reason
    CHECK p_messages_transferred = abap_true.

* Fill log handle
    lr_logh-option    = 'EQ'.
    lr_logh-sign      = i.
    lr_logh-low       = p_log_handle.
    APPEND lr_logh TO ls_lfil-log_handle.
* Fill global_counter as context filter
    ls_context-option = 'EQ'.
    ls_context-sign   = i.
    ls_context-low    = i_global_counter.
    APPEND ls_context TO ls_cfil-t_range.
* Fill context table and field for filter
    ls_cfil-tabname   = 'MIGOCONTEXT'.
    ls_cfil-fieldname = 'GLOBAL_COUNTER'.
    APPEND ls_cfil TO lt_cfil.
* Set current log
    APPEND p_log_handle TO lt_logh.

* get all messages for the selected item
    CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
     EXPORTING
       i_s_log_filter               = ls_lfil
*      I_T_LOG_CONTEXT_FILTER       =
       i_t_log_handle               = lt_logh
*      I_S_MSG_FILTER               =
       i_t_msg_context_filter       = lt_cfil
*      I_T_MSG_HANDLE               =
     IMPORTING
*      E_T_LOG_HANDLE               =
       e_t_msg_handle               = lt_msg_handle
     EXCEPTIONS
       msg_not_found                = 1
       OTHERS                       = 2
              .
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.

    CHECK sy-subrc = 0.

    LOOP AT lt_msg_handle INTO ls_msg_handle.
*   delete the message.
      CALL FUNCTION 'BAL_LOG_MSG_DELETE'
        EXPORTING
          i_s_msg_handle = ls_msg_handle
        EXCEPTIONS
          msg_not_found  = 1
          log_not_found  = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
    ENDLOOP.

  ENDMETHOD. "messages_delete_for_item.

*----------------------------------------------------------------------*
* METHOD MESSAGES_DELETE_UNSELECTED                              ERP2005
*----------------------------------------------------------------------*
* Delete messages related to all unselected items
* (goitem-take_it is initial)
* This method has been implemented for the use with the oref_badi_log
*----------------------------------------------------------------------*
  METHOD  messages_delete_unselected.

    FIELD-SYMBOLS: <ls_goitem> TYPE goitem.

    LOOP AT i_pt_goitem ASSIGNING <ls_goitem>
                        WHERE take_it = abap_false.

      CALL METHOD oref_badi_log->messages_delete_for_item
        EXPORTING
          i_global_counter = <ls_goitem>-global_counter.

    ENDLOOP.

  ENDMETHOD. " messages_delete_unselected

*----------------------------------------------------------------------*
* METHOD MESSAGES_TRANSFER_SELECTED                              ERP2005
*----------------------------------------------------------------------*
* Transfer messages for selected items (goitem-take_it is set)
* to target log
* This method has been implemented for the use with the oref_badi_log
*----------------------------------------------------------------------*
  METHOD  messages_transfer_selected.

    DATA: lt_logh       TYPE  bal_t_logh,          "Current log
          lt_msg_handle TYPE  bal_t_msgh,          "Message handles table
          ls_msg_handle TYPE  balmsghndl,          "Message handle
          ls_s_msg      TYPE  bal_s_msg,           "Message data
          l_counter     TYPE  migo_global_counter, "goitem-global_counter
          ls_goitem     TYPE  goitem.

* Set current log
    APPEND p_log_handle TO lt_logh.

* Get all message handles
    CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
      EXPORTING
*       i_s_log_filter         =
*       I_T_LOG_CONTEXT_FILTER =
        i_t_log_handle         = lt_logh  "Current log
*       i_s_msg_filter         =
*       I_T_MSG_CONTEXT_FILTER =
*       I_T_MSG_HANDLE         =
      IMPORTING
*       E_T_log_handle         =
        e_t_msg_handle         = lt_msg_handle
      EXCEPTIONS
        msg_not_found          = 1
        OTHERS                 = 2.

    IF sy-subrc = 1.
      sy-subrc = sy-subrc.
    ELSEIF sy-subrc <> 1.
*   Get all messages and add those that are related to selected items
*   to the target log
      LOOP AT lt_msg_handle INTO ls_msg_handle.

        CALL FUNCTION 'BAL_LOG_MSG_READ'
          EXPORTING
            i_s_msg_handle                 = ls_msg_handle
            i_langu                        = sy-langu
          IMPORTING
            e_s_msg                        = ls_s_msg
*           e_exists_on_db                 =
*           e_txt_msgty                    =
*           e_txt_msgid                    =
*           e_txt_detlevel                 =
*           e_txt_probclass                =
*           e_txt_msg                      =
*           e_warning_text_not_found       =
         EXCEPTIONS
            log_not_found                  = 1
            msg_not_found                  = 2
            OTHERS                         = 3.

        IF sy-subrc <> 0.
          sy-subrc = sy-subrc.
        ENDIF.

        CHECK sy-subrc = 0.

        LOOP AT i_pt_goitem TRANSPORTING NO FIELDS
                            WHERE global_counter = ls_s_msg-context-value
                              AND take_it = abap_true.
*         Conversion
          l_counter = ls_s_msg-context-value.

          CALL METHOD i_target_log->context_set
            EXPORTING
              i_global_counter = l_counter.

          CALL METHOD i_target_log->message_add
            EXPORTING
              i_msgty = ls_s_msg-msgty
              i_msgid = ls_s_msg-msgid
              i_msgno = ls_s_msg-msgno
              i_msgv1 = ls_s_msg-msgv1
              i_msgv2 = ls_s_msg-msgv2
              i_msgv3 = ls_s_msg-msgv3
              i_msgv4 = ls_s_msg-msgv4.

        ENDLOOP. "at i_pt_goitem

      ENDLOOP. "at lt_msg_handle


    ENDIF.

*   This flag is being used to enable the displaying of messages that are being
*   added only once via BAdI MB_MIGO_ITEM_BADI during the reading of a reference
*   document. It is being checked in message_delete_selected and reset in the refresh
*   method.
    p_messages_transferred = abap_true.

  ENDMETHOD.  "messages_transfer_selected

*----------------------------------------------------------------------*
*   METHOD CONTEXT_SET
*----------------------------------------------------------------------*
*   IMPORTING i_context TYPE  migocontext
*   Set context information such as global_counter in class memory
*----------------------------------------------------------------------*
  METHOD context_set.
    DATA: ls_context TYPE migocontext.
    CHECK NOT ps_mdef-log_handle IS INITIAL.
    ls_context-global_counter = i_global_counter.
    ls_context-fieldname      = i_fieldname.
    ps_mdef-context-value = ls_context.
  ENDMETHOD.                           "CONTEXT_SET

************************************************************************
* Button to position the cursor has been pressed
************************************************************************
  METHOD callback.
    DATA: ls_msg     TYPE bal_s_msg,
          ls_context TYPE migocontext,
          ls_message TYPE lif_migo_frame=>ty_s_message.
* Exit for function codes we do not know
    CHECK cs_data-ucomm = '%EXT_PUSH1' OR
          cs_data-ucomm = '&IC1'.                            "double click
* Read the message which is underneath the cursor position
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = cs_data-list_msgh
      IMPORTING
        e_s_msg        = ls_msg
      EXCEPTIONS
        log_not_found  = 1
        msg_not_found  = 2
        OTHERS         = 3.
    CHECK sy-subrc = 0.
* Unpack CONTEXT-data
    CHECK ls_msg-context-tabname = 'MIGOCONTEXT'.
    ls_context = ls_msg-context-value.
    CHECK NOT ls_context-fieldname IS INITIAL.
* If this was the double click and something was found,
* remap function code, otherwise exit.
* So: Double click on dead line
    IF cs_data-ucomm = '&IC1'.
      cs_data-ucomm = '%EXT_PUSH1'.
      EXIT.
    ENDIF.
* Send tip tat says what we can and what we can't.
* System message because the LOG does not register
* at the framework regularily.
    CLEAR ls_message.
    ls_message-data1 = 'HELP_ERR_POS_CURSOR'.
    CALL METHOD lcl_migo_frame=>message_send
      EXPORTING
        i_message_id     = 'MIGO_TIP_REQUEST'
        is_message       = ls_message
        i_system_message = abap_true.
* Send message
    CLEAR ls_message.
    ls_message-data1 = ls_context-global_counter.
    ls_message-data2 = ls_context-fieldname.
    CALL METHOD lcl_migo_frame=>message_send
      EXPORTING
        i_message_id     = 'SET_CURSOR_POSITION'
        is_message       = ls_message
        i_system_message = abap_true.
* Terminate LOG-display
    cs_data-exit = 'X'.
  ENDMETHOD.                    "callback

ENDCLASS.                    "lcl_migo_log IMPLEMENTATION

************************************************************************
* This routine is called if the pushbutton to position the cursor
* is pressed.
************************************************************************
FORM bal_callback CHANGING
                  c_s_user_command_data TYPE bal_s_cbuc.    "#EC CALLED
  CALL METHOD oref_log->callback
    CHANGING
      cs_data = c_s_user_command_data.
ENDFORM.                    "bal_callback

************************************************************************
* Callback to read data depending on context data
************************************************************************
FORM bal_callback_read
       USING
         i_s_info            TYPE bal_s_cbrd                "#EC NEEDED
       CHANGING
         c_display_data      TYPE bal_s_show                "#EC NEEDED
         c_context_header    TYPE bal_s_cont                "#EC NEEDED
         c_context_message   TYPE bal_s_cont
         c_field             TYPE any.                      "#EC CALLED
  DATA: ls_context TYPE migocontext,
        l_zeile    TYPE mblpo.
* Unpack context
  CHECK c_context_message-tabname = 'MIGOCONTEXT'.
  ls_context = c_context_message-value.
* Global counter not initial: Access model to get ZEILE
  IF NOT ls_context-global_counter IS INITIAL.
    CALL METHOD lcl_migo_globals=>kernel->line_mapping
      EXPORTING
        i_global_counter = ls_context-global_counter
      IMPORTING
        e_zeile          = l_zeile
      EXCEPTIONS
        OTHERS           = 1.
    CHECK sy-subrc = 0.
    c_field = l_zeile.
  ENDIF.
ENDFORM.                    "bal_callback_read