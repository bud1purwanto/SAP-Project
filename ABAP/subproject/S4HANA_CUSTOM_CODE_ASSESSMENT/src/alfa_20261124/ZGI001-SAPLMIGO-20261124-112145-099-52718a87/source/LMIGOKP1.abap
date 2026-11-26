*----------------------------------------------------------------------*
*   INCLUDE LMIGOKP1 Purchase order                                    *
*----------------------------------------------------------------------*

************************************************************************
* Externally called method to add the data of a purchase order
************************************************************************
METHOD purchase_order_read.
  CALL METHOD purchase_order_get
    EXPORTING
      i_po_number = i_po_number
      i_po_item   = i_po_item
      i_po_werks  = i_po_werks.
ENDMETHOD.                    "purchase_order_read

************************************************************************
* Internally called method to add a purchase order. Also used
* for goods receipt for shipping notification, transport, ...
************************************************************************
METHOD purchase_order_get.
  DATA: lt_poitem    TYPE ty_t_poitem,
        lt_st_poitem TYPE ty_t_st_poitem,
        lt_pofreight TYPE ty_t_pofreight,
        ls_control   TYPE ty_s_control,
        lt_ekpo      TYPE TABLE OF ekpo,
        ls_ekpo      TYPE ekpo.
ENHANCEMENT-POINT EHP604_PURCHASE_ORDER_GET_01 SPOTS es_saplmigo STATIC .

  FIELD-SYMBOLS: <ls_poitem> TYPE ty_s_poitem.
* Before getting a purchase order, the new-line-mode has to be
* deactivated. Only this way the correct movement type is
* available. Furthermore, as there is no way of diabling new-line-mode
* directly...here it is.
  ls_control = s_control.
  ls_control-new_line_mode = space.
  CALL METHOD mode_set( is_control = ls_control ).
* Read Header
  CALL METHOD purchase_order_read_header
    EXPORTING
      i_po_number = i_po_number.
  CHECK NOT ps_pohead IS INITIAL.
  IF s_defaults-sobkz = o AND  s_control-action = 'A07'.
    s_action-sc_comp = abap_true.
  ENDIF.
* Goods Receipt
  IF s_action-migo_mode <> 'GI'.
* Begin of Outsourced Manufacturing EhP4
* Subcontracting
    IF s_control-action = 'A08' AND s_control-refdoc = 'R01'.
      CALL METHOD purchase_order_sc_data_fill
        EXPORTING
          i_po_number = i_po_number
          i_po_item   = i_po_item
          i_po_werks   = i_po_werks
          i_ib_number  = i_ib_number
          i_ib_item    = i_ib_item
        IMPORTING
          et_poitem   = lt_poitem.
    ELSE.
   "of Outsourced Manufacturing EhP4
      CALL METHOD purchase_order_read_data
        EXPORTING
          i_po_number  = i_po_number
          i_po_item    = i_po_item
          i_po_werks   = i_po_werks
          i_ib_number  = i_ib_number
          i_ib_item    = i_ib_item
        IMPORTING
          et_poitem    = lt_poitem
          et_pofreight = lt_pofreight.
    ENDIF.
ENHANCEMENT-POINT EHP604_PURCHASE_ORDER_GET_02 SPOTS es_saplmigo.

    CALL METHOD purchase_order_fill_data
      EXPORTING
        it_poitem    = lt_poitem
        it_pofreight = lt_pofreight
        i_ib_number  = i_ib_number
        is_wueb      = is_wueb
        is_vepwe     = is_vepwe
        i_delivery   = i_delivery.
  ELSE.
    IF s_action-sc_comp IS INITIAL.                                "Outsourced Manufacturing EhP4
*   Goods issue referring to a transport order
      CALL METHOD purchase_order_st_read_data
        EXPORTING
          i_po_number  = i_po_number
          i_po_item    = i_po_item
          i_po_werks   = i_po_werks
        IMPORTING
          et_st_poitem = lt_st_poitem
          et_pofreight = lt_pofreight.
        CALL METHOD purchase_order_st_fill_data
          EXPORTING
            it_st_poitem = lt_st_poitem
            it_pofreight = lt_pofreight.
        CLEAR s_action-sc_comp.                                      "Outsourced Manufacturing EhP4
    ELSE.      "s_action-sc_comp = abap_true.                        "Begin of Outsourced Manufacturing EhP4
*   Goods issue (consumption) of SC components
      CALL METHOD purchase_order_sc_data_fill
        EXPORTING
          i_po_number = i_po_number
          i_po_item   = i_po_item
          i_po_werks   = i_po_werks
          i_ib_number  = i_ib_number
          i_ib_item    = i_ib_item
        IMPORTING
          et_poitem   = lt_poitem.
    ENDIF.                                                            "End of Outsourced Manufacturing EhP4
  ENDIF.
ENDMETHOD.                    "purchase_order_get

************************************************************************
* Read the data from a purchase order into PS_POHEAD
************************************************************************
METHOD purchase_order_read_header.
  DATA: l_msgty         TYPE symsgty,
        l_reject        TYPE abap_bool,
        l_m7031rc       TYPE sysubrc,
        l_display       TYPE c.
* Reset data
  CLEAR: ps_pohead.
* Set display field:
* - in display mode, set to x
* - in creation mode, set to m. It means we do not enqueue in MIGO
*   but some checks are done (like PO released?)
  IF s_action-display = abap_true.
    l_display = x.
  ELSE.
    l_display = m.
  ENDIF.
* Read header
  CALL FUNCTION 'ME_READ_HEADER_GOODS_RECEIPT'
    EXPORTING
      ebeln           = i_po_number
      display         = l_display
    IMPORTING
      kbefu           = ps_pohead
    EXCEPTIONS
      not_activ       = 1
      not_found       = 2
      wrong_type      = 3
      not_released    = 4
      parked_document = 5
      error_message   = 6.
* Fake for SLIN. We DO evaluate the sy-subrc, but SLIN is too dull.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
  IF s_action-create = abap_true.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
*       Marked as deleted
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb  = 'M7'
            i_msgnr  = '031'
            i_nolog  = x
            i_output = space
          IMPORTING
            rc       = l_m7031rc.
*       Reject only if error
        IF l_m7031rc = 2.
          l_reject = abap_true.
        ENDIF.
*       Give message in these cases (all below W --> warning)
        IF l_m7031rc <> 0.
          CASE l_m7031rc.
            WHEN 2.      l_msgty = e.
            WHEN OTHERS. l_msgty = w.
          ENDCASE.
          def_msg_add oref_doc_log l_msgty 'M7' '031'
                      i_po_number space space space.
        ENDIF.
      WHEN 2.
*       Not found
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '030'
                    i_po_number space space space.
      WHEN 3.
*       Wrong type
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '032'
                    i_po_number space space space.
      WHEN 4 OR 5 OR 6.
*       Any other error message, also exceptions PARKED_DOCUMENT
*       and NOT_RELEASED.
        l_reject = abap_true.
        def_msg_add oref_doc_log e sy-msgid sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDCASE.
*   Ftrade: only one vendor and one country in a material document
*   Check only necessary if refdoc not a material document.
    IF s_control-refdoc <> 'R02' AND s_control-refdoc <> 'R03'.
*   On header level only possible to check the vendor, not the country
*    - 1st case: exnum is set in GOHEAD:
*      If exnum is already set in header from a previous document,
*      check that the new document has the same vendor
*    - 2nd case: exnum is set in POHEAD but not in GOHEAD
*      If gohead-lifnr is set, it means user has already entered a PO
*      without ftrade data
      IF NOT ps_gohead-exnum IS INITIAL OR                  "1st case
         ( NOT ps_pohead-exnum IS INITIAL AND               "2nd case
           NOT ps_gohead-lifnr IS INITIAL ).
*       Stock transfer order: check plant
        IF ps_pohead-bsakz = t.                             "307238
          IF ps_pohead-reswk <> ps_gohead-reswk.            "307238
            l_reject = abap_true.
            def_msg_add oref_doc_log e 'MIGO' '034'
                        space space space space.
          ENDIF.                                            "307238
*       Other purchase order: check vendor
        ELSEIF ( ps_pohead-lifnr <> ps_gohead-lifnr   ) OR
               ( ps_pohead-llief <> ps_gohead-llief ).
          l_reject = abap_true.
          def_msg_add oref_doc_log e 'MIGO' '034'
                      space space space space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* Stop, if there has been an error while reading the PO
  IF l_reject = abap_true.
    CLEAR ps_pohead.
  ENDIF.
ENDMETHOD.                    "purchase_order_read_header

************************************************************************
* Read the data from a purchase order into the tables T_POITEM,
* PS_POHEAD,
************************************************************************
METHOD purchase_order_read_data.
  DATA: lt_poitem       TYPE ty_t_poitem,
        lt_pofreight    TYPE ty_t_pofreight,
        lt_po_acc       TYPE ty_t_po_acc,       "MAA-DEV
        lt_po_acc_srv   TYPE ty_t_po_acc,       "MAA-DEV
        ls_got156       TYPE got156,
        ls_goplant      TYPE goplant,  "needed for ftrade
        l_reject        TYPE abap_bool,
        l_welfbnr       TYPE abap_bool,
        l_msgty         TYPE symsgty,
        l_subrc         TYPE sysubrc,
        l_display       TYPE c,                             "319678
        l_gr_po         TYPE c,
        l_move          TYPE bwart.

  FIELD-SYMBOLS: <ls_poitem> TYPE ty_s_poitem. "needed for ftrade
  IF s_action-subsequent = abap_true.
    l_welfbnr = abap_true.
  ENDIF.

  l_move = s_defaults-bwart.
  IF s_control-action = 'A11'.
    CALL METHOD lcl_migo_buffer=>move_type_next_get
      EXPORTING
        i_move      = space
        i_fcode     = 'LBMB'
      RECEIVING
        e_move_next = l_move
      EXCEPTIONS
        not_found   = 1.
    IF sy-subrc <> 0.
      def_msg_add oref_doc_log e 'MICK' '001' s_defaults-bwart space
                                                        space space.
      EXIT.
    ENDIF.
  ENDIF.
* Read data for the current movement type from the defaults
* (will be used to fill the movement type).
* If working with reference to a material document, the PO is
* read just for info and the data are not so important.
* Exception: Subsequent adjustment
  IF NOT ( s_control-refdoc = 'R02' OR s_control-refdoc = 'R03' )
     OR s_control-action = 'A11'.
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING
        i_move    = l_move
      IMPORTING
        e_got156  = ls_got156
      EXCEPTIONS
        not_found = 1.
    IF sy-subrc <> 0.
      def_msg_add oref_doc_log e 'MICK' '001' l_move space space space.
      EXIT.
    ENDIF.
  ELSE.
*   Fill in anything as we will just read the PO.
    ls_got156-shkzg = s.
    ls_got156-kzwes = space.
  ENDIF.
"begin Outsourced Manufacturing EhP 4
  IF s_action-sc_comp = abap_true AND ls_got156-bustr = '543'.
*   Fill in anything as we will just read the PO.
    ls_got156-shkzg = s.
    ls_got156-kzwes = space.
  ENDIF.
" end Outsourced Manufacturing EhP 4

* GR with ref. to PO -> Caution for SIT processes!
  IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
    IF s_control-action = 'A01' AND s_control-refdoc = 'R01'.
      l_gr_po = 'X'.
    ENDIF.
  ENDIF.

* Set display field:
* - in display mode, set to x
* - in creation mode, set to m.
* see note 319678. Due to changes in source of MM-PUR, we need to call
* the ME_READ_ITEM_GOODS_RECEIPT with display-flag different to X as
* otherwise they will not read the confirmations.
  IF s_action-display = abap_true.                          "319678
    l_display = x.
  ELSE.
    l_display = m.
  ENDIF.
  CALL FUNCTION 'ME_READ_ITEM_GOODS_RECEIPT'
    EXPORTING
      ebeln         = i_po_number
      ebelp         = i_po_item
      i_werks       = i_po_werks
      kzwes         = ls_got156-kzwes
      lfbnr         = i_lfbnr
      lfgja         = i_lfbja
      lfpos         = i_lfpos
      i_smbln       = i_md_number
      i_sjahr       = i_md_year
      i_smblp       = i_md_item
      shkzg         = ls_got156-shkzg
      i_vbeln       = i_ib_number
      i_vbelp       = i_ib_item
      budat         = ps_gohead-budat                    "#EC DOM_EQUAL
      i_welfbnr     = l_welfbnr
      display       = l_display
      xstor         = s_action-cancel
      i_process     = i_sc_comp
      i_gr_po       = l_gr_po
    TABLES
      xebefu          = lt_poitem
      xekbnk          = lt_pofreight
      xaccounting     = lt_po_acc
      xaccounting_srv = lt_po_acc_srv
    EXCEPTIONS
      not_found_any = 1
      not_found_one = 2                                     "735762
      not_valid_any = 3
      not_valid_one = 4                                    "1518987
      error_message = 6
      OTHERS        = 7.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
  l_subrc = sy-subrc.
  IF s_control-refdoc = 'R05'  AND  NOT i_po_item IS INITIAL.
*   Goods receipt to an outbound delivery: Tied empties are already
*   in WUEB, but ME_READ also delivers e.g. for position 00010
*   the tied empties --> clear the result of ME_READ as we get
*   the empties later (for Joerg: "Delete doubled entries") <LG>
*   I_PO_ITEM is only empty if PO number directly entered on screen
*   for REFDOC = R01.
*   All other refdocs use it.
    DELETE lt_poitem WHERE ( uptyp = c_uptyp_lg  OR
                             uptyp = c_uptyp_nre OR          "1099242
                             uptyp = c_uptyp_nra )           "1099242
                       AND ebelp <> i_po_item.
  ENDIF.
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
* FLS return POs must not be handled by MIGO (only LE)
    delete lt_poitem where fls_rsto <> space.
  ENDIF.
  IF s_action-create = abap_true.
    CASE l_subrc.
      WHEN 0.
      WHEN 1.
*       Not found any
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '033'
                    i_po_number space space space.
      WHEN 2.                                                    "735762
*       Not found one                                            "735762
        l_reject = abap_true.                                    "735762
        def_msg_add oref_doc_log e 'M7' '036'                    "735762
                    i_po_number i_po_item space space.           "735762
      WHEN 3.
*       Not valid any
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '036'
                    i_po_number space space space.
      WHEN 4.
*       Not valid one                                           "1518987
        l_reject = abap_true.                                   "1518987
        IF i_po_item IS INITIAL.                                "1518987
          def_msg_add oref_doc_log e 'M7' '036'                 "1518987
                      i_po_number space space space.            "1518987
        ELSE.                                                   "1518987
          def_msg_add oref_doc_log e 'M7' '036'                 "1518987
                      i_po_number i_po_item space space.        "1518987
        ENDIF.                                                  "1518987
      WHEN 6.
*       Another error message
        l_reject = abap_true.
        def_msg_add oref_doc_log e sy-msgid sy-msgno
                                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      WHEN OTHERS.
*       Exception without error message --> default message
        def_msg_add oref_doc_log e 'M7' '033'
                                 i_po_number space space space.
    ENDCASE.
*   Ftrade: check plant country matches header country
*   Check not necessary if refdoc material document.
    IF s_control-refdoc <> 'R02' AND s_control-refdoc <> 'R03'.
      IF NOT ps_gohead-exnum IS INITIAL OR
         ( NOT ps_pohead-exnum IS INITIAL AND
           NOT ps_gohead-land1 IS INITIAL ).   "set from previous PO
        LOOP AT lt_poitem ASSIGNING <ls_poitem>.
          CALL METHOD lcl_migo_buffer=>plant_get
            EXPORTING
              i_plant   = <ls_poitem>-werks
            RECEIVING
              e_goplant = ls_goplant
            EXCEPTIONS
              OTHERS    = 1.
          CHECK sy-subrc = 0 AND NOT ls_goplant-land1 IS INITIAL.
          IF ps_gohead-land1 <> ls_goplant-land1.
            l_reject = abap_true.
            def_msg_add oref_doc_log e 'MIGO' '034'
                        space space space space.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
* Generic articles
  CALL METHOD purchase_order_ga_header_add
    CHANGING
      ct_poitem = lt_poitem.
* Stop, if there has been an error while reading the PO
  IF l_reject = abap_true.
    EXIT.
  ENDIF.
* Everything ok. Take the data...
  et_poitem    = lt_poitem.
* ...but only freight vendors with a freight-value and -condition.
  DELETE lt_pofreight WHERE kvsl2 IS INITIAL
                        OR  kwert IS INITIAL.
  et_pofreight = lt_pofreight.

* MAA-DEV
  IF NOT lt_po_acc_srv[] IS INITIAL.
    lt_po_acc[] = lt_po_acc_srv[].
  ENDIF.

  CALL METHOD oref_detail_maa->po_data_get
    EXPORTING
      i_ebeln  = i_po_number
      i_ebelp  = i_po_item
      i_lfbnr  = i_lfbnr
      i_lfbja  = i_lfbja
      i_lfpos  = i_lfpos
      i_acctb  = lt_po_acc
      i_poitem = lt_poitem.
* MAA-DEV

ENDMETHOD.                    "purchase_order_read_data

************************************************************************
* Read the data from a purchase order into the tables T_ST_POITEM.
************************************************************************
METHOD purchase_order_st_read_data.
  DATA: lt_st_poitem    TYPE ty_t_st_poitem,
        lt_pofreight    TYPE ty_t_pofreight,
        l_reject        TYPE abap_bool,
        l_msgty         TYPE symsgty,
        l_m7031rc       TYPE sysubrc.
  CALL FUNCTION 'ME_READ_ITEM_TRANSFER'
    EXPORTING
      budat         = ps_gohead-budat                    "#EC DOM_EQUAL
      ebeln         = i_po_number
      ebelp         = i_po_item
      i_werks       = i_po_werks
      reswk         = ps_pohead-reswk
      delivery      = abap_false
      display       = abap_true
      xstor         = s_action-cancel
      i_smbln       = i_md_number
      i_smblp       = i_md_item
      i_sjahr       = i_md_year
    IMPORTING
      lifnr         = ps_pohead-lifnr
    TABLES
      xbbefu        = lt_st_poitem
      xekbnk        = lt_pofreight
    EXCEPTIONS
      not_activ     = 01
      not_found     = 02
      not_found_any = 03
      not_found_one = 04
      not_valid_any = 05
      not_valid_one = 06
      wrong_type    = 07
      OTHERS        = 08.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
  IF s_action-create = abap_true.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        CALL FUNCTION 'MB_CHECK_T160M'
          EXPORTING
            i_arbgb  = 'M7'
            i_msgnr  = '031'
            i_nolog  = abap_true
            i_output = abap_false
          IMPORTING
            rc       = l_m7031rc.
*       Reject only if error
        IF l_m7031rc = 2.
          l_reject = abap_true.
        ENDIF.
*       Give message in these cases (all below W --> warning)
        IF l_m7031rc <> 0.
          CASE l_m7031rc.
            WHEN 2.      l_msgty = e.
            WHEN OTHERS. l_msgty = w.
          ENDCASE.
          def_msg_add oref_doc_log l_msgty 'M7' '031'
                      i_po_number space space space.
        ENDIF.
      WHEN 2.
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '030'
                    i_po_number space space space.
      WHEN 3.
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '033'
                    i_po_number space space space.
      WHEN 4.
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '150'
                    i_po_number i_po_item space space.
      WHEN 5.
        l_reject = abap_true.
        def_msg_add oref_doc_log e 'M7' '151'
                    i_po_number space space space.
      WHEN OTHERS.
        l_reject = abap_true.
        def_msg_add oref_doc_log sy-msgty 'M7' '153'
                                 i_po_number i_po_item space space.
    ENDCASE.
  ENDIF.
* Stop, if there has been an error while reading the PO
  IF l_reject = abap_true.
    EXIT.
  ENDIF.
* Everything ok. Take the data...
  et_st_poitem = lt_st_poitem.
* ...but only freight vendors with a freight-value and -condition.
  DELETE lt_pofreight WHERE kvsl2 IS INITIAL
                         OR kwert IS INITIAL.
  et_pofreight = lt_pofreight.
ENDMETHOD.                    "purchase_order_st_read_data
************************************************************************
* Read the data of subcontracting components from a purchase order
* into the table t_mdgi.
************************************************************************
METHOD purchase_order_sc_data_fill.
  DATA: ls_poitem    TYPE ty_s_poitem,
        lt_mdgi      TYPE ty_t_mdgi,
        ls_mdgi      TYPE ty_s_mdgi,
        ls_got156    TYPE got156,
        ls_migo_t156 TYPE migo_t156.
  DATA: lt_mdvw TYPE STANDARD TABLE OF mdvw,
        ls_mdvw TYPE mdvw,
        ls_goitem_top  TYPE goitem,
        ls_goitem_comp TYPE goitem,
        l_current_tabix TYPE sytabix,
        l_fcode TYPE fcode.
  DATA: l_sum_we TYPE bstmg,
        l_act_we TYPE bstmg.
  DATA: lt_poitem    TYPE ty_t_poitem.
  DATA: lt_ekbe_sc TYPE TABLE OF ekbe_sc,
        ls_ekbe_sc TYPE ekbe_sc,
        l_autyp    TYPE auftyp,
        l_sc_comp  TYPE i,
        ls_control TYPE lcl_migo_kernel=>ty_s_control.
  DATA: l_strategy           TYPE i,                      "n1503506
        l_converted_alt_qty  TYPE menge_d,                "n1503506
        l_converted_base_qty TYPE menge_d.                "n1503506

ENHANCEMENT-POINT EHP606_PO_SC_DATA_FILL_01 SPOTS ES_SAPLMIGO STATIC .

*   Read movement type data
  CALL METHOD lcl_migo_buffer=>move_type_get
    EXPORTING
      i_move       = s_defaults-bwart
    IMPORTING
      e_got156     = ls_got156
      es_migo_t156 = ls_migo_t156
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log e 'MICK' '001' s_defaults-bwart space space space.
    RETURN.
  ENDIF.
  IF s_action-sc_comp = abap_true.
    l_sc_comp = 1.
    CALL METHOD purchase_order_read_data
      EXPORTING
        i_po_number  = i_po_number
        i_po_item    = i_po_item
        i_po_werks   = i_po_werks
        i_ib_number  = i_ib_number
        i_ib_item    = i_ib_item
        i_sc_comp    = l_sc_comp
      IMPORTING
         et_poitem    = lt_poitem.
    LOOP AT lt_poitem into ls_poitem
       WHERE co_order IS NOT INITIAL.
*     If no subcontracting PO, stop here, no need to read further.
      SELECT SINGLE autyp FROM aufk INTO l_autyp
          WHERE aufnr = ls_poitem-aufnr.
      IF  l_autyp = '04'      "CO Production Order
         OR l_autyp = '10'    "Production Order
         OR l_autyp = '40'.   "Production Order
      ELSE.
        CONTINUE.
      ENDIF.
      MOVE-CORRESPONDING ls_poitem to ls_goitem_top.
      ls_goitem_top-shkzg = S.
      ls_goitem_top-kzbew = B.
      ls_goitem_top-xco_order = ls_poitem-co_order.
        l_act_we = ls_goitem_top-bsmng.
        l_sum_we = ls_goitem_top-wemng.
      MOVE-CORRESPONDING ps_pohead   TO ls_goitem_top.
      CALL FUNCTION 'ME_REFRESH_COMP_GOODS_MOVEMENT'.
      CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
        EXPORTING
          aktwe         = l_act_we
          ebeln         = ls_goitem_top-ebeln
          ebelp         = ls_goitem_top-ebelp
          lfbnr         = ls_goitem_top-lfbnr
          lfgja         = ls_goitem_top-lfbja
          lfpos         = ls_goitem_top-lfpos
          shkzg         = ls_goitem_top-shkzg
          sumwe         = l_sum_we
          kzbew         = ls_goitem_top-kzbew
        IMPORTING
          et_ekbe_sc    = lt_ekbe_sc[]
        TABLES
          t_bbefu       = lt_mdvw
        EXCEPTIONS
          not_found_any = 01
          not_found_one = 02
          not_valid_any = 03
          not_valid_one = 04.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ENDIF.
      pt_ekbe_sc[] = lt_ekbe_sc[].
*     Insertion position
      DESCRIBE TABLE pt_goitem LINES l_current_tabix.
      ls_goitem_top-take_it = s_defaults-take_it_all.
*     Insert lines
      LOOP AT lt_mdvw INTO ls_mdvw WHERE NOT matnr IS INITIAL.
*       Normal goods isuues. Delete LGPRO and set SOBKZ
        IF ls_mdvw-sobkz IS INITIAL.
          ls_mdvw-sobkz = o.
          CLEAR ls_mdvw-lgpro.
        ENDIF.
        CLEAR ls_goitem_comp.
*       Business data
        MOVE-CORRESPONDING ls_mdvw TO ls_goitem_comp.
        MOVE-CORRESPONDING ls_goitem_top-group_cobl TO ls_goitem_comp.
        ls_goitem_comp-take_it = ls_goitem_top-take_it.
        ls_goitem_comp-lgort   = ls_mdvw-lgpro.
        ls_goitem_comp-wamme   = ls_mdvw-erfme.
        ls_goitem_comp-ebeln   = ls_goitem_top-ebeln.
        ls_goitem_comp-ebelp   = ls_goitem_top-ebelp.
        ls_goitem_comp-lfbnr   = ls_goitem_top-lfbnr.
        ls_goitem_comp-lfpos   = ls_goitem_top-lfpos.
        ls_goitem_comp-sjahr   = ls_goitem_top-sjahr.
        IF ls_got156-shkzg = h.
          l_fcode = 'LBWA'.
        ELSE.
          l_fcode = 'LBWS'.
        ENDIF.
        ls_goitem_comp-mat_kdauf = ls_goitem_top-mat_kdauf.
        ls_goitem_comp-mat_kdpos = ls_goitem_top-mat_kdpos.
        ls_goitem_comp-mat_pspnr = ls_goitem_top-mat_pspnr.
        IF ls_goitem_top-sobkz = e.
          ls_goitem_comp-kdauf = ls_goitem_top-mat_kdauf.
          ls_goitem_comp-kdpos = ls_goitem_top-mat_kdpos.
        ENDIF.
        IF ls_goitem_top-sobkz = q.
          ls_goitem_comp-ps_psp_pnr = ls_goitem_top-mat_pspnr.
        ENDIF.
*    * begin of insertion note 339452
        IF ls_goitem_comp-sobkz = q.
          IF ls_goitem_top-kzbws = 'M'.
            DATA: l_pspnr TYPE grpga-grpnr.
            CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
              EXPORTING
                i_pspnr              = ls_goitem_comp-ps_psp_pnr
                i_werks              = ls_goitem_comp-werks
                i_matnr              = ls_goitem_comp-matnr
              IMPORTING
                e_grpnr              = l_pspnr
              EXCEPTIONS
                wrong_input          = 1
                no_valid_grpnr_found = 2.
            IF sy-subrc = 0.
              IF ls_goitem_comp-ps_psp_pnr <> l_pspnr AND
                 NOT l_pspnr IS INITIAL.
*                 update only changed wbs element
                ls_goitem_comp-ps_psp_pnr = l_pspnr.
              ENDIF.
            ENDIF.
          ENDIF.
          ls_goitem_comp-mat_pspnr = ls_goitem_comp-ps_psp_pnr.
        ELSEIF ls_goitem_comp-sobkz = e.
          ls_goitem_comp-mat_kdauf = ls_goitem_top-mat_kdauf.
          ls_goitem_comp-mat_kdpos = ls_goitem_top-mat_kdpos.
        ENDIF.
        ls_goitem_comp-lifnr = ls_goitem_top-lifnr.
        ls_goitem_comp-kunnr = ls_goitem_top-kunnr.
        CALL METHOD lcl_migo_buffer=>move_type_next_get
          EXPORTING
            i_move      = space
            i_fcode     = l_fcode
          RECEIVING
            e_move_next = ls_goitem_comp-bwart.
        IF ls_got156-shkzg = h.
          LOOP AT lt_ekbe_sc INTO ls_ekbe_sc
              WHERE ebeln = ls_goitem_comp-ebeln
                AND ebelp = ls_goitem_comp-ebelp
                AND matnr = ls_goitem_comp-matnr.
          "           AND charg = ls_goitem_comp-charg.
* -------------- Start of note 1503506 -------------------------------------- *
* Design error of Outsourced Manufacturing EhP 4
* The ERFMG was just summed without taking care about the UOM!
* ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - ls_ekbe_sc-erfmg.
* ls_ekbe_sc-erfme could be different and must converted in this case
* Of course the UOM must be included in the ERFMG calculation
* Similiar correction was done in include LMIGOKL2
* ----------------------------------------------------------------------------*
* Determine calculation strategy           (i.e. examples BME = ST)
* 1 - old calculation - same unit          (i.e. MIGO = ST  & EKBE_SC = ST  )
* 2 - From alternative unit to base unit   (i.e. MIGO = ST  & EKBE_SC = KAR )
* 3 - From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
* 4 - From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
* ----------------------------------------------------------------------------*
*           Determine strategy
*           are both units the same?
            IF ls_goitem_comp-erfme = ls_ekbe_sc-erfme.
             l_strategy = 1.
            ELSE.
*            is one of them a base unit?
             IF ls_ekbe_sc-lagme = ls_goitem_comp-erfme OR
                ls_ekbe_sc-lagme = ls_ekbe_sc-erfme.
*               is the MIGO/PO unit the base unit?
                IF ls_goitem_comp-erfme = ls_ekbe_sc-lagme.
                 l_strategy = 2.
                ELSE.
                 l_strategy = 3.
                ENDIF.
             ELSE.
*               both units are alternative units but not the same
                l_strategy = 4.
             ENDIF.
            ENDIF.
            CLEAR l_converted_base_qty.
            CLEAR l_converted_alt_qty.
*           Execute determined strategy
            CASE l_strategy.
              WHEN '1'.
*              old logic which was used for all strategies
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - ls_ekbe_sc-erfmg.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + ls_ekbe_sc-erfmg.
               ENDIF.
              WHEN '2'.
*             From alternative unit to base unit(i.e. MIGO = ST & EKBE_SC = KAR)
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_goitem_comp-erfme
*                          menge                = ...-menge
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_base_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_base_qty.
               ENDIF.
              WHEN '3'.
*             From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_goitem_comp-erfme
*                          erfmg                = ...-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = ls_ekbe_sc-erfmg
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_alt_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_alt_qty.
               ENDIF.
              WHEN '4'.
*             From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
*             Conversion from alternative 1 to base unit to alternative 2.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-lagme
*                          menge                = ...-menge
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_goitem_comp-erfme
*                          erfmg                = ...-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = l_converted_base_qty
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_alt_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_alt_qty.
               ENDIF.
            ENDCASE.
* -------------- End of note 1503506 -------------------------------------- *
            IF ls_goitem_comp-erfmg < 0.
              ls_goitem_comp-erfmg = 0.
            ENDIF.
            IF ls_goitem_comp-erfmg = 0.
              ls_goitem_comp-take_it = abap_false.
            ENDIF.
          ENDLOOP.
        ELSE.
          CLEAR ls_goitem_comp-erfmg.
          LOOP AT lt_ekbe_sc INTO ls_ekbe_sc
              WHERE ebeln = ls_goitem_comp-ebeln
                AND ebelp = ls_goitem_comp-ebelp
                AND matnr = ls_goitem_comp-matnr.
          "           AND charg = ls_goitem_comp-charg.
* -------------- Start of note 1503506 -------------------------------------- *
            CLEAR l_converted_base_qty.
            CLEAR l_converted_alt_qty.
*           Execute determined strategy
            CASE l_strategy.
              WHEN '1'.
*              old logic which was used for all strategies
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + ls_ekbe_sc-erfmg.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - ls_ekbe_sc-erfmg.
               ENDIF.
              WHEN '2'.
*             From alternative unit to base unit(i.e. MIGO = ST & EKBE_SC = KAR)
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_goitem_comp-erfme
*                          menge                = ...-menge
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_base_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_base_qty.
               ENDIF.
              WHEN '3'.
*             From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_goitem_comp-erfme
*                          erfmg                = ...-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = ls_ekbe_sc-erfmg
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_alt_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_alt_qty.
               ENDIF.
              WHEN '4'.
*             From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
*             Conversion from alternative 1 to base unit to alternative 2.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-lagme
*                          menge                = ...-menge
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_goitem_comp-erfme
*                          erfmg                = ...-erfmg
                          matnr                = ls_goitem_comp-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = l_converted_base_qty
                          charg                = ls_goitem_comp-charg
                          werks                = ls_goitem_comp-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
               IF ls_ekbe_sc-shkzg = 'H'.
*               consumed component
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg + l_converted_alt_qty.
               ELSE.  "Reversal of consumption
                ls_goitem_comp-erfmg = ls_goitem_comp-erfmg - l_converted_alt_qty.
               ENDIF.
            ENDCASE.
* -------------- End of note 1503506 -------------------------------------- *
          ENDLOOP.
        ENDIF.
        ls_goitem_comp-xpoitem = abap_true.                 "Outsourced Manufacturing EhP 4
        ls_goitem_comp-xco_order = ls_goitem_top-xco_order.
        l_current_tabix = l_current_tabix + 1.

ENHANCEMENT-POINT EHP606_PO_SC_DATA_FILL_02 SPOTS ES_SAPLMIGO .

        CALL METHOD line_modify
          EXPORTING
            i_tabix          = l_current_tabix
            i_insert         = abap_true
            i_status_delayed = abap_true
          CHANGING
            cs_goitem        = ls_goitem_comp.
        ls_control = lcl_migo_globals=>kernel->mode_get( ).
        CLEAR: ls_control-new_line_mode.
        CALL METHOD lcl_migo_globals=>kernel->mode_set
          EXPORTING
            is_control = ls_control.
      ENDLOOP.
      CALL METHOD status_derive.
    ENDLOOP.                                                           "1305450
  ELSE.
* Transfer posting for SC components (mvt. 541)
    CHECK ls_got156-kzbwa = '02'.
    CLEAR lt_mdgi.
    CALL FUNCTION 'ME_READ_COMP_GOODS_ISSUE'
      EXPORTING
        ebeln = i_po_number
        ebelp = i_po_item
      TABLES
        xmdgi = lt_mdgi.          "Components
    LOOP AT lt_mdgi INTO ls_mdgi.
      CLEAR: ls_poitem.
      MOVE-CORRESPONDING ls_mdgi TO ls_poitem.
      ls_poitem-emlif = ls_mdgi-lifnr.
      APPEND ls_poitem TO et_poitem.
    ENDLOOP.
  ENDIF.
ENDMETHOD.                    "purchase_order_sc_data_fill