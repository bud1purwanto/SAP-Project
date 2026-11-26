*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S05                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_delete_header_after_split
*&---------------------------------------------------------------------*
form spe_delete_header_after_split using if_vbeln like likp-vbeln
                                         if_exnum like likp-exnum
                                         if_vbtyp like likp-vbtyp.

  data: lf_ft_basis like eikp-ahbas.

* Group
  delete cvbls where vbeln_lif eq if_vbeln.
  delete cvbss where vbeln eq if_vbeln.


* Partner
  loop at xvbpa where vbeln eq if_vbeln.
    delete xvbadr where adrnr eq xvbpa-adrnr.
    delete xvbpa.
  endloop.

* Conditions
  delete tkomv where knumv eq xlikp-knump.

* Incompleteness data:
  perform uc_delete_header(sapfv50u) using if_vbeln.

* Status
* Performance: If no modified status entries and no entry for the
* current delivery exist in XVBUK no actions are necessary
* (XVBUK_PFLEGEN has not been called before)
  loop at xvbuk transporting no fields                      "470
                where updkz ca 'UI'.
    exit.
  endloop.
  if sy-subrc ne 0.
    read table xvbuk with key mandt = sy-mandt
                              vbeln = if_vbeln
                     binary search
                     transporting no fields.
  endif.
  if sy-subrc eq 0.
    perform xvbuk_pflegen(sapfv50k).
    call function 'RV_XVBUK_DELETE'
      exporting
        f_vbeln = if_vbeln
      tables
        fxvbuk  = xvbuk
        fyvbuk  = yvbuk.
  endif.

* Texts
  perform kopftexte_loeschen_einzeln(sapfv45t) using charl
                                                     if_vbeln
                                                     tvlk-txtgr
                                                     space.

* Export data
  if not if_exnum is initial.
    if ( if_vbtyp eq vbtyp_liav ) or
       ( if_vbtyp eq vbtyp_grwe ) .
      lf_ft_basis = '1LA'.
    else.
      lf_ft_basis = '2LI'.
    endif.

    call function 'EXPIMP_GENERAL_DATA_MAINTAIN'
      exporting
        exnum      = if_exnum
        hland      = tvst-aland
        trtyp      = chard
        i_ft_basis = lf_ft_basis.
  endif.

* Delete header physically
  if if_vbeln ca '$'.
    delete xlikp where vbeln eq if_vbeln.
  endif.

endform.                    " spe_delete_header_after_split