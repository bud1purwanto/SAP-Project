*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_LIST_CURRENT_I                              *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_LIST_CURRENT_I                                     *
*---------------------------------------------------------------------*
*       Ausgabe des druckaufbereiteten Auftrags auf dem Bildschirm    *
*---------------------------------------------------------------------*
form fcode_list_current_i using h185f structure t185f
                                h185  structure t185
                                h185v structure t185v.

  data: da_xnast like vnast occurs 0 with header line,
        da_ynast like nast occurs 0 with header line,
        da_xvbfa like vbfa occurs 0 with header line,
        da_preview_processed(1) type c.

* Objektkey aufbauen
  move  vbak-vbeln to xobjky_pos.
  write vbap-posnr to xobjky_pos+10.
* Nachrichtenfindung durchführen
  IF T185F-TRTYP NE 'A' OR
     XVBAK_UPDKZ EQ UPDKZ_NEW.
* Kommunikationsblock Kopf neu aufbauen
    read table xvbkd index 1.
    na_vbkd = xvbkd.
    perform xvbuk_uebersicht_vorbereiten(sapfv45k).
    call function 'COMMUNICATION_AREA_KOMKBV1'
         exporting
              msg_vbak  = vbak
              msg_vbkd  = na_vbkd
              msg_vbuk  = vbuk
              msg_trtyp = t180-trtyp
         tables
              tab_vbpa  = xvbpa
              tab_vbap  = xvbap
              tab_part  = part.
* Kommunikationsblock Position aufbauen
    perform xvbup_lesen(sapfv45p) using vbak-vbeln vbap-posnr.
    vbup = xvbup.
    call function 'COMMUNICATION_AREA_KOMPBV1'
         exporting
              msg_vbap = vbap
              msg_vbkd = vbkd
              msg_vbup = vbup
* EHS environment
              msg_vbak = vbak
         tables
              tab_vbpa = xvbpa
              tab_part = part.
    if t185f-trtyp = charv.
      loop at xvbap where posnr = vbap-posnr.  " looking for correct xvbap
        exit.
      endloop.
      if xvbap-updkz = charu.
* Kommunikationsblock alt aufbauen
        perform yvbap_lesen(sapfv45p) using vbap-posnr sy-tabix.
        vbap = yvbap.
        perform yvbkd_lesen(sapfv45k) using vbap-posnr sy-tabix ' '.
        if sy-subrc = 0.
          vbkd = yvbkd.
        else.
          vbkd-posnr = 0.
          perform yvbkd_lesen(sapfv45k) using vbkd-posnr sy-tabix ' '.
          if sy-subrc = 0.
            vbkd = yvbkd.
          else.
            read table xvbkd index 1.
            vbkd = xvbkd.
          endif.
        endif.
        yvbup-mandt = vbak-mandt.
        yvbup-vbeln = vbak-vbeln.
        yvbup-posnr = vbap-posnr.
        read table yvbup.
        if sy-subrc = 0.
          vbup = yvbup.
        endif.
      endif.
    endif.
    call function 'COMMUNICATION_AREA_KOMPBV1'
         exporting
              msg_old  = 'X'
              msg_vbap = vbap
              msg_vbkd = vbkd
              msg_vbup = vbup
         tables
              tab_vbpa = xvbpa
              tab_part = part.
* Nachrichtenfindung durchführen
    call function 'MESSAGING'
         exporting
              applikation = tvak-kappl
              msg_objky   = xobjky_pos
              schema      = tvap-kalsm
              pi_item     = charx
         tables
              msg_part    = part.
  endif.

  call function 'RV_MESSAGES_GET'
       exporting
            msg_kappl      = tvak-kappl
            msg_objky_from = xobjky_pos
       tables
            tab_xnast      = da_xnast
            tab_ynast      = da_ynast.

* prüfen, ob überhaupt relevante Nachrichten zur Druckanzeige da sind
  LOOP AT DA_XNAST WHERE NACHA EQ CHAR1 OR
                         NACHA EQ CHAR2.
    exit.
  endloop.
  if sy-subrc eq 0.
* XVBFA in Struktur VBFA an SD_PUSH_ITEM übergeben
    loop at xvbfa.
      move-corresponding xvbfa to da_xvbfa.
      append da_xvbfa.
    endloop.
* aktuelle Daten an FUGR V45I übergeben
    call function 'SD_PUSH_ITEM'
         exporting
              i_vbak  = vbak
         tables
              i_xvbap = xvbap
              i_xvbep = xvbep
              i_xvbfa = da_xvbfa
              i_xvbkd = xvbkd
              i_xvbpa = xvbpa
              i_xvbup = xvbup.

    call function 'RV_PRICE_PRINT_GET_BUFFER'
         exporting
              i_init              = space
              i_vbeln             = vbak-vbeln
              i_print_from_buffer = space
         tables
              t_komv              = xkomv.

* Ausgabe aufrufen
    call function 'RV_MESSAGE_DIALOG'
         exporting
              pi_kappl              = tvak-kappl
              pi_objky              = xobjky_pos
              pi_kschl              = tvak-kschl
              pi_data_from_buffer   = charx
              pi_quick_preview      = space
              pi_quick_preview_opt  = charx
              PI_FAXOUTPUT          = CHARX
         importing
              preview_processed     = da_preview_processed
         exceptions
              cancel                = 1
              no_message            = 2
              message_not_printable = 2
              PRINT_ERROR           = 3
              OTHERS                = 4.

    case sy-subrc.
      when 0.
        if da_preview_processed eq charx.
          message s103.
        endif.
      when 1.
      when 2.
        message s102.
      when 3.
        message s104.
      when others.
        MESSAGE S104.
    endcase.
  else.
    message s102.
  endif.

endform.