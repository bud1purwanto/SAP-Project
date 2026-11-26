*----------------------------------------------------------------------*
*   INCLUDE LMIGODC2                                                   *
*   Detail carrier
*----------------------------------------------------------------------*

CLASS lcl_migo_detail IMPLEMENTATION.

************************************************************************
* Constructor:
* Register for the OK-codes and messages manipulating the
* shown data
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes     TYPE lif_migo_frame=>ty_t_okcodes,
          lt_receiving   TYPE lif_migo_frame=>ty_t_message_ids,
          lt_sending     TYPE lif_migo_frame=>ty_t_message_ids.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    lif_migo_frame~class_id = 'MIGO_DETAIL'.
    APPEND 'MIGO_OK_PREV_IT'        TO lt_okcodes.
    APPEND 'MIGO_OK_NEXT_IT'        TO lt_okcodes.
    APPEND 'MIGO_OK_LOCATE'         TO lt_okcodes.
    APPEND 'MIGO_OK_COPY'           TO lt_okcodes.
    APPEND 'KERNEL_MODE_CHANGED'    TO lt_receiving.
    APPEND 'KERNEL_RESET'           TO lt_receiving.
    APPEND 'ITEMDETAIL_LINE_SET'    TO lt_receiving.
    APPEND 'MODEL_CHANGE_BEGIN'     TO lt_receiving.
    APPEND 'MODEL_CHANGE_COMPLETE'  TO lt_receiving.
    APPEND 'ITEMDETAIL_OPEN'        TO lt_receiving.
    APPEND 'GA_OPEN'                TO lt_receiving.
    APPEND 'ITEMDETAIL_CURRENTLINE' TO lt_sending.
    APPEND 'TABLEVIEW_LINE_SET'     TO lt_sending.
ENHANCEMENT-POINT lmigodc2_01 SPOTS es_saplmigo.
    CALL METHOD lcl_migo_frame=>viewer_register
      EXPORTING
        i_iref_viewer = me
        it_okcodes    = lt_okcodes
        it_receiving  = lt_receiving
        it_sending    = lt_sending.
    CREATE OBJECT poref_settings
      EXPORTING
        i_action = 'MIGO_DETAIL'.
  ENDMETHOD.                    "constructor

************************************************************************
* Includes
************************************************************************
  INCLUDE: lmigodc3.

************************************************************************
* Message handler
************************************************************************
  METHOD lif_migo_frame~message_handler.
    DATA: l_new_mode TYPE char1.
    CASE i_message_id.
      WHEN 'ITEMDETAIL_LINE_SET'.
        current_line = is_message-data1.
        CALL METHOD lcl_migo_globals=>kernel->ga_buttons_fieldselection
          EXPORTING
            i_line = current_line.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
      WHEN 'MODEL_CHANGE_BEGIN'.
        CALL METHOD lcl_migo_globals=>kernel->line_mapping
          EXPORTING
            i_line           = current_line
          IMPORTING
            e_global_counter = p_global_counter
          EXCEPTIONS
            OTHERS           = 1.
      WHEN 'MODEL_CHANGE_COMPLETE'.
        CALL METHOD lcl_migo_globals=>kernel->line_mapping
          EXPORTING
            i_global_counter = p_global_counter
          IMPORTING
            e_line           = current_line
          EXCEPTIONS
            not_found        = 1.
        IF sy-subrc <> 0.
          current_line = 1.
        ENDIF.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
      WHEN 'KERNEL_MODE_CHANGED'.
        IF is_message-data1 <> is_message-data2 AND
           is_message-data2 = 'GT'.
          CALL METHOD poref_settings->set( i_element = 'ACTIVE_TAB'
            i_active = 'OK_GOITEM_TRANS' ).
        ENDIF.
        l_new_mode = lcl_migo_globals=>kernel->s_control-new_line_mode.
        IF p_last_new_line_mode <> l_new_mode AND
           ( p_last_new_line_mode = space OR l_new_mode = space ).
          CASE l_new_mode.
            WHEN p OR c OR x.
*           If the new line mode has been activated now, position the
*           viewer to the first line behind the last line in the model.
              current_line =
              lcl_migo_globals=>kernel->s_status-lines + 1.
            WHEN space.
*           If it has just been deactivated, move to the last line, if
*           we are on the right side of the model.
              IF current_line >
                lcl_migo_globals=>kernel->s_status-lines.
                current_line = lcl_migo_globals=>kernel->s_status-lines.
              ENDIF.
*           If no lines at all, go back to 1 (default)
              IF current_line = 0.
                current_line = 1.
              ENDIF.
          ENDCASE.
          def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
        ENDIF.
        p_last_new_line_mode = l_new_mode.
      WHEN 'KERNEL_RESET'.
        current_line = 1.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
      WHEN 'ITEMDETAIL_OPEN'.
*       Set the active tab if given in this message
        CHECK is_message-data1 <> space.
        CALL METHOD poref_settings->set( i_element = 'ACTIVE_TAB'
          i_active = is_message-data1 ).
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~message_handler

************************************************************************
* OK-code handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
    DATA: ls_control TYPE lcl_migo_kernel=>ty_s_control.
    CASE i_okcode.
      WHEN 'MIGO_OK_NEXT_IT'.
*     Button "Next Item" triggered: Execute the function only if
*     the current line is less or equal to the number of lines
*     in the model. Reason: In new position mode, the button
*     is visible and currentline > lines_model. Pressing the
*     button should only increase the line number if the entered
*     data have been accepted by the kernel. Remember: When coming
*     to this code here the LINE_MODIFY in PAI has already been
*     executed.
        CHECK current_line <= lcl_migo_globals=>kernel->s_status-lines.
        ADD 1 TO current_line.
*     Accept line numbers higher than lines in model only in new_line
*     modes. Check necessary because of input field on detail.
*     If the users enters the highest line in model and presses
*     right-arrow, the line number would illegally increase.
        ls_control = lcl_migo_globals=>kernel->s_control.
        IF ls_control-new_line_mode = space AND
           current_line > lcl_migo_globals=>kernel->s_status-lines.
          current_line = lcl_migo_globals=>kernel->s_status-lines.
        ENDIF.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
      WHEN 'MIGO_OK_PREV_IT'.
        current_line = current_line - 1.
        IF current_line = 0. current_line = 1. ENDIF.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
      WHEN 'MIGO_OK_LOCATE'.
        def_sms 'TABLEVIEW_LINE_SET' current_line space.
      WHEN 'MIGO_OK_COPY'.
*       Don't copy an empty line.
        CHECK current_line <= lcl_migo_globals=>kernel->s_status-lines.
        CALL METHOD transfer_item_copy.
        current_line = lcl_migo_globals=>kernel->s_status-lines.
        def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
    ENDCASE.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

************************************************************************
* PBO
************************************************************************
  METHOD pbo.
    DATA:
      ls_badi   TYPE migo_badi_init,            "BAdI-Registration
      l_cprog   TYPE sycprog,                   "external program
      l_dynnr   TYPE sydynnr,                   "external screen
      l_heading TYPE migo_badi_heading,         "external tabstrip name
      l_tabix   TYPE sytabix,                   "BAdI implementation no.
      cl_change TYPE REF TO /sappspro/cl_numbers,
      lf_active TYPE boolean.

      DATA: ls_t005 TYPE t005.                                "N1535104

    CALL METHOD super->pbo.
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING
        i_line             = current_line
        i_dependent_tables = abap_true
      IMPORTING
        es_goitem          = goitem
        et_gofreight       = t_gofreight
        et_goserial        = t_goserial.
*   Header data is needed for detail tabstrip accounting and import,
*   but it's forbidden to read them into GOHEAD in the detail-viewer.
*   If a detail viewer needs header data, it has to fetch them
*   into it's own local structure.
*      CALL METHOD lcl_migo_globals=>kernel->header_get
*                  IMPORTING e_gohead = gohead.

*   Set GODYNPRO-DETAIL_TAKE.
*   Question: Why don't we use GOITEM-TAKE_IT directly on the dynpro?
*   Answer: Good idea, but does not work by unknown reasons. There is
*   no field transport down from the screen to the field at this point
*   and GOITEM-TAKE_IT is filled from the value in the last line of the
*   tableview!
    godynpro-detail_take = goitem-take_it.
*   Line number. If zero, we must be in new line mode, and the next
*   given number can be found in MAX_ZEILE + 1
    godynpro-detail_zeile = goitem-zeile.
    IF godynpro-detail_zeile = 0.
      godynpro-detail_zeile =
                      lcl_migo_globals=>kernel->s_status-max_zeile + 1.
    ENDIF.
ENHANCEMENT-POINT lmigodc2_06 SPOTS es_saplmigo.
*   set subscreen for purchase order
*   check if long procuremnt number is active and replace dynpro 320 with 400
    CLEAR: lf_active.
    CREATE OBJECT cl_change.

    CALL METHOD cl_change->is_active
      RECEIVING
        rv_active = lf_active.

    IF lf_active = 'X'.
      g_sub_po = '0400'.
    ELSE.
      g_sub_po = '0320'.
    ENDIF.
ENHANCEMENT-POINT LMIGODC2_07 SPOTS ES_SAPLMIGO.
    IF goitem-xpoitem = abap_false AND
       goitem-kzzug   = abap_false.    "no reference to PO
      g_sub_po = '0321'.
    ENDIF.

* begin of Outsourced Manufacturing EhP 4
* EhP4 component consumption

    IF goitem-xco_order = abap_true AND ( goitem-xlbtype = C OR
       goitem-kzbwa = '02' OR lcl_migo_globals=>kernel->s_defaults-sobkz = o ).
      g_sub_sc = '0323'.
    ELSE.
      g_sub_sc = '0324'.
    ENDIF.

* end of Outsourced Manufacturing EhP 4

*   set subscreen for order data
    g_sub_order = '0375'.
    IF goitem-xorditem = abap_false.
      g_sub_order = '0376'.
    ENDIF.
*   set subscreen for freight
    g_sub_freight = '0330'.
    IF goitem-freight = abap_false.    "no freight supplier
      g_sub_freight = '0331'.
    ENDIF.
*   set subscreen for batch
    g_sub_batch = '0335'.                  "normal batch
    IF goitem-xchpf = abap_false.          "not batch managed...
      IF NOT goitem-docubatch_control = ' '.
        g_sub_batch = '0338'.                 "... but documentary batch
      ELSE.
        g_sub_batch = '0336'.                 "... and no batch at all
      ENDIF.
    ENDIF.
    IF goitem-shkzg = 'H' AND
       lcl_migo_globals=>kernel->s_action-migo_mode = 'GT'.
      g_sub_batch = '0337'.                "batch transfer
      IF goitem-umxchpf = abap_false.      "not batch managed
        g_sub_batch = '0336'.
        IF goitem-xchpf = abap_true AND    "not a transfer posting
          lcl_migo_globals=>kernel->s_action-create = abap_false.
          g_sub_batch = '0335'.
        ENDIF.
      ENDIF.
    ENDIF.

    IF CL_OPS_SWITCH_CHECK=>LO_MM_SD_SFWS_DM_SC( ) is not initial  AND lcl_migo_globals=>kernel->s_action-migo_mode ='GS'.
      IF goitem-xchpf = abap_true.
      else.
        IF goitem-kzbew = o.               "for subsequent adjustment
          g_sub_batch = '0306'.            "function not relevant
        ENDIF.
      endif.
  endif.
*   set subscreen for accounting
    g_sub_account = '0347'.            "default: no accounting
    IF goitem-xaccount = abap_true.
*-- MAA-DEV
      if not goitem-mulko is initial." and goitem-konto = '*'. "MAA2
        g_sub_account = '0346'.  "multi accounting (for PO)
      else.
        g_sub_account = '0345'.  "standard accounting block
      endif.
*-- MAA-DEV
    ENDIF.
*   set subscreen for Taxes
    g_sub_taxes = '0350'.
    IF goitem-tax_relevant IS INITIAL.        "no taxes
      g_sub_taxes = '0351'.
    ENDIF.

*   set subscreen for serial numbers
    IF goitem-sernp IS INITIAL.
      g_sub_serial = '0361'.            "no serial numbers
    ELSE.
      DATA l_serialize TYPE abap_bool.
      CALL METHOD lcl_migo_buffer=>serial_relevance_check
        EXPORTING
          i_sernp     = goitem-sernp
          i_bwart     = goitem-bwart
          i_sobkz     = goitem-sobkz
          i_kzbew     = goitem-kzbew
          i_kzzug     = goitem-kzzug
          i_kzvbr     = goitem-kzvbr
        IMPORTING
          e_serialize = l_serialize.

      IF l_serialize = abap_false.
        g_sub_serial = '0361'.            "no serial no. during GM
      ELSE.
        g_sub_serial = '0360'.             "serial numbers active.
      ENDIF.
    ENDIF.
*   begin - serialnumbers from pi-document                "637093
    IF lcl_migo_globals=>kernel->s_control-vgart = 'WI'. "serial numbers
      g_sub_serial = '0362'.
    ENDIF.
*   end                                                        "637093

    IF goitem-kzbew = o.               "for subsequent adjustment
      g_sub_serial = '0306'.           "function not relevant
    ENDIF.
*   set subscreen for nast
    g_sub_nast = '0365'.
    IF goitem-nast = abap_false.       "no output determination
      g_sub_nast = '0366'.
    ENDIF.
*   set subscreen for foreign trade
    g_sub_import = '0355'.
    IF goitem-import = abap_false.     "no foreign trade
      g_sub_import = '0356'.
    ENDIF.
*   set subscreen for transfer
    g_sub_transfer = '0380'.
    IF goitem-kzzug = abap_false       "no transfer data
       OR goitem-xpoitem = abap_true.
      g_sub_transfer = '0381'.
    ENDIF.
*   set subscreen for wm
    g_sub_wm = '0385'.
    IF goitem-wm_relevant = abap_false.
      g_sub_wm = '0386'.
    ENDIF.

    "set subscreen for ewm
    g_sub_ewm = '0387'.
    " IF EWM_is_not_active
    "  g_sub_ewm = '0386'.
    " ENDIF.

*   set subscreen for reservations
    g_sub_res = '0370'.
    IF goitem-xresitem = abap_false.   "no reservation item
      g_sub_res = '0371'.
    ENDIF.
*   Subscreen for partners
    g_sub_partners = '0340'.
    IF goitem-xpartners = abap_false.
      g_sub_partners = '0341'.
    ENDIF.

*   EHP 606 CFB
*   Set subscreen for extension subscreen for internal applications
    g_sub_ext_int = '4200'.

*   BAdI: Subscreens for external components
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      LOOP AT lcl_migo_globals=>t_badi INTO ls_badi.
        l_tabix = sy-tabix.
        CLEAR l_dynnr.
        IF gohead-land1 IS NOT INITIAL.              "Note 1535104 starts
          CALL FUNCTION 'FI_COUNTRY_DATA'
            EXPORTING
              i_land1 = gohead-land1
            IMPORTING
              e_t005  = ls_t005.
          IF ls_t005-intca   EQ 'IN'  AND            "CIN & display mode ( MIGO matdoc display)
             godynpro-action EQ 'A04' AND
             godynpro-refdoc EQ 'R02'.               "Export the value current line to CIN Function module.
            EXPORT cin_current_line FROM current_line TO MEMORY ID 'CIN_MIGO_LINE'.
          ENDIF.
        ENDIF.                                       "Note 1535104 ends

        CALL METHOD lcl_migo_globals=>if_badi->pbo_detail
          EXPORTING
            i_class_id = ls_badi-class_id
            i_line_id  = goitem-global_counter
          CHANGING
            e_cprog    = l_cprog
            e_dynnr    = l_dynnr
            e_heading  = l_heading.
        IF l_dynnr IS INITIAL.
*         No one interested: Dummy screen.
          l_cprog   = sy-repid.
          l_dynnr   = '2099'.
          l_heading = 'Unknown'.                            "#EC NOTEXT
        ENDIF.

ENHANCEMENT-POINT lmigocd1_05 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT lmigocd1_06 SPOTS es_saplmigo.
        CASE l_tabix.
          WHEN 1.
            g_ext1_cprog    = l_cprog.
            g_ext1_dynnr    = l_dynnr.
            ts_goitem_ext_1 = l_heading.
          WHEN 2.
            g_ext2_cprog    = l_cprog.
            g_ext2_dynnr    = l_dynnr.
            ts_goitem_ext_2 = l_heading.
          WHEN 3.
            g_ext3_cprog    = l_cprog.
            g_ext3_dynnr    = l_dynnr.
            ts_goitem_ext_3 = l_heading.
          WHEN 4.
            g_ext4_cprog    = l_cprog.
            g_ext4_dynnr    = l_dynnr.
            ts_goitem_ext_4 = l_heading.
          WHEN 5.
            g_ext5_cprog    = l_cprog.
            g_ext5_dynnr    = l_dynnr.
            ts_goitem_ext_5 = l_heading.
        ENDCASE.
      ENDLOOP.
    ENDIF.
*   set active tabstrip.
ENHANCEMENT-SECTION     lmigodc2_03 SPOTS es_saplmigo.
    ts_goitem-activetab = poref_settings->get( 'ACTIVE_TAB' ).
END-ENHANCEMENT-SECTION.
  ENDMETHOD.                    "pbo

************************************************************************
* PAI: modify GOITEM
************************************************************************
  METHOD pai.
    DATA l_force_change TYPE abap_bool.
*   inherit from super class (e.g. cursor logic)
    CALL METHOD super->pai.
*   Refill TAKE_IT-Flag
    goitem-take_it = godynpro-detail_take.
*   BAdI:
*   Method PAI_DETAIL will be called before LINE_MODIFY so that the BAdI
*   can decide whether MIGO should copy the line (new-line-mode). Also
*   required to ensure that STATUS_AND_HEADER from LINE_MODIFY can
*   operate on current data from the external application.
    CLEAR l_force_change.
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      CALL METHOD lcl_migo_globals=>if_badi->pai_detail
        EXPORTING
          i_line_id      = goitem-global_counter
          i_okcode       = okcode
        CHANGING
          e_force_change = l_force_change.
ENHANCEMENT-POINT lmigodc2_04 SPOTS es_saplmigo STATIC.
ENHANCEMENT-POINT lmigodc2_05 SPOTS es_saplmigo.
    ENDIF.
*   Update
    CALL METHOD lcl_migo_globals=>kernel->line_modify
      EXPORTING
        i_line             = current_line
        i_force_change     = l_force_change
        i_authority_check  = abap_false
        i_dependent_tables = abap_true
        it_gofreight       = t_gofreight
        it_goserial        = t_goserial
      CHANGING
        cs_goitem          = goitem.

*   Read current active tab
    CALL METHOD poref_settings->set( i_element = 'ACTIVE_TAB'
      i_active = ts_goitem-activetab ).
  ENDMETHOD.                    "pai

************************************************************************
* PAI: get actual GOITEM
************************************************************************
  METHOD pai_get.
*   In PAI, is is necessary to read to current line of the detail as
*   the field transport only gets data that are on screen.
*   Without this rereading all data, the detail would pass back
*   an GOITEM with initial data or, even worse, uncleared data from the
*   last tableview-loop, which also uses GOITEM as transport structure.
*   It is NOT necessary to read the dependent tables here as they
*   are maintained in own tables of the detail.
    CALL METHOD lcl_migo_globals=>kernel->line_get
      EXPORTING
        i_line    = current_line
      IMPORTING
        es_goitem = goitem.
  ENDMETHOD.                    "pai_get

************************************************************************
* A line number has been entered. Locate the first line with this
* ZEILE which is currently visible and place the viewer on it.
************************************************************************
  METHOD line_find.
    DATA: ls_goitem TYPE goitem,
          l_index   TYPE syindex.
    DO lcl_migo_globals=>kernel->s_status-lines TIMES.
      l_index = sy-index.
      CALL METHOD lcl_migo_globals=>kernel->line_get
        EXPORTING
          i_line    = l_index
        IMPORTING
          es_goitem = ls_goitem.
*     If a line has been found, exit the loop.
      IF ls_goitem-zeile = godynpro-detail_zeile.
        EXIT.
      ELSE.
        l_index = 0.
      ENDIF.
    ENDDO.
*   Not found --> message, exit.
    IF l_index = 0.
      godynpro-detail_zeile = goitem-zeile.
      MESSAGE s020(migo).
      EXIT.
    ENDIF.
*   Found: Place viewer.
    current_line = l_index.
    def_sms 'ITEMDETAIL_CURRENTLINE' current_line space.
  ENDMETHOD.                    "line_find
ENDCLASS.                    "lcl_migo_detail IMPLEMENTATION