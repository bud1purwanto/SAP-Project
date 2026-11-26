*&---------------------------------------------------------------------*
*&  Include           MV50AF0B_BUILD_ADDRESS_SHORT_F                   *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  build_address_short_form
*&---------------------------------------------------------------------*
*       The address of the ship-to party or the vendor is converted to
*       a single line according to the country specific postal address
*       conventions
*----------------------------------------------------------------------*
form build_address_short_form
     tables   ct_xvbadr       structure sadrvb
     using    if_adrnr        like vbpa-adrnr
     changing cf_txtwe        like rv50a-txtwe.

  data: ls_kupav like kupav,
        lf_txtpa type ad_line_s.

  ls_kupav-adrnr        = if_adrnr.
  ls_kupav-address_type = '1'.

  call function 'SD_ADDRESS_BUILD'
    exporting
      i_kupav = ls_kupav
    importing
      e_txtpa = lf_txtpa
    tables
      xvbadr  = ct_xvbadr.

  cf_txtwe = lf_txtpa.

endform.                    " build_address_short_form
*&---------------------------------------------------------------------*
*&      Form  build_adress_dialog (n_532800)
*&---------------------------------------------------------------------*
form build_address_dialog.

  field-symbols: <ls_xvbpa> type vbpavb.

  if likp-vbtyp ca vbtyp_mmli.
    loop at xvbpa assigning <ls_xvbpa>
                  where vbeln eq likp-vbeln
                    and posnr eq posnr_low
                    and parvw eq parvw_lf.
      perform build_address_short_form tables   xvbadr
                                       using    <ls_xvbpa>-adrnr
                                       changing rv50a-txtwe.
      exit.
    endloop.
  else.
    loop at xvbpa assigning <ls_xvbpa>
                  where vbeln eq likp-vbeln
                    and posnr eq posnr_low
                    and parvw eq parvw_we.
      perform build_address_short_form tables   xvbadr
                                       using    <ls_xvbpa>-adrnr
                                       changing rv50a-txtwe.
      exit.
    endloop.
  endif.

endform.                    " build_adress_dialog