***INCLUDE RQALVF14 .

*---------------------------------------------------------------------*
*       FORM UPDATE_FIELDCAT_VARIANT_F14                              *
*---------------------------------------------------------------------*
*       update fieldcat with variant input data                       *
*       create g_selfields_tab for dynamic select                     *
*---------------------------------------------------------------------*
FORM update_fieldcat_variant_f14.
  DATA: p_fieldcat_tab TYPE slis_t_fieldcat_alv,
        p_exit,
        p_variant LIKE disvariant.

  MOVE g_variant TO p_variant.

  IF NOT g_variant-variant IS INITIAL.                    "note 1365487
  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
       EXPORTING
            i_dialog            = ' '
            i_user_specific     = g_x
            i_default           = ' '
*           I_TABNAME_HEADER    =
*           I_TABNAME_ITEM      =
            it_default_fieldcat = g_fieldcat_tab[]
            i_layout            = g_layout
*           I_BUFFER_ACTIVE     = G_X
       IMPORTING
            e_exit              = p_exit
            et_fieldcat         = p_fieldcat_tab[]
*           ET_SORT             =
*           ET_FILTER           =
       CHANGING
            cs_variant          = p_variant
       EXCEPTIONS
            wrong_input         = 1
            fc_not_complete     = 2
            not_found           = 3
            program_error       = 4
            OTHERS              = 5.

  IF sy-subrc IS INITIAL.
*Popup appears for user to select a variant. If nothing is selected,
*then all fields are displayed in list.
    IF p_exit IS INITIAL.
      MOVE p_variant TO g_variant.
      MOVE p_fieldcat_tab[] TO g_fieldcat_tab[].
    ENDIF.
*--- create itab for dynamic select ----------------------------------
    PERFORM create_g_selfields_tab_f14.
  ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM VARIANT_INPUTHELP_F14                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM variant_inputhelp_f14 USING p_variant LIKE g_variant-variant.

  DATA h_exit.

  CLEAR gx_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            is_variant          = g_variant
*           I_TABNAME_HEADER    =
*           I_TABNAME_ITEM      =
*           IT_DEFAULT_FIELDCAT =
            i_save              = g_variant_save
       IMPORTING
            e_exit              = h_exit
            es_variant          = gx_variant
        EXCEPTIONS
            not_found           = 1
            program_error       = 2
            OTHERS              = 3.

  IF h_exit IS INITIAL.
    g_variant-variant = gx_variant-variant.
    p_variant         = gx_variant-variant.
  ENDIF.

ENDFORM.                               " VARIANT_INPUTHELP_F14

*---------------------------------------------------------------------*
*       FORM VARIANT_INIT_F14                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM variant_init_f14 USING handle    type disvariant-handle
                            log_group type disvariant-log_group
                            text      type disvariant-text.
  CLEAR g_variant.

  g_repid              = sy-repid.
  g_variant-report     = g_repid.
  g_variant-handle     = handle.
  g_variant-log_group  = log_group.
  g_variant-text       = text.
  g_variant-username   = sy-uname.

*--- Wenn Report aus Customizing gerufen dann Globale Varianten aktiv
  IMPORT g_variant_save FROM MEMORY ID 'G_VARIANT_SAVE'.
  IF NOT sy-subrc IS INITIAL.
    g_variant_save = g_u.
  ENDIF.

ENDFORM.                               " VARIANT_INIT_F14

*&---------------------------------------------------------------------*
*&      Form  VARIANT_EXISTENCE_F14
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VARIANT  text                                              *
*----------------------------------------------------------------------*
FORM variant_existence_f14 USING p_variant LIKE g_variant-variant.

  CHECK NOT p_variant IS INITIAL.

  g_variant-variant = p_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
       EXPORTING
            i_save     = g_variant_save
       CHANGING
            cs_variant = g_variant.

ENDFORM.                               " VARIANT_EXISTENCE_F14
*---------------------------------------------------------------------*
*       FORM GET_DEFAULT_VARIANT_F14                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM get_default_variant_f14 USING p_variant LIKE g_variant-variant.

  gx_variant = g_variant.

  IF NOT p_variant IS INITIAL.
    gx_variant-variant = p_variant.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
       EXPORTING
            i_save        = g_variant_save
       CHANGING
            cs_variant    = gx_variant
       EXCEPTIONS
            wrong_input   = 1
            not_found     = 2
            program_error = 3
            OTHERS        = 4.

  CASE sy-subrc.
    WHEN 0.
      p_variant = gx_variant-variant.
    WHEN 2.
      CLEAR p_variant.
  ENDCASE.

ENDFORM.                               " GET_DEFAULT_VARIANT_F14

*---------------------------------------------------------------------*
*       FORM FILL_EVENTS_F14                                          *
*---------------------------------------------------------------------*
*       assign forms to different events during list proccessing      *
*---------------------------------------------------------------------*
FORM fill_events_f14.

  DATA h_event       TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
       EXPORTING
            i_list_type = 0
       IMPORTING
            et_events   = g_events_tab.

* In grid control, space is created for top-of-page if event is found
  IF NOT g_event_needed IS INITIAL.
*--- allocate form for top-of-page ----------------------------------*
    READ TABLE g_events_tab WITH KEY name = slis_ev_top_of_page
                          INTO h_event.
    IF sy-subrc = 0.
      MOVE g_form_top_of_page TO h_event-form.
      MODIFY g_events_tab FROM h_event INDEX sy-tabix.
    ENDIF.
  ENDIF.
*--- allocate form for user-command ---------------------------------*
  READ TABLE g_events_tab WITH KEY name = slis_ev_user_command
                        INTO h_event.
  IF sy-subrc = 0.
    MOVE g_form_user_command TO h_event-form.
    MODIFY g_events_tab FROM h_event INDEX sy-tabix.
  ENDIF.

*--- allocate form for set-pf-status---------------------------------*
  READ TABLE g_events_tab WITH KEY name = slis_ev_pf_status_set
                        INTO h_event.
  IF sy-subrc = 0.
    MOVE g_form_set_pf_stat TO h_event-form.
    MODIFY g_events_tab FROM h_event INDEX sy-tabix.
  ENDIF.

ENDFORM.                               " FILL_EVENTS_F14

*---------------------------------------------------------------------*
*       FORM FILL_EVENT_EXIT_TAB_F14                                  *
*---------------------------------------------------------------------*
*       standard fcodes listviewer with affect to local programm      *
*---------------------------------------------------------------------*
FORM fill_event_exit_tab_f14.

  DATA h_event_exit_wa TYPE slis_event_exit.
*--- fcode get actual variant via icon -------------------------------*
  h_event_exit_wa-ucomm = g_ol0.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- fcode line detail/ call transaction -----------------------------*
  h_event_exit_wa-ucomm = g_eta.
  h_event_exit_wa-before = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- fcode select Variant -------------------------------------------*
  h_event_exit_wa-ucomm = g_oad.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- fcode change actual variant ------------------------------------*
  h_event_exit_wa-ucomm = g_olx.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- fcode show original list layout --------------------------------*
  h_event_exit_wa-ucomm = g_lis.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- pf2 used by salv and also by application (double-click) --------*
  h_event_exit_wa-ucomm = g_ic1.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- set/change filter on list --------------------------------------*
  h_event_exit_wa-ucomm = g_ilt.
  h_event_exit_wa-after = g_x.
  APPEND h_event_exit_wa TO g_event_exit_tab.
  CLEAR h_event_exit_wa.                                  "note 997019
*--- show selection criteria   --------------------------------------*
* h_event_exit_wa-ucomm = g_nfo.
* h_event_exit_wa-before = g_x.
* h_event_exit_wa-after = g_x.
* APPEND H_EVENT_EXIT_WA TO G_EVENT_EXIT_TAB.
*--- fcode show Quickinfo -------------------------------------------*
* CLEAR H_EVENT_EXIT_WA.
* H_EVENT_EXIT_WA-UCOMM  = G_ETA.
* H_EVENT_EXIT_WA-AFTER = G_X.
* APPEND H_EVENT_EXIT_WA TO G_EVENT_EXIT_TAB.

ENDFORM.                               " FILL_EVENT_EXIT_TAB_F14

*---------------------------------------------------------------------*
*       FORM FILL_LAYOUT_F14                                          *
*---------------------------------------------------------------------*
*       general layout info for list display                          *
*---------------------------------------------------------------------*
FORM fill_layout_f14.
* Detailed info on how to affect the layout can be found in the
* documentation for parameter IS_LAYOUT in FB 'REUSE_ALV_LIST_DISPLAY'.

  g_layout-f2code               = '&ETA'.
  g_layout-box_fieldname        = 'SELECTED'.  "field for checkbox
* Lights are only set if a criterion is selected.
*  if not monitor is initial.
*    g_layout-lights_fieldname     = 'LIGHTS'.  "field for lights
*  endif.
  g_layout-get_selinfos         = g_x. "show selection screen criteria
  g_layout-detail_popup         = g_x. "show detail via popup
  g_layout-group_change_edit    = g_x. "allows data to be grouped
* As of 4.6C, the zebra pattern can be set as a variant attribute by
* the user in 'Save variant' dialog.
*  g_layout-zebra                = g_x. "striped pattern
ENDFORM.                               " FILL_LAYOUT_F14

*---------------------------------------------------------------------*
*       FORM CALL_LISTVIEWER_F14                                      *
*---------------------------------------------------------------------*
*       Call SALV                                                     *
*---------------------------------------------------------------------*
FORM call_listviewer_f14 USING  P_FIELDCAT_TAB TYPE SLIS_T_FIELDCAT_ALV
                                P_OBJECT_TAB TYPE TABLE.
  DATA:
    l_exit_caused_by_caller TYPE c,
    l_exit_caused_by_user   TYPE slis_exit_by_user,
    lt_exc                  TYPE TABLE OF alv_s_qinf,
    ls_exc                  TYPE alv_s_qinf.

  ls_exc-type = cl_salv_tooltip=>c_type_symbol.
  ls_exc-value = SYM_CHECK_MARK.
  CALL METHOD CL_WD_UTILITIES=>GET_OTR_TEXT_BY_ALIAS
    EXPORTING
      alias      = 'QV/TEXT1'
      language   = sy-langu
    RECEIVING
      alias_text = ls_exc-text.
  APPEND ls_exc to lt_exc.

  GET PARAMETER ID 'Q_ALV_GRID_INACTIVE' FIELD g_grid.

*--- call customer function to change ALV settings
  CALL FUNCTION 'IREP1_CHANGE_SETTINGS_ALV'
       EXPORTING
            is_repid            = g_repid
            is_variant          = g_variant
            is_form_top_of_page = 'TOP_OF_PAGE_L'
       CHANGING
            i_grid_inactive     = g_grid
            is_layout           = g_layout
            is_print            = g_print
            it_fieldcat         = p_fieldcat_tab[]
            it_special_groups   = g_fieldgroups_tab[]
            it_list_commentary  = g_listheader_tab[]
            it_event_tab        = g_events_tab[].

  IF g_grid IS INITIAL.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
*             i_buffer_active          = g_x
              i_callback_program       = g_repid
              i_callback_pf_status_set = g_form_set_pf_stat
              i_callback_user_command  = g_form_user_command
*           I_STRUCTURE_NAME         =
              is_layout                = g_layout
              it_fieldcat              = p_fieldcat_tab[]
*           it_excluding             =
              it_special_groups        = g_fieldgroups_tab[]
              it_sort                  = g_sortfields_tab[]
*           it_filter                =
*           is_sel_hide              =
*           i_default                =
*              i_save                   = g_variant_save
              i_save                   = g_a
              is_variant               = g_variant
              it_events                = g_events_tab[]
              it_event_exit            = g_event_exit_tab[]
              is_print                 = g_print
              i_screen_start_column    = g_screen_start_column
              i_screen_start_line      = g_screen_start_line
              i_screen_end_column      = g_screen_end_column
              i_screen_end_line        = g_screen_end_line
              it_except_qinfo          = lt_exc
         IMPORTING
              e_exit_caused_by_caller  = l_exit_caused_by_caller
              es_exit_caused_by_user   = l_exit_caused_by_user
         TABLES
              t_outtab                 =  p_object_tab
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
         EXPORTING
*             i_buffer_active          = g_x
              i_callback_program       = g_repid
              i_callback_pf_status_set = g_form_set_pf_stat
              i_callback_user_command  = g_form_user_command
*           I_STRUCTURE_NAME         =
              is_layout                = g_layout
              it_fieldcat              = p_fieldcat_tab[]
*           it_excluding             =
              it_special_groups        = g_fieldgroups_tab[]
              it_sort                  = g_sortfields_tab[]
*           it_filter                =
*           is_sel_hide              =
*           i_default                =
*              i_save                   = g_variant_save
              i_save                   = g_a
              is_variant               = g_variant
              it_events                = g_events_tab[]
              it_event_exit            = g_event_exit_tab[]
              is_print                 = g_print
              i_screen_start_column    = g_screen_start_column
              i_screen_start_line      = g_screen_start_line
              i_screen_end_column      = g_screen_end_column
              i_screen_end_line        = g_screen_end_line
         IMPORTING
              e_exit_caused_by_caller  = l_exit_caused_by_caller
              es_exit_caused_by_user   = l_exit_caused_by_user
         TABLES
              t_outtab                 =  p_object_tab
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.
  ENDIF.
  IF NOT l_exit_caused_by_caller    IS INITIAL
  OR NOT l_exit_caused_by_user-back IS INITIAL.
*   zurueck (f3)
    SET USER-COMMAND 'BACK'.
  ELSEIF NOT l_exit_caused_by_user-exit IS INITIAL.
*   beenden (f15)
    SET USER-COMMAND '%EX'.
  ELSEIF NOT l_exit_caused_by_user-cancel IS INITIAL.
*   abbrechen (f12)
    SET USER-COMMAND 'RW'.
  ENDIF.



ENDFORM.                               " CALL_LISTVIEWER_F14

*---------------------------------------------------------------------*
*       FORM CREATE_G_SELFIELDS_TAB_F14                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM create_g_selfields_tab_f14.

  DATA h_fieldcat_wa TYPE slis_fieldcat_alv.
  DATA h_index       LIKE sy-tabix.

  h_index = 1.
*--- g_selfields_tab consists of fields marked for display -----------*
  REFRESH g_selfields_tab.
  CLEAR   g_selfields_tab.

  SORT g_fieldcat_tab BY no_out ASCENDING.
  DO.
    READ TABLE g_fieldcat_tab INTO h_fieldcat_wa INDEX h_index.
    IF sy-subrc IS INITIAL AND h_fieldcat_wa-no_out = space.
      IF h_fieldcat_wa-fieldname <> 'LIGHTS' AND
         h_fieldcat_wa-fieldname <> 'SELECTED'.
        g_selfields_tab-field = h_fieldcat_wa-fieldname.
        APPEND g_selfields_tab.
      ENDIF.
      h_index = h_index + 1.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                               "CREATE_G_SELFIELDS_TAB_F14

*&---------------------------------------------------------------------*
*&      Form  AKTUALISIEREN_F14
*&---------------------------------------------------------------------*
*  updates the report - current catalog is stored in g_fieldcat_tab.
* this is exported to memory, and imported at start of selection.
*
*
*----------------------------------------------------------------------*
FORM aktualisieren_f14.

  IF sy-ucomm = 'DTC_BAC1' OR sy-ucomm = 'CANC'.            "note 997019
    RETURN.                                                 "note 997019
  ENDIF.                                                    "note 997019

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 100
*           TEXT       = TEXT-001      "'Die Daten werden neu gelesen'
       EXCEPTIONS
            OTHERS     = 0.


  DATA l_reportid    LIKE sy-repid.
  DATA BEGIN OF t_sel_tab OCCURS 1.
          INCLUDE STRUCTURE rsparams.
  DATA END OF t_sel_tab.
  DATA l_texpr TYPE rsds_texpr.
  DATA l_trange TYPE rsds_trange.
*     Liste aktualisieren
  l_reportid = sy-repid.
* Get current field catalog
  REFRESH g_fieldcat_tab.
  CLEAR g_fieldcat_tab.
  PERFORM get_fieldcat_actual_info_f14.

* Select option
  REFRESH t_sel_tab.
  CLEAR t_sel_tab.
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
       EXPORTING
            curr_report     = l_reportid
       TABLES
            selection_table = t_sel_tab.
* Freie Selektionsbedingungen holen und laden
  CALL FUNCTION 'RS_REFRESH_FROM_DYNAMICAL_SEL'
       EXPORTING
            curr_report        = l_reportid
            mode_write_or_move = 'M'
       IMPORTING
            p_trange           = l_trange
       EXCEPTIONS
            not_found          = 1.
  IF sy-subrc IS INITIAL.
*   mit freien Abgrenzungen
    CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
         EXPORTING
              field_ranges = l_trange
         IMPORTING
              expressions  = l_texpr.
    EXPORT g_submit FROM 'X' g_fieldcat_tab TO MEMORY ID 'SUBMIT'.
    SUBMIT (l_reportid) WITH SELECTION-TABLE t_sel_tab
                        WITH FREE SELECTIONS l_texpr AND RETURN.
    IMPORT object_tab FROM MEMORY ID g_repid.
  ELSE.
    EXPORT g_submit FROM 'X' g_fieldcat_tab TO MEMORY ID 'SUBMIT'.
    SUBMIT (l_reportid) WITH SELECTION-TABLE t_sel_tab AND RETURN.
    IMPORT object_tab FROM MEMORY ID g_repid.
  ENDIF.

* Status Puffer zurücksetzen
  CALL FUNCTION 'STATUS_BUFFER_REFRESH'.

  FREE MEMORY ID 'SUBMIT'.
  FREE MEMORY ID g_repid.
ENDFORM.                               " AKTUALISIEREN_F14
*---------------------------------------------------------------------*
*       FORM GET_FIELDCAT_ACTUAL_INFO_F14                             *
*---------------------------------------------------------------------*
*       get actual Listviewer settings
*---------------------------------------------------------------------*
FORM get_fieldcat_actual_info_f14.

  IF g_grid IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
         IMPORTING
              es_layout            = g_layout
              et_fieldcat          = g_fieldcat_tab[]
              et_sort              = g_sortfields_tab[]
              et_filter            = g_filter_tab[]
*           ES_GRID_SCROLL =
              es_variant           = g_variant
              et_filtered_entries  = g_filtered_entries_tab[]
         EXCEPTIONS
              no_infos       = 1
              program_error  = 2
              OTHERS         = 3.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
         IMPORTING
              es_layout           = g_layout
              et_fieldcat         = g_fieldcat_tab[]
              et_sort             = g_sortfields_tab[]
              et_filter           = g_filter_tab[]
              es_list_scroll      = g_scroll
              es_variant          = g_variant
              et_filtered_entries = g_filtered_entries_tab[]
         EXCEPTIONS
              no_infos            = 1
              program_error       = 2
              OTHERS              = 3.
  ENDIF.

ENDFORM.                               "GET_FIELDCAT_ACTUAL_INFO_F14
*&---------------------------------------------------------------------*
*&      Form  ADD_VIEWED_COLUMN_F14
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_viewed_column_f14.


  DATA h_fieldcat_wa TYPE slis_fieldcat_alv.
  DATA h_dd04v_wa    LIKE dd04v.
*--- field pm_selected will be shown as symbol-box in list
  READ TABLE g_fieldcat_tab WITH KEY fieldname = 'VIEWED'
                            INTO h_fieldcat_wa.
  IF NOT sy-subrc IS INITIAL.
    CLEAR h_fieldcat_wa.
    CALL FUNCTION 'DDIF_DTEL_GET'
         EXPORTING
              name     = 'VIEWED'
              langu    = sy-langu
         IMPORTING
              dd04v_wa = h_dd04v_wa
         EXCEPTIONS
              OTHERS   = 1.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING h_dd04v_wa TO h_fieldcat_wa.
      h_fieldcat_wa-key = g_x.
      h_fieldcat_wa-tabname   = 'OBJECT_TAB'.
      h_fieldcat_wa-fieldname = 'VIEWED'.
      h_fieldcat_wa-symbol    = g_x.
      h_fieldcat_wa-emphasize = 'C300'.
      h_fieldcat_wa-outputlen = 1.
      APPEND h_fieldcat_wa TO g_fieldcat_tab.
    ENDIF.
  ENDIF.

ENDFORM.                               " ADD_VIEWED_COLUMN_F14