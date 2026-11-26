*----------------------------------------------------------------------*
*   INCLUDE LMIGOKG1 Goods movement will be prepared                   *
*----------------------------------------------------------------------*

************************************************************************
* Fill the interface to MB_CREATE_GOODS_MOVEMENT
************************************************************************
METHOD goods_movement_fill.
  DATA: ls_imseg3   TYPE imseg3,
        ls_imseg    TYPE ty_s_imseg,
        lt_imseg    TYPE ty_t_imseg,
        ls_goitem   TYPE goitem,
        lt_gocomp   TYPE STANDARD TABLE OF gocomp,
        ls_gocomp   TYPE gocomp,
        ls_goitem_parent  TYPE goitem,
        l_counter_serial  TYPE sytabix,
        l_rc_t160m_check  TYPE sy-subrc,
        l_evere     TYPE t027c-evere,
        lt_slcomp   TYPE ty_t_slcomp_hash,
        ls_goitem_full_head TYPE ty_s_goitem,
        l_bom_found TYPE abap_bool,
        l_item_incomplete TYPE abap_bool,
        l_vbeln     TYPE vbeln_vl,
        lt_badiret  TYPE bapiret2_t,            "BAdI: Message table
        ls_badiret  TYPE bapiret2,              "BAdI: Message structure
        l_badi_err  TYPE abap_bool,             "BAdI: Error message
        l_ser_add   TYPE abap_bool.                         "734758

ENHANCEMENT-POINT goods_movement_fill_01 SPOTS es_saplmigo STATIC.
  FIELD-SYMBOLS: <goitem> TYPE ty_s_goitem,
                 <ls_goitem_child> TYPE goitem.

* clear loglevel for all items and header before beginning...
  CLEAR ps_gohead-loglevel.
  MODIFY pt_goitem FROM ls_goitem TRANSPORTING loglevel WHERE
                                  loglevel <> space.
  CLEAR lt_slcomp.
* in case of full product: check whether empties bom has already been
* exploded and add empties to pt_goitem before main loop; <LG>
  CALL METHOD goods_mvmt_empties_boms_check.
* Cross Docking
  CALL METHOD cd_lgort_distribution_check.
* Check required fields in gohead
  CALL METHOD lcl_migo_screenmodification=>screen_modify_required
    EXPORTING
      is_gohead = ps_gohead.

* add reason code to application log
  DATA: lf_messageno    TYPE symsgno,
        lf_messagetype  TYPE char1,
        lf_messageid    TYPE symsgid.

  CALL FUNCTION '/SAPPSPRO/READ_REASON_CODE_LOG'
    EXPORTING
      i_po_number   = goitem-ebeln
      i_po_item     = 00000
    IMPORTING
      e_messageno   = lf_messageno
      e_messagetype = lf_messagetype
      e_messageid   = lf_messageid
    EXCEPTIONS
      no_message    = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
    CALL METHOD oref_log->context_set
      EXPORTING
        i_global_counter = '000000'.
    CALL METHOD oref_log->message_add
      EXPORTING
        i_msgty = lf_messagetype
        i_msgid = lf_messageid
        i_msgno = lf_messageno.
  ENDIF.

* BAdI: Check header " 552774
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    REFRESH lt_badiret.
    CALL METHOD lcl_migo_globals=>if_badi->check_header
      CHANGING
        et_bapiret2 = lt_badiret.
    IF NOT lt_badiret IS INITIAL.
      CALL METHOD oref_log->context_set
        EXPORTING
          i_global_counter = '000000'.
      LOOP AT lt_badiret INTO ls_badiret.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = ls_badiret-type
            i_msgid = ls_badiret-id
            i_msgno = ls_badiret-number
            i_msgv1 = ls_badiret-message_v1
            i_msgv2 = ls_badiret-message_v2
            i_msgv3 = ls_badiret-message_v3
            i_msgv4 = ls_badiret-message_v4.
      ENDLOOP.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'MIMB_PO_REFRESH'.                          "757894

* __________Main loop over items ___________________________________
* subitems are included as 'take_it' will always be passed on by
* main position
  LOOP AT pt_goitem ASSIGNING <goitem> WHERE  take_it = abap_true.
*   Check fieldselection, if all required fields in
*   goitem are filled with data
*   required fields without filled data: application log is filled
    CALL METHOD lcl_migo_screenmodification=>screen_modify_required
      EXPORTING
        is_goitem = <goitem>.
*   BOM header material should never be passed to MB_CREATE.
*   See note 498133
    CHECK <goitem>-xbomtype <> p.
*   Set context for application log = item number (log before posting)
    CALL METHOD oref_log->context_set
      EXPORTING
        i_global_counter = <goitem>-global_counter.

*   Subcontracting components:
    IF <goitem>-xlbtype = c.
*     APPEND to LT_IMSEG only allowed, if PARENT exists and is ready to
*     be posted.
      CLEAR ls_goitem_parent.
      READ TABLE pt_goitem INTO ls_goitem_parent
           WITH KEY global_counter = <goitem>-parent
                    take_it        = abap_true.
      IF sy-subrc <> 0 OR
         ( ls_goitem_parent-erfmg IS INITIAL AND
           ls_goitem_parent-kzbew <> o ).
*       Skip item
        CONTINUE.
      ENDIF.
    ENDIF.
*   Generic articles: Never post any variant without GA
    IF <goitem>-xgatype = c.
      READ TABLE pt_goitem TRANSPORTING NO FIELDS
            WITH KEY global_counter = <goitem>-parent
                    xgatype         = p.
      IF sy-subrc = 0.
        READ TABLE pt_goitem TRANSPORTING NO FIELDS
            WITH KEY global_counter = <goitem>-parent
                    xgatype         = p
                    take_it         = abap_false.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
ENHANCEMENT-SECTION     lmigokg1_02 SPOTS es_saplmigo.
*   structured article
*   only the parent item will be passed to mb_create
*   for cancellation it is necessary to provide the whole document
    IF <goitem>-xsttype = c AND s_action-cancel = abap_false.
      CONTINUE.
    ENDIF.
    IF <goitem>-xvastype = p.
      CLEAR: ls_goitem, ls_goitem_parent.
      LOOP AT pt_goitem INTO ls_goitem
        WHERE parent = <goitem>-global_counter
        AND xvastype = c.
        ls_goitem_parent-erfmg = ls_goitem_parent-erfmg
                                 + ls_goitem-erfmg.
      ENDLOOP.
      IF ls_goitem_parent-erfmg < <goitem>-erfmg.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = w
            i_msgid = 'W#'
            i_msgno = '176'
            i_msgv1 = <goitem>-erfmg
            i_msgv2 = <goitem>-erfme
            i_msgv3 = ls_goitem_parent-erfmg
            i_msgv4 = ls_goitem-erfme.
        <goitem>-erfmg = ls_goitem_parent-erfmg.
      ENDIF.
    ENDIF.

END-ENHANCEMENT-SECTION.

*---ERROR MESSAGES before filling IMSEG
*   161 should not be possible as GI "546270, 554346, 660232, 661520
    IF s_action-migo_mode = 'GI' AND <goitem>-bustr = '161'
     OR ( s_action-migo_mode = 'GR' AND <goitem>-bustr = '161'
     AND NOT <goitem>-ebeln IS INITIAL
     AND <goitem>-retpo IS INITIAL ).
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = e
          i_msgid = 'M7'
          i_msgno = '873'
          i_msgv1 = '161'.
      CONTINUE.
    ENDIF.

ENHANCEMENT-POINT lmigokg1_04 SPOTS es_saplmigo.
*   Ftrade: check if only one vendor and one country
*           if item is related to a purchase order (not 501)
    IF NOT ps_gohead-exnum IS INITIAL AND
       <goitem>-xpoitem = abap_true.
      IF NOT <goitem>-lifnr  = ps_gohead-lifnr OR
         NOT <goitem>-land1  = ps_gohead-land1.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = e
            i_msgid = 'MIGO'
            i_msgno = '034'.
        CONTINUE.
      ENDIF.
    ENDIF.
*   GI for stock transport order: KZBWA must be '01'
*   Ftrade: check if only one vendor and one country
    IF <goitem>-xpoitem =  abap_false AND
       <goitem>-kzzug   =  abap_true  AND
       <goitem>-kzbwa   <> '01'.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = e
          i_msgid = 'MIGO'
          i_msgno = '030'.
      CONTINUE.
    ENDIF.
*   Entry of CHARG/LGORT = * not permitted (note 369599)
    IF <goitem>-lgort = '*' OR
       <goitem>-charg = '*'.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = e
          i_msgid = 'MIGO'
          i_msgno = '046'.
      CONTINUE.
    ENDIF.
*   begin of note 319194
*   goods issue from blocked stock/qualitiy stock allowed ?
    IF NOT <goitem>-migo_insmk IS INITIAL AND
       NOT <goitem>-migo_insmk = f.
*      we will not post from unrestricted use. So we will check BUSTR
*      in order to analyse whether this might be a disallowed movement
*      in our eyes. In that case we have to read table T160M in order to
*      to check whether customer really wants to forbid the movement
      IF <goitem>-bustr = '201' OR
         <goitem>-bustr = '231' OR
         <goitem>-bustr = '241' OR
         <goitem>-bustr = '281'.
        CLEAR l_rc_t160m_check.
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb  = 'MIGO'
            i_msgnr  = '043'
            i_nolog  = x
            i_output = space
          IMPORTING
            rc       = l_rc_t160m_check.
        CASE l_rc_t160m_check.
          WHEN 1.
*          warning
            CALL METHOD oref_log->message_add
              EXPORTING
                i_msgty = w
                i_msgid = 'MIGO'
                i_msgno = '043'.
          WHEN 2.
*          error
            CALL METHOD oref_log->message_add
              EXPORTING
                i_msgty = e
                i_msgid = 'MIGO'
                i_msgno = '043'.
*             continue with next item
            CONTINUE.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDIF.
*   end of note 319194
*   Shipping instruction required but not maintained
    IF NOT <goitem>-evers IS INITIAL AND
           <goitem>-evere IS INITIAL AND
           <goitem>-kzwes <> s.
*     Check whether compliances are maintained. Maintenance is only
*     obligatory then. The function module
*     ME_SHIPPING_INSTRUCT_DEFAULT is unable to provide this
*     information as it returns the exception NO_RECORD_FOUND also
*     if no compliance has the "default"-indicator.
      SELECT evere INTO l_evere
                   FROM t027c UP TO 1 ROWS
                   WHERE evers = <goitem>-evers.
      ENDSELECT.
      IF sy-subrc = 0.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = e
            i_msgid = 'ME'
            i_msgno = '112'.
        CONTINUE.
      ENDIF.
    ENDIF.

* add reason code for item leven
    CALL FUNCTION '/SAPPSPRO/READ_REASON_CODE_LOG'
      EXPORTING
        i_po_number   = <goitem>-ebeln
        i_po_item     = <goitem>-ebelp
      IMPORTING
        e_messageno   = lf_messageno
        e_messagetype = lf_messagetype
        e_messageid   = lf_messageid
      EXCEPTIONS
        no_message    = 1
        OTHERS        = 2.

    IF sy-subrc = 0.
      CALL METHOD oref_log->context_set
        EXPORTING
          i_global_counter = <goitem>-global_counter.
      CALL METHOD oref_log->message_add
        EXPORTING
          i_msgty = lf_messagetype
          i_msgid = lf_messageid
          i_msgno = lf_messageno.
    ENDIF.

*** Government Procurement: check user status in SRM begin
    DATA: lv_us_msgtype  TYPE symsgty,
          lv_us_msgid    TYPE symsgid,
          lv_us_msgno    TYPE symsgno,
          lv_us_msgv1    TYPE symsgv,
          lv_us_msgv2    TYPE symsgv,
          lv_us_msgv3    TYPE symsgv,
          lv_us_msgv4    TYPE symsgv.
    FIELD-SYMBOLS: <uschk_goitem>  TYPE goitem.

*   decide which item to take
    IF <goitem>-xlbtype = c.
      ASSIGN ls_goitem_parent TO <uschk_goitem>.
    ELSE.
      ASSIGN <goitem> TO <uschk_goitem>.
    ENDIF.
*   make user status check if necessary (only receipts)
    IF <uschk_goitem>-shkzg_migo = '+'.  "is it a receipt
      CALL FUNCTION '/SAPPSPRO/USCHK_GOODS_RECEIPT'
        EXPORTING
          iv_ebeln          = <uschk_goitem>-ebeln
          iv_ebelp          = <uschk_goitem>-ebelp
        IMPORTING
          ev_msgtype        = lv_us_msgtype
          ev_msgid          = lv_us_msgid
          ev_msgno          = lv_us_msgno
          ev_msgv1          = lv_us_msgv1
          ev_msgv2          = lv_us_msgv2
          ev_msgv3          = lv_us_msgv3
          ev_msgv4          = lv_us_msgv4
        EXCEPTIONS
          gr_not_allowed    = 1
          allowed_warning   = 2
          srm_not_available = 3
          poinsrm_not_found = 4
          internal_error    = 5
          OTHERS            = 6.
*     check if something went wrong
      IF sy-subrc <> 0.
        CALL METHOD oref_log->context_set
          EXPORTING
            i_global_counter = <goitem>-global_counter.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = lv_us_msgtype
            i_msgid = lv_us_msgid
            i_msgno = lv_us_msgno
            i_msgv1 = lv_us_msgv1
            i_msgv2 = lv_us_msgv2
            i_msgv3 = lv_us_msgv3
            i_msgv4 = lv_us_msgv4.
*       if error occurred -> skip item
        IF lv_us_msgtype = 'E'.
          CONTINUE.
        ENDIF.
      ENDIF.  "sy-subrc = 0
    ENDIF.  "is it a receipt
*** Government Procurement: user status check in SRM end

ENHANCEMENT-POINT goods_movement_fill_02 SPOTS es_saplmigo.
*   BAdI: Check items
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      REFRESH lt_badiret.
      CALL METHOD lcl_migo_globals=>if_badi->check_item
        EXPORTING
          i_line_id   = <goitem>-global_counter
        CHANGING
          et_bapiret2 = lt_badiret.
      CLEAR l_badi_err.
      LOOP AT lt_badiret INTO ls_badiret.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = ls_badiret-type
            i_msgid = ls_badiret-id
            i_msgno = ls_badiret-number
            i_msgv1 = ls_badiret-message_v1
            i_msgv2 = ls_badiret-message_v2
            i_msgv3 = ls_badiret-message_v3
            i_msgv4 = ls_badiret-message_v4.
        IF 'EAX' CS ls_badiret-type.
          l_badi_err = abap_true.
        ENDIF.
      ENDLOOP.
      IF l_badi_err = abap_true.
        CONTINUE.
      ENDIF.
    ENDIF.


ENHANCEMENT-POINT goods_movement_fill_06 SPOTS es_saplmigo.
*---Everthing is ok until now. Fill IMSEG...
    CLEAR: ls_imseg,
           ls_imseg3.
*   Copy the MIGO document structure
    ls_imseg-line_id    = <goitem>-global_counter.
    ls_imseg-parent_id  = <goitem>-parent.
    ls_imseg-line_depth = <goitem>-depth.
*   in case of tied empty ->adjust quantities and other specific data
*   <LG>
    IF <goitem>-xvgtype = c.
      CALL METHOD goods_movement_adjust_tied_ety
        EXPORTING
          it_imseg        = lt_imseg
        IMPORTING
          es_goitem_full  = ls_goitem_full_head
        CHANGING
          ct_slcomp       = lt_slcomp
          cs_goitem_empty = <goitem>
          i_refix         = ls_imseg-refix
        EXCEPTIONS
          fp_not_found    = 01
          bom_not_found   = 02.
      IF sy-subrc <> 0.
*   process error output into log
        CALL METHOD goods_movement_error_empties
          EXPORTING
            i_subrc             = sy-subrc
            is_goitem_empty     = <goitem>
            is_goitem_full_head = ls_goitem_full_head.
        CONTINUE.
      ENDIF.
    ENDIF.
*   Fill interface for MB_CREATE_GOODS_MOVEMENT
    MOVE-CORRESPONDING <goitem>  TO ls_imseg3.
    MOVE-CORRESPONDING ls_imseg3 TO ls_imseg.
*   Mapping company code, profit center and business area
    CLEAR: ls_imseg-gsber,
           ls_imseg-prctr,
           ls_imseg-bukrs.
    ls_imseg-pargb  = <goitem>-gsber.
    ls_imseg-pprctr = <goitem>-prctr.
    ls_imseg-parbu  = <goitem>-bukrs.
    ls_imseg-bukrs  = <goitem>-bukrs_for_stock.
    ls_imseg-lifnr  = <goitem>-lifnr.
*   Special stock identifier: Move UMMAT-fields to correct IMSEG-fields
    CALL METHOD special_stock_imseg_set
      EXPORTING
        is_goitem = <goitem>
      CHANGING
        cs_imseg  = ls_imseg.
*   Use data from UMVFDAT/UMHSDAT:
    IF s_action-migo_mode = 'GT' AND <goitem>-shkzg = h.
      ls_imseg-hsdat = <goitem>-umhsdat.
      ls_imseg-vfdat = <goitem>-umvfdat.
    ENDIF.
ENHANCEMENT-POINT goods_movement_fill_03 SPOTS es_saplmigo.
*   mark position as parent or component of subcontracting/subsequnt
*   adjustment
    ls_imseg-xlbtype = <goitem>-xlbtype.                    "734758
*   Some more single moves
    IF NOT <goitem>-retpo IS INITIAL.
      ls_imseg-bwart = <goitem>-bwart_retpo.
    ELSE.
      ls_imseg-bwart = <goitem>-bwart.
    ENDIF.
    ls_imseg-insmk = <goitem>-migo_insmk.
    ls_imseg-smbln = <goitem>-smbln.
    ls_imseg-sjahr = <goitem>-sjahr.
    ls_imseg-smblp = <goitem>-smblp.
    ls_imseg-exbwr = <goitem>-exbwr.
    ls_imseg-exvkw = <goitem>-exvkw.
    ls_imseg-j_1bexbase = <goitem>-j_1bexbase.
    IF s_action-return = abap_true.
      ls_imseg-xstor = '1'.
      IF <goitem>-xhistma = 'X'.                            "MAA2
        ls_imseg-maa_urzei = <goitem>-maa_urzei.            "MAA2
      ENDIF.                                                "MAA2
    ENDIF.
*   Fields from "goods receipt for purchase order" (if filled) to IMSEG
    IF NOT <goitem>-pps_aufnr IS INITIAL.
      ls_imseg-aufnr = <goitem>-pps_aufnr.
    ENDIF.
    IF NOT <goitem>-pps_posnr IS INITIAL.
      ls_imseg-aufps = <goitem>-pps_posnr.
    ENDIF.
*   product units: in order that imseg-menge will not be cleared
*   by MB_CREATE, we have to set xmenge.
    IF NOT <goitem>-kzwsm IS INITIAL.
      ls_imseg-xmenge = abap_true.
    ENDIF.
*   Subcontracting components:
    IF <goitem>-xlbtype = c.
*     APPEND to LT_IMSEG only allowed, if PARENT exists and is ready to
*     be posted.
      CLEAR ls_goitem_parent.
      READ TABLE pt_goitem INTO ls_goitem_parent
           WITH KEY global_counter = <goitem>-parent.
*     Fill in the right quantity sign depending on
*     field SC_ADJUST: SC_ADJUST = space = under consumption ->
*     positive quantity, otherwise negative quantity.
      IF ls_goitem_parent-kzbew = o.
        IF <goitem>-sc_adjust = x.
          ls_imseg-erfmg = ls_imseg-erfmg * ( -1 ).
          ls_imseg-menge = ls_imseg-menge * ( -1 ).
        ENDIF.
ENHANCEMENT-POINT lmigokg1_03 SPOTS es_saplmigo.
      ENDIF.
    ENDIF.
*   retail subitems following; <LG>
*   upvor = 3 in case of full product
    ls_imseg-upvor = <goitem>-hpos_wws.
*   Value added services
    IF <goitem>-xvastype = p.
      ls_imseg-upvor = '9'.
    ENDIF.
    ls_imseg-xdeliv = ps_gohead-create_delivery.
    IF <goitem>-xresitem = abap_true.
      ls_imseg-xrere = abap_true.
    ENDIF.
    IF <goitem>-kzwes = s.
      CLEAR ls_imseg-insmk.
    ENDIF.
*   Number of GR slips: MIGO has already calculated everything,  "333860
*   so just give the result to MB_CREATE
    ls_imseg-weanzx = x.
*   WEMPF and ABLAD: MIGO knows it better, so always set X-field "339567
    ls_imseg-wempfx = x.
    ls_imseg-abladx = x.
    IF NOT ls_imseg-vlief_avis IS INITIAL AND
       NOT ls_imseg-vbelp_avis IS INITIAL.
      CALL FUNCTION 'MIMB_PO_EXPORT'                        "757894_v
        EXPORTING
          i_ebeln   = ls_imseg-ebeln
          i_ebelp   = ls_imseg-ebelp
          i_line_id = ls_imseg-line_id.                     "757894_^
      CLEAR: ls_imseg-ebeln, ls_imseg-ebelp.
    ENDIF.
*   L_COUNTER for serial number renumberich. Will be also used in the
*   next loop at pt_goitem for subcontracting components
*   note 734758 start
    l_ser_add = abap_false.
    IF <goitem>-xlbtype = c AND <goitem>-menge IS INITIAL.
*     Note 734758: Don't add components with quantity = 0 to
*     pt_goserial_post otherwise lt_sermbuz before 'renumber' in
*     buchen_ausfuhren will be wrong (it is built up depending on zmbuz
*     and ymbuz -> they have no reference to 543 or 544 lines
*     with quantity = 0)
      l_ser_add = abap_false.
    ELSEIF <goitem>-xlbtype = p AND <goitem>-kzbew = o.
*     during subsequent adjustment parent lines are removed if there
*     are no componentes for them with quantity <> 0.
*     Those parents also must not be added to pt_goserial_post.
      LOOP AT pt_goitem TRANSPORTING NO FIELDS
                        WHERE parent  = <goitem>-global_counter
                        AND   take_it = abap_true
                        AND   erfmg   <> 0.
        l_ser_add = abap_true.
        EXIT.
      ENDLOOP.
    ELSE.
      l_ser_add = abap_true.
    ENDIF.
*   note 734758 end
ENHANCEMENT-POINT lmigokg1_05 SPOTS es_saplmigo.
    IF l_ser_add = abap_true.                               "734758
      l_counter_serial = l_counter_serial + 1.
      CALL METHOD serialnumbers_fill
        EXPORTING
          i_counter        = l_counter_serial
          i_global_counter = <goitem>-global_counter.
    ENDIF.                                                  "734758
    ls_imseg-called_by = 'MIGO'.
    INSERT ls_imseg INTO TABLE lt_imseg.
*   Extract the first VBELN
    IF l_vbeln IS INITIAL.
      l_vbeln = <goitem>-vbeln.
    ENDIF.
  ENDLOOP.
* End of main loop _____________________________________________________

* Subsequent adjustment:
* If parent (item for 121 movement) has take_it, then at least one
* component needs a quantity. If this is not true we have 3 options:
* a. Error message: Do not allow to post the item.
* b. Warning message: Skip that item but issue warning during
*    check/post, that no relevant components exist.
* c. No message: Just skip the item and post the rest of the
*    document.
  LOOP AT pt_goitem ASSIGNING <goitem> WHERE xlbtype = p
                                         AND take_it = abap_true
                                         AND kzbew = o.
*   Check for children with quantity and take_it
    LOOP AT pt_goitem ASSIGNING <ls_goitem_child>
                      WHERE parent  = <goitem>-global_counter
                      AND   take_it = abap_true
                      AND   erfmg   <> 0.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0.
*     Set context for application log = item number (log before posting)
      CALL METHOD oref_log->context_set
        EXPORTING
          i_global_counter = <goitem>-global_counter.

      CLEAR l_rc_t160m_check.
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          i_arbgb  = 'MIGO'
          i_msgnr  = '052'
          i_nolog  = x
          i_output = space
        IMPORTING
          rc       = l_rc_t160m_check.
      CASE l_rc_t160m_check.
        WHEN 1.
*         warning
          CALL METHOD oref_log->message_add
            EXPORTING
              i_msgty = w
              i_msgid = 'MIGO'
              i_msgno = '052'.
        WHEN 2.
*         error
          CALL METHOD oref_log->message_add
            EXPORTING
              i_msgty = e
              i_msgid = 'MIGO'
              i_msgno = '052'.
        WHEN OTHERS.
      ENDCASE.
*     Skip item and corresponding components
      DELETE lt_imseg WHERE global_counter = <goitem>-global_counter.
      DELETE lt_imseg WHERE      parent_id = <goitem>-global_counter.
    ENDIF.
  ENDLOOP.

* GR to Subcontracting-PO:
* If all components have an initial TAKE_IT, LT_IMSEG will need an entry
* with a component (quantity = 0) to prevent MB_CREATE_GOODS_MOVEMENT
* from posting all components (-> old logic).
  LOOP AT pt_goitem ASSIGNING <goitem> WHERE xlbtype = c
                                         AND take_it = abap_false.
*   Check if parent exists (and the quantity <> 0)
    READ TABLE lt_imseg INTO ls_imseg
         WITH KEY line_id = <goitem>-parent.
    IF sy-subrc IS INITIAL.
      CLEAR ls_imseg.
      MOVE-CORRESPONDING <goitem>  TO ls_imseg3.
      MOVE-CORRESPONDING ls_imseg3 TO ls_imseg.
      ls_imseg-line_id    = <goitem>-global_counter.
      ls_imseg-parent_id  = <goitem>-parent.
      ls_imseg-line_depth = <goitem>-depth.
      ls_imseg-called_by  = 'MIGO'.
      CLEAR ls_imseg-erfmg.
      ls_imseg-xlbtype    = <goitem>-xlbtype.
      APPEND ls_imseg TO lt_imseg.
    ENDIF.
  ENDLOOP.

  CHECK NOT lt_imseg IS INITIAL.
  et_imseg = lt_imseg.

* Bill of materials: BOM-header won't be posted (only necessary for
* showing the hierarchy), but it's necessary to set parent_id /
* line_depth of BOM-positions in lt_imseg (<-NOT in pt_goitem!)
  CALL METHOD goods_movement_bom_handling
    CHANGING
      ct_imseg = et_imseg.

* Export freight data to SAPMM07M:
  CALL FUNCTION 'MIMB_FREIGHT_EXPORT'
    TABLES
      i_t_gofreight = pt_gofreight_kernel.
  MOVE-CORRESPONDING ps_gohead TO es_imkpf.
* Field wever filled by move-corresponding - note 315434
  es_imkpf-weverx = abap_true.                              "315434
* The following fields should never be taken from former documents
  CLEAR: es_imkpf-usnam.                                    "211997

* Clear of note 199805 removed by note 499785. As XBLNR is visible
* at screen, it should as well be posted and passed to MB_CREATE
* CLEAR: es_imkpf-xblnr,                                   "499785
*        es_imkpf-lifex,                                   "499785
*        es_imkpf-frbnr.                                   "499785

* Printing:
* 1 will set RM07M-XNAPR in MM07MFD0 to 'X' = print, if possible
* 2 will set RM07M-XNAPR in MM07MFD0 to ' ' = no print
* space = 'read parameter NDR' but not needed in MIGO, we know it better
  es_imkpf-pr_print = 1.
  IF ps_gohead-xnapr = abap_false.
    es_imkpf-pr_print = 2.
  ENDIF.
* Copy the first VBELN from GOITEM into XBLNR of the header if
* not filled yet. This is used for delivery numbers as they are
* not stored in MSEG yet, but are used by invoice verification.
* Only executed for "Goods receipt for outbound delivery"
  IF s_control-action = 'A01' AND s_control-refdoc = 'R05'.
*   but don't overwrite a manual entry                           "880631
    IF es_imkpf-xblnr IS INITIAL
       OR ps_gohead-xblnr_manual IS INITIAL.                "880631
      es_imkpf-xblnr = l_vbeln.
*     make XBLNR visible on the MIGO header screen               "880631
      MOVE l_vbeln TO ps_gohead-xblnr.                      "880631
    ENDIF.
  ENDIF.
* Manual XBLNR has priority. A double move is necessary: "499785
* . IMKPF-XBLNR goes to MKPF-XBLNR
* . IMKPF-LIFEX goes to EKBE-XBLNR
* In case of reference to a material document, header data
* from old document has precedence as well.
* Assume that move can be done always as well as never, but note 499785
* keeps the following if statement in order to prevent that further
* changes within MB_CREATE will have effect on MIGO.
  IF ps_gohead-xblnr_manual = abap_true OR
     s_control-refdoc = 'R02' OR       "mat doc
     s_control-refdoc = 'R03' OR       "delivery slip
     s_control-refdoc = 'R04'.         "inbound delivery
    es_imkpf-lifex = ps_gohead-xblnr.
  ENDIF.
*-=> Start of note 827015

* Background of correction: a goods-receipt with reference to a
* transport ID is posted. The transport ID contains various inbound
* deliveries, which are linked to different external IDs (table LIKP /
* field VERUR).

* Now see the documentation for XBLNR in transaction MB0A:
*
*     General idea:
*
*     a) Manual entries have always priority
*
*     b) No manual entry: If no delivery slip entered manually,
*        we copy the external document number from inbound delivery
*        (ME_CONFIRMATION_SEARCH_GR gives us VERUR) to VM07M-XBLNR_AVIS,
*        which will fill EKBE-XBLNR. Two cases:
*
*        i)  One VERUR for all items: copy to MKPF-XBLNR and EKBE-XBLNR
*        ii) Several VERUR for all items:	 copy to EKBE-XBLNR only.
*
* In order to have the same system-behaviour in transaction MIGO the
* value of XBLNR has to be cleared, if it was not entered manually.

* The same applies for FRBNR, which fills MKPF-FRBNR and/or
* EKBZ-FRBNR.

  IF ps_gohead-xblnr_manual <> abap_true AND s_control-refdoc = 'R07'.
    CLEAR es_imkpf-xblnr.
  ENDIF.

  IF ps_gohead-frbnr_manual <> abap_true AND s_control-refdoc = 'R07'.
    CLEAR es_imkpf-frbnr.
  ENDIF.
*-=> End of note 827015
ENDMETHOD.                    "goods_movement_fill

************************************************************************
* Fill the interface to MB_CANCEL_GOODS_MOVEMENT
************************************************************************
METHOD goods_cancel_fill.
  DATA: lt_gocancel      TYPE STANDARD TABLE OF gocancel,
        lt_gocomp        TYPE STANDARD TABLE OF gocomp,
        ls_gocancel      TYPE gocancel,
        l_cancel         TYPE ty_cancel,
        l_print          TYPE imkpf-pr_print,
        l_counter_serial TYPE sy-tabix,
        ls_goitem        TYPE goitem,
        l_take_it        TYPE mb_take_it,
        lt_badiret  TYPE bapiret2_t,              "BAdI: Message table
      ls_badiret  TYPE bapiret2,              "BAdI: Message structure
        l_badi_err  TYPE abap_bool.               "BAdI: Error message

  FIELD-SYMBOLS: <goitem> TYPE ty_s_goitem.
* clear loglevel for all items and header before beginning...
  CLEAR ps_gohead-loglevel.
  MODIFY pt_goitem FROM ls_goitem TRANSPORTING loglevel
                                  WHERE loglevel NE space.
* Check required fields in gohead
  CALL METHOD lcl_migo_screenmodification=>screen_modify_required
    EXPORTING
      is_gohead = ps_gohead.
* BAdI: Check header
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    REFRESH lt_badiret.
    CALL METHOD lcl_migo_globals=>if_badi->check_header
      CHANGING
        et_bapiret2 = lt_badiret.
    IF NOT lt_badiret IS INITIAL.
      CALL METHOD oref_log->context_set
        EXPORTING
          i_global_counter = '000000'.
      LOOP AT lt_badiret INTO ls_badiret.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = ls_badiret-type
            i_msgid = ls_badiret-id
            i_msgno = ls_badiret-number
            i_msgv1 = ls_badiret-message_v1
            i_msgv2 = ls_badiret-message_v2
            i_msgv3 = ls_badiret-message_v3
            i_msgv4 = ls_badiret-message_v4.
      ENDLOOP.
    ENDIF.
  ENDIF.
* take over materials flagged on;
* subitems are included as flag 'take_it' is always passed on by
* main item; <LG>
  LOOP AT pt_goitem ASSIGNING <goitem> WHERE NOT take_it IS INITIAL.
*   Set context for application log = item number (log before posting)
    CALL METHOD oref_log->context_set
      EXPORTING
        i_global_counter = <goitem>-global_counter.
*   ZEILE of the position in the original material document.
*   Filled in MATERIALDOCUMENT_GET. Do NOT NOT NOT use GOITEM-ZEILE
*   as this field has been raped by MIGO for the use of the button
*   labelling...
    l_cancel = <goitem>-smblp.
*   Ftrade: check if only one vendor and one country
*           if item is related to a purchase order (not 501)     "427858
    IF NOT ps_gohead-exnum IS INITIAL AND
       <goitem>-xpoitem = abap_true.
      IF NOT <goitem>-lifnr  = ps_gohead-lifnr OR
         NOT <goitem>-land1  = ps_gohead-land1.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = e
            i_msgid = 'MIGO'
            i_msgno = '034'.
        CLEAR l_cancel.
        CONTINUE.
      ENDIF.
    ENDIF.
*   BAdI: Check items
    IF NOT lcl_migo_globals=>if_badi IS INITIAL.
      REFRESH lt_badiret.
      CALL METHOD lcl_migo_globals=>if_badi->check_item
        EXPORTING
          i_line_id   = <goitem>-global_counter
        CHANGING
          et_bapiret2 = lt_badiret.
      CLEAR l_badi_err.
      LOOP AT lt_badiret INTO ls_badiret.
        CALL METHOD oref_log->message_add
          EXPORTING
            i_msgty = ls_badiret-type
            i_msgid = ls_badiret-id
            i_msgno = ls_badiret-number
            i_msgv1 = ls_badiret-message_v1
            i_msgv2 = ls_badiret-message_v2
            i_msgv3 = ls_badiret-message_v3
            i_msgv4 = ls_badiret-message_v4.
        IF 'EAX' CS ls_badiret-type.
          l_badi_err = abap_true.
        ENDIF.
      ENDLOOP.
      IF l_badi_err = abap_true.
        CONTINUE.
      ENDIF.
    ENDIF.
*


ENHANCEMENT-POINT goods_cancel_fill_01 SPOTS es_saplmigo.
    INSERT l_cancel INTO TABLE et_cancel.
    MOVE-CORRESPONDING <goitem> TO ls_gocancel.
    ls_gocancel-mblpo = <goitem>-smblp.
    INSERT ls_gocancel INTO TABLE lt_gocancel.
*   L_COUNTER for serial numbers renumberich
    l_counter_serial = l_counter_serial + 1.
    CALL METHOD serialnumbers_fill
      EXPORTING
        i_counter        = l_counter_serial
        i_global_counter = <goitem>-global_counter.
*   Required fields at position level
    CALL METHOD lcl_migo_screenmodification=>screen_modify_required
      EXPORTING
        is_goitem = <goitem>.

  ENDLOOP.
  CHECK NOT et_cancel IS INITIAL.
* Export freight data to SAPMM07M
  CALL FUNCTION 'MIMB_FREIGHT_EXPORT'
    TABLES
      i_t_gofreight = pt_gofreight_kernel.
* Printing
* 1 will set RM07M-XNAPR in MM07MFD0 to 'X' = print, if possible
* 2 will set RM07M-XNAPR in MM07MFD0 to ' ' = no print
  l_print = 1.
  IF ps_gohead-xnapr IS INITIAL.
    l_print = 2.
  ENDIF.
* MB_CANCEL_GOODS_MOVEMENT will look at this data
  CALL FUNCTION 'MIMB_CANCEL_EXPORT'
    EXPORTING
      i_header_text  = ps_gohead-bktxt
      i_print        = l_print
      i_import_exnum = ps_gohead-exnum
      i_wever        = ps_gohead-wever
      i_weverx       = abap_true
    TABLES
      i_t_gocancel   = lt_gocancel.
ENDMETHOD.                    "goods_cancel_fill

************************************************************************
* Call MB_POST_GOODS_MOVEMENT to create the material document
************************************************************************
* CAUTION: before you call this method, make sure MB_CREATE or MB_CANCEL
* returned with EMKPF-SUBRC = 1. This has to be checked by the caller.
************************************************************************
METHOD goods_movement_post.
  DATA: ls_emkpf TYPE ty_s_emkpf,
        ls_message  TYPE lif_migo_frame~ty_s_message,
        ls_key      TYPE ty_s_refdockey,
        l_tafkz     TYPE t321-tafkz.                        "201156
* XBLNR cannot be given to MB_POST because it resets the XBLNR
* assigned automatically for Brazil in BUCHEN_NUMMERNVERGABE "qla
  CALL FUNCTION 'MB_POST_GOODS_MOVEMENT'
*      EXPORTING
*           xblnr_sd = is_imkpf-xblnr
       IMPORTING
            emkpf    = ls_emkpf.
  IF ls_emkpf-subrc IS INITIAL.
*   check if a deliver or material document was created.
    IF ls_emkpf-mblnr IS INITIAL.
*      MESSAGE s514(l9) WITH es_emkpf_old-msgv1.             "1269521
      MESSAGE ID es_emkpf_old-msgid TYPE s                  "1269521
          NUMBER es_emkpf_old-msgno                         "1269521
            WITH es_emkpf_old-msgv1 es_emkpf_old-msgv2      "1269521
                 es_emkpf_old-msgv3 es_emkpf_old-msgv4.     "1269521
    ELSE.
      SET PARAMETER ID 'MBN' FIELD ls_emkpf-mblnr.
      SET PARAMETER ID 'MJA' FIELD ls_emkpf-mjahr.
      MESSAGE s012 WITH ls_emkpf-mblnr.
*       Send message with the new document
      ls_key-mat_doc  = ls_emkpf-mblnr.
      ls_key-doc_year = ls_emkpf-mjahr.
      CALL METHOD new_document
        EXPORTING
          i_refdoc       = 'R02'
          i_from_posting = abap_true
          is_key         = ls_key.

    ENDIF.
*   note 201156:
*   Read the flag stored by TA_AUTOMATISCH (MM07MLVS) to determine
*   whether a direct call to LT06 (create transport request) is
*   set up in customizing of table T321.
*   In this case, we execute COMMIT WORK AND WAIT, so that the
*   material document is surely on the database as LT06 reads it.
    IMPORT lvs_tafkz = l_tafkz FROM MEMORY ID 'MIGO'.
ENHANCEMENT-SECTION     GOODS_MOVEMENT_FILL_04 SPOTS ES_SAPLMIGO.
    IF l_tafkz = x.
      COMMIT WORK AND WAIT.
      CALL METHOD reset.
      CALL TRANSACTION 'LT06'.
    ELSE.
      COMMIT WORK.
      CALL METHOD reset.
    ENDIF.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT goods_movement_fill_05 SPOTS es_saplmigo.
  ENDIF.
ENDMETHOD.                    "goods_movement_post

ENHANCEMENT-POINT lmigokg1_01 SPOTS es_saplmigo STATIC.
************************************************************************
* Bill of materials:
* In MIGO BOM-header is displayed (-> to ENJOY the visual display of the
* hierarchy), but BOM-header will not be posted !!!
* => It's necessary to modify parent_id / line_depth of BOM-positions,
*    to preserve the correct hierarchy level.
*    Right now the result should be
*            parent_id = '000000' and line_depth = '00'
*    because it's not possible to make a BOM explosion for a position
*    with line_depth <> '00'.
************************************************************************
METHOD goods_movement_bom_handling.
  FIELD-SYMBOLS: <header>   TYPE goitem,
                 <position> TYPE imseg.
* find BOM-header
  LOOP AT pt_goitem ASSIGNING <header> WHERE xbomtype = p.
*   find BOM-positions for BOM-header
    LOOP AT ct_imseg ASSIGNING <position>
                            WHERE parent_id = <header>-global_counter.
*     Use BOM-header hierarchy level to modify BOM-position. Needed to
*     preserve the correct hierarchy after deletion of BOM-header.
      <position>-parent_id  = <header>-parent.
      <position>-line_depth = <header>-depth.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.                    "goods_movement_bom_handling