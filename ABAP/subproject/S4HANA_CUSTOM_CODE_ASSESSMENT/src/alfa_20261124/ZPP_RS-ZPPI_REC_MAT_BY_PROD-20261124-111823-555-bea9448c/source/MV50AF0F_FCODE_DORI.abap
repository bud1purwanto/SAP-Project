*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FCODE_DORI
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  fcode_dori
*&--------------------------------------------------------------------*
form fcode_dori.

  data: ls_delivery_relations type /spe/ret_delivery_relations.

  perform xlips_detail_nd(sapfv50p).

  if fcode ne fcode_gleiche_seite.
    call function '/SPE/RET_DIALOG_PREPARE'
      exporting
        is_likp                = likp
        is_lips                = lips
        it_xvbapf              = xvbapf[]                 "n_1245044
      importing
        es_delivery_relations  = ls_delivery_relations
      tables
        ct_xlips               = xlips[]
        it_xvbup               = xvbup[]
      exceptions
        acc_app_not_determined = 0
        others                 = 0.
    if ls_delivery_relations-orig_vbeln ne space.
      call function 'RV_CALL_DISPLAY_TRANSACTION'
        exporting
          vbeln = ls_delivery_relations-orig_vbeln.
    endif.
  endif.

  perform xlips_detail_back(sapfv50p).

endform.                    "fcode_dori