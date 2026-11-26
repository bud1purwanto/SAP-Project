*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_INITIALIZE_CA                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PARTNER_INITIALIZE_CALLBACK
*&---------------------------------------------------------------------*
form partner_initialize_callback.

  data: lf_objectkey type swo_typeid.
  field-symbols: <ls_xvbpa> like vbpavb.
  lf_objectkey = likp-vbeln.

  call function 'SD_PARTNER_CALL_BACK_SET_EVENT'
       exporting
            fic_objecttype       = 'LIKP'
            fic_objectkey        = lf_objectkey
            fif_program          = 'SAPMV50A'
            fif_subroutine       = 'PARTNER_CALLBACK_GENERAL'
*           FIF_EVENT            = ''
       exceptions
            parameter_incomplete = 1
            others               = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Fill initial values for country and transportation zone of the ship-to
* party
  read table xvbpa assigning <ls_xvbpa>                     "HP_377160
                   with key vbeln = likp-vbeln
                            posnr = posnr_low
                            parvw = parvw_we.
  if sy-subrc eq 0.
    gf_we_land1 = <ls_xvbpa>-land1.
    gf_we_lzone = <ls_xvbpa>-lzone.
  endif.

endform.                               " PARTNER_INITIALIZE_CALLBACK