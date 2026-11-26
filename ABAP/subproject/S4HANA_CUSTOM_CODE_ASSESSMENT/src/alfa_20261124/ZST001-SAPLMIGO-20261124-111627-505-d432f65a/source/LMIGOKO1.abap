*----------------------------------------------------------------------*
*   INCLUDE LMIGOKO1                                                   *
*   Outbound delivery
*----------------------------------------------------------------------*

METHOD outbound_delivery_read.
  DATA: ls_wueb  TYPE ty_s_wueb,
        lt_wueb  TYPE ty_t_wueb,
        ls_vepwe TYPE ty_s_vepwe,
        lt_vepwe TYPE ty_t_vepwe,            "note 314765
        ls_156   TYPE t156,                  "note 314765
        ls_got156 TYPE got156,               "note 314765
        ls_likp  TYPE likp,                       "673739
        ls_ekpo  TYPE ekpo.                       "SIT
  IF i_shipping_unit = x.
    CALL METHOD shippingelement_select
      EXPORTING
        i_vbeln = i_outbound_delivery
      IMPORTING
        et_vepwe = lt_vepwe.
  ELSE.
    ls_vepwe-vbeln = i_outbound_delivery.
    APPEND ls_vepwe TO lt_vepwe.
  ENDIF.

* Read movement type data                         "314765
  CALL METHOD lcl_migo_buffer=>move_type_get      "314765
      EXPORTING i_move    = s_defaults-bwart      "314765
      IMPORTING  e_got156 = ls_got156
      EXCEPTIONS OTHERS   = 1.                    "314765
  MOVE-CORRESPONDING ls_got156 TO ls_156.         "314765

  LOOP AT lt_vepwe INTO ls_vepwe.
    CALL FUNCTION 'SD_DELIVERY_ITEMS_RECEIVE'
      EXPORTING
        vbeln                  = ls_vepwe-vbeln
        posnr                  = ls_vepwe-posnr
        if_lock                = 'X'              "435772
        is_t156                = ls_156           "314765
      IMPORTING
        es_likp                = ls_likp          "673739
      TABLES
        wueb                   = lt_wueb
      EXCEPTIONS
        no_delivery            = 1
        delivery_not_suitable  = 2
        delivery_not_posted_gi = 3
        no_items_receiving     = 4
        no_receiving_plant     = 5
        no_delivery_item       = 6
        no_movement_type       = 7
        delivery_locked        = 8                 "435772
        OTHERS                 = 9.

    IF sy-subrc = 0 AND ls_likp-vbtyp CA '7g'.     "673739 "711229
      sy-subrc = 2.
    ENDIF.
    IF sy-subrc <> 0.
      def_msg_add oref_doc_log e 'M7' '865' i_outbound_delivery
                                            sy-subrc space space.
      CONTINUE.
    ENDIF.
*   Only if entered via shipping unit, VEPWE is filled with
*   useful data. Otherwise it is only a carrier for VBELN.
    IF i_shipping_unit = space.
      CLEAR ls_vepwe.
    ENDIF.
    LOOP AT lt_wueb INTO ls_wueb.
      IF NOT ls_wueb-ebeln IS INITIAL.
        IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
*         SIT: No GR to outbound delivery for items with confirmation
*              control key
          IF ls_wueb-vbeln IS NOT INITIAL
          AND cl_mm_im_sit_info=>get_sit_info_item(
                iv_ebeln = ls_wueb-ebeln
                iv_ebelp = ls_wueb-ebelp ) IS NOT INITIAL.
            CLEAR ls_ekpo.
            CALL FUNCTION 'ME_EKPO_SINGLE_READ'
              EXPORTING
                pi_ebeln = ls_wueb-ebeln
                pi_ebelp = ls_wueb-ebelp
              IMPORTING
                po_ekpo  = ls_ekpo
              EXCEPTIONS
                OTHERS   = 1.
            IF sy-subrc = 0 AND ls_ekpo-bstae IS NOT INITIAL.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
        CALL METHOD purchase_order_get
          EXPORTING
            i_po_number = ls_wueb-ebeln
            i_po_item   = ls_wueb-ebelp
*           i_ib_number = ls_wueb-vbeln        note 314255
*           i_ib_item   = ls_wueb-vbelp        ME_READ item should only
                                              "be called with vbeln in
                                              "case of inbound delivery
            is_wueb     = ls_wueb
            is_vepwe    = ls_vepwe
            i_delivery  = abap_true.
      ELSE.
        CALL METHOD new_position_from_wueb
          EXPORTING
            is_wueb    = ls_wueb
            is_vepwe   = ls_vepwe
            i_delivery = abap_true.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDMETHOD.