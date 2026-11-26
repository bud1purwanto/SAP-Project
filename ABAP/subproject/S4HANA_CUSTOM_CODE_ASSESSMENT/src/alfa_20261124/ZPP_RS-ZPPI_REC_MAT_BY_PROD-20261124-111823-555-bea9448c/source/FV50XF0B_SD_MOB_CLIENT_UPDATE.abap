***INCLUDE FV50XF0B_SD_MOB_CLIENT_UPDATE .
*---------------------------------------------------------------------*
*       FORM SD_MOB_CLIENT_UPDATE                                     *
*---------------------------------------------------------------------*
*       Status-Update Mobile-clients
*---------------------------------------------------------------------*
form sd_mob_client_update.

  data: lt_fmtab_501014  like fmrfc   occurs 0 with header line,
        ls_xvbuk         like vbukvb,
        lv_sofortauftrag like v50agl-sofauftrag.

  data: lc_infofunc like tfdir-funcname value 'CRS_SALES_GET_INFO',
        lv_proxy(1) type c.

  data: lt_vbak_keytab like sales_key occurs 0 with header line,
        lt_csltok type table of bapicsltok with header line,
        ls_vbak_keytab like sales_key.

  check v50agl-no_crm_order_update eq space.

  call function 'BF_FUNCTIONS_FIND'
    exporting
      i_event       = '00501014'
    tables
      t_fmrfc       = lt_fmtab_501014
    exceptions
      nothing_found = 1
      others        = 2.
  if sy-subrc eq 0.

*---Sofortauftragskennzeichen übernehmen
    lv_sofortauftrag = v50agl-sofauftrag.
*---Bei Sofortauftrag muss noch folgendes geprüft werden: Falls der
*   Sofortauftrag durch Änderung eines CRM Auftrags erzeugt wird (z.B.
*   Entfernen der Liefersperre), so müssen die Daten von der Lieferung
*   versendet werden.
    if v50agl-sofauftrag = charx.
      do 1 times.
*-------Prüfen, ob Aufruf über Proxy (Anlegen/Ändern aus dem CRM)
        call function 'FUNCTION_EXISTS'
          exporting
            funcname           = lc_infofunc         "#EC NOTEXT
          exceptions
            function_not_exist = 1
            others             = 2.
        if sy-subrc = 0.
          call function lc_infofunc
            importing
              e_send_together = lv_proxy.
          check: lv_proxy is initial.
        endif.
*-------Nur bei CRM Aufträgen
        check vbak-vbkla+2(1) = charm.
*-------Ab Release 30
        check vbak-vbkla+3(1) >= '3'.
*-------Updatekennzeichen Auftrag über Status ermitteln
        read table xvbuk into ls_xvbuk with key vbeln = vbak-vbeln.
        check sy-subrc = 0.
*-------Weiter bei Update des Auftrags
        check ls_xvbuk-updkz = updkz_update.
*-------Daten müssen nun an das CRM versendet werden
        clear lv_sofortauftrag.
      enddo.
    endif.

*---Token für CRM bestimmen, falls kein Sofortauftrag
    if v50agl-sofauftrag is initial.
      loop at xvbuk where vbtyp ca vbtyp_verk
                    and   ( updkz = updkz_update  or
                            updkz = updkz_old ).
        ls_vbak_keytab-vbeln = xvbuk-vbeln.
        insert ls_vbak_keytab into table lt_vbak_keytab.
      endloop.

      call function 'SD_CSLTOK_READ_FROM_BUFFER'
        tables
          it_vbak_keytab     = lt_vbak_keytab
          et_csltok          = lt_csltok
        exceptions
          csltok_not_found   = 1
          others             = 2.
    endif.

    if v50agl-synchron eq charx or lv_sofortauftrag eq charx.
      call function 'SD_CRM_ORDERDATA_FROM_DLV_INV'
        exporting
          call_obj   = charl
          rush_order = lv_sofortauftrag
        tables
          xvbuk      = xvbuk
          yvbuk      = yvbuk
          xvbup      = xvbup
          yvbup      = yvbup
          xvbfa      = xvbfa
          yvbfa      = yvbfa
          i_fmtab    = lt_fmtab_501014
          xlikp      = xlikp
          xlips      = xlips
          ylips      = ylips
          t_csltok   = lt_csltok.
    else.
      call function 'SD_CRM_ORDERDATA_FROM_DLV_INV' in update task
        exporting
          call_obj   = charl
          rush_order = lv_sofortauftrag
        tables
          xvbuk      = xvbuk
          yvbuk      = yvbuk
          xvbup      = xvbup
          yvbup      = yvbup
          xvbfa      = xvbfa
          yvbfa      = yvbfa
          i_fmtab    = lt_fmtab_501014
          xlikp      = xlikp
          xlips      = xlips
          ylips      = ylips
          t_csltok   = lt_csltok.
    endif.

  endif.

endform.                    "sd_mob_client_update