*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLK_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLK_SELECT                                              *
*---------------------------------------------------------------------*
*       Lieferartentabelle   mit Texttabelle lesen                    *
*---------------------------------------------------------------------*
form tvlk_select using ts_lfart like tvlk-lfart
                       ts_error type c
                       ts_subrc like sy-subrc.

  statics: sf_lfart_memo type lfart value space.            "n_923442

  ts_subrc = 0.

  if ts_lfart ne tvlk-lfart.                                "v_n_1083228

  select single * from tvlk where lfart eq ts_lfart.

  if sy-subrc ne 0.
    clear tvlk.
    clear tvlkt.
    ts_subrc = 4.
    if ts_error eq charx.
      perform message_handling(sapmv50a) using posnr_low
                                               '309'
                                               'E'
                                               'VL'
                                               ts_lfart
                                               space
                                               space
                                               space.
      endif.
      return.
    endif.

    select single * from tvlkt where spras eq sy-langu
                               and lfart eq ts_lfart.

    if sy-subrc ne 0.
      ts_subrc = 0.
      clear: tvlkt.
    endif.

  endif.

* Determine internal confirmation type for inbound deliveries and rough
* goods receipts and store it in a global variable. The internal
* confirmation type will be used at several locations later and can
* therfore be determined centrally
  if tvlk-lfart ne sf_lfart_memo.
    clear lfart_besttyp.
    if tvlk-vbtyp ca vbtyp_mmli.
      call function 'ME_CONFIRMATION_DELIVERY_TYPE'
        exporting
          i_func              = '2'
        changing
          c_ibtyp             = lfart_besttyp
          c_lfart             = tvlk-lfart
        exceptions
          function_not_valid  = 0
          param_value_missing = 0
          no_item_found       = 0.
    endif.
    sf_lfart_memo = tvlk-lfart.
  endif.                                                    "^_n_1083228

endform.                    "TVLK_SELECT
*eject