*----------------------------------------------------------------------*
*   INCLUDE LMIGOSP3                                                   *
*----------------------------------------------------------------------*

************************************************************************
* set cursor in tableview split-quantity
************************************************************************
METHOD cursor_set.
  DATA: l_lines TYPE systepl.

  DESCRIBE TABLE pt_gosplit LINES l_lines.
  CHECK NOT l_lines IS INITIAL.
  IF p_displayed_lines = lcl_migo_cursor=>stepl.
    tv_gosplit-top_line = l_lines.
    CALL METHOD lcl_migo_cursor=>cursor_set
      EXPORTING
        i_oref_screenobject = me
        i_field             = lcl_migo_cursor=>field
        i_stepl             = 2.
  ELSE.
    l_lines = lcl_migo_cursor=>stepl + 1.
    CALL METHOD lcl_migo_cursor=>cursor_set
      EXPORTING
        i_oref_screenobject = me
        i_field             = lcl_migo_cursor=>field
        i_stepl             = l_lines.
  ENDIF.
ENDMETHOD.                    "cursor_set

************************************************************************
* set status for popus split-quantity
************************************************************************
METHOD status_set.
  DATA: l_lines        TYPE sytabix,
        l_quantity(18) TYPE c,
        l_unit(3)      TYPE c.

* Convert internal representation to external for the titlebar "354046
  WRITE ps_goitem-erfmg UNIT ps_goitem-erfme TO l_quantity.
  WRITE ps_goitem-erfme TO l_unit.
  SET PF-STATUS 'SPLIT'.
  SET TITLEBAR 'GR_SPLIT' WITH l_quantity
                               l_unit
                               ps_goitem-zeile.
  DESCRIBE TABLE pt_gosplit LINES l_lines.
  tv_gosplit-lines = l_lines.
ENDMETHOD.                    "status_set

************************************************************************
* Call popup 'Split-quantity
************************************************************************
METHOD popup_call.

  DATA:
*   Cursor position in the main table control for restore
    l_field             TYPE migo_fieldname,
    l_stepl             TYPE systepl,
    l_oref_screenobject TYPE REF TO lcl_migo_screenobject,
*   Field mapping
    lt_fieldmapping TYPE STANDARD TABLE OF string,
    l_fieldname     TYPE string,
    l_tmp_fieldname TYPE migo_fieldname,
    l_status        TYPE migo_fs_status.

ENHANCEMENT-POINT POPUP_CALL_01 SPOTS ES_SAPLMIGO STATIC.
  CHECK p_selected_line <> 0.
  CALL METHOD lcl_migo_globals=>kernel->line_get
    EXPORTING
      i_line    = p_selected_line
    IMPORTING
      es_goitem = ps_goitem.
* Leave for lines which are not yet in the model (situation:
* GI-Others, enter one line, ENTER --> Split-function becomes
* active. Now place the cursor in an empty line and press
* "Split"...)
  CHECK NOT ps_goitem-global_counter IS INITIAL.
* Emergency exit for line items we do not want to split because we
* do not understand their nature; <LG>
  IF NOT ps_goitem-xvgtype IS INITIAL
      OR ps_goitem-xbomtype = p
      OR ps_goitem-kzbew    = o
      OR NOT ps_goitem-xgatype IS INITIAL
      OR NOT ps_goitem-xvastype IS INITIAL
      OR NOT ps_goitem-xcdtype IS INITIAL
      OR NOT ps_goitem-xsttype IS INITIAL.
    MESSAGE s039.
    EXIT.
  ENDIF.
* Tip
  def_sms 'MIGO_TIP_REQUEST' 'HELP_MIGO_DELETE_LINE' space.
* fill global fields (needed for dynpro 1000)
  g_split_maktx = ps_goitem-maktx.
  g_split_name1 = ps_goitem-name1.
  g_split_matnr = ps_goitem-matnr.
  g_split_werks = ps_goitem-werks.
  g_split_erfme = ps_goitem-erfme.
* save old cursor position
  l_stepl             = lcl_migo_cursor=>stepl.
  l_field             = lcl_migo_cursor=>field.
  l_oref_screenobject = lcl_migo_cursor=>oref_screenobject.
* Field selection:
* SPLIT_LINE is a technical field. Always invisible.        "354046
  CALL METHOD lcl_migo_screenmodification=>set
    EXPORTING
      i_fields = 'GOSPLIT-SPLIT_LINE'
      i_status = lcl_migo_screenmodification=>c_invisible.
* Fields in GOPLIT-popup whose fieldselection depends on the
* corrsponding source line.                                 "354046
  APPEND 'ERFMG'      TO lt_fieldmapping.
  APPEND 'MIGO_INSMK' TO lt_fieldmapping.
  APPEND 'BWART'      TO lt_fieldmapping.
  APPEND 'LGOBE'      TO lt_fieldmapping.
  APPEND 'CHARG'      TO lt_fieldmapping.
  APPEND 'BWTAR'      TO lt_fieldmapping.
* If field in source line not ready for input, remove it from the
* table control in the split popup.                         "354046
ENHANCEMENT-POINT POPUP_CALL_02 SPOTS ES_SAPLMIGO.

ENHANCEMENT-SECTION     POPUP_CALL_03 SPOTS ES_SAPLMIGO.
  LOOP AT lt_fieldmapping INTO l_fieldname.
    CONCATENATE 'GOITEM-' l_fieldname INTO l_tmp_fieldname.
    l_status = lcl_migo_screenmodification=>get(
                 i_global_counter = ps_goitem-global_counter
                 i_field          = l_tmp_fieldname
               ).
    IF l_status < lcl_migo_screenmodification=>c_input.
      l_status = lcl_migo_screenmodification=>c_invisible.
    ELSE.
      l_status = lcl_migo_screenmodification=>c_visible.
    ENDIF.
    CONCATENATE 'GOSPLIT-' l_fieldname INTO l_fieldname.
    CALL METHOD lcl_migo_screenmodification=>set
      EXPORTING
        i_fields = l_fieldname
        i_status = l_status.
  ENDLOOP.
* Default values for the new lines                          "354046
  MOVE-CORRESPONDING ps_goitem TO ps_gosplit_default.
* Set goitem to ps_goitem as popup needs the correct values "n1605541
  CLEAR goitem.                                             "n1605541
  MOVE ps_goitem TO goitem.                                 "n1605541
  CLEAR ps_gosplit_default-erfmg.
* Call the popup. Width and height are set automatically.   "354046
  CALL SCREEN 1000 STARTING AT 5 1.
END-ENHANCEMENT-SECTION.
* After processing the popup, evaluate the result and update kernel.
* Must not be executed within the popup to avoid problems with
* GUI status settings.
  IF NOT pt_gosplit IS INITIAL.
    CALL METHOD split_insert.
  ENDIF.
* get old cursor position back
  CALL METHOD lcl_migo_cursor=>cursor_set
    EXPORTING
      i_oref_screenobject = l_oref_screenobject
      i_stepl             = l_stepl
      i_field             = l_field.
ENDMETHOD.                    "popup_call

************************************************************************
* How to handle 'sy-ucomm' (is filled by pushing a button on popup).
************************************************************************
METHOD ucomm_handle.
  CASE sy-ucomm.
*   takes the items leave the popup
    WHEN 'OK_GOON'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
*  Route through to the framework (for Environment et al.)
  CALL METHOD lcl_migo_frame=>okcode_dispatch( sy-ucomm ).
ENDMETHOD.                    "ucomm_handle

************************************************************************
* Split-positions: sum all quantities
************************************************************************
METHOD sum_get.
  FIELD-SYMBOLS: <pt_gosplit> TYPE gosplit.

  CLEAR g_sum_quantity.
  LOOP AT pt_gosplit ASSIGNING <pt_gosplit>.
    g_sum_quantity = g_sum_quantity + <pt_gosplit>-erfmg.
  ENDLOOP.
ENDMETHOD.                    "sum_get

************************************************************************
* Reset all important fields for Split-quantity
************************************************************************
METHOD reset_split_quantity.
  CLEAR: p_selected_line,
         p_split_line,
         g_sum_quantity,
         ps_goitem ,
         ps_gosplit_default,
         ps_gosplit,
         pt_gosplit,
         ps_column,
         gosplit.
ENDMETHOD.                    "reset_split_quantity

************************************************************************
* Insert split-quantity lines (-> pt_gosplit) in table pt_goitem.
* Must be executed outside of DYNNR 1000!
************************************************************************
METHOD split_insert.
  DATA: ls_goitem TYPE goitem,
        l_line    TYPE sytabix,
        ls_xmcha  TYPE mcha,                                 "1625205
        lv_rc     LIKE SY-SUBRC.                             "1625205
  FIELD-SYMBOLS: <pt_gosplit> TYPE gosplit.
  l_line = p_selected_line.
  CALL METHOD lcl_migo_globals=>kernel->line_delete
    EXPORTING
      i_line = l_line.
* Insert the new lines behind the original line
  LOOP AT pt_gosplit ASSIGNING <pt_gosplit>.
    ls_goitem = ps_goitem.
    IF  ls_goitem-weanzx IS INITIAL.
      CLEAR ls_goitem-weanz.
    ENDIF.
    IF  ls_goitem-xparallel = abap_true.
      CLEAR ls_goitem-menge.
    ENDIF.
ENHANCEMENT-SECTION LMIGOSP3_02 SPOTS ES_SAPLMIGO .
    IF ls_goitem-erfmg <> <pt_gosplit>-erfmg AND             "1521977
       ls_goitem-bprme <> ls_goitem-bstme AND                "1521977
       NOT ls_goitem-bpmng IS INITIAL.                       "1521977
*     Clear the quantity in order price unit                 "1521977
      CLEAR ls_goitem-bpmng.                                 "1521977
      CALL FUNCTION 'MB_CHECK_T160M'                         "1521977
        EXPORTING                                            "1521977
          i_arbgb  = 'MIGO'                                  "1521977
          i_msgnr  = '045'                                   "1521977
          i_msgv1  = ls_goitem-zeile                         "1521977
          i_nolog  = x                                       "1521977
          i_output = x.                                      "1521977
    ENDIF.                                                   "1521977
END-ENHANCEMENT-SECTION.
    CLEAR: ls_goitem-docubatch_charg,
           ls_goitem-docubatch_control,
           ls_goitem-docubatch_mult_entries.
    MOVE-CORRESPONDING <pt_gosplit> TO ls_goitem.
*   begin of note 1625205                                    "1625205
*   if no charg is provided, we consider it as new and       "1658469
*   takeover LICHA, VFDAT, HSDAT from origin line            "1658469
    IF <pt_gosplit>-charg IS NOT INITIAL.                    "1658469
      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
     EXPORTING
          matnr            = ps_goitem-matnr
          charg            = <pt_gosplit>-charg
          werks            = ps_goitem-werks
          read_from_buffer = X
     IMPORTING
          batch_buffer         = ls_xmcha.
*     if batch is new (ls_xmcha-matnr is initial), takeover
*     LICHA, HSDAT and VFDAT from the origin line, nothing to do
*     if batch exists(ls_xmcha-matnr is filled), check if
*     overwriting of LICHA, HSDAT, VFDAT is allowed by reading
*     the customizing of the corresponding messages
*     clear the value if overwriting is not allowed
      IF NOT <pt_gosplit>-charg = ps_goitem-charg AND NOT
             ls_xmcha-matnr IS INITIAL.
*       1. check if change of LICHA is allowed
      CLEAR lv_rc.
      CALL FUNCTION 'MB_CHECK_T160M'
         EXPORTING
              i_arbgb  = 'M7'
              i_msgnr  = '171'
              i_output = space
         IMPORTING
              rc       = lv_rc.
      IF lv_rc = 2.
*         message customized as error, change not allowed,
*         delete value which will be set later in line_modify
          CLEAR ls_goitem-licha.
        ELSEIF lv_rc = 1.
*         message customized as warning, don't overwrite
*         existing data
        IF ls_xmcha-licha IS NOT INITIAL.
           CLEAR ls_goitem-licha.
        ENDIF.
      ELSEIF lv_rc = 0.
*         message customined as blank, overwriting allowed
*         nothing to do
        ENDIF.
*       2. check if change of HSDAT is allowed
      CLEAR lv_rc.
      CALL FUNCTION 'MB_CHECK_T160M'
         EXPORTING
              i_arbgb  = '12'
              i_msgnr  = '004'
              i_output = space
         IMPORTING
              rc       = lv_rc.
      IF lv_rc = 2.
*         message customized as error, change not allowed,
*         delete value which will be set later in line_modify
          CLEAR ls_goitem-hsdat.
        ELSEIF lv_rc = 1.
*         message customized as warning, don't overwrite
*         existing data
        IF ls_xmcha-hsdat IS NOT INITIAL.
           CLEAR ls_goitem-hsdat.
        ENDIF.
      ELSEIF lv_rc = 0.
*         message customined as blank, overwriting allowed
*         nothing to do
        ENDIF.
*       3. check if change of VFDAT is allowed
      CLEAR lv_rc.
      CALL FUNCTION 'MB_CHECK_T160M'
         EXPORTING
              i_arbgb  = '12'
              i_msgnr  = '005'
              i_output = space
         IMPORTING
              rc       = lv_rc.
      IF lv_rc = 2.
*         message customized as error, change not allowed,
*         delete value which will be set later in line_modify
          CLEAR ls_goitem-vfdat.
        ELSEIF lv_rc = 1.
*         message customized as warning, don't overwrite
*         existing data
        IF ls_xmcha-vfdat IS NOT INITIAL.
           CLEAR ls_goitem-vfdat.
        ENDIF.
      ELSEIF lv_rc = 0.
*         message customined as blank, overwriting allowed
*         nothing to do
        ENDIF.
*     end of note 1625205                                      "1625205
      ENDIF.
    ENDIF.                                                     "1658469
ENHANCEMENT-POINT LMIGOSP3_01 SPOTS ES_SAPLMIGO.
*   A new GLC must be derived if the old line has been deleted
    CLEAR: ls_goitem-global_counter. ", ls_goitem-zeile.     "1618250
    CALL METHOD lcl_migo_globals=>kernel->line_modify
      EXPORTING
        i_line            = l_line
        i_insert          = abap_true
        i_authority_check = abap_false
        i_status_delayed  = abap_false
      CHANGING
        cs_goitem         = ls_goitem.
    l_line = l_line + 1.
    if ps_goitem-xqm_cert = 'X' and                           "834276_v
       ps_goitem-global_counter <> ls_goitem-global_counter.
      CALL FUNCTION 'QBCK_MIGO_LINE_SPLIT'
        EXPORTING
          ls_global_counter              = ls_goitem-global_counter
          ls_global_counter_parent       = ps_goitem-global_counter.
    endif.                                                    "834276_^
  ENDLOOP.
* Set the detail screen
  def_sms 'ITEMDETAIL_LINE_SET' p_selected_line space.
ENDMETHOD.                    "split_insert