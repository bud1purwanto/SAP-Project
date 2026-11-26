*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_ADDRESS_RENUMBER_POST                             *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM ADDRESS_RENUMBER_AND_POST                                *
*---------------------------------------------------------------------*
*       Release 4.6: Since the adress maintenance is managed
*       completely by the CAM renumbering and posting of addresses
*       is done in a single step. It is assumed that the final
*       document numbers are already assigned to table VBPA.
*---------------------------------------------------------------------*
form address_renumber_and_post.

  data: lf_update_task type c.

  if v50agl-synchron ne space.
    lf_update_task = space.
  else.
    lf_update_task = charx.
  endif.

  call function 'SD_PARTNER_ADDRESSES_TO_DB'
       exporting
            fif_in_update_task             = lf_update_task
            object                         = 'VBPA'
            fif_trtyp                      = t180-trtyp       "n_744218
       tables
            fet_xvbpa                      = xvbpa
            fet_xvbadr                     = xvbadr
       exceptions
            number_could_not_be_determined = 1
            cam_saving_error               = 2
            document_number_missing        = 3
            others                         = 4.
  if sy-subrc ne 0.
    message id sy-msgid type 'A' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

** Now all new addresses should be on database
*  loop at xvbadr assigning <ls_xvbadr>
*                 where updkz eq updkz_new.
*    <ls_xvbadr>-updkz = updkz_old.
*  endloop.

endform.