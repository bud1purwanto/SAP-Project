*----------------------------------------------------------------------*
*   INCLUDE LMIGOKS1                                                   *
*   Kernel status changes (ACTION, REFDOC, CANCEL_MODE, ...)
*----------------------------------------------------------------------*

************************************************************************
* Return the current S_CONTROL
************************************************************************
METHOD mode_get.
  rs_control = s_control.
ENDMETHOD.                    "mode_get

************************************************************************
* Set a new kernel mode.
* According the to flags and fields in S_CONTROL, the data in
* S_ACTION are derived.
************************************************************************
METHOD mode_set.
  DATA: lt_mvt        TYPE TABLE OF bwart,
        l_vgart       TYPE vgart,
        ls_action_old TYPE ty_s_action.

  ls_action_old = s_action.
* Nothing to do if old and new mode are identical. Execute always
* if called from within RESET.
  IF is_control <> s_control OR i_unconditional = abap_true.
*   If either ACTION or REFDOC has changed, clear VGART. It will be
*   set later in this routine to a default or set when reading a
*   material document.
*   Exception: Setting of VGART forced by flag. Needed for predoc,
*   as this routing calls MODE_SET once with a complete set of data.
*   Result:
*   - New ACTION/REFDOC --> Correct combination set.
*   - Read material document --> New VGART set.
*   - Change another flag (e.g. new positions) --> No modif to VGART.
    l_vgart = is_control-vgart.
    IF ( s_control-action <> is_control-action OR
         s_control-refdoc <> is_control-refdoc ) AND
         i_keep_vgart = abap_false.
      CLEAR l_vgart.
    ENDIF.
    s_control       = is_control.
    s_control-vgart = l_vgart.
*   Create S_ACTION
    CLEAR s_action.
*   Settings for transaction type. If posting with reference to a
*   material document, this is set by the material document reading
*   routine. (Importing parameter I_VGART). If not given --> cleared.
*   In all other cases, it is derived from ACTION/REFDOC.
    CASE s_control-action.
      WHEN 'A01'.
        s_control-vgart = 'WE'.
        IF 'R08'     CS s_control-refdoc. s_control-vgart = 'WF'. ENDIF.
*       (Yet, in case of a goods receipt/issue and transfer posing
*        related to material documents, only material documents with no
*        related docs are allowed -> set vgart to WA in this case)
        IF 'R02'     CS s_control-refdoc. s_control-vgart = 'WA'. ENDIF.
        IF 'R09 R10' CS s_control-refdoc. s_control-vgart = 'WA'. ENDIF.
      WHEN 'A05'.
        IF 'R02'     NS s_control-refdoc. s_control-vgart = 'WE'. ENDIF.
      WHEN 'A07'.                         s_control-vgart = 'WA'.
      WHEN 'A08'.                         s_control-vgart = 'WA'.
      WHEN 'A09'.                         s_control-vgart = 'WA'.
      WHEN 'A10'.                         s_control-vgart = 'WA'."583649
      WHEN 'A11'.                         s_control-vgart = 'WO'.
    ENDCASE.
*   Goods receipt/issue others: Table control will be ready for input
*   (in case of a goods receipt/issue or transfer posing related
*    to a material document (s_action-copy) that itself has no related
*    document, we do not set the new_line_mode but will offer the
*    new line button below the ALV                             ERP 10)
    IF s_control-refdoc = 'R10'.
      s_control-new_line_mode = x.
    ENDIF.
*   Derive the MIGO_MODE.
*   Controls the selection of the a table control variant, field
*   selection and authority checks.
    CASE s_control-vgart.
      WHEN 'WE'.   s_action-migo_mode = 'GR'.
      WHEN 'WA'.
        IF s_control-action = 'A08' OR s_control-action = 'A09'.
          s_action-migo_mode = 'GT'.
        ELSE.
          s_action-migo_mode = 'GI'.
        ENDIF.
      WHEN 'WF'.   s_action-migo_mode = 'GO'.
      WHEN 'WO'.   s_action-migo_mode = 'GS'.
      WHEN space.  s_action-migo_mode = 'GR'.
      WHEN OTHERS. s_action-migo_mode = 'GI'.
    ENDCASE.
*   If a transfer material document was read by materialdocument_get
*   MIGO_MODE has to be 'GT' (only method materialdocument_get can set
*   parameter i_transfer).
    IF i_transfer = abap_true.
      s_action-migo_mode = 'GT'.
    ENDIF.
*   set accounting VGART for accounting assignment block
    CASE s_control-vgart.                                   "431091
      WHEN 'WE'.   s_control-rw_vorgn = 'RMWE'.             "431091
      WHEN 'WA'.   s_control-rw_vorgn = 'RMWA'.             "431091
      WHEN 'WF'.   s_control-rw_vorgn = 'RMWF'.             "431091
*     additional VGARTs for display material document         "431091
      WHEN 'WI'.   s_control-rw_vorgn = 'RMWI'.             "431091
      WHEN 'WL'.   s_control-rw_vorgn = 'RMWL'.             "431091
      WHEN 'WO'.   s_control-rw_vorgn = 'RMWE'.             "431091
      WHEN 'WQ'.   s_control-rw_vorgn = 'RMWQ'.             "431091
      WHEN 'WR'.   s_control-rw_vorgn = 'RMRU'.             "431091
      WHEN 'WS'.   s_control-rw_vorgn = 'RMRU'.             "431091
      WHEN 'WZ'.   s_control-rw_vorgn = 'RMWA'.             "431091
      WHEN OTHERS. s_control-rw_vorgn = 'RMWA'.             "431091
    ENDCASE.                                                "431091
*   Set the small dependent flags in S_ACTION.
    CASE s_control-action.
      WHEN 'A01'.
        s_action-create  = abap_true.
        IF s_action-migo_mode = 'GI'.
          s_action-issue   = abap_true.
        ELSE.
          s_action-receipt = abap_true.
        ENDIF.
        IF s_control-refdoc = 'R02'.                        "ERP 10
          s_action-copy = abap_true.
        ENDIF.
      WHEN 'A02'.
        s_action-create = abap_true.
        s_action-return = abap_true.
      WHEN 'A03'.
        s_action-create = abap_true.
        s_action-cancel = abap_true.
      WHEN 'A04'.
        s_action-display  = abap_true.
      WHEN 'A05'.
        s_action-create  = abap_true.
        s_action-release = abap_true.
      WHEN 'A06'.
        s_action-create     = abap_true.
        s_action-subsequent = abap_true.
      WHEN 'A07'.
        s_action-create     = abap_true.
        s_action-issue      = abap_true.
        IF s_control-refdoc = 'R02'.
          s_action-copy = abap_true.
        ENDIF.
      WHEN 'A08'.
        s_action-create  = abap_true.
        IF s_control-refdoc = 'R02'.
          s_action-copy = abap_true.
        ENDIF.
      WHEN 'A09'.
        s_action-create  = abap_true.
        IF s_control-refdoc = 'R02'.
          s_action-copy = abap_true.
        ENDIF.
      WHEN 'A10'.
        s_action-create     = abap_true.
        s_action-place      = abap_true.
      WHEN 'A11'.
        s_action-create  = abap_true.
    ENDCASE.
*   Set the type of reference document for this combination of
*   ACTION and REFDOC.
    CASE s_control-refdoc.                                  "381404
      WHEN 'R01' OR 'R04' OR 'R05' OR 'R06' OR 'R07'.       "381404
*       Purchase order, Inbound/Outbound delivery, Transport, TraId.
        s_action-refdoctype = c_refdoctype_po.              "381404
      WHEN 'R02' OR 'R03'.                                  "381404
*       Material document, delivery note.
        s_action-refdoctype = c_refdoctype_matdoc.          "381404
      WHEN 'R08'.                                           "381404
*       Order. Can be MB31 or goods issue for reservation.
        CASE s_control-action.                              "381404
          WHEN 'A01'.                                       "381404
            s_action-refdoctype = c_refdoctype_order.       "381404
          WHEN 'A07'.                                       "381404
            s_action-refdoctype = c_refdoctype_reservation. "381404
        ENDCASE.                                            "381404
      WHEN 'R09'.                                           "381404
*       Reservation.
        s_action-refdoctype = c_refdoctype_reservation.     "381404
      WHEN 'R10'.                                           "381404
*       No reference document.
        s_action-refdoctype = c_refdoctype_none.            "381404
    ENDCASE.                                                "381404
ENHANCEMENT-SECTION     lmigoks1_01 SPOTS es_saplmigo.
*   Set context for the table control
    CALL FUNCTION 'SET_TC_KONTEXT'
      EXPORTING
        programname = 'SAPLMIGO'
        controlname = 'TV_GOITEM'
        kontext     = s_action-migo_mode.                "#EC DOM_EQUAL
*   The REFRESH ***after*** the context has been set ensures that the
*   R/3 kernel creates the new table control structure using the
*   correct settings from that context.
*   This refresh has nothing to do with a refresh of the context!
    REFRESH CONTROL 'TV_GOITEM' FROM SCREEN '0200'.         "354686
END-ENHANCEMENT-SECTION.
*   The detail toggler has to use different subscreens for transfer
*   postings. Therefore it needs to be updated with the correct screens
*   when migo_mode changes.
    IF s_action-migo_mode = 'GT'.
*     To display all tabsprips, the control TS_GOITEM has to be cleared
      CLEAR ts_goitem.
      CALL METHOD oref_detail_toggler->screen_set
        EXPORTING
          i_active_dyn    = '0303'
          i_inactive_dyn  = '0302'
          i_subscreen_dyn = '0305'
          i_subscreen     = 'G_DETAIL_SUBSCREEN'.

    ELSE.
*     To display all tabsprips, the control TS_GOITEM has to be cleared
      CLEAR ts_goitem.
      CALL METHOD oref_detail_toggler->screen_set
        EXPORTING
          i_active_dyn    = '0301'
          i_inactive_dyn  = '0302'
          i_subscreen_dyn = '0300'
          i_subscreen     = 'G_DETAIL_SUBSCREEN'.
    ENDIF.
    def_sms 'MIGO_DETAIL_CARRIER_CHANGE' space space.
  ENDIF.                               "S_CONTROL changed...
* Default values for header data
  CALL METHOD header_defaults_set.
* BAdI: MODE SET
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.              "552774
    CALL METHOD lcl_migo_globals=>if_badi->mode_set
      EXPORTING
        i_action = s_control-action
        i_refdoc = s_control-refdoc.
  ENDIF.                                                    "552774
* Send message
  def_sms 'KERNEL_MODE_CHANGED' ls_action_old-migo_mode
                                s_action-migo_mode.
* New 'migo_mode'-depending fieldselection
  CALL METHOD screen_modify_mode.
* Get allowed movemtent types (from T158B / MIGO_T156)
  CALL METHOD lcl_migo_buffer=>allowed_mvt_get
    EXPORTING
      i_migo_mode   = s_action-migo_mode
      i_migo_action = s_control-action
    IMPORTING
      et_mvt        = lt_mvt.
* Export pt_mvt to memory, because F4-Help for BWART needs it.
  EXPORT lt_mvt FROM lt_mvt TO MEMORY ID 'MIGO_MVT'.

ENDMETHOD.                    "mode_set

*_______________________________________________________________________
* INTERNAL DOCUMENTATION:
*
* How to set migo_mode.
* Possible values: GR (goods receipt [MB01]), GI (goods issue [MB11]),
*                  GO (goods receipt for production order [MB31]),
*                  GS (subsequent adjustment).
* Note: The allowed combinations for MIGO are layed out in LMIGOGL2
*       (METHOD customizing_read).
* Determines the selected table control.
*
*    \REFDOC       |
*     \            |
*      \           |
*       \          |
* ACTION \         |R01|R02|R03|R04|R05|R06|R07|R08|R09|R10|
*___________________________________________________________
* Goods receipt    |GR | - | - |GR |GR |GR |GR |GO |GI |GI |
* Return delivery  | - | * | * | - | - | - | - | - | - | - |
* cancellation     | - | * | - | - | - | - | - | - | - | - |
* Display          | - | * | - | - | - | - | - | - | - | - |
* Release GR bl.st.|GR | * | - |GR |GR |GR |GR | - | - | - |
* Subsequent deliv.| - | * | * | - | - | - | - | - | - | - |
* goods issue      |GI | - | - | - | - | - | - |GI |GI |GI |
* transfer         | - | - | - | - | - | - | - | - |GT |GT |
* remove from stor.| - | - | - | - | - | - | - | - | - |GT |
* place in stor.   | - |GR | - | - | - | - | - | - | - |GR |
* Subsequent adjust|GS | - | - | - | - | - | - | - | - | - |
*___________________________________________________________
* Note: * means: determined by the material document to be read.
*       Before reading, a default is set. Will be overwritten
*       immedeately by the material document!
*       Default today is: GR
*
* Action:
* A01 = Goods receipt
* A02 = Return delivery
* A03 = cancellation
* A04 = Display
* A05 = Release GR bl.st.
* A06 = Subsequent deliv.
* A07 = goods issue
* A08 = transfer
* A09 = remove from stor.
* A10 = place in stor.
* A11 = Subsequent adjust

* Refdoc:
* R01 = Purchase order
* R02 = Material document
* R03 = Delivery note
* R04 = Inbound delivery
* R05 = Outbound delivery
* R06 = Transport
* R07 = Transport ID code
* R08 = Order
* R09 = Reservation
* R10 = Other GR
*_______________________________________________________________________



************************************************************************
* Derive the dependent data from PT_GOITEM.
* If the status has been changed (execpt the number of lines and
* maximum counter), send a message.
************************************************************************
METHOD status_derive.
  DATA: ls_status_old        TYPE ty_s_status,
        ls_status_new        TYPE ty_s_status,
        ls_mapping           TYPE ty_s_line_mapping,
        lv_tabix             TYPE sytabix.
  FIELD-SYMBOLS: <ls_goitem> TYPE goitem.
* Clear all fields
  ls_status_old = s_status.
  CLEAR s_status.
  CLEAR pt_line_mapping.
* -PDI- scrap 12/06 begin
  s_status-ewm = abap_false.
* -PDI- end

* Loop with evaluation of fields.
  LOOP AT pt_goitem ASSIGNING <ls_goitem>.
    IF s_action-migo_mode = 'GT'.
*     Transfer posting
      IF <ls_goitem>-shkzg = h AND <ls_goitem>-umxchpf = abap_true OR
         <ls_goitem>-shkzg = s AND <ls_goitem>-xchpf   = abap_true.
        s_status-xbatch = abap_true.
      ENDIF.
    ELSE.
*     Batch management. Not relevant for subsequent adjustment
*     set same status for 'real' batches and for documentary batches
      IF ( NOT <ls_goitem>-xchpf IS INITIAL AND
           NOT <ls_goitem>-kzbew = o )
        OR
         ( NOT <ls_goitem>-docubatch_control IS INITIAL AND
           NOT <ls_goitem>-kzbew = o ).
        s_status-xbatch = abap_true.
      ENDIF.
    ENDIF.
*   Accounting
    IF NOT <ls_goitem>-xaccount IS INITIAL.
      s_status-xaccount = abap_true.
    ENDIF.
*   Freight vendors
    IF NOT <ls_goitem>-freight IS INITIAL.
      s_status-xfreight = abap_true.
    ENDIF.
*   Partners tabstrip
    IF NOT <ls_goitem>-xpartners IS INITIAL.
      s_status-xpartners = abap_true.
    ENDIF.
*   Serial numbers. Not relevant for subsequent adjustment
    IF NOT <ls_goitem>-sernp IS INITIAL AND NOT <ls_goitem>-kzbew = o.
      s_status-xserial = abap_true.
    ENDIF.
*   Model contains lines with reference to purchase orders
    IF <ls_goitem>-xpoitem = abap_true.
      s_status-xpoitem = abap_true.
    ENDIF.

* begin of Outsourced Manufacturing EhP 4
    IF <ls_goitem>-xco_order IS NOT INITIAL.
      s_status-xpo_sc = abap_true.
    ENDIF.
* end of Outsourced Manufacturing EhP 4
*   Model contains lines with ref. GI to stock transfer purchase orders
    IF <ls_goitem>-kzzug = abap_true                      "note 409029
       AND <ls_goitem>-xpoitem = abap_false.              "note 409029
      s_status-xstpoitem = abap_true.
    ENDIF.
*   Model contains lines with reference to orders
    IF <ls_goitem>-xorditem = abap_true.
      s_status-xorditem = abap_true.
    ENDIF.
*   Model contains lines with linked documents
    IF <ls_goitem>-xlinks = abap_true.
      s_status-xlinks = abap_true.
    ENDIF.
*   Model contains lines with reference to reservations
    IF <ls_goitem>-xresitem = abap_true.
      s_status-xresitem = abap_true.
    ENDIF.
*   Messages
    IF NOT <ls_goitem>-nast IS INITIAL.
      s_status-xnast = abap_true.
    ENDIF.
*   Import
    IF NOT <ls_goitem>-import IS INITIAL.
      s_status-ximport = abap_true.
    ENDIF.
*   Brazil
    IF NOT <ls_goitem>-tax_relevant IS INITIAL.
      s_status-xtaxes = abap_true.
    ENDIF.

*   Set the visibility of the external subscreen for internal purposes
*   EHP606 CFB
    CALL METHOD oref_detail_ext_int->get_tab_visibility
      EXPORTING
        is_goitem  = <ls_goitem>
      RECEIVING
        rv_visible = s_status-xext_int.

*   Warehouse management.
    IF NOT <ls_goitem>-wm_relevant IS INITIAL.
      s_status-xwm = abap_true.
    ENDIF.
* -pdi- scrap 12/06 begin
*   Extended Warehouse Management
     lv_tabix = sy-tabix.

* --> Changed logic for EhP 603 -->

    s_status-ewm = abap_false.

enhancement-point ehp603_lmigoks1_01 spots es_saplmigo.

* <-- Changed logic for EhP 603 <--

    sy-tabix = lv_tabix.
* -PDI- end

*   Handling Unit
    IF NOT <ls_goitem>-xhupf IS INITIAL.
      s_status-xhum = abap_true.
    ENDIF.
*   Loglight
    IF NOT <ls_goitem>-loglevel IS INITIAL.
      s_status-xloglight = abap_true.
    ENDIF.
*   Find the line with the highest ZEILE
    IF <ls_goitem>-zeile > s_status-max_zeile.
      s_status-max_zeile = <ls_goitem>-zeile.
    ENDIF.
*   Create the mapping table from external to internal line number
    IF <ls_goitem>-invisible IS INITIAL.
      ADD 1 TO ls_mapping-line.
      ls_mapping-tabix = sy-tabix.
      INSERT ls_mapping INTO TABLE pt_line_mapping.
    ENDIF.
  ENDLOOP.
* To compare the stati, we do a trick: MAX_LINE is cleared (irrelevant),
* LINES is set to 1 if any in (message only if zero pass).
* Number of lines.
  DESCRIBE TABLE pt_goitem LINES s_status-max_tabix.
  s_status-lines = ls_mapping-line.
* BAdI: Status data and header data
  CLEAR s_status-no_predoc.
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.              "552774
    CALL METHOD lcl_migo_globals=>if_badi->status_and_header
      EXPORTING
        i_lines_in_model    = s_status-max_tabix
        is_gohead           = ps_gohead
      CHANGING
        e_hold_data_disable = s_status-no_predoc.
  ENDIF.                                                    "552774
  ls_status_new = s_status.
  CLEAR: ls_status_old-max_zeile, ls_status_new-max_zeile,
         ls_status_old-max_tabix, ls_status_new-max_tabix.
  IF ls_status_old-lines > 0.
    ls_status_old-lines = 1.
  ENDIF.
  IF ls_status_new-lines > 0.
    ls_status_new-lines = 1.
  ENDIF.
* Determination whether predocs or refdocs are allowed
  CLEAR: s_status-allowed_refdoc, s_status-allowed_predoc.
* Predocuments only if there are no lines in the model
  IF s_status-lines = 0.
    s_status-allowed_predoc = abap_true.
  ENDIF.
* Which REFDOC is currently allowed.
* If not in display mode and there are lines in the model, documents
* like materialdocuments are not allowed. According to Mr. Cannone,
* multiple reservations within the same document are OK.
  s_status-allowed_refdoc = s_control-refdoc.
  IF s_control-action <> 'A04' AND
     'R02 R03' CS s_control-refdoc AND
    s_status-lines <> 0.
    CLEAR s_status-allowed_refdoc.
  ENDIF.
* Send message if changed
  IF ls_status_old-allowed_refdoc <> s_status-allowed_refdoc OR
     ls_status_old-allowed_predoc <> s_status-allowed_predoc.
    def_sms 'ALLOWED_DOCS_CHANGED' space space.
  ENDIF.
* Send a message if really some changes
  IF ls_status_old <> ls_status_new.
    CALL METHOD screen_modify_status.
    def_sms 'KERNEL_STATUS_CHANGED' space space.
  ENDIF.
ENDMETHOD.                    "status_derive

************************************************************************
* Default values manipulation
************************************************************************
METHOD defaults_set.
  s_defaults = is_defaults.
* After a change of the defaults, the field selection for the
* template has to rebuilt to show the fields depending on the
* movement type. I hope there are no side-effcts.
* If there are some, comment this line OUT. The lost "functionality"
* is not worth to destroy other more delicate parts of the coding.
  CALL METHOD screen_modify_mode.
ENDMETHOD.                    "defaults_set