*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CURSOR_SETZEN                                     *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CURSOR_SETZEN
*&---------------------------------------------------------------------*
*       Cursor is placed depending on the situation
*----------------------------------------------------------------------*
* The placement of the cursor is controlled by the global structure
* GS_SET_CURSOR
*
* There are two possibilities to place the cursor
* 1.) Default
*     If the screen changes the cursor is placed on a suitable field
*     on the new screen (or the cursor structure is initialized and the
*     cursor is placed elsewhere)
*     If the screen is not changed then it is assumed that the cursor
*     position is to be controlled by the user. It is therefore not
*     overridden and the new cursor position is the same as the old
*     cursor position
* 2.) Application wants to control the cursor position
*     In this case the application sets the flag set_by_appl to 'A'.
*     This causes the routine CURSOR_SETZEN to skip the placement of the
*     cursor. It only changes the flag to 'B' in order to indicate that
*     the PBO has been processed once (the cursor is placed during PBO)
*     If the flag is 'B' it is assumed that the cursor has been placed
*     during the last PBO. The flag is cleared and the default logic
*     (see above) is executed.
*

form cursor_setzen.

  data: lf_slips_lines type i.
  data: lf_line_counter like sy-loopc,
        lf_line1        like ilips_tabix_zeile_1,
        lf_cursor_tabix like sy-tabix,                      "n_583914
        lf_cursor_line  like sy-tabix,
        lf_items        like sy-tabix.

  lf_cursor_tabix = gf_cursor_tabix.                        "v_n_583914
  clear gf_cursor_tabix.                                    "^_n_583914

  if not ilips_tabix_zeile_1_set is initial.
    lf_line1 = ilips_tabix_zeile_1.
  else.
    if <tc> is assigned.
      lf_line1 = <tc>-top_line.
    else.
      lf_line1 = 1.
    endif.
  endif.

  if ( t180-bldgr eq gc_new_dialog_outb or
       t180-bldgr eq gc_new_dialog_inb ).

*   Cursor position is to be controlled by the application
    if gs_set_cursor-set_by_appl eq 'A'.
      gs_set_cursor-set_by_appl = 'B'.
      exit.
    endif.
    if gs_set_cursor-set_by_appl eq 'B'.
      clear gs_set_cursor.
    endif.

*   Depending on the processed dynpro place cursor on a suitable field
    if t185v-bldgr eq 'W0'.

      if kuwev-kunnr is initial.
        gs_set_cursor-fieldname = 'KUWEV-KUNNR'.
        gs_set_cursor-line = 0.
      else.
        if lf_cursor_tabix    ne 0 and                      "v_n_583914
           gs_get_cursor-line ne 0.
*         Calculate current screen line of the item that was changed by
*         last user interaction (line was maybe moved by scrolling
*         functions)
          read table ilips with key tabix = lf_cursor_tabix
                           transporting no fields.
          if sy-subrc eq 0.
            lf_cursor_line = sy-tabix - lf_line1 + 1.
            if lf_cursor_line gt 0 and
               lf_cursor_line le ilips_loopc.
              gs_set_cursor-line = lf_cursor_line.
              gs_set_cursor-fieldname = gs_get_cursor-fieldname.
              exit.
            endif.
          endif.
        endif.                                              "^_n_583914
        describe table ilips lines lf_items.
        lf_line_counter = lf_items - lf_line1 + 1.
        if lf_items eq 0.
          gs_set_cursor-fieldname = 'LIPS-MATNR'.
          gs_set_cursor-line = 1.
        elseif lf_line_counter ge ilips_loopc and
               ilips_loopc ne 0.
          gs_set_cursor-fieldname = 'LIPS-POSNR'.
          gs_set_cursor-line = 1.
        else.
          gs_set_cursor-fieldname = 'LIPS-MATNR'.
          gs_set_cursor-line = lf_line_counter + 1.
        endif.
      endif.

    elseif t185v-bldgr eq 'WI'.

      describe table ilips lines lf_items.
      lf_line_counter = lf_items - lf_line1 + 1.
      if lf_items eq 0.
        gs_set_cursor-fieldname = 'LIPS-MATNR'.
        gs_set_cursor-line = 1.
      elseif lf_line_counter ge ilips_loopc and
             ilips_loopc ne 0.
        gs_set_cursor-fieldname = 'LIPS-POSNR'.
        gs_set_cursor-line = 1.
      else.
        gs_set_cursor-fieldname = 'LIPS-MATNR'.
        gs_set_cursor-line = lf_line_counter + 1.
      endif.

    elseif t185v-bldgr(1) eq 'I'.

      case t185v-panel.
        when 'CHSP'.
          describe table ilips lines lf_items.
          lf_line_counter = lf_items - lf_line1.
          if lf_line1 gt 1.
            add 1 to lf_line_counter.
          endif.
          if lf_items eq 0.
            gs_set_cursor-fieldname = 'LIPS-MATNR'.
            gs_set_cursor-line = 1.
          elseif lf_line_counter ge ilips_loopc and
                 ilips_loopc ne 0.
            gs_set_cursor-fieldname = 'LIPS-POSNR'.
            gs_set_cursor-line = 1.
          else.
            gs_set_cursor-fieldname = 'LIPS-CHARG'.
            gs_set_cursor-line = lf_line_counter + 1.
          endif.
        when others.
          if *taxi_panel ne taxi_panel.
            clear gs_set_cursor.
          else.
            gs_set_cursor = gs_get_cursor.
          endif.
      endcase.

    elseif t185v-bldgr(1) eq 'H'.

      if *taxi_panel ne taxi_panel.
        clear gs_set_cursor.
      else.
        gs_set_cursor = gs_get_cursor.
      endif.
    endif.

  else.

    if sy-dynnr eq '0200' or
       sy-dynnr eq '0201' or
       sy-dynnr eq '0210' or
       sy-dynnr eq '0220' or
       sy-dynnr eq '0270'.
      if kuwev-kunnr is initial and likp-vbtyp na vbtyp_mmli.
        gs_set_cursor-fieldname = 'KUWEV-KUNNR'.
        gs_set_cursor-line = 0.
      else.
        describe table ilips lines lf_items.
        lf_line_counter = lf_items - lf_line1 + 1.
        if lf_items eq 0.
          gs_set_cursor-fieldname = 'LIPS-MATNR'.
          gs_set_cursor-line = 1.
        elseif lf_line_counter ge ilips_loopc and
               ilips_loopc ne 0.
          gs_set_cursor-fieldname = 'LIPS-POSNR'.
          gs_set_cursor-line = 1.
        else.
          gs_set_cursor-fieldname = 'LIPS-MATNR'.
          gs_set_cursor-line = lf_line_counter + 1.
        endif.
      endif.

    elseif sy-dynnr eq '0250'.

      describe table ilips lines lf_items.
      lf_line_counter = lf_items - lf_line1.
      if lf_line1 gt 1.
        add 1 to lf_line_counter.
      endif.
      if lf_items eq 0.
        gs_set_cursor-fieldname = 'LIPS-MATNR'.
        gs_set_cursor-line = 1.
      elseif lf_line_counter ge ilips_loopc and
             ilips_loopc ne 0.
        gs_set_cursor-fieldname = 'LIPS-POSNR'.
        gs_set_cursor-line = 1.
      else.
        gs_set_cursor-fieldname = 'LIPS-CHARG'.
        gs_set_cursor-line = lf_line_counter + 1.
      endif.
    endif.

    if gf_force_cursor_line_1 ne space.
      gs_set_cursor-fieldname = 'LIPS-POSNR'.
      gs_set_cursor-line = 1.
      clear gf_force_cursor_line_1.
    endif.
    if not gs_set_cursor-fieldname is initial and
       uc_process eq space.
      if gs_set_cursor-line ne 0.
        set cursor field gs_set_cursor-fieldname
                   line  gs_set_cursor-line.
      else.
        set cursor field gs_set_cursor-fieldname.
      endif.
    endif.

  endif.

endform.                               " CURSOR_SETZEN