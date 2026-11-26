*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_TEXT_PAI
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  check_text_key
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form check_text_key.

  data: ls_t002 type t002,
        ls_text type tgs_text_v45a.

  check: gs_text_v45a-spras is not initial or
         gs_text_v45a-id is not initial or
         gs_text_v45a-first_tline is not initial or
         gs_text_v45a-text_string is not initial.

  if gs_text_v45a-spras is initial.
    message e005(vx).
  endif.

  select single *
         from t002
         into ls_t002
         where spras = gs_text_v45a-spras.
  if sy-subrc <> 0.
    message e002(vx) with gs_text_v45a-spras.
  endif.

  if gs_text_v45a-id is initial.
    message e007.
  endif.

  read table xthead
       with key tdobject = tvcom-tdobject
                tdname = gv_tdname_v45a
                tdid = gs_text_v45a-id
                tdspras = space.
  if sy-subrc <> 0.
    message e020(vx) with gs_text_v45a-id tvcom-tdobject.
  endif.
  if gs_text_v45a-object is initial.
    read table gt_text_v45a
         into ls_text
         with key object = tvcom-tdobject
                  name = gv_tdname_v45a
                  id = gs_text_v45a-id
                  spras = gs_text_v45a-spras.
    if sy-subrc = 0.
      message e008 with ls_text-id_t ls_text-spras_t.
    endif.
  endif.

endform.                    "check_text_key


*&---------------------------------------------------------------------*
*&      Form  set_text_string_by_first_tline
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_text_string_by_first_tline.

  gs_text_v45a-text_string = gs_text_v45a-first_tline.

endform.                    "set_text_string_by_first_tline


*&---------------------------------------------------------------------*
*&      Form  set_first_tline_by_text_string
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form set_first_tline_by_text_string.

  data: lv_remaining_string type string.

  if gs_text_v45a-text_string is initial.
    clear gs_text_v45a-first_tline.
  else.
    find cl_abap_char_utilities=>newline in gs_text_v45a-text_string.
    if sy-subrc = 0.
      split gs_text_v45a-text_string
            at cl_abap_char_utilities=>newline
            into gs_text_v45a-first_tline lv_remaining_string.
    else.
      gs_text_v45a-first_tline = gs_text_v45a-text_string.
    endif.
  endif.

endform.                    "set_first_tline_by_text_string


*&---------------------------------------------------------------------*
*&      Form  text_maintain_string
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form text_maintain_string.

  data: ls_xthead type theadvb,
        ls_msg type balmi,
        lf_dataloss type xfeld.

  if gs_text_v45a-text_string is initial.
    loop at xthead into ls_xthead
                   where tdobject eq tvcom-tdobject
                     and tdname   eq gv_tdname_v45a
                     and tdid     eq gs_text_v45a-id
                     and tdspras  eq gs_text_v45a-spras
                     and updkz    ne chard.
      exit.
    endloop.
    if sy-subrc = 0 and
       not ls_xthead-txpfl is initial.
      loop at xthead into ls_xthead
                     where tdobject eq tvcom-tdobject
                       and tdname   eq gv_tdname_v45a
                       and tdid     eq gs_text_v45a-id
                       and tdspras  ne gs_text_v45a-spras
                       and tdspras  ne space
                       and updkz    ne chard.
        exit.
      endloop.
      if sy-subrc <> 0.
        message e203(vx).
      endif.
    endif.
  endif.

* Texts of format type DOC/RTF cannot be created, changed or
* deleted by simply interfacing a text string
  read table xthead
       into ls_xthead
       with key tdobject = tvcom-tdobject
                tdname   = gv_tdname_v45a
                tdid     = gs_text_v45a-id
                tdspras  = space.
  if     sy-subrc             is initial and
     not ls_xthead-tdtexttype is initial.
*   We deal with a format not equal SPACE (= SCR)
    message w090(sls_lord) with gs_text_v45a-id ls_xthead-tdtexttype.
    move-corresponding sy to ls_msg.
    call function 'APPL_LOG_WRITE_SINGLE_MESSAGE'
      exporting
        object  = 'LORD'
        message = ls_msg.
    return.
  endif.

  if not gs_text_v45a-id is initial and
     not gs_text_v45a-spras is initial.
    call function 'SD_TEXT_SET_STRING'
      exporting
        iv_id          = gs_text_v45a-id
        iv_spras       = gs_text_v45a-spras
        iv_text_string = gs_text_v45a-text_string
      importing
        ef_changed     = lf_dataloss
        et_xvbuv       = xvbuv[]
      changing
        ct_xthead      = xthead[]
      exceptions
        others         = 1.
    if lf_dataloss eq charx.
      r185d-dataloss = charx.
    endif.
  endif.

endform.                    " text_maintain_string


*&---------------------------------------------------------------------*
*&      Form  text_maintain_xstring
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form text_maintain_xstring.

  data: ls_xthead type theadvb,
        ls_msg type balmi,
        lf_dataloss type xfeld.

  if gs_text_v45a-text_xstring is initial.
    loop at xthead into ls_xthead
                   where tdobject eq tvcom-tdobject
                     and tdname   eq gv_tdname_v45a
                     and tdid     eq gs_text_v45a-id
                     and tdspras  eq gs_text_v45a-spras
                     and updkz    ne chard.
      exit.
    endloop.
    if     sy-subrc        eq 0       and
       not ls_xthead-txpfl is initial.
      loop at xthead into ls_xthead
                     where tdobject eq tvcom-tdobject
                       and tdname   eq gv_tdname_v45a
                       and tdid     eq gs_text_v45a-id
                       and tdspras  ne gs_text_v45a-spras
                       and tdspras  ne space
                       and updkz    ne chard.
        exit.
      endloop.
      if sy-subrc <> 0.
        message e203(vx).
      endif.
    endif.
  endif.

* Texts of format type SPACE (=SCR) cannot be created, changed or
* deleted by simply interfacing a text xstring
  read table xthead
       into ls_xthead
       with key tdobject = tvcom-tdobject
                tdname   = gv_tdname_v45a
                tdid     = gs_text_v45a-id
                tdspras  = space.
  if sy-subrc             is initial and
     ls_xthead-tdtexttype is initial.
*   We deal with a format not equal DOC or RTF
    message w091(sls_lord) with gs_text_v45a-id.
    move-corresponding sy to ls_msg.
    call function 'APPL_LOG_WRITE_SINGLE_MESSAGE'
      exporting
        object  = 'LORD'
        message = ls_msg.
    return.
  endif.

  call function 'SD_TEXT_SET_XSTRING'
    exporting
      iv_id           = gs_text_v45a-id
      iv_spras        = gs_text_v45a-spras
      iv_handle       = gs_text_v45a-handle
      iv_text_xstring = gs_text_v45a-text_xstring
    importing
      ef_changed      = lf_dataloss
      et_xvbuv        = xvbuv[]
    changing
      ct_xthead       = xthead[]
    exceptions
      others          = 1.

  if lf_dataloss eq charx.
    r185d-dataloss = charx.
  endif.

endform.                    " text_maintain_xstring


*&---------------------------------------------------------------------*
*&      Form  text_delete_by_key
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_ID      text
*      -->UV_SPRAS   text
*----------------------------------------------------------------------*
form text_delete_by_key using uv_id
                              uv_spras.

  local: gs_text_v45a.

  data: ls_text type tgs_text_v45a,
        lt_text type tgt_text_v45a,
        ls_xthead type theadvb,
        lv_message type balmi,
        lv_subrc type sy-subrc,
        lf_dataloss type xfeld.

  field-symbols:
        <ls_text> type tgs_text_v45a.

  lt_text = gt_text_v45a.
  loop at gt_text_v45a into gs_text_v45a.
    check gs_text_v45a-id eq uv_id and
          gs_text_v45a-spras eq uv_spras.
    read table xthead into ls_xthead index gs_text_v45a-tabix.
    if sy-subrc <> 0.
      message a205(vx).
    endif.
    if ls_xthead-txpfl eq 'X' or
       ls_xthead-txpfl eq 'Z'.
      loop at lt_text into ls_text
                      where object = gs_text_v45a-object
                        and name = gs_text_v45a-name
                        and id = gs_text_v45a-id
                        and spras ne gs_text_v45a-spras.
        exit.
      endloop.
      if sy-subrc <> 0.
        message i203(vx).
        move-corresponding sy to lv_message.
        call function 'APPL_LOG_WRITE_SINGLE_MESSAGE'
          exporting
            object  = 'LORD'
            message = lv_message.
        exit.
      endif.
    endif.
    clear gs_text_v45a-text_string.
    call function 'SD_TEXT_SET_STRING'
      exporting
        iv_id          = gs_text_v45a-id
        iv_spras       = gs_text_v45a-spras
        iv_text_string = gs_text_v45a-text_string
      importing
        ef_changed     = lf_dataloss
        et_xvbuv       = xvbuv[]
      changing
        ct_xthead      = xthead[]
      exceptions
        others         = 1.
    if lf_dataloss eq charx.
      r185d-dataloss = charx.
    endif.
    delete gt_text_v45a.
    exit.
  endloop.

endform.                    "text_delete_by_key