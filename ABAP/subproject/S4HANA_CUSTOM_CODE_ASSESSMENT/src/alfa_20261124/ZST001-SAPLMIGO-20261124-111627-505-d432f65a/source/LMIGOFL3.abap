*----------------------------------------------------------------------*
*   INCLUDE LMIGOFL3                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Constructor.
************************************************************************
METHOD constructor.
  DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes,
        lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids,
        lt_sending     TYPE lif_migo_frame=>ty_t_message_ids,
        l_action       TYPE goaction,
        l_refdoc       TYPE refdoc.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  lif_migo_frame~class_id = 'MIGO_FIRSTLINE'.
* Register the OK-codes
  APPEND 'MIGO_OK_ACTION'       TO lt_okcodes.
  APPEND 'MIGO_OK_REFDOC'       TO lt_okcodes.
  APPEND 'MIGO_OK_GO'           TO lt_okcodes.
  APPEND 'MIGO_OK_SEARCH'       TO lt_okcodes.
  APPEND 'MIGO_OK_FIRSTLINE_LO' TO lt_okcodes.

  APPEND 'KERNEL_RESET'           TO lt_receiving.
  APPEND 'NEW_DOCUMENT'           TO lt_receiving.
  APPEND 'SEARCH_HAS_NEW_MATDOC'  TO lt_receiving.
  APPEND 'KERNEL_MODE_CHANGED'    TO lt_receiving.
  APPEND 'KERNEL_STATUS_CHANGED'  TO lt_receiving.
  APPEND 'KERNEL_DOC_LOGLEVEL'    TO lt_receiving.
  APPEND 'SEARCHLIST_BUTTON'      TO lt_receiving.

  APPEND 'MIGO_START_SEARCH_PO'  TO lt_sending.
  APPEND 'MIGO_START_SEARCH_MD'  TO lt_sending.
  APPEND 'MIGO_START_SEARCH_ORD' TO lt_sending.
  APPEND 'MIGO_START_SEARCH_RES' TO lt_sending.
  APPEND 'FIRSTLINE_MVT_CHANGED' TO lt_sending.             "379268
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes
      it_receiving  = lt_receiving
      it_sending    = lt_sending.
* Create the user-defaults object and set the factory defaults
  CREATE OBJECT poref_settings EXPORTING i_action = 'MIGO_FIRSTLINE'.
  CALL METHOD settings_preset.
  CALL METHOD listbox_action_set.
* Get the last action and the according refdoc,
  l_action = poref_settings->get( 'ACTION' ).
  l_refdoc = poref_settings->get( l_action ).
* Check whether the combination is allowed. If not, go back to
* "Display material document".
  READ TABLE lcl_migo_globals=>t_cust WITH KEY action = l_action
                                               refdoc = l_refdoc
                                               TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    l_action = 'A04'.
    l_refdoc = 'R02'.
  ENDIF.
* Send the data to the kernel.
* Note that P_ACTION and P_REFDOC are not set here. This will occur
* if the kernel propagates the mode change.
  CALL METHOD data_send_to_kernel
    EXPORTING
      i_action = l_action
      i_refdoc = l_refdoc.
ENDMETHOD.                    "constructor

************************************************************************
* A set of data is sent to the kernel
************************************************************************
METHOD data_send_to_kernel.
  DATA: ls_control   TYPE lcl_migo_kernel=>ty_s_control,
        l_need_reset TYPE abap_bool.
  ls_control = lcl_migo_globals=>kernel->s_control.
* If there is a change of ACTION/REFDOC, execute a kernel reset
  IF ls_control-action <> i_action OR ls_control-refdoc <> i_refdoc.
    l_need_reset = abap_true.
  ENDIF.
* Set the new mode
  ls_control-action = i_action.
  ls_control-refdoc = i_refdoc.
  CALL METHOD lcl_migo_globals=>kernel->mode_set
    EXPORTING
      is_control = ls_control.
  IF l_need_reset = abap_true.
    CALL METHOD lcl_migo_globals=>kernel->reset.
  ENDIF.
ENDMETHOD.                    "data_send_to_kernel
************************************************************************
* Presets for the listboxes (which REFDOC per ACTION).
* These are used if there are no user-specific entries yet.
************************************************************************
METHOD settings_preset.
  DEFINE def_settings_preset.
    call method poref_settings->preset( i_element = &1
      i_active = &2 ).
  END-OF-DEFINITION.
* Default action is "Goods receipt" except in GI transaction
  CASE lcl_migo_globals=>caller_sytcode.
    WHEN 'MIGO_GI'.
      def_settings_preset 'ACTION' 'A07'.
    WHEN 'MIGO_GS'.
      def_settings_preset 'ACTION' 'A11'.
    WHEN 'MIGO_TR'.
      def_settings_preset 'ACTION' 'A08'.
    WHEN OTHERS.
      def_settings_preset 'ACTION' 'A01'.
  ENDCASE.
* Default refdocs for the actions
* MARKER_NEW_ACTION
* MARKER_NEW_REFDOC
  def_settings_preset 'A01' 'R01'.
  def_settings_preset 'A02' 'R02'.
  def_settings_preset 'A03' 'R02'.
  def_settings_preset 'A04' 'R02'.
  def_settings_preset 'A05' 'R02'.
  def_settings_preset 'A06' 'R02'.
  def_settings_preset 'A07' 'R09'.
  def_settings_preset 'A08' 'R10'.
  def_settings_preset 'A09' 'R10'.
  def_settings_preset 'A10' 'R02'.
  def_settings_preset 'A11' 'R01'.

ENDMETHOD.                    "settings_preset
************************************************************************
* OK-code handler
************************************************************************
METHOD lif_migo_frame~okcode_handler.
  DATA: l_action        TYPE goaction,
        l_refdoc        TYPE refdoc,
        l_history       TYPE string,                        "383269
        ls_key          TYPE lcl_migo_kernel=>ty_s_refdockey,
        l_nothing_found TYPE abap_bool,
        ls_cust         TYPE lcl_migo_globals=>ty_s_cust,
        cl_change TYPE  REF TO /sappspro/cl_numbers,
        lf_active TYPE boolean.

  CASE i_okcode.
    WHEN 'MIGO_OK_ACTION'.
      l_action = godynpro-action.
      l_refdoc = poref_settings->get( l_action ).
*     Check the combination for validity. If invalid, choose
*     any allowed entry for the second listbox.
      READ TABLE lcl_migo_globals=>t_cust
                 WITH KEY action = l_action
                          refdoc = l_refdoc
                          TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        READ TABLE lcl_migo_globals=>t_cust INTO ls_cust
                   WITH KEY action = l_action.
        l_refdoc = ls_cust-refdoc.
      ENDIF.
*     Update field history data
      l_history = poref_settings->get( 'ACTION_HISTORY' ).  "383269
      REPLACE l_action WITH space INTO l_history.           "383269
      CONCATENATE l_history l_action INTO l_history         "383269
                  SEPARATED BY space.                       "383269
      CONDENSE l_history.                                   "383269
      CALL METHOD poref_settings->set( i_element = 'ACTION_HISTORY'
        i_active = l_history ).  "383269
      CALL METHOD listbox_action_set.                            "383269
*     Update current entries
      CALL METHOD poref_settings->set( i_element = 'ACTION'
        i_active = l_action ).
      CALL METHOD poref_settings->set( i_element = l_action
        i_active = l_refdoc ).
      CALL METHOD data_send_to_kernel( i_action = l_action
        i_refdoc = l_refdoc ).
    WHEN 'MIGO_OK_REFDOC'.
      l_action = godynpro-action.
      l_refdoc = godynpro-refdoc.
      CALL METHOD poref_settings->set( i_element = l_action
        i_active = l_refdoc ).
      CALL METHOD data_send_to_kernel( i_action = l_action
        i_refdoc = l_refdoc ).
    WHEN 'MIGO_OK_SEARCH'.
      CASE p_refdoc.
        WHEN 'R01'. def_sms 'MIGO_START_SEARCH_PO'  space space.
        WHEN 'R02'. def_sms 'MIGO_START_SEARCH_MD'  space space.
        WHEN 'R08'. def_sms 'MIGO_START_SEARCH_ORD' space space.
        WHEN 'R09'. def_sms 'MIGO_START_SEARCH_RES' space space.
      ENDCASE.
    WHEN 'MIGO_OK_FIRSTLINE_LO'.
      CALL METHOD oref_doc_log->display.
    WHEN 'MIGO_OK_GO'.
*     Check that there is something to do
      CASE p_refdoc.
        WHEN 'R01'.
          CLEAR: lf_active.
          CREATE OBJECT cl_change.

          CALL METHOD cl_change->is_active
            RECEIVING
              rv_active = lf_active.

          IF lf_active = 'X'.
            TRY.
                godynpro-po_number =
                /sappspro/cl_numbers=>lookup_by_longnum( godynpro-longnum ).
              CATCH /sappspro/cx_number_not_found.
*             number does not exist.
                IF STRLEN( godynpro-longnum ) LE 10.
*interprete the number as an internal number and pass it to the
*application that
* is then responsible for error checking
                  WRITE godynpro-longnum TO godynpro-po_number.
                ELSE.
                  MESSAGE s019(06) DISPLAY LIKE 'E' WITH godynpro-longnum.
                ENDIF.

            ENDTRY.
          ENDIF.
ENHANCEMENT-POINT LMIGOFL3_01 SPOTS ES_SAPLMIGO.
          CHECK NOT godynpro-po_number         IS INITIAL.

        WHEN 'R02'.
          CHECK ( godynpro-mat_doc  <> p_last_mblnr OR
                  godynpro-doc_year <> p_last_mjahr ) AND
                  NOT godynpro-mat_doc IS INITIAL.
        WHEN 'R03'. CHECK NOT godynpro-delivery_note     IS INITIAL.
        WHEN 'R04'.
          CHECK NOT godynpro-inbound_delivery  IS INITIAL OR
                NOT godynpro-shipping_unit     IS INITIAL.
        WHEN 'R05'.
          CHECK NOT godynpro-outbound_delivery IS INITIAL OR
                NOT godynpro-shipping_unit     IS INITIAL.
        WHEN 'R06'. CHECK NOT godynpro-transport         IS INITIAL.
        WHEN 'R07'. CHECK NOT godynpro-transportident    IS INITIAL.
        WHEN 'R08'. CHECK NOT godynpro-order_number      IS INITIAL.
        WHEN 'R09'.
          CHECK NOT godynpro-reservation_number IS INITIAL.
        WHEN 'R10'. EXIT.
      ENDCASE.
*     Copy reference document numbers
      ls_key-po_number          = godynpro-po_number.
      ls_key-po_item            = godynpro-po_item.
      ls_key-po_werks           = godynpro-po_werks.
      ls_key-mat_doc            = godynpro-mat_doc.
      ls_key-doc_year           = godynpro-doc_year.
      ls_key-delivery_note      = godynpro-delivery_note.
      ls_key-inbound_delivery   = godynpro-inbound_delivery.
      ls_key-outbound_delivery  = godynpro-outbound_delivery.
      ls_key-shipping_unit      = godynpro-shipping_unit.
      ls_key-transport          = godynpro-transport.
      ls_key-transportident     = godynpro-transportident.
      ls_key-transport_means    = godynpro-transport_means.
      ls_key-order_number       = godynpro-order_number.
      ls_key-order_item         = godynpro-order_item.
      ls_key-order_operation    = godynpro-order_operation.
      ls_key-reservation_number = godynpro-reservation_number.
      ls_key-reservation_item   = godynpro-reservation_item.
*     Call the central reading routine (with error handling)
      CALL METHOD lcl_migo_globals=>kernel->ref_document_read
        EXPORTING
          i_refdoc        = p_refdoc
          is_key          = ls_key
        IMPORTING
          e_nothing_found = l_nothing_found.
*     Delete the number only if the reading was successful
      CHECK l_nothing_found = abap_false.
      CASE p_refdoc.
        WHEN 'R01'.
          CLEAR: godynpro-po_number, godynpro-po_item.
          IF lf_active = 'X'.
            CLEAR godynpro-longnum.
          ENDIF.
        WHEN 'R02'.
          p_last_mblnr = godynpro-mat_doc.
          p_last_mjahr = godynpro-doc_year.
*         Delete number in case of GM w. reference to a mat. doc.
*         When migo is being called via migo_dialog, godynpro-action
*         may not be filled -> 'A01 A07 A08 A09' CS godynpro-action
*         does not work.                               "824810
          IF godynpro-action = 'A01' OR                "ERP 10
             godynpro-action = 'A07' OR
             godynpro-action = 'A08' OR
             godynpro-action = 'A09'.
            CLEAR: godynpro-mat_doc,
                   godynpro-doc_year.
          ENDIF.

        WHEN 'R03'. CLEAR godynpro-delivery_note.
        WHEN 'R04'.
          CLEAR: godynpro-inbound_delivery,
                 godynpro-shipping_unit.
        WHEN 'R05'.
          CLEAR: godynpro-outbound_delivery,
                 godynpro-shipping_unit.
        WHEN 'R06'. CLEAR godynpro-transport.
        WHEN 'R07'. CLEAR godynpro-transportident.
        WHEN 'R08'.
          CLEAR: godynpro-order_number,
                 godynpro-order_item.
        WHEN 'R09'.
          CLEAR: godynpro-reservation_number,
                 godynpro-reservation_item.
      ENDCASE.
  ENDCASE.
ENDMETHOD.                    "lif_migo_frame~okcode_handler
************************************************************************
* Message handler
* If KERNEL_RESET, the current material document can be reread -->
* delete markup data.
* If a new material document came in, set the dynpro-fields.
* The whole mess is caused by the SET/GET of MBLNR....
* IF the kernel has changed the mode, update P_ACTION and P_REFDOC.

************************************************************************
METHOD lif_migo_frame~message_handler.
  DATA: ls_message TYPE lif_migo_frame~ty_s_message.
  FIELD-SYMBOLS: <ls_key>     TYPE lcl_migo_kernel=>ty_s_refdockey,
                 <l_loglevel> TYPE migo_loglevel.
  CASE i_message_id.
    WHEN 'KERNEL_RESET'.
      CLEAR p_last_mblnr.
      CLEAR p_last_mjahr.
      CLEAR p_firstline_log.
      p_locked = abap_false.
      CALL METHOD cursor_set.
    WHEN 'NEW_DOCUMENT'.
      CHECK is_message-data1 = 'R02'.
      ASSIGN is_message-dref->* TO <ls_key>.
      p_last_mblnr = godynpro-mat_doc  = <ls_key>-mat_doc.
      p_last_mjahr = godynpro-doc_year = <ls_key>-doc_year.
    WHEN 'SEARCH_HAS_NEW_MATDOC'.
      godynpro-mat_doc = is_message-data1.
      godynpro-doc_year = is_message-data2.
    WHEN 'KERNEL_MODE_CHANGED'.
      CALL METHOD mode_change_handler.
    WHEN 'SEARCHLIST_BUTTON'.
      p_searchlist_button = is_message-data1.
    WHEN 'KERNEL_STATUS_CHANGED'.
*     As soon as lines are inserted into the model, the listboxes are
*     locked. To be released upon KERNEL_RESET.
      IF lcl_migo_globals=>kernel->s_status-lines > 0.
        p_locked = abap_true.
      ENDIF.
    WHEN 'KERNEL_DOC_LOGLEVEL'.
*     Get error level.
*     If anything available, write highest error into the quickinfo
      ASSIGN is_message-dref->* TO <l_loglevel>.
      p_firstline_log = <l_loglevel>.

*        case is_message-data1.
*          when icon_green_light.  p_firstline_log = '@08\Q'.
*          when icon_yellow_light. p_firstline_log = '@09\Q'.
*          when icon_red_light.    p_firstline_log = '@0A\Q'.
*        endcase.
*        MESSAGE ID <ls_msg>-MSGID TYPE <ls_msg>-msgty
*                 NUMBER <ls_msg>-MSGNO
*                 WITH <ls_msg>-MSGV1 <ls_msg>-MSGV2
*                      <ls_msg>-MSGV3 <ls_msg>-MSGV4
*                 into l_msgtext.
**       Maximum allowed length: 70 - [ @XX\Q@ ]
*        l_msgtext = l_msgtext(64).
*        concatenate p_firstline_log l_msgtext '@'
*                    into p_firstline_log.
*      endif.
  ENDCASE.
ENDMETHOD.                    "lif_migo_frame~message_handler

************************************************************************
* The current mode of the kernel has been changed.
* Read the new data and prepare the listbox for REFDOC.
************************************************************************
METHOD mode_change_handler.
* Get data
  p_action = lcl_migo_globals=>kernel->s_control-action.
  p_refdoc = lcl_migo_globals=>kernel->s_control-refdoc.
* Create entries for the REFDOC-listbox
  CALL METHOD listbox_refdoc_set.
* Select the proper subscreen for the REFDOC-field
  CASE p_refdoc.
    WHEN 'R01'.
      DATA cl_change TYPE REF TO /sappspro/cl_numbers.
      DATA lf_active TYPE boolean.

      CLEAR: lf_active.
      CREATE OBJECT cl_change.
      CALL METHOD cl_change->is_active
        RECEIVING
          rv_active = lf_active.

      IF lf_active = 'X'.
        g_firstline_subscreen = '2001'.
      ELSE.
        g_firstline_subscreen = '2000'.
      ENDIF.
ENHANCEMENT-POINT LMIGOFL3_02 SPOTS ES_SAPLMIGO.
    WHEN 'R02'.  g_firstline_subscreen = '2010'.
    WHEN 'R03'.  g_firstline_subscreen = '2020'.
    WHEN 'R04'.  g_firstline_subscreen = '2030'.
    WHEN 'R05'.  g_firstline_subscreen = '2040'.
    WHEN 'R06'.  g_firstline_subscreen = '2050'.
    WHEN 'R07'.  g_firstline_subscreen = '2060'.
    WHEN 'R08'.  g_firstline_subscreen = '2070'.
    WHEN 'R09'.  g_firstline_subscreen = '2080'.
    WHEN 'R10'.  g_firstline_subscreen = '2099'.  "there is no refdoc
    WHEN OTHERS. g_firstline_subscreen = '2099'.  "dummy for others
  ENDCASE.
ENDMETHOD.                    "mode_change_handler