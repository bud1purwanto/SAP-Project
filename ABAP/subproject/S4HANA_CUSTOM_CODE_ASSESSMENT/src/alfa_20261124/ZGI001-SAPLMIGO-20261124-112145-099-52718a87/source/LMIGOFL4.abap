*----------------------------------------------------------------------*
*   INCLUDE LMIGOFL4                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Fill in the valid data for the ACTION listbox.
* Entries can be deactivated in customizing table MIGO_CUST_ACTION
************************************************************************
METHOD listbox_action_set.
  DATA: ls_ddic_info   TYPE dd07v,
        lt_ddic_info   TYPE TABLE OF dd07v,
        l_history      TYPE string,                         "383269
        ls_action      TYPE pty_s_action.
  CLEAR pt_action.                                          "383269
* Get all domain texts
  CALL FUNCTION 'DDUT_DOMVALUES_GET'
    EXPORTING
      name          = 'GOACTION'
      texts_only    = x
    TABLES
      dd07v_tab     = lt_ddic_info
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
* Get recently used entries
  l_history = poref_settings->get( 'ACTION_HISTORY' ).      "383269
* Fill the goods ones into the table to be send to the screen
  LOOP AT lt_ddic_info INTO ls_ddic_info.
    ls_action-action = ls_ddic_info-domvalue_l.
    ls_action-value  = ls_ddic_info-ddtext.
    READ TABLE lcl_migo_globals=>t_cust
               WITH KEY action = ls_action-action
               TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
*     The user history for the listbox is evaluated. Recently used
*     entries are moved to front in order of usage.
      ls_action-sort = 0.                                   "383269
      SEARCH l_history FOR ls_action-action.                "383269
      IF sy-subrc = 0.                                      "383269
        ls_action-sort = sy-fdpos + 1.                      "383269
      ENDIF.                                                "383269
      APPEND ls_action TO pt_action.
    ENDIF.
  ENDLOOP.
  SORT pt_action BY sort  DESCENDING                        "383269
                    value ASCENDING.                        "383269
ENDMETHOD.                    "listbox_action_set
************************************************************************
* Fill the values for the REFDOC-listbox according to P_ACTION
* Entries can be deactivated in customizing table MIGO_CUST_REFDOC
************************************************************************
METHOD listbox_refdoc_set.
  DATA: ls_ddic_info TYPE dd07v,
        lt_ddic_info TYPE TABLE OF dd07v,
        ls_refdoc    TYPE pty_s_refdoc.

  CLEAR pt_refdoc.
* Get all domain texts
  CALL FUNCTION 'DDUT_DOMVALUES_GET'
    EXPORTING
      name          = 'REFDOC'
      texts_only    = x
    TABLES
      dd07v_tab     = lt_ddic_info
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
* Loop over the allowed refdocs
  LOOP AT lt_ddic_info INTO ls_ddic_info.
    ls_refdoc-refdoc = ls_ddic_info-domvalue_l.
    ls_refdoc-value  = ls_ddic_info-ddtext.
    READ TABLE lcl_migo_globals=>t_cust
               WITH KEY action = p_action
                        refdoc = ls_refdoc-refdoc
                        TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      APPEND ls_refdoc TO pt_refdoc.
    ENDIF.
  ENDLOOP.
  SORT pt_refdoc BY value.
ENDMETHOD.                    "listbox_refdoc_set
************************************************************************
* POV Module to fill the data for the ACTION-listbox.
* Data have to be filled beforehand into the table T_ACTION.
************************************************************************
METHOD pov_action.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield  = 'ACTION'
      value_org = 'S'
    TABLES
      value_tab = pt_action.
ENDMETHOD.                    "pov_action
************************************************************************
* POV Module to fill the data for the REFDOC-listbox.
************************************************************************
METHOD pov_refdoc.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield  = 'REFDOC'
      value_org = 'S'
    TABLES
      value_tab = pt_refdoc.
ENDMETHOD.                    "pov_refdoc
************************************************************************
* PBO
************************************************************************
METHOD pbo.
  CALL METHOD super->pbo.
  godynpro-action        = p_action.
  godynpro-refdoc        = p_refdoc.
  godynpro-firstline_log = p_firstline_log.
  godefault_tv-sobkz     = lcl_migo_globals=>kernel->s_defaults-sobkz.
  IF g_sub_general = SPACE.                                      "679047
    CALL METHOD oref_header->pbo.                                "679047
  ENDIF.                                                         "679047
* begin note 379268
  godefault_tv-bwart     = lcl_migo_globals=>kernel->s_defaults-bwart.
  CALL METHOD lcl_migo_buffer=>move_type_text_get
    EXPORTING
      i_move       = lcl_migo_globals=>kernel->s_defaults-bwart
      i_spec_stock = lcl_migo_globals=>kernel->s_defaults-sobkz
    RECEIVING
      e_move_text  = godefault_tv-bwtxt
    EXCEPTIONS
      OTHERS       = 1.
* end note 379268
* No text found (can happen due to odd customiizing in T156T)
* show text "Nothing found".
  IF godefault_tv-bwtxt IS INITIAL.                         "381283
    godefault_tv-bwtxt = text-126.                          "381283
  ENDIF.                                                    "381283
* Screen modification
  LOOP AT SCREEN.
    CASE screen-group2.
*     Listboxes grey if lines in and not display material document
      WHEN 'FL1'.
        IF p_locked = abap_true AND p_action <> 'A04'.
          screen-input = c_mod_off.
          MODIFY SCREEN.
        ENDIF.
*     Input fields grey if movement not allowed
      WHEN 'FL2'.
        IF p_refdoc <>
               lcl_migo_globals=>kernel->s_status-allowed_refdoc.
          screen-input = c_mod_off.
          MODIFY SCREEN.
        ENDIF.
*     Button "Loglevel"
      WHEN 'FL4'.
        IF p_firstline_log IS INITIAL.
          screen-active = c_mod_off.
          MODIFY SCREEN.
        ENDIF.
*     Button "Show searchlist"
      WHEN 'FL5'.
        IF p_searchlist_button = abap_false.
          screen-input = c_mod_off.
          MODIFY SCREEN.
        ENDIF.
*     Input field movement type unvisible                        "379268
*     and also the special stock indicator
      WHEN 'FL6'.                                           "379268
        IF lcl_migo_globals=>kernel->s_defaults-bwartx =    "381283
                                                  abap_false."381283
          screen-active = c_mod_off.                        "379268
          MODIFY SCREEN.                                    "379268
        ENDIF.                                              "379268
*     Field ORDER_ITEM_NUMBER inactive in case of GI
      WHEN 'FL7'.                                           "433178
        IF p_action = 'A07'.                                "433178
          screen-active = c_mod_off.                        "433178
          MODIFY SCREEN.                                    "433178
        ENDIF.                                              "433178
*     Field ORDER_OPERATION inactive in case of GR
      WHEN 'FL8'.
        IF p_action = 'A01'.
          screen-active = c_mod_off.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.
* In DEADEND-mode, disable everything.
  IF lcl_migo_globals=>external_call_deadend = abap_true.
    LOOP AT SCREEN.
      screen-input = c_mod_off.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMETHOD.                    "pbo
************************************************************************
* Cursorposition resulotion: Just return the name
************************************************************************
METHOD cursor_position_resolve.
  e_tabix = 0.
  e_name  = 'FIRSTLINE'.
ENDMETHOD.                    "cursor_position_resolve
************************************************************************
* After RESET, set the cursor into the REFDOC field
************************************************************************
METHOD cursor_set.
  DATA: l_field TYPE migo_fieldname.
  CASE p_refdoc.
    WHEN 'R01'. l_field = 'GODYNPRO-PO_NUMBER'.
    WHEN 'R02'. l_field = 'GODYNPRO-MAT_DOC'.
    WHEN 'R03'. l_field = 'GODYNPRO-DELIVERY_NOTE'.
    WHEN 'R04'. l_field = 'GODYNPRO-INBOUND_DELIVERY'.
    WHEN 'R05'. l_field = 'GODYNPRO-OUTBOUND_DELIVERY'.
    WHEN 'R06'. l_field = 'GODYNPRO-TRANSPORT'.
    WHEN 'R07'. l_field = 'GODYNPRO-TRANSPORTIDENT'.
    WHEN 'R08'. l_field = 'GODYNPRO-ORDER_NUMBER'.
    WHEN 'R09'. l_field = 'GODYNPRO-RESERVATION_NUMBER'.
    WHEN 'R10'. l_field = ''.
  ENDCASE.
  CALL METHOD lcl_migo_cursor=>cursor_set
    EXPORTING
      i_oref_screenobject = me
      i_field             = l_field.
ENDMETHOD.                    "cursor_set
*----------------------------------------------------------------------
* METHOD pai_mvt_sobkz_change
* If the user changes movement type or special stock directly on the
* MIGO screen we update the ESDUS defaults in lcl_migo_defaults.
* Lcl_migo_defaults will then send the data to kernel to update
* s_defaults in kernel.
*----------------------------------------------------------------------
METHOD pai_mvt_sobkz_change.
  def_sms 'FIRSTLINE_MVT_CHANGED' godefault_tv-bwart
                                  godefault_tv-sobkz.
ENDMETHOD.                    "pai_change_bwart_sobkz
*----------------------------------------------------------------------*
* METHOD pai_mvt_sobkz_check
* new defaults for bwart and sobkz have been entered directly on the
* MIGO screen.
* This method checks whether the new defaults are valid or not. The
* kernel should not update s_defaults with incorrect data.
*----------------------------------------------------------------------*
METHOD pai_mvt_sobkz_check.
  DATA ls_t156b TYPE t156b.
  CHECK NOT godefault_tv-bwart IS INITIAL.
  call method lcl_migo_buffer=>allowed_mvt_check
                                 exporting
                                   i_bwart = godefault_tv-bwart
                                 exceptions
                                   not_allowed = 1.
  if sy-subrc = 1.
    MESSAGE e062 WITH godefault_tv-bwart.
  ENDIF.
  SELECT SINGLE bwart FROM  t156b
                     INTO  ls_t156b
                     WHERE bwart = godefault_tv-bwart AND
                           sobkz = godefault_tv-sobkz.
  IF sy-subrc <> 0.
    IF godefault_tv-sobkz is INITIAL.
      message e080.
    ENDIF.

    MESSAGE e057 WITH godefault_tv-bwart
                      godefault_tv-sobkz.
  ENDIF.

ENDMETHOD.                    "pai_mvt_sobkz_check