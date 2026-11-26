*----------------------------------------------------------------------*
*   INCLUDE LMIGOKP2 Purchase order                                    *
*----------------------------------------------------------------------*

************************************************************************
* Read the data from a purchase order into the tables T_POITEM,
* S_POHEAD
************************************************************************
METHOD purchase_order_fill_data.
  DATA: l_move_next   TYPE bwart,
        ls_poitem     TYPE ebefu,
        ls_goitem     TYPE goitem,
        ls_got156     TYPE got156,
        ls_migo_t156  TYPE migo_t156,
        ls_govbfa     TYPE vbfa,                            "HW 388902
        lt_prefetch02 TYPE ty_t_prefetch02,
        lt_prefetch03 TYPE ty_t_prefetch03,
        ls_prefetch02 TYPE ty_s_prefetch02,
        ls_prefetch03 TYPE ty_s_prefetch03,
        l_no_take_over   TYPE sysubrc,                           "<LG>
        l_rc_t160m_check TYPE sy-subrc,                     "499785
        l_move           TYPE bwart.

* serial numbers
  DATA: lt_goserial        TYPE ty_t_goserial.
  DATA: ls_goserial_kernel TYPE ty_s_goserial_kernel.

* retail consignment handling
  DATA: lv_sobkz  TYPE sobkz,
        lv_lifnr  TYPE elief,
        ls_return TYPE bapiret2,
        lr_retail TYPE REF TO if_ex_mb_me_csgmt_badi_sap.

ENHANCEMENT-POINT purchase_order_fill_data_11 SPOTS es_saplmigo STATIC.
  LOOP AT it_poitem INTO ls_poitem WHERE NOT matnr IS INITIAL.
    MOVE-CORRESPONDING ls_poitem TO ls_prefetch02.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    MOVE-CORRESPONDING ls_poitem TO ls_prefetch03.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
  ENDLOOP.
  CALL METHOD material_prefetch_read
    EXPORTING
      it_prefetch02 = lt_prefetch02
      it_prefetch03 = lt_prefetch03.
  READ TABLE it_poitem WITH KEY upvor = 9
    TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CALL METHOD oref_log->refresh.
    CALL METHOD oref_log->send_data_to_mick.
  ENDIF.
* Send the data from lt_POITEM to ls_goitem
  LOOP AT it_poitem INTO ls_poitem.
    CHECK ls_poitem-loekz IS INITIAL AND
          ( ls_poitem-lfret = space OR
            ls_poitem-retar = '2' OR
            ls_poitem-retpo = space ).

    l_move = s_defaults-bwart.

ENHANCEMENT-POINT purchase_order_fill_data_10 SPOTS es_saplmigo.

*   Subsequent adjustment
    IF s_control-action = 'A11'.
      CHECK ls_poitem-pstyp = '3' AND ls_poitem-wemng <> 0.
      CALL METHOD lcl_migo_buffer=>move_type_next_get
        EXPORTING
          i_move      = space
          i_fcode     = 'LBMB'
        RECEIVING
          e_move_next = l_move
        EXCEPTIONS
          not_found   = 1.
      IF sy-subrc <> 0.
        sy-subrc = 0.
      ENDIF.
      IF ls_poitem-vbeln_vl IS NOT INITIAL AND ls_poitem-vbelp_vl IS NOT INITIAL
         AND ls_poitem-lamng IS INITIAL AND ls_poitem-lwmng IS INITIAL.
        IF sy-subrc = 0.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
*   Read movement type data
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING
        i_move       = l_move
      IMPORTING
        e_got156     = ls_got156
        es_migo_t156 = ls_migo_t156
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      sy-subrc = 0.
    ENDIF.
    IF ls_poitem-RETPO IS INITIAL AND NOT ls_poitem-WEBRE IS INITIAL.   "n1094812
     CASE ls_migo_t156-bustr.                                            "1157655
      WHEN '101'.                                                        "1157655
       CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H )."n1094812
      WHEN '103'.                                                        "1157655
       CHECK NOT ( ls_poitem-wesbs IS INITIAL AND ls_got156-shkzg = H ). "1157655
      WHEN '105'.                                                        "1157655
       CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H ). "1157655
       CHECK NOT ( ls_poitem-wesbs IS INITIAL AND ls_got156-shkzg = S ). "1498315
      WHEN  '107'.                                                       "1157655
       CHECK NOT ( ls_poitem-wesbb IS INITIAL AND ls_got156-shkzg = H ). "1157655
      WHEN '109'.                                                        "1157655
       CHECK NOT ( ls_poitem-wemng IS INITIAL AND ls_got156-shkzg = H ). "1157655
       CHECK NOT ( ls_poitem-wesbb IS INITIAL AND ls_got156-shkzg = S ). "1498315
     ENDCASE.                                                            "1157655
    ENDIF.                                                              "n1094812
* In case of Outbound Delivery with PO GR-Base IV, we need
* to access table VBFA to prevent PO items being proposed several
* times in case of batch split scenario during reversal.
* During reversal, fields vbeln, vbelp, lfbnr and lfpos should be
* filled. Please also see note 388902.
    IF  s_control-refdoc = 'R05' AND                        "HW 388902
        ls_poitem-webre <> space AND                        "HW 388902
        is_wueb-vbeln   <> space AND                        "HW 388902
        is_wueb-vbelp   <> space AND                        "HW 388902
        ls_poitem-lfbnr <> space AND                        "HW 388902
        ls_poitem-lfpos <> space.                           "HW 388902
                                                            "HW 388902
      SELECT * FROM vbfa INTO ls_govbfa UP TO 1 ROWS        "HW 388902
                        WHERE vbelv = is_wueb-vbeln   AND   "HW 388902
                              posnv = is_wueb-vbelp   AND   "HW 388902
                              vbeln = ls_poitem-lfbnr AND   "HW 388902
                              posnn = ls_poitem-lfpos.      "HW 388902
      ENDSELECT.                                            "HW 388902
      CHECK sy-subrc = 0.                                   "HW 388902
    ENDIF.                                                  "HW 388902

*   No GR to blocked stock for return flagged positions
    IF ls_poitem-retpo = abap_true.
      IF ls_migo_t156-bustr <> '109'.
        CHECK ls_got156-kzwes IS INITIAL.
      ENDIF.
    ENDIF.
    CLEAR ls_goitem.
    CLEAR l_no_take_over.                              "<LG>
    MOVE-CORRESPONDING ls_got156    TO ls_goitem.
    MOVE-CORRESPONDING ls_migo_t156 TO ls_goitem.
    CALL METHOD purchase_order_fill_goitem
      EXPORTING
        i_transfer   = abap_false
        is_poitem    = ls_poitem
        is_goitem    = ls_goitem
        it_pofreight = it_pofreight
      IMPORTING
        es_goitem    = ls_goitem
      EXCEPTIONS
        no_take_over = 1.
*   if trouble with actual po item (e.g. tied empty) -> skip it; <LG>
    l_no_take_over = sy-subrc.
*   Default values
    CALL METHOD defaults_merge
      CHANGING
        cs_goitem = ls_goitem.
    ls_goitem-bwtor = ls_poitem-bwtar.
    ls_goitem-batch_from_refdoc = ls_poitem-charg.
    ls_goitem-vendorbatch_from_refdoc = ls_poitem-licha.
    IF ls_goitem-ean11_bme IS INITIAL.
      ls_goitem-ean11_bme = ls_poitem-ean11.
    ENDIF.
    ls_goitem-erfme = ls_poitem-bstme.
    ls_goitem-bumrz = ls_poitem-umrez.
    ls_goitem-bumrn = ls_poitem-umren.
* begin of Outsourced Manufacturing EhP 4
    IF ls_got156-kzbwa = '02'.
      CLEAR: ls_goitem-batch_from_refdoc.
    ENDIF.
* end of Outsourced Manufacturing EhP 4
*   Return item. Get mvt type 161 from T156N and change movement
*   type data. This behavior has chenged with note 381377.
    IF NOT ls_poitem-retpo IS INITIAL.
      ls_goitem-bwart_retpo = ls_goitem-bwart.              "398683
      CALL METHOD lcl_migo_buffer=>move_type_next_get
        EXPORTING
          i_move      = ls_goitem-bwart
          i_fcode     = 'WERE'
        RECEIVING
          e_move_next = l_move_next
        EXCEPTIONS
          OTHERS      = 1.
      IF sy-subrc <> 0.
        def_msg_add oref_doc_log e 'MIGO' '029'             "381377
                    space space space space.                "381377
        CONTINUE.                                           "381377
      ENDIF.
      CALL METHOD lcl_migo_buffer=>move_type_get
        EXPORTING
          i_move       = l_move_next
        IMPORTING
          e_got156     = ls_got156
          es_migo_t156 = ls_migo_t156
        EXCEPTIONS
          OTHERS       = 1.
      IF sy-subrc <> 0.
        def_msg_add oref_doc_log e 'M7' '001'
                    'T156' l_move_next space space.
        CONTINUE.                                           "381377
      ENDIF.
      MOVE-CORRESPONDING ls_migo_t156 TO ls_goitem.
*     Copy the data needed here from the new movement type.
*     The main data are filled by LINE_CHECK.
*     Maybe this can be extended to a MOVE-CORRESPONDING later.
      ls_goitem-bwart = ls_got156-bwart.                    "381377
      ls_goitem-shkzg = ls_got156-shkzg.                    "381377
      ls_goitem-kzwes = ls_got156-kzwes.                    "381377
    ENDIF.
ENHANCEMENT-POINT lmigokp2_02 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT lmigokp2_01 SPOTS es_saplmigo.

*--- MAA-DEV

     IF ls_poitem-xhistma = abap_true AND ls_got156-bustr = '107'.
        def_msg_add oref_doc_log w 'M7' '448' ls_poitem-ebeln ls_poitem-ebelp space space.
        CONTINUE.
     ENDIF.
*--- MAA-DEV

*   PO has been derived from reference document (without shipping units)
*      R04 Inbound delivery
*      R05 Outbound delivery
*      R06 Transport
*      R07 Transportidentifikation
*   Then the propose quantity is set from WUEB. No MB_PROPOSE_QUANTITY.
    IF ( s_control-refdoc = 'R04' OR
         s_control-refdoc = 'R05' OR
         s_control-refdoc = 'R06' OR
         s_control-refdoc = 'R07' ).
*     Common fields for all types of wueb:
*     Fields VERUR_REFDOC and BOLNR_REFDOC are shortened by WUEB
*     to 16 instead of 35!!
      ls_goitem-verur_refdoc = is_wueb-xblnr_avis.
      ls_goitem-bolnr_refdoc = is_wueb-frbnr_avis.
* note 880631: in GR for outbound delivery, the first delivery is taken
* to GOHEAD-XBLNR. See also method GOODS_MOVEMENT_FILL (note 189746).
      IF s_control-action = 'A01' AND                       "880631
         s_control-refdoc = 'R05' AND                       "880631
         ps_gohead-xblnr IS INITIAL.                        "880631
        MOVE is_wueb-vbeln TO ps_gohead-xblnr.              "880631
      ENDIF.                                                "880631
* note 327455
* begin of note 499785:
*     customizable message that slip number differs between the items
      IF s_control-refdoc = 'R04'.                          "499785
        IF ps_gohead-xblnr <> ls_goitem-verur_refdoc        "499785
         AND NOT ps_gohead-xblnr IS INITIAL                 "499785
         AND NOT ls_goitem-verur_refdoc IS INITIAL.         "499785
          CALL FUNCTION 'MB_CHECK_T160M'                    "499785
               EXPORTING                                    "499785
                   i_arbgb    = 'M7'                        "499785
                   i_msgnr    = '327'                       "499785
                   i_nolog    = x                           "499785
               IMPORTING                                    "499785
                   rc         = l_rc_t160m_check.           "499785
          CASE l_rc_t160m_check.                            "499785
            WHEN 1.                                         "499785
*               warning                                         "499785
              def_msg_add oref_doc_log w 'M7' '327'         "499785
                          ls_goitem-verur_refdoc            "499785
                          ps_gohead-xblnr                   "499785
                          space space.                      "499785
            WHEN 2.                                         "499785
*               error                                           "499785
              def_msg_add oref_doc_log e 'M7' '327'         "499785
                          ls_goitem-verur_refdoc            "499785
                          ps_gohead-xblnr                   "499785
                          space space.                      "499785
              CONTINUE.                                     "499785
            WHEN OTHERS.                                    "499785
          ENDCASE.                                          "499785
        ENDIF.                                              "499785
      ENDIF.                                                "499785
* end of note 499785
* the in the inbound delivery given storage location (LGORT) has
* priority over the storage location of the purchase order if entered
      IF NOT is_wueb-lgort IS INITIAL.
        ls_goitem-lgort = is_wueb-lgort.
      ENDIF.
* end of note 327455
* if no valuation type (BWTAR) is maintained in the PO,       "713651
* it will be proposed from the delivery                       "713651
      IF ls_goitem-bwtar IS INITIAL                         "713651
        AND NOT is_wueb-bwtar IS INITIAL.                   "713651
        ls_goitem-bwtar = is_wueb-bwtar.                    "713651
      ENDIF.                                                "713651
      IF s_control-refdoc = 'R05'.
*       VBELN is needed for goods receipt to stock transfer order via
*       inbound delivery. Only in this case the function
*       SD_DELIVERY_WE_FLOW_UPDATE should be processed in MM07MFB9.
        ls_goitem-vbeln = is_wueb-vbeln.
        ls_goitem-posnr = is_wueb-vbelp.
* For PO GR-Base IV the quantity (erfmg) of the PO has priority over
* the one of the shipping unit during reversal. Thus do not assign
* the wueb-erfmg to poitem-erfmg if the condition is true.
        IF ls_poitem-webre <> space AND                     "HW 388902
           ls_poitem-lfbnr <> space AND                     "HW 388902
           ls_poitem-lfpos <> space.                        "HW 388902
*       Do nothing because the QTY should take from PO if    "HW 388902
*       it is a reversal.                                    "HW 388902
        ELSE.                                               "HW 388902
*          Move erfmg to ls_poitem first as we have a global move
*          from ls_poitem-erfmg to ls_goitem-erfmg later.
          IF s_action-migo_mode = 'GR'
            AND is_wueb-uecha IS INITIAL.                   "609644
*           IF no inbound delivery exists, then read ERFMG from WUEB.
*           Otherwise clear ERFMG and call
*           MB_PROPOSE_RECEIPT_QUANTITY later.
            IF ls_poitem-etens IS INITIAL                   "648770
              AND i_ib_number IS INITIAL.                   "648770
              ls_poitem-erfmg = is_wueb-erfmg.              "648770
ENHANCEMENT-POINT lmigokp2_03 SPOTS es_saplmigo.
            ELSE.                                           "648770
              CLEAR: ls_poitem-erfmg.                       "648770
            ENDIF.                                          "648770
          ELSE.                                             "609644
            ls_poitem-erfmg = is_wueb-erfmg.
ENHANCEMENT-POINT lmigokp2_04 SPOTS es_saplmigo.
          ENDIF.                                            "609644
          ls_poitem-bstme = ls_goitem-erfme = is_wueb-erfme.
ENHANCEMENT-POINT lmigokp2_05 SPOTS es_saplmigo.
        ENDIF.                                              "HW 388902
        IF ls_poitem-charg = space.
          ls_goitem-charg = is_wueb-charg.
        ENDIF.
      ELSE.
*       VLIEF_AVIS is needed for MB_CREATE_GOODS_MOVEMENT. Only if this
*       field is filled, ME_CONFIRMATION_SEARCH_GR will be processed.
        ls_goitem-vlief_avis = is_wueb-vbeln.
        ls_goitem-vbelp_avis = is_wueb-vbelp.
      ENDIF.
*     As first take LSMNG from WUEB
      ls_goitem-lsmng = is_wueb-erfmg.
      ls_goitem-lsmeh = is_wueb-erfme.
    ENDIF.
*   Shipping units are selected for inbound delivery
*   Propose the quantity of each shipping unit.
    IF NOT is_vepwe IS INITIAL.
      IF s_control-refdoc = 'R05'.
*       VBELN: see comment above
*       POSNR is correct for outbound deliveries
        ls_goitem-vbeln = is_vepwe-vbeln.
        ls_goitem-posnr = is_vepwe-posnr.
      ELSE.
*       VLIEF_AVIS: see comment abovve
        ls_goitem-vlief_avis = is_vepwe-vbeln.
        ls_goitem-vbelp_avis = is_vepwe-posnr.
*       VEPWE-LGORT is the Storage location of issueing plant    "412796
*       -> Only useful for inbound delivery (<>'R05')            "412796
        ls_goitem-lgort      = is_vepwe-lgort.              "412796
      ENDIF.
*     The shipping unit has the 'better' information about LSMNG
      ls_goitem-lsmng = is_vepwe-vemng.
      ls_goitem-lsmeh = is_vepwe-vemeh.
      ls_goitem-erfme = is_vepwe-vemeh.
*     Move erfmg to ls_poitem first as we have a global move
*     from ls_poitem-erfmg to ls_goitem-erfmg later.
      ls_poitem-erfmg = is_vepwe-vemng.
    ENDIF.

    IF s_control-action = 'A11'.
*     subsequent adjustment: no quantity proposal.
      CLEAR ls_goitem-erfmg.
    ELSE.
*     Propose quantity, if ERFMG is still initial and
      IF ls_poitem-erfmg = 0 AND
         ls_poitem-noqty = abap_false.
*       noqty is needed for delivery schedule. Is set by PO Read in
*       ls_poitem.
        CALL FUNCTION 'MB_PROPOSE_RECEIPT_QUANTITY'
          EXPORTING
            shkzg = ls_goitem-shkzg                         "381377
            retpo = ls_goitem-retpo
            kzwes = ls_goitem-kzwes                         "381377
            wesbs = ls_poitem-wesbs
            bpwes = ls_poitem-bpwes
            lfbnr = ls_goitem-lfbnr
            vlief = i_ib_number
            lamng = ls_poitem-lamng
            lwmng = ls_poitem-lwmng
            lwsbs = ls_poitem-lwsbs
            etens = ls_poitem-etens
            bsakz = ls_poitem-bsakz                         "sdp462
            wemng = ls_poitem-wemng
            wamng = ls_poitem-wamng
            xselp = x
            bsmng = ls_poitem-bsmng
            bpwem = ls_poitem-bpwem
            webre = ls_poitem-webre
            wesbb = ls_poitem-wesbb
            bpweb = ls_poitem-bpweb
            lwsbb = ls_poitem-lwsbb
          IMPORTING
            erfmg = ls_poitem-erfmg.
      ENDIF.

      ls_goitem-erfmg = ls_poitem-erfmg.

ENHANCEMENT-POINT lmigokp2_06 SPOTS es_saplmigo.
*     Take the item, if the quantity is set or also items with
*     no quantity are to be proposed.
ENHANCEMENT-SECTION     lmigokp2_07 SPOTS es_saplmigo.
      CHECK ls_goitem-erfmg <> 0 OR
            s_defaults-propose_all_items = abap_true.
END-ENHANCEMENT-SECTION.
*     Do not propose the position if the final delivery indicator is
*     set, despite of movements out of the stock, release blocked stock
ENHANCEMENT-SECTION     lmigokp2_08 SPOTS es_saplmigo.
      IF
        ( ls_goitem-erfmg = 0 OR                            "202128
          (                                                 "202128
            ls_goitem-elikz = abap_true AND                 "202128
            ls_goitem-kzwes <> x        AND                 "381377
            (                                               "202128
              ( ls_goitem-shkzg = s AND                     "381377
                ls_goitem-retpo = abap_false ) OR           "381377
              ( ls_goitem-shkzg = h AND                     "381377
                ls_goitem-retpo = abap_true  )              "381377
             )                                              "202128
           )                                                "202128
         ).
        CLEAR ls_goitem-take_it.                            "202128
      ENDIF.                                                "202128
END-ENHANCEMENT-SECTION.
    ENDIF.
*   In MIGO, we do not propose the quantity in order price unit.
*   The user can enter the quantity himself or MB_CREATE will
*   calculate automatically.
    CLEAR ls_goitem-bpmng.
*   Set indicator for "position from delivery" if called with this
*   flag.
    IF i_delivery = abap_true.
      ls_goitem-xdelivitem = x.
    ENDIF.
*   posting a tied empty without full product doesn't make sense; <LG>
    IF NOT l_no_take_over IS INITIAL.
      def_msg_add oref_doc_log e 'M7' '350'
                          ls_poitem-ebeln
                          ls_poitem-ebelp
                          space space.
      CONTINUE.
    ENDIF.
*   generic article
    IF NOT ls_poitem-attyp IS INITIAL.
      CALL METHOD purchase_order_fill_ga
        EXPORTING
          is_poitem = ls_poitem
          it_poitem = it_poitem
          it_goitem = pt_goitem
        CHANGING
          cs_goitem = ls_goitem.
    ENDIF.
*   value added services
    IF ls_poitem-uptyp = '9' OR ls_poitem-upvor = '9'
       OR ls_poitem-upvor = x.
      CALL METHOD purchase_order_fill_vas
        EXPORTING
          is_poitem = ls_poitem
          it_poitem = it_poitem
        CHANGING
          cs_goitem = ls_goitem.
    ENDIF.
*   Cross Docking
    IF NOT ps_pohead-estak IS INITIAL
       OR NOT ls_poitem-aurel IS INITIAL.
      CALL METHOD purchase_order_fill_cd
        EXPORTING
          is_poitem = ls_poitem
        CHANGING
          cs_goitem = ls_goitem.
    ENDIF.
* special handling if retail consignment handling is active.
    IF lcl_migo_globals=>retail_consignment_active = abap_true.
      lr_retail = lcl_migo_globals=>if_badi_retail_mb_me_csgmt.
      CALL METHOD lr_retail->wrf_call_get_mseg_gi_gr_migo(
        EXPORTING
          is_goitem  = ls_goitem
          is_poitem  = ls_poitem
          is_wueb    = is_wueb
          is_gohead  = ps_gohead
        IMPORTING
          e_return   = ls_return
        CHANGING
          c_sobkz    = lv_sobkz
          c_lifnr    = lv_lifnr ).
      IF ls_return IS INITIAL.
        ls_goitem-sobkz = lv_sobkz.
        ls_goitem-lifnr = lv_lifnr.
        ls_goitem-vendorname = lv_lifnr.                    "966023
        CALL FUNCTION 'MM_VENDOR_CONVERT'
          EXPORTING
            bukrs      = space
          CHANGING
            vendor     = ls_goitem-lifnr
            vendorname = ls_goitem-vendorname.
      ELSEIF ls_return-type = 'E'.                          "1077786
        def_msg_add oref_doc_log                            "1077786
                     ls_return-type                         "1077786
                     ls_return-id                           "1077786
                     ls_return-number                       "1077786
                     ls_return-message_v1                   "1077786
                     ls_return-message_v2                   "1077786
                     ls_return-message_v3                   "1077786
                     ls_return-message_v4.                  "1077786
        CONTINUE.                                           "1077786
      ENDIF.
    ENDIF.

* RMA: goods issue must be processed before goods receipt of 2-step-transfer
    data: lr_mb_transfer type ref to mb_transfer,
          ls_mseg type mseg.
    try.
        get badi lr_mb_transfer.
        call badi lr_mb_transfer->check_order_of_steps
          EXPORTING
            is_mseg   = ls_mseg
            is_wueb   = is_wueb
            is_goitem = ls_goitem
          IMPORTING
            e_return  = ls_return.
        if not ls_return is initial.
          def_msg_add oref_doc_log
                       ls_return-type
                       ls_return-id
                       ls_return-number
                       ls_return-message_v1
                       ls_return-message_v2
                       ls_return-message_v3
                       ls_return-message_v4.
          continue.
        endif.
      catch cx_badi_not_implemented.
    endtry.

*   Insert line
    CALL METHOD line_modify
      EXPORTING
        i_line            = 0
        i_authority_check = abap_true
        i_status_delayed  = abap_true
      CHANGING
        cs_goitem         = ls_goitem.
*   Read serial number data (only serial numbers from delivery)
*   EhP 604 serial numbers from PO are also possible
    IF NOT ls_goitem-sernp IS INITIAL                       "491680
       AND ( NOT ls_goitem-vbeln IS INITIAL OR              "491680
             NOT ls_goitem-vlief_avis IS INITIAL OR         "491680
             cl_mmpur_switch_check=>get_serial01_switch_state( ) = abap_true ). "EhP604
      CALL METHOD serialnumbers_read
        EXPORTING
          is_goitem   = ls_goitem
          is_vepwe    = is_vepwe                            "731711
        IMPORTING
          et_goserial = lt_goserial.
      ls_goserial_kernel-global_counter = ls_goitem-global_counter.
      ls_goserial_kernel-t_goserial     =  lt_goserial.
      INSERT ls_goserial_kernel INTO TABLE pt_goserial_kernel.
    ENDIF.
  ENDLOOP.
  CALL METHOD status_derive.
ENDMETHOD.