*----------------------------------------------------------------------*
*   INCLUDE LMIGOTV4                                                   *
*----------------------------------------------------------------------*

************************************************************************
* PBO module before start of LOOP.
************************************************************************
  METHOD pbo.
    CALL METHOD super->pbo.
ENHANCEMENT-SECTION     LMIGOTV4_02 SPOTS ES_SAPLMIGO.
    tv_goitem-lines = lcl_migo_globals=>kernel->s_status-lines.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT LMIGOTV4_06 SPOTS ES_SAPLMIGO.
  ENDMETHOD.

************************************************************************
* PBO module within LOOP: Get data from kernel and transfer them to
* the screen.
************************************************************************
  METHOD pbo_loop.
*  Output only as many lines as there are in the modes.
*  Exception: NEW_LINE_MODE is set and the detail is closed.
ENHANCEMENT-SECTION     LMIGOTV4_03 SPOTS ES_SAPLMIGO.
   IF tv_goitem-current_line > lcl_migo_globals=>kernel->s_status-lines
     AND ( lcl_migo_globals=>kernel->s_control-new_line_mode = space OR
           p_itemdetail_visible = abap_true ).
      EXIT FROM STEP-LOOP.
    ENDIF.
*   The this line from the kernel
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING
        i_line = tv_goitem-current_line
      IMPORTING
        es_goitem = goitem.
*   Field modification on row level.
    CALL METHOD field_selection_line.
*   This data can only be found here
    p_displayed_lines = sy-loopc.
END-ENHANCEMENT-SECTION.
  ENDMETHOD.


ENHANCEMENT-POINT LMIGOTV4_01 SPOTS ES_SAPLMIGO STATIC.
************************************************************************
* Field modification for a single line of the tableview
************************************************************************
  METHOD field_selection_line.
    DATA: l_glc TYPE migo_global_counter.
ENHANCEMENT-POINT LMIGOTV4_07 SPOTS ES_SAPLMIGO STATIC .

*   If GOITEM-GLOBAL_COUNTER already assigned, read the corresponding
*   field selection. Otherwise, use the template.
    l_glc = goitem-global_counter.
    IF l_glc IS INITIAL.
      l_glc = lcl_migo_screenmodification=>c_item_template.
    ENDIF.
*   Screen modification
    CALL METHOD lcl_migo_screenmodification=>main
      EXPORTING i_global_counter = l_glc.
*   General disabling when line also in detail.
ENHANCEMENT-SECTION     LMIGOTV4_04 SPOTS ES_SAPLMIGO.
    IF p_itemdetail_visible = abap_true AND
       p_itemdetail_line    = tv_goitem-current_line.
      LOOP AT SCREEN.
        screen-input       = c_mod_off.
        screen-intensified = c_mod_on.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT LMIGOTV4_05 SPOTS ES_SAPLMIGO.
  ENDMETHOD.