*----------------------------------------------------------------------*
*   INCLUDE LMIGOTV3                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Sort tableview
************************************************************************
METHOD tableview_sort.
  DATA: ls_column TYPE lcl_migo_screenmodification=>ty_s_column,
        l_selected_column_name(100),
        l_field TYPE c.

ENHANCEMENT-SECTION     LMIGOTV3_01 SPOTS ES_SAPLMIGO.
  READ TABLE tv_goitem-cols INTO ls_column
                  WITH KEY selected = x.
END-ENHANCEMENT-SECTION.
  IF sy-subrc IS INITIAL.
    l_selected_column_name = ls_column.
  ELSE.
    IF lcl_migo_cursor=>oref_screenobject = me AND
       lcl_migo_cursor=>stepl > 0.
      l_selected_column_name = lcl_migo_cursor=>field.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.
  IF NOT l_selected_column_name IS INITIAL.
    SHIFT l_selected_column_name UP TO '-'.
    SHIFT l_selected_column_name LEFT DELETING LEADING '-'.
    CALL METHOD lcl_migo_globals=>kernel->table_sort
         EXPORTING
           i_column_name = l_selected_column_name
           i_sort_up     = i_sort_up.
  ENDIF.
ENDMETHOD.

************************************************************************
* Search in tableview.
* The method uses TV_GOITEM-COLS to analyze the current look of the
* table control on screen. The INVISIBLE indicates that the
* column is invisible ( 1 = deactivated by us, X = deactivated by
* the administrator functionality). INDEX is the position currently
* on screen. It can differ from the SY-TABIX of the entry in
* TV_GOITEM-COLS if the column order has been changed by the user.
************************************************************************
METHOD tableview_search.                                         "213353
  DATA:
    l_search_string TYPE migo_search_string,
    l_current_line  TYPE sytabix,
    l_current_index TYPE sytabix,
    l_found         TYPE abap_bool,
    l_selected      TYPE abap_bool,
    l_viewer        TYPE lcl_migo_screenobject=>ty_name,
    ls_column       TYPE lcl_migo_screenmodification=>ty_s_column,
    ls_goitem       TYPE goitem,
    ls_x031l        TYPE x031l,
    lt_x031l        TYPE STANDARD TABLE OF x031l,
    l_fieldname     TYPE migo_fieldname,
    l_refname       TYPE migo_fieldname,
    l_stepl         TYPE systepl,
    lt_split        TYPE STANDARD TABLE OF migo_fieldname,
    l_text(50)      TYPE c.
  FIELD-SYMBOLS:
    <l_field>       TYPE ANY,
    <l_ref>         TYPE ANY.

* Prepare search string and exit if empty
  l_search_string = godynpro-search_string.
  SHIFT l_search_string LEFT DELETING LEADING space.
  CHECK NOT l_search_string IS INITIAL.

* Read nametab of GOITEM. Needed to find out reference fields
* for quantities and currencies.
  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      tabname           = 'GOITEM'
    TABLES
      x031l_tab         = lt_x031l.
  SORT lt_x031l BY fieldname.

* Determine the starting point for the search process.
* The case that the cursor is outside the dynpro (e.g.
* om the tree) is also covered here.
  IF i_search_next = abap_false OR
     lcl_migo_cursor=>oref_screenobject IS INITIAL.
*   Search from start
    l_current_line  = 1.
    l_current_index = 0.
  ELSE.
*   Search from current cursor position
    CALL METHOD
         lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
      IMPORTING
        e_name  = l_viewer
        e_tabix = l_current_line.
    IF l_viewer <> 'TABLEVIEW' OR l_current_line = 0.
*     Not found in table control --> start from beginning
      l_current_line  = 1.
      l_current_index = 0.
    ELSE.
*     Get the index in the table control for the current fieldname
ENHANCEMENT-SECTION     LMIGOTV3_02 SPOTS ES_SAPLMIGO.
      READ TABLE tv_goitem-cols INTO ls_column
                 WITH KEY screen-name = lcl_migo_cursor=>field.
END-ENHANCEMENT-SECTION.
      l_current_index = ls_column-index.
    ENDIF.
  ENDIF.

* If columns in the TC have been selected, we restict the
* search to these. Otherwise, the entire TC is searched.
ENHANCEMENT-SECTION     LMIGOTV3_03 SPOTS ES_SAPLMIGO.
  READ TABLE tv_goitem-cols
             WITH KEY selected = x
             TRANSPORTING NO FIELDS.
END-ENHANCEMENT-SECTION.
  IF sy-subrc = 0.
    l_selected = abap_true.
  ENDIF.

* Loop over the lines of the model, beginning in the current line
  l_found = abap_false.
  DO.
*   Leave the line-loop after the last line of the model
    IF l_current_line > lcl_migo_globals=>kernel->s_status-lines.
      EXIT.
    ENDIF.
*   Get the current line
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING i_line = l_current_line
      IMPORTING es_goitem = ls_goitem.
*   Loop over the fields in the table control, beginning but excluding
*   the current field
    DO.
      l_current_index = l_current_index + 1.
ENHANCEMENT-SECTION     LMIGOTV3_04 SPOTS ES_SAPLMIGO.
      READ TABLE tv_goitem-cols INTO ls_column
                 WITH KEY INDEX = l_current_index.
END-ENHANCEMENT-SECTION.
*     If the index was not found, the end of the row has been reached.
*     Terminate the field-loop and start with the next line.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
*     If the entire column is invisible, or at least one column
*     has been selected but not this one, go to the next cell.
      IF NOT (
               ls_column-invisible = '0' OR
               ls_column-invisible IS INITIAL
             )
         OR
             (
               l_selected = abap_true AND
               ls_column-selected IS INITIAL
             ).
        CONTINUE.
      ENDIF.
*     If the column is there, but in this line the cell is
*     invislbe, go to the next one, because even if there are
*     data transported to the screen, these are deleted
*     and the cursor cannot be set into the field.
*     This condition can easily be checked in 4.6C, but in
*     4.6B we may need a SUPPRESS DIALOG and to check whether
*     the CURSOR_SET has been successful.
      l_fieldname = ls_column-screen-name.
      IF lcl_migo_screenmodification=>get(
            i_global_counter = ls_goitem-global_counter
            i_field          = l_fieldname )
           = lcl_migo_screenmodification=>c_invisible.
        CONTINUE.
      ENDIF.
*     At this point, we have found a visible field.
*     Get tablename and fieldname out of SCREEN-NAME
      SPLIT ls_column-screen-name AT '-' INTO TABLE lt_split.
*     If the tablename is not GOITEM, this field cannot be handled as
*     it is not present in GOITEM (manually added fields in the TC).
      READ TABLE lt_split INTO l_fieldname INDEX 1.
      IF sy-subrc <> 0 OR l_fieldname <> 'GOITEM'.
        CONTINUE.
      ENDIF.
*     Get the fieldname. If problems --> skip.
      READ TABLE lt_split INTO l_fieldname INDEX 2.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
*     Access DDIC-data for this field
      READ TABLE lt_x031l INTO ls_x031l
                 WITH KEY fieldname = l_fieldname
                 BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
*     Fieldnames in LS_GOITEM
      CONCATENATE 'LS_GOITEM-' ls_x031l-fieldname INTO l_fieldname.
      ASSIGN (l_fieldname) TO <l_field>.
*     If the reference field for QUAN/CURR is not in GOITEM,
*     so not work with it.
      IF ls_x031l-reftable <> 'GOITEM'.
        CLEAR ls_x031l-dtyp.
      ENDIF.
      CONCATENATE 'LS_GOITEM-' ls_x031l-reffield  INTO l_refname.
      ASSIGN (l_refname)   TO <l_ref>.
*     Create external representation
      CASE ls_x031l-dtyp.
        WHEN 'QUAN'. WRITE <l_field> UNIT     <l_ref> TO l_text.
        WHEN 'CURR'. WRITE <l_field> CURRENCY <l_ref> TO l_text.
        WHEN OTHERS. WRITE <l_field>                  TO l_text.
      ENDCASE.
*     If the search string is contained, set the return parameters and
*     exit the loop finally.
      IF l_text CS l_search_string.
        l_found = abap_true.
        EXIT.
      ENDIF.
    ENDDO.
*   If string found, terminate also the line-loop.
    IF l_found = abap_true.
      EXIT.
    ENDIF.
*   Continue for the next line in the model.
    l_current_line  = l_current_line + 1.
    l_current_index = 0.
  ENDDO.

* If the search was not successful, issue message.
* Otherwise, ensure that the found line is visible
* and set the cursor.
  IF l_found = abap_true.
    CALL METHOD tableview_line_show( l_current_line ).
    l_fieldname = ls_column-screen-name.
ENHANCEMENT-SECTION     LMIGOTV3_05 SPOTS ES_SAPLMIGO.
    l_stepl     = l_current_line - tv_goitem-top_line + 1.
END-ENHANCEMENT-SECTION.
    CALL METHOD lcl_migo_cursor=>cursor_set
      EXPORTING
        i_oref_screenobject = me
        i_field             = l_fieldname
        i_stepl             = l_stepl.
  ELSE.
    MESSAGE s020.
  ENDIF.

ENDMETHOD.                                                       "213353

************************************************************************
* Clear all lines in tableview without ok = X.
************************************************************************
METHOD tableview_delete_not_ok.
  CALL METHOD lcl_migo_globals=>kernel->table_delete_not_ok.
ENDMETHOD.

************************************************************************
* Return line in model for the current cursor position
************************************************************************
METHOD cursor_position_resolve.
  e_name  = 'TABLEVIEW'.
ENHANCEMENT-SECTION     LMIGOTV3_06 SPOTS ES_SAPLMIGO.
  e_tabix = lcl_migo_cursor=>stepl + tv_goitem-top_line - 1.
END-ENHANCEMENT-SECTION.
* Special case: Cursor within TABLEVIEW-Object, but outside the table
*               (search field): return TABIX = 0.
  IF lcl_migo_cursor=>stepl = 0.
    e_tabix = 0.
  ENDIF.
ENDMETHOD.

************************************************************************
* Ensure that the requested line (I_LINE) is visible in the table
* control. If already visible, nothing to do. Otherwise, scroll
* in the proper direction.
************************************************************************
METHOD tableview_line_show.                                      "213353
  DATA: l_first_line TYPE sytabix,
        l_last_line  TYPE sytabix.
ENHANCEMENT-SECTION     LMIGOTV3_07 SPOTS ES_SAPLMIGO.
* Lines which are currently visible
  l_first_line = tv_goitem-top_line.
  l_last_line  = tv_goitem-top_line + p_displayed_lines - 1.
* If first and last line are in wrong order, p_displayed_lines is
* not correctly set yet. This happens during the INITIALIZATION-phase,
* if the system does not know the TC-size.
  CHECK l_first_line <= l_last_line.
* Exit if requested line already visible
  IF i_line >= l_first_line AND
     i_line <= l_last_line.
    EXIT.
  ENDIF.
* Requested line if before the first line --> scroll upwards
  IF i_line < l_first_line.
    tv_goitem-top_line = i_line.
  ENDIF.
* Requested line is below the last line --> scroll so that the
* requested line is the last line.
  IF i_line > l_last_line.
    tv_goitem-top_line = i_line - p_displayed_lines + 1.
  ENDIF.
END-ENHANCEMENT-SECTION.
ENDMETHOD.                                                       "213353
************************************************************************
* Valuecopy.
* Evaluation the current cursor position (fieldame, line)
* and copy the value in the field to all lines in the model
* below the current line.
************************************************************************
METHOD valuecopy.
  DATA: l_sourceline     TYPE sytabix,
        l_targetline     TYPE sytabix,
        ls_source_goitem TYPE goitem,
        ls_target_goitem TYPE goitem,
        l_field          TYPE scrfname,
        l_field_source   TYPE scrfname,
        l_field_target   TYPE scrfname,
        l_status         TYPE migo_fs_status,
        l_checkfield     TYPE migo_fieldname.
  FIELD-SYMBOLS: <l_value_source> TYPE ANY,
                 <l_value_target> TYPE ANY.
ENHANCEMENT-POINT VALUE_COPY_01 SPOTS ES_SAPLMIGO STATIC.
* Tip
  def_sms 'MIGO_TIP_REQUEST' 'HELP_OK_TAKE_VALUE' space.
* Works only if the cursor is in the tableview
  IF lcl_migo_cursor=>oref_screenobject <> me OR
     lcl_migo_cursor=>stepl = 0.
    MESSAGE s021(migo).
    EXIT.
  ENDIF.
* Get fieldname and TABIX
  CALL METHOD
    lcl_migo_cursor=>oref_screenobject->cursor_position_resolve
      IMPORTING
        e_tabix = l_sourceline.
* Read sourceline from model
  CALL METHOD lcl_migo_globals=>kernel->line_get
    EXPORTING i_line    = l_sourceline
    IMPORTING es_goitem = ls_source_goitem.
*   Special logic for generic articles and its variants
    IF ls_source_goitem-xgatype = P.
      EXIT.
    ENDIF.
* Get reference to the value according to the fieldname
* Some fields need special tratment. These are the ones with
* intelligent long text input fields. In this case, the check
* for input-readyness operates on the long text, but copied are
* the SAP keyfields. LINE_CHECK will then derive the correct
* new long text.
  l_field      = lcl_migo_cursor=>field.
  CHECK l_field CS '-'.        "data fields only                "1444288
  l_checkfield = l_field.
  CASE l_field.
    WHEN 'GOITEM-MAKTX'.           l_field = 'GOITEM-MATNR'.
    WHEN 'GOITEM-NAME1'.           l_field = 'GOITEM-WERKS'.
    WHEN 'GOITEM-LGOBE'.           l_field = 'GOITEM-LGORT'.
    WHEN 'GOITEM-VENDORNAME'.      l_field = 'GOITEM-LIFNR'.
    WHEN 'GOITEM-CUSTNAME'.        l_field = 'GOITEM-KUNNR'.
    WHEN 'GOITEM-MAT_VENDORNAME'.  l_field = 'GOITEM-MAT_LIFNR'. "633827
    WHEN 'GOITEM-MAT_CUSTNAME'.    l_field = 'GOITEM-MAT_KUNNR'. "633827
* begin of note 576915
    WHEN 'GOITEM-UMMAKTX'.          l_field = 'GOITEM-UMMAT'.
    WHEN 'GOITEM-UMNAME1'.          l_field = 'GOITEM-UMWRK'.
    WHEN 'GOITEM-UMLGOBE'.          l_field = 'GOITEM-UMLGO'.
    WHEN 'GOITEM-UMMAT_VENDORNAME'. l_field = 'GOITEM-UMMAT_LIFNR'.
    WHEN 'GOITEM-UMMAT_CUSTNAME'.   l_field = 'GOITEM-UMMAT_KUNNR'.
* end of note 576915
  ENDCASE.
  CONCATENATE 'LS_SOURCE_' l_field INTO l_field_source.
  CONCATENATE 'LS_TARGET_' l_field INTO l_field_target.
  ASSIGN (l_field_source) TO <l_value_source>.
* Process all following lines
  l_targetline = l_sourceline.
  DO.
    l_targetline = l_targetline + 1.
*   Terminate the loop if all lines have been processed
    IF l_targetline > lcl_migo_globals=>kernel->s_status-lines.
      EXIT.
    ENDIF.
*   Get the targetline
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING i_line    = l_targetline
      IMPORTING es_goitem = ls_target_goitem.
*   Not for generic articles and its variants
    CHECK ls_target_goitem-xgatype IS INITIAL.
*   Check the input-readyness of the field in the target line.
*   Valuecopy only works if the field is open.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING i_global_counter = ls_target_goitem-global_counter
                i_field          = l_checkfield
      RECEIVING r_status         = l_status.
    CHECK l_status >= lcl_migo_screenmodification=>c_input.
*   Overwrite the selected field with the new value
    ASSIGN (l_field_target) TO <l_value_target>.
    <l_value_target> = <l_value_source>.
ENHANCEMENT-POINT VALUE_COPY_02 SPOTS ES_SAPLMIGO.
*   Update the model
    CALL METHOD lcl_migo_globals=>kernel->line_modify
      EXPORTING i_line            = l_targetline
                i_authority_check = abap_false
                i_status_delayed  = abap_true
      CHANGING  cs_goitem         = ls_target_goitem.
  ENDDO.
* Derive new status
  CALL METHOD lcl_migo_globals=>kernel->status_derive.
ENDMETHOD.