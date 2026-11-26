*----------------------------------------------------------------------*
*   INCLUDE LMIGOLO4                                                   *
*----------------------------------------------------------------------*
* Application log implementation: communication with MICK/MB_CREATE
*----------------------------------------------------------------------*
*   METHOD SEND_DATA_TO_MICK
*----------------------------------------------------------------------*
*   Send log_handle to MICK memory (used later by MB_CREATE)
*   MICK sets its global context itself.
*----------------------------------------------------------------------*
  METHOD send_data_to_mick.
    CALL FUNCTION 'MICK_LOG_LOCAL_HANDLE_SET'
         EXPORTING
              i_handle   = p_log_handle
              is_mdef    = ps_mdef
              i_log_auth = p_log_auth.
  ENDMETHOD.