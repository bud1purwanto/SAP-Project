***INCLUDE FV50XF0B_VERSANDTERMINE_BUCHEN .
*---------------------------------------------------------------------*
*       FORM VERSANDTERMINE_BUCHEN                                    *
*---------------------------------------------------------------------*
FORM versandtermine_buchen.

  DATA: l_handletab TYPE vltm_handletab WITH HEADER LINE.
  DATA: l_object TYPE tsegobjhdr VALUE 'WSHDRLIKP'.

  LOOP AT xlikp WHERE updkz <> updkz_old.
    l_handletab-head_hdl = xlikp-handle.
    APPEND l_handletab.
*   Save TSEG data                                            "v_n530998
    CALL FUNCTION 'TSEG_WRITE'
      EXPORTING
        if_object      = l_object
        is_object_wa   = xlikp
        if_update_task = 'X'
      EXCEPTIONS
        fatal_error    = 4
        OTHERS         = 8.
    IF sy-subrc IS INITIAL.
      xlikp-tsegfl = charx.
      MODIFY xlikp.
    ENDIF.                                                    "^_n530998
  ENDLOOP.
* Save application specific data
  CALL FUNCTION 'WS_DEADLINE_APPLDATA_WRITE'
    EXPORTING
      if_update_task = 'X'
    TABLES
      t_handle       = l_handletab
    EXCEPTIONS
      no_app_data    = 1
      OTHERS         = 2.
ENDFORM.                    "VERSANDTERMINE_BUCHEN