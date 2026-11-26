*----------------------------------------------------------------------*
*   INCLUDE LMIGOLO1                                                   *
*----------------------------------------------------------------------*
*   Application log definition
*----------------------------------------------------------------------*
CLASS lcl_migo_log DEFINITION.
*----------------------------------------------------------------------*
* PUBLIC SECTION
*----------------------------------------------------------------------*
  PUBLIC SECTION.

*----------------------------------------------------------------------*
* Public types
*----------------------------------------------------------------------*
    TYPES:
    ty_t_goitem  TYPE STANDARD TABLE OF goitem.                 "ERP2005


    CLASS-METHODS:
*     Creates log authorization if we are the first one (master)
      class_constructor.
    METHODS:
*     Set item as context
      context_set
        IMPORTING
          i_global_counter TYPE migo_global_counter OPTIONAL
          i_fieldname      TYPE migo_fieldname      OPTIONAL,
*     Display messages, either by global counter or all
      display
        IMPORTING i_item           TYPE abap_bool DEFAULT abap_false
                  i_global_counter TYPE migo_global_counter OPTIONAL,
*     Add a message to the log
      message_add
              IMPORTING i_msgty TYPE  sy-msgty
                        i_msgid TYPE  sy-msgid
                        i_msgno TYPE  any "emseg-msgno
                        i_msgv1 TYPE  any OPTIONAL
                        i_msgv2 TYPE  any OPTIONAL
                        i_msgv3 TYPE  any OPTIONAL
                        i_msgv4 TYPE  any OPTIONAL,
*     Delete messages related to one item from the log           ERP2005
      messages_delete_for_item
              IMPORTING i_global_counter  TYPE migo_global_counter,
*     Delete messages related to items that have not             ERP2005
*     been selected (goitem-take_it is initial) from the log
      messages_delete_unselected
              IMPORTING i_pt_goitem     TYPE ty_t_goitem,
*     Transfer messages for selected items (goitem-take_it is set)
*     to target log                                              ERP2005
      messages_transfer_selected
              IMPORTING  i_target_log    TYPE REF TO lcl_migo_log
                         i_pt_goitem     TYPE ty_t_goitem,
*     Check if an item has some messages in the log
      message_exist_single
        IMPORTING i_global_counter  TYPE migo_global_counter OPTIONAL
        EXPORTING e_loglevel        TYPE migo_loglevel
                  es_msg            TYPE bal_s_msg,
*     Check if there are messages in the log
      message_exist_all
              IMPORTING i_error_only     TYPE abap_bool OPTIONAL
              RETURNING value(r_exist)   TYPE abap_bool,
*     Refresh old log date before posting and create a new log
      refresh,
*     Set context data for mick and mb_create
      send_data_to_mick,
*     Callback routine from display popup
      callback
        CHANGING cs_data TYPE bal_s_cbuc.

*-----------------------------------------------end of public section--*
* PRIVATE SECTION
*----------------------------------------------------------------------*
  PRIVATE SECTION.
    DATA: p_log_handle           TYPE balloghndl, "Log handle
          ps_mdef                TYPE bal_s_mdef, "Defaults
*         see comments in messages_transfer_selected & _delete_selected
          p_messages_transferred TYPE abap_bool.
    CLASS-DATA:
          p_log_auth             TYPE balauth.    "Authorization
ENDCLASS.


************************************************************************
* Useful definitions for adding messages
************************************************************************
DEFINE def_msg_add.
  call method &1->message_add
    exporting
      i_msgty = &2
      i_msgid = &3
      i_msgno = &4
      i_msgv1 = &5
      i_msgv2 = &6
      i_msgv3 = &7
      i_msgv4 = &8.
END-OF-DEFINITION.