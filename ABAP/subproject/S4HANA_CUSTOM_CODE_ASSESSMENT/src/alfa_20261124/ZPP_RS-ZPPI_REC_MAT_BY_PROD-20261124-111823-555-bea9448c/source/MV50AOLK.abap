************************************************************************
*                                                                      *
* PBO Module Lieferungskopf                                            *
*                                                                      *
************************************************************************


*---------------------------------------------------------------------*
*       MODULE LIKP_BEARBEITEN_VOR(bereiten)                          *
*---------------------------------------------------------------------*
*       Bearbeiten des Kopfes der Lieferung                           *
*---------------------------------------------------------------------*
module likp_bearbeiten_vor output.

  perform likp_bearbeiten_vorbereiten(sapfv50k).
  perform likp_prepare_dynpro(sapfv50k).

endmodule.                    "LIKP_BEARBEITEN_VOR OUTPUT
*eject

*&---------------------------------------------------------------------*
*&      Module  ALV_STATUS_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
module alv_status_display output.

* init ALV data
  perform init_alv_status_display.
* fill ALV data.
  perform fill_alv_status_display tables xvbup
                                         xlips
                                         xvbuk
                                         ilips              "46B
                                  using  xlikp
                                         xlips_umfang.

* field catalog and display options
  perform set_display_character.
* display delivery header status
  perform header_status_display.
* display delivery header status
  perform item_status_display.

endmodule.                             " ALV_STATUS_DISPLAY  OUTPUT