*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KORR_CHECK_LIEFERRELE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_CHECK_LIEFERRELEVANZ
*&---------------------------------------------------------------------*
*       Prüfen Lieferrelevanz einer Auftragsposition
*----------------------------------------------------------------------*
*      <- sy-subrc = 0 nicht relevant
*                    1 nicht bearbeitet
*                    2 teilweise bearbeitet
*                    3 vollständig bearbeitet
*                    4, 8, vbup nicht gefunden                         *
*----------------------------------------------------------------------*
form korr_check_lieferrelevanz using    value(pv_vbeln) like vbup-vbeln
                                        value(pv_posnr) like vbup-posnr
                               changing pv_lfgsa        like vbup-lfgsa.

  field-symbols:
    <ls_vbup>  type vbupvb
  .

  clear pv_lfgsa.
  read table xvbup assigning <ls_vbup>
                   with key vbeln = pv_vbeln
                            posnr = pv_posnr.
  check sy-subrc = 0.
  pv_lfgsa = <ls_vbup>-lfgsa.

endform.                               " KORR_CHECK_LIEFERRELEVANZ