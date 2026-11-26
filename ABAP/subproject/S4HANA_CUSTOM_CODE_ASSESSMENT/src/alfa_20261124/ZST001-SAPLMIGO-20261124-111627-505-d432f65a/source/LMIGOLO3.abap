*----------------------------------------------------------------------*
*   INCLUDE LMIGOLO3                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Display the log, either by position or complete
************************************************************************
METHOD display.
  DATA: ls_display_profile TYPE bal_s_prof,
        lt_logh            TYPE bal_t_logh,
        lt_filter_display  TYPE bal_t_cfil,
        lt_filter_search   TYPE bal_t_cfil,
        ls_filter          TYPE bal_s_cfil,
        ls_context         TYPE bal_rfield,
        ls_fcat            TYPE bal_s_fcat,
        ls_mess_sort       TYPE bal_s_sort.                 "445421

* Leave if no log active
  CHECK NOT p_log_handle IS INITIAL.
* Reset class context (old item number)
  CLEAR ps_mdef-context-value.

*   -------------------------------------------------------------------
*   Please do not delete: this is an example of log display
*   with tree qla list of message: display message text in lenght 60
*     l_fcat-ref_table = 'BAL_S_SHOW'.
*     l_fcat-ref_field = 'T_MSG'.
*     l_fcat-outputlen = 60.
*     APPEND l_fcat TO l_display_profile-mess_fcat.
*   Tree should contain item number for level 1
*     CLEAR l_fcat.
*     l_fcat-ref_table = 'MIGOCONTEXT'.
*     l_fcat-cltxt_add = x.
*     l_fcat-ref_field = 'ZEILE'.
*     APPEND l_fcat TO l_display_profile-lev1_fcat.
*   -------------------------------------------------------------------

* Get default profile for popup style
  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile.
* Append field ZEILE to give the user a recognizable criterium
  ls_fcat-ref_table = 'GOITEM'.
  ls_fcat-ref_field = 'ZEILE'.
  ls_fcat-is_extern = x.
  APPEND ls_fcat TO ls_display_profile-mess_fcat.
* Increase the width and depth a little bit.
* The depth will be adapted automatically to a useful scale.
  ADD 3  TO ls_display_profile-end_col.
  ADD 10 TO ls_display_profile-end_row.
* Show all messages
  ls_display_profile-show_all = x.
* Set current log
  APPEND p_log_handle TO lt_logh.
* If ITEM-display requested, create a filter for the selected GLC
  IF i_item = abap_true.
    CLEAR: ls_context, ls_filter.
    ls_filter-tabname   = 'MIGOCONTEXT'.
    ls_filter-fieldname = 'GLOBAL_COUNTER'.
    ls_context-sign     = 'I'.
    ls_context-option   = 'EQ'.
    ls_context-low      = i_global_counter.
    APPEND ls_context TO ls_filter-t_range.
    INSERT ls_filter INTO TABLE lt_filter_display.
  ENDIF.

* If there are contexts with filled FIELDNAME, we can try to
* position the cursor on them. For this functionality, the BAL-popup
* needs an additional button.
  lt_filter_search = lt_filter_display.
  CLEAR: ls_context, ls_filter.
  ls_filter-tabname   = 'MIGOCONTEXT'.
  ls_filter-fieldname = 'FIELDNAME'.
  ls_context-sign     = 'I'.
  ls_context-option   = 'NE'.
  ls_context-low      = space.
  APPEND ls_context TO ls_filter-t_range.
  INSERT ls_filter INTO TABLE lt_filter_search.
* Check whether there are such messages
  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
    EXPORTING
      i_t_log_handle         = lt_logh
      i_t_msg_context_filter = lt_filter_search
    EXCEPTIONS
      msg_not_found          = 1
      OTHERS                 = 2.
  IF sy-subrc = 0.
    ls_display_profile-ext_push1-active        = x.
    ls_display_profile-ext_push1-def-text      = text-011. "Process
    ls_display_profile-ext_push1-def-icon_text = text-011.
    ls_display_profile-ext_push1-def-icon_id   = '@0Z@'.
    ls_display_profile-clbk_ucom-userexitp     = 'SAPLMIGO'.
    ls_display_profile-clbk_ucom-userexitf     = 'BAL_CALLBACK'.
    ls_display_profile-clbk_ucbf-userexitp     = 'SAPLMIGO'.
    ls_display_profile-clbk_ucbf-userexitf     = 'BAL_CALLBACK'.
  ENDIF.
* Callback function to read ZEILE for GLOBAL_COUNTER (and maybe more)
  ls_display_profile-clbk_read-userexitp     = 'SAPLMIGO'.
  ls_display_profile-clbk_read-userexitf     = 'BAL_CALLBACK_READ'.
* Allow changed layout to be saved                            "n1068539
  ls_display_profile-disvariant-report       =  SY-REPID.     "n1068539
  ls_display_profile-disvariant-handle       =  'LOG'.        "n1068539
* begin of note 445421 for sort by GOITEM-ZEILE
  ls_mess_sort-ref_table = 'GOITEM'.
  ls_mess_sort-ref_field = 'ZEILE'.
  ls_mess_sort-spos      = '01'.
  ls_mess_sort-up        = x.
  APPEND ls_mess_sort TO ls_display_profile-mess_sort.
* end of note 445421
* Display log
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_t_msg_context_filter = lt_filter_display
      i_t_log_handle         = lt_logh
      i_s_display_profile    = ls_display_profile
    EXCEPTIONS
      OTHERS                 = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDMETHOD.                             "DISPLAY_ALL

*----------------------------------------------------------------------*
* METHOD MESSAGE_EXIST_SINGLE
*----------------------------------------------------------------------*
* Checks if there are any messages for an item or header
*       IMPORTING i_global_counter  type migo_global_counter
*       RETURNING value(r_loglevel) type migo_loglevel
*----------------------------------------------------------------------*
METHOD message_exist_single.
  DATA: ls_lfil               TYPE  bal_s_lfil, "Log handle filter
        lr_logh               TYPE  bal_s_logh, "Ranges for log handle
        lt_cfil               TYPE  bal_t_cfil, "Context filter table
        ls_cfil               TYPE  bal_s_cfil, "Context filter
        ls_context            TYPE  bal_rfield, "Context data
        lt_msg_handle         TYPE  bal_t_msgh, "Message handles table
        l_msg_handle          TYPE  balmsghndl, "Message handle
        ls_msg                TYPE  bal_s_msg,  "Message data
        lt_logh               TYPE  bal_t_logh, "Current log
        l_text                TYPE  char100,    "Complete message
        l_length              TYPE i.
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
* Fill current log
  APPEND p_log_handle TO lt_logh.
*
  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
       EXPORTING
            i_s_log_filter         = ls_lfil   "Filter for item
*           I_T_LOG_CONTEXT_FILTER =
            i_t_log_handle         = lt_logh   "Current log
*           I_S_MSG_FILTER         =
            i_t_msg_context_filter = lt_cfil
*           I_T_MSG_HANDLE         =
       IMPORTING
*           E_T_log_handle         =
            e_t_msg_handle         = lt_msg_handle
       EXCEPTIONS
            msg_not_found          = 1
            OTHERS                 = 2
            .
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
* Default loglevel = nothing
  CLEAR e_loglevel.
  CLEAR es_msg.
* No message found
  CHECK sy-subrc = 0.
* Read messages to determine loglevel (warning/error)
  LOOP AT lt_msg_handle INTO l_msg_handle.
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = l_msg_handle
      IMPORTING
        e_s_msg        = ls_msg
      EXCEPTIONS
        OTHERS         = 1.
    CHECK sy-subrc = 0.
*   Set loglevel
    IF ls_msg-msgty = w AND e_loglevel NE icon_red_light.
      e_loglevel = icon_yellow_light.
    ELSEIF ls_msg-msgty = e OR ls_msg-msgty = a.
      e_loglevel = icon_red_light.
    ENDIF.
*   Extract highest loglevel. Three step hierarchy:
*   E or A kill everything
*   W kills only W and below,
*   all others only if no E, A, W.
    IF ( ls_msg-msgty = e OR ls_msg-msgty = a )               OR
       ( ls_msg-msgty = w AND NOT ( es_msg-msgty = e OR
                                    es_msg-msgty = a ) )      OR
        NOT ( es_msg-msgty = e OR es_msg-msgty = a OR
              es_msg-msgty = w ).
      es_msg = ls_msg.
      CASE ls_msg-msgty.
        WHEN e OR a. e_loglevel = icon_red_light.
        WHEN w     . e_loglevel = icon_yellow_light.
        WHEN OTHERS. e_loglevel = icon_green_light.
      ENDCASE.
    ENDIF.
  ENDLOOP.
* Insert the complete message text as quickinfo.
* The length of the field is 50 characters (domain TEXT50 to
* have lower case letters).
  IF e_loglevel <> space.
    MESSAGE ID es_msg-msgid TYPE es_msg-msgty NUMBER es_msg-msgno
            WITH es_msg-msgv1 es_msg-msgv2 es_msg-msgv3 es_msg-msgv4
            INTO l_text.
    l_length = STRLEN( l_text ).
    IF l_length > 42.
      l_text+41(3) = '...'.                                 "#EC NOTEXT
    ENDIF.
    CONCATENATE e_loglevel(3) '\Q' l_text(44) '@' INTO e_loglevel.
  ENDIF.
ENDMETHOD.                             "MESSAGE_EXIST_SINGLE

*----------------------------------------------------------------------*
* METHOD MESSAGE_EXIST_ALL
*----------------------------------------------------------------------*
* Checks if there are any messages in log (all items).
* If I_ERROR_ONLY is set, R_EXIST ignores warnings.
*----------------------------------------------------------------------*
METHOD message_exist_all.
  DATA: lt_logh TYPE  bal_t_logh,
        ls_filter TYPE bal_s_mfil,
        lr_msgty  TYPE bal_r_msty,
        ls_msgty  TYPE bal_s_msty.
  CLEAR r_exist.

* Set current log
  APPEND p_log_handle TO lt_logh.

* Search for errors only (if requested)
  IF i_error_only = abap_true.
    ls_msgty-sign   = 'I'.
    ls_msgty-option = 'EQ'.
    ls_msgty-low    = 'E'.
    APPEND ls_msgty TO lr_msgty.
    ls_msgty-low    = 'A'.
    APPEND ls_msgty TO lr_msgty.
    ls_msgty-low    = 'X'.
    APPEND ls_msgty TO lr_msgty.
    ls_filter-msgty = lr_msgty.
  ENDIF.

  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
       EXPORTING
*              i_s_log_filter         =
*              I_T_LOG_CONTEXT_FILTER =
               i_t_log_handle         = lt_logh  "Current log
               i_s_msg_filter         = ls_filter
*              I_T_MSG_CONTEXT_FILTER =
*              I_T_MSG_HANDLE         =
*         IMPORTING
*              E_T_log_handle         =
*              E_T_MSG_HANDLE         =
       EXCEPTIONS
            msg_not_found          = 1
            OTHERS                 = 2
            .
  IF sy-subrc <> 1.
    r_exist = abap_true.
  ENDIF.

ENDMETHOD.                             "MESSAGE_EXIST_ALL