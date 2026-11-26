*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRICING_PROCESS_HEAD                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PRICING_PROCESS_HEAD
*&---------------------------------------------------------------------*
form pricing_process_head.

* If FCODE is intended to leave the current screen or if the button for
* the activation of a new pricing has been pressed: new pricing is
* carried out
  if fcode ne fcode_gleiche_seite.
    if not global_pricing_type is initial.
      perform preisfindung_gesamt using global_pricing_type.
    endif.
    if global_pricing_type ne chare.
      perform preisfindung_gesamt using chare.
    endif.

    modify tkomk index tkomp-ix_komk.
*   Activation of a new pricing: reset FCODE to neutral value
    if fcode eq 'PRSE'.
      fcode = fcode_gleiche_seite.
    endif.
  endif.

  perform uc_upd_request(sapfv50u) using charx              "n_531900
                                         posnr_low
                                         posnr_low
                                         posnr_low.

endform.                               " PRICING_PROCESS_HEAD