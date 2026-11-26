*---------------------------------------------------------------------*
*       FORM DISPOSITION_AUFRUFEN                                     *
*---------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*
form disposition_aufrufen.

  data: da_vbeln like vbak-vbeln,
        da_posnr like vbap-posnr.

  loop at xvbap where updkz ne updkz_delete
                  and sobkz eq chare.

* Bei Kontierung muß Projekt oder RK-Objekt vorhanden sein
    if xvbap-kzvbr ne space.
      case xvbap-kzvbr.
        when kzvbr_e.
          check not
              ( xvbap-objnr is initial and xvbap-vbelv is initial ).
        when kzvbr_p.
          check not xvbap-ps_psp_pnr is initial.
      endcase.
    endif.

* Relevante Position
    perform t459a_select using xvbap-bedae
                               charx
                               sy-subrc.
    perform t459k_select(sapfv45v) using t459a-bedar
                                         charx
                                         sy-subrc.
    check not t459k-autpl is initial.

* Bedarf da?
    loop at xvbep where updkz ne updkz_delete
                    and vbeln eq xvbap-vbeln
                    and posnr eq xvbap-posnr.
      exit.
    endloop.
    check sy-subrc = 0 and
      not ( xvbep-bdart is initial and xvbep-plart is initial ).

* MRP_KD_AUFTRAG_RFC führt automatisch eine Einzelplanung (MD50) durch
* Er muß mit der verursachenden Belegposition aufgerufen werden
    if not xvbap-vbelv is initial.
      da_vbeln = xvbap-vbelv.
      da_posnr = xvbap-posnv.
    else.
      da_vbeln = vbak-vbeln.
      da_posnr = xvbap-posnr.
    endif.

*   Bei Konfigurationsänderung automatische Planung
    if xvbap-conup is initial.
*     Haben sich die Bedarfe geändert?
*     1. Einzelbedarfe
      loop at xvbbe transporting no fields
                    where vbeln = xvbap-vbeln and
                          posnr = xvbap-posnr and
                          updkz ne updkz_old.
        exit.
      endloop.
      if sy-subrc ne 0.
        loop at yvbbe transporting no fields
                      where vbeln = xvbap-vbeln and
                            posnr = xvbap-posnr and
                            updkz eq updkz_delete.
          exit.
        endloop.
        if sy-subrc ne 0.
*       2. Summenbedarfe
          loop at xvbbs transporting no fields
                        where matnr = xvbap-matnr and
                              werks = xvbap-werks and
                              updkz ne updkz_old.
            exit.
          endloop.
          if sy-subrc ne 0.
            loop at yvbbs transporting no fields
                          where matnr = xvbap-matnr and
                                werks = xvbap-werks and
                                updkz eq updkz_delete.
              exit.
            endloop.
*           Keine Bedarfsänderung: Disposition nicht aufrufen
            check sy-subrc eq 0.
          endif.
        endif.
      endif.
    endif.

    call function 'MRP_KD_AUFTRAG_RFC' in background task
         exporting
              ikdauf = da_vbeln
              ikdpos = da_posnr
              imatnr = xvbap-matnr
              iwerks = xvbap-werks.

  endloop.

endform.