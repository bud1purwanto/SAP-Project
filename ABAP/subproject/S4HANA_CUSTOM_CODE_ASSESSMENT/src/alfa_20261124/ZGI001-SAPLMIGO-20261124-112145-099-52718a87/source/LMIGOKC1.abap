*----------------------------------------------------------------------*
*   INCLUDE LMIGOKC1                                                   *
*   Read confirmations
*----------------------------------------------------------------------*

************************************************************************
* Call ME_CONFIRMATION_SEARCH_GR for the given VBELN/VBELP and
* append the purchase orders found in the confirmations
************************************************************************
METHOD confirmation_get.
  DATA: ls_wueb  TYPE wueb,
        lt_wueb  TYPE TABLE OF wueb,
        l_bolnr  TYPE bolnr,
        l_verur  TYPE verur_vl,
        ls_vepwe TYPE ty_s_vepwe,
        l_besttyp TYPE t163d-ibtyp.                              "673739

  CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
    EXPORTING
      i_vbeln   = i_vbeln
      i_vbelp   = i_vbelp
    IMPORTING
      bolnr     = l_bolnr
      verur     = l_verur
      e_besttyp = l_besttyp                                      "673739
    TABLES
      t_wueb    = lt_wueb.

  CHECK: l_besttyp = 2 OR l_besttyp = 3.
* Batch-split in inbound delivery: WUEB contains all positions,
* but only the split positions need to be given to ME_READ_ITEM_GOODS...
  LOOP AT lt_wueb INTO ls_wueb WHERE uecha <> SPACE.             "664143
    DELETE lt_wueb WHERE uecha = SPACE                           "664143
                   AND   ebeln = ls_wueb-ebeln                   "664143
                   AND   ebelp = ls_wueb-ebelp.                  "664143
  ENDLOOP.                                                       "664143
  LOOP AT lt_wueb INTO ls_wueb.
    ls_wueb-vbeln      = i_vbeln.
    ls_wueb-xblnr_avis = l_verur.
    ls_wueb-frbnr_avis = l_bolnr.
    MODIFY lt_wueb FROM ls_wueb.
  ENDLOOP.

* If not called via VEPWE, VEPWE-VBELN has used to transport the
* field only. To avoid checks in KP2, clear the structure
* entirely.
  IF NOT is_vepwe-venum IS INITIAL.
    ls_vepwe = is_vepwe.
  ENDIF.

  LOOP AT lt_wueb INTO ls_wueb.
    IF NOT ls_wueb-ebeln IS INITIAL.
      CALL METHOD purchase_order_get
        EXPORTING
          i_po_number = ls_wueb-ebeln
          i_po_item   = ls_wueb-ebelp
          i_ib_number = ls_wueb-vbeln
          i_ib_item   = ls_wueb-vbelp
          is_wueb     = ls_wueb
          is_vepwe    = ls_vepwe.
    ELSE.
      CALL METHOD new_position_from_wueb
        EXPORTING
          is_wueb  = ls_wueb
          is_vepwe = ls_vepwe.
    ENDIF.
  ENDLOOP.
ENDMETHOD.