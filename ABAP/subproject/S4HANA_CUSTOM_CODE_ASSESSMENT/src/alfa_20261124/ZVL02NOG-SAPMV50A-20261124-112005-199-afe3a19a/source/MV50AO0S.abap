*----------------------------------------------------------------------*
***INCLUDE MV50AO0S .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_DYNNR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_dynnr output.

  case likp-vbtyp.
    when vbtyp_liav.
      header_dynnr = '0223'.
    when vbtyp_lino.
      header_dynnr = '0222'.
    when vbtyp_lire.
      header_dynnr = '0222'.

  endcase.



endmodule.                             " SET_DYNNR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_POSITION  OUTPUT
*&---------------------------------------------------------------------*
module set_cursor_position output.

  if not gs_set_cursor-fieldname is initial.
    if gs_set_cursor-line ne 0.
      set cursor field gs_set_cursor-fieldname
                 line  gs_set_cursor-line.
    else.
      set cursor field gs_set_cursor-fieldname.
    endif.
  endif.

endmodule.                             " SET_CURSOR_POSITION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_POD_POSITION  OUTPUT
*&---------------------------------------------------------------------*
*       Cursor für POD Split screen
*----------------------------------------------------------------------*
module set_cursor_pod_position output.
  data: gf_step like sy-tabix.
  gs_set_cursor-fieldname = 'TVPODVB-GRUND'.

*  IF GF_ERROR_POD IS INITIAL.
  case t185v-panel.
    when 'PPOD'.
      case fcode.
        when gc_fcode_podenter.
          if not gf_error_pod is initial.
            gs_set_cursor-line = gs_get_cursor-line.
          else.
            gs_set_cursor-line = gs_get_cursor-line + 1.
          endif.
        when gc_fcode_podsplit.
          gs_set_cursor-line  = 1.

      endcase.
    when 'UPOD'.
      case fcode.
        when 'ENT2_T' or gc_fcode_podtake or gc_fcode_podoview.
          if not gf_error_pod is initial.
            gs_set_cursor-line = gs_get_cursor-line.
          else.
            gs_set_cursor-line = gs_get_cursor-line + 1.
            import gf_step from memory id 'GF_STEP'.
            if gf_step is initial.
              read table xvbuk with key vbeln = likp-vbeln.
              if sy-subrc eq 0.
                if xvbuk-pdstk ca 'AB' and xvbuk-fkstk ca 'BC'.
                  message i059(vla).
                endif.
              endif.
            endif.
          endif.
        when gc_fcode_podenter.
          gs_set_cursor-line  = 1.
      endcase.
      if fcode eq gc_fcode_podquit or
         fcode eq gc_fcode_podstor.
        fcode = gc_fcode_podenter.
      endif.
  endcase.

*  ELSE.
*    GS_SET_CURSOR-LINE   = 1.
*  ENDIF.

  set cursor field gs_set_cursor-fieldname
           line  gs_set_cursor-line.

endmodule.                             " SET_CURSOR_POD_POSITION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SUPPRESS_INITIALIZATION  OUTPUT
*&---------------------------------------------------------------------*
*       The global flag V50AGL-SUPPRESS_INIT is set. This causes the
*       document initialization in form TRANSAKTION_INIT to be skipped.
*----------------------------------------------------------------------*
module suppress_initialization output.

* Ensure that document is already refreshed
  if likp-mandt is initial.
    v50agl-suppress_init = charx.
  else.
    clear v50agl-suppress_init.
  endif.

endmodule.                             " SUPPRESS_INITIALIZATION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_4005  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_4005 output.

  set pf-status 'UNIVERSAL_ENTRY'.
  set titlebar 'UNIVERSAL_ENTRY'.
  get parameter id 'VLM' field gf_vbeln_inb.
  get parameter id 'VL' field gf_vbeln_outb.

endmodule.                             " STATUS_4005  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_DATA_TO_EHS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_data_to_ehs output.

  call function 'EHS003_SET_DATA_SD'
    exporting
      i_likp_vbtyp      = likp-vbtyp
      i_tvak_fehgr      = tvak-fehgr
      i_trtyp           = t180-trtyp
      i_shp_cursor      = gs_set_cursor-fieldname
      i_shp_cursor_line = gs_set_cursor-line
      i_posnr           = xlips-posnr
    tables
      i_xvbuvtab        = xvbuv
      i_dvbuvtab        = dvbuv
      i_hvbuvtab        = hvbuv
    exceptions
      others_           = 1.

endmodule.                 " SET_DATA_TO_EHS  OUTPUT

                                                             "v_n_780183
*&---------------------------------------------------------------------*
*&      Module  set_likp_from_parameter  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module set_likp_from_parameter output.

  check sy-binpt ne charx and sy-calld ne charx.               "n_988268
  get parameter id 'ALT' field likp-lfart.

endmodule.                 " set_likp_from_parameter  OUTPUT "^_n_780183