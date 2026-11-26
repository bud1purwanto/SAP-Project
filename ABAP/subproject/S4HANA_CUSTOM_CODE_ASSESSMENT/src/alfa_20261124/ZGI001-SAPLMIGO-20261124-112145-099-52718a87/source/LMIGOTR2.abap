*----------------------------------------------------------------------*
*   INCLUDE LMIGOTR2                                                   *
*   Tracer
*----------------------------------------------------------------------*

CLASS lcl_migo_trace IMPLEMENTATION.
************************************************************************
* Constructor to initialize the controls at startup if requested
************************************************************************
METHOD constructor.
  DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_DEBUG'.
  APPEND 'MIGO_DEBUG' TO lt_okcodes.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes.
* User settings
  CREATE OBJECT poref_settings TYPE cl_mmim_userdefaults
    EXPORTING i_action = 'MIGO_DEBUG'.
  CALL METHOD poref_settings->preset( i_element = 'TOOLBAR'
                                      i_active  = abap_false ).
* Start if requested
  IF poref_settings->get( 'TOOLBAR' ) = abap_true.
    CALL METHOD toolbar_init.
  ELSE.                                                          "491163
*   If the toolbar is invisible, so must be the framework trace
    IF lcl_migo_frame=>trace_visible = abap_true.                "491163
      CALL METHOD                                                "491163
        lcl_migo_frame=>trace_visibility_set                     "491163
          EXPORTING                                              "491163
            i_visibility = abap_false.                           "491163
    ENDIF.                                                       "491163
  ENDIF.                                                         "491163
ENDMETHOD.
************************************************************************
* Initialization of the toolbar
************************************************************************
METHOD toolbar_init.
  DATA: ls_event  TYPE cntl_simple_event,
        lt_events TYPE cntl_simple_events.
* Leave if already done
  CHECK poref_toolbarcontainer IS INITIAL.
* Create control area in screen 0001
  CREATE OBJECT poref_toolbarcontainer
    EXPORTING
      container_name = 'SUB_DEBUG'
      repid          = c_repid
      dynnr          = '0001'.
* Create the toolbar
  CREATE OBJECT poref_toolbar TYPE cl_gui_toolbar
    EXPORTING
      parent = poref_toolbarcontainer.
  ls_event-eventid    = cl_gui_toolbar=>m_id_function_selected.
  ls_event-appl_event = x.
  APPEND ls_event TO lt_events.
  CALL METHOD poref_toolbar->set_registered_events
    EXPORTING
      events = lt_events.
  SET HANDLER toolbar_handler FOR poref_toolbar.
* Breakpoint-Button
  CALL METHOD poref_toolbar->add_button
    EXPORTING
      fcode     = 'BREAK'
      butn_type = cntb_btype_button
      icon      = '@3U@'
      text      = 'Kernel'.                                  "#EC NOTEXT
* Trace
  CALL METHOD poref_toolbar->add_button
    EXPORTING
      fcode      = 'TRACE'
      butn_type  = cntb_btype_button
      icon       = '@9U@'
      text       = 'Trace'.                                  "#EC NOTEXT
* Separator
  CALL METHOD poref_toolbar->add_button
    EXPORTING
      fcode     = ''
      butn_type = cntb_btype_sep
      icon      = ''
      text      = ''.                                        "#EC NOTEXT
* Exit
  CALL METHOD poref_toolbar->add_button
    EXPORTING
      fcode     = 'EXIT'
      butn_type = cntb_btype_button
      icon      = '@3X@'
      text      = 'Exit'.                                    "#EC NOTEXT
ENDMETHOD.
************************************************************************
* Incoming OK-codes and messages
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
* Startup signal
  IF i_okcode = 'MIGO_DEBUG'.
    IF poref_toolbarcontainer IS INITIAL.
      CALL METHOD toolbar_init.
    ELSE.
      CALL METHOD poref_toolbarcontainer->set_visible( '1' ).
    ENDIF.
    CALL METHOD poref_settings->set( i_element = 'TOOLBAR'
                                     i_active  = abap_true ).
  ENDIF.
ENDMETHOD.

METHOD lif_migo_frame~message_handler.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
ENDMETHOD.
************************************************************************
* Toolbar function handler
************************************************************************
METHOD toolbar_handler.
  DATA: l_trace_visible TYPE abap_bool.
  CHECK lcl_migo_globals=>cntl_error = abap_false.
  CASE fcode.
    WHEN 'EXIT'.
      CALL METHOD poref_toolbarcontainer->set_visible( '0' ).
      CALL METHOD poref_settings->set( i_element = 'TOOLBAR'
                                       i_active  = abap_false ).
*     If the trace window is open, close it
      IF lcl_migo_frame=>trace_visible = abap_true.              "491163
        CALL METHOD                                              "491163
          lcl_migo_frame=>trace_visibility_set                   "491163
            EXPORTING                                            "491163
              i_visibility = abap_false.                         "491163
      ENDIF.                                                     "491163
      CALL METHOD cl_mmim_userdefaults=>flush_all.
    WHEN 'TRACE'.
      l_trace_visible = lcl_migo_frame=>trace_visible.
      def_boolean_toggle l_trace_visible.
      CALL METHOD
          lcl_migo_frame=>trace_visibility_set
            EXPORTING
              i_visibility = l_trace_visible.
    WHEN 'BREAK'.
      CALL METHOD lcl_migo_globals=>kernel->break_point.
    ENDCASE.
ENDMETHOD.


ENDCLASS.

************************************************************************
* Easter egg
************************************************************************
FORM on_ctmenu_about_migo USING p_menu TYPE REF TO cl_ctmenu.
  DATA: loref_submenu TYPE REF TO cl_ctmenu.
* Trace functions only if S_DEVELOP available
  AUTHORITY-CHECK OBJECT 'S_DEVELOP'
    ID 'DEVCLASS' DUMMY
    ID 'OBJTYPE'  DUMMY
    ID 'OBJNAME'  DUMMY
    ID 'P_GROUP'  DUMMY
    ID 'ACTVT'    DUMMY.
  IF sy-subrc = 0.
    CALL METHOD p_menu->add_function
      EXPORTING
        fcode = 'MIGO_DEBUG'
        text  = 'Toolbar'.                                   "#EC NOTEXT
    CALL METHOD p_menu->add_separator.
  ENDIF.
* About. Always there.
  CREATE OBJECT loref_submenu.
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Members of the MM-IM Enjoy-Team'.    "#EC NOTEXT
  CALL METHOD loref_submenu->add_separator.
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Antonio Cannone'.                    "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Christiane Kuntz-Mayr'.              "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Joerg von Duhn'.                     "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Johann Kemmer'.                      "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Juergen Kremp'.                      "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Juergen Mueller'.                    "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Pascale Van Laethem'.                "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Ralf Heimburger'.                    "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Viola Mitterer'.                     "#EC NOTEXT
  CALL METHOD loref_submenu->add_function
     EXPORTING fcode = 'MIGO_X1'
               text  = 'Volker Sandmeyer'.                   "#EC NOTEXT
  CALL METHOD p_menu->add_submenu
    EXPORTING
      menu  = loref_submenu
      text  = 'About MIGO'.                                  "#EC NOTEXT
ENDFORM.