*---------------------------------------------------------------------*
*       FORM ALE_POS_ERMITTELN                                        *
*---------------------------------------------------------------------*
*       Ermitteln der ALE-relevanten Auftragspositionen, die an       *
*       die Verbuchung übergeben werden, um ein Workflow-Ereignis     *
*       versorgen                                                     *
*---------------------------------------------------------------------*
form ale_pos_ermitteln.

  data: da_tabix like sy-tabix.

  loop at xvbep where updkz ne updkz_delete
                and   bnfpo  > 0.

* Positionstyp nachlesen
    perform xvbap_lesen_direkt(sapfv45p) using xvbep-posnr
                                               da_tabix.

    perform tvap_select(sapmv45a) using xvbap-pstyv
                                        space
                                        sy-subrc.
* ALE-Relevanz
    if tvap-alekz ne space.
      ale_flag = charx.
      read table vb_key with key mandt = tvap-mandt
                                 vbeln = xvbap-vbeln
                                 posnr = xvbap-posnr
                        binary search.

      if sy-subrc ne 0.
        vb_key-mandt = tvap-mandt.
        vb_key-vbeln = xvbap-vbeln.
        vb_key-posnr = xvbap-posnr.
        insert vb_key index sy-tabix.
      endif.
    endif.

  endloop.

  describe table vb_key lines da_tabix.
  if da_tabix = 0.
    clear ale_flag.
  endif.

endform.