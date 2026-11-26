*----------------------------------------------------------------------*
*   INCLUDE FV50XF0K_KORR_DELETE_LEEREN_KO                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_DELETE_LEEREN_KOPF
*&---------------------------------------------------------------------*
form korr_delete_leeren_kopf changing cf_subrc like sy-subrc.

  data: lf_save_tabix   like sy-tabix.
  data: lf_delete_sw(1) type c.
  data: ls_xlips like xlips.

  clear cf_subrc.
  check v50agl-sammelgang = charx.
  check v50agl-UCDEL_TO_DEL is initial.                            "AIP

  sort xlips by mandt vbeln posnr.
* wenn alle Positionen gelöscht wurden, wird auch der leere Kopf gelösch
  read table xlips with key vbeln = xlikp-vbeln
  binary search
  transporting no fields.
  if sy-subrc > 0.
*   Es existieren weder gelöschte noch zu liefernde Positionen
    perform lieferkopf_loeschen(saplv50s).
    cf_subrc = 1.
  else.
* Prüfen, ob alle existierenden Positionen gelöscht sind.
    lf_save_tabix = sy-tabix.
    lf_delete_sw  = ja.
    field-symbols <ls_xlips> structure xlips default ls_xlips.

    loop at   xlips
    assigning <ls_xlips>
    from      lf_save_tabix.
      if <ls_xlips>-vbeln <> xlikp-vbeln.
        exit.
      endif.
      if <ls_xlips>-updkz <> updkz_delete.
        lf_delete_sw = nein.
        exit.
      endif.
    endloop.

    if lf_delete_sw = ja.
      perform lieferkopf_loeschen(saplv50s).
      cf_subrc = 1.
    endif.
  endif.

endform.                               " KORR_DELETE_LEEREN_KOPF