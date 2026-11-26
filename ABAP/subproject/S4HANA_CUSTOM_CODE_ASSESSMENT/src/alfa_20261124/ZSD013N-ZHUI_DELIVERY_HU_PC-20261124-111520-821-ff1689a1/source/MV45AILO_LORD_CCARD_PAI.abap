*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_CCARD_PAI
*&---------------------------------------------------------------------*

form lord_ccard_pai_multi.

  data: lf_dataloss type flag.

  call function 'SD_CCARD_DATA_GET'
    exporting
      iv_fplnr    = vbak-rplnr
    importing
      ev_fplnr    = vbak-rplnr
      ef_upd_fpla = upd_fpla
      ef_upd_fplt = upd_fplt
      ef_dataloss = lf_dataloss
      et_xfpla    = xfpla[]
      et_yfpla    = yfpla[]
      et_xfplt    = xfplt[]
      et_yfplt    = yfplt[].

  if lf_dataloss ne space and
     r185d-dataloss eq space.
    r185d-dataloss = lf_dataloss.
  endif.

  perform vbak_aendern(sapfv45k).

  refresh open_values.

  if lf_dataloss ne space.
    if ( tvak-klimp eq chard or
         not tvak-babss is initial ) and
       vbuk_recheck is initial.
      perform creditcheck(sapmv45a) using space
                                          space
                                 changing kvbuk.
    endif.
  endif.

endform.                    "lord_ccard_pai_multi