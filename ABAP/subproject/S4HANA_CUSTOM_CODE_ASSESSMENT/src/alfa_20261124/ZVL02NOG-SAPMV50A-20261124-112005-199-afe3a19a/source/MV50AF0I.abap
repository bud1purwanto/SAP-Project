*----------------------------------------------------------------------*
*   INCLUDE MV50AF0I (HP_383471)                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*  FORM invoice_calendar_determine (HP_383471)
*---------------------------------------------------------------------*
*  Deliveries w/o reference: Determine invoice calendar from the
*  customer master of the payer if available. If the payer is not
*  a delivery partner: Use calendar of the ship-to party.
*---------------------------------------------------------------------*
form invoice_calendar_determine tables   it_xvbpa structure vbpavb
                                using    is_kuwev like kuwev
                                changing ef_perfk like likp-perfk.

  data: ls_vbpa_rg like vbpavb,
        ls_vtcom   like vtcom,
        ls_knvv    like knvv.

* If the payer is partner of the delivery take invoice calendar from his
* customer master
  read table it_xvbpa into ls_vbpa_rg
                      with key vbeln = likp-vbeln
                               posnr = posnr_low
                               parvw = parvw_rg.
  if sy-subrc eq 0.
    ls_vtcom-kunnr = ls_vbpa_rg-kunnr.
    ls_vtcom-vkorg = likp-vkorg.
    ls_vtcom-vtweg = rv50a-vtweg.
    ls_vtcom-spart = rv50a-spart.

    call function 'VIEW_KNVV'
      exporting
        comwa   = ls_vtcom
      importing
        knvv_wa = ls_knvv
      exceptions
        no_knvv = 1
        others  = 2.

    if sy-subrc ne 0.
      perform message_handling using posnr_low
                                     sy-msgno
                                     sy-msgty
                                     sy-msgid
                                     sy-msgv1
                                     sy-msgv2
                                     sy-msgv3
                                     sy-msgv4.
      clear ef_perfk.
    else.
      ef_perfk = ls_knvv-perfk.
    endif.
  else.
*   If the payer is not among the delivery partners consider at least
*   the factory calendar of the ship-to party
    ls_vtcom-kunnr = is_kuwev-kunnr.
    ls_vtcom-vkorg = likp-vkorg.
    ls_vtcom-vtweg = rv50a-vtweg.
    ls_vtcom-spart = rv50a-spart.

    call function 'VIEW_KNVV'
      exporting
        comwa   = ls_vtcom
      importing
        knvv_wa = ls_knvv
      exceptions
        no_knvv = 1
        others  = 2.

    if sy-subrc ne 0.
      perform message_handling using posnr_low
                                     sy-msgno
                                     sy-msgty
                                     sy-msgid
                                     sy-msgv1
                                     sy-msgv2
                                     sy-msgv3
                                     sy-msgv4.
      clear ef_perfk.
    else.
      ef_perfk = ls_knvv-perfk.
    endif.

  endif.

endform.                    "invoice_calendar_determine