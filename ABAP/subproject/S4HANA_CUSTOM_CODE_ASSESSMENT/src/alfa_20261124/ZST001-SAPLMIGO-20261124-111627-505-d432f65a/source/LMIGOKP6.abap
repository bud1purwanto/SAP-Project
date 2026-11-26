*&---------------------------------------------------------------------*
*&  Include LMIGOKP6  Purchase order                                   *
*&---------------------------------------------------------------------*

************************************************************************
* Fill the data from a purchase order to GOITEM
* Coding is common for GR for PO and GI for transfer PO
* Also called from filled_matdoc
************************************************************************
METHOD purchase_order_fill_goitem.
  DATA: ls_goitem    TYPE goitem,
        l_freight    TYPE abap_bool,
        l_eknam      TYPE eknam,
        l_ektel      TYPE ektel,
        l_autyp      TYPE auftyp.

  ls_goitem = is_goitem.
  MOVE-CORRESPONDING ps_pohead   TO ls_goitem.
* additional supplier data of po
  ls_goitem-vendorname = ps_pohead-name1.
  ls_goitem-vendorzip  = ps_pohead-pstlz.
  ls_goitem-vendoradd  = ps_pohead-ort01.
* Customer number of supplier from header is not used in MIGO.
* Used only in XDELIV for creation of delivery
* (GN_DELIVERY_CREATE), but irrelevant for MIGO.
* It should not be displayed on PARTNER-tabstrip. In case of
* third party order, field is filled from item data.
  CLEAR ls_goitem-kunnr.
  IF i_transfer = abap_true.
    MOVE-CORRESPONDING is_st_poitem TO ls_goitem.
*   KZZUG: defines an item as goods issue to stock transfer PO
    ls_goitem-kzzug      = abap_true.
    ls_goitem-maktx      = is_st_poitem-txz01.
  ELSE.
    MOVE-CORRESPONDING is_poitem   TO ls_goitem.
*   flag that indicate that goods receipt refers to purchase order,
*   KZBEW is as well necessary
    ls_goitem-xpoitem    = abap_true.
    IF s_action-migo_mode = 'GS'.
      ls_goitem-kzbew      = o.
*     clear non relevant fields for subsequent adjustment. Maybe more
*     fields need to be added...
      CLEAR: ls_goitem-lgort,
             ls_goitem-evers.
    ELSE.
      ls_goitem-kzbew      = b.
    ENDIF.
    ls_goitem-maktx      = is_poitem-txz01.
    ls_goitem-migo_elikz = 1.
    ls_goitem-elikz_po   = is_poitem-elikz.
    CASE ls_goitem-insmk.
      WHEN ' ' OR 'F'.
        CLEAR ls_goitem-migo_insmk.
      WHEN '2' OR 'X'.
        ls_goitem-migo_insmk = '2'.
      WHEN '3' OR 'S'.
        ls_goitem-migo_insmk = '3'.
      WHEN OTHERS.
    ENDCASE.
*   In case of GR for STO we have to set the kzzug, too         "1337306
*   as it is done in MM07MFB7_BESTELLUNG_UEBERNEH02             "1337306
     IF is_poitem-bsakz = t.                                    "1337306
       ls_goitem-kzzug = x.                                     "1337306
     ENDIF.                                                     "1337306
  ENDIF.

*-- MAA-DEV
    call method oref_detail_maa->maa_disp_acc
          CHANGING
               cs_goitem    = ls_goitem.
*-- MAA-DEV
* Outsourced manufacturing
* begin of note 1336246
* If no subcontracting PO, stop here, no need to read further.
  SELECT SINGLE autyp FROM aufk INTO l_autyp
      WHERE aufnr = is_poitem-aufnr.
  IF l_autyp = '04' OR
     l_autyp = '40' OR
     l_autyp = '10'.
    ls_goitem-xco_order = is_poitem-co_order.
  ENDIF.
* end of note 1336246
* ---Common part of coding for transfer orders and normal ones--

* Freight vendor possible?
* No freights in case of subsequent adjustment
  IF s_action-migo_mode <> 'GS'.
    CALL METHOD purchase_order_fill_gofreight
         EXPORTING it_pofreight = it_pofreight
                   i_po_number  = ls_goitem-ebeln
                   i_po_item    = ls_goitem-ebelp
         IMPORTING e_freight    = l_freight.
    IF l_freight = abap_true.
*     Freight available for this item
      ls_goitem-freight = abap_true.
    ENDIF.
  ENDIF.
* Subcontracting
* Begin of Outsourced Manufacturing EhP 4
ENHANCEMENT-POINT PURCHASE_ORDER_FILL_GOITEM_01 SPOTS ES_SAPLMIGO.
  IF ls_goitem-kzbwa = '02' AND s_control-refdoc = 'R01'.
    CLEAR: ls_goitem-kzbew, ls_goitem-xpoitem, ls_goitem-kzzug.
    ls_goitem-ummat_lifnr = is_poitem-emlif.
    goitem-ummat_lifnr = is_poitem-emlif.
    ls_goitem-umsok = o.
ENHANCEMENT-POINT PURCHASE_ORDER_FILL_GOITEM_02 SPOTS ES_SAPLMIGO.
    es_goitem = ls_goitem.
    EXIT.
  ENDIF.
* End of Outsourced Manufacturing EhP 4
  CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
       EXPORTING
            pstyp = ls_goitem-pstyp
       IMPORTING
            ptext = ls_goitem-ptext.
* special stock sales order and project
* handle values for subscreen stock_identifier
  IF ls_goitem-sobkz = e AND NOT ls_goitem-kdauf IS INITIAL.
    ls_goitem-mat_kdauf = ls_goitem-kdauf.
    ls_goitem-mat_kdpos = ls_goitem-kdpos.
    CLEAR: ls_goitem-kdauf, ls_goitem-kdpos.
  ENDIF.
  IF ls_goitem-sobkz = q AND NOT ls_goitem-ps_psp_pnr IS INITIAL.
    ls_goitem-mat_pspnr = ls_goitem-ps_psp_pnr.
    CLEAR ls_goitem-ps_psp_pnr.
  ENDIF.
ENHANCEMENT-POINT LMIGOKP6_01 SPOTS ES_SAPLMIGO.
* Fill buyer data
  ls_goitem-pouser = ps_pohead-ernam.
  CALL METHOD lcl_migo_buffer=>name_and_phone_get
       EXPORTING i_usnam = ls_goitem-pouser
       IMPORTING e_exnam = ls_goitem-pousername
                   e_telnr = ls_goitem-telpouser.
* Fill in complete name of buyer group
  CALL METHOD lcl_migo_buffer=>name_and_phone_buyer_get
       EXPORTING i_ekgrp = ls_goitem-ekgrp
       IMPORTING e_eknam = l_eknam
                 e_ektel = l_ektel.
  ls_goitem-buyer  = l_eknam.
  ls_goitem-telnr1 = l_ektel.
* take over special po data for full product or tied empty; <LG>
  CALL METHOD purchase_order_full_empty
       EXPORTING  is_poitem    = is_poitem
                  is_st_poitem = is_st_poitem
                  i_transfer   = i_transfer
       CHANGING   cs_goitem    = ls_goitem
       EXCEPTIONS full_not_found = 1.
  IF sy-subrc = 1.
*   tied empty without leading full product -> don't take over
    RAISE no_take_over.
  ENDIF.
* --This part of coding is not for transfer orders--------------
  IF i_transfer = abap_false.
    IF ls_goitem-inco1 = space.
      ls_goitem-inco1 = ps_pohead-inco1.
    ENDIF.
    IF ls_goitem-inco2 = space.
      ls_goitem-inco2 = ps_pohead-inco2.
    ENDIF.
  ENDIF.                               "i_transfer = abap_false
* Please put common coding for normal PO and GI transfer PO
* in the common part (before if i_transfer = abap_false)
  es_goitem = ls_goitem.
ENDMETHOD.

************************************************************************
* Read the data from a purchase order and fill them to material
* document item during cancellation or display
************************************************************************
METHOD purchase_order_fill_matdoc.
  TYPES: ty_s_pofreight_ekbz TYPE ekbz,
         ty_t_pofreight_ekbz TYPE STANDARD TABLE OF ty_s_pofreight_ekbz.
  DATA: lt_poitem         TYPE ty_t_poitem,
        lt_pofreight      TYPE ty_t_pofreight,
        lt_gofreight      TYPE ty_t_gofreight,
        lt_pofreight_ekbz TYPE ty_t_pofreight_ekbz,
        ls_pofreight      TYPE ty_s_pofreight,
        ls_gofreight      TYPE ty_s_gofreight,
        ls_goitem         TYPE ty_s_goitem,
        ls_poitem         TYPE ty_s_poitem,
        ls_pofreight_ekbz TYPE ty_s_pofreight_ekbz.
  FIELD-SYMBOLS: <ls_pofreight> TYPE ty_s_pofreight.
* CHECK is_goitem-xcancel_done = abap_false.
  ls_goitem = is_goitem.
* Read Header
  CALL METHOD purchase_order_read_header
    EXPORTING i_po_number = is_mseg-ebeln.
* ps_pohead is empty if nothing found or header error
  IF ps_pohead IS INITIAL.                     "329058
    RAISE no_take_over.                        "329058
  ENDIF.                                       "329058
* Read items
  CALL METHOD purchase_order_read_data
       EXPORTING i_po_number  = is_mseg-ebeln
                 i_po_item    = is_mseg-ebelp
                 i_md_number  = is_mseg-mblnr
                 i_md_year    = is_mseg-mjahr
                 i_md_item    = is_mseg-zeile
                 i_lfbnr      = is_mseg-lfbnr
                 i_lfpos      = is_mseg-lfpos
                 i_lfbja      = is_mseg-lfbja
       IMPORTING et_poitem    = lt_poitem
                 et_pofreight = lt_pofreight.
* PO returns both full product and empties bom when calling
* me_read_item_goods_receipt with just the full product
* -> cancel tied empties; <LG>
* The same applies to the header position of a generic article
* (dt. Sammelartikel)
  DELETE lt_poitem WHERE ebelp <> is_mseg-ebelp.
  IF lt_poitem IS INITIAL.
    RAISE no_take_over.                        "329058
  ENDIF.
* If a goods receipt has been posted for several inbound deliveries
* of the same item, it is possible to get several lines from ME_READ
* with same PO item as we do not read the PO with the inbound delivery
* number.
* The only line in the table is the correct one.
  READ TABLE lt_poitem INTO ls_poitem INDEX 1.
* Find out whether for any of the freight lines for this position
* there is an entry in the kernel-table. In this case, any
* of the READs was successful and LS_GOFREIGHT is filled with anything.
  LOOP AT lt_pofreight INTO ls_pofreight.
    READ TABLE pt_gofreight_kernel INTO ls_gofreight
                           WITH KEY ebeln = ls_pofreight-ebeln
                                    ebelp = ls_pofreight-ebelp
                                    zaehk = ls_pofreight-zaehk
                                    stunr = ls_pofreight-stunr.
  ENDLOOP.
* In this case, do something.
  IF ls_gofreight IS INITIAL.
*   Get all freights for the entire PO-position
    CALL FUNCTION 'MMPUR_EKBZ_READ_EBELN_EBELP'
         EXPORTING
              pi_ebeln          = is_mseg-ebeln
              pi_ebelp          = is_mseg-ebelp
              pi_refresh_buffer = abap_true
         TABLES
              pto_ekbz_po       = lt_pofreight_ekbz
         EXCEPTIONS
              error_message.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
*   For each of them loop over "our" freight lines
*   and get the freight vendor from the old document.
    LOOP AT lt_pofreight_ekbz INTO ls_pofreight_ekbz
                          WHERE belnr = is_mseg-mblnr
                          AND   buzei = is_mseg-zeile.
       LOOP AT lt_pofreight ASSIGNING <ls_pofreight>
                  WHERE ebeln = ls_pofreight_ekbz-ebeln
                  AND   ebelp = ls_pofreight_ekbz-ebelp
                  AND   zaehk = ls_pofreight_ekbz-zaehk
                  AND   stunr = ls_pofreight_ekbz-stunr.
        CHECK NOT <ls_pofreight>-frerf IS INITIAL.
        <ls_pofreight>-lifnr = ls_pofreight_ekbz-lifnr.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
* In case of 351 we do not need to read bbefu so we do not need
* to fill goitem from st_poitem. So i_transfer = abap_false
  CALL METHOD purchase_order_fill_goitem
       EXPORTING i_transfer   = abap_false
                 is_poitem    = ls_poitem
                 is_goitem    = is_goitem
                 it_pofreight = lt_pofreight
       IMPORTING es_goitem    = ls_goitem
       EXCEPTIONS no_take_over = 1.
* if trouble with actual po item (e.g. tied empty) -> skip it; <LG>
  IF NOT sy-subrc IS INITIAL.
    def_msg_add oref_doc_log e 'M7' '350'
                        ls_poitem-ebeln
                        ls_poitem-ebelp
                        space space.
    RAISE no_take_over.
  ENDIF.
* if po item is a tied empty -> memorize original lfbnr; <LG>
  IF ls_poitem-uptyp = c_uptyp_lg.
    IF ls_poitem-lfbnr IS INITIAL.
      MOVE is_mseg-lfbnr TO ls_poitem-lfbnr.
    ENDIF.
  ENDIF.

*-----------------------EhP6 DInv--Start---------------------
  IF cl_ops_switch_check=>mm_sfws_dinv_01( ) = abap_true AND
     ls_poitem-xdinv IS NOT INITIAL.
    IF s_action-subsequent = abap_true AND
       s_action-create = abap_true.
      ls_goitem-charg = is_mseg-charg.
    ENDIF.
  ENDIF.
*-----------------------EhP6 DInv--End-----------------------

  es_goitem = ls_goitem.

ENDMETHOD.

************************************************************************
* Fill the data from a purchase order to PT_GOFREIGHT
************************************************************************
METHOD purchase_order_fill_gofreight.
  DATA: ls_gofreight TYPE ty_s_gofreight,
        ls_pofreight TYPE ty_s_pofreight.
* Freight vendor possible?
  LOOP AT it_pofreight INTO ls_pofreight
                       WHERE ebeln = i_po_number
                       AND   ebelp = i_po_item
                       AND   frerf <> ' '.
    READ TABLE pt_gofreight_kernel INTO ls_gofreight
                            WITH KEY ebeln = ls_pofreight-ebeln
                                     ebelp = ls_pofreight-ebelp
                                     zaehk = ls_pofreight-zaehk
                                     stunr = ls_pofreight-stunr.
    IF sy-subrc <> 0.
*---- for each PO Item only one entry for each ZAEHK / STUNR
      MOVE-CORRESPONDING ls_pofreight TO ls_gofreight.
      CLEAR ls_gofreight-vendorname.
      IF ls_pofreight-lifnr <> space.
        CLEAR: ps_vendordata_a.
        CALL METHOD lcl_migo_buffer=>vendor_master_get
           EXPORTING i_lifnr = ls_pofreight-lifnr
           IMPORTING es_vendordata_a = ps_vendordata_a
           EXCEPTIONS OTHERS = 1.
        IF sy-subrc = 0.
          ls_gofreight-vendorname = ps_vendordata_a-name1.
        ENDIF.
      ENDIF.
      INSERT ls_gofreight INTO TABLE pt_gofreight_kernel.
      e_freight = abap_true.
    ENDIF.
  ENDLOOP.
ENDMETHOD.