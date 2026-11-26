*----------------------------------------------------------------------*
***INCLUDE MV45AO0P_PREISF_POS_VORB .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PREISFINDUNG_VORBEREITEN_POSIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module preisfindung_vorbereiten_posit output.

* reset global display_mode variable which has to be redetermined
* by every new module call
  clear display_mode.

* hier kommt noch eine Datenvorbereitung wie in FCODE_PKON
* DISPLAY_MODE setzen etc.

  CLEAR pricing_header.

  if svbap-tabix > 0.
    read table xvbap index svbap-tabix.
  endif.

  perform vbap_bearbeiten_vorbereiten(sapfv45p).
  if vbap-posar = charb.
*     h185f-fcode = fcode_zurueck.
    t185f-fcode = fcode_zurueck.
    exit.
  endif.
  perform preisfindung_vorbereiten(sapfv45p) using 'P'.
* data: display_mode.
  if tkomp-kaend_typ(1) = '*'.
    display_mode = 'X'.
  endif.

  if /CBAD/CL_SWITCH_CHECK=>/CBAD/SD_SFWS_SC1( ) eq abap_true.
*   Contract Billing: If ACRN conditions are envolved, these condition types
*   must be changeable only if the order item is already billed
*   only for the user parameter 'CBAD_SD_ACRN'
    if tkomp-kaend_typ(1) eq '*'     and
       tvak-kschl_budget  is initial.
      display_mode = 'X'.
    else.
      if /CBAD/CL_SWITCH_CHECK=>/CBAD/SD_ACRN( ) eq abap_true.
        clear display_mode.
      ENDIF.
    endif.
  endif.

* Rechnungskorrektur (bei Gut- oder Lastschrift dürfen die Konditionen
* der automatisch erzeugten Gut-/Last Position nicht eingabebereit sein)
  if vbak-vbklt = vbklt_rech_korr.
    if ( vbak-vbtyp = vbtyp_ganf and vbap-shkzg = charx  and
         not vbap-vgpos is initial                           ) or
       ( vbak-vbtyp = vbtyp_lanf and vbap-shkzg = charx  and
         not vbap-vgpos is initial                           ).
      display_mode = 'X'.
    endif.
  endif.

endmodule.                 " PREISFINDUNG_VORBEREITEN_POSIT  OUTPUT