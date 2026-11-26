***INCLUDE FV50XF0B_XLIKP_AUS_LIKP_FUELLE .
*&---------------------------------------------------------------------*
*&      Form  XLIKP_AUS_LIKP_FUELLEN
*&---------------------------------------------------------------------*
form xlikp_aus_likp_fuellen.

  if v50agl-sammelgang ne space or
     v50agl-mult       ne space .

*   there can be deliveries deleted, which are on the Database "AIP
*   already they must be kept in xlikp, but are not relevant to
*   redetermine the header-status (create a new one... )
    loop at xlikp where updkz ne updkz_delete
                    and updkz ne updkz_mark_del.     "mark for deletion
      exit.
    endloop.

    move-corresponding xlikp to likp.
    move-corresponding xlikp to likpd.

  else.                                "only one delivery to process
    if xlikp_updkz is initial.
      if t180-trtyp eq charh.
        xlikp_updkz = updkz_new.
      else.
        xlikp_updkz = updkz_update.
*       In change mode it has to be ensured that table YLIKP is filled,
*       too. The structure YLIKP is filled when the document is read
*       from the database.
        read table ylikp index 1 transporting no fields.
        if sy-subrc ne 0.
          append ylikp.
        endif.
      endif.
    endif.
    read table xlikp with key mandt = likp-mandt
                              vbeln = likp-vbeln.
    if sy-subrc = 0.
      if likpd is initial.                                   "v_n_792288
        likpd-trtrm = xlikp-trtrm.
        likpd-vstrm = xlikp-vstrm.
      endif.                                                 "^_n_792288
      move-corresponding likp  to xlikp.
      move-corresponding likpd to xlikp.
      xlikp-updkz = xlikp_updkz.
      modify xlikp index sy-tabix.
    else.
      move-corresponding likp  to xlikp.
      move-corresponding likpd to xlikp.
      xlikp-updkz = xlikp_updkz.
      append xlikp.
    endif.
  endif.

endform.                               " XLIKP_AUS_LIKP_FUELLEN