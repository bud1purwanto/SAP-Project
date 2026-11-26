***INCLUDE FV50XF0B_SLL_DOCUMENT_TRANSFER .

*----------------------------------------------------------------------*
*   Form SLL_DOCUMENT_TRANSFER                                         *
*----------------------------------------------------------------------*
*  Transfer Inbound Delivery or Outbound Delivery to SAP GTS
*----------------------------------------------------------------------*
form sll_document_transfer using iv_trtyp  type trtyp
                                 it_xlikp  type shp_likp_t
                                 it_xlips  type shp_lips_t
                                 it_ylips  type shp_lips_t
                                 it_xvbpa  type shp_vbpavb_t
                                 it_yvbpa  type shp_vbpavb_t
                                 it_xvbup  type shp_vl10_vbup_t
                                 it_yvbup  type shp_vl10_vbup_t
                                 it_xvbadr type shp_sadrvb_t.

  data: ls_xlikp     type likpvb,
        li_badi_sd0b type ref to sll_pi_sd0b_transfer,
        li_badi_mm0b type ref to sll_pi_mm0b_transfer,
        li_badi_mm0c type ref to sll_pi_mm0c_transfer,
        ls_xlips     type lipsvb,
        lv_retpo     type ekpo-retpo,
        lv_mm0b_call type xfeld,
        lv_sd0b_call type xfeld.

  read table it_xlikp into ls_xlikp index 1 transporting vbtyp.
  if ls_xlikp-vbtyp co vbtyp_liav or
     ls_xlikp-vbtyp co vbtyp_lief.
  else.
    exit.
  endif.

  perform safe_keeping_stat_det_all using space
                                          iv_trtyp.

  case ls_xlikp-vbtyp.
*---- Inbound deliveries
    when vbtyp_liav.
      lv_mm0b_call = gc_true.

*---- Return deliveries
    when vbtyp_lire.
      read table it_xlips into ls_xlips index 1
                    transporting vgbel vgpos vgtyp.
      if ls_xlips-vgtyp = vbtyp_bestell.
        select single retpo into lv_retpo
               from ekpo
               where ebeln = ls_xlips-vgbel
                 and ebelp = ls_xlips-vgpos.
        if lv_retpo = gc_true.
          lv_sd0b_call = gc_true.
        else.
          lv_mm0b_call = gc_true.
        endif.
      else.
        if ls_xlips-vgtyp = vbtyp_reto or
           ls_xlips-vgtyp = vbtyp_auftr.
          lv_mm0b_call = gc_true.
          lv_sd0b_call = gc_true.
        else.
          lv_mm0b_call = gc_true.
        endif.
      endif.

*---- Outbound deliveries
    when vbtyp_lino.
      lv_sd0b_call = gc_true.
  endcase.

  if lv_mm0b_call = gc_true.

    GET BADI li_badi_mm0b.

    if li_badi_mm0b is bound.
      CALL BADI li_badi_mm0b->inbound_delivery_transfer
        EXPORTING
          it_xlikp  = it_xlikp
          it_xlips  = it_xlips
          it_xvbpa  = it_xvbpa
          it_xvbadr = it_xvbadr
          it_xvbup  = it_xvbup.

    endif.

  endif.

*----- Outbound deliveries
  if lv_sd0b_call = gc_true.

    GET BADI li_badi_sd0b.

    if li_badi_sd0b is bound.
      CALL BADI li_badi_sd0b->outbound_delivery_transfer
        EXPORTING
          it_xlikp  = it_xlikp
          it_xlips  = it_xlips
          it_ylips  = it_ylips
          it_xvbpa  = it_xvbpa
          it_yvbpa  = it_yvbpa
          it_xvbup  = it_xvbup
          it_yvbup  = it_yvbup
          it_xvbadr = it_xvbadr.

    endif.

  endif.

* Fill Buffer with delivery information
  GET BADI li_badi_mm0c.

  if li_badi_mm0c is bound.
    CALL BADI li_badi_mm0c->delivery_buffer_fill
      EXPORTING
        it_xlikp = it_xlikp
        it_xlips = it_xlips
        it_xvbpa = it_xvbpa.
  endif.

endform.                    "SLL_DOCUMENT_TRANSFER
*eject