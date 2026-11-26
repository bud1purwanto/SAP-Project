*eject
*----------------------------------------------------------------------*
*       FORM XVBPA_DETERMINE_TXJCD                                     *
*----------------------------------------------------------------------*
*       Determination of the tax jurisdiction code                     *
*----------------------------------------------------------------------*
form xvbpa_determine_txjcd using us_vbpakom structure vbpakom
                        changing ch_txjcd like vbpakom-txjcd
                                 ch_ort01 like vbpakom-ort01
                                 ch_ort02 like vbpakom-ort02.

  data: da_txjcd like vbpakom-txjcd.
  data: da_ort01 like vbpakom-ort01.
  data: da_ort02 like vbpakom-ort02.
  data: da_msgty like t100c-msgts.


  check: not us_vbpakom-land1 is initial,
             us_vbpakom-txjcd is initial.
*       Kennzeichen 'Ext. Steuersystem aktiv' beim Schema gesetzt?
  if t005-land1 <> us_vbpakom-land1.
    select single * from t005 where land1 = us_vbpakom-land1.
    if sy-subrc <> 0.
      message id 'F2' type 'E' number '013' with us_vbpakom-land1.
    endif.
  endif.
  if ttxd-kalsm <> t005-kalsm.
    select single * from ttxd where kalsm = t005-kalsm.
  endif.

  check ttxd-kalsm = t005-kalsm and
    not ttxd-xextn is initial.

*       Funktionsbaustein zur Ermittlung Jurisdiction Code aufrufen
  call function 'DETERMINE_TXJCD_EXTERNALLY'
    exporting
      country                       = us_vbpakom-land1
      region                        = us_vbpakom-regio
      city                          = us_vbpakom-ort01
      county                        = us_vbpakom-ort02
      zipcode                       = us_vbpakom-pstlz
      procedure                     = ttxd-kalsm
      id_tax_ext                    = ttxd-xextn
      no_dialog                     = charx
    importing
      txjcd                         = da_txjcd
      city                          = da_ort01
      county                        = da_ort02
    exceptions
      txjcd_not_found               = 1
      txjcd_not_unique_in_no_dialog = 2
      external_txjcd_not_required   = 3
      txjcd_processing_not_required = 4
      rfcdest_not_found             = 5.

  case sy-subrc.
    when 0.
      if ch_ort01 <> da_ort01 or
         ch_ort02 <> da_ort02.
        ch_ort01 =  da_ort01.
        ch_ort02 =  da_ort02.
      endif.
      ch_txjcd = da_txjcd.
    when 1. message id 'F2' type 'E' number '217'.
    when 2.
      call function 'READ_CUSTOMIZED_MESSAGE'
        exporting
          i_arbgb = 'F2'
          i_dtype = 'E'
          i_msgnr = '217'
        importing
          e_msgty = da_msgty.
      if call_bapi eq charx.
        perform message_vbfs_aufbauen(sapfv45l) using 'F2'
                                            '217'
                                            da_msgty
                                            space
                                            space
                                            space
                                            space.
      else.
        message id 'F2' type 'E' number '217'.
      endif.
  endcase.

endform.                    "xvbpa_determine_txjcd