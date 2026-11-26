*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_BEDS                                        *
*----------------------------------------------------------------------*
* Display purchase order as preceding document
*
form fcode_beds.

  data: lf_vgbel type bstnr,
        lf_destination like tblsysdest-rfcdest,
        lf_vgsys like lips-vgsys.

  case taxi_screen_group.
    when c_taxi_scrgrp_item.
      lf_vgbel = gs_lips_main-vgbel.
      lf_vgsys = gs_lips_main-vgsys.
    when c_taxi_scrgrp_item_inb.
      lf_vgbel = gs_lips_main-vgbel.
      lf_vgsys = gs_lips_main-vgsys.
    when c_taxi_scrgrp_batch.
      lf_vgbel = gs_lips_chsp-vgbel.
      lf_vgsys = gs_lips_chsp-vgsys.
  endcase.

  if not lf_vgsys is initial.                               "AIP

    call function 'LOG_SYSTEM_GET_RFC_DESTINATION'
         exporting
              logical_system                = lf_vgsys
         importing
              rfc_destination               = lf_destination
         exceptions
              no_rfc_destination_maintained = 1
              others                        = 2.
    if sy-subrc ne 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
    if not lf_destination is initial.
      call function 'SD_SALESDOCUMENT_DISPLAY'
        destination
          lf_destination
        exporting
          i_vbeln            = lf_vgbel
          i_vbtyp            = 'V'
        exceptions
          no_authority       = 1
          others             = 2.

      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.
  else.
    call function 'ME_DISPLAY_PURCHASE_DOCUMENT'
         exporting
              i_ebeln              = lf_vgbel
              i_enjoy              = 'X'
         exceptions
              not_found            = 1
              no_authority         = 2
              invalid_call         = 3
              preview_not_possible = 4
              others               = 5.
    if sy-subrc <> 0.
      message id sy-msgid type 'S' number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
  endif.
endform.