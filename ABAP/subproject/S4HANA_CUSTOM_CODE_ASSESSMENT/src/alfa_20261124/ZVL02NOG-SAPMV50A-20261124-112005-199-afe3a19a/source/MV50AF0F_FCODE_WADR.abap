*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_WADR                                        *
*----------------------------------------------------------------------*
* Sends pop up for maintaining the address of the ship-to party

form fcode_wadr.

  data: lf_objectkey type swo_typeid,
        lf_displayonly type c.

  lf_objectkey = likp-vbeln.

* This function call can be omitted if the whole partner processing
* is managed by function group LV09A
  call function 'SD_PARTNER_DATA_PUT'
       exporting
            fic_objecttype      = 'LIKP'
            fic_objectkey       = lf_objectkey
       tables
            frt_xvbpa           = xvbpa            "#EC ENHOK
            frt_yvbpa           = yvbpa            "#EC ENHOK
            frt_xvbuv           = xvbuv
            frt_hvbuv           = hvbuv
            frt_xvbadr          = xvbadr
            frt_yvbadr          = yvbadr
       exceptions
            no_object_specified = 1
            others              = 2.
  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Address is not changeable in display mode or when goods issue has
* been posted or when document has been sent to a decentral WMS
  if t180-trtyp eq chara or
     vbuk-wbstk eq charc or
     ( likp-vlstk eq 'B' and v50agl-dlv_change eq space ) or
     ( likp-vlstk eq 'E' and likp-verursys is initial ) or
     likp-vlstk eq 'C' or
     likp-sakes eq charb.                   "GTS Safe Keeping Status
    lf_displayonly = charx.
  else.
    lf_displayonly = space.
  endif.

  call function 'SD_PARTNER_ADDRESS_DIALOG'
       exporting
            fic_objecttype       = 'LIKP'
            fic_objectkey        = lf_objectkey
            fif_parvw            = 'WE  '
            fif_posnr            = posnr_low
            fif_parnr            = likp-kunnr
            fif_display_only     = lf_displayonly
       exceptions
            parameter_incomplete = 1
            object_not_found     = 2
            no_address           = 3
            partner_not_found    = 4
            others               = 5.
  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* If something has been changed the callback routine
* PARTNER_CALLBACK_GENERAL is performed (MV50AF0P)

endform.