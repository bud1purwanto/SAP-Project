*----------------------------------------------------------------------*
*   INCLUDE LMIGOKG2                                                   *
*----------------------------------------------------------------------*
* METHOD GOODS_MOVEMENT_ERROR_HANDLING
*          IMPORTING
*            is_emkpf   TYPE ty_s_emkpf
*            et_emseg   TYPE ty_t_emseg,
*----------------------------------------------------------------------*
METHOD goods_movement_error_handling.
  DATA: ls_emseg        TYPE emseg,
        ls_goitem       TYPE ty_s_goitem,
        l_rc            TYPE subrc.
* Error at header level------------------------------------------------
  IF NOT is_emkpf-msgno IS INITIAL.
*   add message without line context to log
    CALL METHOD oref_log->context_set.
    CALL METHOD oref_log->message_add
      EXPORTING
        i_msgty = is_emkpf-msgty
        i_msgid = is_emkpf-msgid
        i_msgno = is_emkpf-msgno
        i_msgv1 = is_emkpf-msgv1
        i_msgv2 = is_emkpf-msgv2
        i_msgv3 = is_emkpf-msgv3
        i_msgv4 = is_emkpf-msgv4.
  ENDIF.

* Error at item level--------------------------------------------------
  LOOP AT it_emseg INTO ls_emseg.
*   in case of a component of a structured article access tables with
*   parent_id because global_counter is initial and the messages are
*   only displayed on the header.
    IF ls_emseg-kzbwa = 'SZ'.                 "explosion struct. art.
      READ TABLE pt_goitem INTO ls_goitem
                 WITH KEY global_counter = ls_emseg-parent_id.
      l_rc = sy-subrc.
    ELSE.
      READ TABLE pt_goitem INTO ls_goitem
                 WITH KEY global_counter = ls_emseg-global_counter.
      l_rc = sy-subrc.
    ENDIF.
    CHECK l_rc IS INITIAL.
*   Errors: create messages with the right context
    IF NOT ls_emseg-msgno IS INITIAL.
*     structured article set context to header
      IF ls_goitem-xsttype = c.
        CALL METHOD oref_log->context_set
          EXPORTING
            i_global_counter = ls_goitem-parent.
      ELSE.
        CALL METHOD oref_log->context_set
          EXPORTING
            i_global_counter = ls_goitem-global_counter.
      ENDIF.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = ls_emseg-msgty
          i_msgid = ls_emseg-msgid
          i_msgno = ls_emseg-msgno
          i_msgv1 = ls_emseg-msgv1
          i_msgv2 = ls_emseg-msgv2
          i_msgv3 = ls_emseg-msgv3
          i_msgv4 = ls_emseg-msgv4.
    ENDIF.
  ENDLOOP.
ENDMETHOD.                             "GOODS_MOVEMENT_ERROR_HANDLING