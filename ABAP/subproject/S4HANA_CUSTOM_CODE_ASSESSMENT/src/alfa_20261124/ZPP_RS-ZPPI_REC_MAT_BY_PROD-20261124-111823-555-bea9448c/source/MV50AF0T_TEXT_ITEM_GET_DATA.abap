*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TEXT_ITEM_GET_DATA                                *
*----------------------------------------------------------------------*
form text_item_get_data.

  data: lf_change_flag type c.

  call function 'SD_WORD_PROCESSING_GET'
       exporting
            fi_fcode_before_return = fcode
       importing
            fe_change_flag      = lf_change_flag
            fe_fcode_on_return  = fcode
*           FE_TEXTNAME         =
*           FE_SUBSCREEN_NUMBER =
            fet_xvbuv           = xvbuv[]
       changing
            fet_xthead          = xthead[]
       exceptions
            error_occured       = 1
            others              = 2
            .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  if lf_change_flag ne space.
    r185d-dataloss = charx.
  endif.

* Workaround: Filter FCODES that cannot be processed by the main
* dialog
  perform subscreen_fcode_filter changing fcode.

  perform uc_upd_request(sapfv50u) using charx lips-posnr   "n_531900
                                         lips-uepos lips-uecha.

endform.