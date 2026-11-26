*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_FCODE_ALLOW                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CUA_FCODE_ALLOW
*&---------------------------------------------------------------------*
*       CUA_EXCLUDE must be sorted
*----------------------------------------------------------------------*
form cua_fcode_allow using if_fcode  type fcode
                           if_action type c.

  data: lf_fcode_nd    type fcode,
        ls_cua_exclude type shp_cua_exclude.

  case if_action.

    when yes.                          "allow fcode
      if if_fcode ns '_T' and
        ( t180-bldgr eq gc_new_dialog_outb or
          t180-bldgr eq gc_new_dialog_inb ).
        concatenate if_fcode '_T' into lf_fcode_nd.
        delete cua_exclude where function eq if_fcode
                              or function eq lf_fcode_nd.
      else.
        delete cua_exclude where function eq if_fcode.
      endif.

    when no.                           "forbidd fcode
      read table cua_exclude with table key function = if_fcode
                             transporting no fields.
      if sy-subrc ne 0.
        ls_cua_exclude-function = if_fcode.
        insert ls_cua_exclude into table cua_exclude.
      endif.
      if if_fcode ns '_T' and
        ( t180-bldgr eq gc_new_dialog_outb
          or t180-bldgr eq gc_new_dialog_inb ).
        concatenate if_fcode '_T' into lf_fcode_nd.
        read table cua_exclude with table key function = lf_fcode_nd
                               transporting no fields.
        if sy-subrc ne 0.
          ls_cua_exclude-function = lf_fcode_nd.
          insert ls_cua_exclude into table cua_exclude.
        endif.
      endif.

  endcase.

endform.                               " CUA_FCODE_ALLOW