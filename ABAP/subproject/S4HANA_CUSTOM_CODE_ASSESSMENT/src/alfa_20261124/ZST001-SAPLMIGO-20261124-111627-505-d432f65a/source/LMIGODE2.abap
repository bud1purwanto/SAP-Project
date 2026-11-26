*----------------------------------------------------------------------*
*   INCLUDE LMIGODE2                                                   *
*   Default values kernel
*----------------------------------------------------------------------*

CLASS lcl_migo_defaults IMPLEMENTATION.

************************************************************************
* Includes                                                             *
************************************************************************
INCLUDE: LMIGODE3,
         LMIGODE4.                 "modules and methods for screen 1110


************************************************************************
* Create the userdefault object and fill the initial data into
* the public section
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes   TYPE lif_migo_frame=>ty_t_okcodes,
          lt_receiving TYPE lif_migo_frame=>ty_t_message_ids,
          lt_sending   TYPE lif_migo_frame=>ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    APPEND 'KERNEL_MODE_CHANGED'   TO lt_receiving.
    APPEND 'HEADER_WEVER_CHANGED'  TO lt_receiving.              "315434
ENHANCEMENT-POINT CONSTRUCTOR_01 SPOTS ES_SAPLMIGO.
    APPEND 'FIRSTLINE_MVT_CHANGED' TO lt_receiving.              "379268
    APPEND 'FIRSTLINE_SOBKZ_CHANG' TO lt_receiving.
    APPEND 'MIGO_TIP_REQUEST'      TO lt_sending.
    APPEND 'MIGO_TIP_RESET'        TO lt_sending.
    APPEND 'OK_DEFVALS'            TO lt_okcodes.
    APPEND 'OK_DEF_TRA'            TO lt_okcodes.
    lif_migo_frame~class_id = 'MIGO_DEFAULTS'.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_receiving  = lt_receiving
        it_sending    = lt_sending.

    CREATE OBJECT oref_settings EXPORTING i_action = 'MIGO_DEFAULTS'.
* DDIF_NAMETAB_GET is called to get the description of GODEFAULT_TRA_TV
* it is needed for METHOD transfer_tv_fill and
* METHOD copy_rule_translate
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'GODEFAULT_TRA_TV'
      TABLES
        dfies_tab = pt_dfies
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
    CREATE OBJECT oref_settings_trans EXPORTING
                                          i_action = 'MIGO_DEF_TRANS'.

    CALL METHOD preset.
    CALL METHOD transfer_tv_fill.
  ENDMETHOD.                    "constructor
************************************************************************
* Presets
************************************************************************
  METHOD preset.
    DATA: ls_cust   TYPE migo_cust_refdoc,
          l_element TYPE es_element,
          l_wever   TYPE wever.                                  "315434

    DEFINE d_preset_wever.                                       "315434
      call method lcl_migo_buffer=>trx_control_get
        exporting
          i_tcode   = &1
        importing
          e_wever   = l_wever
        exceptions
          not_found = 1.
      if sy-subrc <> 0 or l_wever is initial.
        l_wever = '3'.
      endif.
      call method oref_settings->preset( i_element = &2
        i_active = l_wever ).
    END-OF-DEFINITION.                                           "315434
* Preset print version depending on VGART from T158 -        note 315434
    d_preset_wever   'MIGO_GI'   'WEVER_WA'.
    d_preset_wever   'MIGO_GR'   'WEVER_WE'.
    d_preset_wever   'MIGO_GO'   'WEVER_WF'.
    d_preset_wever   'MIGO_TR'   'WEVER_WT'.

    CALL METHOD oref_settings->preset( i_element = 'BWART_NEW'
      i_active = '501' ).
    CALL METHOD oref_settings->preset( i_element = 'BWART_CONTAINER'
      i_active = '501' ).
    CALL METHOD oref_settings->preset( i_element = 'SOBKZ_CONTAINER'
      i_active = 'M' ).

* Analysis of the customizing table for defaults
    SELECT * FROM migo_cust_refdoc INTO ls_cust
             WHERE tcode = lcl_migo_globals=>caller_sytcode.
      CONCATENATE ls_cust-action ls_cust-refdoc 'BWART' INTO l_element.
      CALL METHOD oref_settings->preset( i_element = l_element
        i_active = ls_cust-bwart ).
    ENDSELECT.

* Analysis of the customizing table for defaults when called by ME23
  IF sy-subrc <> 0.                                              "335574
    SELECT * FROM migo_cust_refdoc INTO ls_cust
             WHERE tcode = 'MIGO'.
      CONCATENATE ls_cust-action ls_cust-refdoc 'BWART'
         INTO l_element.
      CALL METHOD oref_settings->preset( i_element = l_element
                                   i_active  = ls_cust-bwart ).
    ENDSELECT.
  ENDIF.

  ENDMETHOD.                    "preset

************************************************************************
* Copy the data from ESDUS to the kernel
************************************************************************
  METHOD data_send_to_kernel.
    DATA: ls_def    TYPE lcl_migo_kernel=>ty_s_defaults,
          l_element TYPE es_element.
* Common control data
    ls_def-take_it_all       = oref_settings->get( 'TAKE_IT_ALL' ).
   ls_def-propose_all_items = oref_settings->get( 'PROPOSE_ALL_ITEMS' ).
*   No serialnumber creation in case of transfer
    If lcl_migo_globals=>kernel->s_action-migo_mode <> 'GT'.
      ls_def-xsaut             = oref_settings->get( 'XSAUT' ).
    ENDIF.
    ls_def-xauto_lines       = oref_settings->get( 'XAUTO_LINES' ).
    ls_def-xbom              = oref_settings->get( 'XBOM' ).
    ls_def-bsskz             = oref_settings->get( 'WM_BSSKZ' ).
    ls_def-tbfkz             = oref_settings->get( 'WM_TBFKZ' ).
    ls_def-xkto              = oref_settings->get( 'XKTO' ).

* Data dependent on the current status
    CASE lcl_migo_globals=>kernel->s_action-migo_mode.           "315434
      WHEN 'GI'.
        ls_def-wever         = oref_settings->get( 'WEVER_WA' ).
      WHEN 'GR'.
        ls_def-wever         = oref_settings->get( 'WEVER_WE' ).
      WHEN 'GO'.
        ls_def-wever         = oref_settings->get( 'WEVER_WF' ).
      WHEN 'GT'.
        ls_def-wever         = oref_settings->get( 'WEVER_WT' ).
      WHEN OTHERS.
        ls_def-wever         = oref_settings->get( 'WEVER_WA' ).
    ENDCASE.                                                "315434
*   Processes which get their data from reference documents
*   (material document, reservation) do not have these defaults.
*   (s_action-copy not initial -> copying of material document)
    IF (                                                          "ERP10
         lcl_migo_globals=>kernel->s_control-new_line_mode IS INITIAL
         OR lcl_migo_globals=>kernel->s_action-copy IS INITIAL
       )                                                          "ERP10
       AND                                                       "409735
       (
         (                                                       "385126
         lcl_migo_globals=>kernel->s_action-refdoctype =
         lcl_migo_globals=>kernel->c_refdoctype_matdoc
       )
*      OR                                                 "385126+429101
*      (
*        lcl_migo_globals=>kernel->s_action-refdoctype =
*        lcl_migo_globals=>kernel->c_refdoctype_reservation
*        )
       OR
        ( lcl_migo_globals=>kernel->s_control-action = 'A11' )
       ).                                                        "409735
      CALL METHOD lcl_migo_globals=>kernel->defaults_set( ls_def ).
      EXIT.
    ENDIF.

* Normal mode of operation
    ls_def-werks  = oref_settings->get( 'WERKS' ).
    ls_def-lgort  = oref_settings->get( 'LGORT' ).
*   If this coding is executed, the movement type is set
*   explicitly. This is stored in BWARTX so that the field on the
*   main screen (dynpro 0010) can be opened.
    ls_def-bwartx = abap_true.                                   "381283
    CONCATENATE lcl_migo_globals=>kernel->s_control-action
                lcl_migo_globals=>kernel->s_control-refdoc
                'BWART' INTO l_element.
    ls_def-bwart = oref_settings->get( l_element ).
    CONCATENATE lcl_migo_globals=>kernel->s_control-action
                lcl_migo_globals=>kernel->s_control-refdoc
                'SOBKZ' INTO l_element.
    ls_def-sobkz = oref_settings->get( l_element ).
    CONCATENATE lcl_migo_globals=>kernel->s_control-action
                lcl_migo_globals=>kernel->s_control-refdoc
                'INSMK' INTO l_element.
    ls_def-insmk = oref_settings->get( l_element ).

* New positions
    IF lcl_migo_globals=>kernel->s_control-new_line_mode = p.
      ls_def-bwart = oref_settings->get( 'BWART_NEW' ).
      ls_def-sobkz = space.
      ls_def-insmk = space.
    ENDIF.
* Container
    IF lcl_migo_globals=>kernel->s_control-new_line_mode = c.
      ls_def-bwart = oref_settings->get( 'BWART_CONTAINER' ).
      ls_def-sobkz = oref_settings->get( 'SOBKZ_CONTAINER' ).
      ls_def-insmk = space.
    ENDIF.
* Copy data
    CALL METHOD lcl_migo_globals=>kernel->defaults_set( ls_def ).
  ENDMETHOD.                    "data_send_to_kernel

************************************************************************
* Mode change of the kernel --> Remap BWART, WERKS, LGORT, SOBKZ, ...
************************************************************************
  METHOD lif_migo_frame~message_handler.
    DATA: l_wever TYPE wever,                                    "315434
          l_mvt   TYPE bwart,                                    "379268
          l_sobkz TYPE sobkz.
    CASE i_message_id.
      WHEN 'KERNEL_MODE_CHANGED'.
        CALL METHOD data_send_to_kernel.
      WHEN 'HEADER_WEVER_CHANGED'.                               "315434
*       update WEVER in ESDUS and send data to kernel
        l_wever = is_message-data1.
        CALL METHOD defaults_update_wever
          EXPORTING
            i_wever = l_wever.
        CALL METHOD data_send_to_kernel.
      WHEN 'FIRSTLINE_MVT_CHANGED'.
*       update movement type and special stock in ESDUS, send data to
*       kernel + send tip
        l_mvt   = is_message-data1.
        l_sobkz = is_message-data2.
        CALL METHOD defaults_update_bwart_sobkz
          EXPORTING
            i_mvt   = l_mvt
            i_sobkz = l_sobkz.
        CALL METHOD data_send_to_kernel.
        def_sms 'MIGO_TIP_REQUEST' 'HELP_DEFAULTS_CHANGED' space.
      WHEN OTHERS.
ENHANCEMENT-POINT MESSAGE_HANDLER_01 SPOTS ES_SAPLMIGO.


    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~message_handler

ENHANCEMENT-POINT LMIGODE2_01 SPOTS ES_SAPLMIGO STATIC.

************************************************************************
* Ok-code handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    CASE i_okcode.
      WHEN 'OK_DEFVALS'.
        CALL METHOD defaults_popup.
      WHEN 'OK_DEF_TRA'.
        CALL METHOD transfer_defaults_popup.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

************************************************************************
* Send the popup with the user defaults
************************************************************************
  METHOD defaults_popup.
    DEFINE def_godefault_purge.
      clear godefault-&1.
      clear ls_godefault-&1.
    END-OF-DEFINITION.

    DATA: ls_godefault TYPE godefault,
          ls_tv        TYPE godefault_tv,
          lt_tv_new    TYPE STANDARD TABLE OF godefault_tv.
    CALL METHOD godefault_fill.
    ls_godefault = godefault.
    pt_tv_old    = pt_tv.
    CALL SCREEN 1100 STARTING AT 5 5.
    IF sy-ucomm = 'OK_DEF_GO'.
*   To check whether there has been a change, irrelevant fields
*   have to be masked out.
      def_godefault_purge def_bwtxt_new.
      def_godefault_purge def_bwtxt_container.
      def_godefault_purge def_name1.
      def_godefault_purge def_lgobe.
      MODIFY pt_tv_old FROM ls_tv TRANSPORTING bwtxt
                       WHERE bwtxt <> space.
      lt_tv_new = pt_tv.
      MODIFY lt_tv_new FROM ls_tv TRANSPORTING bwtxt
                       WHERE bwtxt <> space.
      CHECK godefault <> ls_godefault OR lt_tv_new <> pt_tv_old.
      CALL METHOD defaults_update.
      CALL METHOD data_send_to_kernel.
      def_sms 'MIGO_TIP_REQUEST' 'HELP_DEFAULTS_CHANGED' space.
      MESSAGE s016.
    ENDIF.
  ENDMETHOD.                    "defaults_popup

************************************************************************
* Fill structure GODEFAULT with the current user defaults
************************************************************************
  METHOD godefault_fill.
    DATA: ls_tv     TYPE godefault_tv,
          l_element TYPE es_element,
          ls_cust   TYPE lcl_migo_globals=>ty_s_cust.
* Default values from database
    godefault-def_werks           = oref_settings->get( 'WERKS' ).
    godefault-def_lgort           = oref_settings->get( 'LGORT' ).
    godefault-def_bwart_new       = oref_settings->get( 'BWART_NEW' ).
    godefault-def_bwart_container =
                            oref_settings->get( 'BWART_CONTAINER' ).
    godefault-def_sobkz_container =
                            oref_settings->get( 'SOBKZ_CONTAINER' ).
    godefault-take_it_all         = oref_settings->get( 'TAKE_IT_ALL' ).
    godefault-propose_all_items   =
                            oref_settings->get( 'PROPOSE_ALL_ITEMS' ).
    godefault-def_xsaut           = oref_settings->get( 'XSAUT' ).
    godefault-def_xbom            = oref_settings->get( 'XBOM' ).
    godefault-def_wm_bsskz        = oref_settings->get( 'WM_BSSKZ' ).
    godefault-def_wm_tbfkz        = oref_settings->get( 'WM_TBFKZ' ).
    godefault-def_xauto_lines     = oref_settings->get( 'XAUTO_LINES' ).
    godefault-def_xkto            = oref_settings->get( 'XKTO' ).

*   More complicated: Creation of the table with default values
*   depending on ACTION and REFDOC. The table only shows the valid
*   combinations.
    CLEAR pt_tv.
    LOOP AT lcl_migo_globals=>t_cust INTO ls_cust.
*     Processes which get their data from reference documents
*     (material document) do not have these defaults.
*     Reservations allow entering new items, which will need the
*     defaults.
      IF 'R02 R03' CS ls_cust-refdoc OR                          "409735
*        no defaults for subsequent adjustment
         ls_cust-action = 'A11'.
        CONTINUE.
      ENDIF.
      ls_tv-action = ls_cust-action.
      ls_tv-refdoc = ls_cust-refdoc.
      CONCATENATE ls_tv-action ls_tv-refdoc 'BWART' INTO l_element.
      ls_tv-bwart  = oref_settings->get( l_element ).
      CONCATENATE ls_tv-action ls_tv-refdoc 'SOBKZ' INTO l_element.
      ls_tv-sobkz  = oref_settings->get( l_element ).
      CONCATENATE ls_tv-action ls_tv-refdoc 'INSMK' INTO l_element.
      ls_tv-insmk  = oref_settings->get( l_element ).
      APPEND ls_tv TO pt_tv.
    ENDLOOP.
* Start with the current action/refdoc from the kernel.
    READ TABLE pt_tv WITH KEY
         action = lcl_migo_globals=>kernel->s_control-action
         refdoc = lcl_migo_globals=>kernel->s_control-refdoc
         TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      tv_godefault-top_line = sy-tabix.
      CALL METHOD lcl_migo_cursor=>cursor_set
        EXPORTING
          i_oref_screenobject = me
          i_field             = 'GODEFAULT_TV-BWART'
          i_stepl             = 1.
    ENDIF.
  ENDMETHOD.                    "godefault_fill

************************************************************************
* PBO
************************************************************************
  METHOD pbo.
* PBO-Functions from superclass (cursor handling, SFAC).
    CALL METHOD super->pbo.
* Local screen modification
    CALL METHOD screen_modify_local.
    SET PF-STATUS 'DEFAULTS_POPUP'.
    SET TITLEBAR  'DEFAULTS_POPUP'.
* Read texts
    godefault-def_name1 =
       lcl_migo_buffer=>plant_name_get( godefault-def_werks ).
    godefault-def_lgobe =
       lcl_migo_buffer=>sloc_name_get( i_werks = godefault-def_werks
                                       i_lgort = godefault-def_lgort ).
    CALL METHOD lcl_migo_buffer=>move_type_text_get
      EXPORTING
        i_move      = godefault-def_bwart_new
      RECEIVING
        e_move_text = godefault-def_bwtxt_new
      EXCEPTIONS
        OTHERS      = 1.
    CALL METHOD lcl_migo_buffer=>move_type_text_get
      EXPORTING
        i_move       = godefault-def_bwart_container
        i_spec_stock = godefault-def_sobkz_container
      RECEIVING
        e_move_text  = godefault-def_bwtxt_container
      EXCEPTIONS
        OTHERS       = 1.
*   Tableview
    DESCRIBE TABLE pt_tv LINES tv_godefault-lines.
  ENDMETHOD.                    "pbo

************************************************************************
* PAI
* Handle SY-UCOMM
************************************************************************
  METHOD pai.
    CALL METHOD super->pai.
* Evaluate SY-UCOMM
    CASE sy-ucomm.
      WHEN 'OK_DEF_GO'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'MIGO_OK_TIP_RESET'.
        def_sms 'MIGO_TIP_RESET' space space.
    ENDCASE.
  ENDMETHOD.                    "pai

************************************************************************
* Exit-command: Return to the caller.
************************************************************************
  METHOD exit_command.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDMETHOD.                    "exit_command

************************************************************************
* Write the data from GODYNPRO to the user defaults
************************************************************************
  METHOD defaults_update.
    DATA: ls_tv     TYPE godefault_tv,
          ls_tv_old TYPE godefault_tv,
          l_element TYPE es_element.
    DEFINE d_set.
      call method oref_settings->set( i_element = &1
        i_active = &2 ).
    END-OF-DEFINITION.

    d_set 'WERKS'                       godefault-def_werks.
    d_set 'LGORT'                       godefault-def_lgort.
    d_set 'BWART_NEW'                   godefault-def_bwart_new.
    d_set 'BWART_CONTAINER'             godefault-def_bwart_container.
    d_set 'SOBKZ_CONTAINER'             godefault-def_sobkz_container.
    d_set 'TAKE_IT_ALL'                 godefault-take_it_all.
    d_set 'PROPOSE_ALL_ITEMS'           godefault-propose_all_items.
    d_set 'XSAUT'                       godefault-def_xsaut.
    d_set 'XBOM'                        godefault-def_xbom.
    d_set 'WM_BSSKZ'                    godefault-def_wm_bsskz.
    d_set 'WM_TBFKZ'                    godefault-def_wm_tbfkz.
    d_set 'XAUTO_LINES'                 godefault-def_xauto_lines.
    d_set 'XKTO'                        godefault-def_xkto.
*  Create entries for the ACTION/REFDOC-dependent settings
*  only if really changed with respect to the prior settings.
    LOOP AT pt_tv INTO ls_tv.
      READ TABLE pt_tv_old INTO ls_tv_old
                 WITH KEY action = ls_tv-action
                          refdoc = ls_tv-refdoc.
      IF ls_tv <> ls_tv_old.
        CONCATENATE ls_tv-action ls_tv-refdoc 'BWART' INTO l_element.
        d_set l_element ls_tv-bwart.
        CONCATENATE ls_tv-action ls_tv-refdoc 'SOBKZ' INTO l_element.
        d_set l_element ls_tv-sobkz.
        CONCATENATE ls_tv-action ls_tv-refdoc 'INSMK' INTO l_element.
        d_set l_element ls_tv-insmk.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "defaults_update
************************************************************************
* Write WEVER (send by lcl_header_general) to the user defaults 315434
************************************************************************
  METHOD defaults_update_wever.                                  "315434
    DEFINE d_set.
      call method oref_settings->set( i_element = &1
        i_active = &2 ).
    END-OF-DEFINITION.
    CASE lcl_migo_globals=>kernel->s_action-migo_mode.
      WHEN 'GI'.
        d_set 'WEVER_WA'                     i_wever.
      WHEN 'GR'.
        d_set 'WEVER_WE'                     i_wever.
      WHEN 'GO'.
        d_set 'WEVER_WF'                     i_wever.
      WHEN 'GT'.
        d_set 'WEVER_WT'                     i_wever.
      WHEN OTHERS.
        d_set 'WEVER_WA'                     i_wever.
    ENDCASE.
  ENDMETHOD.                    "defaults_update_wever

***********************************************************************
* Write movement type and special stock to user defaults
***********************************************************************
  METHOD defaults_update_bwart_sobkz.
    DATA: l_element_mvt   TYPE es_element,
          l_element_sobkz type es_element.
*   New positions
    IF lcl_migo_globals=>kernel->s_control-new_line_mode = p.
      l_element_mvt   = 'BWART_NEW'.
      l_element_sobkz = 'SOBKZ_NEW'.
*   Container
    ELSEIF lcl_migo_globals=>kernel->s_control-new_line_mode = c.
      l_element_mvt   = 'BWART_CONTAINER'.
      l_element_sobkz = 'SOBKZ_CONTAINER'.
*   Normal position
    ELSE.
      CONCATENATE lcl_migo_globals=>kernel->s_control-action
                  lcl_migo_globals=>kernel->s_control-refdoc
                  'BWART' INTO l_element_mvt.
      CONCATENATE lcl_migo_globals=>kernel->s_control-action
                  lcl_migo_globals=>kernel->s_control-refdoc
                  'SOBKZ' INTO l_element_sobkz.
    ENDIF.
    CALL METHOD oref_settings->set( i_element = l_element_mvt
                                    i_active  = i_mvt ).

    CALL METHOD oref_settings->set( i_element = l_element_sobkz
                                    i_active  = i_sobkz ).
  ENDMETHOD.


************************************************************************
* Local screen modification: Disable the entries for new lines
* according to the data read from dynpro 0200
************************************************************************
  METHOD screen_modify_local.
    DATA: l_container TYPE abap_bool,
          l_newpos    TYPE abap_bool.
    IF lcl_migo_screenmodification=>get(
       i_field = 'OK_NOT_ORDERED' ) >=
       lcl_migo_screenmodification=>c_input.              "#EC PORTABLE
      l_newpos = abap_true.
    ENDIF.
    IF lcl_migo_screenmodification=>get(
       i_field = 'OK_CONTAINER' ) >=
       lcl_migo_screenmodification=>c_input.              "#EC PORTABLE
      l_container = abap_true.
    ENDIF.
    LOOP AT SCREEN.
      CASE screen-group2.
        WHEN 'D02'.
*       Entire section for not oredered positions
          IF l_container   = abap_false AND
             l_newpos      = abap_false.
            screen-invisible = c_mod_on.
            screen-input     = c_mod_off.
          ENDIF.
        WHEN 'D03'.
*       Movement type for material
          IF l_newpos = abap_false.
            screen-invisible = c_mod_on.
            screen-input     = c_mod_off.
          ENDIF.
        WHEN 'D04'.
*       Movement type for container
          IF l_container = abap_false.
            screen-invisible = c_mod_on.
            screen-input     = c_mod_off.
          ENDIF.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.                    "screen_modify_local

************************************************************************
* PBO for table control
************************************************************************
  METHOD pbo_loop.
    READ TABLE pt_tv INTO godefault_tv INDEX tv_godefault-current_line.
    IF sy-subrc <> 0.
      EXIT FROM STEP-LOOP.
    ENDIF.
    CALL METHOD lcl_migo_buffer=>move_type_text_get
      EXPORTING
        i_move       = godefault_tv-bwart
        i_spec_stock = godefault_tv-sobkz
      RECEIVING
        e_move_text  = godefault_tv-bwtxt
      EXCEPTIONS
        OTHERS       = 1.
  ENDMETHOD.                    "pbo_loop

************************************************************************
* PAI for table control
************************************************************************
  METHOD pai_loop.
    MODIFY pt_tv FROM godefault_tv INDEX tv_godefault-current_line.
  ENDMETHOD.                    "pai_loop

ENDCLASS.                    "lcl_migo_defaults IMPLEMENTATION