*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_INSPECTION_LOT_RENUMB                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&    Form  INSPECTION_LOT_RENUMBER (HP_368559)
*&---------------------------------------------------------------------*
*     Assigns the new delivery number to the created inspection lots
*     This is only necessary for inbound deliveries in case of
*     GR posting via transaction VL01N because this procedure requires
*     the creation of the inspection lot before the delivery number is
*     known.
*----------------------------------------------------------------------*
form inspection_lot_renumber using if_vbeln like likp-vbeln.

  data: ls_qals type qals,
        lf_qals_updkz like qalsvb-upsl.

  field-symbols: <ls_xlips> like line of xlips.

  loop at xlips assigning <ls_xlips>
                where vbeln eq if_vbeln
                  and not qplos is initial.

    call function 'QPL1_LOT_GET'
         exporting
              i_prueflos = <ls_xlips>-qplos
         importing
              e_qals     = ls_qals
              e_updkz    = lf_qals_updkz
         exceptions
              no_lot     = 1
              others     = 2.

    if sy-subrc ne 0.
*     It is assumed that the inspection lot has been created
*     successfully ealier and is therefore not present in the global
*     memory of function group qpl1
      continue.
    endif.
*   Assign new delivery number to the inspection lot if necessary
    if ls_qals-ls_vbeln ne if_vbeln.
      ls_qals-ls_vbeln = if_vbeln.
      call function 'QPL1_UPDATE_MEMORY'
           exporting
                i_qals  = ls_qals
                i_updkz = lf_qals_updkz.
    endif.

  endloop.

endform.