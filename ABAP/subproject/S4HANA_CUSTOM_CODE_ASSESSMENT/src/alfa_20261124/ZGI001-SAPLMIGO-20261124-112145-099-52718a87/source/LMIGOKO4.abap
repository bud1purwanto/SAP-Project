*----------------------------------------------------------------------*
*   INCLUDE LMIGOKO4                                                   *
*   order                                                              *
*----------------------------------------------------------------------*


************************************************************************
* Externally called method to add the data of the order                *
************************************************************************

METHOD order_read.
  CALL METHOD order_get
    EXPORTING
       i_order_number = i_order_number
       i_order_item   = i_order_item.
ENDMETHOD.


************************************************************************
* Internally called method to add the data of an order                 *
************************************************************************

METHOD order_get.

  DATA: lt_orditem TYPE ty_t_orditem.

* read data
  CALL METHOD order_read_data
    EXPORTING i_order_number = i_order_number
              i_order_item   = i_order_item
    IMPORTING et_orditem     = lt_orditem.

* fill data in pt_goitem
  CALL METHOD order_fill_data
    EXPORTING it_orditem     = lt_orditem.

ENDMETHOD.

************************************************************************
* Read data from order and fill tables lt_orditem                      *
************************************************************************

METHOD order_read_data.

  DATA: l_autyp    TYPE cobl-autyp,
        ls_got156  TYPE got156,
        lt_orditem TYPE ty_t_orditem.                           "432683

  CLEAR et_orditem.

  CALL FUNCTION 'CO_SF_HEADER_GOODS_RECEIPT'
     EXPORTING  aufnr              = i_order_number
                flg_extern         = x
                flg_noenq          = s_action-display            "209956
     IMPORTING  autyp              = l_autyp
     EXCEPTIONS not_activ          = 1
                not_found          = 2
                wrong_status       = 3
                wrong_type         = 4
                collective_order   = 5
                lock_error         = 6.

  IF sy-subrc <> 0.
    IF s_action-create = abap_true.                            "432683
       def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       EXIT.
    ENDIF.                                                     "432683
  ENDIF.
  IF l_autyp = '05'.                 "ordertype is run schedule header
    IF s_action-display = abap_false.
    def_msg_add oref_doc_log e 'M7' '162' i_order_number space space
                                                                 space.
    ENDIF.
*   Note 488111:
*   No need to read order data for product cost controller as e.g.
*   ordered quantity has not any meaning.... same for GR quantity.
    EXIT.
  ENDIF.

* Read data for the current movement type from the defaults
* (will be used to fill the movement type).
* If working with reference to a material document, the order is
* read just for info and the data are not so important.
  IF NOT ( s_control-refdoc = 'R02' OR s_control-refdoc = 'R03' ).
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING  i_move    = s_defaults-bwart
      IMPORTING  e_got156  = ls_got156
      EXCEPTIONS not_found = 1.
    IF sy-subrc <> 0.
      def_msg_add oref_doc_log e 'MICK' '001' s_defaults-bwart space
                                                          space space.
      EXIT.
    ENDIF.
  ELSE.
*   Fill in anything as we will just read the order.
    ls_got156-shkzg = s.
  ENDIF.


ENHANCEMENT-SECTION     ORDER_READ_DATA_01 SPOTS ES_SAPLMIGO.
  CALL FUNCTION 'CO_SF_ITEM_GOODS_RECEIPT'
     EXPORTING aufnr  = i_order_number
               aufps  = i_order_item
               budat  = ps_gohead-budat
               smbln  = is_mseg-mblnr
               smblp  = is_mseg-zeile
               sjahr  = is_mseg-mjahr
               xstbw  = s_action-cancel         "seems to be correct
                                                "although different to
                                                "MM07M vm07m-xstor = 2
               xsobkz = is_mseg-sobkz
               xkzbws = is_mseg-kzbws
               xkdauf = is_mseg-kdauf
               xkdpos = is_mseg-kdpos
               xcharg = is_mseg-charg
               xshkzg = ls_got156-shkzg
               xrfrsh = 'X'                                  "589232
     TABLES    fbefu  = lt_orditem
     EXCEPTIONS error_message = 1.                           "432683
END-ENHANCEMENT-SECTION.

     if sy-subrc <> 0.                                       "432683
       IF s_action-create = abap_true.                       "432683
          def_msg_add oref_doc_log e sy-msgid sy-msgno       "432683
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.     "432683
          EXIT.                                              "432683
       endif.                                                "432683
     endif.                                                  "432683

     et_orditem = lt_orditem.                                "432683

ENDMETHOD.

************************************************************************
* Fill data of order in pt_orditem                                     *
************************************************************************

METHOD order_fill_data.

  DATA: ls_goitem  TYPE goitem,
        ls_orditem TYPE fbefu,
        ls_got156  TYPE got156,
        lt_prefetch02 TYPE ty_t_prefetch02,
        lt_prefetch03 TYPE ty_t_prefetch03,
        ls_prefetch02 TYPE ty_s_prefetch02,
        ls_prefetch03 TYPE ty_s_prefetch03.
* serial numbers
  DATA: lt_goserial        TYPE ty_t_goserial,
        ls_vepwe           TYPE vepwe.                           "731711
  DATA: ls_goserial_kernel TYPE ty_s_goserial_kernel.

* material prefetch
  LOOP AT it_orditem INTO ls_orditem WHERE NOT matnr IS INITIAL.
    MOVE-CORRESPONDING ls_orditem TO ls_prefetch02.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    MOVE-CORRESPONDING ls_orditem TO ls_prefetch03.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
  ENDLOOP.
  CALL METHOD material_prefetch_read
    EXPORTING it_prefetch02 = lt_prefetch02
              it_prefetch03 = lt_prefetch03.



* send the data from lt_orditem to ls_goitem and pt_goitem finally
  LOOP AT it_orditem INTO ls_orditem.
    CLEAR ls_goitem.

    CALL METHOD order_fill_goitem
      EXPORTING is_orditem = ls_orditem
                is_goitem  = ls_goitem
      IMPORTING es_goitem  = ls_goitem.

    CALL METHOD defaults_merge CHANGING cs_goitem = ls_goitem.

*   Derive SHKZG for movement type because needed to determine
*   direction of movement.
    CALL METHOD lcl_migo_buffer=>move_type_get
      EXPORTING  i_move    = ls_goitem-bwart
      IMPORTING  e_got156  = ls_got156
      EXCEPTIONS not_found = 1.
    IF sy-subrc = 0.
      ls_goitem-shkzg = ls_got156-shkzg.
    ENDIF.

    ls_goitem-bwtor             = ls_orditem-bwtar.
    ls_goitem-batch_from_refdoc = ls_orditem-charg.


* quantity proposal
    ls_goitem-bumrz             = ls_orditem-umrez.              "433438
    ls_goitem-bumrn             = ls_orditem-umren.              "433438
    ls_goitem-bsmng             = ls_orditem-psmng.
    ls_goitem-bstme             = ls_orditem-amein.

    IF ls_orditem-erfmg IS INITIAL.
      IF ls_goitem-shkzg = s.
        ls_goitem-erfmg = ls_orditem-psmng - ls_orditem-wemng
                                           - ls_orditem-iamng.
      ELSE.
        ls_goitem-erfmg = ls_orditem-wemng.
      ENDIF.
    ELSE.
      ls_goitem-erfmg = ls_orditem-erfmg.
    ENDIF.
    IF ls_goitem-erfmg < 0.
      ls_goitem-erfmg = 0.
    ENDIF.
    ls_goitem-erfme = ls_orditem-amein.

    ls_goitem-knttp = ls_orditem-kzvbr.

*   Do not propose the position if the final delivery indicator is
*   set, despite of movements out of the stock.
*   As the debit/cridit-indicator has not been evaluated at this
*   at this point, but is needed, ...
    IF ls_goitem-erfmg = 0 OR                                    "202128
       (                                                         "202128
         ls_goitem-elikz = abap_true AND                         "202128
         ls_goitem-shkzg = s                                     "202128
       ).                                                        "202128
      CLEAR ls_goitem-take_it.                                   "202128
    ENDIF.                                                       "202128

*   Take the item, if the quantity is set or flag 'propose all   "409754
*   items' is set (->default settings)                           "409754
    CHECK ls_goitem-erfmg <> 0 OR                                "409754
          s_defaults-propose_all_items = abap_true.              "409754

ENHANCEMENT-POINT LMIGOKO4_01 SPOTS ES_SAPLMIGO.

*   Insert line
    CALL METHOD line_modify
      EXPORTING i_line            = 0
                i_authority_check = abap_true
                i_status_delayed  = abap_true
      CHANGING  cs_goitem         = ls_goitem.
ENHANCEMENT-POINT ORDER_FILL_DATA_01 SPOTS ES_SAPLMIGO.
*   Read serial number data
    IF NOT ls_goitem-sernp IS INITIAL.
      CALL METHOD serialnumbers_read
           EXPORTING is_goitem   = ls_goitem
                     is_vepwe    = ls_vepwe                      "731711
           IMPORTING et_goserial = lt_goserial.
      ls_goserial_kernel-global_counter = ls_goitem-global_counter.
      ls_goserial_kernel-t_goserial =  lt_goserial.
      INSERT ls_goserial_kernel INTO TABLE pt_goserial_kernel.
    ENDIF.
  ENDLOOP.

  CALL METHOD status_derive.

ENDMETHOD.


************************************************************************
* order_fill_matdoc                                                    *
* read the data from an order and fill them into the material doc.     *
* during cancellation or display.
* This routine is called anew for each line of the material document.
************************************************************************

METHOD order_fill_matdoc.

  DATA: ls_orditem TYPE ty_s_orditem,
        lt_orditem TYPE ty_t_orditem,
        ls_goitem  TYPE ty_s_goitem.

  ls_goitem = is_goitem.

  CALL METHOD order_read_data
    EXPORTING i_order_number = is_mseg-aufnr
              i_order_item   = is_mseg-aufps
              is_mseg        = is_mseg
    IMPORTING et_orditem     = lt_orditem.

  IF lt_orditem[] IS INITIAL.                                "432683
    RAISE no_take_over.                                      "432683
  ENDIF.                                                     "432683

  READ TABLE lt_orditem INTO ls_orditem INDEX 1.

  CALL METHOD order_fill_goitem
    EXPORTING is_orditem     = ls_orditem
              is_goitem      = ls_goitem
    IMPORTING es_goitem      = ls_goitem.

  es_goitem = ls_goitem.

* To be sure we really only found one line...
  READ TABLE lt_orditem INDEX 2 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    IF lcl_migo_globals=>sap_system = abap_true.
      MESSAGE e899 WITH 'ORDER_FILL_MATDOC' 'multiple lines'
                         space space.
    ELSE.
      MESSAGE s899 WITH 'ORDER_FILL_MATDOC' 'multiple lines'
                         space space.
    ENDIF.
  ENDIF.


ENDMETHOD.

************************************************************************
* order_fill_goitem                                                    *
************************************************************************

METHOD order_fill_goitem.

  es_goitem = is_goitem.
  MOVE-CORRESPONDING is_orditem TO es_goitem.

* handle values for subscreen stock_identifier
  IF is_orditem-sobkz = e AND NOT is_orditem-kdauf IS INITIAL.
    es_goitem-mat_kdauf = is_orditem-kdauf.
    es_goitem-mat_kdpos = is_orditem-kdpos.
    CLEAR: es_goitem-kdauf, es_goitem-kdpos.
  ENDIF.
  IF is_orditem-sobkz = q AND NOT is_orditem-ps_psp_pnr IS INITIAL.
    es_goitem-mat_pspnr = is_orditem-ps_psp_pnr.
    CLEAR es_goitem-ps_psp_pnr.
  ENDIF.

* Both flags indicate that goods receipt refers an order
  es_goitem-xorditem = x.
  es_goitem-kzbew    = f.

  es_goitem-maktx    = is_orditem-ktext.

  es_goitem-migo_elikz = 1.
  es_goitem-elikz_ord  = is_orditem-elikz.
  es_goitem-bsmng      = is_orditem-psmng.
  es_goitem-bstme      = is_orditem-amein.
  es_goitem-wemng      = is_orditem-wemng.
* Move AUFNR and POSNR to PPS_... fields.
* These are necessary to be separate from the accounting fields
* GOITEM-AUFNR is cleared to compensate the MOVE-CORRESPONDING
  es_goitem-pps_aufnr = is_orditem-aufnr.
  es_goitem-pps_posnr = is_orditem-posnr.
  CLEAR es_goitem-aufnr.
  CLEAR es_goitem-aufps.

* INSMK has to be filled to fill the interface of
* MB_CREATE_GOODS_MOVEMENT with correct values. The function
* module MB_CREATE... uses only the passed INSMK.
  CASE is_orditem-insmk.                                        "328790
    WHEN ' ' OR 'F'.                                            "328790
      CLEAR es_goitem-migo_insmk.                               "328790
    WHEN '2' OR 'X'.                                            "328790
      es_goitem-migo_insmk = '2'.                               "328790
    WHEN '3' OR 'S'.                                            "328790
      es_goitem-migo_insmk = '3'.                               "328790
    WHEN OTHERS.                                                "328790
  ENDCASE.                                                      "328790

ENDMETHOD.